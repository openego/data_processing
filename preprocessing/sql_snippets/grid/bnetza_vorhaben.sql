/*
Import Vorhaben von BBPlG und EnLAG

Overview:
  * grid.bnetza_vorhaben_bbplg
  * grid.bnetza_vorhaben_enlag
  * grid.bnetza_vorhabenpunkte_bbplg
  * grid.bnetza_vorhabenpunkte_enlag



__copyright__ 	= "ZNES - Europa-Universität Flensburg"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "wolfbunke"


*/

-- Table:  grid.bnetza_vorhaben_bbplg
-- DROP TABLE grid.bnetza_vorhaben_bbplg;

CREATE TABLE grid.bnetza_vorhaben_bbplg
(
  id serial NOT NULL,
  geom geometry(MultiLineString,5652),
  object_id bigint,
  rechtsgrundlage character varying(5),
  vorhabennummer integer,
  nova character varying(20),
  vorhabenbezeichnung character varying(200),
  zustaendigkeit character varying(4),
  technik character varying(2),
  abschnitt character varying(5),
  anfangspunkt character varying(50),
  endpunkt character varying(50),
  abschnittsbezeichnung character varying(150),
  art_der_geometrie character varying(20),
  status_der_geometrie character varying(20),
  luftlinie_km double precision,
  erdkabelvorrang character varying(4),
  erdkabelpilot character varying(4),
  kennzeichnung character varying(10),
  kennzeichnung_a1 character varying(3),
  kennzeichnung_a2 character varying(3),
  kennzeichnung_b character varying(3),
  kennzeichnung_c character varying(3),
  kennzeichnung_d character varying(3),
  kennzeichnung_e character varying(3),
  kennzeichnung_f character varying(3),
  kennzeichnung_strich character varying(3),
  stand_des_vorhabens character varying(100),
  _id character varying(10),
  vgi character varying(10),
  vgi_nr character varying(15),
  vorhabentraeger character varying(50),
  spannung character varying(20),
  shape_length double precision,
  bezugsmassstab character varying(50),
  hinweis character varying(150),
  CONSTRAINT bnetza_vorhaben_bbplg_pkey PRIMARY KEY (id)
);

ALTER TABLE grid.bnetza_vorhaben_bbplg
  OWNER TO oeuser;

-- Index: grid.sidx_bnetza_vorhaben_bbplg_geom
-- DROP INDEX grid.sidx_bnetza_vorhaben_bbplg_geom;

CREATE INDEX sidx_bnetza_vorhaben_bbplg_geom
  ON grid.bnetza_vorhaben_bbplg
  USING gist
  (geom);
    
