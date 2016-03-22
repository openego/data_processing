

---------- ---------- ---------- ---------- ---------- ----------
-- "Filter Urban Landuse"
---------- ---------- ---------- ---------- ---------- ----------

-- "Filter Urban"   (OK!) -> 13.000ms =494.696
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_rli.osm_deu_polygon_urban_mview AS
	SELECT	osm.*
	FROM	orig_osm.osm_deu_polygon AS osm
	WHERE	osm.landuse='residential' OR

		osm.landuse='commercial' OR 
		osm.landuse='retail' OR
		osm.landuse='industrial;retail' OR

		osm.landuse='industrial' OR 
		osm.landuse='port' OR
		osm.man_made='wastewater_plant' OR
		osm.aeroway='terminal' OR osm.aeroway='gate' OR
		osm.man_made='works' OR
		
		osm.landuse='farmyard' OR 
		osm.landuse='greenhouse_horticulture'
	ORDER BY	osm.gid;

-- "Create Index GIST (geom)"   (OK!) -> 6.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_mview_geom_idx
	ON	orig_geo_rli.osm_deu_polygon_urban_mview
	USING	GIST (geom);

-- "Create Index B-tree (gid)"   (OK!) -> 2.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_mview_gid_idx
	ON		orig_geo_rli.osm_deu_polygon_urban_mview (gid);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE orig_geo_rli.osm_deu_polygon_urban_mview TO oeuser WITH GRANT OPTION;

-- "Validate (geom)"   (OK!) -> 20.000ms =0
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_mview_error_geom_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_rli.osm_deu_polygon_urban_mview_error_geom_mview AS 
	SELECT	test.gid,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		location(ST_IsValidDetail(test.geom)) AS error_location,
		test.geom
	FROM	(
		SELECT	source.gid AS gid,
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_geo_rli.osm_deu_polygon_urban_mview AS source
		) AS test
	WHERE	test.error = FALSE;
GRANT ALL ON TABLE orig_geo_rli.osm_deu_polygon_urban_mview_error_geom_mview TO oeuser WITH GRANT OPTION;

-- "Validate (gid)"   (OK!) -> 500ms =0
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_mview_error_gid_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_rli.osm_deu_polygon_urban_mview_error_gid_mview AS 
	SELECT 		gid,
			count(*)
	FROM 		orig_geo_rli.osm_deu_polygon_urban_mview
	GROUP BY 	gid
	HAVING 		count(*) > 1;
GRANT ALL ON TABLE orig_geo_rli.osm_deu_polygon_urban_mview_error_gid_mview TO oeuser WITH GRANT OPTION;


-- No doubles on Germany! Skip next!
---------- ---------- ----------
-- Delete double entries on "gid" 
---------- ---------- ----------

-- -- Find double entries (OK!) -> =18
-- SELECT 		gid, count(*)
-- FROM 		orig_geo_rli.osm_deu_polygon_spf
-- GROUP BY 	gid
-- HAVING 		count(*) > 1;
-- 
-- -- --  IF double 
-- -- Create nodubs (OK!)
-- DROP TABLE IF EXISTS	orig_geo_rli.osm_deu_polygon_spf_nodubs;
-- CREATE TABLE		orig_geo_rli.osm_deu_polygon_spf_nodubs AS
-- 	SELECT	osm.*
-- 	FROM	orig_geo_rli.osm_deu_polygon_spf AS osm
-- 	LIMIT 	0;
-- 
-- -- Add id (OK!)
-- ALTER TABLE 	orig_geo_rli.osm_deu_polygon_spf_nodubs
-- 	ADD column id serial;
-- 
-- -- Insert data (OK!) 94ms =1567
-- INSERT INTO	orig_geo_rli.osm_deu_polygon_spf_nodubs
-- 	SELECT	osm.*
-- 	FROM	orig_geo_rli.osm_deu_polygon_spf AS osm
-- ORDER BY 	gid;
-- 
-- -- Delete double entries (OK!) 62ms =-18
-- DELETE FROM orig_geo_rli.osm_deu_polygon_spf_nodubs
-- WHERE id IN (SELECT id
--               FROM (SELECT id,
--                              ROW_NUMBER() OVER (partition BY gid ORDER BY id) AS rnum
--                      FROM orig_geo_rli.osm_deu_polygon_spf_nodubs) t
--               WHERE t.rnum > 1);
-- 
-- -- Check for doubles again (OK!)
-- SELECT 		gid, count(*)
-- FROM 		orig_geo_rli.osm_deu_polygon_spf_nodubs
-- GROUP BY 	gid
-- HAVING 		count(*) > 1;
-- 
-- -- Set PK (OK!)
-- ALTER TABLE 	orig_geo_rli.osm_deu_polygon_spf_nodubs ADD PRIMARY KEY (gid);
-- 
-- -- Create new index (OK!)
-- CREATE INDEX  	osm_deu_polygon_spf_nodubs_geom_idx
--     ON    	orig_geo_rli.osm_deu_polygon_spf_nodubs
--     USING     	GIST (geom);


