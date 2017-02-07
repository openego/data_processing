/*
SQL Script which implements methods of development and allocation of renewable energy units in germany by future scenarios.
This script is many based on development_res_ProxToNow_2035.sql

__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

-------------------------------------

Changes beteewn both scripts:
* Scenario numbers are given for the country and for single federal states
* The development relates to the 2035 NEP Scenario

Open Questions:
* small CHP units part of 2050? 

ToDO: 
* Werte pro Bundesland gewichtet nach 2035 Anteil in nep_2015_scenario_capacities erstellen
* ! Bug in json docu
	
*/

-- Test of existens and completeness of tables
SELECT * FROM  orig_geo_vg250.vg250_2_lan Limit 1;
SELECT * FROM  orig_geo_vg250.vg250_2_lan_nuts_view Limit 1;
SELECT * FROM  model_draft.ego_supply_res_powerplant_2035 Limit 1;
SELECT * FROM  political_boundary.bkg_vg250_2_lan Limit 1; 
SELECT * FROM  orig_scenario_data.nep_2015_scenario_capacities Limit 1;
SELECT * FROM  supply.ego_conv_powerplant Limit 1;
SELECT * FROM  model_draft.ego_supply_res_powerplant_2050 Limit 1;
--
/*
Drop Table orig_geo_powerplants.renewable_power_plants_germany_to_region_2050 CASCADE;
Drop Table  model_draft.ego_supply_res_powerplant_2050  CASCADE;
DROP SEQUENCE orig_geo_powerplants.pv_dev_2050_germany_mun_id_seq CASCADE;
DROP TABLE orig_geo_powerplants.pv_dev_2050_germany_mun CASCADE;
DROP SEQUENCE orig_geo_powerplants.wo_dev_2050_germany_mun_id_seq;
*/
-- ...

--
--- Data and Scenario Test 2035
SELECT round(sum(electrical_capacity)/1000000) as sum_gw, count(*), generation_type
FROM model_draft.ego_supply_res_powerplant_2035 
Group by generation_type ;
--
--- Data and Scenario Test 2050
SELECT round(sum(electrical_capacity)/1000000) as sum_gw, count(*), generation_type
FROM model_draft.ego_supply_res_powerplant_2050 
Group by generation_type ;
--
-- Scenario data overview 2050
SELECT *
FROM
orig_scenario_data.nep_2015_scenario_capacities 
Where scenario_name = 'ego-100-2050'
;

--- ------------------------------------------------------------------------------------------------------------
---- Create new Table for 2050 ZNES Scenario
----

-- Drop Table model_draft.ego_supply_res_powerplant_2050 CASCADE;

CREATE TABLE model_draft.ego_supply_res_powerplant_2050
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
  CONSTRAINT ego_supply_res_powerplant_2050_pkey PRIMARY KEY (id)
);

  -- Set Grant and index on geom and generation_type = gt

CREATE INDEX ego_supply_res_powerplant_2050_idx
  ON model_draft.ego_supply_res_powerplant_2050
  USING gist
  (geom);
  
CREATE INDEX ego_supply_res_powerplant_2050_gt_idx 
	ON model_draft.ego_supply_res_powerplant_2050 (generation_type);


ALTER TABLE model_draft.ego_supply_res_powerplant_2050
  OWNER TO oeuser;
  
GRANT ALL ON TABLE model_draft.ego_supply_res_powerplant_2050 TO oeuser;



-- *** HIER WEITER ****
-- Wenn 2035 fertig

--- ------------------------------------------------------------------------------------------------------------
---- Insert Scenario data 2035 as Status Quo
---
-- Attention small chp units are not inclueded

INSERT INTO model_draft.ego_supply_res_powerplant_2050
SELECT
  id,  							-- create new ID 				--
  2050 AS scenario_year, 				--
  round(electrical_capacity,3) as electrical_capacity , -- in kW
  generation_type,					--
  generation_subtype,   				--
  thermal_capacity, 					--
  nuts,							-- nuts id of federal state
  lon,  						--
  lat, 							--	
  voltage_level,   					-- 
  network_node, 					--
  source,  		    				--  
  comment || 'scenario NEP 2035',			--  
  geom,  						--
  voltage,  						--
  subst_id,  						--
  otg_id,  						--
  un_id							--
