---------- ---------- ----------
-- "Exclude large scale consumer"
---------- ---------- ----------

DELETE FROM openstreetmap.osm_deu_polygon_urban
	WHERE gid IN (SELECT polygon_id FROM calc_ego_loads.large_scale_consumer);


---------- ---------- ---------- ---------- ---------- ----------
-- "Urban Buffer (100m)"   2016-04-18 10:00 s
---------- ---------- ---------- ---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	openstreetmap.osm_deu_polygon_urban_buffer100_mview_id CASCADE;
CREATE SEQUENCE 		openstreetmap.osm_deu_polygon_urban_buffer100_mview_id;

-- "Create Buffer"   (OK!) 1.400.000ms =128.931
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_buffer100_mview CASCADE;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_buffer100_mview AS
	SELECT	 nextval('openstreetmap.osm_deu_polygon_urban_buffer100_mview_id') ::integer AS id,
		(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(osm.geom, 100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	openstreetmap.osm_deu_polygon_urban AS osm;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_buffer100_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_buffer100_mview (id);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_buffer100_mview_geom_idx
    ON    	openstreetmap.osm_deu_polygon_urban_buffer100_mview
    USING     	GIST (geom);
    
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	openstreetmap.osm_deu_polygon_urban_buffer100_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.osm_deu_polygon_urban_buffer100_mview OWNER TO oeuser;


---------- ---------- ----------
-- "Loads OSM"
---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	openstreetmap.ego_deu_loads_osm_id CASCADE;
CREATE SEQUENCE 		openstreetmap.ego_deu_loads_osm_id;

-- "Unbuffer"   (OK!) 1.394.000ms =169.639 
DROP TABLE IF EXISTS	openstreetmap.ego_deu_loads_osm CASCADE;
CREATE TABLE		openstreetmap.ego_deu_loads_osm AS
	SELECT	nextval('openstreetmap.ego_deu_loads_osm_id') AS id,
		ST_AREA(buffer.geom)/10000 ::double precision AS area_ha,
		buffer.geom ::geometry(Polygon,3035) AS geom
	FROM	(SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(osm.geom, -100)
			)))).geom ::geometry(Polygon,3035) AS geom
		FROM	openstreetmap.osm_deu_polygon_urban_buffer100_mview AS osm) AS buffer;

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	openstreetmap.ego_deu_loads_osm
	ADD PRIMARY KEY (id);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	ego_deu_loads_osm_geom_idx
    ON    	openstreetmap.ego_deu_loads_osm
    USING     	GIST (geom);
    
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	openstreetmap.ego_deu_loads_osm TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.ego_deu_loads_osm OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'openstreetmap' AS schema_name,
		'ego_deu_loads_osm' AS table_name,
		'process_eGo_osm_loads.sql' AS script,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	openstreetmap.ego_deu_loads_osm;



---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	openstreetmap.ego_deu_loads_osm_error_geom_view CASCADE;
-- CREATE VIEW		openstreetmap.ego_deu_loads_osm_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,			-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	openstreetmap.ego_deu_loads_osm AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	openstreetmap.ego_deu_loads_osm_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		openstreetmap.ego_deu_loads_osm_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_deu_loads_osm_error_geom_view}', 'openstreetmap');


---------- ---------- ----------
-- Alternative Calculation with Table
---------- ---------- ----------

