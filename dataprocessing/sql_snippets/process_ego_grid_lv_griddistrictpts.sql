--DROP TABLE IF EXISTS model_draft.ego_grid_lv_griddistrictpts;

CREATE TABLE model_draft.ego_grid_lv_griddistrictpts

(
  id serial NOT NULL,
  geom geometry (Point,3035),
  textgeom text,
  ont integer,
  ont_distance integer,
  CONSTRAINT ego_grid_lv_griddistrictpts_pkey PRIMARY KEY (id)
);

ALTER TABLE model_draft.ego_grid_lv_griddistrictpts
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_lv_griddistrictpts TO oeuser;

-- Data has to be inserted via python script lv_grid_districts.py

UPDATE model_draft.ego_grid_lv_griddistrictpts
SET geom = ST_SetSRID (ST_GeomFromText (textgeom),3035);

CREATE INDEX ego_grid_lv_griddistrictpts_geom_idx
  ON model_draft.ego_grid_lv_griddistrictpts
  USING gist
  (geom);

COMMENT ON TABLE model_draft.ego_grid_lv_griddistrictpts
  IS '{
        "Name": "ego_grid_lv_griddistrictpts",

	"Source": [{
                  "Name": "Geofabrik - Download - OpenStreetMap Data Extracts",
                  "URL":  "http://download.geofabrik.de/europe/germany.html#" }],

	"Reference date": ["01.10.2016"],

	"Date of collection": ["10.10.2016"],

	"Original file": ["germany-161001.osm.pbf"],

	"Spatial resolution": ["Germany"],

	"Description": ["Start- und Endpunkte der Kanten der Straßen aus OSM in den Niederspannungs-Netzbezirken"],

	"Column":[ 

	{"name":"id",
	"description":"unique identifier",
	"unit":" " },
	{"name":"geom",
	"description":"geometry",
	"unit":" " },
	{"name":"textgeom",
	"description":"geometry in wkt-format",
	"unit":" " },
	{"name":"ont",
	"description":"points with the same value (within a lv load area) in this field are supplied by the same ont",
	"description_german":"Punkte mit dem selben Wert in diesem Feld (innerhalb eines NS-Lastgebiets) werden vom gleichen ONT versorgt",
	"unit":" " },
	{"name":"ont_distance",
	"description":"distance on streets to the nearest ont",
	"unit":"meter " }

	],

	"Changes":[
	   { "name":"Jonas Gütter", 
	    "mail":" ", 
	    "date":"09.12.2016", 
	    "comment":"Created Table"}		],

	

	"Licence": ["Open Data Commons Open Database Lizenz (ODbL)"],

	"Instructions for proper use": ["Wir verlangen die Verwendung des Hinweises OpenStreetMap-Mitwirkende. Du musst auch klarstellen, dass die Daten unter der Open-Database-Lizenz verfügbar sind, und, sofern du unsere Kartenkacheln verwendest, dass die Kartografie gemäß CC BY-SA lizenziert ist. Du kannst dies tun, indem du auf www.openstreetmap.org/copyright verlinkst. Ersatzweise, und als Erfordernis, falls du OSM in Datenform weitergibst, kannst du die Lizenz(en) direkt verlinken und benennen. In Medien, in denen keine Links möglich sind (z.B. gedruckten Werken), empfehlen wir dir, deine Leser direkt auf openstreetmap.org zu verweisen (möglicherweise mit dem Erweitern von OpenStreetMap zur vollen Adresse), auf opendatacommons.org, und, sofern zutreffend, auf creativecommons.org. Der Hinweis sollte für eine durchsuchbare elektronische Karte in der Ecke der Karte stehen."]
	}';