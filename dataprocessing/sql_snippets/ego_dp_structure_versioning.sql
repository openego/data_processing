/*
Result tables for eGoDP

WARNING: It drops the table and deletes old entries when executed!

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee, IlkaCu"
*/


-- SUBSTATIONS (EHV, HVMV, MVLV)
/* 
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
 */
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
SELECT obj_description('grid.ego_dp_ehv_substation' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_dp_ehv_substation','ego_dp_structure_versioning.sql','ehv substation');

/* 
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
 */
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
SELECT ego_scenario_log('v0.2.10','result','grid','ego_dp_hvmv_substation','ego_dp_structure_versioning.sql','hvmv substation');

/* 
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
 */
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
SELECT ego_scenario_log('v0.2.10','result','grid','ego_dp_mvlv_substation','ego_dp_structure_versioning.sql','mvlv substation');


-- GRIDDISTRICTS (EHV, HVMV, MVLV)
/* 
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
 */
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
		"copyright": "© Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"} ],
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
SELECT ego_scenario_log('v0.2.10','result','grid','ego_dp_ehv_griddistrict','ego_dp_structure_versioning.sql','ehv griddistrict');

/* 
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
 */
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
SELECT ego_scenario_log('v0.2.10','result','grid','ego_dp_mv_griddistrict','ego_dp_structure_versioning.sql','mv griddistrict');

/* 
-- LV griddistrict
DROP TABLE IF EXISTS	grid.ego_dp_lv_griddistrict CASCADE;
CREATE TABLE 		grid.ego_dp_lv_griddistrict (
	version 	text,
	id integer NOT NULL,
	mvlv_subst_id integer,
	subst_id integer,
	la_id integer,
	nn boolean,
	subst_cnt integer,
	zensus_sum integer,
	zensus_count integer,
	zensus_density double precision,
	population_density double precision,
	area_ha double precision,
	sector_area_residential double precision,
	sector_area_retail double precision,
	sector_area_industrial double precision,
	sector_area_agricultural double precision,
	sector_area_sum double precision,
	sector_share_residential double precision,
	sector_share_retail double precision,
	sector_share_industrial double precision,
	sector_share_agricultural double precision,
	sector_share_sum double precision,
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
	sector_peakload_residential double precision,
	sector_peakload_retail double precision,
	sector_peakload_industrial double precision,
	sector_peakload_agricultural double precision,
	geom geometry(MultiPolygon,3035),
	CONSTRAINT ego_dp_lv_griddistrict_pkey PRIMARY KEY (version,id));

--FK
ALTER TABLE grid.ego_dp_lv_griddistrict
	ADD CONSTRAINT ego_dp_lv_griddistrict_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_dp_lv_griddistrict OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_dp_lv_griddistrict_geom_idx
	ON grid.ego_dp_lv_griddistrict USING GIST (geom);
 */
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
SELECT ego_scenario_log('v0.2.10','result','grid','ego_dp_lv_griddistrict','ego_dp_structure_versioning.sql','lv griddistrict');


-- DEMAND
/* 
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
	sector_peakload_retail double precision,
	sector_peakload_residential double precision,
	sector_peakload_industrial double precision,
	sector_peakload_agricultural double precision,
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
 */
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
SELECT ego_scenario_log('v0.2.10','result','demand','ego_dp_loadarea','ego_dp_structure_versioning.sql','loadarea');


-- GENERATOR  (con, res)
/* 
-- conventinal powerlants
DROP TABLE IF EXISTS	supply.ego_dp_conv_powerplant;
CREATE TABLE 		supply.ego_dp_conv_powerplant (
	version 	text,
	gid integer NOT NULL,
	bnetza_id text,
	company text,
	name text,
	postcode text,
	city text,
	street text,
	state text,
	block text,
	commissioned_original text,
	commissioned double precision,
	retrofit double precision,
	shutdown double precision,
	status text,
	fuel text,
	technology text,
	type text,
	eeg text,
	chp text,
	capacity double precision,
	capacity_uba double precision,
	chp_capacity_uba double precision,
	efficiency_data double precision,
	efficiency_estimate double precision,
	network_node text,
	voltage text,
	network_operator text,
	name_uba text,
	lat double precision,
	lon double precision,
	comment text,
	geom geometry(Point,4326),
	voltage_level smallint,
	subst_id bigint,
	otg_id bigint,
	un_id bigint,
	CONSTRAINT ego_dp_conv_powerplant_pkey PRIMARY KEY (version,gid) );
  
--FK
ALTER TABLE supply.ego_dp_conv_powerplant
	ADD CONSTRAINT ego_dp_conv_powerplant_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE supply.ego_dp_conv_powerplant OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_dp_conv_powerplant_geom_idx
	ON supply.ego_dp_conv_powerplant USING GIST (geom);
 */
