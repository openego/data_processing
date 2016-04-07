
---------- ---------- ---------- ---------- ---------- ----------
-- "Collect Loads"   2016-04-06 11:39 10s
---------- ---------- ---------- ---------- ---------- ----------

-- "Load Area & Load Point Cluster"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_loads_collect CASCADE;
CREATE TABLE		orig_geo_ego.ego_deu_loads_collect (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT	ego_deu_loads_collect_pkey PRIMARY KEY (id));

-- "Insert Load Area"   (OK!) 7.000ms =139.448
INSERT INTO	orig_geo_ego.ego_deu_loads_collect (geom)
	SELECT	la.geom
	FROM	orig_geo_ego.ego_deu_osm_loadarea AS la;

-- "Insert Load Points Cluster"   (OK!) 3.000ms =461.380
INSERT INTO	orig_geo_ego.ego_deu_loads_collect (geom)
	SELECT	cl.geom
	FROM	orig_geo_ego.ego_deu_zensus_loadpoints_cluster AS cl;

-- "Create Index GIST (geom)"   (OK!) 7.000ms =0
CREATE INDEX	ego_deu_loads_collect_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =600.828
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect OWNER TO oeuser;

---------- ---------- ---------- ---------- ---------- ----------
-- "Buffer (100m)"   2016-04-06 11:41 45min
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100;
CREATE TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100 (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT 	ego_deu_loads_collect_buffer100_pkey PRIMARY KEY (id));

