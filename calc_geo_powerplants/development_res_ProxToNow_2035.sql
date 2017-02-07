/*

SQL Script which implements methods of development and allocation renewable energy units in germany by future scenarios.

__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"


--- ------------------------------------------------------------------------------------------------------------

1. Methodes of development of each type of generation:

	solar -> own methode per municipality

	wind_onshore -> by own methode ProxToNow per municipality  
	
	extention of wind_onshore -> by potental areas (Martin)
       

	geothermal -> status quo, no changes
	
	hydro -> (run_of_river + reservoir) merched small and large  (ATTENTION!!!)
		  size plants together. New capacity per unit proToNow per federal state assumption.
		  No changes of voltage level. 
		  
	biomass -> New capacity per unit proToNow per federal state assumption.
		   No changes of voltage level. 
		   
	wind_offshore -> by NEP data insert from literature 
--- ------------------------------------------------------------------------------------------------------------

1.1 Formular:

    ProxToNow:
     P_inst(unit)/P_sum(federal state) * P_scn(Federal state)



--- ------------------------------------------------------------------------------------------------------------

ToDo: KWK Kleinstanlagen von Mario einbinden
      DEA Verteilung für Szenariodaten durchführen
      Script 2050 anpassen
      Name der neuen DB Struktur anpassen

New DB structure tables:
* political_boundary.bkg_vg250_2_lan
* supply.
* supply.
* model_draft.scenario_...

Namenskonvention:
 < modell >< zielschema >< untermodell >< voltagelevel >< tabelle >
z.B.  model_draft.ego_grid_pf_hv_transformer
      
*/
-- Test of existens and completeness of tables
SELECT * FROM  orig_geo_vg250.vg250_2_lan Limit 1;
SELECT * FROM  orig_geo_vg250.vg250_2_lan_nuts_view Limit 1;
SELECT * FROM  model_draft.ego_supply_res_powerplant_2035 Limit 1;
SELECT * FROM  political_boundary.bkg_vg250_2_lan Limit 1;
SELECT * FROM  orig_scenario_data.nep_2015_scenario_capacities Limit 1;
SELECT * FROM  orig_geo_powerplants.proc_power_plant_germany Limit 1;
/*
DROP TABLE model_draft.ego_supply_res_powerplant_2035 CASCADE;
DROP TABLE model_draft.ego_supply_pv_dev_2035_germany_mun CASCADE;
DROP TABLE model_draft.ego_supply_res_powerplant_germany_to_region CASCADE;
DROP SEQUENCE model_draft.ego_supply_pv_dev_2035_germany_mun_id_seq CASCADE;
DROP SEQUENCE orig_geo_powerplants.wo_dev_nep_germany_mun_id_seq CASCADE;
*/
--- Data and Scenario Test
SELECT
  sum(electrical_capacity),
  count(*),
--  generation_subtype,
  generation_type
FROM
  model_draft.ego_supply_res_powerplant_2035 
Group by generation_type
        -- ,generation_subtype
;
--- ------------------------------------------------------------------------------------------------------------
-- Create view with nuts id and polygones for federal states
---
/*
CREATE MATERIALIZED VIEW orig_geo_vg250.vg250_2_lan_nuts_view AS 
  SELECT lan.ags_0,
    lan.gen,
    lan.nuts,
    st_union(st_transform(lan.geom, 3035)) AS geom
   FROM ( SELECT vg.ags_0,
             vg.nuts,
            replace(vg.gen::text, ' (Bodensee)'::text, ''::text) AS gen,
            vg.geom
           FROM orig_geo_vg250.vg250_2_lan vg) lan
  GROUP BY lan.ags_0, lan.gen,lan.nuts
  ORDER BY lan.ags_0
WITH DATA;


--Q: is GRANT needed anymore?
-- Grant on view
ALTER TABLE orig_geo_vg250.vg250_2_lan_nuts_view
  OWNER TO oeuser;
GRANT ALL ON TABLE orig_geo_vg250.vg250_2_lan_nuts_view TO oeuser WITH GRANT OPTION;

--- Hot Fix
CREATE INDEX vg250_6_gem_clean_idx
  ON orig_geo_vg250.vg250_6_gem_clean
  USING gist
  (geom);
--
CREATE INDEX vg250_2_lan_nuts_view_idx
  ON orig_geo_vg250.vg250_2_lan_nuts_view
  USING gist
  (geom);
--
*/

--- ------------------------------------------------------------------------------------------------------------
---- Create new Table for NEP Scenario
----

-- Drop Table model_draft.ego_supply_res_powerplant_2035 CASCADE;

CREATE TABLE model_draft.ego_supply_res_powerplant_2035
(
  id bigint NOT NULL,                            -- id given by proc_renewable_power_plants_germany
  scenario_year integer,                         -- year of scenario       
  electrical_capacity numeric,                   -- electrical capacity in kW
  generation_type text, 			 -- generaion type	
  generation_subtype character varying,          -- generation subtype 
  thermal_capacity numeric,                      -- thermal capacity of chp biomass, starting from August 2015
  nuts character varying,            	   	 -- nuts id
  lon numeric,                       		 -- lon from source
  lat numeric,                      		 -- lat from source
  voltage_level smallint,          		 -- voltage level from 1 till 7
  network_node character varying,  		 -- name of network node if exist from source
  source character varying,          		 -- source name
  comment character varying,        		 -- own comments
  geom geometry(Point,4326),        		 -- geom 
  voltage character varying,        		 -- voltage in kV calculated, partly not finished
  subst_id bigint,                  		 -- id of associated substation
  otg_id bigint,                    		 -- otg_id of associated substation 
  un_id bigint,                     		 -- unified id for res and conv powerplants   
  CONSTRAINT ego_supply_res_powerplant_2035_pkey PRIMARY KEY (id)
);

