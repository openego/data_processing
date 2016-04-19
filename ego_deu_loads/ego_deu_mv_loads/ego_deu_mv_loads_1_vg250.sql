
---------- ---------- ---------- ---------- ---------- ----------
-- "1. Data Setup vg250"   2016-04-18 10:00 11s
---------- ---------- ---------- ---------- ---------- ----------

---------- ---------- ----------
-- "Schema"   2016-04-17 21:00 1s
---------- ---------- ----------

-- -- "Create Schema"
-- DROP SCHEMA IF EXISTS	orig_ego;
-- CREATE SCHEMA 		orig_ego;
-- GRANT ALL ON SCHEMA 	orig_ego TO oeuser WITH GRANT OPTION;


---------- ---------- ----------
-- "orig_geo_vg250.vg250_1_sta_mview"
---------- ---------- ----------

-- "Transform vg250 State"   (OK!) -> 500ms =11
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_vg250.vg250_1_sta_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_vg250.vg250_1_sta_mview AS
	SELECT	vg.gid ::integer AS gid,
		vg.bez ::text AS bez,
		vg.water ::boolean AS water,
		ST_AREA(ST_TRANSFORM(vg.geom, 3035)) / 10000 ::double precision AS area_km2,
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

-- -- "Area Sum"
-- -- 38162814 km²
-- SELECT	'vg' ::text AS id,
-- 	SUM(vg.area_km2) ::integer AS area_sum_km2
-- FROM	orig_geo_vg250.vg250_1_sta_mview AS vg
-- UNION ALL
-- -- 38141292 km²
-- SELECT	'deu' ::text AS id,
-- 	SUM(vg.area_km2) ::integer AS area_sum_km2
-- FROM	orig_geo_vg250.vg250_1_sta_mview AS vg
-- WHERE	bez='Bundesrepublik'
-- UNION ALL
-- -- 38141292 km²
-- SELECT	'NOT deu' ::text AS id,
-- 	SUM(vg.area_km2) ::integer AS area_sum_km2
-- FROM	orig_geo_vg250.vg250_1_sta_mview AS vg
-- WHERE	bez='--'
-- UNION ALL
-- -- 35718841 km²
-- SELECT	'land' ::text AS id,
-- 	SUM(vg.area_km2) ::integer AS area_sum_km2
-- FROM	orig_geo_vg250.vg250_1_sta_mview AS vg
-- WHERE	water='f'
-- UNION ALL
-- -- 35718841 km²
-- SELECT	'water' ::text AS id,
-- 	SUM(vg.area_km2) ::integer AS area_sum_km2
-- FROM	orig_geo_vg250.vg250_1_sta_mview AS vg
-- WHERE	water='t';

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
-- "orig_geo_vg250.vg250_1_sta_union_mview"
---------- ---------- ----------

-- "Transform VG250 State UNION"   (OK!) -> 2.000ms =1
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_vg250.vg250_1_sta_union_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_vg250.vg250_1_sta_union_mview AS
	SELECT	'1' ::integer AS gid,
		'Bundesrepublik' ::text AS bez,
		ST_AREA(un.geom) / 10000 ::double precision AS area_km2,
		un.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT	ST_UNION(ST_TRANSFORM(vg.geom,3035)) ::geometry(MultiPolygon,3035) AS geom
		FROM	orig_geo_vg250.vg250_1_sta AS vg
		WHERE	vg.bez = 'Bundesrepublik') AS un;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_1_sta_union_mview_id_idx
		ON	orig_geo_vg250.vg250_1_sta_union_mview (gid);

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
-- 		SELECT	source.gid AS id,					-- PK
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
-- "orig_geo_vg250.vg250_4_krs_mview"
---------- ---------- ----------

