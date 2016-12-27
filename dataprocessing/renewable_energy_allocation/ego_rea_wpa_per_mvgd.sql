/*
wind potential area per mv-griddistrict
wpa dump
wpa per mv-griddistrict

__copyright__ = "tba"
__license__ = "tba"
__author__ = "Ludee"
*/

-- wind potential area
DROP TABLE IF EXISTS  	model_draft.ego_supply_wpa CASCADE;
CREATE TABLE         	model_draft.ego_supply_wpa (
		id SERIAL NOT NULL,
		region_key character varying(12),
		geom geometry(Polygon,3035),
CONSTRAINT 	ego_supply_wpa_pkey PRIMARY KEY (id));

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'supply' AS schema_name,
	'soethe_wind_potential_area' AS table_name,
	'ego_rea_wpa_per_mvgd.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('supply.soethe_wind_potential_area' ::regclass) ::json AS metadata
FROM	supply.soethe_wind_potential_area;

-- insert wpa dump
INSERT INTO     model_draft.ego_supply_wpa (region_key,geom)
	SELECT	wpa.region_key
		(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(ST_BUFFER(ST_TRANSFORM(wpa.geom,3035),-0,01),0,01)
		)))).geom AS geom
	FROM	supply.soethe_wind_potential_area AS wpa; -- calc_ego_re.geo_pot_area

-- index gist (geom)
CREATE INDEX 	ego_supply_wpa_geom_idx
	ON 	model_draft.ego_supply_wpa USING gist (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_supply_wpa OWNER TO oeuser;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'temp' AS io,
	'model_draft' AS schema_name,
	'ego_supply_wpa' AS table_name,
	'ego_rea_wpa_per_mvgd.sql' AS script_name,
	COUNT(*)AS entries,
	'drop' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_supply_wpa' ::regclass) ::json AS metadata
FROM	model_draft.ego_supply_wpa;

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
		id SERIAL NOT NULL,
		subst_id integer,
		area_ha decimal,
		geom geometry(Polygon,3035),
CONSTRAINT 	ego_supply_wpa_per_mvgd_pkey PRIMARY KEY (id));

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'model_draft' AS schema_name,
	'ego_grid_mv_griddistrict' AS table_name,
	'ego_rea_wpa_per_mvgd.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_grid_mv_griddistrict' ::regclass) ::json AS metadata
FROM	model_draft.ego_grid_mv_griddistrict;

-- insert wpa per mv-griddistrict
INSERT INTO     model_draft.ego_supply_wpa_per_mvgd (area_ha, geom)
	SELECT	ST_AREA(cut.geom)/10000,
		cut.geom ::geometry(Polygon,3035)
	FROM	(SELECT ST_MakeValid((ST_DUMP(ST_MULTI(ST_SAFE_INTERSECTION(pot.geom,dis.geom)))).geom) AS geom
		FROM	model_draft.ego_supply_wpa AS pot,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE	pot.geom && dis.geom
		) AS cut
	WHERE	ST_IsValid(cut.geom) = 't' AND ST_GeometryType(cut.geom) = 'ST_Polygon' ;

-- substation id
UPDATE 	model_draft.ego_supply_wpa_per_mvgd AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	pot.id AS id,
		gd.subst_id AS subst_id
	FROM	model_draft.ego_supply_wpa_per_mvgd AS pot,
		model_draft.ego_grid_mv_griddistrict AS gd
	WHERE  	gd.geom && pot.geom AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(pot.geom))
	) AS t2
WHERE  	t1.id = t2.id;

-- index gist (geom)
CREATE INDEX 	ego_supply_wpa_per_mvgd_geom_idx
	ON 	model_draft.ego_supply_wpa_per_mvgd USING gist (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_supply_wpa_per_mvgd OWNER TO oeuser;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_supply_wpa_per_mvgd' AS table_name,
	'ego_rea_wpa_per_mvgd.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_supply_wpa_per_mvgd' ::regclass) ::json AS metadata
FROM	model_draft.ego_supply_wpa_per_mvgd;

-- metadata
COMMENT ON TABLE model_draft.ego_supply_wpa_per_mvgd IS '{
	"title": "eGoDP_REA - wpa per mv-griddistrict",
	"description": "potential areas for wind power plants - Wind Potential Area (wpa)",
	"language": [ "eng" ],
	"reference_date": "",
	"sources": [
		{"name": "supply.soethe_wind_potential_area","description": "","url": ""},
		{"name": "model_draft.ego_grid_mv_griddistrict","description": "","url": ""} ],
	"spatial": [
		{"extend": "Germany",
		"resolution": "50m"} ],
	"license": [
		{"id": "tba",
		"name": "tba",
		"version": "tba",
		"url": "tba",
		"instruction": "tba"} ],
	"contributors": [
		{"name": "Ludwig Hülk",	"email": "ludwig.huelk@rl-institut.de",
		"date": "01.10.2016", "comment": "create table"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "25.12.2016", "comment": "create metadata"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "25.12.2016", "comment": "update to v0.2"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "id", "description": "unique identifier", "unit": "" },
				{"name": "subst_id", "description": "hvmv-substation", "unit": "" },
				{"name": "area_ha", "description": "area in ha", "unit": "" },
				{"name": "geom", "description": "Geometry", "unit": "" }]},
		"meta_version": "1.0"}] }';

-- select description
SELECT obj_description('model_draft.ego_supply_wpa_per_mvgd' ::regclass) ::json;
