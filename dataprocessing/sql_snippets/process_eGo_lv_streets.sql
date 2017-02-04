/*
Extract OSM streets

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "jong42, Ludee"
*/

DROP TABLE IF EXISTS model_draft.ego_grid_lv_streets;

CREATE TABLE model_draft.ego_grid_lv_streets

AS

SELECT osm.gid AS line_gid,ST_Safe_Intersection (ST_TRANSFORM(osm.geom,3035),larea.geom)::geometry(LineString,3035) AS geom, larea.id AS load_area_id , numbers.ontnumber AS ontnumber
		FROM openstreetmap.osm_deu_line AS osm, 
		     calc_ego_loads.ego_deu_load_area AS larea,
		     (SELECT COUNT(pts.geom) AS ontnumber,area.id AS load_area_id FROM calc_ego_substation.ego_deu_onts AS pts,calc_ego_loads.ego_deu_load_area AS area
				WHERE ST_INTERSECTS (pts.geom,area.geom) GROUP BY area.id
		     )AS numbers 
		WHERE (osm."highway" = 'motorway' OR osm."highway" = 'trunk' OR osm."highway" = 'primary' OR osm."highway" = 'secondary' OR  osm."highway" = 'tertiary' 
			OR  osm."highway" = 'unclassified' OR osm."highway" = 'residential' OR osm."highway" = 'service' OR osm."highway" = 'living_street' 
			OR  osm."highway" = 'pedestrian' OR osm."highway" = 'bus_guideway' OR osm."highway" = 'road' OR osm."highway" = 'footway')
			AND numbers.load_area_id = larea.id
			AND  ST_INTERSECTS(ST_TRANSFORM(osm.geom,3035),larea.geom)
			AND ST_GEOMETRYTYPE (ST_Safe_Intersection (ST_TRANSFORM(osm.geom,3035),larea.geom)) = 'ST_LineString'
			 
;

ALTER TABLE model_draft.ego_grid_lv_streets
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_lv_streets TO oeuser WITH GRANT OPTION;


CREATE INDEX ego_grid_lv_streets_geom_idx
  ON model_draft.ego_grid_lv_streets
  USING gist
  (geom);

-- Create ID column
ALTER TABLE model_draft.ego_grid_lv_streets
ADD COLUMN id serial;

ALTER TABLE model_draft.ego_grid_lv_streets
ADD CONSTRAINT ego_grid_lv_streets_pkey PRIMARY KEY (id);

--
CREATE UNIQUE INDEX   ego_grid_lv_streets_id_idx
        ON    model_draft.ego_grid_lv_streets (id);


COMMENT ON TABLE model_draft.ego_grid_lv_streets
  IS '{
        "Name": ".ego_grid_lv_streets",

	"Source": [{
                  "Name": "Geofabrik - Download - OpenStreetMap Data Extracts",
                  "URL":  "http://download.geofabrik.de/europe/germany.html#" }],

	"Reference date": ["01.10.2016"],

	"Date of collection": ["10.10.2016"],

	"Original file": ["germany-161001.osm.pbf"],

	"Spatial resolution": ["Germany"],

	"Description": ["Straßen aus OSM in den Niederspannungs-Netzbezirken"],

	"Column":[ 

	{"name":"id",
	"description":"unique identifier",
	"unit":" " },
	{"name":"geom",
	"description":"geometry",
	"description_german":"Geometrie",
	"unit":" " },
	{"name":"line_gid",
	"description":"gid of the corresponding osm line row",
	"unit":" " },
	{"name":"load_area_id",
	"description":"id of the corresponding load area",
	"unit":" " },
	{"name:""ontnumber",
	"description": "number of onts to be modelled in the corresponding load area"
	"unit:"ont"}

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
	    "comment":"filtered streets"},

	   { "name":"Jonas Gütter", 
	    "mail":" ", 
	    "date":"21.11.2016", 
	    "comment":"cut load_areas"},

	   { "name":"Jonas Gütter", 
	    "mail":" ", 
	    "date":"21.11.2016", 
	    "comment":"changed names"},

	   { "name":"Jonas Gütter", 
	    "mail":" ", 
	    "date":"21.11.2016", 
	    "comment":"added ontnumber"}		],

	

	"Licence": ["Open Data Commons Open Database Lizenz (ODbL)"],

	"Instructions for proper use": ["Wir verlangen die Verwendung des Hinweises OpenStreetMap-Mitwirkende. Du musst auch klarstellen, dass die Daten unter der Open-Database-Lizenz verfügbar sind, und, sofern du unsere Kartenkacheln verwendest, dass die Kartografie gemäß CC BY-SA lizenziert ist. Du kannst dies tun, indem du auf www.openstreetmap.org/copyright verlinkst. Ersatzweise, und als Erfordernis, falls du OSM in Datenform weitergibst, kannst du die Lizenz(en) direkt verlinken und benennen. In Medien, in denen keine Links möglich sind (z.B. gedruckten Werken), empfehlen wir dir, deine Leser direkt auf openstreetmap.org zu verweisen (möglicherweise mit dem Erweitern von OpenStreetMap zur vollen Adresse), auf opendatacommons.org, und, sofern zutreffend, auf creativecommons.org. Der Hinweis sollte für eine durchsuchbare elektronische Karte in der Ecke der Karte stehen."]
	}';


 -- Add entry to scenario logtable
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_grid_lv_streets' AS table_name,
	'process_eGo_lv_streets.sql' AS script_name,
	COUNT(*)AS entries,
	'in progress' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_grid_lv_streets' ::regclass) ::json AS metadata
FROM	model_draft.ego_grid_lv_streets;	
