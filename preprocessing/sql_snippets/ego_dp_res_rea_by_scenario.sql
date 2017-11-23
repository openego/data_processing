/* 
SQL Script which prepare and insert a renewable power plant data list by scenario
for the project open_eGo and the tools eTraGo and eDisGo.

__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"	
  
Notes:
------
  This script is divided into two parts:
   
  Part II:
           Development of new renewable power plants by NEP 2035 scenario data
  Part III:
           Development of new renewable power plants by ego 100% scenario data

           
Documentation:
--------------

 flags:
  repowering : old unit get an update of this electrical_capacity (plus or minus)
  commissioning: New unit by a scenario assumption     
  decommissioning: decommissioning of status quo units by a scenario assumption
  constantly: existing plant of status quo or other scenarios
  
 Scenario Names:
    'Status Quo'
    'NEP 2035'
    'eGo 100'


*/


  
--------------------------------------------------------------------------------
-- Part II
--          Develop renewable allocation by generation type, voltage level
--	    and municipality. Scenarios: NEP 2035
--------------------------------------------------------------------------------
---
-- Insert CHP 2035 plants all as gas
---
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_supply_res_powerplant_2035','ego_db_res_rea_by_scenario.sql',' ');  

Insert into model_draft.ego_dp_supply_res_powerplant 
	SELECT
	 'v0.3.0'::text  as preversion,
	  b.max +row_number() over (ORDER BY id) as id,
	  '2034-12-31 00:00:00' as start_up_date,
	  electrical_capacity,
	  generation_type,
	  generation_subtype,
	  thermal_capacity ,
	  NULL as city,
	  NULL as postcode,
	  NULL as address,
	  NULL as lon ,
	  NULL as lat ,
	  NUll as gps_accuracy,
	  Null as validation,
	  Null as notification_reason,
	  Null as eeg_id,
	  Null as tso,
	  Null as tso_eic,
	  Null as dso_id,
	  Null as dso ,
	  Null as voltage_level_var,
	  Null as network_node ,
	  Null as power_plant_id,
	  'chp_small' as source,
	  comment,
	  ST_Transform(geom,3035) as geom,                                   
	  Null as subst_id,
	  Null as otg_id,
	  Null as un_id,
	  Null as voltage_level,
	  Null as la_id,
	  Null as mvlv_subst_id,
	  Null as rea_sort,
	  Null as rea_flag,
	  NULL as rea_geom_line,
	  Null as rea_geom_new,
	  'NEP 2035'::text as scenario,
	  'commissioning'::text as flag,
	  NULL as nuts											
	FROM 
	  model_draft.ego_small_chp_plant_germany,
	  (
	   SELECT max(id) as max
	   FROM model_draft.ego_dp_supply_res_powerplant
          ) as b
	Where
	 comment = 'KWK_NEP_2035_distribution';

-- set nuts
UPDATE model_draft.ego_dp_supply_res_powerplant as upt
set nuts = regions.nuts
from 
  boundaries.bkg_vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(regions.geom, upt.geom)
AND upt.nuts is NULL;

--- Use Buffer 1 km for units at the German Border 
UPDATE model_draft.ego_dp_supply_res_powerplant as upt
set nuts = regions.nuts::varchar
	FROM
	boundaries.bkg_vg250_2_lan_nuts_view as regions,
	(
	SELECT *
	FROM 
	  model_draft.ego_dp_supply_res_powerplant
	WHERE nuts is Null
	) as aa
WHERE ST_Intersects(aa.geom, ST_Buffer(regions.geom,1000))
AND upt.id = aa.id
AND upt.nuts IS NULL;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_dp_supply_res_powerplant','ego_db_res_rea_by_scenario.sql',' ');  
-- ######################################################################################################################################################   HIER WEITER '''
---
-- Biomass power plants
---
-- NEP 2035 Biomass
DROP TABLE IF EXISTS model_draft.ego_supply_res_biomass_2035_temp CASCADE;
CREATE TABLE model_draft.ego_supply_res_biomass_2035_temp AS
	SELECT
	  'v0.3.0'::text as preversion,
	  id ,
	  start_up_date,
	  electrical_capacity,
	  generation_type,
	  generation_subtype,
	  thermal_capacity,
	  city,
	  postcode,
	  address,
	  lon ,
	  lat ,
	  gps_accuracy,
	  validation,
	  notification_reason,
	  eeg_id,
	  tso,
	  tso_eic,
	  dso_id,
	  dso ,
	  voltage_level_var  ,
	  network_node ,
	  power_plant_id,
	  source,
	  comment,
	  ST_Transform(geom,3035) as geom,
	  subst_id,
	  otg_id,
	  un_id,
	  voltage_level,
	  la_id,
	  mvlv_subst_id,
	  rea_sort,
	  rea_flag,
	  NULL::text as rea_geom_line,
	  NULL::text as rea_geom_new,
	  'NEP 2035'::text as scenario,
	  'repowering'::text as flag,
	  nuts										
	FROM
	  model_draft.ego_dp_supply_res_powerplant
	WHERE
	generation_type = 'biomass'
	AND scenario =   'Status Quo';

-- create index GIST (geom)
DROP INDEX IF EXISTS model_draft.ego_supply_res_biomass_2035_temp_geom_idx;
CREATE INDEX ego_supply_res_biomass_2035_temp_geom_idx
	ON model_draft.ego_supply_res_biomass_2035_temp USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_res_biomass_2035_temp OWNER TO oeuser;

-- Biomass Method Prox2Now
-- increase installed capacity by NEP scenario data
-- No changes of voltage level or additional units

UPDATE model_draft.ego_supply_res_biomass_2035_temp as upt
set comment = upt.comment || ', Method ProxToNow Biomass',
    source = 'ego NEP 2015 B2035',
    scenario = 'NEP 2035' ,
    flag = 'repowering',
    preversion ='v0.3.0'::text,
    electrical_capacity = CASE WHEN scn.capacity = 0 THEN 0 
	  ELSE (upt.electrical_capacity/ cap_sum)*scn.capacity*1000    
	 END 
FROM
  model_draft.ego_supply_scenario_capacities as scn,
  (SELECT nuts, sum(electrical_capacity) as cap_sum
   FROM model_draft.ego_supply_res_biomass_2035_temp
   WHERE generation_type = 'biomass'
    Group by nuts
   ) count
WHERE scn.nuts = count.nuts 
AND   scn.nuts = upt.nuts 
AND   upt.nuts = count.nuts
AND   scn.generation_type = 'biomass' 
AND   scn.scenario_name = 'NEP 2035' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
-- SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_dp_supply_res_powerplant','ego_db_res_rea_by_scenario.sql',' ');  

-- Insert ego_dp_supply_res_powerplant 							
Insert into model_draft.ego_dp_supply_res_powerplant
  SELECT
    *
  FROM
    model_draft.ego_supply_res_biomass_2035_temp
  WHERE  scenario = 'NEP 2035';
  
--- 
-- Geothermal Method
-- No changes set status quo
---