-- Set Grant and index

CREATE INDEX ego_supply_res_powerplant_2035_idx
  ON model_draft.ego_supply_res_powerplant_2035
  USING gist
  (geom);

ALTER TABLE model_draft.ego_supply_res_powerplant_2035
  OWNER TO oeuser;
  
GRANT ALL ON TABLE model_draft.ego_supply_res_powerplant_2035 TO oeuser;


--- # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
-- Biomass power plants
---

INSERT INTO model_draft.ego_supply_res_powerplant_2035
SELECT
  id, 				-- 
  2035 AS scenario_year, 	-- 
  electrical_capacity ,  	-- 
  generation_type ,		-- 
  generation_subtype,   	-- 
  thermal_capacity, 		-- 
  NULL AS nuts,			-- 
  lon,  			-- 
  lat, 				-- 
  voltage_level,   		-- 
  network_node, 		--
  source,  		        -- 
  comment,  			--
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'biomass';

--- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
-- 	Set nuts per unit. Use Buffer for units at the German Border 
--- 
UPDATE model_draft.ego_supply_res_powerplant_2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(ST_Transform(upt.geom, 3035), regions.geom)
;
--- Use Buffer 1 km for units at the German Border 
UPDATE model_draft.ego_supply_res_powerplant_2035 as upt
set nuts = regions.nuts
FROM
orig_geo_vg250.vg250_2_lan_nuts_view as regions,
(
SELECT *
FROM 
  model_draft.ego_supply_res_powerplant_2035
WHERE nuts is Null
) as aa
WHERE ST_Intersects(ST_Transform(aa.geom, 3035), ST_Buffer(regions.geom,1000))
AND upt.id = aa.id;
;
-- 
-- Check Biomass by nuts id 
SELECT
  nuts,
  count(id),
  sum(electrical_capacity)
FROM
 model_draft.ego_supply_res_powerplant_2035 
GROUp by nuts;

--- ------------------------------------------------------------------------------------------------------------
-- Biomass Methode
-- increase installed capacity by NEP scenario data
-- No changes of voltage level
--

UPDATE model_draft.ego_supply_res_powerplant_2035 as upt
set comment = upt.comment || ', Method ProxToNow Biomass',
    source = 'open_ego NEP 2015 B2035',
    electrical_capacity = CASE WHEN scn.capacity = 0 THEN 0 
	  ELSE (upt.electrical_capacity/ cap_sum)*scn.capacity*1000    
	 END 
FROM
  orig_scenario_data.nep_2015_scenario_capacities as scn,
  (SELECT nuts, sum(electrical_capacity) as cap_sum
   FROM model_draft.ego_supply_res_powerplant_2035
   WHERE generation_type = 'biomass' Group by nuts
   ) count
WHERE scn.nuts = count.nuts 
AND   scn.nuts = upt.nuts 
AND   upt.nuts = count.nuts
AND   scn.generation_type = 'biomass' ;

--- ------------------------------------------------------------------------------------------------------------
-- Geothermal Methode 
--   No changes set status quo
--
INSERT INTO model_draft.ego_supply_res_powerplant_2035
SELECT
  id, 				--
  2035 AS scenario_year, 	--
  electrical_capacity ,  	-- in kW
  generation_type ,		--
  generation_subtype,   	--
  thermal_capacity, 		--
  NULL AS nuts,			-- nuts id of federal state
  lon,  			--
  lat, 				--	
  voltage_level,   		-- 
  network_node, 		--
  source,  		        -- orignal source name
  comment,  			-- Own comment
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'geothermal';

-- 
UPDATE model_draft.ego_supply_res_powerplant_2035
set comment = comment || ', No changes status quo'
WHERE generation_type = 'geothermal';
--

UPDATE model_draft.ego_supply_res_powerplant_2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(ST_Transform(upt.geom, 3035), regions.geom)
AND generation_type = 'geothermal'
;

--- ------------------------------------------------------------------------------------------------------------
-- Hydro / run_of_river
-- Insert large Hydro reservoir and run_of_river units from status Quo 
-- because of missing entries in NEP KW list
--

INSERT INTO model_draft.ego_supply_res_powerplant_2035
SELECT
  9000000+row_number() over (ORDER BY gid) as id,        -- create new ID
  2035 AS scenario_year, 			  
  capacity*1000 as electrical_capacity ,  	         -- in kW
  fuel as generation_type ,		 
  fuel as generation_subtype,   	 
  NULL as thermal_capacity, 		 
  NULL AS nuts,			
  lon,  		
  lat, 				
  voltage_level,   		
  network_node, 	
  'OPSD powerplant list' as source,  	                 -- orignal source name
  'add Hydro plants from conventional list' as comment,  -- Own comment
  geom,  		
  voltage,  			
  subst_id,  			
  otg_id,  			
  un_id				
FROM
  orig_geo_powerplants.proc_power_plant_germany
WHERE
fuel = 'reservoir'
OR fuel = 'run_of_river';
--
-- Insert 
--
INSERT INTO model_draft.ego_supply_res_powerplant_2035
SELECT
  id, 				--
  2035 AS scenario_year, 	--
  electrical_capacity ,  	-- in kW
  generation_type ,		--
  generation_type as generation_subtype,   	--
  thermal_capacity, 		--
  NULL AS nuts,			-- nuts id of federal state
  lon,  			--
  lat, 				--	
  voltage_level,   		-- 
  network_node, 		--
  source,  		        -- orignal source name
  comment,  			-- Own comment
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'run_of_river';

--
Update model_draft.ego_supply_res_powerplant_2035
set  generation_type = 'hydro'
Where generation_type = 'reservoir'
OR  generation_type = 'run_of_river'; 

