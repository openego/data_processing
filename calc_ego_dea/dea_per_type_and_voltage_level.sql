
------------------------------------ SETUP

-- -- Create schemas for DEA
-- DROP SCHEMA IF EXISTS	calc_ego_re CASCADE;
-- CREATE SCHEMA 		calc_ego_re;
-- 
-- -- Set default privileges for schema
-- ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_re GRANT ALL ON TABLES TO oeuser;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_re GRANT ALL ON SEQUENCES TO oeuser;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_re GRANT ALL ON FUNCTIONS TO oeuser;
-- 
-- -- Grant all in schema
-- GRANT ALL ON SCHEMA 	calc_ego_re TO oeuser WITH GRANT OPTION;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA calc_ego_re TO oeuser;


-- Table with new locations   (OK!) -> 10.951ms =1.608.661
DROP TABLE IF EXISTS calc_ego_re.ego_deu_dea;
CREATE TABLE calc_ego_re.ego_deu_dea (
id bigint NOT NULL,
sort integer,
electrical_capacity numeric,
generation_type text,
generation_subtype character varying,
voltage_level character varying,
voltage_type character(2),
subst_id integer,
la_id integer,
geom_line geometry(LineString,3035),
geom geometry(Point,3035),
CONSTRAINT ego_deu_dea_pkey PRIMARY KEY (id));

INSERT INTO calc_ego_re.ego_deu_dea (id, electrical_capacity, generation_type, generation_subtype, voltage_level, geom)
	SELECT	id, electrical_capacity, generation_type, generation_subtype, voltage_level, ST_TRANSFORM(geom,3035)
	FROM	orig_geo_opsd.renewable_power_plants_germany AS opsd;

CREATE INDEX	ego_deu_dea_geom_idx
	ON	calc_ego_re.ego_deu_dea
	USING	GIST (geom);

UPDATE 	calc_ego_re.ego_deu_dea AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	dea.id AS id,
		gd.subst_id AS subst_id
	FROM	calc_ego_re.ego_deu_dea AS dea,
		calc_ego_grid_district.grid_district AS gd
	WHERE  	gd.geom && dea.geom AND
		ST_CONTAINS(gd.geom,dea.geom)
	) AS t2
WHERE  	t1.id = t2.id;

UPDATE 	calc_ego_re.ego_deu_dea AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	dea.id AS id,
		gd.subst_id AS subst_id
	FROM	calc_ego_re.ego_deu_dea AS dea,
		calc_ego_grid_district.grid_district AS gd
	WHERE  	gd.geom && dea.geom AND
		ST_CONTAINS(gd.geom,dea.geom)
	) AS t2
WHERE  	t1.id = t2.id;



------------------------------------ DEA METHODS

