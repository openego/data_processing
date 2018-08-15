/*
OpenStreetMap power extracts

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Christian-rli; Ludee"
*/


-- Imported from GeoJSON with QGIS 
-- metadata
COMMENT ON TABLE sandbox.ego_pp_osm_deu_power_point IS '{
    "comment": "eGo - REAOSM - Temporary Table",
    "version": "v0.1" }' ;


-- Filter OSM powerplants
DROP MATERIALIZED VIEW IF EXISTS    sandbox.ego_pp_osm_deu_power_point_mview CASCADE;
CREATE MATERIALIZED VIEW            sandbox.ego_pp_osm_deu_power_point_mview AS
    SELECT  trim(both 'node/' from id) ::bigint AS osm_id,
            power,
            "generator:type" AS generator_type,
            "generator:source" AS generator_source,
            "generator:method" AS generator_method,
            ST_TRANSFORM(geom, 3035) ::geometry(Point,3035) AS geom 
    FROM    sandbox.ego_pp_osm_deu_power_point;

-- index (id)
CREATE UNIQUE INDEX ego_pp_osm_deu_power_point_mview_id_idx
    ON sandbox.ego_pp_osm_deu_power_point_mview (osm_id);

-- index GIST (geom)
CREATE INDEX ego_pp_osm_deu_power_point_mview_geom_idx
    ON      sandbox.ego_pp_osm_deu_power_point_mview
    USING   GIST (geom);

-- grant (oeuser)
ALTER TABLE sandbox.ego_pp_osm_deu_power_point_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW sandbox.ego_pp_osm_deu_power_point_mview IS '{
    "comment": "eGo - REAOSM - Temporary Table",
    "version": "v0.1" }' ;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','input','sandbox','ego_pp_osm_deu_power_point','ego_pp_osm_deu_power.sql',' ');
SELECT scenario_log('eGo_REAOSM','v0.1','output','sandbox','ego_pp_osm_deu_power_point_mview','ego_pp_osm_deu_power.sql',' ');


-- buffer with 25m for polygons around biomass in new table
DROP TABLE IF EXISTS	sandbox.ego_pp_osm_deu_power_polygon_buff25_biomass CASCADE;
CREATE TABLE		sandbox.ego_pp_osm_deu_power_polygon_buff25_biomass(
	id SERIAL,
	geom geometry(Point,3035),
	CONSTRAINT ego_pp_osm_deu_power_polygon_buff25_biomass_pkey PRIMARY KEY (id));

-- insert buffer
INSERT INTO	sandbox.ego_pp_osm_deu_power_polygon_buff25_biomass(geom)
	SELECT	ST_CENTROID(
			(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(geom, 25)
		)))).geom) ::geometry(Point,3035) AS geom
	FROM	sandbox.ego_pp_osm_deu_power_polygon
	WHERE	"generator:source" = 'biogas' OR 
		"generator:source" = 'biomass' OR
		"generator:source" = 'biofuel' OR
		"generator:source" = 'waste';

-- index GIST (geom)
CREATE INDEX ego_pp_osm_deu_power_polygon_buff25_biomass_geom_idx
    ON sandbox.ego_pp_osm_deu_power_polygon_buff25_biomass USING GIST (geom);
    
-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_load_collect_buffer100 OWNER TO oeuser;

-- metadata
COMMENT ON TABLE sandbox.ego_pp_osm_deu_power_polygon_buff25_biomass IS '{
    "comment": "eGoDP - Temporary table", 
    "version": "v0.4.2",
    "published": "none" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','input','sandbox','ego_pp_osm_deu_power_polygon','ego_pp_osm_deu_power.sql',' ');
SELECT scenario_log('eGo_REAOSM','v0.1','output','sandbox','ego_pp_osm_deu_power_polygon_buff25_biomass','ego_pp_osm_deu_power.sql',' ');




-- Allocate to REA methods
-- CREATE Placeholder table
DROP TABLE IF EXISTS    sandbox.ego_pp_osm_deu_power_point_reaosm CASCADE;
CREATE TABLE            sandbox.ego_pp_osm_deu_power_point_reaosm (
    osm_id          bigint,
    rea_method      character varying,
    subst_id        integer,
    la_id           integer,
    geom            geometry(Point,3035),
    CONSTRAINT      ego_pp_osm_deu_power_point_reaosm_pkey  PRIMARY KEY (osm_id)
    );

-- index GIST (geom)
CREATE INDEX ego_pp_osm_deu_power_point_reaosm_geom_idx
    ON      sandbox.ego_pp_osm_deu_power_point_reaosm
    USING   GIST (geom);

