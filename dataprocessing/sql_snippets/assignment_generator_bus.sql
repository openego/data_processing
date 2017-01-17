/*
generator to bus

__copyright__ = "tba" 
__license__ = "tba" 
__author__ = "" 
*/

-- contains all generators (RE and conventional) but no duplicates
DROP TABLE IF EXISTS 	model_draft.ego_supply_generator CASCADE;
CREATE TABLE 		model_draft.ego_supply_generator (
	un_id 		serial NOT NULL, 
	re_id 		integer, 
	conv_id 	integer,
	aggr_id_pf 	integer, 
	aggr_id_ms 	integer, 
	geom 		geometry(Point,4326),
	CONSTRAINT ego_supply_generator_pkey PRIMARY KEY (un_id) );

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_generator OWNER TO oeuser;

-- Das wird nicht benötigt
-- DELETE FROM model_draft.ego_supply_generator; 
-- DROP INDEX IF EXISTS model_draft.ego_supply_generator_idx;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','supply','ego_res_powerplant','assignment_generator_bus.sql',' ');
SELECT ego_scenario_log('v0.2.5','input','supply','ego_conv_powerplant','assignment_generator_bus.sql',' ');

INSERT INTO model_draft.ego_supply_generator (re_id, geom) 
	SELECT 	id, geom
	FROM 	supply.ego_res_powerplant
	WHERE geom IS NOT NULL;

INSERT INTO model_draft.ego_supply_generator (conv_id, geom) 
	SELECT 	gid, geom
	FROM 	supply.ego_conv_powerplant
	WHERE eeg NOT LIKE 'yes'; -- Duplicates that already occur in the eeg-list are ignored 

-- index GIST (geom)
CREATE INDEX 	ego_supply_generator_idx
	ON 	model_draft.ego_supply_generator USING gist (geom);

