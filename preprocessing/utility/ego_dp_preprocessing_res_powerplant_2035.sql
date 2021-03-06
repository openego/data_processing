﻿/*
Updates voltage_level in RES power plants list for scenario NEP 2035

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu, Ludee" 
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_supply_res_powerplant','ego_dp_preprocessing_res_powerplant_2035.sql','');

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET voltage_level=1
	WHERE electrical_capacity >=120000;

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET voltage_level=3
	WHERE electrical_capacity between 17500 and 119999.99;

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET voltage_level=4
	WHERE electrical_capacity between 4500 and 17499.99;

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET voltage_level=5
	WHERE electrical_capacity between 300 and 4499.99;

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET voltage_level=6
	WHERE electrical_capacity between 100 and 299.99;

UPDATE model_draft.ego_dp_supply_res_powerplant
	SET voltage_level=7
	WHERE electrical_capacity < 100;

-- Overwrite voltage_level of power plants existing in SQ scenario

UPDATE model_draft.ego_dp_supply_res_powerplant a
	SET voltage_level = b.voltage_level 
	FROM model_draft.ego_dp_supply_res_powerplant b
	WHERE a.id=b.id; 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_supply_res_powerplant_2035','ego_dp_preprocessing_res_powerplant_2035.sql','');
