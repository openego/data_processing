/*
Assignment of generators to the relevant substation in the grid model based on grid districts for generators connected to the HV, MV or LV level. 
Generators connected to the EHV level are assigned based on voronoi cells. The consideres scenario is 'NEP 2035'.
__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

-- Create a table that contains all generators for 'NEP 2035' (RE and conventional) but no duplicates. 


DROP TABLE IF EXISTS model_draft.ego_supply_generator_nep2035;

CREATE TABLE model_draft.ego_supply_generator_nep2035
(
  un_id serial NOT NULL, 
  re_id integer, 
  conv_id integer,
  aggr_id_pf integer, 
  aggr_id_ms integer, 
  geom geometry(Point,4326),
  CONSTRAINT generators_total_nep2035_pkey PRIMARY KEY (un_id)
);

--ALTER TABLE model_draft.ego_supply_generator_nep2035
--	OWNER TO oeuser;
	

DROP INDEX IF EXISTS model_draft.ego_supply_generator_nep2035_idx;

INSERT INTO model_draft.ego_supply_generator_nep2035 (re_id, geom) 
	SELECT id, geom
	FROM model_draft.ego_supply_res_powerplant_2035
	WHERE geom IS NOT NULL; 


INSERT INTO model_draft.ego_supply_generator_nep2035 (conv_id, geom) 
	SELECT gid, geom
	FROM model_draft.ego_supply_conv_powerplant_2035 d
	WHERE d.rated_power_b2035>0 AND d.geom IS NOT NULL; -- Include only powerplants running in 2035 
 
CREATE INDEX generators_nep2035_idx
  ON model_draft.ego_supply_generator_nep2035
  USING gist
  (geom);


-- Update table on conventional power plants and add information on unified id of generators and information of relevant bus


-- Identify corresponding bus with the help of grid districts

UPDATE model_draft.ego_supply_conv_powerplant_2035 a
	SET subst_id = b.subst_id
	FROM model_draft.ego_grid_mv_griddistrict b
	WHERE ST_Intersects (a.geom, ST_TRANSFORM(b.geom,4326))  AND a.voltage_level >= 3; 

-- Identify corresponding bus with the help of ehv-Voronoi

UPDATE model_draft.ego_supply_conv_powerplant_2035 a
	SET subst_id = b.subst_id
	FROM model_draft.ego_grid_ehv_substation_voronoi b
	WHERE ST_Intersects (a.geom, b.geom) =TRUE AND a.voltage_level <= 2;

-- Insert otg_id of bus

UPDATE model_draft.ego_supply_conv_powerplant_2035 a
	SET otg_id =b.otg_id 
	FROM model_draft.ego_grid_hvmv_substation b
	WHERE a.subst_id = b.subst_id;

 
-- Update un_id from generators_total  

UPDATE model_draft.ego_supply_conv_powerplant_2035 a
	SET un_id = b.un_id 
	FROM model_draft.ego_supply_generator_nep2035 b
	WHERE a.gid = b.conv_id; 



-- Insert generator data into powerflow schema, that contains all generators seperately with scn_name = 'NEP 2035' 


DELETE FROM model_draft.ego_supply_pf_generator_single WHERE scn_name = 'NEP 2035';

INSERT INTO model_draft.ego_supply_pf_generator_single (scn_name, generator_id)
	SELECT 'NEP 2035', un_id
	FROM model_draft.ego_supply_generator_nep2035
	WHERE conv_id NOT IN 
		(SELECT a.gid 
		  FROM model_draft.ego_supply_conv_powerplant_2035 a
		  WHERE a.fuel= 'pumped_storage'
		)
	 OR re_id IS NOT NULL; -- pumped storage units are ignored here and will be listed in storage table 



-- Update table on renewable power plants and add information on unified id of generators and information of relevant bus



-- Identify corresponding bus with the help of grid districts

UPDATE model_draft.ego_supply_res_powerplant_2035 a
	SET subst_id = b.subst_id
	FROM	model_draft.ego_grid_mv_griddistrict b
	WHERE ST_Intersects (a.geom, ST_TRANSFORM(b.geom,4326)) AND voltage_level >= 3;  

-- Identify corresponding bus with the help of ehv-Voronoi

UPDATE model_draft.ego_supply_res_powerplant_2035 a
	SET subst_id = b.subst_id
	FROM model_draft.ego_grid_ehv_substation_voronoi b
	WHERE ST_Intersects (a.geom, b.geom) AND voltage_level <= 2; 


-- Identify net connection points for offshore wind parks by comparing id with Status Quo scenario 

UPDATE model_draft.ego_supply_res_powerplant_2035 a
	SET otg_id = 26435
	WHERE a.id IN 
(SELECT id FROM model_draft.ego_supply_res_powerplant
	  WHERE eeg_id LIKE '%%DYSKE%%' 
	  OR eeg_id LIKE '%%BUTENDIEK%%' 
	  OR eeg_id LIKE '%%NORDSEEOST%%'
	  OR eeg_id LIKE '%%NordseeOst%%'
	  OR eeg_id LIKE '%%MEERWINDSUEDOST%%'
	  OR eeg_id LIKE '%%AMRWE%%');


UPDATE model_draft.ego_supply_res_powerplant_2035 a
	SET otg_id = 27153 
	WHERE a.id IN 
(SELECT id FROM model_draft.ego_supply_res_powerplant
	  WHERE eeg_id LIKE '%%BAOEE%%');


UPDATE model_draft.ego_supply_res_powerplant_2035 a
	SET otg_id = 24401 
	WHERE a.id IN 
(SELECT id FROM model_draft.ego_supply_res_powerplant
	  WHERE eeg_id LIKE '%%BALTIC%%');


UPDATE model_draft.ego_supply_res_powerplant_2035 a
	SET otg_id = 26504
	WHERE a.id IN 
(SELECT id FROM model_draft.ego_supply_res_powerplant
	  WHERE eeg_id LIKE '%%RIFFE%%' 
	  OR eeg_id LIKE '%%BRGEE%%' 
	  OR eeg_id LIKE '%%BOWZE%%' 
	  OR eeg_id LIKE '%%GLTEE%%'
	  OR eeg_id LIKE '%%ALPHAVENTUE%%'
	  OR eeg_id LIKE '%%GOWZE%%');

-- Connect future offshore wind parks to existing Status Quo buses manually (this manual adjustment is not valid for future versions of the data set)

UPDATE model_draft.ego_supply_res_powerplant_2035 a
	SET otg_id = 26359 
 	WHERE id IN (10147069, 10147070, 10147066, 10147072, 10147067); 

UPDATE model_draft.ego_supply_res_powerplant_2035 a
	SET otg_id = 26920 
 	WHERE id IN (10147071, 10147068, 10147075); 

UPDATE model_draft.ego_supply_res_powerplant_2035 a
	SET otg_id = 26297 
 	WHERE id IN (10147073, 10147074, 10147065, 10147064); 

UPDATE model_draft.ego_supply_res_powerplant_2035 a
	SET otg_id = 24372 
 	WHERE id = 10147076;

-- Connect powerplants with voltage_level >=3 outside the grid district area to their nearest hv/mv-substation 

Update model_draft.ego_supply_res_powerplant_2035 as C
set otg_id   = sub.otg_id,
    subst_id = sub.subst_id  
FROM(
	SELECT B.subst_id,
	       B.otg_id,
		(SELECT A.id                        
		
		FROM model_draft.ego_supply_res_powerplant_2035 A
                WHERE A.subst_id IS NULL 
                AND A.voltage_level >= 3	    
		ORDER BY B.point <#> A.geom LIMIT 1)
	FROM model_draft.ego_grid_hvmv_substation B
) as sub
WHERE C.id = sub.id 
;


-- Insert otg_id of bus

UPDATE model_draft.ego_supply_res_powerplant_2035 a
	SET otg_id =b.otg_id 
	FROM model_draft.ego_grid_hvmv_substation b
	WHERE a.subst_id = b.subst_id; 


-- Update un_id from generators_total 

UPDATE model_draft.ego_supply_res_powerplant_2035 a
	SET un_id = b.un_id 
	FROM model_draft.ego_supply_generator_nep2035 b
	WHERE a.id = b.re_id; 


-- Insert generator data into powerflow schema, that contains all generators seperately 


-- For conventional generators

UPDATE model_draft.ego_supply_pf_generator_single a
	SET bus = b.otg_id, 
		p_nom = b.rated_power_b2035, 
		control = 'PV',  -- For generators with a capacity 50 MW or more control is set to PV
		source = result.source
		FROM 
			(SELECT c.source_id as source, d.fuel as fuel
			FROM 	model_draft.ego_grid_pf_hv_source c, 
				model_draft.ego_supply_conv_powerplant_2035 d 
			WHERE	d.rated_power_b2035>0 AND d.fuel = c.name) 
			AS 	result,		
			model_draft.ego_supply_conv_powerplant_2035 b
WHERE a.scn_name = 'NEP 2035' AND a.generator_id = b.un_id and b.rated_power_b2035 >= 50 AND result.fuel = b.fuel;


UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	bus = b.otg_id, 
		p_nom = b.rated_power_b2035,
		control = 'PQ', -- For generators with a capacity less than 50 MW control is set to PQ
		source = result.source
		FROM 
			( SELECT c.source_id as source, d.fuel as fuel 
			  FROM 	model_draft.ego_grid_pf_hv_source c, 
			       	model_draft.ego_supply_conv_powerplant_2035 d
			  WHERE	d.fuel = c.name) 
			AS 	result,		
				model_draft.ego_supply_conv_powerplant_2035 b
WHERE scn_name = 'NEP 2035' AND a.generator_id = b.un_id AND b.rated_power_b2035 < 50 AND result.fuel = b.fuel;

-- For renewables 

UPDATE model_draft.ego_supply_pf_generator_single a
	SET 	bus = b.otg_id, 
		p_nom = b.electrical_capacity/1000, -- unit for capacity in RE-register is kW
		dispatch = 'variable',
		control = 'PQ' -- For RE generators control is set to PQ
		FROM model_draft.ego_supply_res_powerplant_2035 b
WHERE scn_name = 'NEP 2035' AND a.generator_id = b.un_id;


UPDATE model_draft.ego_supply_pf_generator_single a
	SET source = result.source
		FROM 
			(SELECT c.source_id as source, d.un_id as un_id
			  FROM 	model_draft.ego_grid_pf_hv_source c, 
			       	model_draft.ego_supply_res_powerplant_2035 d
			  WHERE	d.generation_type = c.name) 
			  AS 	result, model_draft.ego_supply_res_powerplant_2035 b
WHERE scn_name = 'NEP 2035' AND a.generator_id = b.un_id AND a.generator_id = result.un_id; 

-- Control is changed to PV for biomass powerplants > 50 MW

UPDATE model_draft.ego_supply_pf_generator_single 
	SET control = 'PV'
	 
		FROM 
			(SELECT source_id as id
			 FROM model_draft.ego_grid_pf_hv_source a
			 WHERE a.name ='biomass')
		
		AS result  
WHERE scn_name = 'NEP 2035' AND p_nom > 50 AND source = result.id;


-- Identify weather point IDs for each generator


UPDATE model_draft.ego_supply_pf_generator_single a
	SET w_id = b.id
		FROM 
			(SELECT c.un_id, c.geom 
			 FROM model_draft.ego_supply_generator_nep2035 c)
			AS result,
		model_draft.renpassgis_economic_weatherpoint_voronoi b 
WHERE scn_name = 'NEP 2035' AND ST_Intersects (result.geom, b.geom) AND generator_id = result.un_id;



-- source = (wind and solar) and p_nom < 50 MW

UPDATE model_draft.ego_supply_pf_generator_single a
	SET aggr_id = result.aggr_id
		FROM 
			(SELECT b.bus, b.w_id, b.source, nextval('model_draft.ego_supply_pf_generator_single_aggr_id') as aggr_id
			FROM model_draft.ego_supply_pf_generator_single b 
			WHERE scn_name = 'NEP 2035' AND p_nom < 50 AND source IN 
				(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar') 
			GROUP BY bus, w_id, source)
			as result
	WHERE scn_name = 'NEP 2035' AND a.bus = result.bus AND a.w_id = result.w_id AND a.source = result.source;

-- source != (wind and solar) and p_nom < 50 MW 
	
UPDATE model_draft.ego_supply_pf_generator_single a
	SET aggr_id = result.aggr_id
		FROM 
			(SELECT b.bus, b.source, nextval('model_draft.ego_supply_pf_generator_single_aggr_id') as aggr_id
			FROM model_draft.ego_supply_pf_generator_single b 
			WHERE scn_name = 'NEP 2035' AND p_nom < 50 AND source NOT IN 
				(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar')
			GROUP BY b.bus, b.source)
			as result
	WHERE scn_name = 'NEP 2035' AND a.bus = result.bus AND a.source = result.source;

-- all sources and p_nom >= 50MW

UPDATE model_draft.ego_supply_pf_generator_single a
	SET aggr_id = nextval('model_draft.ego_supply_pf_generator_single_aggr_id')
	WHERE scn_name = 'NEP 2035' AND a.p_nom >= 50;

-- Accumulate data from pf_generator_single and insert into hv_powerflow schema. 

DELETE FROM model_draft.ego_grid_pf_hv_generator WHERE scn_name = 'NEP 2035'; 

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
  source
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
  min(p_min_pu_fixed),
  max(p_max_pu_fixed),
  max(sign),
  source
FROM model_draft.ego_supply_pf_generator_single a
WHERE scn_name = 'NEP 2035' AND a.p_nom < 50 AND a.aggr_id IS NOT NULL AND source IN 
	(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar')
GROUP BY a.aggr_id, a.bus, a.w_id, a.source, a.scn_name;

-- source != (wind and solar) and p_nom < 50 MW 
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
  source
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
  min(p_min_pu_fixed),
  max(p_max_pu_fixed),
  max(sign),
  source
FROM model_draft.ego_supply_pf_generator_single a
WHERE scn_name = 'NEP 2035' AND a.p_nom < 50 AND a.aggr_id IS NOT NULL AND source NOT IN 
	(SELECT source_id from model_draft.ego_grid_pf_hv_source WHERE name = 'wind' OR name = 'solar')
	
GROUP BY a.aggr_id, a.bus, a.source, a.scn_name;

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
  source
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
  p_min_pu_fixed,
  p_max_pu_fixed,
  sign,
  source
FROM model_draft.ego_supply_pf_generator_single a
WHERE scn_name = 'NEP 2035' AND a.p_nom >= 50 AND a.aggr_id IS NOT NULL;

DELETE FROM model_draft.ego_supply_pf_generator_single WHERE aggr_id IS NULL AND scn_name= 'NEP 2035';
