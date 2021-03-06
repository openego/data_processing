/*
Creation of a new scenario for ego powerflow including the electricity system of Schleswig-Holstein
__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

----------------
-- Create a new scenario 'SH Status Quo' for the electricity grid in Schleswig-Holstein 
----------------

-- Filter buses whose geometries intersect with the polygon of Schleswig-Holstein 

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo'; 

INSERT INTO model_draft.ego_grid_pf_hv_bus
   SELECT 'SH Status Quo', a.bus_id, a.v_nom, a.current_type, a.v_mag_pu_min, a.v_mag_pu_max, a.geom
   FROM 	model_draft.ego_grid_pf_hv_bus a, 
		boundaries.bkg_vg250_2_lan b
   WHERE 	(scn_name= 'Status Quo' AND b.id=26 AND (ST_Intersects(ST_Transform(ST_SetSRID(b.geom,31467),4326), a.geom))); 

-- Insert buses relevant for SH grid topology manually

INSERT INTO model_draft.ego_grid_pf_hv_bus
	SELECT 		'SH Status Quo', a.bus_id, a.v_nom, a.current_type, a.v_mag_pu_min, a.v_mag_pu_max, a.geom
	FROM 		model_draft.ego_grid_pf_hv_bus a
	WHERE 		scn_name='Status Quo' AND bus_id IN (1055, 23786);


-- Include lines connecting buses within the boundaries of the federal state

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE scn_name = 'SH Status Quo'; 

INSERT INTO 	model_draft.ego_grid_pf_hv_line
SELECT 'SH Status Quo', a.line_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.capital_cost, a.length, a.cables, a.frequency, a.terrain_factor, a.geom, a.topo
FROM 	model_draft.ego_grid_pf_hv_line a 
WHERE 	scn_name= 'Status Quo' AND a.bus0 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo') 
	AND a.bus1 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo'); 


-- Filter data from .bus_v_mag_set for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_bus_v_mag_set WHERE scn_name = 'SH Status Quo'; 
 
INSERT INTO model_draft.ego_grid_pf_hv_bus_v_mag_set
SELECT 'SH Status Quo', a.bus_id, a.temp_id, a.v_mag_pu_set
FROM model_draft.ego_grid_pf_hv_bus_v_mag_set a
WHERE scn_name= 'Status Quo' AND a.bus_id IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo');



-- Filter data from .generator for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_generator WHERE scn_name = 'SH Status Quo'; 

INSERT INTO model_draft.ego_grid_pf_hv_generator
SELECT 'SH Status Quo', a.generator_id, a.bus, a.dispatch, a.control, a.p_nom, a.p_nom_extendable, a.p_nom_min, a.p_nom_max, 
	a.p_min_pu_fixed, a.p_max_pu_fixed, a.sign, a.source, a.marginal_cost, a.capital_cost, a.efficiency
FROM model_draft.ego_grid_pf_hv_generator a
WHERE scn_name= 'Status Quo' AND a.bus IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo'); 



-- Filter data from .generator_pq_set for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_generator_pq_set WHERE scn_name = 'SH Status Quo'; 

INSERT INTO model_draft.ego_grid_pf_hv_generator_pq_set
SELECT 'SH Status Quo', a.generator_id, a.temp_id, a.p_set, a.q_set, a.p_min_pu, a.p_max_pu
FROM model_draft.ego_grid_pf_hv_generator_pq_set a
WHERE scn_name= 'Status Quo' AND a.generator_id IN (SELECT generator_id FROM model_draft.ego_grid_pf_hv_generator WHERE scn_name = 'SH Status Quo'); 

 

-- Filter data from .load for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_load WHERE scn_name = 'SH Status Quo'; 

INSERT INTO model_draft.ego_grid_pf_hv_load
SELECT 'SH Status Quo', a.load_id, a.bus, a.sign, a.e_annual
FROM model_draft.ego_grid_pf_hv_load a
WHERE scn_name= 'Status Quo' AND a.bus IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo'); 


-- Filter data from .load_pq_set for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_load_pq_set WHERE scn_name = 'SH Status Quo'; 

INSERT INTO model_draft.ego_grid_pf_hv_load_pq_set
SELECT 'SH Status Quo', a.load_id, a.temp_id, a.p_set, a.q_set
FROM model_draft.ego_grid_pf_hv_load_pq_set a
WHERE scn_name= 'Status Quo' AND a.load_id IN (SELECT load_id FROM model_draft.ego_grid_pf_hv_load WHERE scn_name = 'SH Status Quo'); 


-- Filter data from .storage for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_storage WHERE scn_name = 'SH Status Quo'; 

INSERT INTO model_draft.ego_grid_pf_hv_storage
SELECT 'SH Status Quo', a.storage_id, a.bus, a.dispatch, a.control, a.p_nom, a.p_nom_extendable, a.p_nom_min, a.p_nom_max, 
	a.p_min_pu_fixed, a.p_max_pu_fixed, a.sign, a.source, a.marginal_cost, a.capital_cost, a.efficiency, a.soc_initial, a.soc_cyclic, 
	a.max_hours, a.efficiency_store, a.efficiency_dispatch, a.standing_loss
FROM model_draft.ego_grid_pf_hv_storage a
WHERE scn_name= 'Status Quo' AND a.bus IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo'); 


-- Filter data from .storage_pq_set for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_storage_pq_set WHERE scn_name = 'SH Status Quo'; 

INSERT INTO model_draft.ego_grid_pf_hv_storage_pq_set
SELECT 'SH Status Quo', a.storage_id, a.temp_id, a.p_set, a.q_set, a.p_min_pu, a.p_max_pu, a.soc_set, a.inflow 
FROM model_draft.ego_grid_pf_hv_storage_pq_set a
WHERE scn_name= 'Status Quo' AND a.storage_id IN (SELECT storage_id FROM model_draft.ego_grid_pf_hv_storage WHERE scn_name = 'SH Status Quo'); 


-- Only include transformers connecting buses within the boundaries of the federal state

DELETE FROM model_draft.ego_grid_pf_hv_transformer WHERE scn_name = 'SH Status Quo'; 

INSERT INTO model_draft.ego_grid_pf_hv_transformer
SELECT 'SH Status Quo', a.trafo_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.tap_ratio, a.phase_shift, a.capital_cost, a.geom, a.topo
FROM 	model_draft.ego_grid_pf_hv_transformer a 
WHERE 	scn_name= 'Status Quo' AND a.bus0 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo') 
	AND a.bus1 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo'); 


-- Delete subnetworks identified in PyPSA

DELETE FROM model_draft.ego_grid_pf_hv_bus
WHERE scn_name = 'SH Status Quo' AND bus_id IN 
(24415, 
 26999, 
 30, 
 17146, 
 23784, 
 17384); -- include ID of buses which shall be deleted 

--- This part deletes all lines in the 'Status Quo EHV' scenario first and includes those lines connecting buses which are included in the adjusted Bus-Table 

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE scn_name = 'SH Status Quo'; 

INSERT INTO 	model_draft.ego_grid_pf_hv_line
SELECT 	'SH Status Quo', a.line_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.capital_cost, a.length, a.cables, a.frequency, a.terrain_factor, a.geom, a.topo
FROM 	model_draft.ego_grid_pf_hv_line a 
WHERE 	scn_name= 'Status Quo' AND a.bus0 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo') 
	AND a.bus1 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo');

--- The same approach for transformers 

DELETE FROM model_draft.ego_grid_pf_hv_transformer WHERE scn_name = 'SH Status Quo'; 

INSERT INTO model_draft.ego_grid_pf_hv_transformer
SELECT 'SH Status Quo', a.trafo_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.tap_ratio, a.phase_shift, a.capital_cost, a.geom, a.topo
FROM 	model_draft.ego_grid_pf_hv_transformer a 
WHERE 	scn_name= 'Status Quo' AND a.bus0 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo') 
	AND a.bus1 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH Status Quo'); 


-- Delete all generators which were connected to deleted buses

DELETE FROM model_draft.ego_grid_pf_hv_generator 
WHERE scn_name = 'SH Status Quo' AND bus NOT IN 
(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name='SH Status Quo'); -- include ID of buses which shall be deleted 


DELETE FROM model_draft.ego_grid_pf_hv_generator_pq_set 
WHERE scn_name='SH Status Quo' AND generator_id NOT IN 
	(SELECT generator_id FROM model_draft.ego_grid_pf_hv_generator WHERE scn_name='SH Status Quo'); 



-- Delete all loads which were connected to deleted buses

DELETE FROM model_draft.ego_grid_pf_hv_load 
WHERE scn_name = 'SH Status Quo' AND bus NOT IN 
(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name='SH Status Quo'); -- include ID of buses which shall be deleted 


DELETE FROM model_draft.ego_grid_pf_hv_load_pq_set 
WHERE scn_name='SH Status Quo' AND load_id NOT IN 
	(SELECT load_id FROM model_draft.ego_grid_pf_hv_load WHERE scn_name='SH Status Quo'); 



-- Delete all storages which were connected to deleted buses

DELETE FROM model_draft.ego_grid_pf_hv_storage 
WHERE scn_name = 'SH Status Quo' AND bus NOT IN 
(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name='SH Status Quo'); -- include ID of buses which shall be deleted 


DELETE FROM model_draft.ego_grid_pf_hv_storage_pq_set 
WHERE scn_name='SH Status Quo' AND storage_id NOT IN 
(SELECT storage_id FROM model_draft.ego_grid_pf_hv_storage WHERE scn_name='SH Status Quo'); 