--- 
-- Hydro / run_of_river
--   Insert large Hydro reservoir and run_of_river units from status Quo 
--   because of missing entries in NEP KW list
--   No changes of voltage level or additional units
---
/*
UPDATE  model_draft.ego_dp_supply_res_powerplant
set generation_type = 'hydro',
    generation_subtype = 'run_of_river'
 WHERE
   generation_type = 'run_of_river';
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
-- SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_dp_supply_res_powerplant','ego_db_res_rea_by_scenario.sql',' ');  

-- NEP 2035 Hydro
DROP TABLE IF EXISTS 	model_draft.ego_supply_res_hydro_2035_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_res_hydro_2035_temp AS
	SELECT
	 'v0.3.0'::text as preversion,
	  id ,
	  start_up_date,
	  electrical_capacity,
	  generation_type,
	  generation_subtype,
	  thermal_capacity,
	  city,
	  postcode,
	  address,
	  lon ,
	  lat ,
	  gps_accuracy,
	  validation,
	  notification_reason,
	  eeg_id,
	  tso,
	  tso_eic,
	  dso_id,
	  dso ,
	  voltage_level_var  ,
	  network_node ,
	  power_plant_id,
	  source,
	  comment,
	  geom,
	  subst_id,
	  otg_id,
	  un_id,
	  voltage_level,
	  la_id,
	  mvlv_subst_id,
	  rea_sort,
	  rea_flag,
	  NULL::Text as rea_geom_line,
	  NULL::text as rea_geom_new,
	  'NEP 2035'::text as scenario,
	  'repowering'::text as flag,
	   nuts			
	FROM
	  model_draft.ego_dp_supply_res_powerplant
	WHERE
	  generation_type = 'run_of_river'
	AND scenario =   'Status Quo'; 

-- create index GIST (geom)
CREATE INDEX ego_supply_res_hydro_2035_temp_geom_idx
	ON model_draft.ego_supply_res_hydro_2035_temp USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_res_hydro_2035_temp OWNER TO oeuser;

INSERT INTO model_draft.ego_supply_res_hydro_2035_temp (preversion,id,start_up_date,electrical_capacity, generation_type,	
generation_subtype, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, otg_id,un_id,scenario,flag)
SELECT
  'v0.3.0'::text as preversion,
  b.max +row_number() over (ORDER BY gid) as id,       
  '2034-12-31 00:00:00' as start_up_date,			  
  a.capacity *1000  as electrical_capacity,  	         -- MW -> kW
   a.fuel as generation_type,		 
  'hydro' as generation_subtype,   	 	
  a.lon,  		
  a.lat, 				
  a.voltage_level,   		
  a.network_node, 	
  'OPSD powerplant list' as source,  	                 
  'add Hydro plants from conventional list' as comment, 
  ST_Transform(a.geom,3035) as geom,  		
  a.voltage AS voltage_level_var,  			
  a.subst_id,  			
  a.otg_id,  			
  a.un_id,
  'NEP 2035'::text as scenario,
  'repowering'::text as flag				
FROM
  model_draft.ego_supply_conv_powerplant a,
  (
    SELECT max(id) as max
    FROM 	model_draft.ego_dp_supply_res_powerplant
  ) as b
WHERE
fuel in ('reservoir','run_of_river');

-- set nuts
UPDATE model_draft.ego_supply_res_hydro_2035_temp as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(regions.geom, upt.geom)
and UPT.NUTS IS NULL;

--- Fill empty nuts values by buffer
UPDATE model_draft.ego_supply_res_hydro_2035_temp as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(St_Buffer(upt.geom,100), regions.geom)
AND upt.nuts  IS NULL
AND generation_type in ('reservoir','hydro','run_of_river');

--
UPDATE model_draft.ego_supply_res_hydro_2035_temp 
set nuts = 'AT'
WHERE nuts  IS NULL AND generation_type in ('reservoir','hydro','run_of_river');
--
UPDATE model_draft.ego_supply_res_hydro_2035_temp as upt
set comment = upt.comment || ', Method ProxToNow Hydro',
    source = 'NEP 2015 B2035',
    flag = 'repowering',
    electrical_capacity = CASE WHEN scn.capacity = 0 THEN upt.electrical_capacity
	  ELSE (upt.electrical_capacity/ cap_sum)*scn.capacity*1000    
	 END 
FROM
  model_draft.ego_supply_scenario_capacities as scn,
  (SELECT nuts, sum(electrical_capacity) as cap_sum
   FROM model_draft.ego_supply_res_hydro_2035_temp
   WHERE generation_type in ('reservoir','hydro','run_of_river')
   AND scenario = 'NEP 2035' 
   Group by nuts
   ) count
WHERE scn.nuts = count.nuts 
AND   scn.nuts = upt.nuts 
AND   upt.nuts = count.nuts
AND   scn.generation_type in ('reservoir','hydro','run_of_river')
AND   upt.generation_type in ('reservoir','hydro','run_of_river');

-- Insert ego_dp_supply_res_powerplant 							
Insert into model_draft.ego_dp_supply_res_powerplant
  SELECT
    *
  FROM
    model_draft.ego_supply_res_hydro_2035_temp
  WHERE  scenario = 'NEP 2035';

--- 
-- Photovoltaic Method
--
/*
Step 0 Get Nuts id per Unit 
Step 1 capacity per municipality -> Pro2Now
       Status Quo
Step 2 Structure of PV ( voltage level, size, Number)
Step 3 add new PV at center of municipality polygon
Step 4 add volatage level, etc.
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_supply_res_pv_to_region_temp','ego_db_res_rea_by_scenario.sql',' ');  

-- Nep 2035 Photovoltaic
-- Step 0
DROP TABLE IF EXISTS 	model_draft.ego_supply_res_pv_to_region_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_res_pv_to_region_temp 
		(
		re_id bigint NOT NULL,   	-- id from renewable_power_plants
		subst_id bigint,      		
		otg_id bigint,        		 
		un_id bigint,         		
		nuts character varying(5),	 
		rs character varying(12),	-- German Regionalschlüssel
		id_vg250 bigint, 		-- ID of political_boundary.bkg_vg250_6_gem_rs_mview table
		CONSTRAINT ego_supply_res_pv_to_region_temp_pkey PRIMARY KEY (re_id)
		);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_res_pv_to_region_temp OWNER TO oeuser;

INSERT INTO model_draft.ego_supply_res_pv_to_region_temp (re_id,subst_id,otg_id,un_id)
	SELECT
	  id as re_id,
	  subst_id,
	  otg_id,
	  un_id
	FROM
	  model_draft.ego_dp_supply_res_powerplant
	WHERE scenario =  'Status Quo'
	AND generation_type ='solar';

Update model_draft.ego_supply_res_pv_to_region_temp A
set id_vg250 = B.id,
    rs = B.rs,
    nuts = B.nuts
FROM (
	SELECT
	D.id as re_id,
	C.id,
	C.rs,
	C.nuts    
	FROM boundaries.bkg_vg250_6_gem_rs_mview C,
	     model_draft.ego_dp_supply_res_powerplant D
	WHERE ST_Intersects(C.geom, D.geom)
      ) as B
WHERE B.re_id = A.re_id;

Update model_draft.ego_supply_res_pv_to_region_temp A
set id_vg250 = B.id,
    rs = B.rs,
    nuts = B.nuts
FROM (
	SELECT
	D.id as re_id,
	C.id,
	C.rs,
	C.nuts    
	FROM boundaries.bkg_vg250_6_gem_rs_mview C,
	     model_draft.ego_dp_supply_res_powerplant D
	WHERE ST_Intersects(C.geom, St_Buffer(D.geom, 1000))
      ) as B
WHERE B.re_id = A.re_id
AND A.nuts IS NULL;

---
-- NEP 2035 Photovoltaic
-- Step 1

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_supply_res_pv_2035_germany_mun_temp','ego_db_res_rea_by_scenario.sql',' ');  

DROP SEQUENCE IF EXISTS model_draft.ego_supply_res_pv_2035_germany_mun_id_seq;
CREATE SEQUENCE model_draft.ego_supply_res_pv_2035_germany_mun_id_seq START 1;

DROP TABLE IF EXISTS 	model_draft.ego_supply_res_pv_2035_germany_mun_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_res_pv_2035_germany_mun_temp 
		(
		  id bigint NOT NULL DEFAULT nextval('model_draft.ego_supply_pv_dev_2035_germany_mun_id_seq'::regclass),-- own id PK 
		  pv_units integer,      	-- number of PV units per mun and voltage level 
		  pv_cap_2014 integer,        	-- sum per region of 2014 in kW 
		  pv_add_cap_2035 integer,      -- sum per region of additional Capacity in 2035 kW 
		  voltage_level smallint,       -- voltage_level from 1-7   
		  rs character varying(12),	-- German Regionalschlüssel
		  pv_avg_cap integer, 		-- average capacity per region and voltage level
		  pv_new_units integer, 	-- New number per region per voltage level 
		  CONSTRAINT ego_supply_res_pv_2035_germany_mun_temp_pkey PRIMARY KEY (id)
		);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_res_pv_2035_germany_mun_temp OWNER TO oeuser;

Insert into model_draft.ego_supply_res_pv_2035_germany_mun_temp (pv_units,pv_cap_2014,voltage_level,rs,pv_avg_cap)
SELECT
  count(A.*) as pv_units,
  sum(A.electrical_capacity) as pv_cap_2014,
  A.voltage_level,
  B.rs,
  avg(A.electrical_capacity) as pv_avg_cap
FROM
  model_draft.ego_dp_supply_res_powerplant A, 
  boundaries.bkg_vg250_6_gem_rs_mview B
WHERE
  ST_Intersects(A.geom ,B.geom)
AND A.generation_type = 'solar'
AND A.scenario =   'Status Quo'
Group by A.voltage_level, B.id, B.rs;

-- Nep 2035 Photovoltaic
-- Step 2 - Photovoltaic Prox2Now per municipality and voltage level

UPDATE model_draft.ego_supply_res_pv_2035_germany_mun_temp AA
set     pv_add_cap_2035 = ( (AA.pv_cap_2014::numeric / pv_sq_2014.fs_cap_2014::numeric)*pv_scn_2035.fs_cap_2035 
                             -AA.pv_cap_2014)::integer                             
FROM
(
SELECT
 substring(A.rs from 1 for 2) as rs,          -- Regionalschlüssel first 2 numbers = federal state
 scn.capacity*1000 as fs_cap_2035 ,           -- in kW
 scn.nuts  				      -- nuts code federal state
 FROM
    boundaries.bkg_vg250_6_gem_rs_mview A,
    model_draft.ego_supply_scenario_capacities scn
WHERE scn.nuts = substring(A.nuts from 1 for 3)
AND   scn.generation_type = 'solar' 
AND scn.scenario_name = 'NEP 2035' 
Group by substring(A.nuts from 1 for 3),rs,scn.capacity,scn.nuts
Order by rs
) as pv_scn_2035,
(
SELECT
   substring(A.rs from 1 for 2) as rs,          -- Regionalschlüssel first 2 numbers = federal state
   sum(A.pv_cap_2014) as fs_cap_2014            -- in kW
FROM
  model_draft.ego_supply_res_pv_2035_germany_mun_temp A
Group by  substring(A.rs from 1 for 2) 
Order by rs
) as pv_sq_2014 
Where pv_scn_2035.rs = pv_sq_2014.rs
AND substring(AA.rs from 1 for 2) =  pv_sq_2014.rs
AND substring(AA.rs from 1 for 2) =  pv_scn_2035.rs;

-- Count new additional Units -> new_units
UPDATE model_draft.ego_supply_res_pv_2035_germany_mun_temp AA
set     pv_new_units =  round(pv_add_cap_2035/pv_avg_cap,0)::int; 

-- Control Photovoltaic development per federal state
SELECT
substring(A.rs from 1 for 2)  rs_fs,       		-- fs ID
SUM(A.pv_add_cap_2035)/1000 pv_add_cap_2035, 		-- additional Capacity in MW
sum(A.pv_cap_2014)/1000  pv_cap_2014,          		-- capacity 2014 im MW
scn.capacity_2035,                           		-- Scenario capacity 2035 in MW
(SUM(A.pv_add_cap_2035) +sum(A.pv_cap_2014))/1000 total -- in MW
FROM
 (
SELECT
  scn.nuts,
  substring(AA.rs from 1 for 2) as rs,
  scn.capacity as capacity_2035,
  scn.generation_type
FROM
  boundaries.bkg_vg250_6_gem_rs_mview AA,
  model_draft.ego_supply_scenario_capacities as scn
WHERE scn.nuts = substring(AA.nuts from 1 for 3)
AND  scn.generation_type = 'solar'
AND scn.scenario_name = 'NEP 2035' 
group by scn.nuts, substring(AA.rs from 1 for 2), substring(AA.nuts from 1 for 3),
         scn.capacity,scn.generation_type
) as scn,
 model_draft.ego_supply_res_pv_2035_germany_mun_temp A
WHERE scn.rs = substring(A.rs from 1 for 2)
Group by substring(A.rs from 1 for 2),scn.capacity_2035;

-- Take status quo and add new Photovoltaic plants 
-- Insert new units by pv_new_units 
-- geom = centroid of municipality geom , see http://postgis.net/docs/ST_Centroid.html
-- generation_subtype defined as solar

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_supply_res_pv_2035_germany_mun_temp','ego_db_res_rea_by_scenario.sql',' '); 

-- Add new PV units 
-- Step 3-4 
Insert into model_draft.ego_dp_supply_res_powerplant  (preversion,id, start_up_date,electrical_capacity,
generation_type, generation_subtype, voltage_level, source, comment,geom, scenario,flag)
        SELECT
	  'v0.3.0'::text as preversion,
	  sub2.max_rown + row_number() over () as id ,
	  '2034-12-31 00:00:00' as start_up_date,
	  sub.electrical_capacity as electrical_capacity,
	  'solar'::text as generation_type,
          'solar'::text as generation_subtype,
          sub.voltage_level,
	  'NEP 2015 for 2035'::text as  source,
	  ', Method ProxToNow solar'::text as comment, 
	  sub.geom,
	  'NEP 2035'::text as scenario,
	  'commissioning'::text as flag
	FROM (
	SELECT
	  A.rs,
	  A.voltage_level,
	  Case when A.pv_new_units = 0 Then A.pv_add_cap_2035
	       else  unnest(array_fill((A.pv_add_cap_2035/A.pv_new_units), Array[A.pv_new_units-1])) END as electrical_capacity ,    -- in kW 
	 ST_Centroid(B.geom) as geom     
	FROM 
	  model_draft.ego_supply_res_pv_2035_germany_mun_temp A,
	  boundaries.bkg_vg250_6_gem_rs_mview B
	Where A.rs = B.rs 
	) as sub ,
	(Select
	 max(id) as max_rown
	 FROM
	  model_draft.ego_dp_supply_res_powerplant
	  ) as sub2;

-- set nuts
UPDATE model_draft.ego_dp_supply_res_powerplant as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(regions.geom, upt.geom)
AND generation_type = 'solar'
AND upt.scenario =  'NEP 2035'
AND upt.nuts is null;

---
-- Offshore Wind 
-- Add NEP 2035 Wind parks from own data research
---
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_dp_supply_res_powerplant','ego_db_res_rea_by_scenario.sql',' '); 

-- 1
INSERT INTO model_draft.ego_dp_supply_res_powerplant  (preversion,id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
    'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id,
    '2034-12-31 00:00:00' as start_up_date, 
     840850, 'wind', 'wind_offshore', NULL, NULL, NULL, NULL, 1, NULL, 'ONEP', 
    'NVP: Büttel', ST_Transform('0101000020E6100000AD05BE1A878A1B40003C769B02924B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;
 -- 2
INSERT INTO model_draft.ego_dp_supply_res_powerplant  (preversion, id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
    'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id , 
    '2034-12-31 00:00:00' as start_up_date, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Segeberg', ST_Transform('0101000020E610000097549B90767B1940BD49396624894B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;
-- 3
INSERT INTO model_draft.ego_dp_supply_res_powerplant  (preversion,id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
   'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id , 
    '2034-12-31 00:00:00' as start_up_date, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Cloppenburg', ST_Transform('0101000020E6100000734ECF8CED571C40D2AE3F9F8B044B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;
-- 4
INSERT INTO model_draft.ego_dp_supply_res_powerplant  (preversion,id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
   'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id , 
    '2034-12-31 00:00:00' as start_up_date, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Cloppenburg', ST_Transform('0101000020E61000007B81CED535641940C088D9991E294B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;
-- 5
INSERT INTO model_draft.ego_dp_supply_res_powerplant (preversion,id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
   'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id , 
    '2034-12-31 00:00:00' as start_up_date, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Cloppenburg', ST_Transform('0101000020E6100000760FAC97AC3D184000CF66EFA2204B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;
-- 6
INSERT INTO model_draft.ego_dp_supply_res_powerplant  (preversion,id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
   'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id , 
    '2034-12-31 00:00:00' as start_up_date, 1188400, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Dörpen West', ST_Transform('0101000020E610000044D62300A7711B400FE3B7CDB9034B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;
-- 7
INSERT INTO model_draft.ego_dp_supply_res_powerplant  (preversion,id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
    'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id , 
    '2034-12-31 00:00:00' as start_up_date, 1800000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Emden Ost', ST_Transform('0101000020E610000083B2A1AEEAF91B40343FC1825E054B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;
-- 8
INSERT INTO model_draft.ego_dp_supply_res_powerplant  (preversion,id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
    'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id , 
    '2034-12-31 00:00:00' as start_up_date, 450000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Unterweser', ST_Transform('0101000020E6100000BAF8659652801740D869CBBDC1284B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;
-- 9
INSERT INTO model_draft.ego_dp_supply_res_powerplant  (preversion,id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
   'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id , 
    '2034-12-31 00:00:00' as start_up_date, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Wilhelmshaven 2', ST_Transform('0101000020E610000033F5B4B394751940EA0712BD2E294B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;
-- 10
INSERT INTO model_draft.ego_dp_supply_res_powerplant  (preversion,id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
   'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id , 
    '2034-12-31 00:00:00' as start_up_date, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Wilhelmshaven 2', ST_Transform('0101000020E6100000E75D445985E61740F70188073D684B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;
-- 11
INSERT INTO model_draft.ego_dp_supply_res_powerplant  (preversion,id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
     'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id , 
    '2034-12-31 00:00:00' as start_up_date, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Wilhelmshaven 2', ST_Transform('0101000020E610000046E764017AE71840ADB08899CC684B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;
-- 12
INSERT INTO model_draft.ego_dp_supply_res_powerplant  (preversion,id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
    'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id , 
    '2034-12-31 00:00:00' as start_up_date, 900000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Halbemond', ST_Transform('0101000020E610000011DD88C5680E1940A8A8439C94004B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;
-- 13
INSERT INTO model_draft.ego_dp_supply_res_powerplant  (preversion,id, start_up_date, electrical_capacity, generation_type, generation_subtype, thermal_capacity, 
 nuts, lon, lat, voltage_level, network_node, source, comment, geom, voltage_level_var, subst_id, 
 otg_id, un_id, scenario, flag)
  SELECT
   'v0.3.0'::text as preversion,
    max(id)+ row_number() over () as id , 
    '2034-12-31 00:00:00' as start_up_date, 1585000, 'wind', 'wind_offshore', NULL, NULL, NULL, 
    NULL, 1, NULL, 'ONEP', 'NVP: Lubmin', ST_Transform('0101000020E6100000C396890D74072A404ADF5A5C48744B40'::geometry,3035), 
    '380', NULL, NULL, NULL,'NEP 2035','commissioning'
  FROM model_draft.ego_dp_supply_res_powerplant;

--- 
--   Wind Onshore 
--   Use of "easy" Prox2Now Method like Photovoltaic 
/*
Step 0 Get Nuts id per Unit 
Step 1 capacity per municipality -> Pro2Now
       Status Quo
Step 2 Structure of  Wind Onshore ( volatage level, size, Number)
Step 3 add new Wind Onshore at center of municipality polygon
Step 4 add voltage level, etc.
*/

