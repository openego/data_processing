---------- ---------- ----------
---------- --SKRIPT-- OK! 13s
---------- ---------- ----------


---------- ---------- ---------- ---------- ---------- ----------
-- Data Setup vg250   2016-05-20 17:00 36s
---------- ---------- ---------- ---------- ---------- ----------
-- 
-- -- Validate 1_sta (geom)   (OK!) -> 500ms =1
-- DROP VIEW IF EXISTS	orig_vg250.vg250_1_sta_error_geom_view CASCADE;
-- CREATE VIEW		orig_vg250.vg250_1_sta_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),31467) ::geometry(Point,31467) AS geom
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	orig_vg250.vg250_1_sta AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_vg250.vg250_1_sta_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_vg250.vg250_1_sta_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{vg250_1_sta_error_geom_view}', 'orig_vg250');

-- Error   (OK!) 47.000ms =143.293
DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_1_sta_error_geom_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_vg250.vg250_1_sta_error_geom_mview AS 
	SELECT	test.id AS id,
		test.error AS error,
		test.error_reason AS error_reason,
		ST_SETSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS geom
	FROM	(
		SELECT	source.gid AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			reason(ST_IsValidDetail(source.geom)) AS error_reason,
			source.geom AS geom
		FROM	orig_vg250.vg250_1_sta AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- Create Index (gid)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_1_sta_error_geom_mview_id_idx
		ON	orig_vg250.vg250_1_sta_error_geom_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	vg250_1_sta_error_geom_mview_geom_idx
	ON	orig_vg250.vg250_1_sta_error_geom_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_vg250.vg250_1_sta_error_geom_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_vg250.vg250_1_sta_error_geom_mview OWNER TO oeuser;
DROP VIEW IF EXISTS	orig_vg250.vg250_1_sta_error_geom_view CASCADE;


---------- ---------- ----------
-- orig_vg250.vg250_1_sta_mview - With tiny buffer because of intersection (in official data)
---------- ---------- ----------

-- Transform vg250 State   (OK!) -> 500ms =11
DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_1_sta_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_vg250.vg250_1_sta_mview AS
	SELECT	vg.gid ::integer,
		vg.bez ::text,
		vg.gf ::double precision,
		ST_AREA(ST_TRANSFORM(vg.geom, 3035)) / 10000 ::double precision AS area_km2,
		ST_MULTI(ST_BUFFER(ST_TRANSFORM(vg.geom,3035),-0.001)) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_vg250.vg250_1_sta AS vg
	ORDER BY vg.gid;

-- Create Index (gid)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_1_sta_mview_gid_idx
		ON	orig_vg250.vg250_1_sta_mview (gid);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	vg250_1_sta_mview_geom_idx
	ON	orig_vg250.vg250_1_sta_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_vg250.vg250_1_sta_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_vg250.vg250_1_sta_mview OWNER TO oeuser;

---------- ---------- ----------
-- 
-- -- Validate (geom)   (OK!) -> 500ms =1
-- DROP VIEW IF EXISTS	orig_vg250.vg250_1_sta_mview_error_geom_view CASCADE;
-- CREATE VIEW		orig_vg250.vg250_1_sta_mview_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(MultiPolygon,3035) AS geom
-- 		FROM	orig_vg250.vg250_1_sta_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_vg250.vg250_1_sta_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_vg250.vg250_1_sta_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{vg250_1_sta_mview_error_geom_view}', 'orig_vg250');

---------- ---------- ----------
-- orig_vg250.vg250_1_sta_union_mview
---------- ---------- ----------

-- Transform VG250 State UNION   (OK!) -> 2.000ms =1
DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_1_sta_union_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_vg250.vg250_1_sta_union_mview AS
	SELECT	'1' ::integer AS gid,
		'Bundesrepublik' ::text AS bez,
		ST_AREA(un.geom) / 10000 ::double precision AS area_km2,
		un.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT	ST_MakeValid(ST_UNION(ST_TRANSFORM(vg.geom,3035))) ::geometry(MultiPolygon,3035) AS geom
		FROM	orig_vg250.vg250_1_sta AS vg
		WHERE	vg.bez = 'Bundesrepublik') AS un;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_1_sta_union_mview_id_idx
		ON	orig_vg250.vg250_1_sta_union_mview (gid);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	vg250_1_sta_union_mview_geom_idx
	ON	orig_vg250.vg250_1_sta_union_mview
	USING	GIST (geom);
	
