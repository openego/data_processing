/*
Information on generators which are assigned to a specific substation are transformed to a data structure which is suitable for PyPSA. This script creates the scenarios
'Status Quo', 'NEP 2035' and 'eGo 100' in the hv powerflow schema. 

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu, Ludee" 
*/


-- Insert generator data into powerflow schema, that contains all generators separately 
DROP TABLE IF EXISTS 	model_draft.ego_supply_pf_generator_single CASCADE;
CREATE TABLE 		model_draft.ego_supply_pf_generator_single (
	scn_name	character varying DEFAULT 'Status Quo'::character varying,
	generator_id 	bigint NOT NULL,
	bus 		bigint,
	dispatch 	text DEFAULT 'flexible'::text,
	control 	text DEFAULT 'PQ'::text,
	p_nom 		double precision DEFAULT 0,
	p_nom_extendable boolean DEFAULT false,
	p_nom_min 	double precision DEFAULT 0,
	p_nom_max 	double precision,
	p_min_pu_fixed 	double precision DEFAULT 0,
	p_max_pu_fixed 	double precision DEFAULT 1,
	sign 		double precision DEFAULT 1,
	source 		bigint,
	marginal_cost 	double precision,
	capital_cost 	double precision,
	efficiency 	double precision,
	w_id 		bigint,
	aggr_id 	bigint,
	CONSTRAINT generator_single_data_pkey PRIMARY KEY (scn_name, generator_id),
	CONSTRAINT generator_data_source_fk FOREIGN KEY (source)
		REFERENCES model_draft.ego_grid_pf_hv_source (source_id) MATCH SIMPLE
		ON UPDATE NO ACTION ON DELETE NO ACTION );

-- SQ 

-- DELETE FROM model_draft.ego_supply_pf_generator_single WHERE scn_name = 'Status Quo';

INSERT INTO model_draft.ego_supply_pf_generator_single (generator_id)
	SELECT 	un_id
	FROM 	model_draft.ego_supply_conv_powerplant_sq_mview
	WHERE 	a.fuel <> 'pumped_storage'; -- pumped storage units are ignored here and will be listed in storage table 

INSERT INTO model_draft.ego_supply_pf_generator_single (generator_id)
	SELECT 	un_id
	FROM 	model_draft.ego_supply_res_powerplant_sq_mview;

-- NEP 2035 

-- DELETE FROM model_draft.ego_supply_pf_generator_single WHERE scn_name = 'NEP 2035';

INSERT INTO model_draft.ego_supply_pf_generator_single (scn_name, generator_id)
	SELECT 	'NEP 2035', un_id
	FROM 	model_draft.ego_supply_conv_powerplant_nep2035_mview
	WHERE 	a.fuel <> 'pumped_storage'; -- pumped storage units are ignored here and will be listed in storage table 

INSERT INTO model_draft.ego_supply_pf_generator_single (scn_name, generator_id)
	SELECT 	'NEP 2035', un_id
	FROM 	model_draft.ego_supply_res_powerplant_nep2035_mview;

-- eGo 100 

-- DELETE FROM model_draft.ego_supply_pf_generator_single WHERE scn_name = 'eGo 100';

INSERT INTO model_draft.ego_supply_pf_generator_single (scn_name, generator_id)
	SELECT 	'eGo 100', un_id
	FROM 	model_draft.ego_supply_conv_powerplant_ego100_mview
	WHERE 	a.fuel <> 'pumped_storage'; -- pumped storage units are ignored here and will be listed in storage table 

INSERT INTO model_draft.ego_supply_pf_generator_single (scn_name, generator_id)
	SELECT 	'eGo 100', un_id
	FROM 	model_draft.ego_supply_res_powerplant_ego100_mview;


-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_pf_generator_single OWNER TO oeuser;

