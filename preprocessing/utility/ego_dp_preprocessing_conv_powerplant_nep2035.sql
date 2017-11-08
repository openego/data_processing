/*
Adjusts conventional power plant list including future scenarios for further use. 

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu, Ludee" 
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','nep_supply_conv_powerplant_nep2015','ego_dp_preprocessing_conv_powerplant_nep2035.sql','');

--- Create table for processed power plant data
DROP TABLE IF EXISTS model_draft.ego_supply_conv_powerplant_2035 CASCADE; 
CREATE TABLE model_draft.ego_supply_conv_powerplant_2035 AS 
	SELECT 	* 
	FROM 	model_draft.ego_dp_supply_conv_powerplant 
	WHERE 	geom IS NOT NULL
	AND scenario ='NEP 2035'; 

ALTER TABLE model_draft.ego_supply_conv_powerplant_2035
	DROP COLUMN IF EXISTS	voltage_level CASCADE,
  	ADD COLUMN voltage_level smallint,
  	DROP COLUMN IF EXISTS	subst_id CASCADE,
	ADD COLUMN subst_id bigint,
	DROP COLUMN IF EXISTS	otg_id CASCADE,
	ADD COLUMN otg_id bigint,
	DROP COLUMN IF EXISTS	un_id CASCADE,
	ADD COLUMN un_id bigint; 
	
	
CREATE INDEX ego_supply_conv_powerplant_2035_idx
	ON model_draft.ego_supply_conv_powerplant_2035 USING gist (geom);
  
ALTER TABLE model_draft.ego_supply_conv_powerplant_2035 OWNER TO oeuser;


-- Update voltage level according to installed capacity in 2035
UPDATE model_draft.ego_supply_conv_powerplant_2035
	SET voltage_level=1
	WHERE capacity >=120.0;	--Voltage_level =1 when capacity greater than 120 MW


UPDATE model_draft.ego_supply_conv_powerplant_2035
	SET voltage_level=3
	WHERE capacity BETWEEN 17.5 AND 119.99;

UPDATE model_draft.ego_supply_conv_powerplant_2035
	SET voltage_level=4
	WHERE capacity BETWEEN 4.5 AND 17.49;

UPDATE model_draft.ego_supply_conv_powerplant_2035
	SET voltage_level=5
	WHERE capacity BETWEEN 0.3 AND 4.49;


UPDATE model_draft.ego_supply_conv_powerplant_2035
	SET voltage_level=6
	WHERE capacity BETWEEN 0.1 AND 0.29;

UPDATE model_draft.ego_supply_conv_powerplant_2035
	SET voltage_level=7
	WHERE capacity BETWEEN 0 AND 0.099;


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

Update 	model_draft.ego_dp_supply_conv_powerplant C
	SET voltage_level = AA.voltage_level,
	    fuel = AA.fuel
	FROM  model_draft.ego_supply_conv_powerplant_2035 AA 
	WHERE AA.scenario = C.scenario
	AND AA.id = C.id
	AND AA.preversion = C.preversion;



-- metadata
COMMENT ON TABLE model_draft.ego_supply_conv_powerplant_2035 IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.3.0" }' ;


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_supply_conv_powerplant_2035','ego_dp_preprocessing_conv_powerplant_nep2035.sql','');
