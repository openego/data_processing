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
COMMENT ON TABLE supply.vernetzen_wind_potential_area IS '{
    "title": "VerNetzen - Wind potential Area",
    "description": "",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": "",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "http://www.uni-flensburg.de/fileadmin/content/abteilungen/industrial/dokumente/downloads/veroeffentlichungen/forschungsergebnisse/vernetzen-2016-endbericht-online.pdf",
            "name": "VerNetzen - Projektabschlussbericht",
            "copyright": " © VerNetzen",
            "description": "Sozial-ökologische und technisch-ökonomische Modellierung von Entwicklungspfaden der Energiewende"
        },
        {
            "url": "http://download.geofabrik.de/europe/germany.html#",
            "name": "OpenStreetMap",
            "copyright": " © OpenStreetMap contributors",
            "description": "Geofabrik - Download - OpenStreetMap Data Extracts"
        },
        {
            "url": "http://www.bkg.bund.de",
            "name": "Bundesamt für Kartographie und Geod\u00e4sie - Verwaltungsgebiete 1:250 000 (VG250)",
            "copyright": " © GeoBasis-DE / BKG 2015",
            "description": ""
        },
        {
            "url": "http://www.bkg.bund.de",
            "name": "Bundesamt für Kartographie und Geod\u00e4sie - Digitale Landschaftsmodell 1:250 000 (DLM250)",
            "copyright": " © GeoBasis-DE / BKG 2015",
            "description": ""
        },
        {
            "url": "https://www.bfn.de/karten.html",
            "name": "Schutzgebietsdaten - Bundesamt für Naturschutz, BfN",
            "copyright": " © Bundesamt für Naturschutz (BfN)",
            "description": "Datentr\u00e4ger zur Verfügung gestellt durch das BfN (30.06.2015)"
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": " © VerNetzen",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2016-08-01",
            "comment": "Create table",
            "name": "Ludee",
            "email": " "
        },
        {
            "date": "2017-03-07",
            "comment": "Add metadata",
            "name": "Ludee",
            "email": " "
        },
        {
            "date": "2017-03-28",
            "comment": "Update metadata",
            "name": "Ludee",
            "email": " "
        },
        {
            "date": "2017-8-10",
            "comment": "Update metadata to v1.3",
            "name": "KilianZimmerer",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "region_key",
                    "unit": "",
                    "description": "Unique identifier"
                },
                {
                    "name": "geom",
                    "unit": "",
                    "description": "Geometry"
                }
            ],
            "name": "supply.vernetzen_wind_potential_area",
            "format": "PostgreSQL"
        }
    ],
    "metadata_version": "1.3"
}';