-- DELETE FROM model_draft.ego_supply_res_powerplant_2035 WHERE generation_type = 'hydro';

-- set nuts
UPDATE model_draft.ego_supply_res_powerplant_2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(ST_Transform(regions.geom, 4326), upt.geom)
AND generation_type = 'hydro'
;
--- Fill emty nuts values by buffer
--
UPDATE model_draft.ego_supply_res_powerplant_2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(St_Buffer(upt.geom,0.02), ST_Transform(regions.geom, 4326))
AND upt.nuts  IS NULL
AND generation_type = 'hydro';
--
--
UPDATE model_draft.ego_supply_res_powerplant_2035 
set nuts = 'AT'
WHERE nuts  IS NULL AND generation_type = 'hydro';

--

UPDATE model_draft.ego_supply_res_powerplant_2035 as upt
set comment = upt.comment || ', Method ProxToNow Hydro',
    source = 'open_ego NEP 2015 B2035',
    electrical_capacity = CASE WHEN scn.capacity = 0 THEN upt.electrical_capacity
	  ELSE (upt.electrical_capacity/ cap_sum)*scn.capacity*1000    
	 END 
FROM
  orig_scenario_data.nep_2015_scenario_capacities as scn,
  (SELECT nuts, sum(electrical_capacity) as cap_sum
   FROM model_draft.ego_supply_res_powerplant_2035
   WHERE generation_type = 'hydro' Group by nuts
   ) count
WHERE scn.nuts = count.nuts 
AND   scn.nuts = upt.nuts 
AND   upt.nuts = count.nuts
AND   scn.generation_type = 'hydro' 
AND   upt.generation_type = 'hydro';

--- ------------------------------------------------------------------------------------------------------------
-- Gas Methode
-- No changes yet
--  ToDo: small CHP units

INSERT INTO model_draft.ego_supply_res_powerplant_2035
SELECT
  id, 				--
  2035 AS scenario_year, 	--
  electrical_capacity ,  	--
  generation_type ,		--
  generation_subtype,   	--
  thermal_capacity, 		--
  NULL AS nuts,			-- 
  lon,  			--
  lat, 				--	
  voltage_level,   		-- 
  network_node, 		--
  source,  		        -- 
  comment,  			-- 
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'gas';

-- set nuts

UPDATE model_draft.ego_supply_res_powerplant_2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(ST_Transform(regions.geom, 4326), upt.geom)
AND generation_type = 'gas';

/*
SELECT
round(sum(electrical_capacity)/1000,2)
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'gas';
*/

--- ------------------------------------------------------------------------------------------------------------
-- PV Methode 
--
/*

Step 0 Get Nuts id per Unit 
Step 1 capacity per municipality -> ProToNow
       Status Quo
Step 2 Structure of PV ( volatage level, size, Number)
Step 3 add new PV at center of municipality polygon
Step 4 add volatage level, etc.
*/

-- Drop Table model_draft.ego_supply_res_powerplant_germany_to_region CASCADE;

Create Table model_draft.ego_supply_res_powerplant_germany_to_region
(
re_id bigint NOT NULL,   	-- id from proc_renewable_power_plants_germany
subst_id bigint,      		-- substation ID
otg_id bigint,        		-- 
un_id bigint,         		--   
nuts character varying(5),	-- Nuts key for districts 
rs_0 character varying(12),	-- German Regionalschlüssel
id_vg250 bigint, 		-- ID of orig_geo_vg250.vg250_6_gem_clean table
CONSTRAINT ego_supply_res_powerplant_germany_to_region_pkey PRIMARY KEY (re_id)
);
--
ALTER TABLE model_draft.ego_supply_res_powerplant_germany_to_region
  OWNER TO oeuser;
  
GRANT ALL ON TABLE model_draft.ego_supply_res_powerplant_germany_to_region TO oeuser WITH GRANT OPTION;
GRANT ALL ON TABLE model_draft.ego_supply_res_powerplant_germany_to_region TO oerest WITH GRANT OPTION;

--- ---------------------------------------------------------------------------
-- DELETE FROM model_draft.ego_supply_res_powerplant_germany_to_region;

INSERT INTO model_draft.ego_supply_res_powerplant_germany_to_region (re_id,subst_id,otg_id,un_id)
SELECT
id as re_id,
subst_id,
otg_id,
un_id
FROM
orig_geo_powerplants.proc_renewable_power_plants_germany;


--
Update model_draft.ego_supply_res_powerplant_germany_to_region A
set id_vg250 = B.id,
    rs_0 = B.rs_0,
    nuts = B.nuts
FROM (
	SELECT
	D.id as re_id,
	C.id,
	C.rs_0,
	C.nuts    
	FROM orig_geo_vg250.vg250_6_gem_clean C,
	     orig_geo_powerplants.proc_renewable_power_plants_germany D
	WHERE ST_Intersects(ST_Transform(C.geom, 4326), D.geom)
      ) as B
WHERE B.re_id = A.re_id;
---
--- Check 
-- time log = 2:00 h 
-- new time log = 12:55 minutes

SELECT
count(*)
FROM model_draft.ego_supply_res_powerplant_germany_to_region 
WHERE nuts IS NULL;

-- Get nuts ID by buffering geometry 
-- ToDo noch mal ausführen!
Update model_draft.ego_supply_res_powerplant_germany_to_region A
set id_vg250 = C.id,
    rs_0 = C.rs_0,
    nuts = C.nuts
FROM
   (
	SELECT
	  A.re_id,
	  B.geom
	FROM
	model_draft.ego_supply_res_powerplant_germany_to_region A,
	orig_geo_powerplants.proc_renewable_power_plants_germany B
	WHERE A.re_id = B.id
	AND A.nuts IS NULL 
  ) as AA,
  orig_geo_vg250.vg250_6_gem_clean C
