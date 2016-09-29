
---------- ---------- ---------- ---------- ---------- ---------- 
-- "2. Data Setup OSM"   2016-04-18 10:00 11s 
---------- ---------- ---------- ---------- ---------- ---------- 

-- -- "Validate (geom)"   (OK!) -> 100ms =0
-- DROP VIEW IF EXISTS	openstreetmap.osm_deu_polygon_error_geom_view CASCADE;
-- CREATE VIEW		openstreetmap.osm_deu_polygon_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	openstreetmap.osm_deu_polygon AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	openstreetmap.osm_deu_polygon_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		openstreetmap.osm_deu_polygon_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 1.581.000ms =1
-- SELECT f_drop_view('{osm_deu_polygon_error_geom_view}', 'orig_osm');

---------- ---------- ----------
-- "Filter OSM Urban Landuse"
---------- ---------- ----------

-- "Filter Urban"   (OK!) -> 35.000ms =494.696
DROP TABLE IF EXISTS	openstreetmap.osm_deu_polygon_urban CASCADE;
CREATE TABLE		openstreetmap.osm_deu_polygon_urban AS
	SELECT	osm.gid ::integer AS gid,
		osm.osm_id ::integer AS osm_id,
		--osm.landuse ::text AS landuse,
		--osm.man_made ::text AS man_made,
		--osm.aeroway ::text AS aeroway,
		osm.name ::text AS name,
		--osm.way_area ::double precision AS way_area,
		'0' ::integer AS sector,
		ST_AREA(ST_TRANSFORM(osm.geom,3035))/10000 ::double precision AS area_ha,
		osm.tags ::hstore AS tags,
		'outside' ::text AS vg250,
		ST_MULTI(ST_TRANSFORM(osm.geom,3035)) ::geometry(MultiPolygon,3035) AS geom		
	FROM	openstreetmap.osm_deu_polygon AS osm
	WHERE	tags @> '"landuse"=>"residential"'::hstore OR 
		tags @> '"landuse"=>"commercial"'::hstore OR 
		tags @> '"landuse"=>"retail"'::hstore OR 
		tags @> '"landuse"=>"industrial;retail"'::hstore OR 
			
		tags @> '"landuse"=>"industrial"'::hstore OR 
		tags @> '"landuse"=>"port"'::hstore OR 
		tags @> '"man_made"=>"wastewater_plant"'::hstore OR
		tags @> '"aeroway"=>"terminal"'::hstore OR 
		tags @> '"aeroway"=>"gate"'::hstore OR 
		tags @> '"man_made"=>"works"'::hstore OR 
		
		tags @> '"landuse"=>"farmyard"'::hstore OR 
		tags @> '"landuse"=>"greenhouse_horticulture"'::hstore 
	
		--osm.landuse='residential' OR
		--osm.landuse='commercial' OR 
		--osm.landuse='retail' OR
		--osm.landuse='industrial;retail' OR
		--osm.landuse='industrial' OR 
		--osm.landuse='port' OR
		--osm.man_made='wastewater_plant' OR
		--osm.aeroway='terminal' OR
		--osm.aeroway='gate' OR
		--osm.man_made='works' OR
		--osm.landuse='farmyard' OR 
		--osm.landuse='greenhouse_horticulture'
	ORDER BY	osm.gid;

-- "Set PK"   (OK!) -> 1.000ms =0
ALTER TABLE openstreetmap.osm_deu_polygon_urban
	ADD PRIMARY KEY (gid);

-- "Create Index GIST (geom)"   (OK!) -> 6.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	openstreetmap.osm_deu_polygon_urban TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.osm_deu_polygon_urban OWNER TO oeuser;


---------- ---------- ----------
-- "OSM Urban Landuse Inside vg250"
---------- ---------- ----------
	
-- "Calculate 'inside' vg250"   (OK!) -> 122.000ms =492.890
UPDATE 	openstreetmap.osm_deu_polygon_urban AS t1
SET  	vg250 = t2.vg250
FROM    (
	SELECT	osm.gid AS gid,
		'inside' ::text AS vg250
	FROM	orig_geo_vg250.vg250_1_sta_union_mview AS vg,
		openstreetmap.osm_deu_polygon_urban AS osm
	WHERE  	vg.geom && osm.geom AND
		ST_CONTAINS(vg.geom,osm.geom)
	) AS t2
WHERE  	t1.gid = t2.gid;

---------- ---------- ----------
	
