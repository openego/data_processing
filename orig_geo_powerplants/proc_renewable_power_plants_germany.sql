/*
Pre-Processing of RE power plants list
__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

/*Assign gridlevels (1-7) and voltage-entries to RE-plants */

--CREATE TABLE supply.ego_res_powerplant AS
--SELECT renewable_power_plants_germany.*
--FROM orig_geo_powerplants.renewable_power_plants_germany;

--ALTER TABLE supply.ego_res_powerplant
--ADD COLUMN voltage character varying;


/* Adjust voltage level of all RE power plants according to allocation table*/
UPDATE supply.ego_res_powerplant 
SET voltage_level='1'
WHERE electrical_capacity >=120000;

UPDATE supply.ego_res_powerplant
SET voltage_level='3'
WHERE electrical_capacity between 17500 and 119999.99;

UPDATE supply.ego_res_powerplant
SET voltage_level='4'
WHERE electrical_capacity between 4500 and 17499.99;

UPDATE supply.ego_res_powerplant
SET voltage_level='5'
WHERE electrical_capacity between 300 and 4499.99;

UPDATE supply.ego_res_powerplant
SET voltage_level='6'
WHERE electrical_capacity between 100 and 299.99;

UPDATE supply.ego_res_powerplant
SET voltage_level='7'
WHERE electrical_capacity <100;


/*Change generation_type = 'hydro' to 'run_of_river' for compatibility reasons*/

UPDATE supply.ego_res_powerplant
	SET generation_type = 'run_of_river'
	WHERE generation_type = 'hydro';

/*Set voltage_level of offshore_wind to 1, to be able to assign offshore wind parks to the closest EHV-substation. This might be changed: See #983 */

UPDATE supply.ego_res_powerplant
	SET voltage_level=1 
	WHERE generation_subtype = 'wind_offshore'; 