FROM
model_draft.ego_supply_res_powerplant_2035
WHERE generation_type in ('solar', 'wind', 'hydro', 'geothermal', 'biomass', 'gas')
;
-- Time Log server = 59.3 secs 

--- ------------------------------------------------------------------------------------------------------------
--- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
-- 	Set nuts per unit. Use Buffer for units at the German Border 
--- 
UPDATE model_draft.ego_supply_res_powerplant_2050 as upt
set nuts = regions.nuts
from
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE upt.nuts IS NULL
AND ST_Intersects(ST_Transform(upt.geom, 3035), regions.geom)
;
-- log time =  05:44 min
--- Use Buffer 1 km for units at the German Border 
UPDATE model_draft.ego_supply_res_powerplant_2050 as upt
set nuts = regions.nuts
FROM
orig_geo_vg250.vg250_2_lan_nuts_view as regions,
(
SELECT *
FROM 
  model_draft.ego_supply_res_powerplant_2050
WHERE nuts is Null
AND generation_subtype != 'wind_offshore'
) as aa
WHERE ST_Intersects(ST_Transform(aa.geom, 3035), ST_Buffer(regions.geom,1000))
AND upt.id = aa.id;
;
-- log time =   54:46 minutes
-- ToDO wind offshore /Nuts region as renpass regions dpr


-- 

-- Check nuts id 
SELECT
  nuts,
  count(id),
  sum(electrical_capacity)/1000000, -- in GW
  generation_type,
  generation_subtype
FROM
 model_draft.ego_supply_res_powerplant_2050 
 --WHERE nuts IS NULL
GROUp by nuts, generation_type, generation_subtype;
--


--- ------------------------------------------------------------------------------------------------------------
-- Biomass Methode
-- Increase installed capacity by 2050 scenario data
-- No changes of voltage level
--

UPDATE model_draft.ego_supply_res_powerplant_2050 as upt
set comment = upt.comment || ', Method ProxToNow Biomass',
    source = 'open_ego 2050',
    electrical_capacity = CASE WHEN scn.capacity = 0 THEN 0 
	  ELSE (upt.electrical_capacity/ cap_sum)*scn.capacity*1000    
	 END 
FROM
  orig_scenario_data.nep_2015_scenario_capacities as scn,
  (SELECT 'DE'::text as nuts, sum(electrical_capacity) as cap_sum
   FROM model_draft.ego_supply_res_powerplant_2050
   WHERE generation_type = 'biomass' --Group by nuts
   ) count
WHERE scn.nuts = substring(count.nuts from 1 for 2)
AND   scn.nuts = substring(upt.nuts from 1 for 2)
AND   substring(upt.nuts from 1 for 2) = substring(count.nuts from 1 for 2)
AND   scn.generation_type = 'biomass'
AND   scn.scenario_name = 'ego-100-2050'
AND   upt.generation_type = 'biomass';

-- Log Time server = 15.308 rows affected, 5.1 secs



--- ------------------------------------------------------------------------------------------------------------
-- Geothermal Methode 
--   No changes set status quo
-- 
/*
UPDATE model_draft.ego_supply_res_powerplant_2035
set comment = comment || ', No changes status quo'
WHERE generation_type = 'geothermal';
*/


--- ------------------------------------------------------------------------------------------------------------
-- Hydro / run_of_river
-- Insert large Hydro reservoir and run_of_river units from NEP 2035 Scenario
--
UPDATE model_draft.ego_supply_res_powerplant_2050 as upt
set comment = upt.comment || ', Method ProxToNow Hydro',
    source = 'open_ego 2050',
    electrical_capacity = CASE WHEN scn.capacity = 0 THEN upt.electrical_capacity
	  ELSE (upt.electrical_capacity/ cap_sum)*scn.capacity*1000    
	 END 
FROM
  orig_scenario_data.nep_2015_scenario_capacities as scn,
  (SELECT nuts, sum(electrical_capacity) as cap_sum
   FROM model_draft.ego_supply_res_powerplant_2050
   WHERE generation_type = 'hydro' Group by nuts
   ) count
WHERE scn.nuts = count.nuts 
AND   scn.nuts = upt.nuts 
AND   upt.nuts = count.nuts
AND   scn.generation_type = 'hydro' 
AND   upt.generation_type = 'hydro'
AND   scn.scenario_name = 'ego-100-2050';