-- grant (oeuser)
ALTER TABLE sandbox.ego_pp_osm_deu_power_point_reaosm OWNER TO oeuser;

-- metadata
COMMENT ON TABLE sandbox.ego_pp_osm_deu_power_point_reaosm IS '{
    "comment": "eGo - REAOSM - Temporary Table",
    "version": "v0.1" }' ;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','setup','sandbox','ego_pp_osm_deu_power_point_reaosm','ego_pp_osm_deu_power.sql',' ');


-- insert M1
INSERT INTO sandbox.ego_pp_osm_deu_power_point_reaosm (osm_id, rea_method, geom)
    SELECT  osm_id,
            'M1',
            geom
    FROM    sandbox.ego_pp_osm_deu_power_point_mview
    WHERE   generator_source = 'biogas' OR generator_source = 'biomass'
    ORDER BY osm_id;

-- insert M1*
INSERT INTO sandbox.ego_pp_osm_deu_power_point_reaosm (osm_id, rea_method, geom)
    SELECT  id,
            'M1',
            geom
    FROM    sandbox.ego_pp_osm_deu_power_polygon_buff25_biomass
    ORDER BY id;

-- insert M2
INSERT INTO sandbox.ego_pp_osm_deu_power_point_reaosm (osm_id, rea_method, geom)
    SELECT  osm_id,
            'M2',
            geom
    FROM    sandbox.ego_pp_osm_deu_power_point_mview
    WHERE   generator_source = 'wind'
    ORDER BY osm_id;

-- insert M5
INSERT INTO sandbox.ego_pp_osm_deu_power_point_reaosm (osm_id, rea_method, geom)
    SELECT  osm_id,
            'M5',
            geom
    FROM    sandbox.ego_pp_osm_deu_power_point_mview
    WHERE   generator_source = 'solar'
    ORDER BY osm_id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','output','sandbox','ego_pp_osm_deu_power_point_reaosm','ego_pp_osm_deu_power.sql',' ');


-- eGo Grid District
SELECT  version
FROM    grid.ego_dp_mv_griddistrict
GROUP BY version
ORDER BY version;


-- eGoDP Grid District
DROP MATERIALIZED VIEW IF EXISTS    grid.ego_dp_mv_griddistrict_v0_4_3_mview CASCADE;
CREATE MATERIALIZED VIEW            grid.ego_dp_mv_griddistrict_v0_4_3_mview AS
    SELECT  *
    FROM    grid.ego_dp_mv_griddistrict
    WHERE   version = 'v0.4.3';

-- index (id)
CREATE UNIQUE INDEX ego_dp_mv_griddistrict_v0_4_3_mview_idx
    ON grid.ego_dp_mv_griddistrict_v0_4_3_mview (subst_id);

-- index GIST (geom)
CREATE INDEX ego_dp_mv_griddistrict_v0_4_3_mview_geom_idx
    ON      grid.ego_dp_mv_griddistrict_v0_4_3_mview
    USING   GIST (geom);

-- grant (oeuser)
ALTER TABLE grid.ego_dp_mv_griddistrict_v0_4_3_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW grid.ego_dp_mv_griddistrict_v0_4_3_mview IS '{
    "comment": "eGo - REAOSM - Temporary Table",
    "version": "v0.1" }' ;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','input','grid','ego_dp_mv_griddistrict','ego_pp_osm_deu_power.sql',' ');
SELECT scenario_log('eGo_REAOSM','v0.1','output','grid','ego_dp_mv_griddistrict_v0_4_3_mview','ego_pp_osm_deu_power.sql',' ');


-- update subst_id from eGo mv_grid_district
UPDATE sandbox.ego_pp_osm_deu_power_point_reaosm AS t1
    SET subst_id = t2.subst_id
    FROM (
        SELECT  b.osm_id AS osm_id,
                a.subst_id AS subst_id
        FROM    grid.ego_dp_mv_griddistrict_v0_4_3_mview AS a,
                sandbox.ego_pp_osm_deu_power_point_reaosm AS b
                
        WHERE   a.geom && b.geom AND
                ST_CONTAINS(a.geom,b.geom)
        ) AS t2
    WHERE   t1.osm_id = t2.osm_id;



-- eGoDP Loadarea
SELECT  version
FROM    demand.ego_dp_loadarea
GROUP BY version
ORDER BY version;


-- Filter Loadarea
DROP MATERIALIZED VIEW IF EXISTS    demand.ego_dp_loadarea_v0_4_3_mview CASCADE;
CREATE MATERIALIZED VIEW            demand.ego_dp_loadarea_v0_4_3_mview AS
    SELECT  *
    FROM    demand.ego_dp_loadarea
    WHERE   version = 'v0.4.3';

