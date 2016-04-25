---------- ---------- ----------
---------- --SKRIPT--    s
---------- ---------- ----------

---------- ---------- ---------- ---------- ---------- ----------
-- "2. Data Setup OSM"   2016-04-18 10:00 11s
---------- ---------- ---------- ---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 100ms =0
-- DROP VIEW IF EXISTS	orig_osm.osm_deu_polygon_error_geom_view CASCADE;
-- CREATE VIEW		orig_osm.osm_deu_polygon_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	orig_osm.osm_deu_polygon AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_osm.osm_deu_polygon_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_osm.osm_deu_polygon_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 1.581.000ms =1
-- SELECT f_drop_view('{osm_deu_polygon_error_geom_view}', 'orig_osm');

---------- ---------- ----------
-- "Filter OSM Urban Landuse"
---------- ---------- ----------

-- "Filter Urban"   (OK!) -> 35.000ms =494.696
DROP TABLE IF EXISTS	orig_osm.osm_deu_polygon_urban CASCADE;
CREATE TABLE		orig_osm.osm_deu_polygon_urban AS
	SELECT	osm.gid ::integer AS gid,
		osm.osm_id ::integer AS osm_id,
		osm.landuse ::text AS landuse,
		osm.man_made ::text AS man_made,
		osm.aeroway ::text AS aeroway,
		osm.name ::text AS name,
		osm.way_area ::double precision AS way_area,
		ST_AREA(ST_TRANSFORM(osm.geom,3035))/10000 ::double precision AS area_ha,
		osm.tags ::hstore AS tags,
		'outside' ::text AS vg250,
		ST_MULTI(ST_TRANSFORM(osm.geom,3035)) ::geometry(MultiPolygon,3035) AS geom		
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

-- "Set PK"   (OK!) -> 1.000ms =0
ALTER TABLE orig_osm.osm_deu_polygon_urban
	ADD PRIMARY KEY (gid);

-- "Create Index GIST (geom)"   (OK!) -> 6.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_geom_idx
	ON	orig_osm.osm_deu_polygon_urban
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_osm.osm_deu_polygon_urban TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_osm.osm_deu_polygon_urban OWNER TO oeuser;



---------- ---------- ----------
-- "OSM Urban Landuse Inside vg250"
---------- ---------- ----------
	
-- "Calculate 'inside' vg250"   (OK!) -> 122.000ms =492.890
UPDATE 	orig_osm.osm_deu_polygon_urban AS t1
SET  	vg250 = t2.vg250
FROM    (
	SELECT	osm.gid AS gid,
		'inside' ::text AS vg250
	FROM	orig_geo_vg250.vg250_1_sta_union_mview AS vg,
		orig_osm.osm_deu_polygon_urban AS osm
	WHERE  	vg.geom && osm.geom AND
		ST_CONTAINS(vg.geom,osm.geom)
	) AS t2
WHERE  	t1.gid = t2.gid;

---------- ---------- ----------
	
-- "Calculate 'crossing' vg250"   (OK!) -> 17.000ms =291
UPDATE 	orig_osm.osm_deu_polygon_urban AS t1
SET  	vg250 = t2.vg250
FROM    (
	SELECT	osm.gid AS gid,
		'crossing' ::text AS vg250
	FROM	orig_geo_vg250.vg250_1_sta_union_mview AS vg,
		orig_osm.osm_deu_polygon_urban AS osm
	WHERE  	osm.vg250 = 'outside' AND
		vg.geom && osm.geom AND
		ST_Overlaps(vg.geom,osm.geom)
	) AS t2
WHERE  	t1.gid = t2.gid;


---------- ---------- ----------
-- OSM outside of vg250
---------- ---------- ----------

-- "OSM error vg250"   (OK!) -> 400ms =1.806
DROP MATERIALIZED VIEW IF EXISTS	orig_osm.osm_deu_polygon_urban_error_geom_vg250_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_osm.osm_deu_polygon_urban_error_geom_vg250_mview AS
	SELECT	osm.*
	FROM	orig_osm.osm_deu_polygon_urban AS osm
	WHERE	osm.vg250 = 'outside' OR osm.vg250 = 'crossing';