-- -- -- -- M1 HS-solar-roof for 1 GD
-- 
-- -- HS solar roof =21.536
-- DROP TABLE IF EXISTS calc_ego_dea.renewable_power_plants_germany_hv_solar_roof;
-- CREATE TABLE calc_ego_dea.renewable_power_plants_germany_hv_solar_roof AS
-- SELECT 	ee.id,
-- 	ee.electrical_capacity,
-- 	ee.generation_type,
-- 	ee.generation_subtype,
-- 	ee.voltage_level,
-- 	'1' ::integer subst_id,
-- 	ST_TRANSFORM(ee.geom,3035) ::geometry(Point,3035) AS geom
-- FROM orig_geo_opsd.renewable_power_plants_germany AS ee
-- WHERE	(ee.voltage_level = '04 (HS/MS)' OR
-- 	ee.voltage_level = '05 (MS)') AND
-- 	(generation_subtype = 'solar_roof_mounted');
-- 	
-- CREATE INDEX renewable_power_plants_germany_hv_solar_roof_geom_idx
--   ON orig_geo_opsd.renewable_power_plants_germany_hv_solar_roof
--   USING gist
--   (geom);
-- 
-- ALTER TABLE orig_geo_opsd.renewable_power_plants_germany_hv_solar_roof
-- 	ADD PRIMARY KEY (id);
-- 
-- -- "Calculate Substation ID"   (OK!) -> 1.000ms =21.500
-- UPDATE 	orig_geo_opsd.renewable_power_plants_germany_hv_solar_roof AS t1
-- SET  	subst_id = t2.subst_id
-- FROM    (
-- 	SELECT	dea.id AS id,
-- 		dis.subst_id AS subst_id
-- 	FROM	orig_geo_opsd.renewable_power_plants_germany_hv_solar_roof AS dea,
-- 		calc_ego_grid_district.grid_district AS dis
-- 	WHERE  	dis.geom && dea.geom AND
-- 		ST_CONTAINS(dis.geom,dea.geom)
-- 	) AS t2
-- WHERE  	t1.id = t2.id;
-- 
-- ------------------------------------ OSM
-- 
-- -- "Create Table"   (OK!) 200ms =0
-- DROP TABLE IF EXISTS  	orig_geo_opsd.urban_sector_per_grid_district_4_agricultural CASCADE;
-- CREATE TABLE         	orig_geo_opsd.urban_sector_per_grid_district_4_agricultural (
-- 		id SERIAL NOT NULL,
-- 		subst_id integer,
-- 		area_ha numeric,
-- 		geom geometry(Polygon,3035),
-- CONSTRAINT 	urban_sector_per_grid_district_4_agricultural_pkey PRIMARY KEY (id));
-- 
-- 
-- INSERT INTO orig_geo_opsd.urban_sector_per_grid_district_4_agricultural (area_ha,geom)
-- SELECT 	ST_AREA(osm.geom)/10000,
-- 	osm.geom ::geometry(Polygon,3035)
-- FROM 	calc_ego_loads.urban_sector_per_grid_district_4_agricultural AS osm;
-- 
-- 
-- -- "Calculate Substation ID"   (OK!) -> 16.000ms =124.855
-- UPDATE 	orig_geo_opsd.urban_sector_per_grid_district_4_agricultural AS t1
-- SET  	subst_id = t2.subst_id
-- FROM    (
-- 	SELECT	osm.id AS id,
-- 		dis.subst_id AS subst_id
-- 	FROM	orig_geo_opsd.urban_sector_per_grid_district_4_agricultural AS osm,
-- 		calc_ego_grid_district.grid_district AS dis
-- 	WHERE  	dis.geom && ST_CENTROID(osm.geom) AND
-- 		ST_CONTAINS(dis.geom,ST_CENTROID(osm.geom))
-- 	) AS t2
-- WHERE  	t1.id = t2.id;
-- 
-- CREATE INDEX urban_sector_per_grid_district_4_agricultural_geom_idx
--   ON orig_geo_opsd.urban_sector_per_grid_district_4_agricultural
--   USING gist
--   (geom);
-- 

-- LOOP with new tables for each GD! Gets a memory error, beacuse a miximum of 1000 locks!
-- 
-- DO
-- $$
-- DECLARE	gd integer;
-- BEGIN
--     FOR gd IN 1..2
--     LOOP
--         EXECUTE 'DROP TABLE IF EXISTS calc_ego_re.dea_' || gd || ';
-- 		CREATE TABLE calc_ego_re.dea_' || gd || ' AS
-- 		SELECT	row_number() over (ORDER BY electrical_capacity DESC)as sorted,
-- 			dea.*
-- 		FROM 	calc_ego_re.ego_deu_dea AS dea
-- 		WHERE 	(dea.voltage_level = ''04 (HS/MS)'' OR dea.voltage_level = ''05 (MS)'') AND
-- 			(dea.generation_subtype = ''solar_roof_mounted'') AND dea.subst_id =' || gd || ';
-- 		ALTER TABLE calc_ego_re.dea_' || gd || ' ADD PRIMARY KEY (sorted);
-- 
-- 		DROP TABLE IF EXISTS calc_ego_re.osm_' || gd || ';
-- 		CREATE TABLE calc_ego_re.osm_' || gd || ' AS
-- 		SELECT 	row_number() over (ORDER BY osm.area_ha DESC)as sorted,
-- 		osm.*
-- 		FROM 	orig_geo_opsd.urban_sector_per_grid_district_4_agricultural AS osm
-- 		WHERE 	subst_id =' || gd || ';
-- 		ALTER TABLE calc_ego_re.osm_' || gd || ' ADD PRIMARY KEY (sorted);
-- 
-- 		DROP TABLE IF EXISTS calc_ego_re.jnt_' || gd || ';
-- 		CREATE TABLE calc_ego_re.jnt_' || gd || ' AS
-- 		SELECT	dea.sorted,
-- 			dea.id,
-- 			dea.electrical_capacity,
-- 			dea.generation_type,
-- 			dea.generation_subtype,
-- 			dea.voltage_level,
-- 			dea.subst_id,
-- 			dea.geom AS old_geom,
-- 			ST_MAKELINE(ST_CENTROID(osm.geom),dea.geom) ::geometry(LineString,3035) AS geom_line,
-- 			ST_CENTROID(osm.geom) ::geometry(Point,3035) AS geom
-- 		FROM	calc_ego_re.dea_' || gd || ' AS dea
-- 		INNER JOIN calc_ego_re.osm_' || gd || ' AS osm ON (dea.sorted = osm.sorted);
-- 		ALTER TABLE calc_ego_re.jnt_' || gd || ' ADD PRIMARY KEY (sorted);
-- 
-- 		UPDATE 	calc_ego_re.ego_deu_dea AS t1
-- 		SET  	geom_new = t2.geom_new,
-- 			flag = ''M1''
-- 		FROM	(SELECT	m.id AS id,
-- 				m.geom AS geom_new
-- 			FROM	calc_ego_re.jnt_' || gd || ' AS m
-- 			)AS t2
-- 		WHERE  	t1.id = t2.id;
-- 
-- 		DROP TABLE IF EXISTS calc_ego_re.dea_' || gd || ';
-- 		DROP TABLE IF EXISTS calc_ego_re.osm_' || gd || ';
-- 		DROP TABLE IF EXISTS calc_ego_re.jnt_' || gd || ';
-- 			';
--     END LOOP;
-- END;
-- $$;