-- check -> no changes done!
--- ------------------------------------------------------------------------------------------------------------
-- Gas and chp Methode 
-- Use of has to be discussed


--- ------------------------------------------------------------------------------------------------------------
-- PV Methode 
-- 
/*

Step 0 Get Nuts id per Unit 
Step 1 capacity per municipality -> ProToNow from NEP 2035
Step 2 Structure of PV ( volatage level, size, Number)
Step 3 Add new PV at center of municipality polygon
Step 4 Add volatage level, etc.
*/


Create Table orig_geo_powerplants.renewable_power_plants_germany_to_region_2050
(
re_id bigint NOT NULL,   	-- id from proc_renewable_power_plants_germany
subst_id bigint,      		-- substation ID
otg_id bigint,        		-- 
un_id bigint,         		--   
nuts character varying(5),	-- Nuts key for districts 
rs_0 character varying(12),	-- German Regionalschlüssel
id_vg250 bigint, 		-- ID of orig_geo_vg250.vg250_6_gem_clean table
CONSTRAINT renewable_power_plants_germany_to_region_2050_pkey PRIMARY KEY (re_id)
);

ALTER TABLE orig_geo_powerplants.renewable_power_plants_germany_to_region_2050
  OWNER TO oeuser;
  
GRANT ALL ON TABLE orig_geo_powerplants.renewable_power_plants_germany_to_region_2050 TO oeuser WITH GRANT OPTION;
GRANT ALL ON TABLE orig_geo_powerplants.renewable_power_plants_germany_to_region_2050 TO oerest WITH GRANT OPTION;
--
--
INSERT INTO orig_geo_powerplants.renewable_power_plants_germany_to_region_2050 (re_id,subst_id,otg_id,un_id)
SELECT
id as re_id,
subst_id,
otg_id,
un_id
FROM
model_draft.ego_supply_res_powerplant_2035;
--
--
Update orig_geo_powerplants.renewable_power_plants_germany_to_region_2050 A
set id_vg250 = C.id,
    rs_0 = C.rs_0,
    nuts = C.nuts
FROM
   (
	SELECT
	  A.re_id,
	  B.geom
	FROM
	orig_geo_powerplants.renewable_power_plants_germany_to_region_2050 A,
	model_draft.ego_supply_res_powerplant_2035 B
	WHERE A.re_id = B.id
	AND A.nuts IS NULL 
  ) as AA,
  orig_geo_vg250.vg250_6_gem_clean C
WHERE ST_Intersects(ST_Transform(C.geom, 4326),AA.geom)
AND AA.re_id = A.re_id;

--- Check 
-- time log = 6:18 min
--
SELECT
count(*)
FROM orig_geo_powerplants.renewable_power_plants_germany_to_region_2050 
WHERE nuts IS NULL;
--
-- Get nuts ID by buffering geometry 
--
Update orig_geo_powerplants.renewable_power_plants_germany_to_region_2050 A
set id_vg250 = C.id,
    rs_0 = C.rs_0,
    nuts = C.nuts
FROM
   (
	SELECT
	  A.re_id,
	  B.geom
	FROM
	orig_geo_powerplants.renewable_power_plants_germany_to_region_2050 A,
	model_draft.ego_supply_res_powerplant_2035 B
	WHERE A.re_id = B.id
	AND A.nuts IS NULL 
	AND B.generation_subtype != 'wind_offshore'

		
  ) as AA,
  orig_geo_vg250.vg250_6_gem_clean C
WHERE ST_Intersects(ST_Transform(C.geom, 4326), ST_Buffer(AA.geom,10))
AND AA.re_id = A.re_id
;

--
--- ------------------------------------------------------------------------------------------------------------
--   Status Quo 2035 PV

CREATE SEQUENCE orig_geo_powerplants.pv_dev_2050_germany_mun_id_seq START 1;

