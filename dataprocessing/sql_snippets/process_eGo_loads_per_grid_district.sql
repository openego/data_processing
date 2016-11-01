---------- ---------- ----------
---------- --SKRIPT-- WORK! s
---------- ---------- ----------

---------- ---------- ---------- ---------- ---------- ----------
-- "LOADS"   2016-04-06 15:17   12s
---------- ---------- ---------- ---------- ---------- ----------

-- -- Create schemas for open_eGo
-- DROP SCHEMA IF EXISTS	calc_ego_loads CASCADE;
-- CREATE SCHEMA 		calc_ego_loads;
-- 
-- -- Set default privileges for schema
-- ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_loads GRANT ALL ON TABLES TO oeuser;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_loads GRANT ALL ON SEQUENCES TO oeuser;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_loads GRANT ALL ON FUNCTIONS TO oeuser;
-- 
-- -- Grant all in schema
-- GRANT ALL ON SCHEMA 	calc_ego_loads TO oeuser WITH GRANT OPTION;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA calc_ego_loads TO oeuser;

---------- ---------- ----------
-- Cutting Loads with Grid Districts
---------- ---------- ----------

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	model_draft.ego_demand_loadarea CASCADE;
CREATE TABLE         	model_draft.ego_demand_loadarea (
		id SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	ego_deu_load_area_pkey PRIMARY KEY (id));

-- "Insert Loads"   (OK!) 493.000ms =208.706
INSERT INTO     model_draft.ego_demand_loadarea (geom)
	SELECT	loads.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(loads.geom,dis.geom))).geom AS geom
		FROM	model_draft.ego_demand_load_melt AS loads,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE	loads.geom && dis.geom
		) AS loads
	WHERE	ST_GeometryType(loads.geom) = 'ST_Polygon';

-- "Extend Table"   (OK!) 100ms =0
ALTER TABLE	model_draft.ego_demand_loadarea
	ADD COLUMN zensus_sum integer,
	ADD COLUMN zensus_count integer,
	ADD COLUMN zensus_density numeric,
	ADD COLUMN ioer_sum numeric,
	ADD COLUMN ioer_count integer,
	ADD COLUMN ioer_density numeric,
	ADD COLUMN area_ha numeric,
	ADD COLUMN sector_area_residential numeric,
	ADD COLUMN sector_area_retail numeric,
	ADD COLUMN sector_area_industrial numeric,
	ADD COLUMN sector_area_agricultural numeric,
	ADD COLUMN sector_area_sum numeric,	
	ADD COLUMN sector_share_residential numeric,
	ADD COLUMN sector_share_retail numeric,
	ADD COLUMN sector_share_industrial numeric,
	ADD COLUMN sector_share_agricultural numeric,
	ADD COLUMN sector_share_sum numeric,
	ADD COLUMN sector_count_residential integer,
	ADD COLUMN sector_count_retail integer,
	ADD COLUMN sector_count_industrial integer,
	ADD COLUMN sector_count_agricultural integer,
	ADD COLUMN sector_consumption_residential numeric,
	ADD COLUMN sector_consumption_retail numeric,
	ADD COLUMN sector_consumption_industrial numeric,
	ADD COLUMN sector_consumption_agricultural numeric,
	ADD COLUMN sector_consumption_sum numeric,
	ADD COLUMN subst_id integer,
	ADD COLUMN nuts varchar(5),
	ADD COLUMN rs_0 varchar(12),
	ADD COLUMN ags_0 varchar(12),	
	ADD COLUMN geom_centroid geometry(POINT,3035),
	ADD COLUMN geom_surfacepoint geometry(POINT,3035),
	ADD COLUMN geom_centre geometry(POINT,3035);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	ego_deu_load_area_geom_idx
    ON    	model_draft.ego_demand_loadarea
    USING     	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_demand_loadarea TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_demand_loadarea OWNER TO oeuser;

---------- ---------- ----------

