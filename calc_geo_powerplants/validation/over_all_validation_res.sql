﻿/*
SQL Script in order to make an over all validation of the RES future allogation
           as well as for the conventional power plants.
           
__copyright__ = "Europa-Universität Flensburg, Fachhochschule Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

*/

--------------------------------------------------------------------------------

/*
   Overview of Validation Queries:
   -------------------------------
	1.) Check installed capacity and number of units of RES units by scenario

	
   Overview of db tables:
   ----------------------
	model_draft.ego_supply_res_powerplant 
	model_draft.ego_supply_res_powerplant_2035 
	model_draft.ego_supply_res_powerplant_2050

*/


-- Info Box
-- https://www.wind-energie.de/themen/offshore
-- onshore und offshore wind vergleichen!!!



--supply.ego_renewable_powerplant

-- check if all units are located in grid districts

SELECT DISTINCT
  count(res.geom)
FROM 
 supply.ego_renewable_powerplant res, 
(
	SELECT
	 St_Transform(geom,4326) as geom
	FROM grid.ego_dp_lv_griddistrict
) as grid
Where
  ST_Within(res.geom, grid.geom)
  
AND 
  res.generation_subtype != 'wind_offshore'




SELECT DISTINCT
  count(geom),
  generation_subtype
  FROM
 supply.ego_renewable_powerplant 
Where 
generation_subtype not in ('wind_offshore')

Group by generation_subtype


1.608.590
1.204.716


-- Plots 
SELECT
 state.gen fs_name,
 sum(res.electrical_capacity) sum_cap,
 res.generation_type,
 state.geom
FROM
  political_boundary.bkg_vg250_2_lan_mview state,
  supply.ego_renewable_powerplant res
Where 
  ST_Intersects(St_Transform(res.geom,3035),state.geom)
Group by state.gen,res.generation_type, state.geom
;


Limit 1

-- Check installed capacity and number of units of RES units by scenario

SELECT Distinct 
	A.generation_type,
	A.sum_sq,
	A.num_sq,
	B.generation_type,
	B.sum_2035,
	B.num_2035,
	C.generation_type,
	C.sum_2050,
	C.num_2050
FROM
(
	SELECT
		generation_type,
		round(sum(electrical_capacity)/1000000,2) as sum_sq, -- in GW
		count(*) as num_sq
	FROM
		model_draft.ego_supply_res_powerplant
	Group by generation_type
	Order by generation_type
) as A,
(
	SELECT
		generation_type ,
		round(sum(electrical_capacity)/1000000,2) as sum_2035, -- in GW
		count(*) as num_2035
	FROM
		model_draft.ego_supply_res_powerplant_2035
	Group by generation_type
	Order by generation_type
) as B ,
(
	SELECT
		generation_type ,
		round(sum(electrical_capacity)/1000000,2) as sum_2050, -- in GW
		count(*) as num_2050
	FROM
		model_draft.ego_supply_res_powerplant_2050
	Group by generation_type
	Order by generation_type
) as C
Where  A.generation_type = B.generation_type
And    C.generation_type = A.generation_type
Group by A.generation_type, B.generation_type, C.generation_type, A.sum_sq, A.num_sq, B.sum_2035, B.num_2035,C.sum_2050,C.num_2050
Order by A.generation_type
;

-- SQ data
SELECT
		generation_type,
		generation_subtype,
		round(sum(electrical_capacity)/1000000,2) as sum_sq, -- in GW
		count(*) as num_sq
	FROM
		model_draft.ego_supply_res_powerplant
	Group by generation_type, generation_subtype
	Order by generation_type;

-- 2035 data
SELECT
		generation_type ,
		generation_subtype,
		round(sum(electrical_capacity)/1000000,2) as sum_2035, -- in GW
		count(*) as num_2035
	FROM
		model_draft.ego_supply_res_powerplant_2035
	Group by generation_type, generation_subtype
	Order by generation_type;

-- 2050
SELECT
		generation_type ,
		generation_subtype,
		round(sum(electrical_capacity)/1000000,2) as sum_2050, -- in GW
		count(*) as num_2050
	FROM
		model_draft.ego_supply_res_powerplant_2050
	Group by generation_type  , generation_subtype
	Order by generation_type;

--- Overview 2035
SELECT 
	--state,
	generation_type,
	sum(capacity) as cap_2035