-- Meta data
COMMENT ON TABLE grid.bnetza_vorhaben_bbplg IS '{
	"title": "Stromleitungsvorhaben des BBPlG in Deutschland",
	"description": "Der Datensatz enthält die Netzausbauvorhaben des Bundesbedarfsplangesetzes (BBPlG) als Linienploygon und weiteren Vorhabeninformationen zum Verfahrensstand Ende des 1. Quartals 2017. \n Für weitergehende, aktuelle Informationen zu den Vorhaben bitte auf die Webseiten www.netzausbau.de/bbplg bzw. www.netzausbau.de/enlag gehen.",
	"language": [ "ger" ],
	"spatial": 
		{"location": "Germany",
		"extent": "Germany",
		"resolution": ""},
	"temporal": 
		{"reference_date": "2017-06-13",
		"start": "",
		"end": "",
		"resolution": ""},
	"sources": [
		{"name": "Vorhaben des BBPlG", "description": "Vorhaben des BBPlG, BNetzA, Stand 1. Quatal 2017", "url": "www.netzausbau.de/bbplg", "license": "GeoNutzV", "copyright": "Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen (BNetzA)"} ],
	"license": 
		{"id": "",
		"name": "GeoNutzV",
		"version": "19.03.2013",
		"url": "https://www.gesetze-im-internet.de/geonutzv/BJNR054700013.html",
		"instruction": "Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen (BNetzA)",
		"copyright": "Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen (BNetzA)"},
	"contributors": [
		{"name": "", "email": "", "date": "2017-07-31", "comment": "Create table and comments"}],
	"resources": [
		{"name": "grid.bnetza_vorhaben_bbplg",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "id", "description": "Unique identifier", "unit": ""},
			{"name": "geom", "description": "MultiLineString der Leitungsvorhaben", "unit": ""},
			{"name": "object_id", "description": "Object id", "unit": ""},
			{"name": "rechtsgrundlage", "description": "Vorhaben auf Basis genannter Rechtsgrundlage", "unit": ""},
			{"name": "vorhabennummer", "description": "Vorhabennummer", "unit": ""},
			{"name": "nova", "description": "NOVA", "unit": ""},
			{"name": "vorhabenbezeichnung", "description": "Vorhabenbezeichnung", "unit": ""},
			{"name": "zustaendigkeit", "description": "Zuständigkeit", "unit": ""},
			{"name": "technik", "description": "Technik", "unit": ""},
			{"name": "abschnitt", "description": "Abschnitt", "unit": ""},
			{"name": "anfangspunkt", "description": "Anfangspunkt", "unit": ""},
			{"name": "endpunkt", "description": "Endpunkt", "unit": ""},
			{"name": "abschnittsbezeichnung", "description": "Abschnittsbezeichnung", "unit": ""},
		        {"name": "art_der_geometrie", "description": "Art der geometrie", "unit": ""},
			{"name": "status_der_geometrie", "description": "Status der Geometrie", "unit": ""},
			{"name": "luftlinie_km", "description": "Luftlinie in km", "unit": ""},
			{"name": "erdkabelvorrang", "description": "Erdkabelvorrang ", "unit": ""},
			{"name": "erdkabelpilot", "description": "Erdkabelpilot ", "unit": ""},
			{"name": "kennzeichnung", "description": "Kennzeichnung", "unit": ""},
			{"name": "kennzeichnung_a1", "description": "Kennzeichnung A1", "unit": ""},
			{"name": "kennzeichnung_a2", "description": "Kennzeichnung A2", "unit": ""},
			{"name": "kennzeichnung_b", "description": "Kennzeichnung B", "unit": ""},
			{"name": "kennzeichnung_c", "description": "Kennzeichnung C", "unit": ""},
			{"name": "kennzeichnung_d", "description": "Kennzeichnung D", "unit": ""},
			{"name": "kennzeichnung_e", "description": "Kennzeichnung E", "unit": ""},
			{"name": "kennzeichnung_f", "description": "Kennzeichnung F", "unit": ""},
			{"name": "kennzeichnung_Strich", "description": "Kennzeichnung Strich", "unit": ""},
			{"name": "stand_des_vorhabens", "description": "Stand des Vorhabens", "unit": ""},
			{"name": "_id", "description": "ID ", "unit": ""},
			{"name": "vgi", "description": "VGI", "unit": ""},
			{"name": "vgi_nr", "description": "VGI_Nr ", "unit": ""},
			{"name": "vorhabentraeger", "description": "Vorhabenträger", "unit": ""},
			{"name": "spannung", "description": "Spannung ", "unit": ""},
			{"name": "shape_length", "description": "Shape_Length", "unit": ""},
			{"name": "bezugsmassstab", "description": "Bezugsmaßstab", "unit": ""},
			{"name": "hinweis", "description": "Hinweis", "unit": ""}
			 ] } ],
	"metadata_version": "1.3"}';

-- select description
SELECT obj_description('grid.bnetza_vorhaben_bbplg' ::regclass) ::json;

-- Insert data
Insert into grid.bnetza_vorhaben_bbplg
SELECT*
From  grid_bnetza."Projekt_VerNetzen_20170613 Vorhaben_BBPlG";


-- Table: grid.bnetza_vorhaben_enlag
-- DROP TABLE grid.bnetza_vorhaben_enlag;

CREATE TABLE grid.bnetza_vorhaben_enlag
(
  id serial NOT NULL,
  geom geometry(MultiLineString,5652),
  object_id bigint,
  rechtsgrundlage character varying(5),
  vorhabennummer integer,
  nova character varying(20),
  vorhabenbezeichnung character varying(200),
  zustaendigkeit character varying(4),
  technik character varying(2),
  abschnitt character varying(5),
  anfangspunkt character varying(50),
  endpunkt character varying(50),
  abschnittsbezeichnung character varying(150),
  art_der_geometrie character varying(20),
  status_der_geometrie character varying(20),
  erdkabelvorrang character varying(4),
  erdkabelpilot character varying(4),
  kennzeichnung character varying(10),
  kennzeichnung_a1 character varying(3),
  kennzeichnung_a2 character varying(3),
  kennzeichnung_b character varying(3),
  kennzeichnung_c character varying(3),
  kennzeichnung_d character varying(3),
  kennzeichnung_e character varying(3),
  kennzeichnung_f character varying(3),
  kennzeichnung_strich character varying(3),
  stand_des_vorhabens character varying(100),
  _id character varying(10),
  vgi character varying(10),
  vgi_nr character varying(15),
  vorhabentraeger character varying(50),
  spannung character varying(20),
  shape_length double precision,
  bezugsmassstab character varying(50),
  hinweis character varying(150),
  CONSTRAINT bnetza_vorhaben_enlag_pkey PRIMARY KEY (id)
);