Create Table orig_geo_powerplants.pv_dev_2050_germany_mun 
(
id bigint NOT NULL DEFAULT nextval('orig_geo_powerplants.pv_dev_2050_germany_mun_id_seq'::regclass),-- own id PK 
pv_units integer,      		-- number of PV units per mun and voltage level 
pv_cap_2035 integer,        	-- sum per region of 2035 in kW 
pv_add_cap_2050 integer,        -- sum per region of additional Capacity in 2035 kW 
voltage_level smallint,        	-- voltage_level from 1-7   
rs_0 character varying(12),	-- German Regionalschlüssel
pv_avg_cap integer, 		-- average capacity per region and voltage level
pv_new_units numeric(9,2), 	-- New number of region per voltage level 
CONSTRAINT pv_dev_2050_germany_mun_pkey PRIMARY KEY (id)
);
--

Insert into orig_geo_powerplants.pv_dev_2050_germany_mun (pv_units,pv_cap_2035,voltage_level,rs_0,pv_avg_cap)
SELECT
  count(A.*) as pv_units,
  sum(A.electrical_capacity) as pv_cap_2035,
  A.voltage_level,
  B.rs_0,
  avg(A.electrical_capacity) as pv_avg_cap
FROM
  model_draft.ego_supply_res_powerplant_2035 A, 
  orig_geo_vg250.vg250_6_gem_clean B
WHERE
  ST_Intersects(ST_Transform(B.geom, 4326), A.geom)
AND A.generation_type = 'solar'
Group by A.voltage_level, B.id, B.rs_0;

-- time log local:   
--- ------------------------------------------------------------------------------------------------------------
-- PV ProxToNow per municipality and voltage level
---
/*


*/
UPDATE orig_geo_powerplants.pv_dev_2050_germany_mun AA
set     pv_add_cap_2050 = ( (AA.pv_cap_2035::numeric / pv_sq_2035.fs_cap_2035::numeric)*pv_scn_2050.fs_cap_2050 
                             -AA.pv_cap_2035)::integer
                              
FROM
(
SELECT
-- substring(A.rs_0 from 1 for 2) as rs,        -- Regionalschlüssel first 2 numbers = federal state
 scn.capacity*1000 as fs_cap_2050 ,           -- in kW
 scn.nuts  				      -- nuts code federal state
 FROM
   orig_geo_vg250.vg250_6_gem_clean A,
    orig_scenario_data.nep_2015_scenario_capacities scn
WHERE scn.nuts = substring(A.nuts from 1 for 2)
AND   scn.generation_type = 'solar' 
AND   scn.scenario_name = 'ego-100-2050'
Group by substring(A.nuts from 1 for 2),scn.capacity,scn.nuts --,rs
) as pv_scn_2050,
(
SELECT
   --substring(A.rs_0 from 1 for 2) as rs,        -- Regionalschlüssel first 2 numbers = federal state
   sum(A.pv_cap_2035) as fs_cap_2035            -- in kW
FROM
  orig_geo_powerplants.pv_dev_2050_germany_mun A
--Group by  substring(A.rs_0 from 1 for 2) 
) as pv_sq_2035
--Where pv_scn_2050.rs = pv_sq_2035.rs
--AND substring(AA.rs_0 from 1 for 2) =  pv_sq_2035.rs
--AND substring(AA.rs_0 from 1 for 2) =  pv_scn_2050.rs
;
--
--- ------------------------------------------------------------------------------------------------------------
-- Count new additional Units -> new_units

UPDATE orig_geo_powerplants.pv_dev_2050_germany_mun AA
set     pv_new_units =  round(pv_add_cap_2050/pv_avg_cap); 

-- Controll PV development 

SELECT
--substring(A.rs_0 from 1 for 2)  rs_fs,       		-- fs ID
SUM(A.pv_add_cap_2050)/1000 pv_add_cap_2050, 		-- additional Capacity in MW
sum(A.pv_cap_2035)/1000  pv_cap_2035,          		-- capacity 2035 im MW
scn.capacity_2050,                           		-- Scenario capacity 2050 in MW
(SUM(A.pv_add_cap_2050) +sum(A.pv_cap_2035))/1000 total -- in MW
FROM
 (
SELECT
  scn.nuts,
 -- substring(AA.rs_0 from 1 for 2) as rs,
  scn.capacity as capacity_2050,
  scn.generation_type
FROM
  orig_geo_vg250.vg250_6_gem_clean AA,
  orig_scenario_data.nep_2015_scenario_capacities as scn
WHERE  scn.generation_type = 'solar'
-- AND scn.nuts = substring(AA.nuts from 1 for 3)

AND   scn.scenario_name = 'ego-100-2050'
group by scn.nuts, substring(AA.nuts from 1 for 2), --substring(AA.rs_0 from 1 for 2),
         scn.capacity,scn.generation_type
) as scn,
 orig_geo_powerplants.pv_dev_2050_germany_mun A
