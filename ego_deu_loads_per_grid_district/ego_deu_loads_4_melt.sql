---------- ---------- ----------
---------- --SKRIPT-- OK! 72min
---------- ---------- ----------

---------- ---------- ---------- ---------- ---------- ----------
-- "Collect Loads"   2016-04-18 10:00 40s
---------- ---------- ---------- ---------- ---------- ----------

-- "Loads OSM & Loads Zensus Cluster"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_ego.ego_deu_loads_collect CASCADE;
CREATE TABLE		orig_ego.ego_deu_loads_collect (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT	ego_deu_loads_collect_pkey PRIMARY KEY (id));

-- "Insert Loads OSM"   (OK!) 7.000ms =169.639
INSERT INTO	orig_ego.ego_deu_loads_collect (geom)
	SELECT	osm.geom
	FROM	orig_ego.ego_deu_loads_osm AS osm;

-- "Insert Loads Zensus Cluster"   (OK!) 3.000ms =454.112
INSERT INTO	orig_ego.ego_deu_loads_collect (geom)
	SELECT	zensus.geom
	FROM	orig_ego.ego_deu_loads_zensus_cluster AS zensus;

-- "Create Index GIST (geom)"   (OK!) 7.000ms =0
CREATE INDEX	ego_deu_loads_collect_geom_idx
	ON	orig_ego.ego_deu_loads_collect
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =600.828
GRANT ALL ON TABLE	orig_ego.ego_deu_loads_collect TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_collect OWNER TO oeuser;



---------- ---------- ----------
-- "Buffer (100m)"   2016-04-06 11:41 45min (22.000.000s)
---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.ego_deu_loads_collect_buffer100_mview_id CASCADE;
CREATE SEQUENCE 		orig_ego.ego_deu_loads_collect_buffer100_mview_id;

-- "Buffer100"   (OK!) 21.832.000ms =143.227
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_loads_collect_buffer100_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_loads_collect_buffer100_mview AS
	SELECT	nextval('orig_ego.ego_deu_loads_collect_buffer100_mview_id') AS id,
		(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(poly.geom, 100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_loads_collect AS poly;

-- "Create Index (id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_loads_collect_buffer100_mview_id_idx
		ON	orig_ego.ego_deu_loads_collect_buffer100_mview (id);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_mview_geom_idx
	ON	orig_ego.ego_deu_loads_collect_buffer100_mview
	USING	GIST (geom);
    
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_loads_collect_buffer100_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_collect_buffer100_mview OWNER TO oeuser;

---------------------------

-- -- "Validate (geom)"   (OK!) -> 100ms =0
-- DROP VIEW IF EXISTS	orig_ego.ego_deu_loads_collect_buffer100_mview_error_geom_view CASCADE;
-- CREATE VIEW		orig_ego.ego_deu_loads_collect_buffer100_mview_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,					-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	orig_ego.ego_deu_loads_collect_buffer100_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_ego.ego_deu_loads_collect_buffer100_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_loads_collect_buffer100_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 5.000ms =1
-- SELECT f_drop_view('{ego_deu_loads_collect_buffer100_mview_error_geom_view}', 'orig_ego');


---------- ---------- ----------
-- Alternative Calculation with Table
---------- ---------- ----------

-- -- "Create Table"   (OK!) 100ms =0
-- DROP TABLE IF EXISTS	orig_ego.ego_deu_loads_collect_buffer100;
-- CREATE TABLE		orig_ego.ego_deu_loads_collect_buffer100 (
-- 		id SERIAL,
-- 		geom geometry(Polygon,3035),
-- CONSTRAINT 	ego_deu_loads_collect_buffer100_pkey PRIMARY KEY (id));
-- 
-- -- "Insert Buffer"   (OK!) 3.700.000ms =140.578 (151.436)
-- INSERT INTO	orig_ego.ego_deu_loads_collect_buffer100 (geom)
-- 	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
-- 			ST_BUFFER(ST_TRANSFORM(poly.geom,3035), 100)
-- 		)))).geom ::geometry(Polygon,3035) AS geom
-- 	FROM	orig_ego.ego_deu_loads_collect AS poly;
-- 
-- -- "Create Index GIST (geom)"   (OK!) 2.000ms =0
-- CREATE INDEX	ego_deu_loads_collect_buffer100_geom_idx
-- 	ON	orig_ego.ego_deu_loads_collect_buffer100
-- 	USING	GIST (geom);
--     
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_ego.ego_deu_loads_collect_buffer100 TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_loads_collect_buffer100 OWNER TO oeuser;



---------- ---------- ---------- ---------- ---------- ----------
-- "Unbuffer (-100m)"   2016-04-06 12:57 6min (1.334s)
---------- ---------- ---------- ---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.ego_deu_loads_melted_mview_id CASCADE;
CREATE SEQUENCE 		orig_ego.ego_deu_loads_melted_mview_id;


