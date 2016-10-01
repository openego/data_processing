/* 
eGo data processing - clean run scenario table

Creates a table to get inserts from other processed tables
It deletes old entries when executed!
*/


/* -- Create scenario table with basic infos
DROP TABLE IF EXISTS	scenario.eGo_data_processing_clean_run CASCADE;
CREATE TABLE 		scenario.eGo_data_processing_clean_run (
	id SERIAL,
	version text,
	schema_name text,
	table_name text,
	script_name text,
	entries integer,
	status text,
	timestamp timestamp,
	CONSTRAINT eGo_data_processing_clean_run_pkey PRIMARY KEY (id));
	
-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	scenario.eGo_data_processing_clean_run TO oeuser WITH GRANT OPTION;
ALTER TABLE		scenario.eGo_data_processing_clean_run OWNER TO oeuser; 
*/

/* 
-- Set comment on table
COMMENT ON TABLE scenario.eGo_data_processing_clean_run IS
'{
"Name": "eGo data processing - clean run",
"Source": [{
                  "Name": "open_eGo",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "2016-10-01",
"Original file": "",
"Spatial resolution": ["Germany"],
"Description": ["eGo data processing clean run"],

"Column": [
                {"Name": "id",
                "Description": "Unique identifier",
                "Unit": "" },
					
                {"Name": "version",
                "Description": "Scenario version",
                "Unit": "" },

                {"Name": "schema_name",
                "Description": "Schema name",
                "Unit": "" },
					
		{"Name": "table_name",
                "Description": "Table name",
                "Unit": "" },
					
		{"Name": "script_name",
                "Description": "Script name",
                "Unit": "" },
					
		{"Name": "entries",
                "Description": "Number of rows",
                "Unit": "" },
			
		{"Name": "status",
                "Description": "Current status and comments",
                "Unit": "" },
			
		{"Name": "timestamp",
                "Description": "Timestamp (Berlin)",
                "Unit": "" }],

"Changes":[
                {"Name": "Ludwig Hülk",
                "Mail": "ludwig.huelk@rl-institut.de",
                "Date":  "01.10.2016",
                "Comment": "Created table" }],

"ToDo": ["More attributes needed?"],
"Licence": ["tba"],
"Instructions for proper use": ["Do not drop table, always insert!"]
}'; 
*/

-- Select description
SELECT obj_description('scenario.eGo_data_processing_clean_run'::regclass)::json
