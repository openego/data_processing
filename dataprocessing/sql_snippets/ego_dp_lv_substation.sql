/*
create mvlv substations (ONT) from lattice
Runtime 08:30 min

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "jong42, Ludee"
*/

-- lv lattice
DROP TABLE IF EXISTS	model_draft.ego_lattice_360m_lv;
CREATE TABLE 		model_draft.ego_lattice_360m_lv (
	id 		serial NOT NULL,
	la_id 		integer,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_lattice_360m_lv_pkey PRIMARY KEY (id) );

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_demand_loadarea','ego_dp_lv_substation.sql',' ');

-- lattice on the bbox of loadareas
INSERT INTO model_draft.ego_lattice_360m_lv (geom, la_id)
	SELECT 
		-- Normalfall: mehrere Zellen pro Grid
		CASE WHEN ST_AREA (geom) > (3.1415926535 * 1152) 
		THEN	ST_SETSRID(ST_CREATEFISHNET(
				ROUND((ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))) /360)::integer,
				ROUND((ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))) /360)::integer,
				360,
				360,
				ST_xmin (box2d(geom)),
				ST_ymin (box2d(geom))
			),3035)::geometry(POLYGON,3035)  
		-- Spezialfall: bei kleinene Lastgebieten erstelle nur eine Zelle
		ELSE	ST_SETSRID(ST_CREATEFISHNET(
				1,
				1,
				(ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))),
				(ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))),
				ST_xmin (box2d(geom)),
				ST_ymin (box2d(geom))
			),3035)::geometry(POLYGON,3035) 
		END 	AS geom, 
		id AS la_id
	FROM 	model_draft.ego_demand_loadarea;

-- index GIST (geom)
CREATE INDEX ego_lattice_360m_lv_geom_idx
	ON model_draft.ego_lattice_360m_lv USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_lattice_360m_lv OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_lattice_360m_lv','ego_dp_lv_substation.sql',' ');


-- MVLV Substation
DROP TABLE IF EXISTS	model_draft.ego_grid_mvlv_substation;
CREATE TABLE 		model_draft.ego_grid_mvlv_substation (
	mvlv_subst_id 	serial NOT NULL,
	la_id 		integer,
	subst_id 	integer,
	geom 		geometry(Point,3035),
	CONSTRAINT ego_grid_mvlv_substation_pkey PRIMARY KEY (mvlv_subst_id) );

-- index GIST (geom)
CREATE INDEX ego_grid_mvlv_substation_geom_idx
	ON model_draft.ego_grid_mvlv_substation USING GIST (geom);

-- Bestimme diejenigen Mittelpunkte der Grid-Polygone, die innerhalb der Lastgebiete liegen
-- centroids from lattice, when inside loadarea
INSERT INTO model_draft.ego_grid_mvlv_substation (la_id, geom)
	SELECT DISTINCT b.id AS la_id,
			ST_CENTROID (a.geom)::geometry(POINT,3035) AS geom
	FROM 	model_draft.ego_lattice_360m_lv AS a, 
		model_draft.ego_demand_loadarea AS b
	WHERE 	ST_WITHIN(ST_CENTROID(a.geom),b.geom) AND
		b.id = a.la_id;

-- Füge den Lastgebieten, die aufgrund ihrer geringen Fläche keine ONTs zugeordnet bekommen haben, ihren Mittelpunkt als ONT-STandort hinzu: (01:54 min)
-- 
INSERT INTO model_draft.ego_grid_mvlv_substation (geom, la_id)
	SELECT
	CASE WHEN	ST_CONTAINS (geom,ST_CENTROID(area_without_ont.geom))
	THEN		ST_CENTROID(area_without_ont.geom)
	ELSE		ST_POINTONSURFACE(area_without_ont.geom)
	END	, area_without_ont.id 
	FROM	(SELECT geom, id
		FROM model_draft.ego_demand_loadarea
		EXCEPT
		SELECT a.geom AS geom, a.id
		FROM 	model_draft.ego_demand_loadarea AS a, 
			model_draft.ego_grid_mvlv_substation AS b
		WHERE ST_CONTAINS (a.geom, b.geom)
		GROUP BY (a.id)
		) AS area_without_ont ;

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mvlv_substation OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_grid_mvlv_substation','ego_dp_lv_substation.sql',' ');