-- "Insert Buffer"   (OK!) 3.700.000ms =140.578 (151.436)
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100 (geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(ST_TRANSFORM(poly.geom,3035), 100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect AS poly;

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100
	USING	GIST (geom);
    
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100 TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100 OWNER TO oeuser;

---------------------------

-- "Validate (geom)"   (OK!) -> 28.000ms =0
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_error_geom_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.ego_deu_loads_collect_buffer100_error_geom_mview AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		location(ST_IsValidDetail(test.geom)) ::geometry(Point,3035) AS error_location,
		ST_TRANSFORM(test.geom,3035) ::geometry(Polygon,3035) AS geom
	FROM	(
		SELECT	source.id AS id,
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_geo_ego.ego_deu_loads_collect_buffer100 AS source
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100 TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100 OWNER TO oeuser;


---------- ---------- ---------- ---------- ---------- ----------
-- "Unbuffer (-100m)"   2016-04-06 12:57 6min
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer CASCADE;
CREATE TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer (
		id SERIAL,
		geom geometry(Polygon,3035),
		geom_centroid geometry(Point,3035),
CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_pkey PRIMARY KEY (id));

-- "Insert Unbuffer"   (OK!) 331.000ms =182.430
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer (geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(buffer.geom, -100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100 AS buffer
	GROUP BY buffer.id
	ORDER BY buffer.id;

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer
	USING	GIST (geom);

-- -- "Update Buffer (100m)"   (OK!) -> 230.000ms =202.131
-- UPDATE 	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS t1
-- SET  	geom_buffer = t2.geom_buffer
-- FROM    (
-- 	SELECT	poly.id AS id,
-- 		ST_BUFFER(ST_TRANSFORM(poly.geom,3035), 100) AS geom_buffer
-- 	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS poly
-- 	) AS t2
-- WHERE  	t1.id = t2.id;
-- 
-- -- "Create Index GIST (geom_buffer)"   (OK!) 3.000ms =0
-- CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_geom_buffer_idx
-- 	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer
-- 	USING	GIST (geom_buffer);

-- "Update Centroid"   (OK!) -> 16.000ms =182.430
UPDATE 	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS t1
SET  	geom_centroid = t2.geom_centroid
FROM    (
	SELECT	la.id AS id,
		ST_Centroid(la.geom) AS geom_centroid
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS la	
	) AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_centroid)"   (OK!) -> 5.000ms =0
CREATE INDEX  	ego_deu_loads_collect_buffer100_unbuffer_geom_centroid_idx
    ON    	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer
    USING     	GIST (geom_centroid);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer OWNER TO oeuser;

---------------------------

-- "Validate (geom)"   (OK!) -> 26.000ms =2
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_mview AS 
	SELECT	test.id AS id,
		test.error AS error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
		ST_TRANSFORM(test.geom,3035) ::geometry(Polygon,3035) AS geom
	FROM	(
		SELECT	source.id AS id,
			ST_IsValid(source.geom) AS error,
			source.geom ::geometry(Polygon,3035) AS geom
		FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS source
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Validate (gid)"   (OK!) -> 500ms =0
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_gid_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_gid_mview AS 
	SELECT 		id,
			count(*)
	FROM 		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer
	GROUP BY 	id
	HAVING 		count(*) > 1;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_gid_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_gid_mview OWNER TO oeuser;


---------- ---------- ---------- ---------- ---------- ----------
-- "Fehlerbehebung"   2016-04-06 13:07   s
---------- ---------- ---------- ---------- ---------- ----------

-- Fix geoms with error (OK!) 200ms =2
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_fix_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_fix_mview AS 
	SELECT	fix.id AS id,
		ST_IsValid(fix.geom) AS error,
		GeometryType(fix.geom) AS geom_type,
		ST_AREA(fix.geom) AS area,
		fix.geom_buffer ::geometry(POLYGON,3035) AS geom_buffer,
		fix.geom ::geometry(POLYGON,3035) AS geom
	FROM	(
		SELECT	fehler.id AS id,
			ST_BUFFER(fehler.geom, -1) AS geom_buffer,
			(ST_DUMP(ST_BUFFER(ST_BUFFER(fehler.geom, -1), 1))).geom AS geom
		FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_mview AS fehler
		) AS fix
	ORDER BY fix.id;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_fix_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_fix_mview OWNER TO oeuser;


-- Update Fixed geoms (OK!) 200ms =2
UPDATE 	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS t1
SET	geom = t2.geom
FROM	(
	SELECT	fix.id AS id,
		fix.geom AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_fix_mview AS fix
	) AS t2
WHERE  	t1.id = t2.id;

-- Check for errors again! (OK!) 20.000ms =0
SELECT	test.id AS id,
	test.error AS error,
	reason(ST_IsValidDetail(test.geom)) AS error_reason,
	ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
	ST_TRANSFORM(test.geom,3035) ::geometry(Polygon,3035) AS geom
FROM	(
	SELECT	source.id AS id,
		ST_IsValid(source.geom) AS error,
		source.geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS source
	) AS test
WHERE	test.error = FALSE;

---------- ---------- ----------
-- 
-- -- Fix geom_buffer with error (OK!) 300ms =8
-- DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview CASCADE;
-- CREATE MATERIALIZED VIEW 		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview AS 
-- 	SELECT	fix.id AS id,
-- 		ST_IsValid(fix.geom) AS error,
-- 		GeometryType(fix.geom) AS geom_type,
-- 		ST_AREA(fix.geom) AS area,
-- 		fix.geom_buffer ::geometry(POLYGON,3035) AS geom_buffer,
-- 		fix.geom ::geometry(POLYGON,3035) AS geom
-- 	FROM	(
-- 		SELECT	fehler.id AS id,
-- 			ST_BUFFER(fehler.geom_buffer, -1) AS geom_buffer,
-- 			(ST_DUMP(ST_BUFFER(ST_BUFFER(fehler.geom_buffer, -1), 1))).geom AS geom
-- 		FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_mview AS fehler
-- 		) AS fix
-- 	ORDER BY fix.id;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview OWNER TO oeuser;
-- 
-- 
-- -- Update Fixed geoms (OK!) 200ms =6
-- UPDATE 	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS t1
-- SET	geom_buffer = t2.geom
-- FROM	(
-- 	SELECT	fix.id AS id,
-- 		fix.geom AS geom
-- 	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview AS fix
-- 	) AS t2
-- WHERE  	t1.id = t2.id;
-- 
-- -- Check for errors again! (OK!) 20.000ms =0
-- SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom_buffer)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom_buffer)),3035) ::geometry(Point,3035) AS error_location,
-- 		ST_TRANSFORM(test.geom_buffer,3035) ::geometry(Polygon,3035) AS geom_buffer
-- 	FROM	(
-- 		SELECT	source.id AS id,
-- 			ST_IsValid(source.geom_buffer) AS error,
-- 			source.geom_buffer ::geometry(Polygon,3035) AS geom_buffer
-- 		FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS source
-- 		) AS test
-- 	WHERE	test.error = FALSE;


---------- ---------- ----------
-- "Create SPF"   2016-04-06 14:50   3s
---------- ---------- ----------

-- "Create Table SPF"   (OK!) 3.000ms =886
DROP TABLE IF EXISTS  	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_spf;
CREATE TABLE         	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_spf AS
	SELECT	lc.*
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS lc,
		orig_geo_vg250.vg250_4_krs_spf_mview AS spf
	WHERE	ST_TRANSFORM(spf.geom,3035) && lc.geom  AND  
		ST_CONTAINS(ST_TRANSFORM(spf.geom,3035), lc.geom_centroid);

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_spf
	ADD PRIMARY KEY (id);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_loads_collect_buffer100_unbuffer_spf_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_spf
	USING	GIST (geom);

-- "Create Index GIST (geom_centroid)"   (OK!) -> 150ms =0
CREATE INDEX  	ego_deu_loads_collect_buffer100_unbuffer_spf_geom_centroid_idx
    ON    	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_spf
    USING     	GIST (geom_centroid);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_spf TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_spf OWNER TO oeuser;



---------- ---------- ---------- ---------- ---------- ----------
-- "VORONOI"   2016-04-06 13:09   3s
---------- ---------- ---------- ---------- ---------- ----------

-- "Substations"   (OK!) 100ms =3.716
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_mv_substations_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.ego_deu_mv_substations_mview AS
	SELECT	pts.subst_id AS subst_id,
		pts.voltage AS subst_voltage,
		pts.name AS subst_name,
		ST_TRANSFORM(pts.geom,3035) ::geometry(Point,3035) AS geom
	FROM	calc_gridcells_znes.znes_deu_substations_filtered AS pts;

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_mv_substations_mview_geom_idx
	ON	orig_geo_ego.ego_deu_mv_substations_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.ego_deu_mv_substations_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_mv_substations_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Cutter"   (OK!) 100ms =3.711
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_mv_gridcell_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.ego_deu_mv_gridcell_mview AS
	SELECT	poly.id AS id,
		(ST_DUMP(ST_TRANSFORM(poly.geom,3035))).geom ::geometry(Polygon,3035) AS geom
	FROM	calc_gridcells_znes.znes_deu_gridcells_qgis AS poly;

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_mv_gridcell_mview_geom_idx
	ON	orig_geo_ego.ego_deu_mv_gridcell_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.ego_deu_mv_gridcell_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_mv_gridcell_mview OWNER TO oeuser;

---------- ---------- ----------	

-- "Cutter"   (OK!) 100ms =3.716
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_mv_gridcell_full_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.ego_deu_mv_gridcell_full_mview AS
	SELECT	poly.id AS id,
		(ST_DUMP(ST_TRANSFORM(poly.geom,3035))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.ego_deu_mv_gridcell_full AS poly;

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_mv_gridcell_full_mview_geom_idx
	ON	orig_geo_ego.ego_deu_mv_gridcell_full_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.ego_deu_mv_gridcell_full_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_mv_gridcell_full_mview OWNER TO oeuser;

-- "Validate (geom)"   (OK!) -> 100ms =0
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_mv_gridcell_full_mview_error_geom_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.ego_deu_mv_gridcell_full_mview_error_geom_mview AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		location(ST_IsValidDetail(test.geom)) ::geometry(Point,3035) AS error_location,
		ST_TRANSFORM(test.geom,3035) ::geometry(Polygon,3035) AS geom
	FROM	(
		SELECT	source.id AS id,
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_geo_ego.ego_deu_mv_gridcell_full_mview AS source
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_mv_gridcell_full_mview_error_geom_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_mv_gridcell_full_mview_error_geom_mview OWNER TO oeuser;



---------- ---------- ---------- ---------- ---------- ----------
-- "Cutting SPF"   2016-04-04 17:08   1s
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf;
CREATE TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_cut_spf_pkey PRIMARY KEY (id));

-- "Insert Cut"   (OK!) 500ms =1038
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf (geom)
	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom,cut.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_spf AS poly,
		orig_geo_ego.ego_deu_mv_gridcell_full_mview AS cut
	WHERE	poly.geom && cut.geom;

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_cut_spf_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf OWNER TO oeuser;


---------- ---------- ---------- ---------- ---------- ----------
-- "Cutting DEU Voronoi"
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut;
CREATE TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut (
		id SERIAL,
		geom geometry(Polygon,3035),
		geom_buffer geometry(Polygon,3035),
CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_cut_pkey PRIMARY KEY (id));
	
-- "Insert Cut"   (OK!) 185.000ms =224.365
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut (geom, geom_buffer)
	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom,cut.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS poly,
		orig_geo_ego.ego_deu_mv_gridcell_full_mview AS cut
	WHERE	poly.geom && cut.geom;

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_cut_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut OWNER TO oeuser;



---------- ---------- ---------- ---------- ---------- ----------
-- "Cutting DEU Gemeinde"
---------- ---------- ---------- ---------- ---------- ----------

-- "Cutter"   (OK!) 3.000ms =12.528
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.vg250_6_gem_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.vg250_6_gem_mview AS
	SELECT	poly.gid AS id,
		(ST_DUMP(ST_TRANSFORM(poly.geom,3035))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_vg250.vg250_6_gem AS poly;

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	vg250_6_gem_mview_geom_idx
	ON	orig_geo_ego.vg250_6_gem_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.vg250_6_gem_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.vg250_6_gem_mview OWNER TO oeuser;


---------- ---------- ----------


-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem;
CREATE TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem (
		id SERIAL,
		geom geometry(Polygon,3035)
CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_cut_gem_pkey PRIMARY KEY (id));

-- "Insert Cut"   (OK!) 330.000ms =210.298
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem (geom)
	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom,cut.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS poly,
		orig_geo_ego.vg250_6_gem_mview AS cut
	WHERE	poly.geom && cut.geom;

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_cut_gem_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem OWNER TO oeuser;








---------- ---------- ---------- ---------- ---------- ----------
-- "LOADS"   2016-04-06 15:17   12s
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	orig_geo_ego.ego_deu_loads CASCADE;
CREATE TABLE         	orig_geo_ego.ego_deu_loads (
		id SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	ego_deu_loads_pkey PRIMARY KEY (id));

-- "Insert Loads"   (OK!) 10.000ms =182.430
INSERT INTO     orig_geo_ego.ego_deu_loads (geom)
	SELECT	loads.geom AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS loads;

-- "Extend Table"   (OK!) 100ms =0
ALTER TABLE	orig_geo_ego.ego_deu_loads
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
	ADD COLUMN geom_surfacepoint geometry(POINT,3035)
	ADD COLUMN geom_centre geometry(POINT,3035);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	ego_deu_loads_geom_idx
    ON    	orig_geo_ego.ego_deu_loads
    USING     	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.ego_deu_loads TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads OWNER TO oeuser;

---------- ---------- ----------

-- "Update Area (area_ha)"   (OK!) -> 14.000ms =182.430
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	area_ha = t2.area
FROM    (
	SELECT	loads.id,
		ST_AREA(ST_TRANSFORM(loads.geom,3035))/10000 AS area
	FROM	orig_geo_ego.ego_deu_loads AS loads
	) AS t2
WHERE  	t1.id = t2.id;

-- "Validate Area (area_ha) kleiner 100m²"   (OK!) 500ms =1.257
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_loads_error_area_ha_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_geo_ego.ego_deu_loads_error_area_ha_mview AS 
	SELECT 	loads.id AS id,
		loads.area_ha AS area_ha,
		loads.geom AS geom
	FROM 	orig_geo_ego.ego_deu_loads AS loads
	WHERE	loads.area_ha < 0.001;
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.ego_deu_loads_error_area_ha_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_error_area_ha_mview OWNER TO oeuser;


-- "Remove Errors (area_ha)"   (OK!) 700ms =1.257
DELETE FROM	orig_geo_ego.ego_deu_loads AS loads
	WHERE	loads.area_ha < 0.001;

-- "Validate Area (area_ha) Check"   (OK!) 84.000ms =81.161
SELECT 	loads.id AS id,
	loads.area_ha AS area_ha,
	loads.geom AS geom
FROM 	orig_geo_ego.ego_deu_loads AS loads
WHERE	loads.area_ha <= 2;



---------- ---------- ---------- ---------- ---------- ----------
-- "Calculate"
---------- ---------- ---------- ---------- ---------- ----------

---------- ---------- ----------
-- "Geometries"
---------- ---------- ----------

-- "Update Centroid"   (OK!) -> 28.000ms =181.173
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	geom_centroid = t2.geom_centroid
FROM    (
	SELECT	loads.id AS id,
		ST_Centroid(loads.geom) AS geom_centroid
	FROM	orig_geo_ego.ego_deu_loads AS loads
	) AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_centroid)"   (OK!) -> 4.000ms =0
CREATE INDEX  	ego_deu_loads_geom_centroid_idx
    ON    	orig_geo_ego.ego_deu_loads
    USING     	GIST (geom_centroid);
    
---------- ---------- ----------

-- "Update PointOnSurface"   (OK!) -> 50.000ms =181.173
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	geom_surfacepoint = t2.geom_surfacepoint
FROM    (
	SELECT	loads.id AS id,
		ST_PointOnSurface(loads.geom) AS geom_surfacepoint
	FROM	orig_geo_ego.ego_deu_loads AS loads
	) AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_surfacepoint)"   (OK!) ->  3.000ms =0
CREATE INDEX  	ego_deu_loads_geom_surfacepoint_idx
    ON    	orig_geo_ego.ego_deu_loads
    USING     	GIST (geom_surfacepoint);


---------- ---------- ----------
-- "Update Centre"
---------- ---------- ----------

-- "Update Centre with centroid if inside area"   (OK!) -> 19.000ms =174.097
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	geom_centre = t2.geom_centre
FROM	(
	SELECT	loads.id AS id,
		loads.geom_centroid AS geom_centre
	FROM	orig_geo_ego.ego_deu_loads AS loads
	WHERE  	loads.geom && loads.geom_centroid AND
		ST_CONTAINS(loads.geom,loads.geom_centroid)
	)AS t2
WHERE  	t1.id = t2.id;

-- "Update Centre with surfacepoint if outside area"   (OK!) -> 2.000ms =7.076
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	geom_centre = t2.geom_centre
FROM	(
	SELECT	loads.id AS id,
		loads.geom_surfacepoint AS geom_centre
	FROM	orig_geo_ego.ego_deu_loads AS loads
	WHERE  	loads.geom_centre IS NULL
	)AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_centre)"   (OK!) -> 2.000ms =0
