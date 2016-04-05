
---------- ---------- ---------- ---------- ---------- ----------
-- "Collect Loads"   2016-03-24 17:15 10s
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

-- "Insert Load Points Cluster"   (OK!) 2.000ms =153.267
INSERT INTO	orig_geo_ego.ego_deu_loads_collect (geom)
	SELECT	cl.geom
	FROM	orig_geo_ego.ego_deu_zensus_loadpoints_cluster AS cl;

-- "Create Index GIST (geom)"   (OK!) 4.000ms =0
CREATE INDEX	ego_deu_loads_collect_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect OWNER TO oeuser;

---------- ---------- ---------- ---------- ---------- ----------
-- "Buffer (100m)"   2016-03-24 17:15 45min
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100;
CREATE TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100 (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT 	ego_deu_loads_collect_buffer100_pkey PRIMARY KEY (id));

-- "Insert Buffer"   (OK!) 2.800.000ms =151.436
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
-- "Unbuffer (-100m)"   2016-03-24 18:07 6min
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer CASCADE;
CREATE TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer (
		id SERIAL,
		geom geometry(Polygon,3035),
		geom_buffer geometry(Polygon,3035),
		geom_centroid geometry(Point,3035),
CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_pkey PRIMARY KEY (id));

-- "Insert Unbuffer"   (OK!) 315.000ms =202.131
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer (geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(buffer.geom, -100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100 AS buffer
	GROUP BY buffer.id
	ORDER BY buffer.id;

-- "Create Index GIST (geom)"   (OK!) 3.000ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer
	USING	GIST (geom);

-- "Update Buffer (100m)"   (OK!) -> 230.000ms =202.131
UPDATE 	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS t1
SET  	geom_buffer = t2.geom_buffer
FROM    (
	SELECT	poly.id AS id,
		ST_BUFFER(ST_TRANSFORM(poly.geom,3035), 100) AS geom_buffer
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS poly
	) AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_buffer)"   (OK!) 3.000ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_geom_buffer_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer
	USING	GIST (geom_buffer);

-- "Update Centroid"   (OK!) -> 22.000ms =202.131
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

-- "Validate (geom)"   (OK!) -> 28.000ms =6
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

-- "Validate (geom_buffer)"   (OK!) -> 38.000ms =8
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_mview AS 
	SELECT	test.id AS id,
		test.error AS error,
		reason(ST_IsValidDetail(test.geom_buffer)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom_buffer)),3035) ::geometry(Point,3035) AS error_location,
		ST_TRANSFORM(test.geom_buffer,3035) ::geometry(Polygon,3035) AS geom_buffer
	FROM	(
		SELECT	source.id AS id,
			ST_IsValid(source.geom_buffer) AS error,
			source.geom_buffer ::geometry(Polygon,3035) AS geom_buffer
		FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS source
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_mview OWNER TO oeuser;

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
-- "Fehlerbehebung"   2016-04-05 13:55   s
---------- ---------- ---------- ---------- ---------- ----------

-- Fix geoms with error (OK!) 200ms =6
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


-- Update Fixed geoms (OK!) 200ms =6
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

-- Fix geom_buffer with error (OK!) 300ms =8
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview AS 
	SELECT	fix.id AS id,
		ST_IsValid(fix.geom) AS error,
		GeometryType(fix.geom) AS geom_type,
		ST_AREA(fix.geom) AS area,
		fix.geom_buffer ::geometry(POLYGON,3035) AS geom_buffer,
		fix.geom ::geometry(POLYGON,3035) AS geom
	FROM	(
		SELECT	fehler.id AS id,
			ST_BUFFER(fehler.geom_buffer, -1) AS geom_buffer,
			(ST_DUMP(ST_BUFFER(ST_BUFFER(fehler.geom_buffer, -1), 1))).geom AS geom
		FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_mview AS fehler
		) AS fix
	ORDER BY fix.id;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview OWNER TO oeuser;


-- Update Fixed geoms (OK!) 200ms =6
UPDATE 	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS t1
SET	geom_buffer = t2.geom
FROM	(
	SELECT	fix.id AS id,
		fix.geom AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview AS fix
	) AS t2
WHERE  	t1.id = t2.id;

-- Check for errors again! (OK!) 20.000ms =0
SELECT	test.id AS id,
		test.error AS error,
		reason(ST_IsValidDetail(test.geom_buffer)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom_buffer)),3035) ::geometry(Point,3035) AS error_location,
		ST_TRANSFORM(test.geom_buffer,3035) ::geometry(Polygon,3035) AS geom_buffer
	FROM	(
		SELECT	source.id AS id,
			ST_IsValid(source.geom_buffer) AS error,
			source.geom_buffer ::geometry(Polygon,3035) AS geom_buffer
		FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS source
		) AS test
	WHERE	test.error = FALSE;