-- metadata
COMMENT ON TABLE supply.ego_dp_conv_powerplant IS '{
	"title": "eGo dataprocessing - Conventional powerplants",
	"description": "",
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
		{"name": "Ludee", "email": " ", "date": "2017-04-13", "comment": "Create table" } ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", 	"description": "Version id", "unit": "" },
				{"name": "id", 		"description": "Unique identifier", "unit": "" }
				 ]},
		"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('supply.ego_dp_conv_powerplant' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','supply','ego_dp_conv_powerplant','ego_dp_structure_versioning.sql','conventional powerplants');

/* 
-- renewable powerlants
DROP TABLE IF EXISTS	supply.ego_dp_res_powerplant;
CREATE TABLE 		supply.ego_dp_res_powerplant (
	version 	text,
	id bigint NOT NULL,
	start_up_date timestamp without time zone,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	thermal_capacity numeric,
	city character varying,
	postcode character varying,
	address character varying,
	lon numeric,
	lat numeric,
	gps_accuracy character varying,
	validation character varying,
	notification_reason character varying,
	eeg_id character varying,
	tso double precision,
	tso_eic character varying,
	dso_id character varying,
	dso character varying,
	voltage_level_var character varying,
	network_node character varying,
	power_plant_id character varying,
	source character varying,
	comment character varying,
	geom geometry(Point,4326),
	subst_id bigint,
	otg_id bigint,
	un_id bigint,
	voltage_level smallint,
	la_id integer,
	mvlv_subst_id integer,
	rea_sort integer,
	rea_flag character varying,
	rea_geom_line geometry(LineString,3035),
	rea_geom_new geometry(Point,3035),
	CONSTRAINT ego_dp_res_powerplant_pkey PRIMARY KEY (version,id) );
  
--FK
ALTER TABLE supply.ego_dp_res_powerplant
	ADD CONSTRAINT ego_dp_res_powerplant_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE supply.ego_dp_res_powerplant OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_dp_res_powerplant_geom_idx
	ON supply.ego_dp_res_powerplant USING GIST (geom);

-- index GIST (rea_geom_new)
CREATE INDEX ego_dp_res_powerplant_rea_geom_new_idx
	ON supply.ego_dp_res_powerplant USING GIST (rea_geom_new);
 */
-- metadata
COMMENT ON TABLE supply.ego_dp_res_powerplant IS '{
	"title": "eGo dataprocessing - Renewable powerlants",
	"description": "",
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
		{"name": "Ludee", "email": " ", "date": "2017-04-13", "comment": "Create table" } ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", 	"description": "Version id", "unit": "" },
				{"name": "id", 		"description": "Unique identifier", "unit": "" }
				 ]},
		"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('supply.ego_dp_res_powerplant' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','supply','ego_dp_res_powerplant','ego_dp_structure_versioning.sql','conventional powerplants');


/* 
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

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','model_draft','ego_scenario_overview','ego_dp_structure_versioning.sql','overview');
 */

----------------------
-- POWERFLOW TABLES
----------------------

-- powerflow bus 

/*DROP TABLE IF EXISTS grid.ego_pf_hv_bus CASCADE;

CREATE TABLE grid.ego_pf_hv_bus
(
  version text, 
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  bus_id bigint NOT NULL,
  v_nom double precision,
  current_type text DEFAULT 'AC'::text, 
  v_mag_pu_min double precision DEFAULT 0, 
  v_mag_pu_max double precision, 
  geom geometry(Point,4326),
  CONSTRAINT bus_pkey PRIMARY KEY (bus_id, scn_name, version)
); 

--FK
ALTER TABLE grid.ego_pf_hv_bus
	ADD CONSTRAINT ego_pf_hv_bus_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_bus OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_pf_hv_bus_geom_idx
	ON grid.ego_pf_hv_bus USING GIST (geom);

*/
-- metadata
COMMENT ON TABLE grid.ego_pf_hv_bus IS '{
	"title": "eGo hv powerflow - bus",
	"description": "Buses relevant for eGo hv powerflow",
	"language": [ "eng" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"} ],
	"spatial": [
		{"extend": "Germany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"} ],
	"contributors": [
		{"name": "IlkaCu", "email": "", "date": "26.04.2017", "comment": "Create table"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "scn_name", "description": "name of corresponding scenario", "unit": "" },
				{"name": "bus_id", "description": "unique id for bus, equivalent to id from osmtgmod", "unit": "" },
				{"name": "v_nom", "description": "nominal voltage","unit": "kV" },
                   		{"name": "current_type", "description": "current type - AC or DC","unit": "" },
                   		{"name": "v_mag_pu_min", "description": "Minimum desired voltage, per unit of v_nom","unit": "per unit" },
                   		{"name": "v_mag_pu_max", "description": "Maximum desired voltage, per unit of v_nom","unit": "per unit" },
                   		{"name": "geom", "description": "geometry of bus","unit": "..." } ]},
	"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_pf_hv_bus' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_bus','ego_dp_structure_versioning.sql','hv pf buses');