-- metadata
COMMENT ON TABLE  model_draft.ego_supply_generator IS
'{
"Name": "eGo generators merged",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["assignment_generator_bus.sql"],
"Column": [
                   {"Name": "un_id",
                    "Description": "unique id for unified generators (res and conv)",
                    "Unit": "" },  
                   {"Name": "re_id",
                    "Description": "id for res-generators",
                    "Unit": "" },     
                   {"Name": "conv_id",
                    "Description": "id for conventional generators",
                    "Unit": "" }, 
                   {"Name": "aggr_id_pf",
                    "Description": "aggregate id for hv powerflow",
                    "Unit": "" },
                   {"Name": "aggr_id_ms",
                    "Description": "aggregate id for mv powerflow",
                    "Unit": "" },                        
                   {"Name": "geom",
                    "Description": "geometry",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "27.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_supply_generator' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_supply_generator','assignment_generator_bus.sql',' ');


-- Update table on conventional power plants and add information on unified id of generators and information of relevant bus

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','model_draft','ego_grid_mv_griddistrict','assignment_generator_bus.sql',' ');
SELECT ego_scenario_log('v0.2.5','input','model_draft','ego_grid_ehv_substation_voronoi','assignment_generator_bus.sql',' ');
SELECT ego_scenario_log('v0.2.5','input','model_draft','ego_grid_hvmv_substation','assignment_generator_bus.sql',' ');

/* ALTER TABLE supply.ego_conv_powerplant
	ADD COLUMN subst_id bigint,
	ADD COLUMN otg_id bigint,
	ADD COLUMN un_id bigint; */ 

-- Identify corresponding bus with the help of grid districts
UPDATE supply.ego_conv_powerplant a
	SET 	subst_id = b.subst_id
	FROM	model_draft.ego_grid_mv_griddistrict b
	WHERE 	ST_Intersects (a.geom, ST_TRANSFORM(b.geom,4326)) 
		AND voltage_level >= 3; 

-- Identify corresponding bus with the help of ehv-Voronoi
UPDATE supply.ego_conv_powerplant a
	SET 	subst_id = b.subst_id
	FROM 	model_draft.ego_grid_ehv_substation_voronoi b
	WHERE 	ST_Intersects (a.geom, b.geom) = TRUE
		AND voltage_level <= 2;

-- Insert otg_id of bus
UPDATE supply.ego_conv_powerplant a
	SET 	otg_id = b.otg_id 
	FROM 	model_draft.ego_grid_hvmv_substation b
	WHERE 	a.subst_id = b.subst_id;

-- Update un_id from generators_total  
UPDATE supply.ego_conv_powerplant a
	SET 	un_id = b.un_id 
	FROM 	model_draft.ego_supply_generator b
	WHERE 	a.gid = b.conv_id; 


-- Insert generator data into powerflow schema, that contains all generators seperately 
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
	w_id 		integer,
	aggr_id 	integer,
	CONSTRAINT generator_single_data_pkey PRIMARY KEY (scn_name, generator_id),
	CONSTRAINT generator_data_source_fk FOREIGN KEY (source)
		REFERENCES model_draft.ego_grid_pf_hv_source (source_id) MATCH SIMPLE
		ON UPDATE NO ACTION ON DELETE NO ACTION );

-- not needed
DELETE FROM model_draft.ego_supply_pf_generator_single; 

-- 
INSERT INTO model_draft.ego_supply_pf_generator_single (generator_id)
	SELECT 	un_id
	FROM 	model_draft.ego_supply_generator
	WHERE 	conv_id NOT IN 
		(SELECT a.gid 
		FROM supply.ego_conv_powerplant a
		WHERE a.fuel= 'pumped_storage' )
		OR re_id IS NOT NULL; -- pumped storage units are ignored here and will be listed in storage table 

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
"Description": ["assignment_generator_bus.sql"],
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
                    "Mail": "ilka.cussmann@hs-flensburg.de",
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
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_supply_pf_generator_single','assignment_generator_bus.sql',' ');


-- Update table on renewable power plants and add information on unified id of generators and information of relevant bus

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','model_draft','ego_grid_mv_griddistrict','assignment_generator_bus.sql',' ');
SELECT ego_scenario_log('v0.2.5','input','model_draft','ego_grid_ehv_substation_voronoi','assignment_generator_bus.sql',' ');
SELECT ego_scenario_log('v0.2.5','input','model_draft','ego_grid_hvmv_substation','assignment_generator_bus.sql',' ');

/* ALTER TABLE supply.ego_res_powerplant
 	ADD COLUMN subst_id bigint,
 	ADD COLUMN otg_id bigint,
 	ADD COLUMN un_id bigint; */

-- ACHTUNG: Hier wird in supply geschrieben. Das ist methodisch unsauber!

-- Identify corresponding bus with the help of grid districts
UPDATE supply.ego_res_powerplant a
	SET 	subst_id = b.subst_id
	FROM	model_draft.ego_grid_mv_griddistrict b
	WHERE 	ST_Intersects (a.geom, ST_TRANSFORM(b.geom,4326)) 
		AND voltage_level >= 3;  

-- Identify corresponding bus with the help of ehv-Voronoi
UPDATE supply.ego_res_powerplant a
	SET 	subst_id = b.subst_id
	FROM 	model_draft.ego_grid_ehv_substation_voronoi b
	WHERE 	ST_Intersects (a.geom, b.geom) = TRUE 
		AND voltage_level <= 2; 

-- Insert otg_id of bus
UPDATE supply.ego_res_powerplant a
	SET 	otg_id =b.otg_id 
	FROM 	model_draft.ego_grid_hvmv_substation b
	WHERE 	a.subst_id = b.subst_id; 

-- Update un_id from generators_total 
UPDATE supply.ego_res_powerplant a
	SET 	un_id = b.un_id 
	FROM 	model_draft.ego_supply_generator b
	WHERE 	a.id = b.re_id; 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','supply','ego_res_powerplant','assignment_generator_bus.sql',' ');


-- Insert generator data into powerflow schema, that contains all generators seperately 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','model_draft','ego_grid_pf_hv_source','assignment_generator_bus.sql',' ');

-- For conventional generators
UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	bus = b.otg_id, 
		p_nom = b.capacity, 
		control = 'PV',  -- For generators with a capacity 50 MW or more control is set to PV
		source = result.source
		FROM 	(SELECT c.source_id as source, d.fuel as fuel
			FROM 	model_draft.ego_grid_pf_hv_source c, 
				supply.ego_conv_powerplant d 
			WHERE	d.fuel = c.name) AS result,		
			supply.ego_conv_powerplant b
		WHERE 	a.generator_id = b.un_id 
			AND b.capacity >= 50 
			AND result.fuel = b.fuel;

UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	bus = b.otg_id, 
		p_nom = b.capacity,
		control = 'PQ', -- For generators with a capacity less than 50 MW control is set to PQ
		source = result.source
		FROM 	(SELECT c.source_id as source, d.fuel as fuel 
			FROM 	model_draft.ego_grid_pf_hv_source c, 
			       	supply.ego_conv_powerplant d
			WHERE	d.fuel = c.name) AS result,		
			supply.ego_conv_powerplant b
WHERE a.generator_id = b.un_id and b.capacity < 50 AND result.fuel = b.fuel;

-- For renewables 
UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	bus = b.otg_id, 
		p_nom = b.electrical_capacity/1000, -- unit for capacity in RE-register is kW
		dispatch = 'variable',
		control = 'PQ' -- For RE generators control is set to PQ
		FROM 	supply.ego_res_powerplant b
		WHERE 	a.generator_id = b.un_id;


UPDATE model_draft.ego_supply_pf_generator_single a
	SET source = result.source
		FROM 	(SELECT c.source_id as source, 
				d.un_id as un_id
			FROM 	model_draft.ego_grid_pf_hv_source c, 
			       	supply.ego_res_powerplant d
			WHERE	d.generation_type = c.name) AS result,
			supply.ego_res_powerplant b
		WHERE a.generator_id = b.un_id AND a.generator_id = result.un_id; 

-- Control is changed to PV for biomass powerplants > 50 MW
UPDATE model_draft.ego_supply_pf_generator_single 
	SET control = 'PV'
		FROM 	(SELECT source_id as id
			FROM model_draft.ego_grid_pf_hv_source a
			WHERE a.name ='biomass') AS result  
		WHERE p_nom > 50 AND source = result.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','model_draft','renpassgis_economic_weatherpoint_voronoi','assignment_generator_bus.sql',' ');

-- Identify weather point IDs for each generator
UPDATE model_draft.ego_supply_pf_generator_single a
	SET w_id = b.id
		FROM 	(SELECT c.un_id, c.geom 
			FROM model_draft.ego_supply_generator c) AS result,
			model_draft.renpassgis_economic_weatherpoint_voronoi b 
		WHERE 	ST_Intersects (result.geom, b.geom) 
			AND generator_id = result.un_id;


-- Create aggregate IDs in pf_generator_single

-- Create sequence for aggregate ID
DROP SEQUENCE IF EXISTS model_draft.ego_supply_pf_generator_single_aggr_id;
CREATE SEQUENCE 	model_draft.ego_supply_pf_generator_single_aggr_id INCREMENT 1;

-- grant (oeuser)
ALTER TABLE		model_draft.ego_supply_pf_generator_single_aggr_id OWNER TO oeuser;

-- source = (wind and solar) and p_nom < 50 MW
UPDATE model_draft.ego_supply_pf_generator_single a
	SET aggr_id = result.aggr_id
		FROM 	(SELECT	b.bus, 
				b.w_id, 
				b.source, 
				nextval('model_draft.ego_supply_pf_generator_single_aggr_id') as aggr_id
			FROM 	model_draft.ego_supply_pf_generator_single b 
			WHERE 	p_nom < 50 AND source IN 
				(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar') 
			GROUP BY bus, w_id, source) AS result
		WHERE 	a.bus = result.bus 
			AND a.w_id = result.w_id 
			AND a.source = result.source;

-- source != (wind and solar) and p_nom < 50 MW 
UPDATE model_draft.ego_supply_pf_generator_single a
	SET aggr_id = result.aggr_id
		FROM  	(SELECT	b.bus, 
				b.source, 
				nextval('model_draft.ego_supply_pf_generator_single_aggr_id') as aggr_id
			FROM model_draft.ego_supply_pf_generator_single b 
			WHERE p_nom < 50 AND source NOT IN 
				(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar')
			GROUP BY b.bus, b.source) AS result
		WHERE 	a.bus = result.bus 
			AND a.source = result.source;

-- all sources and p_nom >= 50MW
UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	aggr_id = nextval('model_draft.ego_supply_pf_generator_single_aggr_id')
	WHERE 	a.p_nom >= 50;


-- Accumulate data from pf_generator_single and insert into hv_powerflow schema. 

-- source = (wind and solar) and p_nom < 50 MW
INSERT INTO model_draft.ego_grid_pf_hv_generator (
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
	SELECT	aggr_id,
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
	GROUP BY a.aggr_id, a.bus, a.w_id, a.source;

-- source != (wind and solar) and p_nom < 50 MW 
INSERT INTO model_draft.ego_grid_pf_hv_generator (
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
	SELECT  aggr_id,
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
	GROUP BY a.aggr_id, a.bus, a.source;

-- all sources and p_nom >= 50MW
INSERT INTO model_draft.ego_grid_pf_hv_generator (
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
	FROM 	model_draft.ego_supply_pf_generator_single a
	WHERE 	a.p_nom >= 50 AND a.aggr_id IS NOT NULL;


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
	WHERE 	cntr_id != 'DE' 
		AND result_id = GREATEST(result_id) 
		AND bus_i IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus) 
		AND base_kv > 110;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_grid_pf_hv_generator','assignment_generator_bus.sql',' ');