-- "Update Area (area_ha)"   (OK!) -> 31.000ms =208.706
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	area_ha = t2.area
FROM    (
	SELECT	loads.id,
		ST_AREA(ST_TRANSFORM(loads.geom,3035))/10000 AS area
	FROM	model_draft.ego_demand_loadarea AS loads
	) AS t2
WHERE  	t1.id = t2.id;

-- "Validate Area (area_ha) kleiner 100m²"   (OK!) 500ms =1.860
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_demand_loadarea_error_area_ha_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_demand_loadarea_error_area_ha_mview AS
	SELECT 	loads.id AS id,
		loads.area_ha AS area_ha,
		loads.geom AS geom
	FROM 	model_draft.ego_demand_loadarea AS loads
	WHERE	loads.area_ha < 0.001;
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_demand_loadarea_error_area_ha_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_demand_loadarea_error_area_ha_mview OWNER TO oeuser;

-- "Remove Errors (area_ha)"   (OK!) 700ms =1.850
DELETE FROM	model_draft.ego_demand_loadarea AS loads
	WHERE	loads.area_ha < 0.001;

-- -- "Validate Area (area_ha) Check"   (OK!) 84.000ms =81.161
-- SELECT 	loads.id AS id,
-- 	loads.area_ha AS area_ha,
-- 	loads.geom AS geom
-- FROM 	model_draft.ego_demand_loadarea AS loads
-- WHERE	loads.area_ha <= 2;



---------- ---------- ---------- ---------- ---------- ----------
-- "Calculate"
---------- ---------- ---------- ---------- ---------- ----------

---------- ---------- ----------
-- "Geometries"
---------- ---------- ----------

-- "Update Centroid"   (OK!) -> 28.000ms =206.846
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	geom_centroid = t2.geom_centroid
FROM    (
	SELECT	loads.id AS id,
		ST_Centroid(loads.geom) AS geom_centroid
	FROM	model_draft.ego_demand_loadarea AS loads
	) AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_centroid)"   (OK!) -> 4.000ms =0
CREATE INDEX  	ego_deu_load_area_geom_centroid_idx
    ON    	model_draft.ego_demand_loadarea
    USING     	GIST (geom_centroid);
    
---------- ---------- ----------

-- "Update PointOnSurface"   (OK!) -> 50.000ms =181.173
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	geom_surfacepoint = t2.geom_surfacepoint
FROM    (
	SELECT	loads.id AS id,
		ST_PointOnSurface(loads.geom) AS geom_surfacepoint
	FROM	model_draft.ego_demand_loadarea AS loads
	) AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_surfacepoint)"   (OK!) ->  3.000ms =0
CREATE INDEX  	ego_deu_load_area_geom_surfacepoint_idx
    ON    	model_draft.ego_demand_loadarea
    USING     	GIST (geom_surfacepoint);


---------- ---------- ----------
-- "Update Centre"
---------- ---------- ----------

-- "Update Centre with centroid if inside area"   (OK!) -> 19.000ms =199.113
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	geom_centre = t2.geom_centre
FROM	(
	SELECT	loads.id AS id,
		loads.geom_centroid AS geom_centre
	FROM	model_draft.ego_demand_loadarea AS loads
	WHERE  	loads.geom && loads.geom_centroid AND
		ST_CONTAINS(loads.geom,loads.geom_centroid)
	)AS t2
WHERE  	t1.id = t2.id;

-- "Update Centre with surfacepoint if outside area"   (OK!) -> 2.000ms =7.733
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	geom_centre = t2.geom_centre
FROM	(
	SELECT	loads.id AS id,
		loads.geom_surfacepoint AS geom_centre
	FROM	model_draft.ego_demand_loadarea AS loads
	WHERE  	loads.geom_centre IS NULL
	)AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_centre)"   (OK!) -> 2.000ms =0
CREATE INDEX  	ego_deu_load_area_geom_centre_idx
    ON    	model_draft.ego_demand_loadarea
    USING     	GIST (geom_centre);

