/*
mv griddistrict

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

---------- ---------- ----------
-- Substations per Municipalities
---------- ---------- ----------

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','input','model_draft','ego_political_boundary_bkg_vg250_6_gem_clean','ego_dp_mv_griddistrict.sql',' ');

-- municipalities
DROP TABLE IF EXISTS	model_draft.ego_political_boundary_hvmv_subst_per_gem CASCADE;
CREATE TABLE		model_draft.ego_political_boundary_hvmv_subst_per_gem AS
	SELECT	vg.*
	FROM	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean AS vg;

ALTER TABLE model_draft.ego_political_boundary_hvmv_subst_per_gem
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_type integer,
	ADD PRIMARY KEY (id);

-- index GIST (geom)
CREATE INDEX  	ego_political_boundary_hvmv_subst_per_gem_geom_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','input','model_draft','ego_grid_hvmv_substation','ego_dp_mv_griddistrict.sql',' ');

-- HVMV subst count
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

-- metadata
COMMENT ON TABLE model_draft.ego_political_boundary_hvmv_subst_per_gem IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_political_boundary_hvmv_subst_per_gem','ego_dp_mv_griddistrict.sql',' ');

-- SELECT	sum(mun.subst_sum) AS sum
-- FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem AS mun;


---------- ---------- ----------
-- MViews
---------- ---------- ----------

-- MView I.
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

-- index (id)
CREATE UNIQUE INDEX  	ego_political_boundary_hvmv_subst_per_gem_1_mview_gid_idx
		ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_1_mview (id);

-- Substation Type 1
UPDATE 	model_draft.ego_political_boundary_hvmv_subst_per_gem AS t1
	SET  	subst_type = t2.subst_type
	FROM	(SELECT	mun.id AS id,
			mun.subst_type AS subst_type
		FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_1_mview AS mun )AS t2
	WHERE  	t1.id = t2.id;

-- grant (oeuser)
ALTER TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem_1_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_political_boundary_hvmv_subst_per_gem_1_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_political_boundary_hvmv_subst_per_gem_1_mview','ego_dp_mv_griddistrict.sql',' ');


-- MView II.
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

-- index (id)
CREATE UNIQUE INDEX  	ego_political_boundary_hvmv_subst_per_gem_2_mview_gid_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview (id);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview OWNER TO oeuser;

-- Substation Type 2
UPDATE 	model_draft.ego_political_boundary_hvmv_subst_per_gem AS t1
	SET  	subst_type = t2.subst_type
	FROM	(SELECT	mun.id AS id,
			mun.subst_type AS subst_type
		FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview AS mun )AS t2
	WHERE  	t1.id = t2.id;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_political_boundary_hvmv_subst_per_gem_2_mview','ego_dp_mv_griddistrict.sql',' ');


-- Substation Type 2
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

-- index (subst_id)
CREATE UNIQUE INDEX  	ego_grid_hvmv_substation_mun_2_mview_subst_id_idx
	ON	model_draft.ego_grid_hvmv_substation_mun_2_mview (subst_id);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_hvmv_substation_mun_2_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_grid_hvmv_substation_mun_2_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_hvmv_substation_mun_2_mview','ego_dp_mv_griddistrict.sql',' ');


-- MView III.
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

-- index (id)
CREATE UNIQUE INDEX  	ego_political_boundary_hvmv_subst_per_gem_3_mview_gid_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview (id);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview OWNER TO oeuser;

-- Substation Type 3   (OK!) -> 1.000ms =9.904
UPDATE 	model_draft.ego_political_boundary_hvmv_subst_per_gem AS t1
	SET  	subst_type = t2.subst_type
	FROM	(SELECT	mun.id AS id,
			'3'::integer AS subst_type
		FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview AS mun )AS t2
	WHERE  	t1.id = t2.id;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_political_boundary_hvmv_subst_per_gem_3_mview','ego_dp_mv_griddistrict.sql',' ');


---------- ---------- ----------
-- Grid Districts
---------- ---------- ----------

---------- ---------- ----------
-- I. Gemeinden mit genau einem USW 
---------- ---------- ----------

-- Substations Template
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_type1 CASCADE;
CREATE TABLE		model_draft.ego_grid_mv_griddistrict_type1 AS
	SELECT	sub.subst_id ::integer,
		sub.subst_name ::text,
		sub.ags_0 ::character varying(12),
		sub.geom ::geometry(Point,3035) AS geom_sub
	FROM	model_draft.ego_grid_hvmv_substation AS sub;

-- PK
ALTER TABLE model_draft.ego_grid_mv_griddistrict_type1
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_type integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (subst_id);

-- index GIST (geom_sub)
CREATE INDEX  	ego_grid_mv_griddistrict_type1_geom_subst_idx
	ON	model_draft.ego_grid_mv_griddistrict_type1 USING GIST (geom_sub);

-- index GIST (geom)
CREATE INDEX  	ego_grid_mv_griddistrict_type1_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_type1 USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_type1 OWNER TO oeuser;

-- subst_id = gem.id
-- update usw geom gem1
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

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mv_griddistrict_type1 IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_mv_griddistrict_type1','ego_dp_mv_griddistrict.sql',' ');

	
---------- ---------- ---------- ---------- ---------- ----------
-- II. Gemeinden mit mehreren USW
---------- ---------- ---------- ---------- ---------- ----------

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','input','model_draft','ego_grid_hvmv_substation_voronoi','ego_dp_mv_griddistrict.sql',' ');

-- Substation ID
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

-- Substation Count
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


-- Voronoi cells
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_hvmv_substation_voronoi_mview AS
	SELECT	voi.id ::integer,
		voi.subst_id ::integer,
		voi.subst_sum ::integer,
		(ST_DUMP(voi.geom)).geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi AS voi
	WHERE	subst_sum = '1';

-- index (id)
CREATE UNIQUE INDEX  	ego_grid_hvmv_substation_voronoi_mview_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_mview (id);

-- index GIST (geom)
CREATE INDEX  	ego_grid_hvmv_substation_voronoi_mview_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_hvmv_substation_voronoi_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_grid_hvmv_substation_voronoi_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_hvmv_substation_voronoi_mview','ego_dp_mv_griddistrict.sql',' ');


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
-- -- grant (oeuser)
-- GRANT ALL ON TABLE	model_draft.ego_grid_hvmv_substation_voronoi_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		model_draft.ego_grid_hvmv_substation_voronoi_error_geom_view OWNER TO oeuser;

-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_deu_substations_voronoi_error_geom_view}', 'calc_grid_district');


---------- ---------- ----------
-- CUT
---------- ---------- ----------

DROP TABLE IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut CASCADE;
CREATE TABLE 		model_draft.ego_grid_hvmv_substation_voronoi_cut (
	id 		serial,
	subst_id 	integer,
	mun_id 		integer,
	voi_id 		integer,
	ags_0 		character varying(12),
	subst_type 	integer,
	subst_sum 	integer,
	geom 		geometry(Polygon,3035),
	geom_sub 	geometry(Point,3035),
	CONSTRAINT ego_grid_hvmv_substation_voronoi_cut_pkey PRIMARY KEY (id) );

INSERT INTO 	model_draft.ego_grid_hvmv_substation_voronoi_cut (subst_id,mun_id,voi_id,ags_0,subst_type,geom)
	SELECT	b.subst_id,
		a.id AS mun_id,
		b.id AS voi_id,
		a.ags_0 AS ags_0,
		a.subst_type,
		(ST_DUMP(ST_INTERSECTION(a.geom,b.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_2_mview AS a,
		model_draft.ego_grid_hvmv_substation_voronoi_mview AS b
	WHERE	a.geom && b.geom;

-- index GIST (geom)
CREATE INDEX	ego_grid_hvmv_substation_voronoi_cut_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut USING GIST (geom);

-- index GIST (geom_sub)
CREATE INDEX	ego_grid_hvmv_substation_voronoi_cut_geom_sub_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut USING GIST (geom_sub);

-- Count Substations in Voronoi Cuts
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
	
-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_hvmv_substation_voronoi_cut OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_hvmv_substation_voronoi_cut IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_hvmv_substation_voronoi_cut','ego_dp_mv_griddistrict.sql',' ');

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
-- -- grant (oeuser)
-- GRANT ALL ON TABLE	model_draft.ego_grid_hvmv_substation_voronoi_cut_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		model_draft.ego_grid_hvmv_substation_voronoi_cut_error_geom_view OWNER TO oeuser;

-- -- Drop empty view   (OK!) -> 100ms =1 (no error!)
-- SELECT f_drop_view('{ego_deu_substations_voronoi_cut_error_geom_view}', 'calc_grid_district');
---------- ---------- ----------


-- Parts with substation
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview AS
	SELECT	voi.*
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut AS voi
	WHERE	subst_sum = 1;

-- index (id)
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_1subst_mview_id_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview (id);

-- index GIST (geom)
CREATE INDEX  	ego_grid_hvmv_substation_voronoi_cut_1subst_mview_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_hvmv_substation_voronoi_cut_1subst_mview','ego_dp_mv_griddistrict.sql',' ');


-- Parts without substation
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

-- index (id)
CREATE UNIQUE INDEX  	ego_grid_hvmv_substation_voronoi_cut_0subst_mview_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_mview (id);

-- index GIST (geom)
CREATE INDEX  	ego_grid_hvmv_substation_voronoi_cut_0subst_mview_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_hvmv_substation_voronoi_cut_0subst_mview','ego_dp_mv_griddistrict.sql',' ');

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

-- Next Neighbor
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

-- index (id)
CREATE UNIQUE INDEX  	ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview_voi_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview (voi_id);

-- index GIST (geom_voi)
CREATE INDEX  	ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview_voi_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview USING GIST (geom_voi);

-- index GIST (geom_sub)
CREATE INDEX  	ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview_geom_sub_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview USING GIST (geom_sub);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview','ego_dp_mv_griddistrict.sql',' ');

---------- ---------- ----------

-- Sequence
DROP SEQUENCE IF EXISTS 	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview_id CASCADE;
CREATE SEQUENCE 		model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview_id;

-- grant (oeuser)
ALTER SEQUENCE		model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview_id OWNER TO oeuser;

-- connect points
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

-- index (id)
CREATE UNIQUE INDEX  	ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview (id);

-- index GIST (geom_centre)
CREATE INDEX	ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_geomcentre_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview USING GIST (geom_centre);

-- index GIST (geom)
CREATE INDEX	ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_hvmv_substation_voronoi_cut_0subst_nn_line_mview','ego_dp_mv_griddistrict.sql',' ');

---------- ---------- ----------

-- nn union
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview AS
	SELECT	nn.subst_id As subst_id, 
		ST_MULTI(ST_UNION(nn.geom_voi)) ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_mview AS nn
	GROUP BY nn.subst_id;

-- index (id)
CREATE UNIQUE INDEX  	ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview (subst_id);

-- index GIST (geom)
CREATE INDEX	ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview','ego_dp_mv_griddistrict.sql',' ');

---------- ---------- ----------

-- nn collect
DROP TABLE IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect CASCADE;
CREATE TABLE		model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect (
	id serial,
	subst_id integer,
	geom geometry(MultiPolygon,3035),
	CONSTRAINT ego_deu_substations_voronoi_cut_nn_collect_pkey PRIMARY KEY (id));

-- Insert parts with substations
INSERT INTO     model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect (subst_id,geom)
	SELECT	sub.subst_id AS subst_id,
		ST_MULTI(sub.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview AS sub;

-- Insert parts without substations union
INSERT INTO     model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect (subst_id,geom)
	SELECT	voi.subst_id AS subst_id,
		voi.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut_0subst_nn_union_mview AS voi;

-- index GIST (geom)
CREATE INDEX	ego_grid_hvmv_substation_voronoi_cut_nn_collect_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_hvmv_substation_voronoi_cut_nn_collect','ego_dp_mv_griddistrict.sql',' ');

---------- ---------- ----------

-- cut next neighbor
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_mview AS
	SELECT	nn.subst_id As subst_id, 
		ST_MULTI(ST_UNION(nn.geom)) ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_collect AS nn
	GROUP BY nn.subst_id;

-- index (id)
CREATE UNIQUE INDEX  	ego_grid_hvmv_substation_voronoi_cut_nn_mview_id_idx
		ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_mview (subst_id);

-- index GIST (geom)
CREATE INDEX	ego_grid_hvmv_substation_voronoi_cut_nn_mview_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_grid_hvmv_substation_voronoi_cut_nn_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_hvmv_substation_voronoi_cut_nn_mview','ego_dp_mv_griddistrict.sql',' ');

---------- ---------- ----------

-- Substations Template
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_type2 CASCADE;
CREATE TABLE		model_draft.ego_grid_mv_griddistrict_type2 AS
	SELECT	sub.subst_id ::integer,
		sub.subst_name ::text,
		sub.ags_0 ::character varying(12),
		sub.geom ::geometry(Point,3035) AS geom_sub
	FROM	model_draft.ego_grid_hvmv_substation AS sub;

-- PK
ALTER TABLE model_draft.ego_grid_mv_griddistrict_type2
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_type integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (subst_id);

-- index GIST (geom_sub)
CREATE INDEX  	ego_grid_mv_griddistrict_type2_geom_sub_idx
	ON	model_draft.ego_grid_mv_griddistrict_type2 USING GIST (geom_sub);

-- index GIST (geom)
CREATE INDEX  	ego_grid_mv_griddistrict_type2_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_type2 USING GIST (geom);

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
	
-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_type2 OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mv_griddistrict_type2 IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_mv_griddistrict_type2','ego_dp_mv_griddistrict.sql',' ');


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
-- -- grant (oeuser)
-- GRANT ALL ON TABLE	calc_ego_grid_district.ego_deu_usw_voronoi_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		calc_ego_grid_district.ego_deu_usw_voronoi_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_deu_usw_voronoi_mview_error_geom_view}', 'calc_grid_district');


---------- ---------- ----------
-- III. Gemeinden ohne sub
---------- ---------- ----------

-- gem WHERE subst_sum=0	orig_geo_ego.vg250_6_gem_subst_3_mview
-- sub				orig_geo_ego.ego_deu_mv_substations_mview

-- Next Neighbor
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

-- PK
ALTER TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn
	ADD PRIMARY KEY (mun_id);

-- index GIST (geom)
CREATE INDEX	ego_political_boundary_hvmv_subst_per_gem_3_nn_geom_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn USING GIST (geom);

-- index GIST (geom_sub)
CREATE INDEX	ego_political_boundary_hvmv_subst_per_gem_3_nn_geom_subst_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn USING GIST (geom_sub);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_political_boundary_hvmv_subst_per_gem_3_nn','ego_dp_mv_griddistrict.sql',' ');


---------- ---------- ----------
-- NN Line
---------- ---------- ----------

-- Sequence   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line_id CASCADE;
CREATE SEQUENCE 		model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line_id;

-- grant (oeuser)
ALTER SEQUENCE		model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line_id OWNER TO oeuser;

-- connect points
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

-- index (id)
CREATE UNIQUE INDEX  	ego_political_boundary_hvmv_subst_per_gem_3_nn_line_id_idx
		ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line (id);

-- index GIST (geom_centre)
CREATE INDEX	ego_political_boundary_hvmv_subst_per_gem_3_nn_line_geom_centre_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line USING GIST (geom_centre);

-- index GIST (geom)
CREATE INDEX	ego_political_boundary_hvmv_subst_per_gem_3_nn_line_geom_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_line IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_political_boundary_hvmv_subst_per_gem_3_nn_line','ego_dp_mv_griddistrict.sql',' ');


-- UNION
-- union mun
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

-- index (subst_id)
CREATE UNIQUE INDEX  	ego_political_boundary_hvmv_subst_per_gem_3_nn_union_subst_id_idx
		ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_union (subst_id);

-- index GIST (geom)
CREATE INDEX	ego_political_boundary_hvmv_subst_per_gem_3_nn_union_geom_idx
	ON	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_union USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_union OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_union IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_political_boundary_hvmv_subst_per_gem_3_nn_union','ego_dp_mv_griddistrict.sql',' ');


-- Substations Template
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_type3 CASCADE;
CREATE TABLE		model_draft.ego_grid_mv_griddistrict_type3 AS
	SELECT	sub.subst_id ::integer,
		sub.subst_name ::text,
		sub.ags_0 ::character varying(12),
		sub.geom ::geometry(Point,3035) AS geom_sub
	FROM	model_draft.ego_grid_hvmv_substation AS sub;

-- PK
ALTER TABLE model_draft.ego_grid_mv_griddistrict_type3
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_type integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (subst_id);

-- Create Index GIST (geom_sub)
CREATE INDEX  	ego_grid_mv_griddistrict_type3_geom_sub_idx
	ON	model_draft.ego_grid_mv_griddistrict_type3 USING GIST (geom_sub);

-- index GIST (geom)
CREATE INDEX  	ego_grid_mv_griddistrict_type3_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_type3 USING GIST (geom);

-- update sub geom mun3
UPDATE 	model_draft.ego_grid_mv_griddistrict_type3 AS t1
	SET  	subst_type = t2.subst_type,
		geom = t2.geom
	FROM	(SELECT	un.subst_id AS subst_id,
			un.subst_type ::integer AS subst_type,
			ST_MULTI(un.geom) ::geometry(MultiPolygon,3035) AS geom
		FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_nn_union AS un ) AS t2
	WHERE  	t1.subst_id = t2.subst_id;

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_type3 OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mv_griddistrict_type3 IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_mv_griddistrict_type3','ego_dp_mv_griddistrict.sql',' ');


---------- ---------- ----------
-- Collect the 3 Mun-types
---------- ---------- ----------

-- Substations Template
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

-- Insert 1
INSERT INTO     model_draft.ego_grid_mv_griddistrict_collect
	(subst_id,subst_name,ags_0,geom_sub,subst_sum,subst_type,geom)
	SELECT	*
	FROM	model_draft.ego_grid_mv_griddistrict_type1
	ORDER BY subst_id;

-- Insert 2
INSERT INTO     model_draft.ego_grid_mv_griddistrict_collect
	(subst_id,subst_name,ags_0,geom_sub,subst_sum,subst_type,geom)
	SELECT	*
	FROM	model_draft.ego_grid_mv_griddistrict_type2
	ORDER BY subst_id;

-- Insert 3 
INSERT INTO     model_draft.ego_grid_mv_griddistrict_collect
	(subst_id,subst_name,ags_0,geom_sub,subst_sum,subst_type,geom)
	SELECT	*
	FROM	model_draft.ego_grid_mv_griddistrict_type3
	ORDER BY subst_id;

-- Create Index GIST (geom_sub)
CREATE INDEX  	ego_grid_mv_griddistrict_collect_geom_sub_idx
	ON	model_draft.ego_grid_mv_griddistrict_collect USING GIST (geom_sub);

-- index GIST (geom)
CREATE INDEX  	ego_grid_mv_griddistrict_collect_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_collect USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_collect OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mv_griddistrict_collect IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_mv_griddistrict_collect','ego_dp_mv_griddistrict.sql',' ');


-- NEW PART
---------- ---------- ----------

-- Grid Districts with Multipolygons
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_union CASCADE;
CREATE TABLE         	model_draft.ego_grid_mv_griddistrict_union (
	subst_id	integer,
	geom		geometry(MultiPolygon,3035),
	CONSTRAINT ego_grid_mv_griddistrict_union_pkey PRIMARY KEY (subst_id) );

-- insert mvgd
INSERT INTO	model_draft.ego_grid_mv_griddistrict_union (subst_id,geom)
	SELECT DISTINCT ON 	(subst_id)
				subst_id AS subst_id,
				ST_MULTI(ST_UNION(geom)) ::geometry(MultiPolygon,3035) AS geom
			FROM	model_draft.ego_grid_mv_griddistrict_collect
		GROUP BY 	subst_id;

-- index GIST (geom)
CREATE INDEX  	ego_grid_mv_griddistrict_union_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_union USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_union OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mv_griddistrict_union IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- Clean Polygons and Snap to Grid
UPDATE 	model_draft.ego_grid_mv_griddistrict_union AS t1
	SET  	geom = t2.geom
	FROM	(SELECT	dis.subst_id,
			ST_SnapToGrid(ST_MULTI(ST_BUFFER(ST_BUFFER(dis.geom,0.1),-0.1)),1) ::geometry(MultiPolygon,3035) AS geom
		FROM	model_draft.ego_grid_mv_griddistrict_union AS dis
		)AS t2
	WHERE  	t1.subst_id = t2.subst_id;

-- dump
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_dump CASCADE;
CREATE TABLE         	model_draft.ego_grid_mv_griddistrict_dump (
	id		serial,
	subst_id	integer,
	subst_cnt	integer,
	geom_point	geometry(Point,3035),
	geom		geometry(Polygon,3035),
	CONSTRAINT ego_grid_mv_griddistrict_dump_pkey PRIMARY KEY (id) );

-- insert dump
INSERT INTO	model_draft.ego_grid_mv_griddistrict_dump (subst_id,geom)
	SELECT	subst_id,
		(ST_DUMP(geom)).geom AS geom
	FROM	model_draft.ego_grid_mv_griddistrict_union;

-- index GIST (geom)
CREATE INDEX  	ego_grid_mv_griddistrict_dump_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_dump USING GIST (geom);

-- index GIST (geom_point)
CREATE INDEX  	ego_grid_mv_griddistrict_dump_geom_point_idx
	ON	model_draft.ego_grid_mv_griddistrict_dump USING GIST (geom_point);	

-- hvmv substation count
UPDATE 	model_draft.ego_grid_mv_griddistrict_dump AS t1
	SET  	subst_cnt = t2.subst_cnt
	FROM	(SELECT	a.id AS id,
			COUNT(b.geom)::integer AS subst_cnt
		FROM	model_draft.ego_grid_mv_griddistrict_dump AS a,
			model_draft.ego_grid_hvmv_substation AS b
		WHERE  	a.geom && b.geom AND
			ST_CONTAINS(a.geom,b.geom)
		GROUP BY a.id
		)AS t2
	WHERE  	t1.id = t2.id;

-- geom_point
UPDATE 	model_draft.ego_grid_mv_griddistrict_dump AS t1
	SET  	geom_point = t2.geom_point
	FROM	(SELECT	id,
			ST_PointOnSurface(geom) AS geom_point
		FROM	model_draft.ego_grid_mv_griddistrict_dump
		WHERE  	subst_cnt IS NULL
		)AS t2
	WHERE  	t1.id = t2.id;

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_dump OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mv_griddistrict_dump IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;


-- dump centre fragments (a)
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_dump_0sub CASCADE;
CREATE TABLE         	model_draft.ego_grid_mv_griddistrict_dump_0sub (
	id		serial,
	subst_id	integer,
	subst_cnt	integer,
	geom_point	geometry(Point,3035),
	geom		geometry(Polygon,3035),
	CONSTRAINT ego_grid_mv_griddistrict_dump_0sub_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_dump_0sub OWNER TO oeuser;

-- insert dump
INSERT INTO	model_draft.ego_grid_mv_griddistrict_dump_0sub (subst_id,subst_cnt,geom_point,geom)
	SELECT	subst_id,
		subst_cnt,
		geom_point,
		geom
	FROM	model_draft.ego_grid_mv_griddistrict_dump
	WHERE	subst_cnt IS NULL;

-- index GIST (geom)
CREATE INDEX  	ego_grid_mv_griddistrict_dump_0sub_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_dump_0sub USING GIST (geom);


-- dump with substation without fragments (b)
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_dump_1sub CASCADE;
CREATE TABLE         	model_draft.ego_grid_mv_griddistrict_dump_1sub (
	id		serial,
	subst_id	integer,
	subst_cnt	integer,
	geom		geometry(Polygon,3035),
	CONSTRAINT ego_grid_mv_griddistrict_dump_1sub_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_dump_1sub OWNER TO oeuser;

-- insert dump
INSERT INTO	model_draft.ego_grid_mv_griddistrict_dump_1sub (subst_id,subst_cnt,geom)
	SELECT	subst_id,
		subst_cnt,
		geom
	FROM	model_draft.ego_grid_mv_griddistrict_dump
	WHERE	subst_cnt = 1;

-- index GIST (geom)
CREATE INDEX  	ego_grid_mv_griddistrict_dump_1sub_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_dump_1sub USING GIST (geom);


-- Next Neighbor
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_dump_nn CASCADE;
CREATE TABLE 		model_draft.ego_grid_mv_griddistrict_dump_nn AS
	SELECT DISTINCT ON (a.id)
		a.id 		AS a_id,
		a.geom_point	AS a_geom_point,
		a.geom		AS a_geom,
		b.id 		AS b_id,
		b.subst_id 	AS subst_id,
		b.subst_cnt	AS b_subst_cnt,
		b.geom		AS b_geom,
		ST_Distance(a.geom_point,ST_ExteriorRing(b.geom)) AS distance
	FROM 	model_draft.ego_grid_mv_griddistrict_dump_0sub AS a,
		model_draft.ego_grid_mv_griddistrict_dump_1sub AS b
	WHERE 	ST_DWithin(a.geom_point,ST_ExteriorRing(b.geom), 50000) -- In a 50 km radius
	ORDER BY a.id, ST_Distance(a.geom_point,ST_ExteriorRing(b.geom));

-- PK
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_dump_nn
	ADD PRIMARY KEY (a_id);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_dump_nn OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mv_griddistrict_dump_nn IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_mv_griddistrict_dump_nn','ego_dp_mv_griddistrict.sql',' ');


-- connect nn points
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_dump_nn_line CASCADE;
CREATE TABLE         	model_draft.ego_grid_mv_griddistrict_dump_nn_line (
	id		serial,
	a_id		integer,
	subst_id	integer,
	geom		geometry(LineString,3035),
	CONSTRAINT ego_grid_mv_griddistrict_dump_nn_line_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_dump_nn_line OWNER TO oeuser;


-- insert line
INSERT INTO	model_draft.ego_grid_mv_griddistrict_dump_nn_line (a_id,subst_id,geom)
	SELECT	a.a_id,
		a.subst_id,
		ST_ShortestLine(
			a_geom_point ::geometry(Point,3035),
			ST_ExteriorRing(b.geom) ::geometry(LineString,3035)
		) ::geometry(LineString,3035) AS geom
	FROM	model_draft.ego_grid_mv_griddistrict_dump_nn AS a,
		model_draft.ego_grid_mv_griddistrict_dump_1sub AS b
	WHERE	b.subst_id = a.subst_id;

-- index GIST (geom)
CREATE INDEX  	ego_grid_mv_griddistrict_dump_nn_line_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_dump_nn_line USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_dump_nn_line OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mv_griddistrict_dump_nn_line IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;


-- collect
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_dump_nn_collect CASCADE;
CREATE TABLE         	model_draft.ego_grid_mv_griddistrict_dump_nn_collect (
	id		serial,
	subst_id	integer,
	geom		geometry(Polygon,3035),
	CONSTRAINT ego_grid_mv_griddistrict_dump_nn_collect_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_dump_nn_collect OWNER TO oeuser;

-- insert a
INSERT INTO	model_draft.ego_grid_mv_griddistrict_dump_nn_collect (subst_id,geom)
	SELECT	subst_id,
		a_geom
	FROM	model_draft.ego_grid_mv_griddistrict_dump_nn
	ORDER BY subst_id;

-- insert b
INSERT INTO	model_draft.ego_grid_mv_griddistrict_dump_nn_collect (subst_id,geom)
	SELECT	subst_id,
		b_geom
	FROM	model_draft.ego_grid_mv_griddistrict_dump_nn
	ORDER BY subst_id;

-- index GIST (geom)
CREATE INDEX	ego_grid_mv_griddistrict_dump_nn_collect_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_dump_nn_collect USING GIST (geom);

-- clean
UPDATE 	model_draft.ego_grid_mv_griddistrict_dump_nn_collect AS t1
	SET  	geom = t2.geom
	FROM	(SELECT	id,
			ST_BUFFER(ST_BUFFER(geom,1,'join=mitre'),-1,'join=mitre') ::geometry(Polygon,3035) AS geom
		FROM	model_draft.ego_grid_mv_griddistrict_dump_nn_collect
		WHERE 	subst_id = subst_id
		)AS t2
	WHERE  	t1.id = t2.id;


-- union
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_dump_nn_collect_union CASCADE;
CREATE TABLE         	model_draft.ego_grid_mv_griddistrict_dump_nn_collect_union (
	subst_id	integer,
	geom		geometry(MultiPolygon,3035),
	CONSTRAINT ego_grid_mv_griddistrict_dump_nn_collect_union_pkey PRIMARY KEY (subst_id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict_dump_nn_collect_union OWNER TO oeuser;

-- insert union
INSERT INTO	model_draft.ego_grid_mv_griddistrict_dump_nn_collect_union (subst_id,geom)
	SELECT	un.subst_id 	::integer AS subst_id,
		un.geom 	::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT DISTINCT ON (subst_id)
			subst_id,
			ST_MULTI(ST_UNION(geom)) AS geom
		FROM	model_draft.ego_grid_mv_griddistrict_dump_nn_collect
		GROUP BY subst_id) AS un;

-- index GIST (geom)
CREATE INDEX	ego_grid_mv_griddistrict_dump_nn_collect_union_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_dump_nn_collect_union USING GIST (geom);

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mv_griddistrict_dump_nn_collect_union IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.7" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','temp','model_draft','ego_grid_mv_griddistrict_dump_nn_collect_union','ego_dp_mv_griddistrict.sql',' ');

-- Clean Polygons and Snap to Grid
UPDATE 	model_draft.ego_grid_mv_griddistrict_dump_nn_collect_union AS t1
	SET  	geom = t2.geom
	FROM	(SELECT	subst_id,
			ST_MULTI(ST_BUFFER(ST_BUFFER(geom,2,'join=mitre'),-2,'join=mitre')) ::geometry(MultiPolygon,3035) AS geom
		FROM	model_draft.ego_grid_mv_griddistrict_dump_nn_collect_union
		)AS t2
	WHERE  	t1.subst_id = t2.subst_id;

-- -- Validate (geom)
-- DROP VIEW IF EXISTS	model_draft.ego_grid_mv_griddistrict_union_error_geom_view CASCADE;
-- CREATE VIEW		model_draft.ego_grid_mv_griddistrict_union_error_geom_view AS
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.subst_id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	model_draft.ego_grid_mv_griddistrict_dump_nn_collect_union AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- grant (oeuser)
-- GRANT ALL ON TABLE	model_draft.ego_grid_mv_griddistrict_union_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		model_draft.ego_grid_mv_griddistrict_union_error_geom_view OWNER TO oeuser;
-- 
-- -- Drop empty view   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_grid_mv_griddistrict_union_error_geom_view}', 'model_draft');


-- create grid district
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict CASCADE;
CREATE TABLE 		model_draft.ego_grid_mv_griddistrict (
	subst_id	integer,
	subst_sum	integer,
	type1 		integer,
	type1_cnt 	integer,
	type2 		integer,
	type2_cnt	integer,
	type3		integer,
	type3_cnt	integer,
	"group"		char(1),
	gem		integer,
	gem_clean	integer,
	zensus_sum 		integer,
	zensus_count 		integer,
	zensus_density 		numeric,
	population_density 	numeric,
	la_count	integer,
	area_ha		decimal,	
	la_area		decimal(10,1),
	free_area	decimal(10,1),
	area_share	decimal(4,1),
	consumption	numeric,
	consumption_per_area	numeric,
	dea_cnt		integer,
	dea_capacity	numeric,
	lv_dea_cnt	integer,
	lv_dea_capacity	decimal,
	mv_dea_cnt	integer,
	mv_dea_capacity	decimal,
	geom_type	text,
	geom		geometry(MultiPolygon,3035),
	CONSTRAINT ego_grid_mv_griddistrict_pkey PRIMARY KEY (subst_id));

-- insert mvgd
INSERT INTO	model_draft.ego_grid_mv_griddistrict (subst_id,geom)
	SELECT 	subst_id,
		ST_MULTI(geom)
	FROM	model_draft.ego_grid_mv_griddistrict_dump_1sub
	ORDER BY subst_id;

-- index GIST (geom)
CREATE INDEX	ego_grid_mv_griddistrict_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict OWNER TO oeuser;

-- Count Substations in Grid Districts
UPDATE 	model_draft.ego_grid_mv_griddistrict AS t1
	SET  	geom = t2.geom
	FROM	(SELECT	subst_id,
			geom
		FROM	model_draft.ego_grid_mv_griddistrict_dump_nn_collect_union
		)AS t2
	WHERE  	t1.subst_id = t2.subst_id;

-- Count Substations in Grid Districts
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

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','output','model_draft','ego_grid_mv_griddistrict','ego_dp_mv_griddistrict.sql',' ');

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mv_griddistrict IS '{
	"title": "eGo dataprocessing - MV Grid district",
	"description": "Catchment area of HVMV substation (Transition point)",
	"language": [ "eng", "ger" ],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ",
		"url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)"},
		{"name": "OpenStreetMap", "description": "© OpenStreetMap contributors",
		"url": "http://www.openstreetmap.org/", "license": "Open Database License (ODbL) v1.0"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", "description": "© GeoBasis-DE / BKG 2016 (Daten verändert)",
		"url": "http://www.geodatenzentrum.de/", "license": "Geodatenzugangsgesetz (GeoZG)"} ],
	"spatial": [
		{"extend": "Gemany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!"} ],
	"contributors": [
		{"name": "Ludee", "email": "",
		"date": "02.09.2016", "comment": "Create table"},
		{"name": "Ludee", "email": "",
		"date": "15.01.2017", "comment": "Update metadata"},
		{"name": "Ludee", "email": "",
		"date": "21.03.2017", "comment": "Update metadata to 1.1"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "version", "description": "version id", "unit": "" },
				{"name": "subst_id", "description": "unique identifier", "unit": "" },
				{"name": "subst_sum", "description": "number of substation per MV griddistrict", "unit": "" },
				{"name": "area_ha", "description": "area in hectar", "unit": "ha" },
				{"name": "geom_type", "description": "polygon type (polygon, multipolygon)", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.1"}] }';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','result','model_draft','ego_grid_mv_griddistrict','ego_dp_mv_griddistrict.sql',' ');

/* -- versioning
INSERT INTO grid.ego_mv_griddistrict (version, subst_id, subst_sum, area_ha, geom_type, geom)
	SELECT	'v0.2.7',
		subst_id, subst_sum, area_ha, geom_type, geom
	FROM	model_draft.ego_grid_mv_griddistrict;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.7','result','grid','ego_mv_griddistrict','ego_dp_mv_griddistrict.sql','versioning'); */


