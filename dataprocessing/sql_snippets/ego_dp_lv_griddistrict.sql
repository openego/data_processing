/*
generate ONT
Runtime 08:30 min

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "jong42, Ludee"
*/


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
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_demand_loadarea','ego_dp_lv_griddistrict.sql',' ');
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_grid_mvlv_substation_voronoi','ego_dp_lv_griddistrict.sql',' ');

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

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_grid_mvlv_substation','ego_dp_lv_griddistrict.sql',' ');

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
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut','ego_dp_lv_griddistrict.sql',' ');


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
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_1subst_mview','ego_dp_lv_griddistrict.sql',' ');


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
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_0subst_mview','ego_dp_lv_griddistrict.sql',' ');




---------- ---------- ----------
-- Connect the cutted parts to the next substation
---------- ---------- ----------

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
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_0subst_nn_mview','process_eGo_grid_district.sql',' ');

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
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_0subst_nn_line_mview','process_eGo_grid_district.sql',' ');

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
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_0subst_nn_union_mview','process_eGo_grid_district.sql',' ');

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
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_nn_collect','process_eGo_grid_district.sql',' ');

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
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_grid_mvlv_substation_voronoi_cut_nn_mview','process_eGo_grid_district.sql',' ');






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
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_grid_lv_griddistrict','ego_dp_lv_substation.sql',' ');




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
				
				{"Name": "load_area_id",
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
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_grid_lv_griddistrict','ego_dp_lv_griddistrict.sql',' ');
 */