ALTER TABLE grid.bnetza_vorhaben_enlag
  OWNER TO oeuser;

-- Index: grid.sidx_bnetza_vorhaben_enlag_geom
-- DROP INDEX grid.sidx_bnetza_vorhaben_enlag_geom;

CREATE INDEX sidx_bnetza_vorhaben_enlag_geom
  ON grid.bnetza_vorhaben_enlag
  USING gist
  (geom);


-- Meta data
COMMENT ON TABLE grid.bnetza_vorhaben_enlag IS '{
	"title": "Stromleitungsvorhaben des EnLAG in Deutschland",
	"description": "Der Datensatz enthält die Netzausbauvorhaben des Energieleitungsausbaugesetz (EnLAG) als Linienploygon und weiteren Vorhabeninformationen zum Verfahrensstand Ende des 1. Quartals 2017. \n Für weitergehende, aktuelle Informationen zu den Vorhaben bitte auf die Webseiten www.netzausbau.de/bbplg bzw. www.netzausbau.de/enlag gehen.",
	"language": [ "ger" ],
	"spatial": 
		{"location": "Germany",
		"extent": "Germany",
		"resolution": ""},
	"temporal": 
		{"reference_date": "2017-06-13",
		"start": "",
		"end": "",
		"resolution": ""},
	"sources": [
		{"name": "Vorhaben des EnLAG", "description": "Vorhaben des EnLAG, BNetzA, Stand 1. Quatal 2017", "url": "www.netzausbau.de/enlag", "license": "GeoNutzV", "copyright": "Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen (BNetzA)"} ],
	"license": 
		{"id": "",
		"name": "GeoNutzV",
		"version": "19.03.2013",
		"url": "https://www.gesetze-im-internet.de/geonutzv/BJNR054700013.html",
		"instruction": "Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen (BNetzA)",
		"copyright": "Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen (BNetzA)"},
	"contributors": [
		{"name": "", "email": "", "date": "2017-07-31", "comment": "Create table and comments"}],
	"resources": [
		{"name": "grid.bnetza_vorhaben_enlag",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "id", "description": "Unique identifier", "unit": ""},
			{"name": "geom", "description": "MultiLineString der Leitungsvorhaben", "unit": ""},
			{"name": "object_id", "description": "Object id", "unit": ""},
			{"name": "rechtsgrundlage", "description": "Vorhaben auf Basis genannter Rechtsgrundlage", "unit": ""},
			{"name": "vorhabennummer", "description": "Vorhabennummer", "unit": ""},
			{"name": "nova", "description": "NOVA", "unit": ""},
			{"name": "vorhabenbezeichnung", "description": "Vorhabenbezeichnung", "unit": ""},
			{"name": "zustaendigkeit", "description": "Zuständigkeit", "unit": ""},
			{"name": "technik", "description": "Technik", "unit": ""},
			{"name": "abschnitt", "description": "Abschnitt", "unit": ""},
			{"name": "anfangspunkt", "description": "Anfangspunkt", "unit": ""},
			{"name": "endpunkt", "description": "Endpunkt", "unit": ""},
			{"name": "abschnittsbezeichnung", "description": "Abschnittsbezeichnung", "unit": ""},
		        {"name": "art_der_geometrie", "description": "Art der geometrie", "unit": ""},
			{"name": "status_der_geometrie", "description": "Status der Geometrie", "unit": ""},
			{"name": "erdkabelvorrang", "description": "Erdkabelvorrang ", "unit": ""},
			{"name": "erdkabelpilot", "description": "Erdkabelpilot ", "unit": ""},
			{"name": "kennzeichnung", "description": "Kennzeichnung", "unit": ""},
			{"name": "kennzeichnung_a1", "description": "Kennzeichnung A1", "unit": ""},
			{"name": "kennzeichnung_a2", "description": "Kennzeichnung A2", "unit": ""},
			{"name": "kennzeichnung_b", "description": "Kennzeichnung B", "unit": ""},
			{"name": "kennzeichnung_c", "description": "Kennzeichnung C", "unit": ""},
			{"name": "kennzeichnung_d", "description": "Kennzeichnung D", "unit": ""},
			{"name": "kennzeichnung_e", "description": "Kennzeichnung E", "unit": ""},
			{"name": "kennzeichnung_f", "description": "Kennzeichnung F", "unit": ""},
			{"name": "kennzeichnung_Strich", "description": "Kennzeichnung Strich", "unit": ""},
			{"name": "stand_des_vorhabens", "description": "Stand des Vorhabens", "unit": ""},
			{"name": "_id", "description": "ID ", "unit": ""},
			{"name": "vgi", "description": "VGI", "unit": ""},
			{"name": "vgi_nr", "description": "VGI_Nr ", "unit": ""},
			{"name": "vorhabentraeger", "description": "Vorhabenträger", "unit": ""},
			{"name": "spannung", "description": "Spannung ", "unit": ""},
			{"name": "shape_length", "description": "Shape_Length", "unit": ""},
			{"name": "bezugsmassstab", "description": "Bezugsmaßstab", "unit": ""},
			{"name": "hinweis", "description": "Hinweis", "unit": ""}
			 ] } ],
	"metadata_version": "1.3"}';

