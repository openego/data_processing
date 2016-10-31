/* 
eGo data processing - data setup of BKG bkg_vg250

Process given administrative borders (bkg_vg250).
Create mviews with transformed (EPSG:3035) and corrected geometries.
Municipalities / Gemeinden are fragmented and cleaned from ringholes (bkg_vg250_6_gem_clean).
 */


-- State borders - political_boundary.bkg_vg250_1_sta_mview
/*
With tiny buffer because of intersection (in official data).
*/ 

-- Transform bkg_vg250 State   (OK!) -> 500ms =11
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_1_sta_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_1_sta_mview AS
	SELECT	vg.id ::integer,
		vg.bez ::text,
		vg.gf ::double precision,
		ST_AREA(ST_TRANSFORM(vg.geom, 3035)) / 10000 ::double precision AS area_km2,
		ST_MULTI(ST_BUFFER(ST_TRANSFORM(vg.geom,3035),-0.001)) ::geometry(MultiPolygon,3035) AS geom
	FROM	political_boundary.bkg_vg250_1_sta AS vg
	WHERE	reference_date = '2016-01-01'
	ORDER BY vg.id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	bkg_vg250_1_sta_mview_id_idx
		ON	political_boundary.bkg_vg250_1_sta_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	bkg_vg250_1_sta_mview_geom_idx
	ON	political_boundary.bkg_vg250_1_sta_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_1_sta_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_1_sta_mview OWNER TO oeuser;


/* 
-- Validate mview (geom)   (OK!) -> 500ms =1
DROP VIEW IF EXISTS	political_boundary.bkg_vg250_1_sta_mview_error_geom_view CASCADE;
CREATE VIEW		political_boundary.bkg_vg250_1_sta_mview_error_geom_view AS 
	SELECT	test.id AS id,
		test.error AS error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom ::geometry(MultiPolygon,3035) AS geom
		FROM	political_boundary.bkg_vg250_1_sta_mview AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_1_sta_mview_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_1_sta_mview_error_geom_view OWNER TO oeuser;

-- Drop empty view   (OK!) -> 100ms =1
SELECT f_drop_view('{bkg_vg250_1_sta_mview_error_geom_view}', 'orig_bkg_vg250');
 */


/* 
-- Find errors	(OK!) 47.000ms =143.293
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_1_sta_error_geom_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_1_sta_error_geom_mview AS 
	SELECT	test.id AS id,
		test.error AS error,
		test.error_reason AS error_reason,
		ST_SETSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS geom
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			reason(ST_IsValidDetail(source.geom)) AS error_reason,
			source.geom AS geom
		FROM	political_boundary.bkg_vg250_1_sta AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	bkg_vg250_1_sta_error_geom_mview_id_idx
		ON	political_boundary.bkg_vg250_1_sta_error_geom_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	bkg_vg250_1_sta_error_geom_mview_geom_idx
	ON	political_boundary.bkg_vg250_1_sta_error_geom_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_1_sta_error_geom_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_1_sta_error_geom_mview OWNER TO oeuser;
DROP VIEW IF EXISTS	political_boundary.bkg_vg250_1_sta_error_geom_view CASCADE;
 */


---------- ---------- ----------
-- political_boundary.bkg_vg250_1_sta_union_mview
---------- ---------- ----------

-- Transform bkg_vg250 State UNION   (OK!) -> 2.000ms =1
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_1_sta_union_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_1_sta_union_mview AS
	SELECT	'1' ::integer AS id,
		'Bundesrepublik' ::text AS bez,
		ST_AREA(un.geom) / 10000 ::double precision AS area_km2,
		un.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT	ST_MakeValid(ST_UNION(ST_TRANSFORM(vg.geom,3035))) ::geometry(MultiPolygon,3035) AS geom
		FROM	political_boundary.bkg_vg250_1_sta AS vg
		WHERE	vg.bez = 'Bundesrepublik' AND reference_date = '2016-01-01'
		) AS un;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	bkg_vg250_1_sta_union_mview_id_idx
		ON	political_boundary.bkg_vg250_1_sta_union_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	bkg_vg250_1_sta_union_mview_geom_idx
	ON	political_boundary.bkg_vg250_1_sta_union_mview
	USING	GIST (geom);
	
-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_1_sta_union_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_1_sta_union_mview OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'orig_bkg_vg250' AS schema_name,
		'bkg_vg250_1_sta_union_mview' AS table_name,
		'setup_bkg_vg250.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	political_boundary.bkg_vg250_1_sta_union_mview;


