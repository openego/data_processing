





---------- ---------- ---------- ---------- ---------- ----------
-- "Fehlerbehebung"
---------- ---------- ---------- ---------- ---------- ----------
-- 
-- -- LG Fehler (OK!) 13.000ms =950
-- DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.rli_deu_lastgebiete_fehler;
-- CREATE MATERIALIZED VIEW 		orig_geo_ego.rli_deu_lastgebiete_fehler AS 
-- 	SELECT 	lg.*		
-- 	FROM 	orig_geo_ego.rli_deu_lastgebiete AS lg
-- 	WHERE	lg.area_lg < 0.01
-- 
-- -- Delete Errors from LG (OK!) 100ms =950
-- DELETE FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuff AS lg
-- 	WHERE	lg.area_lg < 0.01;
-- 
-- -- Validate geoms (OK!) 20.000ms =157
-- DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.rli_deu_lastgebiete_fehler_2;
-- CREATE MATERIALIZED VIEW 		orig_geo_ego.rli_deu_lastgebiete_fehler_2 AS 
-- 	SELECT	test.uid,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		location(ST_IsValidDetail(test.geom)) AS error_location,
-- 		test.geom
-- 	FROM	(
-- 		SELECT	lg.uid AS uid,
-- 			ST_IsValid(lg.geom) AS error,
-- 			lg.geom AS geom
-- 		FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuff AS lg
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Fix geoms (OK!) 8.000ms =157
-- DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.rli_deu_lastgebiete_fehler_2_fix;
-- CREATE MATERIALIZED VIEW 		orig_geo_ego.rli_deu_lastgebiete_fehler_2_fix AS 
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
-- 		FROM	orig_geo_ego.rli_deu_lastgebiete_fehler_2 AS fehler
-- 		) AS fix
-- 	WHERE	ST_AREA(fix.geom) > 0.4
-- 	ORDER BY fix.uid;
-- 
-- 
-- -- Update Fixed geoms (OK!) 1.000ms =157
-- UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuff AS t1
-- SET	geom = t2.geom
-- FROM	(
-- 	SELECT	fix.uid AS uid,
-- 		fix.geom AS geom,
-- 		fix.geom_type AS geom_type
-- 	FROM	orig_geo_ego.rli_deu_lastgebiete_fehler_2_fix AS fix
-- 	) AS t2
-- JOIN	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuff USING (uid)
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
-- 	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuff AS lg
-- 	) AS test
-- WHERE	test.error = FALSE;
	
---------- ---------- ---------- ---------- ---------- ----------
-- "Calculate"
---------- ---------- ---------- ---------- ---------- ----------

---------- ---------- ----------
-- "Geometries"
---------- ---------- ----------