-- "Calculate 'crossing' vg250"   (OK!) -> 17.000ms =291
UPDATE 	openstreetmap.osm_deu_polygon_urban AS t1
SET  	vg250 = t2.vg250
FROM    (
	SELECT	osm.gid AS gid,
		'crossing' ::text AS vg250
	FROM	orig_geo_vg250.vg250_1_sta_union_mview AS vg,
		openstreetmap.osm_deu_polygon_urban AS osm
	WHERE  	osm.vg250 = 'outside' AND
		vg.geom && osm.geom AND
		ST_Overlaps(vg.geom,osm.geom)
	) AS t2
WHERE  	t1.gid = t2.gid;


---------- ---------- ----------
-- OSM outside of vg250
---------- ---------- ----------

-- "OSM error vg250"   (OK!) -> 400ms =1.806
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview CASCADE;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview AS
	SELECT	osm.*
	FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	osm.vg250 = 'outside' OR osm.vg250 = 'crossing';

-- "Create Index (gid)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_error_geom_vg250_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 150ms =0
CREATE INDEX  	osm_deu_polygon_urban_error_geom_vg250_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview OWNER TO oeuser;	

---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview_id CASCADE;
CREATE SEQUENCE 		openstreetmap.osm_deu_polygon_urban_vg250_cut_mview_id;

-- "Cutting 'crossing' with vg250"   (OK!) 12.000ms =291
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_vg250_cut_mview AS
	SELECT	nextval('openstreetmap.osm_deu_polygon_urban_vg250_cut_mview_id') ::integer AS id,
		cut.gid ::integer AS gid,
		cut.osm_id ::integer AS osm_id,
		--cut.landuse ::text AS landuse,
		--cut.man_made ::text AS man_made,
		--cut.aeroway ::text AS aeroway,
		cut.name ::text AS name,
		--cut.way_area ::double precision AS way_area,
		cut.sector ::integer AS sector,
		cut.area_ha ::double precision AS area_ha,
		cut.tags ::hstore AS tags,
		cut.vg250 ::text AS vg250,
		GeometryType(cut.geom_new) ::text AS geom_type,
		ST_MULTI(ST_TRANSFORM(cut.geom_new,3035)) ::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT	poly.*,
			ST_INTERSECTION(poly.geom,cut.geom) AS geom_new
		FROM	openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview AS poly,
			orig_geo_vg250.vg250_1_sta_union_mview AS cut
		WHERE	poly.vg250 = 'crossing'
		) AS cut
	ORDER BY 	cut.gid;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_vg250_cut_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	osm_deu_polygon_urban_vg250_cut_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.osm_deu_polygon_urban_vg250_cut_mview OWNER TO oeuser;

-- Find double entries (OK!) -> =0
-- SELECT 		gid, count(*)
-- FROM 		openstreetmap.osm_deu_polygon_urban_vg250_cut_mview
-- GROUP BY 	gid
-- HAVING 		count(*) > 1;

---------- ---------- ----------