CREATE INDEX  	ego_deu_loads_geom_centre_idx
    ON    	orig_geo_ego.ego_deu_loads
    USING     	GIST (geom_centre);

-- "Validate Centre"   (OK!) -> 1.000ms =0
	SELECT	loads.id AS id
	FROM	orig_geo_ego.ego_deu_loads AS loads
	WHERE  	NOT ST_CONTAINS(loads.geom,loads.geom_centre);

---------- ---------- ----------

-- "Surfacepoint outside area"   (OK!) 2.000ms =7.076
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_loads_centre_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_geo_ego.ego_deu_loads_centre_mview AS 
	SELECT	loads.id AS id,
		ST_Centroid(loads.geom) ::geometry(POINT,3035) AS geom_centroid
	FROM	orig_geo_ego.ego_deu_loads AS loads
	WHERE  	NOT ST_CONTAINS(loads.geom,loads.geom_centroid);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.ego_deu_loads_centre_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_centre_mview OWNER TO oeuser;

---------- ---------- ----------
-- "Calculate Zensus2011 Population"
---------- ---------- ----------

-- "Zensus2011 Population"   (OK!) -> 411.000ms =163.465
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	zensus_sum = t2.zensus_sum,
	zensus_count = t2.zensus_count,
	zensus_density = t2.zensus_density