-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_vg250.vg250_1_sta_union_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_vg250.vg250_1_sta_union_mview OWNER TO oeuser;


---------- ---------- ----------
-- orig_vg250.vg250_1_sta_mview - With tiny buffer because of intersection (in official data)
---------- ---------- ----------

-- Transform vg250 State   (OK!) -> 11.000ms =11
DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_2_lan_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_vg250.vg250_2_lan_mview AS
	SELECT	lan.ags_0 ::character varying(12) AS ags_0,
		lan.gen ::text AS gen,
		ST_UNION(ST_TRANSFORM(lan.geom,3035)) AS geom
	FROM	(SELECT	vg.ags_0,
			replace( vg.gen, ' (Bodensee)', '') as gen,
			vg.geom
		FROM	orig_vg250.vg250_2_lan AS vg ) AS lan
	GROUP BY lan.ags_0,lan.gen
	ORDER BY lan.ags_0;

-- Create Index (gid)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_2_lan_mview_ags_0_idx
		ON	orig_vg250.vg250_2_lan_mview (ags_0);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	vg250_2_lan_mview_geom_idx
	ON	orig_vg250.vg250_2_lan_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_vg250.vg250_2_lan_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_vg250.vg250_2_lan_mview OWNER TO oeuser;

---------- ---------- ----------
-- orig_vg250.vg250_4_krs_mview
---------- ---------- ----------

-- Transform VG250 Kreise   (OK!) -> 1.000ms =432
DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_4_krs_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_vg250.vg250_4_krs_mview AS
	SELECT	vg.gid ::integer AS gid,
		vg.gen ::text AS gen,
		vg.bez ::text AS bez,
		vg.nuts ::varchar(5) AS nuts,
		vg.rs_0 ::varchar(12) AS rs_0,
		vg.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(vg.geom) / 10000 ::double precision AS area_km2,
		ST_TRANSFORM(vg.geom,3035) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_vg250.vg250_4_krs AS vg
	ORDER BY vg.gid;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_4_krs_mview_gid_idx
		ON	orig_vg250.vg250_4_krs_mview (gid);

-- Create Index GIST (geom)   (OK!) -> 200ms =0
CREATE INDEX  	vg250_4_krs_mview_geom_idx
	ON	orig_vg250.vg250_4_krs_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_vg250.vg250_4_krs_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_vg250.vg250_4_krs_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_vg250.vg250_4_krs_mview_error_geom_view CASCADE;
-- CREATE VIEW		orig_vg250.vg250_4_krs_mview_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(MultiPolygon,3035) AS geom
-- 		FROM	orig_vg250.vg250_4_krs_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_vg250.vg250_4_krs_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_vg250.vg250_4_krs_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{vg250_4_krs_mview_error_geom_view}', 'orig_vg250');


---------- ---------- ----------
-- orig_vg250.vg250_6_gem
---------- ---------- ----------

-- -- Create Index GIST (geom)   (OK!) -> 100ms =0
-- CREATE INDEX  	vg250_6_gem_geom_idx
-- 	ON	orig_vg250.vg250_6_gem
-- 	USING	GIST (geom);

-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_vg250.vg250_6_gem_error_geom_view CASCADE;
-- CREATE VIEW		orig_vg250.vg250_6_gem_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),31467) ::geometry(Point,31467) AS error_location,
-- 		test.geom ::geometry(MultiPolygon,31467) AS error_geom
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(MultiPolygon,31467) AS geom
-- 		FROM	orig_vg250.vg250_6_gem AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_vg250.vg250_6_gem_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_vg250.vg250_6_gem_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{vg250_6_gem_error_geom_view}', 'orig_vg250');


---------- ---------- ----------
-- orig_vg250.vg250_6_gem_mview
---------- ---------- ----------

