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
		--AND a.subst_id = '1886'; -- test one mvgd

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
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_grid_lv_griddistrict_cut','ego_dp_lv_griddistrict.sql',' ');


/* -- Validate (geom)
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
	id 	integer,
	la_id 		integer,
	subst_id 	integer,
	subst_cnt	integer,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_grid_lv_griddistrict_cut_1subst_pkey PRIMARY KEY (id) );

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
	"version": "v0.3.0" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_grid_lv_griddistrict_cut_1subst','ego_dp_lv_griddistrict.sql',' ');



-- fragments
DROP TABLE IF EXISTS	model_draft.ego_grid_lv_griddistrict_cut_0subst CASCADE;
CREATE TABLE         	model_draft.ego_grid_lv_griddistrict_cut_0subst (
	id 	integer,
	la_id 		integer,
	subst_id 	integer,
	subst_cnt	integer,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_grid_lv_griddistrict_cut_0subst_pkey PRIMARY KEY (id) );

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
	"version": "v0.3.0" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_grid_lv_griddistrict_cut_0subst','ego_dp_lv_griddistrict.sql',' ');



-- with too many substation!
DROP TABLE IF EXISTS	model_draft.ego_grid_lv_griddistrict_cut_xsubst CASCADE;
CREATE TABLE         	model_draft.ego_grid_lv_griddistrict_cut_xsubst (
	id 	integer,
	la_id 		integer,
	subst_id 	integer,
	subst_cnt	integer,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_grid_lv_griddistrict_cut_xsubst_pkey PRIMARY KEY (id) );

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
	"version": "v0.3.0" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_grid_lv_griddistrict_cut_xsubst','ego_dp_lv_griddistrict.sql',' ');



-- Next Neighbor
DROP TABLE IF EXISTS	model_draft.ego_grid_lv_griddistrict_cut_nn CASCADE;
CREATE TABLE         	model_draft.ego_grid_lv_griddistrict_cut_nn (
	id	 	serial,
	a_id 		integer,
	b_id 		integer,
	subst_id	integer,
	la_id 		integer,
	geom		geometry(Polygon,3035),
	geom_line	geometry(LineString,3035),
	distance	double precision,
	CONSTRAINT ego_grid_lv_griddistrict_cut_nn_pkey PRIMARY KEY (id) );

INSERT INTO model_draft.ego_grid_lv_griddistrict_cut_nn (a_id,b_id,subst_id,la_id,geom,geom_line,distance)
	SELECT DISTINCT ON (a.id)
		a.id,
		b.id,
		a.subst_id,
		a.la_id,
		a.geom,
		ST_ShortestLine(
			ST_CENTROID(a.geom) ::geometry(Point,3035),
			ST_ExteriorRing(b.geom) ::geometry(LineString,3035)
			) ::geometry(LineString,3035) AS geom_line,
		ST_Distance(ST_CENTROID(a.geom),ST_ExteriorRing(b.geom))
	FROM 	model_draft.ego_grid_lv_griddistrict_cut_0subst AS a,		-- fragments
		model_draft.ego_grid_lv_griddistrict_cut_1subst AS b		-- target
	WHERE 	ST_DWithin(ST_CENTROID(a.geom),ST_ExteriorRing(b.geom), 1000) 	-- In a 1 km radius
		AND a.subst_id = b.subst_id
	ORDER BY a.id, ST_Distance(ST_CENTROID(a.geom),ST_ExteriorRing(b.geom));

-- index GIST (geom)
CREATE INDEX  	ego_grid_lv_griddistrict_cut_nn_ageom_idx
	ON	model_draft.ego_grid_lv_griddistrict_cut_nn USING GIST (geom);

-- index GIST (geom)
CREATE INDEX  	ego_grid_lv_griddistrict_cut_nn_geom_line_idx
	ON	model_draft.ego_grid_lv_griddistrict_cut_nn USING GIST (geom_line);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_lv_griddistrict_cut_nn OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_lv_griddistrict_cut_nn IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.3.0" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_grid_lv_griddistrict_cut_nn','ego_dp_lv_griddistrict.sql',' ');



-- collect and union
DROP TABLE IF EXISTS	model_draft.ego_grid_lv_griddistrict_cut_nn_collect CASCADE;
CREATE TABLE         	model_draft.ego_grid_lv_griddistrict_cut_nn_collect (
	id		integer,
	mvlv_subst_id	integer,
	subst_id	integer,
	la_id 		integer,
	nn		boolean,
	geom		geometry(MultiPolygon,3035),
	CONSTRAINT ego_grid_lv_griddistrict_cut_nn_collect_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_lv_griddistrict_cut_nn_collect OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX	ego_grid_lv_griddistrict_cut_nn_collect_geom_idx
	ON	model_draft.ego_grid_lv_griddistrict_cut_nn_collect USING GIST (geom);

-- insert
INSERT INTO	model_draft.ego_grid_lv_griddistrict_cut_nn_collect (id,subst_id,la_id,nn,geom)
	SELECT	id,
		subst_id,
		la_id,
		FALSE,
		ST_MULTI(geom)
	FROM	model_draft.ego_grid_lv_griddistrict_cut_1subst
	ORDER BY id;

-- insert union
WITH collect AS (
	SELECT	a.id,a.geom
	FROM	(
		SELECT	b_id AS id,geom
		FROM	model_draft.ego_grid_lv_griddistrict_cut_nn
		UNION ALL
		SELECT	id,geom
		FROM	model_draft.ego_grid_lv_griddistrict_cut_1subst) AS a
	ORDER BY id )
UPDATE 	model_draft.ego_grid_lv_griddistrict_cut_nn_collect AS t1
	SET  	geom = t2.geom,
		nn = TRUE
	FROM	(SELECT	id,
			ST_MULTI(ST_UNION(geom)) AS geom
		FROM	collect
		GROUP BY id
		) AS t2
	WHERE  	t1.id = t2.id;

-- mvlv substation id
UPDATE 	model_draft.ego_grid_lv_griddistrict_cut_nn_collect AS t1
	SET  	mvlv_subst_id = t2.mvlv_subst_id
	FROM    (
		SELECT	a.id AS id,
			b.mvlv_subst_id AS mvlv_subst_id
		FROM	model_draft.ego_grid_lv_griddistrict_cut_nn_collect AS a,
			model_draft.ego_grid_mvlv_substation AS b
		WHERE  	a.geom && b.geom AND
			ST_CONTAINS(a.geom,b.geom)
		) AS t2
	WHERE  	t1.id = t2.id;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_lv_griddistrict_cut_nn_collect IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.3.0" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_grid_lv_griddistrict_cut_nn_collect','ego_dp_lv_griddistrict.sql',' ');