---------- ---------- ---------- ---------- ---------- ----------
-- "Filter by Sector"
---------- ---------- ---------- ---------- ---------- ----------

-- "Sector 1. Residential"

-- "Filter Residential"   (OK!) -> 12.000ms =277.423
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_sector_1_residential_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_rli.osm_deu_polygon_urban_sector_1_residential_mview AS
	SELECT	osm.gid,
		osm.osm_id,
		osm.landuse,
		osm.man_made,
		osm.name,
		osm.way_area,
		ST_AREA(ST_TRANSFORM(osm.geom,3035))/10000 AS area_ha,
		osm.tags,
		ST_TRANSFORM(osm.geom,3035) AS geom
	FROM	orig_geo_rli.osm_deu_polygon_urban_mview AS osm
	WHERE	osm.landuse='residential'
ORDER BY	osm.gid;
    
-- "Create Index GIST (geom)"   (OK!) -> 4.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_1_residential_mview_geom_idx
	ON	orig_geo_rli.osm_deu_polygon_urban_sector_1_residential_mview
	USING	GIST (geom);

-- "Create Index B-tree (gid)"   (OK!) -> 400ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_1_residential_mview_gid_idx
	ON		orig_geo_rli.osm_deu_polygon_urban_sector_1_residential_mview (gid);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE orig_geo_rli.osm_deu_polygon_urban_sector_1_residential_mview TO oeuser WITH GRANT OPTION;


---------- ---------- ----------

-- "Sector 2. Retail"

-- "Filter Retail"   (OK!) -> 1.000ms =35.750
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_sector_2_retail_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_rli.osm_deu_polygon_urban_sector_2_retail_mview AS
	SELECT	osm.gid,
		osm.osm_id,
		osm.landuse,
		osm.man_made,
		osm.name,
		osm.way_area,
		ST_AREA(ST_TRANSFORM(osm.geom,3035))/10000 AS area_ha,
		osm.tags,
		ST_TRANSFORM(osm.geom,3035) AS geom
	FROM	orig_geo_rli.osm_deu_polygon_urban_mview AS osm
	WHERE	osm.landuse='commercial' OR 
		osm.landuse='retail' OR
		osm.landuse='industrial;retail'
ORDER BY	osm.gid;
    
-- "Create Index GIST (geom)"   (OK!) -> 2.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_2_retail_mview_geom_idx
	ON	orig_geo_rli.osm_deu_polygon_urban_sector_2_retail_mview
	USING	GIST (geom);

-- "Create Index B-tree (gid)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_2_retail_mview_gid_idx
	ON		orig_geo_rli.osm_deu_polygon_urban_sector_2_retail_mview (gid);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE orig_geo_rli.osm_deu_polygon_urban_sector_2_retail_mview TO oeuser WITH GRANT OPTION;


---------- ---------- ----------

-- "Sector 3. Industrial"

-- "Filter Industrial"   (OK!) -> 1.000ms =59.110
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_sector_3_industrial_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_rli.osm_deu_polygon_urban_sector_3_industrial_mview AS
	SELECT	osm.gid,
		osm.osm_id,
		osm.landuse,
		osm.man_made,
		osm.name,
		osm.way_area,
		ST_AREA(ST_TRANSFORM(osm.geom,3035))/10000 AS area_ha,
		osm.tags,
		ST_TRANSFORM(osm.geom,3035) AS geom
	FROM	orig_geo_rli.osm_deu_polygon_urban_mview AS osm
	WHERE	osm.landuse='industrial' OR 
		osm.landuse='port' OR
		osm.man_made='wastewater_plant' OR
		osm.aeroway='terminal' OR osm.aeroway='gate' OR
		osm.man_made='works'
ORDER BY	osm.gid;
    
-- "Create Index GIST (geom)"   (OK!) -> 1.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_3_industrial_mview_geom_idx
	ON	orig_geo_rli.osm_deu_polygon_urban_sector_3_industrial_mview
	USING	GIST (geom);

-- "Create Index B-tree (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_3_industrial_mview_gid_idx
	ON		orig_geo_rli.osm_deu_polygon_urban_sector_3_industrial_mview (gid);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE orig_geo_rli.osm_deu_polygon_urban_sector_3_industrial_mview TO oeuser WITH GRANT OPTION;


---------- ---------- ----------

-- "Sector 4. Agricultural"

-- "Filter Agricultural"   (OK!) -> 2.000ms =122.549
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_sector_4_agricultural_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_rli.osm_deu_polygon_urban_sector_4_agricultural_mview AS
	SELECT	osm.gid,
		osm.osm_id,
		osm.landuse,
		osm.man_made,
		osm.name,
		osm.way_area,
		ST_AREA(ST_TRANSFORM(osm.geom,3035))/10000 AS area_ha,
		osm.tags,
		ST_TRANSFORM(osm.geom,3035) AS geom
	FROM	orig_geo_rli.osm_deu_polygon_urban_mview AS osm
	WHERE	osm.landuse='farmyard' OR 
		osm.landuse='greenhouse_horticulture'
ORDER BY	osm.gid;
    