WHERE ST_Intersects(ST_Transform(C.geom, 4326), ST_Buffer(AA.geom,10))
AND AA.re_id = A.re_id;

--- Check  
-- time log local  = 02:40:7214 hours execution time
-- time log server:  02:45:7236 hours execution time.
--- ------------------------------------------------------------------------------------------------------------
--   Status Quo PV

-- DROP SEQUENCE model_draft.ego_supply_pv_dev_2035_germany_mun_id_seq;
CREATE SEQUENCE model_draft.ego_supply_pv_dev_2035_germany_mun_id_seq START 1;

-- DROP TABLE model_draft.ego_supply_pv_dev_2035_germany_mun CASCADE;

Create Table model_draft.ego_supply_pv_dev_2035_germany_mun
(
id bigint NOT NULL DEFAULT nextval('model_draft.ego_supply_pv_dev_2035_germany_mun_id_seq'::regclass),-- own id PK 
pv_units integer,      		-- number of PV units per mun and voltage level 
pv_cap_2014 integer,        	-- sum per region of 2014 in kW 
pv_add_cap_2035 integer,        -- sum per region of additional Capacity in 2035 kW 
voltage_level smallint,        	-- voltage_level from 1-7   
rs_0 character varying(12),	-- German Regionalschlüssel
pv_avg_cap integer, 		-- average capacity per region and voltage level
pv_new_units numeric(9,2), 	-- New number of region per voltage level 
CONSTRAINT pv_dev_nep_germany_mun_pkey PRIMARY KEY (id)
);
--

Insert into model_draft.ego_supply_pv_dev_2035_germany_mun (pv_units,pv_cap_2014,voltage_level,rs_0,pv_avg_cap)
SELECT
  count(A.*) as pv_units,
  sum(A.electrical_capacity) as pv_cap_2014,
  A.voltage_level,
  B.rs_0,
  avg(A.electrical_capacity) as pv_avg_cap
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany A, 
  orig_geo_vg250.vg250_6_gem_clean B
WHERE
  ST_Intersects(ST_Transform(B.geom, 4326), A.geom)
AND A.generation_type = 'solar'
Group by A.voltage_level, B.id, B.rs_0;
-- time log local:  03:11 minutes 

--- ------------------------------------------------------------------------------------------------------------
-- PV ProxToNow per municipality and voltage level
---
/*
UPDATE model_draft.ego_supply_pv_dev_2035_germany_mun
 set     pv_add_cap_2035 = NULL;


1. Pro Gemeinde Polygon werden die PV Anlagen 2014 pro Voltage level, Anzahl und installierter Leistung aufsummiert,
   Eine Durchschnittliche Anlage wird pro Gemeinde und Voltagelevel gebildet
	Gemeinden und voltage level die nicht betroffen sind, werden nicht mehr berücksichtigt
2. Der Zubau pro Gemeinde und voltage level wird Proportional zu 2014 anhand der NEP 2035 Szenariodaten gebildet
   Formel P_add(Gemeinde,Voltage Level, 2035) =  (P_sum(Gemeinde,Voltage Level, 2014)/ P_sum(Bundesland,2014) 
						 ) x P_sum(Bundesland,2035) - P_sum(Gemeinde,Voltage Level, 2014)

3. Anhand der Zubauzahlen pro Gemeinde und voltage level wird die Anzahl neuer Anlagen anhand der durchschnittlichen
   Größe (kW) gebildet.

4. Die Status Quo Daten werden in model_draft.ego_supply_res_powerplant_2035 überführt

5. Die neuen Anlagen werden anhand des Mittelpunktes der Gemeinde in model_draft.ego_supply_res_powerplant_2035 
   hinzugefügt
   
6. Übergabe an weiten Skript zur Zuweisung der Netzknoten
               

*/


UPDATE model_draft.ego_supply_pv_dev_2035_germany_mun AA
set     pv_add_cap_2035 = ( (AA.pv_cap_2014::numeric / pv_sq_2014.fs_cap_2014::numeric)*pv_scn_2035.fs_cap_2035 
                             -AA.pv_cap_2014)::integer
                              
FROM
(
SELECT
 substring(A.rs_0 from 1 for 2) as rs,        -- Regionalschlüssel first 2 numbers = federal state
 scn.capacity*1000 as fs_cap_2035 ,           -- in kW
 scn.nuts  				      -- nuts code federal state
 FROM
   orig_geo_vg250.vg250_6_gem_clean A,
    orig_scenario_data.nep_2015_scenario_capacities scn
WHERE scn.nuts = substring(A.nuts from 1 for 3)
AND   scn.generation_type = 'solar' 
Group by substring(A.nuts from 1 for 3),rs,scn.capacity,scn.nuts
) as pv_scn_2035,
(
SELECT
   substring(A.rs_0 from 1 for 2) as rs,        -- Regionalschlüssel first 2 numbers = federal state
   sum(A.pv_cap_2014) as fs_cap_2014            -- in kW
FROM
  model_draft.ego_supply_pv_dev_2035_germany_mun A
Group by  substring(A.rs_0 from 1 for 2) 
) as pv_sq_2014
Where pv_scn_2035.rs = pv_sq_2014.rs
AND substring(AA.rs_0 from 1 for 2) =  pv_sq_2014.rs
AND substring(AA.rs_0 from 1 for 2) =  pv_scn_2035.rs
;


--- ------------------------------------------------------------------------------------------------------------
-- Count new additional Units -> new_units

UPDATE model_draft.ego_supply_pv_dev_2035_germany_mun AA
set     pv_new_units =  round(pv_add_cap_2035/pv_avg_cap); 

-- Controll PV development 

