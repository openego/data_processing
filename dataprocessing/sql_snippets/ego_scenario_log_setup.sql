/*
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


-- hvmv substation
DROP TABLE IF EXISTS	grid.ego_hvmv_substation CASCADE;
CREATE TABLE 		grid.ego_hvmv_substation (
	version 	text,
	subst_id       	serial NOT NULL,
	subst_name     	text,
	ags_0 		text,
	voltage        	text,
	power_type     	text,
	substation     	text,
	osm_id         	text,
	osm_www        	text NOT NULL,
	frequency      	text,
	"ref"      	text,
	"operator"     	text,
	dbahn          	text,
	status		smallint NOT NULL,
	lat            	float NOT NULL,
	lon            	float NOT NULL,
	point	   	geometry(Point,4326) NOT NULL,
	polygon	   	geometry(Polygon,4326) NOT NULL,
	geom 		geometry(Point,3035),
	CONSTRAINT ego_hvmv_substation_pkey PRIMARY KEY (version,subst_id));

-- grant (oeuser)
-- ALTER TABLE	grid.ego_hvmv_substation OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','grid','ego_hvmv_substation','ego_scenario_log_setup.sql','hvmv substation');


-- load area
DROP TABLE IF EXISTS	demand.ego_loadarea CASCADE;
CREATE TABLE 		demand.ego_loadarea (
	version 	text,
	id 		integer,
	subst_id 	integer,
	area_ha 	numeric,
	nuts 		varchar(5),
	rs_0 		varchar(12),
	ags_0 		varchar(12),
	otg_id 		integer,
	un_id 		integer,
	zensus_sum 	integer,
	zensus_count 	integer,
	zensus_density 	numeric,
	ioer_sum 	numeric,
	ioer_count 	integer,
	ioer_density 	numeric,
	sector_area_residential 	numeric,
	sector_area_retail 		numeric,
	sector_area_industrial 		numeric,
	sector_area_agricultural 	numeric,
	sector_area_sum 		numeric,	
	sector_share_residential 	numeric,
	sector_share_retail 		numeric,
	sector_share_industrial 	numeric,
	sector_share_agricultural 	numeric,
	sector_share_sum 		numeric,
	sector_count_residential 	integer,
	sector_count_retail 		integer,
	sector_count_industrial 	integer,
	sector_count_agricultural 	integer,
	sector_count_sum 		integer,
	sector_consumption_residential 	numeric,
	sector_consumption_retail 	numeric,
	sector_consumption_industrial	numeric,
	sector_consumption_agricultural numeric,
	sector_consumption_sum 		numeric,
	geom_centroid 		geometry(Point,3035),
	geom_surfacepoint 	geometry(Point,3035),
	geom_centre 		geometry(Point,3035),
	geom 			geometry(Polygon,3035),
	CONSTRAINTego_loadarea_pkey PRIMARY KEY (version,id));

-- grant (oeuser)
-- ALTER TABLE	demand.ego_loadarea OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','demand','ego_loadarea','ego_scenario_log_setup.sql','hvmv substation');


-- hvmv substation
DROP TABLE IF EXISTS	grid.ego_mv_griddistrict CASCADE;
CREATE TABLE 		grid.ego_mv_griddistrict (
	version 	text,
	subst_id       	serial NOT NULL,
	subst_sum	text,
	area_ha 	numeric,
	geom_type 	text,
	geom 		geometry(MultiPolygon,3035),
	CONSTRAINT ego_hvmv_substation_pkey PRIMARY KEY (version,subst_id));

-- grant (oeuser)
-- ALTER TABLE	grid.ego_hvmv_substation OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','grid','ego_hvmv_substation','ego_scenario_log_setup.sql','hvmv substation');