-- "'crossing' Polygon to MultiPolygon"   (OK!) 1.000ms =255
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview AS
	SELECT	nextval('openstreetmap.osm_deu_polygon_gid_seq'::regclass) ::integer AS gid,
		cut.osm_id ::integer AS osm_id,
		--cut.landuse ::text AS landuse,
		--cut.man_made ::text AS man_made,
		--cut.aeroway ::text AS aeroway,
		cut.name ::text AS name,
		cut.sector ::integer AS sector,
		--cut.way_area ::double precision AS way_area,
		cut.area_ha ::double precision AS area_ha,
		cut.tags ::hstore AS tags,
		cut.vg250 ::text AS vg250,
		ST_MULTI(cut.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview AS cut
	WHERE	cut.geom_type = 'POLYGON';

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_vg250_clean_cut_multi_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	osm_deu_polygon_urban_vg250_clean_cut_multi_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview OWNER TO oeuser;

-- Find double entries (OK!) -> =0
-- SELECT 		gid, count(*)
-- FROM 		openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview
-- GROUP BY 	gid
-- HAVING 		count(*) > 1;

---------- ---------- ----------

-- "clean cut"   (OK!) 100ms =36
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_mview;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_mview AS
	SELECT	nextval('openstreetmap.osm_deu_polygon_gid_seq'::regclass) ::integer AS gid,
		cut.osm_id ::integer AS osm_id,
		--cut.landuse ::text AS landuse,
		--cut.man_made ::text AS man_made,
		--cut.aeroway ::text AS aeroway,
		cut.name ::text AS name,
		cut.sector ::integer AS sector,
		--cut.way_area ::double precision AS way_area,
		cut.area_ha ::double precision AS area_ha,
		cut.tags ::hstore AS tags,
		cut.vg250 ::text AS vg250,
		cut.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview AS cut
	WHERE	cut.geom_type = 'MULTIPOLYGON';

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_vg250_clean_cut_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_mview (gid);

---------- ---------- ----------

-- "Remove 'outside' vg250"   (OK!) 300ms =1515
DELETE FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	osm.vg250 = 'outside';

-- "Remove 'outside' vg250"   (OK!) 300ms =618
DELETE FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	osm.vg250 = 'crossing';

-- "Insert cut"   (OK!) 300ms =36
INSERT INTO	openstreetmap.osm_deu_polygon_urban
	SELECT	clean.*
	FROM	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_mview AS clean
	ORDER BY 	clean.gid;

-- "Insert cut multi"   (ungleiche spalten!) 300ms =255
INSERT INTO	openstreetmap.osm_deu_polygon_urban
	SELECT	clean.*
	FROM	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview AS clean
	ORDER BY 	clean.gid;


---------- ---------- ----------
-- "(Geo) Data Validation"
---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_error_geom_mview CASCADE;
-- CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_error_geom_mview AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	openstreetmap.osm_deu_polygon_urban AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	openstreetmap.osm_deu_polygon_urban_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		openstreetmap.osm_deu_polygon_urban_error_geom_view OWNER TO oeuser;

---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_error_geom_view CASCADE;
-- CREATE VIEW		openstreetmap.osm_deu_polygon_urban_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	openstreetmap.osm_deu_polygon_urban AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	openstreetmap.osm_deu_polygon_urban_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		openstreetmap.osm_deu_polygon_urban_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{osm_deu_polygon_urban_error_geom_view}', 'orig_osm');


---------- ---------- ----------
-- "Filter by Sector"
---------- ---------- ----------

-- "Sector 1. Residential"

-- "Update Sector"   (OK!) -> 122.000ms =492.890
UPDATE 	openstreetmap.osm_deu_polygon_urban
SET  	sector = '1'
WHERE	tags @> '"landuse"=>"residential"'::hstore;

-- "Filter Residential"   (OK!) -> 3.000ms =276.513
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview CASCADE;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview AS
	SELECT	osm.*
	FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	sector = '1'
ORDER BY	osm.gid;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_1_residential_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 4.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_1_residential_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Sector 2. Retail"

-- "Update Sector"   (OK!) -> 122.000ms =492.890
UPDATE 	openstreetmap.osm_deu_polygon_urban
SET  	sector = '2'
WHERE	tags @> '"landuse"=>"commercial"'::hstore OR 
		tags @> '"landuse"=>"retail"'::hstore OR 
		tags @> '"landuse"=>"industrial;retail"'::hstore;

-- "Filter Retail"   (OK!) -> 1.000ms =35.527
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview CASCADE;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview AS
	SELECT	osm.*
	FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	sector = '2'
ORDER BY	osm.gid;
    
-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_2_retail_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 1.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_2_retail_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Sector 3. Industrial"

-- "Update Sector"   (OK!) -> 122.000ms =492.890
UPDATE 	openstreetmap.osm_deu_polygon_urban
SET  	sector = '3'
WHERE	tags @> '"landuse"=>"industrial"'::hstore OR 
		tags @> '"landuse"=>"port"'::hstore OR 
		tags @> '"man_made"=>"wastewater_plant"'::hstore OR
		tags @> '"aeroway"=>"terminal"'::hstore OR 
		tags @> '"aeroway"=>"gate"'::hstore OR 
		tags @> '"man_made"=>"works"'::hstore;

-- "Filter Industrial"   (OK!) -> 1.000ms =58.870
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview CASCADE;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview AS
	SELECT	osm.*
	FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	sector = '3'
ORDER BY	osm.gid;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_3_industrial_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 1.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_3_industrial_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Sector 4. Agricultural"

-- "Update Sector"   (OK!) -> 122.000ms =492.890
UPDATE 	openstreetmap.osm_deu_polygon_urban
SET  	sector = '4'
WHERE	tags @> '"landuse"=>"farmyard"'::hstore OR 
	tags @> '"landuse"=>"greenhouse_horticulture"'::hstore;

-- "Filter Agricultural"   (OK!) -> 2.000ms =122.406
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview CASCADE;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview AS
	SELECT	osm.*
	FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	sector = '4'
ORDER BY	osm.gid;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_4_agricultural_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview (gid);
    
-- "Create Index GIST (geom)"   (OK!) -> 1.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_4_agricultural_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview_error_geom_view CASCADE;
-- CREATE VIEW		openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{osm_deu_polygon_urban_sector_4_agricultural_mview_error_geom_view}', 'orig_osm');