-- -- "Validate Centre"   (OK!) -> 1.000ms =0
-- 	SELECT	loads.id AS id
-- 	FROM	model_draft.ego_demand_loadarea AS loads
-- 	WHERE  	NOT ST_CONTAINS(loads.geom,loads.geom_centre);

---------- ---------- ----------

-- "Surfacepoint outside area"   (OK!) 2.000ms =7.733
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_demand_loadarea_centre_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_demand_loadarea_centre_mview AS
	SELECT	loads.id AS id,
		ST_Centroid(loads.geom) ::geometry(POINT,3035) AS geom_centroid
	FROM	model_draft.ego_demand_loadarea AS loads
	WHERE  	NOT ST_CONTAINS(loads.geom,loads.geom_centroid);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_demand_loadarea_centre_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_demand_loadarea_centre_mview OWNER TO oeuser;

---------- ---------- ----------
-- "Calculate Zensus2011 Population"
---------- ---------- ----------

-- "Zensus2011 Population"   (OK!) -> 411.000ms =173.278
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	zensus_sum = t2.zensus_sum,
	zensus_count = t2.zensus_count,
	zensus_density = t2.zensus_density
FROM    (SELECT	loads.id AS id,
		SUM(pts.population)::integer AS zensus_sum,
		COUNT(pts.geom)::integer AS zensus_count,
		(SUM(pts.population)/COUNT(pts.geom))::numeric AS zensus_density
	FROM	model_draft.ego_demand_loadarea AS loads,
		social.zensus_population_per_ha_mview AS pts
	WHERE  	loads.geom && pts.geom AND
		ST_CONTAINS(loads.geom,pts.geom)
	GROUP BY loads.id
	)AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------
-- "Calculate IÖR Industry Share"
---------- ---------- ----------

-- "IÖR Industry Share"   (OK!) -> 167.000ms =46.105
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	ioer_sum = t2.ioer_sum,
	ioer_count = t2.ioer_count,
	ioer_density = t2.ioer_density
FROM    (SELECT	loads.id AS id,
		SUM(pts.ioer_share)/100::numeric AS ioer_sum,
		COUNT(pts.geom)::integer AS ioer_count,
		(SUM(pts.ioer_share)/COUNT(pts.geom))::numeric AS ioer_density
	FROM	model_draft.ego_demand_loadarea AS loads,
		economic.ioer_urban_share_industrial_centroid AS pts
	WHERE  	loads.geom && pts.geom AND
		ST_CONTAINS(loads.geom,pts.geom)
	GROUP BY loads.id
	)AS t2
WHERE  	t1.id = t2.id;


---------- ---------- ----------
-- "Calculate Sectors"
---------- ---------- ----------

-- 1. Residential

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_griddistrict_1_residential CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_griddistrict_1_residential	 (
		id SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	urban_sector_per_grid_district_1_residential_pkey PRIMARY KEY (id));

-- "Insert Loads Residential"   (OK!) 330.000ms =290.559
INSERT INTO     model_draft.ego_osm_sector_per_griddistrict_1_residential (geom)
	SELECT	loads.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(loads.geom,dis.geom))).geom AS geom
		FROM	openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview AS loads,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE	loads.geom && dis.geom
		) AS loads
	WHERE	ST_GeometryType(loads.geom) = 'ST_Polygon';

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	urban_sector_per_grid_district_1_residential_geom_idx
    ON    	model_draft.ego_osm_sector_per_griddistrict_1_residential
    USING     	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_osm_sector_per_griddistrict_1_residential TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_osm_sector_per_griddistrict_1_residential OWNER TO oeuser;

---------- ---------- ----------

-- "Calculate Sector Residential"   (OK!) -> 47.000ms =102.302
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	sector_area_residential = t2.sector_area,
	sector_count_residential = t2.sector_count,
	sector_share_residential = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	model_draft.ego_osm_sector_per_griddistrict_1_residential AS sector,
		model_draft.ego_demand_loadarea AS loads
	WHERE  	loads.geom && sector.geom AND  
		ST_INTERSECTS(loads.geom,ST_BUFFER(sector.geom,-1))
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_osm_sector_per_griddistrict_1_residential' AS table_name,
		'process_eGo_loads_per_grid_district.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_osm_sector_per_griddistrict_1_residential;
	
