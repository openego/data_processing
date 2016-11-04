/* 
Skript to allocate decentralized renewable power plants (dea)
Methods base on technology and voltage level
Uses different lattice from setup_ego_wpa_per_grid_district.sql
*/

/* 
Results
*/ 

-- dea capacity and count per generation types and voltage level
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

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_per_generation_type_and_voltage_level' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_per_generation_type_and_voltage_level;

	
/* 
DEA capacity and count per grid_district
*/ 
DROP TABLE IF EXISTS 	model_draft.ego_dea_per_grid_district CASCADE;
CREATE TABLE 		model_draft.ego_dea_per_grid_district AS
	SELECT	gd.subst_id,
		'0'::integer lv_dea_cnt,
		'0.0'::decimal lv_dea_capacity,
		'0'::integer mv_dea_cnt,
		'0.0'::decimal mv_dea_capacity
	FROM	model_draft.ego_grid_mv_griddistrict AS gd;

ALTER TABLE	model_draft.ego_dea_per_grid_district
	ADD PRIMARY KEY (subst_id),
	OWNER TO oeuser;

UPDATE 	model_draft.ego_dea_per_grid_district AS t1
	SET  	lv_dea_cnt = t2.lv_dea_cnt,
		lv_dea_capacity = t2.lv_dea_capacity
	FROM	(SELECT	gd.subst_id AS subst_id,
			COUNT(dea.geom)::integer AS lv_dea_cnt,
			SUM(electrical_capacity) AS lv_dea_capacity
		FROM	model_draft.ego_grid_mv_griddistrict AS gd,
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
		FROM	model_draft.ego_grid_mv_griddistrict AS gd,
			model_draft.ego_dea_allocation AS dea
		WHERE  	gd.geom && dea.geom AND
			ST_CONTAINS(gd.geom,dea.geom) AND
			dea.voltage_level = '03 (HS)'
		GROUP BY gd.subst_id
		)AS t2
	WHERE  	t1.subst_id = t2.subst_id;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_per_grid_district' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_per_grid_district;

	
/* 
DEA capacity and count per load area
*/ 
DROP TABLE IF EXISTS 	model_draft.ego_dea_per_load_area CASCADE;
CREATE TABLE 		model_draft.ego_dea_per_load_area AS
	SELECT	la.id,
		la.subst_id,
		'0'::integer lv_dea_cnt,
		'0.0'::decimal lv_dea_capacity
	FROM	model_draft.ego_demand_loadarea AS la;

ALTER TABLE	model_draft.ego_dea_per_load_area
	ADD PRIMARY KEY (id),
	OWNER TO oeuser;

UPDATE 	model_draft.ego_dea_per_load_area AS t1
SET  	lv_dea_cnt = t2.lv_dea_cnt,
	lv_dea_capacity = t2.lv_dea_capacity
FROM	(SELECT	la.id AS id,
		COUNT(dea.geom)::integer AS lv_dea_cnt,
		SUM(electrical_capacity) AS lv_dea_capacity
	FROM	model_draft.ego_demand_loadarea AS la,
		model_draft.ego_dea_allocation AS dea
	WHERE  	la.geom && dea.geom AND
		ST_CONTAINS(la.geom,dea.geom) AND
		dea.voltage_level = '07 (NS)'
	GROUP BY la.id
	)AS t2
WHERE  	t1.id = t2.id;

/*
SELECT	SUM(la.lv_dea_cnt) AS lv_dea,
	SUM(gd.lv_dea_cnt) - SUM(la.lv_dea_cnt) AS missing 
FROM	model_draft.ego_dea_per_load_area AS la,
	model_draft.ego_dea_per_grid_district AS gd;
*/

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_per_load_area' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_per_load_area;

/* 
DEA capacity and count per load area
*/ 
DROP TABLE IF EXISTS 	model_draft.ego_dea_per_method CASCADE;
CREATE TABLE 		model_draft.ego_dea_per_method AS
	SELECT	'all' AS name,
		SUM(dea.electrical_capacity) AS capacity,
		COUNT(dea.id) AS count
	FROM	model_draft.ego_dea_allocation AS dea
UNION ALL
	SELECT	'new' AS name,
		SUM(dea.electrical_capacity) AS capacity,
		COUNT(dea.id) AS count
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.geom_new IS NOT NULL
UNION ALL
	SELECT	'M1' AS name,
		SUM(dea.electrical_capacity) AS capacity,
		COUNT(dea.id) AS count
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.flag = 'M1' OR dea.flag = 'M1-1' OR dea.flag = 'M1-2'
UNION ALL
	SELECT	'M1-1' AS name,
		SUM(dea.electrical_capacity) AS capacity,
		COUNT(dea.id) AS count
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.flag = 'M1-1'
UNION ALL
	SELECT	'M1-2' AS name,
		SUM(dea.electrical_capacity) AS capacity,
		COUNT(dea.id) AS count
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.flag = 'M1-2'
UNION ALL
	SELECT	'M2' AS name,
		SUM(dea.electrical_capacity) AS capacity,
		COUNT(dea.id) AS count
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.flag = 'M2'
UNION ALL
	SELECT	'M3' AS name,
		SUM(dea.electrical_capacity) AS capacity,
		COUNT(dea.id) AS count
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.flag = 'M3'
UNION ALL
	SELECT	'M4' AS name,
		SUM(dea.electrical_capacity) AS capacity,
		COUNT(dea.id) AS count
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.flag = 'M4'
UNION ALL
	SELECT	'M5' AS name,
		SUM(dea.electrical_capacity) AS capacity,
		COUNT(dea.id) AS count
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.flag = 'M5'
UNION ALL
	SELECT	'rest' AS name,
		SUM(dea.electrical_capacity) AS capacity,
		COUNT(dea.id) AS count
	FROM	model_draft.ego_dea_allocation AS dea
	WHERE	dea.flag LIKE '\%%_rest';	
	

ALTER TABLE	model_draft.ego_dea_per_method
	ADD PRIMARY KEY (name),
	OWNER TO oeuser;

-- scenario log
INSERT INTO	scenario.ego_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_per_method' AS table_name,
		'process_ego_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_per_method;
