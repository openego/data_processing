/*
Setup scenario log table
Creates a table to get inserts from other processed tables

WARNING: It drops the table and deletes old entries when executed!

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
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

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_scenario','ego_scenario_log_setup.sql','Reset scenario list');

-- scenario list
INSERT INTO	model_draft.ego_scenario (version,version_name,release,comment,timestamp) VALUES
	('0', 'setup', 'FALSE', ' ', ' ' ),
	('v0.1', 'cleanrun', 'FALSE', 'data in calc schemata', ' '  ),
	('v0.2', 'restructure', 'FALSE', 'data in model_draft schema', ' '  ),
	('v0.2.1', ' ', 'FALSE', ' ', ' '  ),
	('v0.2.2', ' ', 'FALSE', ' ', ' '  ),
	('v0.2.3', ' ', 'FALSE', ' ', ' '  ),
	('v0.2.4', ' ', 'FALSE', ' ', ' '  ),
	('v0.2.5', 'mockrun', 'FALSE', 'finished but revealed major bugs', '2017-03-03' ),
	('v0.2.6', 'premiere', 'TRUE', 'First complete relase', '2017-03-23' ) ; 

-- metadata
COMMENT ON TABLE model_draft.ego_scenario IS '{
	"title": "eGo dataprocessing - Scenario list",
	"description": "Version info",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ",
		"url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)"} ],
	"spatial": [
		{"extend": "",
		"resolution": ""} ],
	"license": [
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!"} ],
	"contributors": [
		{"name": "Ludee", "email": "",
		"date": "01.10.2016", "comment": "Create table" },
		{"name": "Ludee", "email": "",
		"date": "16.11.2016", "comment": "Add metadata" },
		{"name": "Ludee", "email": " ",
		"date": "21.03.2017", "comment": "Update metadata to 1.1"}		],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "scenario version number", "unit": "" },
				{"name": "version_name", "description": "version name", "unit": "" },
				{"name": "release", "description": "external release", "unit": "" },
				{"name": "comment", "description": "additional information and comments", "unit": "" },
				{"name": "timestamp", "description": "timestamp (Berlin)", "unit": "" } ]},
		"meta_version": "1.1"}] }' ;

-- select description
SELECT obj_description('model_draft.ego_scenario' ::regclass) ::json;

/* -- logged versions
SELECT	version
FROM 	model_draft.ego_scenario_log
	GROUP BY version 
	ORDER BY version; */


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

-- metadata
COMMENT ON TABLE model_draft.ego_scenario_log IS '{
	"title": "eGo dataprocessing - Scenario log",
	"description": "Versioning and table info",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ",
		"url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)"} ],
	"spatial": [
		{"extend": "",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!"} ],
	"contributors": [
		{"name": "Ludee", "email": "",
		"date": "01.10.2016", "comment": "Create table" },
		{"name": "Ludee", "email": "",
		"date": "12.10.2016", "comment": "Add user_name" },
		{"name": "Ludee", "email": "",
		"date": "16.11.2016", "comment": "Add io" },
		{"name": "Ludee", "email": "",
		"date": "16.11.2016", "comment": "Add metadata" },
		{"name": "Ludee", "email": "",
		"date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "",
		"date": "21.03.2017", "comment": "Update metadata to 1.1"} ],
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
		"meta_version": "1.1"}] }';

