/*
SQL Script in order to clean and correct data set of proc_renewable_power_plants_germany 
(status quo renewable power plants in germany).
__copyright__ = "Europa-Universität Flensburg, Fachhochschule Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke, IlkaCu"

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


﻿/*
Clean data set of proc_power_plant_germany

*/

DELETE  FROM orig_geo_powerplants.proc_power_plant_germany
WHERE capacity IS NULL AND fuel!='pumped_storage' OR capacity <= 0 AND fuel!='pumped_storage';


-- Update incorrect geom of offshore windturbines

UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany
SET geom =
	(CASE
		WHEN eeg_id LIKE '%DYSKE%' 
		THEN (SELECT geom from orig_geo_powerplants.proc_renewable_power_plants_germany where id = 1560412)
		WHEN eeg_id LIKE '%BRGEE%' 
		THEN (SELECT geom from orig_geo_powerplants.proc_renewable_power_plants_germany where id = 1560969)
		WHEN eeg_id LIKE '%MEERWINDSUEDOST%' 
		THEN (SELECT geom from orig_geo_powerplants.proc_renewable_power_plants_germany where id = 1560502)
		WHEN eeg_id LIKE '%GLTEE%' 
		THEN (SELECT geom from orig_geo_powerplants.proc_renewable_power_plants_germany where id = 1561081)
		WHEN eeg_id LIKE '%BUTENDIEK%' 
		THEN (SELECT geom from orig_geo_powerplants.proc_renewable_power_plants_germany where id = 1560705)
		WHEN eeg_id LIKE '%BOWZE%' 
		THEN (SELECT geom from orig_geo_powerplants.proc_renewable_power_plants_germany where id = 1561018)
		WHEN eeg_id LIKE '%NORDSEEOST%' or eeg_id LIKE '%NordseeOst%'
		THEN (SELECT geom from orig_geo_powerplants.proc_renewable_power_plants_germany where id = 1560647)
		WHEN eeg_id LIKE '%BALTIC%' 
		THEN (SELECT geom from orig_geo_powerplants.proc_renewable_power_plants_germany where id = 1561137)
		WHEN eeg_id LIKE '%RIFFE%' 
		THEN ST_SetSRID(ST_MakePoint(6.48, 53.69),4326)
		WHEN eeg_id LIKE '%ALPHAVENTUE%' 
		THEN ST_SetSRID(ST_MakePoint(6.598333, 54.008333),4326)
		WHEN eeg_id LIKE '%BAOEE%' 
		THEN ST_SetSRID(ST_MakePoint(5.975, 54.358333),4326)
		END)
WHERE postcode = '00000' OR postcode = 'keine' or postcode = 'O04WF' AND generation_subtype = 'wind_offshore';

-- Update missing subtype of some offshore windturbines

update orig_geo_powerplants.proc_renewable_power_plants_germany
set generation_subtype = 'wind_offshore'
where city = 'Ausschließliche Wirtschaftszone';

-- Update missing subtypes
update orig_geo_powerplants.proc_renewable_power_plants_germany
set generation_subtype = 'biomass'
where generation_type = 'biomass'
and generation_subtype is NULL;
--
update orig_geo_powerplants.proc_renewable_power_plants_germany
set generation_subtype = 'gas'
where generation_type = 'gas'
and generation_subtype is NULL;
--
update orig_geo_powerplants.proc_renewable_power_plants_germany
set generation_subtype = 'geothermal'
where generation_type = 'geothermal'
and generation_subtype is NULL;
--
update orig_geo_powerplants.proc_renewable_power_plants_germany
set generation_subtype = 'hydro'
where generation_type = 'run_of_river'
and generation_subtype is NULL;
--
update orig_geo_powerplants.proc_renewable_power_plants_germany
set generation_subtype = 'wind_onshore'
where generation_type = 'wind'
and generation_subtype is NULL;
---
-- Todo 
/*
update orig_geo_powerplants.proc_renewable_power_plants_germany
set generation_subtype = 'solar_roof_mounted'
where generation_type = 'solar'
and generation_subtype is NULL
and voltage_level is in [1,2,]
*/

/*
SELECT
voltage_level,
max(electrical_capacity),
min(electrical_capacity)
FROM 
orig_geo_powerplants.proc_renewable_power_plants_germany 
where generation_type = 'solar'
and generation_subtype is NULL
Group by voltage_level;
*/
