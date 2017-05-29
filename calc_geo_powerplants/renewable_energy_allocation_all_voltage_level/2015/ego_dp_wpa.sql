
-- metadata
COMMENT ON TABLE supply.soethe_wind_potential_area IS '{
	"title": "eGoDP_REA - wpa per mv-griddistrict",
	"description": "potential areas for wind power plants - Wind Potential Area (wpa)",
	"language": [ "eng" ],
	"reference_date": "",
	"sources": [
		{"name": "VerNetzen - Projektabschlussbericht","description": "Sozial-ökologische und technisch-ökonomische Modellierung von Entwicklungspfaden der Energiewende","url": "http://www.uni-flensburg.de/fileadmin/content/abteilungen/industrial/dokumente/downloads/veroeffentlichungen/forschungsergebnisse/vernetzen-2016-endbericht-online.pdf"},
		{"name": "OpenStreetMap","description": "Geofabrik - Download - OpenStreetMap Data Extracts","url": "http://download.geofabrik.de/europe/germany.html#"},
		{"name": "Bundesamt für Kartographie und Geodäsie - Digitale Landschaftsmodell 1:250 000 (DLM250)","description": "© GeoBasis-DE / BKG 2015","url": "http://www.bkg.bund.de"},
		{"name": "Bundesamt für Naturschutz - Schutzgebiete in Deutschland","description": "","url": "https://www.bfn.de/karten.html"} ],
	"spatial": [
		{"extend": "Germany",
		"resolution": ""} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!"} ],
	"contributors": [
		{"name": "Ludwig Hülk",	"email": "ludwig.huelk@rl-institut.de",
		"date": "01.08.2016", "comment": "Create table"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "07.03.2017", "comment": "Add metadata"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "region_key", "description": "unique identifier", "unit": "" },
				{"name": "geom", "description": "Geometry", "unit": "" }]},
		"meta_version": "1.0"}] }';

-- select description
SELECT obj_description('supply.soethe_wind_potential_area' ::regclass) ::json;