---------- ---------- ----------
-- political_boundary.bkg_vg250_1_sta_bbox_mview
---------- ---------- ----------

-- Transform bkg_vg250 State UNION   (OK!) -> 2.000ms =1
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_1_sta_bbox_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_1_sta_bbox_mview AS
	SELECT	'1' ::integer AS id,
		'Bundesrepublik' ::text AS bez,
		ST_AREA(un.geom) / 10000 ::double precision AS area_km2,
		un.geom ::geometry(Polygon,3035) AS geom
	FROM	(SELECT	ST_SetSRID(Box2D(vg.geom),3035) ::geometry(Polygon,3035) AS geom
		FROM	political_boundary.bkg_vg250_1_sta_union_mview AS vg
		) AS un;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	bkg_vg250_1_sta_bbox_mview_id_idx
		ON	political_boundary.bkg_vg250_1_sta_bbox_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	bkg_vg250_1_sta_bbox_mview_geom_idx
	ON	political_boundary.bkg_vg250_1_sta_bbox_mview
	USING	GIST (geom);
	
-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_1_sta_bbox_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_1_sta_bbox_mview OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'orig_bkg_vg250' AS schema_name,
		'bkg_vg250_1_sta_bbox_mview' AS table_name,
		'setup_bkg_vg250.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	political_boundary.bkg_vg250_1_sta_bbox_mview;
	
	
	
---------- ---------- ----------
-- political_boundary.bkg_vg250_2_lan_mview - With tiny buffer because of intersection (in official data)
---------- ---------- ----------

-- Transform bkg_vg250 State   (OK!) -> 11.000ms =11
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_2_lan_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_2_lan_mview AS
	SELECT	lan.ags_0 ::character varying(12) AS ags_0,
		lan.gen ::text AS gen,
		ST_UNION(ST_TRANSFORM(lan.geom,3035)) AS geom
	FROM	(SELECT	vg.ags_0,
			replace( vg.gen, ' (Bodensee)', '') as gen,
			vg.geom
		FROM	political_boundary.bkg_vg250_2_lan AS vg ) AS lan
	GROUP BY lan.ags_0,lan.gen
	ORDER BY lan.ags_0;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	bkg_vg250_2_lan_mview_ags_0_idx
		ON	political_boundary.bkg_vg250_2_lan_mview (ags_0);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	bkg_vg250_2_lan_mview_geom_idx
	ON	political_boundary.bkg_vg250_2_lan_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_2_lan_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_2_lan_mview OWNER TO oeuser;

---------- ---------- ----------
-- political_boundary.bkg_vg250_4_krs_mview
---------- ---------- ----------

-- Transform bkg_vg250 Kreise   (OK!) -> 1.000ms =432
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_4_krs_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_4_krs_mview AS
	SELECT	vg.id ::integer AS id,
		vg.gen ::text AS gen,
		vg.bez ::text AS bez,
		vg.nuts ::varchar(5) AS nuts,
		vg.rs_0 ::varchar(12) AS rs_0,
		vg.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(vg.geom) / 10000 ::double precision AS area_km2,
		ST_TRANSFORM(vg.geom,3035) ::geometry(MultiPolygon,3035) AS geom
	FROM	political_boundary.bkg_vg250_4_krs AS vg
	ORDER BY vg.id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	bkg_vg250_4_krs_mview_id_idx
		ON	political_boundary.bkg_vg250_4_krs_mview (id);

-- Create Index GIST (geom)   (OK!) -> 200ms =0
CREATE INDEX  	bkg_vg250_4_krs_mview_geom_idx
	ON	political_boundary.bkg_vg250_4_krs_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_4_krs_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_4_krs_mview OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'orig_bkg_vg250' AS schema_name,
		'bkg_vg250_4_krs_mview' AS table_name,
		'setup_bkg_vg250.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	political_boundary.bkg_vg250_4_krs_mview;

---------- ---------- ----------

-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	political_boundary.bkg_vg250_4_krs_mview_error_geom_view CASCADE;
-- CREATE VIEW		political_boundary.bkg_vg250_4_krs_mview_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(MultiPolygon,3035) AS geom
-- 		FROM	political_boundary.bkg_vg250_4_krs_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	political_boundary.bkg_vg250_4_krs_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		political_boundary.bkg_vg250_4_krs_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{bkg_vg250_4_krs_mview_error_geom_view}', 'orig_bkg_vg250');

