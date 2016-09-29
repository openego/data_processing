--------------	
-- Insert storage data into powerflow schema, that contains all storage units seperately 
--------------


DROP TABLE IF EXISTS orig_geo_powerplants.pf_storage_single;

CREATE TABLE orig_geo_powerplants.pf_storage_single
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
  standing_loss double precision, -- Unit: per unit...
 CONSTRAINT storage_data_pkey PRIMARY KEY (storage_id, scn_name),
  CONSTRAINT storage_data_source_fkey FOREIGN KEY (source)
      REFERENCES calc_ego_hv_powerflow.source (source_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE orig_geo_powerplants.pf_storage_single
  OWNER TO oeuser;


DELETE FROM orig_geo_powerplants.pf_storage_single; 

INSERT INTO orig_geo_powerplants.pf_storage_single (storage_id)
	SELECT un_id
	FROM orig_geo_powerplants.generators_total
	WHERE conv_id IN 
		(SELECT a.gid 
		  FROM orig_geo_powerplants.proc_power_plant_germany a
		  WHERE a.fuel= 'pumped_storage'
		); -- only (pumped) storage units are selected and written into pf_storage_single 

-- For pumped storage (this section needs to be extended as soon as other storage technologies are included) 

UPDATE orig_geo_powerplants.pf_storage_single a
	SET bus = b.otg_id, 
		p_nom = b.capacity, 
		control = 'PV',  -- For pumped storage units control is set to PV
		source = result.source
		FROM 
			(SELECT c.source_id as source, d.fuel as fuel
			FROM 	calc_ego_hv_powerflow.source c, 
				orig_geo_powerplants.proc_power_plant_germany d 
			WHERE	d.fuel = c.name) 
			AS 	result,		
			orig_geo_powerplants.proc_power_plant_germany b
WHERE a.storage_id = b.un_id and result.fuel = 'pumped_storage' AND result.fuel = b.fuel;

DELETE FROM orig_geo_powerplants.pf_storage_single WHERE p_nom IS NULL; -- Delete those PS units without an entry on the installed capacity


-----------
-- Create aggregate IDs in pf_storage_single
-----------
-- Create sequence for aggregate ID

DROP SEQUENCE IF EXISTS orig_geo_powerplants.pf_storage_single_aggr_id;
CREATE SEQUENCE orig_geo_powerplants.pf_storage_single_aggr_id
  INCREMENT 1;
ALTER TABLE orig_geo_powerplants.pf_storage_single_aggr_id
  OWNER TO oeuser;

-- source= pumped_storage and p_nom < 50 MW 
	
UPDATE orig_geo_powerplants.pf_storage_single a
	SET aggr_id = result.aggr_id
		FROM 
			(SELECT b.bus, b.source, nextval('orig_geo_powerplants.pf_storage_single_aggr_id') as aggr_id
			FROM orig_geo_powerplants.pf_storage_single b 
			WHERE p_nom < 50 AND source NOT IN 
				(SELECT source_id from calc_ego_hv_powerflow.source WHERE name = 'pumped_storage')
			GROUP BY b.bus, b.source)
			as result
	WHERE a.bus = result.bus AND a.source = result.source;

-- all sources (in the moment this only includes pumped storage) and p_nom >= 50MW

UPDATE orig_geo_powerplants.pf_storage_single a
	SET aggr_id = nextval('orig_geo_powerplants.pf_storage_single_aggr_id')
	WHERE a.p_nom >= 50;

