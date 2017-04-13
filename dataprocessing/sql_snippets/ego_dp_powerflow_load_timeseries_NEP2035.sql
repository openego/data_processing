/*
Copy timeseries from SQ to 'NEP 2035' scenario

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

---------------
-- Add load time series to future scenarios equivalent to Status Quo scenario
---------------


-- Include data from .load_pq_set for scenario 'NEP 2035' equivalent to Status Quo 

DELETE FROM model_draft.ego_grid_pf_hv_load_pq_set WHERE scn_name = 'NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_load_pq_set
SELECT 'NEP 2035', a.load_id, a.temp_id, a.p_set, a.q_set
FROM model_draft.ego_grid_pf_hv_load_pq_set a
WHERE scn_name= 'Status Quo'; 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.9','output','model_draft','ego_grid_pf_hv_load_pq_set','ego_dp_powerflow_load_timeseries_NEP2035.sql',' ');
