﻿CREATE MATERIALIZED VIEW openstreetmap.osm_deu_polygon_building_mview

AS

SELECT gid,ST_TRANSFORM(geom,3035) AS geom,building FROM openstreetmap.osm_deu_polygon
WHERE building IS NOT NULL;

ALTER TABLE openstreetmap.osm_deu_polygon_building_mview
  OWNER TO oeuser;
GRANT ALL ON TABLE openstreetmap.osm_deu_polygon_building_mview TO oeuser WITH GRANT OPTION;

CREATE INDEX osm_deu_polygon_building_mview_geom_idx
  ON openstreetmap.osm_deu_polygon_building_mview
  USING gist
  (geom);

COMMENT ON MATERIALIZED VIEW openstreetmap.osm_deu_polygon_building_mview
  IS '{
        "Name": "osm_deu_polygon_building_mview",

	"Source": [{
                  "Name": "Geofabrik - Download - OpenStreetMap Data Extracts",
                  "URL":  "http://download.geofabrik.de/europe/germany.html#" }],

	"Reference date": ["01.10.2016"],

	"Date of collection": ["10.10.2016"],

	"Original file": ["germany-161001.osm.pbf"],

	"Spatial resolution": ["Germany"],

	"Description": ["OSM Datensatz Deutschland - nur Gebäudepolygone"],

	"Column":[ 
	
	{"name":"gid",
	"description":"unique identifier",
	"unit":" " },

	{"name":"geom",
	"description":"geometry information , SRID 3035",
	"unit":" " }


	],

	"Changes":[
	  { "name":"Martin Glauer", 
	    "mail":" ", 
	    "date":"10.10.2016", 
	    "comment":"Created table with osm2pgsql"},

	   { "name":"Ludwig Hülk", 
	    "mail":"ludwig.huelk@rl-institut.de", 
	    "date":"11.10.2016", 
	    "comment":"Executed setup"},
	    
	   { "name":"Jonas Gütter", 
	    "mail":"jonas.guetterk@rl-institut.de", 
	    "date":"16.10.2016", 
	    "comment":"filtered buildings"}  ],

	
	"Licence": ["Open Data Commons Open Database Lizenz (ODbL)"],

	"Instructions for proper use": ["Wir verlangen die Verwendung des Hinweises OpenStreetMap-Mitwirkende. Du musst auch klarstellen, dass die Daten unter der Open-Database-Lizenz verfügbar sind, und, sofern du unsere Kartenkacheln verwendest, dass die Kartografie gemäß CC BY-SA lizenziert ist. Du kannst dies tun, indem du auf www.openstreetmap.org/copyright verlinkst. Ersatzweise, und als Erfordernis, falls du OSM in Datenform weitergibst, kannst du die Lizenz(en) direkt verlinken und benennen. In Medien, in denen keine Links möglich sind (z.B. gedruckten Werken), empfehlen wir dir, deine Leser direkt auf openstreetmap.org zu verweisen (möglicherweise mit dem Erweitern von OpenStreetMap zur vollen Adresse), auf opendatacommons.org, und, sofern zutreffend, auf creativecommons.org. Der Hinweis sollte für eine durchsuchbare elektronische Karte in der Ecke der Karte stehen."]
	}';


SELECT obj_description('openstreetmap.osm_deu_polygon_building_mview' ::regclass) ::json;

 -- Add entry to scenario logtable
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'openstreetmap' AS schema_name,
	'osm_deu_polygon_building_mview' AS table_name,
	'osm_deu_polygon_building_mview.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('openstreetmap.osm_deu_polygon_building_mview' ::regclass) ::json AS metadata
FROM	openstreetmap.osm_deu_polygon_building_mview;