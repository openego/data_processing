/*
Adjusts conventional power plant list including future scenarios for further use. 
__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/


--- Create table for processed power plant data
DROP TABLE IF EXISTS model_draft.ego_supply_conv_powerplant_2035 CASCADE; 

CREATE TABLE model_draft.ego_supply_conv_powerplant_2035 AS 
	AS TABLE model_draft.nep_supply_conv_powerplant_nep2015; 

ALTER TABLE model_draft.ego_supply_conv_powerplant_2035
  	ADD COLUMN voltage_level smallint,
	ADD COLUMN subst_id bigint,
	ADD COLUMN otg_id bigint,
	ADD COLUMN un_id bigint; 

-- Update voltage level according to installed capacity in 2035

UPDATE model_draft.ego_supply_conv_powerplant_2035
SET voltage_level=1
WHERE rated_power_b2035 >=120.0   --Voltage_level =1 when capacity greater than 120 MW
;

UPDATE model_draft.ego_supply_conv_powerplant_2035
SET voltage_level=3
WHERE rated_power_b2035 BETWEEN 17.5 AND 119.99 
;

UPDATE model_draft.ego_supply_conv_powerplant_2035
SET voltage_level=4
WHERE rated_power_b2035 BETWEEN 4.5 AND 17.49  
;

UPDATE model_draft.ego_supply_conv_powerplant_2035
SET voltage_level=5
WHERE rated_power_b2035 BETWEEN 0.3 AND 4.49 
;


UPDATE model_draft.ego_supply_conv_powerplant_2035
SET voltage_level=6
WHERE rated_power_b2035 BETWEEN 0.1 AND 0.29 
;

UPDATE model_draft.ego_supply_conv_powerplant_2035
SET voltage_level=7
WHERE rated_power_b2035 BETWEEN 0 AND 0.099 
;



--- Change name of fuel types to be compatible to PyPSA 

UPDATE model_draft.ego_supply_conv_powerplant_2035
  SET fuel = 'pumped_storage'
  WHERE fuel = 'pump_storage';


UPDATE model_draft.ego_supply_conv_powerplant_2035
  SET fuel = 'oil'
  WHERE fuel = 'mineral_oil';

UPDATE model_draft.ego_supply_conv_powerplant_2035
  SET fuel = 'coal'
  WHERE fuel = 'hard_coal';

UPDATE model_draft.ego_supply_conv_powerplant_2035
  SET fuel = 'other_non_renewable'
  WHERE fuel = 'other';