SELECT
substring(A.rs_0 from 1 for 2)  rs_fs,       		-- fs ID
SUM(A.pv_add_cap_2035)/1000 pv_add_cap_2035, 		-- additional Capacity in MW
sum(A.pv_cap_2014)/1000  pv_cap_2014,          		-- capacity 2014 im MW
scn.capacity_2035,                           		-- Scenario capacity 2035 in MW
(SUM(A.pv_add_cap_2035) +sum(A.pv_cap_2014))/1000 total -- in MW
FROM
 (
SELECT
  scn.nuts,
  substring(AA.rs_0 from 1 for 2) as rs,
  scn.capacity as capacity_2035,
  scn.generation_type
FROM
  orig_geo_vg250.vg250_6_gem_clean AA,
  orig_scenario_data.nep_2015_scenario_capacities as scn
WHERE scn.nuts = substring(AA.nuts from 1 for 3)
AND  scn.generation_type = 'solar'
group by scn.nuts, substring(AA.rs_0 from 1 for 2), substring(AA.nuts from 1 for 3),
         scn.capacity,scn.generation_type
) as scn,
 model_draft.ego_supply_pv_dev_2035_germany_mun A
WHERE scn.rs = substring(rs_0 from 1 for 2)
Group by substring(rs_0 from 1 for 2),scn.capacity_2035;

--- ------------------------------------------------------------------------------------------------------------
-- Take status Quo and Add new PV plants 
-- Insert new units by pv_new_units 
-- geom = centroid of mun geom , see http://postgis.net/docs/ST_PointOnSurface.html
-- generation_subtype is not defined 

INSERT INTO model_draft.ego_supply_res_powerplant_2035
SELECT
  id, 				--
  2035 AS scenario_year, 	--
  electrical_capacity ,  	-- in kW
  generation_type ,		--
  generation_subtype,   	--
  thermal_capacity, 		--
  NULL AS nuts,			-- nuts id of federal state
  lon,  			--
  lat, 				--	
  voltage_level,   		-- 
  network_node, 		--
  source,  		        -- orignal source name
  comment,  			-- Own comment
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'solar';

-- set nuts
-- Hier weiter --
UPDATE model_draft.ego_supply_res_powerplant_2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(ST_Transform(regions.geom, 4326), upt.geom)
AND generation_type = 'solar';
-- time log local =  15:17:54047 hours
-- time log server = 10:32:36017 hours 


--- ------------------------------------------------------------------------------------------------------------
-- Add new PV units 
---
--
Insert into model_draft.ego_supply_res_powerplant_2035 (id,scenario_year,electrical_capacity,
generation_type, voltage_level, source, comment,geom)

	SELECT
	  sub2.max_rown + row_number() over () as id ,
	  2035  as scenario_year,
	  sub.electrical_capacity,
	  'solar'::text as generation_type,
	  sub.voltage_level,
	  'open_ego NEP 2015 B2035'::text as  source,
	  ', Method ProxToNow solar'::text as comment, 
	  sub.geom
	FROM (
	SELECT
	  A.rs_0,
	  A.voltage_level,
	  Case when A.pv_new_units = 0 Then A.pv_add_cap_2035
	       else  unnest(array_fill(A.pv_avg_cap, Array[(A.pv_new_units)::int])) END as electrical_capacity ,    -- in kW 
	 ST_Transform(ST_PointOnSurface(B.geom), 4326) as geom     
	FROM 
	  model_draft.ego_supply_pv_dev_2035_germany_mun A,
	  orig_geo_vg250.vg250_6_gem_clean B
	Where A.rs_0 = B.rs_0
	) as sub ,
	(Select
	 max(id) as max_rown
	 FROM
	  model_draft.ego_supply_res_powerplant_2035
	  ) as sub2
;
-- log time local: 06:39 minutes
 
--- ------------------------------------------------------------------------------------------------------------
--  Offshore Wind 
--
-- Status Quo Data
INSERT INTO model_draft.ego_supply_res_powerplant_2035
SELECT
  id, 				--
  2035 AS scenario_year, 	--
  electrical_capacity ,  	-- 
  generation_type ,		--
  generation_subtype,   	--
  thermal_capacity, 		--
  NULL AS nuts,			-- 
  lon,  			--
  lat, 				--	
  voltage_level,   		-- 
  network_node, 		--
  source,  		        -- 
  comment,  			-- 
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'wind'
AND generation_subtype = 'wind_offshore';


-- Insert NEP 2015 wind offshore plants as big single offshore wind farm
--
/*
 INSERT INTO model_draft.ego_supply_res_powerplant_2035 (id, scenario_year, electrical_capacity,
             generation_type, generation_subtype, thermal_capacity, nuts, lon, lat, voltage_level, network_node, 
             source, comment, geom, voltage, subst_id, otg_id, un_id)

VALUES
(100000000, 2035, 840850, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Büttel', '0101000020E6100000AD05BE1A878A1B40003C769B02924B40', '380', NULL, NULL, NULL),
(200000000, 2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Segeberg', '0101000020E610000097549B90767B1940BD49396624894B40', '380', NULL, NULL, NULL),
(300000000, 2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Cloppenburg', '0101000020E6100000734ECF8CED571C40D2AE3F9F8B044B40', '380', NULL, NULL, NULL),
(400000000, 2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Cloppenburg', '0101000020E61000007B81CED535641940C088D9991E294B40', '380', NULL, NULL, NULL),
(500000000, 2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Cloppenburg', '0101000020E6100000760FAC97AC3D184000CF66EFA2204B40', '380', NULL, NULL, NULL),
(600000000, 2035, 1188400, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Dörpen West', '0101000020E610000044D62300A7711B400FE3B7CDB9034B40', '380', NULL, NULL, NULL),
(700000000, 2035, 1800000, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Emden Ost', '0101000020E610000083B2A1AEEAF91B40343FC1825E054B40', '380', NULL, NULL, NULL),
(800000000, 2035, 450000, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Unterweser', '0101000020E6100000BAF8659652801740D869CBBDC1284B40', '380', NULL, NULL, NULL),
(900000000, 2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Wilhelmshaven 2', '0101000020E610000033F5B4B394751940EA0712BD2E294B40', '380', NULL, NULL, NULL),
(1000000000, 2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Wilhelmshaven 2', '0101000020E6100000E75D445985E61740F70188073D684B40', '380', NULL, NULL, NULL),
(1100000000, 2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Wilhelmshaven 2', '0101000020E610000046E764017AE71840ADB08899CC684B40', '380', NULL, NULL, NULL),
(1200000000, 2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Halbemond', '0101000020E610000011DD88C5680E1940A8A8439C94004B40', '380', NULL, NULL, NULL),
(1300000000, 2035, 1585000, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 'NVP: Lubmin', '0101000020E6100000C396890D74072A404ADF5A5C48744B40', '380', NULL, NULL, NULL);

*/