-- "Create Index (gid)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_error_geom_vg250_mview_gid_idx
		ON	orig_osm.osm_deu_polygon_urban_error_geom_vg250_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 150ms =0
CREATE INDEX  	osm_deu_polygon_urban_error_geom_vg250_mview_geom_idx
	ON	orig_osm.osm_deu_polygon_urban_error_geom_vg250_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_osm.osm_deu_polygon_urban_error_geom_vg250_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_osm.osm_deu_polygon_urban_error_geom_vg250_mview OWNER TO oeuser;	

---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_osm.osm_deu_polygon_urban_vg250_cut_mview_id CASCADE;
CREATE SEQUENCE 		orig_osm.osm_deu_polygon_urban_vg250_cut_mview_id;

-- "Cutting 'crossing' with vg250"   (OK!) 12.000ms =291
DROP MATERIALIZED VIEW IF EXISTS	orig_osm.osm_deu_polygon_urban_vg250_cut_mview;
CREATE MATERIALIZED VIEW		orig_osm.osm_deu_polygon_urban_vg250_cut_mview AS
	SELECT	nextval('orig_osm.osm_deu_polygon_urban_vg250_cut_mview_id') ::integer AS id,
		cut.gid ::integer AS gid,
		cut.osm_id ::integer AS osm_id,
		cut.landuse ::text AS landuse,
		cut.man_made ::text AS man_made,
		cut.aeroway ::text AS aeroway,
		cut.name ::text AS name,
		cut.way_area ::double precision AS way_area,
		cut.area_ha ::double precision AS area_ha,
		cut.tags ::hstore AS tags,
		cut.vg250 ::text AS vg250,
		GeometryType(cut.geom_new) ::text AS geom_type,
		ST_MULTI(ST_TRANSFORM(cut.geom_new,3035)) ::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT	poly.*,
			ST_INTERSECTION(poly.geom,cut.geom) AS geom_new
		FROM	orig_osm.osm_deu_polygon_urban_error_geom_vg250_mview AS poly,
			orig_geo_vg250.vg250_1_sta_union_mview AS cut
		WHERE	poly.vg250 = 'crossing'
		) AS cut
	ORDER BY 	cut.gid;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_vg250_cut_mview_gid_idx
		ON	orig_osm.osm_deu_polygon_urban_vg250_cut_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	osm_deu_polygon_urban_vg250_cut_mview_geom_idx
	ON	orig_osm.osm_deu_polygon_urban_vg250_cut_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_osm.osm_deu_polygon_urban_vg250_cut_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_osm.osm_deu_polygon_urban_vg250_cut_mview OWNER TO oeuser;

-- Find double entries (OK!) -> =0
-- SELECT 		gid, count(*)
-- FROM 		orig_osm.osm_deu_polygon_urban_vg250_cut_mview
-- GROUP BY 	gid
-- HAVING 		count(*) > 1;

---------- ---------- ----------