-- Lege Buffer um ONT-Standorte und ermittle die Teile der Lastgebiete, die sich nicht innerhalb dieser Buffer befinden
-- 
DROP TABLE IF EXISTS	model_draft.ego_grid_lv_loadarea_rest; 
CREATE TABLE 		model_draft.ego_grid_lv_loadarea_rest (
	id 		serial NOT NULL,
	la_id 		integer,
	geom_point	geometry(Point,3035),
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_grid_lv_loadarea_rest_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_lv_loadarea_rest OWNER TO oeuser;

-- insert rest
INSERT INTO model_draft.ego_grid_lv_loadarea_rest (la_id, geom)
	SELECT 	c.id AS la_id,
		(ST_DUMP(ST_DIFFERENCE(c.geom, area_with_onts.geom))).geom::geometry(Polygon,3035) AS geom
	FROM 	(SELECT ST_BUFFER(ST_UNION(a.geom),540) AS geom,b.id AS id
		FROM 	model_draft.ego_grid_mvlv_substation AS a, 
			model_draft.ego_demand_loadarea AS b
		WHERE 	b.geom && a.geom AND
			ST_CONTAINS(b.geom,a.geom) 
		GROUP BY b.id
		) AS area_with_onts
		INNER JOIN model_draft.ego_demand_loadarea AS c
			ON (c.id = area_with_onts.id)
	WHERE  ST_AREA(ST_DIFFERENCE(c.geom, area_with_onts.geom)) > 0 ;

-- index GIST (geom)
CREATE INDEX ego_grid_lv_loadarea_rest_geom_idx
	ON model_draft.ego_grid_lv_loadarea_rest USING GIST (geom);
	
-- index GIST (geom_point)
CREATE INDEX ego_grid_lv_loadarea_rest_geom_point_idx
	ON model_draft.ego_grid_lv_loadarea_rest USING GIST (geom_point);

-- PointOnSurface for rest
UPDATE	model_draft.ego_grid_lv_loadarea_rest
	SET 	geom_point = ST_PointOnSurface(geom) ::geometry(POINT,3035) ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_grid_lv_loadarea_rest','ego_dp_lv_substation.sql',' ');


-- Bestimme die Mittelpunkte der Gebiete, die noch nicht durch ONT abgedeckt sind, und lege diese Mittelpunkte als ONT-Standorte fest
-- 
INSERT INTO model_draft.ego_grid_mvlv_substation (la_id, geom)
	SELECT 	la_id,
		geom_point ::geometry(POINT,3035) 
	FROM 	model_draft.ego_grid_lv_loadarea_rest;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_grid_mv_griddistrict','ego_dp_lv_substation.sql',' ');

-- subst_id from MV-griddistrict
UPDATE 	model_draft.ego_grid_mvlv_substation AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	a.mvlv_subst_id AS mvlv_subst_id,
			b.subst_id AS subst_id
		FROM	model_draft.ego_grid_mvlv_substation AS a,
			model_draft.ego_grid_mv_griddistrict AS b
		WHERE  	b.geom && a.geom AND
			ST_CONTAINS(b.geom,a.geom)
		) AS t2
	WHERE  	t1.mvlv_subst_id = t2.mvlv_subst_id;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mvlv_substation IS '{
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
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!"} ],
	"contributors": [
		{"name": "jong42", "email": "",
		"date": "20.10.2016", "comment": "create table"},
		{"name": "jong42", "email": "",
		"date": "27.10.2016", "comment": "change table names"},
		{"name": "Ludee", "email": "",
		"date": "21.03.2017", "comment": "validate and restructure tables"},
		{"name": "Ludee", "email": "",
		"date": "22.03.2017", "comment": "update metadata (1.1) and add license"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "mvlv_subst_id", "description": "MVLV substation ID", "unit": "" },
				{"name": "la_id", "description": "loadarea ID", "unit": "" },
				{"name": "subst_id", "description": "HVMV substation ID", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.1" }] }';

-- select description
SELECT obj_description('model_draft.ego_grid_mvlv_substation' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_grid_mvlv_substation','ego_dp_lv_substation.sql',' ');


-- drop
--DROP TABLE IF EXISTS model_draft.ego_lattice_360m_lv;
--DROP TABLE IF EXISTS model_draft.ego_grid_lv_loadarea_rest;
