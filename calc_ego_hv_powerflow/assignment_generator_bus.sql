------------
-- Create a table that contains all generators (RE and conventional) but no duplicates. 
------------

DROP TABLE IF EXISTS orig_geo_powerplants.generators_total;

CREATE TABLE orig_geo_powerplants.generators_total
(
  un_id serial NOT NULL, 
  re_id integer, 
  conv_id integer,
  aggr_id_pf integer, 
  aggr_id_ms integer, 
  geom geometry(Point,4326),
  CONSTRAINT generators_total_pkey PRIMARY KEY (un_id)
);

ALTER TABLE orig_geo_powerplants.generators_total
	OWNER TO oeuser; 


INSERT INTO orig_geo_powerplants.generators_total (re_id, geom) 
	SELECT id, geom
	FROM orig_geo_powerplants.proc_renewable_power_plants_germany
	WHERE geom IS NOT NULL; 

INSERT INTO orig_geo_powerplants.generators_total (conv_id, geom) 
	SELECT gid, geom
	FROM orig_geo_powerplants.proc_power_plant_germany
	WHERE eeg NOT LIKE 'yes'; -- Duplicates that already occur in the eeg-list are ignored 


---------------
-- Update table on conventional power plants and add information on unified id of generators and information of relevant bus
---------------

/* ALTER TABLE orig_geo_powerplants.proc_power_plant_germany
	ADD COLUMN subst_id bigint,
	ADD COLUMN otg_id bigint,
	ADD COLUMN un_id bigint; */ 

-- Identify corresponding bus with the help of grid districts

UPDATE orig_geo_powerplants.proc_power_plant_germany a
	SET subst_id = b.subst_id,
	    otg_id = result.otg_id
	FROM 
		(SELECT c.otg_id, c.id as subst_id
		 FROM 	calc_ego_substation.ego_deu_substations c, 
		 	calc_ego_grid_district.grid_district d
		 WHERE c.id = d.subst_id)
		AS result, 
		calc_ego_grid_district.grid_district b
	WHERE ST_Intersects (a.geom, ST_TRANSFORM(b.geom,4326))  AND voltage_level >= 3 AND result.subst_id = b.subst_id; 

-- Identify corresponding bus with the help of ehv-Voronoi

UPDATE orig_geo_powerplants.proc_power_plant_germany a
	SET subst_id = b.subst_id, 
	    otg_id = result.otg_id
	FROM 
		(SELECT c.otg_id, c.id as subst_id
		 FROM 	calc_ego_substation.ego_deu_substations_ehv c, 
		 	calc_ego_substation.ego_deu_voronoi_ehv d
		 WHERE c.id = d.subst_id)
		AS result, 
		calc_ego_substation.ego_deu_voronoi_ehv b
	WHERE ST_Intersects (a.geom, b.geom) =TRUE AND voltage_level <= 2 AND result.subst_id = b.subst_id;
 
-- Update un_id from generators_total  

UPDATE orig_geo_powerplants.proc_power_plant_germany a
	SET un_id = b.un_id 
	FROM orig_geo_powerplants.generators_total b
	WHERE a.gid = b.conv_id; 




--------------	
-- Insert generator data into powerflow schema, that contains all generators seperately 
--------------


DROP TABLE orig_geo_powerplants.pf_generator_single;

