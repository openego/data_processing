/* 
Create different lattices for Germany with 500m / 50m / (34m)
*/

-- Create a lattice on the bbox of Germany with 500m
DROP TABLE IF EXISTS 	model_draft.eGo_lattice_deu_500m;
CREATE TABLE 			model_draft.eGo_lattice_deu_500m AS
	SELECT ST_SETSRID(ST_CreateFishnet(
		ROUND((ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))) /500)::integer,
		ROUND((ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))) /500)::integer,
		500,
		500,
		ST_xmin (box2d(geom)),
		ST_ymin (box2d(geom))
										),3035)::geometry(POLYGON,3035) AS geom
	FROM orig_vg250.vg250_1_sta_union_mview ;

-- Add ID
ALTER TABLE model_draft.eGo_lattice_deu_500m ADD "gid" SERIAL;
ALTER TABLE model_draft.eGo_lattice_deu_500m ADD CONSTRAINT eGo_lattice_deu_500m_pkey PRIMARY KEY(gid);

-- Add GIST Index
CREATE INDEX eGo_lattice_deu_500m_geom_idx
  ON model_draft.eGo_lattice_deu_500m
  USING gist (geom);

-- Grant oeuser
ALTER TABLE			model_draft.eGo_lattice_deu_500m OWNER TO oeuser;

-- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.1' AS version,
	'model_draft' AS schema_name,
	'eGo_lattice_deu_500m' AS table_name,
	'setup_eGo_create_lattice.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.eGo_lattice_deu_500m;


-- Create a lattice on the bbox of load area with 50m
DROP TABLE IF EXISTS model_draft.eGo_lattice_la_50m;
CREATE TABLE model_draft.eGo_lattice_la_50m AS
	SELECT ST_SETSRID(ST_CREATEFISHNET(
		ROUND((ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))) /50)::integer,
		ROUND((ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))) /50)::integer,
		50,
		50,
		ST_xmin (box2d(geom)),
		ST_ymin (box2d(geom))
										),3035)::geometry(POLYGON,3035) AS geom
	FROM calc_ego_loads.ego_deu_load_area;

-- Add ID
ALTER TABLE model_draft.eGo_lattice_la_50m ADD "gid" SERIAL;
ALTER TABLE model_draft.eGo_lattice_la_50m ADD CONSTRAINT eGo_lattice_la_50m_pkey PRIMARY KEY(gid);

-- Add GIST Index
CREATE INDEX eGo_lattice_la_50m_geom_idx
  ON model_draft.eGo_lattice_la_50m
  USING gist (geom);

-- Grant oeuser   
ALTER TABLE		model_draft.eGo_lattice_la_50m OWNER TO oeuser;

-- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.1' AS version,
	'model_draft' AS schema_name,
	'eGo_lattice_la_50m' AS table_name,
	'setup_eGo_create_lattice.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.eGo_lattice_la_50m;


-- Create a lattice on the bbox of load area with 50m
DROP TABLE IF EXISTS model_draft.eGo_lattice_la_34m;
CREATE TABLE model_draft.eGo_lattice_la_34m AS
	SELECT ST_SETSRID(ST_CREATEFISHNET(
		ROUND((ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))) /34)::integer,
		ROUND((ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))) /34)::integer,
		34,
		34,
		ST_xmin (box2d(geom)),
		ST_ymin (box2d(geom))
										),3035)::geometry(POLYGON,3035) AS geom
	FROM calc_ego_loads.ego_deu_load_area;

-- Add ID
ALTER TABLE model_draft.eGo_lattice_la_34m ADD "gid" SERIAL;
ALTER TABLE model_draft.eGo_lattice_la_34m ADD CONSTRAINT eGo_lattice_la_34m_pkey PRIMARY KEY(gid);

-- Add GIST Index
CREATE INDEX eGo_lattice_la_34m_geom_idx
  ON model_draft.eGo_lattice_la_34m
  USING gist (geom);

-- Grant oeuser   
ALTER TABLE		model_draft.eGo_lattice_la_34m OWNER TO oeuser;

-- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.1' AS version,
	'model_draft' AS schema_name,
	'eGo_lattice_la_34m' AS table_name,
	'setup_eGo_create_lattice.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.eGo_lattice_la_34m;



-- Set comment on table
COMMENT ON TABLE model_draft.eGo_lattice_deu_500m IS
'{
"Name": "eGo data processing - lattice on Germany with 500m",
"Source": [{
                  "Name": "open_eGo",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "2016-10-12",
"Original file": "setup_eGo_create_lattice.sql",
"Spatial resolution": ["Germany"],
"Description": ["eGo data processing - regular grid with 500m on Germany"],
"Column": [
                {"Name": "id",
                "Description": "Unique identifier",
                "Unit": "" },
			
				{"Name": "subst_id",
                "Description": "Substation ID",
                "Unit": "" },
				
				{"Name": "area_type",
                "Description": "Classify lattice points (wpa, la)",
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
                "Comment": "Add metadata" }],
"ToDo": [""],
"Licence": ["tba"],
"Instructions for proper use": [""]
}'; 
-- Select description
SELECT obj_description('model_draft.eGo_lattice_deu_500m'::regclass)::json;


-- Set comment on table
COMMENT ON TABLE model_draft.eGo_lattice_la_50m IS
'{
"Name": "eGo data processing - lattice on load area with 50m",
"Source": [{
                  "Name": "open_eGo",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "2016-10-01",
"Original file": "setup_eGo_create_lattice.sql",
"Spatial resolution": ["Germany"],
"Description": ["eGo data processing - regular grid with 50m on load areas"],

"Column": [
                {"Name": "id",
                "Description": "Unique identifier",
                "Unit": "" },
			
				{"Name": "subst_id",
                "Description": "Substation ID",
                "Unit": "" },
				
				{"Name": "area_type",
                "Description": "Classify lattice points (wpa, la)",
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
                "Comment": "Add metadata" }],
"ToDo": [""],
"Licence": ["tba"],
"Instructions for proper use": [""]
}'; 
-- Select description
SELECT obj_description('model_draft.eGo_lattice_la_50m'::regclass)::json;


-- Set comment on table
COMMENT ON TABLE model_draft.eGo_wpa_per_grid_district IS
'{
"Name": "eGo data processing - lattice on load area with 34m",
"Source": [{
                  "Name": "open_eGo",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "2016-10-01",
"Original file": "setup_eGo_create_lattice.sql",
"Spatial resolution": ["Germany"],
"Description": ["eGo data processing wind - regular grid with 34m on Germany"],

"Column": [
                {"Name": "id",
                "Description": "Unique identifier",
                "Unit": "" },
			
				{"Name": "subst_id",
                "Description": "Substation ID",
                "Unit": "" },
				
				{"Name": "area_type",
                "Description": "Classify lattice points (wpa, la)",
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
                "Comment": "Add metadata" }],
"ToDo": [""],
"Licence": ["tba"],
"Instructions for proper use": [""]
}'; 
-- Select description
SELECT obj_description('model_draft.eGo_wpa_per_grid_district'::regclass)::json;