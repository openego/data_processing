/*
OpenStreetMap power extracts

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Christian-rli; Ludee"
*/


-- metadata
COMMENT ON TABLE sandbox.ego_pp_osm_deu_power_point IS '{
    "title": "Good example title",
    "description": "example metadata for example data",
    "language": [ "eng", "ger", "fre" ],
    "spatial": 
        {"location": "none",
        "extent": "europe",
        "resolution": "100 m"},
    "temporal": 
        {"reference_date": "2016-01-01",
        "start": "2017-01-01",
        "end": "2017-12-31",
        "resolution": "hour"},
    "sources": [
        {"name": "OpenEnergyPlatform Metadata Example", "description": "Metadata description", "url": "https://github.com/OpenEnergyPlatform", "license": "Creative Commons Zero v1.0 Universal (CC0-1.0)", "copyright": "© Reiner Lemoine Institut"},
        {"name": "OpenStreetMap", "description": "A collaborative project to create a free editable map of the world", "url": "https://www.openstreetmap.org/", "license": "ODbL-1.0", "copyright": "© OpenStreetMap contributors"} ],
    "license": 
        {"id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "© Reiner Lemoine Institut"},
    "contributors": [
        {"name": "Ludee", "email": "none", "date": "2016-06-16", "comment": "Create metadata"},
        {"name": "Ludee", "email": "none", "date": "2016-11-22", "comment": "Update metadata"},
        {"name": "Ludee", "email": "none", "date": "2016-11-22", "comment": "Update header and license"},
        {"name": "Ludee", "email": "none", "date": "2017-03-16", "comment": "Add license to source"},
        {"name": "Ludee", "email": "none", "date": "2017-03-28", "comment": "Add copyright to source and license"},
        {"name": "Ludee", "email": "none", "date": "2017-05-30", "comment": "Update metadata to version 1.3"},
        {"name": "Ludee", "email": "none", "date": "2017-06-26", "comment": "Update metadata version 1.3: move reference_date into temporal and remove some array"} ],
    "resources": [
        {"name": "model_draft.oep_metadata_table_example_v13",
        "format": "PostgreSQL",
        "fields": [
            {"name": "id", "description": "Unique identifier", "unit": "none"},
            {"name": "year", "description": "Reference year", "unit": "none"},
            {"name": "value", "description": "Example value", "unit": "MW"},
            {"name": "geom", "description": "Geometry", "unit": "none"} ] } ],
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
COMMENT ON MATERIALIZED VIEW model_draft.ego_pp_osm_deu_power_point_mview IS '{
    "comment": "eGoPP - REA OSM - Temporary Table",
    "version": "v0.4.2" }' ;

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

-- metadata
COMMENT ON TABLE model_draft.ego_pp_osm_deu_power_point_reaosm IS '{
    "comment": "eGoPP - REA OSM - Temporary Table",
    "version": "v0.4.2" }' ;

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

-- insert M2
INSERT INTO sandbox.ego_pp_osm_deu_power_point_reaosm (osm_id, rea_method, geom)
    SELECT  osm_id,
            'M1',
            geom
    FROM    sandbox.ego_pp_osm_deu_power_point_mview
    WHERE   
    ORDER BY osm_id;

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
