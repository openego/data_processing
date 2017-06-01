/*
Assignment of storage units to the relevant substation in the grid model. Scenario based on 'Status Quo'. 
__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

DROP TABLE IF EXISTS model_draft.ego_supply_pf_storage_single;

CREATE TABLE model_draft.ego_supply_pf_storage_single
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo',
  storage_id bigint NOT NULL, 
  bus bigint,
  dispatch text DEFAULT 'flexible'::text, 
  control text DEFAULT 'PQ'::text, 
  p_nom double precision DEFAULT 0, 
  p_nom_extendable boolean DEFAULT false, 
  p_nom_min double precision DEFAULT 0, 
  p_nom_max double precision, 
  p_min_pu_fixed double precision DEFAULT 0, 
  p_max_pu_fixed double precision DEFAULT 1, 
  sign double precision DEFAULT 1, 
  source bigint, 
  marginal_cost double precision, 
  capital_cost double precision, 
  efficiency double precision, 
  soc_initial double precision, 
  soc_cyclic boolean DEFAULT false, 
  max_hours double precision, 
  efficiency_store double precision, 
  efficiency_dispatch double precision, 
  standing_loss double precision,
  aggr_id integer, 
 CONSTRAINT storage_data_pkey PRIMARY KEY (storage_id, scn_name)
);

-- Insert storage data into powerflow schema, that contains all storage units seperately 

INSERT INTO model_draft.ego_supply_pf_storage_single (scn_name, storage_id)
	SELECT 'Status Quo', un_id
	FROM model_draft.ego_supply_generator
	WHERE conv_id IN 
		(SELECT a.gid 
		  FROM model_draft.ego_supply_conv_powerplant a
		  WHERE capacity > 0 AND a.fuel= 'pumped_storage'
); -- only (pumped) storage units from NEP 2035 scenario are selected and written into pf_storage_single #


-- For pumped storage (this section needs to be extended as soon as other storage technologies are included) 

UPDATE model_draft.ego_supply_pf_storage_single a
	SET bus = b.otg_id, 
		p_nom = b.capacity, 
		control = 'PV',  -- For pumped storage units control is set to PV
		source = result.source
		FROM 
			(SELECT c.source_id as source, d.fuel as fuel
			FROM 	model_draft.ego_grid_pf_hv_source c, 
				model_draft.ego_supply_conv_powerplant d 
			WHERE	d.capacity > 0 AND d.fuel = c.name) 
			AS 	result,		
			model_draft.ego_supply_conv_powerplant b
WHERE a.scn_name = 'Status Quo' AND a.storage_id = b.un_id AND result.fuel = 'pumped_storage' AND result.fuel = b.fuel;

DELETE FROM model_draft.ego_supply_pf_storage_single WHERE p_nom IS NULL; -- Delete those PS units without an entry on the installed capacity



-- Create aggregate IDs in pf_storage_single

-- source= pumped_storage and p_nom < 50 MW 
	
UPDATE model_draft.ego_supply_pf_storage_single a
	SET aggr_id = result.aggr_id
		FROM 
			(SELECT b.bus, b.source, nextval('model_draft.ego_supply_pf_storage_single_aggr_id') as aggr_id
			FROM model_draft.ego_supply_pf_storage_single b 
			WHERE p_nom < 50 AND source NOT IN 
				(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'pumped_storage')
			GROUP BY b.bus, b.source)
			as result
	WHERE a.bus = result.bus AND a.source = result.source;

-- all sources (in the moment this only includes pumped storage) and p_nom >= 50MW

UPDATE model_draft.ego_supply_pf_storage_single a
	SET aggr_id = nextval('model_draft.ego_supply_pf_storage_single_aggr_id')
	WHERE a.p_nom >= 50;


-----------
-- Accumulate data from pf_storage_single and insert into hv_powerflow schema. 
-----------

-- source = (pumped_storage) and p_nom < 50 MW 
INSERT INTO model_draft.ego_grid_pf_hv_storage (
  scn_name, 
  storage_id,
  bus,
  dispatch,
  control,
  p_nom,
  p_nom_extendable,
  p_nom_min,
  p_min_pu_fixed,
  p_max_pu_fixed,
  sign,
  source
)
SELECT 
  'Status Quo',
  aggr_id,
  bus,
  max(dispatch),
  max(control),
  sum(p_nom),
  FALSE,
  min(p_nom_min),
  min(p_min_pu_fixed),
  max(p_max_pu_fixed),
  max(sign),
  source
FROM model_draft.ego_supply_pf_storage_single a
WHERE scn_name = 'Status Quo' AND a.p_nom < 50 AND a.aggr_id IS NOT NULL AND source IN 
	(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'pumped_storage')
	
GROUP BY a.aggr_id, a.bus, a.source;

-- source = (pumped_storage) and p_nom >= 50MW

INSERT INTO model_draft.ego_grid_pf_hv_storage (
  scn_name, 
  storage_id,
  bus,
  dispatch,
  control,
  p_nom,
  p_nom_extendable,
  p_nom_min,
  p_min_pu_fixed,
  p_max_pu_fixed,
  sign,
  source
)
SELECT 
  'Status Quo',
  aggr_id,
  bus,
  max(dispatch),
  max(control),
  sum(p_nom),
  FALSE,
  min(p_nom_min),
  min(p_min_pu_fixed),
  max(p_max_pu_fixed),
  max(sign),
  source
FROM model_draft.ego_supply_pf_storage_single a
WHERE scn_name = 'Status Quo' AND a.p_nom > 50 AND a.aggr_id IS NOT NULL AND source IN 
	(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'pumped_storage')
	
GROUP BY a.aggr_id, a.bus, a.source;