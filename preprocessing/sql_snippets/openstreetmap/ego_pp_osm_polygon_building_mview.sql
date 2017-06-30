/*
Extracted OSM buildings from polygon

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','openstreetmap','osm_deu_polygon','ego_pp_osm_polygon_building_mview.sql','');

-- building
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_building_mview;
CREATE MATERIALIZED VIEW 		openstreetmap.osm_deu_polygon_building_mview AS
	SELECT 	gid,
		osm_id,
		building,
		tags,
		ST_TRANSFORM(geom,3035) AS geom
	FROM 	openstreetmap.osm_deu_polygon
	WHERE 	building IS NOT NULL;

-- grant (oeuser)
ALTER TABLE openstreetmap.osm_deu_polygon_building_mview OWNER TO oeuser;

-- index
CREATE UNIQUE INDEX osm_deu_polygon_building_mview_gid_idx
	ON openstreetmap.osm_deu_polygon_building_mview (gid);

-- index GIST (geom)
CREATE INDEX osm_deu_polygon_building_mview_geom_idx
	ON openstreetmap.osm_deu_polygon_building_mview USING GIST (geom);


-- metadata
COMMENT ON MATERIALIZED VIEW openstreetmap.osm_deu_polygon_building_mview IS '{
	"title": "OpenStreetMap (OSM) - Germany - Polygon - Building",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "vector"},
	"temporal": 
		{"reference_date": "2016-10-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Geofabrik - Download - OpenStreetMap Data Extracts",
		"description": "",
		"url": "http://download.geofabrik.de/europe/germany.html",
		"license": "Open Data Commons Open Database License 1.0 (ODbL-1.0)",
		"copyright": "© OpenStreetMap contributors"} ],
	"license": 
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "http://www.openstreetmap.org/copyright/en",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© OpenStreetMap contributors"},
	"contributors": [
		{"name": "Martin Glauer", "email": "", "date": "2016-10-10", "comment": "Create table with osm2pgsql"},
		{"name": "Ludee", "email": "", "date": "2016-10-11", "comment": "Execute setup"},
		{"name": "Jonas Gütter", "email":"", "date": "2016-11-08", "comment": "Filter buildings"},
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_polygon_building_mview",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "gid", "description": "Unique identifier", "unit": "none" },
			{"name": "osm_id", "description": "OSM identifier", "unit": "none" },
			{"name": "building", "description": "Building key", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "geom", "description": "Geometry", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','openstreetmap','osm_deu_polygon_building_mview','ego_pp_osm_polygon_building_mview.sql','');
