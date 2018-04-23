/*
The grid model which is used as an input for powerflow calculations and optimization in open_eGo is the same in all 
three scenarios 'SQ', 'NEP 2035' and 'eGo100'. 
In the following script the grid model created for the 'SQ' scenario in the previous scripts is duplicated for the remaining
two future scenarios

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

----------------
-- Create a new scenario 'NEP 2035' for the interconnected electrical grid in Germany
----------------

-- Use buses from the scenario 'Status Quo' for the new scenario

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_bus
SELECT 'NEP 2035', a.bus_id, a.v_nom, a.current_type, a.v_mag_pu_min, a.v_mag_pu_max, a.geom
FROM 	model_draft.ego_grid_pf_hv_bus a 
WHERE scn_name= 'Status Quo';


-- Include all lines from SQ scenario in the NEP 2035 scenario

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE scn_name = 'NEP 2035'; 

INSERT INTO 	model_draft.ego_grid_pf_hv_line
SELECT 'NEP 2035', a.line_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.capital_cost, a.length, a.cables, a.frequency, a.terrain_factor, a.geom, a.topo
FROM 	model_draft.ego_grid_pf_hv_line a 
WHERE 	scn_name= 'Status Quo'; 


-- Include transformers from Status Quo into new scenario 'NEP 2035'

DELETE FROM model_draft.ego_grid_pf_hv_transformer WHERE scn_name = 'NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_transformer
SELECT 'NEP 2035', a.trafo_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.tap_ratio, a.phase_shift, a.capital_cost, a.geom, a.topo
FROM 	model_draft.ego_grid_pf_hv_transformer a 
WHERE scn_name= 'Status Quo';

----------------
-- Create a new scenario 'eGo 100' for the interconnected electrical grid in Germany
----------------

-- Use buses from the scenario 'Status Quo' for the new scenario

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'eGo 100'; 

INSERT INTO model_draft.ego_grid_pf_hv_bus
SELECT 'eGo 100', a.bus_id, a.v_nom, a.current_type, a.v_mag_pu_min, a.v_mag_pu_max, a.geom
FROM 	model_draft.ego_grid_pf_hv_bus a 
WHERE scn_name= 'Status Quo';


-- Include all lines from SQ scenario in the eGo 100 scenario

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE scn_name = 'eGo 100'; 

INSERT INTO 	model_draft.ego_grid_pf_hv_line
SELECT 'eGo 100', a.line_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.capital_cost, a.length, a.cables, a.frequency, a.terrain_factor, a.geom, a.topo
FROM 	model_draft.ego_grid_pf_hv_line a 
WHERE 	scn_name= 'Status Quo'; 


-- Include transformers from Status Quo into new scenario 'eGo 100'

DELETE FROM model_draft.ego_grid_pf_hv_transformer WHERE scn_name = 'eGo 100'; 

INSERT INTO model_draft.ego_grid_pf_hv_transformer
SELECT 'eGo 100', a.trafo_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.tap_ratio, a.phase_shift, a.capital_cost, a.geom, a.topo
FROM 	model_draft.ego_grid_pf_hv_transformer a 
WHERE scn_name= 'Status Quo';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','output','model_draft','ego_grid_pf_hv_bus','ego_dp_powerflow_grid_NEP2035.sql',' ');
SELECT scenario_log('eGo_DP', 'v0.4.0','output','model_draft','ego_grid_pf_hv_line','ego_dp_powerflow_grid_NEP2035.sql',' ');
SELECT scenario_log('eGo_DP', 'v0.4.0','output','model_draft','ego_grid_pf_hv_transformer','ego_dp_powerflow_grid_NEP2035.sql',' ');
