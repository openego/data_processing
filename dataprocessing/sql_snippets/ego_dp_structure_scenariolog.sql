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
	('v0.2.8', 'eastereggs', 'FALSE', 'big and small eggs everywhere', '2017-04-13' ),
	('v0.2.9', 'maihem', 'FALSE', 'several runs', '2017-05-01' ),
	('v0.2.10', 'homerun', 'TRUE', 'finish in one run', '2017-05-22' );

-- metadata
COMMENT ON TABLE model_draft.ego_scenario IS '{
	"title": "eGo dataprocessing - Scenario list",
	"description": "Version info",
	"language": [ "eng", "ger" ],
	"reference_date": "none",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", 
		"license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"} ],
	"spatial": [
		{"extent": "none",
		"resolution": "none"} ],
	"temporal": [
		{"start": "none",
		"end": "none",
		"resolution": "none"} ],
	"license": [
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Reiner Lemoine Institut"} ],
	"contributors": [
		{"name": "Ludee", "email": "", "date": "2016-10-01", "comment": "Create table" },
		{"name": "Ludee", "email": "", "date": "2016-11-16", "comment": "Add metadata" },
		{"name": "Ludee", "email": "", "date": "2017-03-21", "comment": "Update metadata to 1.1" },
		{"name": "Ludee", "email": "", "date": "2017-04-06", "comment": "Update metadata to 1.2" },
		{"name": "Ludee", "email": "", "date": "2017-06-19", "comment": "Update metadata to 1.3" } ],
	"resources": [
		{"name": "model_draft.ego_scenario",		
		"format": "sql",
		"fields": [
			{"name": "version", "description": "scenario version number", "unit": "none" },
			{"name": "version_name", "description": "version name", "unit": "none" },
			{"name": "release", "description": "external release", "unit": "none" },
			{"name": "comment", "description": "additional information and comments", "unit": "none" },
			{"name": "timestamp", "description": "timestamp (Berlin)", "unit": "none" } ] }],
	"metadata_version": "1.3"}';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_scenario','ego_dp_structure_scenariolog.sql','Update scenario list');


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
	meta_data 	text,
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
	"reference_date": "none",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", 
		"license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"} ],
	"spatial": [
		{"extent": "none",
		"resolution": "none"} ],
	"temporal": [
		{"start": "none",
		"end": "none",
		"resolution": "none"} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Reiner Lemoine Institut"} ],
	"contributors": [
		{"name": "Ludee", "email": "", "date": "2016-10-01", "comment": "Create table" },
		{"name": "Ludee", "email": "", "date": "2016-10-12", "comment": "Add user_name" },
		{"name": "Ludee", "email": "", "date": "2016-11-16", "comment": "Add io" },
		{"name": "Ludee", "email": "", "date": "2016-11-16", "comment": "Add metadata" },
		{"name": "Ludee", "email": "", "date": "2017-01-15", "comment": "Update metadata"},
		{"name": "Ludee", "email": "", "date": "2017-03-21", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-04-06", "comment": "Update metadata to 1.2"},
		{"name": "Ludee", "email": "", "date": "2017-06-19", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "model_draft.ego_scenario_log",		
		"format": "sql",
		"fields": [
			{"name": "id", "description": "unique identifier", "unit": "none" },
				{"name": "version", "description": "scenario version", "unit": "none" },
				{"name": "io", "description": "input or output", "unit": "none" },
				{"name": "schema_name", "description": "Schema name", "unit": "none" },
				{"name": "table_name", "description": "Table name", "unit": "none" },
				{"name": "script_name", "description": "Script name", "unit": "none" },
				{"name": "entries", "description": "Number of rows", "unit": "none" },
				{"name": "status", "description": "Current status and comments", "unit": "none" },
				{"name": "user_name", "description": "Author (session user)", "unit": "none" },
				{"name": "timestamp", "description": "Timestamp without time zone", "unit": "YYYY-MM-DD HH:MM:SS" },
				{"name": "meta_data", "description": "Copy of the input metadta", "unit": "none" } ] }],
	"metadata_version": "1.3"}';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_scenario_log','ego_dp_structure_scenariolog.sql','Reset scenario log');
