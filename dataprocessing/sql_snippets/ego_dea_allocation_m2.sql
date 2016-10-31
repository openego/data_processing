/* 
Skript to allocate decentralized renewable power plants (dea)
Methods base on technology and voltage level
Uses different lattice from setup_ego_wpa_per_grid_district.sql
*/


/* 3. M2
Move "wind" with "04 (HS/MS)" to WPA as wind farms.
The rest could not be allocated, consider in M4.
*/

-- MView M2
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
	WHERE 	(dea.voltage_level = '04 (HS/MS)' AND 
		dea.generation_type = 'wind');

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m2_a_mview_geom_idx
	ON model_draft.ego_dea_allocation_m2_a_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m2_a_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_m2_a_mview OWNER TO oeuser;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m2_a_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m2_a_mview;

-- flag M2
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = 'M2_rest'
	WHERE	dea.voltage_level = '04 (HS/MS)' AND 
		dea.generation_type = 'wind';

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

-- insert data (windfarm)
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

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m2_windfarm_geom_idx
	ON model_draft.ego_dea_allocation_m2_windfarm USING gist (geom);

-- update subst_id from grid_district
UPDATE 	model_draft.ego_dea_allocation_m2_windfarm AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	farm.farm_id AS farm_id,
			gd.subst_id AS subst_id
		FROM	model_draft.ego_dea_allocation_m2_windfarm AS farm,
			model_draft.ego_grid_mv_griddistrict AS gd
		WHERE  	gd.geom && ST_CENTROID(farm.geom) AND
			ST_CONTAINS(gd.geom,ST_CENTROID(farm.geom))
		) AS t2
	WHERE  	t1.farm_id = t2.farm_id;

-- update wind farm data
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

-- update DEA in wind farms
UPDATE 	model_draft.ego_dea_allocation AS t1
	SET  	sort = t2.farm_id   -- temporary store farm_id in sort!
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

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m2_windfarm' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m2_windfarm;

-- create temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_m2_farm_temp CASCADE;
CREATE TABLE 		model_draft.ego_m2_farm_temp (
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
	CONSTRAINT ego_m2_farm_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m2_farm_temp_geom_idx
	ON model_draft.ego_m2_farm_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.ego_m2_wpa_temp CASCADE;
CREATE TABLE 		model_draft.ego_m2_wpa_temp (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_m2_wpa_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m2_wpa_temp_geom_idx
	ON model_draft.ego_m2_wpa_temp USING gist (geom);

DROP TABLE IF EXISTS 	model_draft.ego_m2_jnt_temp CASCADE;
CREATE TABLE 		model_draft.ego_m2_jnt_temp (
	sorted bigint NOT NULL,
	farm_id bigint,
	subst_id integer,
	geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_m2_jnt_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m2_jnt_temp_geom_idx
	ON model_draft.ego_m2_jnt_temp USING gist (geom);

-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3609	-- subst_id
	LOOP
        EXECUTE '
		INSERT INTO model_draft.ego_m2_farm_temp
			SELECT	row_number() over (ORDER BY farm.dea_cnt DESC)as sorted,
				farm.*
			FROM 	model_draft.ego_dea_allocation_m2_windfarm AS farm
			WHERE 	farm.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_m2_wpa_temp
			SELECT 	row_number() over (ORDER BY wpa.area_ha DESC)as sorted,
				wpa.*
			FROM 	model_draft.ego_wpa_per_grid_district AS wpa
			WHERE 	wpa.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_m2_jnt_temp
			SELECT	farm.sorted,
				farm.farm_id,
				farm.subst_id,
				ST_MAKELINE(ST_CENTROID(farm.geom),ST_PointOnSurface(wpa.geom)) ::geometry(LineString,3035) AS geom_line,
				ST_PointOnSurface(wpa.geom) ::geometry(Point,3035) AS geom	-- NEW LOCATION!
			FROM	model_draft.ego_m2_farm_temp AS farm
			INNER JOIN model_draft.ego_m2_wpa_temp AS wpa ON (farm.sorted = wpa.sorted);

		UPDATE 	model_draft.ego_dea_allocation AS t1
			SET  	geom_new = t2.geom_new,
				geom_line = t2.geom_line,
				flag = ''M2''
			FROM	(SELECT	m.farm_id AS farm_id,
					m.geom_line,
					m.geom AS geom_new
				FROM	model_draft.ego_m2_jnt_temp AS m
				)AS t2
			WHERE  	t1.sort = t2.farm_id;

		TRUNCATE TABLE model_draft.ego_m2_farm_temp, model_draft.ego_m2_wpa_temp, model_draft.ego_m2_jnt_temp;
		';
	END LOOP;
END;
$$;

-- M2 result
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m2_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m2_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	flag = 'M2';

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m2_mview_geom_idx
	ON model_draft.ego_dea_allocation_m2_mview USING gist (geom);

-- create index GIST (geom_line)
CREATE INDEX ego_dea_allocation_m2_mview_geom_line_idx
	ON model_draft.ego_dea_allocation_m2_mview USING gist (geom_line);

-- create index GIST (geom_new)
CREATE INDEX ego_dea_allocation_m2_mview_geom_new_idx
	ON model_draft.ego_dea_allocation_m2_mview USING gist (geom_new);	

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m2_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_m2_mview OWNER TO oeuser;

-- M2 rest
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_m2_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_m2_rest_mview AS
	SELECT 	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	flag = 'M2_rest';

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_m2_rest_mview_geom_idx
	ON model_draft.ego_dea_allocation_m2_rest_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_m2_rest_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_m2_rest_mview OWNER TO oeuser;	

-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_m2_farm_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_m2_wpa_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_m2_jnt_temp CASCADE;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m2_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m2_mview;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_m2_rest_mview' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_m2_rest_mview;
