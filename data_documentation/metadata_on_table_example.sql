/*
This script provides an SQL example of the metadata documentation
A definition of metadata can be found in the openmod glossary http://wiki.openmod-initiative.org/wiki/Metadata
A further description can be found on http://wiki.openmod-initiative.org/wiki/DatabaseRules
*/

-- metadata
COMMENT ON TABLE schema.table IS '{
	"title":"Good example title",
	"description":"example metadata for example data",
	"keywords":["example", "test", "meta"],
	"sources": [{
		"name":"Website",
		"description":"Data website",
		"url":"www.website.com"}],
	"spatial": [{
		"extend":"europe",
		"resolution":"100mx100m"}],
	"license": [{
		"id":"GPL-3.0",
		"name":"GNU General Public License 3.0",
		"version":"3.0",
		"url":"https://opensource.org/licenses/GPL-3.0",
		"instruction":""}],
	"contributors": [
		{"name":"Ludwig Hülk",
		"email":"ludwig.huelk@rl-institut.de",
		"date":"16.06.2016",
		"comment":"created metadata"},
		{"name":"Ludwig Hülk",
		"email":"ludwig.huelk@rl-institut.de",
		"date":"22.11.2016",
		"comment":"updated metadata"}],
	"notes":"use this example",
	"resources": [{
		"schema": {
			"fields": [
				{"name":"id",
				"description":"unique identifier",
				"unit":"" },
				{"name":"year",
				"description":"reference year",
				"unit":"" }
				]  } }] }';

-- select description
SELECT obj_description('schema.table' ::regclass) ::json;
