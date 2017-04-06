/*
Result tables for eGoDP

WARNING: It drops the table and deletes old entries when executed!

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- substation (EHV, HVMV, MVLV)

-- EHV(HV) substation
DROP TABLE IF EXISTS	grid.ego_dp_ehv_substation CASCADE;
CREATE TABLE 		grid.ego_dp_ehv_substation (
	version 	text,
	subst_id integer,
	lon double precision,
	lat double precision,
	point geometry(Point,4326),
	polygon geometry,
	voltage text,
	power_type text,
	substation text,
	osm_id text,
	osm_www text,
	frequency text,
	subst_name text,
	ref text,
	operator text,
	dbahn text,
	status smallint,
	otg_id bigint,
	CONSTRAINT ego_dp_ehv_substation_pkey PRIMARY KEY (version,subst_id));

--FK
ALTER TABLE grid.ego_dp_ehv_substation
	ADD CONSTRAINT ego_dp_ehv_substation_fkey FOREIGN KEY (version) 
		REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_dp_ehv_substation OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_dp_ehv_substation_point_idx
	ON grid.ego_dp_ehv_substation USING GIST (point);

-- metadata
COMMENT ON TABLE grid.ego_dp_ehv_substation IS '{
	"title": "eGo dataprocessing - EHV(HV) Substation",
	"description": "Abstracted substation between extrahigh- and high voltage (Transmission substation)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": " ", "url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)", "copyright": "© GeoBasis-DE / BKG 2016 (Data changed)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© NEXT ENERGY"} ],
	"contributors": [
		{"name": "lukasol", "email": "", "date":  "20.10.2016", "comment": "Create substations" },
		{"name": "Ludee", "email": "", "date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "", "date": "21.03.2017", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-04-06", "comment": "Update metadata to 1.2"}],
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
		"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_dp_ehv_substation' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','grid','ego_dp_ehv_substation','ego_dp_structure_versioning.sql','hvmv substation');


-- HVMV substation
DROP TABLE IF EXISTS	grid.ego_dp_hvmv_substation CASCADE;
CREATE TABLE 		grid.ego_dp_hvmv_substation (
	version 	text,
	subst_id integer,
	lon double precision,
	lat double precision,
	point geometry(Point,4326),
	polygon geometry,
	voltage text,
	power_type text,
	substation text,
	osm_id text,
	osm_www text,
	frequency text,
	subst_name text,
	ref text,
	operator text,
	dbahn text,
	status smallint,
	otg_id bigint,
	ags_0 text,
	geom geometry(Point,3035),
	CONSTRAINT ego_dp_hvmv_substation_pkey PRIMARY KEY (version,subst_id));

--FK
ALTER TABLE grid.ego_dp_hvmv_substation
	ADD CONSTRAINT ego_dp_hvmv_substation_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_dp_hvmv_substation OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_dp_hvmv_substation_geom_idx
	ON grid.ego_dp_hvmv_substation USING GIST (geom);

-- metadata
COMMENT ON TABLE grid.ego_dp_hvmv_substation IS '{
	"title": "eGo dataprocessing - HVMV Substation",
	"description": "Abstracted substation between high- and medium voltage (Transition point)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": " ", "url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)", "copyright": "© GeoBasis-DE / BKG 2016 (Data changed)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© NEXT ENERGY"} ],
	"contributors": [
		{"name": "lukasol", "email": "", "date":  "20.10.2016", "comment": "Create substations" },
		{"name": "Ludee", "email": "", "date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "", "date": "21.03.2017", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-04-06", "comment": "Update metadata to 1.2"} ],
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
		"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_dp_hvmv_substation' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','grid','ego_dp_hvmv_substation','ego_dp_structure_versioning.sql','hvmv substation');



-- MVLV substation
DROP TABLE IF EXISTS	grid.ego_dp_mvlv_substation CASCADE;
CREATE TABLE 		grid.ego_dp_mvlv_substation (
	version 	text,
	mvlv_subst_id integer,
	la_id integer,
	subst_id integer,
	geom geometry(Point,3035),
	is_dummy boolean,
	CONSTRAINT ego_dp_mvlv_substation_pkey PRIMARY KEY (version,mvlv_subst_id));

--FK
ALTER TABLE grid.ego_dp_mvlv_substation
	ADD CONSTRAINT ego_dp_mvlv_substation_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_dp_mvlv_substation OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_dp_mvlv_substation_geom_idx
	ON grid.ego_dp_mvlv_substation USING GIST (geom);

-- metadata
COMMENT ON TABLE grid.ego_dp_mvlv_substation IS '{
	"title": "eGo dataprocessing - HVMV Substation",
	"description": "Abstracted substation between medium- and low voltage (Distribution substation)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": " ", "url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)", "copyright": "© GeoBasis-DE / BKG 2016 (Data changed)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Reiner Lemoine Institut"} ],
	"contributors": [
		{"name": "jong42", "email": "", "date": "20.10.2016", "comment": "Create table"},
		{"name": "jong42", "email": "", "date": "27.10.2016", "comment": "Change table names"},
		{"name": "Ludee", "email": "", "date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "", "date": "21.03.2017", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-04-06", "comment": "Update metadata to 1.2"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "subst_id", "description": "unique identifier", "unit": "" },
				{"name": "mvgd_id", "description": "corresponding hvmv substation", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_dp_mvlv_substation' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','grid','ego_dp_mvlv_substation','ego_dp_structure_versioning.sql','hvmv substation');


-- Catchment areas

-- EHV Transmission grid area
DROP TABLE IF EXISTS	grid.ego_dp_ehv_griddistrict CASCADE;
CREATE TABLE 		grid.ego_dp_ehv_griddistrict (
	version 	text,
	geom geometry(Polygon,4326),
	subst_id integer NOT NULL,
	CONSTRAINT ego_dp_ehv_griddistrict_pkey PRIMARY KEY (version,subst_id));

--FK
ALTER TABLE grid.ego_dp_ehv_griddistrict
	ADD CONSTRAINT ego_dp_ehv_griddistrict_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_dp_ehv_griddistrict OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_dp_ehv_griddistrict_geom_idx
	ON grid.ego_dp_ehv_griddistrict USING GIST (geom);

-- metadata
COMMENT ON TABLE grid.ego_dp_ehv_griddistrict IS '{
	"title": "eGo dataprocessing - EHV Transmission grid area",
	"description": "Catchment area of EHV substation (Transmission substation)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": " ", "url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)", "copyright": "© GeoBasis-DE / BKG 2016 (Data changed)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© ZNES"} ],
	"contributors": [
		{"name": "Ludee", "email": "", "date": "02.09.2016", "comment": "Create table"},
		{"name": "Ludee", "email": "", "date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "", "date": "21.03.2017", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-04-06", "comment": "Update metadata to 1.2"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "subst_id", "description": "unique identifier", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_dp_ehv_griddistrict' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','grid','ego_dp_ehv_griddistrict','ego_dp_structure_versioning.sql','mv grid district');


-- MV griddistrict
DROP TABLE IF EXISTS	grid.ego_dp_mv_griddistrict CASCADE;
CREATE TABLE 		grid.ego_dp_mv_griddistrict (
	version 	text,
	subst_id integer,
	subst_sum integer,
	type1 integer,
	type1_cnt integer,
	type2 integer,
	type2_cnt integer,
	type3 integer,
	type3_cnt integer,
	"group" character(1),
	gem integer,
	gem_clean integer,
	zensus_sum integer,
	zensus_count integer,
	zensus_density numeric,
	population_density numeric,
	la_count integer,
	area_ha numeric,
	la_area numeric(10,1),
	free_area numeric(10,1),
	area_share numeric(4,1),
	consumption numeric,
	consumption_per_area numeric,
	dea_cnt integer,
	dea_capacity numeric,
	lv_dea_cnt integer,
	lv_dea_capacity numeric,
	mv_dea_cnt integer,
	mv_dea_capacity numeric,
	geom_type text,
	geom geometry(MultiPolygon,3035),
	CONSTRAINT ego_dp_mv_griddistrict_pkey PRIMARY KEY (version,subst_id));

--FK
ALTER TABLE grid.ego_dp_mv_griddistrict
	ADD CONSTRAINT ego_dp_mv_griddistrict_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_dp_mv_griddistrict OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_dp_mv_griddistrict_geom_idx
	ON grid.ego_dp_mv_griddistrict USING GIST (geom);

-- metadata
COMMENT ON TABLE grid.ego_dp_mv_griddistrict IS '{
	"title": "eGo dataprocessing - MV Grid district",
	"description": "Catchment area of HVMV substation (Transition point)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": " ", "url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)", "copyright": "© GeoBasis-DE / BKG 2016 (Data changed)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Reiner Lemoine Institut"} ],
	"contributors": [
		{"name": "Ludee", "email": "", "date": "02.09.2016", "comment": "Create table"},
		{"name": "Ludee", "email": "", "date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "", "date": "21.03.2017", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-04-06", "comment": "Update metadata to 1.2"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "subst_id", "description": "unique identifier", "unit": "" },
				{"name": "subst_sum", "description": "number of substation per MV griddistrict", "unit": "" },
				{"name": "area_ha", "description": "area in hectar", "unit": "ha" },
				{"name": "geom_type", "description": "polygon type (polygon, multipolygon)", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_dp_mv_griddistrict' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','grid','ego_dp_mv_griddistrict','ego_dp_structure_versioning.sql','mv grid district');


-- in process

-- LV griddistrict
DROP TABLE IF EXISTS	grid.ego_dp_lv_griddistrict CASCADE;
CREATE TABLE 		grid.ego_dp_lv_griddistrict (
	version 	text,
	mvlv_subst_id	integer,
	mvlv_subst_id_new	integer,
	subst_id	integer,
	la_id 		integer,
	nn		boolean,
	geom		geometry(MultiPolygon,3035),
	CONSTRAINT ego_dp_lv_griddistrict_pkey PRIMARY KEY (version,mvlv_subst_id));
	
/* 
-- LV griddistrict
DROP TABLE IF EXISTS	grid.ego_dp_lv_griddistrict CASCADE;
CREATE TABLE 		grid.ego_dp_lv_griddistrict (
	version 	text,
	id integer,
	geom geometry(Polygon,3035),
	load_area_id integer,
	ont_count integer,
	ont_id integer,
	merge_id integer,
	mvlv_subst_id integer,
	CONSTRAINT ego_dp_lv_griddistrict_pkey PRIMARY KEY (version,id));
 */

