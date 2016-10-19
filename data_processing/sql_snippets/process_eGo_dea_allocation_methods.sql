/* 
Skript to allocate decentralized renewable power plants (dea)
Methods base on technology and voltage level
Uses different lattice from setup_ego_wpa_per_grid_district.sql
*/ 

-- number of grid_district -> 3609
	SELECT	COUNT(*)
	FROM	 calc_ego_grid_district.grid_district;

-- table for allocated dea
DROP TABLE IF EXISTS model_draft.ego_dea_allocation CASCADE;
CREATE TABLE model_draft.ego_dea_allocation (
	id bigint NOT NULL,
	sort integer,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	postcode character varying,
	subst_id integer,
	source character varying,
	la_id integer,
	flag character varying,
	geom geometry(Point,3035),
	geom_line geometry(LineString,3035),
	geom_new geometry(Point,3035),
CONSTRAINT ego_dea_allocation_pkey PRIMARY KEY (id));

-- insert DEA, with no geom excluded
INSERT INTO model_draft.ego_dea_allocation (id, electrical_capacity, generation_type, generation_subtype, voltage_level, postcode, source, geom)
	SELECT	id, electrical_capacity, generation_type, generation_subtype, voltage_level, postcode, source, ST_TRANSFORM(geom,3035)
	FROM	supply.ego_renewable_power_plants_germany
	WHERE	geom IS NOT NULL;

-- create index GIST (geom)
CREATE INDEX	ego_dea_allocation_geom_idx
	ON	model_draft.ego_dea_allocation USING GIST (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation TO oeuser WITH GRANT OPTION;
ALTER TABLE			model_draft.ego_dea_allocation OWNER TO oeuser;

-- update subst_id from grid_district
UPDATE 	model_draft.ego_dea_allocation AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	dea.id AS id,
			gd.subst_id AS subst_id
		FROM	model_draft.ego_dea_allocation AS dea,
			calc_ego_grid_district.grid_district AS gd
		WHERE  	gd.geom && dea.geom AND
			ST_CONTAINS(gd.geom,dea.geom)
		) AS t2
	WHERE  	t1.id = t2.id;

-- flag reset
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = NULL,
		geom_new = NULL,
		geom_line = NULL;

-- DEA outside grid_district
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = 'out',
		geom_new = NULL,
		geom_line = NULL
	WHERE	dea.subst_id IS NULL;

-- DEA outside grid_district offshore wind
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = 'offshore',
		geom_new = NULL,
		geom_line = NULL
	WHERE	dea.subst_id IS NULL AND
		dea.generation_type = 'wind';


/*
Some DEA are outside Germany because of unknown inaccuracies.
They are moved to the next substation before the allocation methods.
Offshore wind power plants are not moved.
*/ 
    
-- MView DEA outside grid_district
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_out_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_out_mview AS
	SELECT	dea.*
	FROM 	model_draft.ego_dea_allocation AS dea
	WHERE	flag = 'out' OR flag = 'offshore';

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_out_mview_geom_idx
	ON model_draft.ego_dea_allocation_out_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_out_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE			model_draft.ego_dea_allocation_out_mview OWNER TO oeuser;

-- New geom, DEA to next substation
DROP TABLE IF EXISTS	model_draft.ego_dea_allocation_out_nn CASCADE;
CREATE TABLE 		model_draft.ego_dea_allocation_out_nn AS 
	SELECT DISTINCT ON (dea.id)
		dea.id AS dea_id,
		dea.generation_type,
		sub.subst_id, 
		sub.geom ::geometry(Point,3035) AS geom_sub,
		ST_Distance(dea.geom,sub.geom) AS distance,
		dea.geom ::geometry(Point,3035) AS geom
	FROM 	model_draft.ego_dea_allocation_out_mview AS dea,
		calc_ego_substation.ego_deu_substations AS sub
	WHERE 	ST_DWithin(dea.geom,sub.geom, 100000) -- In a 100 km radius
	ORDER BY 	dea.id, ST_Distance(dea.geom,sub.geom);

ALTER TABLE	model_draft.ego_dea_allocation_out_nn
	ADD PRIMARY KEY (dea_id),
	OWNER TO oeuser;

-- new subst_id and geom_new with line
UPDATE 	model_draft.ego_dea_allocation AS t1
SET  	subst_id = t2.subst_id,
	geom_new = t2.geom_new,
	geom_line = t2.geom_line
FROM	(SELECT	nn.dea_id AS dea_id,
		nn.subst_id AS subst_id,
		nn.geom_sub AS geom_new,
		ST_MAKELINE(nn.geom,nn.geom_sub) ::geometry(LineString,3035) AS geom_line
	FROM	model_draft.ego_dea_allocation_out_nn AS nn,
		model_draft.ego_dea_allocation AS dea
	WHERE  	flag = 'out'
	)AS t2
WHERE  	t1.id = t2.dea_id;

-- drop
DROP TABLE IF EXISTS			model_draft.ego_dea_allocation_out_nn CASCADE;

-- scenario log
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_out_mview' AS table_name,
		'process_eGo_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_out_mview;


/* 
Prepare a special OSM layer with farmyards per grid districts.
In Germany a lot of farmyard builings are used for renewable energy production with solar and biomass.
*/

-- OSM agricultural per grid district
DROP TABLE IF EXISTS 	model_draft.ego_dea_agricultural_sector_per_grid_district CASCADE;
CREATE TABLE 		model_draft.ego_dea_agricultural_sector_per_grid_district (
	id serial NOT NULL,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_dea_agricultural_sector_per_grid_district_pkey PRIMARY KEY (id));

-- insert data (osm agricultural)
INSERT INTO	model_draft.ego_dea_agricultural_sector_per_grid_district (area_ha,geom)
	SELECT	ST_AREA(osm.geom)/10000, osm.geom
	FROM	calc_ego_loads.urban_sector_per_grid_district_4_agricultural AS osm;
	