-- powerflow generator 
/*
DROP TABLE IF EXISTS grid.ego_pf_hv_generator CASCADE;

CREATE TABLE grid.ego_pf_hv_generator
(
  version text, 
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  generator_id bigint NOT NULL, 
  bus bigint, 
  dispatch text DEFAULT 'flexible'::text, 
  control text DEFAULT 'PQ'::text, 
  p_nom double precision DEFAULT 0, 
  p_nom_extendable boolean DEFAULT false, 
  p_nom_min double precision DEFAULT 0, 
  p_nom_max double precision, 
  p_min_pu_fixed double precision DEFAULT 0, 
  p_max_pu_fixed double precision DEFAULT 1, 
  sign double precision DEFAULT 1, 
  source bigint, 
  marginal_cost double precision, 
  capital_cost double precision, 
  efficiency double precision, 
  CONSTRAINT generator_pkey PRIMARY KEY (generator_id, scn_name, version)
); 

--FK
ALTER TABLE grid.ego_pf_hv_generator
	ADD CONSTRAINT ego_pf_hv_generator_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_generator OWNER TO oeuser;

*/

-- metadata
COMMENT ON TABLE grid.ego_pf_hv_generator IS '{
	"title": "eGo hv powerflow - generator",
	"description": "Generators relevant for eGo hv powerflow",
	"language": [ "eng" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"}, 
		{"name": "Open Power System Data (OPSD)", "description": " ", "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/", "license": "MIT Licence", "copyright": "© 2016 Open Power System Data"},
		{"name": "EnergyMap", "description": " ", "url": "www.energymap.info", "license": "", "copyright": ""},
		{"name": "Bundesnetzagentur (BNetzA)", "description": " ", "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html", "license": "", "copyright": ""} ],
	"spatial": [

		{"extend": "Germany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"} ],
	"contributors": [
		{"name": "IlkaCu", "email": "", "date": "26.04.2017", "comment": "Create table"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "scn_name", "description": "name of corresponding scenario", "unit": "" },
                  		{"name": "generator_id", "description": "ID of corresponding generator", "unit": "" },
				{"name": "bus", "description": "id of associated bus", "unit": "" },
                   		{"name": "dispatch", "description": "Controllability of active power dispatch, must be flexible or variable.", "unit": "" },
                   		{"name": "control","description": "P,Q,V control strategy, must be PQ, PV or Slack.", "unit": "" },
                   		{"name": "p_nom", "description": "Nominal power", "unit": "MW" },
                   		{"name": "p_nom_extendable", "description": "Switch to allow capacity p_nom to be extended", "unit": "" },
                   		{"name": "p_nom_min", "description": "If p_nom is extendable, set its minimum value", "unit": "" },
                   		{"name": "p_nom_max", "description": "If p_nom is extendable, set its maximum value (e.g. limited by potential)", "unit": "" },
                   		{"name": "p_min_pu_fixed", "description": "If control=flexible this gives the minimum output per unit of p_nom", "unit": "per unit" },
                   		{"name": "p_max_pu_fixed", "description": "If control=flexible this gives the maximum output per unit of p_nom, equivalent to a de-rating factor.", "unit": "per unit" },
                   		{"name": "sign", "description": "power sign", "unit": "" },
                   		{"name": "source", "description": "prime mover energy carrier", "unit": "" },
                   		{"name": "marginal_cost", "description": "Marginal cost of production of 1 MWh", "unit": "EUR/MWh" },
                   		{"name": "capital_cost", "description": "Capital cost of extending p_nom by 1 MW", "unit": "EUR/MW" },
                   		{"name": "efficiency", "description": "Ratio between primary energy and electrical energy", "unit": "per unit" } ]},
	"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_pf_hv_generator' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_generator','ego_dp_structure_versioning.sql','hv pf generators');


