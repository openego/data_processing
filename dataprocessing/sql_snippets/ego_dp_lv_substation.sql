/*
MVLV Substation (ONT)
Create a lattice (regular fishnet grid) with 360m.
Create MVLV Substation from lattice centroid.

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee, jong42"
*/


-- Create a lattice (regular fishnet grid) with 360m
DROP TABLE IF EXISTS    model_draft.ego_lattice_360m_lv;
CREATE TABLE            model_draft.ego_lattice_360m_lv (
    id      serial NOT NULL,
    la_id   integer,
    geom    geometry(Polygon,3035),
    CONSTRAINT ego_lattice_360m_lv_pkey PRIMARY KEY (id) );

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_demand_loadarea','ego_dp_lv_substation.sql',' ');

-- lattice on the bbox of loadareas
INSERT INTO model_draft.ego_lattice_360m_lv (geom, la_id)
    SELECT 
        -- Normalfall: mehrere Zellen pro Grid
        CASE WHEN ST_AREA (geom) > (3.1415926535 * 1152) 
        THEN    ST_SETSRID(ST_CREATEFISHNET(
                ROUND((ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))) /360)::integer,
                ROUND((ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))) /360)::integer,
                360,
                360,
                ST_xmin (box2d(geom)),
                ST_ymin (box2d(geom))
            ),3035)::geometry(POLYGON,3035)  
        -- Spezialfall: bei kleinene Lastgebieten erstelle nur eine Zelle
        ELSE    ST_SETSRID(ST_CREATEFISHNET(
                1,
                1,
                (ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))),
                (ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))),
                ST_xmin (box2d(geom)),
                ST_ymin (box2d(geom))
            ),3035)::geometry(POLYGON,3035) 
        END     AS geom, 
        id AS la_id
    FROM    model_draft.ego_demand_loadarea;

-- index GIST (geom)
CREATE INDEX ego_lattice_360m_lv_geom_idx
    ON model_draft.ego_lattice_360m_lv USING GIST (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_lattice_360m_lv OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_lattice_360m_lv IS '{
    "comment": "eGoDP - Temporary table",
    "version": "v0.3.0" }';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_lattice_360m_lv','ego_dp_lv_substation.sql',' ');


-- Create MVLV Substation from lattice centroid
DROP TABLE IF EXISTS    model_draft.ego_grid_mvlv_substation;
CREATE TABLE            model_draft.ego_grid_mvlv_substation (
    mvlv_subst_id   serial NOT NULL,
    la_id           integer,
    subst_id        integer,
    geom            geometry(Point,3035),
    CONSTRAINT ego_grid_mvlv_substation_pkey PRIMARY KEY (mvlv_subst_id) );

-- index GIST (geom)
CREATE INDEX ego_grid_mvlv_substation_geom_idx
    ON model_draft.ego_grid_mvlv_substation USING GIST (geom);

-- Bestimme diejenigen Mittelpunkte der Grid-Polygone, die innerhalb der Lastgebiete liegen
-- Centroids from lattice, when inside loadarea
INSERT INTO model_draft.ego_grid_mvlv_substation (la_id, geom)
    SELECT DISTINCT b.id AS la_id,
            ST_CENTROID (a.geom)::geometry(POINT,3035) AS geom
    FROM    model_draft.ego_lattice_360m_lv AS a, 
            model_draft.ego_demand_loadarea AS b
    WHERE   ST_WITHIN(ST_CENTROID(a.geom),b.geom) 
            AND b.id = a.la_id;

-- Füge den Lastgebieten, die aufgrund ihrer geringen Fläche keine ONT zugeordnet bekommen haben, ihren Mittelpunkt als ONT-Standort hinzu
-- Centroid for very small Loadarea
INSERT INTO model_draft.ego_grid_mvlv_substation (geom, la_id)
    SELECT
        CASE 
            WHEN   ST_CONTAINS (geom,ST_CENTROID(area_without_ont.geom))
            THEN        ST_CENTROID(area_without_ont.geom)
            ELSE        ST_POINTONSURFACE(area_without_ont.geom)
        END,
        area_without_ont.id 
    FROM (
        SELECT geom, id
        FROM model_draft.ego_demand_loadarea
        EXCEPT
        SELECT a.geom AS geom, a.id
        FROM 	model_draft.ego_demand_loadarea AS a, 
            model_draft.ego_grid_mvlv_substation AS b
        WHERE ST_CONTAINS (a.geom, b.geom)
        GROUP BY (a.id)
        ) AS area_without_ont ;

