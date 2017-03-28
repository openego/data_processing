/*
lattice (regular point grid) with 500m
lattice on bbox of Germany

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

-- table for lattice 500m
DROP TABLE IF EXISTS  	model_draft.ego_lattice_500m CASCADE;
CREATE TABLE         	model_draft.ego_lattice_500m (
		id SERIAL NOT NULL,
		subst_id integer,
		area_type text,
		geom_box geometry(Polygon,3035),
		geom geometry(Point,3035),
CONSTRAINT 	ego_lattice_500m_pkey PRIMARY KEY (id));

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','political_boundary','bkg_vg250_1_sta_union_mview','ego_dp_lattice_500m.sql',' ');

-- lattice on bbox of Germany with 500m
INSERT INTO     model_draft.ego_lattice_500m (geom_box)
	SELECT 	ST_SETSRID(ST_CreateFishnet(
			ROUND((ST_ymax(box2d(box.geom)) - ST_ymin(box2d(box.geom))) /500)::integer,
			ROUND((ST_xmax(box2d(box.geom)) - ST_xmin(box2d(box.geom))) /500)::integer,
			500,
			500,
			ST_xmin (box2d(box.geom)),
			ST_ymin (box2d(box.geom))
		),3035)::geometry(POLYGON,3035) AS geom
	FROM political_boundary.bkg_vg250_1_sta_union_mview AS box ;

-- index gist (geom_box)
CREATE INDEX 	ego_lattice_500m_geom_box_idx
	ON 	model_draft.ego_lattice_500m USING gist (geom_box);

-- centroid
UPDATE 	model_draft.ego_lattice_500m
	SET	geom = ST_CENTROID(geom_box);

-- index gist (geom)
CREATE INDEX 	ego_lattice_500m_geom_idx
	ON 	model_draft.ego_lattice_500m USING gist (geom);	

-- grant (oeuser)
ALTER TABLE	model_draft.ego_lattice_500m OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_lattice_500m IS '{
	"title": "eGoDP - lattice on bbox of Germany with 500m",
	"description": "lattice (regular point grid)",
	"language": [ "eng" ],
	"reference_date": "",
	"sources": [
		{"name": "political_boundary.bkg_vg250_1_sta_union_mview","description": "","url": ""} ],
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
		"date": "25.12.2016", "comment": "update to v0.2"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "10.01.2016", "comment": "update centroid"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "id", "description": "unique identifier", "unit": "" },
				{"name": "subst_id", "description": "hvmv-substation", "unit": "" },
				{"name": "area_type", "description": "type of area (wpa, la, x)", "unit": "" },
				{"name": "geom_box", "description": "Geometry polygon", "unit": "" },
				{"name": "geom", "description": "Geometry point", "unit": "" } ]},
		"meta_version": "1.0"}] }';

-- select description
SELECT obj_description('model_draft.ego_lattice_500m' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_lattice_500m','ego_dp_lattice_500m.sql',' ');
