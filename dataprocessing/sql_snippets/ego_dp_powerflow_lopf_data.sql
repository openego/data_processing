/*
Missing parameters necessary for calculating a linear optimal power flow (LOPF) are added to the existing data. This
includes marginal costs per technology, which is composed of specific operating cost, fuel costs and CO2 costs 
according to renpass_gis, NEP 2014 scenario. 
In addition p_max_pu is set for all generators with variable dispatch based on p_max_pu = p_set / p_nom.

A further section of the script is used to insert extendable battery and hydrogen storages to all substations in the 
grid model. These have a initial installed capacity p_nom=0, which can be extended when executing an optimization 
(by calculating a LOPF). 

__copyright__ 	= "Europa-Universität Flensburg, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "wolfbunke, lukasol"
*/



UPDATE model_draft.ego_grid_pf_hv_generator
SET marginal_cost =        -- operating costs + fuel costs + CO2 crt cost
(
CASE source                 -- source / renpass_gis NEP 2014 
when 1 THEN (30.3012 + 2.0) -- gas / gas
when 2 THEN (6.3761 + 4.4)  -- lignite / lignite
when 3 THEN (8.6470 + 23.0) -- waste / waste
when 4 THEN (39.5156 + 1.5) -- oil / oil
when 5 THEN (4.1832 + 0.5)  -- uranium / uranium
when 6 THEN (20.0586 + 3.9) -- biomass / biomass
when 7 THEN (30.3012 + 2.0) -- eeg_gas / gas
when 8 THEN (10.9541 + 4.0) -- coal / hard_coal
when 15 THEN (39.5156 + 1.5) -- other_non_renewable / other_non_renewable -- assumption:same price as oil!
ELSE 0                      -- run_of_river/reservoir/pumped_storage/solar/wind/geothermal
END)
where scn_name = 'Status Quo';

UPDATE model_draft.ego_grid_pf_hv_generator
SET marginal_cost =        -- operating costs + fuel costs + CO2 crt cost
(
CASE source                 -- source / renpass_gis NEP 2014
when 1 THEN (39.9344 + 2.0) -- gas / gas
when 2 THEN (13.2412 + 4.4)  -- lignite / lignite
when 3 THEN (16.9297 + 23.0) -- waste / waste
when 4 THEN (67.3643 + 1.5) -- oil / oil
when 5 THEN (4.9781 + 0.5)  -- uranium / uranium
when 6 THEN (27.5112 + 3.9) -- biomass / biomass
when 7 THEN (39.9344 + 2.0) -- eeg_gas / gas
when 8 THEN (20.7914 + 4.0) -- coal / hard_coal
when 15 THEN (67.3643 + 1.5) -- other_non_renewable / other_non_renewable -- assumption:same price as oil!
ELSE 0                      -- run_of_river/reservoir/pumped_storage/solar/wind/geothermal
END)
where scn_name = 'NEP 2035';


UPDATE model_draft.ego_grid_pf_hv_generator
SET marginal_cost =        -- operating costs + fuel costs + CO2 crt cost
(
CASE source                 -- source / renpass_gis ZNES eHighway 2050
when 1 THEN (54.0533 + 2.0) -- gas / gas
--when 2 THEN (13.2412 + 4.4)  -- lignite / lignite
--when 3 THEN (16.9297 + 23.0) -- waste / waste
--when 4 THEN (67.3643 + 1.5) -- oil / oil
---when 5 THEN (4.9781 + 0.5)  -- uranium / uranium
when 6 THEN (27.7348 + 3.9) -- biomass / biomass
when 7 THEN (54.0533 + 2.0) -- eeg_gas / gas
--when 8 THEN (20.7914 + 4.0) -- coal / hard_coal
when 15 THEN (67.3643 + 1.5) -- other_non_renewable / other_non_renewable -- assumption:same price as oil!
ELSE 0                      -- run_of_river/reservoir/pumped_storage/solar/wind/geothermal
END)
where scn_name = 'eGo 100';



-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','output','model_draft','ego_grid_pf_hv_generator','ego_dp_powerflow_lopf_data.sql',' ');

-- set p_max_pu

DELETE FROM model_draft.ego_grid_pf_hv_generator WHERE p_nom=0; 

-- TODO: outermost subquery needed?
UPDATE model_draft.ego_grid_pf_hv_generator_pq_set Y
SET p_max_pu = T3.p_max_pu
FROM (
	SELECT T2.generator_id, array_agg(T2.p_max_pu ORDER BY rn) as p_max_pu
	FROM
		(
			SELECT T1.*, row_number() over() AS rn -- row number introduced to keep array order
			FROM (
				SELECT 
				B.generator_id, 
				A.p_nom , 
				unnest(B.p_set) / A.p_nom AS p_max_pu 
				FROM model_draft.ego_grid_pf_hv_generator A
				JOIN model_draft.ego_grid_pf_hv_generator_pq_set  B USING (generator_id)
				WHERE A.dispatch = 'variable'
			) AS T1
		) AS T2 
	GROUP BY T2.generator_id
) T3 WHERE T3.generator_id = Y.generator_id
AND Y.p_max_pu IS NULL;