---------- ---------- ----------

-- -- Create Index GIST (geom)   (OK!) -> 100ms =0
-- CREATE INDEX  	bkg_vg250_6_gem_geom_idx
-- 	ON	political_boundary.bkg_vg250_6_gem
-- 	USING	GIST (geom);

-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	political_boundary.bkg_vg250_6_gem_error_geom_view CASCADE;
-- CREATE VIEW		political_boundary.bkg_vg250_6_gem_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),31467) ::geometry(Point,31467) AS error_location,
-- 		test.geom ::geometry(MultiPolygon,31467) AS error_geom
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(MultiPolygon,31467) AS geom
-- 		FROM	political_boundary.bkg_vg250_6_gem AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	political_boundary.bkg_vg250_6_gem_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		political_boundary.bkg_vg250_6_gem_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{bkg_vg250_6_gem_error_geom_view}', 'orig_bkg_vg250');


---------- ---------- ----------
-- political_boundary.bkg_vg250_6_gem_mview
---------- ---------- ----------

-- Transform bkg_vg250 Gemeinden   (OK!) -> 2.000ms =11.431
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_6_gem_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_6_gem_mview AS
	SELECT	vg.id ::integer AS id,
		vg.gen ::text AS gen,
		vg.bez ::text AS bez,
		vg.bem ::text AS bem,
		vg.nuts ::varchar(5) AS nuts,
		vg.rs_0 ::varchar(12) AS rs_0,
		vg.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(vg.geom) / 1000 ::double precision AS area_ha,
		ST_TRANSFORM(vg.geom,3035) ::geometry(MultiPolygon,3035) AS geom
	FROM	political_boundary.bkg_vg250_6_gem AS vg
	ORDER BY vg.id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	bkg_vg250_6_gem_mview_id_idx
		ON	political_boundary.bkg_vg250_6_gem_mview (id);

-- Create Index GIST (geom)   (OK!) -> 150ms =0
CREATE INDEX  	bkg_vg250_6_gem_mview_geom_idx
	ON	political_boundary.bkg_vg250_6_gem_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_6_gem_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_6_gem_mview OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'orig_bkg_vg250' AS schema_name,
		'bkg_vg250_6_gem_mview' AS table_name,
		'setup_bkg_vg250.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	political_boundary.bkg_vg250_6_gem_mview;


---------- ---------- ----------

-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	political_boundary.bkg_vg250_6_gem_mview_error_geom_view CASCADE;
-- CREATE VIEW		political_boundary.bkg_vg250_6_gem_mview_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
-- 		test.geom ::geometry(MultiPolygon,3035) AS error_geom
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(MultiPolygon,3035) AS geom
-- 		FROM	political_boundary.bkg_vg250_6_gem_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	political_boundary.bkg_vg250_6_gem_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		political_boundary.bkg_vg250_6_gem_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{bkg_vg250_6_gem_mview_error_geom_view}', 'orig_bkg_vg250');



---------- ---------- ----------
-- political_boundary.bkg_vg250_6_gem_dump_mview
---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	political_boundary.bkg_vg250_6_gem_dump_mview_id CASCADE;
CREATE SEQUENCE 		political_boundary.bkg_vg250_6_gem_dump_mview_id;

-- Transform bkg_vg250 Gemeinden   (OK!) -> 5.000ms =12.521
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_6_gem_dump_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_6_gem_dump_mview AS
	SELECT	nextval('political_boundary.bkg_vg250_6_gem_dump_mview_id') AS id,
		vg.id ::integer AS id,
		vg.gen ::text AS gen,
		vg.bez ::text AS bez,
		vg.bem ::text AS bem,
		vg.nuts ::varchar(5) AS nuts,
		vg.rs_0 ::varchar(12) AS rs_0,
		vg.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(vg.geom) / 10000 ::double precision AS area_km2,
		ST_MakeValid((ST_DUMP(ST_TRANSFORM(vg.geom,3035))).geom) ::geometry(Polygon,3035) AS geom
	FROM	political_boundary.bkg_vg250_6_gem AS vg
	WHERE	gf = '4' -- Without water
	ORDER BY vg.id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	bkg_vg250_6_gem_dump_mview_id_idx
		ON	political_boundary.bkg_vg250_6_gem_dump_mview (id);

-- Create Index GIST (geom)   (OK!) -> 150ms =0
CREATE INDEX  	bkg_vg250_6_gem_dump_mview_geom_idx
	ON	political_boundary.bkg_vg250_6_gem_dump_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_6_gem_dump_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_6_gem_dump_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	political_boundary.bkg_vg250_6_gem_dump_mview_error_geom_view CASCADE;
