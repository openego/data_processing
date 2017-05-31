/*
Rectifies incorrect or implausible records in power plant list and adjusts it for further use

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu, wolfbunke" 
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','supply','ego_renewable_powerplant','ego_dp_preprocessing_res_powerplant.sql','');

-- copy powerplant list
DROP TABLE IF EXISTS model_draft.ego_supply_res_powerplant CASCADE; 
CREATE TABLE model_draft.ego_supply_res_powerplant AS
	TABLE supply.ego_renewable_powerplant; 

ALTER TABLE model_draft.ego_supply_res_powerplant
  	ADD COLUMN subst_id bigint,
  	ADD COLUMN otg_id bigint,
  	ADD COLUMN un_id bigint, 
	ADD PRIMARY KEY (id); 

ALTER TABLE model_draft.ego_supply_res_powerplant 
	RENAME COLUMN voltage_level TO voltage_level_var;

CREATE INDEX ego_supply_res_powerplant_idx
	ON model_draft.ego_supply_res_powerplant USING gist (geom);

ALTER TABLE model_draft.ego_supply_res_powerplant OWNER TO oeuser; 


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','temp','model_draft','ego_supply_res_powerplant','ego_dp_preprocessing_res_powerplant.sql','');


-- Delete entries without information on installed capacity or where electrical_capacity <= 0
DELETE  FROM model_draft.ego_supply_res_powerplant
	WHERE 	electrical_capacity IS NULL OR 
		electrical_capacity <= 0; 

-- Delete entries where generation_type and subtype are inconsistent
DELETE  FROM model_draft.ego_supply_res_powerplant
	WHERE generation_type = 'biomass' AND generation_subtype ='wind_onshore'
	OR generation_type = 'biomass' AND generation_subtype ='solar_roof_mounted'
	OR generation_type = 'solar' AND generation_subtype ='wind_onshore'
	OR generation_type = 'wind' AND generation_subtype ='solar_roof_mounted';

-- Update missing subtype of some offshore windturbines
UPDATE model_draft.ego_supply_res_powerplant
	SET generation_subtype = 'wind_offshore'
	WHERE city = 'Ausschließliche Wirtschaftszone';

-- Change generation_type = 'hydro' to 'run_of_river' for compatibility reasons
UPDATE model_draft.ego_supply_res_powerplant
	SET generation_type = 'run_of_river'
	WHERE generation_type = 'hydro';

-- Update missing subtypes
UPDATE model_draft.ego_supply_res_powerplant
	SET generation_subtype = 'biomass'
	WHERE generation_type = 'biomass'
	AND generation_subtype IS NULL;

UPDATE model_draft.ego_supply_res_powerplant
	SET generation_subtype = 'gas'
	WHERE generation_type = 'gas'
	AND generation_subtype IS NULL;

UPDATE model_draft.ego_supply_res_powerplant
	SET generation_subtype = 'geothermal'
	WHERE generation_type = 'geothermal'
	AND generation_subtype IS NULL;

UPDATE model_draft.ego_supply_res_powerplant
	SET generation_subtype = 'hydro'
	WHERE generation_type = 'run_of_river'
	AND generation_subtype IS NULL;

UPDATE model_draft.ego_supply_res_powerplant
	SET generation_subtype = 'wind_onshore'
	WHERE generation_type = 'wind'
	AND generation_subtype IS NULL;
	

-- Update incorrect geom of offshore windturbines
UPDATE model_draft.ego_supply_res_powerplant
	SET geom =
		(CASE
		WHEN eeg_id LIKE '%%DYSKE%%' 
		THEN (SELECT geom from model_draft.ego_supply_res_powerplant where id = 1560412)
		WHEN eeg_id LIKE '%%BRGEE%%' 
		THEN (SELECT geom from model_draft.ego_supply_res_powerplant where id = 1560969)
		WHEN eeg_id LIKE '%%MEERWINDSUEDOST%%' 
		THEN (SELECT geom from model_draft.ego_supply_res_powerplant where id = 1560502)
		WHEN eeg_id LIKE '%%GLTEE%%' 
		THEN (SELECT geom from model_draft.ego_supply_res_powerplant where id = 1561081)
		WHEN eeg_id LIKE '%%BUTENDIEK%%' 
		THEN (SELECT geom from model_draft.ego_supply_res_powerplant where id = 1560705)
		WHEN eeg_id LIKE '%%BOWZE%%' 
		THEN (SELECT geom from model_draft.ego_supply_res_powerplant where id = 1561018)
		WHEN eeg_id LIKE '%%NORDSEEOST%%' or eeg_id LIKE '%%NordseeOst%%'
		THEN (SELECT geom from model_draft.ego_supply_res_powerplant where id = 1560647)
		WHEN eeg_id LIKE '%%BALTIC%%' 
		THEN (SELECT geom from model_draft.ego_supply_res_powerplant where id = 1561137)
		WHEN eeg_id LIKE '%%RIFFE%%' 
		THEN ST_SetSRID(ST_MakePoint(6.48, 53.69),4326)
		WHEN eeg_id LIKE '%%ALPHAVENTUE%%' 
		THEN ST_SetSRID(ST_MakePoint(6.598333, 54.008333),4326)
		WHEN eeg_id LIKE '%%BAOEE%%' 
		THEN ST_SetSRID(ST_MakePoint(5.975, 54.358333),4326)
		END)
	WHERE postcode = '00000' OR postcode = 'keine' or postcode = 'O04WF' AND generation_subtype = 'wind_offshore';


-- Update voltage_level 
ALTER TABLE model_draft.ego_supply_res_powerplant 
	ADD COLUMN voltage_level smallint; 

UPDATE model_draft.ego_supply_res_powerplant
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
UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level= 1
	WHERE 	electrical_capacity >=120000 AND 
		generation_subtype<>'wind_onshore';

UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level= 3
	WHERE 	electrical_capacity between 17500 and 119999.99 AND 
		generation_subtype<>'wind_onshore';

UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level= 4
	WHERE 	electrical_capacity between 4500 and 17499.99 AND 
		generation_subtype<>'wind_onshore';

UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level= 5
	WHERE 	electrical_capacity between 300 and 4499.99 AND 
		generation_subtype<>'wind_onshore';

UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level= 6
	WHERE 	electrical_capacity between 100 and 299.99 AND 
		generation_subtype<>'wind_onshore';

UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level= 7
	WHERE 	electrical_capacity <100 AND generation_subtype<>'wind_onshore';

-- Update onshore_wind with voltage_level higher than suggested by allocation table
UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level= 1
	WHERE 	electrical_capacity >=120000 AND 
		generation_subtype='wind_onshore';

UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level= 3 
	WHERE 	electrical_capacity between 17500 and 119999.99 AND 
		generation_subtype='wind_onshore' AND 
		(voltage_level > 3 OR voltage_level IS NULL);

UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level= 4
	WHERE 	electrical_capacity between 4500 and 17499.99 AND 
		generation_subtype='wind_onshore' AND 
		(voltage_level > 4 OR voltage_level IS NULL) ; 

UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level= 5
	WHERE 	electrical_capacity between 300 and 4499.99 AND 
		generation_subtype='wind_onshore' AND 
		(voltage_level > 5 OR voltage_level IS NULL);

UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level= 6
	WHERE 	electrical_capacity between 100 and 299.99 AND 
		generation_subtype='wind_onshore' AND 
		(voltage_level > 6 OR voltage_level IS NULL);
		
UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level= 7
	WHERE 	electrical_capacity <100 AND 
		generation_subtype='wind_onshore' AND 
		voltage_level IS NULL;

--Set voltage_level of offshore_wind to 1
UPDATE model_draft.ego_supply_res_powerplant
	SET 	voltage_level='1' 
	WHERE 	generation_subtype = 'wind_offshore'; 

-- metadata
COMMENT ON TABLE model_draft.ego_supply_res_powerplant
  IS '{"Name": "Renewable power plants in Germany -Status quo",
"Source": [{
                     "Name": "EnergyMap",
                      "URL": "www.energymap.info" },
                     {
                     "Name": "Bundesnetzagentur (BNetzA)",
                      "URL": "www.bundesnetzagentur.de" },
                     {
                     "Name": "open_eGo data-processing",
                      "URL":  "https://github.com/openego/data_processing" }
],
"Reference date": ["31.12.2015"],
"Retrieved": ["16.03.2016"],
"Date of collection": ["31.12.2015"],
"Original file": ["eeg_anlagenregister_2015.08.utf8.csv.zip,Meldungen_Aug-Dez2015.xls, 2016_01_Veroeff_AnlReg.xls"],
"Spatial resolution": ["Germany"],
"Description": ["This table contains a list of renewable energy power plants in Germany. This data join two sources: energymap.info, a data platform of the ''''Deutsche Gesellschaft für Sonnenenergie e.V.'''' and Bundesnetzagentur, the regularor together."], 
"Regional level": ["minimum postcode level"],
"Column":[
	{"Name": "id",
	"Description": "Primary Key",
	"Unit": "" },
	{"Name": "start_up_date",
	"Description": "start-up date",
	"Unit": "" },
	{"Name": "electrical_capacity",
	"Description": "electrical capacity",
	"Unit": "kW" },
	{"Name": "generation_type",
	"Description": "generation_type or main fuel type",
	"Unit": "" },
	{"Name": "generation_subtype",
	"Description": "generation subtype",
	"Unit": "" },
	{"Name": "thermal_capacity",
	"Description": "thermal capacity",
	"Unit": "kW" },
	{"Name": "city",
	"Description": "Name of city or location",
	"Unit": "" },
	{"Name": "postcode",
	"Description": "postcode",
	"Unit": "" },
	{"Name": "address",
	"Description": "address",
	"Unit": "" },
	{"Name": "lon",
	"Description": "longitude",
	"Unit": "" },
	{"Name": "lat",
	"Description": "latitude",
	"Unit": "" },
	{"Name": "gps_accuracy",
	"Description": "gps accuracy in meter",
	"Unit": "meter" },
	{"Name": "validation",
	"Description": "validation comments",
	"Unit": "" },
	{"Name":"notification_reason",
	"Description":"notification reason from BNetzA sources",
	"Unit":"" },
	{"Name":"eeg_id",
	"Description":"EEG id of Unit",
	"Unit":"" },
	{"Name":"tso",
	"Description":"Name of Transmission system operator",
	"Unit":"" },
	{"Name":"tso_eic",
	"Description":"Name of Transmission system operator",
	"Unit":"" },
	{"Name":"dso_id",
	"Description":"Name of District system operator",
	"Unit":"" },
	{"Name":"dso",
	"Description":"Name of District system operator",
	"Unit":"" },
	{"Name":"voltage_level",
	"Description":"voltage level",
	"Unit":"" },
	{"Name":"network_node",
	"Description":"Name or code of network node",
	"Unit":"" },
	{"Name":"power_plant_id",
	"Description":"power plant id from BNetzA",
	"Unit":"" },
	{"Name":"source",
	"Description":"short Name of source: energymap or bnetza",
	"Unit":"" },
	{"Name":"comment",
	"Description":"Further comment of changes",
	"Unit":"" },
	{"Name":"geom",
	"Description":"Geometry",
	"Unit":"" },
	{"Name":"subst_id",
	"Description":"ID of related substation",
	"Unit":"" },
	{"Name":"otg_id",
	"Description":"ID od related substation from osmTGmod",
	"Unit":"" },
	{"Name":"un_id",
	"Description":"unified ID of RES and CONV power plants",
	"Unit":"" }
],
"Changes":[
  { "Name":"Wolf-Dieter Bunke", 
    "Mail":"wolf-dieter.bunke@uni-flensburg.de", 
    "Date":"16.03.2016", 
    "Comment":"Created table" },
  { "Name":"Wolf-Dieter Bunke", 
    "Mail":"wolf-dieter.bunke@uni-flensburg.de", 
    "Date":"02.02.2017", 
    "Comment":"change meta data" }
    
    
    ],
"Notes": ["..."],
"Licence": [{
            "Name": "Open Database License (ODbL) v1.0",
	    "URL": "http://opendatacommons.org/licenses/odbl/1.0/",
	    "Copyright": "ZNES EUF"
	    }
],
"Instructions for proper use": ["..."]}';

-- select description
SELECT obj_description('model_draft.ego_supply_res_powerplant' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_supply_res_powerplant','ego_dp_preprocessing_res_powerplant.sql','');
