/*
Setup for OPSD power plants list.

__copyright__ 	= "Europa-Universität Flensburg, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	    = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	    = "wolfbunke"
*/


-- OPSD powerplants based on beta version 

-- Table: supply.ego_conventional_powerplant
-- DROP supply.ego_conventional_powerplant;

CREATE TABLE supply.ego_conventional_powerplant
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
  CONSTRAINT ego_conventional_powerplant_pkey PRIMARY KEY (gid)
);

-- set meta documentation

COMMENT ON TABLE  supply.ego_conventional_powerplant IS
'{
	"title": "eGo Conventional power plants in Germany",
	"description": "This dataset contains an augmented and corrected power plant list based on the power plant list provided by the BNetzA and UBA.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "Germany",
		"extent": "europe",
		"resolution": "100 m"},
	"temporal": 
		{"reference_date": "2016-02-08",
		"start": "1900-01-01",
		"end": "2015-12-31",
		"resolution": ""},
	"sources": [
		{"name": "Open Power System Data (OPSD)",
                "url":  "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
                "license": "Creative Commons Attribution 4.0 International", 
		"copyright": "© Open Power System Data. 2017"}, 

		{"name": "Bundesnetzagentur (BNetzA)", 
		"description": "The Federal Network Agency for Electricity, Gas, Telecommunications, Posts and Railway Data is in Germany data provider of power plant", 
		"url": "https://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/ErneuerbareEnergien/Anlagenregister/Anlagenregister_Veroeffentlichung/Anlagenregister_Veroeffentlichungen_node.html", 
		"license": "Creative Commons Namensnennung-Keine Bearbeitung 3.0 Deutschland Lizenz", 
		"copyright": "© Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen; Pressestelle"}
		 ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© ZNES Europa-Universität Flensburg"} ],
	"contributors": [
		{"name": "wolfbunke", "email": " ", "date": "01.06.2017", "comment": "Create and restructure scripts and table"}],
	"resources": [
		{"name": "model_draft.ego_dp_supply_conv_powerplant",		
		"format": "PostgreSQL",
		"fields": [
                   {"name": "gid", "description": "Geo ID", "unit": "" },
                   {"name": "bnetza_id", "description": "Bundesnetzagentur unit ID", "unit": "" },
                   {"name": "company", "description": "name of company","unit": "" },
                   {"name": "name", "description": "name of unit","unit": "" },
                   {"name": "postcode", "description": "postcode", "unit": "" },
                   {"name": "city", "description": "name of City","unit": "" },
                   {"name": "street", "description": "Street name, address","unit": "" },
                   {"name": "state", "description": "name of federate state of location","unit": "" },
                   {"name": "block", "description": "Power plant block","unit": "" },
                   {"name": "commissioned_original", "description": "Year of commissioning (raw data)", "unit": "" },
                   {"name": "commissioned","description": "Year of commissioning", "unit": "" },
                   {"name": "retrofit",   "description": "Year of modernization according to UBA data", "unit": "" },
                   {"name": "shutdown", "description": "Year of decommissioning", "unit": "" },
                   {"name": "status","description": "Power plant status", "unit": "" },
                   {"name": "fuel", "description": "Used fuel or energy source","unit": "" },
                   {"name": "technology",  "description": "Power plant technology or sort","unit": "" },
                   {"name": "type","description": "Purpose of the produced power","unit": "" },
                   {"name": "eeg", "description": "Status of being entitled to a renumeration", "unit": "" },
                   {"name": "chp", "description": "Status of being able to supply heat","unit": "" },
                   {"name": "capacity",  "description": "Power capacity","unit": "MW" },
                   {"name": "capacity_uba",  "description": "Power capacity according to UBA data","unit": "" },
                   {"name": "chp_capacity_uba", "description": "Heat capacity according to UBA data","unit": "MW" },
                   {"name": "efficiency_data",  "description": "Proportion between power output and input","unit": "" },
                   {"name": "efficiency_estimate",  "description": "Estimated proportion between power output and input", "unit": "" },
                   {"name": "network_node",  "description": "Connection point to the electricity grid","unit": "" },
                   {"name": "voltage", "description": "Grid or transformation level of the network node","unit": "" },
                   {"name": "network_operator", "description": "Network operator of the grid or transformation level","unit": "" },
                   {"name": "name_uba","description": "Power plant name according to UBA data","unit": "" },
                   {"name": "lat",  "description": "Precise geographic coordinates - latitude","unit": "" },
                   {"name": "lon", "description": "Precise geographic coordinates - longitude","unit": "" },
                   {"name": "comment", "description": "Further comments", "unit": "" },
                   {"name": "geom", "description": "Geometry Point", "unit": "" } ] } ],
	"meta_version": "1.3" }';

-- Json String test
SELECT obj_description('supply.ego_conventional_powerplant'::regclass)::json;