-- 1
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id, 
    2035, 840850, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 
    'NVP: Büttel', '0101000020E6100000AD05BE1A878A1B40003C769B02924B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
 -- 2
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id , 
    2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Segeberg', '0101000020E610000097549B90767B1940BD49396624894B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
-- 3
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id , 
    2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Cloppenburg', '0101000020E6100000734ECF8CED571C40D2AE3F9F8B044B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
-- 4
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id , 
    2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Cloppenburg', '0101000020E61000007B81CED535641940C088D9991E294B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
-- 5
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id , 
    2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Cloppenburg', '0101000020E6100000760FAC97AC3D184000CF66EFA2204B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
-- 6
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id , 
    2035, 1188400, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Dörpen West', '0101000020E610000044D62300A7711B400FE3B7CDB9034B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
-- 7
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id , 
    2035, 1800000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Emden Ost', '0101000020E610000083B2A1AEEAF91B40343FC1825E054B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
-- 8
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id , 
    2035, 450000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Unterweser', '0101000020E6100000BAF8659652801740D869CBBDC1284B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
-- 9
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id , 
    2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Wilhelmshaven 2', '0101000020E610000033F5B4B394751940EA0712BD2E294B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
-- 10
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id , 
    2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Wilhelmshaven 2', '0101000020E6100000E75D445985E61740F70188073D684B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
-- 11
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id , 
    2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Wilhelmshaven 2', '0101000020E610000046E764017AE71840ADB08899CC684B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
-- 12
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id , 
    2035, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Halbemond', '0101000020E610000011DD88C5680E1940A8A8439C94004B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
--
INSERT INTO model_draft.ego_supply_res_powerplant_2035 
  SELECT
    max(id)+ row_number() over () as id , 
    2035, 1585000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Lubmin', '0101000020E6100000C396890D74072A404ADF5A5C48744B40', 
    '380', NULL, NULL, NULL
  FROM model_draft.ego_supply_res_powerplant_2035;
--
-- Check 
SELECT
 *
FROM
  model_draft.ego_supply_res_powerplant_2035
  WHERE generation_subtype = 'wind_offshore'
  AND scenario_year = 2035
  AND source = 'ONEP';

--- ------------------------------------------------------------------------------------------------------------
--  Onshore Wind 
--  
-- Use of "easy" ProxToNow

--- ------------------------------------------------------------------------------------------------------------
--   Status Quo Wind Onshore
-- Same methode as PV
--

-- DROP SEQUENCE orig_geo_powerplants.wo_dev_nep_germany_mun_id_seq;
CREATE SEQUENCE orig_geo_powerplants.wo_dev_nep_germany_mun_id_seq START 1;

-- DROP TABLE orig_geo_powerplants.wo_dev_nep_germany_mun CASCADE;

Create Table orig_geo_powerplants.wo_dev_nep_germany_mun
(
id bigint NOT NULL DEFAULT nextval('orig_geo_powerplants.wo_dev_nep_germany_mun_id_seq'::regclass), -- own id PK 
wo_units integer,      		-- number of onshore units per mun and voltage level 
wo_cap_2014 integer,        	-- sum per region of 2014 in kW 
wo_add_cap_2035 integer,        -- sum per region of additional Capacity in 2035 kW 
voltage_level smallint,        	-- voltage_level from 1-7   
rs_0 character varying(12),	-- German Regionalschlüssel
wo_avg_cap integer, 		-- average capacity per region and voltage level
wo_new_units numeric(9,2), 	-- New number of region per voltage level 
CONSTRAINT wo_dev_nep_germany_mun_pkey PRIMARY KEY (id)
);
--
Insert into orig_geo_powerplants.wo_dev_nep_germany_mun (wo_units,wo_cap_2014,voltage_level,rs_0,wo_avg_cap)
SELECT
  count(A.*) as wo_units,
  sum(A.electrical_capacity) as wo_cap_2014,
  A.voltage_level,
  B.rs_0,
  avg(A.electrical_capacity) as wo_avg_cap
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany A, 
  orig_geo_vg250.vg250_6_gem_clean B
WHERE
  ST_Intersects(ST_Transform(B.geom, 4326), A.geom)
AND A.generation_type = 'wind'
AND A.generation_subtype = 'wind_onshore'
Group by A.voltage_level, B.id, B.rs_0;
--
-- Time log server =  03:46:10806 hours
-- SELECT * FROM orig_geo_powerplants.wo_dev_nep_germany_mun LIMIT 10;

