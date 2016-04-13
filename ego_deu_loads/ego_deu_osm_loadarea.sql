
---------- ---------- ---------- ---------- ---------- ----------
-- "Setup"
---------- ---------- ---------- ---------- ---------- ----------

-- -- "Create Schema"
-- DROP SCHEMA IF EXISTS	orig_geo_ego;
-- CREATE SCHEMA 		orig_geo_ego;
-- GRANT ALL ON SCHEMA 		orig_geo_ego TO oeuser WITH GRANT OPTION;


---------- ---------- ----------
-- "vg250_1_sta_mview"   2016-04-13 11:47 1s
---------- ---------- ----------

-- "Transform VG250 State"   (OK!) -> 200ms =11
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_vg250.vg250_1_sta_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_vg250.vg250_1_sta_mview AS
	SELECT	vg.gid,
		ST_TRANSFORM(vg.geom,3035) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_geo_vg250.vg250_1_sta AS vg
	ORDER BY vg.gid;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_1_sta_mview_gid_idx
		ON	orig_geo_vg250.vg250_1_sta_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	vg250_1_sta_mview_geom_idx
	ON	orig_geo_vg250.vg250_1_sta_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_vg250.vg250_1_sta_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_vg250.vg250_1_sta_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 500ms =1
-- DROP VIEW IF EXISTS	orig_geo_vg250.vg250_1_sta_mview_error_geom_view CASCADE;
-- CREATE VIEW		orig_geo_vg250.vg250_1_sta_mview_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(MultiPolygon,3035) AS geom
-- 		FROM	orig_geo_vg250.vg250_1_sta_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_geo_vg250.vg250_1_sta_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_geo_vg250.vg250_1_sta_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{vg250_1_sta_mview_error_geom_view}', 'orig_geo_vg250');


---------- ---------- ----------
-- "vg250_1_sta_union_mview"   2016-04-13 11:47 2s
---------- ---------- ----------

-- "Transform VG250 State UNION"   (OK!) -> 2.000ms =1
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_vg250.vg250_1_sta_union_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_vg250.vg250_1_sta_union_mview AS
	SELECT	'DEU' ::text AS id,
		ST_UNION(ST_TRANSFORM(vg.geom,3035)) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_geo_vg250.vg250_1_sta AS vg;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_1_sta_union_mview_id_idx
		ON	orig_geo_vg250.vg250_1_sta_union_mview (id);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	vg250_1_sta_union_mview_geom_idx
	ON	orig_geo_vg250.vg250_1_sta_union_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_vg250.vg250_1_sta_union_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_vg250.vg250_1_sta_union_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_geo_vg250.vg250_1_sta_union_mview_error_geom_view CASCADE;
-- CREATE VIEW		orig_geo_vg250.vg250_1_sta_union_mview_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,					-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(MultiPolygon,3035) AS geom
-- 		FROM	orig_geo_vg250.vg250_1_sta_union_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_geo_vg250.vg250_1_sta_union_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_geo_vg250.vg250_1_sta_union_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{vg250_1_sta_union_mview_error_geom_view}', 'orig_geo_vg250');


---------- ---------- ----------
-- "orig_geo_vg250.vg250_4_krs_mview"   2016-04-13 11:47 2s
---------- ---------- ----------

-- "Transform VG250 Gemeinden"   (OK!) -> 1.000ms =432
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_vg250.vg250_4_krs_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_vg250.vg250_4_krs_mview AS
	SELECT	vg.gid,
		vg.gen,
		vg.nuts,
		vg.rs,
		ags_0,
		ST_TRANSFORM(vg.geom,3035) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_geo_vg250.vg250_4_krs AS vg
	ORDER BY vg.gid;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_4_krs_mview_gid_idx
		ON	orig_geo_vg250.vg250_4_krs_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 200ms =0
CREATE INDEX  	vg250_4_krs_mview_geom_idx
	ON	orig_geo_vg250.vg250_4_krs_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_vg250.vg250_4_krs_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_vg250.vg250_4_krs_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_geo_vg250.vg250_4_krs_mview_error_geom_view CASCADE;