-- "'crossing' Polygon to MultiPolygon"   (OK!) 1.000ms =255
DROP MATERIALIZED VIEW IF EXISTS	orig_osm.osm_deu_polygon_urban_vg250_clean_cut_multi_mview;
CREATE MATERIALIZED VIEW		orig_osm.osm_deu_polygon_urban_vg250_clean_cut_multi_mview AS
	SELECT	nextval('orig_osm.osm_deu_polygon_gid_seq'::regclass) ::integer AS gid,
		cut.osm_id ::integer AS osm_id,
		cut.landuse ::text AS landuse,
		cut.man_made ::text AS man_made,
		cut.aeroway ::text AS aeroway,
		cut.name ::text AS name,
		cut.way_area ::double precision AS way_area,
		cut.area_ha ::double precision AS area_ha,
		cut.tags ::hstore AS tags,
		cut.vg250 ::text AS vg250,
		ST_MULTI(cut.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_osm.osm_deu_polygon_urban_vg250_cut_mview AS cut
	WHERE	cut.geom_type = 'POLYGON';

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_vg250_clean_cut_multi_mview_gid_idx
		ON	orig_osm.osm_deu_polygon_urban_vg250_clean_cut_multi_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	osm_deu_polygon_urban_vg250_clean_cut_multi_mview_geom_idx
	ON	orig_osm.osm_deu_polygon_urban_vg250_clean_cut_multi_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_osm.osm_deu_polygon_urban_vg250_clean_cut_multi_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_osm.osm_deu_polygon_urban_vg250_clean_cut_multi_mview OWNER TO oeuser;

-- Find double entries (OK!) -> =0
-- SELECT 		gid, count(*)
-- FROM 		orig_osm.osm_deu_polygon_urban_vg250_clean_cut_multi_mview
-- GROUP BY 	gid
-- HAVING 		count(*) > 1;

---------- ---------- ----------

-- "clean cut"   (OK!) 100ms =36
DROP MATERIALIZED VIEW IF EXISTS	orig_osm.osm_deu_polygon_urban_vg250_clean_cut_mview;
CREATE MATERIALIZED VIEW		orig_osm.osm_deu_polygon_urban_vg250_clean_cut_mview AS
	SELECT	nextval('orig_osm.osm_deu_polygon_gid_seq'::regclass) ::integer AS gid,
		cut.osm_id ::integer AS osm_id,
		cut.landuse ::text AS landuse,
		cut.man_made ::text AS man_made,
		cut.aeroway ::text AS aeroway,
		cut.name ::text AS name,
		cut.way_area ::double precision AS way_area,
		cut.area_ha ::double precision AS area_ha,
		cut.tags ::hstore AS tags,
		cut.vg250 ::text AS vg250,
		cut.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_osm.osm_deu_polygon_urban_vg250_cut_mview AS cut
	WHERE	cut.geom_type = 'MULTIPOLYGON';

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_vg250_clean_cut_mview_gid_idx
		ON	orig_osm.osm_deu_polygon_urban_vg250_clean_cut_mview (gid);

---------- ---------- ----------

-- "Remove 'outside' vg250"   (OK!) 300ms =1515
DELETE FROM	orig_osm.osm_deu_polygon_urban AS osm
	WHERE	osm.vg250 = 'outside';

-- "Remove 'outside' vg250"   (OK!) 300ms =618
DELETE FROM	orig_osm.osm_deu_polygon_urban AS osm
	WHERE	osm.vg250 = 'crossing';

-- "Insert cut"   (OK!) 300ms =36
INSERT INTO	orig_osm.osm_deu_polygon_urban
	SELECT	clean.*
	FROM	orig_osm.osm_deu_polygon_urban_vg250_clean_cut_mview AS clean
	ORDER BY 	clean.gid;

-- "Insert cut multi"   (ungleiche spalten!) 300ms =255
INSERT INTO	orig_osm.osm_deu_polygon_urban
	SELECT	clean.*
	FROM	orig_osm.osm_deu_polygon_urban_vg250_clean_cut_multi_mview AS clean
	ORDER BY 	clean.gid;


---------- ---------- ----------
-- "(Geo) Data Validation"
---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP MATERIALIZED VIEW IF EXISTS	orig_osm.osm_deu_polygon_urban_error_geom_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_osm.osm_deu_polygon_urban_error_geom_mview AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	orig_osm.osm_deu_polygon_urban AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_osm.osm_deu_polygon_urban_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_osm.osm_deu_polygon_urban_error_geom_view OWNER TO oeuser;

---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_osm.osm_deu_polygon_urban_error_geom_view CASCADE;
-- CREATE VIEW		orig_osm.osm_deu_polygon_urban_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	orig_osm.osm_deu_polygon_urban AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_osm.osm_deu_polygon_urban_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_osm.osm_deu_polygon_urban_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{osm_deu_polygon_urban_error_geom_view}', 'orig_ego');



---------- ---------- ----------
-- "Filter by Sector"
---------- ---------- ----------

-- "Sector 1. Residential"

-- "Filter Residential"   (OK!) -> 3.000ms =276.513
DROP MATERIALIZED VIEW IF EXISTS	orig_osm.osm_deu_polygon_urban_sector_1_residential_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_osm.osm_deu_polygon_urban_sector_1_residential_mview AS
	SELECT	osm.gid ::integer AS gid,
		osm.osm_id ::integer AS osm_id,
		osm.landuse ::text AS landuse,
		osm.man_made ::text AS man_made,
		osm.aeroway ::text AS aeroway,
		osm.name ::text AS name,
		osm.way_area ::double precision AS way_area,
		osm.area_ha ::double precision AS area_ha,
		osm.tags ::hstore AS tags,
		osm.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_osm.osm_deu_polygon_urban AS osm
	WHERE	osm.landuse='residential'
ORDER BY	osm.gid;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_1_residential_mview_gid_idx
		ON	orig_osm.osm_deu_polygon_urban_sector_1_residential_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 4.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_1_residential_mview_geom_idx
	ON	orig_osm.osm_deu_polygon_urban_sector_1_residential_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_osm.osm_deu_polygon_urban_sector_1_residential_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_osm.osm_deu_polygon_urban_sector_1_residential_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Sector 2. Retail"

-- "Filter Retail"   (OK!) -> 1.000ms =35.527
DROP MATERIALIZED VIEW IF EXISTS	orig_osm.osm_deu_polygon_urban_sector_2_retail_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_osm.osm_deu_polygon_urban_sector_2_retail_mview AS
	SELECT	osm.gid ::integer AS gid,
		osm.osm_id ::integer AS osm_id,
		osm.landuse ::text AS landuse,
		osm.man_made ::text AS man_made,
		osm.aeroway ::text AS aeroway,
		osm.name ::text AS name,
		osm.way_area ::double precision AS way_area,
		osm.area_ha ::double precision AS area_ha,
		osm.tags ::hstore AS tags,
		osm.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_osm.osm_deu_polygon_urban AS osm
	WHERE	osm.landuse='commercial' OR 
		osm.landuse='retail' OR
		osm.landuse='industrial;retail'
ORDER BY	osm.gid;
    
-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_2_retail_mview_gid_idx
		ON	orig_osm.osm_deu_polygon_urban_sector_2_retail_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 1.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_2_retail_mview_geom_idx
	ON	orig_osm.osm_deu_polygon_urban_sector_2_retail_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_osm.osm_deu_polygon_urban_sector_2_retail_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_osm.osm_deu_polygon_urban_sector_2_retail_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Sector 3. Industrial"

-- "Filter Industrial"   (OK!) -> 1.000ms =58.870
DROP MATERIALIZED VIEW IF EXISTS	orig_osm.osm_deu_polygon_urban_sector_3_industrial_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_osm.osm_deu_polygon_urban_sector_3_industrial_mview AS
	SELECT	osm.gid ::integer AS gid,
		osm.osm_id ::integer AS osm_id,
		osm.landuse ::text AS landuse,
		osm.man_made ::text AS man_made,
		osm.aeroway ::text AS aeroway,
		osm.name ::text AS name,
		osm.way_area ::double precision AS way_area,
		osm.area_ha ::double precision AS area_ha,
		osm.tags ::hstore AS tags,
		osm.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_osm.osm_deu_polygon_urban AS osm
	WHERE	osm.landuse='industrial' OR 
		osm.landuse='port' OR
		osm.man_made='wastewater_plant' OR
		osm.aeroway='terminal' OR osm.aeroway='gate' OR
		osm.man_made='works'
ORDER BY	osm.gid;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_3_industrial_mview_gid_idx
		ON	orig_osm.osm_deu_polygon_urban_sector_3_industrial_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 1.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_3_industrial_mview_geom_idx
	ON	orig_osm.osm_deu_polygon_urban_sector_3_industrial_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_osm.osm_deu_polygon_urban_sector_3_industrial_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_osm.osm_deu_polygon_urban_sector_3_industrial_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Sector 4. Agricultural"

-- "Filter Agricultural"   (OK!) -> 2.000ms =122.406
DROP MATERIALIZED VIEW IF EXISTS	orig_osm.osm_deu_polygon_urban_sector_4_agricultural_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_osm.osm_deu_polygon_urban_sector_4_agricultural_mview AS
	SELECT	osm.gid ::integer AS gid,
		osm.osm_id ::integer AS osm_id,
		osm.landuse ::text AS landuse,
		osm.man_made ::text AS man_made,
		osm.aeroway ::text AS aeroway,
		osm.name ::text AS name,
		osm.way_area ::double precision AS way_area,
		osm.area_ha ::double precision AS area_ha,
		osm.tags ::hstore AS tags,
		osm.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_osm.osm_deu_polygon_urban AS osm
	WHERE	osm.landuse='farmyard' OR 
		osm.landuse='greenhouse_horticulture'
ORDER BY	osm.gid;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_4_agricultural_mview_gid_idx
		ON	orig_osm.osm_deu_polygon_urban_sector_4_agricultural_mview (gid);
    
-- "Create Index GIST (geom)"   (OK!) -> 1.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_4_agricultural_mview_geom_idx
	ON	orig_osm.osm_deu_polygon_urban_sector_4_agricultural_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_osm.osm_deu_polygon_urban_sector_4_agricultural_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_osm.osm_deu_polygon_urban_sector_4_agricultural_mview OWNER TO oeuser;

---------- ---------- ----------


---------- ---------- ---------- ---------- ---------- ----------
-- "Urban Buffer (100m)"   2016-04-18 10:00 s
---------- ---------- ---------- ---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_osm.osm_deu_polygon_urban_buffer100_mview_id CASCADE;
CREATE SEQUENCE 		orig_osm.osm_deu_polygon_urban_buffer100_mview_id;

-- "Create Buffer"   (OK!) 1.400.000ms =128.931
DROP MATERIALIZED VIEW IF EXISTS	orig_osm.osm_deu_polygon_urban_buffer100_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_osm.osm_deu_polygon_urban_buffer100_mview AS
	SELECT	 nextval('orig_osm.osm_deu_polygon_urban_buffer100_mview_id') ::integer AS id,
		(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(osm.geom, 100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_osm.osm_deu_polygon_urban AS osm;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_buffer100_mview_gid_idx
		ON	orig_osm.osm_deu_polygon_urban_buffer100_mview (id);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_buffer100_mview_geom_idx
    ON    	orig_osm.osm_deu_polygon_urban_buffer100_mview
    USING     	GIST (geom);
    
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_osm.osm_deu_polygon_urban_buffer100_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_osm.osm_deu_polygon_urban_buffer100_mview OWNER TO oeuser;


---------- ---------- ----------
-- "Loads OSM"
---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.ego_deu_loads_osm_id CASCADE;
CREATE SEQUENCE 		orig_ego.ego_deu_loads_osm_id;

-- "Unbuffer"   (OK!) 1.394.000ms =169.639 
DROP TABLE IF EXISTS	orig_ego.ego_deu_loads_osm CASCADE;
CREATE TABLE		orig_ego.ego_deu_loads_osm AS
	SELECT	nextval('orig_ego.ego_deu_loads_osm_id') AS id,
		ST_AREA(buffer.geom)/10000 ::double precision AS area_ha,
		buffer.geom ::geometry(Polygon,3035) AS geom
	FROM	(SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(osm.geom, -100)
			)))).geom ::geometry(Polygon,3035) AS geom
		FROM	orig_osm.osm_deu_polygon_urban_buffer100_mview AS osm) AS buffer;

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	orig_ego.ego_deu_loads_osm
	ADD PRIMARY KEY (id);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	ego_deu_loads_osm_geom_idx
    ON    	orig_ego.ego_deu_loads_osm
    USING     	GIST (geom);
    
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_loads_osm TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_osm OWNER TO oeuser;