-- Transform VG250 Gemeinden   (OK!) -> 2.000ms =11.431
DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_6_gem_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_vg250.vg250_6_gem_mview AS
	SELECT	vg.gid ::integer AS gid,
		vg.gen ::text AS gen,
		vg.bez ::text AS bez,
		vg.bem ::text AS bem,
		vg.nuts ::varchar(5) AS nuts,
		vg.rs_0 ::varchar(12) AS rs_0,
		vg.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(vg.geom) / 1000 ::double precision AS area_ha,
		ST_TRANSFORM(vg.geom,3035) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_vg250.vg250_6_gem AS vg
	ORDER BY vg.gid;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_6_gem_mview_gid_idx
		ON	orig_vg250.vg250_6_gem_mview (gid);

-- Create Index GIST (geom)   (OK!) -> 150ms =0
CREATE INDEX  	vg250_6_gem_mview_geom_idx
	ON	orig_vg250.vg250_6_gem_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_vg250.vg250_6_gem_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_vg250.vg250_6_gem_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_vg250.vg250_6_gem_mview_error_geom_view CASCADE;
-- CREATE VIEW		orig_vg250.vg250_6_gem_mview_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
-- 		test.geom ::geometry(MultiPolygon,3035) AS error_geom
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(MultiPolygon,3035) AS geom
-- 		FROM	orig_vg250.vg250_6_gem_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_vg250.vg250_6_gem_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_vg250.vg250_6_gem_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{vg250_6_gem_mview_error_geom_view}', 'orig_vg250');



---------- ---------- ----------
-- orig_vg250.vg250_6_gem_dump_mview
---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_vg250.vg250_6_gem_dump_mview_id CASCADE;
CREATE SEQUENCE 		orig_vg250.vg250_6_gem_dump_mview_id;

-- Transform VG250 Gemeinden   (OK!) -> 5.000ms =12.521
DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_6_gem_dump_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_vg250.vg250_6_gem_dump_mview AS
	SELECT	nextval('orig_vg250.vg250_6_gem_dump_mview_id') AS id,
		vg.gid ::integer AS gid,
		vg.gen ::text AS gen,
		vg.bez ::text AS bez,
		vg.bem ::text AS bem,
		vg.nuts ::varchar(5) AS nuts,
		vg.rs_0 ::varchar(12) AS rs_0,
		vg.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(vg.geom) / 10000 ::double precision AS area_km2,
		ST_MakeValid((ST_DUMP(ST_TRANSFORM(vg.geom,3035))).geom) ::geometry(Polygon,3035) AS geom
	FROM	orig_vg250.vg250_6_gem AS vg
	WHERE	gf = '4' -- Without water
	ORDER BY vg.gid;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_6_gem_dump_mview_gid_idx
		ON	orig_vg250.vg250_6_gem_dump_mview (id);

-- Create Index GIST (geom)   (OK!) -> 150ms =0
CREATE INDEX  	vg250_6_gem_dump_mview_geom_idx
	ON	orig_vg250.vg250_6_gem_dump_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_vg250.vg250_6_gem_dump_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_vg250.vg250_6_gem_dump_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_vg250.vg250_6_gem_dump_mview_error_geom_view CASCADE;
-- CREATE VIEW		orig_vg250.vg250_6_gem_dump_mview_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
-- 		test.geom ::geometry(Polygon,3035) AS geom
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(Polygon,3035) AS geom
-- 		FROM	orig_vg250.vg250_6_gem_dump_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_vg250.vg250_6_gem_dump_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_vg250.vg250_6_gem_dump_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{vg250_6_gem_dump_mview_error_geom_view}', 'orig_vg250');



---------- ---------- ----------
-- orig_ego.vg250_6_gem_clean
---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 		orig_vg250.vg250_6_gem_clean_id CASCADE;
CREATE SEQUENCE 			orig_vg250.vg250_6_gem_clean_id;