-- CREATE VIEW		orig_geo_vg250.vg250_4_krs_mview_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(MultiPolygon,3035) AS geom
-- 		FROM	orig_geo_vg250.vg250_4_krs_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_geo_vg250.vg250_4_krs_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_geo_vg250.vg250_4_krs_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{vg250_4_krs_mview_error_geom_view}', 'orig_geo_vg250');


---------- ---------- ----------
-- "vg250_6_gem_mview"   2016-04-13 11:47 2s
---------- ---------- ----------

-- "Transform VG250 Gemeinden"   (OK!) -> 2.000ms =11.438
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_vg250.vg250_6_gem_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_vg250.vg250_6_gem_mview AS
	SELECT	vg.gid,
		vg.gen,
		vg.nuts,
		vg.rs,
		ags_0,
		ST_TRANSFORM(vg.geom,3035) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_geo_vg250.vg250_6_gem AS vg
	ORDER BY vg.gid;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_6_gem_mview_gid_idx
		ON	orig_geo_vg250.vg250_6_gem_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 150ms =0
CREATE INDEX  	vg250_6_gem_mview_geom_idx
	ON	orig_geo_vg250.vg250_6_gem_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_vg250.vg250_6_gem_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_vg250.vg250_6_gem_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Validate (geom)"   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	orig_geo_vg250.vg250_6_gem_mview_error_geom_view CASCADE;
CREATE VIEW		orig_geo_vg250.vg250_6_gem_mview_error_geom_view AS 
	SELECT	test.id AS id,
		test.error AS error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.gid AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom ::geometry(MultiPolygon,3035) AS geom
		FROM	orig_geo_vg250.vg250_6_gem_mview AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_vg250.vg250_6_gem_mview_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_vg250.vg250_6_gem_mview_error_geom_view OWNER TO oeuser;

-- "Drop empty view"   (OK!) -> 100ms =1
SELECT f_drop_view('{vg250_6_gem_mview_error_geom_view}', 'orig_geo_vg250');



---------- ---------- ---------- ---------- ---------- ----------
-- "Filter OSM Urban Landuse"   2016-04-13 11:49 184s
---------- ---------- ---------- ---------- ---------- ----------	

-- "Filter Urban"   (OK!) -> 31.000ms =494.696
DROP TABLE IF EXISTS	orig_geo_ego.osm_deu_polygon_urban CASCADE;
CREATE TABLE		orig_geo_ego.osm_deu_polygon_urban AS
	SELECT	osm.gid,
		osm.osm_id,
		osm.landuse,
		osm.man_made,
		osm.aeroway,
		osm.name,
		osm.way_area,
		ST_AREA(ST_TRANSFORM(osm.geom,3035))/10000 AS area_ha,
		osm.tags,
		'outside' ::text AS vg250,
		ST_TRANSFORM(osm.geom,3035) ::geometry(MultiPolygon,3035) AS geom		
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
ALTER TABLE orig_geo_ego.osm_deu_polygon_urban
	ADD PRIMARY KEY (gid);

-- "Create Index GIST (geom)"   (OK!) -> 6.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_geom_idx
	ON	orig_geo_ego.osm_deu_polygon_urban
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.osm_deu_polygon_urban TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban OWNER TO oeuser;

---------- ---------- ----------
	
-- "Calculate 'inside' vg250"   (OK!) -> 122.000ms =492.890
UPDATE 	orig_geo_ego.osm_deu_polygon_urban AS t1
SET  	vg250 = t2.vg250
FROM    (
	SELECT	osm.gid AS gid,
		'inside' ::text AS vg250
	FROM	orig_geo_vg250.vg250_1_sta_union_mview AS vg,
		orig_geo_ego.osm_deu_polygon_urban AS osm
	WHERE  	vg.geom && osm.geom AND
		ST_CONTAINS(vg.geom,osm.geom)
	) AS t2
WHERE  	t1.gid = t2.gid;

---------- ---------- ----------
	
-- "Calculate 'crossing' vg250"   (OK!) -> 17.000ms =291
UPDATE 	orig_geo_ego.osm_deu_polygon_urban AS t1
SET  	vg250 = t2.vg250
FROM    (
	SELECT	osm.gid AS gid,
		'crossing' ::text AS vg250
	FROM	orig_geo_vg250.vg250_1_sta_union_mview AS vg,
		orig_geo_ego.osm_deu_polygon_urban AS osm
	WHERE  	osm.vg250 = 'outside' AND
		vg.geom && osm.geom AND
		ST_Overlaps(vg.geom,osm.geom)
	) AS t2
