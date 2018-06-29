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
	"description": "Liste of renewable power plants in Germany by Scenario status quo, NEP 2035 and eGo100 Scenario of the eGo project",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "Germany",
		"extent": "Europe",
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
		
		{"name": "Renewable power plants from netztransparenz.de provided by the four TSOs of Germany", 
		"description": "Original Data Anlagenstammdaten from the four german TSOs", 
		"url": "https://www.netztransparenz.de/EEG/Anlagenstammdaten", 
		"license": "Open Database License (ODbL) v1.0", 
		"copyright": "© 50Hertz Transmission GmbH,  Amprion GmbH, TransnetBW GmbH, TenneT TSO GmbH"},
		
		{"name": "Open-Power-System-Data Renewable power plants DE", 
		"description": "Open Power System Data. 2018. Data Package Renewable power plants. Version 2018-03-08. Data provider how collects and clean TSO, DSO data and other energy data of Germany and Europe", 
		"url": "https://data.open-power-system-data.org/renewable_power_plants/2018-03-08/", 
		"license": "MIT", 
		"copyright": "© Open-Power-System-Data, Europa-Universität Flensburg"},
		
		{"name": "EEG-Anlagenstammdaten (außer PV-Gebäudeanlagen), Bundesnetzagentur (BNetzA)", 
		"description": "The Federal Network Agency for Electricity, Gas, Telecommunications, Posts and Railway Data is in Germany data provider of power plant.", 
		"url": "https://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/ErneuerbareEnergien/ZahlenDatenInformationen/EEG_Registerdaten/EEG_Registerdaten_node.html", 
		"license": "Deutschland – Namensnennung – Version 2.0", 
		"copyright": "© Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen; Pressestelle"},
		
		{"name": "PV-Datenmeldungen (außer PV-Freiflächenanlagen), Bundesnetzagentur (BNetzA)", 
		"description": "The Federal Network Agency for Electricity, Gas, Telecommunications, Posts and Railway Data is in Germany data provider of power plant.", 
		"url": "https://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/ErneuerbareEnergien/ZahlenDatenInformationen/EEG_Registerdaten/EEG_Registerdaten_node.html", 
		"license": "Deutschland – Namensnennung – Version 2.0", 
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
		"date": "2017-11-06", "comment": "Create and restructure scripts and table"}],
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
	"description": "This dataset contains an augmented and corrected power plant list based on the power plant list provided by the OPSD (BNetzA and UBA) and NEP Kraftwerksliste 2015 for the scenario B1-2035 and the ZNES scenario eGo 100 of the open_eGo project.",
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
		
		{"name": "Conventional power plants DE", 
		"description": "Open Power System Data. 2018. Data Package Conventional power plants. Version 2018-02-27. Data provider how collects and clean TSO, DSO data and other energy data of Germany and Europe", 
		"url": "https://data.open-power-system-data.org/conventional_power_plants/2018-02-27/", 
		"license": "MIT", 
		"copyright": "© Open-Power-System-Data, TU Berlin"},
		
		{"name": "Kraftwerke in Deutschland 100MW", 
		"description": "Open Power System Data. 2018. Data Package Renewable power plants. Version 2018-03-08. Data provider how collects and clean TSO, DSO data and other energy data of Germany and Europe", 
		"url": "https://www.umweltbundesamt.de/dokument/datenbank-kraftwerke-in-deutschland", 
		"license": "in clarification processes", 
		"copyright": "© Umweltbundesamt (UBA)"},
			 
		{"name": "Bundesnetzagentur (BNetzA)", 
		"description": "The Federal Network Agency for Electricity, Gas, Telecommunications, Posts and Railway Data is in Germany data provider of power plant", 
		"url": "https://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/ErneuerbareEnergien/Anlagenregister/Anlagenregister_Veroeffentlichung/Anlagenregister_Veroeffentlichungen_node.html", 
		"license": "Deutschland – Namensnennung – Version 2.0", 
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
		{"name": "wolfbunke", "email": " ", "date": "2017-11-06", "comment": "Create and restructure scripts and table"}],
	"resources": [
		{"name": "model_draft.ego_dp_supply_conv_powerplant",		
		"format": "PostgreSQL",
		"fields": [
				{"name": "version", "description": "version number of eGo data processing", "unit": "" },
				{"name": "id", "description": "Unique identifier", "unit": "" },
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

---
COMMENT ON TABLE supply.ego_renewable_feedin IS '{
	"title": "Renewable feedin time series for eGo",
	"description": "Renewable feedin timeseries for each weather cell of the open_eGo Scenarios",
	"language": ["eng"],
	"spatial": 
		{"location": "Germany and its electrical neighbours and Baltic Sea/North Sea",
		"extent": "",
		"resolution": "Coastdat2 weather cells"},
	"temporal": 
		{"reference_date": "2011",
		"start": "",
		"end": "",
		"resolution": "hours"},
	"sources": [
		{"name": "open_eGo preprocessing", 
		"description": "", 
		"url": "https://github.com/openego/data_processing/tree/master/preprocessing", 
		"license": "GNU Affero General Public License Version 3 (AGPL-3.0)", 
		"copyright": "open_eGo Team"},
		{"name": "coastDat-2 Hindcast", 
		"description": "Closed input data of coastDat-2 Hindcast", 
		"url": "http://www.coastdat.de/data/index.php", 
		"license": "Copyright", 
		"copyright": "Helmholtz-Zentrum Geesthacht Zentrum für Material- und Küstenforschung GmbH"} ],
	"license": 
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Europa-Universität Flensburg"},
	"contributors": [
		{"name": "Marlon Schlemminger", "email": "marlon@wmkamp46a.de", "date": "13.03.2018", "comment": ""}],
	"resources": [
		{"name": "",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "version", "description": "version number of eGo data processing", "unit": "" },
			{"name": "weather_scenario_id", "description": "Identifier for weather data version", "unit": ""},
			{"name": "w_id", "description": "Coastdat2 identifier", "unit": ""},
			{"name": "source", "description": "Renewable energy source", "unit": ""},
			{"name": "weather_year", "description": "Year of weather data", "unit": ""},
			{"name": "feedin", "description": "Feedin timeseries", "unit": "pu"} ] } ],
	"metadata_version": "1.3"}';

