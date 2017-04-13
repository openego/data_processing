/*
Creation of a new scenario for ego powerflow including the electricity system of Schleswig-Holstein
__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

----------------
-- Create a new scenario 'SH NEP 2035' for the electricity grid in Schleswig-Holstein 
----------------

-- Filter buses whose geometries intersect with the polygon of Schleswig-Holstein 

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_bus
SELECT 'SH NEP 2035', a.bus_id, a.v_nom, a.current_type, a.v_mag_pu_min, a.v_mag_pu_max, a.geom
FROM 	model_draft.ego_grid_pf_hv_bus a, 
	political_boundary.bkg_vg250_2_lan b
WHERE scn_name= 'NEP 2035' AND b.id=26 AND ST_Intersects(ST_Transform(ST_SetSRID(b.geom,31467),4326), a.geom); -- gid=26 is valid for Schleswig-Holstein


-- Include lines connecting buses within the boundaries of the federal state

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE scn_name = 'SH NEP 2035'; 

INSERT INTO 	model_draft.ego_grid_pf_hv_line
SELECT 'SH NEP 2035', a.line_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.capital_cost, a.length, a.cables, a.frequency, a.terrain_factor, a.geom, a.topo
FROM 	model_draft.ego_grid_pf_hv_line a 
WHERE 	scn_name= 'NEP 2035' AND a.bus0 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035') 
	AND a.bus1 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035'); 


-- Filter data from .bus_v_mag_set for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_bus_v_mag_set WHERE scn_name = 'SH NEP 2035'; 
 
INSERT INTO model_draft.ego_grid_pf_hv_bus_v_mag_set
SELECT 'SH NEP 2035', a.bus_id, a.temp_id, a.v_mag_pu_set
FROM model_draft.ego_grid_pf_hv_bus_v_mag_set a
WHERE scn_name= 'NEP 2035' AND a.bus_id IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035');



-- Filter data from .generator for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_generator WHERE scn_name = 'SH NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_generator
SELECT 'SH NEP 2035', a.generator_id, a.bus, a.dispatch, a.control, a.p_nom, a.p_nom_extendable, a.p_nom_min, a.p_nom_max, 
	a.p_min_pu_fixed, a.p_max_pu_fixed, a.sign, a.source, a.marginal_cost, a.capital_cost, a.efficiency
FROM model_draft.ego_grid_pf_hv_generator a
WHERE scn_name= 'NEP 2035' AND a.bus IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035'); 



-- Filter data from .generator_pq_set for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_generator_pq_set WHERE scn_name = 'SH NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_generator_pq_set
SELECT 'SH NEP 2035', a.generator_id, a.temp_id, a.p_set, a.q_set, a.p_min_pu, a.p_max_pu
FROM model_draft.ego_grid_pf_hv_generator_pq_set a
WHERE scn_name= 'NEP 2035' AND a.generator_id IN (SELECT generator_id FROM model_draft.ego_grid_pf_hv_generator WHERE scn_name = 'SH NEP 2035'); 

 

-- Filter data from .load for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_load WHERE scn_name = 'SH NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_load
SELECT 'SH NEP 2035', a.load_id, a.bus, a.sign, a.e_annual
FROM model_draft.ego_grid_pf_hv_load a
WHERE scn_name= 'NEP 2035' AND a.bus IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035'); 


-- Filter data from .load_pq_set for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_load_pq_set WHERE scn_name = 'SH NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_load_pq_set
SELECT 'SH NEP 2035', a.load_id, a.temp_id, a.p_set, a.q_set
FROM model_draft.ego_grid_pf_hv_load_pq_set a
WHERE scn_name= 'NEP 2035' AND a.load_id IN (SELECT load_id FROM model_draft.ego_grid_pf_hv_load WHERE scn_name = 'SH NEP 2035'); 


-- Filter data from .storage for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_storage WHERE scn_name = 'SH NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_storage
SELECT 'SH NEP 2035', a.storage_id, a.bus, a.dispatch, a.control, a.p_nom, a.p_nom_extendable, a.p_nom_min, a.p_nom_max, 
	a.p_min_pu_fixed, a.p_max_pu_fixed, a.sign, a.source, a.marginal_cost, a.capital_cost, a.efficiency, a.soc_initial, a.soc_cyclic, 
	a.max_hours, a.efficiency_store, a.efficiency_dispatch, a.standing_loss
FROM model_draft.ego_grid_pf_hv_storage a
WHERE scn_name= 'NEP 2035' AND a.bus IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035'); 

-- Insert extendable storage at each node

INSERT INTO model_draft.ego_grid_pf_hv_storage
(scn_name,
  storage_id,
  bus,
  dispatch, 
  control, 
  p_nom, 
  p_nom_extendable,
  p_nom_min,
  p_nom_max, 
  p_min_pu_fixed, 
  p_max_pu_fixed,
  sign, 
  source,
  marginal_cost, 
  capital_cost, 
  efficiency,
  soc_initial, 
  soc_cyclic, 
  max_hours,
  efficiency_store, 
  efficiency_dispatch, 
  standing_loss 
)
SELECT 
  'SH NEP 2035',
  nextval('orig_geo_powerplants.pf_storage_single_aggr_id') as aggr_id,
  model_draft.ego_grid_pf_hv_bus.bus_id,  -- assign one storage to each substation
  'flexible', 	-- set storage to be flexible
  'PQ',  -- PQ control
  0,  -- initial power of storage is 0
  false, -- storage is set to extendable in python script
  0, -- there is no lower limit to storage power 
  1000000, -- inf could not be defined, thus very high number
  -1, -- default
  1, -- default
  1, -- default
  11, -- source is for now the one of pumped_storage
  0.01, -- marginal costs are set low in order to dispatch after RES and before conv. PP
  65822, -- set according to Acatech2015 for Lithium-Ion (base year is 2023, not 2035!). Annual cost method based on investment costs per MW. Must be reduced to size of snapshots if extendable storage shall be used.
  1, -- efficiency will be set via efficiency_store and efficiency_dispatch
  0, -- initial storage level is 0
  false, -- cyclic state of charge is false
  6, -- set to 6, to represent daily storage operation  
  1, -- no losses for storing
  1, -- no losses for dispatch
  0 -- no standing losses
FROM model_draft.ego_grid_pf_hv_bus
WHERE scn_name = 'SH NEP 2035';

-- Filter data from .storage_pq_set for new scenario

DELETE FROM model_draft.ego_grid_pf_hv_storage_pq_set WHERE scn_name = 'SH NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_storage_pq_set
SELECT 'SH NEP 2035', a.storage_id, a.temp_id, a.p_set, a.q_set, a.p_min_pu, a.p_max_pu, a.soc_set, a.inflow 
FROM model_draft.ego_grid_pf_hv_storage_pq_set a
WHERE scn_name= 'NEP 2035' AND a.storage_id IN (SELECT storage_id FROM model_draft.ego_grid_pf_hv_storage WHERE scn_name = 'SH NEP 2035'); 


-- Only include transformers connecting buses within the boundaries of the federal state

DELETE FROM model_draft.ego_grid_pf_hv_transformer WHERE scn_name = 'SH NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_transformer
SELECT 'SH NEP 2035', a.trafo_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.tap_ratio, a.phase_shift, a.capital_cost, a.geom, a.topo
FROM 	model_draft.ego_grid_pf_hv_transformer a 
WHERE 	scn_name= 'NEP 2035' AND a.bus0 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035') 
AND a.bus1 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035'); 


-- Delete subgrids identified with PyPSA 

DELETE FROM model_draft.ego_grid_pf_hv_bus
WHERE scn_name = 'SH NEP 2035' AND bus_id IN 
(24415,
26999,  
1053,
1052,
5636,
30,
17146,
23784,
17384); -- include ID of buses which shall be deleted 

--- This part deletes all lines in the 'NEP 2035 EHV' scenario first and includes those lines connecting buses which are included in the adjusted Bus-Table 

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE scn_name = 'SH NEP 2035'; 

INSERT INTO 	model_draft.ego_grid_pf_hv_line
SELECT 	'SH NEP 2035', a.line_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.capital_cost, a.length, a.cables, a.frequency, a.terrain_factor, a.geom, a.topo
FROM 	model_draft.ego_grid_pf_hv_line a 
WHERE 	scn_name= 'NEP 2035' AND a.bus0 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035') 
	AND a.bus1 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035');

--- The same approach for transformers 

DELETE FROM model_draft.ego_grid_pf_hv_transformer WHERE scn_name = 'SH NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_transformer
SELECT 'SH NEP 2035', a.trafo_id, a.bus0, a.bus1, a.x, a.r, a.g, a.b, a.s_nom, a.s_nom_extendable, a.s_nom_min, 
	a.s_nom_max, a.tap_ratio, a.phase_shift, a.capital_cost, a.geom, a.topo
FROM 	model_draft.ego_grid_pf_hv_transformer a 
WHERE 	scn_name= 'NEP 2035' AND a.bus0 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035') 
	AND a.bus1 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'SH NEP 2035'); 


-- Delete all generators which were connected to deleted buses

DELETE FROM model_draft.ego_grid_pf_hv_generator 
WHERE scn_name = 'SH NEP 2035' AND bus NOT IN 
(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name='SH NEP 2035'); -- include ID of buses which shall be deleted 


DELETE FROM model_draft.ego_grid_pf_hv_generator_pq_set 
WHERE scn_name='SH NEP 2035' AND generator_id NOT IN 
	(SELECT generator_id FROM model_draft.ego_grid_pf_hv_generator WHERE scn_name='SH NEP 2035'); 



-- Delete all loads which were connected to deleted buses

DELETE FROM model_draft.ego_grid_pf_hv_load 
WHERE scn_name = 'SH NEP 2035' AND bus NOT IN 
(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name='SH NEP 2035'); -- include ID of buses which shall be deleted 


DELETE FROM model_draft.ego_grid_pf_hv_load_pq_set 
WHERE scn_name='SH NEP 2035' AND load_id NOT IN 
	(SELECT load_id FROM model_draft.ego_grid_pf_hv_load WHERE scn_name='SH NEP 2035'); 



-- Delete all storages which were connected to deleted buses

DELETE FROM model_draft.ego_grid_pf_hv_storage 
WHERE scn_name = 'SH NEP 2035' AND bus NOT IN 
(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name='SH NEP 2035'); -- include ID of buses which shall be deleted 


DELETE FROM model_draft.ego_grid_pf_hv_storage_pq_set 
WHERE scn_name='SH NEP 2035' AND storage_id NOT IN 
	(SELECT storage_id FROM model_draft.ego_grid_pf_hv_storage WHERE scn_name='SH NEP 2035'); 