-- select description
SELECT obj_description('grid.bnetza_vorhaben_enlag' ::regclass) ::json;

-- Insert data
Insert into grid.bnetza_vorhaben_enlag
SELECT*
From  grid_bnetza."Projekt_VerNetzen_20170613 Vorhaben_EnLAG";



-- Table: grid.bnetza_vorhabenpunkte_bbplg
-- DROP TABLE grid.bnetza_vorhabenpunkte_bbplg;

CREATE TABLE grid.bnetza_vorhabenpunkte_bbplg
(
  id serial NOT NULL,
  geom geometry(Point,4647),
  object_id bigint,
  name character varying(50),
  CONSTRAINT bnetza_vorhabenpunkte_bbplg_pkey PRIMARY KEY (id)
);

ALTER TABLE grid.bnetza_vorhabenpunkte_bbplg
  OWNER TO oeuser;

-- Index: grid.sidx_bnetza_vorhabenpunkte_bbplg_geom
-- DROP INDEX grid.sidx_bnetza_vorhabenpunkte_bbplg_geom;

CREATE INDEX idx_bnetza_vorhabenpunkte_bbplg_geom
  ON grid.bnetza_vorhabenpunkte_bbplg
  USING gist
  (geom);

-- Meta data
COMMENT ON TABLE grid.bnetza_vorhabenpunkte_bbplg IS '{
	"title": "Stromleitungsvorhabenpunkte des BBPlG in Deutschland",
	"description": "Der Datensatz enthält die Netzausbauvorhaben des Bundesbedarfsplangesetzes (BBPlG) als Linienploygon und weiteren Vorhabeninformationen zum Verfahrensstand Ende des 1. Quartals 2017. \n Für weitergehende, aktuelle Informationen zu den Vorhaben bitte auf die Webseiten www.netzausbau.de/bbplg bzw. www.netzausbau.de/enlag gehen.",
	"language": [ "ger" ],
	"spatial": 
		{"location": "Germany",
		"extent": "Germany",
		"resolution": ""},
	"temporal": 
		{"reference_date": "2017-06-13",
		"start": "",
		"end": "",
		"resolution": ""},
	"sources": [
		{"name": "Vorhabenpunkte des BBPlG", "description": "Vorhabenpunkte des BBPlG, BNetzA, Stand 1. Quatal 2017", "url": "www.netzausbau.de/bbplg", "license": "GeoNutzV", "copyright": "Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen (BNetzA)"} ],
	"license": 
		{"id": "",
		"name": "GeoNutzV",
		"version": "19.03.2013",
		"url": "https://www.gesetze-im-internet.de/geonutzv/BJNR054700013.html",
		"instruction": "Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen (BNetzA)",
		"copyright": "Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen (BNetzA)"},
	"contributors": [
		{"name": "", "email": "", "date": "2017-07-31", "comment": "Create table and comments"}],
	"resources": [
		{"name": "grid.bnetza_vorhaben_enlag",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "id", "description": "Unique identifier", "unit": ""},
			{"name": "geom", "description": "MultiLineString der Leitungsvorhaben", "unit": ""},
			{"name": "object_id", "description": "Object id", "unit": ""},
			{"name": "name", "description": "Name des Abschnittpunkt (Trafostation, Umspannwerk, Landesgrenze etc.)", "unit": ""}
			 ] } ],
	"metadata_version": "1.3"}';

-- select description
SELECT obj_description('grid.bnetza_vorhabenpunkte_bbplg' ::regclass) ::json;


