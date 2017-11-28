/*
Metadata for gn250 tables
Geographische Namen 1:250 000 - GN250

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- metadata
COMMENT ON TABLE boundaries.bkg_gn250_p IS '{
	"title": "BKG - Geographische Namen 1:250 000 - GN250 - Darstellung als Punktgeometrie (Point)",
	"description": "Die Geographischen Namen beinhalten Namen der Objektbereiche Siedlung, Verkehr, Vegetation, Gewässer, Relief und Gebiete. Der Datensatz GN250 orientiert sich am Maßstab 1:250 000 und umfasst ca. 134.000 Einträge. Die Lage der Objekte wird jeweils als Punktgeometrie über eine einzelne Koordinate (Punktgeometrie) und über kleinste umschreibende Rechtecke (Bounding Boxes) beschrieben.",
	"language": [ "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "vector"},
	"temporal": 
		{"reference_date": "2015-12-31",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data - Geographische Namen 1:250 000 - GN250", 
		"description": "Die Geographischen Namen beinhalten Namen der Objektbereiche Siedlung, Verkehr, Vegetation, Gewässer, Relief und Gebiete.", 
		"url": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=20&gdz_user_id=0", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© Bundesamt für Kartographie und Geodäsie - Außenstelle Leipzig - Dienstleistungszentrum. Alle Rechte vorbehalten. "},
		{"name": "Bundesamt für Kartographie und Geodäsie - Geographische Namen 1:250 000 (GN250) - Dokumentation", 
		"description": "Datensatzbeschreibung als PDF", 
		"url": "http://sg.geodatenzentrum.de/web_download/gn/gn250/gn250.pdf", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"},
		{"name": "BKG - Geographische Namen 1:250 000 - GN250", 
		"description": "Der Datenbestand umfasst sämtliche Verwaltungseinheiten aller hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden mit ihren Verwaltungsgrenzen, statistischen Schlüsselzahlen und dem Namen der Verwaltungseinheit sowie der spezifischen Bezeichnung der Verwaltungsebene des jeweiligen Bundeslandes. ", 
		"url": "http://www.bkg.bund.de", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2017 (Daten verändert)"} ],
	"license": 
		{"id": "",
		"name": "Gesetz über den Zugang zu digitalen Geodaten (Geodatenzugangsgesetz - GeoZG)",
		"version": "Geändert durch Art. 1 G v. 7.11.2012",
		"url": "http://www.gesetze-im-internet.de/bundesrecht/geozg/gesamt.pdf",
		"instruction": "",
		"copyright": "© GeoBasis-DE / BKG 2017 (Daten verändert)"},
	"contributors": [
		{"name": "Ludee", "email": "", "date": "2017-07-03", "comment": "Create table"},
		{"name": "Ludee", "email": "", "date": "2017-07-03", "comment": "Add metadata v1.3"} ],
	"resources": [
		{"name": "boundaries.bkg_gn250_p",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "reference_date", "description": "Reference date", "unit": "none"},
			{"name": "id", "description": "Unique identifier", "unit": "none"},
			{"name": "nnid", "description": "Nationaler Namensidentifikator", "unit": ""},
			{"name": "datum", "description": "Datum der letzten Modifikation des Namensobjekts (TT.MM.JJJJ)", "unit": ""},
			{"name": "oba", "description": "Name der ATKIS-Objektart, der das Namensobjekt angehört", "unit": ""},
			{"name": "oba_wert", "description": "genauere Spezifizierung des Namensobjektes innerhalb der Objektart", "unit": ""},
			{"name": "name", "description": "Name des geographischen Namenobjekts (amtlicher Name der SPRACHE DEUTSCH)", "unit": ""},
			{"name": "sprache", "description": "Sprache, der NAME zuzuordnen ist", "unit": ""},
			{"name": "genus", "description": "Geschlecht, das NAME zugeordnet ist (m, f, n, p)", "unit": ""},
			{"name": "name2", "description": "Synonym des Objektnamens (u.a. sorbischer o. friesischer o. dänischer Name)", "unit": ""},
			{"name": "sprache2", "description": "Sprache, der NAME2 zuzuordnen ist", "unit": ""},
			{"name": "genus2", "description": "Geschlecht, das NAME2 zugeordnet ist (m, f, n, p)", "unit": ""},
			{"name": "zusatz", "description": "Namenszusatz (bei mehreren wird einer zufällig ausgewählt)", "unit": ""},
			{"name": "ags", "description": "Amtlicher Gemeindeschlüssel (Der AGS wird explizit für alle Gemeinden, Kreise, Regierungsbezirke und Bundesländer angegeben)", "unit": ""},
			{"name": "rs", "description": "Regionalschlüssel (Existiert für alle Verwaltungseinheiten Gemeindeteil, Gemeinde, Verwaltungsgemeinschaft, Kreis, Regierungsbezirk, Land, Staat)", "unit": ""},
			{"name": "hoehe", "description": "Höhe über NN (Meterangabe; für die Objektarten Ortslage und Besonderer Höhenpunkt)", "unit": "Meter"},
			{"name": "hoehe_ger", "description": "Gerechnete Höhe über NHN (Meterangabe; für die Objektart Ortslage)", "unit": "Meter"},
			{"name": "ewz", "description": "Einwohnerzahl von Gemeinden (Wird nur für Verwaltungseinheitenangegeben)", "unit": "Einwohner"},
			{"name": "ewz_ger", "description": "Gerechnete Einwohnerzahl für alle Ortslagen", "unit": ""},
			{"name": "gewk", "description": "Gewässerkennziffer (eindeutige Gewässerkennziffer nach Bund/Länder-Arbeitsgemeinschaft Wasser (LAWA))", "unit": ""},
			{"name": "gemteil", "description": "Ja/Nein (Ist Gemeindeteil oder nicht)", "unit": ""},
			{"name": "virtuell", "description": "Ja/Nein (Ist eine selbstständige Gemeinde ohne reale Ortslage oder nicht)", "unit": ""},
			{"name": "gemeinde", "description": "Name der Gemeinde (für Ortslagen, Gemeindeteile)", "unit": ""},
			{"name": "verwgem", "description": "Name der Verwaltungsgemeinschaft (für Ortslagen, Gemeindeteile, Gemeinden)", "unit": ""},
			{"name": "kreis", "description": "Name des Kreises (für Ortslagen, Gemeindeteile, Gemeinden, Verwaltungsgemeinschaften)", "unit": ""},
			{"name": "regbezirk", "description": "Name des Regierungsbezirks (für Ortslagen, Gemeindeteile, Gemeinden, Verwaltungsgemeinschaften, Kreise)", "unit": ""},
			{"name": "bundesland", "description": "Name des Bundeslandes (für Ortslagen, Gemeindeteile, Gemeinden, Verwaltungsgemeinschaften, Kreise, Regierungsbezirke)", "unit": ""},
			{"name": "staat", "description": "Zweibuchstaben-Code (ISO 3166, DIN-NABD 10.2 2-92)(für Ortslagen und Verwaltungseinheiten)", "unit": ""},
			{"name": "geola", "description": "Geographische Länge (Grad, Minuten, Sekunden (GGMMSS) )", "unit": ""},
			{"name": "geobr", "description": "Geographische Breite (Grad, Minuten, Sekunden (GGMMSS) )", "unit": ""},
			{"name": "gkre", "description": "Gauß-Krüger Rechtswert (m; vgl. Georeferenzierung unter Punkt 1 für Details)", "unit": ""},
			{"name": "gkho", "description": "Gauß-Krüger Hochwert (m; vgl. Georeferenzierung unter Punkt 1 für Details)", "unit": ""},
			{"name": "utmre", "description": "UTM Rechtswert (m, vgl. Georeferenzierung unter Punkt 1 für Details)", "unit": ""},
			{"name": "utmho", "description": "UTM Hochwert (m, vgl. Georeferenzierung unter Punkt 1 für Details)", "unit": ""},
			{"name": "box_geo", "description": "Kleinstes umschließendes Rechteck für das Objekt in geographischen Koordinaten, für Punktobjekte künstliches Rechteck 0,00001 Grad x 0,00001 Grad mit (GEOLA, GEOBR) als Mittelpunkt. OGC Well Known Text (WKT) Format", "unit": ""},
			{"name": "box_gk", "description": "Kleinstes umschließendes Rechteck für das Objekt in Gauß-Krüger-Koordinaten, für Punktobjekte künstliches Rechteck 1m x 1m mit (GKRE, GKHO) als Mittelpunkt. OGC Well Known Text (WKT) Format", "unit": ""},
			{"name": "box_utm", "description": "Kleinstes umschließendes Rechteck für das Objekt in UTM-Koordinaten, für Punktobjekte künstliches Rechteck 1m x 1m mit (UTMRE, UTMHO) als Mittelpunkt. OGC Well Known Text (WKT) Format", "unit": ""},
			{"name": "geom", "description": "Geometrie", "unit": ""} ] } ],
	"metadata_version": "1.3"}';


-- metadata
COMMENT ON TABLE boundaries.bkg_gn250_b IS '{
	"title": "BKG - Geographische Namen 1:250 000 - GN250 - Darstellung als Bounding-Boxes (Polygon)",
	"description": "Die Geographischen Namen beinhalten Namen der Objektbereiche Siedlung, Verkehr, Vegetation, Gewässer, Relief und Gebiete. Der Datensatz GN250 orientiert sich am Maßstab 1:250 000 und umfasst ca. 134.000 Einträge. Die Lage der Objekte wird jeweils als Punktgeometrie über eine einzelne Koordinate (Punktgeometrie) und über kleinste umschreibende Rechtecke (Bounding Boxes) beschrieben.",
	"language": [ "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "vector"},
	"temporal": 
		{"reference_date": "2015-12-31",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data - Geographische Namen 1:250 000 - GN250", 
		"description": "Die Geographischen Namen beinhalten Namen der Objektbereiche Siedlung, Verkehr, Vegetation, Gewässer, Relief und Gebiete.", 
		"url": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=20&gdz_user_id=0", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© Bundesamt für Kartographie und Geodäsie - Außenstelle Leipzig - Dienstleistungszentrum. Alle Rechte vorbehalten. "},
		{"name": "Bundesamt für Kartographie und Geodäsie - Geographische Namen 1:250 000 (GN250) - Dokumentation", 
		"description": "Datensatzbeschreibung als PDF", 
		"url": "http://sg.geodatenzentrum.de/web_download/gn/gn250/gn250.pdf", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2016 (Daten verändert)"},
		{"name": "BKG - Geographische Namen 1:250 000 - GN250", 
		"description": "Der Datenbestand umfasst sämtliche Verwaltungseinheiten aller hierarchischen Verwaltungsebenen vom Staat bis zu den Gemeinden mit ihren Verwaltungsgrenzen, statistischen Schlüsselzahlen und dem Namen der Verwaltungseinheit sowie der spezifischen Bezeichnung der Verwaltungsebene des jeweiligen Bundeslandes. ", 
		"url": "http://www.bkg.bund.de", 
		"license": "Geodatenzugangsgesetz (GeoZG)", 
		"copyright": "© GeoBasis-DE / BKG 2017 (Daten verändert)"} ],
	"license": 
		{"id": "",
		"name": "Gesetz über den Zugang zu digitalen Geodaten (Geodatenzugangsgesetz - GeoZG)",
		"version": "Geändert durch Art. 1 G v. 7.11.2012",
		"url": "http://www.gesetze-im-internet.de/bundesrecht/geozg/gesamt.pdf",
		"instruction": "",
		"copyright": "© GeoBasis-DE / BKG 2017 (Daten verändert)"},
	"contributors": [
		{"name": "Ludee", "email": "", "date": "2017-07-03", "comment": "Create table"},
		{"name": "Ludee", "email": "", "date": "2017-07-03", "comment": "Add metadata v1.3"} ],
	"resources": [
		{"name": "boundaries.bkg_gn250_b",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "reference_date", "description": "Reference date", "unit": "none"},
			{"name": "id", "description": "Unique identifier", "unit": "none"},
			{"name": "nnid", "description": "Nationaler Namensidentifikator", "unit": ""},
			{"name": "datum", "description": "Datum der letzten Modifikation des Namensobjekts (TT.MM.JJJJ)", "unit": ""},
			{"name": "oba", "description": "Name der ATKIS-Objektart, der das Namensobjekt angehört", "unit": ""},
			{"name": "oba_wert", "description": "genauere Spezifizierung des Namensobjektes innerhalb der Objektart", "unit": ""},
			{"name": "name", "description": "Name des geographischen Namenobjekts (amtlicher Name der SPRACHE DEUTSCH)", "unit": ""},
			{"name": "sprache", "description": "Sprache, der NAME zuzuordnen ist", "unit": ""},
			{"name": "genus", "description": "Geschlecht, das NAME zugeordnet ist (m, f, n, p)", "unit": ""},
			{"name": "name2", "description": "Synonym des Objektnamens (u.a. sorbischer o. friesischer o. dänischer Name)", "unit": ""},
			{"name": "sprache2", "description": "Sprache, der NAME2 zuzuordnen ist", "unit": ""},
			{"name": "genus2", "description": "Geschlecht, das NAME2 zugeordnet ist (m, f, n, p)", "unit": ""},
			{"name": "zusatz", "description": "Namenszusatz (bei mehreren wird einer zufällig ausgewählt)", "unit": ""},
			{"name": "ags", "description": "Amtlicher Gemeindeschlüssel (Der AGS wird explizit für alle Gemeinden, Kreise, Regierungsbezirke und Bundesländer angegeben)", "unit": ""},
			{"name": "rs", "description": "Regionalschlüssel (Existiert für alle Verwaltungseinheiten Gemeindeteil, Gemeinde, Verwaltungsgemeinschaft, Kreis, Regierungsbezirk, Land, Staat)", "unit": ""},
			{"name": "hoehe", "description": "Höhe über NN (Meterangabe; für die Objektarten Ortslage und Besonderer Höhenpunkt)", "unit": "Meter"},
			{"name": "hoehe_ger", "description": "Gerechnete Höhe über NHN (Meterangabe; für die Objektart Ortslage)", "unit": "Meter"},
			{"name": "ewz", "description": "Einwohnerzahl von Gemeinden (Wird nur für Verwaltungseinheitenangegeben)", "unit": "Einwohner"},
			{"name": "ewz_ger", "description": "Gerechnete Einwohnerzahl für alle Ortslagen", "unit": ""},
			{"name": "gewk", "description": "Gewässerkennziffer (eindeutige Gewässerkennziffer nach Bund/Länder-Arbeitsgemeinschaft Wasser (LAWA))", "unit": ""},
			{"name": "gemteil", "description": "Ja/Nein (Ist Gemeindeteil oder nicht)", "unit": ""},
			{"name": "virtuell", "description": "Ja/Nein (Ist eine selbstständige Gemeinde ohne reale Ortslage oder nicht)", "unit": ""},
			{"name": "gemeinde", "description": "Name der Gemeinde (für Ortslagen, Gemeindeteile)", "unit": ""},
			{"name": "verwgem", "description": "Name der Verwaltungsgemeinschaft (für Ortslagen, Gemeindeteile, Gemeinden)", "unit": ""},
			{"name": "kreis", "description": "Name des Kreises (für Ortslagen, Gemeindeteile, Gemeinden, Verwaltungsgemeinschaften)", "unit": ""},
			{"name": "regbezirk", "description": "Name des Regierungsbezirks (für Ortslagen, Gemeindeteile, Gemeinden, Verwaltungsgemeinschaften, Kreise)", "unit": ""},
			{"name": "bundesland", "description": "Name des Bundeslandes (für Ortslagen, Gemeindeteile, Gemeinden, Verwaltungsgemeinschaften, Kreise, Regierungsbezirke)", "unit": ""},
			{"name": "staat", "description": "Zweibuchstaben-Code (ISO 3166, DIN-NABD 10.2 2-92)(für Ortslagen und Verwaltungseinheiten)", "unit": ""},
			{"name": "geola", "description": "Geographische Länge (Grad, Minuten, Sekunden (GGMMSS) )", "unit": ""},
			{"name": "geobr", "description": "Geographische Breite (Grad, Minuten, Sekunden (GGMMSS) )", "unit": ""},
			{"name": "gkre", "description": "Gauß-Krüger Rechtswert (m; vgl. Georeferenzierung unter Punkt 1 für Details)", "unit": ""},
			{"name": "gkho", "description": "Gauß-Krüger Hochwert (m; vgl. Georeferenzierung unter Punkt 1 für Details)", "unit": ""},
			{"name": "utmre", "description": "UTM Rechtswert (m, vgl. Georeferenzierung unter Punkt 1 für Details)", "unit": ""},
			{"name": "utmho", "description": "UTM Hochwert (m, vgl. Georeferenzierung unter Punkt 1 für Details)", "unit": ""},
			{"name": "box_geo", "description": "Kleinstes umschließendes Rechteck für das Objekt in geographischen Koordinaten, für Punktobjekte künstliches Rechteck 0,00001 Grad x 0,00001 Grad mit (GEOLA, GEOBR) als Mittelpunkt. OGC Well Known Text (WKT) Format", "unit": ""},
			{"name": "box_gk", "description": "Kleinstes umschließendes Rechteck für das Objekt in Gauß-Krüger-Koordinaten, für Punktobjekte künstliches Rechteck 1m x 1m mit (GKRE, GKHO) als Mittelpunkt. OGC Well Known Text (WKT) Format", "unit": ""},
			{"name": "box_utm", "description": "Kleinstes umschließendes Rechteck für das Objekt in UTM-Koordinaten, für Punktobjekte künstliches Rechteck 1m x 1m mit (UTMRE, UTMHO) als Mittelpunkt. OGC Well Known Text (WKT) Format", "unit": ""},
			{"name": "geom", "description": "Geometrie", "unit": ""} ] } ],
	"metadata_version": "1.3"}';


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','boundaries','bkg_gn250_p','ego_pp_gn250_metadata.sql','metadata');
SELECT ego_scenario_log('v0.2.10','output','boundaries','bkg_gn250_b','ego_pp_gn250_metadata.sql','metadata');
