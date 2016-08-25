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
-- Add information on corresponding bus (subst_id and otg_id) to load areas
-----

ALTER TABLE calc_ego_loads.ego_deu_load_area
	ADD COLUMN otg_id bigint;

-- Identify corresponding bus with the help of grid districts (large scale consumer are not considered seperately yet) 

UPDATE calc_ego_loads.ego_deu_load_area a
	SET otg_id = b.otg_id
	FROM calc_ego_substation.ego_deu_substations b
	WHERE a.subst_id = b.id; 

-- Add data to pf_load_single 

INSERT INTO calc_ego_loads.pf_load_single (load_id, bus, e_annual)
	SELECT id, otg_id, sector_consumption_sum
	FROM calc_ego_loads.ego_deu_load_area; 


-- Aggregate load per bus and insert into hv_powerflow schema 


INSERT INTO calc_ego_hv_powerflow.load (e_annual, load_id, bus)
SELECT sum(e_annual), bus, bus 
FROM calc_ego_loads.pf_load_single a
WHERE a.bus IS NOT NULL
GROUP BY a.bus;


