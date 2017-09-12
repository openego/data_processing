-- metadata 
COMMENT ON TABLE demand.ego_demand_federalstate IS '{
    "title": "Electricity consumption per federal state in Germany",
    "description": "Electricity consumption of the sectors households, industry and tertiary sector (including others) for the German federal states in 2011",
    "language": [ "eng", "ger" ],
    "spatial": {
        "resolution": "Federal state",
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
            "url": "http://www.lak-energiebilanzen.de/seiten/energiebilanzenLaender.cfm",
            "copyright": " ",
            "name": "Länderarbeitskreis Energiebilanzen",
            "license": " ",
            "description": " "
        },
        {
            "url": "http://www.stmwi.bayern.de/fileadmin/user_upload/stmwivt/Themen/Energie_und_Rohstoffe/Dokumente_und_Cover/Energiebilanz/2014/B-03_bilanzjo_mgh_2014-03-07.pdf",
            "copyright": " ",
            "name": "Bayerisches Landesamt für Statistik und Datenverarbeitung",
            "license": " ",
            "description": " "
        },
        {
            "url": "http://www.statistik-hessen.de/publikationen/download/277/index.html",
            "copyright": " ",
            "name": "Hessisches Statistisches Landesamt",
            "license": " ",
            "description": " "
        },
        {
            "url": "https://www.destatis.de/GPStatistik/servlets/MCRFileNodeServlet/MVHeft_derivate_00000168/E453_2011_00a.pdf;jsessionid=CD300CD3A06FF85FDEA864FF4D91D880",
            "copyright": " ",
            "name": "Statistisches Amt Mecklenburg-Vorpommern",
            "license": " ",
            "description": " "
        },
        {
            "url": "http://www.umwelt.niedersachsen.de/energie/daten/co2bilanzen/niedersaechsische-energie--und-co2-bilanzen-2009-6900.html",
            "copyright": " ",
            "name": "Niedersächsisches Ministerium für Umwelt, Energie und Klimaschutz",
            "license": " ",
            "description": " "
        },
        {
            "url": "https://webshop.it.nrw.de/gratis/E449%20201100.pdf",
            "copyright": " ",
            "name": "Information und Technik Nordrhein-Westfalen",
            "license": " ",
            "description": " "
        },
        {
            "url": "http://www.stala.sachsen-anhalt.de/download/stat_berichte/6E402_j_2011.pdf",
            "copyright": " ",
            "name": "Statistisches Landesamt Sachsen-Anhalt",
            "license": " ",
            "description": " "
        },
        {
            "url": "http://www.statistik.thueringen.de/webshop/pdf/2011/05402_2011_00.pdf",
            "copyright": " ",
            "name": "Thüringer Landesamt für Statistik",
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
            "Date": "2016-10-24",
            "Comment": "Add json-string",
            "Name": "Ilka Cussmann",
            "email": "ilka.cussmann@hs-flensburg.de"
        },
        {
            "Date": "2016-03-13",
            "Comment": "Rectify incorrect entries",
            "Name": "Ilka Cussmann",
            "email": "ilka.cussmann@hs-flensburg.de"
        },
        {
            "date": "2017-03-30",
            "comment": "Update metadata",
            "name": "Ludee",
            "email": " "
        },
        {
            "date": "2017-09-12",
            "comment": "Update metadata to v1.3",
            "name": "KilianZimmerer",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "Name": "eu_code",
                    "unit": "",
                    "description": "Nuts code for federal state"
                },
                {
                    "Name": "federal_states",
                    "unit": "",
                    "description": "Name of federal state in Germany"
                },
                {
                    "Name": "elec_consumption_housholds",
                    "unit": "GWh",
                    "description": "Annual electricity consumption in the household sector"
                },
                {
                    "Name": "elec_consumption_industry",
                    "unit": "GWh",
                    "description": "Annual electricity consumption in the industrial sector"
                },
                {
                    "Name": "elec_consumption_tertiary_sector",
                    "unit": "GWh",
                    "description": "Annual electricity consumption in the tertiary sector including public sector"
                },
                {
                    "Name": "population",
                    "unit": "",
                    "description": "Inhabitants per federal state"
                },
                {
                    "Name": "elec_consumption_households_per_person",
                    "unit": "GWh",
                    "description": "Electricity consumption of household sector per inhabitant"
                }
            ],
            "name": "demand.ego_demand_federalstate",
            "format": "PostgreSQL"
        }
    ],
    "metadata_version": "1.3"
}';