-- Transform VG250 Gemeinden   (OK!) -> 1.000ms =12.870
DROP TABLE IF EXISTS	orig_vg250.vg250_6_gem_clean CASCADE;
CREATE TABLE		orig_vg250.vg250_6_gem_clean AS
	SELECT	nextval('orig_vg250.vg250_6_gem_clean_id') AS id,
		dump.gid ::integer AS gid,
		dump.gen ::text AS gen,
		dump.bez ::text AS bez,
		dump.bem ::text AS bem,
		dump.nuts ::varchar(5) AS nuts,
		dump.rs_0 ::varchar(12) AS rs_0,
		dump.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(dump.geom) / 1000 ::double precision AS area_ha,
		dump.count_ring,
		dump.path,
		dump.geom ::geometry(Polygon,3035) AS geom		
	FROM	(SELECT vg.gid,
			vg.gen,
			vg.bez,
			vg.bem,
			vg.nuts,
			vg.rs_0,
			vg.ags_0,
			ST_NumInteriorRings(vg.geom) AS count_ring,
			(ST_DumpRings(vg.geom)).path AS path,
			(ST_DumpRings(vg.geom)).geom AS geom
		FROM	orig_vg250.vg250_6_gem_dump_mview AS vg) AS dump;

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	orig_vg250.vg250_6_gem_clean
	ADD COLUMN	is_ring boolean,
	ADD PRIMARY KEY (id);

-- Create Index GIST (geom)   (OK!) -> 150ms =0
CREATE INDEX  	vg250_6_gem_clean_geom_idx
	ON	orig_vg250.vg250_6_gem_clean
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_vg250.vg250_6_gem_clean TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_vg250.vg250_6_gem_clean OWNER TO oeuser;

---------- ---------- ----------

-- separate all holes   (OK!) 30.000ms =350
DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_6_gem_rings_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_vg250.vg250_6_gem_rings_mview AS 
SELECT 	mun.*
FROM	orig_vg250.vg250_6_gem_clean AS mun
WHERE	mun.path[1] <> 0;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_6_gem_rings_mview_id_idx
		ON	orig_vg250.vg250_6_gem_rings_mview (id);

-- Create Index GIST (geom)   (OK!) -> 150ms =0
CREATE INDEX  	vg250_6_gem_rings_mview_geom_idx
	ON	orig_vg250.vg250_6_gem_rings_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_vg250.vg250_6_gem_rings_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_vg250.vg250_6_gem_rings_mview OWNER TO oeuser;