DELETE FROM model_draft.ego_grid_pf_hv_storage WHERE scn_name IN ('Status Quo', 'NEP 2035', 'eGo 100') AND source = 16;

-- Insert battery storages to all substations (Status Quo)
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
  'Status Quo',
  nextval('model_draft.ego_supply_pf_storage_single_aggr_id') as aggr_id,
  model_draft.ego_grid_hvmv_substation.otg_id,  -- assign storage to substation
  'flexible', 	-- set storage to be flexible
  'PQ',  -- PQ control
  0,  -- initial power of storage is 0
  false, -- storage is set to extendable in python script
  0, -- there is no lower limit to storage power 
  1000000, -- inf could not be defined, thus very high number
  -1, -- default
  1, -- default
  1, -- default
  16, -- source is extendable_storage
  0.01, -- marginal costs are set low in order to dispatch after RES and before conv. PP
  229357, -- set according to Acatech2015 for Lithium-Ion. Annual cost method based on investment costs per MW. Must be reduced to size of snapshots if extendable storage shall be used.
  1, -- efficiency is set below 
  0, -- initial storage level is 0
  true, -- cyclic state of charge is true
  6, -- set to 6, to represent daily storage operation  
  0.9247, -- efficiency according to Acatech2015
  0.9247, -- efficiency according to Acatech2015
  0.00972 -- standing losses according to Acatech2015
FROM model_draft.ego_grid_hvmv_substation;

-- Insert battery storages to all substations (NEP 2035)
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
  'NEP 2035',
  nextval('model_draft.ego_supply_pf_storage_single_aggr_id') as aggr_id,
  model_draft.ego_grid_hvmv_substation.otg_id,  -- assign storage to substation
  'flexible', 	-- set storage to be flexible
  'PQ',  -- PQ control
  0,  -- initial power of storage is 0
  false, -- storage is set to extendable in python script
  0, -- there is no lower limit to storage power 
  1000000, -- inf could not be defined, thus very high number
  -1, -- default
  1, -- default
  1, -- default
  16, -- source is extendable_storage
  0.01, -- marginal costs are set low in order to dispatch after RES and before conv. PP
  65822, -- set according to Acatech2015 for Lithium-Ion (base year is 2023, not 2035!). Annual cost method based on investment costs per MW. Must be reduced to size of snapshots if extendable storage shall be used.
  1, -- efficiency is set below
  0, -- initial storage level is 0
  true, -- cyclic state of charge is true
  6, -- set to 6, to represent daily storage operation  
  0.9327, -- efficiency according to Acatech2015
  0.9327, -- efficiency according to Acatech2015
  0.00694 -- standing losses according to Acatech2015
FROM model_draft.ego_grid_hvmv_substation;


-- Insert battery storages to all substations (eGo 100)
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
  'eGo 100',
  nextval('model_draft.ego_supply_pf_storage_single_aggr_id') as aggr_id,
  model_draft.ego_grid_hvmv_substation.otg_id,  -- assign storage to substation
 'flexible', 	-- set storage to be flexible
  'PQ',  -- PQ control
  0,  -- initial power of storage is 0
  false, -- storage is set to extendable in python script
  0, -- there is no lower limit to storage power 
  1000000, -- inf could not be defined, thus very high number
  -1, -- default
  1, -- default
  1, -- default
  16, -- source is extendable_storage
  0.01, -- marginal costs are set low in order to dispatch after RES and before conv. PP
  44546, -- set according to Acatech2015 for Lithium-Ion (base year is 2023, not 2035!). Annual cost method based on investment costs per MW. Must be reduced to size of snapshots if extendable storage shall be used.
  1, -- efficiency is set below
  0, -- initial storage level is 0
  true, -- cyclic state of charge is true
  6, -- set to 6, to represent daily storage operation  
  0.9487, -- efficiency according to Acatech2015
  0.9487, -- efficiency according to Acatech2015
  0.00417 -- standing losses according to Acatech2015
FROM model_draft.ego_grid_hvmv_substation;

