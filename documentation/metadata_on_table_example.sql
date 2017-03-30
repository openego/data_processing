/*
This script provides an SQL example of the metadata documentation
A definition of metadata can be found in the openmod glossary http://wiki.openmod-initiative.org/wiki/Metadata
A further description can be found on http://wiki.openmod-initiative.org/wiki/DatabaseRules

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
__contains__	= "http://stackoverflow.com/questions/383692/what-is-json-and-why-would-i-use-it"
*/


-- metadata
COMMENT ON TABLE schema.table IS '{
	"title": "Good example title",
	"description": "example metadata for example data",
	"language": [ "eng", "ger", "fre" ],
	"reference_date": "2016-01-01",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": " ", "description": " ", "url": " ", "license": " ", "copyright": " "} ],
	"spatial": [
		{"extend": "europe",
		"resolution": "100m"} ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Reiner Lemoine Institut"} ],
	"contributors": [
		{"name": "Ludee", "email": " ", "date": "16.06.2016", "comment": "created metadata"},
		{"name": "Ludee", "email": " ", "date": "22.11.2016", "comment": "updated metadata"},
		{"name": "Ludee", "email": " ", "date": "22.11.2016", "comment": "updated header and license"},
		{"name": "Ludee", "email": " ", "date": "16.03.2017", "comment": "add license to source"},
		{"name": "Ludee", "email": " ", "date": "28.03.2017", "comment": "add copyright to source and license"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "id", "description": "Unique identifier", "unit": "" },
				{"name": "year", "description": "Reference year", "unit": "" },
				{"name": "geom", "description": "Geometry", "unit": "" } ]},
		"meta_version": "1.2" }] }';

-- select description
SELECT obj_description('schema.table' ::regclass) ::json;