-- LOOP FOR M1

DROP TABLE IF EXISTS 	calc_ego_re.temp_dea ;
CREATE TABLE 		calc_ego_re.temp_dea (
	sorted bigint NOT NULL,
	id bigint NOT NULL,
	sort integer,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	voltage_type character(2),
	subst_id integer,
	la_id integer,
	geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	geom_new geometry(Point,3035),
	flag character varying,
	CONSTRAINT temp_dea_pkey PRIMARY KEY (sorted));

DROP TABLE IF EXISTS 	calc_ego_re.temp_osm ;
CREATE TABLE 		calc_ego_re.temp_osm (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT temp_osm_pkey PRIMARY KEY (sorted));

DROP TABLE IF EXISTS 	calc_ego_re.temp_jnt ;
CREATE TABLE 		calc_ego_re.temp_jnt (
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
  CONSTRAINT temp_jnt_pkey PRIMARY KEY (sorted));

DO
$$
DECLARE	gd integer;
BEGIN
    FOR gd IN 1..3610
    LOOP
        EXECUTE 'INSERT INTO calc_ego_re.temp_dea
		SELECT	row_number() over (ORDER BY electrical_capacity DESC)as sorted,
			dea.*
		FROM 	calc_ego_re.ego_deu_dea AS dea
		WHERE 	(dea.voltage_level = ''04 (HS/MS)'' OR dea.voltage_level = ''05 (MS)'') AND
			(dea.generation_subtype = ''solar_roof_mounted'') AND dea.subst_id =' || gd || ';

		INSERT INTO calc_ego_re.temp_osm
		SELECT 	row_number() over (ORDER BY osm.area_ha DESC)as sorted,
		osm.*
		FROM 	orig_geo_opsd.urban_sector_per_grid_district_4_agricultural AS osm
		WHERE 	subst_id =' || gd || ';

		INSERT INTO calc_ego_re.temp_jnt
		SELECT	dea.sorted,
			dea.id,
			dea.electrical_capacity,
			dea.generation_type,
			dea.generation_subtype,
			dea.voltage_level,
			dea.subst_id,
			dea.geom AS old_geom,
			ST_MAKELINE(ST_CENTROID(osm.geom),dea.geom) ::geometry(LineString,3035) AS geom_line,
			ST_CENTROID(osm.geom) ::geometry(Point,3035) AS geom
		FROM	calc_ego_re.temp_dea AS dea
		INNER JOIN calc_ego_re.temp_osm AS osm ON (dea.sorted = osm.sorted);

		UPDATE 	calc_ego_re.ego_deu_dea AS t1
		SET  	geom_new = t2.geom_new,
			flag = ''M1''
		FROM	(SELECT	m.id AS id,
				m.geom AS geom_new
			FROM	calc_ego_re.temp_jnt AS m
			)AS t2
		WHERE  	t1.id = t2.id;

		TRUNCATE TABLE calc_ego_re.temp_dea, calc_ego_re.temp_osm, calc_ego_re.temp_jnt;
			';
    END LOOP;
