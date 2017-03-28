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
	Group by generation_type, generation_subtype
	Order by generation_type;



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
