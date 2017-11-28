/*

Set or adjust voltage_level according to installed capacity and technology of power plants. 

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

------------------
-- Renewable power plants
------------------


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


------------------
-- Conventional power plants
------------------

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