-- select description
SELECT obj_description('supply.ego_renewable_feedin' ::regclass) ::json;

---
COMMENT ON TABLE supply.ego_power_class IS '{
	"title": "eGo renewable power classes of wind",
	"description": "Power classes used for feedin timeseries",
	"language": ["eng"],
	"spatial": 
		{"location": "",
		"extent": "",
		"resolution": ""},
	"temporal": 
		{"reference_date": "",
		"start": "",
		"end": "",
		"resolution": ""},
	"sources": [
		{"name": "open_eGo preprocessing", 
		"description": "", 
		"url": "https://github.com/openego/data_processing/tree/master/preprocessing", 
		"license": "GNU Affero General Public License Version 3 (AGPL-3.0)", 
		"copyright": "open_eGo Team"} ],
	"license": 
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Europa-Universität Flensburg"},
	"contributors": [
		{"name": "Marlon Schlemminger", "email": "marlon@wmkamp46a.de", "date": "26.03.2018", "comment": ""}],
	"resources": [
		{"name": "",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "version", "description": "version number of eGo data processing", "unit": "" },
			{"name": "power_class_id", "description": "Identifier for power class", "unit": ""},
			{"name": "lower_limit", "description": "Lower limit of the power class", "unit": "MW"},
			{"name": "upper_limit", "description": "Upper limit of the power class", "unit": "MW"},
			{"name": "wea", "description": "Type of WEA used in this powerclass", "unit": ""},
			{"name": "h_hub", "description": "Hub height of WEA", "unit": "m"},
			{"name": "d_rotor", "description": "Rotor diameter of WEA", "unit": "m"} ] } ],
	"metadata_version": "1.3"}';

-- select description
SELECT obj_description('supply.ego_power_class' ::regclass) ::json;