UPDATE orig_geo_powerplants.wo_dev_nep_germany_mun AA
set     wo_add_cap_2035 = ( (AA.wo_cap_2014::numeric / wo_sq_2014.fs_cap_2014::numeric)*wo_scn_2035.fs_cap_2035 
                             -AA.wo_cap_2014)::integer
                              
FROM
(
SELECT
 substring(A.rs_0 from 1 for 2) as rs,        -- Regionalschlüssel first 2 numbers = federal state
 scn.capacity*1000 as fs_cap_2035 ,           -- in kW
 scn.nuts  				      -- nuts code federal state
 FROM
    orig_geo_vg250.vg250_6_gem_clean A,
    orig_scenario_data.nep_2015_scenario_capacities scn
WHERE scn.nuts = substring(A.nuts from 1 for 3)
AND   scn.generation_type = 'wind_onshore' 
AND   scn.scenario_name ='B12035/B22035'
Group by substring(A.nuts from 1 for 3),rs,scn.capacity,scn.nuts
) as wo_scn_2035,
(
SELECT
   substring(A.rs_0 from 1 for 2) as rs,        -- Regionalschlüssel first 2 numbers = federal state
   sum(A.wo_cap_2014) as fs_cap_2014            -- in kW
FROM
  orig_geo_powerplants.wo_dev_nep_germany_mun A
Group by  substring(A.rs_0 from 1 for 2) 
) as wo_sq_2014
Where wo_scn_2035.rs = wo_sq_2014.rs
AND substring(AA.rs_0 from 1 for 2) =  wo_sq_2014.rs
AND substring(AA.rs_0 from 1 for 2) =  wo_scn_2035.rs
;
--
--- ------------------------------------------------------------------------------------------------------------
-- Count new additional Units -> new_units
-- Hot Fix data cleaning
DELETE FROM orig_geo_powerplants.wo_dev_nep_germany_mun WHERE wo_add_cap_2035 <=0;
--
UPDATE orig_geo_powerplants.wo_dev_nep_germany_mun AA
     set wo_new_units =  round(wo_add_cap_2035/wo_avg_cap); 
--
-- SELECT * FROM   orig_scenario_data.nep_2015_scenario_capacities WHERE generation_type = 'wind_onshore' Limit 20;
--
-- Controll wind onshore development 
SELECT
scn.state,
substring(A.rs_0 from 1 for 2)  rs_fs,       		-- fs ID
SUM(A.wo_add_cap_2035)/1000 wo_add_cap_2035, 		-- additional Capacity in MW
sum(A.wo_cap_2014)/1000  wo_cap_2014,          		-- capacity 2014 im MW
scn.capacity_2035,                           		-- Scenario capacity 2035 in MW
(SUM(A.wo_add_cap_2035) +sum(A.wo_cap_2014))/1000 total -- in MW
FROM
 (
SELECT 
  scn.state,
  scn.nuts,
  substring(AA.rs_0 from 1 for 2) as rs,
  scn.capacity as capacity_2035,
  scn.generation_type
FROM
  orig_geo_vg250.vg250_6_gem_clean AA,
  orig_scenario_data.nep_2015_scenario_capacities as scn
WHERE scn.nuts = substring(AA.nuts from 1 for 3)
AND  scn.generation_type = 'wind_onshore'
AND   scn.scenario_name ='B12035/B22035'
group by scn.nuts, substring(AA.rs_0 from 1
 for 2), substring(AA.nuts from 1 for 3),
         scn.capacity,scn.generation_type, scn.state
) as scn,
 orig_geo_powerplants.wo_dev_nep_germany_mun A
WHERE scn.rs = substring(rs_0 from 1 for 2)
Group by substring(rs_0 from 1 for 2),scn.capacity_2035, scn.state
Order by scn.state
;
--
-- SELECT sum(wo_cap_2014) FROM  orig_geo_powerplants.wo_dev_nep_germany_mun;
--
--- ------------------------------------------------------------------------------------------------------------
-- Take status Quo and Add new onshore plants 
-- Insert new units by pv_new_units 
-- geom = centroid of mun geom , see http://postgis.net/docs/ST_PointOnSurface.html
-- generation_subtype is not defined 



INSERT INTO model_draft.ego_supply_res_powerplant_2035
SELECT
  id, 				--
  2035 AS scenario_year, 	--
  electrical_capacity ,  	-- in kW
  generation_type ,		--
  generation_subtype,   	--
  thermal_capacity, 		--
  NULL AS nuts,			-- nuts id of federal state
  lon,  			--
  lat, 				--	
  voltage_level,   		-- 
  network_node, 		--
  source,  		        --  
  comment,  			--  
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'wind'
AND generation_subtype = 'wind_onshore'
;
--
-- SELECT count(*) FROM model_draft.ego_supply_res_powerplant_2035
-- WHERE generation_type = 'wind' AND generation_subtype = 'wind_onshore';
-- set nuts

UPDATE model_draft.ego_supply_res_powerplant_2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(ST_Transform(regions.geom, 4326), upt.geom)
AND generation_subtype = 'wind_onshore';
-- Time log local =  01:47 minutes
-- Time log server = 03:52:10855 hours 



