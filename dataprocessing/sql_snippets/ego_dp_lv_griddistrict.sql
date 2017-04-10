/*
Generate ONT

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "jong42, Ludee"
*/


-- Cutting
DROP TABLE IF EXISTS 	model_draft.ego_grid_lv_griddistrict_cut CASCADE;
CREATE TABLE		model_draft.ego_grid_lv_griddistrict_cut (
	id 		serial NOT NULL,
	la_id 		integer,
	subst_id 	integer,
	subst_cnt	integer,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_grid_lv_griddistrict_cut_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_lv_griddistrict_cut OWNER TO oeuser;
	
-- index GIST (geom)
CREATE INDEX ego_grid_lv_griddistrict_cut_geom_idx
	ON model_draft.ego_grid_lv_griddistrict_cut USING GIST (geom);

INSERT INTO	model_draft.ego_grid_lv_griddistrict_cut (geom,la_id,subst_id)
	SELECT	(ST_DUMP(ST_SAFE_INTERSECTION(a.geom,b.geom))).geom ::geometry(Polygon,3035) AS geom, 
		a.id AS la_id,
		a.subst_id AS subst_id
	FROM	model_draft.ego_demand_loadarea AS a,
		model_draft.ego_grid_mvlv_substation_voronoi AS b
	WHERE	a.geom && b.geom 
		AND a.subst_id = b.subst_id
		-- make sure the boundaries really intersect and not just touch each other
		AND (ST_GEOMETRYTYPE(ST_SAFE_INTERSECTION(a.geom,b.geom)) = 'ST_Polygon' 
			OR ST_GEOMETRYTYPE(ST_SAFE_INTERSECTION(a.geom,b.geom)) = 'ST_MultiPolygon' )
		AND ST_isvalid(b.geom) AND ST_isvalid(a.geom);

-- mvlv substation count
UPDATE 	model_draft.ego_grid_lv_griddistrict_cut AS t1
	SET  	subst_cnt = t2.subst_cnt
	FROM	(SELECT	a.id AS id,
			COUNT(b.geom)::integer AS subst_cnt
		FROM	model_draft.ego_grid_lv_griddistrict_cut AS a,
			model_draft.ego_grid_mvlv_substation AS b
		WHERE  	a.geom && b.geom AND
			ST_CONTAINS(a.geom,b.geom)
		GROUP BY a.id
		)AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_lv_griddistrict_cut','ego_dp_lv_griddistrict.sql',' ');


/* -- Validate (geom)   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	model_draft.ego_grid_lv_griddistrict_cut_error_geom_view CASCADE;
CREATE VIEW		model_draft.ego_grid_lv_griddistrict_cut_error_geom_view AS
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	model_draft.ego_grid_lv_griddistrict_cut AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_grid_lv_griddistrict_cut_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_lv_griddistrict_cut_error_geom_view OWNER TO oeuser;

-- Drop empty view   (OK!) -> 100ms =1
SELECT f_drop_view('{ego_grid_lv_griddistrict_cut_error_geom_view}', 'model_draft');
 */


-- with substation
DROP TABLE IF EXISTS	model_draft.ego_grid_lv_griddistrict_cut_1subst CASCADE;
CREATE TABLE         	model_draft.ego_grid_lv_griddistrict_cut_1subst (
	mvlv_subst_id 	integer,
	la_id 		integer,
	subst_id 	integer,
	subst_cnt	integer,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_grid_lv_griddistrict_cut_1subst_pkey PRIMARY KEY (mvlv_subst_id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_lv_griddistrict_cut_1subst OWNER TO oeuser;

-- insert dump
INSERT INTO	model_draft.ego_grid_lv_griddistrict_cut_1subst
	SELECT	*
	FROM	model_draft.ego_grid_lv_griddistrict_cut
	WHERE	subst_cnt = 1;

-- index GIST (geom)
CREATE INDEX  	ego_grid_lv_griddistrict_cut_1subst_geom_idx
	ON	model_draft.ego_grid_lv_griddistrict_cut_1subst USING GIST (geom);

-- metadata
COMMENT ON TABLE model_draft.ego_grid_lv_griddistrict_cut_1subst IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.8" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_lv_griddistrict_cut_1subst','ego_dp_lv_griddistrict.sql',' ');



-- fragments
DROP TABLE IF EXISTS	model_draft.ego_grid_lv_griddistrict_cut_0subst CASCADE;
CREATE TABLE         	model_draft.ego_grid_lv_griddistrict_cut_0subst (
	mvlv_subst_id 	integer,
	la_id 		integer,
	subst_id 	integer,
	subst_cnt	integer,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_grid_lv_griddistrict_cut_0subst_pkey PRIMARY KEY (mvlv_subst_id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_lv_griddistrict_cut_0subst OWNER TO oeuser;

-- insert dump
INSERT INTO	model_draft.ego_grid_lv_griddistrict_cut_0subst
	SELECT	*
	FROM	model_draft.ego_grid_lv_griddistrict_cut
	WHERE	subst_cnt IS NULL;

-- index GIST (geom)
CREATE INDEX  	ego_grid_lv_griddistrict_cut_0subst_geom_idx
	ON	model_draft.ego_grid_lv_griddistrict_cut_0subst USING GIST (geom);

-- metadata
COMMENT ON TABLE model_draft.ego_grid_lv_griddistrict_cut_0subst IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.8" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_lv_griddistrict_cut_0subst','ego_dp_lv_griddistrict.sql',' ');



-- with too many substation!
DROP TABLE IF EXISTS	model_draft.ego_grid_lv_griddistrict_cut_xsubst CASCADE;
CREATE TABLE         	model_draft.ego_grid_lv_griddistrict_cut_xsubst (
	mvlv_subst_id 	integer,
	la_id 		integer,
	subst_id 	integer,
	subst_cnt	integer,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_grid_lv_griddistrict_cut_xsubst_pkey PRIMARY KEY (mvlv_subst_id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_lv_griddistrict_cut_xsubst OWNER TO oeuser;

-- insert dump
INSERT INTO	model_draft.ego_grid_lv_griddistrict_cut_xsubst
	SELECT	*
	FROM	model_draft.ego_grid_lv_griddistrict_cut
	WHERE	subst_cnt > 1;

-- index GIST (geom)
CREATE INDEX  	ego_grid_lv_griddistrict_cut_xsubst_geom_idx
	ON	model_draft.ego_grid_lv_griddistrict_cut_xsubst USING GIST (geom);

-- metadata
COMMENT ON TABLE model_draft.ego_grid_lv_griddistrict_cut_xsubst IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.8" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_lv_griddistrict_cut_xsubst','ego_dp_lv_griddistrict.sql',' ');



-- Next Neighbor
DROP TABLE IF EXISTS	model_draft.ego_grid_lv_griddistrict_cut_nn CASCADE;
CREATE TABLE         	model_draft.ego_grid_lv_griddistrict_cut_nn (
	id	 		serial,
	a_mvlv_subst_id 	integer,
	b_mvlv_subst_id 	integer,
	subst_id		integer,
	la_id 			integer,
	a_geom			geometry(Polygon,3035),
	b_geom			geometry(Polygon,3035),
	geom_line		geometry(LineString,3035),
	distance		double precision,
	CONSTRAINT ego_grid_lv_griddistrict_cut_nn_pkey PRIMARY KEY (id) );

INSERT INTO model_draft.ego_grid_lv_griddistrict_cut_nn (a_mvlv_subst_id,b_mvlv_subst_id,subst_id,la_id,a_geom,b_geom,geom_line,distance)
	SELECT DISTINCT ON (a.mvlv_subst_id)
		a.mvlv_subst_id,
		b.mvlv_subst_id,
		a.subst_id,
		a.la_id,
		a.geom,
		b.geom,
		ST_ShortestLine(
			ST_CENTROID(a.geom) ::geometry(Point,3035),
			ST_ExteriorRing(b.geom) ::geometry(LineString,3035)
			) ::geometry(LineString,3035) AS geom_line,
		ST_Distance(ST_CENTROID(a.geom),ST_ExteriorRing(b.geom))
	FROM 	model_draft.ego_grid_lv_griddistrict_cut_0subst AS a,		-- fragments
		model_draft.ego_grid_lv_griddistrict_cut_1subst AS b		-- target
	WHERE 	ST_DWithin(ST_CENTROID(a.geom),ST_ExteriorRing(b.geom), 1000) 	-- In a 1 km radius
		AND a.subst_id = b.subst_id
	ORDER BY a.mvlv_subst_id, ST_Distance(ST_CENTROID(a.geom),ST_ExteriorRing(b.geom));

-- index GIST (geom)
CREATE INDEX  	ego_grid_lv_griddistrict_cut_nn_ageom_idx
	ON	model_draft.ego_grid_lv_griddistrict_cut_nn USING GIST (a_geom);

-- index GIST (geom)
CREATE INDEX  	ego_grid_lv_griddistrict_cut_nn_geom_line_idx
	ON	model_draft.ego_grid_lv_griddistrict_cut_nn USING GIST (geom_line);

-- index GIST (geom)
CREATE INDEX  	ego_grid_lv_griddistrict_cut_nn_bgeom_idx
	ON	model_draft.ego_grid_lv_griddistrict_cut_nn USING GIST (b_geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_lv_griddistrict_cut_nn OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_lv_griddistrict_cut_nn IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.8" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_lv_griddistrict_cut_nn','ego_dp_lv_griddistrict.sql',' ');



-- collect and union
DROP TABLE IF EXISTS	model_draft.ego_grid_lv_griddistrict_cut_nn_collect CASCADE;
CREATE TABLE         	model_draft.ego_grid_lv_griddistrict_cut_nn_collect (
	mvlv_subst_id	integer,
	mvlv_subst_id_new	integer,
	subst_id	integer,
	la_id 		integer,
	nn		boolean,
	geom		geometry(MultiPolygon,3035),
	CONSTRAINT ego_grid_lv_griddistrict_cut_nn_collect_pkey PRIMARY KEY (mvlv_subst_id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_lv_griddistrict_cut_nn_collect OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX	ego_grid_lv_griddistrict_cut_nn_collect_geom_idx
	ON	model_draft.ego_grid_lv_griddistrict_cut_nn_collect USING GIST (geom);

-- insert
INSERT INTO	model_draft.ego_grid_lv_griddistrict_cut_nn_collect (mvlv_subst_id,subst_id,la_id,nn,geom)
	SELECT	mvlv_subst_id,
		subst_id,
		la_id,
		FALSE,
		ST_MULTI(geom)
	FROM	model_draft.ego_grid_lv_griddistrict_cut_1subst
	ORDER BY mvlv_subst_id;

-- insert union
UPDATE 	model_draft.ego_grid_lv_griddistrict_cut_nn_collect AS t1
	SET  	geom = t2.geom,
		nn = TRUE
	FROM	(SELECT	DISTINCT ON (a.b_mvlv_subst_id)
			a.b_mvlv_subst_id AS mvlv_subst_id,
			ST_MULTI(ST_UNION(a.a_geom, b.geom)) AS geom
		FROM	model_draft.ego_grid_lv_griddistrict_cut_nn AS a,
			model_draft.ego_grid_lv_griddistrict_cut_1subst AS b 
		WHERE	a.b_mvlv_subst_id = b.mvlv_subst_id
		) AS t2
	WHERE  	t1.mvlv_subst_id = t2.mvlv_subst_id;

-- substation id
UPDATE 	model_draft.ego_grid_lv_griddistrict_cut_nn_collect AS t1
	SET  	mvlv_subst_id_new = t2.mvlv_subst_id_new
	FROM    (
		SELECT	a.mvlv_subst_id AS mvlv_subst_id,
			b.mvlv_subst_id AS mvlv_subst_id_new
		FROM	model_draft.ego_grid_lv_griddistrict_cut_nn_collect AS a,
			model_draft.ego_grid_mvlv_substation AS b
		WHERE  	a.geom && b.geom AND
			ST_CONTAINS(a.geom,b.geom)
		) AS t2
	WHERE  	t1.mvlv_subst_id = t2.mvlv_subst_id;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_lv_griddistrict_cut_nn_collect IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.8" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_lv_griddistrict_cut_nn_collect','ego_dp_lv_griddistrict.sql',' ');

		
		
		
		
		
		


/* 
-- Lösche sehr kleine Gebiete; Diese sind meistens Bugs in den Grenzverläufen
DELETE FROM model_draft.ego_grid_lv_griddistrict WHERE ST_AREA(geom) < 0.001;
	
-- Count substations per grid district
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
SET ont_count = 0;

UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
SET  	ont_count = t2.count
FROM (SELECT COUNT (onts.geom) AS count,dist.id AS id
	FROM model_draft."ego_grid_mvlv_substation" AS onts, model_draft.ego_grid_lv_griddistrict AS dist
	WHERE ST_CONTAINS (dist.geom,onts.geom)
	GROUP BY dist.id
      ) AS t2
WHERE t1.id = t2.id;


UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
SET  	ont_id = t2.id
FROM model_draft."ego_grid_mvlv_substation" AS t2
WHERE ST_CONTAINS(t1.geom,t2.geom);

-- Add merge info


UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
SET merge_id = t2.merge_id
FROM (
	WITH mins AS (
		SELECT regions.id AS regions_id, MIN(ST_DISTANCE(ST_CENTROID(regions.geom),onts.geom)) AS distance
		FROM
			model_draft."ego_grid_mvlv_substation" AS onts 
			INNER JOIN 
			model_draft.ego_grid_lv_griddistrict AS regions ON onts.la_id = regions.la_id
			INNER JOIN 
			model_draft.ego_grid_lv_griddistrict AS regions2 ON ST_INTERSECTS(regions.geom,regions2.geom)
		WHERE ST_CONTAINS (regions2.geom,onts.geom)
		GROUP BY regions_id

	)

	SELECT regions.id AS district_id, onts.id AS merge_id
	FROM
		model_draft."ego_grid_mvlv_substation" AS onts 
		INNER JOIN 
		model_draft.ego_grid_lv_griddistrict AS regions ON onts.la_id = regions.la_id
		INNER JOIN
		mins ON mins.regions_id = regions.id
	WHERE  ST_DISTANCE(ST_CENTROID(regions.geom),onts.geom) = mins.distance
      ) AS t2
WHERE t1.id = t2.district_id;

UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
SET ont_id = merge_id
WHERE ont_count = 0;

----- bis hierhin 3h 13 min


-- Merge areas with same ONT_ID
DROP TABLE IF EXISTS model_draft."ego_grid_lv_griddistrictwithoutpop" CASCADE;
CREATE TABLE IF NOT EXISTS model_draft."ego_grid_lv_griddistrictwithoutpop"
(
  id serial NOT NULL,
  geom geometry(Polygon,3035),
  la_id integer,
  CONSTRAINT ego_grid_lv_griddistrictwithoutpop_pkey PRIMARY KEY (id)
);

-- index GIST (geom)
CREATE INDEX ego_grid_lv_griddistrictwithoutpop_geom_idx
	ON model_draft."ego_grid_lv_griddistrictwithoutpop" USING GIST (geom);

INSERT INTO		model_draft."ego_grid_lv_griddistrictwithoutpop" (geom,la_id)

SELECT (ST_DUMP(ST_UNION(cut.geom))).geom::geometry(Polygon,3035), onts.la_id
FROM model_draft.ego_grid_lv_griddistrict AS cut
	INNER JOIN model_draft."ego_grid_mvlv_substation" AS onts
ON cut.ont_id = onts.id
WHERE ont_id >= 0
GROUP BY cut.ont_id, onts.la_id;

-------------------------------
-- Lösche Bezirke ohne Transformator
DELETE FROM model_draft."ego_grid_lv_griddistrictwithoutpop" AS districts
USING model_draft."ego_grid_mvlv_substation" AS onts
WHERE ST_INTERSECTS (onts.geom,districts.geom) = FALSE
	AND onts.id = districts.id;


-- Ordne Bezirke ohne Trafo benachbarten Bezirken mit Trafo zu
UPDATE model_draft."ego_grid_lv_griddistrictwithoutpop" AS districts
SET geom = ST_UNION(adjacent.geom, districts.geom)
FROM  ( SELECT ST_UNION(cut.geom) AS geom, districts.id AS district_id
	FROM model_draft."ego_grid_lv_griddistrictwithoutpop" AS districts,
		model_draft.ego_grid_lv_griddistrict AS cut
	WHERE ST_TOUCHES(cut.geom,districts.geom)
	 AND NOT ST_GEOMETRYTYPE (ST_INTERSECTION(cut.geom,districts.geom)) = 'ST_Point'
	 AND cut.id IN (
		SELECT id FROM model_draft.ego_grid_lv_griddistrict AS cut
		WHERE cut.id NOT IN (
			SELECT cut.id 
			FROM model_draft.ego_grid_lv_griddistrict AS cut,
				model_draft."ego_grid_lv_griddistrictwithoutpop" AS districts
			WHERE ST_WITHIN(cut.geom,districts.geom)
			GROUP BY cut.id
		)
)
		
	GROUP BY districts.id
	) AS adjacent
WHERE districts.id = adjacent.district_id;


-- Add relation between LV grid districts and MVLV substations
-- step 1: add new col with MVLV subst id
ALTER TABLE model_draft.ego_grid_lv_griddistrict
ADD COLUMN mvlv_subst_id integer DEFAULT NULL;
-- step 2: write MVLV subst id to LV grid district table
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
SET  	mvlv_subst_id = t2.sub_id
FROM	(SELECT	gd.id AS gd_id,
	sub.id ::integer AS sub_id

	FROM	model_draft.ego_grid_lv_griddistrict AS gd,
		model_draft.ego_grid_mvlv_substation AS sub
	WHERE  	gd.la_id = sub.la_id AND
		gd.geom && sub.geom AND
		ST_CONTAINS(gd.geom,sub.geom)
	GROUP BY gd.id, sub.id
	) AS t2
WHERE  	t1.id = t2.gd_id;

 */



















/* 
-- cut mvlv voronoi with loadarea
DROP TABLE IF EXISTS	model_draft.ego_grid_mvlv_substation_voronoi_cut;
CREATE TABLE 		model_draft.ego_grid_mvlv_substation_voronoi_cut (
	id 		serial NOT NULL,
	lvgd_id 	integer,
	subst_sum 	integer,
	la_id 		integer,
	geom 		geometry(Polygon,3035),
	geom_sub 	geometry(Point,3035),
	CONSTRAINT ego_grid_lv_griddistrict_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE model_draft.ego_grid_mvlv_substation_voronoi_cut OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','input','model_draft','ego_demand_loadarea','ego_dp_lv_griddistrict.sql',' ');
SELECT ego_scenario_log('v0.2.8','input','model_draft','ego_grid_mvlv_substation_voronoi','ego_dp_lv_griddistrict.sql',' ');

-- insert cut
INSERT INTO 	model_draft.ego_grid_mvlv_substation_voronoi_cut (la_id,geom)
	SELECT	a.id AS la_id,
		(ST_DUMP(ST_INTERSECTION(a.geom,b.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_demand_loadarea AS a,
		model_draft.ego_grid_mvlv_substation_voronoi AS b
	WHERE	a.geom && b.geom AND
		a.subst_id = b.subst_id
		AND cnt = 1
		-- make sure the boundaries really intersect and not just touch each other
		AND (ST_GEOMETRYTYPE(ST_INTERSECTION(a.geom,b.geom)) = 'ST_Polygon' 
		OR ST_GEOMETRYTYPE(ST_INTERSECTION(a.geom,b.geom)) = 'ST_MultiPolygon' );

-- index GIST (geom)
CREATE INDEX	ego_grid_mvlv_substation_voronoi_cut_geom_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_cut USING GIST (geom);

-- index GIST (geom_sub)
CREATE INDEX	ego_grid_mvlv_substation_voronoi_cut_geom_sub_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_cut USING GIST (geom_sub);
 */
/* -- count mvlv_substation (only count)
UPDATE 	model_draft.ego_grid_mvlv_substation_voronoi_cut AS t1
	SET  	subst_sum = t2.subst_sum
	FROM	(SELECT	a.id AS id,
			COUNT(b.geom)::integer AS subst_sum
		FROM	model_draft.ego_grid_mvlv_substation_voronoi_cut AS a,
			model_draft.ego_grid_mvlv_substation AS b
		WHERE  	a.geom && b.geom AND
			ST_CONTAINS(a.geom,b.geom)
		GROUP BY a.id
		)AS t2
	WHERE  	t1.id = t2.id; */
/* 
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','input','model_draft','ego_grid_mvlv_substation','ego_dp_lv_griddistrict.sql',' ');

-- count mvlv_substation
UPDATE 	model_draft.ego_grid_mvlv_substation_voronoi_cut AS t1
	SET  	lvgd_id = t2.lvgd_id,
		subst_sum = t2.subst_sum,
		geom_sub = t2.geom_sub
	FROM	(SELECT	a.id AS id,
			b.lvgd_id,
			b.geom AS geom_sub,
			COUNT(b.geom)::integer AS subst_sum
		FROM	model_draft.ego_grid_mvlv_substation_voronoi_cut AS a,
			model_draft.ego_grid_mvlv_substation AS b
		WHERE  	a.geom && b.geom AND
			ST_CONTAINS(a.geom,b.geom)
		GROUP BY a.id,b.lvgd_id,b.geom
		)AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut','ego_dp_lv_griddistrict.sql',' ');


-- Parts with substation
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_mvlv_substation_voronoi_cut_1subst_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_mvlv_substation_voronoi_cut_1subst_mview AS
	SELECT	a.*
	FROM	model_draft.ego_grid_mvlv_substation_voronoi_cut AS a
	WHERE	subst_sum = 1;

-- index (id)
CREATE UNIQUE INDEX  	ego_grid_mvlv_substation_voronoi_cut_1subst_mview_id_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_1subst_mview (id);

-- index GIST (geom)
CREATE INDEX  	ego_grid_mvlv_substation_voronoi_cut_1subst_mview_geom_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_1subst_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mvlv_substation_voronoi_cut_1subst_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_1subst_mview','ego_dp_lv_griddistrict.sql',' ');


-- Parts without substation
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_mview AS
	SELECT	a.*
	FROM	model_draft.ego_grid_mvlv_substation_voronoi_cut AS a
	WHERE	subst_sum IS NULL;

-- index (id)
CREATE UNIQUE INDEX  	ego_grid_mvlv_substation_voronoi_cut_0subst_mview_id_idx
		ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_mview (id);

-- index GIST (geom)
CREATE INDEX  	ego_grid_mvlv_substation_voronoi_cut_0subst_mview_geom_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_0subst_mview','ego_dp_lv_griddistrict.sql',' ');
 */



---------- ---------- ----------
-- Connect the cutted parts to the next substation
---------- ---------- ----------
/* 
-- Next Neighbor
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview AS
	SELECT DISTINCT ON (voi.id)
		voi.id AS voi_id,
		--voi.ags_0 AS voi_ags_0,
		voi.geom AS geom_voi,
		sub.subst_id AS subst_id,
		--sub.ags_0 AS ags_0,
		sub.geom AS geom_sub
	FROM 	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_mview AS voi,
		model_draft.ego_grid_mvlv_substation_voronoi_cut_1subst_mview AS sub
	WHERE 	ST_DWithin(ST_ExteriorRing(voi.geom),ST_ExteriorRing(sub.geom), 50000) -- In a 50 km radius
		--AND voi.ags_0 = sub.ags_0  -- only inside same mun
	ORDER BY 	voi.id, 
			ST_Distance(ST_ExteriorRing(voi.geom),ST_ExteriorRing(sub.geom));

-- ST_Length(ST_CollectionExtract(ST_Intersection(a_geom, b_geom), 2)) -- Lenght of the shared border?

-- index (id)
CREATE UNIQUE INDEX  	ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview_voi_id_idx
		ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview (voi_id);

-- index GIST (geom_voi)
CREATE INDEX  	ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview_voi_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview USING GIST (geom_voi);

-- index GIST (geom_sub)
CREATE INDEX  	ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview_geom_sub_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview USING GIST (geom_sub);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview','process_eGo_grid_district.sql',' ');

---------- ---------- ----------

-- Sequence
DROP SEQUENCE IF EXISTS 	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview_id CASCADE;
CREATE SEQUENCE 		model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview_id;

-- grant (oeuser)
ALTER SEQUENCE		model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview_id OWNER TO oeuser;

-- connect points
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview;
CREATE MATERIALIZED VIEW 		model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview AS
	SELECT 	nextval('model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview_id') AS id,
		nn.voi_id,
		nn.subst_id,
		(ST_Dump(ST_CENTROID(nn.geom_voi))).geom ::geometry(Point,3035) AS geom_centre,
		ST_ShortestLine(	(ST_Dump(ST_CENTROID(nn.geom_voi))).geom ::geometry(Point,3035),
					sub.geom ::geometry(Point,3035)
		) ::geometry(LineString,3035) AS geom
	FROM	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview AS nn,
		model_draft.ego_grid_hvmv_substation AS sub
	WHERE	sub.subst_id = nn.subst_id;

-- index (id)
CREATE UNIQUE INDEX  	ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview_id_idx
		ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview (id);

-- index GIST (geom_centre)
CREATE INDEX	ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview_geom_centre_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview USING GIST (geom_centre);

-- index GIST (geom)
CREATE INDEX	ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview_geom_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview','process_eGo_grid_district.sql',' ');

---------- ---------- ----------

-- nn union
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_union_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_union_mview AS
	SELECT	nn.subst_id As subst_id, 
		ST_MULTI(ST_UNION(nn.geom_voi)) ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview AS nn
	GROUP BY nn.subst_id;

-- index (id)
CREATE UNIQUE INDEX  	ego_grid_mvlv_substation_voronoi_cut_0subst_nn_union_mview_id_idx
		ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_union_mview (subst_id);

-- index GIST (geom)
CREATE INDEX	ego_grid_mvlv_substation_voronoi_cut_0subst_nn_union_mview_geom_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_union_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_union_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_0subst_nn_union_mview','process_eGo_grid_district.sql',' ');

---------- ---------- ----------

-- nn collect
DROP TABLE IF EXISTS	model_draft.ego_grid_mvlv_substation_voronoi_cut_nn_collect CASCADE;
CREATE TABLE		model_draft.ego_grid_mvlv_substation_voronoi_cut_nn_collect (
	id serial,
	subst_id integer,
	geom geometry(MultiPolygon,3035),
	CONSTRAINT ego_deu_substations_voronoi_cut_nn_collect_pkey PRIMARY KEY (id));

-- Insert parts with substations
INSERT INTO     model_draft.ego_grid_mvlv_substation_voronoi_cut_nn_collect (subst_id,geom)
	SELECT	sub.subst_id AS subst_id,
		ST_MULTI(sub.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut_1subst_mview AS sub;

-- Insert parts without substations union
INSERT INTO     model_draft.ego_grid_mvlv_substation_voronoi_cut_nn_collect (subst_id,geom)
	SELECT	voi.subst_id AS subst_id,
		voi.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_mvlv_substation_voronoi_cut_0subst_nn_union_mview AS voi;

-- index GIST (geom)
CREATE INDEX	ego_grid_mvlv_substation_voronoi_cut_nn_collect_geom_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_nn_collect USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mvlv_substation_voronoi_cut_nn_collect OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_nn_collect','process_eGo_grid_district.sql',' ');

---------- ---------- ----------

-- cut next neighbor
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_grid_mvlv_substation_voronoi_cut_nn_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.ego_grid_mvlv_substation_voronoi_cut_nn_mview AS
	SELECT	nn.subst_id As subst_id, 
		ST_MULTI(ST_UNION(nn.geom)) ::geometry(MultiPolygon,3035) AS geom
	FROM	model_draft.ego_grid_mvlv_substation_voronoi_cut_nn_collect AS nn
	GROUP BY nn.subst_id;

-- index (id)
CREATE UNIQUE INDEX  	ego_grid_mvlv_substation_voronoi_cut_nn_mview_id_idx
		ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_nn_mview (subst_id);

-- index GIST (geom)
CREATE INDEX	ego_grid_mvlv_substation_voronoi_cut_nn_mview_geom_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_cut_nn_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mvlv_substation_voronoi_cut_nn_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_nn_mview','process_eGo_grid_district.sql',' ');






-- metadata
COMMENT ON TABLE model_draft.ego_grid_lv_griddistrict IS '{
	"title": "eGoDP - MVLV Substation (ONT)",
	"description": "Low voltage substations / Distribution substations (Ortsnetztrafos)",
	"language": [ "eng", "ger" ],
	"reference_date": "2017",
	"sources": [
		{"name": "open_eGo", "description": "eGo dataprocessing",
		"url": "https://github.com/openego/data_processing", "license": "ODbL-1.0"} ],
	"spatial": [
		{"extend": "Germany",
		"resolution": " "} ],
	"license": [
		{"id": "tba",
		"name": "tba",
		"version": "tba",
		"url": "tba",
		"instruction": "tba"} ],
	"contributors": [
		{"name": "jong42", "email": " ",
		"date": "20.10.2016", "comment": "create table"},
		{"name": "jong42", "email": " ",
		"date": "27.10.2016", "comment": "change table names"},
		{"name": "Ludee", "email": " ",
		"date": "21.03.2017", "comment": "validate and restructure tables"},
		{"name": "Ludee", "email": " ",
		"date": "22.03.2017", "comment": "update metadata (1.1) and add license"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "id", "description": "unique identifier", "unit": "" },
				{"name": "la_id", "description": "loadarea ID", "unit": "" },
				{"name": "subst_id", "description": "HVMV substation ID", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.1" }] }';

-- select description
SELECT obj_description('model_draft.ego_grid_lv_griddistrict' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','output','model_draft','ego_grid_lv_griddistrict','ego_dp_lv_substation.sql',' ');

 */


/* 
-- metadata
COMMENT ON TABLE model_draft.ego_grid_lv_griddistrict IS
'{
"Name": "eGo data processing - ego_grid_lv_griddistrict",
"Source": [{
                  "Name": "open_eGo",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "2016-10-12",
"Original file": "process_eGo_lv_grid_districts.sql",
"Spatial resolution": ["germany"],
"Description": ["eGo data processing modeling of LV grid districts"],

"Column": [
                {"Name": "id",
                "Description": "Unique identifier",
                "Unit": "" },
				
				{"Name": "geom",
                "Description": "Geometry",
                "Unit": "" },
				
				{"Name": "la_id",
                "Description": "ID of the corresponding load area",
                "Unit": "" },
				
				{"Name": "population",
                "Description": "number of residents in the district",
                "Unit": "residents" },

                		{"Name": "peak_load",
                "Description": "estimated peak_load in the district",
                "Unit": "kW" },

                              	{"Name": "area_ha",
                "Description": "area of the the district",
                "Unit": "ha" },

                                {"Name": "pop_density",
                "Description": "population density in the district",
                "Unit": "residents/ha" },

                                {"Name": "structure_type",
                "Description": "structure type of the the district (urban, rural)",
                "Unit": "" }],


"Changes":[
                {"Name": "Jonas Gütter",
                "Mail": "jonas.guetter@rl-institut.de",
                "Date":  "20.10.2016",
                "Comment": "Created table" },
				
				{"Name": "Jonas Gütter",
                "Mail": "jonas.guetter@rl-institut.de",
                "Date":  "20.10.2016",
                "Comment": "Changed table names" }],

"ToDo": [""],
"Licence": ["tba"],
"Instructions for proper use": [""]
}'; 

-- Select description
SELECT obj_description('model_draft.ego_grid_lv_griddistrict'::regclass)::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','output','model_draft','ego_grid_lv_griddistrict','ego_dp_lv_griddistrict.sql',' ');
 */