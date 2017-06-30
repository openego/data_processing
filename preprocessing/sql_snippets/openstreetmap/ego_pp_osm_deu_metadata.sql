/*
Metadata for OpenStreetMap tables

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- metadata
COMMENT ON TABLE openstreetmap.osm_deu_line IS '{
	"title": "OpenStreetMap (OSM) - Germany - Line",
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
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_line",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "gid", "description": "Unique identifier", "unit": "none" },
			{"name": "osm_id", "description": "OSM identifier", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "geom", "description": "Geometry", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

COMMENT ON TABLE openstreetmap.osm_deu_nodes IS '{
	"title": "OpenStreetMap (OSM) - Germany - Nodes",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "none"},
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
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_nodes",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "id", "description": "Unique identifier", "unit": "none" },
			{"name": "lat", "description": "Latitude", "unit": "none" },
			{"name": "lon", "description": "Longitutde", "unit": "none" },
			{"name": "tags", "description": "Tags", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

COMMENT ON TABLE openstreetmap.osm_deu_point IS '{
	"title": "OpenStreetMap (OSM) - Germany - Point",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "none"},
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
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_point",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "gid", "description": "Unique identifier", "unit": "none" },
			{"name": "osm_id", "description": "OSM identifier", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "geom", "description": "Geometry", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

COMMENT ON TABLE openstreetmap.osm_deu_polygon IS '{
	"title": "OpenStreetMap (OSM) - Germany - Polygon",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "none"},
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
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_polygon",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "gid", "description": "Unique identifier", "unit": "none" },
			{"name": "osm_id", "description": "OSM identifier", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "geom", "description": "Geometry", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

COMMENT ON TABLE openstreetmap.osm_deu_rels IS '{
	"title": "OpenStreetMap (OSM) - Germany - Rels",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "none"},
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
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_rels",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "id", "description": "Unique identifier", "unit": "none" },
			{"name": "way_off", "description": "", "unit": "none" },
			{"name": "rel_off", "description": "", "unit": "none" },
			{"name": "parts", "description": "", "unit": "none" },
			{"name": "members", "description": "", "unit": "none" },
			{"name": "tags", "description": "", "unit": "none" },
			{"name": "pending", "description": "", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

COMMENT ON TABLE openstreetmap.osm_deu_roads IS '{
	"title": "OpenStreetMap (OSM) - Germany - Roads",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "none"},
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
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_roads",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "gid", "description": "Unique identifier", "unit": "none" },
			{"name": "osm_id", "description": "OSM identifier", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "geom", "description": "Geometry", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

COMMENT ON TABLE openstreetmap.osm_deu_ways IS '{
	"title": "OpenStreetMap (OSM) - Germany - Ways",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "none"},
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
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_ways",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "id", "description": "Unique identifier", "unit": "none" },
			{"name": "nodes", "description": "", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "pending", "description": "", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_line','ego_pp_osm_deu_metadata.sql','metadata');
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_nodes','ego_pp_osm_deu_metadata.sql','metadata');
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_point','ego_pp_osm_deu_metadata.sql','metadata');
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_polygon','ego_pp_osm_deu_metadata.sql','metadata');
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_rels','ego_pp_osm_deu_metadata.sql','metadata');
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_roads','ego_pp_osm_deu_metadata.sql','metadata');
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_ways','ego_pp_osm_deu_metadata.sql','metadata');
