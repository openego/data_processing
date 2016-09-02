/*
Clean data set of proc_renewable_power_plants_germany

*/

-- get an overview
SELECT
generation_type,
generation_subtype,
count(*)
from 
  orig_geo_powerplants.proc_renewable_power_plants_germany
Group by generation_type, generation_subtype
Order by generation_type;

/*
Drop following wrong data:

|generation_type|generation_subtype|count|
|biomass|wind_onshore|3|
|biomass|solar_roof_mounted|4|
|solar|wind_onshore|1|
|wind|solar_roof_mounted|1|

sum = 9 
*/

DELETE  FROM 
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE generation_type = 'biomass' AND generation_subtype ='wind_onshore'
OR generation_type = 'biomass' AND generation_subtype ='solar_roof_mounted'
OR generation_type = 'solar' AND generation_subtype ='wind_onshore'
OR generation_type = 'wind' AND generation_subtype ='solar_roof_mounted';


DELETE  FROM orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE electrical_capacity IS NULL OR electrical_capacity <= 0; 
