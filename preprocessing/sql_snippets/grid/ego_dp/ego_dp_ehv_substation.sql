-- metadata
COMMENT ON TABLE grid.ego_dp_ehv_substation IS '{
    "title": "eGo dataprocessing - EHV(HV) Substation",
    "description": "Abstracted substation between extrahigh- and high voltage (Transmission substation)",
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
        "copyright": "\u00a9 NEXT ENERGY",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "20.10.2016",
            "comment": "Create substations",
            "name": "lukasol",
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
                    "name": "subst_name",
                    "unit": "",
                    "description": "name of substation"
                },
                {
                    "name": "ags_0",
                    "unit": "",
                    "description": "Geimeindeschl\u00fcssel, municipality key"
                },
                {
                    "name": "voltage",
                    "unit": "",
                    "description": "(all) voltage levels contained in substation"
                },
                {
                    "name": "power_type",
                    "unit": "",
                    "description": "value of osm key power"
                },
                {
                    "name": "substation",
                    "unit": "",
                    "description": "value of osm key substation"
                },
                {
                    "name": "osm_id",
                    "unit": "",
                    "description": "osm id of substation, begins with prefix n(node) or w(way)"
                },
                {
                    "name": "osm_www",
                    "unit": "",
                    "description": "hyperlink to osm source"
                },
                {
                    "name": "frequency",
                    "unit": "",
                    "description": "frequency of substation"
                },
                {
                    "name": "ref",
                    "unit": "",
                    "description": "reference tag of substation"
                },
                {
                    "name": "operator",
                    "unit": "",
                    "description": "operator(s) of substation"
                },
                {
                    "name": "dbahn",
                    "unit": "",
                    "description": "states if substation is connected to railway grid and if yes the indicator"
                },
                {
                    "name": "status",
                    "unit": "",
                    "description": "states the osm source of substation (1=way, 2=way intersected by 110kV-line, 3=node)"
                },
                {
                    "name": "otg_id",
                    "unit": "",
                    "description": "states the id of respective bus in osmtgmod"
                },
                {
                    "name": "lat",
                    "unit": "",
                    "description": "latitude of substation"
                },
                {
                    "name": "lon",
                    "unit": "",
                    "description": "longitude of substation"
                },
                {
                    "name": "point",
                    "unit": "",
                    "description": "point geometry of substation"
                },
                {
                    "name": "polygon",
                    "unit": "",
                    "description": "original geometry of substation"
                },
                {
                    "name": "geom",
                    "unit": "",
                    "description": "geometry"
                }
            ],
            "name": "grid.ego_dp_ehv_substation",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';
