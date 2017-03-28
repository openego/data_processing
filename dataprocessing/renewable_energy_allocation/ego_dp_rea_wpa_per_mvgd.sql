/*
wind potential area per mv-griddistrict
wpa dump
wpa per mv-griddistrict

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


/* 
-- wind potential area
DROP TABLE IF EXISTS  	model_draft.ego_supply_wpa CASCADE;
CREATE TABLE         	model_draft.ego_supply_wpa (
		id SERIAL NOT NULL,
		region_key character varying(12),
		geom geometry(Polygon,3035),
CONSTRAINT 	ego_supply_wpa_pkey PRIMARY KEY (id));

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','supply','soethe_wind_potential_area','ego_dp_rea_wpa_per_mvgd.sql',' ');

-- insert wpa dump
INSERT INTO     model_draft.ego_supply_wpa (geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(ST_BUFFER(ST_TRANSFORM(wpa.geom,3035),-0,01),0,01)
		)))).geom AS geom
	FROM	supply.soethe_wind_potential_area AS wpa;

-- index gist (geom)
CREATE INDEX 	ego_supply_wpa_geom_idx
	ON 	model_draft.ego_supply_wpa USING gist (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_supply_wpa OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_supply_wpa','ego_dp_rea_wpa_per_mvgd.sql',' ');
 */
/* -- validate (geom)
DROP VIEW IF EXISTS	model_draft.ego_supply_wpa_error_geom_view CASCADE;
CREATE VIEW		model_draft.ego_supply_wpa_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	model_draft.ego_supply_wpa AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- drop empty view
SELECT f_drop_view('{ego_supply_wpa_error_geom_view}', 'calc_ego_re'); */


-- wpa per mv-griddistrict
DROP TABLE IF EXISTS  	model_draft.ego_supply_wpa_per_mvgd CASCADE;
CREATE TABLE         	model_draft.ego_supply_wpa_per_mvgd (
	id 		serial,
	subst_id 	integer,
	area_ha 	double precision,
	geom 		geometry(Polygon,3035),
CONSTRAINT 	ego_supply_wpa_per_mvgd_pkey PRIMARY KEY (id));

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_grid_mv_griddistrict','ego_dp_rea_wpa_per_mvgd.sql',' ');
SELECT ego_scenario_log('v0.2.6','input','supply','soethe_wind_potential_area','ego_dp_rea_wpa_per_mvgd.sql',' ');

-- insert wpa per mv-griddistrict
WITH	wpa_dump AS (
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(ST_BUFFER(ST_TRANSFORM(geom,3035),-0,01),0,01)
		)))).geom AS geom
	FROM	supply.soethe_wind_potential_area)
INSERT INTO     model_draft.ego_supply_wpa_per_mvgd (area_ha, geom)
	SELECT	ST_AREA(c.geom)/10000,
		c.geom ::geometry(Polygon,3035)
	FROM	(SELECT ST_MakeValid((ST_DUMP(ST_MULTI(ST_SAFE_INTERSECTION(a.geom,b.geom)))).geom) AS geom
		FROM	wpa_dump AS a,
			model_draft.ego_grid_mv_griddistrict AS b
		WHERE	a.geom && b.geom
		) AS c
	WHERE	ST_IsValid(c.geom) = 't' AND ST_GeometryType(c.geom) = 'ST_Polygon' ;

-- substation id
UPDATE 	model_draft.ego_supply_wpa_per_mvgd AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	a.id AS id,
			b.subst_id AS subst_id
		FROM	model_draft.ego_supply_wpa_per_mvgd AS a,
			model_draft.ego_grid_mv_griddistrict AS b
		WHERE  	b.geom && a.geom AND
			ST_CONTAINS(b.geom,ST_PointOnSurface(a.geom))
		) AS t2
	WHERE  	t1.id = t2.id;

-- index gist (geom)
CREATE INDEX 	ego_supply_wpa_per_mvgd_geom_idx
	ON 	model_draft.ego_supply_wpa_per_mvgd USING gist (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_supply_wpa_per_mvgd OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_supply_wpa_per_mvgd IS '{
	"title": "eGo dataprocessing - WPA per MV Griddistrict",
	"description": "Potential areas for wind power plants - Wind Potential Area (wpa)",
	"language": [ "eng" ],
	"reference_date": "",
	"sources": [
		{"name": "eGo dataprocessing", "description": "v0.2.6", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": " " },
		{"name": "VerNetzen - Wind potential Area", "description": " ", "url": "http://oep.iks.cs.ovgu.de/dataedit/view/supply/vernetzen_wind_potential_area", "license": "ODbL-1.0", "copyright": "© VerNetzen"} ],
	"spatial": [
		{"extend": "Germany",
		"resolution": "50m"} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Reiner Lemoine Institut" } ],
	"contributors": [
		{"name": "Ludwig Hülk",	"email": "ludwig.huelk@rl-institut.de",
		"date": "01.10.2016", "comment": "Create table"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "25.12.2016", "comment": "Add metadata"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "25.12.2016", "comment": "Update to v0.2"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "28.03.2017", "comment": "Update to v0.2.6"}],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "id", "description": "Unique identifier", "unit": "" },
				{"name": "subst_id", "description": "HVMV substation", "unit": "" },
				{"name": "area_ha", "description": "Area", "unit": "ha" },
				{"name": "geom", "description": "Geometry", "unit": "" }]},
		"meta_version": "1.2"}] }';

-- select description
SELECT obj_description('model_draft.ego_supply_wpa_per_mvgd' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_supply_wpa_per_mvgd','ego_dp_rea_wpa_per_mvgd.sql',' ');


-- DROP TABLE IF EXISTS  	model_draft.ego_supply_wpa CASCADE;