-- CREATE VIEW		political_boundary.bkg_vg250_6_gem_dump_mview_error_geom_view AS 
-- 	SELECT	test.id AS id,
-- 		test.error AS error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
-- 		test.geom ::geometry(Polygon,3035) AS geom
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom ::geometry(Polygon,3035) AS geom
-- 		FROM	political_boundary.bkg_vg250_6_gem_dump_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	political_boundary.bkg_vg250_6_gem_dump_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		political_boundary.bkg_vg250_6_gem_dump_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{bkg_vg250_6_gem_dump_mview_error_geom_view}', 'orig_bkg_vg250');



---------- ---------- ----------
-- orig_ego.bkg_vg250_6_gem_clean
---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 		political_boundary.bkg_vg250_6_gem_clean_id CASCADE;
CREATE SEQUENCE 			political_boundary.bkg_vg250_6_gem_clean_id;

-- Transform bkg_vg250 Gemeinden   (OK!) -> 1.000ms =12.870
DROP TABLE IF EXISTS	political_boundary.bkg_vg250_6_gem_clean CASCADE;
CREATE TABLE		political_boundary.bkg_vg250_6_gem_clean AS
	SELECT	nextval('political_boundary.bkg_vg250_6_gem_clean_id') AS id,
		dump.id ::integer AS id,
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
	FROM	(SELECT vg.id,
			vg.gen,
			vg.bez,
			vg.bem,
			vg.nuts,
			vg.rs_0,
			vg.ags_0,
			ST_NumInteriorRings(vg.geom) AS count_ring,
			(ST_DumpRings(vg.geom)).path AS path,
			(ST_DumpRings(vg.geom)).geom AS geom
		FROM	political_boundary.bkg_vg250_6_gem_dump_mview AS vg) AS dump;

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	political_boundary.bkg_vg250_6_gem_clean
	ADD COLUMN	is_ring boolean,
	ADD PRIMARY KEY (id);

-- Create Index GIST (geom)   (OK!) -> 150ms =0
CREATE INDEX  	bkg_vg250_6_gem_clean_geom_idx
	ON	political_boundary.bkg_vg250_6_gem_clean
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_6_gem_clean TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_6_gem_clean OWNER TO oeuser;

---------- ---------- ----------

-- separate all holes   (OK!) 30.000ms =350
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_6_gem_rings_mview CASCADE;
CREATE MATERIALIZED VIEW 		political_boundary.bkg_vg250_6_gem_rings_mview AS 
SELECT 	mun.*
FROM	political_boundary.bkg_vg250_6_gem_clean AS mun
WHERE	mun.path[1] <> 0;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	bkg_vg250_6_gem_rings_mview_id_idx
		ON	political_boundary.bkg_vg250_6_gem_rings_mview (id);

-- Create Index GIST (geom)   (OK!) -> 150ms =0
CREATE INDEX  	bkg_vg250_6_gem_rings_mview_geom_idx
	ON	political_boundary.bkg_vg250_6_gem_rings_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_6_gem_rings_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_6_gem_rings_mview OWNER TO oeuser;

