/* 
Create different lattices for Germany with 500m / 50m / (34m)
*/

-- Create a lattice on the bbox of Germany with 500m
DROP TABLE IF EXISTS 	model_draft.eGo_deu_lattice_500m;
CREATE TABLE 			model_draft.eGo_deu_lattice_500m AS
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
ALTER TABLE model_draft.eGo_deu_lattice_500m ADD "gid" SERIAL;
ALTER TABLE model_draft.eGo_deu_lattice_500m ADD CONSTRAINT eGo_deu_lattice_500m_pkey PRIMARY KEY(gid);

-- Add GIST Index
CREATE INDEX eGo_deu_lattice_500m_geom_idx
  ON model_draft.eGo_deu_lattice_500m
  USING gist (geom);

-- Grant oeuser
ALTER TABLE			model_draft.eGo_deu_lattice_500m OWNER TO oeuser;

-- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.1' AS version,
	'model_draft' AS schema_name,
	'eGo_deu_lattice_500m' AS table_name,
	'setup_eGo_create_lattice.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.eGo_deu_lattice_500m;


-- Create a lattice on the bbox of load area with 50m
DROP TABLE IF EXISTS model_draft.eGo_la_lattice_50m;
CREATE TABLE model_draft.eGo_la_lattice_50m AS
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
ALTER TABLE model_draft.eGo_la_lattice_50m ADD "gid" SERIAL;
ALTER TABLE model_draft.eGo_la_lattice_50m ADD CONSTRAINT eGo_la_lattice_50m_pkey PRIMARY KEY(gid);

-- Add GIST Index
CREATE INDEX eGo_la_lattice_50m_geom_idx
  ON model_draft.eGo_la_lattice_50m
  USING gist (geom);

-- Grant oeuser   
ALTER TABLE		model_draft.eGo_la_lattice_50m OWNER TO oeuser;

-- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.1' AS version,
	'model_draft' AS schema_name,
	'eGo_la_lattice_50m' AS table_name,
	'setup_eGo_create_lattice.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.eGo_la_lattice_50m;


-- Create a lattice on the bbox of load area with 50m
DROP TABLE IF EXISTS model_draft.eGo_la_lattice_34m;
CREATE TABLE model_draft.eGo_la_lattice_34m AS
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
ALTER TABLE model_draft.eGo_la_lattice_34m ADD "gid" SERIAL;
ALTER TABLE model_draft.eGo_la_lattice_34m ADD CONSTRAINT eGo_la_lattice_34m_pkey PRIMARY KEY(gid);

-- Add GIST Index
CREATE INDEX eGo_la_lattice_34m_geom_idx
  ON model_draft.eGo_la_lattice_34m
  USING gist (geom);

-- Grant oeuser   
ALTER TABLE		model_draft.eGo_la_lattice_34m OWNER TO oeuser;

-- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.1' AS version,
	'model_draft' AS schema_name,
	'eGo_la_lattice_34m' AS table_name,
	'setup_eGo_create_lattice.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.eGo_la_lattice_34m;