---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_ego.ego_deu_loads_osm_error_geom_view CASCADE;
-- CREATE VIEW		orig_ego.ego_deu_loads_osm_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,			-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	orig_ego.ego_deu_loads_osm AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_ego.ego_deu_loads_osm_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_loads_osm_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_deu_loads_osm_error_geom_view}', 'orig_ego');


---------- ---------- ----------
-- Alternative Calculation with Table
---------- ---------- ----------

-- -- "Create Table"   (OK!) 200ms =0
-- DROP TABLE IF EXISTS  	orig_osm.osm_deu_polygon_urban_buffer100_unbuffer CASCADE;
-- CREATE TABLE         	orig_osm.osm_deu_polygon_urban_buffer100_unbuffer (
-- 		id SERIAL NOT NULL,
-- 		area_ha double precision,
-- 		geom geometry(Polygon,3035),
-- CONSTRAINT 	osm_deu_polygon_urban_buffer100_unbuffer_pkey PRIMARY KEY (id));
-- 
-- "Insert Buffer"   (OK!) 100.000ms =169.639
-- INSERT INTO     orig_osm.osm_deu_polygon_urban_buffer100_unbuffer(geom)
-- 	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
-- 			ST_BUFFER(ST_TRANSFORM(osm.geom,3035), -100)
-- 		)))).geom ::geometry(Polygon,3035) AS geom
-- 	FROM	orig_osm.osm_deu_polygon_urban_buffer100_mview AS osm
-- 	GROUP BY osm.id
-- 	ORDER BY osm.id;
-- 
-- -- -- "Extend Table"   (OK!) 150ms =0
-- -- ALTER TABLE	orig_osm.osm_deu_polygon_urban_buffer100_unbuffer
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
--     ON    	orig_osm.osm_deu_polygon_urban_buffer100_unbuffer
--     USING     	GIST (geom);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	orig_osm.osm_deu_polygon_urban_buffer100_unbuffer TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_osm.osm_deu_polygon_urban_buffer100_unbuffer OWNER TO oeuser;



