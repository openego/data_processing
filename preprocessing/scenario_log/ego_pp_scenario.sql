/*
eGo Scenario List

Creates a table with all versions.
WARNING: It drops the table and deletes old entries when executed!

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://www.gnu.org/licenses/agpl-3.0.en.html"
__author__      = "Ludee"

 * This file is part of project "open_eGo DataProcessing" (https://github.com/openego/data_processing/).
 * It's copyrighted by the contributors recorded in the version control history:
 * openego/data_processing/preprocessing/scenario_log/ego_pp_scenario.sql
 * 
 * SPDX-License-Identifier: AGPL-3.0-or-later
*/


-- scenario list
DROP TABLE IF EXISTS    model_draft.ego_scenario CASCADE;
CREATE TABLE            model_draft.ego_scenario (
    id              serial,
    model           text,
    version         text,
    version_name    text,
    "release"       boolean,
    "comment"       text,
    "timestamp"     timestamp,
    CONSTRAINT ego_scenario_pkey PRIMARY KEY (id, version));

-- access rights
ALTER TABLE model_draft.ego_scenario OWNER TO oeuser;

-- scenario list
INSERT INTO model_draft.ego_scenario (model,version,version_name,release,comment,timestamp) VALUES
    ('eGo_PP', 'PP1', 'data setup', 'TRUE', 'data import', '2016-10-01' ),
    ('eGo_DP', '0', 'setup', 'FALSE', ' ', '2016-10-01' ),
    ('eGo_DP', 'v0.1', 'cleanrun', 'FALSE', 'data in calc schemata', '2016-11-11'  ),
    ('eGo_DP', 'v0.2', 'restructure', 'FALSE', 'data in model_draft schema', '2016-12-09' ),
    ('eGo_DP', 'v0.2.1', 'none', 'FALSE', ' ', '2017-01-01' ),
    ('eGo_DP', 'v0.2.2', 'none', 'FALSE', ' ', '2017-01-01' ),
    ('eGo_DP', 'v0.2.3', 'none', 'FALSE', ' ', '2017-01-01' ),
    ('eGo_DP', 'v0.2.4', 'none', 'FALSE', ' ', '2017-01-01' ),
    ('eGo_DP', 'v0.2.5', 'mockrun', 'FALSE', 'finished but revealed major bugs', '2017-03-03' ),
    ('eGo_DP', 'v0.2.6', 'premiere', 'TRUE', 'first complete relase', '2017-03-24' ),
    ('eGo_DP', 'v0.2.7', 'debugbranch', 'FALSE', 'run blocks to debug', '2017-04-06' ),
    ('eGo_DP', 'v0.2.8', 'eastereggs', 'FALSE', 'big and small eggs everywhere', '2017-04-13' ),
    ('eGo_DP', 'v0.2.9', 'maihem', 'FALSE', 'several runs', '2017-05-01' ),
    ('eGo_DP', 'v0.2.10', 'homerun', 'TRUE', 'finish in one run', '2017-05-22' ),
    ('eGo_DP', 'v0.2.11', 'powerflow scenario', 'FALSE', 'save intermediate changes in pf tables', '2017-07-11' ),
    ('eGo_DP', 'v0.3.0', 'release v0.3', 'TRUE', ' ', '2017-07-11' ),
    ('eGo_DP', 'v0.3.0pre1', 'v0.3 backup', 'FALSE', ' ', '2017-10-26' ),
    ('eGo_DP', 'v0.3.1', 'RTDoku', 'TRUE', 'new scenario log and documentation', '2018-02-21' ),
    ('eGo_DP', 'v0.4.0', 'tba', 'TRUE', 'tba', '' );

-- metadata
COMMENT ON TABLE model_draft.ego_scenario IS '{
    "title": "eGo dataprocessing - Scenario list",
    "description": "Version info",
    "language": [ "eng", "ger" ],
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
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2016-11-16", "comment": "Add metadata" },
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2017-03-21", "comment": "Update metadata to 1.1" },
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2017-04-06", "comment": "Update metadata to 1.2" },
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2017-06-19", "comment": "Update metadata to 1.3" },
        {"name": "Ludee", "email": "https://github.com/Ludee", "date": "2018-02-21", "comment": "Update license to CC0" } ],
    "resources": [
        {"name": "model_draft.ego_scenario",
        "format": "PostgreSQL",
        "fields": [
            {"name": "id", "description": "unique identifier", "unit": "none" },
            {"name": "model", "description": "model name", "unit": "none" },
            {"name": "version", "description": "scenario version number", "unit": "none" },
            {"name": "version_name", "description": "version name", "unit": "none" },
            {"name": "release", "description": "external release", "unit": "none" },
            {"name": "comment", "description": "additional information and comments", "unit": "none" },
            {"name": "timestamp", "description": "timestamp (Berlin)", "unit": "none" } ] } ],
    "metadata_version": "1.3"}';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_PP','PP1','setup','model_draft','ego_scenario','ego_pp_scenario.sql','Update scenario list');
