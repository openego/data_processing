-- 30 s

DROP TABLE IF EXISTS model_draft.ego_grid_lv_griddistricts_temp;

CREATE TABLE model_draft.ego_grid_lv_griddistricts_temp AS

SELECT ST_BUFFER (geom,180)::geometry(Polygon,3035) AS geom, id AS ont_id
FROM model_draft.ego_grid_mvlv_onts;

-- Add ID

ALTER TABLE model_draft.ego_grid_lv_griddistricts_temp
ADD COLUMN id serial;
ALTER TABLE model_draft.ego_grid_lv_griddistricts_temp
ADD CONSTRAINT ego_grid_lv_griddistricts_temp_pkey PRIMARY KEY (id);



ALTER TABLE model_draft.ego_grid_lv_griddistricts_temp
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_lv_griddistricts_temp TO oeuser;

CREATE INDEX ego_grid_lv_griddistricts_temp_geom_idx
  ON model_draft.ego_grid_lv_griddistricts_temp
  USING gist
  (geom);


 COMMENT ON TABLE model_draft.ego_grid_lv_griddistricts_temp
  IS '{
        "Name": "ego_grid_lv_griddistricts_temp",

	"Spatial resolution": ["Germany"],

	"Description": ["Kreisförmige Buffer um modellierte ONS als deren Einzugsgebiete"],

	"Column":[ 

	{"name":"id",
	"description":"unique identifier",
	"unit":" " },
	{"name":"geom",
	"description":"geometry",
	"description_german":"Geometrie",
	"unit":" " },
	{"name":"ont_id",
	"description":"id of the corresponding ont",
	"unit":" " }

	],

	"Changes":[

	   { "name":"Jonas Gütter", 
	    "mail":" ", 
	    "date":"16.12.2016", 
	    "comment":"created table"}		],

	

	"Licence": ["Open Data Commons Open Database Lizenz (ODbL)"],

	"Instructions for proper use": ["Wir verlangen die Verwendung des Hinweises OpenStreetMap-Mitwirkende. Du musst auch klarstellen, dass die Daten unter der Open-Database-Lizenz verfügbar sind, und, sofern du unsere Kartenkacheln verwendest, dass die Kartografie gemäß CC BY-SA lizenziert ist. Du kannst dies tun, indem du auf www.openstreetmap.org/copyright verlinkst. Ersatzweise, und als Erfordernis, falls du OSM in Datenform weitergibst, kannst du die Lizenz(en) direkt verlinken und benennen. In Medien, in denen keine Links möglich sind (z.B. gedruckten Werken), empfehlen wir dir, deine Leser direkt auf openstreetmap.org zu verweisen (möglicherweise mit dem Erweitern von OpenStreetMap zur vollen Adresse), auf opendatacommons.org, und, sofern zutreffend, auf creativecommons.org. Der Hinweis sollte für eine durchsuchbare elektronische Karte in der Ecke der Karte stehen."]
	}';