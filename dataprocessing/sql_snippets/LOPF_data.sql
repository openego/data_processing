/*
LOPF data -
Setting marginal_cost ( operating cost + fuel cost + CO2 crt cost ) 
in model_draft.ego_grid_pf_hv_generator according to renpass_gis, NEP 2014 scenario.
In addition p_max_pu is set for all generators with variable dispatch based on p_max_pu = p_set / p_nom .

__copyright__ 	= "Europa-Universität Flensburg, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "s3pp, lukasol"
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
ELSE 0                      -- run_of_river/reservoir/pumped_storage/solar/wind/geothermal/other_non_renewable
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
ELSE 0                      -- run_of_river/reservoir/pumped_storage/solar/wind/geothermal/other_non_renewable
END)
where scn_name = 'NEP 2035';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_grid_pf_hv_generator','LOPF_data.sql',' ');

-- set p_max_pu
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
) T3 WHERE T3.generator_id = Y.generator_id;

/*
-- set storage parameters to every node with p_nom_extendable as true
-- by Lukas

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
SELECT 'Status Quo',
  nextval('orig_geo_powerplants.pf_storage_single_aggr_id') as aggr_id,
  model_draft.ego_grid_hvmv_substation.otg_id,  -- assign one storage to each substation
  'flexible', 	-- set storage to be flexible
  'PQ',  -- PQ control
  0,  -- initial power of storage is 0
  true, -- storage is extendable
  0, -- there is no lower limit to storage power
  1000000, -- inf could not be defined, thus very high number
  0, -- default
  1, -- default
  1, -- default
  null, -- source could not be set to 0, so null.
  (39.5156 + 1.5 + 1), -- marginal costs are those of oil / source no.4 plus 1
  1000, -- this is an assumption as of now, must be defined when calculating for more than 1 or 2 hours
  1, -- efficiency will be set via efficiency_store and efficiency_dispatch
  0, -- initial storage level is 0
  false, -- cyclic state of charge is false
  10, -- max hours is set to 10, just an assumption as of now
  1, -- no losses for storing
  1, -- no losses for dispatch
  0 -- no standing losses
FROM model_draft.ego_grid_hvmv_substation;
*/
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_grid_pf_hv_generator_pq_set','LOPF_data.sql',' ');
