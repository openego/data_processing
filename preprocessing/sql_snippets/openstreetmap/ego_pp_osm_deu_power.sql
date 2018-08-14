/*
OpenStreetMap power extracts

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Christian-rli; Ludee"
*/


-- metadata
COMMENT ON TABLE sandbox.ego_pp_osm_deu_power_point IS '{
    "title": "Openstreetmap generator=source",
    "description": "extracted from Openstreetmap via overpass-turbo",
    "language": [ "en" ],
    "spatial": 
        {"location": "germany",
        "extent": "europe",
        },
    "temporal": 
        {"reference_date": "2018-08-13",
        },
    "sources": [
        {"name": "OpenStreetMap", "description": "A collaborative project to create a free editable map of the world", "url": "https://www.openstreetmap.org/", "license": "ODbL-1.0", "copyright": "© OpenStreetMap contributors"} ],
    "license": 
        {"id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "© Reiner Lemoine Institut"},
    "contributors": [
        {"name": "OpenStreetMap Contributors", date": "2018-08-13"},
],
    "metadata_version": "1.3"}';





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
    "comment": "eGoPP - REA OSM - Temporary Table",
    "version": "v0.4.2" }' ;



-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
-- SELECT scenario_log('eGo_PP_REAOSM', 'v0.4.2','output','sandbox','ego_pp_osm_deu_power_point_mview','ego_pp_osm_deu_power.sql',' ');


-- Allocate to REA methods
-- CREATE Placeholder table
DROP TABLE IF EXISTS    sandbox.ego_pp_osm_deu_power_point_reaosm CASCADE;
CREATE TABLE            sandbox.ego_pp_osm_deu_power_point_reaosm (
    osm_id          bigint,
    rea_method      character varying,
    mvgd_id         integer,
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


/*
-- metadata
COMMENT ON TABLE model_draft.ego_pp_osm_deu_power_point_reaosm IS '{
    "comment": "eGoPP - REA OSM - Temporary Table",
    "version": "v0.4.2" }' ;
*/

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
-- SELECT scenario_log('eGo_PP_REAOSM', 'v0.4.2','output','sandbox','ego_pp_osm_deu_power_point_reaosm','ego_pp_osm_deu_power.sql',' ');


-- insert M1
INSERT INTO sandbox.ego_pp_osm_deu_power_point_reaosm (osm_id, rea_method, geom)
    SELECT  osm_id,
            'M1',
            geom
    FROM    sandbox.ego_pp_osm_deu_power_point_mview
    WHERE   generator_source = 'biogas' OR generator_source = 'biomass'
    ORDER BY osm_id;


-- insert M2
INSERT INTO sandbox.ego_pp_osm_deu_power_point_reaosm (osm_id, rea_method, geom)
    SELECT  osm_id,
            'M2',
            geom
    FROM    sandbox.ego_pp_osm_deu_power_point_mview
    WHERE   generator_source = 'wind'
    ORDER BY osm_id;

/*
-- insert M3
INSERT INTO sandbox.ego_pp_osm_deu_power_point_reaosm (osm_id, rea_method, geom)
    SELECT  osm_id,
            'M1',
            geom
    FROM    sandbox.ego_pp_osm_deu_power_point_mview
    WHERE   
    ORDER BY osm_id;

-- insert M4
INSERT INTO sandbox.ego_pp_osm_deu_power_point_reaosm (osm_id, rea_method, geom)
    SELECT  osm_id,
            'M1',
            geom
    FROM    sandbox.ego_pp_osm_deu_power_point_mview
    WHERE   
    ORDER BY osm_id;

-- insert M5
INSERT INTO sandbox.ego_pp_osm_deu_power_point_reaosm (osm_id, rea_method, geom)
    SELECT  osm_id,
            'M1',
            geom
    FROM    sandbox.ego_pp_osm_deu_power_point_mview
    WHERE   
    ORDER BY osm_id;
*/


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
    "comment": "eGoPP - REA OSM - Temporary Table",
    "version": "v0.4.2" }' ;


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
    "comment": "eGoPP - REA OSM - Temporary Table",
    "version": "v0.4.2" }' ;