-- powerflow generator_pq_set 
/*
DROP TABLE IF EXISTS grid.ego_pf_hv_generator_pq_set CASCADE;

CREATE TABLE grid.ego_pf_hv_generator_pq_set
(
  version text, 
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  generator_id character varying(25) NOT NULL,
  temp_id integer NOT NULL,
  p_set double precision[],
  q_set double precision[],
  p_min_pu double precision[],
  p_max_pu double precision[],
  CONSTRAINT generator_pq_set_pkey PRIMARY KEY (generator_id, temp_id, scn_name, version)
); 

--FK
ALTER TABLE grid.ego_pf_hv_generator_pq_set
	ADD CONSTRAINT ego_pf_hv_generator_pq_set_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_generator_pq_set OWNER TO oeuser;
*/
-- metadata
COMMENT ON TABLE grid.ego_pf_hv_generator_pq_set IS '{
	"title": "eGo hv powerflow - generator time series",
	"description": "Time series of generators relevant for eGo hv powerflow",
	"language": [ "eng" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Europa-Universitaet Flensburg, Center for Sustainable Energy Systems"},
		{"name": "oemof feedinlib", "description": " ", "url": "https://github.com/oemof/feedinlib", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© oemof developing group"}		 ],
	"spatial": [

		{"extend": "Germany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Europa-Universitaet Flensburg, Center for Sustainable Energy Systems"} ],
	"contributors": [
		{"name": "IlkaCu", "email": "", "date": "26.04.2017", "comment": "Create table"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "scn_name", "description": "name of corresponding scenario", "unit": "" },
                  		{"name": "generator_id", "description": "ID of corresponding generator", "unit": "" },
                   		{"name": "temp_id", "description": "ID of temporal resolution", "unit": "" },     
                   		{"name": "p_set", "description": "active power set point (for PF)", "unit": "MW" },     
                   		{"name": "q_set", "description": "reactive power set point (for PF)", "unit": "MVar" },     
                   		{"name": "p_min_pu", "description": "If control=variable this gives the minimum output for each snapshot per unit of p_nom for the OPF", "unit": "per unit" },     
                   		{"name": "p_max_pu", "description": "If control=variable this gives the maximum output for each snapshot per unit of p_nom for the OPF", "unit": "per unit" } ]},
	"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_pf_hv_generator_pq_set' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_generator_pq_set','ego_dp_structure_versioning.sql','hv pf generator time series');


-- powerflow line 
/*
DROP TABLE IF EXISTS grid.ego_pf_hv_line CASCADE;

CREATE TABLE grid.ego_pf_hv_line
(
  version text, 
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  line_id bigint NOT NULL, 
  bus0 bigint, 
  bus1 bigint, 
  x numeric DEFAULT 0, 
  r numeric DEFAULT 0, 
  g numeric DEFAULT 0,
  b numeric DEFAULT 0, 
  s_nom numeric DEFAULT 0, 
  s_nom_extendable boolean DEFAULT false, 
  s_nom_min double precision DEFAULT 0, 
  s_nom_max double precision, 
  capital_cost double precision, 
  length double precision, 
  cables integer,
  frequency numeric,
  terrain_factor double precision DEFAULT 1, 
  geom geometry(MultiLineString,4326),
  topo geometry(LineString,4326),
  CONSTRAINT line_pkey PRIMARY KEY (line_id, scn_name, version)
); 

--FK
ALTER TABLE grid.ego_pf_hv_line
	ADD CONSTRAINT ego_pf_hv_line_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_line OWNER TO oeuser;
*/
-- metadata
COMMENT ON TABLE grid.ego_pf_hv_line IS '{
	"title": "eGo hv powerflow - lines",
	"description": "lines in eGo hv powerflow",
	"language": [ "eng" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"}, 
		{"name": "osmTGmod", "description": " ", "url": "https://github.com/openego/osmTGmod", "license": "Apache License 2.0", "copyright": "© Wuppertal Institut"}		 ],
	"spatial": [

		{"extend": "Germany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© NEXT ENERGY"} ],
	"contributors": [
		{"name": "IlkaCu", "email": "", "date": "26.04.2017", "comment": "Create table"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "scn_name", "description": "name of corresponding scenario", "unit": "" },
                  		{"name": "line_id", "description": "ID of line", "unit": "" },
                   		{"name": "bus0", "description": "name of first bus to which branch is attached", "unit": "" },
                   		{"name": "bus1", "description": "name of second bus to which branch is attached", "unit": "" },
                   		{"name": "x", "description": "Series reactance", "unit": "Ohm" },
                   		{"name": "r", "description": "Series resistance", "unit": "Ohm" },
                   		{"name": "g", "description": "Shunt conductivity", "unit": "Siemens" }, 
                   		{"name": "b", "description": "Shunt susceptance", "unit": "Siemens" }, 
                   		{"name": "s_nom", "description": "Limit of apparent power which can pass through branch", "unit": "MVA" }, 
                   		{"name": "s_nom_extendable", "description": "Switch to allow capacity s_nom to be extended", "unit": "" }, 
                   		{"name": "s_nom_min", "description": "If s_nom is extendable, set its minimum value", "unit": "MVA" }, 
                   		{"name": "s_nom_max", "description": "If s_nom is extendable in OPF, set its maximum value", "unit": "MVA" }, 
                   		{"name": "capital_cost", "description": "capital cost of extending s_nom by 1 MVA", "unit": "EUR/MVA" }, 
                   		{"name": "length", "description": "length of line", "unit": "km" }, 
                   		{"name": "cables", "description": "...", "unit": "" }, 
                   		{"name": "frequency", "description": "frequency of line", "unit": "" }, 
                   		{"name": "terrain_factor", "description": "...", "unit": "" }, 
                   		{"name": "geom", "description": "geometry that depict the real route of the line", "unit": "" }, 
                   		{"name": "topo", "description": "topology that depicts a direct connection between both busses", "unit": "..." } ]},
	"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_pf_hv_line' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_line','ego_dp_structure_versioning.sql','hv pf lines');

