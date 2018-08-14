/*
OpenStreetMap power extracts

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Christian-rli; Ludee"
*/


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

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_PP_REAOSM', 'v0.4.2','output','sandbox','ego_pp_osm_deu_power_point_mview','ego_pp_osm_deu_power.sql',' ');


-- Allocate to REA methods
DROP TABLE IF EXISTS    sandbox.ego_pp_osm_deu_power_point_reaosm CASCADE;
CREATE TABLE            sandbox.ego_pp_osm_deu_power_point_reaosm (
    osm_id          integer,
    rea_method      character varying,
    mvgd_id         integer,
    la_id           integer,
    geom            geometry(Point,3035),
    CONSTRAINT      ego_pp_osm_deu_power_point_reaosm_pkey  PRIMARY KEY (osm_id);

-- index GIST (geom)
CREATE INDEX ego_pp_osm_deu_power_point_reaosm_geom_idx
    ON      sandbox.ego_pp_osm_deu_power_point_reaosm
    USING   GIST (geom);

-- grant (oeuser)
ALTER TABLE sandbox.ego_pp_osm_deu_power_point_reaosm OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_PP_REAOSM', 'v0.4.2','output','sandbox','ego_pp_osm_deu_power_point_reaosm','ego_pp_osm_deu_power.sql',' ');


-- insert M1
INSERT INTO sandbox.ego_pp_osm_deu_power_point_reaosm (osm_id, rea_method, geom)
    SELECT  osm_id,
            'M1',
            geom
    FROM    sandbox.ego_pp_osm_deu_power_point_mview
    WHERE   
    ORDER BY osm_id;