-- Update Holes   (OK!) -> 2.000ms =696
UPDATE 	orig_vg250.vg250_6_gem_clean AS t1
SET  	is_ring = t2.is_ring
FROM    (
	SELECT	gem.id AS id,
		'TRUE' ::boolean AS is_ring
	FROM	orig_vg250.vg250_6_gem_clean AS gem,
		orig_vg250.vg250_6_gem_rings_mview AS ring
	WHERE  	gem.geom = ring.geom
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- Separate all ringholes   (OK!) 1.000ms =12.174
DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_6_gem_clean_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_vg250.vg250_6_gem_clean_mview AS
	SELECT	vg.*
	FROM	orig_vg250.vg250_6_gem_clean AS vg
	WHERE	vg.is_ring IS NOT TRUE;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_6_gem_clean_mview_id_idx
		ON	orig_vg250.vg250_6_gem_clean_mview (id);

-- Create Index GIST (geom)   (OK!) -> 150ms =0
CREATE INDEX  	vg250_6_gem_clean_mview_geom_idx
	ON	orig_vg250.vg250_6_gem_clean_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_vg250.vg250_6_gem_clean_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_vg250.vg250_6_gem_clean_mview OWNER TO oeuser;


---------- ---------- ----------
-- 
-- -- Spearate all municipalities without rings   (OK!) 30.000ms =350
-- DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_6_gem_clean_mview CASCADE;
-- CREATE MATERIALIZED VIEW 		orig_vg250.vg250_6_gem_clean_mview AS 
-- SELECT 	mun.*
-- FROM	orig_vg250.vg250_6_gem_clean AS mun
-- WHERE	mun.path[1] = 0;
-- 
-- -- Create Index (id)   (OK!) -> 100ms =0
-- CREATE UNIQUE INDEX  	vg250_6_gem_clean_mview_id_idx
-- 		ON	orig_vg250.vg250_6_gem_clean_mview (id);
-- 
-- -- Create Index GIST (geom)   (OK!) -> 150ms =0
-- CREATE INDEX  	vg250_6_gem_clean_mview_geom_idx
-- 	ON	orig_vg250.vg250_6_gem_clean_mview
-- 	USING	GIST (geom);
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_vg250.vg250_6_gem_clean_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_vg250.vg250_6_gem_clean_mview OWNER TO oeuser;

---------- ---------- ----------

---------- ---------- ----------
-- 
-- -- Select all rings rings   (OK!) 1.000ms =341
-- DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_6_gem_clean_rings_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_vg250.vg250_6_gem_clean_rings_mview AS 
-- 	SELECT 	DISTINCT mun.*,
-- 		joi.id AS j_id
-- 	FROM 	orig_vg250.vg250_6_gem_clean_ring_mview AS mun		
-- 	INNER JOIN orig_vg250.vg250_6_gem_clean_ring_mview AS joi
-- 		ON ST_WITHIN(ST_BUFFER(mun.geom,1),joi.geom)
-- 	WHERE	mun.geom && joi.geom;
-- 
-- 
-- -- Create Index (id)   (OK!) -> 100ms =0
-- CREATE UNIQUE INDEX  	vg250_6_gem_clean_rings_mview_id_idx
-- 		ON	orig_vg250.vg250_6_gem_clean_rings_mview (id,j_id);
-- 
-- -- Create Index GIST (geom)   (OK!) -> 150ms =0
-- CREATE INDEX  	vg250_6_gem_clean_rings_mview_geom_idx
-- 	ON	orig_vg250.vg250_6_gem_clean_rings_mview
-- 	USING	GIST (geom);
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_vg250.vg250_6_gem_clean_rings_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_vg250.vg250_6_gem_clean_rings_mview OWNER TO oeuser;

---------- ---------- ----------
-- 
-- -- Update rings   (OK!) -> 160.000ms =2.483.755
-- UPDATE 	orig_vg250.vg250_6_gem_clean AS t1
-- SET  	is_ring = t2.is_ring
-- FROM    (
-- 	SELECT	clean.id AS id,
-- 		'TRUE' ::boolean AS is_ring
-- 	FROM	orig_vg250.vg250_6_gem_clean_rings_mview AS ring,
-- 		orig_vg250.vg250_6_gem_clean AS clean
-- 	WHERE  	clean.id = ring.id
-- 	) AS t2
-- WHERE  	t1.id = t2.id;
-- 
-- -- Spearate all municipalities with rings   (OK!) 1.000ms =12.539
-- DROP MATERIALIZED VIEW IF EXISTS	orig_vg250.vg250_6_gem_clean_mview CASCADE;
-- CREATE MATERIALIZED VIEW 		orig_vg250.vg250_6_gem_clean_mview AS 
-- 	SELECT 	mun.*
-- 	FROM	orig_vg250.vg250_6_gem_clean AS mun
-- 	WHERE	mun.is_ring IS NOT TRUE;
-- 
-- -- Create Index (id)   (OK!) -> 100ms =0
-- CREATE UNIQUE INDEX  	vg250_6_gem_clean_mview_id_idx
-- 		ON	orig_vg250.vg250_6_gem_clean_mview (id);
-- 
-- -- Create Index GIST (geom)   (OK!) -> 150ms =0
-- CREATE INDEX  	vg250_6_gem_clean_mview_geom_idx
-- 	ON	orig_vg250.vg250_6_gem_clean_mview
-- 	USING	GIST (geom);
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_vg250.vg250_6_gem_clean_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_vg250.vg250_6_gem_clean_mview OWNER TO oeuser;

---------- ---------- ----------

CREATE OR REPLACE VIEW orig_vg250.vg250_statistics AS
-- Area Sum
-- 38162814 km²
SELECT	'vg' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
UNION ALL
-- 38141292 km²
SELECT	'deu' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
WHERE	bez='Bundesrepublik'
UNION ALL
-- 38141292 km²
SELECT	'NOT deu' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
WHERE	bez='--'
UNION ALL
-- 35718841 km²
SELECT	'land' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
WHERE	gf='3' OR gf='4'
UNION ALL
-- 35718841 km²
SELECT	'water' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
WHERE	gf='1' OR gf='2';