-- "Transform VG250 Kreise"   (OK!) -> 1.000ms =432
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_vg250.vg250_4_krs_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_vg250.vg250_4_krs_mview AS
	SELECT	vg.gid ::integer AS gid,
		vg.gen ::text AS gen,
		vg.bez ::text AS bez,
		vg.nuts ::varchar(5) AS nuts,
		vg.rs_0 ::varchar(12) AS rs_0,
		vg.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(vg.geom) / 10000 ::double precision AS area_km2,
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
-- "orig_geo_vg250.vg250_6_gem"
---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_geo_vg250.vg250_6_gem_error_geom_view CASCADE;
-- CREATE VIEW		orig_geo_vg250.vg250_6_gem_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),31467) ::geometry(Point,31467) AS error_location,
-- 		test.geom ::geometry(MultiPolygon,31467) AS error_geom
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(MultiPolygon,31467) AS geom
-- 		FROM	orig_geo_vg250.vg250_6_gem AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_geo_vg250.vg250_6_gem_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_geo_vg250.vg250_6_gem_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{vg250_6_gem_mview_error_geom_view}', 'orig_geo_vg250');


---------- ---------- ----------
-- "orig_geo_vg250.vg250_6_gem_mview"
---------- ---------- ----------

-- "Transform VG250 Gemeinden"   (OK!) -> 2.000ms =11.438
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_vg250.vg250_6_gem_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_vg250.vg250_6_gem_mview AS
	SELECT	vg.gid ::integer AS gid,
		vg.gen ::text AS gen,
		vg.bez ::text AS bez,
		vg.bem ::text AS bem,
		vg.nuts ::varchar(5) AS nuts,
		vg.rs_0 ::varchar(12) AS rs_0,
		vg.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(vg.geom) / 10000 ::double precision AS area_km2,
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

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_geo_vg250.vg250_6_gem_mview_error_geom_view CASCADE;
-- CREATE VIEW		orig_geo_vg250.vg250_6_gem_mview_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
-- 		test.geom ::geometry(MultiPolygon,3035) AS error_geom
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(MultiPolygon,3035) AS geom
-- 		FROM	orig_geo_vg250.vg250_6_gem_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_geo_vg250.vg250_6_gem_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_geo_vg250.vg250_6_gem_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{vg250_6_gem_mview_error_geom_view}', 'orig_geo_vg250');



---------- ---------- ----------
-- "orig_geo_vg250.vg250_6_gem_dump_mview"
---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	vg250_6_gem_dump_mview_id CASCADE;
CREATE TEMP SEQUENCE 		vg250_6_gem_dump_mview_id;

-- "Transform VG250 Gemeinden"   (OK!) -> 5.000ms =12.528
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_vg250.vg250_6_gem_dump_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_vg250.vg250_6_gem_dump_mview AS
	SELECT	nextval('vg250_6_gem_dump_mview_id') AS id,
		vg.gid ::integer AS gid,
		vg.gen ::text AS gen,
		vg.bez ::text AS bez,
		vg.bem ::text AS bem,
		vg.nuts ::varchar(5) AS nuts,
		vg.rs_0 ::varchar(12) AS rs_0,
		vg.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(vg.geom) / 10000 ::double precision AS area_km2,
		ST_MakeValid((ST_DUMP(ST_TRANSFORM(vg.geom,3035))).geom) ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_vg250.vg250_6_gem AS vg
	ORDER BY vg.gid;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_6_gem_dump_mview_gid_idx
		ON	orig_geo_vg250.vg250_6_gem_dump_mview (id);

-- "Create Index GIST (geom)"   (OK!) -> 150ms =0
CREATE INDEX  	vg250_6_gem_dump_mview_geom_idx
	ON	orig_geo_vg250.vg250_6_gem_dump_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_vg250.vg250_6_gem_dump_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_vg250.vg250_6_gem_dump_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_geo_vg250.vg250_6_gem_dump_mview_error_geom_view CASCADE;
-- CREATE VIEW		orig_geo_vg250.vg250_6_gem_dump_mview_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
-- 		test.geom ::geometry(Polygon,3035) AS geom
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(Polygon,3035) AS geom
-- 		FROM	orig_geo_vg250.vg250_6_gem_dump_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_geo_vg250.vg250_6_gem_dump_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_geo_vg250.vg250_6_gem_dump_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{vg250_6_gem_dump_mview_error_geom_view}', 'orig_geo_vg250');

---------- ---------- ----------
