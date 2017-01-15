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

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_scenario','ego_scenario_log_setup.sql','Reset scenario list');

-- scenario list
INSERT INTO	model_draft.ego_scenario (version,version_name,release,comment,timestamp) VALUES
	('0', 'setup', 'FALSE', ' ', now() ),
	('v0.1', 'cleanrun', 'FALSE', 'data in calc schemata', now() ),
	('v0.2', ' ', 'FALSE', 'data in model_draft schema', now() ),
	('v0.2.1', ' ', 'FALSE', ' ', now() ),
	('v0.2.2', ' ', 'FALSE', ' ', now() ),
	('v0.2.3', ' ', 'FALSE', ' ', now() ),
	('v0.2.4', ' ', 'FALSE', ' ', now() ),
	('v0.2.5', ' ', 'FALSE', ' ', now() ),
	('v0.2.6', ' ', 'FALSE', ' ', now() ) ;

-- logged versions
SELECT	version
FROM 	model_draft.ego_scenario_log
	GROUP BY version 
	ORDER BY version;


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
	timestamp 	timestamp,
	metadata 	text,
	CONSTRAINT ego_scenario_log_pkey PRIMARY KEY (id));

--FK
ALTER TABLE model_draft.ego_scenario_log
	ADD CONSTRAINT ego_scenario_log_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	model_draft.ego_scenario_log OWNER TO oeuser; 

-- metadata
COMMENT ON TABLE model_draft.ego_scenario_log IS '{
	"title": "eGo Scenario Log",
	"description": "Versioning and table info",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGoDataProcessing","description": "","url": "https://github.com/openego/data_processing"} ],
	"spatial": [
		{"extend": "",
		"resolution": ""} ],
	"license": [
		{"id": "tba",
		"name": "tba",
		"version": "tba",
		"url": "tba",
		"instruction": "Do not drop table, only once and then insert!"} ],
	"contributors": [
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "01.10.2016", "comment": "Create table" },
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "12.10.2016", "comment": "Adde user_name" },
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "16.11.2016", "comment": "Adde io" },
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "16.11.2016", "comment": "Adde metadata" },
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "15.01.2017", "comment": "updated metadata"} ],
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
		"meta_version": "1.0"}] }';

