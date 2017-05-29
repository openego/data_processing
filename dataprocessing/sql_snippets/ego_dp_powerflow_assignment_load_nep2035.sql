/*
Load data from scenario 'Status Quo' are used for scenario 'NEP 2035' and are therefore dupilcated 

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

-------------
-- Add information for future scenarios to hv_powerflow schema under the assumption that the consumption remains constant 
-------------

-- Loads in scenario 'NEP 2035' are equivalent to 'Status Quo'

DELETE FROM model_draft.ego_grid_pf_hv_load WHERE scn_name = 'NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_load
SELECT 'NEP 2035', a.load_id, a.bus, a.sign, a.e_annual
FROM model_draft.ego_grid_pf_hv_load a
WHERE scn_name= 'Status Quo'; 