-- update subst_id from grid_district
UPDATE 	model_draft.ego_dea_agricultural_sector_per_grid_district AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	osm.id AS id,
			dis.subst_id AS subst_id
		FROM	model_draft.ego_dea_agricultural_sector_per_grid_district AS osm,
			calc_ego_grid_district.grid_district AS dis
		WHERE  	dis.geom && ST_CENTROID(osm.geom) AND
			ST_CONTAINS(dis.geom,ST_CENTROID(osm.geom))
		) AS t2
	WHERE  	t1.id = t2.id;

-- create index GIST (geom)
CREATE INDEX ego_dea_agricultural_sector_per_grid_district_geom_idx
	ON model_draft.ego_dea_agricultural_sector_per_grid_district USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_agricultural_sector_per_grid_district TO oeuser WITH GRANT OPTION;
ALTER TABLE			model_draft.ego_dea_agricultural_sector_per_grid_district OWNER TO oeuser;  

-- scenario log
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_agricultural_sector_per_grid_district' AS table_name,
		'process_eGo_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_agricultural_sector_per_grid_district;


/* BNetzA MView
-- some dea are mapped good, could be excluded, but did not work to filter them!

-- Check for sources
	SELECT	dea.source
	FROM 	supply.ego_renewable_power_plants_germany AS dea
	GROUP BY dea.source

-- Flag BNetzA    (OK!) -> 1.000ms =3.585
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = 'bnetza',
		geom_new = NULL,
		geom_line = NULL
	WHERE	dea.source = 'BNetzA' OR dea.source = 'BNetzA PV';

-- MView BNetzA   (OK!) -> 1.000ms =2.992
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_bnetza_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_bnetza_mview AS
	SELECT	dea.*
	FROM 	model_draft.ego_dea_allocation AS dea
	WHERE	flag = 'bnetza';

CREATE INDEX ego_dea_allocation_bnetza_mview_geom_idx
	ON model_draft.ego_dea_allocation_bnetza_mview USING gist (geom);

-- Drops
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_bnetza_mview CASCADE;
*/ 


-- DEA METHODS

/* Statistics (old, see scenario_log)
0. DEA (HV) -> 1.598.624
1. M1-1	biomass & gas 	-> osm_urban_4 	-> 16.062 / 15.090 -> 972 Rest! 	-ok
2. M1-2	solar_roof (04) -> osm_urban_4 	-> 21.535 / 18.290 -> 3.245 Rest! 	-ok
3. M2	wind (04)	-> wpa_farm	-> 2.127 / 2.097 -> 30 Rest! 		-ok
4. M3	wind (05 & 06)	-> grid_wpa	-> 13.543
5. M4	solar_gr & Rest	-> grid_out	-> 
6. M5	solar (07)	-> grid_la	->  
*/ 


/* 1. M1-1
Move "biomass" & (renewable) "gas" to OSM agricultural areas.
*/ 

-- MView M1-1 DEA   (OK!) -> 1.000ms =16.062
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
ALTER TABLE			model_draft.ego_dea_allocation_m1_1_a_mview OWNER TO oeuser;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m1_1_a_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m1_1_a_mview;

-- flag M1-1 DEA    (OK!) -> 1.000ms =16.062
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = 'M1-1_rest'
	WHERE	(dea.generation_type = 'biomass' OR dea.generation_type = 'gas') AND
		(dea.voltage_level = '04 (HS/MS)' OR dea.voltage_level = '05 (MS)' OR
		dea.voltage_level = '06 (MS/NS)' OR dea.voltage_level = '07 (NS)'
		OR dea.voltage_level IS NULL );

