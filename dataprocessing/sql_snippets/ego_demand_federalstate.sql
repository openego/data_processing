/*
Setup for table demand.ego_demand_federalstate		

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/



-- CREATE TABLE demand.ego_demand_federalstate
-- ( 
--   eu_code character varying(7) NOT NULL, 
--   federal_states character varying NOT NULL, 
--   elec_consumption_households double precision NOT NULL, 
--   elec_consumption_industry double precision NOT NULL, 
--   elec_consumption_tertiary_sector double precision NOT NULL, ‐‐ Commercial, trading, public buildings etc. 
-- PRIMARY KEY (eu_code) 
-- ) 
-- ; 

CREATE TABLE demand.ego_demand_federalstate AS
	SELECT * FROM orig_ego_consumption.lak_consumption_per_federalstate; 

COMMENT ON TABLE  demand.ego_demand_federalstate IS
'{
"Name": "Electricity consumption per federal state in Germany",
"Source": [{
                  "Name": "Länderarbeitskreis Energiebilanzen",
                  "URL":  "http://www.lak-energiebilanzen.de/seiten/energiebilanzenLaender.cfm" }, 
		{
                  "Name": "Statistisches Landesamt Baden-Württemberg",
                  "URL":  "http://www.lak-energiebilanzen.de/seiten/download/Archiv%20Bilanzen/Baden-W%C3%BCrttemberg/2011/Energiebilanz%20BadenW%C3%BCrttemberg2011.pdf" }, 
		{
                  "Name": "Amt für Statistik Berlin-Brandenburg",
                  "URL":  "http://www.lak-energiebilanzen.de/seiten/download/Archiv%20Bilanzen/Berlin/2011/Energiebilanz%20Berlin%202011.pdf" }, 
		{
                  "Name": "Amt für Statistik Berlin-Brandenburg",
                  "URL":  "http://www.lak-energiebilanzen.de/seiten/download/Archiv%20Bilanzen/Brandenburg/2011/Energiebilanz%20Brandenburg%202011.pdf" }, 
		{
                  "Name": "Statistisches Landesamt Bremen",
                  "URL":  "http://www.lak-energiebilanzen.de/seiten/download/Archiv%20Bilanzen/Bremen/2011/Energiebilanz%20Bremen%202011.pdf" },
		{
                  "Name": "Statistisches Amt für Hamburg und Schleswig-Holstein",
                  "URL":  "www.lak-energiebilanzen.de/seiten/download/Archiv Bilanzen/Hamburg/2011/Energiebilanz Hamburg 2011.pdf" },
		{
                  "Name": "Statistisches Amt für Hamburg und Schleswig-Holstein",
                  "URL":  "http://www.lak-energiebilanzen.de/seiten/download/Archiv%20Bilanzen/Schleswig-Holstein/2011/Energiebilanz%20SchleswigHolstein%202011.pdf" },
		{
                  "Name": "Statistisches Landesamt Rheinland-Pfalz",
                  "URL":  "http://www.lak-energiebilanzen.de/seiten/download/Archiv%20Bilanzen/Rheinland-Pfalz/2011/Energiebilanz%20RheinlandPfalz%202011.pdf" },
		{
                  "Name": "Statistisches Amt Saarland",
                  "URL":  "http://www.lak-energiebilanzen.de/seiten/download/Archiv%20Bilanzen/Saarland/2011/Energiebilanz%20Saarland%202011.pdf" },
		{
                  "Name": "Statistisches Landesamt Sachsen",
                  "URL":  "http://www.lak-energiebilanzen.de/seiten/download/Archiv%20Bilanzen/Sachsen/2011/Energiebilanz%20Sachsen%202011.pdf" },
		{
                  "Name": "Bayerisches Landesamt für Statistik und Datenverarbeitung",
                  "URL":  "http://www.stmwi.bayern.de/fileadmin/user_upload/stmwivt/Themen/Energie_und_Rohstoffe/Dokumente_und_Cover/Energiebilanz/2014/B-03_bilanzjo_mgh_2014-03-07.pdf" }, 
		{
                  "Name": "Hessisches Statistisches Landesamt",
                  "URL":  "http://www.statistik-hessen.de/publikationen/download/277/index.html" }, 
		{
                  "Name": "Statistisches Amt Mecklenburg-Vorpommern",
                  "URL":  "https://www.destatis.de/GPStatistik/servlets/MCRFileNodeServlet/MVHeft_derivate_00000168/E453_2011_00a.pdf;jsessionid=CD300CD3A06FF85FDEA864FF4D91D880" }, 
		{
                  "Name": "Niedersächsisches Ministerium für Umwelt, Energie und Klimaschutz",
                  "URL":  "http://www.umwelt.niedersachsen.de/energie/daten/co2bilanzen/niedersaechsische-energie--und-co2-bilanzen-2009-6900.html" }, 
		{
                  "Name": "Information und Technik Nordrhein-Westfalen",
                  "URL":  "https://webshop.it.nrw.de/gratis/E449%20201100.pdf" }, 
		{
                  "Name": "Statistisches Landesamt Sachsen-Anhalt",
                  "URL":  "http://www.stala.sachsen-anhalt.de/download/stat_berichte/6E402_j_2011.pdf" }, 
		{
                  "Name": "Thüringer Landesamt für Statistik",
                  "URL":  "http://www.statistik.thueringen.de/webshop/pdf/2011/05402_2011_00.pdf" },
		{
                  "Name": "Statistisches Bundesamt, Wiesbaden, Genesis-Online, Datenlizenz by-2-0.",
                  "URL":  "https://ergebnisse.zensus2011.de/" }],

"Reference date": "2011",
"Date of collection": "November 2015",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Electricity consumption of the sectors households, industry and tertiary sector (including others) for the German federal states in 2011"],
"Column": [
                   {"Name": "eu_code",
                    "Description": "Nuts code for federal state",
                    "Unit": "" },
                   {"Name": "federal_states",
                    "Description": "Name of federal state in Germany",
                    "Unit": "" },
                   {"Name": "elec_consumption_housholds",
                    "Description": "Annual electricity consumption in the household sector",
                    "Unit": "GWh" },
                   {"Name": "elec_consumption_industry",
                    "Description": "Annual electricity consumption in the industrial sector",
                    "Unit": "GWh" },
                   {"Name": "elec_consumption_tertiary_sector",
                    "Description": "Annual electricity consumption in the tertiary sector including public sector",
                    "Unit": "GWh" },
                   {"Name": "population",
                    "Description": "Inhabitants per federal state",
                    "Unit": "" },
                   {"Name": "elec_consumption_households_per_person",
                    "Description": "Electricity consumption of household sector per inhabitant",
                    "Unit": "GWh" }],
"Changes":[
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "24.10.2016",
                    "Comment": "Add json-string" }, 

                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "01.02.2017",
                    "Comment": "Add licence" },
                  ],
"ToDo": [""],
"Licence": ["
	"Name":		"Open Database License (ODbL) v1.0",
	"URL":		"http://opendatacommons.org/licenses/odbl/1.0/",
	"Copyright": 	"Flensburg University of Applied Sciences""],
"Instructions for proper use": [""]
}';