-- grant (oeuser)
ALTER TABLE model_draft.ego_grid_mvlv_substation OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mvlv_substation IS '{
    "comment": "eGoDP - Temporary table",
    "version": "v0.3.0" }';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_grid_mvlv_substation','ego_dp_lv_substation.sql',' ');


-- Lege Buffer um ONT-Standorte und ermittle die Teile der Lastgebiete, die sich nicht innerhalb dieser Buffer befinden
-- LV Griddistrict rest
DROP TABLE IF EXISTS    model_draft.ego_grid_lv_loadarea_rest; 
CREATE TABLE            model_draft.ego_grid_lv_loadarea_rest (
    id          serial NOT NULL,
    la_id       integer,
    geom_point  geometry(Point,3035),
    geom        geometry(Polygon,3035),
    CONSTRAINT ego_grid_lv_loadarea_rest_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE model_draft.ego_grid_lv_loadarea_rest OWNER TO oeuser;

-- Insert rest
INSERT INTO model_draft.ego_grid_lv_loadarea_rest (la_id, geom)
    SELECT  c.id AS la_id,
            (ST_DUMP(ST_DIFFERENCE(c.geom, area_with_onts.geom))).geom::geometry(Polygon,3035) AS geom
    FROM (
        SELECT  ST_BUFFER(ST_UNION(a.geom),540) AS geom,b.id AS id
        FROM    model_draft.ego_grid_mvlv_substation AS a, 
                model_draft.ego_demand_loadarea AS b
        WHERE   b.geom && a.geom AND
                ST_CONTAINS(b.geom,a.geom) 
        GROUP BY b.id
        ) AS area_with_onts
        INNER JOIN model_draft.ego_demand_loadarea AS c
            ON (c.id = area_with_onts.id)
    WHERE   ST_AREA(ST_DIFFERENCE(c.geom, area_with_onts.geom)) > 0 ;

-- index GIST (geom)
CREATE INDEX ego_grid_lv_loadarea_rest_geom_idx
    ON model_draft.ego_grid_lv_loadarea_rest USING GIST (geom);

-- index GIST (geom_point)
CREATE INDEX ego_grid_lv_loadarea_rest_geom_point_idx
    ON model_draft.ego_grid_lv_loadarea_rest USING GIST (geom_point);

-- PointOnSurface for rest
UPDATE model_draft.ego_grid_lv_loadarea_rest
    SET geom_point = ST_PointOnSurface(geom) ::geometry(POINT,3035) ;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_lv_loadarea_rest IS '{
    "comment": "eGoDP - Temporary table",
    "version": "v0.3.0" }';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_grid_lv_loadarea_rest','ego_dp_lv_substation.sql',' ');


-- Bestimme die Mittelpunkte der Gebiete, die noch nicht durch ONT abgedeckt sind, und lege diese Mittelpunkte als ONT-Standorte fest
-- Add LV 
INSERT INTO model_draft.ego_grid_mvlv_substation (la_id, geom)
    SELECT  la_id,
            geom_point ::geometry(POINT,3035) 
    FROM    model_draft.ego_grid_lv_loadarea_rest;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_grid_mv_griddistrict','ego_dp_lv_substation.sql',' ');

-- subst_id from MV-griddistrict
UPDATE model_draft.ego_grid_mvlv_substation AS t1
    SET subst_id = t2.subst_id
    FROM (
        SELECT  a.mvlv_subst_id AS mvlv_subst_id,
                b.subst_id AS subst_id
        FROM    model_draft.ego_grid_mvlv_substation AS a,
                model_draft.ego_grid_mv_griddistrict AS b
        WHERE   b.geom && a.geom AND
                ST_CONTAINS(b.geom,a.geom)
        ) AS t2
    WHERE   t1.mvlv_subst_id = t2.mvlv_subst_id;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mvlv_substation IS '{
    "comment": "eGoDP - Temporary table",
    "version": "v0.3.0" }';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_mvlv_substation','ego_dp_lv_substation.sql',' ');


-- drop
--DROP TABLE IF EXISTS model_draft.ego_lattice_360m_lv;
--DROP TABLE IF EXISTS model_draft.ego_grid_lv_loadarea_rest;