--WHERE scn.rs = substring(rs_0 from 1 for 2)
Group by scn.capacity_2050 --, substring(rs_0 from 1 for 2)
;
---
--- ------------------------------------------------------------------------------------------------------------
-- Add new PV units 
---
--
Insert into model_draft.ego_supply_res_powerplant_2050 (id,scenario_year,electrical_capacity,
generation_type, voltage_level, source, comment,geom)

	SELECT
	  sub2.max_rown + row_number() over () as id ,
	  2050  as scenario_year,
	  sub.electrical_capacity,
	  'solar'::text as generation_type,
	  sub.voltage_level,
	  'open_ego 2050'::text as  source,
	  ', Method ProxToNow solar'::text as comment, 
	  sub.geom
	FROM (
	SELECT
	  A.rs_0,
	  A.voltage_level,
	  Case when A.pv_new_units = 0 Then A.pv_add_cap_2050
	       else  unnest(array_fill(A.pv_avg_cap, Array[(A.pv_new_units)::int])) END as electrical_capacity ,    -- in kW 
	 ST_Transform(ST_PointOnSurface(B.geom), 4326) as geom     
	FROM 
	  orig_geo_powerplants.pv_dev_2050_germany_mun A,
	  orig_geo_vg250.vg250_6_gem_clean B
	Where A.rs_0 = B.rs_0 --limit 12
	) as sub ,
	(Select
	 max(id) as max_rown
	 FROM
	  model_draft.ego_supply_res_powerplant_2050
	  ) as sub2
;
-- log time local: 10:30 min

--- ------------------------------------------------------------------------------------------------------------
--  Offshore Wind 
--  
-- 

-- here fix nuts / renpass region

UPDATE model_draft.ego_supply_res_powerplant_2050 as upt
set comment = upt.comment || ', Method ProxToNow wind offshore',
    source = 'open_ego 2050',
    electrical_capacity = CASE WHEN scn.capacity = 0 THEN upt.electrical_capacity
	  ELSE (upt.electrical_capacity/ cap_sum)*scn.capacity*1000    
	 END 
FROM
  orig_scenario_data.nep_2015_scenario_capacities as scn,
  (SELECT nuts, sum(electrical_capacity) as cap_sum
   FROM model_draft.ego_supply_res_powerplant_2035
   WHERE generation_subtype = 'wind_offshore' Group by nuts
   ) count
WHERE scn.nuts = count.nuts 
AND   scn.nuts = upt.nuts 
AND   upt.nuts = count.nuts
AND   scn.generation_type = 'wind_offshore' 
AND   upt.generation_subtype = 'wind_offshore'
AND   scn.scenario_name = 'ego-100-2050';


--- ------------------------------------------------------------------------------------------------------------
--  Onshore Wind 
--  
-- Use of "easy" ProxToNow
--
CREATE SEQUENCE orig_geo_powerplants.wo_dev_2050_germany_mun_id_seq START 1;

Create Table orig_geo_powerplants.wo_dev_2050_germany_mun
(
id bigint NOT NULL DEFAULT nextval('orig_geo_powerplants.wo_dev_2050_germany_mun_id_seq'::regclass), -- own id PK 
wo_units integer,      		-- number of onshore units per mun and voltage level 
wo_cap_2035 integer,        	-- sum per region of 2035 in kW 
wo_add_cap_2050 integer,        -- sum per region of additional Capacity in 2050 kW 
voltage_level smallint,        	-- voltage_level from 1-7   
rs_0 character varying(12),	-- German Regionalschlüssel
wo_avg_cap integer, 		-- average capacity per region and voltage level
wo_new_units numeric(9,2), 	-- New number of region per voltage level 
CONSTRAINT wo_dev_2050_germany_mun_pkey PRIMARY KEY (id)
);
--
Insert into orig_geo_powerplants.wo_dev_2050_germany_mun (wo_units,wo_cap_2035,voltage_level,rs_0,wo_avg_cap)
SELECT
  count(A.*) as wo_units,
  sum(A.electrical_capacity) as wo_cap_2035,
  A.voltage_level,
  B.rs_0,
  avg(A.electrical_capacity) as wo_avg_cap