WHERE  	t1.gid = t2.gid;

---------- ---------- ----------

-- "OSM error vg250"   (OK!) -> 400ms =1.806
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_error_geom_vg250_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.osm_deu_polygon_urban_error_geom_vg250_mview AS
	SELECT	osm.*
	FROM	orig_geo_ego.osm_deu_polygon_urban AS osm
	WHERE	osm.vg250 = 'outside' OR osm.vg250 = 'crossing';

-- "Create Index (gid)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_error_geom_vg250_mview_gid_idx
		ON	orig_geo_ego.osm_deu_polygon_urban_error_geom_vg250_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 150ms =0
CREATE INDEX  	osm_deu_polygon_urban_error_geom_vg250_mview_geom_idx
	ON	orig_geo_ego.osm_deu_polygon_urban_error_geom_vg250_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.osm_deu_polygon_urban_error_geom_vg250_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_error_geom_vg250_mview OWNER TO oeuser;	

---------- ---------- ----------

-- "Cutting 'crossing' with vg250"   (OK!) 12.000ms =291
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_vg250_cut_mview;
CREATE MATERIALIZED VIEW		orig_geo_ego.osm_deu_polygon_urban_vg250_cut_mview AS
	SELECT	ROW_NUMBER() OVER () AS id,
		cut.gid AS gid,
		cut.osm_id AS osm_id,
		cut.landuse AS landuse,
		cut.man_made AS man_made,
		cut.aeroway AS aeroway,
		cut.name AS name,
		cut.way_area AS way_area,
		cut.area_ha AS area_ha,
		cut.tags AS tags,
		cut.vg250 AS vg250,
		GeometryType(cut.geom_new) AS geom_type,
		cut.geom_new AS geom
	FROM	(SELECT	poly.*,
			ST_INTERSECTION(poly.geom,cut.geom) AS geom_new
		FROM	orig_geo_ego.osm_deu_polygon_urban_error_geom_vg250_mview AS poly,
			orig_geo_vg250.vg250_1_sta_union_mview AS cut
		WHERE	poly.vg250 = 'crossing'
		) AS cut
	ORDER BY 	cut.gid;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_vg250_cut_mview_gid_idx
		ON	orig_geo_ego.osm_deu_polygon_urban_vg250_cut_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	osm_deu_polygon_urban_vg250_cut_mview_geom_idx
	ON	orig_geo_ego.osm_deu_polygon_urban_vg250_cut_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.osm_deu_polygon_urban_vg250_cut_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_vg250_cut_mview OWNER TO oeuser;

-- Find double entries (OK!) -> =0
SELECT 		gid, count(*)
FROM 		orig_geo_ego.osm_deu_polygon_urban_vg250_cut_mview
GROUP BY 	gid
HAVING 		count(*) > 1;

---------- ---------- ----------

-- POLYGON von MULTIPOLYGON Trennen