-- powerflow load 
/*
DROP TABLE IF EXISTS grid.ego_pf_hv_load CASCADE;

CREATE TABLE grid.ego_pf_hv_load
(
  version text, 
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  load_id bigint NOT NULL, 
  bus bigint, 
  sign double precision DEFAULT (-1), 
  e_annual double precision, 
  CONSTRAINT load_pkey PRIMARY KEY (load_id, scn_name, version)
); 

--FK
ALTER TABLE grid.ego_pf_hv_load
	ADD CONSTRAINT ego_pf_hv_load_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_load OWNER TO oeuser;
*/
-- metadata
COMMENT ON TABLE grid.ego_pf_hv_load IS '{
	"title": "eGo hv powerflow - loads",
	"description": "loads in eGo hv powerflow",
	"language": [ "eng" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"},  
		{"name": "Länderarbeitskreis Energiebilanzen", "description": " ", "url": "http://www.lak-energiebilanzen.de/seiten/energiebilanzenLaender.cfm", "license": " ", "copyright": " "},
		{"name": "Bayerisches Landesamt für Statistik und Datenverarbeitung", "description": " ", "url": "http://www.stmwi.bayern.de/fileadmin/user_upload/stmwivt/Themen/Energie_und_Rohstoffe/Dokumente_und_Cover/Energiebilanz/2014/B-03_bilanzjo_mgh_2014-03-07.pdf", "license": " ", "copyright": " "},
		{"name": "Hessisches Statistisches Landesamt", "description": " ", "url": "http://www.statistik-hessen.de/publikationen/download/277/index.html", "license": " ", "copyright": " "},
		{"name": "Statistisches Amt Mecklenburg-Vorpommern", "description": " ", "url": "https://www.destatis.de/GPStatistik/servlets/MCRFileNodeServlet/MVHeft_derivate_00000168/E453_2011_00a.pdf;jsessionid=CD300CD3A06FF85FDEA864FF4D91D880", "license": " ", "copyright": " "},
		{"name": "Niedersächsisches Ministerium für Umwelt, Energie und Klimaschutz", "description": " ", "url": "http://www.umwelt.niedersachsen.de/energie/daten/co2bilanzen/niedersaechsische-energie--und-co2-bilanzen-2009-6900.html", "license": " ", "copyright": " "},
		{"name": "Information und Technik Nordrhein-Westfalen", "description": " ", "url": "https://webshop.it.nrw.de/gratis/E449%20201100.pdf", "license": " ", "copyright": " "},
		{"name": "Statistisches Landesamt Sachsen-Anhalt", "description": " ", "url": "http://www.stala.sachsen-anhalt.de/download/stat_berichte/6E402_j_2011.pdf", "license": " ", "copyright": " "},
		{"name": "Thüringer Landesamt für Statistik", "description": " ", "url": "http://www.statistik.thueringen.de/webshop/pdf/2011/05402_2011_00.pdf", "license": " ", "copyright": " "}],
	"spatial": [

		{"extend": "Germany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"} ],
	"contributors": [
		{"name": "IlkaCu", "email": "", "date": "26.04.2017", "comment": "Create table"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "scn_name", "description": "name of corresponding scenario", "unit": "" },
                  		{"name": "load_id", "description": "unique id", "unit": "" },                   
                   		{"name": "bus", "description": "id of associated bus", "unit": "" },
                   		{"name": "sign", "description": "power sign", "unit": "" },
                   		{"name": "e_annual", "description": "annual electricity consumption", "unit": "GWh" } ]},
	"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_pf_hv_load' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_load','ego_dp_structure_versioning.sql','hv pf loads');

-- powerflow load_pq_set
/*
DROP TABLE IF EXISTS grid.ego_pf_hv_load_pq_set CASCADE;

CREATE TABLE grid.ego_pf_hv_load_pq_set
(
  version text, 
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  load_id bigint NOT NULL, 
  bus bigint, 
  sign double precision DEFAULT (-1), 
  e_annual double precision, 
  CONSTRAINT load_pq_set_pkey PRIMARY KEY (load_id, scn_name, version)
); 

--FK
ALTER TABLE grid.ego_pf_hv_load_pq_set
	ADD CONSTRAINT ego_pf_hv_load_pq_set_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_load_pq_set OWNER TO oeuser;
*/
-- metadata
COMMENT ON TABLE grid.ego_pf_hv_load_pq_set IS '{
	"title": "eGo hv powerflow - loads",
	"description": "loads in eGo hv powerflow",
	"language": [ "eng" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing/blob/master/dataprocessing/python_scripts/demand_per_mv_grid_district.py", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"}],
	"spatial": [

		{"extend": "Germany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Reiner Lemoine Institut"} ],
	"contributors": [
		{"name": "IlkaCu", "email": "", "date": "26.04.2017", "comment": "Create table"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "scn_name", "description": "name of corresponding scenario", "unit": "" },
                  		{"name": "load_id", "description": "unique id", "unit": "" },                   
                   		{"name": "temp_id", "description": "id of temporal resolution", "unit": "" },
                   		{"name": "p_set", "description": "active power set point", "unit": "MW" },
                   		{"name": "q_set","description": "reactive power set point", "unit": "MVar" } ]},
	"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_pf_hv_load_pq_set' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_load_pq_set','ego_dp_structure_versioning.sql','hv pf load time series');

