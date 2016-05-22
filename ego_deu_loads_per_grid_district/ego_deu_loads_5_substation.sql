---------- ---------- ----------
---------- --SKRIPT-- OK! 7min
---------- ---------- ----------

-- -- Create schemas for open_eGo
-- DROP SCHEMA IF EXISTS	calc_ego_grid_districts;
-- CREATE SCHEMA 		calc_ego_grid_districts;
-- 
-- -- Set default privileges for schema
-- ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_grid_districts GRANT ALL ON TABLES TO oeuser;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_grid_districts GRANT ALL ON SEQUENCES TO oeuser;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_grid_districts GRANT ALL ON FUNCTIONS TO oeuser;
-- 
-- -- Grant all in schema
-- GRANT ALL ON SCHEMA 	calc_ego_grid_districts TO oeuser WITH GRANT OPTION;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA calc_ego_grid_districts TO oeuser;

---------- ---------- ----------
-- Substations 110 (mv)
---------- ---------- ----------

-- -- Substations   (OK!) 2.000ms =3.610
DROP TABLE IF EXISTS	calc_ego_grid_districts.substations_110 CASCADE;
CREATE TABLE		calc_ego_grid_districts.substations_110 AS
	SELECT	sub.id AS subst_id,
		sub.name AS subst_name,
		ST_TRANSFORM(sub.geom,3035) ::geometry(Point,3035) AS geom
	FROM	orig_ego.ego_deu_substations AS sub;

