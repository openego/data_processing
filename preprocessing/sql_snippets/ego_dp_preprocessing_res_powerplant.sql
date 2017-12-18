/*
Set up status quo data and create standardized table of all scenarios and rectifies incorrect or implausible records in power plant list and adjusts it for further use

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu, wolfbunke" 
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_dp_supply_res_powerplant','ego_db_res_rea_by_scenario.sql','');

DROP TABLE IF EXISTS model_draft.ego_dp_supply_res_powerplant CASCADE;
CREATE TABLE model_draft.ego_dp_supply_res_powerplant
(
  preversion text,
  id bigint NOT NULL,
  start_up_date timestamp without time zone,
  electrical_capacity numeric,
  generation_type text,
  generation_subtype character varying,
  thermal_capacity numeric,
  city character varying,
  postcode character varying,
  address character varying,
  lon numeric,
  lat numeric,
  gps_accuracy character varying,
  validation character varying,
  notification_reason character varying,
  eeg_id character varying,
  tso double precision,
  tso_eic character varying,
  dso_id character varying,
  dso character varying,
  voltage_level_var character varying,
  network_node character varying,
  power_plant_id character varying,
  source character varying,
  comment character varying,
  geom geometry(Point,3035),
  subst_id bigint,
  otg_id bigint,
  un_id bigint,
  voltage_level smallint,
  la_id integer,
  mvlv_subst_id integer,
  rea_sort integer,
  rea_flag character varying,
  rea_geom_line geometry(LineString,3035),
  rea_geom_new geometry(Point,3035),
  scenario character varying NOT NULL,
  flag character varying,
  nuts character varying,
  CONSTRAINT ego_dp_supply_res_powerplant_pkey PRIMARY KEY (preversion,id,scenario)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE model_draft.ego_dp_supply_res_powerplant
  OWNER TO oeuser;
  
GRANT ALL ON TABLE model_draft.ego_dp_supply_res_powerplant TO oeuser;

-- Index: model_draft.ego_dp_supply_res_powerplant_idx
-- DROP INDEX model_draft.ego_dp_supply_res_powerplant_idx;
CREATE INDEX ego_dp_supply_res_powerplant_idx
  ON model_draft.ego_dp_supply_res_powerplant
  USING gist
  (geom);
  
-- set metadata  
COMMENT ON TABLE model_draft.ego_dp_supply_res_powerplant IS '{
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
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "©  ZNES Europa-Universität Flensburg"} ],
	"contributors": [
		{"name": "wolfbunke", "email": " ", 
		"date": "01.06.2017", "comment": "Create and restructure scripts and table"}],
	"resources": [
		{"name": "model_draft.ego_dp_supply_res_powerplant",		
		"format": "PostgreSQL",
		"fields": [
			        {"name": "preversion", "description": "preversion number of data preprocessing", "unit": "" },
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
				{"name": "scenario", "description": "Name of scenario", "unit": "" },
				{"name": "flag", "description": "Flag of scenario changes of an power plant unit (repowering, decommission or commissioning).", "unit": "" },
				{"name": "nuts", "description": "NUTS ID).", "unit": "" } ] } ],		
	"metadata_version": "1.3"}';

-- select description
SELECT obj_description('model_draft.ego_dp_supply_res_powerplant'::regclass)::json;

-- Insert Status Quo Data to new table with rea geom
Insert into model_draft.ego_dp_supply_res_powerplant 
	SELECT
	  'v0.3.0'::text as preversion,
	  id, 
	  start_up_date,
	  electrical_capacity,
	  generation_type,
	  generation_subtype,
	  thermal_capacity,
	  city,
	  postcode,
	  address,
	  lon,
	  lat,
	  gps_accuracy,
	  validation,
	  notification_reason,
	  eeg_id,
	  tso,
	  tso_eic,
	  dso_id,
	  dso ,
	  voltage_level_var,
	  network_node ,
	  power_plant_id,
	  source || ' ego_dp' as source,
	  comment || ' geom changes by rea' as comment ,
	  ST_Transform(geom,3035) as geom,                                      
	  subst_id,
	  otg_id,
	  un_id,
	  voltage_level,
	  la_id,
	  mvlv_subst_id,
	  rea_sort,
	  rea_flag,
	  NULL as rea_geom_line,
	  Null as rea_geom_new,
	  'Status Quo'::text as scenario,
	  'constantly'::text as flag,
	  Null as nuts
	FROM 
	  model_draft.ego_supply_res_powerplant
	 WHERE geom is not NULL;


---------------
-- Rectify incorrect or implausible records
---------------

-- Delete entries without information on installed capacity or where electrical_capacity <= 0
DELETE  FROM model_draft.ego_dp_supply_res_powerplant
	WHERE 	electrical_capacity IS NULL OR 
		electrical_capacity <= 0; 

-- Delete entries where generation_type and subtype are inconsistent
DELETE  FROM model_draft.ego_dp_supply_res_powerplant
	WHERE generation_type = 'biomass' AND generation_subtype ='wind_onshore'
	OR generation_type = 'biomass' AND generation_subtype ='solar_roof_mounted'
	OR generation_type = 'solar' AND generation_subtype ='wind_onshore'
	OR generation_type = 'wind' AND generation_subtype ='solar_roof_mounted';

-- Update missing subtype of some offshore windturbines
UPDATE model_draft.ego_dp_supply_res_powerplant
	SET generation_subtype = 'wind_offshore'
	WHERE city = 'Ausschließliche Wirtschaftszone';

-- Change generation_type = 'hydro' to 'run_of_river' for compatibility reasons
UPDATE model_draft.ego_dp_supply_res_powerplant
	SET generation_type = 'run_of_river'
	WHERE generation_type = 'hydro';

-- Update missing subtypes
UPDATE model_draft.ego_dp_supply_res_powerplant
	SET generation_subtype = 'biomass'
	WHERE generation_type = 'biomass'
	AND generation_subtype IS NULL;

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET generation_subtype = 'gas'
	WHERE generation_type = 'gas'
	AND generation_subtype IS NULL;

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET generation_subtype = 'geothermal'
	WHERE generation_type = 'geothermal'
	AND generation_subtype IS NULL;

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET generation_subtype = 'hydro'
	WHERE generation_type = 'run_of_river'
	AND generation_subtype IS NULL;

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET generation_subtype = 'wind_onshore'
	WHERE generation_type = 'wind'
	AND generation_subtype IS NULL;
	

-- Update incorrect geom of offshore windturbines
UPDATE model_draft.ego_dp_supply_res_powerplant
	SET geom =
		(CASE
		WHEN eeg_id LIKE '%%DYSKE%%' 
		THEN (SELECT geom from model_draft.ego_dp_supply_res_powerplant where id = 1560412)
		WHEN eeg_id LIKE '%%BRGEE%%' 
		THEN (SELECT geom from model_draft.ego_dp_supply_res_powerplant where id = 1560969)
		WHEN eeg_id LIKE '%%MEERWINDSUEDOST%%' 
		THEN (SELECT geom from model_draft.ego_dp_supply_res_powerplant where id = 1560502)
		WHEN eeg_id LIKE '%%GLTEE%%' 
		THEN (SELECT geom from model_draft.ego_dp_supply_res_powerplant where id = 1561081)
		WHEN eeg_id LIKE '%%BUTENDIEK%%' 
		THEN (SELECT geom from model_draft.ego_dp_supply_res_powerplant where id = 1560705)
		WHEN eeg_id LIKE '%%BOWZE%%' 
		THEN (SELECT geom from model_draft.ego_dp_supply_res_powerplant where id = 1561018)
		WHEN eeg_id LIKE '%%NORDSEEOST%%' or eeg_id LIKE '%%NordseeOst%%'
		THEN (SELECT geom from model_draft.ego_dp_supply_res_powerplant where id = 1560647)
		WHEN eeg_id LIKE '%%BALTIC%%' 
		THEN (SELECT geom from model_draft.ego_dp_supply_res_powerplant where id = 1561137)
		WHEN eeg_id LIKE '%%RIFFE%%' 
		THEN ST_SetSRID(ST_MakePoint(6.48, 53.69),3035)
		WHEN eeg_id LIKE '%%ALPHAVENTUE%%' 
		THEN ST_SetSRID(ST_MakePoint(6.598333, 54.008333),3035)
		WHEN eeg_id LIKE '%%BAOEE%%' 
		THEN ST_SetSRID(ST_MakePoint(5.975, 54.358333),3035)
		END)
	WHERE postcode = '00000' OR postcode = 'keine' or postcode = 'O04WF' AND generation_subtype = 'wind_offshore';


UPDATE model_draft.ego_dp_supply_res_powerplant
 	SET 	voltage_level=
		(CASE 
		 	WHEN voltage_level_var='01 (HöS)' THEN 1 
		 	WHEN voltage_level_var='02 (HöS/HS)' THEN 2 
		 	WHEN voltage_level_var='03 (HS)' THEN 3
		 	WHEN voltage_level_var='04 (HS/MS)' THEN 4
		 	WHEN voltage_level_var='05 (MS)' THEN 5
		 	WHEN voltage_level_var='06 (MS/NS)' THEN 6 
		 	WHEN voltage_level_var='07 (NS)' THEN 7
		 	ELSE NULL
		 END);

-- Adjust voltage level of all RE power plants except wind_onshore according to allocation table
UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level= 1
	WHERE 	electrical_capacity >=120000 AND 
		generation_subtype<>'wind_onshore';

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level= 3
	WHERE 	electrical_capacity between 17500 and 119999.99 AND 
		generation_subtype<>'wind_onshore';

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level= 4
	WHERE 	electrical_capacity between 4500 and 17499.99 AND 
		generation_subtype<>'wind_onshore';

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level= 5
	WHERE 	electrical_capacity between 300 and 4499.99 AND 
		generation_subtype<>'wind_onshore';

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level= 6
	WHERE 	electrical_capacity between 100 and 299.99 AND 
		generation_subtype<>'wind_onshore';

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level= 7
	WHERE 	electrical_capacity <100 AND generation_subtype<>'wind_onshore';

-- Update onshore_wind with voltage_level higher than suggested by allocation table
UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level= 1
	WHERE 	electrical_capacity >=120000 AND 
		generation_subtype='wind_onshore';

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level= 3 
	WHERE 	electrical_capacity between 17500 and 119999.99 AND 
		generation_subtype='wind_onshore' AND 
		(voltage_level > 3 OR voltage_level IS NULL);

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level= 4
	WHERE 	electrical_capacity between 4500 and 17499.99 AND 
		generation_subtype='wind_onshore' AND 
		(voltage_level > 4 OR voltage_level IS NULL) ; 

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level= 5
	WHERE 	electrical_capacity between 300 and 4499.99 AND 
		generation_subtype='wind_onshore' AND 
		(voltage_level > 5 OR voltage_level IS NULL);

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level= 6
	WHERE 	electrical_capacity between 100 and 299.99 AND 
		generation_subtype='wind_onshore' AND 
		(voltage_level > 6 OR voltage_level IS NULL);
		
UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level= 7
	WHERE 	electrical_capacity <100 AND 
		generation_subtype='wind_onshore' AND 
		voltage_level IS NULL;

--Set voltage_level of offshore_wind to 1
UPDATE model_draft.ego_dp_supply_res_powerplant
	SET 	voltage_level='1' 
	WHERE 	generation_subtype = 'wind_offshore'; 

-- select description
SELECT obj_description('model_draft.ego_dp_supply_res_powerplant' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_dp_supply_res_powerplant','ego_dp_preprocessing_res_powerplant.sql','');