---------- ---------- ----------
-- "Create SPF"   2016-04-05 13:55   3s
---------- ---------- ----------

-- "Create Table SPF"   (OK!) 3.000ms =956
DROP TABLE IF EXISTS  	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_spf;
CREATE TABLE         	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_spf AS
	SELECT	lp.*
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS lp,
		orig_geo_vg250.vg250_4_krs_spf_mview AS spf
	WHERE	ST_TRANSFORM(spf.geom,3035) && lp.geom  AND  
		ST_CONTAINS(ST_TRANSFORM(spf.geom,3035), lp.geom_centroid);

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
-- "Cutting"
---------- ---------- ---------- ---------- ---------- ----------

-- "Substations"   (OK!) 100ms =3.711
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_mv_substations_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.ego_deu_mv_substations_mview AS
	SELECT	pts.subst_id AS subst_id,
		pts.voltage AS subst_voltage,
		pts.name AS subst_name,
		ST_TRANSFORM(pts.geom,3035) ::geometry(Point,3035) AS geom
	FROM	calc_gridcells_znes.znes_deu_substations_filtered AS pts;

-- "Cutter"   (OK!) 100ms =3.711
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_mv_gridcell_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.ego_deu_mv_gridcell_mview AS
	SELECT	poly.id AS id,
		(ST_DUMP(ST_TRANSFORM(poly.geom,3035))).geom ::geometry(Polygon,3035) AS geom
	FROM	calc_gridcells_znes.znes_deu_gridcells_qgis AS poly;


-- "Cutter"   (OK!) 100ms =3.711
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


-- "Validate (geom)"   (OK!) -> 22.000ms =0
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
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_mv_gridcell_mview_error_geom_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_mv_gridcell_mview_error_geom_mview OWNER TO oeuser;

---------- ---------- ---------- ----------
-- "Cutting only SPF"   2016-04-04 17:08   1s
---------- ---------- ---------- ----------

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


---------- ---------- ---------- ----------
-- "Cutting DEU Voronoi"
---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut;
CREATE TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut (
		id SERIAL,
		geom geometry(Polygon,3035),
		geom_buffer geometry(Polygon,3035),
CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_cut_pkey PRIMARY KEY (id));
	
-- "Insert Cut"   (OK!) 185.000ms =224.365
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut (geom)
	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom,cut.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS poly,
		orig_geo_ego.ego_deu_mv_gridcell_full_mview AS cut
	WHERE	poly.geom && cut.geom;

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_cut_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut
	USING	GIST (geom);


-- "Insert Cut Buffer"   (OK!) 210.000ms =231.910
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut (geom_buffer)
	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom_buffer,cut.geom))).geom ::geometry(Polygon,3035) AS geom_buffer
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS poly,
		orig_geo_ego.ego_deu_mv_gridcell_full_mview AS cut
	WHERE	poly.geom_buffer && cut.geom;

-- "Create Index GIST (geom_buffer)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_cut_geom_buffer_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut
	USING	GIST (geom_buffer);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut OWNER TO oeuser;



---------- ---------- ---------- ----------
-- "Cutting DEU Gemeinde"
---------- ---------- ---------- ----------

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
		geom geometry(Polygon,3035),
		geom_buffer geometry(Polygon,3035),
CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_cut_gem_pkey PRIMARY KEY (id));

-- "Insert Cut"   (OK!) 185.000ms =224.365
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem (geom)
	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom,cut.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS poly,
		orig_geo_ego.vg250_6_gem_mview AS cut
	WHERE	poly.geom && cut.geom;

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_cut_gem_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem
	USING	GIST (geom);


-- "Insert Cut Buffer"   (OK!) 220.000ms =239.351
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem (geom_buffer)
	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom_buffer,cut.geom))).geom ::geometry(Polygon,3035) AS geom_buffer
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS poly,
		orig_geo_ego.vg250_6_gem_mview AS cut
	WHERE	poly.geom_buffer && cut.geom;

-- "Create Index GIST (geom_buffer)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_cut_gem_geom_buffer_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem
	USING	GIST (geom_buffer);


-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem OWNER TO oeuser;