-- select description
SELECT obj_description('model_draft.ego_scenario_log' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_scenario_log','ego_scenario_log_setup.sql','Reset scenario log');



-- result tables for eGoDP

-- substation (EHV, HVMV, MVLV)

-- EHV(HV) substation
DROP TABLE IF EXISTS	grid.ego_ehv_substation CASCADE;
CREATE TABLE 		grid.ego_ehv_substation (
	version 	text,
	subst_id       	integer,
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
	CONSTRAINT ego_ehv_substation_pkey PRIMARY KEY (version,subst_id));

--FK
ALTER TABLE grid.ego_ehv_substation
	ADD CONSTRAINT ego_ehv_substation_fkey FOREIGN KEY (version) 
		REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_ehv_substation OWNER TO oeuser;

-- metadata
COMMENT ON TABLE grid.ego_ehv_substation IS '{
	"title": "eGo dataprocessing - EHV(HV) Substation",
	"description": "Abstracted substation between extrahigh- and high voltage (Transmission substation)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ",
		"url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)"},
		{"name": "OpenStreetMap", "description": "© OpenStreetMap contributors",
		"url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0"}
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": "© GeoBasis-DE / BKG 2016 (Daten verändert)",
		"url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!"} ],
	"contributors": [
		{"name": "lukasol", "email": "",
		"date":  "20.10.2016", "comment": "Create substations" },
		{"name": "Ludee", "email": "",
		"date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "",
		"date": "21.03.2017", "comment": "Update metadata to 1.1"} ],
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
		"meta_version": "1.1"}] }';

-- select description
SELECT obj_description('grid.ego_ehv_substation' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','grid','ego_ehv_substation','ego_scenario_log_setup.sql','hvmv substation');


-- HVMV substation
DROP TABLE IF EXISTS	grid.ego_hvmv_substation CASCADE;
CREATE TABLE 		grid.ego_hvmv_substation (
	version 	text,
	subst_id       	integer,
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
ALTER TABLE	grid.ego_hvmv_substation OWNER TO oeuser;

-- metadata
COMMENT ON TABLE grid.ego_hvmv_substation IS '{
	"title": "eGo dataprocessing - HVMV Substation",
	"description": "Abstracted substation between high- and medium voltage (Transition point)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ",
		"url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)"},
		{"name": "OpenStreetMap", "description": "© OpenStreetMap contributors",
		"url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0"}
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": "© GeoBasis-DE / BKG 2016 (Daten verändert)",
		"url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!"} ],
	"contributors": [
		{"name": "lukasol", "email": "",
		"date":  "20.10.2016", "comment": "Create substations" },
		{"name": "Ludee", "email": "",
		"date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "",
		"date": "21.03.2017", "comment": "Update metadata to 1.1"} ],
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
		"meta_version": "1.1"}] }';