-- "Create Index GIST (geom)"   (OK!) -> 1.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_4_agricultural_mview_geom_idx
	ON	orig_geo_rli.osm_deu_polygon_urban_sector_4_agricultural_mview
	USING	GIST (geom);

-- "Create Index B-tree (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_4_agricultural_mview_gid_idx
	ON		orig_geo_rli.osm_deu_polygon_urban_sector_4_agricultural_mview (gid);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE orig_geo_rli.osm_deu_polygon_urban_sector_4_agricultural_mview TO oeuser WITH GRANT OPTION;


---------- ---------- ---------- ---------- ---------- ----------
-- "Urban Buffer [100m]"
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	orig_geo_rli.osm_deu_polygon_urban_buffer100;
CREATE TABLE         	orig_geo_rli.osm_deu_polygon_urban_buffer100 (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT 	osm_deu_polygon_urban_buffer100_pkey PRIMARY KEY (id));

-- "Insert Buffer"   (OK!) 1.216.000ms =129.322
INSERT INTO     orig_geo_rli.osm_deu_polygon_urban_buffer100(geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(ST_TRANSFORM(osm.geom,3035), 100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_rli.osm_deu_polygon_urban_mview AS osm;

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_buffer100_geom_idx
    ON    	orig_geo_rli.osm_deu_polygon_urban_buffer100
    USING     	GIST (geom);
    
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE orig_geo_rli.osm_deu_polygon_urban_buffer100 TO oeuser WITH GRANT OPTION;


---------- ---------- ---------- ---------- ---------- ----------
-- "Unbuffer [-100m]"
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer;
CREATE TABLE         	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer (
		uid SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	osm_deu_polygon_urban_buffer100_unbuffer_pkey PRIMARY KEY (uid));

-- "Insert Buffer"   (OK!) 93.000ms =170.088
INSERT INTO     orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer(geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(ST_TRANSFORM(osm.geom,3035), -100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100 AS osm
	GROUP BY osm.id
	ORDER BY osm.id;

-- -- UNBUFFER (OK!) 135.000ms =169.620
-- DROP TABLE IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff;
-- CREATE TABLE 		orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff AS
-- 	SELECT	nextval('orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff_uid_seq') AS uid,
-- 		ST_AsTEXT((ST_DUMP(ST_MULTI(ST_UNION(ST_BUFFER(ST_TRANSFORM(osm.geom,3035), -100))))).geom) AS geom
-- 	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100 AS osm
-- 	GROUP BY osm.id
-- 	ORDER BY osm.id;

-- "Extend Table"   (OK!) 150ms =0
ALTER TABLE	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
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
	ADD COLUMN sector_share_residential numeric,
	ADD COLUMN sector_share_retail numeric,
	ADD COLUMN sector_share_industrial numeric,
	ADD COLUMN sector_share_agricultural numeric,
	ADD COLUMN sector_count_residential integer,
	ADD COLUMN sector_count_retail integer,
	ADD COLUMN sector_count_industrial integer,
	ADD COLUMN sector_count_agricultural integer,
	ADD COLUMN sector_consumption_residential numeric,
	ADD COLUMN sector_consumption_retail numeric,
	ADD COLUMN sector_consumption_industrial numeric,
	ADD COLUMN sector_consumption_agricultural numeric,
	ADD COLUMN mv_poly_id integer,
	ADD COLUMN nuts varchar(5),
	ADD COLUMN rs varchar(12),
	ADD COLUMN ags_0 varchar(8),	
	ADD COLUMN geom_centroid geometry(POINT,3035),
	ADD COLUMN geom_surfacepoint geometry(POINT,3035),
	ADD COLUMN geom_buffer geometry(Polygon,3035);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_buffer100_unbuffer_geom_idx
    ON    	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
    USING     	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer TO oeuser WITH GRANT OPTION;

---------- ---------- ---------- ---------- ---------- ----------
-- "(Geo) Data Validation"
---------- ---------- ---------- ---------- ---------- ----------

-- "Validate (geom)"   (OK!) -> 16.000ms =0
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer_error_geom_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer_error_geom_mview AS 
	SELECT	test.uid,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		location(ST_IsValidDetail(test.geom)) AS error_location,
		test.geom
	FROM	(
		SELECT	source.uid AS uid,
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS source
		) AS test
	WHERE	test.error = FALSE;
GRANT ALL ON TABLE orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer_error_geom_mview TO oeuser WITH GRANT OPTION;

-- "Validate (uid)"   (OK!) -> 100ms =0
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer_error_gid_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer_error_gid_mview AS 
	SELECT 		source.uid AS uid,
			count(source.*) AS count
	FROM 		orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS source
	GROUP BY 	source.uid
	HAVING 		count(source.*) > 1;
GRANT ALL ON TABLE orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer_error_gid_mview TO oeuser WITH GRANT OPTION;

-- "Update Area (area_ha)"   (OK!) -> 10.000ms :170.088
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	area_ha = t2.area
FROM    (
	SELECT	la.uid,
		ST_AREA(ST_TRANSFORM(la.geom,3035))/10000 AS area
	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la
	) AS t2
WHERE  	t1.uid = t2.uid;

-- "Validate Area (area_ha)"   (OK!) 500ms =1.418
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview AS 
	SELECT 	la.uid AS uid,
		la.area_ha AS area_ha,
		la.geom AS geom
	FROM 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la
	WHERE	la.area_ha < 0.01;
GRANT ALL ON TABLE orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview TO oeuser WITH GRANT OPTION;

-- "Remove Errors (area_ha)"   (OK!) 700ms =1.418
DELETE FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la
	WHERE	la.area_ha < 0.01;

-- "Validate Area (area_ha) Check"   (OK!) 400ms =0
SELECT 	la.uid AS uid,
	la.area_ha AS area_ha,
	la.geom AS geom
FROM 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la
WHERE	la.area_ha < 0.01;


---------- ---------- ---------- ---------- ---------- ----------
-- "Fehlerbehebung"
---------- ---------- ---------- ---------- ---------- ----------
-- 
-- -- LG Fehler (OK!) 13.000ms =950
-- DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.rli_deu_lastgebiete_fehler;
-- CREATE MATERIALIZED VIEW 		orig_geo_rli.rli_deu_lastgebiete_fehler AS 
-- 	SELECT 	lg.*		
-- 	FROM 	orig_geo_rli.rli_deu_lastgebiete AS lg
-- 	WHERE	lg.area_lg < 0.01
-- 
-- -- Delete Errors from LG (OK!) 100ms =950
-- DELETE FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff AS lg
-- 	WHERE	lg.area_lg < 0.01;
-- 
-- -- Validate geoms (OK!) 20.000ms =157
-- DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.rli_deu_lastgebiete_fehler_2;
-- CREATE MATERIALIZED VIEW 		orig_geo_rli.rli_deu_lastgebiete_fehler_2 AS 
-- 	SELECT	test.uid,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		location(ST_IsValidDetail(test.geom)) AS error_location,
-- 		test.geom
-- 	FROM	(
-- 		SELECT	lg.uid AS uid,
-- 			ST_IsValid(lg.geom) AS error,
-- 			lg.geom AS geom
-- 		FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff AS lg
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Fix geoms (OK!) 8.000ms =157
-- DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.rli_deu_lastgebiete_fehler_2_fix;
-- CREATE MATERIALIZED VIEW 		orig_geo_rli.rli_deu_lastgebiete_fehler_2_fix AS 
-- 	SELECT	fix.uid AS uid,
-- 		ST_IsValid(fix.geom) AS error,
-- 		GeometryType(fix.geom) AS geom_type,
-- 		ST_AREA(fix.geom) AS area,
-- 		fix.geom_buffer,
-- 		fix.geom
-- 	FROM	(
-- 		SELECT	fehler.uid AS uid,
-- 			ST_BUFFER(fehler.geom, -0.01)  AS geom_buffer,
-- 			(ST_DUMP(ST_BUFFER(ST_BUFFER(fehler.geom, -0.01), 0.01))).geom ::geometry(POLYGON,3035) AS geom
-- 		FROM	orig_geo_rli.rli_deu_lastgebiete_fehler_2 AS fehler
-- 		) AS fix
-- 	WHERE	ST_AREA(fix.geom) > 0.4
-- 	ORDER BY fix.uid;
-- 
-- 
-- -- Update Fixed geoms (OK!) 1.000ms =157
-- UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff AS t1
-- SET	geom = t2.geom
-- FROM	(
-- 	SELECT	fix.uid AS uid,
-- 		fix.geom AS geom,
-- 		fix.geom_type AS geom_type
-- 	FROM	orig_geo_rli.rli_deu_lastgebiete_fehler_2_fix AS fix
-- 	) AS t2
-- JOIN	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff USING (uid)
-- WHERE  	t1.uid = t2.uid;
-- 
-- -- Check for errors again! (OK!) 20.000ms =0
-- SELECT	test.uid,
-- 	test.error,
-- 	reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 	location(ST_IsValidDetail(test.geom)) AS error_location,
-- 	test.geom
-- FROM	(
-- 	SELECT	lg.uid AS uid,
-- 		ST_IsValid(lg.geom) AS error,
-- 		lg.geom AS geom
-- 	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff AS lg
-- 	) AS test
-- WHERE	test.error = FALSE;
	
---------- ---------- ---------- ---------- ---------- ----------
-- "Calculate"
---------- ---------- ---------- ---------- ---------- ----------

---------- ---------- ----------
-- "Geometries"
---------- ---------- ----------

-- "Update PointOnSurface"   (OK!) -> 34.000ms =168.670
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	geom_surfacepoint = t2.geom_surfacepoint
FROM    (
	SELECT	la.uid AS uid,
		ST_PointOnSurface(la.geom) AS geom_surfacepoint
	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;

-- "Create Index GIST (geom_surfacepoint)"   (OK!) ->  10.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_buffer100_unbuffer_geom_surfacepoint_idx
    ON    	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
    USING     	GIST (geom_surfacepoint);

---------- ---------- ----------

-- "Update Centroid"   (OK!) -> 18.000ms =168.670
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	geom_centroid = t2.geom_centroid
FROM    (
	SELECT	la.uid AS uid,
		ST_Centroid(la.geom) AS geom_centroid
	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la	
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;

-- "Create Index GIST (geom_centroid)"   (OK!) -> 8.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_buffer100_unbuffer_geom_centroid_idx
    ON    	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
    USING     	GIST (geom_centroid);

---------- ---------- ----------

-- "Update Buffer [100m]"   (OK!) -> 80.000ms =168.670
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	geom_buffer = t2.geom_buffer
FROM    (
	SELECT	la.uid AS uid,
		ST_BUFFER(ST_TRANSFORM(la.geom,3035), 100) AS geom_buffer
	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la	
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;

-- "Create Index GIST (geom_buffer)"   (OK!) -> 14.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_buffer100_unbuffer_geom_buffer_idx
    ON    	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
    USING     	GIST (geom_buffer);


-- ---------- ---------- ----------
-- -- Check geoms
-- ---------- ---------- ----------
-- 
-- -- Check geom (OK!) -> 20.000ms =0
-- SELECT	test.uid,
-- 	test.error,
-- 	reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 	location(ST_IsValidDetail(test.geom)) AS error_location,
-- 	test.geom
-- FROM	(
-- 	SELECT	lg.uid AS uid,
-- 		ST_IsValid(lg.geom) AS error,
-- 		lg.geom AS geom
-- 	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS lg
-- 	) AS test
-- WHERE	test.error = FALSE;
-- 
-- -- Check geom_buffer (OK!) -> 32.000ms =0
-- SELECT	test.uid,
-- 	test.error,
-- 	reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 	location(ST_IsValidDetail(test.geom)) AS error_location,
-- 	test.geom
-- FROM	(
-- 	SELECT	lg.uid AS uid,
-- 		ST_IsValid(lg.geom_buffer) AS error,
-- 		lg.geom_buffer AS geom
-- 	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS lg
-- 	) AS test
-- WHERE	test.error = FALSE;


---------- ---------- ----------
-- "Calculate Zensus2011 Population"
---------- ---------- ----------

-- -- Zensus SPF ohne population '-1' (OK!) -> 7.500ms =3.177.723
-- DROP MATERIALIZED VIEW IF EXISTS	orig_destatis.zensus_population_per_ha_mview;
-- CREATE MATERIALIZED VIEW		orig_destatis.zensus_population_per_ha_mview AS
-- 	SELECT	pts.*
-- 	FROM	orig_destatis.zensus_population_per_ha AS pts
-- 	WHERE	population > '-1';

-- -- CALC POP (OK!) ms =
-- DROP TABLE IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff_catch_zensus;
-- CREATE TABLE 		orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff_catch_zensus AS
-- 	SELECT	lg.uid AS uid,
-- 		SUM(pts.population)::integer AS zensus_sum,
-- 		COUNT(pts.geom)::integer AS zensus_count,
-- 		(SUM(pts.population)/COUNT(pts.geom))::numeric AS zensus_density
-- 	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff AS lg,
-- 		orig_destatis.zensus_population_per_ha_mview AS pts
-- 	WHERE  	ST_TRANSFORM(lg.geom_buffer,3035) && ST_TRANSFORM(pts.geom,3035) AND 
-- 		ST_CONTAINS(ST_TRANSFORM(lg.geom_buffer,3035),ST_TRANSFORM(pts.geom,3035))
-- 	GROUP BY lg.uid;
-- 
-- -- UPDATE counts (OK!) -> ms =
-- UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff AS t1
-- SET  	zensus_sum = t2.zensus_sum,
-- 	zensus_count = t2.zensus_count,
-- 	zensus_density = t2.zensus_density
-- FROM    orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff_catch_zensus AS t2
-- JOIN    orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff USING (uid)
-- WHERE  	t1.uid = t2.uid;

-- "Zensus2011 Population"   (OK!) -> 166.000ms =140.604
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	zensus_sum = t2.zensus_sum,
	zensus_count = t2.zensus_count,
	zensus_density = t2.zensus_density
FROM    (SELECT	la.uid AS uid,
		SUM(pts.population)::integer AS zensus_sum,
		COUNT(pts.geom)::integer AS zensus_count,
		(SUM(pts.population)/COUNT(pts.geom))::numeric AS zensus_density
	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la,
		orig_destatis.zensus_population_per_ha_mview AS pts
	WHERE  	la.geom_buffer && pts.geom AND
		ST_CONTAINS(la.geom_buffer,pts.geom)
	GROUP BY la.uid
	)AS t2
WHERE  	t1.uid = t2.uid;


---------- ---------- ----------
-- "Calculate IÖR Industry Share"
---------- ---------- ----------

-- -- CALC IOER (OK!) ms =
-- DROP TABLE IF EXISTS	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff_catch_ioer;
-- CREATE TABLE 		orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff_catch_ioer AS
-- 	SELECT	lg.uid AS uid,
-- 		SUM(pts.ioer_share) AS ioer_sum,
-- 		COUNT(pts.geom)::integer AS ioer_count,
-- 		(SUM(pts.ioer_share)/COUNT(pts.geom))::numeric AS ioer_density
-- 	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff AS lg,
-- 		orig_ioer.ioer_urban_share_industrial_centroid AS pts
-- 	WHERE  	ST_TRANSFORM(lg.geom_buffer,3035) && ST_TRANSFORM(pts.geom,3035) AND 
-- 		ST_CONTAINS(ST_TRANSFORM(lg.geom_buffer,3035),ST_TRANSFORM(pts.geom,3035))
-- 	GROUP BY lg.uid;
--  
-- -- UPDATE counts (OK!) -> ms =
-- UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff AS t1
-- SET  	ioer_sum = t2.ioer_sum,
-- 	ioer_count = t2.ioer_count,
-- 	ioer_density = t2.ioer_density
-- FROM    orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff_catch_ioer AS t2
-- JOIN    orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff USING (uid)
-- WHERE  	t1.uid = t2.uid;

-- "IÖR Industry Share"   (OK!) -> 84.000ms =47.774
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	ioer_sum = t2.ioer_sum,
	ioer_count = t2.ioer_count,
	ioer_density = t2.ioer_density
FROM    (SELECT	la.uid AS uid,
		SUM(pts.ioer_share) AS ioer_sum,
		COUNT(pts.geom)::integer AS ioer_count,
		(SUM(pts.ioer_share)/COUNT(pts.geom))::numeric AS ioer_density
	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la,
		orig_ioer.ioer_urban_share_industrial_centroid AS pts
	WHERE  	la.geom_buffer && pts.geom AND
		ST_CONTAINS(la.geom_buffer,pts.geom)
	GROUP BY la.uid
	)AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------
-- "Calculate Sectors"
---------- ---------- ----------

-- -- UPDATE area_lg (OK!) -> 100ms :812
-- UPDATE 	orig_geo_rli_spf.rli_deu_lastgebiete_spf_buffer100_unbuff AS t1
-- SET  	area_lg = t2.area
-- FROM    (
-- 	SELECT	lg.uid,
-- 		ST_AREA(ST_TRANSFORM(lg.geom,3035))/10000 AS area
-- 	FROM	orig_geo_rli_spf.rli_deu_lastgebiete_spf_buffer100_unbuff AS lg
-- 	ORDER BY lg.uid
-- 	) AS t2
-- JOIN    orig_geo_rli_spf.rli_deu_lastgebiete_spf_buffer100_unbuff USING (uid)
-- WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate Sector Residential"   (OK!) -> 70.000ms =111.340
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	sector_area_residential = t2.sector_area,
	sector_count_residential = t2.sector_count,
	sector_share_residential = t2.sector_area / t2.area_ha
FROM    (
	SELECT	la.uid AS uid,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		la.area_ha AS area_ha
	FROM	orig_geo_rli.osm_deu_polygon_urban_sector_1_residential_mview AS sector,
		orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la	
	WHERE  	la.geom_buffer && sector.geom AND  
		ST_CONTAINS(la.geom_buffer,sector.geom)
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate Sector Retail"   (OK!) -> 177.000ms =10.157
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	sector_area_retail = t2.sector_area,
	sector_count_retail = t2.sector_count,
	sector_share_retail = t2.sector_area / t2.area_ha
FROM    (
	SELECT	la.uid AS uid,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		la.area_ha AS area_ha
	FROM	orig_geo_rli.osm_deu_polygon_urban_sector_2_retail_mview AS sector,
		orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la	
	WHERE  	la.geom_buffer && sector.geom AND
		ST_CONTAINS(la.geom_buffer,sector.geom)
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate Sector Industrial"   (OK!) -> 35.000ms =21.033
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	sector_area_industrial = t2.sector_area,
	sector_count_industrial = t2.sector_count,
	sector_share_industrial = t2.sector_area / t2.area_ha
FROM    (
	SELECT	la.uid AS uid,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		la.area_ha AS area_ha
	FROM	orig_geo_rli.osm_deu_polygon_urban_sector_3_industrial_mview AS sector,
		orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la	
	WHERE  	la.geom_buffer && sector.geom AND
		ST_CONTAINS(la.geom_buffer,sector.geom)
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate Sector Agricultural"   (OK!) -> 203.000ms =71.358
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	sector_area_agricultural = t2.sector_area,
	sector_count_agricultural = t2.sector_count,
	sector_share_agricultural = t2.sector_area / t2.area_ha
FROM    (
	SELECT	la.uid AS uid,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		la.area_ha AS area_ha
	FROM	orig_geo_rli.osm_deu_polygon_urban_sector_4_agricultural_mview AS sector,
		orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la	
	WHERE  	la.geom_buffer && sector.geom AND
		ST_CONTAINS(la.geom_buffer,sector.geom)
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;


---------- ---------- ----------
-- "Calculate Codes"
---------- ---------- ----------

-- "Transform VG250"   (OK!) -> 2.000ms =11.438
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_vg250.vg250_6_gem_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_vg250.vg250_6_gem_mview AS
	SELECT	vg.gid,
		vg.gen,
		vg.nuts,
		vg.rs,
		ags_0,
		ST_TRANSFORM(vg.geom,3035) AS geom
	FROM	orig_geo_vg250.vg250_6_gem AS vg
	ORDER BY vg.gid;

-- "Create Index GIST (geom)"   (OK!) -> 150ms =0
CREATE INDEX  	vg250_6_gem_mview_geom_idx
	ON	orig_geo_vg250.vg250_6_gem_mview
	USING	GIST (geom);

---------- ---------- ----------

-- "Calculate NUTS"   (OK!) -> 94.458ms =168.095
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	nuts = t2.nuts
FROM    (
	SELECT	la.uid AS uid,
		vg.nuts AS nuts
	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && la.geom_surfacepoint AND
		ST_CONTAINS(vg.geom,la.geom_surfacepoint)
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate Regionalschlüssel"   (OK!) -> 98.404ms =168.095
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	rs = t2.rs
FROM    (
	SELECT	la.uid AS uid,
		vg.rs AS rs
	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && la.geom_surfacepoint AND
		ST_CONTAINS(vg.geom,la.geom_surfacepoint)
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate Gemeindeschlüssel"   (OK!) -> 220.000ms =168.095
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	ags_0 = t2.ags_0
FROM    (
	SELECT	la.uid AS uid,
		vg.ags_0 AS ags_0
	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && la.geom_surfacepoint AND
		ST_CONTAINS(vg.geom,la.geom_surfacepoint)
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate MV-Key"   (OK!) -> 112.000ms =168.537
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	mv_poly_id = t2.mv_poly_id
FROM    (
	SELECT	la.uid AS uid,
		mv.id AS mv_poly_id
	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la,
		calc_gridcells_znes.znes_deu_gridcells_qgis AS mv
	WHERE  	ST_TRANSFORM(mv.geom,3035) && la.geom_surfacepoint AND
		ST_CONTAINS(ST_TRANSFORM(mv.geom,3035),la.geom_surfacepoint)
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------
-- "Set Zeros"
---------- ---------- ----------

-- "Add NULL"   (OK!) -> 4.000ms =28.066
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
SET	zensus_sum 	= 0
WHERE	zensus_sum 	IS NULL;

-- "Add NULL"   (OK!) ->  10.000ms =28.066
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
SET	zensus_count 	= 0
WHERE	zensus_count 	IS NULL;

-- "Add NULL"   (OK!) ->  11.000ms =28.066
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
SET	zensus_density 	= 0
WHERE	zensus_density 	IS NULL;

---------- ---------- ----------

-- "Add NULL"   (OK!) ->  19.000ms =120.896
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
SET	ioer_sum 	= 0
WHERE	ioer_sum 	IS NULL;

-- "Add NULL"   (OK!) ->  21.000ms =120.896
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
SET	ioer_count 	= 0
WHERE	ioer_count 	IS NULL;

-- "Add NULL"   (OK!) ->  22.000ms =120.896
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
SET	ioer_density 	= 0
WHERE	ioer_density 	IS NULL;

---------- ---------- ----------

-- "Add NULL"   (OK!) ->  16.000ms =57.330
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_share_residential 	= 0
WHERE	sector_share_residential 	IS NULL;

-- "Add NULL"   (OK!) ->  39.000ms =158.513
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_share_retail 	= 0
WHERE	sector_share_retail 	IS NULL;

-- "Add NULL"   (OK!) ->  43.000ms =147.637
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_share_industrial 	= 0
WHERE	sector_share_industrial 	IS NULL;

-- "Add NULL"   (OK!) ->  54.000ms =168.670
UPDATE 	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_share_agricultural 	= 0
WHERE	sector_share_agricultural 	IS NULL;


---------- ---------- ---------- ---------- ---------- ----------
-- "Write Results"
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 18.000ms =168.670
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_loadarea CASCADE;
CREATE TABLE 		orig_geo_rli.rli_deu_loadarea AS
	SELECT	la.*
	FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuffer AS la
ORDER BY 	la.uid;

-- "Add ID (la_id)"   (OK!) 16.000ms =0
ALTER TABLE 	orig_geo_rli.rli_deu_loadarea
	ADD COLUMN la_id SERIAL;

-- "Set PK (la_id)"   (OK!) 600ms =0
ALTER TABLE 	orig_geo_rli.rli_deu_loadarea
	ADD PRIMARY KEY (la_id);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_rli.rli_deu_loadarea TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_rli.rli_deu_loadarea OWNER TO oeuser;

-- "Create Index GIST (geom)"   (OK!) -> 2.000ms =0
CREATE INDEX  	rli_deu_loadarea_geom_idx
    ON    	orig_geo_rli.rli_deu_loadarea
    USING     	GIST (geom);

-- "Create Index GIST (geom_surfacepoint)"   (OK!) -> 2.000ms =0
CREATE INDEX  	rli_deu_loadarea_geom_surfacepoint_idx
    ON    	orig_geo_rli.rli_deu_loadarea
    USING     	GIST (geom_surfacepoint);

-- "Create Index GIST (geom_centroid)"   (OK!) -> 2.000ms =0
CREATE INDEX  	rli_deu_loadarea_geom_centroid_idx
    ON    	orig_geo_rli.rli_deu_loadarea
    USING     	GIST (geom_centroid);

-- "Create Index GIST (geom_buffer)"   (OK!) -> 2.000ms =0
CREATE INDEX  	rli_deu_loadarea_geom_buffer_idx
    ON    	orig_geo_rli.rli_deu_loadarea
    USING     	GIST (geom_buffer);


---------- ---------- ----------
-- "Create SPF"
---------- ---------- ----------

-- "Create Table SPF"   (OK!) 1.000ms =796
DROP TABLE IF EXISTS  	orig_geo_rli.rli_deu_loadarea_spf;
CREATE TABLE         	orig_geo_rli.rli_deu_loadarea_spf AS
	SELECT	la.*
	FROM	orig_geo_rli.rli_deu_loadarea AS la
	WHERE	nuts='DE27C' OR nuts='DE274';

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	orig_geo_rli.rli_deu_loadarea_spf
	ADD PRIMARY KEY (la_id);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_rli.rli_deu_loadarea_spf TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_rli.rli_deu_loadarea_spf OWNER TO oeuser;

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	rli_deu_loadarea_spf_geom_idx
	ON	orig_geo_rli.rli_deu_loadarea_spf
	USING	GIST (geom);

-- "Create Index GIST (geom_surfacepoint)"   (OK!) -> 150ms =0
CREATE INDEX  	rli_deu_loadarea_spf_geom_surfacepoint_idx
    ON    	orig_geo_rli.rli_deu_loadarea_spf
    USING     	GIST (geom_surfacepoint);

-- "Create Index GIST (geom_centroid)"   (OK!) -> 150ms =0
CREATE INDEX  	rli_deu_loadarea_spf_geom_centroid_idx
    ON    	orig_geo_rli.rli_deu_loadarea_spf
    USING     	GIST (geom_centroid);

-- "Create Index GIST (geom_buffer)"   (OK!) -> 150ms =0
CREATE INDEX  	rli_deu_loadarea_spf_geom_buffer_idx
    ON    	orig_geo_rli.rli_deu_loadarea_spf
    USING     	GIST (geom_buffer);

-- "Update Consumption"   (OK!) -> 112.000ms =168.537
UPDATE 	orig_geo_rli.rli_deu_loadarea_spf AS t1
SET  	sector_consumption_residential = t2.sector_consumption_residential,
	sector_consumption_retail = t2.sector_consumption_retail,
	sector_consumption_industrial = t2.sector_consumption_industrial,
	sector_consumption_agricultural = t2.sector_consumption_agricultural
FROM    orig_geo_rli.rli_deu_consumption_spf AS t2
WHERE  	t1.la_id = t2.la_id;


---------- ---------- ---------- ---------- ---------- ----------
-- "Load Area Processing"
---------- ---------- ---------- ---------- ---------- ----------

-- "Load Areas In Germany"   (OK!) -> 500ms =575
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.rli_deu_loadarea_check_germany_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_rli.rli_deu_loadarea_check_germany_mview AS
	SELECT	la.la_id,
		la.area_ha,
		la.geom_buffer
	FROM	orig_geo_rli.rli_deu_loadarea AS la
	WHERE	la.nuts IS NULL;

-- "Remove Load Areas Outside Germany"   (OK!) 700ms =575
DELETE FROM	orig_geo_rli.rli_deu_loadarea AS la
	WHERE	la.nuts IS NULL;

---------- ---------- ----------

-- "Residential Combination"   (OK!) -> 500ms =29.180
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.rli_deu_loadarea_check_res_combination_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_rli.rli_deu_loadarea_check_res_combination_mview AS
	SELECT	la.la_id,
		la.zensus_sum,
		la.zensus_count,
		la.zensus_density,
		la.area_ha,
		la.ioer_sum,
		la.geom_buffer
	FROM	orig_geo_rli.rli_deu_loadarea AS la
	WHERE	(la.sector_area_retail IS NULL AND
		la.sector_area_industrial IS NULL AND
		la.sector_area_agricultural IS NULL) AND
		la.ioer_sum = 0 AND
		la.area_ha < 1;

-- "Remove Residential Combination"   (OK!) 2.500ms =29.180
DELETE FROM	orig_geo_rli.rli_deu_loadarea AS la
	WHERE	(la.sector_area_retail IS NULL AND
		la.sector_area_industrial IS NULL AND
		la.sector_area_agricultural IS NULL) AND
		la.ioer_sum = 0 AND
		la.area_ha < 1;

---------- ---------- ---------- ---------- ---------- ----------
-- "Consumption (Ilka)"
---------- ---------- ---------- ---------- ---------- ----------

CREATE TABLE orig_geo_rli.rli_deu_consumption_spf AS
	SELECT	la_id,
		sector_consumption_residential,
		sector_consumption_retail,
		sector_consumption_industrial,
		sector_consumption_agricultural
	FROM	orig_geo_rli.rli_deu_loadarea;

ALTER TABLE orig_geo_rli.rli_deu_consumption_spf
	ADD PRIMARY KEY (la_id);