-- metadata
COMMENT ON TABLE  model_draft.ego_supply_pf_generator_single IS
'{
"Name": "Seperated generators for powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["ego_dp_powerflow_assignment_generator.sql"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "name of scenario",
                    "Unit": "" },
		   {"Name": "generator_id",
                    "Description": "unique id for generators",
                    "Unit": "" },                   
                   {"Name": "bus",
                    "Description": "id of associated bus",
                    "Unit": "" },
                   {"Name": "dispatch",
                    "Description": "Controllability of active power dispatch, must be flexible or variable",
                    "Unit": "" },
                   {"Name": "control",
                    "Description": "P,Q,V control strategy, must be PQ, PV or Slack",
                    "Unit": "" },
                   {"Name": "p_nom",
                    "Description": "Nominal power",
                    "Unit": "MW" },
                   {"Name": "p_nom_extendable",
                    "Description": "Switch to allow capacity p_nom to be extended",
                    "Unit": "" },
                   {"Name": "p_nom_min",
                    "Description": "If p_nom is extendable, set its minimum value",
                    "Unit": "" },
                   {"Name": "p_nom_max",
                    "Description": "If p_nom is extendable, set its maximum value (e.g. limited by potential)",
                    "Unit": "" },
                   {"Name": "p_min_pu_fixed",
                    "Description": "If control=flexible this gives the minimum output per unit of p_nom",
                    "Unit": "per unit" },
                   {"Name": "p_max_pu_fixed",
                    "Description": "If control=flexible this gives the maximum output per unit of p_nom, equivalent to a de-rating factor",
                    "Unit": "per unit" },
                   {"Name": "sign",
                    "Description": "power sign",
                    "Unit": "" },
                   {"Name": "source",
                    "Description": "prime mover energy carrier",
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
                   {"Name": "w_id",
                    "Description": "w_id",
                    "Unit": "" },                        
                   {"Name": "aggr_id",
                    "Description": "aggregate id",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }, 
	           {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "27.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["add licence, Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_supply_pf_generator_single' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_supply_pf_generator_single','ego_dp_powerflow_assignment_generator.sql',' ');




-- Insert generator data into powerflow schema, that contains all generators seperately 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_grid_pf_hv_source','ego_dp_powerflow_assignment_generator.sql',' ');


UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	bus = b.otg_id, 
		p_nom = b.capacity
		source = result.source
		FROM 	(SELECT c.source_id as source, d.fuel as fuel
				FROM 	model_draft.ego_grid_pf_hv_source c, 
					model_draft.ego_dp_supply_conv_powerplant d 
				WHERE	d.fuel = c.name) AS result,		
			model_draft.ego_dp_supply_conv_powerplant b
	WHERE 	a.generator_id = b.un_id; 



UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	bus = b.otg_id, 
		p_nom = b.capacity
		source = result.source
		FROM 	(SELECT c.source_id as source, d.fuel as fuel
				FROM 	model_draft.ego_grid_pf_hv_source c, 
					model_draft.ego_dp_supply_res_powerplant d 
				WHERE	d.fuel = c.name) AS result,		
			model_draft.ego_dp_supply_res_powerplant b
	WHERE 	a.generator_id = b.un_id; 



UPDATE model_draft.ego_supply_pf_generator_single a
	SET control= 
			(CASE 
			WHEN p_nom < 50 THEN 'PQ'
			WHEN p_nom > 50 AND source_id IN (12, 13) THEN 'PQ'-- Wind or solar pp
			WHEN p_nom > 50 AND source_id NOT IN (12, 13) THEN 'PV'
			END);   


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','renpassgis_economy_climatepoint_voronoi','ego_dp_powerflow_assignment_generator.sql',' ');


-- Identify climate point IDs for each renewables generator
UPDATE model_draft.ego_supply_pf_generator_single a
	SET w_id = b.id
		FROM 	(SELECT c.un_id, c.geom 
			FROM model_draft.ego_supply_res_powerplant_sq_view c) AS result,
			model_draft.renpassgis_economy_climatepoint_voronoi b 
		WHERE 	result.geom && b.geom
			AND ST_Intersects(result.geom, b.geom) 
			AND generator_id = result.un_id;


-- Create aggregate IDs in pf_generator_single

-- Create sequence for aggregate ID
DROP SEQUENCE IF EXISTS model_draft.ego_supply_pf_generator_single_aggr_id;
CREATE SEQUENCE 	model_draft.ego_supply_pf_generator_single_aggr_id INCREMENT 1;

-- grant (oeuser)
ALTER TABLE		model_draft.ego_supply_pf_generator_single_aggr_id OWNER TO oeuser;

-- SQ

-- source = (wind and solar) and p_nom < 50 MW
UPDATE model_draft.ego_supply_pf_generator_single a
	SET aggr_id = result.aggr_id
		FROM 	(SELECT	b.bus, 
				b.w_id, 
				b.source 
				nextval('model_draft.ego_supply_pf_generator_single_aggr_id') as aggr_id
			FROM 	model_draft.ego_supply_pf_generator_single b 
			WHERE 	scn_name='Status Quo' AND p_nom < 50 AND source IN 
				(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar') 
			GROUP BY bus, w_id, source) AS result
		WHERE 	a.bus = result.bus 
			AND a.w_id = result.w_id 
			AND a.source = result.source;

-- source <> (wind and solar) and p_nom < 50 MW 
UPDATE model_draft.ego_supply_pf_generator_single a
	SET aggr_id = result.aggr_id
		FROM  	(SELECT	b.bus, 
				b.source, 
				nextval('model_draft.ego_supply_pf_generator_single_aggr_id') as aggr_id
			FROM model_draft.ego_supply_pf_generator_single b 
			WHERE scn_name='Status Quo' AND p_nom < 50 AND source NOT IN 
				(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar')
			GROUP BY b.bus, b.source) AS result
		WHERE 	a.bus = result.bus 
			AND a.source = result.source;

-- all sources and p_nom >= 50MW
UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	aggr_id = nextval('model_draft.ego_supply_pf_generator_single_aggr_id')
	WHERE 	scn_name= 'Status Quo' AND a.p_nom >= 50;

-- NEP 2035 

-- source = (wind and solar) and p_nom < 50 MW
UPDATE model_draft.ego_supply_pf_generator_single a
	SET aggr_id = result.aggr_id
		FROM 	(SELECT	b.bus, 
				b.w_id, 
				b.source 
				nextval('model_draft.ego_supply_pf_generator_single_aggr_id') as aggr_id
			FROM 	model_draft.ego_supply_pf_generator_single b 
			WHERE 	scn_name='NEP 2035' AND p_nom < 50 AND source IN 
				(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar') 
			GROUP BY bus, w_id, source) AS result
		WHERE 	a.bus = result.bus 
			AND a.w_id = result.w_id 
			AND a.source = result.source;

-- source <> (wind and solar) and p_nom < 50 MW 
UPDATE model_draft.ego_supply_pf_generator_single a
	SET aggr_id = result.aggr_id
		FROM  	(SELECT	b.bus, 
				b.source, 
				nextval('model_draft.ego_supply_pf_generator_single_aggr_id') as aggr_id
			FROM model_draft.ego_supply_pf_generator_single b 
			WHERE scn_name='NEP 2035' AND p_nom < 50 AND source NOT IN 
				(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar')
			GROUP BY b.bus, b.source) AS result
		WHERE 	a.bus = result.bus 
			AND a.source = result.source;

-- all sources and p_nom >= 50MW
UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	aggr_id = nextval('model_draft.ego_supply_pf_generator_single_aggr_id')
	WHERE 	scn_name= 'NEP 2035' AND a.p_nom >= 50;



-- eGo 100

-- source = (wind and solar) and p_nom < 50 MW
UPDATE model_draft.ego_supply_pf_generator_single a
	SET aggr_id = result.aggr_id
		FROM 	(SELECT	b.bus, 
				b.w_id, 
				b.source 
				nextval('model_draft.ego_supply_pf_generator_single_aggr_id') as aggr_id
			FROM 	model_draft.ego_supply_pf_generator_single b 
			WHERE 	scn_name='eGo 100' AND p_nom < 50 AND source IN 
				(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar') 
			GROUP BY bus, w_id, source) AS result
		WHERE 	a.bus = result.bus 
			AND a.w_id = result.w_id 
			AND a.source = result.source;

-- source <> (wind and solar) and p_nom < 50 MW 
UPDATE model_draft.ego_supply_pf_generator_single a
	SET aggr_id = result.aggr_id
		FROM  	(SELECT	b.bus, 
				b.source, 
				nextval('model_draft.ego_supply_pf_generator_single_aggr_id') as aggr_id
			FROM model_draft.ego_supply_pf_generator_single b 
			WHERE scn_name='eGo 100' AND p_nom < 50 AND source NOT IN 
				(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar')
			GROUP BY b.bus, b.source) AS result
		WHERE 	a.bus = result.bus 
			AND a.source = result.source;

-- all sources and p_nom >= 50MW
UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	aggr_id = nextval('model_draft.ego_supply_pf_generator_single_aggr_id')
	WHERE 	scn_name= 'eGo 100' AND a.p_nom >= 50;

-- Delete all generators with p_nom=0

DELETE FROM model_draft.ego_supply_pf_generator_single WHERE p_nom IS NULL OR p_nom = 0; 

-- Accumulate data from pf_generator_single and insert into hv_powerflow schema. 

DELETE FROM model_draft.ego_grid_pf_hv_generator WHERE scn_name IN ('Status Quo', 'NEP 2035', 'eGo 100'); 

-- source = (wind and solar) and p_nom < 50 MW
INSERT INTO model_draft.ego_grid_pf_hv_generator (
		scn_name, 		
		generator_id,
		bus,
		dispatch,
		control,
		p_nom,
		p_nom_extendable,
		p_nom_min,
		p_min_pu_fixed,
		p_max_pu_fixed,
		sign,
		source )
	SELECT	scn_name
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
	FROM 	model_draft.ego_supply_pf_generator_single a
	WHERE 	a.p_nom < 50 
		AND a.aggr_id IS NOT NULL 
		AND source IN 
		(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar')
	GROUP BY a. scn_name, a.aggr_id, a.bus, a.w_id, a.source;

-- source <> (wind and solar) and p_nom < 50 MW 
INSERT INTO model_draft.ego_grid_pf_hv_generator (
		scn_name, 
		generator_id,
		bus,
		dispatch,
		control,
		p_nom,
		p_nom_extendable,
		p_nom_min,
		p_min_pu_fixed,
		p_max_pu_fixed,
		sign,
		source )
	SELECT  scn_name, 
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
	FROM 	model_draft.ego_supply_pf_generator_single a
	WHERE 	a.p_nom < 50 
		AND a.aggr_id IS NOT NULL 
		AND source NOT IN 
		(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar')
	GROUP BY a.scn_name, a.aggr_id, a.bus, a.source;

-- all sources and p_nom >= 50MW
INSERT INTO model_draft.ego_grid_pf_hv_generator (
		scn_name, 		
		generator_id,
		bus,
		dispatch,
		control,
		p_nom,
		p_nom_extendable,
		p_nom_min,
		p_min_pu_fixed,
		p_max_pu_fixed,
		sign,
		source )
	SELECT  scn_name, 
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
	FROM 	model_draft.ego_supply_pf_generator_single a
	WHERE 	a.p_nom >= 50 AND a.aggr_id IS NOT NULL;

/*
-- Add slack generators at buses that are located outside of Germany

-- create sequence for slack generators
DROP SEQUENCE IF EXISTS model_draft.ego_grid_pf_hv_slack_gen_seq; 
CREATE SEQUENCE 	model_draft.ego_grid_pf_hv_slack_gen_seq 
	INCREMENT 1 
	MINVALUE 100000 
	MAXVALUE 9223372036854775807 
	START 100000 
	CACHE 1; 

-- grant (oeuser)
ALTER TABLE model_draft.ego_grid_pf_hv_slack_gen_seq OWNER TO oeuser;

-- insert slack generators into poswerflow schema
INSERT INTO model_draft.ego_grid_pf_hv_generator 
		(generator_id, 
		bus, 
		dispatch, 
		control) 
	SELECT  nextval('model_draft.ego_grid_pf_hv_slack_gen_seq'), 
		bus_i, 
		'flexible', 
		'Slack' 
	FROM 	grid.otg_ehvhv_bus_data 
	WHERE 	cntr_id <> 'DE' 
		AND result_id = GREATEST(result_id) 
		AND bus_i IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus) 
		AND base_kv > 110;
*/
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_generator','ego_dp_powerflow_assignment_generator.sql',' ');