FROM orig_scenario_data.nep_2015_scenario_capacities
Where scenario_name ='B12035/B22035'
AND state != 'Deutschland'
Group by generation_type--, state
Order by generation_type;
--- Overview 2050
SELECT 
	state,
	generation_type,
	sum(capacity) as cap_2035
FROM orig_scenario_data.nep_2015_scenario_capacities
Where scenario_name ='ego-100-2050'
Group by generation_type, state
Order by generation_type;


----- -----------------------------------------------------------  
-- CHECK Wind onshore
---- ------------------------------------------------------------
SELECT
source,
sum(electrical_capacity),
count(*)
	FROM
		model_draft.ego_supply_res_powerplant_2035
	Where   generation_type	='wind'
	AND     generation_subtype ='wind_onshore'
	AND     source ='open_ego NEP 2015 B2035'
	Group by source
	Order by source;
--
SELECT
min(electrical_capacity),
max(electrical_capacity),
count(*)
	FROM
		model_draft.ego_supply_res_powerplant_2035
	Where   generation_type	='wind'
	AND     generation_subtype ='wind_onshore'
	AND     source ='open_ego NEP 2015 B2035'
	Group by source
	Order by source;

-- Clean up small units
-- wind onshore
SELECT
source,
count(*),
round(sum(electrical_capacity)/1000000,2)
FROM
	model_draft.ego_supply_res_powerplant_2035
Where   generation_type	='wind'
AND     generation_subtype ='wind_onshore'
AND     source ='open_ego NEP 2015 B2035'
and     electrical_capacity <= 1000
Group by source
Order by source;

-- solar
SELECT
source,
count(*),
round(sum(electrical_capacity)/1000000,2)
FROM
	model_draft.ego_supply_res_powerplant_2035
Where   generation_type	='solar'
AND     source ='open_ego NEP 2015 B2035'
AND      electrical_capacity >= 1150
Group by source
Order by source;

-- 2050 
-- solar

SELECT
--source,
count(*),
round(sum(electrical_capacity)/1000000,2)
FROM
	model_draft.ego_supply_res_powerplant_2050
Where   generation_type	='solar'
--AND     source ='open_ego NEP 2015 B2035'
--AND 	  source = 'open_ego 2050'
--AND     electrical_capacity <= 8
--AND     electrical_capacity >= 1150
Group by source
Order by source;
--
-- Wind
SELECT
generation_subtype,
count(*),
round(sum(electrical_capacity)/1000000,2)
FROM
	model_draft.ego_supply_res_powerplant_2050
Where   generation_type	='wind'
AND     generation_subtype ='wind_onshore'
--AND     source ='open_ego NEP 2015 B2035'
AND	 source ='open_ego 2050'
AND     electrical_capacity <= 1300
Group by generation_subtype 
--source--Order by source;

SELECT
source,
round(sum(electrical_capacity)/1000000,2)
FROM model_draft.ego_supply_res_powerplant_2050
Where     generation_subtype ='wind_onshore'
Group by source 

--- ------------------------------------------------------------
--- Clean Part 2035
-- wind_onshore
DELETE
FROM  model_draft.ego_supply_res_powerplant_2035
Where   generation_type	='wind'
AND     generation_subtype ='wind_onshore'
AND     source ='open_ego NEP 2015 B2035'
and     electrical_capacity <= 1000; 
-- solar
DELETE
FROM  model_draft.ego_supply_res_powerplant_2035
Where   generation_type	='solar'
AND     source ='open_ego NEP 2015 B2035'
AND      electrical_capacity >= 1150;
--- -------------------------------------------------------------
--- Clean Part 2050
-- solar
DELETE
FROM  model_draft.ego_supply_res_powerplant_2050
Where   generation_type	='solar'
AND     source ='open_ego NEP 2015 B2035'
AND      electrical_capacity >= 1150;
--
DELETE
FROM  model_draft.ego_supply_res_powerplant_2050
Where   generation_type	='solar'
AND     source = 'open_ego 2050'
AND     electrical_capacity  <= 8;
--
DELETE
FROM  model_draft.ego_supply_res_powerplant_2050
Where   generation_type	='solar'
AND     source = 'open_ego 2050'
AND     electrical_capacity >= 1150;
-- wind onshore
DELETE
FROM  model_draft.ego_supply_res_powerplant_2050
Where   generation_type	='wind'
AND     generation_subtype ='wind_onshore'
AND     source ='open_ego NEP 2015 B2035'
AND     electrical_capacity <= 1000;
--
DELETE
FROM  model_draft.ego_supply_res_powerplant_2050
Where   generation_type	='wind'
AND     generation_subtype ='wind_onshore'
AND     source ='open_ego 2050'
AND     electrical_capacity <= 1300;
--