-- Step 1
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_supply_res_wo_2035_germany_mun_temp','ego_db_res_rea_by_scenario.sql',' '); 

DROP SEQUENCE IF EXISTS model_draft.ego_supply_res_wo_2035_germany_mun_id_seq CASCADE;
CREATE SEQUENCE model_draft.ego_supply_res_wo_2035_germany_mun_id_seq START 1;

DROP TABLE IF EXISTS 	model_draft.ego_supply_res_wo_2035_germany_mun_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_res_wo_2035_germany_mun_temp 
		(
		  id bigint NOT NULL DEFAULT nextval('model_draft.ego_supply_res_wo_2035_germany_mun_id_seq'::regclass),-- own id PK 
		  wo_units integer,      	-- number of onshore units per mun and voltage level 
		  wo_cap_2014 integer,        	-- sum per region of 2014 in kW 
		  wo_add_cap_2035 integer,      -- sum per region of additional Capacity in 2035 kW 
		  voltage_level smallint,       -- voltage_level from 1-7   
		  rs character varying(12),	-- German Regionalschlüssel
		  wo_avg_cap integer, 		-- average capacity per region and voltage level
		  wo_new_units integer, 	-- New number of region per voltage level 
		  CONSTRAINT ego_supply_res_wo_2035_germany_mun_temp_pkey PRIMARY KEY (id)
		);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_res_wo_2035_germany_mun_temp OWNER TO oeuser;