FROM
  model_draft.ego_supply_res_powerplant_2035 A, 
  orig_geo_vg250.vg250_6_gem_clean B
WHERE
  ST_Intersects(ST_Transform(B.geom, 4326), A.geom)
AND A.generation_type = 'wind'
AND A.generation_subtype = 'wind_onshore'
Group by A.voltage_level, B.id, B.rs_0;
--
-- SELECT * FROM orig_geo_powerplants.wo_dev_2050_germany_mun LIMIT 10;
--
UPDATE orig_geo_powerplants.wo_dev_2050_germany_mun AA
set     wo_add_cap_2050 = ( (AA.wo_cap_2035::numeric / wo_sq_2035.fs_cap_2035::numeric)*wo_scn_2050.fs_cap_2050 
                             -AA.wo_cap_2035)::integer
                              
FROM
(
SELECT
 --substring(A.rs_0 from 1 for 2) as rs,        -- Regionalschlüssel first 2 numbers = federal state
 scn.capacity*1000 as fs_cap_2050 ,           -- in kW
 scn.nuts  				      -- nuts code federal state
 FROM
    orig_geo_vg250.vg250_6_gem_clean A,
    orig_scenario_data.nep_2015_scenario_capacities scn
WHERE   scn.generation_type = 'wind_onshore' 

AND scn.nuts = substring(A.nuts from 1 for 2)

AND   scn.scenario_name = 'ego-100-2050'
Group by substring(A.nuts from 1 for 2),scn.capacity,scn.nuts --,rs
) as wo_scn_2050,
(
SELECT
   --substring(A.rs_0 from 1 for 2) as rs,        -- Regionalschlüssel first 2 numbers = federal state
   sum(A.wo_cap_2035) as fs_cap_2035            -- in kW
FROM
  orig_geo_powerplants.wo_dev_2050_germany_mun A
--Group by  substring(A.rs_0 from 1 for 2) 
) as wo_sq_2035
--Where wo_scn_2050.rs = wo_sq_2035.rs
--AND substring(AA.rs_0 from 1 for 2) =  wo_sq_2035.rs
--AND substring(AA.rs_0 from 1 for 2) =  wo_scn_2050.rs
;
--
--- ------------------------------------------------------------------------------------------------------------
-- Count new additional Units -> new_units
-- Hot Fix data cleaning
-- DELETE FROM orig_geo_powerplants.wo_dev_2050_germany_mun WHERE wo_add_cap_2050 <=0;
--
UPDATE orig_geo_powerplants.wo_dev_2050_germany_mun AA
     set wo_new_units =  round(wo_add_cap_2050/wo_avg_cap); 
--
-- SELECT * FROM   orig_scenario_data.nep_2015_scenario_capacities WHERE generation_type = 'wind_onshore' AND scenario_name = 'ego-100-2050' Limit 20;
--
-- Controll wind onshore development 
SELECT
scn.state,
--substring(A.rs_0 from 1 for 2)  rs_fs,       		-- fs ID
SUM(A.wo_add_cap_2050)/1000 wo_add_cap_2050, 		-- additional Capacity in MW
sum(A.wo_cap_2035)/1000  wo_cap_2035,          		-- capacity 2035 im MW
scn.capacity_2050,                           		-- Scenario capacity 2050 in MW
(SUM(A.wo_add_cap_2050) +sum(A.wo_cap_2035))/1000 total -- in MW
FROM
 (
SELECT 
  scn.state,
  scn.nuts,
  --substring(AA.rs_0 from 1 for 2) as rs,
  scn.capacity as capacity_2050,
  scn.generation_type
FROM
  orig_geo_vg250.vg250_6_gem_clean AA,
  orig_scenario_data.nep_2015_scenario_capacities as scn
WHERE scn.nuts = substring(AA.nuts from 1 for 2)
AND  scn.generation_type = 'wind_onshore'
AND   scn.scenario_name = 'ego-100-2050'

group by scn.nuts, substring(AA.nuts from 1 for 2), --, substring(AA.rs_0 from 1 for 2)
         scn.capacity,scn.generation_type, scn.state
) as scn,
 orig_geo_powerplants.wo_dev_2050_germany_mun A