-- "Update PointOnSurface"   (OK!) -> 35.000ms =168.205
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	geom_surfacepoint = t2.geom_surfacepoint
FROM    (
	SELECT	la.uid AS uid,
		ST_PointOnSurface(la.geom) AS geom_surfacepoint
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;

-- "Create Index GIST (geom_surfacepoint)"   (OK!) ->  10.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_buffer100_unbuffer_geom_surfacepoint_idx
    ON    	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
    USING     	GIST (geom_surfacepoint);

---------- ---------- ----------

-- "Update Centroid"   (OK!) -> 18.000ms =168.670
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	geom_centroid = t2.geom_centroid
FROM    (
	SELECT	la.uid AS uid,
		ST_Centroid(la.geom) AS geom_centroid
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la	
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;

-- "Create Index GIST (geom_centroid)"   (OK!) -> 8.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_buffer100_unbuffer_geom_centroid_idx
    ON    	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
    USING     	GIST (geom_centroid);

---------- ---------- ----------

-- "Update Buffer (100m)"   (OK!) -> 100.000ms =168.205
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	geom_buffer = t2.geom_buffer
FROM    (
	SELECT	la.uid AS uid,
		ST_BUFFER(ST_TRANSFORM(la.geom,3035), 100) AS geom_buffer
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la	
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;

-- "Create Index GIST (geom_buffer)"   (OK!) -> 4.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_buffer100_unbuffer_geom_buffer_idx
    ON    	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
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
-- 	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS lg
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
-- 	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS lg
-- 	) AS test
-- WHERE	test.error = FALSE;


---------- ---------- ----------
-- "Calculate Zensus2011 Population"
---------- ---------- ----------

-- "Zensus2011 Population"   (OK!) -> 142.000ms =141.973
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	zensus_sum = t2.zensus_sum,
	zensus_count = t2.zensus_count,
	zensus_density = t2.zensus_density
FROM    (SELECT	la.uid AS uid,
		SUM(pts.population)::integer AS zensus_sum,
		COUNT(pts.geom)::integer AS zensus_count,
		(SUM(pts.population)/COUNT(pts.geom))::numeric AS zensus_density
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la,
		orig_destatis.zensus_population_per_ha_mview AS pts
	WHERE  	la.geom_buffer && pts.geom AND
		ST_CONTAINS(la.geom_buffer,pts.geom)
	GROUP BY la.uid
	)AS t2
WHERE  	t1.uid = t2.uid;


---------- ---------- ----------
-- "Calculate IÖR Industry Share"
---------- ---------- ----------

-- "IÖR Industry Share"   (OK!) -> 60.000ms =51,052
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	ioer_sum = t2.ioer_sum,
	ioer_count = t2.ioer_count,
	ioer_density = t2.ioer_density
FROM    (SELECT	la.uid AS uid,
		SUM(pts.ioer_share)/100::numeric AS ioer_sum,
		COUNT(pts.geom)::integer AS ioer_count,
		(SUM(pts.ioer_share)/COUNT(pts.geom))::numeric AS ioer_density
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la,
		orig_ioer.ioer_urban_share_industrial_centroid AS pts
	WHERE  	la.geom_buffer && pts.geom AND
		ST_CONTAINS(la.geom_buffer,pts.geom)
	GROUP BY la.uid
	)AS t2
WHERE  	t1.uid = t2.uid;


---------- ---------- ----------
-- "Calculate Sectors"
---------- ---------- ----------

-- "Calculate Sector Residential"   (OK!) -> 740.000ms =111.028
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	sector_area_residential = t2.sector_area,
	sector_count_residential = t2.sector_count,
	sector_share_residential = t2.sector_area / t2.area_ha
FROM    (
	SELECT	la.uid AS uid,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		la.area_ha AS area_ha
	FROM	orig_geo_ego.osm_deu_polygon_urban_sector_1_residential_mview AS sector,
		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la	
	WHERE  	la.geom_buffer && sector.geom AND  
		ST_CONTAINS(la.geom_buffer,sector.geom)
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate Sector Retail"   (OK!) -> 156.000ms =10.095
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	sector_area_retail = t2.sector_area,
	sector_count_retail = t2.sector_count,
	sector_share_retail = t2.sector_area / t2.area_ha
FROM    (
	SELECT	la.uid AS uid,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		la.area_ha AS area_ha
	FROM	orig_geo_ego.osm_deu_polygon_urban_sector_2_retail_mview AS sector,
		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la	
	WHERE  	la.geom_buffer && sector.geom AND
		ST_CONTAINS(la.geom_buffer,sector.geom)
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate Sector Industrial"   (OK!) -> 155.000ms =20.936
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	sector_area_industrial = t2.sector_area,
	sector_count_industrial = t2.sector_count,
	sector_share_industrial = t2.sector_area / t2.area_ha
FROM    (
	SELECT	la.uid AS uid,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		la.area_ha AS area_ha
	FROM	orig_geo_ego.osm_deu_polygon_urban_sector_3_industrial_mview AS sector,
		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la	
	WHERE  	la.geom_buffer && sector.geom AND
		ST_CONTAINS(la.geom_buffer,sector.geom)
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate Sector Agricultural"   (OK!) -> 200.000ms =71.248
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	sector_area_agricultural = t2.sector_area,
	sector_count_agricultural = t2.sector_count,
	sector_share_agricultural = t2.sector_area / t2.area_ha
FROM    (
	SELECT	la.uid AS uid,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		la.area_ha AS area_ha
	FROM	orig_geo_ego.osm_deu_polygon_urban_sector_4_agricultural_mview AS sector,
		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la	
	WHERE  	la.geom_buffer && sector.geom AND
		ST_CONTAINS(la.geom_buffer,sector.geom)
	GROUP BY la.uid
	) AS t2
WHERE  	t1.uid = t2.uid;


---------- ---------- ----------
-- "Calculate Codes"
---------- ---------- ----------

-- "Calculate NUTS"   (OK!) -> 94.458ms =168.095
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	nuts = t2.nuts
FROM    (
	SELECT	la.uid AS uid,
		vg.nuts AS nuts
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && la.geom_surfacepoint AND
		ST_CONTAINS(vg.geom,la.geom_surfacepoint)
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate Regionalschlüssel"   (OK!) -> 98.404ms =168.095
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	rs = t2.rs
FROM    (
	SELECT	la.uid AS uid,
		vg.rs AS rs
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && la.geom_surfacepoint AND
		ST_CONTAINS(vg.geom,la.geom_surfacepoint)
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate Gemeindeschlüssel"   (OK!) -> 220.000ms =168.095
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	ags_0 = t2.ags_0
FROM    (
	SELECT	la.uid AS uid,
		vg.ags_0 AS ags_0
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && la.geom_surfacepoint AND
		ST_CONTAINS(vg.geom,la.geom_surfacepoint)
	) AS t2
WHERE  	t1.uid = t2.uid;

---------- ---------- ----------

-- "Calculate MV-Key"   (OK!) -> 112.000ms =168.537
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	mv_poly_id = t2.mv_poly_id
FROM    (
	SELECT	la.uid AS uid,
		mv.id AS mv_poly_id
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la,
		calc_gridcells_znes.znes_deu_gridcells_qgis AS mv
	WHERE  	ST_TRANSFORM(mv.geom,3035) && la.geom_surfacepoint AND
		ST_CONTAINS(ST_TRANSFORM(mv.geom,3035),la.geom_surfacepoint)
	) AS t2
WHERE  	t1.uid = t2.uid;


---------- ---------- ---------- ---------- ---------- ----------
-- "Criterion for Exclusion"
---------- ---------- ---------- ---------- ---------- ----------
-- 
-- -- "Areas Outside Germany"   (OK!) -> 500ms =575
-- DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_check_germany_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_check_germany_mview AS
-- 	SELECT	la.uid,
-- 		la.area_ha,
-- 		la.geom_buffer
-- 	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- 	WHERE	la.nuts IS NULL;
-- 
-- -- "Remove Areas Outside Germany"   (OK!) 700ms =575
-- DELETE FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- 	WHERE	la.nuts IS NULL;
-- 
-- -- "Create Index GIST (geom_buffer)"   (OK!) -> 150ms =0
-- CREATE INDEX  	osm_deu_polygon_urban_buffer100_unbuffer_check_germany_mview_geom_buffer_idx
--     ON    	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_check_germany_mview
--     USING     	GIST (geom_buffer);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_check_germany_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_check_germany_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Residential Combination"   (OK!) -> 500ms =28.647
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_check_res_combination_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_check_res_combination_mview AS
	SELECT	la.uid,
		la.zensus_sum,
		la.zensus_count,
		la.zensus_density,
		la.area_ha,
		la.ioer_sum,
		la.geom_buffer
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la
	WHERE	(la.sector_area_retail IS NULL AND
		la.sector_area_industrial IS NULL AND
		la.sector_area_agricultural IS NULL) AND
		la.ioer_sum = 0 AND
		la.area_ha < 1;

-- "Create Index GIST (geom_buffer)"   (OK!) -> 150ms =0
CREATE INDEX  	eosm_deu_polygon_urban_buffer100_unbuffer_check_res_combination_mview_geom_buffer_idx
    ON    	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_check_res_combination_mview
    USING     	GIST (geom_buffer);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_check_res_combination_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_check_res_combination_mview OWNER TO oeuser;

-- "Remove Residential Combination"   (OK!) 2.500ms =28.647
DELETE FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la
	WHERE	(la.sector_area_retail IS NULL AND
		la.sector_area_industrial IS NULL AND
		la.sector_area_agricultural IS NULL) AND
		la.ioer_sum = 0 AND
		la.area_ha < 1;


---------- ---------- ----------
-- "Set Zeros"
---------- ---------- ----------

---------- ---------- ---------- zensus

-- "Add NULL"   (OK!) -> 4.000ms =28.066
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	zensus_sum 	= 0
WHERE	zensus_sum 	IS NULL;

-- "Add NULL"   (OK!) ->  10.000ms =28.066
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	zensus_count 	= 0
WHERE	zensus_count 	IS NULL;

-- "Add NULL"   (OK!) ->  11.000ms =28.066
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	zensus_density 	= 0
WHERE	zensus_density 	IS NULL;

---------- ---------- ---------- ioer

-- "Add NULL"   (OK!) ->  19.000ms =120.896
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	ioer_sum 	= 0
WHERE	ioer_sum 	IS NULL;

-- "Add NULL"   (OK!) ->  21.000ms =120.896
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	ioer_count 	= 0
WHERE	ioer_count 	IS NULL;

-- "Add NULL"   (OK!) ->  22.000ms =120.896
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	ioer_density 	= 0
WHERE	ioer_density 	IS NULL;

---------- ---------- ---------- area

-- "Add NULL"   (OK!) ->  18.000ms =57.131
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_area_residential 	= 0
WHERE	sector_area_residential 	IS NULL;

-- "Add NULL"   (OK!) ->  43.000ms =129.356
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_area_retail 	= 0
WHERE	sector_area_retail 	IS NULL;

-- "Add NULL"   (OK!) ->  45.000ms =118.526
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_area_industrial 	= 0
WHERE	sector_area_industrial 	IS NULL;

-- "Add NULL"   (OK!) ->  32.000ms =68.215
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_area_agricultural 	= 0
WHERE	sector_area_agricultural 	IS NULL;

---------- ---------- ---------- share

-- "Add NULL"   (OK!) ->  16.000ms =57.131
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_share_residential 	= 0
WHERE	sector_share_residential 	IS NULL;

-- "Add NULL"   (OK!) ->  39.000ms =129.356
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_share_retail 	= 0
WHERE	sector_share_retail 	IS NULL;

-- "Add NULL"   (OK!) ->  43.000ms =118.526
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_share_industrial 	= 0
WHERE	sector_share_industrial 	IS NULL;

-- "Add NULL"   (OK!) ->  54.000ms =68.215
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_share_agricultural 	= 0
WHERE	sector_share_agricultural 	IS NULL;

---------- ---------- ---------- count

-- "Add NULL"   (OK!) ->  17.000ms =57.131
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_count_residential 	= 0
WHERE	sector_count_residential 	IS NULL;

-- "Add NULL"   (OK!) ->  43.000ms =129.356
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_count_retail 	= 0
WHERE	sector_count_retail 	IS NULL;

-- "Add NULL"   (OK!) ->  43.000ms =118.526
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_count_industrial 	= 0
WHERE	sector_count_industrial 	IS NULL;

-- "Add NULL"   (OK!) ->  30.000ms =68.215
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
SET	sector_count_agricultural 	= 0
WHERE	sector_count_agricultural 	IS NULL;

---------- ---------- ---------- ---------- ---------- ----------
-- "Write Results"   2016-03-30 15:55   45s
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 20.000ms =168.670
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_osm_loadarea CASCADE;
CREATE TABLE 		orig_geo_ego.ego_deu_osm_loadarea AS
	SELECT	la.*
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la
ORDER BY 	la.uid;

-- "Add ID (la_id)"   (OK!) 13.000ms =0
ALTER TABLE 	orig_geo_ego.ego_deu_osm_loadarea
	ADD COLUMN la_id SERIAL;

-- "Set PK (la_id)"   (OK!) 600ms =0
ALTER TABLE 	orig_geo_ego.ego_deu_osm_loadarea
	ADD PRIMARY KEY (la_id);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.ego_deu_osm_loadarea TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_osm_loadarea OWNER TO oeuser;

-- "Create Index GIST (geom)"   (OK!) -> 2.000ms =0
CREATE INDEX  	ego_deu_osm_loadarea_geom_idx
    ON    	orig_geo_ego.ego_deu_osm_loadarea
    USING     	GIST (geom);

-- "Create Index GIST (geom_surfacepoint)"   (OK!) -> 2.000ms =0
CREATE INDEX  	ego_deu_osm_loadarea_geom_surfacepoint_idx
    ON    	orig_geo_ego.ego_deu_osm_loadarea
    USING     	GIST (geom_surfacepoint);

-- "Create Index GIST (geom_centroid)"   (OK!) -> 2.000ms =0
CREATE INDEX  	ego_deu_osm_loadarea_geom_centroid_idx
    ON    	orig_geo_ego.ego_deu_osm_loadarea
    USING     	GIST (geom_centroid);

-- "Create Index GIST (geom_buffer)"   (OK!) -> 2.000ms =0
CREATE INDEX  	ego_deu_osm_loadarea_geom_buffer_idx
    ON    	orig_geo_ego.ego_deu_osm_loadarea
    USING     	GIST (geom_buffer);


---------- ---------- ----------
-- "Create SPF"   2016-03-30 15:55   1s
---------- ---------- ----------

-- "Create Table SPF"   (OK!) 1.000ms =719
DROP TABLE IF EXISTS  	orig_geo_ego.ego_deu_osm_loadarea_spf;
CREATE TABLE         	orig_geo_ego.ego_deu_osm_loadarea_spf AS
	SELECT	la.*
	FROM	orig_geo_ego.ego_deu_osm_loadarea AS la
	WHERE	nuts='DE27C' OR nuts='DE274';

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	orig_geo_ego.ego_deu_osm_loadarea_spf
	ADD PRIMARY KEY (la_id);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_osm_loadarea_spf_geom_idx
	ON	orig_geo_ego.ego_deu_osm_loadarea_spf
	USING	GIST (geom);

-- "Create Index GIST (geom_surfacepoint)"   (OK!) -> 150ms =0
CREATE INDEX  	ego_deu_osm_loadarea_spf_geom_surfacepoint_idx
    ON    	orig_geo_ego.ego_deu_osm_loadarea_spf
    USING     	GIST (geom_surfacepoint);

-- "Create Index GIST (geom_centroid)"   (OK!) -> 150ms =0
CREATE INDEX  	ego_deu_osm_loadarea_spf_geom_centroid_idx
    ON    	orig_geo_ego.ego_deu_osm_loadarea_spf
    USING     	GIST (geom_centroid);

-- "Create Index GIST (geom_buffer)"   (OK!) -> 150ms =0
CREATE INDEX  	ego_deu_osm_loadarea_spf_geom_buffer_idx
    ON    	orig_geo_ego.ego_deu_osm_loadarea_spf
    USING     	GIST (geom_buffer);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.ego_deu_osm_loadarea_spf TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_osm_loadarea_spf OWNER TO oeuser;

---------- ---------- ---------- ---------- ---------- ----------
-- "Drops"
---------- ---------- ---------- ---------- ---------- ----------





---------- ---------- ---------- ---------- ---------- ----------
-- "Consumption (Ilka)"
---------- ---------- ---------- ---------- ---------- ----------

-- CREATE TABLE orig_geo_ego.znes_deu_consumption_spf AS
-- 	SELECT	la_id,
-- 		sector_consumption_residential,
-- 		sector_consumption_retail,
-- 		sector_consumption_industrial,
-- 		sector_consumption_agricultural
-- 	FROM	orig_geo_ego.ego_deu_osm_loadarea;
-- 
-- ALTER TABLE orig_geo_ego.rli_deu_consumption_spf
-- 	ADD PRIMARY KEY (la_id);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	orig_geo_ego.znes_deu_consumption_spf TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_geo_ego.znes_deu_consumption_spf OWNER TO oeuser;