Insert into model_draft.ego_supply_res_wo_2035_germany_mun_temp (wo_units,wo_cap_2014,voltage_level,rs,wo_avg_cap)
SELECT
  count(A.*) as wo_units,
  sum(A.electrical_capacity) as wo_cap_2014,
  A.voltage_level,
  B.rs,
  avg(A.electrical_capacity) as wo_avg_cap
FROM
  model_draft.ego_dp_supply_res_powerplant A, 
  boundaries.bkg_vg250_6_gem_rs_mview B
WHERE
  ST_Intersects(B.geom, A.geom)
AND A.generation_type = 'wind'
AND A.generation_subtype not in ('wind_offshore')
AND scenario =   'Status Quo'
Group by A.voltage_level, B.id, B.rs;

UPDATE model_draft.ego_supply_res_wo_2035_germany_mun_temp AA
set     wo_add_cap_2035 = ( (AA.wo_cap_2014::numeric / wo_sq_2014.fs_cap_2014::numeric)*wo_scn_2035.fs_cap_2035 
                             -AA.wo_cap_2014)::integer                          
FROM
(
SELECT
 substring(A.rs from 1 for 2) as rs,        -- Regionalschlüssel first 2 numbers = federal state
 scn.capacity*1000 as fs_cap_2035 ,           -- in kW
 scn.nuts  				      -- nuts code federal state
 FROM
    boundaries.bkg_vg250_6_gem_rs_mview A,
    model_draft.ego_supply_scenario_capacities scn
WHERE scn.nuts = substring(A.nuts from 1 for 3)
AND   scn.generation_type = 'wind_onshore' 
AND   scn.scenario_name ='NEP 2035'
AND   scn.state not in ('Deutschland')
Group by substring(A.nuts from 1 for 3),rs,scn.capacity,scn.nuts
) as wo_scn_2035,
(
SELECT
   substring(A.rs from 1 for 2) as rs,        -- Regionalschlüssel first 2 numbers = federal state
   sum(A.wo_cap_2014) as fs_cap_2014            -- in kW
FROM
  model_draft.ego_supply_res_wo_2035_germany_mun_temp A
Group by  substring(A.rs from 1 for 2) 
) as wo_sq_2014
Where wo_scn_2035.rs = wo_sq_2014.rs
AND substring(AA.rs from 1 for 2) =  wo_sq_2014.rs
AND substring(AA.rs from 1 for 2) =  wo_scn_2035.rs;

