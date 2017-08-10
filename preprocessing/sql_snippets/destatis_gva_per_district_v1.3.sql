-- metadata 
COMMENT ON TABLE economy.destatis_gva_per_district IS '{
    "title": "Gross value added per district in Germany",
    "description": "Gross value added per administrative district for the business sectors industry and tertiary sector",
    "language": [ "eng", "ger" ],
    "spatial": {
        "resolution": "District (Kreis)",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": "2011",
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
            "url": "https://www.destatis.de/DE/Publikationen/Thematisch/VolkswirtschaftlicheGesamtrechnungen/VGRderLaender/VGR_KreisergebnisseBand1.html",
            "copyright": " ",
            "name": "Statistisches Bundesamt (Destatis)- VGR der Länder",
            "license": " ",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "© Flensburg University of Applied Sciences",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2016-10-05",
            "comment": "Create table",
            "name": "Mario Kropshofer",
            "email": "mario.kropshofer2@stud.fh-flensburg.de"
        },
        {
            "date": "2016-10-25",
            "comment": "Complete metadata",
            "name": "Ilka Cussmann",
            "email": "ilka.cussmann@hs-flensburg.de"
        },
        {
            "date": "2017-03-30",
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
                    "name": "eu_code",
                    "unit": " ",
                    "description": "Nuts id for district"
                },
                {
                    "name": "district",
                    "unit": " ",
                    "description": "District name"
                },
                {
                    "name": "total_gva",
                    "unit": "Million Euro",
                    "description": "Total gross value added per district"
                },
                {
                    "name": "gva_industry",
                    "unit": "Million Euro",
                    "description": "Gross value added of industry per district"
                },
                {
                    "name": "gva_tertiary_sector",
                    "unit": "Million Euro",
                    "description": "Gross value added of tertiary sector per district"
                }
            ],
            "name": "economy.destatis_gva_per_district",
            "format": "PostgreSQL"
        }
    ],
    "metadata_version": "1.3"
}';
