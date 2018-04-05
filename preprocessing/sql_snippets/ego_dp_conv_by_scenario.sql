/*
SQL Script which prepare and insert a conventional power plant data list by scenario
for the project open_eGo and the tools eTraGo and eDisGo. And insert  Power plants by 
NEP 2035 scenario data set.


__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

*/


--------------------------------------------------------------------------------
-- Part II
--          Insert conventional power plants Scenarios: NEP 2035
--------------------------------------------------------------------------------
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','supply','ego_dp_supply_conv_powerplant',' .sql','');

-- DELETE FROM model_draft.ego_dp_supply_conv_powerplant Where scenario = 'NEP 2035';

INSERT INTO model_draft.ego_dp_supply_conv_powerplant
SELECT 
  'v0.3.0'::text  as preversion,
  b.max +row_number() over (ORDER BY gid) as id,
  bnetza_id,
  NULL::text as company,
  power_plant_name as name,
  postcode,
  NULL::text as city,
  NULL::text as street,
  state,
  unit_name as block,
  NULL::text as commissioned_original,
  commissioning As commissioned,
  NULL::numeric as retrofit,
  NULL::numeric as shutdown,
  NULL::text as status,
  fuel,
  NULL::text as technology,
  NULL::text as type,
  NULL::text as eeg,
  chp,
  rated_power_b2035 as capacity,
  NULL::numeric as capacity_uba,
  NULL::numeric as chp_capacity_uba,
  NULL::numeric as efficiency_data,
  NULL::numeric as efficiency_estimate,
  NULL::text as network_node,
  NULL::text as voltage,
  tso as network_operator,
  NULL::text as name_uba,
  lat,
  lon,
  'NEP2015 KW list'::text as comment,
  geom,
  voltage_level,
  subst_id,
  otg_id,
  un_id,
  NULL::int as la_id,
  'NEP 2035'::text as scenario,
  NULL::text as flag,
  NULL::text as nuts
FROM
  model_draft.ego_supply_conv_powerplant_2035,
   (
    SELECT max(id) as max
    FROM 	model_draft.ego_dp_supply_conv_powerplant
  ) as b;

--change flag
Update model_draft.ego_dp_supply_conv_powerplant A
  set flag = 'decommissioning'
Where  A.capacity = 0
AND scenario = 'NEP 2035';
--
Update model_draft.ego_dp_supply_conv_powerplant A
  set  flag = 'constantly' 
  WHERE scenario = 'Status Quo';


--------------------------------------------------------------------------------
-- Part III 
--          Add given Hydro storages
--	    Scenarios: ego 100%
--------------------------------------------------------------------------------

-- only pumed_storage for NEP2035 and Satatus Quo 
-- No entries or changes use of MView
-- see: dataprocessing/sql_snippets/ego_dp_powerflow_create_pp_mview.sql