END;
$$;



UPDATE 	calc_ego_re.ego_deu_dea AS t1
SET  	geom_line = t2.geom_line
FROM	(SELECT	dea.id AS id,
		ST_MAKELINE(dea.geom,dea.geom_new) ::geometry(LineString,3035) AS geom_line
	FROM	calc_ego_re.ego_deu_dea AS dea
	WHERE	dea.geom_new IS NOT NULL
	)AS t2
WHERE  	t1.id = t2.id;

DROP TABLE IF EXISTS 	calc_ego_re.ego_deu_dea_m1 ;
CREATE TABLE 		calc_ego_re.ego_deu_dea_m1 AS
SELECT 	dea.*
FROM	calc_ego_re.ego_deu_dea AS dea
WHERE	flag = 'M1';

ALTER TABLE calc_ego_re.ego_deu_dea_m1
	ADD PRIMARY KEY (id);


-- -- TEST
-- 
-- -- DEA
-- DROP TABLE IF EXISTS orig_geo_opsd.test_dea;
-- CREATE TABLE orig_geo_opsd.test_dea AS
-- SELECT 	row_number() over (ORDER BY electrical_capacity DESC)as sorted,
-- 	dea.*
-- FROM 	orig_geo_opsd.renewable_power_plants_germany_hv_solar_roof AS dea
-- WHERE 	subst_id ='1323';
-- 
-- ALTER TABLE orig_geo_opsd.test_dea
-- 	ADD PRIMARY KEY (sorted);
-- 
-- -- OSM
-- DROP TABLE IF EXISTS orig_geo_opsd.test_osm;
-- CREATE TABLE orig_geo_opsd.test_osm AS
-- SELECT 	row_number() over (ORDER BY osm.area_ha DESC)as sorted,
-- 	osm.*
-- FROM 	orig_geo_opsd.urban_sector_per_grid_district_4_agricultural AS osm
-- WHERE 	subst_id ='1323';
-- 
-- ALTER TABLE orig_geo_opsd.test_osm
-- 	ADD PRIMARY KEY (sorted);
-- 
-- 
-- DROP TABLE IF EXISTS orig_geo_opsd.test_new;
-- CREATE TABLE orig_geo_opsd.test_new AS
-- SELECT	dea.sorted,
-- 	dea.id,
-- 	dea.electrical_capacity,
-- 	dea.generation_type,
-- 	dea.generation_subtype,
-- 	dea.voltage_level,
-- 	dea.subst_id,
-- 	dea.geom AS old_geom,
-- 	ST_MAKELINE(ST_CENTROID(osm.geom),dea.geom) ::geometry(LineString,3035) AS geom_line,
-- 	ST_CENTROID(osm.geom) ::geometry(Point,3035) AS geom
-- FROM	orig_geo_opsd.test_dea AS dea
-- INNER JOIN orig_geo_opsd.test_osm AS osm ON (dea.sorted = osm.sorted);
-- 
-- ALTER TABLE orig_geo_opsd.test_new
-- 	ADD PRIMARY KEY (sorted);


-- -- -- M2 HS ?



------------------------------------STATISTICS

-- dea capacity and count per generation types and voltage level  (OK!) 1.000ms =103
DROP TABLE IF EXISTS 	calc_ego_re.dea_germany_per_generation_type_and_voltage_level;
CREATE TABLE 		calc_ego_re.dea_germany_per_generation_type_and_voltage_level AS
SELECT 	row_number() over (ORDER BY ee.voltage_level, ee.generation_type, ee.generation_subtype DESC) AS id,
	ee.generation_type,
	ee.generation_subtype,
	ee.voltage_level,
	SUM(ee.electrical_capacity) AS capacity,
	COUNT(ee.geom) AS count
FROM 	orig_geo_opsd.renewable_power_plants_germany AS ee
GROUP BY	ee.voltage_level, ee.generation_type, ee.generation_subtype
ORDER BY 	ee.voltage_level, ee.generation_type, ee.generation_subtype;

ALTER TABLE	calc_ego_re.dea_germany_per_generation_type_and_voltage_level
	ADD PRIMARY KEY (id),
	OWNER TO oeuser;

-- WHERE 	
-- 	ee.voltage_level = '01 (HöS)' OR
-- 	ee.voltage_level = '02 (HöS/HS)' OR
-- 	ee.voltage_level = '03 (HS)' OR
--	ee.voltage_level = '04 (HS/MS)' OR
-- 	ee.voltage_level = '05 (MS)' OR
-- 	ee.voltage_level = '06 (MS/NS)' OR
-- 	ee.voltage_level = '07 (NS)' OR
-- 	ee.voltage_level IS NULL

