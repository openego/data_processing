﻿-- 00:41 min

CREATE MATERIALIZED VIEW openstreetmap.osm_deu_line_street_mview

AS

SELECT * FROM openstreetmap.osm_deu_line 
		WHERE "highway" = 'motorway' OR "highway" = 'trunk' OR "highway" = 'primary' OR "highway" = 'secondary' OR  "highway" = 'tertiary' 
			OR  "highway" = 'unclassified' OR "highway" = 'residential' OR "highway" = 'service' OR "highway" = 'living_street' 
			OR  "highway" = 'pedestrian' OR "highway" = 'bus_guideway' OR "highway" = 'road' OR "highway" = 'footway'
	
;

ALTER TABLE openstreetmap.osm_deu_line_street_mview
  OWNER TO oeuser;
GRANT ALL ON TABLE openstreetmap.osm_deu_line_street_mview TO oeuser WITH GRANT OPTION;


CREATE INDEX osm_deu_line_street_mview_geom_idx
  ON openstreetmap.osm_deu_line_street_mview
  USING gist
  (geom);


COMMENT ON MATERIALIZED VIEW openstreetmap.osm_deu_line_street_mview
  IS '{
        "Name": "OpenStreetMap - Germany",

	"Source": [{
                  "Name": "Geofabrik - Download - OpenStreetMap Data Extracts",
                  "URL":  "http://download.geofabrik.de/europe/germany.html#" }],

	"Reference date": ["01.10.2016"],

	"Date of collection": ["10.10.2016"],

	"Original file": ["germany-161001.osm.pbf"],

	"Spatial resolution": ["Germany"],

	"Description": ["OSM Datensatz Deutschland, gefiltert nach Straßen"],

	"Column":[ 
	
	{"name":"osm_id",
	"description":"OSM ID",
	"description_german":"OSM ID",
	"unit":" " },

	{"name":"oedb.style",
	"description":"Keys defined in this file",
	"description_german":"Alle keys in diesem Dokument dokumentiert",
	"unit":" "}
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
	    "mail":" ", 
	    "date":"08.11.2016", 
	    "comment":"filtered streets"},		],

	

	"Licence": ["Open Data Commons Open Database Lizenz (ODbL)"],

	"Instructions for proper use": ["Wir verlangen die Verwendung des Hinweises OpenStreetMap-Mitwirkende. Du musst auch klarstellen, dass die Daten unter der Open-Database-Lizenz verfügbar sind, und, sofern du unsere Kartenkacheln verwendest, dass die Kartografie gemäß CC BY-SA lizenziert ist. Du kannst dies tun, indem du auf www.openstreetmap.org/copyright verlinkst. Ersatzweise, und als Erfordernis, falls du OSM in Datenform weitergibst, kannst du die Lizenz(en) direkt verlinken und benennen. In Medien, in denen keine Links möglich sind (z.B. gedruckten Werken), empfehlen wir dir, deine Leser direkt auf openstreetmap.org zu verweisen (möglicherweise mit dem Erweitern von OpenStreetMap zur vollen Adresse), auf opendatacommons.org, und, sofern zutreffend, auf creativecommons.org. Der Hinweis sollte für eine durchsuchbare elektronische Karte in der Ecke der Karte stehen."]
	}';


 -- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.2' AS version,
	'openstreetmap' AS schema_name,
	'osm_deu_line_street_mview' AS table_name,
	'osm_deu_line_street_mview.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	openstreetmap.osm_deu_line_street_mview;	