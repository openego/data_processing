
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


---------- ---------- ---------- ---------- ---------- ----------
-- "Unbuffer (-100m)"   2016-03-24 18:07 6min
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer;
CREATE TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer (
		id SERIAL,
		geom geometry(Polygon,3035),
		geom_centroid geometry(Point,3035),
CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_pkey PRIMARY KEY (id));

-- "Insert Buffer"   (OK!) 350.000ms =202.130
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer (geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(ST_TRANSFORM(buffer.geom,3035), -100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100 AS buffer
	GROUP BY buffer.id
	ORDER BY buffer.id;

-- "Create Index GIST (geom)"   (OK!) 4.000ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer
	USING	GIST (geom);

---------------------------
-- DELETE IF NEW!
ALTER TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer
	ADD COLUMN	geom_centroid geometry(Point,3035);
---------------------------

-- "Update Centroid"   (OK!) -> 20.000ms =202.131
UPDATE 	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS t1
SET  	geom_centroid = t2.geom_centroid
FROM    (
	SELECT	la.id AS id,
		ST_Centroid(la.geom) AS geom_centroid
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS la	
	GROUP BY la.id
	) AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_centroid)"   (OK!) -> 4.000ms =0
CREATE INDEX  	ego_deu_loads_collect_buffer100_unbuffer_geom_centroid_idx
    ON    	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer
    USING     	GIST (geom_centroid);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer OWNER TO oeuser;

---------- ---------- ----------
-- "Create SPF"   2016-03-30 15:55   1s
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
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_mv_gridcell_mview_error_geom_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.ego_deu_mv_gridcell_mview_error_geom_mview AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		location(ST_IsValidDetail(test.geom)) ::geometry(Point,3035) AS error_location,
		ST_TRANSFORM(test.geom,3035) ::geometry(Polygon,3035) AS geom
	FROM	(
		SELECT	source.id AS id,
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_geo_ego.ego_deu_mv_gridcell_mview AS source
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_mv_gridcell_mview_error_geom_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_mv_gridcell_mview_error_geom_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Validate (gid)"   (OK!) -> 500ms =0
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.ego_deu_mv_gridcell_mview_error_gid_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.ego_deu_mv_gridcell_mview_error_gid_mview AS 
	SELECT 		id,
			count(*)
	FROM 		orig_geo_ego.ego_deu_mv_gridcell_mview
	GROUP BY 	id
	HAVING 		count(*) > 1;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_mv_gridcell_mview_error_gid_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_mv_gridcell_mview_error_gid_mview OWNER TO oeuser;


---------- ---------- ---------- ----------
-- "Cutting only SPF"
---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf;
CREATE TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_cut_spf_pkey PRIMARY KEY (id));

-- "Insert Cut"   (OK!) 290.000ms =1038
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf (geom)
	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom,ST_TRANSFORM(cut.geom,3035)))).geom AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_spf AS poly,
		orig_geo_ego.ego_deu_mv_gridcell_full_mview AS cut;

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_cut_spf_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf OWNER TO oeuser;


---------- ---------- ---------- ----------
-- "Cutting DEU"
---------- ---------- ---------- ----------


-- "Create Table"   (OK!) 100ms =
DROP TABLE IF EXISTS	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut;
CREATE TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_cut_pkey PRIMARY KEY (id));
	
-- "Insert Cut"   (???) 350.000ms =
INSERT INTO	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut (geom)
	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom,cut.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer AS poly,
		orig_geo_ego.ego_deu_mv_gridcell_full_mview AS cut;

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_cut_geom_idx
	ON	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_ego.ego_deu_loads_collect_buffer100_unbuffer_cut OWNER TO oeuser;