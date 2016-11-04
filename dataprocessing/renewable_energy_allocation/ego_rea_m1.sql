/* 
Skript to allocate decentralized renewable power plants (dea)
Methods base on technology and voltage level
Uses different lattice from setup_ego_wpa_per_grid_district.sql
*/


/* 1. M1-1
Move "biomass" & (renewable) "gas" to OSM agricultural areas.
The rest could not be allocated, consider in M4.
*/ 

-- MView M1-1
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m1_1_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m1_1_a_mview AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM 	model_draft.ego_dea_allocation AS dea
	WHERE 	(dea.generation_type = 'biomass' OR dea.generation_type = 'gas') AND
		(dea.voltage_level = '04 (HS/MS)' OR dea.voltage_level = '05 (MS)' OR
		dea.voltage_level = '06 (MS/NS)' OR dea.voltage_level = '07 (NS)'
		OR dea.voltage_level IS NULL );

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m1_1_a_mview_geom_idx
	ON model_draft.ego_dea_allocation_m1_1_a_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m1_1_a_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_m1_1_a_mview OWNER TO oeuser;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m1_1_a_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m1_1_a_mview;

-- flag M1-1
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = 'M1-1_rest'
	WHERE	(dea.generation_type = 'biomass' OR dea.generation_type = 'gas') AND
		(dea.voltage_level = '04 (HS/MS)' OR dea.voltage_level = '05 (MS)' OR
		dea.voltage_level = '06 (MS/NS)' OR dea.voltage_level = '07 (NS)'
		OR dea.voltage_level IS NULL );