---------- ---------- ----------

-- 2. Retail

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_griddistrict_2_retail CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_griddistrict_2_retail	 (
		id SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	urban_sector_per_grid_district_2_retail_pkey PRIMARY KEY (id));

-- "Insert Loads Retail"   (OK!) 32.000ms =37.496
INSERT INTO     model_draft.ego_osm_sector_per_griddistrict_2_retail (geom)
	SELECT	loads.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(loads.geom,dis.geom))).geom AS geom
		FROM	openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview AS loads,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE	loads.geom && dis.geom
		) AS loads
	WHERE	ST_GeometryType(loads.geom) = 'ST_Polygon';

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	urban_sector_per_grid_district_2_retail_geom_idx
    ON    	model_draft.ego_osm_sector_per_griddistrict_2_retail
    USING     	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_osm_sector_per_griddistrict_2_retail TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_osm_sector_per_griddistrict_2_retail OWNER TO oeuser;

---------- ---------- ----------

-- "Calculate Sector Retail"   (OK!) -> 18.000ms =10.990
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	sector_area_retail = t2.sector_area,
	sector_count_retail = t2.sector_count,
	sector_share_retail = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	model_draft.ego_osm_sector_per_griddistrict_2_retail AS sector,
		model_draft.ego_demand_loadarea AS loads
	WHERE  	loads.geom && sector.geom AND  
		ST_INTERSECTS(loads.geom,ST_BUFFER(sector.geom,-1))
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_osm_sector_per_griddistrict_2_retail' AS table_name,
		'process_eGo_loads_per_grid_district.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_osm_sector_per_griddistrict_2_retail;
	
---------- ---------- ----------

-- 3. Industrial

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_griddistrict_3_industrial CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_griddistrict_3_industrial	 (
		id SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	urban_sector_per_grid_district_3_industrial_pkey PRIMARY KEY (id));

-- "Insert Loads Industrial"   (OK!) 58.000ms =62.181
INSERT INTO     model_draft.ego_osm_sector_per_griddistrict_3_industrial (geom)
	SELECT	loads.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(loads.geom,dis.geom))).geom AS geom
		FROM	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview AS loads,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE	loads.geom && dis.geom
		) AS loads
	WHERE	ST_GeometryType(loads.geom) = 'ST_Polygon';

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	urban_sector_per_grid_district_3_industrial_geom_idx
    ON    	model_draft.ego_osm_sector_per_griddistrict_3_industrial
    USING     	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_osm_sector_per_griddistrict_3_industrial TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_osm_sector_per_griddistrict_3_industrial OWNER TO oeuser;

---------- ---------- ----------

-- "Calculate Sector Industrial"   (OK!) -> 24.000ms =22.129
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	sector_area_industrial = t2.sector_area,
	sector_count_industrial = t2.sector_count,
	sector_share_industrial = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	model_draft.ego_osm_sector_per_griddistrict_3_industrial AS sector,
		model_draft.ego_demand_loadarea AS loads
	WHERE  	loads.geom && sector.geom AND  
		ST_INTERSECTS(loads.geom,ST_BUFFER(sector.geom,-1))
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_osm_sector_per_griddistrict_3_industrial' AS table_name,
		'process_eGo_loads_per_grid_district.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_osm_sector_per_griddistrict_3_industrial;
	
---------- ---------- ----------

-- 4. Agricultural

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_griddistrict_4_agricultural CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_griddistrict_4_agricultural	 (
		id SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	urban_sector_per_grid_district_4_agricultural_pkey PRIMARY KEY (id));