-- powerflow source
/*
DROP TABLE IF EXISTS grid.ego_pf_hv_source CASCADE;

CREATE TABLE grid.ego_pf_hv_source
(
  version text, 
  source_id bigint NOT NULL,
  name text, 
  co2_emissions double precision,
  commentary text,
  CONSTRAINT source_pkey PRIMARY KEY (source_id, version)
); 

--FK
ALTER TABLE grid.ego_pf_hv_source
	ADD CONSTRAINT ego_pf_hv_source_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_source OWNER TO oeuser;
*/
-- metadata
COMMENT ON TABLE grid.ego_pf_hv_source IS '{
	"title": "eGo hv powerflow - sources",
	"description": "sources in eGo hv powerflow",
	"language": [ "eng" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"} ],
	"spatial": [

		{"extend": "Germany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"} ],
	"contributors": [
		{"name": "IlkaCu", "email": "", "date": "26.04.2017", "comment": "Create table"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "source_id", "description": "unique source id", "unit": "" },
                   		{"name": "name", "description": "source name", "unit": "" },                   
                   		{"name": "co2_emissions", "description": "technology specific CO2 emissions ", "unit": "tonnes/MWh" },
                  		{"name": "commentary", "description": "...", "unit": "" } ]},
	"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_pf_hv_source' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_source','ego_dp_structure_versioning.sql','hv pf sources');

-- powerflow storage 
/*
DROP TABLE IF EXISTS grid.ego_pf_hv_storage CASCADE;

CREATE TABLE grid.ego_pf_hv_storage
(
  version text, 
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  storage_id bigint NOT NULL, 
  bus bigint, 
  dispatch text DEFAULT 'flexible'::text, 
  control text DEFAULT 'PQ'::text, 
  p_nom double precision DEFAULT 0, 
  p_nom_extendable boolean DEFAULT false, 
  p_nom_min double precision DEFAULT 0, 
  p_nom_max double precision, 
  p_min_pu_fixed double precision DEFAULT 0, 
  p_max_pu_fixed double precision DEFAULT 1, 
  sign double precision DEFAULT 1, 
  source bigint, 
  marginal_cost double precision, 
  capital_cost double precision, 
  efficiency double precision, 
  soc_initial double precision, 
  soc_cyclic boolean DEFAULT false, 
  max_hours double precision,
  efficiency_store double precision, 
  efficiency_dispatch double precision, 
  standing_loss double precision, 
  CONSTRAINT storage_pkey PRIMARY KEY (storage_id, scn_name, version)
); 

--FK
ALTER TABLE grid.ego_pf_hv_storage
	ADD CONSTRAINT ego_pf_hv_storage_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_storage OWNER TO oeuser;


*/
-- metadata
COMMENT ON TABLE grid.ego_pf_hv_storage IS '{
	"title": "eGo hv powerflow - storage",
	"description": "Storages relevant for eGo hv powerflow",
	"language": [ "eng" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"}, 
		{"name": "Open Power System Data (OPSD)", "description": " ", "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/", "license": "MIT Licence", "copyright": "© 2016 Open Power System Data"},
		{"name": "Bundesnetzagentur (BNetzA)", "description": " ", "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html", "license": "", "copyright": ""} ],
	"spatial": [

		{"extend": "Germany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Europa-Universitaet Flensburg, Center for Sustainable Energy Systems"} ],
	"contributors": [
		{"name": "IlkaCu", "email": "", "date": "26.04.2017", "comment": "Create table"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "scn_name", "description": "name of corresponding scenario", "unit": "" },
                  		{"name": "storage_id", "description": "ID of corresponding storage", "unit": "" },
				{"name": "bus", "description": "id of associated bus", "unit": "" },
                   		{"name": "dispatch", "description": "Controllability of active power dispatch, must be flexible or variable.", "unit": "" },
                   		{"name": "control","description": "P,Q,V control strategy, must be PQ, PV or Slack.", "unit": "" },
                   		{"name": "p_nom", "description": "Nominal power", "unit": "MW" },
                   		{"name": "p_nom_extendable", "description": "Switch to allow capacity p_nom to be extended", "unit": "" },
                   		{"name": "p_nom_min", "description": "If p_nom is extendable, set its minimum value", "unit": "" },
                   		{"name": "p_nom_max", "description": "If p_nom is extendable, set its maximum value (e.g. limited by potential)", "unit": "" },
                   		{"name": "p_min_pu_fixed", "description": "If control=flexible this gives the minimum output per unit of p_nom", "unit": "per unit" },
                   		{"name": "p_max_pu_fixed", "description": "If control=flexible this gives the maximum output per unit of p_nom, equivalent to a de-rating factor.", "unit": "per unit" },
                   		{"name": "sign", "description": "power sign", "unit": "" },
                   		{"name": "source", "description": "prime mover energy carrier", "unit": "" },
                   		{"name": "marginal_cost", "description": "Marginal cost of production of 1 MWh", "unit": "EUR/MWh" },
                   		{"name": "capital_cost", "description": "Capital cost of extending p_nom by 1 MW", "unit": "EUR/MW" },
                   		{"name": "efficiency", "description": "Ratio between primary energy and electrical energy", "unit": "per unit" }, 
				{"name": "soc_initial", "description": "State of charge before the snapshots in the OPF.", "unit": "MWh" },
                   		{"name": "soc_cyclic", "description": "Switch: if True, then state_of_charge_initial is ignored and the initial state of charge is set to the final state of charge for the group of snapshots in the OPF","unit": "" },
                   		{"name": "max_hours", "description": "Maximum state of charge capacity in terms of hours at full output capacity p_nom", "unit": "hours" },
                   		{"name": "efficiency_store", "description": "Efficiency of storage on the way into the storage", "unit": "per unit" },                   
                   		{"name": "efficiency_dispatch", "description": "Efficiency of storage on the way out of the storage", "unit": "per unit" },
                   		{"name": "standing_loss", "description": "Losses per hour to state of charge", "unit": "per unit" } ]},
	"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_pf_hv_storage' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_storage','ego_dp_structure_versioning.sql','hv pf storages');

