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
		control = 'PQ',  -- For generators with a capacity 50 MW or more control is set to PQ
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
		control = 'PV', 
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
		control = 'PV'
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

-- Control is changed to PQ for biomass powerplants > 50 MW

UPDATE orig_geo_powerplants.pf_generator_single 
	SET control = 'PQ'
	 
		FROM 
			(SELECT source_id as id
			 FROM calc_ego_hv_powerflow.source a
			 WHERE a.name ='biomass')
		
		AS result  
WHERE p_nom > 50 AND source = result.id;

-----------
-- Accumulate data from pf_generator_single for hv_powerflow schema. Powerplants with a capacity of under 50 MW 
-- are aggregated per bus and technology
-----------


