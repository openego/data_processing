/*
Setup tables for REA
Skript to allocate decentralized renewable power plants (dea).
Methods base on technology and voltage level.
Allocate DEA outside of Germany to next HVMV Substation.
Generate OSM farmyards.

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/


-- number of grid_district -> 3608
SELECT  COUNT(*)
FROM    model_draft.ego_grid_mv_griddistrict;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','input','model_draft','ego_dp_supply_res_powerplant','ego_dp_rea_setup.sql',' ');

ALTER TABLE model_draft.ego_dp_supply_res_powerplant
    DROP COLUMN IF EXISTS   la_id CASCADE,
    ADD COLUMN              la_id integer,
    DROP COLUMN IF EXISTS   mvlv_subst_id CASCADE,
    ADD COLUMN              mvlv_subst_id integer,
    DROP COLUMN IF EXISTS   rea_sort CASCADE,
    ADD COLUMN              rea_sort integer,
    DROP COLUMN IF EXISTS   rea_flag CASCADE,
    ADD COLUMN              rea_flag character varying,
    DROP COLUMN IF EXISTS   rea_geom_line CASCADE,
    ADD COLUMN              rea_geom_line geometry(LineString,3035),
    DROP COLUMN IF EXISTS   rea_geom_new CASCADE,
    ADD COLUMN              rea_geom_new geometry(Point,3035);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','input','model_draft','ego_grid_mv_griddistrict','ego_dp_rea_setup.sql',' ');

-- subst_id from mv-griddistrict
UPDATE model_draft.ego_dp_supply_res_powerplant AS t1
    SET subst_id = t2.subst_id
    FROM (
        SELECT  a.id AS id,
                b.subst_id AS subst_id
        FROM    model_draft.ego_dp_supply_res_powerplant AS a,
                model_draft.ego_grid_mv_griddistrict AS b
        WHERE   b.geom && ST_TRANSFORM(a.geom,3035) AND
                ST_CONTAINS(b.geom,ST_TRANSFORM(a.geom,3035))
        ) AS t2
    WHERE   t1.id = t2.id;

-- rea_flag reset
UPDATE model_draft.ego_dp_supply_res_powerplant
    SET rea_flag = NULL,
        rea_geom_new = NULL,
        rea_geom_line = NULL;

-- re outside mv-griddistrict
UPDATE model_draft.ego_dp_supply_res_powerplant
    SET rea_flag = 'out',
        rea_geom_new = NULL,
        rea_geom_line = NULL
    WHERE subst_id IS NULL;

-- re outside mv-griddistrict -> offshore wind
UPDATE model_draft.ego_dp_supply_res_powerplant
    SET rea_flag = 'wind_offshore',
        rea_geom_new = NULL,
        rea_geom_line = NULL
    WHERE generation_subtype = 'wind_offshore';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','output','model_draft','ego_dp_supply_res_powerplant','ego_dp_rea_setup.sql',' ');


/*
Some RES are outside Germany because of unknown inaccuracies.
They are moved to the next substation before the allocation methods.
Offshore wind power plants are not moved.
*/ 

-- re outside mv-griddistrict
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_dp_supply_res_powerplant_out_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.ego_dp_supply_res_powerplant_out_mview AS
    SELECT  *
    FROM    model_draft.ego_dp_supply_res_powerplant
    WHERE   rea_flag = 'out' OR rea_flag = 'wind_offshore';

-- index GIST (geom)
CREATE INDEX ego_dp_supply_res_powerplant_out_mview_geom_idx
    ON model_draft.ego_dp_supply_res_powerplant_out_mview USING gist (geom);

-- index GIST (rea_geom_line)
CREATE INDEX ego_dp_supply_res_powerplant_out_mview_rea_geom_line_idx
    ON model_draft.ego_dp_supply_res_powerplant_out_mview USING gist (rea_geom_line);

-- index GIST (rea_geom_new)
CREATE INDEX ego_dp_supply_res_powerplant_out_mview_rea_geom_new_idx
    ON model_draft.ego_dp_supply_res_powerplant_out_mview USING gist (rea_geom_new);	

-- grant (oeuser)
ALTER TABLE model_draft.ego_dp_supply_res_powerplant_out_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_dp_supply_res_powerplant_out_mview IS '{
    "comment": "eGoDP - Temporary table",
    "version": "v0.4.0" }';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','temp','model_draft','ego_dp_supply_res_powerplant_out_mview','ego_dp_rea_setup.sql','First check if RES are outside Germany');


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','input','model_draft','ego_grid_hvmv_substation','ego_dp_rea_setup.sql',' ');