CREATE TABLE orig_geo_powerplants.pf_generator_single
(
  generator_id bigint NOT NULL,
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
  w_id integer,
  aggr_id integer,
  CONSTRAINT generator_data_pkey PRIMARY KEY (generator_id),
  CONSTRAINT generator_data_source_fk FOREIGN KEY (source)
      REFERENCES calc_ego_hv_powerflow.source (source_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE orig_geo_powerplants.pf_generator_single
  OWNER TO oeuser;


INSERT INTO orig_geo_powerplants.pf_generator_single (generator_id)
	SELECT un_id
	FROM orig_geo_powerplants.generators_total
	WHERE conv_id NOT IN 
		(SELECT a.gid 
		  FROM orig_geo_powerplants.proc_power_plant_germany a
		  WHERE a.fuel= 'pumped_storage'
		)
	 OR re_id IS NOT NULL; -- pumped storage units are ignored here and will be listed in storage table 


-----------------
-- Update table on renewable power plants and add information on unified id of generators and information of relevant bus
-----------------


/* ALTER TABLE orig_geo_powerplants.proc_renewable_power_plants_germany
 	ADD COLUMN subst_id bigint,
 	ADD COLUMN otg_id bigint,
 	ADD COLUMN un_id bigint; */

-- Identify corresponding bus with the help of grid districts

UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany a
	SET subst_id = b.subst_id, 
	    otg_id = result.otg_id
	FROM 
		(SELECT c.otg_id , c.id as subst_id
		 FROM 	calc_ego_substation.ego_deu_substations c, 
		 	calc_ego_grid_district.grid_district d
		 WHERE c.id = d.subst_id)
		AS result, 
		calc_ego_grid_district.grid_district b
	WHERE ST_Intersects (a.geom, ST_TRANSFORM(b.geom,4326)) =TRUE AND voltage_level >= 3 AND result.subst_id = b.subst_id; 

-- Identify corresponding bus with the help of ehv-Voronoi

UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany a
	SET subst_id = b.subst_id, 
	    otg_id = result.otg_id
	FROM 
		(SELECT c.otg_id , c.id as subst_id
		 FROM 	calc_ego_substation.ego_deu_substations_ehv c, 
		 	calc_ego_substation.ego_deu_voronoi_ehv d
		 WHERE c.id = d.subst_id)
		AS result, 
		calc_ego_substation.ego_deu_voronoi_ehv b
	WHERE ST_Intersects (a.geom, b.geom) =TRUE AND voltage_level <= 2 AND result.subst_id = b.subst_id; 

-- Update un_id from generators_total 

UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany a
	SET un_id = b.un_id 
	FROM orig_geo_powerplants.generators_total b
	WHERE a.id = b.re_id; 

-------------
-- Insert generator data into powerflow schema, that contains all generators seperately 
-------------

-- For conventional generators

UPDATE orig_geo_powerplants.pf_generator_single a
	SET bus = b.otg_id, 
		p_nom = b.capacity, 
		control = 'PV',  -- For generators with a capacity 50 MW or more control is set to PV
		source = result.source
		FROM 
			(SELECT c.source_id as source, d.fuel as fuel
			FROM 	calc_ego_hv_powerflow.source c, 
				orig_geo_powerplants.proc_power_plant_germany d 
			WHERE	d.fuel = c.name) 
			AS 	result,		
			orig_geo_powerplants.proc_power_plant_germany b
WHERE a.generator_id = b.un_id and b.capacity >= 50 AND result.fuel = b.fuel;


UPDATE orig_geo_powerplants.pf_generator_single a
	SET 	bus = b.otg_id, 
		p_nom = b.capacity,
		control = 'PQ', -- For generators with a capacity less than 50 MW control is set to PQ
		source = result.source
		FROM 
			( SELECT c.source_id as source, d.fuel as fuel 
			  FROM 	calc_ego_hv_powerflow.source c, 
			       	orig_geo_powerplants.proc_power_plant_germany d
			  WHERE	d.fuel = c.name) 
			AS 	result,		
				orig_geo_powerplants.proc_power_plant_germany b
WHERE a.generator_id = b.un_id and b.capacity < 50 AND result.fuel = b.fuel;

-- For renewables 

UPDATE orig_geo_powerplants.pf_generator_single a
	SET 	bus = b.otg_id, 
		p_nom = b.electrical_capacity/1000, -- unit for capacity in RE-register is kW
		control = 'PQ' -- For RE generators control is set to PQ
		FROM orig_geo_powerplants.proc_renewable_power_plants_germany b
WHERE a.generator_id = b.un_id;


UPDATE orig_geo_powerplants.pf_generator_single a
	SET source = result.source
		FROM 
			(SELECT c.source_id as source, d.un_id as un_id
			  FROM 	calc_ego_hv_powerflow.source c, 
			       	orig_geo_powerplants.proc_renewable_power_plants_germany d
			  WHERE	d.generation_type = c.name) 
			  AS 	result, orig_geo_powerplants.proc_renewable_power_plants_germany b
WHERE a.generator_id = b.un_id AND a.generator_id = result.un_id; 

-- Control is changed to PV for biomass powerplants > 50 MW

UPDATE orig_geo_powerplants.pf_generator_single 
	SET control = 'PV'
	 
		FROM 
			(SELECT source_id as id
			 FROM calc_ego_hv_powerflow.source a
			 WHERE a.name ='biomass')
		
		AS result  
WHERE p_nom > 50 AND source = result.id;

-----------
-- Identify weather point IDs for each generator
-----------

UPDATE orig_geo_powerplants.pf_generator_single a
	SET w_id = b.id
		FROM 
			(SELECT c.un_id, c.geom 
			 FROM orig_geo_powerplants.generators_total c)
			AS result,
		calc_renpass_gis.voronoi_weatherpoint b 
WHERE ST_Intersects (result.geom, b.geom) AND generator_id = result.un_id;

-----------
-- Create aggregate IDs in pf_generator_single
-----------
-- Create sequence for aggregate ID

DROP SEQUENCE IF EXISTS orig_geo_powerplants.pf_generator_single_aggr_id;
CREATE SEQUENCE orig_geo_powerplants.pf_generator_single_aggr_id
  INCREMENT 1;
ALTER TABLE orig_geo_powerplants.pf_generator_single_aggr_id
  OWNER TO oeuser;

-- source = (wind and solar) and p_nom < 50 MW

UPDATE orig_geo_powerplants.pf_generator_single a
	SET aggr_id = result.aggr_id
		FROM 
			(SELECT b.bus, b.w_id, b.source, nextval('orig_geo_powerplants.pf_generator_single_aggr_id') as aggr_id
			FROM orig_geo_powerplants.pf_generator_single b 
			WHERE p_nom < 50 AND source IN 
				(SELECT source_id from calc_ego_hv_powerflow.source WHERE name = 'wind' OR name = 'solar') 
			GROUP BY bus, w_id, source)
			as result
	WHERE a.bus = result.bus AND a.w_id = result.w_id AND a.source = result.source;

-- source != (wind and solar) and p_nom < 50 MW 
	
UPDATE orig_geo_powerplants.pf_generator_single a
	SET aggr_id = result.aggr_id
		FROM 
			(SELECT b.bus, b.source, nextval('orig_geo_powerplants.pf_generator_single_aggr_id') as aggr_id
			FROM orig_geo_powerplants.pf_generator_single b 
			WHERE p_nom < 50 AND source NOT IN 
				(SELECT source_id from calc_ego_hv_powerflow.source WHERE name = 'wind' OR name = 'solar')
			GROUP BY b.bus, b.source)
			as result
	WHERE a.bus = result.bus AND a.source = result.source;

-- all sources and p_nom >= 50MW

UPDATE orig_geo_powerplants.pf_generator_single a
	SET aggr_id = nextval('orig_geo_powerplants.pf_generator_single_aggr_id')
	WHERE a.p_nom >= 50;

-----------
-- Accumulate data from pf_generator_single and insert into hv_powerflow schema. 
-----------
	
-- source = (wind and solar) and p_nom < 50 MW
INSERT INTO calc_ego_hv_powerflow.generator (
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
FROM orig_geo_powerplants.pf_generator_single a
WHERE a.p_nom < 50 AND a.aggr_id IS NOT NULL AND source IN 
	(SELECT source_id from calc_ego_hv_powerflow.source WHERE name = 'wind' OR name = 'solar')
GROUP BY a.aggr_id, a.bus, a.w_id, a.source;

-- source != (wind and solar) and p_nom < 50 MW 
INSERT INTO calc_ego_hv_powerflow.generator (
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
FROM orig_geo_powerplants.pf_generator_single a
WHERE a.p_nom < 50 AND a.aggr_id IS NOT NULL AND source NOT IN 
	(SELECT source_id from calc_ego_hv_powerflow.source WHERE name = 'wind' OR name = 'solar')
	
GROUP BY a.aggr_id, a.bus, a.source;

-- all sources and p_nom >= 50MW

INSERT INTO calc_ego_hv_powerflow.generator (
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
FROM orig_geo_powerplants.pf_generator_single a
WHERE a.p_nom >= 50 AND a.aggr_id IS NOT NULL;
