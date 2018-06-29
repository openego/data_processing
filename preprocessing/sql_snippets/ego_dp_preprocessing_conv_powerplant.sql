/*
This script rectifies incorrect or implausible records in power plant list of the BNetzA
and adjusts it for further use. The results ends up in table model_draft.ego_dp_supply_conv_powerplant
and supply.ego_dp_conv_powerplant. 


__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu, wolfbunke" 
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','supply','ego_dp_supply_conv_powerplant',' .sql','');

DROP TABLE IF EXISTS model_draft.ego_dp_supply_conv_powerplant CASCADE;
CREATE TABLE model_draft.ego_dp_supply_conv_powerplant
(
  preversion text NOT NULL,
  id integer NOT NULL,
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
  voltage_level smallint,
  subst_id bigint,
  otg_id bigint,
  un_id bigint,
  la_id integer,
  scenario text,
  flag text,
  nuts varchar,
  CONSTRAINT ego_dp_supply_conv_powerplant_pkey PRIMARY KEY (preversion,id,scenario)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE model_draft.ego_dp_supply_conv_powerplant
  OWNER TO oeuser;
  
GRANT ALL ON TABLE model_draft.ego_dp_supply_conv_powerplant TO oeuser;

--DROP INDEX model_draft.ego_dp_supply_res_powerplant_idx;
CREATE INDEX ego_dp_supply_conv_powerplant_idx
  ON model_draft.ego_dp_supply_conv_powerplant
  USING gist
  (geom);

-- metadata description

COMMENT ON TABLE model_draft.ego_dp_supply_conv_powerplant
 IS 
  '{
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
		"license": "unknown", 
		"copyright": "© Umweltbundesamt (UBA)"},
			 
		{"name": "Kraftwerksliste der Bundesnetzagentur (BNetzA)", 
		"description": "The Federal Network Agency for Electricity, Gas, Telecommunications, Posts and Railway Data is in Germany data provider of power plant", 
		"url": "https://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html", 
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
				{"name": "preversion", "description": "Preversion ID of data preprocessing", "unit": "" },
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
				{"name": "flag", "description": "Flag of scenario changes of an power plant unit (repowering, decommission or commissioning).", "unit": "" },
				{"name": "nuts", "description": "NUTS ID).", "unit": ""} ] } ],
		"meta_version": "1.3" }';
	  
-- select description
SELECT obj_description('model_draft.ego_dp_supply_conv_powerplant'::regclass)::json;

--------------------------------------------------------------------------------
--          Insert conventional power plants Scenarios: Status-Quo
--------------------------------------------------------------------------------

INSERT INTO model_draft.ego_dp_supply_conv_powerplant
	SELECT 
	  'v0.3.0'::text  as preversion,
	  id,
	  bnetza_id,
	  company,
	  name,
	  postcode,
	  city,
	  street,
	  state,
	  block,
	  commissioned_original,
	  commissioned,
	  retrofit,
	  shutdown,
	  status,
	  fuel,
	  technology,
	  type,
	  eeg,
	  chp,
	  capacity,
	  capacity_uba,
	  chp_capacity_uba,
	  efficiency_data,
	  efficiency_estimate,
	  network_node,
	  voltage,
	  network_operator,
	  name_uba,
	  lat,
	  lon,
	  comment,
	  geom,
	  voltage_level,
	  subst_id,
	  otg_id,
	  un_id,
	  NULL::int as la_id,
	  'Status Quo'::text as scenario,
	  NULL::text as flag,
	  NULL::text as nuts
	FROM
	  model_draft.ego_dp_supply_conv_powerplant;

--------------------------------------------------------------------------------
--          Rectify implausible and incorrect entries
--------------------------------------------------------------------------------


-- Delete entries without information on installed capacity or where capacity <= 0
DELETE  FROM model_draft.ego_dp_supply_conv_powerplant
	WHERE capacity IS NULL OR capacity <= 0; 

-- Change fuel='multiple_non_renewable' to 'other_non_renewable' for compatibility reasons
UPDATE model_draft.ego_dp_supply_conv_powerplant
	SET fuel = 'other_non_renewable'
	WHERE fuel = 'multiple_non_renewable';


-- Correct an invalid geom in the register
UPDATE model_draft.ego_dp_supply_conv_powerplant
	SET lat = 48.0261021
	WHERE id = 493;

UPDATE  model_draft.ego_dp_supply_conv_powerplant
	set geom = ST_SetSRID(ST_MakePoint(lon,lat),4326)
	WHERE id = 493;


-- Update Voltage Level of Power Plants according to allocation table
UPDATE model_draft.ego_dp_supply_conv_powerplant
	SET voltage_level=1
	WHERE capacity >=120.0 /*Voltage_level =1 when capacity greater than 120 MW*/;


UPDATE model_draft.ego_dp_supply_conv_powerplant
	SET voltage_level=3
	WHERE capacity BETWEEN 17.5 AND 119.99 /*Voltage_level =2 when capacity between 17.5 and 119.99 MW*/;

UPDATE model_draft.ego_dp_supply_conv_powerplant
	SET voltage_level=4
	WHERE capacity BETWEEN 4.5 AND 17.49;

UPDATE model_draft.ego_dp_supply_conv_powerplant
	SET voltage_level=5
	WHERE capacity BETWEEN 0.3 AND 4.49 /* Voltage_level =3 when capacity between 0.3 and 4.5 kV*/;

UPDATE model_draft.ego_dp_supply_conv_powerplant
	SET voltage_level=6
	WHERE capacity BETWEEN 0.1 AND 0.29;

UPDATE model_draft.ego_dp_supply_conv_powerplant
	SET voltage_level=7
	WHERE capacity < 0.1 /*voltage_level =7 when capacity lower than 0.1*/;
	

--  Due to discrepancies between the given NEP 2035 power plant lsit
--  and the the installed Capacities of the study NEP 2015 with scenario B2035  
--  a correction of the capacities is done.

DROP TABLE IF EXISTS 	model_draft.ego_supply_conv_nep2035_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_conv_nep2035_temp AS
	SELECT * 
	FROM 
	  model_draft.ego_dp_supply_conv_powerplant
	WHERE scenario in ('NEP 2035');

-- create index GIST (geom)
CREATE INDEX ego_supply_conv_nep2035_temp_geom_idx
	ON model_draft.ego_supply_conv_nep2035_temp USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_conv_nep2035_temp OWNER TO oeuser;

-- Repowering units 
UPDATE model_draft.ego_supply_conv_nep2035_temp 
set   capacity = capacity +  round(capacity*((12700.-14477.)/12700.))
Where fuel ='pumped_storage';

UPDATE model_draft.ego_supply_conv_nep2035_temp 
set   capacity = capacity +   round(capacity*((33500.-35390.)/33500.))
Where fuel ='gas';

UPDATE model_draft.ego_supply_conv_nep2035_temp 
set   capacity = capacity +  round(capacity*((9100.-12240)/9100.))
Where fuel ='lignite';

UPDATE model_draft.ego_supply_conv_nep2035_temp 
set   capacity = capacity +  round(capacity*((11000.-13860.)/11000.))
Where fuel ='coal';

Update   model_draft.ego_dp_supply_conv_powerplant A
  set capacity =B.capacity
FROM model_draft.ego_supply_conv_nep2035_temp  B
WHERE A.scenario in ('NEP 2035')
AND A.id = B.id;

	
SELECT obj_description('model_draft.ego_dp_supply_conv_powerplant' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_dp_supply_conv_powerplant','ego_dp_preprocessing_conv_powerplant.sql','');
