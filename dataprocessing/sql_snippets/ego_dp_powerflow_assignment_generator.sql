/*
Assignment of generators to the relevant substation in the grid model based on grid districts for generators connected to the HV, MV or LV level. 
Generators connected to the EHV level are assigned based on voronoi cells. 

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu, Ludee" 
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

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_supply_res_powerplant','ego_dp_powerflow_assignment_generator.sql',' ');
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_supply_conv_powerplant','ego_dp_powerflow_assignment_generator.sql',' ');

INSERT INTO model_draft.ego_supply_generator (re_id, geom) 
	SELECT 	id, geom
	FROM 	model_draft.ego_supply_res_powerplant
	WHERE geom IS NOT NULL;

INSERT INTO model_draft.ego_supply_generator (conv_id, geom) 
	SELECT 	gid, geom
	FROM 	model_draft.ego_supply_conv_powerplant
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
"Description": ["ego_dp_powerflow_assignment_generator.sql"],
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
                    "Mail": "",
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
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_supply_generator','ego_dp_powerflow_assignment_generator.sql',' ');


-- Update table on conventional power plants and add information on unified id of generators and information of relevant bus

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_mv_griddistrict','ego_dp_powerflow_assignment_generator.sql',' ');
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_ehv_substation_voronoi','ego_dp_powerflow_assignment_generator.sql',' ');
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_hvmv_substation','ego_dp_powerflow_assignment_generator.sql',' ');


-- Identify corresponding bus with the help of grid districts
UPDATE model_draft.ego_supply_conv_powerplant a
	SET 	subst_id = b.subst_id
	FROM	model_draft.ego_grid_mv_griddistrict b
	WHERE 	a.geom && ST_TRANSFORM(b.geom,4326)
		AND ST_Intersects(a.geom, ST_TRANSFORM(b.geom,4326)) 
		AND voltage_level >= 3; 

-- Identify corresponding bus with the help of ehv-Voronoi
UPDATE model_draft.ego_supply_conv_powerplant a
	SET 	subst_id = b.subst_id
	FROM 	model_draft.ego_grid_ehv_substation_voronoi b
	WHERE 	a.geom && b.geom
		AND ST_Intersects(a.geom, b.geom)
		AND voltage_level <= 2;

-- Assign conventional pp with voltage_level >2 located outside of Germany to their closest 110 kV substation

ALTER TABLE model_draft.ego_supply_conv_powerplant
   ADD COLUMN subst_id_NN int; 

UPDATE model_draft.ego_supply_conv_powerplant a
   SET subst_id_NN = result.subst_id	
   FROM 
	(SELECT DISTINCT ON (pp.gid) pp.gid, subst.subst_id, ST_Distance(ST_Transform(subst.geom, 4326), pp.geom)  as dist
	   FROM model_draft.ego_supply_conv_powerplant As pp, model_draft.ego_grid_hvmv_substation As subst   
	   ORDER BY pp.gid, ST_Distance(ST_Transform(subst.geom, 4326), pp.geom), subst.subst_id) as result
	   WHERE a.gid=result.gid;

UPDATE model_draft.ego_supply_conv_powerplant a
   SET subst_id=subst_id_NN
   WHERE subst_id IS NULL and voltage_level > 2; 

ALTER TABLE model_draft.ego_supply_conv_powerplant 
   DROP COLUMN subst_id_NN; 



-- Insert otg_id of bus
UPDATE model_draft.ego_supply_conv_powerplant a
	SET 	otg_id = b.otg_id 
	FROM 	model_draft.ego_grid_hvmv_substation b
	WHERE 	a.subst_id = b.subst_id;
	

-- Update un_id from generators_total  
UPDATE model_draft.ego_supply_conv_powerplant a
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
	w_id 		bigint,
	aggr_id 	bigint,
	CONSTRAINT generator_single_data_pkey PRIMARY KEY (scn_name, generator_id),
	CONSTRAINT generator_data_source_fk FOREIGN KEY (source)
		REFERENCES model_draft.ego_grid_pf_hv_source (source_id) MATCH SIMPLE
		ON UPDATE NO ACTION ON DELETE NO ACTION );

-- 
INSERT INTO model_draft.ego_supply_pf_generator_single (generator_id)
	SELECT 	un_id
	FROM 	model_draft.ego_supply_generator
	WHERE 	conv_id NOT IN 
		(SELECT a.gid 
		FROM model_draft.ego_supply_conv_powerplant a
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
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_supply_pf_generator_single','ego_dp_powerflow_assignment_generator.sql',' ');


-- Update table on renewable power plants and add information on unified id of generators and information of relevant bus

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_mv_griddistrict','ego_dp_powerflow_assignment_generator.sql',' ');
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_ehv_substation_voronoi','ego_dp_powerflow_assignment_generator.sql',' ');
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_hvmv_substation','ego_dp_powerflow_assignment_generator.sql',' ');


-- Identify corresponding bus with the help of grid districts
UPDATE model_draft.ego_supply_res_powerplant a
	SET 	subst_id = b.subst_id
	FROM	model_draft.ego_grid_mv_griddistrict b
	WHERE 	a.geom && ST_TRANSFORM(b.geom,4326)
		AND ST_Intersects(a.geom, ST_TRANSFORM(b.geom,4326)) 
		AND voltage_level >= 3;  

-- Identify corresponding bus with the help of ehv-Voronoi
UPDATE model_draft.ego_supply_res_powerplant a
	SET 	subst_id = b.subst_id
	FROM 	model_draft.ego_grid_ehv_substation_voronoi b
	WHERE 	a.geom && b.geom
		AND ST_Intersects(a.geom, b.geom)
		AND voltage_level <= 2; 

-- Insert otg_id of bus
UPDATE model_draft.ego_supply_res_powerplant a
	SET 	otg_id =b.otg_id 
	FROM 	model_draft.ego_grid_hvmv_substation b
	WHERE 	a.subst_id = b.subst_id; 
	
-- Update otg_id of offshore windturbines manually 


UPDATE model_draft.ego_supply_res_powerplant

SET otg_id = (CASE 	WHEN ST_Within(model_draft.ego_supply_res_powerplant.geom, ST_Transform(ST_GeomFromText('Polygon((6.52991154226757331 55.0731495469060448, 6.76032878777667889 55.5415269292555891, 7.95630401446679425 55.49182999161460828, 8.23061025912049082 54.05536039374283064, 8.04682507520251633 53.92957832960381381, 6.52991154226757331 55.0731495469060448))', 4326), 4326))
			THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE (geom = '0101000020E6100000BB169FDC4B782240A84AC13A5BF54A40' AND v_nom = 380))

			WHEN ST_Within(model_draft.ego_supply_res_powerplant.geom, ST_Transform(ST_GeomFromText('Polygon((5.85237511797294463 54.84951794763450295, 4.78532382627006481 54.35697386477539084, 6.3817861701545775 53.57925959134499294, 5.85237511797294463 54.84951794763450295))', 4326), 4326)) 
			THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE (geom = '0101000020E6100000E10EC4C4D53E1D4032D0841E19904A40' AND v_nom = 380))

			WHEN ST_Within(model_draft.ego_supply_res_powerplant.geom, ST_Transform(ST_GeomFromText('Polygon((6.38727229504765148 53.58252052345604, 5.86060430531255516 54.84635981450501419, 6.54088379205372217 55.07943099765473249, 8.04408201275597889 53.93279988414769832, 6.38727229504765148 53.58252052345604))', 4326), 4326))
			THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE (geom = '0101000020E6100000F6D6A6710E081D40B62017FD957D4A40' AND v_nom = 380))
			
			WHEN ST_Within(model_draft.ego_supply_res_powerplant.geom, ST_Transform(ST_GeomFromText('Polygon((12.77312167058569869 55.19855141024020639, 12.49881542593200479 54.66908170513258369, 14.36409788957713651 54.76412687912878852, 14.39701463893557865 55.26744430972406974, 12.77312167058569869 55.19855141024020639))	', 4326), 4326))
			THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE (geom = '0101000020E6100000509011B4F05D2B4040490BB9CD114B40' AND v_nom = 380))

			ELSE otg_id
			
			END);

-- Update un_id from generators_total 
UPDATE model_draft.ego_supply_res_powerplant a
	SET 	un_id = b.un_id 
	FROM 	model_draft.ego_supply_generator b
	WHERE 	a.id = b.re_id; 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_supply_res_powerplant','ego_dp_powerflow_assignment_generator.sql',' ');


-- Insert generator data into powerflow schema, that contains all generators seperately 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_pf_hv_source','ego_dp_powerflow_assignment_generator.sql',' ');

-- For conventional generators
UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	bus = b.otg_id, 
		p_nom = b.capacity, 
		control = 'PV',  -- For generators with a capacity 50 MW or more control is set to PV
		source = result.source
		FROM 	(SELECT c.source_id as source, d.fuel as fuel
			FROM 	model_draft.ego_grid_pf_hv_source c, 
				model_draft.ego_supply_conv_powerplant d 
			WHERE	d.fuel = c.name) AS result,		
			model_draft.ego_supply_conv_powerplant b
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
			       	model_draft.ego_supply_conv_powerplant d
			WHERE	d.fuel = c.name) AS result,		
			model_draft.ego_supply_conv_powerplant b
WHERE a.generator_id = b.un_id and b.capacity < 50 AND result.fuel = b.fuel;

-- For renewables 
UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	bus = b.otg_id, 
		p_nom = b.electrical_capacity/1000, -- unit for capacity in RE-register is kW
		dispatch = 'variable',
		control = 'PQ' -- For RE generators control is set to PQ
		FROM 	model_draft.ego_supply_res_powerplant b
		WHERE 	a.generator_id = b.un_id;


UPDATE model_draft.ego_supply_pf_generator_single a
	SET source = result.source
		FROM 	(SELECT c.source_id as source, 
				d.un_id as un_id
			FROM 	model_draft.ego_grid_pf_hv_source c, 
			       	model_draft.ego_supply_res_powerplant d
			WHERE	d.generation_type = c.name) AS result,
			model_draft.ego_supply_res_powerplant b
		WHERE a.generator_id = b.un_id AND a.generator_id = result.un_id; 

-- Control is changed to PV for biomass powerplants > 50 MW
UPDATE model_draft.ego_supply_pf_generator_single 
	SET control = 'PV'
		FROM 	(SELECT source_id as id
			FROM model_draft.ego_grid_pf_hv_source a
			WHERE a.name ='biomass') AS result  
		WHERE p_nom > 50 AND source = result.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','renpassgis_economic_weatherpoint_voronoi','ego_dp_powerflow_assignment_generator.sql',' ');

-- Identify weather point IDs for each generator
UPDATE model_draft.ego_supply_pf_generator_single a
	SET w_id = b.id
		FROM 	(SELECT c.un_id, c.geom 
			FROM model_draft.ego_supply_generator c) AS result,
			model_draft.renpassgis_economic_weatherpoint_voronoi b 
		WHERE 	result.geom && b.geom
			AND ST_Intersects(result.geom, b.geom) 
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

-- source <> (wind and solar) and p_nom < 50 MW 
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

-- source <> (wind and solar) and p_nom < 50 MW 
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
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_generator','ego_dp_powerflow_assignment_generator.sql',' ');