FROM    (SELECT	loads.id AS id,
		SUM(pts.population)::integer AS zensus_sum,
		COUNT(pts.geom)::integer AS zensus_count,
		(SUM(pts.population)/COUNT(pts.geom))::numeric AS zensus_density
	FROM	orig_geo_ego.ego_deu_loads AS loads,
		orig_destatis.zensus_population_per_ha_mview AS pts
	WHERE  	loads.geom && pts.geom AND
		ST_CONTAINS(loads.geom,pts.geom)
	GROUP BY loads.id
	)AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------
-- "Calculate IÖR Industry Share"
---------- ---------- ----------

-- "IÖR Industry Share"   (OK!) -> 167.000ms =42.120
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	ioer_sum = t2.ioer_sum,
	ioer_count = t2.ioer_count,
	ioer_density = t2.ioer_density
FROM    (SELECT	loads.id AS id,
		SUM(pts.ioer_share)/100::numeric AS ioer_sum,
		COUNT(pts.geom)::integer AS ioer_count,
		(SUM(pts.ioer_share)/COUNT(pts.geom))::numeric AS ioer_density
	FROM	orig_geo_ego.ego_deu_loads AS loads,
		orig_ioer.ioer_urban_share_industrial_centroid AS pts
	WHERE  	loads.geom && pts.geom AND
		ST_CONTAINS(loads.geom,pts.geom)
	GROUP BY loads.id
	)AS t2