-- Update Holes   (OK!) -> 2.000ms =696
UPDATE 	political_boundary.bkg_vg250_6_gem_clean AS t1
SET  	is_ring = t2.is_ring
FROM    (
	SELECT	gem.id AS id,
		'TRUE' ::boolean AS is_ring
	FROM	political_boundary.bkg_vg250_6_gem_clean AS gem,
		political_boundary.bkg_vg250_6_gem_rings_mview AS ring
	WHERE  	gem.geom = ring.geom
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- Separate all ringholes   (OK!) 1.000ms =682
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_6_gem_clean_rings_mview CASCADE;
CREATE MATERIALIZED VIEW 		political_boundary.bkg_vg250_6_gem_clean_rings_mview AS
	SELECT	vg.*
	FROM	political_boundary.bkg_vg250_6_gem_clean AS vg
	WHERE	vg.is_ring IS TRUE;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	bkg_vg250_6_gem_clean_rings_mview_id_idx
		ON	political_boundary.bkg_vg250_6_gem_clean_rings_mview (id);

-- Create Index GIST (geom)   (OK!) -> 150ms =0
CREATE INDEX  	bkg_vg250_6_gem_clean_rings_mview_geom_idx
	ON	political_boundary.bkg_vg250_6_gem_clean_rings_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_6_gem_clean_rings_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_6_gem_clean_rings_mview OWNER TO oeuser;

-- Remove ringholes   (OK!) 1.000ms =682
DELETE FROM 	political_boundary.bkg_vg250_6_gem_clean
WHERE			is_ring IS TRUE;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'orig_bkg_vg250' AS schema_name,
		'bkg_vg250_6_gem_clean' AS table_name,
		'setup_bkg_vg250.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	political_boundary.bkg_vg250_6_gem_clean;


---------- ---------- ----------

CREATE OR REPLACE VIEW political_boundary.bkg_vg250_statistics AS
-- Area Sum
-- 38162814 km²
SELECT	'vg' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
UNION ALL
-- 38141292 km²
SELECT	'deu' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	bez='Bundesrepublik'
UNION ALL
-- 38141292 km²
SELECT	'NOT deu' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	bez='--'
UNION ALL
-- 35718841 km²
SELECT	'land' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	gf='3' OR gf='4'
UNION ALL
-- 35718841 km²
SELECT	'water' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	gf='1' OR gf='2';



-- COMMENTS

-- Set comment on table
COMMENT ON MATERIALIZED VIEW political_boundary.bkg_vg250_1_sta_union_mview IS
'{
"Name": "BKG - Verwaltungsgebiete 1:250.000 / Administrative borders - State border (union)",
"Source": [{
                  "Name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data",
                  "URL":  "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0" }],
"Reference date": "2000-2016",
"Date of collection": "2016-10-01",
"Original file": "bkg_vg250_0101.utm32s.shape.ebenen.zip",
"Spatial resolution": ["Germany"],
"Description": ["Der Datenbestand umfasst die Verwaltungseinheiten der hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden"],

"Column": [
                {"Name": "id",
                "Description": "Unique identifier",
                "Unit": "" },
					
                {"Name": "version",
                "Description": "Scenario version",
                "Unit": "" },

                {"Name": "schema_name",
                "Description": "Schema name",
                "Unit": "" },
					
		{"Name": "table_name",
                "Description": "Table name",
                "Unit": "" },
					
		{"Name": "script_name",
                "Description": "Script name",
                "Unit": "" },
					
		{"Name": "entries",
                "Description": "Number of rows",
                "Unit": "" },
			
		{"Name": "status",
                "Description": "Current status and comments",
                "Unit": "" },
			
		{"Name": "timestamp",
                "Description": "Timestamp (Berlin)",
                "Unit": "" }],

"Changes":[
                {"Name": "Ludwig Hülk",
                "Mail": "ludwig.huelk@rl-institut.de",
                "Date":  "01.10.2016",
                "Comment": "Created table" }],

"ToDo": ["Table fields in English"],
"Licence": ["Geodatenzugangsgesetz (GeoZG)"],
"Instructions for proper use": ["Dieser Datenbestand steht über Geodatendienste gemäß Geodatenzugangsgesetz (GeoZG) (http://www.geodatenzentrum.de/auftrag/pdf/geodatenzugangsgesetz.pdf) für die kommerzielle und nicht kommerzielle Nutzung geldleistungsfrei zum Download und zur Online-Nutzung zur Verfügung. Die Nutzung der Geodaten und Geodatendienste wird durch die Verordnung zur Festlegung der Nutzungsbestimmungen für die Bereitstellung von Geodaten des Bundes (GeoNutzV) (http://www.geodatenzentrum.de/auftrag/pdf/geonutz.pdf) geregelt. Insbesondere hat jeder Nutzer den Quellenvermerk zu allen Geodaten, Metadaten und Geodatendiensten erkennbar und in optischem Zusammenhang zu platzieren. Veränderungen, Bearbeitungen, neue Gestaltungen oder sonstige Abwandlungen sind mit einem Veränderungshinweis im Quellenvermerk zu versehen. Quellenvermerk und Veränderungshinweis sind wie folgt zu gestalten. Bei der Darstellung auf einer Webseite ist der Quellenvermerk mit der URL http://www.bkg.bund.de zu verlinken. © GeoBasis-DE / BKG <Jahr des letzten Datenbezugs> © GeoBasis-DE / BKG <Jahr des letzten Datenbezugs> (Daten verändert) Beispiel: © GeoBasis-DE / BKG 2013"]
}';

-- Select description
SELECT obj_description('political_boundary.bkg_vg250_1_sta_union_mview'::regclass)::json