-- clean zero values
DELETE FROM model_draft.ego_supply_res_wo_2035_germany_mun_temp WHERE wo_add_cap_2035 <=0;

-- Count new additional Units -> new_units
UPDATE model_draft.ego_supply_res_wo_2035_germany_mun_temp AA
     set wo_new_units =  round(wo_add_cap_2035/wo_avg_cap,0)::int; 

-- Control wind onshore development 
SELECT
scn.state,
substring(A.rs from 1 for 2)  rs_fs,       		-- fs ID
SUM(A.wo_add_cap_2035)/1000 wo_add_cap_2035, 		-- additional Capacity in MW
sum(A.wo_cap_2014)/1000  wo_cap_2014,          		-- capacity 2014 im MW
scn.capacity_2035,                           		-- Scenario capacity 2035 in MW
(SUM(A.wo_add_cap_2035) +sum(A.wo_cap_2014))/1000 total -- in MW
FROM
 (
SELECT 
  scn.state,
  scn.nuts,
  substring(AA.rs from 1 for 2) as rs,
  scn.capacity as capacity_2035,
  scn.generation_type
FROM
  boundaries.bkg_vg250_6_gem_rs_mview AA,
  model_draft.ego_supply_scenario_capacities as scn
WHERE scn.nuts = substring(AA.nuts from 1 for 3)
AND  scn.generation_type = 'wind_onshore'
AND   scn.scenario_name ='NEP 2035'
group by scn.nuts, substring(AA.rs from 1
 for 2), substring(AA.nuts from 1 for 3),
         scn.capacity,scn.generation_type, scn.state
) as scn,
 model_draft.ego_supply_res_wo_2035_germany_mun_temp A
WHERE scn.rs = substring(A.rs from 1 for 2)
Group by substring(A.rs from 1 for 2),scn.capacity_2035, scn.state
Order by scn.state;

-- set nuts
UPDATE model_draft.ego_dp_supply_res_powerplant as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(regions.geom, upt.geom)
AND generation_subtype = 'wind_onshore'
AND upt.nuts IS NULL;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_supply_res_wo_2035_germany_mun_temp','ego_db_res_rea_by_scenario.sql',' '); 

-- Add new wind onshore units 
Insert into model_draft.ego_dp_supply_res_powerplant (preversion,id,start_up_date,electrical_capacity,
            generation_type, generation_subtype, voltage_level, source, comment,geom, scenario,flag)
	SELECT
	  'v0.3.0'::text as preversion,
	  sub2.max_rown + row_number() over () as id ,
	  '2034-12-31 00:00:00' as start_up_date,
	  sub.electrical_capacity,
	  'wind'::text as generation_type,
	  'wind_onshore'::text as generation_subtype,
	  sub.voltage_level,
	  'NEP 2015 scenario B2035'::text as  source,
	  'Method ProxToNow wind onshore'::text as comment, 
	  sub.geom,
	  'NEP 2035'::text as scenario,
	  'commissioning'::text as flag
	FROM (
	SELECT
	  A.rs,
	  A.voltage_level,
	  Case when A.wo_new_units = 0 Then A.wo_add_cap_2035
	       else  unnest(array_fill((A.wo_add_cap_2035/A.wo_new_unit), Array[A.wo_new_units])) END as electrical_capacity ,    -- in kW 
	 ST_Centroid(B.geom) as geom     
	FROM 
	  model_draft.ego_supply_res_wo_2035_germany_mun_temp A,
	  boundaries.bkg_vg250_6_gem_rs_mview B
	Where A.rs = B.rs
	) as sub ,
	(Select
	 max(id) as max_rown
	 FROM
	  model_draft.ego_dp_supply_res_powerplant
	  ) as sub2 ;
	  
-- set nuts
UPDATE model_draft.ego_dp_supply_res_powerplant as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(regions.geom, upt.geom)
AND generation_subtype = 'wind_onshore'
AND scenario ='NEP 2035';

---
-- Delete section
-- Drop temps
DROP TABLE IF EXISTS model_draft.ego_supply_res_biomass_2035_temp CASCADE;
DROP TABLE IF EXISTS model_draft.ego_supply_res_pv_to_region_temp CASCADE;
DROP TABLE IF EXISTS model_draft.ego_supply_res_wo_2035_germany_mun_temp CASCADE;
DROP TABLE IF EXISTS model_draft.ego_supply_res_hydro_2035_temp CASCADE;
DROP TABLE IF EXISTS model_draft.ego_supply_res_pv_to_region_temp  CASCADE;
DROP TABLE IF EXISTS model_draft.ego_supply_res_pv_2035_germany_mun_temp  CASCADE;

-- VACUUM FULL ANALYZE model_draft.ego_dp_supply_res_powerplant;
	  
--------------------------------------------------------------------------------
-- Part III 
--          Develop renewable allocation by generation type, voltage level
--	    and municipality. Scenarios: ego-100RES	
--------------------------------------------------------------------------------

---
-- Biomass power plants
---
-- eGo 100 Biomass
DROP TABLE IF EXISTS 	model_draft.ego_supply_res_biomass_2050_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_res_biomass_2050_temp AS
	SELECT * 
	FROM 
	  model_draft.ego_dp_supply_res_powerplant
	WHERE
	generation_type = 'biomass'
	AND scenario in ( 'Status Quo');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_dp_supply_res_powerplant','ego_db_res_rea_by_scenario.sql',' ');  

-- Biomass Method Prox2Now
-- increase installed capacity by scenario data
-- No changes of voltage level or additional units

UPDATE model_draft.ego_supply_res_biomass_2050_temp as upt
set comment = upt.comment || ', Method ProxToNow Biomass',
    source = 'open_ego 2050',
    scenario = 'eGo 100' ,
    flag = 'repowering',
    preversion = 'v0.3.0'::text,
    electrical_capacity = CASE WHEN scn.capacity = 0 THEN 0 
	  ELSE (upt.electrical_capacity/ cap_sum)*scn.capacity*1000    
	 END 
FROM
  model_draft.ego_supply_scenario_capacities as scn,
  (SELECT 'DE'::text as nuts, sum(electrical_capacity) as cap_sum
   FROM  model_draft.ego_dp_supply_res_powerplant 
   WHERE generation_type = 'biomass'
   AND scenario in ( 'Status Quo')
   ) count
WHERE scn.nuts = substring(count.nuts from 1 for 2)
AND   scn.nuts = substring(upt.nuts from 1 for 2)
AND   substring(upt.nuts from 1 for 2) = substring(count.nuts from 1 for 2)
AND   scn.generation_type = 'biomass'
AND   scn.scenario_name = 'eGo 100' ;

-- create index GIST (geom)
CREATE INDEX ego_supply_res_biomass_2050_temp_geom_idx
	ON model_draft.ego_supply_res_biomass_2050_temp USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_res_biomass_2050_temp OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_dp_supply_res_powerplant','ego_db_res_rea_by_scenario.sql',' ');  