---------- ---------- ---------- ---------- ---------- ----------
-- "exclusion"
---------- ---------- ---------- ---------- ---------- ----------

-- -- "Update Area (area_ha)"   (OK!) -> 10.000ms =169.639
-- UPDATE 	orig_osm.osm_deu_polygon_urban_buffer100_unbuffer AS t1
-- SET  	area_ha = t2.area
-- FROM    (
-- 	SELECT	la.id,
-- 		ST_AREA(ST_TRANSFORM(la.geom,3035))/10000 ::double precision AS area
-- 	FROM	orig_osm.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- 	) AS t2
-- WHERE  	t1.id = t2.id;

-- -- "Validate Area (area_ha) kleiner 100m²"   (OK!) 500ms =1.418
-- DROP MATERIALIZED VIEW IF EXISTS	orig_osm.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview CASCADE;
-- CREATE MATERIALIZED VIEW 		orig_osm.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview AS 
-- 	SELECT 	la.id AS id,
-- 		la.area_ha AS area_ha,
-- 		la.geom AS geom
-- 	FROM 	orig_osm.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- 	WHERE	la.area_ha < 0.01;
-- GRANT ALL ON TABLE orig_osm.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview TO oeuser WITH GRANT OPTION;
-- 
-- -- "Remove Errors (area_ha)"   (OK!) 700ms =1.418
-- DELETE FROM	orig_osm.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- 	WHERE	la.area_ha < 0.01;
-- 
-- -- "Validate Area (area_ha) Check"   (OK!) 400ms =0
-- SELECT 	la.id AS id,
-- 	la.area_ha AS area_ha,
-- 	la.geom AS geom
-- FROM 	orig_osm.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- WHERE	la.area_ha < 0.01;