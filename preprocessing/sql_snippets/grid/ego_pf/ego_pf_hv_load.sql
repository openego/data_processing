-- metadata
COMMENT ON TABLE grid.ego_pf_hv_load IS
'{
    "title": "eGo hv powerflow - loads",
    "description": "loads in eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
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
            "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
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
            "url": "http://www.lak-energiebilanzen.de/seiten/energiebilanzenLaender.cfm",
            "copyright": " ",
            "name": "L\u00e4nderarbeitskreis Energiebilanzen",
            "license": " ",
            "description": " "
        },
        {
            "url": "http://www.stmwi.bayern.de/fileadmin/user_upload/stmwivt/Themen/Energie_und_Rohstoffe/Dokumente_und_Cover/Energiebilanz/2014/B-03_bilanzjo_mgh_2014-03-07.pdf",
            "copyright": " ",
            "name": "Bayerisches Landesamt f\u00fcr Statistik und Datenverarbeitung",
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
            "name": "Nieders\u00e4chsisches Ministerium f\u00fcr Umwelt, Energie und Klimaschutz",
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
            "name": "Th\u00fcringer Landesamt f\u00fcr Statistik",
            "license": " ",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "26.04.2017",
            "comment": "Create table",
            "name": "IlkaCu",
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
                    "name": "scn_name",
                    "unit": "",
                    "description": "name of corresponding scenario"
                },
                {
                    "name": "load_id",
                    "unit": "",
                    "description": "unique id"
                },
                {
                    "name": "bus",
                    "unit": "",
                    "description": "id of associated bus"
                },
                {
                    "name": "sign",
                    "unit": "",
                    "description": "power sign"
                },
                {
                    "name": "e_annual",
                    "unit": "GWh",
                    "description": "annual electricity consumption"
                }
            ],
            "name": "grid.ego_pf_hv_load",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';
