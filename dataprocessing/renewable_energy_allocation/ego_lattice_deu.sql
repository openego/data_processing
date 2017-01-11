/*
lattice (regular point grid)
lattice on bbox of Germany with 500m
lattice on bbox of loadarea with 50m

__copyright__ = "tba"
__license__ = "tba"
__author__ = "Ludee"
*/

-- lattice on bbox of Germany with 500m
DROP TABLE IF EXISTS  	model_draft.ego_lattice_deu_500m CASCADE;
CREATE TABLE         	model_draft.ego_lattice_deu_500m (
		id SERIAL NOT NULL,
		subst_id integer,
		area_type text,
		geom geometry(Polygon,3035),
CONSTRAINT 	ego_lattice_deu_500m_pkey PRIMARY KEY (id));

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','input','political_boundary','bkg_vg250_1_sta_union_mview','ego_lattice_deu.sql',' ');

-- insert lattice
INSERT INTO     model_draft.ego_lattice_deu_500m (geom)
	SELECT 	ST_SETSRID(ST_CreateFishnet(
			ROUND((ST_ymax(box2d(box.geom)) - ST_ymin(box2d(box.geom))) /500)::integer,
			ROUND((ST_xmax(box2d(box.geom)) - ST_xmin(box2d(box.geom))) /500)::integer,
			500,
			500,
			ST_xmin (box2d(box.geom)),
			ST_ymin (box2d(box.geom))
		),3035)::geometry(POLYGON,3035) AS geom
	FROM political_boundary.bkg_vg250_1_sta_union_mview AS box ;

-- index gist (geom)
CREATE INDEX 	ego_lattice_deu_500m_geom_idx
	ON 	model_draft.ego_lattice_deu_500m USING gist (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_lattice_deu_500m OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_lattice_deu_500m IS '{
	"title": "eGoDP - lattice on bbox of Germany with 500m",
	"description": "lattice (regular point grid)",
	"language": [ "eng" ],
	"reference_date": "",
	"sources": [
		{"name": "bkg_vg250_1_sta_union_mview","description": "","url": ""} ],
	"spatial": [
		{"extend": "Germany",
		"resolution": "500m"} ],
	"license": [
		{"id": "tba",
		"name": "tba",
		"version": "tba",
		"url": "tba",
		"instruction": "tba"} ],
	"contributors": [
		{"name": "Ludwig Hülk",	"email": "ludwig.huelk@rl-institut.de",
		"date": "01.10.2016", "comment": "create table"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "12.10.2016", "comment": "create metadata"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "25.12.2016", "comment": "update to v0.2"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "id", "description": "unique identifier", "unit": "" },
				{"name": "subst_id", "description": "hvmv-substation", "unit": "" },
				{"name": "area_type", "description": "type of area (wpa, la, x)", "unit": "" },
				{"name": "geom", "description": "Geometry", "unit": "" }]},
		"meta_version": "1.0"}] }';

-- select description
SELECT obj_description('model_draft.ego_lattice_deu_500m' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_lattice_deu_500m','ego_lattice_deu.sql',' ');


-- lattice on bbox of loadarea with 50m
DROP TABLE IF EXISTS  	model_draft.ego_lattice_la_50m CASCADE;
CREATE TABLE         	model_draft.ego_lattice_la_50m (
		id SERIAL NOT NULL,
		subst_id integer,
		area_type text,
		geom geometry(Polygon,3035),
CONSTRAINT 	ego_lattice_la_50m_pkey PRIMARY KEY (id));

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','input','model_draft','ego_demand_loadarea','ego_lattice_deu.sql',' ');

-- insert lattice
INSERT INTO     model_draft.ego_lattice_la_50m (geom)
	SELECT 	ST_SETSRID(ST_CREATEFISHNET(
			ROUND((ST_ymax(box2d(geom)) - ST_ymin(box2d(geom))) /50)::integer,
			ROUND((ST_xmax(box2d(geom)) - ST_xmin(box2d(geom))) /50)::integer,
			50,
			50,
			ST_xmin (box2d(geom)),
			ST_ymin (box2d(geom))
		),3035)::geometry(POLYGON,3035) AS geom
	FROM model_draft.ego_demand_loadarea;

-- index gist (geom)
CREATE INDEX 	ego_lattice_la_50m_geom_idx
	ON 	model_draft.ego_lattice_la_50m USING gist (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_lattice_la_50m OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_lattice_la_50m IS '{
	"title": "eGoDP - lattice on loadarea with 50m",
	"description": "lattice (regular point grid)",
	"language": [ "eng" ],
	"reference_date": "",
	"sources": [
		{"name": "bkg_vg250_1_sta_union_mview","description": "","url": ""},
		{"name": "model_draft.ego_demand_loadarea","description": "","url": ""} ],
	"spatial": [
		{"extend": "Germany",
		"resolution": "50m"} ],
	"license": [
		{"id": "tba",
		"name": "tba",
		"version": "tba",
		"url": "tba",
		"instruction": "tba"} ],
	"contributors": [
		{"name": "Ludwig Hülk",	"email": "ludwig.huelk@rl-institut.de",
		"date": "01.10.2016", "comment": "create table"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "12.10.2016", "comment": "create metadata"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "25.12.2016", "comment": "update to v0.2"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "id", "description": "unique identifier", "unit": "" },
				{"name": "subst_id", "description": "hvmv-substation", "unit": "" },
				{"name": "area_type", "description": "type of area (wpa, la, x)", "unit": "" },
				{"name": "geom", "description": "Geometry", "unit": "" }]},
		"meta_version": "1.0"}] }';

-- select description
SELECT obj_description('model_draft.ego_lattice_la_50m' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_lattice_la_50m','ego_lattice_deu.sql',' ');
