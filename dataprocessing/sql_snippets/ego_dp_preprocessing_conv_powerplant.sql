/*
Rectifies incorrect or implausible records in power plant list and adjusts it for further use

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu, wolfbunke" 
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','supply','ego_conventional_powerplant','ego_dp_preprocessing_conv_powerplant.sql','');

-- copy powerplant list
DROP TABLE IF EXISTS model_draft.ego_supply_conv_powerplant CASCADE; 
CREATE TABLE model_draft.ego_supply_conv_powerplant AS
	TABLE supply.ego_conventional_powerplant; 

ALTER TABLE model_draft.ego_supply_conv_powerplant
	ADD COLUMN voltage_level smallint,  	
	ADD COLUMN subst_id bigint,
  	ADD COLUMN otg_id bigint,
  	ADD COLUMN un_id bigint;

CREATE INDEX model_draft.ego_supply_conv_powerplant_idx
	ON model_draft.ego_supply_conv_powerplant
	USING gist
	(geom);
  
ALTER TABLE model_draft.ego_supply_conv_powerplant OWNER TO oeuser; 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','temp','model_draft','ego_supply_conv_powerplant','ego_dp_preprocessing_conv_powerplant.sql','');


-- Delete entries without information on installed capacity or where capacity <= 0
DELETE  FROM model_draft.ego_supply_conv_powerplant
	WHERE capacity IS NULL OR capacity <= 0; 

-- Change fuel='multiple_non_renewable' to 'other_non_renewable' for compatibility reasons
UPDATE model_draft.ego_supply_conv_powerplant
	SET fuel = 'other_non_renewable'
	WHERE fuel = 'multiple_non_renewable';


-- Correct an invalid geom in the register
ALTER TABLE model_draft.ego_supply_conv_powerplant
SET lat = 48.0261021
WHERE gid = 493;

UPDATE  model_draft.ego_supply_conv_powerplant
set geom = ST_SetSRID(ST_MakePoint(lon,lat),4326)
WHERE gid = 493;


-- Update Voltage Level of Power Plants according to allocation table
UPDATE model_draft.ego_supply_conv_powerplant
SET voltage_level=1
WHERE capacity >=120.0 /*Voltage_level =1 when capacity greater than 120 MW*/;


UPDATE model_draft.ego_supply_conv_powerplant
SET voltage_level=3
WHERE capacity BETWEEN 17.5 AND 119.99 /*Voltage_level =2 when capacity between 17.5 and 119.99 MW*/;

UPDATE model_draft.ego_supply_conv_powerplant
SET voltage_level=4
WHERE capacity BETWEEN 4.5 AND 17.49;

UPDATE model_draft.ego_supply_conv_powerplant
SET voltage_level=5
WHERE capacity BETWEEN 0.3 AND 4.49 /* Voltage_level =3 when capacity between 0.3 and 4.5 kV*/;

UPDATE model_draft.ego_supply_conv_powerplant
SET voltage_level=6
WHERE capacity BETWEEN 0.1 AND 0.29;

UPDATE model_draft.ego_supply_conv_powerplant
SET voltage_level=7
WHERE capacity < 0.1 /*voltage_level =7 when capacity lower than 0.1*/;


-- metadata
COMMENT ON TABLE  model_draft.ego_supply_conv_powerplant IS
'{
"Name": "eGo conventional powerplant list",
"Source": [{
                  "Name": "open_eGo data_processing",
                  "URL":  "https://github.com/openego/data_processing" }, 
	   {
                  "Name": "BNetzA Kraftwerksliste",
                  "URL":  "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html" }, 
{
                  "Name": "Umweltbundesamt Datenbank Kraftwerke in Deutschland",
                  "URL":  "http://www.umweltbundesamt.de/dokument/datenbank-kraftwerke-in-deutschland" }, 
],
"Reference date": "2016-02-08",
"Date of collection": "...",
"Original file": "proc_power_plant_germany.sql",
"Spatial resolution": ["Germany"],
"Description": ["This dataset contains processed information on powerplants from BNetzA and UBA-list"],
"Column": [
                   {"Name": "gid",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "bnetza_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "company",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "postcode",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "city",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "street",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "state",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "block",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "commissioned_original",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "commissioned",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "retrofit",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "shutdown",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "status",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "fuel",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "technology",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "type",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "eeg",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "chp",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "capacity",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "capacity_uba",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "chp_capacity_uba",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "efficiency_data",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "efficiency_estimate",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "network_node",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "voltage",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "network_operator",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "name_uba",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "lat",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "lon",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "comment",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "geom",
                    "Description": "geometry",
                    "Unit": "" }, 
                   {"Name": "voltage_level",
                    "Description": "voltage level to which generator is connected (partly calculated based on installed capacity)",
                    "Unit": "" }, 
                   {"Name": "subst_id",
                    "Description": "id of associated substation",
                    "Unit": "" }, 
                   {"Name": "otg_id",
                    "Description": "otg_id of associated substation",
                    "Unit": "" },                        
                   {"Name": "un_id",
                    "Description": "unified id for res and conv powerplants",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." },
                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "27.10.2016",
                    "Comment": "added information to metadata" } 
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_supply_conv_powerplant' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_supply_conv_powerplant','ego_dp_preprocessing_conv_powerplant.sql','');