-- "Create Table"   (OK!) 340.000ms =189.104
DROP TABLE IF EXISTS	orig_ego.ego_deu_loads_melted CASCADE;
CREATE TABLE		orig_ego.ego_deu_loads_melted AS
	SELECT	nextval('orig_ego.ego_deu_loads_melted_mview_id') AS id,
		(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(buffer.geom, -100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_loads_collect_buffer100_mview AS buffer
	GROUP BY buffer.id
	ORDER BY buffer.id;

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	orig_ego.ego_deu_loads_melted
	ADD PRIMARY KEY (id);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	ego_deu_loads_melted_geom_idx
	ON	orig_ego.ego_deu_loads_melted
	USING	GIST (geom);
    
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_loads_melted TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_melted OWNER TO oeuser;

---------- ---------- ----------
-- 
-- "Validate (geom)"   (OK!) -> 100ms =0
DROP VIEW IF EXISTS	orig_ego.ego_deu_loads_melted_error_geom_view CASCADE;
CREATE VIEW		orig_ego.ego_deu_loads_melted_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
		test.geom ::geometry(Polygon,3035) AS geom
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_ego.ego_deu_loads_melted AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_loads_melted_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_melted_error_geom_view OWNER TO oeuser;

-- -- "Drop empty view"   (OK!) -> 3.000ms =1
-- SELECT f_drop_view('{ego_deu_loads_melted_error_geom_view}', 'orig_ego');

-- "Error"   (OK!) 3.753.000ms =143.293
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_loads_melted_error_geom_mview;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_loads_melted_error_geom_mview AS
	SELECT	error.*
	FROM	orig_ego.ego_deu_loads_melted_error_geom_view AS error;

-- "Create Index (id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_loads_melted_error_geom_mview_id_idx
		ON	orig_ego.ego_deu_loads_melted_error_geom_mview (id);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	ego_deu_loads_melted_error_geom_mview_geom_idx
	ON	orig_ego.ego_deu_loads_melted_error_geom_mview
	USING	GIST (geom);
    
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_loads_melted_error_geom_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_melted_error_geom_mview OWNER TO oeuser;

---------- ---------- ----------
-- Alternative Calculation with Table
---------- ---------- ----------

-- -- "Create Table"   (OK!) 100ms =0
-- DROP TABLE IF EXISTS	orig_ego.ego_deu_loads_collect_buffer100_unbuffer CASCADE;
-- CREATE TABLE		orig_ego.ego_deu_loads_collect_buffer100_unbuffer (
-- 		id SERIAL,
-- 		geom geometry(Polygon,3035),
-- 		geom_centroid geometry(Point,3035),
-- CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_pkey PRIMARY KEY (id));
-- 
-- -- "Insert Unbuffer"   (OK!) 331.000ms =182.430
-- INSERT INTO	orig_ego.ego_deu_loads_collect_buffer100_unbuffer (geom)
-- 	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
-- 			ST_BUFFER(buffer.geom, -100)
-- 		)))).geom ::geometry(Polygon,3035) AS geom
-- 	FROM	orig_ego.ego_deu_loads_collect_buffer100 AS buffer
-- 	GROUP BY buffer.id
-- 	ORDER BY buffer.id;
-- 
-- -- "Create Index GIST (geom)"   (OK!) 2.000ms =0
-- CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_geom_idx
-- 	ON	orig_ego.ego_deu_loads_collect_buffer100_unbuffer
-- 	USING	GIST (geom);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_ego.ego_deu_loads_collect_buffer100_unbuffer TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_loads_collect_buffer100_unbuffer OWNER TO oeuser;

-- -- "Update Buffer (100m)"   (OK!) -> 230.000ms =202.131
-- UPDATE 	orig_ego.ego_deu_loads_collect_buffer100_unbuffer AS t1
-- SET  	geom_buffer = t2.geom_buffer
-- FROM    (
-- 	SELECT	poly.id AS id,
-- 		ST_BUFFER(ST_TRANSFORM(poly.geom,3035), 100) AS geom_buffer
-- 	FROM	orig_ego.ego_deu_loads_collect_buffer100_unbuffer AS poly
-- 	) AS t2
-- WHERE  	t1.id = t2.id;
-- 
-- -- "Create Index GIST (geom_buffer)"   (OK!) 3.000ms =0
-- CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_geom_buffer_idx
-- 	ON	orig_ego.ego_deu_loads_collect_buffer100_unbuffer
-- 	USING	GIST (geom_buffer);

-- -- "Update Centroid"   (OK!) -> 16.000ms =182.430
-- UPDATE 	orig_ego.ego_deu_loads_collect_buffer100_unbuffer AS t1
-- SET  	geom_centroid = t2.geom_centroid
-- FROM    (
-- 	SELECT	la.id AS id,
-- 		ST_Centroid(la.geom) AS geom_centroid
-- 	FROM	orig_ego.ego_deu_loads_collect_buffer100_unbuffer AS la	
-- 	) AS t2
-- WHERE  	t1.id = t2.id;
-- 
-- -- "Create Index GIST (geom_centroid)"   (OK!) -> 5.000ms =0
-- CREATE INDEX  	ego_deu_loads_collect_buffer100_unbuffer_geom_centroid_idx
--     ON    	orig_ego.ego_deu_loads_collect_buffer100_unbuffer
--     USING     	GIST (geom_centroid);