-- Insert ego_dp_supply_res_powerplant
Insert into model_draft.ego_dp_supply_res_powerplant
  SELECT
    *
  FROM
      model_draft.ego_supply_res_biomass_2050_temp
  WHERE  scenario = 'eGo 100';
  
--- 
-- Geothermal Method
-- No changes set status quo
---

--- 
-- CHP Method
-- No Units set all NULL
---
DROP TABLE IF EXISTS 	model_draft.ego_supply_res_chp_2050_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_res_chp_2050_temp AS
	SELECT * 
	FROM 
	  model_draft.ego_dp_supply_res_powerplant
	WHERE
	comment = 'KWK_NEP_2035_distribution'
	AND scenario = 'NEP 2035';

Update model_draft.ego_supply_res_chp_2050_temp
 set scenario =  'eGo 100',
     flag = 'decommissioning',
     start_up_date = '2034-12-31 00:00:00',
     preversion = 'v0.3.0'::text,
     electrical_capacity = 0;  

-- create index GIST (geom)
CREATE INDEX ego_supply_res_chp_2050_temp_geom_idx
	ON model_draft.ego_supply_res_chp_2050_temp USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_res_chp_2050_temp OWNER TO oeuser;

Insert into model_draft.ego_dp_supply_res_powerplant
	SELECT *
	FROM model_draft.ego_supply_res_chp_2050_temp
	WHERE scenario =  'eGo 100';

--- 
-- Hydro / run_of_river
-- Repowering Units from NEP 2035 Scenario
---

DROP TABLE IF EXISTS 	model_draft.ego_supply_res_hydro_2050_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_res_hydro_2050_temp AS
	SELECT * 
	FROM 
	  model_draft.ego_dp_supply_res_powerplant
	WHERE
	generation_subtype = 'hydro'
	AND scenario in ('NEP 2035');

-- create index GIST (geom)
CREATE INDEX ego_supply_res_hydro_2050_temp_geom_idx
	ON model_draft.ego_supply_res_hydro_2050_temp USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_res_hydro_2050_temp OWNER TO oeuser;

-- Repowering units by Pro2Now
UPDATE model_draft.ego_supply_res_hydro_2050_temp as upt
set comment = upt.comment || ', Method ProxToNow Hydro',
    source = 'open_ego 100',
    scenario =  'eGo 100',
    flag = 'repowering',
    preversion = 'v0.3.0'::text,
    electrical_capacity = CASE WHEN scn.capacity = 0 THEN upt.electrical_capacity
	  ELSE (upt.electrical_capacity/ cap_sum)*scn.capacity*1000    
	 END 
FROM
  model_draft.ego_supply_scenario_capacities as scn,
  (SELECT 'DE'::text as nuts,  sum(electrical_capacity) as cap_sum
   FROM model_draft.ego_supply_res_hydro_2050_temp
   WHERE generation_subtype = 'hydro'
   ) count
WHERE scn.nuts = substring(count.nuts from 1 for 2)
AND   scn.nuts = substring(upt.nuts from 1 for 2)
AND   substring(upt.nuts from 1 for 2) = substring(count.nuts from 1 for 2)
AND   scn.generation_type = 'run_of_river' 
AND   upt.generation_subtype = 'hydro'
AND   scn.scenario_name = 'eGo 100';

-- insert data
Insert into model_draft.ego_dp_supply_res_powerplant
	SELECT *
	FROM  model_draft.ego_supply_res_hydro_2050_temp
	WHERE scenario =  'eGo 100';
---
-- Photovoltaic Methode 
--- 

