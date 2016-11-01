---------- ---------- ----------
---------- --SKRIPT-- OK! 7min
---------- ---------- ----------

/* -- Create schemas for open_eGo
DROP SCHEMA IF EXISTS	calc_ego_grid_district CASCADE;
CREATE SCHEMA 		calc_ego_grid_district;

-- Set default privileges for schema
ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_grid_district GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_grid_district GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_grid_district GRANT ALL ON FUNCTIONS TO oeuser;

-- Grant all in schema
GRANT ALL ON SCHEMA 	calc_ego_grid_district TO oeuser WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA calc_ego_grid_district TO oeuser;
 */
---------- ---------- ----------
-- Substations per Municipalities
---------- ---------- ----------

-- Municipalities   (OK!) -> 28.000ms =12.174
DROP TABLE IF EXISTS	model_draft.ego_political_boundary_hvmv_subst_per_gem CASCADE;
CREATE TABLE		model_draft.ego_political_boundary_hvmv_subst_per_gem AS
	SELECT	vg.*
	FROM	political_boundary.bkg_vg250_6_gem_clean AS vg;

-- Set PK   (OK!) -> 1.000ms =0
ALTER TABLE model_draft.ego_political_boundary_hvmv_subst_per_gem
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_type integer,
	ADD PRIMARY KEY (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	ego_political_boundary_hvmv_subst_per_gem_geom_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_political_boundary_hvmv_subst_per_gem OWNER TO oeuser;

-- usw count   (OK!) -> 1.000ms =2.270
UPDATE 	model_draft.ego_political_boundary_hvmv_subst_per_gem AS t1
SET  	subst_sum = t2.subst_sum
FROM	(SELECT	mun.id AS id,
		COUNT(sub.geom)::integer AS subst_sum
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem AS mun,
		model_draft.ego_grid_hvmv_substation AS sub
	WHERE  	mun.geom && sub.geom AND
		ST_CONTAINS(mun.geom,sub.geom)
	GROUP BY mun.id
	)AS t2
WHERE  	t1.id = t2.id;

-- SELECT	sum(mun.subst_sum) AS sum
-- FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem AS mun;


---------- ---------- ----------
-- MViews
---------- ---------- ----------

-- MView I.   (OK!) -> 300ms =1.724
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_political_boundary_hvmv_subst_per_gem_1_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_political_boundary_hvmv_subst_per_gem_1_mview AS
	SELECT	mun.id,
		mun.gen,
		mun.bez,
		mun.ags_0,
		'1' ::integer AS subst_type,
		mun.geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem AS mun
	WHERE	mun.subst_sum = '1';

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_political_boundary_hvmv_subst_per_gem_1_mview_gid_idx
		ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_1_mview (id);

-- Substation Type 1   (OK!) -> 1.000ms =1.724
UPDATE 	model_draft.ego_political_boundary_hvmv_subst_per_gem AS t1
SET  	subst_type = t2.subst_type
FROM	(SELECT	mun.id AS id,
		mun.subst_type AS subst_type
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_1_mview AS mun )AS t2
WHERE  	t1.id = t2.id;

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_political_boundary_hvmv_subst_per_gem_1_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_political_boundary_hvmv_subst_per_gem_1_mview OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_political_boundary_hvmv_subst_per_gem_1_mview' AS table_name,
		'process_eGo_grid_district.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_1_mview;

---------- ---------- ----------

-- MView II.   (OK!) -> 100ms =546
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview AS
	SELECT	mun.id,
		mun.gen,
		mun.bez,
		mun.ags_0,
		'2' ::integer AS subst_type,
		mun.geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem AS mun
	WHERE	mun.subst_sum > '1';

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_political_boundary_hvmv_subst_per_gem_2_mview_gid_idx
		ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview (id);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview OWNER TO oeuser;

-- Substation Type 2   (OK!) -> 1.000ms =546
UPDATE 	model_draft.ego_political_boundary_hvmv_subst_per_gem AS t1
SET  	subst_type = t2.subst_type
FROM	(SELECT	mun.id AS id,
		mun.subst_type AS subst_type
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview AS mun )AS t2
WHERE  	t1.id = t2.id;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_political_boundary_hvmv_subst_per_gem_2_mview' AS table_name,
		'process_eGo_grid_district.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview;

---------- ---------- ----------

-- Substation Type 2   (OK!) -> 200ms =1.886
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_mun_2_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_hvmv_substation_mun_2_mview AS
	SELECT	sub.subst_id ::integer,
		sub.subst_name ::text,
		'3' ::integer AS subst_type,
		sub.geom ::geometry(Point,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation AS sub,
		model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview AS mun
	WHERE  	mun.geom && sub.geom AND
		ST_CONTAINS(mun.geom,sub.geom);

-- Create Index (subst_id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_grid_hvmv_substation_mun_2_mview_subst_id_idx
		ON	model_draft.ego_grid_hvmv_substation_mun_2_mview (subst_id);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_grid_hvmv_substation_mun_2_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_hvmv_substation_mun_2_mview OWNER TO oeuser;


---------- ---------- ----------

-- MView III.   (OK!) -> 22.000ms =9.904
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview AS
	SELECT	mun.id,
		mun.gen,
		mun.bez,
		mun.ags_0,
		'3' ::integer AS subst_type,
		mun.geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem AS mun
	WHERE	mun.subst_sum IS NULL;

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_political_boundary_hvmv_subst_per_gem_3_mview_gid_idx
		ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview (id);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview OWNER TO oeuser;


-- Substation Type 3   (OK!) -> 1.000ms =9.904
UPDATE 	model_draft.ego_political_boundary_hvmv_subst_per_gem AS t1
SET  	subst_type = t2.subst_type
FROM	(SELECT	mun.id AS id,
		'3'::integer AS subst_type
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview AS mun )AS t2
WHERE  	t1.id = t2.id;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_political_boundary_hvmv_subst_per_gem_3_mview' AS table_name,
		'process_eGo_grid_district.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview;

---------- ---------- ----------
-- Grid Districts
---------- ---------- ----------

---------- ---------- ----------
-- I. Gemeinden mit genau einem USW 
---------- ---------- ----------

-- Substations Template   (OK!) -> 100ms =3.610
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_type1 CASCADE;
CREATE TABLE		model_draft.ego_grid_mv_griddistrict_type1 AS
	SELECT	sub.subst_id ::integer,
		sub.subst_name ::text,
		sub.ags_0 ::character varying(12),
		sub.geom ::geometry(Point,3035) AS geom_sub
	FROM	model_draft.ego_grid_hvmv_substation AS sub;

-- Set PK   (OK!) -> 100ms =0
ALTER TABLE model_draft.ego_grid_mv_griddistrict_type1
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_type integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (subst_id);

-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	grid_district_type_1_geom_subst_idx
	ON	model_draft.ego_grid_mv_griddistrict_type1
	USING	GIST (geom_sub);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	grid_district_type_1_geom_mun_idx
	ON	model_draft.ego_grid_mv_griddistrict_type1
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_grid_mv_griddistrict_type1 TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_mv_griddistrict_type1 OWNER TO oeuser;

-- subst_id = gem.id
-- update usw geom gem1   (OK!) -> 1.000ms =1.724
UPDATE 	model_draft.ego_grid_mv_griddistrict_type1 AS t1
SET  	subst_sum  = t2.subst_sum,
	subst_type = t2.subst_type,
	geom = t2.geom
FROM	(SELECT	mun.ags_0,
		mun.subst_sum ::integer,
		mun.subst_type ::integer,
		ST_MULTI(mun.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem AS mun
	WHERE	subst_type = '1')AS t2
WHERE  	t1.ags_0 = t2.ags_0;

---------- ---------- ---------- ---------- ---------- ----------
-- II. Gemeinden mit mehreren USW
---------- ---------- ---------- ---------- ---------- ----------

-- Create Table "ego_deu_substations_voronoi" 

-- Substation ID   (OK!) -> 1.000ms =3.610
UPDATE 	model_draft.ego_grid_hvmv_substation_voronoi AS t1
SET  	subst_id = t2.subst_id
FROM	(SELECT	voi.id AS id,
		sub.subst_id ::integer AS subst_id
	FROM	model_draft.ego_grid_hvmv_substation_voronoi AS voi,
		model_draft.ego_grid_hvmv_substation AS sub
	WHERE  	voi.geom && sub.geom AND
		ST_CONTAINS(voi.geom,sub.geom)
	GROUP BY voi.id,sub.subst_id
	)AS t2
WHERE  	t1.id = t2.id;

-- Substation Count   (OK!) -> 1.000ms =3.610
UPDATE 	model_draft.ego_grid_hvmv_substation_voronoi AS t1
SET  	subst_sum = t2.subst_sum
FROM	(SELECT	voi.id AS id,
		COUNT(sub.geom)::integer AS subst_sum
	FROM	model_draft.ego_grid_hvmv_substation_voronoi AS voi,
		model_draft.ego_grid_hvmv_substation AS sub
	WHERE  	voi.geom && sub.geom AND
		ST_CONTAINS(voi.geom,sub.geom)
	GROUP BY voi.id
	)AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- Voronoi Gridcells (voi)   (OK!) 100ms =3.610
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_hvmv_substation_voronoi_mview AS
	SELECT	voi.id ::integer,
		voi.subst_id ::integer,
		voi.subst_sum ::integer,
		(ST_DUMP(voi.geom)).geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi AS voi
	WHERE	subst_sum = '1';

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_mview_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_voronoi_mview_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_grid_hvmv_substation_voronoi_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_hvmv_substation_voronoi_mview OWNER TO oeuser;

---------- ---------- ----------
-- 
-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_error_geom_view CASCADE;
-- CREATE VIEW		model_draft.ego_grid_hvmv_substation_voronoi_error_geom_view AS
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	calc_ego_grid_district.ego_deu_substations_voronoi AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	model_draft.ego_grid_hvmv_substation_voronoi_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		model_draft.ego_grid_hvmv_substation_voronoi_error_geom_view OWNER TO oeuser;

-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_deu_substations_voronoi_error_geom_view}', 'calc_grid_district');


---------- ---------- ----------
-- CUT
---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	model_draft.ego_grid_hvmv_substation_voronoi_cut_id CASCADE;
CREATE SEQUENCE 		model_draft.ego_grid_hvmv_substation_voronoi_cut_id;

-- Grant oeuser   (OK!) -> 100ms =0
ALTER SEQUENCE		model_draft.ego_grid_hvmv_substation_voronoi_cut_id OWNER TO oeuser;

-- Cutting GEM II.   (OK!) 3.000ms =4.531
DROP TABLE IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut CASCADE;
CREATE TABLE		model_draft.ego_grid_hvmv_substation_voronoi_cut AS
	SELECT	nextval('model_draft.ego_grid_hvmv_substation_voronoi_cut_id') AS id,
		voi.subst_id,
		mun.id AS mun_id,
		voi.id AS voi_id,
		mun.ags_0 AS ags_0,
		mun.subst_type,
		(ST_DUMP(ST_INTERSECTION(mun.geom,voi.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview AS mun,
		model_draft.ego_grid_hvmv_substation_voronoi_mview AS voi
	WHERE	mun.geom && voi.geom;

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	model_draft.ego_grid_hvmv_substation_voronoi_cut
	ADD COLUMN subst_sum integer,
	ADD COLUMN geom_sub geometry(Point,3035),
	ADD PRIMARY KEY (id);

-- Count Substations in Voronoi Cuts   (OK!) -> 1.000ms =1.886
UPDATE 	model_draft.ego_grid_hvmv_substation_voronoi_cut AS t1
SET  	subst_sum = t2.subst_sum,
	subst_id = t2.subst_id,
	geom_sub = t2.geom_sub
FROM	(SELECT	mun.id AS id,
		sub.subst_id,
		sub.geom AS geom_sub,
		COUNT(sub.geom)::integer AS subst_sum
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut AS mun,
		model_draft.ego_grid_hvmv_substation AS sub
	WHERE  	mun.geom && sub.geom AND
		ST_CONTAINS(mun.geom,sub.geom)
	GROUP BY mun.id,sub.subst_id,sub.geom
	)AS t2
WHERE  	t1.id = t2.id;

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut
	USING	GIST (geom);

-- Create Index GIST (geom_sub)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_geom_subst_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut
	USING	GIST (geom_sub);
	
-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	model_draft.ego_grid_hvmv_substation_voronoi_cut TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_hvmv_substation_voronoi_cut OWNER TO oeuser;

---------- ---------- ----------

-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut_error_geom_view CASCADE;
-- CREATE VIEW		model_draft.ego_grid_hvmv_substation_voronoi_cut_error_geom_view AS
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	model_draft.ego_grid_hvmv_substation_voronoi_cut_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		model_draft.ego_grid_hvmv_substation_voronoi_cut_error_geom_view OWNER TO oeuser;

-- -- Drop empty view   (OK!) -> 100ms =1 (no error!)
-- SELECT f_drop_view('{ego_deu_substations_voronoi_cut_error_geom_view}', 'calc_grid_district');

---------- ---------- ----------

-- Parts with substation   (OK!) 100ms =1.886
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview AS
SELECT	voi.*
FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut AS voi
WHERE	subst_sum = 1;

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_1subst_mview_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_voronoi_cut_1subst_mview_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview OWNER TO oeuser;

---------- ---------- ----------

-- Parts without substation   (OK!) 100ms =2.645
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_mview AS
SELECT	voi.id,
	voi.subst_id,
	voi.mun_id,
	voi.voi_id,
	voi.ags_0,
	voi.subst_type,
	voi.geom
FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut AS voi
WHERE	subst_sum IS NULL;

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_0subst_mview_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_voronoi_cut_0subst_mview_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- Calculate Gemeindeschlüssel   (OK!) -> 3.000ms =4.981
-- UPDATE 	model_draft.ego_grid_hvmv_substation_voronoi_cut AS t1
-- SET  	ags_0 = t2.ags_0
-- FROM    (
-- 	SELECT	cut.id AS id,
-- 		vg.ags_0 AS ags_0
-- 	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut AS cut,
-- 		orig_geo_vg250.vg250_6_gem_mview AS vg
-- 	WHERE  	vg.geom && ST_POINTONSURFACE(cut.geom) AND
-- 		ST_CONTAINS(vg.geom,ST_POINTONSURFACE(cut.geom))
-- 	) AS t2
-- WHERE  	t1.id = t2.id;


---------- ---------- ----------
-- Connect the cutted parts to the next substation
---------- ---------- ----------

-- Next Neighbor   (OK!) 1.000ms =2.645
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview AS
SELECT DISTINCT ON (voi.id)
	voi.id AS voi_id,
	voi.ags_0 AS voi_ags_0,
	voi.geom AS geom_voi,
	sub.subst_id AS subst_id,
	sub.ags_0 AS ags_0,
	sub.geom AS geom_sub
FROM 	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_mview AS voi,
	model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview AS sub
WHERE 	ST_DWithin(ST_ExteriorRing(voi.geom),ST_ExteriorRing(sub.geom), 50000) -- In a 50 km radius
	AND voi.ags_0 = sub.ags_0  -- only inside same mun
ORDER BY 	voi.id, 
		ST_Distance(ST_ExteriorRing(voi.geom),ST_ExteriorRing(sub.geom));
		
-- ST_Length(ST_CollectionExtract(ST_Intersection(a_geom, b_geom), 2)) -- Lenght of the shared border?

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_0subst_nn_mview_voi_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview (voi_id);

-- Create Index GIST (geom_voi)   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_voronoi_cut_0subst_nn_mview_geom_voi_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview
	USING	GIST (geom_voi);

-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_voronoi_cut_0subst_nn_mview_geom_subst_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview
	USING	GIST (geom_sub);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview OWNER TO oeuser;

---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview_id CASCADE;
CREATE SEQUENCE 		model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview_id;

-- Grant oeuser   (OK!) -> 100ms =0
ALTER SEQUENCE		model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview_id OWNER TO oeuser;

-- connect points   (OK!) 1.000ms =2.645
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview;
CREATE MATERIALIZED VIEW 		model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview AS
	SELECT 	nextval('model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview_id') AS id,
		nn.voi_id,
		nn.subst_id,
		(ST_Dump(ST_CENTROID(nn.geom_voi))).geom ::geometry(Point,3035) AS geom_centre,
		ST_ShortestLine(	(ST_Dump(ST_CENTROID(nn.geom_voi))).geom ::geometry(Point,3035),
					sub.geom ::geometry(Point,3035)
		) ::geometry(LineString,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview AS nn,
		model_draft.ego_grid_hvmv_substation AS sub
	WHERE	sub.subst_id = nn.subst_id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_0subst_nn_line_mview_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview (id);

-- Create Index GIST (geom_centre)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_0subst_nn_line_mview_geom_centre_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview
	USING	GIST (geom_centre);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_0subst_nn_line_mview_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview
	USING	GIST (geom);

---------- ---------- ----------

-- Create Table   (OK!) 4.000ms =1.057
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview AS
	SELECT	nn.subst_id As subst_id, 
		ST_MULTI(ST_UNION(nn.geom_voi)) ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview AS nn
	GROUP BY nn.subst_id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_0subst_nn_union_mview_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview (subst_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_0subst_nn_union_mview_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview
	USING	GIST (geom);

---------- ---------- ----------

-- Create Table   (OK!) 4.000ms =0
DROP TABLE IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect CASCADE;
CREATE TABLE		model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect (
	id serial,
	subst_id integer,
	geom geometry(MultiPolygon,3035),
CONSTRAINT ego_deu_substations_voronoi_cut_nn_collect_pkey PRIMARY KEY (id));

-- Insert parts with substations   (OK!) 4.000ms =1.886
INSERT INTO     model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect (subst_id,geom)
	SELECT	sub.subst_id AS subst_id,
		ST_MULTI(sub.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview AS sub;

-- Insert parts without substations union   (OK!) 4.000ms =1.103
INSERT INTO     model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect (subst_id,geom)
	SELECT	voi.subst_id AS subst_id,
		voi.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview AS voi;

-- Create Index GIST (geom)   (OK!) 11.000ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_nn_collect_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect
	USING	GIST (geom);

---------- ---------- ----------

-- Create Table   (OK!) 4.000ms =1.886
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_mview AS
	SELECT	nn.subst_id As subst_id, 
		ST_MULTI(ST_UNION(nn.geom)) ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect AS nn
	GROUP BY nn.subst_id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_nn_mview_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_mview (subst_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_nn_mview_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_mview
	USING	GIST (geom);

---------- ---------- ----------

-- Substations Template   (OK!) -> 100ms =3.610
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_type2 CASCADE;
CREATE TABLE		model_draft.ego_grid_mv_griddistrict_type2 AS
	SELECT	sub.subst_id ::integer,
		sub.subst_name ::text,
		sub.ags_0 ::character varying(12),
		sub.geom ::geometry(Point,3035) AS geom_sub
	FROM	model_draft.ego_grid_hvmv_substation AS sub;

-- Set PK   (OK!) -> 100ms =0
ALTER TABLE model_draft.ego_grid_mv_griddistrict_type2
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_type integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (subst_id);

-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	grid_district_type_2_geom_subst_idx
	ON	model_draft.ego_grid_mv_griddistrict_type2
	USING	GIST (geom_sub);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	grid_district_type_2_geom_mun_idx
	ON	model_draft.ego_grid_mv_griddistrict_type2
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_grid_mv_griddistrict_type2 TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_mv_griddistrict_type2 OWNER TO oeuser;

---------- ---------- ----------

-- subst_id = id
-- update sub geom gem2   (OK!) -> 1.000ms =1.886
UPDATE 	model_draft.ego_grid_mv_griddistrict_type2 AS t1
SET  	subst_type = t2.subst_type,
	geom = t2.geom
FROM	(SELECT	nn.subst_id AS subst_id,
		'2' ::integer AS subst_type,
		nn.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_mview AS nn )AS t2
WHERE  	t1.subst_id = t2.subst_id;


-- ---------- ---------- ----------	
-- 
-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	calc_ego_grid_district.ego_deu_usw_voronoi_mview_error_geom_view CASCADE;
-- CREATE VIEW		calc_ego_grid_district.ego_deu_usw_voronoi_mview_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	calc_ego_grid_district.ego_deu_usw_voronoi_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	calc_ego_grid_district.ego_deu_usw_voronoi_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		calc_ego_grid_district.ego_deu_usw_voronoi_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_deu_usw_voronoi_mview_error_geom_view}', 'calc_grid_district');


---------- ---------- ----------
-- III. Gemeinden ohne sub
---------- ---------- ----------

-- gem WHERE subst_sum=0		orig_geo_ego.vg250_6_gem_subst_3_mview
-- sub				orig_geo_ego.ego_deu_mv_substations_mview

-- Next Neighbor   (OK!) 14.000ms =10.259
DROP TABLE IF EXISTS	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn CASCADE;
CREATE TABLE 		model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn AS
SELECT DISTINCT ON (mun.id)
	mun.id AS mun_id,
	mun.ags_0 AS mun_ags_0,
	sub.ags_0 AS subst_ags_0,
	sub.subst_id, 
	mun.subst_type,
	sub.geom ::geometry(Point,3035) AS geom_sub,
	ST_Distance(ST_ExteriorRing(mun.geom),sub.geom) AS distance,
	ST_MULTI(mun.geom) ::geometry(MultiPolygon,3035) AS geom
FROM 	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview AS mun,
	model_draft.ego_grid_hvmv_substation AS sub
WHERE 	ST_DWithin(ST_ExteriorRing(mun.geom),sub.geom, 50000) -- In a 50 km radius
ORDER BY 	mun.id, ST_Distance(ST_ExteriorRing(mun.geom),sub.geom);

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn
	ADD PRIMARY KEY (mun_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
DROP INDEX IF EXISTS 	ego_political_boundary_hvmv_subst_per_gem_3_nn_geom_idx;
CREATE INDEX		ego_political_boundary_hvmv_subst_per_gem_3_nn_geom_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn
	USING	GIST (geom);

-- Create Index GIST (geom_sub)   (OK!) 2.500ms =0
DROP INDEX IF EXISTS 	ego_political_boundary_hvmv_subst_per_gem_3_nn_geom_subst_idx;
CREATE INDEX		ego_political_boundary_hvmv_subst_per_gem_3_nn_geom_subst_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn
	USING	GIST (geom_sub);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn OWNER TO oeuser;


---------- ---------- ----------
-- NN Line
---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line_id CASCADE;
CREATE SEQUENCE 		model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line_id;

-- Grant oeuser   (OK!) -> 100ms =0
ALTER SEQUENCE		model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line_id OWNER TO oeuser;

-- connect points   (OK!) 1.000ms =9.902
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line;
CREATE MATERIALIZED VIEW 		model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line AS
	SELECT 	nextval('model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line_id') AS id,
		nn.mun_id AS nn_id,
		nn.subst_id,
		(ST_Dump(ST_PointOnSurface(nn.geom))).geom ::geometry(Point,3035) AS geom_centre,
		ST_ShortestLine(	(ST_Dump(ST_PointOnSurface(nn.geom))).geom ::geometry(Point,3035),
					nn.geom_sub ::geometry(Point,3035)
		) ::geometry(LineString,3035) AS geom
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn AS nn;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_political_boundary_hvmv_subst_per_gem_3_nn_line_id_idx
		ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line (id);

-- Create Index GIST (geom_centre)   (OK!) 2.500ms =0
CREATE INDEX	ego_political_boundary_hvmv_subst_per_gem_3_nn_line_geom_centre_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line
	USING	GIST (geom_centre);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_political_boundary_hvmv_subst_per_gem_3_nn_line_geom_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line OWNER TO oeuser;


---------- ---------- ----------

-- UNION

-- union mun   (OK!) 33.000ms =2.077
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_union CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_union AS
	SELECT	un.subst_id ::integer AS subst_id,
		un.subst_type ::integer AS subst_type,
		un.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT DISTINCT ON (nn.subst_id)
			nn.subst_id AS subst_id,
			nn.subst_type AS subst_type,
			ST_MULTI(ST_UNION(nn.geom)) AS geom
		FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn AS nn
		GROUP BY nn.subst_id, nn.subst_type) AS un;

-- Create Index (subst_id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_political_boundary_hvmv_subst_per_gem_3_nn_union_subst_id_idx
		ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_union (subst_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_political_boundary_hvmv_subst_per_gem_3_nn_union_geom_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_union
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_union TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_union OWNER TO oeuser;

---------- ---------- ----------

-- Substations Template   (OK!) -> 100ms =3.610
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_type3 CASCADE;
CREATE TABLE		model_draft.ego_grid_mv_griddistrict_type3 AS
	SELECT	sub.subst_id ::integer,
		sub.subst_name ::text,
		sub.ags_0 ::character varying(12),
		sub.geom ::geometry(Point,3035) AS geom_sub
	FROM	model_draft.ego_grid_hvmv_substation AS sub;

-- Set PK   (OK!) -> 100ms =0
ALTER TABLE model_draft.ego_grid_mv_griddistrict_type3
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_type integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (subst_id);

-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	grid_district_type_3_geom_subst_idx
	ON	model_draft.ego_grid_mv_griddistrict_type3
	USING	GIST (geom_sub);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	grid_district_type_3_geom_mun_idx
	ON	model_draft.ego_grid_mv_griddistrict_type3
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_grid_mv_griddistrict_type3 TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_mv_griddistrict_type3 OWNER TO oeuser;

---------- ---------- ----------

-- update sub geom mun3   (OK!) -> 1.000ms =2.077
UPDATE 	model_draft.ego_grid_mv_griddistrict_type3 AS t1
SET  	subst_type = t2.subst_type,
	geom = t2.geom
FROM	(SELECT	un.subst_id AS subst_id,
		un.subst_type ::integer AS subst_type,
		ST_MULTI(un.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_union AS un ) AS t2
WHERE  	t1.subst_id = t2.subst_id;



---------- ---------- ----------
-- Collect the 3 Mun-types
---------- ---------- ----------

-- Substations Template   (OK!) -> 100ms =0
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_collect CASCADE;
CREATE TABLE		model_draft.ego_grid_mv_griddistrict_collect (
	id SERIAL NOT NULL,
	subst_id integer,
	subst_name text,
	ags_0 character varying(12),
	geom_sub geometry(Point,3035),
	subst_sum integer,
	subst_type integer,
	geom geometry(MultiPolygon,3035),
	CONSTRAINT	grid_district_collect_pkey PRIMARY KEY (id));

-- Insert 1   (OK!) 100.000ms =3.610
INSERT INTO     model_draft.ego_grid_mv_griddistrict_collect
	(subst_id,subst_name,ags_0,geom_sub,subst_sum,subst_type,geom)
	SELECT	*
	FROM	model_draft.ego_grid_mv_griddistrict_type1
	ORDER BY subst_id;

-- Insert 2   (OK!) 100.000ms =3.610
INSERT INTO     model_draft.ego_grid_mv_griddistrict_collect
	(subst_id,subst_name,ags_0,geom_sub,subst_sum,subst_type,geom)
	SELECT	*
	FROM	model_draft.ego_grid_mv_griddistrict_type2
	ORDER BY subst_id;

-- Insert 3   (OK!) 100.000ms =3.610
INSERT INTO     model_draft.ego_grid_mv_griddistrict_collect
	(subst_id,subst_name,ags_0,geom_sub,subst_sum,subst_type,geom)
	SELECT	*
	FROM	model_draft.ego_grid_mv_griddistrict_type3
	ORDER BY subst_id;


-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	grid_district_collect_geom_subst_idx
	ON	model_draft.ego_grid_mv_griddistrict_collect
	USING	GIST (geom_sub);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	grid_district_collect_geom_mun_idx
	ON	model_draft.ego_grid_mv_griddistrict_collect
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_grid_mv_griddistrict_collect TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_mv_griddistrict_collect OWNER TO oeuser;


---------- ---------- ----------

-- UNION I + II + II

-- -- union mun   (OK!) 19.000ms =3.707
-- DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict CASCADE;
-- CREATE TABLE 		model_draft.ego_grid_mv_griddistrict AS
-- 	SELECT	un.subst_id ::integer AS subst_id,
-- 		ST_AREA(un.geom)/10000 AS area_ha,
-- 		un.geom AS geom
-- 	FROM	(SELECT DISTINCT ON (dis.subst_id)
-- 			dis.subst_id AS subst_id,
-- 			ST_UNION(ST_SNAP(dis.geom,dis.geom,0.5))  AS geom
-- 		FROM	model_draft.ego_grid_mv_griddistrict_collect AS dis
-- 		GROUP BY dis.subst_id) AS un;
-- --::geometry(MultiPolygon,3035)

-- union mun   (OK!) 19.000ms =3.610
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict CASCADE;
CREATE TABLE 		model_draft.ego_grid_mv_griddistrict AS
SELECT DISTINCT ON 	(dis.subst_id)
			dis.subst_id AS subst_id,
			ST_MULTI(ST_UNION(dis.geom)) ::geometry(MultiPolygon,3035) AS geom
		FROM	model_draft.ego_grid_mv_griddistrict_collect AS dis
	GROUP BY 	dis.subst_id;

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	model_draft.ego_grid_mv_griddistrict
	ADD COLUMN subst_sum integer,
	ADD COLUMN area_ha decimal,
	ADD COLUMN geom_type text,
	ADD PRIMARY KEY (subst_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	grid_district_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	model_draft.ego_grid_mv_griddistrict TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_mv_griddistrict OWNER TO oeuser;

-- Count Substations in Grid Districts   (OK!) -> 1.000ms =3.610
UPDATE 	model_draft.ego_grid_mv_griddistrict AS t1
SET  	subst_sum = t2.subst_sum,
	area_ha = t2.area_ha,
	geom_type = t2.geom_type
FROM	(SELECT	dis.subst_id AS subst_id,
		ST_AREA(dis.geom)/10000 AS area_ha,
		COUNT(sub.geom)::integer AS subst_sum,
		GeometryType(dis.geom) ::text AS geom_type
	FROM	model_draft.ego_grid_mv_griddistrict AS dis,
		model_draft.ego_grid_hvmv_substation AS sub
	WHERE  	dis.geom && sub.geom AND
		ST_CONTAINS(dis.geom,sub.geom)
	GROUP BY dis.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

---------- ---------- ----------

-- Clean Polygons and Snap to Grid   (OK!) -> 11.000ms =3.610
UPDATE 	model_draft.ego_grid_mv_griddistrict AS t1
SET  	geom = t2.geom
FROM	(SELECT	dis.subst_id,
		ST_SnapToGrid(ST_MULTI(ST_BUFFER(ST_BUFFER(dis.geom,0.1),-0.1)),1) ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_mv_griddistrict AS dis
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_grid_mv_griddistrict' AS table_name,
		'process_eGo_grid_district.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_grid_mv_griddistrict;

	

---------- ---------- ---------- 
	
	
	
	

---------- ---------- ----------

/* -- Create Test Area
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_ta CASCADE;
CREATE TABLE 		model_draft.ego_grid_mv_griddistrict_ta AS
	SELECT	dis.*
	FROM	model_draft.ego_grid_mv_griddistrict AS dis
	WHERE	subst_id = '372' OR
		subst_id = '387' OR
		subst_id = '373' OR
		subst_id = '407' OR
		subst_id = '403' OR
		subst_id = '482' OR
		subst_id = '416' OR
		subst_id = '425' OR
		subst_id = '491' OR
		subst_id = '368' OR
		subst_id = '360' OR
		subst_id = '571' OR
		subst_id = '593';

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_ta
	ADD PRIMARY KEY (subst_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	grid_district_ta_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_ta
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	model_draft.ego_grid_mv_griddistrict_ta TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_mv_griddistrict_ta OWNER TO oeuser; */

---------- ---------- ----------


-- Grid Districts with Multipolygons (Bugs!)

DROP SEQUENCE IF EXISTS model_draft.ego_grid_mv_griddistrict_dump_id_seq;
CREATE SEQUENCE 	model_draft.ego_grid_mv_griddistrict_dump_id_seq;

-- Grant oeuser   (OK!) -> 100ms =0
ALTER SEQUENCE		model_draft.ego_grid_mv_griddistrict_dump_id_seq OWNER TO oeuser;

DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_dump CASCADE;
CREATE TABLE         	model_draft.ego_grid_mv_griddistrict_dump AS
	SELECT	nextval('model_draft.ego_grid_mv_griddistrict_dump_id_seq') AS id,
		subst_id,
		(ST_DUMP(dis.geom)).geom AS geom
	FROM	model_draft.ego_grid_mv_griddistrict AS dis;

ALTER TABLE model_draft.ego_grid_mv_griddistrict_dump
	ADD COLUMN subst_cnt integer,
	ADD PRIMARY KEY (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	grid_district_dump_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_dump
	USING	GIST (geom);

-- usw count   (OK!) -> 1.000ms =2.270
UPDATE 	model_draft.ego_grid_mv_griddistrict_dump AS t1
SET  	subst_cnt = t2.subst_cnt
FROM	(SELECT	mun.id AS id,
		COUNT(sub.geom)::integer AS subst_cnt
	FROM	model_draft.ego_grid_mv_griddistrict_dump AS mun,
		model_draft.ego_grid_hvmv_substation AS sub
	WHERE  	mun.geom && sub.geom AND
		ST_CONTAINS(mun.geom,sub.geom)
	GROUP BY mun.id
	)AS t2
WHERE  	t1.id = t2.id;

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	model_draft.ego_grid_mv_griddistrict_dump TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_mv_griddistrict_dump OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_grid_mv_griddistrict_dump' AS table_name,
		'process_eGo_grid_district.sql' AS script_name,
		COUNT(geom)AS entries,
		'BUGS' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_grid_mv_griddistrict_dump;


-- -- Dump Rings   (OK!) -> 22.000ms =0
-- SELECT	dis.subst_id,
-- 	ST_NumInteriorRings(dis.geom) ::integer AS count_ring
-- FROM	model_draft.ego_grid_mv_griddistrict AS dis
-- WHERE	ST_NumInteriorRings(dis.geom) <> 0;
-- 
-- -- Dump Rings   (OK!) -> 22.000ms =0
-- DROP SEQUENCE IF EXISTS model_draft.ego_grid_mv_griddistrict_rings_id CASCADE;
-- CREATE SEQUENCE model_draft.ego_grid_mv_griddistrict_rings_id;
-- DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_mv_griddistrict_rings CASCADE;
-- CREATE MATERIALIZED VIEW 		model_draft.ego_grid_mv_griddistrict_rings AS
-- 	SELECT	nextval('model_draft.ego_grid_mv_griddistrict_rings_id') AS id,
-- 		dis.subst_id,
-- 		ST_NumInteriorRings(dis.geom) AS count_ring,
-- 		(ST_DumpRings(dis.geom)).geom AS geom
-- 	FROM	model_draft.ego_grid_mv_griddistrict AS dis
-- 	WHERE	ST_NumInteriorRings(dis.geom) <> 0;
-- 
-- -- Dump Rings   (OK!) -> 22.000ms =0
-- DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_mv_griddistrict_rings_dump CASCADE;
-- CREATE MATERIALIZED VIEW 		model_draft.ego_grid_mv_griddistrict_rings_dump AS
-- 	SELECT	dump.id AS id,
-- 		dump.subst_id,
-- 		dump.count_ring,
-- 		ST_AREA(dump.geom) AS area_ha,
-- 		dump.geom AS geom
-- 	FROM	model_draft.ego_grid_mv_griddistrict_rings AS dump
-- 	WHERE	ST_AREA(dump.geom) > 1000000;



---------- ---------- ----------

-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	model_draft.ego_grid_mv_griddistrict_error_geom_view CASCADE;
-- CREATE VIEW		model_draft.ego_grid_mv_griddistrict_error_geom_view AS
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.subst_id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	model_draft.ego_grid_mv_griddistrict AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	model_draft.ego_grid_mv_griddistrict_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		model_draft.ego_grid_mv_griddistrict_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{grid_district_error_geom_view}', 'calc_grid_district');

-- ---------- ---------- ----------
-- -- DUMP
-- ---------- ---------- ----------
-- 
-- -- Sequence   (OK!) 100ms =0
-- DROP SEQUENCE IF EXISTS 	model_draft.ego_grid_mv_griddistrict_dump_id CASCADE;
-- CREATE SEQUENCE 		model_draft.ego_grid_mv_griddistrict_dump_id;
-- 
-- -- Dump   (OK!) 19.000ms =4.091
-- DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_dump CASCADE;
-- CREATE TABLE 		model_draft.ego_grid_mv_griddistrict_dump AS
-- 	SELECT	nextval('model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line_id') AS id,
-- 		dump.subst_id ::integer AS subst_id,
-- 		ST_AREA(dump.geom)/1000 AS area_ha,
-- 		dump.geom ::geometry(Polygon,3035) AS geom
-- 	FROM	(SELECT dis.subst_id AS subst_id,
-- 			(ST_DUMP(dis.geom)).geom ::geometry(Polygon,3035) AS geom
-- 		FROM	model_draft.ego_grid_mv_griddistrict AS dis) AS dump;
-- 
-- -- Ad PK   (OK!) 150ms =0
-- ALTER TABLE	model_draft.ego_grid_mv_griddistrict_dump
-- 	ADD COLUMN subst_sum integer,
-- 	ADD PRIMARY KEY (id);
-- 
-- -- Count Substations in Grid Districts   (OK!) -> 1.000ms =2.267
-- UPDATE 	model_draft.ego_grid_mv_griddistrict_dump AS t1
-- SET  	subst_sum = t2.subst_sum
-- FROM	(SELECT	dis.id AS id,
-- 		COUNT(sub.geom)::integer AS subst_sum
-- 	FROM	model_draft.ego_grid_mv_griddistrict_dump AS dis,
-- 		model_draft.ego_grid_hvmv_substation AS sub
-- 	WHERE  	dis.geom && sub.geom AND
-- 		ST_CONTAINS(dis.geom,sub.geom)
-- 	GROUP BY dis.id
-- 	)AS t2
-- WHERE  	t1.id = t2.id;
-- 
-- -- Create Index GIST (geom)   (OK!) 2.500ms =0
-- CREATE INDEX	grid_district_dump_geom_idx
-- 	ON	model_draft.ego_grid_mv_griddistrict_dump
-- 	USING	GIST (geom);

-- 