---------- ---------- ---------- ---------- ---------- ----------
-- "Error Fix with Buffer-Unbuffer-Combo"   2016-04-06 13:07   s
---------- ---------- ---------- ---------- ---------- ----------

-- Fix geoms with error (OK!) 25.000ms =3
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_loads_melted_error_geom_fix_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_loads_melted_error_geom_fix_mview AS 
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
		FROM	orig_ego.ego_deu_loads_melted_error_geom_mview AS fehler
		) AS fix
	ORDER BY fix.id;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_loads_melted_error_geom_fix_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_melted_error_geom_fix_mview OWNER TO oeuser;


-- Update Fixed geoms (OK!) 200ms =2
UPDATE 	orig_ego.ego_deu_loads_melted AS t1
SET	geom = t2.geom
FROM	(
	SELECT	fix.id AS id,
		fix.geom AS geom
	FROM	orig_ego.ego_deu_loads_melted_error_geom_fix_mview AS fix
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
	FROM	orig_ego.ego_deu_loads_melted AS source
	) AS test
WHERE	test.error = FALSE;

---------- ---------- ----------
-- Alternative Calculation with MView
---------- ---------- ----------
-- 
-- -- Fix geom_buffer with error (OK!) 300ms =8
-- DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview CASCADE;
-- CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview AS 
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
-- 		FROM	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_mview AS fehler
-- 		) AS fix
-- 	ORDER BY fix.id;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview OWNER TO oeuser;
-- 
-- 
-- -- Update Fixed geoms (OK!) 200ms =6
-- UPDATE 	orig_ego.ego_deu_loads_collect_buffer100_unbuffer AS t1
-- SET	geom_buffer = t2.geom
-- FROM	(
-- 	SELECT	fix.id AS id,
-- 		fix.geom AS geom
-- 	FROM	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_error_geom_buffer_fix_mview AS fix
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
-- 		FROM	orig_ego.ego_deu_loads_collect_buffer100_unbuffer AS source
-- 		) AS test
-- 	WHERE	test.error = FALSE;




-- ---------- ---------- ----------
-- -- Cut Loads with vg250_gem_dump 22.837s
-- ---------- ---------- ----------
-- 
-- -- "Create Table"   (OK!) 100ms =0
-- DROP TABLE IF EXISTS	orig_ego.ego_deu_loads_melted_cut_gem CASCADE;
-- CREATE TABLE		orig_ego.ego_deu_loads_melted_cut_gem (
-- 		id SERIAL,
-- 		geom geometry(Polygon,3035),
-- CONSTRAINT	ego_deu_loads_melted_cut_gem_pkey PRIMARY KEY (id));
-- 
-- -- "Insert Cut"   (OK!) 330.000ms =188.998
-- INSERT INTO	orig_ego.ego_deu_loads_melted_cut_gem (geom)
-- 	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom,cut.geom))).geom ::geometry(Polygon,3035) AS geom
-- 	FROM	orig_ego.ego_deu_loads_melted AS poly,
-- 		orig_geo_vg250.vg250_6_gem_dump_mview AS cut
-- 	WHERE	poly.geom && cut.geom;
-- 
-- -- "Create Index GIST (geom)"   (OK!) 2.500ms =0
-- CREATE INDEX	ego_deu_loads_melted_cut_gem_geom_idx
-- 	ON	orig_ego.ego_deu_loads_melted_cut_gem
-- 	USING	GIST (geom);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_ego.ego_deu_loads_melted_cut_gem TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_loads_melted_cut_gem OWNER TO oeuser;



-- ---------- ---------- ----------
-- -- "Create SPF"   2016-04-06 14:50   3s
-- ---------- ---------- ----------
-- 
-- -- "Create Table SPF"   (OK!) 3.000ms =886
-- DROP TABLE IF EXISTS  	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_spf;
-- CREATE TABLE         	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_spf AS
-- 	SELECT	lc.*
-- 	FROM	orig_ego.ego_deu_loads_collect_buffer100_unbuffer AS lc,
-- 		orig_geo_vg250.vg250_4_krs_spf_mview AS spf
-- 	WHERE	ST_TRANSFORM(spf.geom,3035) && lc.geom  AND  
-- 		ST_CONTAINS(ST_TRANSFORM(spf.geom,3035), lc.geom_centroid);
-- 
-- -- "Ad PK"   (OK!) 150ms =0
-- ALTER TABLE	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_spf
-- 	ADD PRIMARY KEY (id);
-- 
-- -- "Create Index GIST (geom)"   (OK!) -> 100ms =0
-- CREATE INDEX  	ego_deu_loads_collect_buffer100_unbuffer_spf_geom_idx
-- 	ON	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_spf
-- 	USING	GIST (geom);
-- 
-- -- "Create Index GIST (geom_centroid)"   (OK!) -> 150ms =0
-- CREATE INDEX  	ego_deu_loads_collect_buffer100_unbuffer_spf_geom_centroid_idx
--     ON    	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_spf
--     USING     	GIST (geom_centroid);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_spf TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_loads_collect_buffer100_unbuffer_spf OWNER TO oeuser;
-- 
-- ---------- ---------- ----------