-- "Insert Loads Agricultural"   (OK!) 130.000ms =124.855
INSERT INTO     model_draft.ego_osm_sector_per_griddistrict_4_agricultural (geom)
	SELECT	loads.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(loads.geom,dis.geom))).geom AS geom
		FROM	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview AS loads,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE	loads.geom && dis.geom
		) AS loads
	WHERE	ST_GeometryType(loads.geom) = 'ST_Polygon';

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	urban_sector_per_grid_district_4_agricultural_geom_idx
    ON    	model_draft.ego_osm_sector_per_griddistrict_4_agricultural
    USING     	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_osm_sector_per_griddistrict_4_agricultural TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_osm_sector_per_griddistrict_4_agricultural OWNER TO oeuser;

---------- ---------- ----------

-- "Calculate Sector Agricultural"   (OK!) -> 278.000ms =65.931
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	sector_area_agricultural = t2.sector_area,
	sector_count_agricultural = t2.sector_count,
	sector_share_agricultural = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	model_draft.ego_osm_sector_per_griddistrict_4_agricultural AS sector,
		model_draft.ego_demand_loadarea AS loads
	WHERE  	loads.geom && sector.geom AND  
		ST_INTERSECTS(loads.geom,ST_BUFFER(sector.geom,-1))
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_osm_sector_per_griddistrict_4_agricultural' AS table_name,
		'process_eGo_loads_per_grid_district.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_osm_sector_per_griddistrict_4_agricultural;
	
---------- ---------- ----------

-- "Calculate Sector Stats"   (OK!) -> 42.000ms =206.846
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	sector_area_sum = t2.sector_area_sum,
	sector_share_sum = t2.sector_share_sum
FROM    (
	SELECT	id,
		coalesce(load.sector_area_residential,0) + 
			coalesce(load.sector_area_retail,0) + 
			coalesce(load.sector_area_industrial,0) + 
			coalesce(load.sector_area_agricultural,0) AS sector_area_sum,
		coalesce(load.sector_share_residential,0) + 
			coalesce(load.sector_share_retail,0) + 
			coalesce(load.sector_share_industrial,0) + 
			coalesce(load.sector_share_agricultural,0) AS sector_share_sum		
	FROM	model_draft.ego_demand_loadarea AS load
	) AS t2
WHERE  	t1.id = t2.id;



---------- ---------- ----------
-- "Calculate Codes"   2016-04-06 18:01
---------- ---------- ----------
-- 
-- -- "Transform VG250"   (OK!) -> 2.000ms =11.438
-- DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_6_gem_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_vg250.vg250_6_gem_mview AS
-- 	SELECT	vg.gid,
-- 		vg.gen,
-- 		vg.nuts,
-- 		vg.rs,
-- 		ags_0,
-- 		ST_TRANSFORM(vg.geom,3035) AS geom
-- 	FROM	orig_vg250.vg250_6_gem AS vg
-- 	ORDER BY vg.gid;
-- 
-- -- "Create Index GIST (geom)"   (OK!) -> 150ms =0
-- CREATE INDEX  	vg250_6_gem_mview_geom_idx
-- 	ON	orig_vg250.vg250_6_gem_mview
-- 	USING	GIST (geom);

---------- ---------- ----------