--FK
ALTER TABLE grid.ego_dp_lv_griddistrict
	ADD CONSTRAINT ego_dp_lv_griddistrict_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_dp_lv_griddistrict OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_dp_lv_griddistrict_geom_idx
	ON grid.ego_dp_lv_griddistrict USING GIST (geom);

-- metadata
COMMENT ON TABLE grid.ego_dp_lv_griddistrict IS '{
	"title": "eGo dataprocessing - LV Distribution grid area",
	"description": "Catchment area of MVLV substation (Distribution substation)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": " ", "url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)", "copyright": "© GeoBasis-DE / BKG 2016 (Data changed)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Reiner Lemoine Institut"} ],
	"contributors": [
		{"name": "Ludee", "email": "", "date": "02.09.2016", "comment": "Create table"},
		{"name": "Ludee", "email": "", "date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "", "date": "21.03.2017", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-04-06", "comment": "Update metadata to 1.2"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "subst_id", "description": "unique identifier", "unit": "" },
				{"name": "subst_sum", "description": "number of substation per MV griddistrict", "unit": "" },
				{"name": "area_ha", "description": "area in hectar", "unit": "ha" },
				{"name": "geom_type", "description": "polygon type (polygon, multipolygon)", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_dp_lv_griddistrict' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','grid','ego_dp_lv_griddistrict','ego_dp_structure_versioning.sql','mv grid district');


-- Demand

-- load area
DROP TABLE IF EXISTS	demand.ego_dp_loadarea CASCADE;
CREATE TABLE 		demand.ego_dp_loadarea (
	version 	text,
	id integer,
	subst_id integer,
	area_ha numeric,
	nuts character varying(5),
	rs_0 character varying(12),
	ags_0 character varying(12),
	otg_id integer,
	un_id integer,
	zensus_sum integer,
	zensus_count integer,
	zensus_density numeric,
	ioer_sum numeric,
	ioer_count integer,
	ioer_density numeric,
	sector_area_residential numeric,
	sector_area_retail numeric,
	sector_area_industrial numeric,
	sector_area_agricultural numeric,
	sector_area_sum numeric,
	sector_share_residential numeric,
	sector_share_retail numeric,
	sector_share_industrial numeric,
	sector_share_agricultural numeric,
	sector_share_sum numeric,
	sector_count_residential integer,
	sector_count_retail integer,
	sector_count_industrial integer,
	sector_count_agricultural integer,
	sector_count_sum integer,
	sector_consumption_residential double precision,
	sector_consumption_retail double precision,
	sector_consumption_industrial double precision,
	sector_consumption_agricultural double precision,
	sector_consumption_sum double precision,
	geom_centroid geometry(Point,3035),
	geom_surfacepoint geometry(Point,3035),
	geom_centre geometry(Point,3035),
	geom geometry(Polygon,3035),
	CONSTRAINT ego_dp_loadarea_pkey PRIMARY KEY (version,id));

--FK
ALTER TABLE demand.ego_dp_loadarea
	ADD CONSTRAINT ego_dp_loadarea_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	demand.ego_dp_loadarea OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_dp_loadarea_geom_idx
	ON demand.ego_dp_loadarea USING GIST (geom);

-- metadata
COMMENT ON TABLE demand.ego_dp_loadarea IS '{
	"title": "eGo dataprocessing - Loadarea",
	"description": "Loadarea with electrical consumption per sector",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": " ", "url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)", "copyright": "© GeoBasis-DE / BKG 2016 (data changed)"},
		{"name": "Statistisches Bundesamt (Destatis) - Zensus2011", "description": " ", "url": "https://www.destatis.de/DE/Methoden/Zensus_/Zensus.html", "license": "Datenlizenz Deutschland – Namensnennung – Version 2.0", "copyright": "© Statistisches Bundesamt, Wiesbaden, Genesis-Online, 2016; Datenlizenz by-2-0"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": " "} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Reiner Lemoine Institut"} ],
	"contributors": [
		{"name": "Ludee", "email": " ", "date": "02.10.2016", "comment": "Create loadareas" },
		{"name": "Ilka Cussmann", "email": " ", "date": "25.10.2016", "comment": "Create metadata" },
		{"name": "Ludee", "email": " ", "date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": " ", "date": "21.03.2017", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": " ", "date": "2017-03-21", "comment": "Update metadata to 1.2"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", 	"description": "Version id", "unit": "" },
				{"name": "id", 		"description": "Unique identifier", "unit": "" },
				{"name": "subst_id", 	"description": "Substation id", "unit": "" },
				{"name": "area_ha", 	"description": "Area", "unit": "ha" },
				{"name": "nuts", 	"description": "Nuts id", "unit": "" },
				{"name": "rs_0", 	"description": "Geimeindeschlüssel, municipality key", "unit": "" },
				{"name": "ags_0", 	"description": "Geimeindeschlüssel, municipality key", "unit": "" },
				{"name": "otg_id", 	"description": "States the id of respective bus in osmtgmod", "unit": "" },
				{"name": "zensus_sum", 		"description": "Population", "unit": "" },
				{"name": "zensus_count", 	"description": "Number of population rasters", "unit": "" },
				{"name": "zensus_density", 	"description": "Average population per raster (zensus_sum/zensus_count)", "unit": "" },
				{"name": "sector_area_residential", 	"description": "Aggregated residential area", "unit": "ha" },
				{"name": "sector_area_retail", 		"description": "Aggregated retail area", "unit": "ha" },
				{"name": "sector_area_industrial", 	"description": "Aggregated industrial area", "unit": "ha" },
				{"name": "sector_area_agricultural", 	"description": "Aggregated agricultural area", "unit": "ha" },
				{"name": "sector_area_sum", 		"description": "Aggregated sector area", "unit": "ha" },
				{"name": "sector_share_residential", 	"description": "Percentage of residential area per load area", "unit":"" },
				{"name": "sector_share_retail", 	"description": "Percentage of retail area per load area", "unit": ""},
				{"name": "sector_share_industrial", 	"description": "Percentage of industrial area per load area", "unit": ""},
				{"name": "sector_share_agricultural", 	"description": "Percentage of agricultural area per load area", "unit": "" },
				{"name": "sector_share_sum", 		"description": "Percentage of sector area per load area", "unit": "" },
				{"name": "sector_count_residential", 	"description": "Number of residential areas per load area", "unit": "" },
				{"name": "sector_count_retail", 	"description": "Number of retail areas per load area", "unit": "" },
				{"name": "sector_count_industrial", 	"description": "Number of industrial areas per load area", "unit": "" },
				{"name": "sector_count_agricultural", 	"description": "Number of agricultural areas per load area", "unit": "" },
				{"name": "sector_count_sum", 		"description": "Number of sector areas per load area", "unit": "" },
				{"name": "sector_consumption_residential", 	"description": "Electricity consumption of residential sector", "unit": "GWh" },
				{"name": "sector_consumption_retail", 		"description": "Electricity consumption of retail sector", "unit": "GWh" },
				{"name": "sector_consumption_industrial", 	"description": "Electricity consumption of industrial sector", "unit": "GWh" },
				{"name": "sector_consumption_agricultural", 	"description": "Electricity consumption of agricultural sector", "unit": "GWh" },
				{"name": "sector_consumption_sum", 		"description": "Electricity consumption of ALL sectorS", "unit": "GWh" },
				{"name": "geom_centroid", 	"description": "Centroid (can be outside the polygon)", "unit": "" },
				{"name": "geom_surfacepoint", 	"description": "Point on surface", "unit": "" },
				{"name": "geom_centre", 	"description": "Centroid and point on surface when centroid outside the polygon", "unit": "" },
				{"name": "geom", 		"description": "Geometry", "unit": "" } ]},
		"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('demand.ego_dp_loadarea' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','result','demand','ego_dp_loadarea','ego_dp_structure_versioning.sql','load area');


-- OVERVIEW
DROP TABLE IF EXISTS	model_draft.ego_scenario_overview CASCADE;
CREATE TABLE 		model_draft.ego_scenario_overview (
	id	serial,
	name	text,
	version	text,
	cnt	integer,
	CONSTRAINT ego_scenario_overview_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_scenario_overview OWNER TO oeuser;