-- select description
SELECT obj_description('model_draft.ego_scenario_log' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_scenario_log','ego_scenario_log_setup.sql','Reset scenario log');


-- result table

-- hvmv substation
DROP TABLE IF EXISTS	grid.ego_hvmv_substation CASCADE;
CREATE TABLE 		grid.ego_hvmv_substation (
	version 	text,
	subst_id       	smallint,
	subst_name     	text,
	ags_0 		text,
	voltage        	text,
	power_type     	text,
	substation     	text,
	osm_id         	text,
	osm_www        	text,
	frequency      	text,
	"ref"      	text,
	"operator"     	text,
	dbahn          	text,
	status		smallint,
	otg_id		bigint,
	lat            	float,
	lon            	float,
	point	   	geometry(Point,4326),
	polygon	   	geometry,
	geom 		geometry(Point,3035),
	CONSTRAINT ego_hvmv_substation_pkey PRIMARY KEY (version,subst_id));

--FK
ALTER TABLE grid.ego_hvmv_substation
	ADD CONSTRAINT ego_hvmv_substation_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
-- ALTER TABLE	grid.ego_hvmv_substation OWNER TO oeuser;

-- metadata
COMMENT ON TABLE grid.ego_hvmv_substation IS '{
	"title": "eGo HVMV Substation",
	"description": "Abstracted substations between high- and medium voltage (transition points)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "OSM","description": "OSM","url": "https://www.openstreetmap.de"},
		{"name": "eGoDataProcessing","description": "","url": "https://github.com/openego/data_processing"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "tba",
		"name": "tba",
		"version": "tba",
		"url": "tba",
		"instruction": "tba"} ],
	"contributors": [
		{"name": "Lukas Wienholt", "email": "lukas.wienholt@next-energy.de",
		"date":  "20.10.2016", "comment": "create substation" },
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "15.01.2017", "comment": "updated metadata"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "subst_id", "description": "unique identifier", "unit": "" },
				{"name": "subst_name", "description": "name of substation", "unit": "" },
				{"name": "ags_0", "description": "Geimeindeschlüssel, municipality key", "unit": "" },
				{"name": "voltage", "description": "(all) voltage levels contained in substation", "unit": "" },
				{"name": "power_type", "description": "value of osm key power", "unit": "" },
				{"name": "substation", "description": "value of osm key substation", "unit": "" },
				{"name": "osm_id", "description": "osm id of substation, begins with prefix n(node) or w(way)", "unit": "" },
				{"name": "osm_www", "description": "hyperlink to osm source", "unit": "" },
				{"name": "frequency", "description": "frequency of substation", "unit": "" },
				{"name": "ref", "description": "reference tag of substation", "unit": "" },
				{"name": "operator", "description": "operator(s) of substation", "unit": "" },
				{"name": "dbahn", "description": "states if substation is connected to railway grid and if yes the indicator", "unit": "" },
				{"name": "status", "description": "states the osm source of substation (1=way, 2=way intersected by 110kV-line, 3=node)", "unit": "" },
				{"name": "otg_id", "description": "states the id of respective bus in osmtgmod", "unit": "" },
				{"name": "lat", "description": "latitude of substation", "unit": "" },
				{"name": "lon", "description": "longitude of substation", "unit": "" },
				{"name": "point", "description": "point geometry of substation", "unit": "" },
				{"name": "polygon", "description": "original geometry of substation", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.0"}] }';

-- select description
SELECT obj_description('grid.ego_hvmv_substation' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','result','grid','ego_hvmv_substation','ego_scenario_log_setup.sql','hvmv substation');


-- mv grid district
DROP TABLE IF EXISTS	grid.ego_mv_griddistrict CASCADE;
CREATE TABLE 		grid.ego_mv_griddistrict (
	version 	text,
	subst_id       	serial NOT NULL,
	subst_sum	text,
	area_ha 	numeric,
	geom_type 	text,
	geom 		geometry(MultiPolygon,3035),
	CONSTRAINT ego_mv_griddistrict_pkey PRIMARY KEY (version,subst_id));

--FK
ALTER TABLE grid.ego_mv_griddistrict
	ADD CONSTRAINT ego_mv_griddistrict_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
-- ALTER TABLE	grid.ego_mv_griddistrict OWNER TO oeuser;

-- metadata
COMMENT ON TABLE grid.ego_mv_griddistrict IS '{
	"title": "eGo MV Grid Districts",
	"description": "Area associated with each transition point",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "BKG vg250","description": "borders","url": ""},
		{"name": "OSM","description": "OSM","url": "https://www.openstreetmap.de"},
		{"name": "eGoDataProcessing","description": "","url": "https://github.com/openego/data_processing"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "tba",
		"name": "tba",
		"version": "tba",
		"url": "tba",
		"instruction": "tba"} ],
	"contributors": [
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "02.09.2016", "comment": "create table"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "15.01.2017", "comment": "updated metadata"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "subst_id", "description": "unique identifier", "unit": "" },
				{"name": "subst_sum", "description": "number of substation per MV griddistrict", "unit": "" },
				{"name": "area_ha", "description": "area in hectar", "unit": "ha" },
				{"name": "geom_type", "description": "polygon type (polygon, multipolygon)", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.0"}] }';

-- select description
SELECT obj_description('grid.ego_mv_griddistrict' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','result','grid','ego_mv_griddistrict','ego_scenario_log_setup.sql','mv grid district');


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
	CONSTRAINT ego_loadarea_pkey PRIMARY KEY (version,id));

--FK
ALTER TABLE demand.ego_loadarea
	ADD CONSTRAINT ego_loadarea_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
-- ALTER TABLE	demand.ego_loadarea OWNER TO oeuser;

-- metadata
COMMENT ON TABLE demand.ego_loadarea IS '{
	"title": "eGo Load Area",
	"description": "Load Area with electrical consumption",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "OSM","description": "OSM","url": "https://www.openstreetmap.de"},
		{"name": "BKG vg250","description": "borders","url": ""},
		{"name": "Statistisches Bundesamt (Destatis)","description": "Population raster","url": "https://www.destatis.de/DE/Methoden/Zensus_/Zensus.html"},
		{"name": "eGoDataProcessing","description": "","url": "https://github.com/openego/data_processing"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "tba",
		"name": "tba",
		"version": "tba",
		"url": "tba",
		"instruction": "tba"} ],
	"contributors": [
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date":  "02.10.2016", "comment": "create loadareas" },
		{"name": "Ilka Cussmann", "email": "ilka.cussmann@hs-flensburg.de",
		"date":  "25.10.2016", "comment": "create metadata" },
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "15.01.2017", "comment": "updated metadata"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", 	"description": "version id", "unit": "" },
				{"name": "id", 		"description": "unique identifier", "unit": "" },
				{"name": "subst_id", 	"description": "substation id", "unit": "" },
				{"name": "area_ha", 	"description": "area in hectar", "unit": "ha" },
				{"name": "nuts", 	"description": "nuts id", "unit": "" },
				{"name": "rs_0", 	"description": "Geimeindeschlüssel, municipality key", "unit": "" },
				{"name": "ags_0", 	"description": "Geimeindeschlüssel, municipality key", "unit": "" },
				{"name": "otg_id", 	"description": "states the id of respective bus in osmtgmod", "unit": "" },
				{"name": "zensus_sum", 		"description": "population", "unit": "" },
				{"name": "zensus_count", 	"description": "number of population rasters", "unit": "" },
				{"name": "zensus_density", 	"description": "average population per raster (zensus_sum/zensus_count)", "unit": "" },
				{"name": "sector_area_residential", 	"description": "aggregated residential area", "unit": "ha" },
				{"name": "sector_area_retail", 		"description": "aggregated retail area", "unit": "ha" },
				{"name": "sector_area_industrial", 	"description": "aggregated industrial area", "unit": "ha" },
				{"name": "sector_area_agricultural", 	"description": "aggregated agricultural area", "unit": "ha" },
				{"name": "sector_area_sum", 		"description": "aggregated sector area", "unit": "ha" },
				{"name": "sector_share_residential", 	"description": "percentage of residential area per load area", "unit": "%" },
				{"name": "sector_share_retail", 	"description": "percentage of retail area per load area", "unit": "%" },
				{"name": "sector_share_industrial", 	"description": "percentage of industrial area per load area", "unit": "%" },
				{"name": "sector_share_agricultural", 	"description": "percentage of agricultural area per load area", "unit": "%" },
				{"name": "sector_share_sum", 		"description": "percentage of sector area per load area", "unit": "%" },
				{"name": "sector_count_residential", 	"description": "number of residential areas per load area", "unit": "" },
				{"name": "sector_count_retail", 	"description": "number of retail areas per load area", "unit": "" },
				{"name": "sector_count_industrial", 	"description": "number of industrial areas per load area", "unit": "" },
				{"name": "sector_count_agricultural", 	"description": "number of agricultural areas per load area", "unit": "" },
				{"name": "sector_count_sum", 		"description": "number of sector areas per load area", "unit": "" },
				{"name": "sector_consumption_residential", 	"description": "electricity consumption of residential sector", "unit": "GWh" },
				{"name": "sector_consumption_retail", 		"description": "electricity consumption of retail sector", "unit": "GWh" },
				{"name": "sector_consumption_industrial", 	"description": "electricity consumption of industrial sector", "unit": "GWh" },
				{"name": "sector_consumption_agricultural", 	"description": "electricity consumption of agricultural sector", "unit": "GWh" },
				{"name": "sector_consumption_sum", 		"description": "", "unit": "" },
				{"name": "geom_centroid", 	"description": "centroid (can be outside the polygon)", "unit": "" },
				{"name": "geom_surfacepoint", 	"description": "point on surface", "unit": "" },
				{"name": "geom_centre", 	"description": "centroid and point on surface when centroid outside the polygon", "unit": "" },
				{"name": "geom", 		"description": "geometry", "unit": "" } ]},
		"meta_version": "1.0"}] }';

-- select description
SELECT obj_description('demand.ego_loadarea' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','result','demand','ego_loadarea','ego_scenario_log_setup.sql','load area');