-- index (id)
CREATE UNIQUE INDEX ego_dp_loadarea_v0_4_3_mview_idx
    ON demand.ego_dp_loadarea_v0_4_3_mview (id);

-- index GIST (geom)
CREATE INDEX ego_dp_loadarea_v0_4_3_mview_geom_idx
    ON      demand.ego_dp_loadarea_v0_4_3_mview
    USING   GIST (geom);

-- grant (oeuser)
ALTER TABLE demand.ego_dp_loadarea_v0_4_3_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW demand.ego_dp_loadarea_v0_4_3_mview IS '{
    "comment": "eGo - REAOSM - Temporary Table",
    "version": "v0.1" }' ;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','input','demand','ego_dp_loadarea','ego_pp_osm_deu_power.sql',' ');
SELECT scenario_log('eGo_REAOSM','v0.1','output','demand','ego_dp_loadarea_v0_4_3_mview','ego_pp_osm_deu_power.sql',' ');


-- update subst_id from eGo mv_grid_district
UPDATE sandbox.ego_pp_osm_deu_power_point_reaosm AS t1
    SET la_id = t2.la_id
    FROM (
        SELECT  b.osm_id AS osm_id,
                a.id AS la_id
        FROM    demand.ego_dp_loadarea_v0_4_3_mview AS a,
                sandbox.ego_pp_osm_deu_power_point_reaosm AS b
        WHERE   a.geom && b.geom AND
                ST_CONTAINS(a.geom,b.geom)
        ) AS t2
    WHERE   t1.osm_id = t2.osm_id;



-- eGoDP RES Powerplant
SELECT  version, scenario
FROM    supply.ego_dp_res_powerplant
GROUP BY version, scenario
ORDER BY version;


-- Filter RES Powerplant
DROP TABLE IF EXISTS    sandbox.ego_dp_res_powerplant_reaosm CASCADE;
CREATE TABLE            sandbox.ego_dp_res_powerplant_reaosm AS
    SELECT  *
    FROM    supply.ego_dp_res_powerplant
    WHERE   version = 'v0.4.3'
            AND scenario = 'Status Quo';

-- PK (id)
ALTER TABLE sandbox.ego_dp_res_powerplant_reaosm ADD PRIMARY KEY (id);

ALTER TABLE sandbox.ego_dp_res_powerplant_reaosm
    DROP COLUMN IF EXISTS   reaosm_sort CASCADE,
    ADD COLUMN              reaosm_sort integer,
    DROP COLUMN IF EXISTS   reaosm_flag CASCADE,
    ADD COLUMN              reaosm_flag character varying,
    DROP COLUMN IF EXISTS   reaosm_geom_line CASCADE,
    ADD COLUMN              reaosm_geom_line geometry(LineString,3035),
    DROP COLUMN IF EXISTS   reaosm_geom_new CASCADE,
    ADD COLUMN              reaosm_geom_new geometry(Point,3035);

-- index GIST (geom)
CREATE INDEX ego_dp_res_powerplant_reaosm_geom_idx
    ON      sandbox.ego_dp_res_powerplant_reaosm
    USING   GIST (geom);

-- index GIST (rea_geom_new)
CREATE INDEX ego_dp_res_powerplant_reaosm_rea_geom_new_idx
    ON      sandbox.ego_dp_res_powerplant_reaosm
    USING   GIST (rea_geom_new);

-- index GIST (reaosm_geom_new)
CREATE INDEX ego_dp_res_powerplant_reaosm_reaosm_geom_new_idx
    ON      sandbox.ego_dp_res_powerplant_reaosm
    USING   GIST (reaosm_geom_new);

-- grant (oeuser)
ALTER TABLE sandbox.ego_dp_res_powerplant_reaosm OWNER TO oeuser;

-- metadata
COMMENT ON TABLE sandbox.ego_dp_res_powerplant_reaosm IS '{
    "comment": "eGo - REAOSM - Temporary Table",
    "version": "v0.1" }' ;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','input','supply','ego_dp_res_powerplant','ego_pp_osm_deu_power.sql',' ');
SELECT scenario_log('eGo_REAOSM','v0.1','output','sandbox','ego_dp_res_powerplant_reaosm','ego_pp_osm_deu_power.sql',' ');


