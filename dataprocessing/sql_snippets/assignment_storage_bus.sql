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


-- DELETE FROM model_draft.ego_supply_pf_storage_single; 
	 
INSERT INTO model_draft.ego_supply_pf_storage_single (scn_name, storage_id)
	SELECT 'Status Quo', un_id
	FROM model_draft.ego_supply_generator
	WHERE conv_id IN 
		(SELECT a.gid 
		  FROM supply.ego_conv_powerplant a
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
				supply.ego_conv_powerplant d 
			WHERE	d.fuel = c.name) 
			AS 	result,		
			supply.ego_conv_powerplant b
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

DELETE FROM model_draft.ego_grid_pf_hv_storage WHERE scn_name = 'Status Quo'; 

-- source = (pumped_storage) and p_nom < 50 MW

INSERT INTO model_draft.ego_grid_pf_hv_storage (
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
WHERE a.p_nom < 50 AND a.aggr_id IS NOT NULL AND source IN 
	(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'pumped_storage')
	
GROUP BY a.aggr_id, a.bus, a.source;

-- source = (pumped_storage) and p_nom > 50 MW

INSERT INTO model_draft.ego_grid_pf_hv_storage (
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
  source
FROM model_draft.ego_supply_pf_storage_single a
WHERE a.p_nom >= 50 AND a.aggr_id IS NOT NULL AND source IN 
(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'pumped_storage');