-- select description
SELECT obj_description('grid.ego_hvmv_substation' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','grid','ego_hvmv_substation','ego_scenario_log_setup.sql','hvmv substation');



-- MVLV substation
DROP TABLE IF EXISTS	grid.ego_mvlv_substation CASCADE;
CREATE TABLE 		grid.ego_mvlv_substation (
	version 	text,
	subst_id	integer,
	mvgd_id       	integer,
	geom 		geometry(Point,3035),
	CONSTRAINT ego_mvlv_substation_pkey PRIMARY KEY (version,subst_id));

--FK
ALTER TABLE grid.ego_mvlv_substation
	ADD CONSTRAINT ego_mvlv_substation_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_mvlv_substation OWNER TO oeuser;

-- metadata
COMMENT ON TABLE grid.ego_mvlv_substation IS '{
	"title": "eGo dataprocessing - HVMV Substation",
	"description": "Abstracted substation between medium- and low voltage (Distribution substation)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ",
		"url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)"},
		{"name": "OpenStreetMap", "description": "© OpenStreetMap contributors",
		"url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0"}
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": "© GeoBasis-DE / BKG 2016 (Daten verändert)",
		"url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!"} ],
	"contributors": [
		{"name": "jong42", "email": "",
		"date": "20.10.2016", "comment": "Create table"},
		{"name": "jong42", "email": "",
		"date": "27.10.2016", "comment": "Change table names"},
		{"name": "Ludee", "email": "",
		"date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "",
		"date": "21.03.2017", "comment": "Update metadata to 1.1"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "subst_id", "description": "unique identifier", "unit": "" },
				{"name": "mvgd_id", "description": "corresponding hvmv substation", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.1"}] }';

-- select description
SELECT obj_description('grid.ego_mvlv_substation' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','grid','ego_mvlv_substation','ego_scenario_log_setup.sql','hvmv substation');


-- Catchment areas

-- EHV Transmission grid area
DROP TABLE IF EXISTS	grid.ego_ehv_griddistrict CASCADE;
CREATE TABLE 		grid.ego_ehv_griddistrict (
	version 	text,
	subst_id 	integer NOT NULL,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_ehv_griddistrict_pkey PRIMARY KEY (version,subst_id));

--FK
ALTER TABLE grid.ego_ehv_griddistrict
	ADD CONSTRAINT ego_ehv_griddistrict_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_ehv_griddistrict OWNER TO oeuser;

-- metadata
COMMENT ON TABLE grid.ego_ehv_griddistrict IS '{
	"title": "eGo dataprocessing - EHV Transmission grid area",
	"description": "Catchment area of EHV substation (Transmission substation)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ",
		"url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)"},
		{"name": "OpenStreetMap", "description": "© OpenStreetMap contributors",
		"url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0"}
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": "© GeoBasis-DE / BKG 2016 (Daten verändert)",
		"url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!"} ],
	"contributors": [
		{"name": "Ludee", "email": "",
		"date": "02.09.2016", "comment": "Create table"},
		{"name": "Ludee", "email": "",
		"date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "",
		"date": "21.03.2017", "comment": "Update metadata to 1.1"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "subst_id", "description": "unique identifier", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.1"}] }';

-- select description
SELECT obj_description('grid.ego_ehv_griddistrict' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','grid','ego_ehv_griddistrict','ego_scenario_log_setup.sql','mv grid district');


-- MV griddistrict
DROP TABLE IF EXISTS	grid.ego_mv_griddistrict CASCADE;
CREATE TABLE 		grid.ego_mv_griddistrict (
	version 	text,
	subst_id 	integer NOT NULL,
	subst_sum 	integer,
	type1 		integer,
	type1_cnt 	integer,
	type2 		integer,
	type2_cnt 	integer,
	type3 		integer,
	type3_cnt 	integer,
	"group" 	character(1),
	gem 		integer,
	gem_clean 	integer,
	zensus_sum 	integer,
	zensus_count 	integer,
	zensus_density 	numeric,
	population_density numeric,
	la_count 	integer,
	area_ha 	numeric,
	la_area 	numeric(10,1),
	free_area 	numeric(10,1),
	area_share 	numeric(4,1),
	consumption 	numeric,
	consumption_per_area numeric,
	dea_cnt 	integer,
	dea_capacity 	numeric,
	lv_dea_cnt 	integer,
	lv_dea_capacity numeric,
	mv_dea_cnt 	integer,
	mv_dea_capacity numeric,
	geom_type 	text,
	geom 		geometry(MultiPolygon,3035),
	CONSTRAINT ego_mv_griddistrict_pkey PRIMARY KEY (version,subst_id));

--FK
ALTER TABLE grid.ego_mv_griddistrict
	ADD CONSTRAINT ego_mv_griddistrict_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_mv_griddistrict OWNER TO oeuser;

-- metadata
COMMENT ON TABLE grid.ego_mv_griddistrict IS '{
	"title": "eGo dataprocessing - MV Grid district",
	"description": "Catchment area of HVMV substation (Transition point)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ",
		"url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)"},
		{"name": "OpenStreetMap", "description": "© OpenStreetMap contributors",
		"url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0"}
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": "© GeoBasis-DE / BKG 2016 (Daten verändert)",
		"url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!"} ],
	"contributors": [
		{"name": "Ludee", "email": "",
		"date": "02.09.2016", "comment": "Create table"},
		{"name": "Ludee", "email": "",
		"date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "",
		"date": "21.03.2017", "comment": "Update metadata to 1.1"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "subst_id", "description": "unique identifier", "unit": "" },
				{"name": "subst_sum", "description": "number of substation per MV griddistrict", "unit": "" },
				{"name": "area_ha", "description": "area in hectar", "unit": "ha" },
				{"name": "geom_type", "description": "polygon type (polygon, multipolygon)", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.1"}] }';

-- select description
SELECT obj_description('grid.ego_mv_griddistrict' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','grid','ego_mv_griddistrict','ego_scenario_log_setup.sql','mv grid district');



-- LV griddistrict
DROP TABLE IF EXISTS	grid.ego_lv_griddistrict CASCADE;
CREATE TABLE 		grid.ego_lv_griddistrict (
	version 	text,
	id 		integer NOT NULL,
	subst_id	integer,
	la_id	 	integer,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_lv_griddistrict_pkey PRIMARY KEY (version,subst_id));

--FK
ALTER TABLE grid.ego_lv_griddistrict
	ADD CONSTRAINT ego_lv_griddistrict_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_lv_griddistrict OWNER TO oeuser;

-- metadata
COMMENT ON TABLE grid.ego_lv_griddistrict IS '{
	"title": "eGo dataprocessing - LV Distribution grid area",
	"description": "Catchment area of MVLV substation (Distribution substation)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ",
		"url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)"},
		{"name": "OpenStreetMap", "description": "© OpenStreetMap contributors",
		"url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0"}
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": "© GeoBasis-DE / BKG 2016 (Daten verändert)",
		"url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!"} ],
	"contributors": [
		{"name": "Ludee", "email": "",
		"date": "02.09.2016", "comment": "Create table"},
		{"name": "Ludee", "email": "",
		"date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "",
		"date": "21.03.2017", "comment": "Update metadata to 1.1"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "subst_id", "description": "unique identifier", "unit": "" },
				{"name": "subst_sum", "description": "number of substation per MV griddistrict", "unit": "" },
				{"name": "area_ha", "description": "area in hectar", "unit": "ha" },
				{"name": "geom_type", "description": "polygon type (polygon, multipolygon)", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.1"}] }';

-- select description
SELECT obj_description('grid.ego_lv_griddistrict' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','grid','ego_lv_griddistrict','ego_scenario_log_setup.sql','mv grid district');


-- Demand

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
ALTER TABLE	demand.ego_loadarea OWNER TO oeuser;

-- metadata
COMMENT ON TABLE demand.ego_loadarea IS '{
	"title": "eGo dataprocessing - Load area",
	"description": "Load Area with electrical consumption",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ",
		"url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)"},
		{"name": "OpenStreetMap", "description": "© OpenStreetMap contributors",
		"url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0"}
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": "© GeoBasis-DE / BKG 2016 (Daten verändert)",
		"url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)"},
		{"name": "Statistisches Bundesamt (Destatis) - Zensus2011", "description": "© Statistisches Bundesamt, Wiesbaden, Genesis-Online, 2016; Datenlizenz by-2-0",
		"url": "https://www.destatis.de/DE/Methoden/Zensus_/Zensus.html", "license": "Datenlizenz Deutschland – Namensnennung – Version 2.0"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!"} ],
	"contributors": [
		{"name": "Ludee", "email": "",
		"date":  "02.10.2016", "comment": "Create loadareas" },
		{"name": "Ilka Cussmann", "email": "",
		"date":  "25.10.2016", "comment": "Create metadata" },
		{"name": "Ludee", "email": "",
		"date": "15.01.2017", "comment": "update metadata"},
		{"name": "Ludee", "email": "",
		"date": "21.03.2017", "comment": "Update metadata to 1.1"} ],
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
				{"name": "sector_share_residential", 	"description": "percentage of residential area per load area", "unit":"" },
				{"name": "sector_share_retail", 	"description": "percentage of retail area per load area", "unit": ""},
				{"name": "sector_share_industrial", 	"description": "percentage of industrial area per load area", "unit": ""},
				{"name": "sector_share_agricultural", 	"description": "percentage of agricultural area per load area", "unit": "" },
				{"name": "sector_share_sum", 		"description": "percentage of sector area per load area", "unit": "" },
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
		"meta_version": "1.1"}] }';

-- select description
SELECT obj_description('demand.ego_loadarea' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','demand','ego_loadarea','ego_scenario_log_setup.sql','load area');
