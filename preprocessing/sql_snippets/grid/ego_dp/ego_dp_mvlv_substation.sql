/*
A description of the module (short but could be more than one line).
Modules names should have short, all-lowercase names. 
The module name may have underscores if this improves readability.

__copyright__ 	= "Copyright Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "KilianZimmerer"
__contains__	= "url"
*/

-- metadata
COMMENT ON TABLE grid.ego_dp_mvlv_substation IS '{
    "title": "eGo dataprocessing - HVMV Substation",
    "description": "Abstracted substation between medium- and low voltage (Distribution substation)",
    "language": [ "eng", "ger" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Gemany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://www.geodatenzentrum.de/",
            "copyright": "\u00a9 GeoBasis-DE / BKG 2016 (Data changed)",
            "name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)",
            "license": "Geodatenzugangsgesetz (GeoZG)",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\u00a9 Reiner Lemoine Institut",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "20.10.2016",
            "comment": "Create table",
            "name": "jong42",
            "email": ""
        },
        {
            "date": "27.10.2016",
            "comment": "Change table names",
            "name": "jong42",
            "email": ""
        },
        {
            "date": "15.01.2017",
            "comment": "Update metadata",
            "name": "Ludee",
            "email": ""
        },
        {
            "date": "21.03.2017",
            "comment": "Update metadata to 1.1",
            "name": "Ludee",
            "email": ""
        },
        {
            "date": "2017-04-06",
            "comment": "Update metadata to 1.2",
            "name": "Ludee",
            "email": ""
        },
        {
            "date": "2017-9-12",
            "comment": "Update metadata to v1.3",
            "name": "KilianZimmerer",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "version",
                    "unit": "",
                    "description": "version id"
                },
                {
                    "name": "subst_id",
                    "unit": "",
                    "description": "unique identifier"
                },
                {
                    "name": "mvgd_id",
                    "unit": "",
                    "description": "corresponding hvmv substation"
                },
                {
                    "name": "geom",
                    "unit": "",
                    "description": "geometry"
                }
            ],
            "name": "grid.ego_dp_mvlv_substation",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';