-- OLD after restructuring

/* 
-- create grid district
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict CASCADE;
CREATE TABLE 		model_draft.ego_grid_mv_griddistrict (
	subst_id	integer,
	subst_sum	integer,
	type1 		integer,
	type1_cnt 	integer,
	type2 		integer,
	type2_cnt	integer,
	type3		integer,
	type3_cnt	integer,
	"group"		char(1),
	gem		integer,
	gem_clean	integer,
	zensus_sum 		integer,
	zensus_count 		integer,
	zensus_density 		numeric,
	population_density 	numeric,
	la_count	integer,
	area_ha		decimal,	
	la_area		decimal(10,1),
	free_area	decimal(10,1),
	area_share	decimal(4,1),
	consumption	numeric,
	consumption_per_area	numeric,
	dea_cnt		integer,
	dea_capacity	numeric,
	lv_dea_cnt	integer,
	lv_dea_capacity	decimal,
	mv_dea_cnt	integer,
	mv_dea_capacity	decimal,
	geom_type	text,
	geom		geometry(MultiPolygon,3035),
	CONSTRAINT ego_grid_mv_griddistrict_pkey PRIMARY KEY (subst_id));

-- insert mvgd
INSERT INTO	model_draft.ego_grid_mv_griddistrict (subst_id,geom)
	SELECT DISTINCT ON 	(dis.subst_id)
				dis.subst_id AS subst_id,
				ST_MULTI(ST_UNION(dis.geom)) ::geometry(MultiPolygon,3035) AS geom
			FROM	model_draft.ego_grid_mv_griddistrict_collect AS dis
		GROUP BY 	dis.subst_id;

-- index GIST (geom)
CREATE INDEX	ego_grid_mv_griddistrict_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mv_griddistrict OWNER TO oeuser;

-- Count Substations in Grid Districts
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
 */
