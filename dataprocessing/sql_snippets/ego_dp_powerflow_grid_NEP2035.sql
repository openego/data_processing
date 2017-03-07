/*
Copy SQ grid to NEP2035 scenario

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

----------------
-- Create a new scenario 'NEP 2035' for the interconnected electrical grid in Germany
----------------

-- Use buses from the scenario 'Status Quo' for the new scenario

DELETE FROM calc_ego_hv_powerflow.bus WHERE scn_name = 'NEP 2035'; 

INSERT INTO calc_ego_hv_powerflow.bus
SELECT 'NEP 2035', a.bus_id, a.v_nom, a.current_type, a.v_mag_pu_min, a.v_mag_pu_max, a.geom
FROM 	calc_ego_hv_powerflow.bus a 
WHERE scn_name= 'Status Quo';


-- Include all lines from SQ scenario in the NEP 2035 scenario

DELETE FROM calc_ego_hv_powerflow.line WHERE scn_name = 'NEP 2035'; 

INSERT INTO 	calc_ego_hv_powerflow.line
SELECT 'NEP 2035', a.line_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.capital_cost, a.length, a.cables, a.frequency, a.terrain_factor, a.geom, a.topo
FROM 	calc_ego_hv_powerflow.line a 
WHERE 	scn_name= 'Status Quo'; 


-- Include transformers from Status Quo into new scenario 'NEP 2035'

DELETE FROM calc_ego_hv_powerflow.transformer WHERE scn_name = 'NEP 2035'; 

INSERT INTO calc_ego_hv_powerflow.transformer
SELECT 'NEP 2035', a.trafo_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.tap_ratio, a.phase_shift, a.capital_cost, a.geom, a.topo
FROM 	calc_ego_hv_powerflow.transformer a 
WHERE scn_name= 'Status Quo'; 
