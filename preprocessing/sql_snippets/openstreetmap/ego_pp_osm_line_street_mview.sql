/*
Extracted OSM streets from line

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "jong42, Ludee"
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','openstreetmap','osm_deu_line','ego_pp_osm_line_street_mview.sql','');

-- street
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_line_street_mview;
CREATE MATERIALIZED VIEW 		openstreetmap.osm_deu_line_street_mview AS
	SELECT	* 
	FROM	openstreetmap.osm_deu_line AS osm
	WHERE 	osm."highway" = 'motorway' 
		OR osm."highway" = 'trunk' 
		OR osm."highway" = 'primary' 
		OR osm."highway" = 'secondary' 
		OR  osm."highway" = 'tertiary' 
		OR  osm."highway" = 'unclassified' 
		OR osm."highway" = 'residential' 
		OR osm."highway" = 'service' 
		OR osm."highway" = 'living_street' 
		OR  osm."highway" = 'pedestrian' 
		OR osm."highway" = 'bus_guideway' 
		OR osm."highway" = 'road' 
		OR osm."highway" = 'footway' ;

-- grant (oeuser)
ALTER TABLE openstreetmap.osm_deu_line_street_mview OWNER TO oeuser;

-- index
CREATE UNIQUE INDEX osm_deu_line_street_mview_gid_idx
	ON openstreetmap.osm_deu_line_street_mview (gid);

-- index GIST (geom)
CREATE INDEX osm_deu_line_street_mview_geom_idx
	ON openstreetmap.osm_deu_line_street_mview USING GIST (geom);

-- metadata
COMMENT ON MATERIALIZED VIEW openstreetmap.osm_deu_line_street_mview IS '{
	"title": "OpenStreetMap (OSM) - Germany - Line - Street",
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
		{"name": "Jonas Gütter", "email":"", "date": "2016-11-08", "comment": "Filter streets"},
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to v1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_line_street_mview",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "gid", "description": "Unique identifier", "unit": "none" },
			{"name": "osm_id", "description": "OSM identifier", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "geom", "description": "Geometry", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','openstreetmap','osm_deu_line_street_mview','ego_pp_osm_line_street_mview.sql','Streets');