-- powerflow storage_pq_set 
/*
DROP TABLE IF EXISTS grid.ego_pf_hv_storage_pq_set CASCADE;

CREATE TABLE grid.ego_pf_hv_storage_pq_set
(
  version text, 
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  storage_id bigint NOT NULL,
  temp_id integer NOT NULL,
  p_set double precision[],
  q_set double precision[], 
  p_min_pu double precision[], 
  p_max_pu double precision[],
  soc_set double precision[],
  inflow double precision[], 
  CONSTRAINT storage_pq_set_pkey PRIMARY KEY (storage_id, temp_id, scn_name)
); 

--FK
ALTER TABLE grid.ego_pf_hv_storage_pq_set
	ADD CONSTRAINT ego_pf_hv_storage_pq_set_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_storage_pq_set OWNER TO oeuser;
*/
-- metadata
COMMENT ON TABLE grid.ego_pf_hv_storage_pq_set IS '{
	"title": "eGo hv powerflow - storage time series",
	"description": "Time series of storages relevant for eGo hv powerflow",
	"language": [ "eng" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Europa-Universitaet Flensburg, Center for Sustainable Energy Systems"},
		{"name": "oemof feedinlib", "description": " ", "url": "https://github.com/oemof/feedinlib", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© oemof developing group"}		 ],
	"spatial": [

		{"extend": "Germany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"} ],
	"contributors": [
		{"name": "IlkaCu", "email": "", "date": "26.04.2017", "comment": "Create table"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "scn_name", "description": "name of corresponding scenario", "unit": "" },
                  		{"name": "storage_id", "description": "ID of corresponding storage", "unit": "" },
                   		{"name": "temp_id", "description": "ID of temporal resolution", "unit": "" },     
                   		{"name": "p_set", "description": "active power set point (for PF)", "unit": "MW" },     
                   		{"name": "q_set", "description": "reactive power set point (for PF)", "unit": "MVar" },     
                   		{"name": "p_min_pu", "description": "If control=variable this gives the minimum output for each snapshot per unit of p_nom for the OPF", "unit": "per unit" },     
                   		{"name": "p_max_pu", "description": "If control=variable this gives the maximum output for each snapshot per unit of p_nom for the OPF", "unit": "per unit" }, 
				{"name": "soc_set", "description": "State of charge set points for snapshots in the OPF", "unit": "MWh" },
                   		{"name": "inflow", "description": "Inflow to the state of charge, e.g. due to river inflow in hydro reservoir", "unit": "MW" } ]},
	"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_pf_hv_storage_pq_set' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_storage_pq_set','ego_dp_structure_versioning.sql','hv pf storage time series');

-- powerflow temp_resolution 
/*
DROP TABLE IF EXISTS grid.ego_pf_hv_temp_resolution CASCADE;

CREATE TABLE grid.ego_pf_hv_temp_resolution
(
  version text, 
  temp_id bigint NOT NULL,
  timesteps bigint NOT NULL,
  resolution text, 
  start_time timestamp without time zone, 
  CONSTRAINT temp_resolution_pkey PRIMARY KEY (temp_id, version)
); 

--FK
ALTER TABLE grid.ego_pf_hv_temp_resolution
	ADD CONSTRAINT ego_pf_hv_temp_resolution_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_temp_resolution OWNER TO oeuser;
*/
-- metadata
COMMENT ON TABLE grid.ego_pf_hv_temp_resolution IS '{
	"title": "eGo hv powerflow - temp_resolution",
	"description": "Temporal resolution in eGo hv powerflow",
	"language": [ "eng" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"} ],
	"spatial": [

		{"extend": "",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"} ],
	"contributors": [
		{"name": "IlkaCu", "email": "", "date": "26.04.2017", "comment": "Create table"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "temp_id", "description": "unique id", "unit": "" },
                   		{"name": "timesteps", "description": "timestep", "unit": "" },
                   		{"name": "resolution", "description": "temporal resolution", "unit": "" },
                   		{"name": "start_time", "description": "start time with style: YYYY-MM-DD HH:MM:SS", "unit": "" } ]},
	"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_pf_hv_temp_resolution' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_temp_resolution','ego_dp_structure_versioning.sql','hv pf temporal resolution');

-- powerflow transformer 
/*
DROP TABLE IF EXISTS grid.ego_pf_hv_transformer CASCADE;

CREATE TABLE grid.ego_pf_hv_transformer
(
  version text, 
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  trafo_id bigint NOT NULL, 
  bus0 bigint, 
  bus1 bigint, 
  x numeric DEFAULT 0, 
  r numeric DEFAULT 0, 
  g numeric DEFAULT 0,
  b numeric DEFAULT 0, 
  s_nom double precision DEFAULT 0, 
  s_nom_extendable boolean DEFAULT false,
  s_nom_min double precision DEFAULT 0, 
  s_nom_max double precision, 
  tap_ratio double precision, 
  phase_shift double precision, 
  capital_cost double precision DEFAULT 0,
  geom geometry(MultiLineString,4326),
  topo geometry(LineString,4326),
  CONSTRAINT transformer_pkey PRIMARY KEY (trafo_id, scn_name, version)
); 

--FK
ALTER TABLE grid.ego_pf_hv_transformer
	ADD CONSTRAINT ego_pf_hv_transformer_fkey FOREIGN KEY (version) 
	REFERENCES model_draft.ego_scenario(version) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_transformer OWNER TO oeuser;
*/
-- metadata
COMMENT ON TABLE grid.ego_pf_hv_transformer IS '{
	"title": "eGo hv powerflow - transformer",
	"description": "transformer in eGo hv powerflow",
	"language": [ "eng" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"},
		{"name": "OpenStreetMap", "description": " ", "url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0", "copyright": "© OpenStreetMap contributors"}, 
		{"name": "osmTGmod", "description": " ", "url": "https://github.com/openego/osmTGmod", "license": "Apache License 2.0", "copyright": "© Wuppertal Institut"}		 ],
	"spatial": [

		{"extend": "Germany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© NEXT ENERGY"} ],
	"contributors": [
		{"name": "IlkaCu", "email": "", "date": "26.04.2017", "comment": "Create table"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "scn_name", "description": "name of corresponding scenario", "unit": "" },
                  		{"name": "trafo_id", "description": "ID of line", "unit": "" },
                   		{"name": "bus0", "description": "name of first bus to which branch is attached", "unit": "" },
                   		{"name": "bus1", "description": "name of second bus to which branch is attached", "unit": "" },
                   		{"name": "x", "description": "Series reactance", "unit": "Ohm" },
                   		{"name": "r", "description": "Series resistance", "unit": "Ohm" },
                   		{"name": "g", "description": "Shunt conductivity", "unit": "Siemens" }, 
                   		{"name": "b", "description": "Shunt susceptance", "unit": "Siemens" }, 
                   		{"name": "s_nom", "description": "Limit of apparent power which can pass through branch", "unit": "MVA" }, 
                   		{"name": "s_nom_extendable", "description": "Switch to allow capacity s_nom to be extended", "unit": "" }, 
                   		{"name": "s_nom_min", "description": "If s_nom is extendable, set its minimum value", "unit": "MVA" }, 
                   		{"name": "s_nom_max", "description": "If s_nom is extendable in OPF, set its maximum value", "unit": "MVA" }, 
				{"name": "tap_ratio", "description": "Ratio of per unit voltages at each bus", "unit": "" },
                   		{"name": "phase_shift", "description": "Voltage phase angle shift", "unit": "degrees" },
                   		{"name": "capital_cost", "description": "capital cost of extending s_nom by 1 MVA", "unit": "EUR/MVA" }, 
                   		{"name": "geom", "description": "geometry that depict the real route of the line", "unit": "" }, 
                   		{"name": "topo", "description": "topology that depicts a direct connection between both busses", "unit": "..." } ]},
	"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('grid.ego_pf_hv_transformer' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_transformer','ego_dp_structure_versioning.sql','hv pf transformer');