-- create temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_m1_1_dea_temp CASCADE;
CREATE TABLE 			model_draft.ego_m1_1_dea_temp (
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
CREATE TABLE 			model_draft.ego_m1_1_osm_temp (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_m1_1_osm_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m1_1_osm_temp_geom_idx
	ON model_draft.ego_m1_1_osm_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.ego_m1_1_jnt_temp CASCADE;
CREATE TABLE 			model_draft.ego_m1_1_jnt_temp (
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
CREATE MATERIALIZED VIEW 			model_draft.ego_dea_allocation_m1_1_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	flag = 'M1-1';

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m1_1_mview_geom_idx
	ON model_draft.ego_dea_allocation_m1_1_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m1_1_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE			model_draft.ego_dea_allocation_m1_1_mview OWNER TO oeuser;

-- M1-1 rest
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m1_1_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 			model_draft.ego_dea_allocation_m1_1_rest_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.flag = 'M1-1_rest';

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m1_1_rest_mview_geom_idx
	ON model_draft.ego_dea_allocation_m1_1_rest_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m1_1_rest_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE			model_draft.ego_dea_allocation_m1_1_rest_mview OWNER TO oeuser;

-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_m1_1_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_m1_1_osm_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_m1_1_jnt_temp CASCADE;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
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
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m1_1_rest_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m1_1_rest_mview;


/* 2. M1-2
Move "solar roof mounted" with "04 (HS/MS)" to OSM agricultural areas
*/

-- MView M1-2 DEA
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m1_2_a_mview CASCADE;
CREATE MATERIALIZED VIEW 			model_draft.ego_dea_allocation_m1_2_a_mview AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM 	model_draft.ego_dea_allocation AS dea
	WHERE 	(dea.voltage_level = '04 (HS/MS)' OR dea.voltage_level = '05 (MS)') 
		AND (dea.generation_subtype = 'solar_roof_mounted');

CREATE INDEX ego_dea_allocation_m1_2_a_mview_geom_idx
  ON model_draft.ego_dea_allocation_m1_2_a_mview USING gist (geom);

-- Flag M1-2 DEA    (OK!) -> 1.000ms =21.536
UPDATE 	model_draft.ego_dea_allocation AS dea
SET	flag = 'M1-2_rest'
WHERE	(dea.voltage_level = '04 (HS/MS)' OR dea.voltage_level = '05 (MS)') 
		AND (dea.generation_subtype = 'solar_roof_mounted');

-- Create temp tables for the loop
DROP TABLE IF EXISTS 	model_draft.m1_2_dea_temp CASCADE;
CREATE TABLE 		model_draft.m1_2_dea_temp (
	sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	flag character varying,
	CONSTRAINT m1_2_dea_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX m1_2_dea_temp_geom_idx
  ON model_draft.m1_2_dea_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.m1_2_osm_temp ;
CREATE TABLE 		model_draft.m1_2_osm_temp (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT m1_2_osm_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX m1_2_osm_temp_geom_idx
  ON model_draft.m1_2_osm_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.m1_2_jnt_temp CASCADE;
CREATE TABLE 		model_draft.m1_2_jnt_temp (
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
  CONSTRAINT m1_2_jnt_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX m1_2_jnt_temp_geom_idx
  ON model_draft.m1_2_jnt_temp USING gist (geom);

-- Run a loop around all grid districs -> 1.000ms
DO
$$
DECLARE	gd integer;
BEGIN
    FOR gd IN 1..3609
    LOOP
        EXECUTE 'INSERT INTO model_draft.m1_2_dea_temp
		SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as sorted,
			dea.*
		FROM 	model_draft.ego_dea_allocation_m1_2_a_mview AS dea
		WHERE 	dea.subst_id =' || gd || ';

		INSERT INTO model_draft.m1_2_osm_temp
		SELECT 	row_number() over (ORDER BY osm.area_ha DESC)as sorted,
		osm.*
		FROM 	model_draft.ego_dea_agricultural_sector_per_grid_district AS osm
		WHERE 	subst_id =' || gd || ';

		INSERT INTO model_draft.m1_2_jnt_temp
		SELECT	dea.sorted,
			dea.id,
			dea.electrical_capacity,
			dea.generation_type,
			dea.generation_subtype,
			dea.voltage_level,
			dea.subst_id,
			dea.geom AS old_geom,
			ST_MAKELINE(dea.geom,ST_CENTROID(osm.geom)) ::geometry(LineString,3035) AS geom_line,
			ST_CENTROID(osm.geom) ::geometry(Point,3035) AS geom -- NEW LOCATION!
		FROM	model_draft.m1_2_dea_temp AS dea
		INNER JOIN model_draft.m1_2_osm_temp AS osm ON (dea.sorted = osm.sorted);

		UPDATE 	model_draft.ego_dea_allocation AS t1
		SET  	geom_new = t2.geom_new,
			geom_line = t2.geom_line,
			flag = ''M1-2''
		FROM	(SELECT	m.id AS id,
				m.geom_line,
				m.geom AS geom_new
			FROM	model_draft.m1_2_jnt_temp AS m
			)AS t2
		WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.m1_2_dea_temp, model_draft.m1_2_osm_temp, model_draft.m1_2_jnt_temp;
			';
    END LOOP;
END;
$$;

-- Get M1-2 List (OK!) -> 1.000ms = 18.290 
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m1_2_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m1_2_mview AS
SELECT 	dea.*
FROM	model_draft.ego_dea_allocation AS dea
WHERE	flag = 'M1-2';

CREATE INDEX ego_dea_allocation_m1_2_mview_geom_idx
	ON model_draft.ego_dea_allocation_m1_2_mview USING gist (geom);

-- Get M1-2 Rest (OK!) -> 1.000ms = 3.210
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m1_2_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m1_2_rest_mview AS
SELECT 	dea.*
FROM	model_draft.ego_dea_allocation AS dea
WHERE	dea.flag = 'M1-2_rest';

CREATE INDEX ego_dea_allocation_m1_2_rest_mview_geom_idx
	ON model_draft.ego_dea_allocation_m1_2_rest_mview USING gist (geom);

-- Drop temp
DROP TABLE IF EXISTS 	model_draft.m1_2_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.m1_2_osm_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.m1_2_jnt_temp CASCADE;

-- Scenario ego data processing
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
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
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m1_2_rest_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
        session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m1_2_rest_mview;


/* 3. M2
Relocate "wind" with "04 (HS/MS)" to WPA as wind farms
(OK!) -> .000ms =2.097
Total 2.127 -> 30 Rest!
The "rest" could not be allocated, consider in next method
*/

-- MView M2 DEA   (OK!) -> 1.000ms =2.127
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m2_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m2_a_mview AS
		SELECT	id,
			electrical_capacity,
			generation_type,
			generation_subtype,
			voltage_level,
			subst_id,
			geom,
			flag
		FROM 	model_draft.ego_dea_allocation AS dea
		WHERE 	(dea.voltage_level = '04 (HS/MS)' 
			AND dea.generation_type = 'wind');

CREATE INDEX ego_dea_allocation_m2_a_mview_geom_idx
	ON model_draft.ego_dea_allocation_m2_a_mview USING gist (geom);

-- Flag M2 DEA    (OK!) -> 1.000ms =2.127
UPDATE 	model_draft.ego_dea_allocation AS dea
SET	flag = 'M2_rest'
WHERE	dea.voltage_level = '04 (HS/MS)' 
	AND dea.generation_type = 'wind';

-- get windfarms   (OK!) -> 485.000ms =317
DROP TABLE IF EXISTS 	model_draft.ego_dea_allocation_m2_windfarm CASCADE;
CREATE TABLE 		model_draft.ego_dea_allocation_m2_windfarm (
	farm_id serial,
	subst_id integer,
	area_ha decimal,
	dea_cnt integer,
	electrical_capacity_sum numeric,
	geom_new geometry(Polygon,3035),
	geom_line geometry(LineString,3035),
	geom geometry(Polygon,3035),
	CONSTRAINT ego_dea_allocation_m2_windfarm_pkey PRIMARY KEY (farm_id));

INSERT INTO model_draft.ego_dea_allocation_m2_windfarm (area_ha,geom)
	SELECT	ST_AREA(farm.geom_farm),
		farm.geom_farm
	FROM	(SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
				ST_BUFFER(dea.geom, 1000)
			)))).geom ::geometry(Polygon,3035) AS geom_farm
		FROM 	model_draft.ego_dea_allocation AS dea
		WHERE 	(dea.voltage_level = '04 (HS/MS)') AND
			(dea.generation_type = 'wind')
		) AS farm;

CREATE INDEX ego_dea_allocation_m2_windfarm_geom_idx
	ON model_draft.ego_dea_allocation_m2_windfarm USING gist (geom);

-- Update subst_id   (OK!) -> 1.000ms =317
UPDATE 	model_draft.ego_dea_allocation_m2_windfarm AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	farm.farm_id AS farm_id,
		gd.subst_id AS subst_id
	FROM	model_draft.ego_dea_allocation_m2_windfarm AS farm,
		calc_ego_grid_district.grid_district AS gd
	WHERE  	gd.geom && ST_CENTROID(farm.geom) AND
		ST_CONTAINS(gd.geom,ST_CENTROID(farm.geom))
	) AS t2
WHERE  	t1.farm_id = t2.farm_id;

-- Update wind farm data   (OK!) -> 1.000ms =317
UPDATE 	model_draft.ego_dea_allocation_m2_windfarm AS t1
SET  	dea_cnt = t2.dea_cnt,
	electrical_capacity_sum = t2.electrical_capacity_sum
FROM    (
	SELECT	farm.farm_id AS farm_id,
		COUNT(dea.geom) AS dea_cnt,
		SUM(dea.electrical_capacity) AS electrical_capacity_sum
	FROM	model_draft.ego_dea_allocation AS dea,
		model_draft.ego_dea_allocation_m2_windfarm AS farm
	WHERE  	(dea.voltage_level = '04 (HS/MS)' AND
		dea.generation_type = 'wind') AND
		(farm.geom && dea.geom AND
		ST_CONTAINS(farm.geom,dea.geom))
	GROUP BY farm.farm_id
	) AS t2
WHERE  	t1.farm_id = t2.farm_id;

-- Update DEA in wind farms   (OK!) -> 1.000ms =2.127
UPDATE 	model_draft.ego_dea_allocation AS t1
SET  	sort = t2.farm_id   -- temporary storage of farm id in sort!
FROM    (
	SELECT	dea.id AS id,
		farm.farm_id AS farm_id
	FROM	model_draft.ego_dea_allocation AS dea,
		model_draft.ego_dea_allocation_m2_windfarm AS farm
	WHERE  	(dea.voltage_level = '04 (HS/MS)' AND
		dea.generation_type = 'wind') AND
		(farm.geom && dea.geom AND
		ST_CONTAINS(farm.geom,dea.geom))
	) AS t2
WHERE  	t1.id = t2.id;


-- Create Temp Tables for the loop   (OK!) -> 1.000ms =0
DROP TABLE IF EXISTS 	model_draft.m2_farm_temp CASCADE;
CREATE TABLE 		model_draft.m2_farm_temp (
	sorted bigint NOT NULL,
	farm_id bigint NOT NULL,
	subst_id integer,
	area_ha numeric,
	dea_cnt integer,
	electrical_capacity_sum numeric,
	geom_new geometry(Point,3035),
	geom_line geometry(LineString,3035),
	geom geometry(Polygon,3035),
	flag character varying,
	CONSTRAINT m2_farm_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX m2_farm_temp_geom_idx
	ON model_draft.m2_farm_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.m2_wpa_temp CASCADE;
CREATE TABLE 		model_draft.m2_wpa_temp (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT m2_wpa_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX m2_wpa_temp_geom_idx
	ON model_draft.m2_wpa_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.m2_jnt_temp CASCADE;
CREATE TABLE 		model_draft.m2_jnt_temp (
	sorted bigint NOT NULL,
	farm_id bigint,
	subst_id integer,
	geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT m2_jnt_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX m2_jnt_temp_geom_idx
	ON model_draft.m2_jnt_temp USING gist (geom);

-- Run a loop around all grid districs   (OK!)
DO
$$
DECLARE	gd integer;
BEGIN
    FOR gd IN 1..3609
    LOOP
        EXECUTE 'INSERT INTO model_draft.m2_farm_temp
		SELECT	row_number() over (ORDER BY farm.dea_cnt DESC)as sorted,
			farm.*
		FROM 	model_draft.ego_dea_allocation_m2_windfarm AS farm
		WHERE 	farm.subst_id =' || gd || ';

		INSERT INTO model_draft.m2_wpa_temp
		SELECT 	row_number() over (ORDER BY pot.area_ha DESC)as sorted,
			pot.*
		FROM 	model_draft.ego_wpa_per_grid_district AS pot
		WHERE 	subst_id =' || gd || ';

		INSERT INTO model_draft.m2_jnt_temp
		SELECT	farm.sorted,
			farm.farm_id,
			farm.subst_id,
			ST_MAKELINE(ST_CENTROID(farm.geom),ST_PointOnSurface(wpa.geom)) ::geometry(LineString,3035) AS geom_line,
			ST_PointOnSurface(wpa.geom) ::geometry(Point,3035) AS geom -- NEW LOCATION!
		FROM	model_draft.m2_farm_temp AS farm
		INNER JOIN model_draft.m2_wpa_temp AS wpa ON (farm.sorted = wpa.sorted);

		UPDATE 	model_draft.ego_dea_allocation AS t1
		SET  	geom_new = t2.geom_new,
			geom_line = t2.geom_line,
			flag = ''M2''
		FROM	(SELECT	m.farm_id AS farm_id,
				m.geom_line,
				m.geom AS geom_new
			FROM	model_draft.m2_jnt_temp AS m
			)AS t2
		WHERE  	t1.sort = t2.farm_id;

		TRUNCATE TABLE model_draft.m2_farm_temp, model_draft.m2_wpa_temp, model_draft.m2_jnt_temp;
			';
    END LOOP;
END;
$$;

-- Get M2 List (OK!) -> 1.000ms = 2.097
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m2_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m2_mview AS
SELECT 	dea.*
FROM	model_draft.ego_dea_allocation AS dea
WHERE	flag = 'M2';

CREATE INDEX ego_dea_allocation_m2_mview_geom_idx
	ON model_draft.ego_dea_allocation_m2_mview USING gist (geom);

-- Get M2 Rest (OK!) -> 1.000ms = 30
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m2_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m2_rest_mview AS
SELECT 	dea.*
FROM	model_draft.ego_dea_allocation AS dea
WHERE	flag = 'M2_rest';

CREATE INDEX ego_dea_allocation_m2_rest_mview_geom_idx
	ON model_draft.ego_dea_allocation_m2_rest_mview USING gist (geom);

-- Drop temp
DROP TABLE IF EXISTS 	model_draft.m2_farm_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.m2_wpa_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.m2_jnt_temp CASCADE;

-- Scenario ego data processing
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m2_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
        session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m2_mview;

-- Scenario ego data processing
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m2_rest_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
        session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m2_rest_mview;


/* 4. M3 
Relocate "wind" with "05 (MS)" & "06 (MS/NS)" to wpa_grid
(OK!) -> 2.290.000ms = 10.835
Total 13.925 -> 3.090 Rest!
The "rest" could not be allocated, consider in next method
*/ 

-- MView M3 DEA   (OK!) -> 1.000ms =13.925 / 
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m3_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m3_a_mview AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM 	model_draft.ego_dea_allocation AS dea
	WHERE 	(dea.voltage_level = '05 (MS)' 
			OR dea.voltage_level = '06 (MS/NS)') 
		AND 	dea.generation_type = 'wind'
		OR 	dea.flag = 'M2_rest'
		AND	dea.subst_id IS NOT NULL ;

CREATE INDEX ego_dea_allocation_m3_a_mview_geom_idx
  ON model_draft.ego_dea_allocation_m3_a_mview USING gist (geom);

-- Flag M3 DEA    (OK!) -> 1.000ms =13.948
UPDATE 	model_draft.ego_dea_allocation AS dea
SET	flag = 'M3_rest'
WHERE	(dea.voltage_level = '05 (MS)' 
			OR dea.voltage_level = '06 (MS/NS)') 
		AND 	dea.generation_type = 'wind'
		OR 	dea.flag = 'M2_rest'
		AND	dea.subst_id IS NOT NULL ;

-- Create Temp Tables for the loop   (OK!) -> 1.000ms =0
DROP TABLE IF EXISTS 	model_draft.m3_dea_temp CASCADE;
CREATE TABLE 		model_draft.m3_dea_temp (
	sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	flag character varying,
	CONSTRAINT m3_dea_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX m3_dea_temp_geom_idx
  ON model_draft.m3_dea_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.m3_grid_wpa_temp CASCADE;
CREATE TABLE 		model_draft.m3_grid_wpa_temp (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_type text,
	geom geometry(Point,3035),
	CONSTRAINT m3_grid_wpa_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX m3_grid_wpa_temp_geom_idx
  ON model_draft.m3_grid_wpa_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.m3_jnt_temp CASCADE;
CREATE TABLE 		model_draft.m3_jnt_temp (
  sorted bigint NOT NULL,
  id bigint,
  geom_line geometry(LineString,3035),
  geom geometry(Point,3035),
  CONSTRAINT m3_jnt_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX m3_jnt_temp_geom_idx
  ON model_draft.m3_jnt_temp USING gist (geom);


-- Run a loop around all grid districs   (OK!)
DO
$$
DECLARE	gd integer;
BEGIN
    FOR gd IN 1..3609
    LOOP
        EXECUTE 'INSERT INTO model_draft.m3_dea_temp
		SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as sorted,
			dea.*
		FROM 	model_draft.ego_dea_allocation_m3_a_mview AS dea
		WHERE 	dea.subst_id =' || gd || ';;

		INSERT INTO model_draft.m3_grid_wpa_temp
		SELECT 	row_number() over (ORDER BY RANDOM())as sorted,
			wpa.*
		FROM 	model_draft.ego_lattice_deu_500m_wpa_mview AS wpa
		WHERE 	wpa.subst_id =' || gd || ';

		INSERT INTO model_draft.m3_jnt_temp
		SELECT	dea.sorted,
			dea.id,
			ST_MAKELINE(dea.geom,wpa.geom) ::geometry(LineString,3035) AS geom_line,
			wpa.geom ::geometry(Point,3035) AS geom -- NEW LOCATION!
		FROM	model_draft.m3_dea_temp AS dea
		INNER JOIN model_draft.m3_grid_wpa_temp AS wpa ON (dea.sorted = wpa.sorted);

		UPDATE 	model_draft.ego_dea_allocation AS t1
		SET  	geom_new = t2.geom_new,
			geom_line = t2.geom_line,
			flag = ''M3''
		FROM	(SELECT	m.id AS id,
				m.geom_line,
				m.geom AS geom_new
			FROM	model_draft.m3_jnt_temp AS m
			)AS t2
		WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.m3_dea_temp, model_draft.m3_grid_wpa_temp, model_draft.m3_jnt_temp;
			';
    END LOOP;
END;
$$;

-- Get M3 List (OK!) -> 1.000ms = 10.835
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m3_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m3_mview AS
SELECT 	dea.*
FROM	model_draft.ego_dea_allocation AS dea
WHERE	flag = 'M3';

CREATE INDEX ego_dea_allocation_m3_mview_geom_idx
  ON model_draft.ego_dea_allocation_m3_mview USING gist (geom);

-- Get M3 Rest (OK!) -> 1.000ms = 3.120
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m3_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m3_rest_mview AS
SELECT 	dea.*
FROM	model_draft.ego_dea_allocation AS dea
WHERE	flag = 'M3_rest';

CREATE INDEX ego_dea_allocation_m3_rest_mview_geom_idx
  ON model_draft.ego_dea_allocation_m3_rest_mview USING gist (geom);

-- Drop temp
DROP TABLE IF EXISTS 	model_draft.m3_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.m3_grid_wpa_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.m3_jnt_temp CASCADE;

-- Scenario ego data processing
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m3_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
        session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m3_mview;

-- Scenario ego data processing
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m3_rest_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
        session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m3_rest_mview;


/* 5. M4
Relocate "wind" with "05 (MS)" & "06 (MS/NS)" to wpa_grid
(OK!) -> 1.679.000ms =
Total 13.925 -> 3.245 Rest!
"solar ground" & "wind" ohne voltage & 
Rest M1-1 & Rest M1-2 & Rest M3
The "rest" could not be allocated, consider in next method
*/ 

-- MView M4 DEA   (OK!) -> 1.000ms =13.925 / 20.147
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m4_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m4_a_mview AS
		SELECT	id,
			electrical_capacity,
			generation_type,
			generation_subtype,
			voltage_level,
			subst_id,
			geom,
			flag
		FROM 	model_draft.ego_dea_allocation AS dea
		WHERE 	(dea.voltage_level = '04 (HS/MS)' OR dea.voltage_level = '05 (MS)')
			AND 	(dea.generation_subtype = 'solar_ground_mounted' 
				OR (dea.generation_type = 'solar' AND dea.generation_subtype IS NULL))
			OR (dea.voltage_level IS NULL AND dea.generation_type = 'wind')
			OR dea.flag = 'M1-1_rest'
			OR dea.flag = 'M1-2_rest'
			OR dea.flag = 'M3_rest'
			AND dea.subst_id IS NOT NULL;

CREATE INDEX ego_dea_allocation_m4_a_mview_geom_idx
	ON model_draft.ego_dea_allocation_m4_a_mview USING gist (geom);

-- Flag M4 DEA    (OK!) -> 1.000ms =20.147
UPDATE 	model_draft.ego_dea_allocation AS dea
SET	flag = 'M4_rest'
WHERE	(dea.voltage_level = '04 (HS/MS)' OR dea.voltage_level = '05 (MS)')
			AND 	(dea.generation_subtype = 'solar_ground_mounted' 
				OR (dea.generation_type = 'solar' AND dea.generation_subtype IS NULL))
			OR (dea.voltage_level IS NULL AND dea.generation_type = 'wind')
			OR dea.flag = 'M1-1_rest'
			OR dea.flag = 'M1-2_rest'
			OR dea.flag = 'M3_rest'
			AND dea.subst_id IS NOT NULL;

-- Create Temp Tables for the loop   (OK!) -> 1.000ms =0
DROP TABLE IF EXISTS 	model_draft.m4_dea_temp CASCADE;
CREATE TABLE 		model_draft.m4_dea_temp (
	sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	flag character varying,
	CONSTRAINT m4_dea_temp_pkey PRIMARY KEY (sorted));

DROP TABLE IF EXISTS 	model_draft.m4_grid_wpa_temp CASCADE;
CREATE TABLE 		model_draft.m4_grid_wpa_temp (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_type text,
	geom geometry(Point,3035),
	CONSTRAINT m4_grid_wpa_temp_pkey PRIMARY KEY (sorted));

DROP TABLE IF EXISTS 	model_draft.m4_jnt_temp CASCADE;
CREATE TABLE 		model_draft.m4_jnt_temp (
  sorted bigint NOT NULL,
  id bigint,
  geom_line geometry(LineString,3035),
  geom geometry(Point,3035),
  CONSTRAINT m4_jnt_temp_pkey PRIMARY KEY (sorted));


-- Run a loop around all grid districs   (OK!)
DO
$$
DECLARE	gd integer;
BEGIN
    FOR gd IN 1..3609
    LOOP
        EXECUTE 'INSERT INTO model_draft.m4_dea_temp
		SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as sorted,
			dea.*
		FROM 	model_draft.ego_dea_allocation_m4_a_mview AS dea
		WHERE 	dea.subst_id =' || gd || ';

		INSERT INTO model_draft.m4_grid_wpa_temp
		SELECT 	row_number() over (ORDER BY RANDOM())as sorted,
			wpa.*
		FROM 	model_draft.ego_lattice_deu_500m_out_mview AS wpa
		WHERE 	wpa.subst_id =' || gd || ';

		INSERT INTO model_draft.m4_jnt_temp
		SELECT	dea.sorted,
			dea.id,
			ST_MAKELINE(dea.geom,wpa.geom) ::geometry(LineString,3035) AS geom_line,
			wpa.geom ::geometry(Point,3035) AS geom -- NEW LOCATION!
		FROM	model_draft.m4_dea_temp AS dea
		INNER JOIN model_draft.m4_grid_wpa_temp AS wpa ON (dea.sorted = wpa.sorted);

		UPDATE 	model_draft.ego_dea_allocation AS t1
		SET  	geom_new = t2.geom_new,
			geom_line = t2.geom_line,
			flag = ''M4''
		FROM	(SELECT	m.id AS id,
				m.geom_line,
				m.geom AS geom_new
			FROM	model_draft.m4_jnt_temp AS m
			)AS t2
		WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.m4_dea_temp, model_draft.m4_grid_wpa_temp, model_draft.m4_jnt_temp;
			';
    END LOOP;
END;
$$;

-- Get M4 List (OK!) -> 1.000ms = 12.418 
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m4_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m4_mview AS
SELECT 	dea.*
FROM	model_draft.ego_dea_allocation AS dea
WHERE	flag = 'M4';

CREATE INDEX ego_dea_allocation_m4_mview_geom_idx
  ON model_draft.ego_dea_allocation_m4_mview USING gist (geom);

-- Get M4 Rest (OK!) -> 1.000ms = 7.729
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m4_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m4_rest_mview AS
SELECT 	dea.*
FROM	model_draft.ego_dea_allocation AS dea
WHERE	dea.flag = 'M4_rest';

CREATE INDEX ego_dea_allocation_m4_rest_mview_geom_idx
  ON model_draft.ego_dea_allocation_m4_rest_mview USING gist (geom);

-- Drop temp
DROP TABLE IF EXISTS 	model_draft.m4_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.m4_grid_wpa_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.m4_jnt_temp CASCADE;

-- Scenario ego data processing
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m4_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
        session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m4_mview;

-- Scenario ego data processing
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m4_rest_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
        session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m4_rest_mview;


/* 6. M5
Relocate "solar" with "06 (MS/NS)" & "07 (NS)" to la_grid
(OK!) -> 1.679.000ms =
Total 1.524.670 ->  Rest?
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

CREATE INDEX ego_dea_allocation_m5_a_mview_geom_idx
	ON model_draft.ego_dea_allocation_m5_a_mview USING gist (geom);

-- Flag M5 DEA    (OK!) -> 189.000ms =1.524.674
UPDATE 	model_draft.ego_dea_allocation AS dea
SET	flag = 'M5_rest'
WHERE 	(dea.voltage_level = '06 (MS/NS)' 
		OR dea.voltage_level = '07 (NS)'
		OR dea.voltage_level IS NULL)
	AND 	dea.generation_type = 'solar'
	OR (dea.voltage_level = '07 (NS)' AND dea.generation_type = 'wind')
	AND dea.subst_id IS NOT NULL;

-- Create Temp Tables for the loop   (OK!) -> 1.000ms =0
DROP TABLE IF EXISTS 	model_draft.m5_dea_temp CASCADE;
CREATE TABLE 		model_draft.m5_dea_temp (
	sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	flag character varying,
	CONSTRAINT m5_dea_temp_pkey PRIMARY KEY (sorted));

DROP TABLE IF EXISTS 	model_draft.m5_grid_la_temp CASCADE;
CREATE TABLE 		model_draft.m5_grid_la_temp (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	geom geometry(Point,3035),
	CONSTRAINT m5_grid_wpa_temp_pkey PRIMARY KEY (sorted));

DROP TABLE IF EXISTS 	model_draft.m5_jnt_temp CASCADE;
CREATE TABLE 		model_draft.m5_jnt_temp (
  sorted bigint NOT NULL,
  id bigint,
  geom_line geometry(LineString,3035),
  geom geometry(Point,3035),
  CONSTRAINT m5_jnt_temp_pkey PRIMARY KEY (sorted));


-- Run a loop around all grid districs   (OK!)
DO
$$
DECLARE	gd integer;
BEGIN
    FOR gd IN 1..3609
    LOOP
        EXECUTE 'INSERT INTO model_draft.m5_dea_temp
		SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as sorted,
                dea.*
		FROM 	model_draft.ego_dea_allocation_m5_a_mview AS dea
		WHERE 	dea.subst_id =' || gd || ';

		INSERT INTO model_draft.m5_grid_la_temp
		SELECT 	row_number() over (ORDER BY RANDOM())as sorted,
                la.*
		FROM 	model_draft.ego_lattice_deu_50m_la_mview AS la
		WHERE 	la.subst_id =' || gd || ';

		INSERT INTO model_draft.m5_jnt_temp
		SELECT	dea.sorted,
			dea.id,
			ST_MAKELINE(dea.geom,la.geom) ::geometry(LineString,3035) AS geom_line,
			la.geom ::geometry(Point,3035) AS geom -- NEW LOCATION!
		FROM	model_draft.m5_dea_temp AS dea
		INNER JOIN model_draft.m5_grid_la_temp AS la ON (dea.sorted = la.sorted);

		UPDATE 	model_draft.ego_dea_allocation AS t1
		SET  	geom_new = t2.geom_new,
			geom_line = t2.geom_line,
			flag = ''M5''
		FROM	(SELECT	m.id AS id,
				m.geom_line,
				m.geom AS geom_new
			FROM	model_draft.m5_jnt_temp AS m
			)AS t2
		WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.m5_dea_temp, model_draft.m5_grid_la_temp, model_draft.m5_jnt_temp;
			';
    END LOOP;
END;
$$;

-- Get M5 List (OK!) -> 1.000ms = 12.418 
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m5_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m5_mview AS
SELECT 	dea.*
FROM	model_draft.ego_dea_allocation AS dea
WHERE	flag = 'M5';

CREATE INDEX ego_dea_allocation_m5_mview_geom_idx
  ON model_draft.ego_dea_allocation_m5_mview USING gist (geom);

-- Get M5 Rest (OK!) -> 1.000ms = 7.729
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m5_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m5_rest_mview AS
SELECT 	dea.*
FROM	model_draft.ego_dea_allocation AS dea
WHERE	dea.flag = 'M5_rest';

CREATE INDEX ego_dea_allocation_m5_rest_mview_geom_idx
  ON model_draft.ego_dea_allocation_m5_rest_mview USING gist (geom);

-- Drop temp
DROP TABLE IF EXISTS 	model_draft.m5_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.m5_grid_la_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.m5_jnt_temp CASCADE;

-- Scenario ego data processing
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

-- Scenario ego data processing
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


-- STATISTICS

-- dea capacity and count per generation types and voltage level  (OK!) 1.000ms =103
DROP TABLE IF EXISTS 	model_draft.ego_dea_per_generation_type_and_voltage_level CASCADE;
CREATE TABLE 		model_draft.ego_dea_per_generation_type_and_voltage_level AS
SELECT 	row_number() over (ORDER BY ee.voltage_level, ee.generation_type, ee.generation_subtype DESC) AS id,
	ee.generation_type,
	ee.generation_subtype,
	ee.voltage_level,
	SUM(ee.electrical_capacity) AS capacity,
	COUNT(ee.geom) AS count
FROM 	orig_geo_opsd.renewable_power_plants_germany AS ee
GROUP BY	ee.voltage_level, ee.generation_type, ee.generation_subtype
ORDER BY 	ee.voltage_level, ee.generation_type, ee.generation_subtype;

ALTER TABLE	model_draft.ego_dea_per_generation_type_and_voltage_level
	ADD PRIMARY KEY (id),
	OWNER TO oeuser;

-- Scenario ego data processing
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_per_generation_type_and_voltage_level' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_per_generation_type_and_voltage_level;


-- dea capacity and count per grid district (GD)  (OK!) 1.000ms =3.610
DROP TABLE IF EXISTS 	model_draft.ego_dea_per_grid_district CASCADE;
CREATE TABLE 		model_draft.ego_dea_per_grid_district AS
SELECT	gd.subst_id,
	'0'::integer lv_dea_cnt,
	'0.0'::decimal lv_dea_capacity,
	'0'::integer mv_dea_cnt,
	'0.0'::decimal mv_dea_capacity
FROM	calc_ego_grid_district.grid_district AS gd;

ALTER TABLE	model_draft.ego_dea_per_grid_district
	ADD PRIMARY KEY (subst_id),
	OWNER TO oeuser;

UPDATE 	model_draft.ego_dea_per_grid_district AS t1
SET  	lv_dea_cnt = t2.lv_dea_cnt,
	lv_dea_capacity = t2.lv_dea_capacity
FROM	(SELECT	gd.subst_id AS subst_id,
		COUNT(dea.geom)::integer AS lv_dea_cnt,
		SUM(electrical_capacity) AS lv_dea_capacity
	FROM	calc_ego_grid_district.grid_district AS gd,
		model_draft.ego_dea_allocation AS dea
	WHERE  	gd.geom && dea.geom AND
		ST_CONTAINS(gd.geom,dea.geom) AND
		dea.voltage_level = '07 (NS)'
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

UPDATE 	model_draft.ego_dea_per_grid_district AS t1
SET  	mv_dea_cnt = t2.mv_dea_cnt,
	mv_dea_capacity = t2.mv_dea_capacity
FROM	(SELECT	gd.subst_id AS subst_id,
		COUNT(dea.geom)::integer AS mv_dea_cnt,
		SUM(electrical_capacity) AS mv_dea_capacity
	FROM	calc_ego_grid_district.grid_district AS gd,
		model_draft.ego_dea_allocation AS dea
	WHERE  	gd.geom && dea.geom AND
		ST_CONTAINS(gd.geom,dea.geom) AND
		dea.voltage_level = '03 (HS)'
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

/* test
SELECT	SUM(gd.lv_dea_cnt) AS lv_dea,
	SUM(gd.mv_dea_cnt) AS mv_dea,
	'1608661' - (SUM(gd.lv_dea_cnt) + SUM(gd.mv_dea_cnt)) AS missing
FROM	model_draft.ego_dea_per_grid_district AS gd; 
*/ 

-- Scenario ego data processing
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'ego_dea_per_grid_district' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_per_grid_district;



-- dea capacity and count per load area  (OK!) 1.000ms = 208.646
DROP TABLE IF EXISTS 	model_draft.dea_germany_per_load_area CASCADE;
CREATE TABLE 		model_draft.dea_germany_per_load_area AS
SELECT	la.id,
	la.subst_id,
	'0'::integer lv_dea_cnt,
	'0.0'::decimal lv_dea_capacity
FROM	calc_ego_loads.ego_deu_load_area AS la;

ALTER TABLE	model_draft.dea_germany_per_load_area
	ADD PRIMARY KEY (id),
	OWNER TO oeuser;

UPDATE 	model_draft.dea_germany_per_load_area AS t1
SET  	lv_dea_cnt = t2.lv_dea_cnt,
	lv_dea_capacity = t2.lv_dea_capacity
FROM	(SELECT	la.id AS id,
		COUNT(dea.geom)::integer AS lv_dea_cnt,
		SUM(electrical_capacity) AS lv_dea_capacity
	FROM	calc_ego_loads.ego_deu_load_area AS la,
		model_draft.ego_dea_allocation AS dea
	WHERE  	la.geom && dea.geom AND
		ST_CONTAINS(la.geom,dea.geom) AND
		dea.voltage_level = '07 (NS)'
	GROUP BY la.id
	)AS t2
WHERE  	t1.id = t2.id;

SELECT	SUM(la.lv_dea_cnt) AS lv_dea,
	SUM(gd.lv_dea_cnt) - SUM(la.lv_dea_cnt) AS missing 
FROM	model_draft.dea_germany_per_load_area AS la,
	model_draft.ego_dea_per_grid_district AS gd;

-- Scenario ego data processing
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'dea_germany_per_load_area' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
        session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.dea_germany_per_load_area;


/* -- TEST
SELECT	'all' AS name,
	COUNT(dea.id) AS count
FROM	model_draft.ego_dea_allocation AS dea
UNION ALL
SELECT	'new' AS name,
	COUNT(dea.id) AS count
FROM	model_draft.ego_dea_allocation AS dea
WHERE	dea.geom_new IS NOT NULL
UNION ALL
SELECT	'M1' AS name,
	COUNT(dea.id) AS count
FROM	model_draft.ego_dea_allocation AS dea
WHERE	dea.flag = 'M1' OR dea.flag = 'M1-1' OR dea.flag = 'M1-2'
UNION ALL
SELECT	'M1-1' AS name,
	COUNT(dea.id) AS count
FROM	model_draft.ego_dea_allocation AS dea
WHERE	dea.flag = 'M1-1'
UNION ALL
SELECT	'M1-2' AS name,
	COUNT(dea.id) AS count
FROM	model_draft.ego_dea_allocation AS dea
WHERE	dea.flag = 'M1-2'
UNION ALL
SELECT	'M2' AS name,
	COUNT(dea.id) AS count
FROM	model_draft.ego_dea_allocation AS dea
WHERE	dea.flag = 'M2'
UNION ALL
SELECT	'M3' AS name,
	COUNT(dea.id) AS count
FROM	model_draft.ego_dea_allocation AS dea
WHERE	dea.flag = 'M3'
UNION ALL
SELECT	'M4' AS name,
	COUNT(dea.id) AS count
FROM	model_draft.ego_dea_allocation AS dea
WHERE	dea.flag = 'M4'
UNION ALL
SELECT	'M5' AS name,
	COUNT(dea.id) AS count
FROM	model_draft.ego_dea_allocation AS dea
WHERE	dea.flag = 'M5' */