/*
Step 0 Create temp temp 
Step 1 capacity per municipality -> Pro2Now
       Status Quo
Step 2 Structure of PV ( voltage level, size, Number)
Step 3 add new PV at center of municipality polygon
Step 4 add volatage level, etc.
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_supply_res_pv_to_region_temp','ego_db_res_rea_by_scenario.sql',' ');  

-- eGo 100 Photovoltaic
-- Step 0
DROP TABLE IF EXISTS 	model_draft.ego_supply_res_pv_to_region_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_res_pv_to_region_temp 
		(
		re_id bigint NOT NULL,   	-- id from renewable_power_plants
		subst_id bigint,      		
		otg_id bigint,        		 
		un_id bigint,         		
		nuts character varying(5),	 
		rs character varying(12),	-- German Regionalschlüssel
		id_vg250 bigint, 		-- ID of boundaries.bkg_vg250_6_gem_rs_mview table
		CONSTRAINT ego_supply_res_pv_to_region_temp_pkey PRIMARY KEY (re_id)
		);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_res_pv_to_region_temp OWNER TO oeuser;

INSERT INTO model_draft.ego_supply_res_pv_to_region_temp (re_id,subst_id,otg_id,un_id)
	SELECT
	  id as re_id,
	  subst_id,
	  otg_id,
	  un_id
	FROM
	  model_draft.ego_dp_supply_res_powerplant
	WHERE scenario in ( 'Status Quo','NEP 2035')
	AND generation_type = 'solar' 
	AND flag in ('commissioning','constantly');

Update model_draft.ego_supply_res_pv_to_region_temp A
set id_vg250 = B.id,
    rs = B.rs,
    nuts = B.nuts
FROM (
	SELECT
	D.id as re_id,
	C.id,
	C.rs,
	C.nuts    
	FROM boundaries.bkg_vg250_6_gem_rs_mview C,
	     model_draft.ego_dp_supply_res_powerplant D
	WHERE ST_Intersects(C.geom, D.geom)
      ) as B
WHERE B.re_id = A.re_id;

-- Get nuts ID by buffering geometry 
Update model_draft.ego_supply_res_pv_to_region_temp A
set id_vg250 = C.id,
    rs = C.rs,
    nuts = C.nuts
FROM
   (
	SELECT
	  A.re_id,
	  B.geom
	FROM
	  model_draft.ego_supply_res_pv_to_region_temp A,
	  model_draft.ego_dp_supply_res_powerplant B
	WHERE A.re_id = B.id
	AND A.nuts IS NULL 
  ) as AA,
  boundaries.bkg_vg250_6_gem_rs_mview C
WHERE ST_Intersects(C.geom, ST_Buffer(AA.geom,1000))
AND AA.re_id = A.re_id;

---
-- ego 100 Photovoltaic
-- Step 1
---

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_supply_res_pv_2050_germany_mun_temp','ego_db_res_rea_by_scenario.sql',' ');  

DROP SEQUENCE IF EXISTS model_draft.ego_supply_res_pv_2050_germany_mun_id_seq CASCADE;
CREATE SEQUENCE model_draft.ego_supply_res_pv_2050_germany_mun_id_seq START 1;

DROP TABLE IF EXISTS 	model_draft.ego_supply_res_pv_2050_germany_mun_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_res_pv_2050_germany_mun_temp 
		(
		  id bigint NOT NULL DEFAULT nextval('model_draft.ego_supply_res_pv_2050_germany_mun_id_seq'::regclass),-- own id PK 
		  pv_units integer,      	-- number of PV units per mun and voltage level 
		  pv_cap_2035 integer,        	-- sum per region of 2014 in kW 
		  pv_add_cap_2050 integer,      -- sum per region of additional Capacity in 2035 kW 
		  voltage_level smallint,       -- voltage_level from 1-7   
		  rs character varying(12),	-- German Regionalschlüssel
		  pv_avg_cap integer, 		-- average capacity per region and voltage level
		  pv_new_units integer, 	-- New number of region per voltage level 
		  CONSTRAINT ego_supply_res_pv_2050_germany_mun_temp_pkey PRIMARY KEY (id)
		);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_res_pv_2050_germany_mun_temp OWNER TO oeuser;

Insert into model_draft.ego_supply_res_pv_2050_germany_mun_temp (pv_units,pv_cap_2035,voltage_level,rs,pv_avg_cap)
SELECT
  count(A.*) as pv_units,
  sum(A.electrical_capacity) as pv_cap_2035,
  A.voltage_level,
  B.rs,
  avg(A.electrical_capacity) as pv_avg_cap
FROM
  model_draft.ego_dp_supply_res_powerplant A, 
  boundaries.bkg_vg250_6_gem_rs_mview B
WHERE
  ST_Intersects(B.geom, A.geom)
AND A.generation_type = 'solar'
AND A.scenario in (  'Status Quo','NEP 2035')
AND A.flag in ('commissioning','constantly')
Group by A.voltage_level, B.id, B.rs;

---
-- ego 100 Photovoltaic
-- Step 2 - Photovoltaic Prox2Now per municipality and voltage level
---

UPDATE model_draft.ego_supply_res_pv_2050_germany_mun_temp AA
set     pv_add_cap_2050 = ( (AA.pv_cap_2035::numeric / pv_sq_2035.fs_cap_2035::numeric)*pv_scn_2050.fs_cap_2050 
                             -AA.pv_cap_2035)::integer
FROM
(
SELECT
 scn.capacity*1000 as fs_cap_2050 ,           -- in kW
 scn.nuts  				      -- nuts code
 FROM
   boundaries.bkg_vg250_6_gem_rs_mview A,
    model_draft.ego_supply_scenario_capacities scn
WHERE scn.nuts = substring(A.nuts from 1 for 2)
AND   scn.generation_type = 'solar' 
AND   scn.scenario_name = 'eGo 100'
Group by fs_cap_2050 ,scn.nuts
) as pv_scn_2050,
(
SELECT
   sum(A.pv_cap_2035) as fs_cap_2035            -- in kW
FROM
  model_draft.ego_supply_res_pv_2050_germany_mun_temp A
) as pv_sq_2035;

-- Count new additional Units -> new_units
UPDATE model_draft.ego_supply_res_pv_2050_germany_mun_temp
  set pv_new_units =  CASE WHEN pv_add_cap_2050 = 0 Then pv_add_cap_2050 ELSE round(pv_add_cap_2050/pv_avg_cap,0)::int END; 

-- Control Photovoltaic development 
SELECT
sum(A.pv_add_cap_2050)/1000 pv_add_cap_2035, 		-- additional Capacity in MW
sum(A.pv_cap_2035)/1000  pv_cap_2035,          		-- capacity 2035 im MW
scn.capacity_2050,                           		-- Scenario capacity 2050 in MW
(sum(A.pv_add_cap_2050) +sum(A.pv_cap_2035))/1000 total -- in MW
FROM
 (
SELECT
  scn.nuts,
  scn.capacity as capacity_2050,
  scn.generation_type
FROM
  boundaries.bkg_vg250_6_gem_rs_mview AA,
  model_draft.ego_supply_scenario_capacities as scn
WHERE scn.generation_type = 'solar'
AND   scn.scenario_name = 'eGo 100'
group by scn.nuts,  substring(AA.nuts from 1 for 2),
         scn.capacity,scn.generation_type
) as scn,
 model_draft.ego_supply_res_pv_2050_germany_mun_temp A
Group by scn.capacity_2050;

-- set nuts
UPDATE model_draft.ego_dp_supply_res_powerplant as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(regions.geom, upt.geom)
AND generation_type = 'solar'
AND upt.scenario in (  'Status Quo','NEP 2035')
AND upt.nuts IS NULL;

-- Take status quo and add new Photovoltaic plants 
-- Insert new units by pv_new_units 
-- geom = centroid of municipality geom , see http://postgis.net/docs/ST_Centroid.html
-- generation_subtype is defined as solar

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_supply_res_pv_2050_germany_mun_temp','ego_db_res_rea_by_scenario.sql',' '); 

-- Add new PV units 
Insert into model_draft.ego_dp_supply_res_powerplant (preversion,id,start_up_date, electrical_capacity,
generation_type, generation_subtype, voltage_level, source, comment,geom, scenario,flag)

        SELECT
	  'v0.3.0'::text as preversion,
	  sub2.max_rown + row_number() over () as id ,
	  '2050-12-31 00:00:00' as start_up_date,
	  sub.electrical_capacity as electrical_capacity,
	  'solar'::text as generation_type,
          'solar'::text  as generation_subtype,
          sub.voltage_level,
	  'open_ego 100'::text as  source,
	  ', Method ProxToNow solar'::text as comment, 
	  sub.geom,
	  'eGo 100'::text as scenario,
	  'commissioning'::text as flag
	FROM (
	SELECT
	  A.rs,
	  A.voltage_level,
	  Case when A.pv_new_units = 0 Then A.pv_add_cap_2050
	       else  unnest(array_fill((A.pv_add_cap_2050/A.pv_new_units), Array[A.pv_new_units])) END as electrical_capacity ,    -- in kW 
	 ST_Centroid(B.geom) as geom     
	FROM 
	  model_draft.ego_supply_res_pv_2050_germany_mun_temp A,
	  boundaries.bkg_vg250_6_gem_rs_mview B
	Where A.rs = B.rs
	) as sub ,
	(Select
	 max(id) as max_rown
	 FROM
	  model_draft.ego_dp_supply_res_powerplant
	  ) as sub2;

-- set nuts
UPDATE model_draft.ego_dp_supply_res_powerplant as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(regions.geom, upt.geom)
AND generation_type = 'solar'
AND upt.nuts is NULL;

---
-- Wind offshore eGo 100
---

DROP TABLE IF EXISTS 	model_draft.ego_supply_res_woff_2050_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_res_woff_2050_temp AS
	SELECT * 
	FROM 
	  model_draft.ego_dp_supply_res_powerplant
	WHERE
	generation_subtype = 'wind_offshore'
	AND scenario in ('Status Quo','NEP 2035');

-- create index GIST (geom)
CREATE INDEX ego_supply_res_woff_2050_temp_geom_idx
	ON model_draft.ego_supply_res_woff_2050_temp USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_res_woff_2050_temp OWNER TO oeuser;

-- Repowering units by Pro2Now
UPDATE model_draft.ego_supply_res_woff_2050_temp as scn2050
set source   = 'open_ego 2050',
    scenario = 'eGo 100',
    flag     = 'repowering',
    preversion  = 'v0.3.0'::text,
    electrical_capacity = scn2050.electrical_capacity + round(scn2050.electrical_capacity*q1.pp) 
From
(
Select (scn.capacity*1000 - sum(base.electrical_capacity))/(scn.capacity*1000) as pp
From
      model_draft.ego_supply_scenario_capacities as scn,
      model_draft.ego_supply_res_woff_2050_temp as base
Where scn.generation_type = 'wind_offshore' 
And  scn.scenario_name = 'eGo 100'
And  base.generation_subtype = 'wind_offshore'
Group by scn.capacity
) as q1
WHERE 
scn2050.generation_subtype = 'wind_offshore';

Insert into model_draft.ego_dp_supply_res_powerplant
	SELECT *
	FROM model_draft.ego_supply_res_woff_2050_temp
	WHERE scenario =  'eGo 100';

--- 
--  Wind Onshore 
--  Use of "easy" Prox2Now Method like Photovoltaic
--- 
/*
Step 0 Get Nuts id per Unit 
Step 1 capacity per municipality -> Pro2Now
       Status Quo
Step 2 Structure of  Wind Onshore ( volatage level, size, Number)
Step 3 add new Wind Onshore at center of municipality polygon
Step 4 add voltage level, etc.
*/

