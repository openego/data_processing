/*
This script provides an SQL example of the metadata documentation
A definition of metadata can be found in the openmod glossary http://wiki.openmod-initiative.org/wiki/Metadata
A further description can be found on http://wiki.openmod-initiative.org/wiki/DatabaseRules

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

-- metadata
COMMENT ON TABLE schema.table IS '{
	"title": "Good example title",
	"description": "example metadata for example data",
	"language": [ "eng", "ger", "fre" ],
	"reference_date": "2016-01-24",
	"sources": [
		{"name": "Website","description": "Data website","url": "www.website.com"},
		{"name": "Website","description": "Data website","url": "www.website.com"} ],
	"spatial": [
		{"extend": "europe",
		"resolution": "100mx100m"} ],
	"license": [
		{"id": "tba",
		"name": "tba",
		"version": "tba",
		"url": "tba",
		"instruction": "tba"} ],
	"contributors": [
		{"name": "Ludwig Hülk",	"email": "ludwig.huelk@rl-institut.de",
		"date": "16.06.2016", "comment": "created metadata"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "22.11.2016", "comment": "updated metadata"},
		{"name": "Ludwig Hülk", "email": "ludwig.huelk@rl-institut.de",
		"date": "22.11.2016", "comment": "updated header and license"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "id", "description": "unique identifier", "unit": "" },
				{"name": "year", "description": "reference year", "unit": "" } ]},
		"meta_version": "1.0"}] }';

-- select description
SELECT obj_description('schema.table' ::regclass) ::json;