-- Insert data
Insert into grid.bnetza_vorhaben_enlag
SELECT*
From grid_bnetza."Projekt_VerNetzen_20170613 Vorhabenpunkte_BBPlG";


-- Table: grid.bnetza_vorhabenpunkte_bbplg
-- DROP TABLE grid.bnetza_vorhabenpunkte_bbplg;

CREATE TABLE grid.bnetza_vorhabenpunkte_enlag
(
  id serial NOT NULL,
  geom geometry(Point,4647),
  object_id bigint,
  name character varying(50),
  CONSTRAINT bnetza_vorhabenpunkte_enlag_pkey PRIMARY KEY (id)
);

ALTER TABLE grid.bnetza_vorhabenpunkte_enlag
  OWNER TO oeuser;

-- Index: grid.sidx_bnetza_vorhabenpunkte_enlag_geom
-- DROP INDEX grid.sidx_bnetza_vorhabenpunkte_enlag_geom;

CREATE INDEX idx_bnetza_vorhabenpunkte_enlag_geom
  ON grid.bnetza_vorhabenpunkte_enlag
  USING gist
  (geom);


-- Meta data
COMMENT ON TABLE grid.bnetza_vorhabenpunkte_enlag IS '{
	"title": "Stromleitungsvorhabenpunkte des EnlAG in Deutschland",
	"description": "Der Datensatz enthält die Netzausbauvorhaben des Energieleitungsausbaugesetz (EnLAG) als Linienploygon und weiteren Vorhabeninformationen zum Verfahrensstand Ende des 1. Quartals 2017. \n Für weitergehende, aktuelle Informationen zu den Vorhaben bitte auf die Webseiten www.netzausbau.de/bbplg bzw. www.netzausbau.de/enlag gehen.",
	"language": [ "ger" ],
	"spatial": 
		{"location": "Germany",
		"extent": "Germany",
		"resolution": ""},
	"temporal": 
		{"reference_date": "2017-06-13",
		"start": "",
		"end": "",
		"resolution": ""},
	"sources": [
		{"name": "Vorhabenpunkte des BBPlG", "description": "Vorhabenpunkte des BBPlG, BNetzA, Stand 1. Quatal 2017", "url": "www.netzausbau.de/enlag", "license": "GeoNutzV", "copyright": "Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen (BNetzA)"} ],
	"license": 
		{"id": "",
		"name": "GeoNutzV",
		"version": "19.03.2013",
		"url": "https://www.gesetze-im-internet.de/geonutzv/BJNR054700013.html",
		"instruction": "Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen (BNetzA)",
		"copyright": "Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen (BNetzA)"},
	"contributors": [
		{"name": "", "email": "", "date": "2017-07-31", "comment": "Create table and comments"}],
	"resources": [
		{"name": "grid.bnetza_vorhaben_enlag",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "id", "description": "Unique identifier", "unit": ""},
			{"name": "geom", "description": "MultiLineString der Leitungsvorhaben", "unit": ""},
			{"name": "object_id", "description": "Object id", "unit": ""},
			{"name": "name", "description": "Name des Abschnittpunkt (Trafostation, Umspannwerk, Landesgrenze etc.)", "unit": ""}
			 ] } ],
	"metadata_version": "1.3"}';

-- select description
SELECT obj_description('grid.bnetza_vorhabenpunkte_enlag' ::regclass) ::json;


-- Insert data
Insert into grid.bnetza_vorhabenpunkte_enlag
SELECT*
From grid_bnetza."Projekt_VerNetzen_20170613 Vorhabenpunkte_EnLAG";

/*
work around with CSV import:

COPY grid_bnetza."Projekt_VerNetzen_20170613 Vorhaben_BBPlG" TO '/tmp/vorhaben_bbplg.csv' WITH  DELIMITER ',' CSV HEADER ;
COPY grid_bnetza."Projekt_VerNetzen_20170613 Vorhaben_EnLAG" TO '/tmp/vorhaben_enlag.csv' WITH  DELIMITER ',' CSV HEADER ;
COPY grid_bnetza."Projekt_VerNetzen_20170613 Vorhabenpunkte_BBPlG" TO '/tmp/vorhabenpunkt_bbplg.csv' WITH  DELIMITER ',' CSV HEADER ;
COPY grid_bnetza."Projekt_VerNetzen_20170613 Vorhabenpunkte_EnLAG" TO '/tmp/vorhabenpunkt_enlag.csv' WITH  DELIMITER ',' CSV HEADER ;
*/