/* -- Clean Polygons and Snap to Grid
UPDATE 	model_draft.ego_grid_mv_griddistrict AS t1
	SET  	geom = t2.geom
	FROM	(SELECT	dis.subst_id,
			ST_SnapToGrid(ST_MULTI(ST_BUFFER(ST_BUFFER(dis.geom,0.1),-0.1)),1) ::geometry(MultiPolygon,3035) AS geom
		FROM	model_draft.ego_grid_mv_griddistrict AS dis
		)AS t2
	WHERE  	t1.subst_id = t2.subst_id; */

/* 
-- Validate (geom)
DROP VIEW IF EXISTS	model_draft.ego_grid_mv_griddistrict_error_geom_view CASCADE;
CREATE VIEW		model_draft.ego_grid_mv_griddistrict_error_geom_view AS
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.subst_id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	model_draft.ego_grid_mv_griddistrict AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_grid_mv_griddistrict_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_mv_griddistrict_error_geom_view OWNER TO oeuser;

-- Drop empty view   (OK!) -> 100ms =1
SELECT f_drop_view('{ego_grid_mv_griddistrict_error_geom_view}', 'model_draft'); 
*/

/* -- dump
DROP TABLE IF EXISTS	model_draft.ego_grid_mv_griddistrict_new_dump CASCADE;
CREATE TABLE         	model_draft.ego_grid_mv_griddistrict_new_dump (
	id		serial,
	subst_id	integer,
	subst_cnt	integer,
	geom_point	geometry(Point,3035),
	geom		geometry(Polygon,3035),
	CONSTRAINT ego_grid_mv_griddistrict_new_dump_pkey PRIMARY KEY (id) );

-- insert dump
INSERT INTO	model_draft.ego_grid_mv_griddistrict_new_dump (subst_id,geom)
	SELECT	subst_id,
		(ST_DUMP(geom)).geom AS geom
	FROM	model_draft.ego_grid_mv_griddistrict_new;

-- index GIST (geom)
CREATE INDEX  	ego_grid_mv_griddistrict_new_dump_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict_new_dump USING GIST (geom);

-- hvmv substation count
UPDATE 	model_draft.ego_grid_mv_griddistrict_new_dump AS t1
	SET  	subst_cnt = t2.subst_cnt
	FROM	(SELECT	a.id AS id,
			COUNT(b.geom)::integer AS subst_cnt
		FROM	model_draft.ego_grid_mv_griddistrict_new_dump AS a,
			model_draft.ego_grid_hvmv_substation AS b
		WHERE  	a.geom && b.geom AND
			ST_CONTAINS(a.geom,b.geom)
		GROUP BY a.id
		)AS t2
	WHERE  	t1.id = t2.id; */
