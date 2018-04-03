/*
This script creates and fills a table with information in the electricity demand per federalstate for the consumption sectors household, industry and tertiary sector. 

__copyright__ 	= "Flensburg University of Applied Sciences"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu"
*/

-- DROP TABLE demand.ego_demand_federalstate CASCADE;

CREATE TABLE demand.ego_demand_federalstate
(
  eu_code character varying(7) NOT NULL,
  federal_states character varying,
  elec_consumption_households double precision,
  elec_consumption_industry double precision,
  elec_consumption_tertiary_sector double precision,
  population integer,
  elec_consumption_households_per_person double precision,
  CONSTRAINT ego_demand_federalstate_pkey PRIMARY KEY (eu_code)
);

ALTER TABLE demand.ego_demand_federalstate
  OWNER TO oeuser;


COMMENT ON TABLE demand.ego_demand_federalstate
  IS '{
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
        },
	{
            "url": "https://www.zensus2011.de/SharedDocs/Aktuelles/Ergebnisse/DemografischeGrunddaten.html?nn=3065474",
            "copyright": "© Statistisches Bundesamt, Wiesbaden 2014",
            "name": "Ergebnisse des Zensus am 9. Mai 2011",
            "license": " ",
            "description": "Als Download bieten wir Ihnen auf dieser Seite zusätzlich zur Zensusdatenbank CSV- und teilweise Excel-Tabellen mit umfassenden Personen-, Haushalts- und Familien- sowie Gebäude- und Wohnungs­merkmalen. Die Ergebnisse liegen auf Bundes-, Länder-, 			Kreis- und Gemeinde­ebene vor. Außerdem sind einzelne Ergebnisse für Gitterzellen verfügbar."
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
        },
        {
            "date": "2018-03-28",
            "comment": "Correct wrong entries, update sources",
            "name": "IlkaCu",
            "email": "ilka.cussmann@hs-flensburg.de"
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


INSERT INTO demand.ego_demand_federalstate (eu_code, federal_states, elec_consumption_households, elec_consumption_industry, elec_consumption_tertiary_sector, population) VALUES
   ('DE000', 'Deutschland', NULL, NULL, NULL, NULL), 
   ('DE100', 'Baden-Württemberg', 17142, 28742, 20952, 10486660),
   ('DE200', 'Bayern', 21408, 34521, 26166, 12397614), 
   ('DE300', 'Berlin', 4238, 1988, 4654, 3292365), 
   ('DE400', 'Brandenburg', 3210, 7118, 4191, 2455780), 
   ('DE500', 'Bremen', 993, 2370, 1213, 650863), 
   ('DE600', 'Hamburg', 3821, 4678, 3994, 1706696), 
   ('DE700', 'Hessen', 10540, 11694, 12882, 5971816), 
   ('DE800', 'Mecklenburg-Vorpommern', 1955, 1797, 2472, 1609981), 
   ('DE900', 'Niedersachsen', 12142, 24093, 13665, 7777992), 
   ('DEA00', 'Nordrhein-Westfalen', 30203, 63682, 26360, 17538252), 
   ('DEB00', 'Rheinland-Pfalz', 6707, 15419, 5542, 3989808), 
   ('DEC00', 'Saarland', 1667, 4339, 2037, 999623), 
   ('DED00', 'Sachsen', 5260, 9535, 5643, 4056799), 
   ('DEE00', 'Sachsen-Anhalt', 3146, 9771, 1995, 2287040), 
   ('DEF00', 'Schleswig-Holstein', 5716, 3767, 4481, 2800119), 
   ('DEG00', 'Thüringen', 2847, 6180, 3669, 2188589); 


UPDATE demand.ego_demand_federalstate
   SET  elec_consumption_households = 
   	(SELECT sum(a.elec_consumption_households) FROM demand.ego_demand_federalstate a WHERE eu_code != 'DE000')
   WHERE eu_code = 'DE000'; 

UPDATE demand.ego_demand_federalstate
   SET  elec_consumption_industry = 
   	(SELECT sum(a.elec_consumption_industry) FROM demand.ego_demand_federalstate a WHERE eu_code != 'DE000')
   WHERE eu_code = 'DE000'; 

UPDATE demand.ego_demand_federalstate
   SET  elec_consumption_tertiary_sector = 
   	(SELECT sum(a.elec_consumption_tertiary_sector) FROM demand.ego_demand_federalstate a WHERE eu_code != 'DE000')
   WHERE eu_code = 'DE000'; 

UPDATE demand.ego_demand_federalstate
   SET  population = 
   	(SELECT sum(a.population) FROM demand.ego_demand_federalstate a WHERE eu_code != 'DE000')
   WHERE eu_code = 'DE000'; 


UPDATE demand.ego_demand_federalstate a
   SET elec_consumption_households_per_person = a.elec_consumption_households/a.population; 

