-- metadata
COMMENT ON TABLE demand.ego_dp_loadarea IS '{
    "title": "eGo dataprocessing - Loadarea",
    "description": "Loadarea with electrical consumption per sector",
    "language": [ "eng", "ger" ],
    "spatial": {
        "resolution": " ",
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
            "copyright": "© Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "© OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://www.geodatenzentrum.de/",
            "copyright": "© GeoBasis-DE / BKG 2016 (data changed)",
            "name": "BKG - Verwaltungsgebiete 1:250.000 (vg250)",
            "license": "Geodatenzugangsgesetz (GeoZG)",
            "description": " "
        },
        {
            "url": "https://www.destatis.de/DE/Methoden/Zensus_/Zensus.html",
            "copyright": "© Statistisches Bundesamt, Wiesbaden, Genesis-Online, 2016; Datenlizenz by-2-0",
            "name": "Statistisches Bundesamt (Destatis) - Zensus2011",
            "license": "Datenlizenz Deutschland - Namensnennung - Version 2.0",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "© Reiner Lemoine Institut",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "02.10.2016",
            "comment": "Create loadareas",
            "name": "Ludee",
            "email": " "
        },
        {
            "date": "25.10.2016",
            "comment": "Create metadata",
            "name": "Ilka Cussmann",
            "email": " "
        },
        {
            "date": "15.01.2017",
            "comment": "Update metadata",
            "name": "Ludee",
            "email": " "
        },
        {
            "date": "21.03.2017",
            "comment": "Update metadata to 1.1",
            "name": "Ludee",
            "email": " "
        },
        {
            "date": "2017-03-21",
            "comment": "Update metadata to 1.2",
            "name": "Ludee",
            "email": " "
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
                    "description": "Version id"
                },
                {
                    "name": "id",
                    "unit": "",
                    "description": "Unique identifier"
                },
                {
                    "name": "subst_id",
                    "unit": "",
                    "description": "Substation id"
                },
                {
                    "name": "area_ha",
                    "unit": "ha",
                    "description": "Area"
                },
                {
                    "name": "nuts",
                    "unit": "",
                    "description": "Nuts id"
                },
                {
                    "name": "rs_0",
                    "unit": "",
                    "description": "Geimeindeschl\u00fcssel, municipality key"
                },
                {
                    "name": "ags_0",
                    "unit": "",
                    "description": "Geimeindeschl\u00fcssel, municipality key"
                },
                {
                    "name": "otg_id",
                    "unit": "",
                    "description": "States the id of respective bus in osmtgmod"
                },
                {
                    "name": "zensus_sum",
                    "unit": "",
                    "description": "Population"
                },
                {
                    "name": "zensus_count",
                    "unit": "",
                    "description": "Number of population rasters"
                },
                {
                    "name": "zensus_density",
                    "unit": "",
                    "description": "Average population per raster (zensus_sum/zensus_count)"
                },
                {
                    "name": "sector_area_residential",
                    "unit": "ha",
                    "description": "Aggregated residential area"
                },
                {
                    "name": "sector_area_retail",
                    "unit": "ha",
                    "description": "Aggregated retail area"
                },
                {
                    "name": "sector_area_industrial",
                    "unit": "ha",
                    "description": "Aggregated industrial area"
                },
                {
                    "name": "sector_area_agricultural",
                    "unit": "ha",
                    "description": "Aggregated agricultural area"
                },
                {
                    "name": "sector_area_sum",
                    "unit": "ha",
                    "description": "Aggregated sector area"
                },
                {
                    "name": "sector_share_residential",
                    "unit": "",
                    "description": "Percentage of residential area per load area"
                },
                {
                    "name": "sector_share_retail",
                    "unit": "",
                    "description": "Percentage of retail area per load area"
                },
                {
                    "name": "sector_share_industrial",
                    "unit": "",
                    "description": "Percentage of industrial area per load area"
                },
                {
                    "name": "sector_share_agricultural",
                    "unit": "",
                    "description": "Percentage of agricultural area per load area"
                },
                {
                    "name": "sector_share_sum",
                    "unit": "",
                    "description": "Percentage of sector area per load area"
                },
                {
                    "name": "sector_count_residential",
                    "unit": "",
                    "description": "Number of residential areas per load area"
                },
                {
                    "name": "sector_count_retail",
                    "unit": "",
                    "description": "Number of retail areas per load area"
                },
                {
                    "name": "sector_count_industrial",
                    "unit": "",
                    "description": "Number of industrial areas per load area"
                },
                {
                    "name": "sector_count_agricultural",
                    "unit": "",
                    "description": "Number of agricultural areas per load area"
                },
                {
                    "name": "sector_count_sum",
                    "unit": "",
                    "description": "Number of sector areas per load area"
                },
                {
                    "name": "sector_consumption_residential",
                    "unit": "GWh",
                    "description": "Electricity consumption of residential sector"
                },
                {
                    "name": "sector_consumption_retail",
                    "unit": "GWh",
                    "description": "Electricity consumption of retail sector"
                },
                {
                    "name": "sector_consumption_industrial",
                    "unit": "GWh",
                    "description": "Electricity consumption of industrial sector"
                },
                {
                    "name": "sector_consumption_agricultural",
                    "unit": "GWh",
                    "description": "Electricity consumption of agricultural sector"
                },
                {
                    "name": "sector_consumption_sum",
                    "unit": "GWh",
                    "description": "Electricity consumption of ALL sectorS"
                },
                {
                    "name": "geom_centroid",
                    "unit": "",
                    "description": "Centroid (can be outside the polygon)"
                },
                {
                    "name": "geom_surfacepoint",
                    "unit": "",
                    "description": "Point on surface"
                },
                {
                    "name": "geom_centre",
                    "unit": "",
                    "description": "Centroid and point on surface when centroid outside the polygon"
                },
                {
                    "name": "geom",
                    "unit": "",
                    "description": "Geometry"
                }
            ],
            "name": "demand.ego_dp_loadarea",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';
