﻿/*
Setup scenario log table
Creates a table to get inserts from other processed tables
Used inputs are flaged "input" in column io
Created outputs are flaged "output" in column io
WARNING: It drops the table and deletes old entries when executed!

__copyright__ = "tba"
__license__ = "tba"
__author__ = "Ludee"
*/

-- scenario log table
DROP TABLE IF EXISTS	model_draft.ego_scenario_log CASCADE;
CREATE TABLE 		model_draft.ego_scenario_log (
	id SERIAL,
	version text,
	io text,
	schema_name text,
	table_name text,
	script_name text,
	entries integer,
	status text,
	user_name text,
	timestamp timestamp,
	metadata text,
	CONSTRAINT ego_scenario_log_pkey PRIMARY KEY (id));

-- grant (oeuser)
ALTER TABLE	model_draft.ego_scenario_log OWNER TO oeuser; 

-- metadata
COMMENT ON TABLE model_draft.ego_scenario_log IS '{
	"Name": "ego scenario log",
	"Source": [{
		"Name": "open_eGo",
		"URL":  "https://github.com/openego/data_processing" }],
	"Reference date": "2016",
	"Date of collection": "",
	"Original file": "",
	"Spatial": [{
		"Resolution": "",
		"Extend": "Germany" }],
	"Description": ["ego scenario log table"],
	"Column": [
		{"Name": "id", "Description": "Unique identifier", "Unit": "" },
		{"Name": "version", "Description": "Scenario version", "Unit": "" },
		{"Name": "io", "Description": "input or output", "Unit": "" },
		{"Name": "schema_name", "Description": "Schema name", "Unit": "" },
		{"Name": "table_name", "Description": "Table name", "Unit": "" },
		{"Name": "script_name", "Description": "Script name", "Unit": "" },
		{"Name": "entries", "Description": "Number of rows", "Unit": "" },
		{"Name": "status", "Description": "Current status and comments", "Unit": "" },
		{"Name": "user_name", "Description": "Author (session user)", "Unit": "" },
		{"Name": "metadata", "Description": "Copy of the input metadta", "Unit": "" },
		{"Name": "timestamp", "Description": "Timestamp (Berlin)", "Unit": "" },
		{"Name": "metadata", "Description": "Metadata of table", "Unit": "" } ],
	"Changes":[
		{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
		"Date":  "01.10.2016", "Comment": "Created table" },
		{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
		"Date":  "12.10.2016", "Comment": "Added user_name" },
		{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
		"Date":  "16.11.2016", "Comment": "Added io" },
		{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
		"Date":  "16.11.2016", "Comment": "Added metadata" } ],
	"ToDo": ["More attributes needed?"],
	"Licence": [{
		"Name": "tba", 
		"URL": "" }],
	"Instructions for proper use": ["Do not drop table, only once and then insert!"]
	}'; 

-- select description
SELECT obj_description('model_draft.ego_scenario_log' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_scenario_log','ego_scenario_log_setup.sql','Reset scenario log');