-- "'crossing' polgon to multi"   (OK!) 100ms =255
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_vg250_clean_cut_multi_mview;
CREATE MATERIALIZED VIEW		orig_geo_ego.osm_deu_polygon_urban_vg250_clean_cut_multi_mview AS
	SELECT	nextval('orig_osm.osm_deu_polygon_gid_seq'::regclass)  AS gid,
		cut.osm_id AS osm_id,
		cut.landuse AS landuse,
		cut.man_made AS man_made,
		cut.aeroway AS aeroway,
		cut.name AS name,
		cut.way_area AS way_area,
		cut.area_ha AS area_ha,
		cut.tags AS tags,
		cut.vg250 AS vg250,
		ST_MULTI(cut.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_geo_ego.osm_deu_polygon_urban_vg250_cut_mview AS cut
	WHERE	cut.geom_type = 'POLYGON';

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_vg250_clean_cut_multi_mview_gid_idx
		ON	orig_geo_ego.osm_deu_polygon_urban_vg250_clean_cut_multi_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	osm_deu_polygon_urban_vg250_clean_cut_multi_mview_geom_idx
	ON	orig_geo_ego.osm_deu_polygon_urban_vg250_clean_cut_multi_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.osm_deu_polygon_urban_vg250_clean_cut_multi_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_vg250_clean_cut_multi_mview OWNER TO oeuser;

-- Find double entries (OK!) -> =0
SELECT 		gid, count(*)
FROM 		orig_geo_ego.osm_deu_polygon_urban_vg250_clean_cut_multi_mview
GROUP BY 	gid
HAVING 		count(*) > 1;

---------- ---------- ----------

-- "clean cut"   (OK!) 100ms =36
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_vg250_clean_cut_mview;
CREATE MATERIALIZED VIEW		orig_geo_ego.osm_deu_polygon_urban_vg250_clean_cut_mview AS
	SELECT	nextval('orig_osm.osm_deu_polygon_gid_seq'::regclass) AS gid,
		cut.osm_id AS osm_id,
		cut.landuse AS landuse,
		cut.man_made AS man_made,
		cut.aeroway AS aeroway,
		cut.name AS name,
		cut.way_area AS way_area,
		cut.area_ha AS area_ha,
		cut.tags AS tags,
		cut.vg250 AS vg250,
		cut.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_geo_ego.osm_deu_polygon_urban_vg250_cut_mview AS cut
	WHERE	cut.geom_type = 'MULTIPOLYGON';

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_vg250_clean_cut_mview_gid_idx
		ON	orig_geo_ego.osm_deu_polygon_urban_vg250_clean_cut_mview (gid);

---------- ---------- ----------

-- "Remove 'outside' vg250"   (OK!) 300ms =1515
DELETE FROM	orig_geo_ego.osm_deu_polygon_urban AS osm
	WHERE	osm.vg250 = 'outside';

-- "Remove 'outside' vg250"   (OK!) 300ms =618
DELETE FROM	orig_geo_ego.osm_deu_polygon_urban AS osm
	WHERE	osm.vg250 = 'crossing';

-- "Insert cut"   (OK!) 300ms =36
INSERT INTO	orig_geo_ego.osm_deu_polygon_urban
	SELECT	clean.*
	FROM	orig_geo_ego.osm_deu_polygon_urban_vg250_clean_cut_mview AS clean
	ORDER BY 	clean.gid;

-- "Insert cut multi"   (ungleiche spalten!) 300ms =255
INSERT INTO	orig_geo_ego.osm_deu_polygon_urban
	SELECT	clean.*
	FROM	orig_geo_ego.osm_deu_polygon_urban_vg250_clean_cut_multi_mview AS clean
	ORDER BY 	clean.gid;


---------- ---------- ---------- ---------- ---------- ----------
-- "(Geo) Data Validation"   2016-04-13 11:53 2s
---------- ---------- ---------- ---------- ---------- ----------

-- "Validate (geom)"   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_error_geom_view CASCADE;
CREATE VIEW		orig_geo_ego.osm_deu_polygon_urban_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.gid AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_geo_ego.osm_deu_polygon_urban AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.osm_deu_polygon_urban_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_error_geom_view OWNER TO oeuser;

-- "Drop empty view"   (OK!) -> 100ms =1
SELECT f_drop_view('{osm_deu_polygon_urban_error_geom_view}', 'orig_geo_ego');

---------- ---------- ----------

-- "Validate (gid)"   (OK!) -> 500ms =0
DROP VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_mview_error_gid_view CASCADE;
CREATE VIEW		orig_geo_ego.osm_deu_polygon_urban_mview_error_gid_view AS 
	SELECT 		source.gid AS id,				-- PK
			count(source.*) AS duplicates
	FROM		orig_geo_ego.osm_deu_polygon_urban AS source	-- Table
	GROUP BY 	source.gid
	HAVING 		count(source.*) > 1;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.osm_deu_polygon_urban_mview_error_gid_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_mview_error_gid_view OWNER TO oeuser;

-- "Drop empty view"   (OK!) -> 100ms =1
SELECT f_drop_view('{osm_deu_polygon_urban_mview_error_gid_view}', 'orig_geo_ego');


-- No doubles on Germany! Skip next!
---------- ---------- ----------
-- Delete double entries on "gid" 
---------- ---------- ----------

-- -- Find double entries (OK!) -> =18
-- SELECT 		gid, count(*)
-- FROM 		orig_geo_ego.osm_deu_polygon_spf
-- GROUP BY 	gid
-- HAVING 		count(*) > 1;
-- 
-- -- --  IF double 
-- -- Create nodubs (OK!)
-- DROP TABLE IF EXISTS	orig_geo_ego.osm_deu_polygon_spf_nodubs;
-- CREATE TABLE		orig_geo_ego.osm_deu_polygon_spf_nodubs AS
-- 	SELECT	osm.*
-- 	FROM	orig_geo_ego.osm_deu_polygon_spf AS osm
-- 	LIMIT 	0;
-- 
-- -- Add id (OK!)
-- ALTER TABLE 	orig_geo_ego.osm_deu_polygon_spf_nodubs
-- 	ADD column id serial;
-- 
-- -- Insert data (OK!) 94ms =1567
-- INSERT INTO	orig_geo_ego.osm_deu_polygon_spf_nodubs
-- 	SELECT	osm.*
-- 	FROM	orig_geo_ego.osm_deu_polygon_spf AS osm
-- ORDER BY 	gid;
-- 
-- -- Delete double entries (OK!) 62ms =-18
-- DELETE FROM orig_geo_ego.osm_deu_polygon_spf_nodubs
-- WHERE id IN (SELECT id
--               FROM (SELECT id,
--                              ROW_NUMBER() OVER (partition BY gid ORDER BY id) AS rnum
--                      FROM orig_geo_ego.osm_deu_polygon_spf_nodubs) t
--               WHERE t.rnum > 1);
-- 
-- -- Check for doubles again (OK!)
-- SELECT 		gid, count(*)
-- FROM 		orig_geo_ego.osm_deu_polygon_spf_nodubs
-- GROUP BY 	gid
-- HAVING 		count(*) > 1;
-- 
-- -- Set PK (OK!)
-- ALTER TABLE 	orig_geo_ego.osm_deu_polygon_spf_nodubs ADD PRIMARY KEY (gid);
-- 
-- -- Create new index (OK!)
-- CREATE INDEX  	osm_deu_polygon_spf_nodubs_geom_idx
--     ON    	orig_geo_ego.osm_deu_polygon_spf_nodubs
--     USING     	GIST (geom);


---------- ---------- ---------- ---------- ---------- ----------
-- "Filter by Sector"   2016-04-13 13:09 s
---------- ---------- ---------- ---------- ---------- ----------

-- "Sector 1. Residential"

-- "Filter Residential"   (OK!) -> 3.000ms =276.513
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_sector_1_residential_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.osm_deu_polygon_urban_sector_1_residential_mview AS
	SELECT	osm.gid,
		osm.osm_id,
		osm.landuse,
		osm.man_made,
		osm.aeroway,
		osm.name,
		osm.way_area,
		osm.area_ha AS area_ha,
		osm.tags,
		osm.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_geo_ego.osm_deu_polygon_urban AS osm
	WHERE	osm.landuse='residential'
ORDER BY	osm.gid;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_1_residential_mview_gid_idx
		ON	orig_geo_ego.osm_deu_polygon_urban_sector_1_residential_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 4.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_1_residential_mview_geom_idx
	ON	orig_geo_ego.osm_deu_polygon_urban_sector_1_residential_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.osm_deu_polygon_urban_sector_1_residential_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_sector_1_residential_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Sector 2. Retail"

-- "Filter Retail"   (OK!) -> 1.000ms =35.527
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_sector_2_retail_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.osm_deu_polygon_urban_sector_2_retail_mview AS
	SELECT	osm.gid,
		osm.osm_id,
		osm.landuse,
		osm.man_made,
		osm.aeroway,
		osm.name,
		osm.way_area,
		osm.area_ha AS area_ha,
		osm.tags,
		osm.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_geo_ego.osm_deu_polygon_urban AS osm
	WHERE	osm.landuse='commercial' OR 
		osm.landuse='retail' OR
		osm.landuse='industrial;retail'
ORDER BY	osm.gid;
    
-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_2_retail_mview_gid_idx
		ON	orig_geo_ego.osm_deu_polygon_urban_sector_2_retail_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 1.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_2_retail_mview_geom_idx
	ON	orig_geo_ego.osm_deu_polygon_urban_sector_2_retail_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.osm_deu_polygon_urban_sector_2_retail_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_sector_2_retail_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Sector 3. Industrial"

-- "Filter Industrial"   (OK!) -> 1.000ms =58.870
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_sector_3_industrial_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.osm_deu_polygon_urban_sector_3_industrial_mview AS
	SELECT	osm.gid,
		osm.osm_id,
		osm.landuse,
		osm.man_made,
		osm.aeroway,
		osm.name,
		osm.way_area,
		osm.area_ha AS area_ha,
		osm.tags,
		osm.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_geo_ego.osm_deu_polygon_urban AS osm
	WHERE	osm.landuse='industrial' OR 
		osm.landuse='port' OR
		osm.man_made='wastewater_plant' OR
		osm.aeroway='terminal' OR osm.aeroway='gate' OR
		osm.man_made='works'
ORDER BY	osm.gid;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_3_industrial_mview_gid_idx
		ON	orig_geo_ego.osm_deu_polygon_urban_sector_3_industrial_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 1.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_3_industrial_mview_geom_idx
	ON	orig_geo_ego.osm_deu_polygon_urban_sector_3_industrial_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.osm_deu_polygon_urban_sector_3_industrial_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_sector_3_industrial_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Sector 4. Agricultural"

-- "Filter Agricultural"   (OK!) -> 2.000ms =122.406
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_sector_4_agricultural_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.osm_deu_polygon_urban_sector_4_agricultural_mview AS
	SELECT	osm.gid,
		osm.osm_id,
		osm.landuse,
		osm.man_made,
		osm.aeroway,
		osm.name,
		osm.way_area,
		osm.area_ha AS area_ha,
		osm.tags,
		osm.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_geo_ego.osm_deu_polygon_urban AS osm
	WHERE	osm.landuse='farmyard' OR 
		osm.landuse='greenhouse_horticulture'
ORDER BY	osm.gid;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_4_agricultural_mview_gid_idx
		ON	orig_geo_ego.osm_deu_polygon_urban_sector_4_agricultural_mview (gid);
    
-- "Create Index GIST (geom)"   (OK!) -> 1.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_sector_4_agricultural_mview_geom_idx
	ON	orig_geo_ego.osm_deu_polygon_urban_sector_4_agricultural_mview
	USING	GIST (geom);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.osm_deu_polygon_urban_sector_4_agricultural_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_sector_4_agricultural_mview OWNER TO oeuser;


---------- ---------- ---------- ---------- ---------- ----------
-- "Urban Buffer (100m)"
---------- ---------- ---------- ---------- ---------- ----------

-- -- "Create Table"   (OK!) 200ms =0
-- DROP TABLE IF EXISTS  	orig_geo_ego.osm_deu_polygon_urban_buffer100;
-- CREATE TABLE         	orig_geo_ego.osm_deu_polygon_urban_buffer100 (
-- 		id SERIAL,
-- 		geom geometry(Polygon,3035),
-- CONSTRAINT 	osm_deu_polygon_urban_buffer100_pkey PRIMARY KEY (id));
-- 
-- -- "Insert Buffer"   (OK!) 1.216.000ms =129.322
-- INSERT INTO     orig_geo_ego.osm_deu_polygon_urban_buffer100(geom)
-- 	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
-- 			ST_BUFFER(ST_TRANSFORM(osm.geom,3035), 100)
-- 		)))).geom ::geometry(Polygon,3035) AS geom
-- 	FROM	orig_geo_ego.osm_deu_polygon_urban_mview AS osm;
-- 
-- -- "Create Index GIST (geom)"   (OK!) 2.000ms =0
-- CREATE INDEX  	osm_deu_polygon_urban_buffer100_geom_idx
--     ON    	orig_geo_ego.osm_deu_polygon_urban_buffer100
--     USING     	GIST (geom);
--     
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	orig_geo_ego.osm_deu_polygon_urban_buffer100 TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_buffer100 OWNER TO oeuser;

