/*
Assignment of storage units to the relevant substation in the grid model. 

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu", "lukasol" 
*/

--------------	
-- Insert storage data into powerflow schema, that contains all storage units seperately 
--------------


DROP TABLE IF EXISTS model_draft.ego_supply_pf_storage_single;

CREATE TABLE model_draft.ego_supply_pf_storage_single
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  storage_id bigint NOT NULL, -- Unit: n/a...
  bus bigint, -- Unit: n/a...
  dispatch text DEFAULT 'flexible'::text, -- Unit: n/a...
  control text DEFAULT 'PQ'::text, -- Unit: n/a...
  p_nom double precision DEFAULT 0, -- Unit: MW...
  p_nom_extendable boolean DEFAULT false, -- Unit: n/a...
  p_nom_min double precision DEFAULT 0, -- Unit: MW...
  p_nom_max double precision, -- Unit: MW...
  p_min_pu_fixed double precision DEFAULT 0, -- Unit: per unit...
  p_max_pu_fixed double precision DEFAULT 1, -- Unit: per unit...
  sign double precision DEFAULT 1, -- Unit: n/a...
  source bigint, -- Unit: n/a...
  marginal_cost double precision, -- Unit: currency/MWh...
  capital_cost double precision, -- Unit: currency/MW...
  efficiency double precision, -- Unit: per unit...
  soc_initial double precision, -- Unit: MWh...
  soc_cyclic boolean DEFAULT false, -- Unit: n/a...
  max_hours double precision, -- Unit: hours...
  efficiency_store double precision, -- Unit: per unit...
  efficiency_dispatch double precision, -- Unit: per unit...
  standing_loss double precision,
  aggr_id integer, -- Unit: per unit...
 CONSTRAINT storage_data_pkey PRIMARY KEY (storage_id, scn_name),
  CONSTRAINT storage_data_source_fkey FOREIGN KEY (source)
      REFERENCES model_draft.ego_grid_pf_hv_source (source_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE model_draft.ego_supply_pf_storage_single
  OWNER TO oeuser;


COMMENT ON TABLE  model_draft.ego_supply_pf_storage_single IS
'{
"Name": "Individual storage units in eGo dataprocessing",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["storage units considered in eGo data processing"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "storage_id",
                    "Description": "unique id",
                    "Unit": "" },
                   {"Name": "bus",
                    "Description": "id of associated bus",
                    "Unit": "" },
                   {"Name": "dispatch",
                    "Description": "Controllability of active power dispatch, must be “flexible” or “variable”",
                    "Unit": "" },
                   {"Name": "control",
                    "Description": "P,Q,V control strategy for PF, must be “PQ”, “PV” or “Slack”",
                    "Unit": "" },
                   {"Name": "p_nom",
                    "Description": "Nominal power",
                    "Unit": "MW" },
                   {"Name": "p_nom_extendable",
                    "Description": "Switch to allow capacity p_nom to be extended",
                    "Unit": "" },
                   {"Name": "p_nom_min",
                    "Description": "If p_nom is extendable in OPF, set its minimum value",
                    "Unit": "MW" },
                   {"Name": "p_nom_max",
                    "Description": "If p_nom is extendable in OPF, set its maximum value (e.g. limited by potential))",
                    "Unit": "MW" },
                   {"Name": "p_min_pu_fixed",
                    "Description": "If control=”flexible” this gives the minimum output per unit of p_nom for the OPF.",
                    "Unit": "per unit" },
                   {"Name": "p_max_pu_fixed",
                    "Description": "If control=”flexible” this gives the maximum output per unit of p_nom for the OPF, equivalent to a de-rating factor",
                    "Unit": "per unit" },
                   {"Name": "sign",
                    "Description": "power sign",
                    "Unit": "" },
                   {"Name": "source",
                    "Description": "Prime mover energy carrier",
                    "Unit": "" },
                   {"Name": "marginal_cost",
                    "Description": "Marginal cost of production of 1 MWh",
                    "Unit": "€/MWh" },
                   {"Name": "capital_cost",
                    "Description": "Capital cost of extending p_nom by 1 MW",
                    "Unit": "€/MW" },
                   {"Name": "efficiency",
                    "Description": "Ratio between primary energy and electrical energy",
                    "Unit": "per unit" },
                   {"Name": "soc_initial",
                    "Description": "State of charge before the snapshots in the OPF.",
                    "Unit": "MWh" },
                   {"Name": "soc_cyclic",
                    "Description": "Switch: if True, then state_of_charge_initial is ignored and the initial state of charge is set to the final state of charge for the group of snapshots in the OPF",
                    "Unit": "" },
                   {"Name": "max_hours",
                    "Description": "Maximum state of charge capacity in terms of hours at full output capacity p_nom",
                    "Unit": "hours" },
                   {"Name": "efficiency_store",
                    "Description": "Efficiency of storage on the way into the storage",
                    "Unit": "per unit" },                   
                   {"Name": "efficiency_dispatch",
                    "Description": "Efficiency of storage on the way out of the storage",
                    "Unit": "per unit" },
                   {"Name": "standing_loss",
                    "Description": "Losses per hour to state of charge",
                    "Unit": "per unit" }, 
		   {"Name": "aggr_id",
                    "Description": "Aggregate ID for further processing",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "15.12.2016",
                    "Comment": "Created table and completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-----------
-- Status Quo
-----------

DELETE FROM model_draft.ego_supply_pf_storage_single WHERE scn_name = 'Status Quo';
	 
INSERT INTO model_draft.ego_supply_pf_storage_single (scn_name, storage_id)
	SELECT 'Status Quo', un_id
	FROM model_draft.ego_supply_generator
	WHERE conv_id IN 
		(SELECT a.gid 
		  FROM model_draft.ego_supply_conv_powerplant_sq_mview a
		  WHERE a.fuel= 'pumped_storage'
		); -- only (pumped) storage units are selected and written into pf_storage_single 

-- For pumped storage (this section needs to be extended as soon as other storage technologies are included) 

UPDATE model_draft.ego_supply_pf_storage_single a
	SET bus = b.otg_id, 
		p_nom = b.capacity, 
		control = 'PV',  -- For pumped storage units control is set to PV
		source = result.source
		FROM 
			(SELECT c.source_id as source, d.fuel as fuel
			FROM 	model_draft.ego_grid_pf_hv_source c, 
				model_draft.ego_supply_conv_powerplant_sq_mview d 
			WHERE	d.fuel = c.name) 
			AS 	result,		
			model_draft.ego_supply_conv_powerplant_sq_mview b
WHERE a.storage_id = b.un_id and result.fuel = 'pumped_storage' AND result.fuel = b.fuel;

DELETE FROM model_draft.ego_supply_pf_storage_single WHERE p_nom IS NULL; -- Delete those PS units without an entry on the installed capacity


-----------
-- Create aggregate IDs in pf_storage_single
-----------
-- Create sequence for aggregate ID

DROP SEQUENCE IF EXISTS model_draft.ego_supply_pf_storage_single_aggr_id;
CREATE SEQUENCE model_draft.ego_supply_pf_storage_single_aggr_id
  INCREMENT 1;
ALTER TABLE model_draft.ego_supply_pf_storage_single_aggr_id
  OWNER TO oeuser;

-- source= pumped_storage and p_nom < 50 MW 
	
UPDATE model_draft.ego_supply_pf_storage_single a
	SET aggr_id = result.aggr_id
		FROM 
			(SELECT b.bus, b.source, nextval('model_draft.ego_supply_pf_storage_single_aggr_id') as aggr_id
			FROM model_draft.ego_supply_pf_storage_single b 
			WHERE p_nom < 50 AND source IN 
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
  source,
  0, -- marginal_cost 
  0, -- capital_cost 0 since PHP are not extendable 
  1, --  efficiency is set below 
  0, -- soc_initial 
  false, -- soc_cyclic 
  6, -- max_hours as an average for existing German PHP 
  0.88, -- efficiency_store according to Acatech2015 
  0.89, -- efficiency_dispatch according to Acatech2015 
  0.00052 -- standing_loss according to Acatech2015 
FROM model_draft.ego_supply_pf_storage_single a
WHERE scn_name = 'Status Quo' AND a.p_nom < 50 AND a.aggr_id IS NOT NULL AND source IN 
	(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'pumped_storage')
GROUP BY a.aggr_id, a.bus, a.source;

-- source = (pumped_storage) and p_nom > 50 MW

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
  aggr_id,
  bus,
  dispatch,
  control,
  p_nom,
  p_nom_extendable,
  p_nom_min,
  p_min_pu_fixed,
  p_max_pu_fixed,
  sign,
  source,
  0, -- marginal_cost 
  0, -- capital_cost 0 since PHP are not extendable 
  1, --  efficiency is set below 
  0, -- soc_initial 
  false, -- soc_cyclic 
  6, -- max_hours as an average for existing German PHP 
  0.88, -- efficiency_store according to Acatech2015 
  0.89, -- efficiency_dispatch according to Acatech2015 
  0.00052 -- standing_loss according to Acatech2015 
FROM model_draft.ego_supply_pf_storage_single a
WHERE scn_name = 'Status Quo' AND a.p_nom >= 50 AND a.aggr_id IS NOT NULL AND source IN 
(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'pumped_storage');

-----------
-- NEP 2035
-----------

DELETE FROM model_draft.ego_supply_pf_storage_single WHERE scn_name='NEP 2035'; 

INSERT INTO model_draft.ego_supply_pf_storage_single (scn_name, storage_id)
	SELECT 'NEP 2035', un_id
	FROM model_draft.ego_supply_generator_nep2035
	WHERE conv_id IN 
		(SELECT a.gid 
		  FROM model_draft.ego_supply_conv_powerplant_nep2035_mview a
		  WHERE a.fuel= 'pumped_storage'
		); -- only (pumped) storage units from NEP 2035 scenario are selected and written into pf_storage_single 

-- For pumped storage (this section needs to be extended as soon as other storage technologies are included) 

UPDATE model_draft.ego_supply_pf_storage_single a
	SET bus = b.otg_id, 
		p_nom = b.capacity, 
		control = 'PV',  -- For pumped storage units control is set to PV
		source = result.source
		FROM 
			(SELECT c.source_id as source, d.fuel as fuel
			FROM 	model_draft.ego_grid_pf_hv_source c, 
				model_draft.ego_supply_conv_powerplant_nep2035_mview d 
			WHERE	d.fuel = c.name) 
			AS 	result,		
			model_draft.ego_supply_conv_powerplant_nep2035_mview b
WHERE a.storage_id = b.un_id and result.fuel = 'pumped_storage' AND result.fuel = b.fuel;

DELETE FROM model_draft.ego_supply_pf_storage_single WHERE p_nom IS NULL; -- Delete those PS units without an entry on the installed capacity

-- source= pumped_storage and p_nom < 50 MW 
	
UPDATE model_draft.ego_supply_pf_storage_single a
	SET aggr_id = result.aggr_id
		FROM 
			(SELECT b.bus, b.source, nextval('model_draft.ego_supply_pf_storage_single_aggr_id') as aggr_id
			FROM model_draft.ego_supply_pf_storage_single b 
			WHERE p_nom < 50 AND source IN 
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
  source,
  0, -- marginal_cost 
  0, -- capital_cost 0 since PHP are not extendable 
  1, --  efficiency is set below 
  0, -- soc_initial 
  false, -- soc_cyclic 
  6, -- max_hours as an average for existing German PHP 
  0.88, -- efficiency_store according to Acatech2015 
  0.89, -- efficiency_dispatch according to Acatech2015 
  0.00052 -- standing_loss according to Acatech2015 
FROM model_draft.ego_supply_pf_storage_single a
WHERE scn_name = 'NEP 2035' AND a.p_nom < 50 AND a.aggr_id IS NOT NULL AND source IN 
	(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'pumped_storage')
GROUP BY a.aggr_id, a.bus, a.source;

-- source = (pumped_storage) and p_nom > 50 MW

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
  aggr_id,
  bus,
  dispatch,
  control,
  p_nom,
  p_nom_extendable,
  p_nom_min,
  p_min_pu_fixed,
  p_max_pu_fixed,
  sign,
  source,
  0, -- marginal_cost 
  0, -- capital_cost 0 since PHP are not extendable 
  1, --  efficiency is set below 
  0, -- soc_initial 
  false, -- soc_cyclic 
  6, -- max_hours as an average for existing German PHP 
  0.88, -- efficiency_store according to Acatech2015 
  0.89, -- efficiency_dispatch according to Acatech2015 
  0.00052 -- standing_loss according to Acatech2015 
FROM model_draft.ego_supply_pf_storage_single a
WHERE scn_name = 'NEP 2035' AND a.p_nom >= 50 AND a.aggr_id IS NOT NULL AND source IN 
(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'pumped_storage');

-----------
-- eGo 100
-----------

DELETE FROM model_draft.ego_supply_pf_storage_single WHERE scn_name='eGo 100'; 

INSERT INTO model_draft.ego_supply_pf_storage_single (scn_name, storage_id)
	SELECT 'eGo 100', un_id
	FROM model_draft.ego_supply_generator_ego100
	WHERE res_id IN 
		(SELECT a.gid 
		  FROM model_draft.ego_supply_res_powerplant_ego100_mview a
		  WHERE a.fuel= 'pumped_storage'
		); -- only (pumped) storage units from eGo 100 scenario are selected and written into pf_storage_single 

-- For pumped storage (this section needs to be extended as soon as other storage technologies are included) 

UPDATE model_draft.ego_supply_pf_storage_single a
	SET bus = b.otg_id, 
		p_nom = b.capacity, 
		control = 'PV',  -- For pumped storage units control is set to PV
		source = result.source
		FROM 
			(SELECT c.source_id as source, d.fuel as fuel
			FROM 	model_draft.ego_grid_pf_hv_source c, 
				model_draft.ego_supply_res_powerplant_ego100_mview d 
			WHERE	d.generation_type = c.name) 
			AS 	result,		
			model_draft.ego_supply_res_powerplant_ego100_mview b
WHERE a.scn_name = 'ego100' AND a.storage_id = b.un_id AND result.generation_type = 'pumped_storage' AND result.generation_type = b.generation_type;

DELETE FROM model_draft.ego_supply_pf_storage_single WHERE p_nom IS NULL; -- Delete those PS units without an entry on the installed capacity

-- source= pumped_storage and p_nom < 50 MW 
	
UPDATE model_draft.ego_supply_pf_storage_single a
	SET aggr_id = result.aggr_id
		FROM 
			(SELECT b.bus, b.source, nextval('model_draft.ego_supply_pf_storage_single_aggr_id') as aggr_id
			FROM model_draft.ego_supply_pf_storage_single b 
			WHERE p_nom < 50 AND source IN 
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
  source,
  0, -- marginal_cost 
  0, -- capital_cost 0 since PHP are not extendable 
  1, --  efficiency is set below 
  0, -- soc_initial 
  false, -- soc_cyclic 
  6, -- max_hours as an average for existing German PHP 
  0.88, -- efficiency_store according to Acatech2015 
  0.89, -- efficiency_dispatch according to Acatech2015 
  0.00052 -- standing_loss according to Acatech2015 
FROM model_draft.ego_supply_pf_storage_single a
WHERE scn_name = 'eGo 100' AND a.p_nom < 50 AND a.aggr_id IS NOT NULL AND source IN 
	(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'pumped_storage')
GROUP BY a.aggr_id, a.bus, a.source;

-- source = (pumped_storage) and p_nom > 50 MW

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
  aggr_id,
  bus,
  dispatch,
  control,
  p_nom,
  p_nom_extendable,
  p_nom_min,
  p_min_pu_fixed,
  p_max_pu_fixed,
  sign,
  source,
  0, -- marginal_cost 
  0, -- capital_cost 0 since PHP are not extendable 
  1, --  efficiency is set below 
  0, -- soc_initial 
  false, -- soc_cyclic 
  6, -- max_hours as an average for existing German PHP 
  0.88, -- efficiency_store according to Acatech2015 
  0.89, -- efficiency_dispatch according to Acatech2015 
  0.00052 -- standing_loss according to Acatech2015 
FROM model_draft.ego_supply_pf_storage_single a
WHERE scn_name = 'eGo 100' AND a.p_nom >= 50 AND a.aggr_id IS NOT NULL AND source IN 
(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'pumped_storage');

------------------ NEIGHBOURING COUNTRIES
DELETE FROM model_draft.ego_grid_pf_hv_storage WHERE storage_id > 200000 AND scn_name = 'Status Quo';
DELETE FROM model_draft.ego_grid_pf_hv_storage WHERE storage_id > 200000 AND scn_name = 'NEP 2035';
DELETE FROM model_draft.ego_grid_pf_hv_storage WHERE storage_id > 200000 AND scn_name = 'eGo 100';

-- INSERT params of Storages in model_draft.ego_grid_pf_hv_storage (countries besides Germany)
-- starting storage_id at 200000

-- Status Quo

INSERT into model_draft.ego_grid_pf_hv_storage (
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
  'Status Quo' as scn_name,
  row_number() over () + 200000 as storage_id,
  B.bus_id as bus,
  'flexible' AS dispatch,
  'PV' AS control,
  nominal_value[1] AS p_nom,
  FALSE as p_nom_extendable,
  0 as p_nom_min,
  -1 as p_min_pu_fixed,
  1 as p_max_pu_fixed,
  1 as sign,
  11 as source,
  0 as marginal_cost,
  0 as capital_cost,
  1 as efficiency,
  0 as soc_inital,
  false as soc_cyclic,
  6 as max_hours,
  A.inflow_conversion_factor[1] as efficiency_store,
  A.outflow_conversion_factor[1] as efficiency_dispatch,
  A.capacity_loss[1] as standing_loss

		FROM calc_renpass_gis.renpass_gis_storage A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where id <= 27
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON (substring(A.source, 1, 2) = B.cntr_id)
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.nominal_value IS not NULL
	AND A.nominal_value[1] > 0.001
	AND A.source not LIKE '%%powerline%%'
	AND A.scenario_id = 43
	AND A.nominal_capacity IS not NULL;


-- NEP 2035

INSERT into model_draft.ego_grid_pf_hv_storage (
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
  'NEP 2035' as scn_name,
  row_number() over () + 200000 as storage_id,
  B.bus_id as bus,
  'flexible' AS dispatch,
  'PV' AS control,
  nominal_value[1] AS p_nom,
  FALSE as p_nom_extendable,
  0 as p_nom_min,
  -1 as p_min_pu_fixed,
  1 as p_max_pu_fixed,
  1 as sign,
  11 as source,
  0 as marginal_cost,
  0 as capital_cost,
  1 as efficiency,
  0 as soc_inital,
  false as soc_cyclic,
  6 as max_hours,
  A.inflow_conversion_factor[1] as efficiency_store,
  A.outflow_conversion_factor[1] as efficiency_dispatch,
  A.capacity_loss[1] as standing_loss

		FROM calc_renpass_gis.renpass_gis_storage A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where id <= 27
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON (substring(A.source, 1, 2) = B.cntr_id)
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.nominal_value IS not NULL
	AND A.nominal_value[1] > 0.001
	AND A.source not LIKE '%%powerline%%'
	AND A.scenario_id = 41
	AND A.nominal_capacity IS not NULL;

-- eGo 100

INSERT into model_draft.ego_grid_pf_hv_storage (
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
  'eGo 100' as scn_name,
  row_number() over () + 200000 as storage_id,
  B.bus_id as bus,
  'flexible' AS dispatch,
  'PV' AS control,
  nominal_value[1] AS p_nom,
  FALSE as p_nom_extendable,
  0 as p_nom_min,
  -1 as p_min_pu_fixed,
  1 as p_max_pu_fixed,
  1 as sign,
  11 as source,
  0 as marginal_cost,
  0 as capital_cost,
  1 as efficiency,
  0 as soc_inital,
  false as soc_cyclic,
  6 as max_hours,
  A.inflow_conversion_factor[1] as efficiency_store,
  A.outflow_conversion_factor[1] as efficiency_dispatch,
  A.capacity_loss[1] as standing_loss

		FROM calc_renpass_gis.renpass_gis_storage A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where id <= 27
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON (substring(A.source, 1, 2) = B.cntr_id)
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.nominal_value IS not NULL
	AND A.nominal_value[1] > 0.001
	AND A.source not LIKE '%%powerline%%'
	AND A.scenario_id = 40
	AND A.nominal_capacity IS not NULL;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_storage','ego_dp_powerflow_assignment_storage.sql',' ');


