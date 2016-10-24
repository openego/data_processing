/* 
Skript to process potential areas for wind power plants - Wind Potential Area (wpa)
Starting from geo_pot_area
*/ 

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	model_draft.eGo_wpa CASCADE;
CREATE TABLE         	model_draft.eGo_wpa (
		id SERIAL NOT NULL,
		--region_key character varying(12) NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	eGo_wpa_pkey PRIMARY KEY (id));

-- "Insert pots"   (OK!) 493.000ms =208.706
INSERT INTO     model_draft.eGo_wpa (geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
				ST_BUFFER(ST_BUFFER(ST_TRANSFORM(pot.geom,3035),-0,01),0,01)
		)))).geom AS geom
	FROM	calc_ego_re.geo_pot_area AS pot;

CREATE INDEX eGo_wpa_idx
  ON model_draft.eGo_wpa
  USING gist (geom);

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'eGo_wpa' AS table_name,
		'setup_eGo_wpa_per_grid_district.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.eGo_wpa;

/* -- Validate (geom)   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	model_draft.eGo_wpa_error_geom_view CASCADE;
CREATE VIEW		model_draft.eGo_wpa_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	model_draft.eGo_wpa AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- Drop empty view   (OK!) -> 100ms =1
SELECT f_drop_view('{eGo_wpa_error_geom_view}', 'calc_ego_re'); */


-- WPA per grid district   (OK!) 200ms =0
DROP TABLE IF EXISTS  	model_draft.eGo_wpa_per_grid_district CASCADE;
CREATE TABLE         	model_draft.eGo_wpa_per_grid_district (
		id SERIAL NOT NULL,
		subst_id integer,
		area_ha decimal,
		geom geometry(Polygon,3035),
CONSTRAINT 	eGo_wpa_per_grid_district_pkey PRIMARY KEY (id));

-- "Insert pots"   (OK!) 174.000ms
INSERT INTO     model_draft.eGo_wpa_per_grid_district (area_ha, geom)
	SELECT	ST_AREA(cut.geom)/10000,
		cut.geom ::geometry(Polygon,3035)
	FROM	(SELECT ST_MakeValid((ST_DUMP(ST_MULTI(ST_SAFE_INTERSECTION(pot.geom,dis.geom)))).geom) AS geom
		FROM	model_draft.eGo_wpa AS pot,
			calc_ego_grid_district.grid_district AS dis
		WHERE	pot.geom && dis.geom
		) AS cut
	WHERE	ST_IsValid(cut.geom) = 't' AND ST_GeometryType(cut.geom) = 'ST_Polygon';

-- Get substation ID   (OK!) 46.000ms =123.862
UPDATE 	model_draft.eGo_wpa_per_grid_district AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	pot.id AS id,
		gd.subst_id AS subst_id
	FROM	model_draft.eGo_wpa_per_grid_district AS pot,
		calc_ego_grid_district.grid_district AS gd
	WHERE  	gd.geom && pot.geom AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(pot.geom))
	) AS t2
WHERE  	t1.id = t2.id;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'eGo_wpa_per_grid_district' AS table_name,
		'setup_eGo_wpa_per_grid_district.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.eGo_wpa_per_grid_district;


-- Set comment on table
COMMENT ON TABLE model_draft.eGo_wpa IS
'{
"Name": "eGo data processing - wind potential area",
"Source": [{
                  "Name": "open_eGo",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "2016-10-01",
"Original file": "setup_eGo_wpa_per_grid_district.sql",
"Spatial resolution": ["Germany"],
"Description": ["eGo data processing wind potential area"],

"Column": [
                {"Name": "id",
                "Description": "Unique identifier",
                "Unit": "" },
			
		{"Name": "geom",
                "Description": "Geometry",
                "Unit": "" }],

"Changes":[
                {"Name": "Ludwig Hülk",
                "Mail": "ludwig.huelk@rl-institut.de",
                "Date":  "01.10.2016",
                "Comment": "Created table" },
				
				{"Name": "Ludwig Hülk",
                "Mail": "ludwig.huelk@rl-institut.de",
                "Date":  "12.10.2016",
                "Comment": "eGo v0.1" }],

"ToDo": [""],
"Licence": ["tba"],
"Instructions for proper use": [""]
}'; 

-- Select description
SELECT obj_description('model_draft.eGo_wpa'::regclass)::json;


-- Set comment on table
COMMENT ON TABLE model_draft.eGo_wpa_per_grid_district IS
'{
"Name": "eGo data processing - wind potential area",
"Source": [{
                  "Name": "open_eGo",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "2016-10-01",
"Original file": "setup_eGo_wpa_per_grid_district.sql",
"Spatial resolution": ["Germany"],
"Description": ["eGo data processing wind potential area per grid district"],

"Column": [
                {"Name": "id",
                "Description": "Unique identifier",
                "Unit": "" },
		
		{"Name": "area_ha",
                "Description": "Area",
                "Unit": "ha" },
		
		{"Name": "geom",
                "Description": "Geometry",
                "Unit": "" }],

"Changes":[
                {"Name": "Ludwig Hülk",
                "Mail": "ludwig.huelk@rl-institut.de",
                "Date":  "01.10.2016",
                "Comment": "Created table" }],

"ToDo": [""],
"Licence": ["tba"],
"Instructions for proper use": [""]
}'; 

-- Select description
SELECT obj_description('model_draft.eGo_wpa_per_grid_district'::regclass)::json;