-- Step 1
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','ego_supply_res_wo_2050_germany_mun_temp','ego_db_res_rea_by_scenario.sql',' '); 

DROP SEQUENCE IF EXISTS model_draft.ego_supply_res_wo_2050_germany_mun_id_seq CASCADE;
CREATE SEQUENCE model_draft.ego_supply_res_wo_2050_germany_mun_id_seq START 1;

DROP TABLE IF EXISTS 	model_draft.ego_supply_res_wo_2050_germany_mun_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_res_wo_2050_germany_mun_temp 
		(
		  id bigint NOT NULL DEFAULT nextval('model_draft.ego_supply_res_wo_2050_germany_mun_id_seq'::regclass),-- own id PK 
		  wo_units integer,      	-- number of onshore units per mun and voltage level 
		  wo_cap_2035 integer,        	-- sum per region of 2035 in kW 
		  wo_add_cap_2050 integer,      -- sum per region of additional Capacity in 2050 kW 
		  voltage_level smallint,       -- voltage_level from 1-7   
		  rs character varying(12),	-- German Regionalschlüssel
		  wo_avg_cap integer, 		-- average capacity per region and voltage level
		  wo_new_units integer, 	-- New number of region per voltage level 
		  CONSTRAINT ego_supply_res_wo_2050_germany_mun_temp_pkey PRIMARY KEY (id)
		);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_res_wo_2050_germany_mun_temp OWNER TO oeuser;

Insert into model_draft.ego_supply_res_wo_2050_germany_mun_temp (wo_units, wo_cap_2035, voltage_level,rs,wo_avg_cap)
SELECT
  count(A.*) as wo_units,
  sum(A.electrical_capacity) as wo_cap_2035,
  A.voltage_level,
  B.rs,
  avg(A.electrical_capacity) as wo_avg_cap
FROM
  model_draft.ego_dp_supply_res_powerplant A, 
  boundaries.bkg_vg250_6_gem_rs_mview B
WHERE
  ST_Intersects(B.geom, A.geom)
AND A.generation_type = 'wind'
AND A.generation_subtype not in('wind_offshore')
AND scenario in (  'Status Quo','NEP 2035')
AND A.flag in ('commissioning','constantly')
Group by A.voltage_level, B.id, B.rs;


UPDATE model_draft.ego_supply_res_wo_2050_germany_mun_temp AA
set     wo_add_cap_2050 = ((AA.wo_cap_2035::numeric / wo_sq_2035.fs_cap_2035::numeric)*wo_scn_2050.fs_cap_2050 
                             -AA.wo_cap_2035)::integer                  
FROM
(
SELECT
 scn.capacity*1000 as fs_cap_2050 ,           -- in kW
 scn.nuts  				      -- nuts code federal state
 FROM
    boundaries.bkg_vg250_6_gem_rs_mview A,
    model_draft.ego_supply_scenario_capacities scn
WHERE scn.nuts = substring(A.nuts from 1 for 2)
AND   scn.generation_type = 'wind_onshore' 
And   scn.scenario_name = 'eGo 100'
Group by substring(A.nuts from 1 for 2),scn.capacity,scn.nuts
) as wo_scn_2050,
(
SELECT
   sum(A.wo_cap_2035) as fs_cap_2035            -- in kW
FROM
  model_draft.ego_supply_res_wo_2050_germany_mun_temp A
) as wo_sq_2035;

-- clean zero values
DELETE FROM model_draft.ego_supply_res_wo_2050_germany_mun_temp WHERE wo_add_cap_2050 <=0;

-- Count new additional Units -> new_units
UPDATE model_draft.ego_supply_res_wo_2050_germany_mun_temp AA
     set wo_new_units =  round(wo_add_cap_2050/wo_avg_cap); 

-- Control wind onshore development 
SELECT
scn.state,
SUM(A.wo_add_cap_2050)/1000 wo_add_cap_2050, 		-- additional Capacity in MW
sum(A.wo_cap_2035)/1000  wo_cap_2035,          		-- capacity 2035 im MW
scn.capacity_2050,                           		-- Scenario capacity 2050 in MW
(SUM(A.wo_add_cap_2050) +sum(A.wo_cap_2035))/1000 total -- in MW
FROM
 (
SELECT 
  scn.state,
  scn.nuts,
  scn.capacity as capacity_2050,
  scn.generation_type
FROM
  boundaries.bkg_vg250_6_gem_rs_mview AA,
  model_draft.ego_supply_scenario_capacities as scn
WHERE scn.nuts = substring(AA.nuts from 1 for 2)
AND  scn.generation_type = 'wind_onshore'
And  scn.scenario_name = 'eGo 100'
group by scn.nuts, substring(AA.nuts from 1 for 2),
         scn.capacity,scn.generation_type, scn.state
) as scn,
 model_draft.ego_supply_res_wo_2050_germany_mun_temp A
Group by scn.capacity_2050, scn.state
Order by scn.state;

-- set nuts
UPDATE model_draft.ego_dp_supply_res_powerplant as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(regions.geom, upt.geom)
AND generation_subtype = 'wind_onshore'
AND upt.nuts is Null;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_supply_res_wo_2050_germany_mun_temp','ego_db_res_rea_by_scenario.sql',' '); 

-- Add new wind shore units 
Insert into model_draft.ego_dp_supply_res_powerplant (preversion,id,start_up_date, electrical_capacity,
            generation_type, generation_subtype, voltage_level, source, comment,geom,scenario,flag)
	SELECT
	  'v0.3.0'::text as preversion,
	  sub2.max_rown + row_number() over () as id ,
	  '2049-12-31 00:00:00' as start_up_date,
	  sub.electrical_capacity,
	  'wind'::text as generation_type,
	  'wind_onshore'::text as generation_subtype,
	  sub.voltage_level,
	  'open_ego 100'::text as  source,
	  'Method ProxToNow wind onshore'::text as comment, 
	  sub.geom,
	  'eGo 100'::text as scenario,
	  'commissioning'::text as flag
	FROM (
	SELECT
	  A.rs,
	  A.voltage_level,
	  Case when A.wo_new_units = 0 Then A.wo_add_cap_2050
	       else  unnest(array_fill((A.wo_add_cap_2050/A.wo_new_units), Array[A.wo_new_units])) END as electrical_capacity ,    -- in kW 
	 ST_Centroid(B.geom) as geom     
	FROM 
	  model_draft.ego_supply_res_wo_2050_germany_mun_temp A,
	  boundaries.bkg_vg250_6_gem_rs_mview B
	Where A.rs = B.rs
	) as sub ,
	(Select
	 max(id) as max_rown
	 FROM
	  model_draft.ego_dp_supply_res_powerplant
	  ) as sub2 ;

-- set nuts
UPDATE model_draft.ego_dp_supply_res_powerplant as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(regions.geom, upt.geom)
AND generation_subtype = 'wind_onshore'
And upt.nuts is null;

-- Change geom to SRID 4326
ALTER TABLE  model_draft.ego_dp_supply_res_powerplant
  ALTER COLUMN geom TYPE geometry(Point, 4326)
    USING ST_Transform(ST_SetSRID(geom,3035),4326);

-- reset values
Update model_draft.ego_dp_supply_res_powerplant
  set   rea_sort = NULL,
        rea_flag = NULL,
	rea_geom_line = NULL,
	rea_geom_new = NULL;

-- VACUUM FULL ANALYZE model_draft.ego_dp_supply_res_powerplant;
-- MView for scenarios in dataprocessing/sql_snippets/ego_dp_powerflow_create_pp_mview.sql
