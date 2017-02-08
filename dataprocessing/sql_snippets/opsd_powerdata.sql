/*
Setup for OPSD power plants list

__copyright__ 	= "Europa-Universität Flensburg, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	    = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	    = "wolfbunke"
*/


-- OPSD powerplants based on beta version 

-- Table: supply.opsd_power_plants_germany
-- DROP TABLE supply.opsd_power_plants_germany;
/*
CREATE TABLE supply.opsd_power_plants_germany
(
  gid integer NOT NULL,
  bnetza_id text,
  company text,
  name text,
  postcode text,
  city text,
  street text,
  state text,
  block text,
  commissioned_original text,
  commissioned double precision,
  retrofit double precision,
  shutdown double precision,
  status text,
  fuel text,
  technology text,
  type text,
  eeg text,
  chp text,
  capacity double precision,
  capacity_uba double precision,
  chp_capacity_uba double precision,
  efficiency_data double precision,
  efficiency_estimate double precision,
  network_node text,
  voltage text,
  network_operator text,
  name_uba text,
  lat double precision,
  lon double precision,
  comment text,
  geom geometry(Point,4326),
  CONSTRAINT opsd_power_plants_germany_pkey PRIMARY KEY (gid)
);

-- set meta documentation

COMMENT ON TABLE  supply.opsd_power_plants_germany IS
'{
"Name": "Conventional power plants in Germany",
"Source": [{      "Name": "Open Power System Data (OPSD)",
                  "URL":  "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/" },
                 {"Name": "Bundesnetzagentur (BNetzA)",
                  "URL":  "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html" },
                 {"Name": "Umweltbundesamt (UBA)",
                  "URL":  "http://www.umweltbundesamt.de/dokument/datenbank-kraftwerke-in-deutschland" }],
"Reference date": "08.02.2016",
"Date of collection": "31.12.2015",
"Original file": "http://data.open-power-system-data.org/conventional_power_plants/opsd-conventional_power_plants-2016-03-08.zip",
"Spatial resolution": ["Germany"],
"Description": ["This dataset contains an augmented and corrected power plant list based on the power plant list provided by the BNetzA and UBA."],
"Column": [
                   {"Name": "gid",
                    "Description": "Geo ID",
                    "Unit": "" },
                   {"Name": "bnetza_id",
                    "Description": "Bundesnetzagentur unit ID",
                    "Unit": "" },     
                   {"Name": "company",
                    "Description": "Name of company",
                    "Unit": "" },     
                   {"Name": "name",
                    "Description": "name of unit",
                    "Unit": "" },     
                   {"Name": "postcode",
                    "Description": "postcode",
                    "Unit": "" },     
                   {"Name": "city",
                    "Description": "Name of City",
                    "Unit": "" },     
                   {"Name": "street",
                    "Description": "Street name, address",
                    "Unit": "" },
                   {"Name": "state",
                    "Description": "Name of federate state of location",
                    "Unit": "" },     
                   {"Name": "block",
                    "Description": "Power plant block",
                    "Unit": "" },     
                   {"Name": "commissioned_original",
                    "Description": "Year of commissioning (raw data)",
                    "Unit": "" },     
                   {"Name": "commissioned",
                    "Description": "Year of commissioning",
                    "Unit": "" },     
                   {"Name": "retrofit",
                    "Description": "Year of modernization according to UBA data",
                    "Unit": "" },     
                   {"Name": "shutdown",
                    "Description": "Year of decommissioning",
                    "Unit": "" },     
                   {"Name": "status",
                    "Description": "Power plant status",
                    "Unit": "" },     
                   {"Name": "fuel",
                    "Description": "Used fuel or energy source",
                    "Unit": "" },     
                   {"Name": "technology",
                    "Description": "Power plant technology or sort",
                    "Unit": "" },     
                   {"Name": "type",
                    "Description": "Purpose of the produced power",
                    "Unit": "" },     
                   {"Name": "eeg",
                    "Description": "Status of being entitled to a renumeration",
                    "Unit": "" },     
                   {"Name": "chp",
                    "Description": "Status of being able to supply heat",
                    "Unit": "" },     
                   {"Name": "capacity",
                    "Description": "Power capacity",
                    "Unit": "MW" },     
                   {"Name": "capacity_uba",
                    "Description": "Power capacity according to UBA data",
                    "Unit": "" },     
                   {"Name": "chp_capacity_uba",
                    "Description": "Heat capacity according to UBA data",
                    "Unit": "MW" },     
                   {"Name": "efficiency_data",
                    "Description": "Proportion between power output and input",
                    "Unit": "" },     
                   {"Name": "efficiency_estimate",
                    "Description": "Estimated proportion between power output and input",
                    "Unit": "" },     
                   {"Name": "network_node",
                    "Description": "Connection point to the electricity grid",
                    "Unit": "" },     
                   {"Name": "voltage",
                    "Description": "Grid or transformation level of the network node",
                    "Unit": "" },     
                   {"Name": "network_operator",
                    "Description": "Network operator of the grid or transformation level",
                    "Unit": "" },     
                   {"Name": "name_uba",
                    "Description": "Power plant name according to UBA data",
                    "Unit": "" },     
                   {"Name": "lat",
                    "Description": "Precise geographic coordinates - latitude",
                    "Unit": "" },     
                   {"Name": "lon",
                    "Description": "Precise geographic coordinates - longitude",
                    "Unit": "" },     
                   {"Name": "comment",
                    "Description": "Further comments",
                    "Unit": "" },                             
                   {"Name": "geom",
                    "Description": "Geometry Point",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Wolf-Dieter Bunke",
                    "Mail": "Wolf-dieter-bunke@uni-flensburg.de",
                    "Date":  "19.02.2016",
                    "Comment": "Add comments and structure" }
                  ],
"Notes": ["Primary data from BNetzA, BNetzA_PV, TransnetBW, TenneT, Amprion, 50Hertz, Netztransparenz.de,
 Postleitzahlen Deutschland, Energinet.dk, Energistyrelsen, GeoNames, French Ministery of the Environment, 
 Energy and the Sea, OpenDataSoft, Urzad Regulacji Energetyki (URE)"],
"Licence": [{
            "Name":		"Open Power System Data",
	          "URL":		"http://open-power-system-data.org/",
	          "Copyright": 	"ZNES EUF"}],
"Instructions for proper use": ["..."]
}';
*/

-- Json String test
-- SELECT obj_description('supply.opsd_power_plants_germany'::regclass)::json;