-- "Calculate NUTS"   (OK!) -> 2.164.000ms =206.815
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	nuts = t2.nuts
FROM    (
	SELECT	loads.id AS id,
		vg.nuts AS nuts
	FROM	model_draft.ego_demand_loadarea AS loads,
		political_boundary.bkg_vg250_6_gem_clean AS vg
	WHERE  	vg.geom && loads.geom_centre AND
		ST_CONTAINS(vg.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Regionalschlüssel"   (OK!) -> 47.000ms =181.157
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	rs_0 = t2.rs_0
FROM    (
	SELECT	loads.id,
		vg.rs_0
	FROM	model_draft.ego_demand_loadarea AS loads,
		political_boundary.bkg_vg250_6_gem_clean AS vg
	WHERE  	vg.geom && loads.geom_centre AND
		ST_CONTAINS(vg.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Gemeindeschlüssel"   (OK!) -> 50.000ms =181.157
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	ags_0 = t2.ags_0
FROM    (
	SELECT	loads.id AS id,
		vg.ags_0 AS ags_0
	FROM	model_draft.ego_demand_loadarea AS loads,
		political_boundary.bkg_vg250_6_gem_clean AS vg
	WHERE  	vg.geom && loads.geom_centre AND
		ST_CONTAINS(vg.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

-- "Loads without AGS"   (OK!) 500ms =16
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_demand_loadarea_error_noags_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_demand_loadarea_error_noags_mview AS
	SELECT	loads.id,
		loads.geom
	FROM	model_draft.ego_demand_loadarea AS loads
	WHERE  	loads.ags_0 IS NULL;

---------- ---------- ----------

-- "Calculate Substation ID"   (OK!) -> 2.305.000ms =206.815
UPDATE 	model_draft.ego_demand_loadarea AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	loads.id AS id,
		dis.subst_id AS subst_id
	FROM	model_draft.ego_demand_loadarea AS loads,
		model_draft.ego_grid_mv_griddistrict AS dis
	WHERE  	dis.geom && loads.geom_centre AND
		ST_CONTAINS(dis.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_demand_loadarea' AS table_name,
		'process_eGo_loads_per_grid_district.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_demand_loadarea;

/* 
---------- ---------- ----------
-- consumption calculation   (OK!) -> 7.000ms =446
---------- ---------- ----------


-- Calculate the retail area per district


UPDATE model_draft.ego_demand_per_district a
SET area_retail = result.sum
FROM
( 
	SELECT 
 	sum(coalesce(sector_area_retail,0)), 
	substr(nuts,1,5) 
	FROM model_draft.ego_demand_loadarea
	GROUP BY substr(nuts,1,5)
) as result

WHERE result.substr = substr(a.eu_code,1,5);


-- Calculate the agricultural area per district

UPDATE model_draft.ego_demand_per_district a
SET area_agriculture = result.sum
FROM
( 
	SELECT 
	--sum(sector_area_agricultural), --Merge-error???
	sum(coalesce(sector_area_agricultural,0)), 
	substr(nuts,1,5) 
	FROM model_draft.ego_demand_loadarea
	GROUP BY substr(nuts,1,5)
) as result

WHERE result.substr = substr(a.eu_code,1,5);

-- Calculate area of tertiary sector by adding agricultural and retail area up


update orig_consumption_znes.lak_consumption_per_district 
	set area_tertiary_sector = coalesce(area_retail,0) + coalesce(area_agriculture,0);

-- Calculate electricity demand per loadarea

UPDATE orig_consumption_znes.lak_consumption_per_district
	SET consumption_per_area_tertiary_sector = elec_consumption_tertiary_sector/nullif(area_tertiary_sector,0);



---------- ---------- ----------


-- Calculate sector 1. consumption of households per loadarea   (OK!) -> 38.000ms =206.846
UPDATE model_draft.ego_demand_loadarea a
SET   sector_consumption_residential = sub.result 
FROM
(
	SELECT
	c.id,
	b.elec_consumption_households_per_person * c.zensus_sum as result
	FROM 
	orig_consumption_znes.lak_consumption_per_federalstate b,
	model_draft.ego_demand_loadarea c
	WHERE
	substring(c.nuts,1,3) = b.eu_code
) AS sub
WHERE
sub.id = a.id;

-- Calculate sector 2. consumption of tertiary sector per loadarea   (OK!) -> 50.000ms =196.802
UPDATE model_draft.ego_demand_loadarea a
SET   sector_consumption_retail = sub.result 
FROM
(
	SELECT
	c.id,
	b.consumption_per_area_tertiary_sector * c.sector_area_retail as result
	FROM
	orig_consumption_znes.lak_consumption_per_district b,
	model_draft.ego_demand_loadarea c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.id = a.id;

-- Calculate sector 3. consumption of industry per loadarea   (OK!) -> 36.000ms =196.802
UPDATE model_draft.ego_demand_loadarea a
SET   sector_consumption_industrial = sub.result 
FROM
(
	SELECT
	c.id,
	b.consumption_per_area_industry * c.sector_area_industrial as result
	FROM
	orig_consumption_znes.lak_consumption_per_district b,
	model_draft.ego_demand_loadarea c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.id = a.id;

-- Calculate sector 4. consumption of agriculture per loadarea   (OK!) -> 57.000ms =196.802
UPDATE model_draft.ego_demand_loadarea a
SET   sector_consumption_agricultural = sub.result 
FROM
(
	SELECT
	c.id,
	b.consumption_per_area_tertiary_sector * c.sector_area_agricultural as result
	FROM
	orig_consumption_znes.lak_consumption_per_district b,
	model_draft.ego_demand_loadarea c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.id = a.id;

---------- ---------- ----------

-- Calculate consumption sum per loadarea   (OK!) -> 52.000ms =206.846
UPDATE 	model_draft.ego_demand_loadarea AS a
SET   	sector_consumption_sum = sub.consumption_sum 
FROM	(SELECT	la.id,
		coalesce(la.sector_consumption_residential,0) + 
			coalesce(la.sector_consumption_retail,0) + 
			coalesce(la.sector_consumption_industrial,0) + 
			coalesce(la.sector_consumption_agricultural,0) AS consumption_sum
	FROM	model_draft.ego_demand_loadarea AS la) AS sub
WHERE	sub.id = a.id; */






---------- ---------- ----------

-- Create Test Area   (OK!) -> 3.000ms =1.020
DROP TABLE IF EXISTS	model_draft.ego_demand_loadarea_ta CASCADE;
CREATE TABLE 		model_draft.ego_demand_loadarea_ta AS
	SELECT	load.*
	FROM	model_draft.ego_demand_loadarea AS load
	WHERE	subst_id = '372' OR
		subst_id = '387' OR
		subst_id = '373' OR
		subst_id = '407' OR
		subst_id = '403' OR
		subst_id = '482' OR
		subst_id = '416' OR
		subst_id = '425' OR
		subst_id = '491' OR
		subst_id = '368' OR
		subst_id = '360' OR
		subst_id = '571' OR
		subst_id = '593';

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	model_draft.ego_demand_loadarea_ta
	ADD PRIMARY KEY (id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_load_area_ta_geom_idx
	ON	model_draft.ego_demand_loadarea_ta
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	model_draft.ego_demand_loadarea_ta TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_demand_loadarea_ta OWNER TO oeuser;

-- 
-- ---------- ---------- ----------
-- -- "Create SPF"   2016-04-07 11:34   3s
-- ---------- ---------- ----------
-- 
-- -- "Create Table SPF"   (OK!) 3.000ms =884
-- DROP TABLE IF EXISTS  	model_draft.ego_demand_loadarea_spf;
-- CREATE TABLE         	model_draft.ego_demand_loadarea_spf AS
-- 	SELECT	loads.*
-- 	FROM	model_draft.ego_demand_loadarea AS loads,
-- 		orig_vg250.vg250_4_krs_spf_mview AS spf
-- 	WHERE	ST_TRANSFORM(spf.geom,3035) && loads.geom  AND  
-- 		ST_CONTAINS(ST_TRANSFORM(spf.geom,3035), loads.geom_centre)
-- 	ORDER BY loads.id;
-- 
-- -- "Ad PK"   (OK!) 150ms =0
-- ALTER TABLE	model_draft.ego_demand_loadarea_spf
-- 	ADD PRIMARY KEY (id);
-- 
-- -- "Create Index GIST (geom)"   (OK!) -> 100ms =0
-- CREATE INDEX  	ego_deu_load_area_spf_geom_idx
-- 	ON	model_draft.ego_demand_loadarea_spf
-- 	USING	GIST (geom);
-- 
-- -- "Create Index GIST (geom_centre)"   (OK!) -> 150ms =0
-- CREATE INDEX  	ego_deu_load_area_spf_geom_centre_idx
--     ON    	model_draft.ego_demand_loadarea_spf
--     USING     	GIST (geom_centre);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	model_draft.ego_demand_loadarea_spf TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		model_draft.ego_demand_loadarea_spf OWNER TO oeuser;