-- new geom, DEA to next substation
DROP TABLE IF EXISTS    model_draft.ego_dp_supply_res_powerplant_out_nn CASCADE;
CREATE TABLE            model_draft.ego_dp_supply_res_powerplant_out_nn AS 
    SELECT DISTINCT ON (a.id)
            a.id AS dea_id,
            a.generation_type,
            b.subst_id, 
            b.geom ::geometry(Point,3035) AS geom_sub,
            ST_Distance(ST_TRANSFORM(a.geom,3035),b.geom) AS distance,
            ST_TRANSFORM(a.geom,3035) ::geometry(Point,3035) AS geom
    FROM    model_draft.ego_dp_supply_res_powerplant_out_mview AS a,
            model_draft.ego_grid_hvmv_substation AS b
    WHERE   ST_DWithin(ST_TRANSFORM(a.geom,3035),b.geom, 100000) -- In a 100 km radius
    ORDER BY a.id, ST_Distance(ST_TRANSFORM(a.geom,3035),b.geom);

ALTER TABLE model_draft.ego_dp_supply_res_powerplant_out_nn
    ADD PRIMARY KEY (dea_id),
    OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_dp_supply_res_powerplant_out_nn IS '{
    "comment": "eGoDP - Temporary table",
    "version": "v0.4.0" }';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','temp','model_draft','ego_dp_supply_res_powerplant_out_nn','ego_dp_rea_setup.sql',' ');

-- new subst_id and rea_geom_new with line
UPDATE model_draft.ego_dp_supply_res_powerplant AS t1
    SET subst_id = t2.subst_id,
        rea_geom_new = t2.rea_geom_new,
        rea_geom_line = t2.rea_geom_line
    FROM (
        SELECT  nn.dea_id AS dea_id,
                nn.subst_id AS subst_id,
                nn.geom_sub AS rea_geom_new,
                ST_MAKELINE(nn.geom,nn.geom_sub) ::geometry(LineString,3035) AS rea_geom_line
        FROM    model_draft.ego_dp_supply_res_powerplant_out_nn AS nn,
                model_draft.ego_dp_supply_res_powerplant AS dea
        WHERE   rea_flag = 'out'
        )AS t2
    WHERE   t1.id = t2.dea_id;


-- DEA outside MV Griddistrict
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_dp_supply_res_powerplant_out_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.ego_dp_supply_res_powerplant_out_mview AS
    SELECT  dea.*
    FROM    model_draft.ego_dp_supply_res_powerplant AS dea
    WHERE   rea_flag = 'out' OR rea_flag = 'wind_offshore';

-- index GIST (geom)
CREATE INDEX ego_dp_supply_res_powerplant_out_mview_geom_idx
    ON model_draft.ego_dp_supply_res_powerplant_out_mview USING gist (geom);

-- index GIST (rea_geom_line)
CREATE INDEX ego_dp_supply_res_powerplant_out_mview_rea_geom_line_idx
    ON model_draft.ego_dp_supply_res_powerplant_out_mview USING gist (rea_geom_line);

-- index GIST (rea_geom_new)
CREATE INDEX ego_dp_supply_res_powerplant_out_mview_rea_geom_new_idx
    ON model_draft.ego_dp_supply_res_powerplant_out_mview USING gist (rea_geom_new);	

-- grant (oeuser)
ALTER TABLE model_draft.ego_dp_supply_res_powerplant_out_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_dp_supply_res_powerplant_out_mview IS '{
    "comment": "eGoDP - Temporary table",
    "version": "v0.4.0" }';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','temp','model_draft','ego_dp_supply_res_powerplant_out_mview','ego_dp_rea_setup.sql','Second check if RES outside Germany');

-- drop
DROP TABLE IF EXISTS model_draft.ego_dp_supply_res_powerplant_out_nn CASCADE;
-- DROP MATERIALIZED VIEW IF EXISTS model_draft.ego_dp_supply_res_powerplant_out_mview CASCADE;


/* 
Prepare a special OSM layer with farmyards per grid districts.
In Germany a lot of farmyard builings are used for renewable energy production with solar and biomass.
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','input','model_draft','ego_osm_sector_per_griddistrict_4_agricultural','ego_dp_rea_setup.sql',' ');

ALTER TABLE model_draft.ego_osm_sector_per_griddistrict_4_agricultural
    DROP COLUMN IF EXISTS   subst_id,
    ADD COLUMN              subst_id integer,
    DROP COLUMN IF EXISTS   area_ha,
    ADD COLUMN              area_ha double precision;

-- update subst_id from grid_district
UPDATE model_draft.ego_osm_sector_per_griddistrict_4_agricultural AS t1
    SET subst_id = t2.subst_id
    FROM (
        SELECT  osm.id AS id,
                dis.subst_id AS subst_id
        FROM    model_draft.ego_osm_sector_per_griddistrict_4_agricultural AS osm,
                model_draft.ego_grid_mv_griddistrict AS dis
        WHERE   dis.geom && ST_CENTROID(osm.geom) AND
                ST_CONTAINS(dis.geom,ST_CENTROID(osm.geom))
        ) AS t2
    WHERE   t1.id = t2.id;

-- update area
UPDATE model_draft.ego_osm_sector_per_griddistrict_4_agricultural
    SET area_ha = ST_AREA(geom)/10000;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','output','model_draft','ego_osm_sector_per_griddistrict_4_agricultural','ego_dp_rea_setup.sql',' ');
