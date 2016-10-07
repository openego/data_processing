﻿ DROP TABLE IF EXISTS calc_ego_loads.loads_total CASCADE;

CREATE TABLE calc_ego_loads.loads_total
(
  un_id serial NOT NULL, 
  ssc_id integer, 
  lsc_id integer,
  geom geometry(Point,4326),
  CONSTRAINT generators_total_pkey PRIMARY KEY (un_id)
);

ALTER TABLE calc_ego_loads.loads_total
	OWNER TO oeuser;
	
DELETE FROM calc_ego_loads.loads_total; 

INSERT INTO calc_ego_loads.loads_total (ssc_id, geom) 
	SELECT id, geom
	FROM calc_ego_loads.ego_deu_consumption; 

INSERT INTO calc_ego_loads.loads_total (lsc_id, geom) 
	SELECT id, geom
	FROM calc_ego_loads.large_scale_consumer; 

CREATE INDEX loads_total_idx
  ON calc_ego_loads.loads_total
  USING gist
  (geom);



-----
-- Create table to assign single load areas to a bus
-----
DROP TABLE IF EXISTS calc_ego_loads.pf_load_single;

CREATE TABLE calc_ego_loads.pf_load_single
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  load_id bigint NOT NULL, -- Unit: n/a...
  bus bigint, -- Unit: n/a...
  sign double precision DEFAULT (-1), -- Unit: n/a...
  e_annual double precision, -- Unit: MW...
  CONSTRAINT load_data_pkey PRIMARY KEY (load_id),
  CONSTRAINT load_data_bus_fk FOREIGN KEY (bus, scn_name)
      REFERENCES calc_ego_hv_powerflow.bus (bus_id, scn_name) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE calc_ego_hv_powerflow.load
  OWNER TO oeuser;

-----
-- Add information on corresponding bus (subst_id and otg_id) and un_id to load tables
-----


-- Identify corresponding bus for small scale consumer (ssc) with the help of grid districts and add un_id
ALTER TABLE calc_ego_loads.ego_deu_consumption
	ADD COLUMN otg_id bigint;


UPDATE calc_ego_loads.ego_deu_consumption a
	SET otg_id = b.otg_id
	FROM calc_ego_substation.ego_deu_substations b
	WHERE a.subst_id = b.id; 

UPDATE calc_ego_loads.ego_deu_consumption a
	SET un_id = b.un_id 
	FROM calc_ego_loads.loads_total b
	WHERE a.id = b.ssc_id; 

-- Identify corresponding bus for large scale consumer (lsc) with the help of ehv-voronoi and add un_id

ALTER TABLE calc_ego_loads.large_scale_consumer
	ADD COLUMN subst_id bigint,
	ADD COLUMN otg_id bigint,
	ADD COLUMN un_id bigint;

UPDATE calc_ego_loads.large_scale_consumer a
	SET subst_id = b.subst_id
	FROM calc_ego_substation.ego_deu_voronoi_ehv b
	WHERE ST_Intersects (ST_Transform(a.geom,4326), b.geom) =TRUE;

UPDATE calc_ego_loads.large_scale_consumer a
	SET otg_id = b.otg_id
	FROM calc_ego_substation.ego_deu_substations b
	WHERE a.subst_id = b.id; 

UPDATE calc_ego_loads.large_scale_consumer a
	SET un_id = b.un_id 
	FROM calc_ego_loads.loads_total b
	WHERE a.id = b.lsc_id; 

-------------
-- Insert load data into powerflow schema, that contains all generators seperately 
-------------

-- Add data for small scale consumer to pf_load_single 

INSERT INTO calc_ego_loads.pf_load_single (load_id, bus, e_annual)
	SELECT un_id, otg_id, (sector_consumption_residential+sector_consumption_retail+sector_consumption_industrial+sector_consumption_agricultural)
	FROM calc_ego_loads.ego_deu_consumption; 

-- Add data for large scale consumer to pf_load_single 

INSERT INTO calc_ego_loads.pf_load_single (load_id, bus, e_annual)
	SELECT un_id, otg_id, consumption
	FROM calc_ego_loads.large_scale_consumer; 

-------------
-- Aggregate load per bus and insert into hv_powerflow schema 
-------------

INSERT INTO calc_ego_hv_powerflow.load (e_annual, load_id, bus)
SELECT sum(e_annual), bus, bus 
FROM calc_ego_loads.pf_load_single a
WHERE a.bus IS NOT NULL
GROUP BY a.bus;


-- Assigment of otg_id for demand time series (to be added to demand time series script, temporarily here)

INSERT INTO calc_ego_hv_powerflow.load_pq_set (load_id, temp_id, p_set)
	SELECT
	result.otg_id,
	1,
	b.demand

	FROM 
		(SELECT id, otg_id FROM calc_ego_substation.ego_deu_substations) 
		AS result, calc_ego_loads.ego_demand_per_transition_point b
	WHERE b.id = result.id