--WHERE scn.rs = substring(rs_0 from 1 for 2)
Group by scn.capacity_2050, scn.state --, substring(rs_0 from 1 for 2)
Order by scn.state
;
--
--HIER WEITER!
-- Add new wind shore units 
Insert into model_draft.ego_supply_res_powerplant_2050 (id,scenario_year,electrical_capacity,
            generation_type, generation_subtype, voltage_level, source, comment,geom)

	SELECT
	  sub2.max_rown + row_number() over () as id ,
	  2050  as scenario_year,
	  sub.electrical_capacity,
	  'wind'::text as generation_type,
	  'wind_onshore'::text as generation_subtype,
	  sub.voltage_level,
	  'open_ego 2050'::text as  source,
	  'Method ProxToNow wind onshore'::text as comment, 
	  sub.geom
	FROM (
	SELECT
	  A.rs_0,
	  A.voltage_level,
	  Case when A.wo_new_units = 0 Then A.wo_add_cap_2050
	       else  unnest(array_fill(A.wo_avg_cap, Array[(A.wo_new_units)::int])) END as electrical_capacity ,    -- in kW 
	 ST_Transform(ST_PointOnSurface(B.geom), 4326) as geom     
	FROM 
	  orig_geo_powerplants.wo_2050_nep_germany_mun A,
	  orig_geo_vg250.vg250_6_gem_clean B
	Where A.rs_0 = B.rs_0
	) as sub ,
	(Select
	 max(id) as max_rown
	 FROM
	  model_draft.ego_supply_res_powerplant_2050
	  ) as sub2 
;
-- log time local: 

--- ------------------------------------------------------------------------------------------------------------
-- CHP/ KWK Part here
-- Q: Also for 2050 needed? or only 2035 data?



-- ------------------------------------------------------------------------------------------------------------
-- Validation and Analyse Part
--
--- # # # # # # # # # # # # # # #
-- 
-- Check Scenario Data per felderal state
--
--- # # # # # # # # # # # # # # #








--- ------------------------------------------------------------------------------------------------------------
-- 
--  META Documentation
--

COMMENT ON TABLE  model_draft.ego_supply_res_powerplant_2050 IS
'{
"Name": "Renewable power plants in Germany by NEP 2050 Scenario data",
"Source": [{
                  "Name": "Open_eGo",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2050",
"Date of collection": "21-11-2016",
"Original file": "https://github.com/openego/data_processing/... .sql",
"Spatial resolution": ["Germany"],
"Description": ["The data set includes a set of power plants in Germany which is based on 
                 the status Quo data until 2015. The sources are Energymap until August 2014 
                 and BNetzA until End of 2015 known as “EEG Anlagenregister”. By the scenario data 
                 ZNES-100, the scenario “ego-100-2050” which reflex a 100% on renewable energy source 
                 based energy system in 2050, was created. \n The development of new power plant units are 
                 given in a high spatial resolution. The power units are differenced in generation_type 
                 (e.g. biomass, solar, wind for generation_type) and generation_subtype (e.g. solar_roof_mounted, 
                 wind_onshore, wind_offshore). A detailed description can be found on: http://XXX."],
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
                    "Description": "voltage level to which generator is connected 
                    (partly calculated based on installed capacity) Voltage level of 
                    Germany form 1 (Extra-high voltage) to 7 (Low voltage)",
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
                    "Description": "id of associated substation",
                    "Unit": "" }, 
                   {"Name": "otg_id",
                    "Description": "otg_id of associated substation",
                    "Unit": "" }, 
                   {"Name": "un_id",
                    "Description": "unified id for res and conv powerplants",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Wolf-Dieter Bunke",
                    "Mail": "wolf-dieter.bunke@uni-flensburg.de",
                    "Date":  "21.11.2016",
                    "Comment": "Creat Tabel and implement development method" },
                   {"Name": "Wolf-Dieter Bunke",
                    "Mail": "wolf-dieter.bunke@uni-flensburg.de",
                    "Date":  "07.02.2017",
                    "Comment": "Change of DB version, new allocation" }
                  ],
"ToDo": ["Add subst_id till un_id, and soon"],
"Licence": ["Not choosen yet"],
"Instructions for proper use": [".."]
}';

--- 
SELECT obj_description('model_draft.ego_supply_res_powerplant_2050'::regclass)::json;