-- -- "Create Table"   (OK!) 200ms =0
-- DROP TABLE IF EXISTS  	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer CASCADE;
-- CREATE TABLE         	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer (
-- 		id SERIAL NOT NULL,
-- 		area_ha double precision,
-- 		geom geometry(Polygon,3035),
-- CONSTRAINT 	osm_deu_polygon_urban_buffer100_unbuffer_pkey PRIMARY KEY (id));
-- 
-- "Insert Buffer"   (OK!) 100.000ms =169.639
-- INSERT INTO     openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer(geom)
-- 	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
-- 			ST_BUFFER(ST_TRANSFORM(osm.geom,3035), -100)
-- 		)))).geom ::geometry(Polygon,3035) AS geom
-- 	FROM	openstreetmap.osm_deu_polygon_urban_buffer100_mview AS osm
-- 	GROUP BY osm.id
-- 	ORDER BY osm.id;
-- 
-- -- -- "Extend Table"   (OK!) 150ms =0
-- -- ALTER TABLE	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer
-- -- 	ADD COLUMN zensus_sum integer,
-- -- 	ADD COLUMN zensus_count integer,
-- -- 	ADD COLUMN zensus_density numeric,
-- -- 	ADD COLUMN ioer_sum numeric,
-- -- 	ADD COLUMN ioer_count integer,
-- -- 	ADD COLUMN ioer_density numeric,
-- -- 	ADD COLUMN area_ha numeric,
-- -- 	ADD COLUMN sector_area_residential numeric,
-- -- 	ADD COLUMN sector_area_retail numeric,
-- -- 	ADD COLUMN sector_area_industrial numeric,
-- -- 	ADD COLUMN sector_area_agricultural numeric,
-- -- 	ADD COLUMN sector_share_residential numeric,
-- -- 	ADD COLUMN sector_share_retail numeric,
-- -- 	ADD COLUMN sector_share_industrial numeric,
-- -- 	ADD COLUMN sector_share_agricultural numeric,
-- -- 	ADD COLUMN sector_count_residential integer,
-- -- 	ADD COLUMN sector_count_retail integer,
-- -- 	ADD COLUMN sector_count_industrial integer,
-- -- 	ADD COLUMN sector_count_agricultural integer,
-- -- 	ADD COLUMN mv_poly_id integer,
-- -- 	ADD COLUMN nuts varchar(5),
-- -- 	ADD COLUMN rs varchar(12),
-- -- 	ADD COLUMN ags_0 varchar(8),	
-- -- 	ADD COLUMN geom_centroid geometry(POINT,3035),
-- -- 	ADD COLUMN geom_surfacepoint geometry(POINT,3035),
-- -- 	ADD COLUMN geom_buffer geometry(Polygon,3035);
-- 
-- -- "Create Index GIST (geom)"   (OK!) 2.000ms =0
-- CREATE INDEX  	osm_deu_polygon_urban_buffer100_unbuffer_geom_idx
--     ON    	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer
--     USING     	GIST (geom);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer OWNER TO oeuser;



---------- ---------- ---------- ---------- ---------- ----------
-- "exclusion"
---------- ---------- ---------- ---------- ---------- ----------

-- -- "Update Area (area_ha)"   (OK!) -> 10.000ms =169.639
-- UPDATE 	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer AS t1
-- SET  	area_ha = t2.area
-- FROM    (
-- 	SELECT	la.id,
-- 		ST_AREA(ST_TRANSFORM(la.geom,3035))/10000 ::double precision AS area
-- 	FROM	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- 	) AS t2
-- WHERE  	t1.id = t2.id;

-- -- "Validate Area (area_ha) kleiner 100m²"   (OK!) 500ms =1.418
-- DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview CASCADE;
-- CREATE MATERIALIZED VIEW 		openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview AS 
-- 	SELECT 	la.id AS id,
-- 		la.area_ha AS area_ha,
-- 		la.geom AS geom
-- 	FROM 	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- 	WHERE	la.area_ha < 0.01;
-- GRANT ALL ON TABLE openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview TO oeuser WITH GRANT OPTION;
-- 
-- -- "Remove Errors (area_ha)"   (OK!) 700ms =1.418
-- DELETE FROM	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- 	WHERE	la.area_ha < 0.01;
-- 
-- -- "Validate Area (area_ha) Check"   (OK!) 400ms =0
-- SELECT 	la.id AS id,
-- 	la.area_ha AS area_ha,
-- 	la.geom AS geom
-- FROM 	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- WHERE	la.area_ha < 0.01;