-- Set PK   (OK!) -> 2.000ms =0
ALTER TABLE calc_ego_grid_districts.substations_110
	ADD COLUMN	ags_0 character varying(12),
	ADD PRIMARY KEY (subst_id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	substations_110_geom_idx
	ON	calc_ego_grid_districts.substations_110
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.substations_110 TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.substations_110 OWNER TO oeuser;

-- "Calculate Gemeindeschlüssel"   (OK!) -> 3.000ms =3.610
UPDATE 	calc_ego_grid_districts.substations_110 AS t1
SET  	ags_0 = t2.ags_0
FROM    (
	SELECT	sub.subst_id,
		vg.ags_0
	FROM	calc_ego_grid_districts.substations_110 AS sub,
		orig_vg250.vg250_6_gem_clean_mview AS vg
	WHERE  	vg.geom && sub.geom AND
		ST_CONTAINS(vg.geom,sub.geom)
	) AS t2
WHERE  	t1.subst_id = t2.subst_id;

---------- ---------- ----------
-- Substations per Municipalities
---------- ---------- ----------

-- Municipalities   (OK!) -> 28.000ms =12.174
DROP TABLE IF EXISTS	calc_ego_grid_districts.municipalities_subst CASCADE;
CREATE TABLE		calc_ego_grid_districts.municipalities_subst AS
	SELECT	vg.*
	FROM	orig_vg250.vg250_6_gem_clean_mview AS vg;

-- Set PK   (OK!) -> 1.000ms =0
ALTER TABLE calc_ego_grid_districts.municipalities_subst
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_type integer,
	ADD PRIMARY KEY (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	municipalities_substst_geom_idx
	ON	calc_ego_grid_districts.municipalities_subst
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	calc_ego_grid_districts.municipalities_subst TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.municipalities_subst OWNER TO oeuser;

-- usw count   (OK!) -> 1.000ms =2.270
UPDATE 	calc_ego_grid_districts.municipalities_subst AS t1
SET  	subst_sum = t2.subst_sum
FROM	(SELECT	mun.id AS id,
		COUNT(sub.geom)::integer AS subst_sum
	FROM	calc_ego_grid_districts.municipalities_subst AS mun,
		calc_ego_grid_districts.substations_110 AS sub
	WHERE  	mun.geom && sub.geom AND
		ST_CONTAINS(mun.geom,sub.geom)
	GROUP BY mun.id
	)AS t2
WHERE  	t1.id = t2.id;

-- SELECT	sum(mun.subst_sum) AS sum
-- FROM	calc_ego_grid_districts.municipalities_subst AS mun;



---------- ---------- ----------
-- MViews
---------- ---------- ----------

-- MView I.   (OK!) -> 300ms =1.724
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.municipalities_subst_1_mview CASCADE;
CREATE MATERIALIZED VIEW		calc_ego_grid_districts.municipalities_subst_1_mview AS 
	SELECT	mun.id,
		mun.gen,
		mun.bez,
		mun.ags_0,
		'1' ::integer AS subst_type,
		mun.geom ::geometry(Polygon,3035) AS geom
	FROM	calc_ego_grid_districts.municipalities_subst AS mun
	WHERE	mun.subst_sum = '1';

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	municipalities_subst_1_mview_gid_idx
		ON	calc_ego_grid_districts.municipalities_subst_1_mview (id);

-- Substation Type 1   (OK!) -> 1.000ms =1.724
UPDATE 	calc_ego_grid_districts.municipalities_subst AS t1
SET  	subst_type = t2.subst_type
FROM	(SELECT	mun.id AS id,
		mun.subst_type AS subst_type
	FROM	calc_ego_grid_districts.municipalities_subst_1_mview AS mun )AS t2
WHERE  	t1.id = t2.id;

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.municipalities_subst_1_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.municipalities_subst_1_mview OWNER TO oeuser;

---------- ---------- ----------

-- MView II.   (OK!) -> 100ms =546
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.municipalities_subst_2_mview CASCADE;
CREATE MATERIALIZED VIEW		calc_ego_grid_districts.municipalities_subst_2_mview AS 
	SELECT	mun.id,
		mun.gen,
		mun.bez,
		mun.ags_0,
		'2' ::integer AS subst_type,
		mun.geom ::geometry(Polygon,3035) AS geom
	FROM	calc_ego_grid_districts.municipalities_subst AS mun
	WHERE	mun.subst_sum > '1';

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	municipalities_subst_2_mview_gid_idx
		ON	calc_ego_grid_districts.municipalities_subst_2_mview (id);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.municipalities_subst_2_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.municipalities_subst_2_mview OWNER TO oeuser;

-- Substation Type 2   (OK!) -> 1.000ms =546
UPDATE 	calc_ego_grid_districts.municipalities_subst AS t1
SET  	subst_type = t2.subst_type
FROM	(SELECT	mun.id AS id,
		mun.subst_type AS subst_type
	FROM	calc_ego_grid_districts.municipalities_subst_2_mview AS mun )AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- Substation Type 2   (OK!) -> 200ms =1.886
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.substations_110_mun_2_mview CASCADE;
CREATE MATERIALIZED VIEW		calc_ego_grid_districts.substations_110_mun_2_mview AS
	SELECT	sub.subst_id ::integer,
		sub.subst_name ::text,
		'3' ::integer AS subst_type,
		sub.geom ::geometry(Point,3035) AS geom
	FROM	calc_ego_grid_districts.substations_110 AS sub,
		calc_ego_grid_districts.municipalities_subst_2_mview AS mun
	WHERE  	mun.geom && sub.geom AND
		ST_CONTAINS(mun.geom,sub.geom);

-- Create Index (subst_id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	substations_110_mun_2_mview_subst_id_idx
		ON	calc_ego_grid_districts.substations_110_mun_2_mview (subst_id);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.substations_110_mun_2_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.substations_110_mun_2_mview OWNER TO oeuser;


---------- ---------- ----------

-- MView III.   (OK!) -> 22.000ms =9.904
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.municipalities_subst_3_mview CASCADE;
CREATE MATERIALIZED VIEW		calc_ego_grid_districts.municipalities_subst_3_mview AS 
	SELECT	mun.id,
		mun.gen,
		mun.bez,
		mun.ags_0,
		'3' ::integer AS subst_type,
		mun.geom ::geometry(Polygon,3035) AS geom
	FROM	calc_ego_grid_districts.municipalities_subst AS mun
	WHERE	mun.subst_sum IS NULL;

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	municipalities_subst_3_mview_gid_idx
		ON	calc_ego_grid_districts.municipalities_subst_3_mview (id);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.municipalities_subst_3_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.municipalities_subst_3_mview OWNER TO oeuser;


-- Substation Type 3   (OK!) -> 1.000ms =9.904
UPDATE 	calc_ego_grid_districts.municipalities_subst AS t1
SET  	subst_type = t2.subst_type
FROM	(SELECT	mun.id AS id,
		'3'::integer AS subst_type
	FROM	calc_ego_grid_districts.municipalities_subst_3_mview AS mun )AS t2
WHERE  	t1.id = t2.id;



---------- ---------- ----------
-- Grid Districts
---------- ---------- ----------

---------- ---------- ----------
-- I. Gemeinden mit genau einem USW 
---------- ---------- ----------

-- Substations Template   (OK!) -> 100ms =3.610
DROP TABLE IF EXISTS	calc_ego_grid_districts.grid_districts_type_1 CASCADE;
CREATE TABLE		calc_ego_grid_districts.grid_districts_type_1 AS
	SELECT	sub.subst_id ::integer,
		sub.subst_name ::text,
		sub.ags_0 ::character varying(12),
		sub.geom ::geometry(Point,3035) AS geom_sub
	FROM	calc_ego_grid_districts.substations_110 AS sub;

-- Set PK   (OK!) -> 100ms =0
ALTER TABLE calc_ego_grid_districts.grid_districts_type_1
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_type integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (subst_id);

-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	grid_districts_type_1_geom_subst_idx
	ON	calc_ego_grid_districts.grid_districts_type_1
	USING	GIST (geom_sub);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	grid_districts_type_1_geom_mun_idx
	ON	calc_ego_grid_districts.grid_districts_type_1
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.grid_districts_type_1 TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.grid_districts_type_1 OWNER TO oeuser;

-- subst_id = gem.id
-- update usw geom gem1   (OK!) -> 1.000ms =1.724
UPDATE 	calc_ego_grid_districts.grid_districts_type_1 AS t1
SET  	subst_sum  = t2.subst_sum,
	subst_type = t2.subst_type,
	geom = t2.geom
FROM	(SELECT	mun.ags_0,
		mun.subst_sum ::integer,
		mun.subst_type ::integer,
		ST_MULTI(mun.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	calc_ego_grid_districts.municipalities_subst AS mun
	WHERE	subst_type = '1')AS t2
WHERE  	t1.ags_0 = t2.ags_0;

---------- ---------- ---------- ---------- ---------- ----------
-- II. Gemeinden mit mehreren USW
---------- ---------- ---------- ---------- ---------- ----------

-- Create Table "substations_110_voronoi" 
-- with Script "data_processing\ego_deu_substations\substations_110_voronoi.sql"

-- Substation ID   (OK!) -> 1.000ms =3.610
UPDATE 	calc_ego_grid_districts.substations_110_voronoi AS t1
SET  	subst_id = t2.subst_id
FROM	(SELECT	voi.id AS id,
		sub.subst_id ::integer AS subst_id
	FROM	calc_ego_grid_districts.substations_110_voronoi AS voi,
		calc_ego_grid_districts.substations_110 AS sub
	WHERE  	voi.geom && sub.geom AND
		ST_CONTAINS(voi.geom,sub.geom)
	GROUP BY voi.id,sub.subst_id
	)AS t2
WHERE  	t1.id = t2.id;

-- Substation Count   (OK!) -> 1.000ms =3.610
UPDATE 	calc_ego_grid_districts.substations_110_voronoi AS t1
SET  	subst_sum = t2.subst_sum
FROM	(SELECT	voi.id AS id,
		COUNT(sub.geom)::integer AS subst_sum
	FROM	calc_ego_grid_districts.substations_110_voronoi AS voi,
		calc_ego_grid_districts.substations_110 AS sub
	WHERE  	voi.geom && sub.geom AND
		ST_CONTAINS(voi.geom,sub.geom)
	GROUP BY voi.id
	)AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- Voronoi Gridcells (voi)   (OK!) 100ms =3.610
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.substations_110_voronoi_mview CASCADE;
CREATE MATERIALIZED VIEW		calc_ego_grid_districts.substations_110_voronoi_mview AS
	SELECT	voi.id ::integer,
		voi.subst_id ::integer,
		voi.subst_sum ::integer,
		(ST_DUMP(voi.geom)).geom ::geometry(Polygon,3035) AS geom
	FROM	calc_ego_grid_districts.substations_110_voronoi AS voi
	WHERE	subst_sum = '1';

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	substations_110_voronoi_mview_id_idx
		ON	calc_ego_grid_districts.substations_110_voronoi_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	substations_110_voronoi_mview_geom_idx
	ON	calc_ego_grid_districts.substations_110_voronoi_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.substations_110_voronoi_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.substations_110_voronoi_mview OWNER TO oeuser;

---------- ---------- ----------
-- 
-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	calc_ego_grid_districts.substations_110_voronoi_error_geom_view CASCADE;
-- CREATE VIEW		calc_ego_grid_districts.substations_110_voronoi_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	calc_ego_grid_districts.ego_deu_substations_voronoi AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	calc_ego_grid_districts.substations_110_voronoi_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		calc_ego_grid_districts.substations_110_voronoi_error_geom_view OWNER TO oeuser;

-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{substations_110_voronoi_error_geom_view}', 'calc_grid_districts');


---------- ---------- ----------
-- CUT
---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	calc_ego_grid_districts.substations_110_voronoi_cut_id CASCADE;
CREATE SEQUENCE 		calc_ego_grid_districts.substations_110_voronoi_cut_id;

-- Cutting GEM II.   (OK!) 3.000ms =4.531
DROP TABLE IF EXISTS	calc_ego_grid_districts.substations_110_voronoi_cut CASCADE;
CREATE TABLE		calc_ego_grid_districts.substations_110_voronoi_cut AS
	SELECT	nextval('calc_ego_grid_districts.substations_110_voronoi_cut_id') AS id,
		voi.subst_id,
		mun.id AS mun_id,
		voi.id AS voi_id,
		mun.ags_0 AS ags_0,
		mun.subst_type,
		(ST_DUMP(ST_INTERSECTION(mun.geom,voi.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	calc_ego_grid_districts.municipalities_subst_2_mview AS mun,
		calc_ego_grid_districts.substations_110_voronoi_mview AS voi
	WHERE	mun.geom && voi.geom;

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	calc_ego_grid_districts.substations_110_voronoi_cut
	ADD COLUMN subst_sum integer,
	ADD COLUMN geom_sub geometry(Point,3035),
	ADD PRIMARY KEY (id);

-- Count Substations in Voronoi Cuts   (OK!) -> 1.000ms =1.886
UPDATE 	calc_ego_grid_districts.substations_110_voronoi_cut AS t1
SET  	subst_sum = t2.subst_sum,
	subst_id = t2.subst_id,
	geom_sub = t2.geom_sub
FROM	(SELECT	mun.id AS id,
		sub.subst_id,
		sub.geom AS geom_sub,
		COUNT(sub.geom)::integer AS subst_sum
	FROM	calc_ego_grid_districts.substations_110_voronoi_cut AS mun,
		calc_ego_grid_districts.substations_110 AS sub
	WHERE  	mun.geom && sub.geom AND
		ST_CONTAINS(mun.geom,sub.geom)
	GROUP BY mun.id,sub.subst_id
	)AS t2
WHERE  	t1.id = t2.id;

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	substations_110_voronoi_cut_geom_idx
	ON	calc_ego_grid_districts.substations_110_voronoi_cut
	USING	GIST (geom);

-- Create Index GIST (geom_sub)   (OK!) 2.500ms =0
CREATE INDEX	substations_110_voronoi_cut_geom_subst_idx
	ON	calc_ego_grid_districts.substations_110_voronoi_cut
	USING	GIST (geom_sub);
	
-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	calc_ego_grid_districts.substations_110_voronoi_cut TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.substations_110_voronoi_cut OWNER TO oeuser;

---------- ---------- ----------

-- Validate (geom)   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	calc_ego_grid_districts.substations_110_voronoi_cut_error_geom_view CASCADE;
CREATE VIEW		calc_ego_grid_districts.substations_110_voronoi_cut_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	calc_ego_grid_districts.substations_110_voronoi_cut AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	calc_ego_grid_districts.substations_110_voronoi_cut_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.substations_110_voronoi_cut_error_geom_view OWNER TO oeuser;

-- -- Drop empty view   (OK!) -> 100ms =1 (no error!)
-- SELECT f_drop_view('{substations_110_voronoi_cut_error_geom_view}', 'calc_grid_districts');

---------- ---------- ----------

-- Parts with substation   (OK!) 100ms =1.886
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.substations_110_voronoi_cut_1subst_mview CASCADE;
CREATE MATERIALIZED VIEW		calc_ego_grid_districts.substations_110_voronoi_cut_1subst_mview AS
SELECT	voi.*
FROM	calc_ego_grid_districts.substations_110_voronoi_cut AS voi
WHERE	subst_sum = 1;

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	substations_110_voronoi_cut_1subst_mview_id_idx
		ON	calc_ego_grid_districts.substations_110_voronoi_cut_1subst_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	substations_110_voronoi_cut_1subst_mview_geom_idx
	ON	calc_ego_grid_districts.substations_110_voronoi_cut_1subst_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.substations_110_voronoi_cut_1subst_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.substations_110_voronoi_cut_1subst_mview OWNER TO oeuser;

---------- ---------- ----------

-- Parts without substation   (OK!) 100ms =2.645
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_mview CASCADE;
CREATE MATERIALIZED VIEW		calc_ego_grid_districts.substations_110_voronoi_cut_0subst_mview AS
SELECT	voi.id,
	voi.subst_id,
	voi.mun_id,
	voi.voi_id,
	voi.ags_0,
	voi.subst_type,
	voi.geom
FROM	calc_ego_grid_districts.substations_110_voronoi_cut AS voi
WHERE	subst_sum IS NULL;

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	substations_110_voronoi_cut_0subst_mview_id_idx
		ON	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	substations_110_voronoi_cut_0subst_mview_geom_idx
	ON	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.substations_110_voronoi_cut_0subst_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- Calculate Gemeindeschlüssel   (OK!) -> 3.000ms =4.981
-- UPDATE 	calc_ego_grid_districts.substations_110_voronoi_cut AS t1
-- SET  	ags_0 = t2.ags_0
-- FROM    (
-- 	SELECT	cut.id AS id,
-- 		vg.ags_0 AS ags_0
-- 	FROM	calc_ego_grid_districts.substations_110_voronoi_cut AS cut,
-- 		orig_geo_vg250.vg250_6_gem_mview AS vg
-- 	WHERE  	vg.geom && ST_POINTONSURFACE(cut.geom) AND
-- 		ST_CONTAINS(vg.geom,ST_POINTONSURFACE(cut.geom))
-- 	) AS t2
-- WHERE  	t1.id = t2.id;


---------- ---------- ----------
-- Connect the cutted parts to the next substation
---------- ---------- ----------

-- Next Neighbor   (OK!) 1.000ms =2.645
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_mview CASCADE;
CREATE MATERIALIZED VIEW 		calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_mview AS 
SELECT DISTINCT ON (voi.id)
	voi.id AS voi_id,
	voi.ags_0 AS voi_ags_0,
	voi.geom AS geom_voi,
	sub.subst_id AS subst_id,
	sub.ags_0 AS ags_0,
	sub.geom AS geom_sub
FROM 	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_mview AS voi,
	calc_ego_grid_districts.substations_110_voronoi_cut_1subst_mview AS sub
WHERE 	ST_DWithin(ST_ExteriorRing(voi.geom),ST_ExteriorRing(sub.geom), 50000) -- In a 50 km radius
	AND voi.ags_0 = sub.ags_0  -- only inside same mun
ORDER BY 	voi.id, 
		ST_Distance(ST_ExteriorRing(voi.geom),ST_ExteriorRing(sub.geom));
		
-- ST_Length(ST_CollectionExtract(ST_Intersection(a_geom, b_geom), 2)) -- Lenght of the shared border?

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	substations_110_voronoi_cut_0subst_nn_mview_voi_id_idx
		ON	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_mview (voi_id);

-- Create Index GIST (geom_voi)   (OK!) -> 100ms =0
CREATE INDEX  	substations_110_voronoi_cut_0subst_nn_mview_geom_voi_idx
	ON	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_mview
	USING	GIST (geom_voi);

-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	substations_110_voronoi_cut_0subst_nn_mview_geom_subst_idx
	ON	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_mview
	USING	GIST (geom_sub);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_mview OWNER TO oeuser;

---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_line_mview_id CASCADE;
CREATE SEQUENCE 		calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_line_mview_id;

-- connect points   (OK!) 1.000ms =2.645
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_line_mview;
CREATE MATERIALIZED VIEW 		calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_line_mview AS 
	SELECT 	nextval('calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_line_mview_id') AS id,
		nn.voi_id,
		nn.subst_id,
		(ST_Dump(ST_CENTROID(nn.geom_voi))).geom ::geometry(Point,3035) AS geom_centre,
		ST_ShortestLine(	(ST_Dump(ST_CENTROID(nn.geom_voi))).geom ::geometry(Point,3035),
					sub.geom ::geometry(Point,3035)
		) ::geometry(LineString,3035) AS geom
	FROM	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_mview AS nn,
		calc_ego_grid_districts.substations_110 AS sub
	WHERE	sub.subst_id = nn.subst_id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	substations_110_voronoi_cut_0subst_nn_line_mview_id_idx
		ON	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_line_mview (id);

-- Create Index GIST (geom_centre)   (OK!) 2.500ms =0
CREATE INDEX	substations_110_voronoi_cut_0subst_nn_line_mview_geom_centre_idx
	ON	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_line_mview
	USING	GIST (geom_centre);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	substations_110_voronoi_cut_0subst_nn_line_mview_geom_idx
	ON	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_line_mview
	USING	GIST (geom);

---------- ---------- ----------

-- Create Table   (OK!) 4.000ms =1.057
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_union_mview CASCADE;
CREATE MATERIALIZED VIEW		calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_union_mview AS 
	SELECT	nn.subst_id As subst_id, 
		ST_MULTI(ST_UNION(nn.geom_voi)) ::geometry(MultiPolygon,3035) AS geom
	FROM	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_mview AS nn
	GROUP BY nn.subst_id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	substations_110_voronoi_cut_0subst_nn_union_mview_id_idx
		ON	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_union_mview (subst_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	substations_110_voronoi_cut_0subst_nn_union_mview_geom_idx
	ON	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_union_mview
	USING	GIST (geom);

---------- ---------- ----------

-- Create Table   (OK!) 4.000ms =0
DROP TABLE IF EXISTS	calc_ego_grid_districts.substations_110_voronoi_cut_nn_collect CASCADE;
CREATE TABLE		calc_ego_grid_districts.substations_110_voronoi_cut_nn_collect (
	id serial,
	subst_id integer,
	geom geometry(MultiPolygon,3035),
CONSTRAINT substations_110_voronoi_cut_nn_collect_pkey PRIMARY KEY (id));

-- Insert parts with substations   (OK!) 4.000ms =1.886
INSERT INTO     calc_ego_grid_districts.substations_110_voronoi_cut_nn_collect (subst_id,geom)
	SELECT	sub.subst_id AS subst_id,
		ST_MULTI(sub.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	calc_ego_grid_districts.substations_110_voronoi_cut_1subst_mview AS sub;

-- Insert parts without substations union   (OK!) 4.000ms =1.103
INSERT INTO     calc_ego_grid_districts.substations_110_voronoi_cut_nn_collect (subst_id,geom)
	SELECT	voi.subst_id AS subst_id,
		voi.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	calc_ego_grid_districts.substations_110_voronoi_cut_0subst_nn_union_mview AS voi;

-- Create Index GIST (geom)   (OK!) 11.000ms =0
CREATE INDEX	substations_110_voronoi_cut_nn_collect_geom_idx
	ON	calc_ego_grid_districts.substations_110_voronoi_cut_nn_collect
	USING	GIST (geom);

---------- ---------- ----------

-- Create Table   (OK!) 4.000ms =1.886
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.substations_110_voronoi_cut_nn_mview CASCADE;
CREATE MATERIALIZED VIEW		calc_ego_grid_districts.substations_110_voronoi_cut_nn_mview AS 
	SELECT	nn.subst_id As subst_id, 
		ST_MULTI(ST_UNION(nn.geom)) ::geometry(MultiPolygon,3035) AS geom
	FROM	calc_ego_grid_districts.substations_110_voronoi_cut_nn_collect AS nn
	GROUP BY nn.subst_id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	substations_110_voronoi_cut_nn_mview_id_idx
		ON	calc_ego_grid_districts.substations_110_voronoi_cut_nn_mview (subst_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	substations_110_voronoi_cut_nn_mview_geom_idx
	ON	calc_ego_grid_districts.substations_110_voronoi_cut_nn_mview
	USING	GIST (geom);

---------- ---------- ----------

-- Substations Template   (OK!) -> 100ms =3.610
DROP TABLE IF EXISTS	calc_ego_grid_districts.grid_districts_type_2 CASCADE;
CREATE TABLE		calc_ego_grid_districts.grid_districts_type_2 AS
	SELECT	sub.subst_id ::integer,
		sub.subst_name ::text,
		sub.ags_0 ::character varying(12),
		sub.geom ::geometry(Point,3035) AS geom_sub
	FROM	calc_ego_grid_districts.substations_110 AS sub;

-- Set PK   (OK!) -> 100ms =0
ALTER TABLE calc_ego_grid_districts.grid_districts_type_2
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_type integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (subst_id);

-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	grid_districts_type_2_geom_subst_idx
	ON	calc_ego_grid_districts.grid_districts_type_2
	USING	GIST (geom_sub);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	grid_districts_type_2_geom_mun_idx
	ON	calc_ego_grid_districts.grid_districts_type_2
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.grid_districts_type_2 TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.grid_districts_type_2 OWNER TO oeuser;

---------- ---------- ----------

-- subst_id = id
-- update sub geom gem2   (OK!) -> 1.000ms =1.886
UPDATE 	calc_ego_grid_districts.grid_districts_type_2 AS t1
SET  	subst_type = t2.subst_type,
	geom = t2.geom
FROM	(SELECT	nn.subst_id AS subst_id,
		'2' ::integer AS subst_type,
		nn.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	calc_ego_grid_districts.substations_110_voronoi_cut_nn_mview AS nn )AS t2
WHERE  	t1.subst_id = t2.subst_id;

---------- ---------- ----------
-- 
-- -- voi   (OK!) 100ms =3.693
-- DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.ego_deu_usw_voronoi_mview CASCADE;
-- CREATE MATERIALIZED VIEW		calc_ego_grid_districts.ego_deu_usw_voronoi_mview AS
-- 	SELECT	poly.id ::integer AS id,
-- 		(ST_DUMP(ST_TRANSFORM(poly.geom,3035))).geom ::geometry(Polygon,3035) AS geom
-- 	FROM	calc_ego_grid_districts.ego_deu_usw_voronoi AS poly;
-- 
-- -- Create Index GIST (geom)   (OK!) -> 100ms =0
-- CREATE INDEX  	ego_deu_usw_voronoi_mview_geom_idx
-- 	ON	calc_ego_grid_districts.ego_deu_usw_voronoi_mview
-- 	USING	GIST (geom);
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	calc_ego_grid_districts.ego_deu_usw_voronoi_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		calc_ego_grid_districts.ego_deu_usw_voronoi_mview OWNER TO oeuser;
-- 
-- ---------- ---------- ----------	
-- 
-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	calc_ego_grid_districts.ego_deu_usw_voronoi_mview_error_geom_view CASCADE;
-- CREATE VIEW		calc_ego_grid_districts.ego_deu_usw_voronoi_mview_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	calc_ego_grid_districts.ego_deu_usw_voronoi_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	calc_ego_grid_districts.ego_deu_usw_voronoi_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		calc_ego_grid_districts.ego_deu_usw_voronoi_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_deu_usw_voronoi_mview_error_geom_view}', 'calc_grid_districts');

---------- ---------- ----------



---------- ---------- ----------

-- DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.vg250_6_gem_subst_2_pts_mview CASCADE;
-- CREATE MATERIALIZED VIEW		calc_ego_grid_districts.vg250_6_gem_subst_2_pts_mview AS 
-- 	SELECT	'1' ::integer AS id,
-- 		ST_SetSRID(ST_Union(sub.geom), 0) AS geom
-- 	FROM	calc_gridcells_znes.znes_deu_substations_filtered AS sub
-- 	WHERE	subst_id = '3791' OR subst_id = '3765';

-- -- (POSTGIS 2.3!!!)
-- DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.vg250_6_gem_subst_2_voronoi_mview CASCADE;
-- CREATE MATERIALIZED VIEW		calc_ego_grid_districts.vg250_6_gem_subst_2_voronoi_mview AS 
-- 	SELECT	gem2.gid AS id,
-- 		ST_Voronoi(sub.geom,gem2.geom,30,true) AS geom
-- 	FROM	calc_ego_grid_districts.vg250_6_gem_subst_2_pts_mview AS sub,
-- 		calc_ego_grid_districts.vg250_6_gem_subst_2_mview AS gem2
-- 	WHERE	gem2.gid = '4884'



---------- ---------- ----------
-- III. Gemeinden ohne sub
---------- ---------- ----------

-- gem WHERE subst_sum=0		orig_geo_ego.vg250_6_gem_subst_3_mview
-- sub				orig_geo_ego.ego_deu_mv_substations_mview

-- Next Neighbor   (OK!) 14.000ms =10.259
DROP TABLE IF EXISTS	calc_ego_grid_districts.municipalities_subst_3_nn CASCADE;
CREATE TABLE 		calc_ego_grid_districts.municipalities_subst_3_nn AS 
SELECT DISTINCT ON (mun.id)
	mun.id AS mun_id,
	mun.ags_0 AS mun_ags_0,
	sub.ags_0 AS subst_ags_0,
	sub.subst_id, 
	mun.subst_type,
	sub.geom ::geometry(Point,3035) AS geom_sub,
	ST_Distance(ST_ExteriorRing(mun.geom),sub.geom) AS distance,
	ST_MULTI(mun.geom) ::geometry(MultiPolygon,3035) AS geom
FROM 	calc_ego_grid_districts.municipalities_subst_3_mview AS mun, 
	calc_ego_grid_districts.substations_110 AS sub
WHERE 	ST_DWithin(ST_ExteriorRing(mun.geom),sub.geom, 50000) -- In a 50 km radius
ORDER BY 	mun.id, ST_Distance(ST_ExteriorRing(mun.geom),sub.geom);

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	calc_ego_grid_districts.municipalities_subst_3_nn
	ADD PRIMARY KEY (mun_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
DROP INDEX IF EXISTS 	municipalities_subst_3_nn_geom_idx;
CREATE INDEX		municipalities_subst_3_nn_geom_idx
	ON	calc_ego_grid_districts.municipalities_subst_3_nn
	USING	GIST (geom);

-- Create Index GIST (geom_sub)   (OK!) 2.500ms =0
DROP INDEX IF EXISTS 	municipalities_subst_3_nn_geom_subst_idx;
CREATE INDEX		municipalities_subst_3_nn_geom_subst_idx
	ON	calc_ego_grid_districts.municipalities_subst_3_nn
	USING	GIST (geom_sub);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	calc_ego_grid_districts.municipalities_subst_3_nn TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.municipalities_subst_3_nn OWNER TO oeuser;


---------- ---------- ----------
-- NN Line
---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	calc_ego_grid_districts.municipalities_subst_3_nn_line_id CASCADE;
CREATE SEQUENCE 		calc_ego_grid_districts.municipalities_subst_3_nn_line_id;

-- connect points   (OK!) 1.000ms =9.902
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.municipalities_subst_3_nn_line;
CREATE MATERIALIZED VIEW 		calc_ego_grid_districts.municipalities_subst_3_nn_line AS 
	SELECT 	nextval('calc_ego_grid_districts.municipalities_subst_3_nn_line_id') AS id,
		nn.mun_id AS nn_id,
		nn.subst_id,
		(ST_Dump(ST_PointOnSurface(nn.geom))).geom ::geometry(Point,3035) AS geom_centre,
		ST_ShortestLine(	(ST_Dump(ST_PointOnSurface(nn.geom))).geom ::geometry(Point,3035),
					nn.geom_sub ::geometry(Point,3035)
		) ::geometry(LineString,3035) AS geom
	FROM	calc_ego_grid_districts.municipalities_subst_3_nn AS nn;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	municipalities_subst_3_nn_line_id_idx
		ON	calc_ego_grid_districts.municipalities_subst_3_nn_line (id);

-- Create Index GIST (geom_centre)   (OK!) 2.500ms =0
CREATE INDEX	municipalities_subst_3_nn_line_geom_centre_idx
	ON	calc_ego_grid_districts.municipalities_subst_3_nn_line
	USING	GIST (geom_centre);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	municipalities_subst_3_nn_line_geom_idx
	ON	calc_ego_grid_districts.municipalities_subst_3_nn_line
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	calc_ego_grid_districts.municipalities_subst_3_nn_line TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.municipalities_subst_3_nn_line OWNER TO oeuser;


---------- ---------- ----------

-- UNION

-- union mun   (OK!) 33.000ms =2.077
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.municipalities_subst_3_nn_union CASCADE;
CREATE MATERIALIZED VIEW 		calc_ego_grid_districts.municipalities_subst_3_nn_union AS 
	SELECT	un.subst_id ::integer AS subst_id,
		un.subst_type ::integer AS subst_type,
		un.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT DISTINCT ON (nn.subst_id)
			nn.subst_id AS subst_id,
			nn.subst_type AS subst_type,
			ST_MULTI(ST_UNION(nn.geom)) AS geom
		FROM	calc_ego_grid_districts.municipalities_subst_3_nn AS nn
		GROUP BY nn.subst_id, nn.subst_type) AS un;

-- Create Index (subst_id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	municipalities_subst_3_nn_union_subst_id_idx
		ON	calc_ego_grid_districts.municipalities_subst_3_nn_union (subst_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	municipalities_subst_3_nn_union_geom_idx
	ON	calc_ego_grid_districts.municipalities_subst_3_nn_union
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	calc_ego_grid_districts.municipalities_subst_3_nn_union TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.municipalities_subst_3_nn_union OWNER TO oeuser;

---------- ---------- ----------

-- Substations Template   (OK!) -> 100ms =3.610
DROP TABLE IF EXISTS	calc_ego_grid_districts.grid_districts_type_3 CASCADE;
CREATE TABLE		calc_ego_grid_districts.grid_districts_type_3 AS
	SELECT	sub.subst_id ::integer,
		sub.subst_name ::text,
		sub.ags_0 ::character varying(12),
		sub.geom ::geometry(Point,3035) AS geom_sub
	FROM	calc_ego_grid_districts.substations_110 AS sub;

-- Set PK   (OK!) -> 100ms =0
ALTER TABLE calc_ego_grid_districts.grid_districts_type_3
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_type integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (subst_id);

-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	grid_districts_type_3_geom_subst_idx
	ON	calc_ego_grid_districts.grid_districts_type_3
	USING	GIST (geom_sub);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	grid_districts_type_3_geom_mun_idx
	ON	calc_ego_grid_districts.grid_districts_type_3
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.grid_districts_type_3 TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.grid_districts_type_3 OWNER TO oeuser;

---------- ---------- ----------

-- update sub geom mun3   (OK!) -> 1.000ms =2.077
UPDATE 	calc_ego_grid_districts.grid_districts_type_3 AS t1
SET  	subst_type = t2.subst_type,
	geom = t2.geom
FROM	(SELECT	un.subst_id AS subst_id,
		un.subst_type ::integer AS subst_type,
		ST_MULTI(un.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	calc_ego_grid_districts.municipalities_subst_3_nn_union AS un ) AS t2
WHERE  	t1.subst_id = t2.subst_id;



---------- ---------- ----------
-- Collect the 3 Mun-types
---------- ---------- ----------

-- Substations Template   (OK!) -> 100ms =0
DROP TABLE IF EXISTS	calc_ego_grid_districts.grid_districts_collect CASCADE;
CREATE TABLE		calc_ego_grid_districts.grid_districts_collect (
	id SERIAL NOT NULL,
	subst_id integer,
	subst_name text,
	ags_0 character varying(12),
	geom_sub geometry(Point,3035),
	subst_sum integer,
	subst_type integer,
	geom geometry(MultiPolygon,3035),
	CONSTRAINT	grid_districts_collect_pkey PRIMARY KEY (id));

-- Insert 1   (OK!) 100.000ms =3.610
INSERT INTO     calc_ego_grid_districts.grid_districts_collect 
	(subst_id,subst_name,ags_0,geom_sub,subst_sum,subst_type,geom)
	SELECT	*
	FROM	calc_ego_grid_districts.grid_districts_type_1
	ORDER BY subst_id;

-- Insert 2   (OK!) 100.000ms =3.610
INSERT INTO     calc_ego_grid_districts.grid_districts_collect 
	(subst_id,subst_name,ags_0,geom_sub,subst_sum,subst_type,geom)
	SELECT	*
	FROM	calc_ego_grid_districts.grid_districts_type_2
	ORDER BY subst_id;

-- Insert 3   (OK!) 100.000ms =3.610
INSERT INTO     calc_ego_grid_districts.grid_districts_collect 
	(subst_id,subst_name,ags_0,geom_sub,subst_sum,subst_type,geom)
	SELECT	*
	FROM	calc_ego_grid_districts.grid_districts_type_3
	ORDER BY subst_id;


-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	grid_districts_collect_geom_subst_idx
	ON	calc_ego_grid_districts.grid_districts_collect
	USING	GIST (geom_sub);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	grid_districts_collect_geom_mun_idx
	ON	calc_ego_grid_districts.grid_districts_collect
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.grid_districts_collect TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.grid_districts_collect OWNER TO oeuser;


---------- ---------- ----------

-- UNION I + II + II

-- -- union mun   (OK!) 19.000ms =3.707
-- DROP TABLE IF EXISTS	calc_ego_grid_districts.grid_districts CASCADE;
-- CREATE TABLE 		calc_ego_grid_districts.grid_districts AS 
-- 	SELECT	un.subst_id ::integer AS subst_id,
-- 		ST_AREA(un.geom)/10000 AS area_ha,
-- 		un.geom AS geom
-- 	FROM	(SELECT DISTINCT ON (dis.subst_id)
-- 			dis.subst_id AS subst_id,
-- 			ST_UNION(ST_SNAP(dis.geom,dis.geom,0.5))  AS geom
-- 		FROM	calc_ego_grid_districts.grid_districts_collect AS dis
-- 		GROUP BY dis.subst_id) AS un;
-- --::geometry(MultiPolygon,3035)

-- union mun   (OK!) 19.000ms =3.610
DROP TABLE IF EXISTS	calc_ego_grid_districts.grid_districts CASCADE;
CREATE TABLE 		calc_ego_grid_districts.grid_districts AS 
SELECT DISTINCT ON 	(dis.subst_id)
			dis.subst_id AS subst_id,
			ST_MULTI(ST_UNION(dis.geom)) ::geometry(MultiPolygon,3035) AS geom
		FROM	calc_ego_grid_districts.grid_districts_collect AS dis
	GROUP BY 	dis.subst_id;

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	calc_ego_grid_districts.grid_districts
	ADD COLUMN subst_sum integer,
	ADD COLUMN area_ha decimal,
	ADD COLUMN geom_type text,
	ADD PRIMARY KEY (subst_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	grid_districts_geom_idx
	ON	calc_ego_grid_districts.grid_districts
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	calc_ego_grid_districts.grid_districts TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.grid_districts OWNER TO oeuser;

-- Count Substations in Grid Districts   (OK!) -> 1.000ms =3.610
UPDATE 	calc_ego_grid_districts.grid_districts AS t1
SET  	subst_sum = t2.subst_sum,
	area_ha = t2.area_ha,
	geom_type = t2.geom_type
FROM	(SELECT	dis.subst_id AS subst_id,
		ST_AREA(dis.geom)/10000 AS area_ha,
		COUNT(sub.geom)::integer AS subst_sum,
		GeometryType(dis.geom) ::text AS geom_type
	FROM	calc_ego_grid_districts.grid_districts AS dis,
		calc_ego_grid_districts.substations_110 AS sub
	WHERE  	dis.geom && sub.geom AND
		ST_CONTAINS(dis.geom,sub.geom)
	GROUP BY dis.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;


---------- ---------- ----------

-- -- Dump Rings   (OK!) -> 22.000ms =0
-- SELECT	dis.subst_id,
-- 	ST_NumInteriorRings(dis.geom) ::integer AS count_ring
-- FROM	calc_ego_grid_districts.grid_districts AS dis
-- WHERE	ST_NumInteriorRings(dis.geom) <> 0;
-- 
-- -- Dump Rings   (OK!) -> 22.000ms =0
-- DROP SEQUENCE IF EXISTS calc_ego_grid_districts.grid_districts_rings_id CASCADE;
-- CREATE SEQUENCE calc_ego_grid_districts.grid_districts_rings_id;
-- DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.grid_districts_rings CASCADE;
-- CREATE MATERIALIZED VIEW 		calc_ego_grid_districts.grid_districts_rings AS 
-- 	SELECT	nextval('calc_ego_grid_districts.grid_districts_rings_id') AS id,
-- 		dis.subst_id,
-- 		ST_NumInteriorRings(dis.geom) AS count_ring,
-- 		(ST_DumpRings(dis.geom)).geom AS geom
-- 	FROM	calc_ego_grid_districts.grid_districts AS dis
-- 	WHERE	ST_NumInteriorRings(dis.geom) <> 0;
-- 
-- -- Dump Rings   (OK!) -> 22.000ms =0
-- DROP MATERIALIZED VIEW IF EXISTS	calc_ego_grid_districts.grid_districts_rings_dump CASCADE;
-- CREATE MATERIALIZED VIEW 		calc_ego_grid_districts.grid_districts_rings_dump AS 
-- 	SELECT	dump.id AS id,
-- 		dump.subst_id,
-- 		dump.count_ring,
-- 		ST_AREA(dump.geom) AS area_ha,
-- 		dump.geom AS geom
-- 	FROM	calc_ego_grid_districts.grid_districts_rings AS dump
-- 	WHERE	ST_AREA(dump.geom) > 1000000;



---------- ---------- ----------

-- Validate (geom)   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	calc_ego_grid_districts.grid_districts_error_geom_view CASCADE;
CREATE VIEW		calc_ego_grid_districts.grid_districts_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.subst_id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	calc_ego_grid_districts.grid_districts AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	calc_ego_grid_districts.grid_districts_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.grid_districts_error_geom_view OWNER TO oeuser;

-- Drop empty view   (OK!) -> 100ms =1
SELECT f_drop_view('{grid_districts_error_geom_view}', 'calc_grid_districts');

-- ---------- ---------- ----------
-- -- DUMP
-- ---------- ---------- ----------
-- 
-- -- Sequence   (OK!) 100ms =0
-- DROP SEQUENCE IF EXISTS 	calc_ego_grid_districts.grid_districts_dump_id CASCADE;
-- CREATE SEQUENCE 		calc_ego_grid_districts.grid_districts_dump_id;
-- 
-- -- Dump   (OK!) 19.000ms =4.091
-- DROP TABLE IF EXISTS	calc_ego_grid_districts.grid_districts_dump CASCADE;
-- CREATE TABLE 		calc_ego_grid_districts.grid_districts_dump AS 
-- 	SELECT	nextval('calc_ego_grid_districts.municipalities_subst_3_nn_line_id') AS id,
-- 		dump.subst_id ::integer AS subst_id,
-- 		ST_AREA(dump.geom)/1000 AS area_ha,
-- 		dump.geom ::geometry(Polygon,3035) AS geom
-- 	FROM	(SELECT dis.subst_id AS subst_id,
-- 			(ST_DUMP(dis.geom)).geom ::geometry(Polygon,3035) AS geom
-- 		FROM	calc_ego_grid_districts.grid_districts AS dis) AS dump;
-- 
-- -- Ad PK   (OK!) 150ms =0
-- ALTER TABLE	calc_ego_grid_districts.grid_districts_dump
-- 	ADD COLUMN subst_sum integer,
-- 	ADD PRIMARY KEY (id);
-- 
-- -- Count Substations in Grid Districts   (OK!) -> 1.000ms =2.267
-- UPDATE 	calc_ego_grid_districts.grid_districts_dump AS t1
-- SET  	subst_sum = t2.subst_sum
-- FROM	(SELECT	dis.id AS id,
-- 		COUNT(sub.geom)::integer AS subst_sum
-- 	FROM	calc_ego_grid_districts.grid_districts_dump AS dis,
-- 		calc_ego_grid_districts.substations_110 AS sub
-- 	WHERE  	dis.geom && sub.geom AND
-- 		ST_CONTAINS(dis.geom,sub.geom)
-- 	GROUP BY dis.id
-- 	)AS t2
-- WHERE  	t1.id = t2.id;
-- 
-- -- Create Index GIST (geom)   (OK!) 2.500ms =0
-- CREATE INDEX	grid_districts_dump_geom_idx
-- 	ON	calc_ego_grid_districts.grid_districts_dump
-- 	USING	GIST (geom);

-- 
-- ---------- ---------- ----------
-- -- HULL
-- ---------- ---------- ----------
-- 
-- -- hull   (OK!) 19.000ms =4.091
-- DROP TABLE IF EXISTS	calc_ego_grid_districts.grid_districts_hull CASCADE;
-- CREATE TABLE 		calc_ego_grid_districts.grid_districts_hull AS 
-- 	SELECT	dis.subst_id ::integer AS subst_id,
-- 		ST_AREA(dis.geom)/1000 AS area_ha,
-- 		ST_MULTI(dis.geom) ::geometry(MultiPolygon,3035) AS geom
-- 	FROM	(SELECT dis.subst_id AS subst_id,
-- 			ST_BUFFER(dis.geom,1) AS geom
-- 		FROM	calc_ego_grid_districts.grid_districts AS dis) AS dis;
-- 
-- -- Ad PK   (OK!) 150ms =0
-- ALTER TABLE	calc_ego_grid_districts.grid_districts_hull
-- 	ADD COLUMN subst_sum integer,
-- 	ADD PRIMARY KEY (subst_id);
-- 
-- -- Count Substations in Grid Districts   (OK!) -> 1.000ms =2.267
-- UPDATE 	calc_ego_grid_districts.grid_districts_hull AS t1
-- SET  	subst_sum = t2.subst_sum
-- FROM	(SELECT	dis.subst_id AS subst_id,
-- 		COUNT(sub.geom)::integer AS subst_sum
-- 	FROM	calc_ego_grid_districts.grid_districts_hull AS dis,
-- 		calc_ego_grid_districts.substations_110 AS sub
-- 	WHERE  	dis.geom && sub.geom AND
-- 		ST_CONTAINS(dis.geom,sub.geom)
-- 	GROUP BY dis.subst_id
-- 	)AS t2
-- WHERE  	t1.subst_id = t2.subst_id;
-- 
-- -- Create Index GIST (geom)   (OK!) 2.500ms =0
-- CREATE INDEX	grid_districts_hull_geom_idx
-- 	ON	calc_ego_grid_districts.grid_districts_hull
-- 	USING	GIST (geom);

