/*
SQL Script which sets the metadata on table

__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"
  
*/

--
COMMENT ON TABLE supply.ego_dp_res_powerplant
  IS '{
	"title": "Renewable power plants in Germany by Scenario",
	"description": "Liste of renewable power plants in Germany by Scenario status quo, NEP 2035 and 2050 of the eGo project",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "Germany",
		"extent": "Europe",
		"resolution": "100m"},
	"temporal": 
		{"reference_date": "2016-01-01",
		"start": "1900-01-01",
		"end": "2049-12-31",
		"resolution": ""},
	"sources": [
		{"name": "eGo data processing", 
		"description": "Scripts with allocate Geometry by OpenStreetMap Objects or create future scenarios by high resolution geo-allocation", 
		"url": "https://github.com/openego/data_processing", 
		"license": "GNU Affero General Public License Version 3 (AGPL-3.0)", 
		"copyright": "© ZNES Europa-Universität Flensburg"},
		
		{"name": "EnergyMap.info ", 
		"description": "Data provider how collects and clean TSO and DSO data of Germany", 
		"url": "http://www.energymap.info/download.html", 
		"license": "unknown ", 
		"copyright": "Deutsche Gesellschaft für Sonnenenergie e.V."},
		
		{"name": "Bundesnetzagentur (BNetzA)", 
		"description": "The Federal Network Agency for Electricity, Gas, Telecommunications, Posts and Railway Data is in Germany data provider of power plant", 
		"url": "https://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/ErneuerbareEnergien/Anlagenregister/Anlagenregister_Veroeffentlichung/Anlagenregister_Veroeffentlichungen_node.html", 
		"license": "Creative Commons Namensnennung-Keine Bearbeitung 3.0 Deutschland Lizenz", 
		"copyright": "© Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen; Pressestelle"}
	        ],
	"license": 
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "©  ZNES Europa-Universität Flensburg"},
	"contributors": [
		{"name": "wolfbunke", "email": " ", 
		"date": "01.06.2017", "comment": "Create and restructure scripts and table"}],
	"resources": [
		{"name": "model_draft.ego_dp_supply_res_powerplant",		
		"format": "PostgreSQL",
		"fields": [
			    {"name": "version", "description": "version number of eGo data processing", "unit": "" },
				{"name": "id", "description": "Unique identifier", "unit": "" },
				{"name": "start_up_date", "description": "start_up date of unit", "unit": "" },
				{"name": "electrical_capacity", "description": "electrical capacity", "unit": "kW" },
				{"name": "generation_type", "description": "generation_type or main fuel type", "unit": "" },
				{"name": "generation_subtype", "description": "generation subtype", "unit": "" },
				{"name": "thermal_capacity", "description": "", "unit": "kW" },
				{"name": "city", "description": "Name of city or location", "unit": "" },
				{"name": "postcode", "description": "postcode", "unit": "" },
				{"name": "address", "description": "address", "unit": "" },
				{"name": "lon", "description": "longitude", "unit": "" },
				{"name": "lat", "description": "latitude", "unit": "" },
				{"name": "gps_accuracy", "description": "gps accuracy in meter", "unit": "" },
				{"name": "validation", "description": "validation comments", "unit": "" },
				{"name": "notification_reason", "description": "notification reason from BNetzA sources", "unit": "" },
				{"name": "eeg_id", "description": "EEG id of Unit", "unit": "" },
				{"name": "tso", "description": "Name of Transmission system operator", "unit": "" },
				{"name": "tso_eic", "description": "Name of Transmission system operator", "unit": "" },
				{"name": "dso_id", "description": "Name of District system operator", "unit": "" },
				{"name": "dso", "description": "Name of District system operator", "unit": "" },
				{"name": "voltage_level_var", "description": "German voltage level ", "unit": "" },
				{"name": "network_node", "description": "Name or code of network node", "unit": "" },
				{"name": "power_plant_id", "description": "Power plant id from BNetzA", "unit": "" },
				{"name": "source", "description": "Short Name of source: energymap or bnetza", "unit": "" },
				{"name": "comment", "description": "Further comment of changes", "unit": "" },
				{"name": "geom", "description": "Geometry", "unit": "" },
				{"name": "subst_id", "description": "Unique identifier of related substation", "unit": "" },
				{"name": "otg_id", "description": "Unique identifier of related substation from osmTGmod", "unit": "" },
				{"name": "un_id", "description": "Unique identifier of RES and CONV power plants", "unit": "" },
				{"name": "voltage_level", "description": "voltage level as number code", "unit": "" },
				{"name": "la_id", "description": "Unique identifier of related .... ???", "unit": "" },                               
				{"name": "mvlv_subst_id", "description": "Unique identifier of related ... ???", "unit": "" },
				{"name": "rea_sort", "description": "res sort entry", "unit": "" },
				{"name": "rea_flag", "description": "Flag comment of rea method", "unit": "" },
				{"name": "rea_geom_line", "description": "Geometry line between original and processed data", "unit": "" },
				{"name": "rea_geom_new", "description": "Geometry of new position", "unit": "" },	
				{"name": "preversion", "description": "preversion number of eGo data preprocessing", "unit": "" },			
				{"name": "scenario", "description": "Name of scenario", "unit": "" },
				{"name": "flag", "description": "Flag of scenario changes of an power plant unit (repowering, decommission or commissioning).", "unit": "" },
				{"name": "nuts", "description": "NUTS ID", "unit": "" } ] } ],		
	"metadata_version": "1.3"}';
