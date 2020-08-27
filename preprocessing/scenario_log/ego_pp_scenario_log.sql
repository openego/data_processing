/*
Setup Scenario Log table

Creates a table to get inserts (logs) from other processed tables.
WARNING: It drops the table and deletes old entries when executed!

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://www.gnu.org/licenses/agpl-3.0.en.html"
__author__      = "Ludee"

 * This file is part of project "open_eGo DataProcessing" (https://github.com/openego/data_processing/).
 * It's copyrighted by the contributors recorded in the version control history:
 * openego/data_processing/preprocessing/scenario_log/ego_pp_scenario_log.sql
 * 
 * SPDX-License-Identifier: AGPL-3.0-or-later
*/


/* -- select logged versions
SELECT  version
FROM    model_draft.scenario_log
GROUP BY version 
ORDER BY version;
*/

-- scenario log table
DROP TABLE IF EXISTS    model_draft.scenario_log CASCADE;
CREATE TABLE            model_draft.scenario_log (
    id          SERIAL,
    project     text,
    version     text,
    io          text,
    schema_name text,
    table_name  text,
    script_name text,
    entries     integer,
    comment      text,
    user_name   text,
    "timestamp" timestamp,
    meta_data   text,
    CONSTRAINT scenario_log_pkey PRIMARY KEY (id));

-- FK
ALTER TABLE model_draft.scenario_log
    ADD CONSTRAINT scenario_log_fkey FOREIGN KEY (version) 
        REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- access rights
ALTER TABLE model_draft.scenario_log OWNER TO oeuser; 

-- metadata
COMMENT ON TABLE model_draft.scenario_log IS '{
    "title": "Scenario Log",
    "description": "Versioning and table info",
    "language": [ "eng" ],
    "sources": [
        {"name": "eGo DataProcessing", "description": "Code", "url": "https://github.com/openego/data_processing", "license": "AGPL-3.0-or-later", "copyright": "eGo DataProcessing © Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems © Europa-Universität Flensburg, Centre for Sustainable Energy Systems © Reiner Lemoine Institut © DLR Institute for Networked Energy Systems"},
        {"name": "eGo DataProcessing", "description": "Documentation", "url": "http://data-processing.readthedocs.io/en/latest/", "license": "CC-BY-4.0", "copyright": "eGo DataProcessing Documentation © Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems © Europa-Universität Flensburg, Centre for Sustainable Energy Systems © Reiner Lemoine Institut © DLR Institute for Networked Energy Systems"}],
    "spatial": 
        {"location": "none",
        "extent": "none",
        "resolution": "none"},
    "temporal": 
        {"reference_date": "none",
        "start": "none",
        "end": "none",
        "resolution": "none"},
    "license": 
        {"id": "CC0-1.0",
        "name": "Creative Commons Zero v1.0 Universal",
        "version": "1.0",
        "url": "https://creativecommons.org/publicdomain/zero/1.0/legalcode",
        "instruction": "You can: Commercial Use, Private Use, Modify, Distribute; You cannot: Use Trademark, Hold Liable, Use Patent Claims; You must: none!",
        "copyright": "© Reiner Lemoine Institut"},
    "contributors": [
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2016-10-01", "comment": "Create table" },
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2016-10-12", "comment": "Add user_name" },
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2016-11-16", "comment": "Add io" },
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2016-11-16", "comment": "Add metadata" },
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2017-01-15", "comment": "Update metadata"},
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2017-03-21", "comment": "Update metadata to 1.1"},
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2017-04-06", "comment": "Update metadata to 1.2"},
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2017-06-19", "comment": "Update metadata to 1.3"},
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2018-02-21", "comment": "Update license to CC0" }        ],
    "resources": [
        {"name": "model_draft.scenario_log",
        "format": "PostgreSQL",
        "fields": [
            {"name": "id", "description": "Unique identifier", "unit": "none" },
            {"name": "project", "description": "Project name", "unit": "none" },
            {"name": "version", "description": "Scenario version", "unit": "none" },
            {"name": "io", "description": "Input or output", "unit": "none" },
            {"name": "schema_name", "description": "Schema name", "unit": "none" },
            {"name": "table_name", "description": "Table name", "unit": "none" },
            {"name": "script_name", "description": "Script name", "unit": "none" },
            {"name": "entries", "description": "Number of rows", "unit": "none" },
            {"name": "comment", "description": "Current status and comments", "unit": "none" },
            {"name": "user_name", "description": "Author (session user)", "unit": "none" },
            {"name": "timestamp", "description": "Timestamp without time zone", "unit": "YYYY-MM-DD HH:MM:SS" },
            {"name": "meta_data", "description": "Copy of the input metadata", "unit": "none" } ] } ],
    "metadata_version": "1.3"}';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_PP','PP1','setup','model_draft','scenario_log','ego_pp_scenario_log.sql','Setup Scenario Log');
