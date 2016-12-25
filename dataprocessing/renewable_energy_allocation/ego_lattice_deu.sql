/*
lattices (regular point grid) for Germany with 500m / 50m 

__copyright__ = "tba"
__license__ = "tba"
__author__ = "Ludee"
*/

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_1_sta_union_mview' AS table_name,
	'ego_lattice_deu.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_1_sta_union_mview' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_1_sta_union_mview;

-- lattice on the bbox of Germany with 500m
DROP TABLE IF EXISTS 	model_draft.ego_lattice_deu_500m CASCADE;
CREATE TABLE 			model_draft.ego_lattice_deu_500m AS
	SELECT ST_SETSRID(ST_CreateFishnet(
		ROUND((ST_ymax(box2d(box.geom)) -  ST_ymin(box2d(box.geom))) /500)::integer,
		ROUND((ST_xmax(box2d(box.geom)) -  ST_xmin(box2d(box.geom))) /500)::integer,
		500,
		500,
		ST_xmin (box2d(box.geom)),
		ST_ymin (box2d(box.geom))
										),3035)::geometry(POLYGON,3035) AS geom
	FROM political_boundary.bkg_vg250_1_sta_union_mview AS box ;

-- add ID
ALTER TABLE model_draft.ego_lattice_deu_500m ADD "gid" SERIAL;
ALTER TABLE model_draft.ego_lattice_deu_500m ADD CONSTRAINT ego_lattice_deu_500m_pkey PRIMARY KEY(gid);

-- GIST Index
CREATE INDEX ego_lattice_deu_500m_geom_idx
  ON model_draft.ego_lattice_deu_500m
  USING gist (geom);

-- Grant oeuser
ALTER TABLE			model_draft.ego_lattice_deu_500m OWNER TO oeuser;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_lattice_deu_500m' AS table_name,
	'ego_lattice_deu.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_lattice_deu_500m' ::regclass) ::json AS metadata
FROM	model_draft.ego_lattice_deu_500m;



-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'model_draft' AS schema_name,
	'ego_demand_loadarea' AS table_name,
	'ego_lattice_deu.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_demand_loadarea' ::regclass) ::json AS metadata
FROM	model_draft.ego_demand_loadarea;

-- lattice on the bbox of load area with 50m
DROP TABLE IF EXISTS model_draft.ego_lattice_la_50m CASCADE;
CREATE TABLE model_draft.ego_lattice_la_50m AS
	SELECT ST_SETSRID(ST_CREATEFISHNET(
		ROUND((ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))) /50)::integer,
		ROUND((ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))) /50)::integer,
		50,
		50,
		ST_xmin (box2d(geom)),
		ST_ymin (box2d(geom))
										),3035)::geometry(POLYGON,3035) AS geom
	FROM model_draft.ego_demand_loadarea;

-- Add ID
ALTER TABLE model_draft.ego_lattice_la_50m ADD "gid" SERIAL;
ALTER TABLE model_draft.ego_lattice_la_50m ADD CONSTRAINT ego_lattice_la_50m_pkey PRIMARY KEY(gid);

-- Add GIST Index
CREATE INDEX ego_lattice_la_50m_geom_idx
  ON model_draft.ego_lattice_la_50m
  USING gist (geom);

-- Grant oeuser   
ALTER TABLE		model_draft.ego_lattice_la_50m OWNER TO oeuser;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_lattice_la_50m' AS table_name,
	'ego_lattice_deu.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_lattice_la_50m' ::regclass) ::json AS metadata
FROM	model_draft.ego_lattice_la_50m;



-- Set comment on table
COMMENT ON TABLE model_draft.ego_lattice_deu_500m IS
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
                {"Name": "Ludwig H�lk",
                "Mail": "ludwig.huelk@rl-institut.de",
                "Date":  "01.10.2016",
                "Comment": "Created table" },
				
				{"Name": "Ludwig H�lk",
                "Mail": "ludwig.huelk@rl-institut.de",
                "Date":  "12.10.2016",
                "Comment": "Add metadata" }],
"ToDo": [""],
"Licence": ["tba"],
"Instructions for proper use": [""]
}'; 
-- Select description
SELECT obj_description('model_draft.ego_lattice_deu_500m'::regclass)::json;


-- Set comment on table
COMMENT ON TABLE model_draft.ego_lattice_la_50m IS
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
                {"Name": "Ludwig H�lk",
                "Mail": "ludwig.huelk@rl-institut.de",
                "Date":  "01.10.2016",
                "Comment": "Created table" },
				
				{"Name": "Ludwig H�lk",
                "Mail": "ludwig.huelk@rl-institut.de",
                "Date":  "12.10.2016",
                "Comment": "Add metadata" }],
"ToDo": [""],
"Licence": ["tba"],
"Instructions for proper use": [""]
}'; 
-- Select description
SELECT obj_description('model_draft.ego_lattice_la_50m'::regclass)::json;