-- select description
SELECT obj_description('supply.ego_dp_res_powerplant'::regclass)::json;	

---
COMMENT ON TABLE supply.ego_dp_conv_powerplant
  IS '{
	"title": "eGo Conventional power plants in Germany by Scenario",
	"description": "This dataset contains an augmented and corrected power plant list based on the power plant list provided by the OPSD (BNetzA and UBA) and NEP Kraftwerksliste 2015 for the scenario B1-2035 and the ZNES scenario eGo 100 in 2050.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "Germany",
		"extent": "europe",
		"resolution": "100 m"},
	"temporal": 
		{"reference_date": "2016-01-01",
		"start": "1900-01-01",
		"end": "2049-12-31",
		"resolution": ""},
	"sources": [
		{"name": "eGo data processing", 
		"description": "Scripts with allocate Geometry by OpenStreetMap Objects or create future scenarios by high resolution geo-allocation", 
		"url": "https://github.com/openego/data_processing", 
		"license": "GNU Affero General Public License Version 3 (AGPL-3.0)", 
		"copyright": "© ZNES Europa-Universität Flensburg"},
		
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
	"license": 
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© ZNES Europa-Universität Flensburg"},
	"contributors": [
		{"name": "wolfbunke", "email": " ", "date": "01.06.2017", "comment": "Create and restructure scripts and table"}],
	"resources": [
		{"name": "model_draft.ego_dp_supply_conv_powerplant",		
		"format": "PostgreSQL",
		"fields": [
				{"name": "version", "description": "version number of eGo data processing", "unit": "" },
				{"name": "gid", "description": "Unique identifier", "unit": "" },
				{"name": "bnetza_id", "description": "Bundesnetzagentur unit ID", "unit": " " },			
				{"name": "company", "description": "Name of company", "unit": " " },				
				{"name": "name", "description": "name of unit ", "unit": " " },				
				{"name": "postcode", "description": "postcode ", "unit": " " },				
				{"name": "city", "description": "Name of City", "unit": " " },				
				{"name": "street", "description": "Street name, address", "unit": " " },				
				{"name": "state", "description": "Name of federate state of location", "unit": " " },				
				{"name": "block", "description": "Power plant block", "unit": " " },	
				{"name": "commissioned_original", "description": "Year of commissioning (raw data)", "unit": " " },	
				{"name": "commissioned", "description": "Year of commissioning", "unit": " " },	
				{"name": "retrofit", "description": "Year of modernization according to UBA data", "unit": " " },	
				{"name": "shutdown", "description": "Year of decommissioning", "unit": " " },	
				{"name": "status", "description": "Power plant status", "unit": " " },	
				{"name": "fuel", "description": "Used fuel or energy source", "unit": " " },	
				{"name": "technology", "description": "Power plant technology or sort", "unit": " " },	
				{"name": "type", "description": "Purpose of the produced power", "unit": " " },	
				{"name": "eeg", "description":  "Status of being entitled to a renumeration", "unit": " " },	
				{"name": "chp", "description": "Status of being able to supply heat", "unit": " " },	
				{"name": "capacity", "description": "Power capacity", "unit": " " },	
				{"name": "capacity_uba", "description": "Power capacity according to UBA data", "unit": " " },
				{"name": "chp_capacity_uba", "description":  "Heat capacity according to UBA data", "unit": " " },	
				{"name": "efficiency_data", "description": "Proportion between power output and input", "unit": " " },	
				{"name": "efficiency_estimate", "description": "Estimated proportion between power output and input", "unit": " " },
				{"name": "network_node", "description":  "Connection point to the electricity grid", "unit": " " },
				{"name": "voltage", "description": "Grid or transformation level of the network node", "unit": " " },
				{"name": "network_operator", "description": "Network operator of the grid or transformation level", "unit": " " },
				{"name": "name_uba", "description": "Power plant name according to UBA data", "unit": " " },
				{"name": "lat", "description": "Precise geographic coordinates - latitude", "unit": " " },
				{"name": "lon", "description": "Precise geographic coordinates - longitude", "unit": " " },
				{"name": "comment", "description": "Further comments", "unit": " " },
				{"name": "geom", "description": "Geometry Point", "unit": " " },
				{"name": "voltage_level", "description": " ", "unit": " " },
				{"name": "subst_id", "description": "Unique identifier of related substation", "unit": "" },
				{"name": "otg_id", "description": "Unique identifier of related substation from osmTGmod", "unit": "" },
				{"name": "un_id", "description": "Unique identifier of RES and CONV power plants", "unit": "" },
				{"name": "la_id", "description": "Unique identifier of RES and CONV power plants", "unit": "" },									
				{"name": "scenario", "description": "Name of scenario", "unit": "" },
				{"name": "preversion", "description": "Preversion ID of eGo data preprocessing", "unit": "" },
				{"name": "flag", "description": "Flag of scenario changes of an power plant unit (repowering, decommission or commissioning).", "unit": "" },
				{"name": "nuts", "description": "NUTS ID", "unit": ""} ] } ],
		"meta_version": "1.3" }';

-- select description
SELECT obj_description('supply.ego_dp_conv_powerplant'::regclass)::json;