-- Insert Hydrogen storages to substations with potential (Status Quo)
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
  'Status Quo',
  nextval('model_draft.ego_supply_pf_storage_single_aggr_id') as aggr_id,
  model_draft.ego_grid_hvmv_substation.otg_id,  -- assign storage to substation
  'flexible', 	-- set storage to be flexible
  'PQ',  -- PQ control
  0,  -- initial power of storage is 0
  false, -- storage is set to extendable in appl.py
  0, -- there is no lower limit to storage power 
  1000000, -- inf could not be defined, thus very high number
  -1, -- default
  1, -- default
  1, -- default
  16, -- source is extendable_storage
  0.01, -- marginal costs are set low in order to dispatch after RES and before conv. PP
  94776, -- set according to Acatech2015 for Hydrogen. Annual cost method based on investment costs per MW. Is reduced to size of snapshots if extendable storage shall be used.
  1, -- efficiency is set below
  0, -- initial storage level is 0
  true, -- cyclic state of charge is true
  168, -- set to 168, to represent weekly storage operation  
  0.675, -- efficiency according to Acatech2015
  0.375, -- efficiency according to Acatech2015
  0.000694 -- standing losses according to Acatech2015
FROM model_draft.ego_grid_hvmv_substation
WHERE model_draft.ego_grid_hvmv_substation.subst_id IN (
            SELECT model_draft.ego_grid_hvmv_substation.subst_id
				FROM model_draft.ego_grid_hvmv_substation, model_draft.ego_storage_h2_areas_de as salt
				WHERE salt.geom && model_draft.ego_grid_hvmv_substation.point
				AND ST_CONTAINS(salt.geom,model_draft.ego_grid_hvmv_substation.point));
				
-- Insert Hydrogen storages to substations with potential (NEP 2035)
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
  'NEP 2035',
  nextval('model_draft.ego_supply_pf_storage_single_aggr_id') as aggr_id,
  model_draft.ego_grid_hvmv_substation.otg_id,  -- assign storage to substation
  'flexible', 	-- set storage to be flexible
  'PQ',  -- PQ control
  0,  -- initial power of storage is 0
  false, -- storage is set to extendable in appl.py
  0, -- there is no lower limit to storage power 
  1000000, -- inf could not be defined, thus very high number
  -1, -- default
  1, -- default
  1, -- default
  16, -- source is extendable_storage
  0.01, -- marginal costs are set low in order to dispatch after RES and before conv. PP
  65402, -- set according to Acatech2015 for Hydrogen (reference year is 2023). Annual cost method based on investment costs per MW. Is reduced to size of snapshots if extendable storage shall be used.
  1, -- efficiency is set below
  0, -- initial storage level is 0
  true, -- cyclic state of charge is true
  168, -- set to 168, to represent weekly storage operation  
  0.725, -- efficiency according to Acatech2015
  0.425, -- efficiency according to Acatech2015
  0.000694 -- standing losses according to Acatech2015
FROM model_draft.ego_grid_hvmv_substation
WHERE model_draft.ego_grid_hvmv_substation.subst_id IN (
            SELECT model_draft.ego_grid_hvmv_substation.subst_id
				FROM model_draft.ego_grid_hvmv_substation, model_draft.ego_storage_h2_areas_de as salt
				WHERE salt.geom && model_draft.ego_grid_hvmv_substation.point
				AND ST_CONTAINS(salt.geom,model_draft.ego_grid_hvmv_substation.point));
				
-- Insert Hydrogen storages to substations with potential (eGo 100)
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
  'eGo 100',
  nextval('model_draft.ego_supply_pf_storage_single_aggr_id') as aggr_id,
  model_draft.ego_grid_hvmv_substation.otg_id,  -- assign storage to substation
  'flexible', 	-- set storage to be flexible
  'PQ',  -- PQ control
  0,  -- initial power of storage is 0
  false, -- storage is set to extendable in appl.py
  0, -- there is no lower limit to storage power 
  1000000, -- inf could not be defined, thus very high number
  -1, -- default
  1, -- default
  1, -- default
  16, -- source is extendable_storage
  0.01, -- marginal costs are set low in order to dispatch after RES and before conv. PP
  47777, -- set according to Acatech2015 for Hydrogen (reference year is 2023). Annual cost method based on investment costs per MW. Is reduced to size of snapshots if extendable storage shall be used.
  1, -- efficiency is set below
  0, -- initial storage level is 0
  true, -- cyclic state of charge is true
  168, -- set to 168, to represent weekly storage operation  
  0.785, -- efficiency according to Acatech2015
  0.57, -- efficiency according to Acatech2015
  0.000694 -- standing losses according to Acatech2015
FROM model_draft.ego_grid_hvmv_substation
WHERE model_draft.ego_grid_hvmv_substation.subst_id IN (
            SELECT model_draft.ego_grid_hvmv_substation.subst_id
				FROM model_draft.ego_grid_hvmv_substation, model_draft.ego_storage_h2_areas_de as salt
				WHERE salt.geom && model_draft.ego_grid_hvmv_substation.point
				AND ST_CONTAINS(salt.geom,model_draft.ego_grid_hvmv_substation.point));
				
-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','output','model_draft','ego_grid_pf_hv_storage','ego_dp_powerflow_lopf_data.sql',' ');				

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','output','model_draft','ego_grid_pf_hv_generator_pq_set','ego_dp_powerflow_lopf_data.sql',' ');
