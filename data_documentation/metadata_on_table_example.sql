/*
This script provides an SQL example of the metadata documentation
A definition of metadata can be found in the openmod glossary http://wiki.openmod-initiative.org/wiki/Metadata
A further description can be found on http://wiki.openmod-initiative.org/wiki/DatabaseRules

Copyright (C) 2016  open_eGo project
Published under GNU General Public License 3.0 (GPL-3.0)
see https://github.com/openego/data_processing/blob/master/LICENSE
*/

-- metadata
COMMENT ON TABLE schema.table IS '{
	"title": "Good example title",
	"description": "example metadata for example data",
	"language": [ "eng", "ger", "fre" ],
	"reference_date": "2016-01-24",
	"sources": [
		{"name": "Website",
		"url": "www.website.com"},
		{"name": "Website",
		"url": "www.website.com"} ],
	"spatial": [
		{"extend": "europe",
		"resolution": "100mx100m"} ],
	"license": [
		{"id": "GPL-3.0",
		"name": "GNU General Public License 3.0",
		"version": "3.0",
		"url": "https://opensource.org/licenses/GPL-3.0",
		"instruction": "You may copy, distribute and modify the software as long as you track changes/dates in source files. Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions."} ],
	"contributors": [
		{"name": "Ludwig Hülk",
		"email": "ludwig.huelk@rl-institut.de",
		"date": "16.06.2016",
		"comment": "created metadata"},
		{"name": "Ludwig Hülk",
		"email": "ludwig.huelk@rl-institut.de",
		"date": "22.11.2016",
		"comment": "updated metadata"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "id",
				"description": "unique identifier",
				"unit": "" },
				{"name": "year",
				"description": "reference year",
				"unit": "" }
				]  },
		"meta_version": "1.0"}] }';

-- select description
SELECT obj_description('schema.table' ::regclass) ::json;