WHERE  	t1.id = t2.id;


---------- ---------- ----------
-- "Calculate Sectors"
---------- ---------- ----------

-- "Calculate Sector Residential"   (OK!) -> 64.000ms =11.873
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	sector_area_residential = t2.sector_area,
	sector_count_residential = t2.sector_count,
	sector_share_residential = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	orig_geo_ego.osm_deu_polygon_urban_sector_1_residential_mview AS sector,
		orig_geo_ego.ego_deu_loads AS loads	
	WHERE  	loads.geom && sector.geom AND  
		ST_CONTAINS(loads.geom,sector.geom)
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Sector Retail"   (OK!) -> 800.000ms =2.997
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	sector_area_retail = t2.sector_area,
	sector_count_retail = t2.sector_count,
	sector_share_retail = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	orig_geo_ego.osm_deu_polygon_urban_sector_2_retail_mview AS sector,
		orig_geo_ego.ego_deu_loads AS loads	
	WHERE  	loads.geom && sector.geom AND  
		ST_CONTAINS(loads.geom,sector.geom)
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Sector Industrial"   (OK!) -> 1.320.000ms =4.118
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	sector_area_industrial = t2.sector_area,
	sector_count_industrial = t2.sector_count,
	sector_share_industrial = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	orig_geo_ego.osm_deu_polygon_urban_sector_3_industrial_mview AS sector,
		orig_geo_ego.ego_deu_loads AS loads	
	WHERE  	loads.geom && sector.geom AND  
		ST_CONTAINS(loads.geom,sector.geom)
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Sector Agricultural"   (OK!) -> 1.856.000ms =5.270
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	sector_area_agricultural = t2.sector_area,
	sector_count_agricultural = t2.sector_count,
	sector_share_agricultural = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	orig_geo_ego.osm_deu_polygon_urban_sector_4_agricultural_mview AS sector,
		orig_geo_ego.ego_deu_loads AS loads	
	WHERE  	loads.geom && sector.geom AND  
		ST_CONTAINS(loads.geom,sector.geom)
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;