---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	buffer100_id;
CREATE TEMP SEQUENCE 		buffer100_id;

-- "Create Buffer"   (OK!) 1.600.000ms =128.931
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_buffer100_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.osm_deu_polygon_urban_buffer100_mview AS
	SELECT	 nextval('buffer100_id') AS id,
		(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(ST_TRANSFORM(osm.geom,3035), 100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.osm_deu_polygon_urban AS osm;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_buffer100_mview_gid_idx
		ON	orig_geo_ego.osm_deu_polygon_urban_buffer100_mview (id);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_buffer100_mview_geom_idx
    ON    	orig_geo_ego.osm_deu_polygon_urban_buffer100_mview
    USING     	GIST (geom);
    
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_buffer100_mview OWNER TO oeuser;

---------- ---------- ---------- ---------- ---------- ----------
-- "Unbuffer (-100m)"
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer CASCADE;
CREATE TABLE         	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer (
		uid SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	osm_deu_polygon_urban_buffer100_unbuffer_pkey PRIMARY KEY (uid));

-- "Insert Buffer"   (OK!) 100.000ms =169.639
INSERT INTO     orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer(geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(ST_TRANSFORM(osm.geom,3035), -100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_mview AS osm
	GROUP BY osm.id
	ORDER BY osm.id;

-- "Extend Table"   (OK!) 150ms =0
ALTER TABLE	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
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
	ADD COLUMN mv_poly_id integer,
	ADD COLUMN nuts varchar(5),
	ADD COLUMN rs varchar(12),
	ADD COLUMN ags_0 varchar(8),	
	ADD COLUMN geom_centroid geometry(POINT,3035),
	ADD COLUMN geom_surfacepoint geometry(POINT,3035),
	ADD COLUMN geom_buffer geometry(Polygon,3035);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	osm_deu_polygon_urban_buffer100_unbuffer_geom_idx
    ON    	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer
    USING     	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer OWNER TO oeuser;

---------- ---------- ---------- ---------- ---------- ----------
-- "(Geo) Data Validation 2"
---------- ---------- ---------- ---------- ---------- ----------

-- "Validate (geom)"   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_error_geom_view CASCADE;
CREATE VIEW		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.uid AS id,						-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_error_geom_view OWNER TO oeuser;

-- "Drop empty view"   (OK!) -> 100ms =1
SELECT f_drop_view('{osm_deu_polygon_urban_buffer100_unbuffer_error_geom_view}', 'orig_geo_ego');

---------- ---------- ----------

-- "Validate (uid)"   (OK!) -> 100ms =0
DROP VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_error_gid_view CASCADE;
CREATE VIEW		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_error_gid_view AS 
	SELECT 		source.uid AS id,						-- PK
			count(source.*) AS count
	FROM 		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS source	-- Table
	GROUP BY 	source.uid
	HAVING 		count(source.*) > 1;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_error_gid_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_error_gid_view OWNER TO oeuser;

-- "Drop empty view"   (OK!) -> 100ms =1
SELECT f_drop_view('{osm_deu_polygon_urban_buffer100_unbuffer_error_gid_view}', 'orig_geo_ego');

---------- ---------- ----------

-- "Update Area (area_ha)"   (OK!) -> 10.000ms =169.639
UPDATE 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS t1
SET  	area_ha = t2.area
FROM    (
	SELECT	la.uid,
		ST_AREA(ST_TRANSFORM(la.geom,3035))/10000 AS area
	FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la
	) AS t2
WHERE  	t1.uid = t2.uid;

-- "Validate Area (area_ha) kleiner 100m²"   (OK!) 500ms =1.418
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview AS 
	SELECT 	la.uid AS uid,
		la.area_ha AS area_ha,
		la.geom AS geom
	FROM 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la
	WHERE	la.area_ha < 0.01;
GRANT ALL ON TABLE orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview TO oeuser WITH GRANT OPTION;

-- "Remove Errors (area_ha)"   (OK!) 700ms =1.418
DELETE FROM	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la
	WHERE	la.area_ha < 0.01;

-- "Validate Area (area_ha) Check"   (OK!) 400ms =0
SELECT 	la.uid AS uid,
	la.area_ha AS area_ha,
	la.geom AS geom
FROM 	orig_geo_ego.osm_deu_polygon_urban_buffer100_unbuffer AS la
WHERE	la.area_ha < 0.01;


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