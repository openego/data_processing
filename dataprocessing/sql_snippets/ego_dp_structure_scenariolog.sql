/*
Setup scenario log table
Creates a table to get inserts from other processed tables

WARNING: It drops the table and deletes old entries when executed!

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

-- scenario list
DROP TABLE IF EXISTS	model_draft.ego_scenario CASCADE;
CREATE TABLE 		model_draft.ego_scenario (
	version 	text,
	version_name	text,
	"release"	boolean,
	"comment"	text,
	"timestamp"	timestamp,
	CONSTRAINT ego_scenario_pkey PRIMARY KEY (version));

-- grant (oeuser)
ALTER TABLE	model_draft.ego_scenario OWNER TO oeuser;

-- scenario list
INSERT INTO	model_draft.ego_scenario (version,version_name,release,comment,timestamp) VALUES
	('0', 'setup', 'FALSE', ' ', '2016-10-01' ),
	('v0.1', 'cleanrun', 'FALSE', 'data in calc schemata', '2016-11-11'  ),
	('v0.2', 'restructure', 'FALSE', 'data in model_draft schema', '2016-12-09' ),
	('v0.2.1', ' ', 'FALSE', ' ', '2017-01-01' ),
	('v0.2.2', ' ', 'FALSE', ' ', '2017-01-01' ),
	('v0.2.3', ' ', 'FALSE', ' ', '2017-01-01' ),
	('v0.2.4', ' ', 'FALSE', ' ', '2017-01-01' ),
	('v0.2.5', 'mockrun', 'FALSE', 'finished but revealed major bugs', '2017-03-03' ),
	('v0.2.6', 'premiere', 'TRUE', 'first complete relase', '2017-03-24' ),
	('v0.2.7', 'debugbranch', 'FALSE', 'run blocks to debug', '2017-04-06' ),
	('v0.2.8', 'eastereggs', 'TRUE', 'big and small eggs everywhere', '2017-04-13' ),
	('v0.2.9', 'homerun', 'TRUE', 'finish in one run', '2017-04-14' );

-- metadata
COMMENT ON TABLE model_draft.ego_scenario IS '{
	"title": "eGo dataprocessing - Scenario list",
	"description": "Version info",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ",
		"url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"} ],
	"spatial": [
		{"extend": "",
		"resolution": ""} ],
	"license": [
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Reiner Lemoine Institut"} ],
	"contributors": [
		{"name": "Ludee", "email": "", "date": "01.10.2016", "comment": "Create table" },
		{"name": "Ludee", "email": "", "date": "16.11.2016", "comment": "Add metadata" },
		{"name": "Ludee", "email": " ", "date": "21.03.2017", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-04-06", "comment": "Update metadata to 1.2"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "scenario version number", "unit": "" },
				{"name": "version_name", "description": "version name", "unit": "" },
				{"name": "release", "description": "external release", "unit": "" },
				{"name": "comment", "description": "additional information and comments", "unit": "" },
				{"name": "timestamp", "description": "timestamp (Berlin)", "unit": "" } ]},
		"meta_version": "1.2"}] }' ;

-- select description
SELECT obj_description('model_draft.ego_scenario' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','output','model_draft','ego_scenario','ego_dp_structure_scenariolog.sql','Update scenario list');


/* -- logged versions
SELECT	version
FROM 	model_draft.ego_scenario_log
	GROUP BY version 
	ORDER BY version; */

/* 
-- scenario log table
DROP TABLE IF EXISTS	model_draft.ego_scenario_log CASCADE;
CREATE TABLE 		model_draft.ego_scenario_log (
	id 		SERIAL,
	version 	text,
	io 		text,
	schema_name 	text,
	table_name 	text,
	script_name 	text,
	entries 	integer,
	status 		text,
	user_name 	text,
	"timestamp" 	timestamp,
	metadata 	text,
	CONSTRAINT ego_scenario_log_pkey PRIMARY KEY (id));

--FK
ALTER TABLE model_draft.ego_scenario_log
	ADD CONSTRAINT ego_scenario_log_fkey FOREIGN KEY (version) 
		REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	model_draft.ego_scenario_log OWNER TO oeuser; 
 */

-- metadata
COMMENT ON TABLE model_draft.ego_scenario_log IS '{
	"title": "eGo dataprocessing - Scenario log",
	"description": "Versioning and table info",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"} ],
	"spatial": [
		{"extend": "",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Reiner Lemoine Institut"} ],
	"contributors": [
		{"name": "Ludee", "email": "", "date": "01.10.2016", "comment": "Create table" },
		{"name": "Ludee", "email": "", "date": "12.10.2016", "comment": "Add user_name" },
		{"name": "Ludee", "email": "", "date": "16.11.2016", "comment": "Add io" },
		{"name": "Ludee", "email": "", "date": "16.11.2016", "comment": "Add metadata" },
		{"name": "Ludee", "email": "", "date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "", "date": "21.03.2017", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-04-06", "comment": "Update metadata to 1.2"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "id", "description": "unique identifier", "unit": "" },
				{"name": "version", "description": "scenario version", "unit": "" },
				{"name": "io", "description": "input or output", "unit": "" },
				{"name": "schema_name", "description": "Schema name", "unit": "" },
				{"name": "table_name", "description": "Table name", "unit": "" },
				{"name": "script_name", "description": "Script name", "unit": "" },
				{"name": "entries", "description": "Number of rows", "unit": "" },
				{"name": "status", "description": "Current status and comments", "unit": "" },
				{"name": "user_name", "description": "Author (session user)", "unit": "" },
				{"name": "metadata", "description": "Copy of the input metadta", "unit": "" },
				{"name": "timestamp", "description": "Timestamp (Berlin)", "unit": "" },
				{"name": "metadata", "description": "Metadata of table", "unit": "" } ]},
		"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('model_draft.ego_scenario_log' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','output','model_draft','ego_scenario_log','ego_dp_structure_scenariolog.sql','Reset scenario log');