-- Add new wind shore units 
Insert into model_draft.ego_supply_res_powerplant_2035 (id,scenario_year,electrical_capacity,
            generation_type, generation_subtype, voltage_level, source, comment,geom)

	SELECT
	  sub2.max_rown + row_number() over () as id ,
	  2035  as scenario_year,
	  sub.electrical_capacity,
	  'wind'::text as generation_type,
	  'wind_onshore'::text as generation_subtype,
	  sub.voltage_level,
	  'open_ego NEP 2015 B2035'::text as  source,
	  'Method ProxToNow wind onshore'::text as comment, 
	  sub.geom
	FROM (
	SELECT
	  A.rs_0,
	  A.voltage_level,
	  Case when A.wo_new_units = 0 Then A.wo_add_cap_2035
	       else  unnest(array_fill(A.wo_avg_cap, Array[(A.wo_new_units)::int])) END as electrical_capacity ,    -- in kW 
	 ST_Transform(ST_PointOnSurface(B.geom), 4326) as geom     
	FROM 
	  orig_geo_powerplants.wo_dev_nep_germany_mun A,
	  orig_geo_vg250.vg250_6_gem_clean B
	Where A.rs_0 = B.rs_0
	) as sub ,
	(Select
	 max(id) as max_rown
	 FROM
	  model_draft.ego_supply_res_powerplant_2035
	  ) as sub2 
;
-- log time local: 12.1 secs
--DELETE FROM  model_draft.ego_supply_res_powerplant_2035  WHERE comment = 'Method ProxToNow wind onshore';


--- ------------------------------------------------------------------------------------------------------------
-- CHP/ KWK Part here
-- supply."ego_renewable_power_plants_germany_Stand_2016_11_24"
-- Easy approach use Marios Tabel
-- 
-- Change Python script in order to fill tabel
 
INSERT INTO model_draft.ego_supply_res_powerplant_2035
SELECT
  B.max_id +row_number() over (ORDER BY A.id) as id,  -- create new ID 
  2035 AS scenario_year, 		--
  A.electrical_capacity,  		-- in kW
  A.generation_type,		--
  A.generation_subtype,   	--
  A.thermal_capacity, 			--
  NULL AS nuts,				-- nuts id of federal state
  A.lon,  				--
  A.lat, 				--	
  Null as voltage_level,   		-- 
  A.network_node, 			--
  A.source,  		    		--  
  A.comment,  				--  
  A.geom,  				--
  Null as voltage,  			--
  Null as subst_id,  			--
  Null as otg_id,  			--
  Null as un_id				--
FROM
   model_draft.ego_small_chp_plant_germany A,
   (SELECT max(id) as max_id FROM
       model_draft.ego_supply_res_powerplant_2035 
       ) B
WHERE
A.generation_type = 'chp'
;
-- Time log server = 792 msec 

--  ++++   HIER WEITER **** 


--- ------------------------------------------------------------------------------------------------------------
-- Clean up Part
-- Drop View and temp tables

/*
 DROP SEQUENCE orig_geo_powerplants.on_dev_nep_germany_mun_id_seq;
 DROP SEQUENCE model_draft.ego_supply_pv_dev_2035_germany_mun_id_seq;
 DROP SEQUENCE orig_geo_powerplants.wo_dev_nep_germany_mun_id_seq;
 DROP TABLE model_draft.ego_supply_res_powerplant_germany_to_region CASCADE;
 DROP TABLE orig_geo_powerplants.wo_dev_nep_germany_mun CASCADE;
*/
 
--- ------------------------------------------------------------------------------------------------------------
-- 
--  META Documentation
--

COMMENT ON TABLE  model_draft.ego_supply_res_powerplant_2035 IS
'{
"Name": "Renewable power plants in Germany by NEP 2035 Scenario data",
"Source": [{
                  "Name": "Open_eGo",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2035",
"Date of collection": "21-11-2016",
"Original file": "https://github.com/openego/data_processing/... .sql",
"Spatial resolution": ["Germany"],
"Description": ["The data set in"],
"Column": [
                   {"Name": "id",
                    "Description": "Primary ID",
                    "Unit": "" }, 
                   {"Name": "scenario_year",
                    "Description": "Scenario date",
                    "Unit": "Year" }, 
                   {"Name": "electrical_capacity",
                    "Description": "Electrical Capacity",
                    "Unit": "KW" }, 
                   {"Name": "generation_type",
                    "Description": "Generation type as wind, solar, biomass, etc.",
                    "Unit": "" }, 
                   {"Name": "generation_subtype",
                    "Description": "Generation type as wind onshore, wind offshore, solar_roof_mounted, etc.",
                    "Unit": "" }, 
                   {"Name": "thermal_capacity",
                    "Description": "Thermal capacity of CHP units",
                    "Unit": "KW" }, 
                   {"Name": "nuts",
                    "Description": "NUTS Region Code of NUTS 3",
                    "Unit": "" }, 
                   {"Name": "lon",
                    "Description": "Longitude",
                    "Unit": "" }, 
                   {"Name": "lat",
                    "Description": "Latitude",
                    "Unit": "" }, 
                   {"Name": "voltage_level",
                    "Description": "Voltage level of Germany form 1 (Extra-high voltage) to 7 (Low voltage)",
                    "Unit": "" }, 
                   {"Name": "network_node",
                    "Description": "Connection point to the electricity grid based on BNetzA data",
                    "Unit": "" }, 
                   {"Name": "source",
                    "Description": "Name of source or abbreviation of source name",
                    "Unit": "" }, 
                   {"Name": "comment",
                    "Description": "Comment and description of e.g. methods, corrections, etc.",
                    "Unit": "" }, 
                   {"Name": "geom",
                    "Description": "Geometry Point",
                    "Unit": "" }, 
                   {"Name": "voltage",
                    "Description": "Calculated voltage level",
                    "Unit": "KV" }, 
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "otg_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "un_id",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Wolf-Dieter Bunke",
                    "Mail": "wolf-dieter.bunke@uni-flensburg.de",
                    "Date":  "21.11.2016",
                    "Comment": "Creat Tabel and implement development method" }
                  ],
"ToDo": ["Add subst_id till un_id, and soon"],
"Licence": ["Not choosen yet"],
"Instructions for proper use": [".."]
}';

--- 
SELECT obj_description('model_draft.ego_supply_res_powerplant_2035'::regclass)::json;

-- END
