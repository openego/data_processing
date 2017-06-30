/*
Metadata for vg250 tables

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- metadata
COMMENT ON TABLE political_boundary.bkg_vg250_2_lan IS '{
	"title": "BKG - Verwaltungsgebiete 1:250.000 - Länder (LAN)",
	"description": "Der Datenbestand umfasst die Verwaltungseinheiten der hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden",
	"language": [ "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "vector"},
	"temporal": 
		{"reference_date": "2016-01-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data", 
		"description": "Dieser Datenbestand steht über Geodatendienste gemäß Geodatenzugangsgesetz (GeoZG) (http://www.geodatenzentrum.de/auftrag/pdf/geodatenzugangsgesetz.pdf) für die kommerzielle und nicht kommerzielle Nutzung geldleistungsfrei zum Download und zur Online-Nutzung zur Verfügung. Die Nutzung der Geodaten und Geodatendienste wird durch die Verordnung zur Festlegung der Nutzungsbestimmungen für die Bereitstellung von Geodaten des Bundes (GeoNutzV) (http://www.geodatenzentrum.de/auftrag/pdf/geonutz.pdf) geregelt. Insbesondere hat jeder Nutzer den Quellenvermerk zu allen Geodaten, Metadaten und Geodatendiensten erkennbar und in optischem Zusammenhang zu platzieren. Veränderungen, Bearbeitungen, neue Gestaltungen oder sonstige Abwandlungen sind mit einem Veränderungshinweis im Quellenvermerk zu versehen. Quellenvermerk und Veränderungshinweis sind wie folgt zu gestalten. Bei der Darstellung auf einer Webseite ist der Quellenvermerk mit der URL http://www.bkg.bund.de zu verlinken. © GeoBasis-DE / BKG <Jahr des letzten Datenbezugs> © GeoBasis-DE / BKG <Jahr des letzten Datenbezugs> (Daten verändert) Beispiel: © GeoBasis-DE / BKG 2013", 
		"url": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", 
		"description": "Der Datenbestand umfasst sämtliche Verwaltungseinheiten aller hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden mit ihren Verwaltungsgrenzen, statistischen Schlüsselzahlen und dem Namen der Verwaltungseinheit sowie der spezifischen Bezeichnung der Verwaltungsebene des jeweiligen Bundeslandes. ", 
		"url": "http://www.bkg.bund.de", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"} ],
	"license": 
		{"id": "",
		"name": "Gesetz über den Zugang zu digitalen Geodaten (Geodatenzugangsgesetz - GeoZG)",
		"version": "Geändert durch Art. 1 G v. 7.11.2012",
		"url": "http://www.gesetze-im-internet.de/bundesrecht/geozg/gesamt.pdf",
		"instruction": "",
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"},
	"contributors": [
		{"name": "Ludee", "email": "", "date": "2016-09-02", "comment": "Create table"},
		{"name": "Ludee", "email": "", "date": "2016-11-16", "comment": "Add metadata"},
		{"name": "Ludee", "email": "", "date": "2017-03-21", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "political_boundary.bkg_vg250_2_lan",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "reference_date", "description": "Reference date", "unit": "none"},
			{"name": "id", "description": "Unique identifier", "unit": "none"},
			{"name": "ade", "description": "Administrative Ebene", "unit": "none"},
			{"name": "gf", "description": "Geofaktor", "unit": "none"},
			{"name": "bsg", "description": "Besondere Gebiete", "unit": "none"},
			{"name": "rs", "description": "Regionalschlüssel", "unit": "none"},
			{"name": "ags", "description": "Amtlicher Gemeindeschlüssel", "unit": "none"},
			{"name": "sdv_rs", "description": "Sitz der Verwaltung (Regionalschlüssel)", "unit": "none"},
			{"name": "gen", "description": "Geografischer Name", "unit": "none"},
			{"name": "bez", "description": "Bezeichnung der Verwaltungseinheit", "unit": "none"},
			{"name": "ibz", "description": "Identifikator", "unit": "none"},
			{"name": "bem", "description": "Bemerkung", "unit": "none"},
			{"name": "nbd", "description": "Namensbildung", "unit": "none"},
			{"name": "sn_l", "description": "Land", "unit": "none"},
			{"name": "sn_r", "description": "Regierungsbezirk", "unit": "none"},
			{"name": "sn_k", "description": "Kreis", "unit": "none"},
			{"name": "sn_v1", "description": "Verwaltungsgemeinschaft - vorderer Teil", "unit": "none"},
			{"name": "sv_v2", "description": "Verwaltungsgemeinschaft - hinterer Teil", "unit": "none"},
			{"name": "sn_g", "description": "Gemeinde", "unit": "none"},
			{"name": "fk_s3", "description": "Funktion der 3. Schlüsselstelle", "unit": "none"},
			{"name": "nuts", "description": "Europäischer Statistikschlüssel", "unit": "none"},
			{"name": "rs_0", "description": "aufgefüllter Regionalschlüssel", "unit": "none"},
			{"name": "ags_0", "description": "aufgefüllter Amtlicher Gemeindeschlüssel", "unit": "none"},
			{"name": "wsk", "description": "Wirksamkeit", "unit": "none"},
			{"name": "debkg_id", "description": "DLM-Identifikator", "unit": "none"},
			{"name": "geom", "description": "Geometry", "unit": "none" } ] } ],
	"metadata_version": "1.3"}';

-- metadata
COMMENT ON TABLE political_boundary.bkg_vg250_3_rbz IS '{
	"title": "BKG - Verwaltungsgebiete 1:250.000 - Regierungsbezirke (RBZ)",
	"description": "Der Datenbestand umfasst die Verwaltungseinheiten der hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden",
	"language": [ "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "vector"},
	"temporal": 
		{"reference_date": "2016-01-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data", 
		"description": "Dieser Datenbestand steht über Geodatendienste gemäß Geodatenzugangsgesetz (GeoZG) (http://www.geodatenzentrum.de/auftrag/pdf/geodatenzugangsgesetz.pdf) für die kommerzielle und nicht kommerzielle Nutzung geldleistungsfrei zum Download und zur Online-Nutzung zur Verfügung. Die Nutzung der Geodaten und Geodatendienste wird durch die Verordnung zur Festlegung der Nutzungsbestimmungen für die Bereitstellung von Geodaten des Bundes (GeoNutzV) (http://www.geodatenzentrum.de/auftrag/pdf/geonutz.pdf) geregelt. Insbesondere hat jeder Nutzer den Quellenvermerk zu allen Geodaten, Metadaten und Geodatendiensten erkennbar und in optischem Zusammenhang zu platzieren. Veränderungen, Bearbeitungen, neue Gestaltungen oder sonstige Abwandlungen sind mit einem Veränderungshinweis im Quellenvermerk zu versehen. Quellenvermerk und Veränderungshinweis sind wie folgt zu gestalten. Bei der Darstellung auf einer Webseite ist der Quellenvermerk mit der URL http://www.bkg.bund.de zu verlinken. © GeoBasis-DE / BKG <Jahr des letzten Datenbezugs> © GeoBasis-DE / BKG <Jahr des letzten Datenbezugs> (Daten verändert) Beispiel: © GeoBasis-DE / BKG 2013", 
		"url": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", 
		"description": "Der Datenbestand umfasst sämtliche Verwaltungseinheiten aller hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden mit ihren Verwaltungsgrenzen, statistischen Schlüsselzahlen und dem Namen der Verwaltungseinheit sowie der spezifischen Bezeichnung der Verwaltungsebene des jeweiligen Bundeslandes. ", 
		"url": "http://www.bkg.bund.de", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"} ],
	"license": 
		{"id": "",
		"name": "Gesetz über den Zugang zu digitalen Geodaten (Geodatenzugangsgesetz - GeoZG)",
		"version": "Geändert durch Art. 1 G v. 7.11.2012",
		"url": "http://www.gesetze-im-internet.de/bundesrecht/geozg/gesamt.pdf",
		"instruction": "",
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"},
	"contributors": [
		{"name": "Ludee", "email": "", "date": "2016-09-02", "comment": "Create table"},
		{"name": "Ludee", "email": "", "date": "2016-11-16", "comment": "Add metadata"},
		{"name": "Ludee", "email": "", "date": "2017-03-21", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "political_boundary.bkg_vg250_3_rbz",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "reference_date", "description": "Reference date", "unit": "none"},
			{"name": "id", "description": "Unique identifier", "unit": "none"},
			{"name": "ade", "description": "Administrative Ebene", "unit": "none"},
			{"name": "gf", "description": "Geofaktor", "unit": "none"},
			{"name": "bsg", "description": "Besondere Gebiete", "unit": "none"},
			{"name": "rs", "description": "Regionalschlüssel", "unit": "none"},
			{"name": "ags", "description": "Amtlicher Gemeindeschlüssel", "unit": "none"},
			{"name": "sdv_rs", "description": "Sitz der Verwaltung (Regionalschlüssel)", "unit": "none"},
			{"name": "gen", "description": "Geografischer Name", "unit": "none"},
			{"name": "bez", "description": "Bezeichnung der Verwaltungseinheit", "unit": "none"},
			{"name": "ibz", "description": "Identifikator", "unit": "none"},
			{"name": "bem", "description": "Bemerkung", "unit": "none"},
			{"name": "nbd", "description": "Namensbildung", "unit": "none"},
			{"name": "sn_l", "description": "Land", "unit": "none"},
			{"name": "sn_r", "description": "Regierungsbezirk", "unit": "none"},
			{"name": "sn_k", "description": "Kreis", "unit": "none"},
			{"name": "sn_v1", "description": "Verwaltungsgemeinschaft - vorderer Teil", "unit": "none"},
			{"name": "sv_v2", "description": "Verwaltungsgemeinschaft - hinterer Teil", "unit": "none"},
			{"name": "sn_g", "description": "Gemeinde", "unit": "none"},
			{"name": "fk_s3", "description": "Funktion der 3. Schlüsselstelle", "unit": "none"},
			{"name": "nuts", "description": "Europäischer Statistikschlüssel", "unit": "none"},
			{"name": "rs_0", "description": "aufgefüllter Regionalschlüssel", "unit": "none"},
			{"name": "ags_0", "description": "aufgefüllter Amtlicher Gemeindeschlüssel", "unit": "none"},
			{"name": "wsk", "description": "Wirksamkeit", "unit": "none"},
			{"name": "debkg_id", "description": "DLM-Identifikator", "unit": "none"},
			{"name": "geom", "description": "Geometry", "unit": "none" } ] } ],
	"metadata_version": "1.3"}';

-- metadata
COMMENT ON TABLE political_boundary.bkg_vg250_4_krs IS '{
	"title": "BKG - Verwaltungsgebiete 1:250.000 - Kreise (KRS)",
	"description": "Der Datenbestand umfasst die Verwaltungseinheiten der hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden",
	"language": [ "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "vector"},
	"temporal": 
		{"reference_date": "2016-01-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data", 
		"description": "Dieser Datenbestand steht über Geodatendienste gemäß Geodatenzugangsgesetz (GeoZG) (http://www.geodatenzentrum.de/auftrag/pdf/geodatenzugangsgesetz.pdf) für die kommerzielle und nicht kommerzielle Nutzung geldleistungsfrei zum Download und zur Online-Nutzung zur Verfügung. Die Nutzung der Geodaten und Geodatendienste wird durch die Verordnung zur Festlegung der Nutzungsbestimmungen für die Bereitstellung von Geodaten des Bundes (GeoNutzV) (http://www.geodatenzentrum.de/auftrag/pdf/geonutz.pdf) geregelt. Insbesondere hat jeder Nutzer den Quellenvermerk zu allen Geodaten, Metadaten und Geodatendiensten erkennbar und in optischem Zusammenhang zu platzieren. Veränderungen, Bearbeitungen, neue Gestaltungen oder sonstige Abwandlungen sind mit einem Veränderungshinweis im Quellenvermerk zu versehen. Quellenvermerk und Veränderungshinweis sind wie folgt zu gestalten. Bei der Darstellung auf einer Webseite ist der Quellenvermerk mit der URL http://www.bkg.bund.de zu verlinken. © GeoBasis-DE / BKG <Jahr des letzten Datenbezugs> © GeoBasis-DE / BKG <Jahr des letzten Datenbezugs> (Daten verändert) Beispiel: © GeoBasis-DE / BKG 2013", 
		"url": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", 
		"description": "Der Datenbestand umfasst sämtliche Verwaltungseinheiten aller hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden mit ihren Verwaltungsgrenzen, statistischen Schlüsselzahlen und dem Namen der Verwaltungseinheit sowie der spezifischen Bezeichnung der Verwaltungsebene des jeweiligen Bundeslandes. ", 
		"url": "http://www.bkg.bund.de", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"} ],
	"license": 
		{"id": "",
		"name": "Gesetz über den Zugang zu digitalen Geodaten (Geodatenzugangsgesetz - GeoZG)",
		"version": "Geändert durch Art. 1 G v. 7.11.2012",
		"url": "http://www.gesetze-im-internet.de/bundesrecht/geozg/gesamt.pdf",
		"instruction": "",
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"},
	"contributors": [
		{"name": "Ludee", "email": "", "date": "2016-09-02", "comment": "Create table"},
		{"name": "Ludee", "email": "", "date": "2016-11-16", "comment": "Add metadata"},
		{"name": "Ludee", "email": "", "date": "2017-03-21", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "political_boundary.bkg_vg250_4_krs",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "reference_date", "description": "Reference date", "unit": "none"},
			{"name": "id", "description": "Unique identifier", "unit": "none"},
			{"name": "ade", "description": "Administrative Ebene", "unit": "none"},
			{"name": "gf", "description": "Geofaktor", "unit": "none"},
			{"name": "bsg", "description": "Besondere Gebiete", "unit": "none"},
			{"name": "rs", "description": "Regionalschlüssel", "unit": "none"},
			{"name": "ags", "description": "Amtlicher Gemeindeschlüssel", "unit": "none"},
			{"name": "sdv_rs", "description": "Sitz der Verwaltung (Regionalschlüssel)", "unit": "none"},
			{"name": "gen", "description": "Geografischer Name", "unit": "none"},
			{"name": "bez", "description": "Bezeichnung der Verwaltungseinheit", "unit": "none"},
			{"name": "ibz", "description": "Identifikator", "unit": "none"},
			{"name": "bem", "description": "Bemerkung", "unit": "none"},
			{"name": "nbd", "description": "Namensbildung", "unit": "none"},
			{"name": "sn_l", "description": "Land", "unit": "none"},
			{"name": "sn_r", "description": "Regierungsbezirk", "unit": "none"},
			{"name": "sn_k", "description": "Kreis", "unit": "none"},
			{"name": "sn_v1", "description": "Verwaltungsgemeinschaft - vorderer Teil", "unit": "none"},
			{"name": "sv_v2", "description": "Verwaltungsgemeinschaft - hinterer Teil", "unit": "none"},
			{"name": "sn_g", "description": "Gemeinde", "unit": "none"},
			{"name": "fk_s3", "description": "Funktion der 3. Schlüsselstelle", "unit": "none"},
			{"name": "nuts", "description": "Europäischer Statistikschlüssel", "unit": "none"},
			{"name": "rs_0", "description": "aufgefüllter Regionalschlüssel", "unit": "none"},
			{"name": "ags_0", "description": "aufgefüllter Amtlicher Gemeindeschlüssel", "unit": "none"},
			{"name": "wsk", "description": "Wirksamkeit", "unit": "none"},
			{"name": "debkg_id", "description": "DLM-Identifikator", "unit": "none"},
			{"name": "geom", "description": "Geometry", "unit": "none" } ] } ],
	"metadata_version": "1.3"}';

-- metadata
COMMENT ON TABLE political_boundary.bkg_vg250_5_vwg IS '{
	"title": "BKG - Verwaltungsgebiete 1:250.000 - Verwaltungsgemeinschaften (VWG)",
	"description": "Der Datenbestand umfasst die Verwaltungseinheiten der hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden",
	"language": [ "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "vector"},
	"temporal": 
		{"reference_date": "2016-01-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data", 
		"description": "Dieser Datenbestand steht über Geodatendienste gemäß Geodatenzugangsgesetz (GeoZG) (http://www.geodatenzentrum.de/auftrag/pdf/geodatenzugangsgesetz.pdf) für die kommerzielle und nicht kommerzielle Nutzung geldleistungsfrei zum Download und zur Online-Nutzung zur Verfügung. Die Nutzung der Geodaten und Geodatendienste wird durch die Verordnung zur Festlegung der Nutzungsbestimmungen für die Bereitstellung von Geodaten des Bundes (GeoNutzV) (http://www.geodatenzentrum.de/auftrag/pdf/geonutz.pdf) geregelt. Insbesondere hat jeder Nutzer den Quellenvermerk zu allen Geodaten, Metadaten und Geodatendiensten erkennbar und in optischem Zusammenhang zu platzieren. Veränderungen, Bearbeitungen, neue Gestaltungen oder sonstige Abwandlungen sind mit einem Veränderungshinweis im Quellenvermerk zu versehen. Quellenvermerk und Veränderungshinweis sind wie folgt zu gestalten. Bei der Darstellung auf einer Webseite ist der Quellenvermerk mit der URL http://www.bkg.bund.de zu verlinken. © GeoBasis-DE / BKG <Jahr des letzten Datenbezugs> © GeoBasis-DE / BKG <Jahr des letzten Datenbezugs> (Daten verändert) Beispiel: © GeoBasis-DE / BKG 2013", 
		"url": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", 
		"description": "Der Datenbestand umfasst sämtliche Verwaltungseinheiten aller hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden mit ihren Verwaltungsgrenzen, statistischen Schlüsselzahlen und dem Namen der Verwaltungseinheit sowie der spezifischen Bezeichnung der Verwaltungsebene des jeweiligen Bundeslandes. ", 
		"url": "http://www.bkg.bund.de", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"} ],
	"license": 
		{"id": "",
		"name": "Gesetz über den Zugang zu digitalen Geodaten (Geodatenzugangsgesetz - GeoZG)",
		"version": "Geändert durch Art. 1 G v. 7.11.2012",
		"url": "http://www.gesetze-im-internet.de/bundesrecht/geozg/gesamt.pdf",
		"instruction": "",
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"},
	"contributors": [
		{"name": "Ludee", "email": "", "date": "2016-09-02", "comment": "Create table"},
		{"name": "Ludee", "email": "", "date": "2016-11-16", "comment": "Add metadata"},
		{"name": "Ludee", "email": "", "date": "2017-03-21", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "political_boundary.bkg_vg250_5_vwg",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "reference_date", "description": "Reference date", "unit": "none"},
			{"name": "id", "description": "Unique identifier", "unit": "none"},
			{"name": "ade", "description": "Administrative Ebene", "unit": "none"},
			{"name": "gf", "description": "Geofaktor", "unit": "none"},
			{"name": "bsg", "description": "Besondere Gebiete", "unit": "none"},
			{"name": "rs", "description": "Regionalschlüssel", "unit": "none"},
			{"name": "ags", "description": "Amtlicher Gemeindeschlüssel", "unit": "none"},
			{"name": "sdv_rs", "description": "Sitz der Verwaltung (Regionalschlüssel)", "unit": "none"},
			{"name": "gen", "description": "Geografischer Name", "unit": "none"},
			{"name": "bez", "description": "Bezeichnung der Verwaltungseinheit", "unit": "none"},
			{"name": "ibz", "description": "Identifikator", "unit": "none"},
			{"name": "bem", "description": "Bemerkung", "unit": "none"},
			{"name": "nbd", "description": "Namensbildung", "unit": "none"},
			{"name": "sn_l", "description": "Land", "unit": "none"},
			{"name": "sn_r", "description": "Regierungsbezirk", "unit": "none"},
			{"name": "sn_k", "description": "Kreis", "unit": "none"},
			{"name": "sn_v1", "description": "Verwaltungsgemeinschaft - vorderer Teil", "unit": "none"},
			{"name": "sv_v2", "description": "Verwaltungsgemeinschaft - hinterer Teil", "unit": "none"},
			{"name": "sn_g", "description": "Gemeinde", "unit": "none"},
			{"name": "fk_s3", "description": "Funktion der 3. Schlüsselstelle", "unit": "none"},
			{"name": "nuts", "description": "Europäischer Statistikschlüssel", "unit": "none"},
			{"name": "rs_0", "description": "aufgefüllter Regionalschlüssel", "unit": "none"},
			{"name": "ags_0", "description": "aufgefüllter Amtlicher Gemeindeschlüssel", "unit": "none"},
			{"name": "wsk", "description": "Wirksamkeit", "unit": "none"},
			{"name": "debkg_id", "description": "DLM-Identifikator", "unit": "none"},
			{"name": "geom", "description": "Geometry", "unit": "none" } ] } ],
	"metadata_version": "1.3"}';

-- metadata
COMMENT ON TABLE political_boundary.bkg_vg250_6_gem IS '{
	"title": "BKG - Verwaltungsgebiete 1:250.000 - Gemeinden (GEM)",
	"description": "Der Datenbestand umfasst die Verwaltungseinheiten der hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden",
	"language": [ "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "vector"},
	"temporal": 
		{"reference_date": "2016-01-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data", 
		"description": "Dieser Datenbestand steht über Geodatendienste gemäß Geodatenzugangsgesetz (GeoZG) (http://www.geodatenzentrum.de/auftrag/pdf/geodatenzugangsgesetz.pdf) für die kommerzielle und nicht kommerzielle Nutzung geldleistungsfrei zum Download und zur Online-Nutzung zur Verfügung. Die Nutzung der Geodaten und Geodatendienste wird durch die Verordnung zur Festlegung der Nutzungsbestimmungen für die Bereitstellung von Geodaten des Bundes (GeoNutzV) (http://www.geodatenzentrum.de/auftrag/pdf/geonutz.pdf) geregelt. Insbesondere hat jeder Nutzer den Quellenvermerk zu allen Geodaten, Metadaten und Geodatendiensten erkennbar und in optischem Zusammenhang zu platzieren. Veränderungen, Bearbeitungen, neue Gestaltungen oder sonstige Abwandlungen sind mit einem Veränderungshinweis im Quellenvermerk zu versehen. Quellenvermerk und Veränderungshinweis sind wie folgt zu gestalten. Bei der Darstellung auf einer Webseite ist der Quellenvermerk mit der URL http://www.bkg.bund.de zu verlinken. © GeoBasis-DE / BKG <Jahr des letzten Datenbezugs> © GeoBasis-DE / BKG <Jahr des letzten Datenbezugs> (Daten verändert) Beispiel: © GeoBasis-DE / BKG 2013", 
		"url": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"},
		{"name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)", 
		"description": "Der Datenbestand umfasst sämtliche Verwaltungseinheiten aller hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden mit ihren Verwaltungsgrenzen, statistischen Schlüsselzahlen und dem Namen der Verwaltungseinheit sowie der spezifischen Bezeichnung der Verwaltungsebene des jeweiligen Bundeslandes. ", 
		"url": "http://www.bkg.bund.de", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"} ],
	"license": 
		{"id": "",
		"name": "Gesetz über den Zugang zu digitalen Geodaten (Geodatenzugangsgesetz - GeoZG)",
		"version": "Geändert durch Art. 1 G v. 7.11.2012",
		"url": "http://www.gesetze-im-internet.de/bundesrecht/geozg/gesamt.pdf",
		"instruction": "",
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"},
	"contributors": [
		{"name": "Ludee", "email": "", "date": "2016-09-02", "comment": "Create table"},
		{"name": "Ludee", "email": "", "date": "2016-11-16", "comment": "Add metadata"},
		{"name": "Ludee", "email": "", "date": "2017-03-21", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "political_boundary.bkg_vg250_6_gem",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "reference_date", "description": "Reference date", "unit": "none"},
			{"name": "id", "description": "Unique identifier", "unit": "none"},
			{"name": "ade", "description": "Administrative Ebene", "unit": "none"},
			{"name": "gf", "description": "Geofaktor", "unit": "none"},
			{"name": "bsg", "description": "Besondere Gebiete", "unit": "none"},
			{"name": "rs", "description": "Regionalschlüssel", "unit": "none"},
			{"name": "ags", "description": "Amtlicher Gemeindeschlüssel", "unit": "none"},
			{"name": "sdv_rs", "description": "Sitz der Verwaltung (Regionalschlüssel)", "unit": "none"},
			{"name": "gen", "description": "Geografischer Name", "unit": "none"},
			{"name": "bez", "description": "Bezeichnung der Verwaltungseinheit", "unit": "none"},
			{"name": "ibz", "description": "Identifikator", "unit": "none"},
			{"name": "bem", "description": "Bemerkung", "unit": "none"},
			{"name": "nbd", "description": "Namensbildung", "unit": "none"},
			{"name": "sn_l", "description": "Land", "unit": "none"},
			{"name": "sn_r", "description": "Regierungsbezirk", "unit": "none"},
			{"name": "sn_k", "description": "Kreis", "unit": "none"},
			{"name": "sn_v1", "description": "Verwaltungsgemeinschaft - vorderer Teil", "unit": "none"},
			{"name": "sv_v2", "description": "Verwaltungsgemeinschaft - hinterer Teil", "unit": "none"},
			{"name": "sn_g", "description": "Gemeinde", "unit": "none"},
			{"name": "fk_s3", "description": "Funktion der 3. Schlüsselstelle", "unit": "none"},
			{"name": "nuts", "description": "Europäischer Statistikschlüssel", "unit": "none"},
			{"name": "rs_0", "description": "aufgefüllter Regionalschlüssel", "unit": "none"},
			{"name": "ags_0", "description": "aufgefüllter Amtlicher Gemeindeschlüssel", "unit": "none"},
			{"name": "wsk", "description": "Wirksamkeit", "unit": "none"},
			{"name": "debkg_id", "description": "DLM-Identifikator", "unit": "none"},
			{"name": "geom", "description": "Geometry", "unit": "none" } ] } ],
	"metadata_version": "1.3"}';


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','political_boundary','bkg_vg250_1_sta','ego_pp_vg250_metadata.sql','');
SELECT ego_scenario_log('v0.2.10','output','political_boundary','bkg_vg250_2_lan','ego_pp_vg250_metadata.sql','');
SELECT ego_scenario_log('v0.2.10','output','political_boundary','bkg_vg250_3_rbz','ego_pp_vg250_metadata.sql','');
SELECT ego_scenario_log('v0.2.10','output','political_boundary','bkg_vg250_4_krs','ego_pp_vg250_metadata.sql','');
SELECT ego_scenario_log('v0.2.10','output','political_boundary','bkg_vg250_5_vwg','ego_pp_vg250_metadata.sql','');
SELECT ego_scenario_log('v0.2.10','output','political_boundary','bkg_vg250_6_gem','ego_pp_vg250_metadata.sql','');