-- -- --

-- dea capacity and count per grid district (GD)  (OK!) 1.000ms =3.610
DROP TABLE IF EXISTS 	calc_ego_re.dea_germany_per_grid_district;
CREATE TABLE 		calc_ego_re.dea_germany_per_grid_district AS
SELECT	gd.subst_id,
	'0'::integer lv_dea_cnt,
	'0.0'::decimal lv_dea_capacity,
	'0'::integer mv_dea_cnt,
	'0.0'::decimal mv_dea_capacity
FROM	calc_ego_grid_district.grid_district AS gd;

ALTER TABLE	calc_ego_re.dea_germany_per_grid_district
	ADD PRIMARY KEY (subst_id),
	OWNER TO oeuser;

UPDATE 	calc_ego_re.dea_germany_per_grid_district AS t1
SET  	lv_dea_cnt = t2.lv_dea_cnt,
	lv_dea_capacity = t2.lv_dea_capacity
FROM	(SELECT	gd.subst_id AS subst_id,
		COUNT(dea.geom)::integer AS lv_dea_cnt,
		SUM(electrical_capacity) AS lv_dea_capacity
	FROM	calc_ego_grid_district.grid_district AS gd,
		calc_ego_re.ego_deu_dea AS dea
	WHERE  	gd.geom && dea.geom AND
		ST_CONTAINS(gd.geom,dea.geom) AND
		dea.voltage_level = '07 (NS)'
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

UPDATE 	calc_ego_re.dea_germany_per_grid_district AS t1
SET  	mv_dea_cnt = t2.mv_dea_cnt,
	mv_dea_capacity = t2.mv_dea_capacity
FROM	(SELECT	gd.subst_id AS subst_id,
		COUNT(dea.geom)::integer AS mv_dea_cnt,
		SUM(electrical_capacity) AS mv_dea_capacity
	FROM	calc_ego_grid_district.grid_district AS gd,
		calc_ego_re.ego_deu_dea AS dea
	WHERE  	gd.geom && dea.geom AND
		ST_CONTAINS(gd.geom,dea.geom) AND
		dea.voltage_level = '03 (HS)'
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

SELECT	SUM(gd.lv_dea_cnt) AS lv_dea,
	SUM(gd.mv_dea_cnt) AS mv_dea,
	'1608661' - (SUM(gd.lv_dea_cnt) + SUM(gd.mv_dea_cnt)) AS missing
FROM	calc_ego_re.dea_germany_per_grid_district AS gd;

-- -- --

-- dea capacity and count per load area  (OK!) 1.000ms = 208.646
DROP TABLE IF EXISTS 	calc_ego_re.dea_germany_per_load_area;
CREATE TABLE 		calc_ego_re.dea_germany_per_load_area AS
SELECT	la.id,
	la.subst_id,
	'0'::integer lv_dea_cnt,
	'0.0'::decimal lv_dea_capacity
FROM	calc_ego_loads.ego_deu_load_area AS la;

ALTER TABLE	calc_ego_re.dea_germany_per_load_area
	ADD PRIMARY KEY (id),
	OWNER TO oeuser;

UPDATE 	calc_ego_re.dea_germany_per_load_area AS t1
SET  	lv_dea_cnt = t2.lv_dea_cnt,
	lv_dea_capacity = t2.lv_dea_capacity
FROM	(SELECT	la.id AS id,
		COUNT(dea.geom)::integer AS lv_dea_cnt,
		SUM(electrical_capacity) AS lv_dea_capacity
	FROM	calc_ego_loads.ego_deu_load_area AS la,
		calc_ego_re.ego_deu_dea AS dea
	WHERE  	la.geom && dea.geom AND
		ST_CONTAINS(la.geom,dea.geom) AND
		dea.voltage_level = '07 (NS)'
	GROUP BY la.id
	)AS t2
WHERE  	t1.id = t2.id;

SELECT	SUM(la.lv_dea_cnt) AS lv_dea,
	SUM(gd.lv_dea_cnt) - SUM(la.lv_dea_cnt) AS missing 
FROM	calc_ego_re.dea_germany_per_load_area AS la,
	calc_ego_re.dea_germany_per_grid_district AS gd;



	