-- create temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_m1_1_dea_temp CASCADE;
CREATE TABLE 		model_draft.ego_m1_1_dea_temp (
	sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	flag character varying,
	CONSTRAINT ego_m1_1_dea_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m1_1_dea_temp_geom_idx
	ON model_draft.ego_m1_1_dea_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.ego_m1_1_osm_temp CASCADE;
CREATE TABLE 		model_draft.ego_m1_1_osm_temp (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_m1_1_osm_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m1_1_osm_temp_geom_idx
	ON model_draft.ego_m1_1_osm_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.ego_m1_1_jnt_temp CASCADE;
CREATE TABLE 		model_draft.ego_m1_1_jnt_temp (
	sorted bigint NOT NULL,
	id bigint,
	geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_m1_1_jnt_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m1_1_jnt_temp_geom_idx
	ON model_draft.ego_m1_1_jnt_temp USING gist (geom);

-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3609	-- subst_id
	LOOP
        EXECUTE '
		INSERT INTO model_draft.ego_m1_1_dea_temp
			SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as sorted,
					dea.*
			FROM 	model_draft.ego_dea_allocation_m1_1_a_mview AS dea
			WHERE 	dea.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_m1_1_osm_temp
			SELECT 	row_number() over (ORDER BY osm.area_ha DESC)as sorted,
					osm.*
			FROM 	model_draft.ego_dea_agricultural_sector_per_grid_district AS osm
			WHERE 	osm.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_m1_1_jnt_temp
			SELECT	dea.sorted,
					dea.id,
					ST_MAKELINE(dea.geom,ST_CENTROID(osm.geom)) ::geometry(LineString,3035) AS geom_line,
					ST_CENTROID(osm.geom) ::geometry(Point,3035) AS geom	-- NEW LOCATION!
			FROM	model_draft.ego_m1_1_dea_temp AS dea
			INNER JOIN model_draft.ego_m1_1_osm_temp AS osm ON (dea.sorted = osm.sorted);

		UPDATE 	model_draft.ego_dea_allocation AS t1
			SET  	geom_new = t2.geom_new,
					geom_line = t2.geom_line,
					flag = ''M1-1''
			FROM	(SELECT	m.id AS id,
					m.geom_line,
					m.geom AS geom_new
					FROM	model_draft.ego_m1_1_jnt_temp AS m
					)AS t2
			WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.ego_m1_1_dea_temp, model_draft.ego_m1_1_osm_temp, model_draft.ego_m1_1_jnt_temp;
		';
	END LOOP;
END;
$$;

-- M1-1 result
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m1_1_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m1_1_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	flag = 'M1-1';

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m1_1_mview_geom_idx
	ON model_draft.ego_dea_allocation_m1_1_mview USING gist (geom);

-- create index GIST (geom_line)
CREATE INDEX ego_dea_allocation_m1_1_mview_geom_line_idx
	ON model_draft.ego_dea_allocation_m1_1_mview USING gist (geom_line);

-- create index GIST (geom_new)
CREATE INDEX ego_dea_allocation_m1_1_mview_geom_new_idx
	ON model_draft.ego_dea_allocation_m1_1_mview USING gist (geom_new);	

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m1_1_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_m1_1_mview OWNER TO oeuser;

-- M1-1 rest
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m1_1_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m1_1_rest_mview AS
	SELECT 	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.flag = 'M1-1_rest';

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m1_1_rest_mview_geom_idx
	ON model_draft.ego_dea_allocation_m1_1_rest_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m1_1_rest_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_m1_1_rest_mview OWNER TO oeuser;

-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_m1_1_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_m1_1_osm_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_m1_1_jnt_temp CASCADE;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m1_1_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m1_1_mview;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m1_1_rest_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m1_1_rest_mview;


/* 2. M1-2
Move "solar roof mounted" with "04 (HS/MS)" to OSM agricultural areas.
The rest could not be allocated, consider in M4.
*/

-- MView M1-2
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m1_2_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m1_2_a_mview AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM 	model_draft.ego_dea_allocation AS dea
	WHERE 	(dea.voltage_level = '04 (HS/MS)' OR dea.voltage_level = '05 (MS)') AND
		(dea.generation_subtype = 'solar_roof_mounted');

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m1_2_a_mview_geom_idx
	ON model_draft.ego_dea_allocation_m1_2_a_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m1_2_a_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_m1_2_a_mview OWNER TO oeuser;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m1_2_a_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m1_2_a_mview;

-- flag M1-2
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = 'M1-2_rest'
	WHERE	(dea.voltage_level = '04 (HS/MS)' OR dea.voltage_level = '05 (MS)') AND
		(dea.generation_subtype = 'solar_roof_mounted');

-- create temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_m1_2_dea_temp CASCADE;
CREATE TABLE 		model_draft.ego_m1_2_dea_temp (
	sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	flag character varying,
	CONSTRAINT ego_m1_2_dea_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m1_2_dea_temp_geom_idx
	ON model_draft.ego_m1_2_dea_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.ego_m1_2_osm_temp ;
CREATE TABLE 		model_draft.ego_m1_2_osm_temp (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_m1_2_osm_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m1_2_osm_temp_geom_idx
	ON model_draft.ego_m1_2_osm_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.ego_m1_2_jnt_temp CASCADE;
CREATE TABLE 		model_draft.ego_m1_2_jnt_temp (
	sorted bigint NOT NULL,
	id bigint,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	old_geom geometry(Point,3035),
	geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_m1_2_jnt_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m1_2_jnt_temp_geom_idx
	ON model_draft.ego_m1_2_jnt_temp USING gist (geom);

-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3609	-- subst_id
	LOOP
        EXECUTE '
		INSERT INTO model_draft.ego_m1_2_dea_temp
			SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as sorted,
				dea.*
			FROM 	model_draft.ego_dea_allocation_m1_2_a_mview AS dea
			WHERE 	dea.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_m1_2_osm_temp
			SELECT 	row_number() over (ORDER BY osm.area_ha DESC)as sorted,
			osm.*
			FROM 	model_draft.ego_dea_agricultural_sector_per_grid_district AS osm
			WHERE 	subst_id =' || gd || ';

		INSERT INTO model_draft.ego_m1_2_jnt_temp
			SELECT	dea.sorted,
				dea.id,
				dea.electrical_capacity,
				dea.generation_type,
				dea.generation_subtype,
				dea.voltage_level,
				dea.subst_id,
				dea.geom AS old_geom,
				ST_MAKELINE(dea.geom,ST_CENTROID(osm.geom)) ::geometry(LineString,3035) AS geom_line,
				ST_CENTROID(osm.geom) ::geometry(Point,3035) AS geom 	-- NEW LOCATION!
			FROM	model_draft.ego_m1_2_dea_temp AS dea
			INNER JOIN model_draft.ego_m1_2_osm_temp AS osm ON (dea.sorted = osm.sorted);

		UPDATE 	model_draft.ego_dea_allocation AS t1
			SET  	geom_new = t2.geom_new,
				geom_line = t2.geom_line,
				flag = ''M1-2''
			FROM	(SELECT	m.id AS id,
					m.geom_line,
					m.geom AS geom_new
				FROM	model_draft.ego_m1_2_jnt_temp AS m
				)AS t2
			WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.ego_m1_2_dea_temp, model_draft.ego_m1_2_osm_temp, model_draft.ego_m1_2_jnt_temp;
		';
	END LOOP;
END;
$$;

-- M1-2 result
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m1_2_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m1_2_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	flag = 'M1-2';

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m1_2_mview_geom_idx
	ON model_draft.ego_dea_allocation_m1_2_mview USING gist (geom);

-- create index GIST (geom_line)
CREATE INDEX ego_dea_allocation_m1_2_mview_geom_line_idx
	ON model_draft.ego_dea_allocation_m1_2_mview USING gist (geom_line);

-- create index GIST (geom_new)
CREATE INDEX ego_dea_allocation_m1_2_mview_geom_new_idx
	ON model_draft.ego_dea_allocation_m1_2_mview USING gist (geom_new);	

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m1_2_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_m1_2_mview OWNER TO oeuser;

-- M1-2 rest
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m1_2_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m1_2_rest_mview AS
	SELECT 	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.flag = 'M1-2_rest';

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m1_2_rest_mview_geom_idx
	ON model_draft.ego_dea_allocation_m1_2_rest_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m1_2_rest_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_m1_2_rest_mview OWNER TO oeuser;
	
-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_m1_2_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_m1_2_osm_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_m1_2_jnt_temp CASCADE;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m1_2_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m1_2_mview;

-- Scenario ego data processing
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m1_2_rest_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
        session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m1_2_rest_mview;
