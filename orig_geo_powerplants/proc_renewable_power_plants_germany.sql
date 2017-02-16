---------------
--- proc_renewable_power_plants_germany
---------------

/*Assign gridlevels (1-7) and voltage-entries to RE-plants */

CREATE TABLE orig_geo_powerplants.proc_renewable_power_plants_germany AS
SELECT renewable_power_plants_germany.*
FROM orig_geo_powerplants.renewable_power_plants_germany;

ALTER TABLE orig_geo_powerplants.proc_renewable_power_plants_germany
ADD COLUMN voltage character varying;


/* Adjust voltage level of all RE power plants according to allocation table*/
UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany 
SET voltage_level='1'
WHERE electrical_capacity >=120000;

UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany
SET voltage_level='3',
Voltage=110
WHERE electrical_capacity between 17500 and 119999.99;

UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany
SET voltage_level='4'
WHERE electrical_capacity between 4500 and 17499.99;

UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany
SET voltage_level='5'
WHERE electrical_capacity between 300 and 4499.99;

UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany
SET voltage_level='6'
WHERE electrical_capacity between 100 and 299.99;

UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany
SET voltage_level='7'
WHERE electrical_capacity <100;

/*Assign RE-plants in ehv-level to nearest substation*/

DROP TABLE IF EXISTS AA;
CREATE TEMP Table AA AS
SELECT proc_renewable_power_plants_germany.*
FROM orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE proc_renewable_power_plants_germany.voltage_level='1';

UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany
SET voltage=substr(osm_deu_substations_ehv.voltage,1,3)
FROM orig_osm.osm_deu_substations_ehv,orig_ego.ego_deu_voronoi_ehv, AA
WHERE ST_Intersects (ego_deu_voronoi_ehv.geom,AA.geom) AND osm_deu_substations_ehv.subst_id=ego_deu_voronoi_ehv.subst_id AND AA.id=proc_renewable_power_plants_germany.id;


/*Change generation_type = 'hydro' to 'run_of_river' for compatibility reasons*/

UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany
	SET generation_type = 'run_of_river'
	WHERE generation_type = 'hydro';

/*Set voltage_level of offshore_wind to 1, to be able to assign offshore wind parks to the closest EHV-substation. This might be changed: See #983 */

UPDATE orig_geo_powerplants.proc_renewable_power_plants_germany 
	SET voltage_level=1 
	WHERE generation_subtype = 'wind_offshore'; 

/*Set capacity= capacity_uba for units without capacity entry */

UPDATE orig_geo_powerplants.proc_power_plant_germany 
	SET capacity = capacity_uba
	WHERE capacity IS NULL and capacity_uba IS NOT NULL; 