----------------------------------------------------------
----------------------------------------------------------
SELECT
generation_type,
generation_subtype,
count(*)
FROM model_draft.ego_supply_res_powerplant
Group by generation_type, generation_subtype
Order by A.generation_type




-- Query run time = 

-- Check number of onshore and offshore wind units and capacity
-- off shore 4.7 zuviel inSQ und 2035
-- ....


-- Conventinal
SELECT
fuel,
technology,
min(capacity) as minC,
min(capacity_uba) as minC_u
FROM
supply.ego_conv_powerplant
group by fuel, technology
order by fuel;



-- Scenario orig_scenario_data.nep_2015_scenario_capacities
-- Hydro orig_geo_powerplants.proc_power_plant_germany

SELECT
*
FROM model_draft.nep_supply_conv_powerplant_nep2015


SELECT
fuel,
sum(rated_power_b2035) cap_b2035
FROM model_draft.nep_supply_conv_powerplant_nep2015
WHERE power_plant_name != 'KWK-Anlagen <10MW'
AND geom IS NOT NULL
Group by fuel
Order by fuel;

-- res

SELECT
  --electrical_capacity,
  generation_type ,
  generation_subtype,
  Count(*)
From
 model_draft.ego_supply_res_powerplant
Group by generation_type, generation_subtype
Order by generation_type;
--


SELECT
  round(sum(electrical_capacity)/1000000,3)  cum_Cap, -- in GW
  generation_subtype,
  generation_type ,
  Count(*)
From
 model_draft.ego_supply_res_powerplant
WHERE start_up_date < '2015-01-01 00:00:00'
AND  generation_subtype = 'wind_offshore'
Group by generation_type ,generation_subtype
order by generation_type;

--
SELECT
  round(sum(electrical_capacity)/1000000,3)  cum_Cap, -- in GW
  generation_type ,
  Count(*)
From
model_draft.ego_supply_res_powerplant_2035
WHERE  generation_subtype = 'wind_offshore'
Group by generation_type --,generation_subtype
Order by generation_type;


--
SELECT
  round(sum(electrical_capacity)/1000000,3)  cum_Cap, -- in GW
  generation_type ,
  Count(*)
From
model_draft.ego_supply_res_powerplant_2050
WHERE  generation_subtype != 'wind_offshore'
Group by generation_type
order by generation_type;


---

SELECT
generation_type,
source,
count(*)
FROM
supply.ego_renewable_power_plants_germany
Group by source, generation_type
Order by source ;


----
SELECT
*
FROM
orig_scenario_data.nep_2015_scenario_capacities
where scenario_name = 'ego-100-2050'

--
SELECT
sum(electrical_capacity)/1000000
FROM
supply.ego_renewable_power_plants_germany
WHERE generation_subtype = 'wind_offshore'
Group by generation_subtype;

SELECT
sum(electrical_capacity)/1000000
FROM
supply.ego_renewable_power_plants_germany
WHERE generation_subtype = 'wind_onshore'
Group by generation_subtype;

SELECT
sum(electrical_capacity)/1000000
FROM
supply.ego_renewable_power_plants_germany
WHERE generation_type = 'wind'
AND generation_subtype != 'wind_offshore'
Group by generation_type;



SELECT
generation_type,
generation_subtype,
sum(electrical_capacity)/1000000
FROM
supply.ego_res_powerplant
Where generation_type = 'wind'
Group by generation_subtype, generation_type;

SELECT
generation_type,
generation_subtype,
sum(electrical_capacity)/1000000
FROM
supply.ego_renewable_power_plants_germany
Where generation_type = 'wind'
Group by generation_subtype, generation_type;



----- Plots

SELECT DISTINCT 
A.*,
B.*
FROM 
( SELECT * FROM model_draft.renpass_gis_parameter_region
Where u_region_id in( 'DEow19','DEow20','DEow21') ) AS A,
( SELECT * FROM orig_vg250.vg250_2_lan WHERE gf = 4 ) AS B
