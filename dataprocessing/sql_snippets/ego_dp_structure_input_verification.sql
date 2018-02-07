/*
Input verification (eGoPP)
Check the necessary input tables from eGo PreProcessing.
Return version of input tables.

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','check','boundaries','bkg_vg250_1_sta','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','boundaries','bkg_vg250_2_lan','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','boundaries','bkg_vg250_4_krs','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','boundaries','bkg_vg250_6_gem','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','openstreetmap','osm_deu_polygon','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','openstreetmap','osm_deu_ways','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','openstreetmap','osm_deu_nodes','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','openstreetmap','osm_deu_line','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','society','destatis_zensus_population_per_ha','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','economy','destatis_gva_per_district','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','demand','ego_demand_federalstate','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','supply','vernetzen_wind_potential_area','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','model_draft','ego_supply_res_powerplant_sq_mview','ego_dp_structure_input_verification.sql','preprocessing verification');
SELECT ego_scenario_log('v0.3.0','check','model_draft','ego_supply_conv_powerplant_sq_mview','ego_dp_structure_input_verification.sql','preprocessing verification');

/*
-- input tables
DROP TABLE IF EXISTS    model_draft.ego_scenario_input CASCADE;
CREATE TABLE            model_draft.ego_scenario_input (
    id                      serial,
    version                 text,
    oid                     oid,
    database                varchar,
    table_schema            varchar,
    table_name              varchar,
    path                    text,
    metadata_title          text,
    metadata_reference_date text,
    metadata                text,
    CONSTRAINT ego_scenario_input_pkey PRIMARY KEY (id));

-- grant (oeuser)
ALTER TABLE model_draft.ego_scenario_input OWNER TO oeuser;

-- metadata template
COMMENT ON TABLE model_draft.ego_scenario_input IS '{
    "title": "eGoDP input data verification",
    "description": "Check input tables and gathers meta infos",
    "language": [ "eng" ],
    "spatial": 
        {"location": "none",
        "extent": "none",
        "resolution": "none"},
    "temporal": 
        {"reference_date": "none",
        "start": "none",
        "end": "none",
        "resolution": "none"},
    "sources": [
        {"name": "none", "description": "", "url": "", "license": "", "copyright": ""} ],
    "license": 
        {"id":  "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "© Reiner Lemoine Institut"},
    "contributors": [
        {"name": "Ludee", "email": "", "date": "2017-10-26", "comment": "Create table and metadata" },
        {"name": "", "email": "", "date": "", "comment": ""} ],
    "resources": [
        {"name": "model_draft.ego_scenario_input",        
        "format": "PostgreSQL",
        "fields": [
            {"name": "id", "description": "Unique identifier", "unit": "none"},
            {"name": "version", "description": "eGoDP version number", "unit": "none"},
            {"name": "oid", "description": "The OID of the object this description pertains to", "unit": "none"},
            {"name": "database", "description": "Database name", "unit": "none"},
            {"name": "table_schema", "description": "Schema name", "unit": "none"},
            {"name": "table_name", "description": "Table name", "unit": "none"},
            {"name": "path", "description": "Schema.Table", "unit": "none"},
            {"name": "metadata_title", "description": "Title from metadata", "unit": "none"},
            {"name": "metadata_reference_date", "description": "Reference date from metadata", "unit": "none"},
            {"name": "metadata", "description": "Full metadat", "unit": "none"} ] } ],
    "metadata_version": "1.3"}';

-- select description
SELECT obj_description('model_draft.test_table' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','setup','model_draft','ego_scenario_input','ego_dp_structure_input_verification.sql','preprocessing verification');
*/

-- insert version
INSERT INTO     model_draft.ego_scenario_input(version,oid,database,table_schema,table_name,path,metadata_title,metadata_reference_date,metadata)
    SELECT  'v0.3.0' AS version,
            sub.oid,
            sub.database,
            sub.table_schema,
            sub.table_name,
            sub.path,
            sub.metadata::json ->>'title' AS metadata_title,
            sub.metadata::json #>>'{temporal,reference_date}' AS metadata_reference_date,
            sub.metadata
    FROM    (SELECT    st.relid AS oid,
            table_catalog AS database,
            i.table_schema AS table_schema,
            i.table_name AS table_name,
            i.table_schema ||'.'|| i.table_name AS path,
            pgd.description AS metadata
            FROM    information_schema.tables AS i
    INNER JOIN pg_catalog.pg_statio_all_tables AS st ON (st.schemaname=i.table_schema and st.relname=i.table_name)
    INNER JOIN pg_catalog.pg_description AS pgd ON (pgd.objoid=st.relid)
    WHERE   (table_schema='boundaries' AND table_name='bkg_vg250_1_sta') OR
            (table_schema='boundaries' AND table_name='bkg_vg250_2_lan') OR
            (table_schema='boundaries' AND table_name='bkg_vg250_4_krs') OR
            (table_schema='boundaries' AND table_name='bkg_vg250_6_gem') OR
            (table_schema='openstreetmap' AND table_name='osm_deu_polygon') OR
            (table_schema='openstreetmap' AND table_name='osm_deu_ways') OR 
            (table_schema='openstreetmap' AND table_name='osm_deu_nodes') OR
            (table_schema='openstreetmap' AND table_name='osm_deu_line') OR
            (table_schema='society' AND table_name='destatis_zensus_population_per_ha') OR
            (table_schema='economy' AND table_name='destatis_gva_per_district') OR
            (table_schema='demand' AND table_name='ego_demand_federalstate') OR
            (table_schema='supply' AND table_name='vernetzen_wind_potential_area') OR
            (table_schema='model_draft' AND table_name='ego_supply_res_powerplant_sq_mview') OR
            (table_schema='model_draft' AND table_name='ego_supply_conv_powerplant_sq_mview')
            ) AS sub
    ORDER BY table_schema, table_name;