-- eGoDP OSM Farmyards
DROP MATERIALIZED VIEW IF EXISTS    sandbox.ego_osm_sector_per_griddistrict_4_agricultural_mview CASCADE;
CREATE MATERIALIZED VIEW            sandbox.ego_osm_sector_per_griddistrict_4_agricultural_mview AS
    SELECT  id,
            subst_id,
            area_ha,
            ST_CENTROID(geom) ::geometry(Point,3035) AS geom
    FROM    model_draft.ego_osm_sector_per_griddistrict_4_agricultural;

-- index (id)
CREATE UNIQUE INDEX ego_osm_sector_per_griddistrict_4_agricultural_mview_idx
    ON sandbox.ego_osm_sector_per_griddistrict_4_agricultural_mview (id);

-- index GIST (geom)
CREATE INDEX ego_osm_sector_per_griddistrict_4_agricultural_mview_geom_idx
    ON      sandbox.ego_osm_sector_per_griddistrict_4_agricultural_mview
    USING   GIST (geom);

-- grant (oeuser)
ALTER TABLE sandbox.ego_osm_sector_per_griddistrict_4_agricultural_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW sandbox.ego_osm_sector_per_griddistrict_4_agricultural_mview IS '{
    "comment": "eGo - REAOSM - Temporary Table",
    "version": "v0.1" }' ;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','input','model_draft','ego_osm_sector_per_griddistrict_4_agricultural','ego_pp_osm_deu_power.sql',' ');
SELECT scenario_log('eGo_REAOSM','v0.1','output','sandbox','ego_osm_sector_per_griddistrict_4_agricultural_mview','ego_pp_osm_deu_power.sql',' ');





-- extract wind from oedb osm
DROP MATERIALIZED VIEW IF EXISTS    openstreetmap.osm_deu_point_wind_mview CASCADE;
CREATE MATERIALIZED VIEW            openstreetmap.osm_deu_point_wind_mview AS 
    SELECT  osm_id,
            gid,
            tags,
            ST_TRANSFORM(geom, 3035) ::geometry(Point,3035) AS geom
    FROM    openstreetmap.osm_deu_point
    WHERE   tags @> '"generator:source"=>"wind"'::hstore;

-- index GIST (geom)
CREATE INDEX osm_deu_point_wind_mview_geom_idx
    ON      openstreetmap.osm_deu_point_wind_mview
    USING   GIST (geom);

-- grant (oeuser)
ALTER TABLE openstreetmap.osm_deu_point_wind_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW openstreetmap.osm_deu_point_wind_mview IS '{
    "comment": "eGo - REAOSM - Temporary Table",
    "version": "v0.1" }' ;


-- extract biomass from oedb osm
DROP MATERIALIZED VIEW IF EXISTS    openstreetmap.osm_deu_point_biogas_mview CASCADE;
CREATE MATERIALIZED VIEW            openstreetmap.osm_deu_point_biogas_mview AS 
    SELECT  osm_id,
            gid,
            tags,
            ST_TRANSFORM(geom, 3035) ::geometry(Point,3035) AS geom
    FROM    openstreetmap.osm_deu_point
    WHERE   tags @> '"generator:source"=>"biogas"' ::hstore 
            OR tags @> '"generator:source"=>"biomass"' ::hstore ;

-- index GIST (geom)
CREATE INDEX osm_deu_point_biogas_mview_geom_idx
    ON      openstreetmap.osm_deu_point_biogas_mview
    USING   GIST (geom);

-- grant (oeuser)
ALTER TABLE openstreetmap.osm_deu_point_biogas_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW openstreetmap.osm_deu_point_biogas_mview IS '{
    "comment": "eGo - REAOSM - Temporary Table",
    "version": "v0.1" }' ;


-- extract solar from oedb osm
DROP MATERIALIZED VIEW IF EXISTS    openstreetmap.osm_deu_point_solar_mview CASCADE;
CREATE MATERIALIZED VIEW            openstreetmap.osm_deu_point_solar_mview AS 
    SELECT  osm_id,
            gid,
            tags,
            ST_TRANSFORM(geom, 3035) ::geometry(Point,3035) AS geom
    FROM    openstreetmap.osm_deu_point
    WHERE   tags @> '"generator:source"=>"solar"' ::hstore;

-- index GIST (geom)
CREATE INDEX osm_deu_point_solar_mview_geom_idx
    ON      openstreetmap.osm_deu_point_solar_mview
    USING   GIST (geom);

-- grant (oeuser)
ALTER TABLE openstreetmap.osm_deu_point_solar_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW openstreetmap.osm_deu_point_solar_mview IS '{
    "comment": "eGo - REAOSM - Temporary Table",
    "version": "v0.1" }' ;
