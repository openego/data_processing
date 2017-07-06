/*
Import DESTATIS zensus 2011 table

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- metadata
COMMENT ON TABLE social.destatis_zensus_population_per_ha IS '{
	"title": "DESTATIS - Zensus 2011 - Population per hectar",
	"description": "National census in Germany in 2011",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "1 ha"},
	"temporal": 
		{"reference_date": "2011",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Statistisches Bundesamt (Destatis) - Ergebnisse des Zensus 2011 zum Download", 
		"description": "Als Download bieten wir Ihnen auf dieser Seite zusätzlich zur Zensusdatenbank CSV- und teilweise Excel-Tabellen mit umfassenden Personen-, Haushalts- und Familien- sowie Gebäude- und Wohnungs­merkmalen. Die Ergebnisse liegen auf Bundes-, Länder-, Kreis- und Gemeinde­ebene vor. Außerdem sind einzelne Ergebnisse für Gitterzellen verfügbar.", 
		"url": "https://www.zensus2011.de/SharedDocs/Aktuelles/Ergebnisse/DemografischeGrunddaten.html;jsessionid=E0A2B4F894B258A3B22D20448F2E4A91.2_cid380?nn=3065474", 
		"license": "", 
		"copyright": "© Statistische Ämter des Bundes und der Länder 2014"},
		{"name": "Dokumentation - Zensus 2011 - Methoden und Verfahren", 
		"description": "Diese Publikation beschreibt ausführlich die Methoden und Verfahren des registergestützten Zensus 2011; von der Datengewinnung und -aufbereitung bis hin zur Ergebniserstellung und Geheimhaltung. Der vorliegende Band wurde von den Statistischen Ämtern des Bundes und der Länder im Juni 2015 veröffentlicht.", 
		"url": "https://www.destatis.de/DE/Publikationen/Thematisch/Bevoelkerung/Zensus/ZensusBuLaMethodenVerfahren5121105119004.pdf?__blob=publicationFile", 
		"license": "Vervielfältigung und Verbreitung, auch auszugsweise, mit Quellenangabe gestattet.", 
		"copyright": "© Statistisches Bundesamt, Wiesbaden, 2015 (im Auftrag der Herausgebergemeinschaft)"} ],
	"license": 
		{"id": "dl-de/by-2-0",
		"name": "Datenlizenz by-2-0",
		"version": "2.0",
		"url": "www.govdata.de/dl-de/by-2-0",
		"instruction": "Empfohlene Zitierweise des Quellennachweises: Datenquelle: Statistisches Bundesamt, Wiesbaden, Genesis-Online, <optional> Abrufdatum; Datenlizenz by-2-0. Quellenvermerk bei eigener Berechnung / Darstellung: Datenquelle: Statistisches Bundesamt, Wiesbaden, Genesis-Online, <optional> Abrufdatum; Datenlizenz by-2-0; eigene Berechnung/eigene Darstellung. In elektronischen Werken ist im Quellenverweis dem Begriff (Datenlizenz by-2-0) der Link www.govdata.de/dl-de/by-2-0 als Verknüpfung zu hinterlegen.",
		"copyright": "Statistisches Bundesamt, Wiesbaden, Genesis-Online; Datenlizenz by-2-0; eigene Berechnung"},
	"contributors": [
		{"name": "Ludee", "email": "", "date": "2016-02-03", "comment": "Create table"},
		{"name": "Ludee", "email": "", "date": "2016-10-25", "comment": "Moved table and add metadata"},
		{"name": "Ludee", "email": "", "date": "2017-06-30", "comment": "Update metadata to v1.3"} ],
	"resources": [
		{"name": "social.destatis_zensus_population_per_ha",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "gid",	"description": "Unique identifier", "unit": "none"},
			{"name": "grid_id", "description": "Grid number of source", "unit": "none"},
			{"name": "x_mp", "description": "Latitude of centroid in (ETRS89 - LAEA; EPSG:3035)", "unit": "none"},
			{"name": "y_mp", "description": "Longitude of centroid in (ETRS89 - LAEA; EPSG:3035)", "unit": "none"},
			{"name": "population", "description": "Number of registred residents", "unit": "resident"},
			{"name": "geom_point", "description": "Geometry centroid", "unit": "none"},
			{"name": "geom", "description": "Geometry", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','preprocessing','social','destatis_zensus_population_per_ha','ego_pp_destatis_zensus_import.sql','metadata');
