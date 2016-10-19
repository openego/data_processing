/* 
Skript to allocate decentralized renewable power plants (dea)
Methods base on technology and voltage level
Uses different lattice from setup_ego_wpa_per_grid_district.sql
*/


/* 6. M5
Relocate "solar" with "06 (MS/NS)" & "07 (NS)" to la_grid.
There should be no rest.
*/

-- MView M5 DEA   (OK!) -> 1.000ms =1.524.674
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m5_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m5_a_mview AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM 	model_draft.ego_dea_allocation AS dea
	WHERE 	(dea.voltage_level = '06 (MS/NS)' 
			OR dea.voltage_level = '07 (NS)'
			OR dea.voltage_level IS NULL)
		AND 	dea.generation_type = 'solar'
		OR (dea.voltage_level = '07 (NS)' AND dea.generation_type = 'wind');
		
-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m5_a_mview_geom_idx
	ON model_draft.ego_dea_allocation_m5_a_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m5_a_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_m5_a_mview OWNER TO oeuser;  

-- flag M5
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = 'M5_rest'
	WHERE 	(dea.voltage_level = '06 (MS/NS)' 
			OR dea.voltage_level = '07 (NS)'
			OR dea.voltage_level IS NULL)
		AND 	dea.generation_type = 'solar'
		OR (dea.voltage_level = '07 (NS)' AND dea.generation_type = 'wind')
		AND dea.subst_id IS NOT NULL;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m5_a_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m5_a_mview;


-- create temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_m5_dea_temp CASCADE;
CREATE TABLE 		model_draft.ego_m5_dea_temp (
	sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	flag character varying,
	CONSTRAINT ego_m5_dea_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m5_dea_temp_geom_idx
	ON model_draft.ego_m5_dea_temp USING gist (geom);
  
DROP TABLE IF EXISTS 	model_draft.ego_m5_grid_la_temp CASCADE;
CREATE TABLE 		model_draft.ego_m5_grid_la_temp (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	geom geometry(Point,3035),
	CONSTRAINT ego_m5_grid_la_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m5_grid_la_temp_geom_idx
	ON model_draft.ego_m5_grid_la_temp USING gist (geom);
  
DROP TABLE IF EXISTS 	model_draft.ego_m5_jnt_temp CASCADE;
CREATE TABLE 		model_draft.ego_m5_jnt_temp (
	sorted bigint NOT NULL,
	id bigint,
	geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_m5_jnt_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m5_jnt_temp_geom_idx
	ON model_draft.ego_m5_jnt_temp USING gist (geom);

-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3609	-- subst_id
	LOOP
        EXECUTE '
		INSERT INTO model_draft.ego_m5_dea_temp
			SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as sorted,
			dea.*
			FROM 	model_draft.ego_dea_allocation_m5_a_mview AS dea
			WHERE 	dea.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_m5_grid_la_temp
			SELECT 	row_number() over (ORDER BY RANDOM())as sorted,
			la.*
			FROM 	model_draft.ego_lattice_deu_50m_la_mview AS la	-- INPUT LATTICE
			WHERE 	la.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_m5_jnt_temp
			SELECT	dea.sorted,
				dea.id,
				ST_MAKELINE(dea.geom,la.geom) ::geometry(LineString,3035) AS geom_line,
				la.geom ::geometry(Point,3035) AS geom 		-- NEW LOCATION!
			FROM	model_draft.ego_m5_dea_temp AS dea
			INNER JOIN model_draft.ego_m5_grid_la_temp AS la ON (dea.sorted = la.sorted);

		UPDATE 	model_draft.ego_dea_allocation AS t1
			SET  	geom_new = t2.geom_new,
				geom_line = t2.geom_line,
				flag = ''M5''
			FROM	(SELECT	m.id AS id,
					m.geom_line,
					m.geom AS geom_new
				FROM	model_draft.ego_m5_jnt_temp AS m
				)AS t2
			WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.ego_m5_dea_temp, model_draft.ego_m5_grid_la_temp, model_draft.ego_m5_jnt_temp;
		';
	END LOOP;
END;
$$;

-- M5 result
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m5_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m5_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	flag = 'M5';

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m5_mview_geom_idx
	ON model_draft.ego_dea_allocation_m5_mview USING gist (geom);

-- create index GIST (geom_line)
CREATE INDEX ego_dea_allocation_m5_mview_geom_line_idx
	ON model_draft.ego_dea_allocation_m5_rest_mview USING gist (geom_line);

-- create index GIST (geom_new)
CREATE INDEX ego_dea_allocation_m5_mview_geom_new_idx
	ON model_draft.ego_dea_allocation_m5_rest_mview USING gist (geom_new);	

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m5_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_m5_mview OWNER TO oeuser;

-- M5 rest
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m5_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m5_rest_mview AS
	SELECT 	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.flag = 'M5_rest';

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m5_rest_mview_geom_idx
	ON model_draft.ego_dea_allocation_m5_rest_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m5_rest_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_m5_rest_mview OWNER TO oeuser;  

-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_m5_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_m5_grid_la_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_m5_jnt_temp CASCADE;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m5_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m5_mview;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m5_rest_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m5_rest_mview;
