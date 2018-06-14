/*
Equivalent to the assignment of generators in this script storages are converted and clustered for all three scenarios
considered in open_eGo. 

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu", "lukasoldi" 
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
  p_min_pu_fixed double precision DEFAULT -1, -- Unit: per unit...
  p_max_pu_fixed double precision DEFAULT 1, -- Unit: per unit...
  sign double precision DEFAULT 1, -- Unit: n/a...
  source bigint, -- Unit: n/a...
  marginal_cost double precision, -- Unit: currency/MWh...
  capital_cost double precision, -- Unit: currency/MW...
  efficiency double precision, -- Unit: per unit...
  soc_initial double precision, -- Unit: MWh...
  soc_cyclic boolean DEFAULT true, -- Unit: n/a...
  max_hours double precision, -- Unit: hours...
  efficiency_store double precision, -- Unit: per unit...
  efficiency_dispatch double precision, -- Unit: per unit...
  standing_loss double precision, -- Unit: per unit...
  aggr_id integer, 
  source_name character varying, 
 CONSTRAINT storage_single_pkey PRIMARY KEY (storage_id, scn_name),
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

------------------
-- SQ 
------------------

-- DELETE FROM model_draft.ego_supply_pf_storage_single WHERE scn_name = 'Status Quo';

INSERT INTO model_draft.ego_supply_pf_storage_single (scn_name, storage_id, bus, p_nom, source_name)
	SELECT 	'Status Quo', un_id, otg_id, capacity, fuel
	FROM 	model_draft.ego_supply_conv_powerplant_sq_mview a
	WHERE 	a.fuel = 'pumped_storage' AND a.un_id IS NOT NULL AND a.capacity IS NOT NULL; -- other storage technologies can be included here


------------------
-- NEP 2035
------------------

-- DELETE FROM model_draft.ego_supply_pf_storage_single WHERE scn_name = 'NEP 2035';

INSERT INTO model_draft.ego_supply_pf_storage_single (scn_name, storage_id, bus, p_nom, source_name)
	SELECT 	'NEP 2035', un_id, otg_id, capacity, fuel
	FROM 	model_draft.ego_supply_conv_powerplant_sq_mview a
	WHERE 	a.fuel = 'pumped_storage' AND a.un_id IS NOT NULL AND a.capacity IS NOT NULL; -- other storage technologies can be included here


------------------
-- eGo 100 
------------------

-- DELETE FROM model_draft.ego_supply_pf_storage_single WHERE scn_name = 'eGo 100';

INSERT INTO model_draft.ego_supply_pf_storage_single (scn_name, storage_id, bus, p_nom, source_name)
	SELECT 	'eGo 100', un_id, otg_id, capacity, fuel
	FROM 	model_draft.ego_supply_conv_powerplant_sq_mview a
	WHERE 	a.fuel = 'pumped_storage' AND a.un_id IS NOT NULL AND a.capacity IS NOT NULL; -- other storage technologies can be included here


-- Update tables for all scenarios

UPDATE model_draft.ego_supply_pf_storage_single a 
	SET source = b.source_id
	FROM model_draft.ego_grid_pf_hv_source b
	WHERE a.source_name = b.name; 
	
ALTER TABLE model_draft.ego_supply_pf_storage_single
	DROP COLUMN source_name; 


UPDATE model_draft.ego_supply_pf_storage_single a -- this query might be extended for other storage technologies
	SET control= 
			(CASE 
			WHEN source IN (SELECT source_id FROM model_draft.ego_grid_pf_hv_source WHERE name = 'pumped_storage')  THEN 'PV' 
			END);   


-----------
-- Create aggregate IDs in pf_storage_single
-----------
-- Create sequence for aggregate ID

DROP SEQUENCE IF EXISTS model_draft.ego_supply_pf_storage_single_aggr_id;
CREATE SEQUENCE model_draft.ego_supply_pf_storage_single_aggr_id
  INCREMENT 1;

-- grant (oeuser)
ALTER SEQUENCE model_draft.ego_supply_pf_storage_single_aggr_id
  OWNER TO oeuser;


-- Create aggr_id for all scenarios

-- all storage technologies and p_nom < 50 MW 
UPDATE model_draft.ego_supply_pf_storage_single a
	SET aggr_id = result.aggr_id
		FROM  	(SELECT	b.bus, 
				b.source, 
				b.scn_name,
				nextval('model_draft.ego_supply_pf_storage_single_aggr_id') as aggr_id
			FROM model_draft.ego_supply_pf_storage_single b 
			WHERE p_nom < 50
			GROUP BY b.bus, b.source, b.scn_name) AS result
		WHERE 	a.bus = result.bus 
			AND a.source = result.source
			AND a.scn_name = result.scn_name;

-- all sources and p_nom >= 50MW
UPDATE model_draft.ego_supply_pf_storage_single a
	SET 	aggr_id = nextval('model_draft.ego_supply_pf_storage_single_aggr_id')
	WHERE 	a.p_nom >= 50;


------------------------------------
-- Accumulate data from pf_storage_single and insert into hv_powerflow schema. 
------------------------------------

DELETE FROM model_draft.ego_grid_pf_hv_storage WHERE scn_name IN ('Status Quo', 'NEP 2035', 'eGo 100'); 


-- all storage technologies and p_nom < 50 MW

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
  scn_name,
  aggr_id,
  bus,
  max(dispatch),
  max(control),
  sum(p_nom),
  FALSE,
  min(p_nom_min),
  -1,
  max(p_max_pu_fixed),
  max(sign),
  source,
  0, -- marginal_cost 
  0, -- capital_cost 0 since PHP are not extendable 
  1, --  efficiency is set below 
  0, -- soc_initial 
  true, -- soc_cyclic 
  6, -- max_hours as an average for existing German PHP 
  0.88, -- efficiency_store according to Acatech2015 
  0.89, -- efficiency_dispatch according to Acatech2015 
  0.00052 -- standing_loss according to Acatech2015 
FROM model_draft.ego_supply_pf_storage_single a
WHERE a.p_nom < 50 AND a.aggr_id IS NOT NULL 
GROUP BY a.scn_name, a.aggr_id, a.bus, a.source;

-- all storage_technologies and p_nom > 50 MW

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
  scn_name,
  aggr_id,
  bus,
  dispatch,
  control,
  p_nom,
  p_nom_extendable,
  p_nom_min,
  -1,
  p_max_pu_fixed,
  sign,
  source,
  0, -- marginal_cost 
  0, -- capital_cost 0 since PHP are not extendable 
  1, --  efficiency is set below 
  0, -- soc_initial 
  true, -- soc_cyclic 
  6, -- max_hours as an average for existing German PHP 
  0.88, -- efficiency_store according to Acatech2015 
  0.89, -- efficiency_dispatch according to Acatech2015 
  0.00052 -- standing_loss according to Acatech2015 
FROM model_draft.ego_supply_pf_storage_single a
WHERE a.p_nom >= 50 AND a.aggr_id IS NOT NULL;


------------------ NEIGHBOURING COUNTRIES

-- INSERT params of Storages in model_draft.ego_grid_pf_hv_storage (countries besides Germany)
-- starting storage_id at 200000

-- Create a new sequence for storage_id of storages located in neighbouring countries

DROP SEQUENCE IF EXISTS model_draft.ego_grid_pf_hv_storage_neighbouring;
CREATE SEQUENCE model_draft.ego_grid_pf_hv_storage_neighbouring
  INCREMENT 1;
  
SELECT setval('model_draft.ego_grid_pf_hv_storage_neighbouring', (max(storage_id)+200000)) FROM model_draft.ego_grid_pf_hv_storage;

-- grant (oeuser)
ALTER SEQUENCE model_draft.ego_grid_pf_hv_storage_neighbouring
OWNER TO oeuser;

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
  nextval('model_draft.ego_grid_pf_hv_storage_neighbouring') as storage_id,
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
  true as soc_cyclic,
  6 as max_hours,
  0.88 as efficiency_store, -- efficiency_store according to Acatech2015 
  0.89 as efficiency_dispatch, -- efficiency_dispatch according to Acatech2015 
  0.00052 as standing_loss -- standing_loss according to Acatech2015

		FROM calc_renpass_gis.renpass_gis_storage A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where central_bus = True
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON (substring(A.source, 1, 2) = B.cntr_id)
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.nominal_value IS not NULL
	AND A.nominal_value[1] > 0.001
	AND A.source not LIKE '%%powerline%%'
	AND A.scenario_id = 43
Group by bus, p_nom;



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
  nextval('model_draft.ego_grid_pf_hv_storage_neighbouring') as storage_id,
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
  true as soc_cyclic,
  6 as max_hours,
  0.88 as efficiency_store, -- efficiency_store according to Acatech2015 
  0.89 as efficiency_dispatch, -- efficiency_dispatch according to Acatech2015 
  0.00052 as standing_loss -- standing_loss according to Acatech2015

		FROM calc_renpass_gis.renpass_gis_storage A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where central_bus = True
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON (substring(A.source, 1, 2) = B.cntr_id)
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.nominal_value IS not NULL
	AND A.nominal_value[1] > 0.001
	AND A.source not LIKE '%%powerline%%'
	AND A.scenario_id = 41
Group by bus, p_nom;

-- eGo 100

-- batteries

CREATE TABLE model_draft.ego_grid_pf_hv_storage_batteries_temp AS
SELECT
 sub. scenario_id ,
 sub.source ,
 sum( sub.p_nom) as p_nom,
 sub.cntr_id
FROM 
(
SELECT
  scenario_id ,
  'battery'::text as source ,
  nominal_value[1] AS p_nom,
  substring(source, 1, 2)::text as  cntr_id
FROM
  calc_renpass_gis.renpass_gis_storage
WHERE substring(source, 1, 2) <> 'DE'
AND (substring(target,12,22) = 'lithium_ion'
Or substring(target,12,21) = 'redox_flow')
AND nominal_value IS not NULL
AND nominal_value[1] > 0.001
AND source not LIKE '%%powerline%%'
AND scenario_id = 40
Group by scenario_id, source,nominal_value
UNION
SELECT
  scenario_id ,
  'battery'::text as source ,
  nominal_value[1] AS p_nom,
  'AT' as  cntr_id
FROM
  calc_renpass_gis.renpass_gis_storage
WHERE substring(target, 1, 2) = 'AT'
AND (substring(target,12,22) = 'lithium_ion'
Or substring(target,12,21) = 'redox_flow')
AND nominal_value IS not NULL
AND nominal_value[1] > 0.001
AND source not LIKE '%%powerline%%'
AND scenario_id = 40
Group by scenario_id, source,nominal_value
UNION
SELECT
  scenario_id ,
  'battery'::text as source ,
  nominal_value[1] AS p_nom,
  'LU' as  cntr_id
FROM
  calc_renpass_gis.renpass_gis_storage
WHERE substring(target, 1, 2) = 'LU'
AND (substring(target,12,22) = 'lithium_ion'
Or substring(target,12,21) = 'redox_flow')
AND nominal_value IS not NULL
AND nominal_value[1] > 0.001
AND source not LIKE '%%powerline%%'
AND scenario_id = 40
Group by scenario_id, source,nominal_value
) as sub
Group by sub.scenario_id, sub.source,sub.cntr_id;

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
  nextval('model_draft.ego_grid_pf_hv_storage_neighbouring') as storage_id,
  B.bus_id as bus,
  'flexible' AS dispatch,
  'PV' AS control,
  A.p_nom,
  FALSE as p_nom_extendable,
  0 as p_nom_min,
  -1 as p_min_pu_fixed,
  1 as p_max_pu_fixed,
  1 as sign,
  19 as source,
  0 as marginal_cost,
  0 as capital_cost,
  1 as efficiency,
  0 as soc_inital,
  true as soc_cyclic,
  6 as max_hours,
  0.9487 as efficiency_store, -- efficiency_store according to Acatech2015 
  0.9487 as efficiency_dispatch, -- efficiency_dispatch according to Acatech2015 
  0.00417 as standing_loss -- standing_loss according to Acatech2015

		FROM  model_draft.ego_grid_pf_hv_storage_batteries_temp A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where central_bus = True
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON A.cntr_id = B.cntr_id
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.p_nom > 0.001
Group by bus, p_nom;

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_storage_batteries_temp; 
  
-- hydrogen

CREATE TABLE model_draft.ego_grid_pf_hv_storage_hydrogen_temp AS
SELECT
 sub. scenario_id ,
 sub.source ,
 sum( sub.p_nom) as p_nom,
 sub.cntr_id
FROM 
(
SELECT
  scenario_id ,
  'hydrogen'::text as source ,
  nominal_value[1] AS p_nom,
  substring(source, 1, 2)::text as  cntr_id
FROM
  calc_renpass_gis.renpass_gis_storage
WHERE substring(source, 1, 2) <> 'DE'
AND substring(target,12,19) = 'hydrogen'
AND nominal_value IS not NULL
AND nominal_value[1] > 0.001
AND source not LIKE '%%powerline%%'
AND scenario_id = 40
Group by scenario_id, source,nominal_value
UNION
SELECT
  scenario_id ,
  'hydrogen'::text as source ,
  nominal_value[1] AS p_nom,
  'AT' as  cntr_id
FROM
  calc_renpass_gis.renpass_gis_storage
WHERE substring(target, 1, 2) = 'AT'
AND substring(target,12,19) = 'hydrogen'
AND nominal_value IS not NULL
AND nominal_value[1] > 0.001
AND source not LIKE '%%powerline%%'
AND scenario_id = 40
Group by scenario_id, source,nominal_value
UNION
SELECT
  scenario_id ,
  'hydrogen'::text as source ,
  nominal_value[1] AS p_nom,
  'LU' as  cntr_id
FROM
  calc_renpass_gis.renpass_gis_storage
WHERE substring(target, 1, 2) = 'LU'
AND substring(target,12,19) = 'hydrogen'
AND nominal_value IS not NULL
AND nominal_value[1] > 0.001
AND source not LIKE '%%powerline%%'
AND scenario_id = 40
Group by scenario_id, source,nominal_value
) as sub
Group by sub.scenario_id, sub.source,sub.cntr_id;


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
  nextval('model_draft.ego_grid_pf_hv_storage_neighbouring') as storage_id,  
  B.bus_id as bus,
  'flexible' AS dispatch,
  'PV' AS control,
  A.p_nom,
  FALSE as p_nom_extendable,
  0 as p_nom_min,
  -1 as p_min_pu_fixed,
  1 as p_max_pu_fixed,
  1 as sign,
  18 as source,
  0 as marginal_cost,
  0 as capital_cost,
  1 as efficiency,
  0 as soc_inital,
  true as soc_cyclic,
  168 as max_hours,
  0.785, -- efficiency according to Acatech2015
  0.57, -- efficiency according to Acatech2015
  0.000694 -- standing losses according to Acatech2015

		FROM  model_draft.ego_grid_pf_hv_storage_hydrogen_temp A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where central_bus = True
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON A.cntr_id = B.cntr_id
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.p_nom > 0.001
Group by bus, p_nom;

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_storage_hydrogen_temp; 

-- pumped_hydro


CREATE TABLE model_draft.ego_grid_pf_hv_storage_pumped_temp AS
SELECT
 sub. scenario_id ,
 sub.source ,
 sum( sub.p_nom) as p_nom,
 sub.cntr_id
FROM 
(
SELECT
  scenario_id ,
  'pumped'::text as source ,
  nominal_value[1] AS p_nom,
  substring(source, 1, 2)::text as  cntr_id
FROM
  calc_renpass_gis.renpass_gis_storage
WHERE substring(source, 1, 2) <> 'DE'
AND (substring(target,12,23) = 'pumped_hydro'
Or substring(target,12,17) = 'a_caes')
AND nominal_value IS not NULL
AND nominal_value[1] > 0.001
AND source not LIKE '%%powerline%%'
AND scenario_id = 40
Group by scenario_id, source,nominal_value
UNION
SELECT
  scenario_id ,
  'pumped'::text as source ,
  nominal_value[1] AS p_nom,
  'AT' as  cntr_id
FROM
  calc_renpass_gis.renpass_gis_storage
WHERE substring(target, 1, 2) = 'AT'
AND (substring(target,12,23) = 'pumped_hydro'
Or substring(target,12,17) = 'a_caes')
AND nominal_value IS not NULL
AND nominal_value[1] > 0.001
AND source not LIKE '%%powerline%%'
AND scenario_id = 40
Group by scenario_id, source,nominal_value
UNION
SELECT
  scenario_id ,
  'pumped'::text as source ,
  nominal_value[1] AS p_nom,
  'LU' as  cntr_id
FROM
  calc_renpass_gis.renpass_gis_storage
WHERE substring(target, 1, 2) = 'LU'
AND (substring(target,12,23) = 'pumped_hydro'
Or substring(target,12,17) = 'a_caes')
AND nominal_value IS not NULL
AND nominal_value[1] > 0.001
AND source not LIKE '%%powerline%%'
AND scenario_id = 40
Group by scenario_id, source,nominal_value
) as sub
Group by sub.scenario_id, sub.source,sub.cntr_id;

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
  nextval('model_draft.ego_grid_pf_hv_storage_neighbouring') as storage_id,
  B.bus_id as bus,
  'flexible' AS dispatch,
  'PV' AS control,
  A.p_nom AS p_nom,
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
  true as soc_cyclic,
  6 as max_hours,
  0.88 as efficiency_store, -- efficiency_store according to Acatech2015 
  0.89 as efficiency_dispatch, -- efficiency_dispatch according to Acatech2015 
  0.00052 as standing_loss -- standing_loss according to Acatech2015

		FROM model_draft.ego_grid_pf_hv_storage_pumped_temp A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where central_bus = True
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON A.cntr_id = B.cntr_id)
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.p_nom > 0.001
	Group by bus, p_nom;

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_storage_pumped_temp;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.1','output','model_draft','ego_grid_pf_hv_storage','ego_dp_powerflow_assignment_storage.sql',' ');
