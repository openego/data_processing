---------- ---------- ----------
---------- --SKRIPT-- OK! 7min
---------- ---------- ----------

---------- ---------- ----------
-- Substations 110 (mv)
---------- ---------- ----------

-- -- Substations   (OK!) 2.000ms =3.610
DROP TABLE IF EXISTS	orig_ego.ego_deu_substations_110 CASCADE;
CREATE TABLE		orig_ego.ego_deu_substations_110 AS
	SELECT	sub.id AS sub_id,
		sub.name AS sub_name,
		ST_TRANSFORM(sub.geom,3035) ::geometry(Point,3035) AS geom
	FROM	orig_ego.ego_deu_substations AS sub;

-- Set PK   (OK!) -> 2.000ms =0
ALTER TABLE orig_ego.ego_deu_substations_110
	ADD COLUMN	ags_0 character varying(12),
	ADD PRIMARY KEY (sub_id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_110_geom_idx
	ON	orig_ego.ego_deu_substations_110
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_substations_110 TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_110 OWNER TO oeuser;

-- "Calculate Gemeindeschlüssel"   (OK!) -> 3.000ms =3.610
UPDATE 	orig_ego.ego_deu_substations_110 AS t1
SET  	ags_0 = t2.ags_0
FROM    (
	SELECT	sub.sub_id,
		vg.ags_0
	FROM	orig_ego.ego_deu_substations_110 AS sub,
		orig_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && sub.geom AND
		ST_CONTAINS(vg.geom,sub.geom)
	) AS t2
WHERE  	t1.sub_id = t2.sub_id;

---------- ---------- ----------
-- Substations per Municipalities
---------- ---------- ----------

-- Municipalities   (OK!) -> 28.000ms =12.174
DROP TABLE IF EXISTS	orig_ego.ego_deu_municipalities_sub CASCADE;
CREATE TABLE		orig_ego.ego_deu_municipalities_sub AS
	SELECT	vg.*
	FROM	orig_vg250.vg250_6_gem_clean_mview AS vg;

-- Set PK   (OK!) -> 1.000ms =0
ALTER TABLE orig_ego.ego_deu_municipalities_sub
	ADD COLUMN sub_sum integer,
	ADD COLUMN sub_type integer,
	ADD PRIMARY KEY (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_municipalities_sub_geom_idx
	ON	orig_ego.ego_deu_municipalities_sub
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_municipalities_sub TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub OWNER TO oeuser;

---------- ---------- ----------

-- usw count   (OK!) -> 1.000ms =2.270
UPDATE 	orig_ego.ego_deu_municipalities_sub AS t1
SET  	sub_sum = t2.sub_sum
FROM	(SELECT	mun.id AS id,
		COUNT(sub.geom)::integer AS sub_sum
	FROM	orig_ego.ego_deu_municipalities_sub AS mun,
		orig_ego.ego_deu_substations_110 AS sub
	WHERE  	mun.geom && sub.geom AND
		ST_CONTAINS(mun.geom,sub.geom)
	GROUP BY mun.id
	)AS t2
WHERE  	t1.id = t2.id;

-- SELECT	sum(mun.sub_sum) AS sum
-- FROM	orig_ego.ego_deu_municipalities_sub AS mun;



---------- ---------- ----------
-- MViews
---------- ---------- ----------

-- MView I.   (OK!) -> 300ms =1.724
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_municipalities_sub_1_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_municipalities_sub_1_mview AS 
	SELECT	mun.id,
		mun.gen,
		mun.bez,
		mun.ags_0,
		'1' ::integer AS sub_type,
		mun.geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub AS mun
	WHERE	mun.sub_sum = '1';

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_municipalities_sub_1_mview_gid_idx
		ON	orig_ego.ego_deu_municipalities_sub_1_mview (id);

-- Substation Type 1   (OK!) -> 1.000ms =1.724
UPDATE 	orig_ego.ego_deu_municipalities_sub AS t1
SET  	sub_type = t2.sub_type
FROM	(SELECT	mun.id AS id,
		mun.sub_type AS sub_type
	FROM	orig_ego.ego_deu_municipalities_sub_1_mview AS mun )AS t2
WHERE  	t1.id = t2.id;

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_municipalities_sub_1_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub_1_mview OWNER TO oeuser;

---------- ---------- ----------

-- MView II.   (OK!) -> 100ms =546
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_municipalities_sub_2_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_municipalities_sub_2_mview AS 
	SELECT	mun.id,
		mun.gen,
		mun.bez,
		mun.ags_0,
		'2' ::integer AS sub_type,
		mun.geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub AS mun
	WHERE	mun.sub_sum > '1';

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_municipalities_sub_2_mview_gid_idx
		ON	orig_ego.ego_deu_municipalities_sub_2_mview (id);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_municipalities_sub_2_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub_2_mview OWNER TO oeuser;

-- Substation Type 2   (OK!) -> 1.000ms =546
UPDATE 	orig_ego.ego_deu_municipalities_sub AS t1
SET  	sub_type = t2.sub_type
FROM	(SELECT	mun.id AS id,
		mun.sub_type AS sub_type
	FROM	orig_ego.ego_deu_municipalities_sub_2_mview AS mun )AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- Substation Type 2   (OK!) -> 200ms =1.886
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_110_mun_2_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_substations_110_mun_2_mview AS
	SELECT	sub.sub_id ::integer,
		sub.sub_name ::text,
		'3' ::integer AS sub_type,
		sub.geom ::geometry(Point,3035) AS geom
	FROM	orig_ego.ego_deu_substations_110 AS sub,
		orig_ego.ego_deu_municipalities_sub_2_mview AS mun
	WHERE  	mun.geom && sub.geom AND
		ST_CONTAINS(mun.geom,sub.geom);

-- Create Index (sub_id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_110_mun_2_mview_sub_id_idx
		ON	orig_ego.ego_deu_substations_110_mun_2_mview (sub_id);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_substations_110_mun_2_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_110_mun_2_mview OWNER TO oeuser;


---------- ---------- ----------

-- MView III.   (OK!) -> 22.000ms =9.904
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_municipalities_sub_3_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_municipalities_sub_3_mview AS 
	SELECT	mun.id,
		mun.gen,
		mun.bez,
		mun.ags_0,
		'3' ::integer AS sub_type,
		mun.geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub AS mun
	WHERE	mun.sub_sum IS NULL;

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_municipalities_sub_3_mview_gid_idx
		ON	orig_ego.ego_deu_municipalities_sub_3_mview (id);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_municipalities_sub_3_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub_3_mview OWNER TO oeuser;


-- Substation Type 3   (OK!) -> 1.000ms =9.904
UPDATE 	orig_ego.ego_deu_municipalities_sub AS t1
SET  	sub_type = t2.sub_type
FROM	(SELECT	mun.id AS id,
		'3'::integer AS sub_type
	FROM	orig_ego.ego_deu_municipalities_sub_3_mview AS mun )AS t2
WHERE  	t1.id = t2.id;



---------- ---------- ----------
-- Grid Districts
---------- ---------- ----------

---------- ---------- ----------
-- I. Gemeinden mit genau einem USW 
---------- ---------- ----------

-- Substations Template   (OK!) -> 100ms =3.610
DROP TABLE IF EXISTS	orig_ego.ego_grid_districts_type_1 CASCADE;
CREATE TABLE		orig_ego.ego_grid_districts_type_1 AS
	SELECT	sub.sub_id ::integer,
		sub.sub_name ::text,
		sub.ags_0 ::character varying(12),
		sub.geom ::geometry(Point,3035) AS geom_sub
	FROM	orig_ego.ego_deu_substations_110 AS sub;

-- Set PK   (OK!) -> 100ms =0
ALTER TABLE orig_ego.ego_grid_districts_type_1
	ADD COLUMN sub_sum integer,
	ADD COLUMN sub_type integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (sub_id);

-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districts_type_1_geom_sub_idx
	ON	orig_ego.ego_grid_districts_type_1
	USING	GIST (geom_sub);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districts_type_1_geom_mun_idx
	ON	orig_ego.ego_grid_districts_type_1
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_grid_districts_type_1 TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_grid_districts_type_1 OWNER TO oeuser;

---------- ---------- ----------

-- sub_id = gem.id
-- update usw geom gem1   (OK!) -> 1.000ms =1.724
UPDATE 	orig_ego.ego_grid_districts_type_1 AS t1
SET  	sub_sum  = t2.sub_sum,
	sub_type = t2.sub_type,
	geom = t2.geom
FROM	(SELECT	mun.ags_0 AS ags_0,
		mun.sub_sum ::integer AS sub_sum,
		mun.sub_type ::integer AS sub_type,
		ST_MULTI(mun.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub AS mun
	WHERE	sub_type = '1')AS t2
WHERE  	t1.ags_0 = t2.ags_0;



---------- ---------- ---------- ---------- ---------- ----------
-- II. Gemeinden mit mehreren USW
---------- ---------- ---------- ---------- ---------- ----------

-- Create Table "ego_deu_substations_110_voronoi" 
-- with Script "data_processing\ego_deu_substations\ego_deu_substations_110_voronoi.sql"

-- Substation ID   (OK!) -> 1.000ms =3.610
UPDATE 	orig_ego.ego_deu_substations_110_voronoi AS t1
SET  	sub_id = t2.sub_id
FROM	(SELECT	voi.id AS id,
		sub.sub_id ::integer AS sub_id
	FROM	orig_ego.ego_deu_substations_110_voronoi AS voi,
		orig_ego.ego_deu_substations_110 AS sub
	WHERE  	voi.geom && sub.geom AND
		ST_CONTAINS(voi.geom,sub.geom)
	GROUP BY voi.id,sub.sub_id
	)AS t2
WHERE  	t1.id = t2.id;

-- Substation Count   (OK!) -> 1.000ms =3.610
UPDATE 	orig_ego.ego_deu_substations_110_voronoi AS t1
SET  	sub_sum = t2.sub_sum
FROM	(SELECT	voi.id AS id,
		COUNT(sub.geom)::integer AS sub_sum
	FROM	orig_ego.ego_deu_substations_110_voronoi AS voi,
		orig_ego.ego_deu_substations_110 AS sub
	WHERE  	voi.geom && sub.geom AND
		ST_CONTAINS(voi.geom,sub.geom)
	GROUP BY voi.id
	)AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- Voronoi Gridcells (voi)   (OK!) 100ms =3.610
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_110_voronoi_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_substations_110_voronoi_mview AS
	SELECT	voi.id ::integer,
		voi.sub_id ::integer,
		voi.sub_sum ::integer,
		(ST_DUMP(voi.geom)).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_substations_110_voronoi AS voi
	WHERE	sub_sum = '1';

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_110_voronoi_mview_id_idx
		ON	orig_ego.ego_deu_substations_110_voronoi_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_110_voronoi_mview_geom_idx
	ON	orig_ego.ego_deu_substations_110_voronoi_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_substations_110_voronoi_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_110_voronoi_mview OWNER TO oeuser;

---------- ---------- ----------

-- Validate (geom)   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	orig_ego.ego_deu_substations_voronoi_error_geom_view CASCADE;
CREATE VIEW		orig_ego.ego_deu_substations_voronoi_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_ego.ego_deu_substations_voronoi AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_substations_voronoi_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_voronoi_error_geom_view OWNER TO oeuser;

-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_deu_substations_voronoi_error_geom_view}', 'orig_ego');


---------- ---------- ----------
-- CUT
---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.ego_deu_substations_110_voronoi_cut_id CASCADE;
CREATE SEQUENCE 		orig_ego.ego_deu_substations_110_voronoi_cut_id;

-- Cutting GEM II.   (OK!) 3.000ms =4.531
DROP TABLE IF EXISTS	orig_ego.ego_deu_substations_110_voronoi_cut CASCADE;
CREATE TABLE		orig_ego.ego_deu_substations_110_voronoi_cut AS
	SELECT	nextval('orig_ego.ego_deu_substations_110_voronoi_cut_id') AS id,
		voi.sub_id,
		mun.id AS mun_id,
		voi.id AS voi_id,
		mun.ags_0 AS ags_0,
		mun.sub_type,
		(ST_DUMP(ST_INTERSECTION(mun.geom,voi.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub_2_mview AS mun,
		orig_ego.ego_deu_substations_110_voronoi_mview AS voi
	WHERE	mun.geom && voi.geom;

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	orig_ego.ego_deu_substations_110_voronoi_cut
	ADD COLUMN sub_sum integer,
	ADD COLUMN geom_sub geometry(Point,3035),
	ADD PRIMARY KEY (id);

-- Count Substations in Voronoi Cuts   (OK!) -> 1.000ms =1.886
UPDATE 	orig_ego.ego_deu_substations_110_voronoi_cut AS t1
SET  	sub_sum = t2.sub_sum,
	sub_id = t2.sub_id,
	geom_sub = t2.geom_sub
FROM	(SELECT	mun.id AS id,
		sub.sub_id,
		sub.geom AS geom_sub,
		COUNT(sub.geom)::integer AS sub_sum
	FROM	orig_ego.ego_deu_substations_110_voronoi_cut AS mun,
		orig_ego.ego_deu_substations_110 AS sub
	WHERE  	mun.geom && sub.geom AND
		ST_CONTAINS(mun.geom,sub.geom)
	GROUP BY mun.id,sub.sub_id
	)AS t2
WHERE  	t1.id = t2.id;

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_110_voronoi_cut_geom_idx
	ON	orig_ego.ego_deu_substations_110_voronoi_cut
	USING	GIST (geom);

-- Create Index GIST (geom_sub)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_110_voronoi_cut_geom_sub_idx
	ON	orig_ego.ego_deu_substations_110_voronoi_cut
	USING	GIST (geom_sub);
	
-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_substations_110_voronoi_cut TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_110_voronoi_cut OWNER TO oeuser;

---------- ---------- ----------

-- Validate (geom)   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	orig_ego.ego_deu_substations_110_voronoi_cut_error_geom_view CASCADE;
CREATE VIEW		orig_ego.ego_deu_substations_110_voronoi_cut_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_ego.ego_deu_substations_110_voronoi_cut AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_substations_110_voronoi_cut_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_110_voronoi_cut_error_geom_view OWNER TO oeuser;

-- -- Drop empty view   (OK!) -> 100ms =1 (no error!)
-- SELECT f_drop_view('{ego_deu_substations_110_voronoi_cut_error_geom_view}', 'orig_ego');

---------- ---------- ----------

-- Parts with substation   (OK!) 100ms =1.886
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_110_voronoi_cut_1sub_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_substations_110_voronoi_cut_1sub_mview AS
SELECT	voi.*
FROM	orig_ego.ego_deu_substations_110_voronoi_cut AS voi
WHERE	sub_sum = 1;

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_110_voronoi_cut_1sub_mview_id_idx
		ON	orig_ego.ego_deu_substations_110_voronoi_cut_1sub_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_110_voronoi_cut_1sub_mview_geom_idx
	ON	orig_ego.ego_deu_substations_110_voronoi_cut_1sub_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_substations_110_voronoi_cut_1sub_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_110_voronoi_cut_1sub_mview OWNER TO oeuser;

---------- ---------- ----------

-- Parts without substation   (OK!) 100ms =2.645
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_substations_110_voronoi_cut_0sub_mview AS
SELECT	voi.id,
	voi.sub_id,
	voi.mun_id,
	voi.voi_id,
	voi.ags_0,
	voi.sub_type,
	voi.geom
FROM	orig_ego.ego_deu_substations_110_voronoi_cut AS voi
WHERE	sub_sum IS NULL;

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_110_voronoi_cut_0sub_mview_id_idx
		ON	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_mview (id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_110_voronoi_cut_0sub_mview_geom_idx
	ON	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_110_voronoi_cut_0sub_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- Calculate Gemeindeschlüssel   (OK!) -> 3.000ms =4.981
-- UPDATE 	orig_ego.ego_deu_substations_110_voronoi_cut AS t1
-- SET  	ags_0 = t2.ags_0
-- FROM    (
-- 	SELECT	cut.id AS id,
-- 		vg.ags_0 AS ags_0
-- 	FROM	orig_ego.ego_deu_substations_110_voronoi_cut AS cut,
-- 		orig_geo_vg250.vg250_6_gem_mview AS vg
-- 	WHERE  	vg.geom && ST_POINTONSURFACE(cut.geom) AND
-- 		ST_CONTAINS(vg.geom,ST_POINTONSURFACE(cut.geom))
-- 	) AS t2
-- WHERE  	t1.id = t2.id;


---------- ---------- ----------
-- Connect the cutted parts to the next substation
---------- ---------- ----------

-- Next Neighbor   (OK!) 1.000ms =2.645
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_mview AS 
SELECT DISTINCT ON (voi.id)
	voi.id AS voi_id,
	voi.ags_0 AS voi_ags_0,
	voi.geom AS geom_voi,
	sub.sub_id AS sub_id,
	sub.ags_0 AS ags_0,
	sub.geom AS geom_sub
FROM 	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_mview AS voi,
	orig_ego.ego_deu_substations_110_voronoi_cut_1sub_mview AS sub
WHERE 	ST_DWithin(ST_ExteriorRing(voi.geom),ST_ExteriorRing(sub.geom), 50000) -- In a 50 km radius
	AND voi.ags_0 = sub.ags_0  -- only inside same mun
ORDER BY 	voi.id, 
		ST_Distance(ST_ExteriorRing(voi.geom),ST_ExteriorRing(sub.geom));
		
-- ST_Length(ST_CollectionExtract(ST_Intersection(a_geom, b_geom), 2)) -- Lenght of the shared border?

-- Create Index (id)   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_110_voronoi_cut_0sub_nn_mview_voi_id_idx
		ON	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_mview (voi_id);

-- Create Index GIST (geom_voi)   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_110_voronoi_cut_0sub_nn_mview_geom_voi_idx
	ON	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_mview
	USING	GIST (geom_voi);

-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_110_voronoi_cut_0sub_nn_mview_geom_sub_idx
	ON	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_mview
	USING	GIST (geom_sub);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_mview OWNER TO oeuser;

---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_line_mview_id CASCADE;
CREATE SEQUENCE 		orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_line_mview_id;

-- connect points   (OK!) 1.000ms =2.645
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_line_mview;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_line_mview AS 
	SELECT 	nextval('orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_line_mview_id') AS id,
		nn.voi_id,
		nn.sub_id,
		(ST_Dump(ST_CENTROID(nn.geom_voi))).geom ::geometry(Point,3035) AS geom_centre,
		ST_ShortestLine(	(ST_Dump(ST_CENTROID(nn.geom_voi))).geom ::geometry(Point,3035),
					sub.geom ::geometry(Point,3035)
		) ::geometry(LineString,3035) AS geom
	FROM	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_mview AS nn,
		orig_ego.ego_deu_substations_110 AS sub
	WHERE	sub.sub_id = nn.sub_id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_110_voronoi_cut_0sub_nn_line_mview_id_idx
		ON	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_line_mview (id);

-- Create Index GIST (geom_centre)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_110_voronoi_cut_0sub_nn_line_mview_geom_centre_idx
	ON	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_line_mview
	USING	GIST (geom_centre);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_110_voronoi_cut_0sub_nn_line_mview_geom_idx
	ON	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_line_mview
	USING	GIST (geom);

---------- ---------- ----------

-- Create Table   (OK!) 4.000ms =1.057
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_union_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_union_mview AS 
	SELECT	nn.sub_id As sub_id, 
		ST_MULTI(ST_UNION(nn.geom_voi)) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_mview AS nn
	GROUP BY nn.sub_id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_110_voronoi_cut_0sub_nn_union_mview_id_idx
		ON	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_union_mview (sub_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_110_voronoi_cut_0sub_nn_union_mview_geom_idx
	ON	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_union_mview
	USING	GIST (geom);

---------- ---------- ----------

-- Create Table   (OK!) 4.000ms =0
DROP TABLE IF EXISTS	orig_ego.ego_deu_substations_110_voronoi_cut_nn_collect CASCADE;
CREATE TABLE		orig_ego.ego_deu_substations_110_voronoi_cut_nn_collect (
	id serial,
	sub_id integer,
	geom geometry(MultiPolygon,3035),
CONSTRAINT ego_deu_substations_110_voronoi_cut_nn_collect_pkey PRIMARY KEY (id));

-- Insert parts with substations   (OK!) 4.000ms =1.886
INSERT INTO     orig_ego.ego_deu_substations_110_voronoi_cut_nn_collect (sub_id,geom)
	SELECT	sub.sub_id AS sub_id,
		ST_MULTI(sub.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_substations_110_voronoi_cut_1sub_mview AS sub;

-- Insert parts without substations union   (OK!) 4.000ms =1.103
INSERT INTO     orig_ego.ego_deu_substations_110_voronoi_cut_nn_collect (sub_id,geom)
	SELECT	voi.sub_id AS sub_id,
		voi.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_substations_110_voronoi_cut_0sub_nn_union_mview AS voi;

-- Create Index GIST (geom)   (OK!) 11.000ms =0
CREATE INDEX	ego_deu_substations_110_voronoi_cut_nn_collect_geom_idx
	ON	orig_ego.ego_deu_substations_110_voronoi_cut_nn_collect
	USING	GIST (geom);

---------- ---------- ----------

-- Create Table   (OK!) 4.000ms =1.886
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_110_voronoi_cut_nn_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_substations_110_voronoi_cut_nn_mview AS 
	SELECT	nn.sub_id As sub_id, 
		ST_MULTI(ST_UNION(nn.geom)) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_substations_110_voronoi_cut_nn_collect AS nn
	GROUP BY nn.sub_id;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_110_voronoi_cut_nn_mview_id_idx
		ON	orig_ego.ego_deu_substations_110_voronoi_cut_nn_mview (sub_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_110_voronoi_cut_nn_mview_geom_idx
	ON	orig_ego.ego_deu_substations_110_voronoi_cut_nn_mview
	USING	GIST (geom);

---------- ---------- ----------

-- Substations Template   (OK!) -> 100ms =3.610
DROP TABLE IF EXISTS	orig_ego.ego_grid_districts_type_2 CASCADE;
CREATE TABLE		orig_ego.ego_grid_districts_type_2 AS
	SELECT	sub.sub_id ::integer,
		sub.sub_name ::text,
		sub.ags_0 ::character varying(12),
		sub.geom ::geometry(Point,3035) AS geom_sub
	FROM	orig_ego.ego_deu_substations_110 AS sub;

-- Set PK   (OK!) -> 100ms =0
ALTER TABLE orig_ego.ego_grid_districts_type_2
	ADD COLUMN sub_sum integer,
	ADD COLUMN sub_type integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (sub_id);

-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districts_type_2_geom_sub_idx
	ON	orig_ego.ego_grid_districts_type_2
	USING	GIST (geom_sub);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districts_type_2_geom_mun_idx
	ON	orig_ego.ego_grid_districts_type_2
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_grid_districts_type_2 TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_grid_districts_type_2 OWNER TO oeuser;

---------- ---------- ----------

-- sub_id = id
-- update sub geom gem2   (OK!) -> 1.000ms =1.886
UPDATE 	orig_ego.ego_grid_districts_type_2 AS t1
SET  	sub_type = t2.sub_type,
	geom = t2.geom
FROM	(SELECT	nn.sub_id AS sub_id,
		'2' ::integer AS sub_type,
		nn.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_substations_110_voronoi_cut_nn_mview AS nn )AS t2
WHERE  	t1.sub_id = t2.sub_id;

---------- ---------- ----------
-- 
-- -- voi   (OK!) 100ms =3.693
-- DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_usw_voronoi_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_ego.ego_deu_usw_voronoi_mview AS
-- 	SELECT	poly.id ::integer AS id,
-- 		(ST_DUMP(ST_TRANSFORM(poly.geom,3035))).geom ::geometry(Polygon,3035) AS geom
-- 	FROM	orig_ego.ego_deu_usw_voronoi AS poly;
-- 
-- -- Create Index GIST (geom)   (OK!) -> 100ms =0
-- CREATE INDEX  	ego_deu_usw_voronoi_mview_geom_idx
-- 	ON	orig_ego.ego_deu_usw_voronoi_mview
-- 	USING	GIST (geom);
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	orig_ego.ego_deu_usw_voronoi_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_usw_voronoi_mview OWNER TO oeuser;
-- 
-- ---------- ---------- ----------	
-- 
-- -- Validate (geom)   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_ego.ego_deu_usw_voronoi_mview_error_geom_view CASCADE;
-- CREATE VIEW		orig_ego.ego_deu_usw_voronoi_mview_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	orig_ego.ego_deu_usw_voronoi_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_ego.ego_deu_usw_voronoi_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_usw_voronoi_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_deu_usw_voronoi_mview_error_geom_view}', 'orig_ego');

---------- ---------- ----------



---------- ---------- ----------

-- DROP MATERIALIZED VIEW IF EXISTS	orig_ego.vg250_6_gem_sub_2_pts_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_ego.vg250_6_gem_sub_2_pts_mview AS 
-- 	SELECT	'1' ::integer AS id,
-- 		ST_SetSRID(ST_Union(sub.geom), 0) AS geom
-- 	FROM	calc_gridcells_znes.znes_deu_substations_filtered AS sub
-- 	WHERE	sub_id = '3791' OR sub_id = '3765';

-- -- (POSTGIS 2.3!!!)
-- DROP MATERIALIZED VIEW IF EXISTS	orig_ego.vg250_6_gem_sub_2_voronoi_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_ego.vg250_6_gem_sub_2_voronoi_mview AS 
-- 	SELECT	gem2.gid AS id,
-- 		ST_Voronoi(sub.geom,gem2.geom,30,true) AS geom
-- 	FROM	orig_ego.vg250_6_gem_sub_2_pts_mview AS sub,
-- 		orig_ego.vg250_6_gem_sub_2_mview AS gem2
-- 	WHERE	gem2.gid = '4884'



---------- ---------- ----------
-- III. Gemeinden ohne sub
---------- ---------- ----------

-- gem WHERE sub_sum=0		orig_geo_ego.vg250_6_gem_sub_3_mview
-- sub				orig_geo_ego.ego_deu_mv_substations_mview

-- Next Neighbor   (OK!) 14.000ms =10.259
DROP TABLE IF EXISTS	orig_ego.ego_deu_municipalities_sub_3_nn CASCADE;
CREATE TABLE 		orig_ego.ego_deu_municipalities_sub_3_nn AS 
SELECT DISTINCT ON (mun.id)
	mun.id AS mun_id,
	mun.ags_0 AS mun_ags_0,
	sub.ags_0 AS sub_ags_0,
	sub.sub_id, 
	mun.sub_type,
	sub.geom ::geometry(Point,3035) AS geom_sub,
	ST_Distance(ST_ExteriorRing(mun.geom),sub.geom) AS distance,
	ST_MULTI(mun.geom) ::geometry(MultiPolygon,3035) AS geom
FROM 	orig_ego.ego_deu_municipalities_sub_3_mview AS mun, 
	orig_ego.ego_deu_substations_110 AS sub
WHERE 	ST_DWithin(ST_ExteriorRing(mun.geom),sub.geom, 50000) -- In a 50 km radius
ORDER BY 	mun.id, ST_Distance(ST_ExteriorRing(mun.geom),sub.geom);

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	orig_ego.ego_deu_municipalities_sub_3_nn
	ADD PRIMARY KEY (mun_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
DROP INDEX IF EXISTS 	ego_deu_municipalities_sub_3_nn_geom_idx;
CREATE INDEX		ego_deu_municipalities_sub_3_nn_geom_idx
	ON	orig_ego.ego_deu_municipalities_sub_3_nn
	USING	GIST (geom);

-- Create Index GIST (geom_sub)   (OK!) 2.500ms =0
DROP INDEX IF EXISTS 	ego_deu_municipalities_sub_3_nn_geom_sub_idx;
CREATE INDEX		ego_deu_municipalities_sub_3_nn_geom_sub_idx
	ON	orig_ego.ego_deu_municipalities_sub_3_nn
	USING	GIST (geom_sub);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_municipalities_sub_3_nn TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub_3_nn OWNER TO oeuser;


---------- ---------- ----------
-- NN Line
---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.ego_deu_municipalities_sub_3_nn_line_id CASCADE;
CREATE SEQUENCE 		orig_ego.ego_deu_municipalities_sub_3_nn_line_id;

-- connect points   (OK!) 1.000ms =9.902
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_municipalities_sub_3_nn_line;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_municipalities_sub_3_nn_line AS 
	SELECT 	nextval('orig_ego.ego_deu_municipalities_sub_3_nn_line_id') AS id,
		nn.mun_id AS nn_id,
		nn.sub_id,
		(ST_Dump(ST_PointOnSurface(nn.geom))).geom ::geometry(Point,3035) AS geom_centre,
		ST_ShortestLine(	(ST_Dump(ST_PointOnSurface(nn.geom))).geom ::geometry(Point,3035),
					nn.geom_sub ::geometry(Point,3035)
		) ::geometry(LineString,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub_3_nn AS nn;

-- Create Index (id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_municipalities_sub_3_nn_line_id_idx
		ON	orig_ego.ego_deu_municipalities_sub_3_nn_line (id);

-- Create Index GIST (geom_centre)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_municipalities_sub_3_nn_line_geom_centre_idx
	ON	orig_ego.ego_deu_municipalities_sub_3_nn_line
	USING	GIST (geom_centre);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_municipalities_sub_3_nn_line_geom_idx
	ON	orig_ego.ego_deu_municipalities_sub_3_nn_line
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_municipalities_sub_3_nn_line TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub_3_nn_line OWNER TO oeuser;


---------- ---------- ----------

-- UNION

-- union mun   (OK!) 33.000ms =2.077
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_municipalities_sub_3_nn_union CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_municipalities_sub_3_nn_union AS 
	SELECT	un.sub_id ::integer AS sub_id,
		un.sub_type ::integer AS sub_type,
		un.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT DISTINCT ON (nn.sub_id)
			nn.sub_id AS sub_id,
			nn.sub_type AS sub_type,
			ST_MULTI(ST_UNION(nn.geom)) AS geom
		FROM	orig_ego.ego_deu_municipalities_sub_3_nn AS nn
		GROUP BY nn.sub_id, nn.sub_type) AS un;

-- Create Index (sub_id)   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_municipalities_sub_3_nn_union_sub_id_idx
		ON	orig_ego.ego_deu_municipalities_sub_3_nn_union (sub_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_municipalities_sub_3_nn_union_geom_idx
	ON	orig_ego.ego_deu_municipalities_sub_3_nn_union
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_municipalities_sub_3_nn_union TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub_3_nn_union OWNER TO oeuser;

---------- ---------- ----------

-- Substations Template   (OK!) -> 100ms =3.610
DROP TABLE IF EXISTS	orig_ego.ego_grid_districts_type_3 CASCADE;
CREATE TABLE		orig_ego.ego_grid_districts_type_3 AS
	SELECT	sub.sub_id ::integer,
		sub.sub_name ::text,
		sub.ags_0 ::character varying(12),
		sub.geom ::geometry(Point,3035) AS geom_sub
	FROM	orig_ego.ego_deu_substations_110 AS sub;

-- Set PK   (OK!) -> 100ms =0
ALTER TABLE orig_ego.ego_grid_districts_type_3
	ADD COLUMN sub_sum integer,
	ADD COLUMN sub_type integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (sub_id);

-- Create Index GIST (geom_sub)   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districts_type_3_geom_sub_idx
	ON	orig_ego.ego_grid_districts_type_3
	USING	GIST (geom_sub);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districts_type_3_geom_mun_idx
	ON	orig_ego.ego_grid_districts_type_3
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_grid_districts_type_3 TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_grid_districts_type_3 OWNER TO oeuser;

---------- ---------- ----------

-- update sub geom mun3   (OK!) -> 1.000ms =2.077
UPDATE 	orig_ego.ego_grid_districts_type_3 AS t1
SET  	sub_type = t2.sub_type,
	geom = t2.geom
FROM	(SELECT	un.sub_id AS sub_id,
		un.sub_type ::integer AS sub_type,
		ST_MULTI(un.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub_3_nn_union AS un ) AS t2
WHERE  	t1.sub_id = t2.sub_id;



---------- ---------- ----------
-- Collect the 3 Mun-types
---------- ---------- ----------

-- Substations Template   (OK!) -> 100ms =3.709
DROP TABLE IF EXISTS	orig_ego.ego_grid_districts_collect CASCADE;
CREATE TABLE		orig_ego.ego_grid_districts_collect (
	id SERIAL NOT NULL,
	sub_id integer,
	sub_name text,
	ags_0 character varying(12),
	geom_sub geometry(Point,3035),
	sub_sum integer,
	sub_type integer,
	geom geometry(MultiPolygon,3035),
	CONSTRAINT	ego_grid_districts_collect_pkey PRIMARY KEY (id));

-- Insert 1   (OK!) 100.000ms =3.610
INSERT INTO     orig_ego.ego_grid_districts_collect 
	(sub_id,sub_name,ags_0,geom_sub,sub_sum,sub_type,geom)
	SELECT	*
	FROM	orig_ego.ego_grid_districts_type_1
	ORDER BY sub_id;

-- Insert 2   (OK!) 100.000ms =3.610
INSERT INTO     orig_ego.ego_grid_districts_collect 
	(sub_id,sub_name,ags_0,geom_sub,sub_sum,sub_type,geom)
	SELECT	*
	FROM	orig_ego.ego_grid_districts_type_2
	ORDER BY sub_id;

-- Insert 3   (OK!) 100.000ms =3.610
INSERT INTO     orig_ego.ego_grid_districts_collect 
	(sub_id,sub_name,ags_0,geom_sub,sub_sum,sub_type,geom)
	SELECT	*
	FROM	orig_ego.ego_grid_districts_type_3
	ORDER BY sub_id;

---------- ---------- ----------

-- UNION I + II + II

-- -- union mun   (OK!) 19.000ms =3.707
-- DROP TABLE IF EXISTS	orig_ego.ego_grid_districts CASCADE;
-- CREATE TABLE 		orig_ego.ego_grid_districts AS 
-- 	SELECT	un.sub_id ::integer AS sub_id,
-- 		ST_AREA(un.geom)/10000 AS area_ha,
-- 		un.geom AS geom
-- 	FROM	(SELECT DISTINCT ON (dis.sub_id)
-- 			dis.sub_id AS sub_id,
-- 			ST_UNION(ST_SNAP(dis.geom,dis.geom,0.5))  AS geom
-- 		FROM	orig_ego.ego_grid_districts_collect AS dis
-- 		GROUP BY dis.sub_id) AS un;
-- --::geometry(MultiPolygon,3035)

-- union mun   (OK!) 19.000ms =3.707
DROP TABLE IF EXISTS	orig_ego.ego_grid_districts CASCADE;
CREATE TABLE 		orig_ego.ego_grid_districts AS 
SELECT DISTINCT ON 	(dis.sub_id)
			dis.sub_id AS sub_id,
			ST_UNION(ST_SnapToGrid(dis.geom, 0.01))  AS geom
		FROM	orig_ego.ego_grid_districts_collect AS dis
	GROUP BY 	dis.sub_id;

--::geometry(MultiPolygon,3035)
-- Ad PK   (OK!) 150ms =0
ALTER TABLE	orig_ego.ego_grid_districts
	ADD COLUMN sub_sum integer,
	ADD COLUMN area_ha decimal,
	ADD COLUMN geom_type text,
	ADD PRIMARY KEY (sub_id);

-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	ego_grid_districts_geom_idx
	ON	orig_ego.ego_grid_districts
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_grid_districts TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_grid_districts OWNER TO oeuser;

-- Count Substations in Grid Districts   (OK!) -> 1.000ms =2.267
UPDATE 	orig_ego.ego_grid_districts AS t1
SET  	sub_sum = t2.sub_sum,
	area_ha = t2.area_ha,
	geom_type = t2.geom_type
FROM	(SELECT	dis.sub_id AS sub_id,
		ST_AREA(dis.geom)/10000 AS area_ha,
		COUNT(sub.geom)::integer AS sub_sum,
		GeometryType(dis.geom) ::text AS geom_type
	FROM	orig_ego.ego_grid_districts AS dis,
		orig_ego.ego_deu_substations_110 AS sub
	WHERE  	dis.geom && sub.geom AND
		ST_CONTAINS(dis.geom,sub.geom)
	GROUP BY dis.sub_id
	)AS t2
WHERE  	t1.sub_id = t2.sub_id;


-- Dump Rings   (OK!) -> 22.000ms =0
SELECT	dis.sub_id,
	ST_NumInteriorRings(dis.geom) ::integer AS count_ring
FROM	orig_ego.ego_grid_districts AS dis
WHERE	ST_NumInteriorRings(dis.geom) <> 0;

-- Dump Rings   (OK!) -> 22.000ms =0
DROP SEQUENCE IF EXISTS orig_ego.ego_grid_districts_rings_id CASCADE;
CREATE SEQUENCE orig_ego.ego_grid_districts_rings_id;
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_grid_districts_rings CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.ego_grid_districts_rings AS 
	SELECT	nextval('orig_ego.ego_grid_districts_rings_id') AS id,
		dis.sub_id,
		ST_NumInteriorRings(dis.geom) AS count_ring,
		(ST_DumpRings(dis.geom)).geom AS geom
	FROM	orig_ego.ego_grid_districts AS dis
	WHERE	ST_NumInteriorRings(dis.geom) <> 0;

-- Dump Rings   (OK!) -> 22.000ms =0
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_grid_districts_rings_dump CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.ego_grid_districts_rings_dump AS 
	SELECT	dump.id AS id,
		dump.sub_id,
		dump.count_ring,
		ST_AREA(dump.geom) AS area_ha,
		dump.geom AS geom
	FROM	orig_ego.ego_grid_districts_rings AS dump
	WHERE	ST_AREA(dump.geom) > 1000000;



---------- ---------- ----------

-- Validate (geom)   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	orig_ego.ego_grid_districts_error_geom_view CASCADE;
CREATE VIEW		orig_ego.ego_grid_districts_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.sub_id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_ego.ego_grid_districts AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_grid_districts_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_grid_districts_error_geom_view OWNER TO oeuser;

-- Drop empty view   (OK!) -> 100ms =1
SELECT f_drop_view('{ego_grid_districts_error_geom_view}', 'orig_ego');

-- ---------- ---------- ----------
-- -- DUMP
-- ---------- ---------- ----------
-- 
-- -- Sequence   (OK!) 100ms =0
-- DROP SEQUENCE IF EXISTS 	orig_ego.ego_grid_districts_dump_id CASCADE;
-- CREATE SEQUENCE 		orig_ego.ego_grid_districts_dump_id;
-- 
-- -- Dump   (OK!) 19.000ms =4.091
-- DROP TABLE IF EXISTS	orig_ego.ego_grid_districts_dump CASCADE;
-- CREATE TABLE 		orig_ego.ego_grid_districts_dump AS 
-- 	SELECT	nextval('orig_ego.ego_deu_municipalities_sub_3_nn_line_id') AS id,
-- 		dump.sub_id ::integer AS sub_id,
-- 		ST_AREA(dump.geom)/1000 AS area_ha,
-- 		dump.geom ::geometry(Polygon,3035) AS geom
-- 	FROM	(SELECT dis.sub_id AS sub_id,
-- 			(ST_DUMP(dis.geom)).geom ::geometry(Polygon,3035) AS geom
-- 		FROM	orig_ego.ego_grid_districts AS dis) AS dump;
-- 
-- -- Ad PK   (OK!) 150ms =0
-- ALTER TABLE	orig_ego.ego_grid_districts_dump
-- 	ADD COLUMN sub_sum integer,
-- 	ADD PRIMARY KEY (id);
-- 
-- -- Count Substations in Grid Districts   (OK!) -> 1.000ms =2.267
-- UPDATE 	orig_ego.ego_grid_districts_dump AS t1
-- SET  	sub_sum = t2.sub_sum
-- FROM	(SELECT	dis.id AS id,
-- 		COUNT(sub.geom)::integer AS sub_sum
-- 	FROM	orig_ego.ego_grid_districts_dump AS dis,
-- 		orig_ego.ego_deu_substations_110 AS sub
-- 	WHERE  	dis.geom && sub.geom AND
-- 		ST_CONTAINS(dis.geom,sub.geom)
-- 	GROUP BY dis.id
-- 	)AS t2
-- WHERE  	t1.id = t2.id;
-- 
-- -- Create Index GIST (geom)   (OK!) 2.500ms =0
-- CREATE INDEX	ego_grid_districts_dump_geom_idx
-- 	ON	orig_ego.ego_grid_districts_dump
-- 	USING	GIST (geom);

-- 
-- ---------- ---------- ----------
-- -- HULL
-- ---------- ---------- ----------
-- 
-- -- hull   (OK!) 19.000ms =4.091
-- DROP TABLE IF EXISTS	orig_ego.ego_grid_districts_hull CASCADE;
-- CREATE TABLE 		orig_ego.ego_grid_districts_hull AS 
-- 	SELECT	dis.sub_id ::integer AS sub_id,
-- 		ST_AREA(dis.geom)/1000 AS area_ha,
-- 		ST_MULTI(dis.geom) ::geometry(MultiPolygon,3035) AS geom
-- 	FROM	(SELECT dis.sub_id AS sub_id,
-- 			ST_BUFFER(dis.geom,1) AS geom
-- 		FROM	orig_ego.ego_grid_districts AS dis) AS dis;
-- 
-- -- Ad PK   (OK!) 150ms =0
-- ALTER TABLE	orig_ego.ego_grid_districts_hull
-- 	ADD COLUMN sub_sum integer,
-- 	ADD PRIMARY KEY (sub_id);
-- 
-- -- Count Substations in Grid Districts   (OK!) -> 1.000ms =2.267
-- UPDATE 	orig_ego.ego_grid_districts_hull AS t1
-- SET  	sub_sum = t2.sub_sum
-- FROM	(SELECT	dis.sub_id AS sub_id,
-- 		COUNT(sub.geom)::integer AS sub_sum
-- 	FROM	orig_ego.ego_grid_districts_hull AS dis,
-- 		orig_ego.ego_deu_substations_110 AS sub
-- 	WHERE  	dis.geom && sub.geom AND
-- 		ST_CONTAINS(dis.geom,sub.geom)
-- 	GROUP BY dis.sub_id
-- 	)AS t2
-- WHERE  	t1.sub_id = t2.sub_id;
-- 
-- -- Create Index GIST (geom)   (OK!) 2.500ms =0
-- CREATE INDEX	ego_grid_districts_hull_geom_idx
-- 	ON	orig_ego.ego_grid_districts_hull
-- 	USING	GIST (geom);