---------- ---------- ----------
-- "Calculate Codes"   2016-04-06 18:01
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

-- "Calculate NUTS"   (OK!) -> 42.000ms =181.157
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	nuts = t2.nuts
FROM    (
	SELECT	loads.id AS id,
		vg.nuts AS nuts
	FROM	orig_geo_ego.ego_deu_loads AS loads,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && loads.geom_centre AND
		ST_CONTAINS(vg.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Regionalschlüssel"   (OK!) -> 47.000ms =181.157
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	rs = t2.rs
FROM    (
	SELECT	loads.id AS id,
		vg.rs AS rs
	FROM	orig_geo_ego.ego_deu_loads AS loads,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && loads.geom_centre AND
		ST_CONTAINS(vg.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Gemeindeschlüssel"   (OK!) -> 50.000ms =181.157
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	ags_0 = t2.ags_0
FROM    (
	SELECT	loads.id AS id,
		vg.ags_0 AS ags_0
	FROM	orig_geo_ego.ego_deu_loads AS loads,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && loads.geom_centre AND
		ST_CONTAINS(vg.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

-- "Loads without AGS"   (OK!) 500ms =16
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_loads_error_noags_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_geo_ego.ego_deu_loads_error_noags_mview AS 
	SELECT	loads.id,
		loads.geom
	FROM	orig_geo_ego.ego_deu_loads AS loads
	WHERE  	loads.ags_0 IS NULL;

---------- ---------- ----------

-- "Calculate MV-Key"   (OK!) -> 55.000ms =181.068
UPDATE 	orig_geo_ego.ego_deu_loads AS t1
SET  	mv_poly_id = t2.mv_poly_id
FROM    (
	SELECT	loads.id AS id,
		mv.id AS mv_poly_id
	FROM	orig_geo_ego.ego_deu_loads AS loads,
		orig_geo_ego.ego_deu_mv_gridcell_full_mview AS mv
	WHERE  	mv.geom && loads.geom_centre AND
		ST_CONTAINS(mv.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

-- "Loads without MV"   (OK!) 500ms =105
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_loads_error_nomv_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_geo_ego.ego_deu_loads_error_nomv_mview AS 
	SELECT	loads.id,
		loads.geom
	FROM	orig_geo_ego.ego_deu_loads AS loads
	WHERE  	loads.mv_poly_id IS NULL;



---------- ---------- ----------
-- "Create SPF"   2016-04-07 11:34   3s
---------- ---------- ----------

-- "Create Table SPF"   (OK!) 3.000ms =884
DROP TABLE IF EXISTS  	orig_geo_ego.ego_deu_loads_spf;
CREATE TABLE         	orig_geo_ego.ego_deu_loads_spf AS
	SELECT	loads.*
	FROM	orig_geo_ego.ego_deu_loads AS loads,
		orig_geo_vg250.vg250_4_krs_spf_mview AS spf
	WHERE	ST_TRANSFORM(spf.geom,3035) && loads.geom  AND  
		ST_CONTAINS(ST_TRANSFORM(spf.geom,3035), loads.geom_centre)
	ORDER BY loads.id;

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	orig_geo_ego.ego_deu_loads_spf
	ADD PRIMARY KEY (id);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_loads_spf_geom_idx
	ON	orig_geo_ego.ego_deu_loads_spf
	USING	GIST (geom);

-- "Create Index GIST (geom_centre)"   (OK!) -> 150ms =0
CREATE INDEX  	ego_deu_loads_spf_geom_centre_idx
    ON    	orig_geo_ego.ego_deu_loads_spf
    USING     	GIST (geom_centre);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_ego.ego_deu_loads_spf TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_spf OWNER TO oeuser;