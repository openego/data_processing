------------
--- proc_power_plant_germany
------------


CREATE TABLE orig_geo_powerplants.proc_power_plant_germany AS
SELECT opsd_power_plants_germany.*
FROM orig_geo_opsd.opsd_power_plants_germany
;

/* Manual modifications which are valid for version 1.0 of opsd_power_plants_germany. A validity for later versions is not quaranteed*/
UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage='10;110'
WHERE voltage='10 und 110'
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage='110;220'
WHERE voltage='220 / 110 / 10'
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage='220'
WHERE voltage='Werknetz' AND city = 'Salzgitter'
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage='MS'
WHERE voltage='MSP'
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage='6;30'
WHERE voltage='30 auf 6'
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage='110'
WHERE voltage='Mai 25'
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage='10;25'
WHERE voltage='10kV, 25kV'
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage='6'
WHERE voltage='6
20'
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage='6;110'
WHERE voltage='110/6'
;


/*Correct an invalide geom in the register*/

ALTER TABLE orig_geo_powerplants.proc_power_plant_germany
SET lat = 48.0261021
WHERE gid = 493
;

UPDATE  orig_geo_powerplants.proc_power_plant_germany
set geom = ST_SetSRID(ST_MakePoint(lon,lat),4326)
WHERE gid = 493;

/*Update Voltage Level of Power Plants in proc_power_plants_germany*/
ALTER TABLE orig_geo_powerplants.proc_power_plant_germany
ADD COLUMN voltage_level smallint DEFAULT NULL
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=1
WHERE voltage='220' or voltage='380' or voltage='400'
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=1,
voltage= NULL
WHERE  voltage='HOES' 
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=2
WHERE voltage='10;110;220'  or voltage='110;220'
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=2,
voltage= NULL
WHERE  voltage='HOES/HS' 
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=3
WHERE voltage='110' 
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=3,
voltage=110
WHERE  voltage='HS' 
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=4
WHERE voltage='10;110' or voltage='6;110'
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=4,
voltage= NULL
WHERE  voltage='HS/MS' 
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=5
WHERE voltage='10' or voltage='6' or voltage='11' or voltage='15' or voltage='20' or voltage='25' or voltage='30' or voltage='35' or voltage='50' or voltage='60' or voltage='65'
; 

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=5, 
voltage=NULL
WHERE  voltage='MS' 
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=6
WHERE voltage='6;30' or voltage='10;25' or voltage='6;20'
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=6,
voltage= NULL
WHERE  voltage='MS/NS' 
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=7
WHERE voltage='0.4' 
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=7,
voltage= NULL
WHERE  voltage='NS' 
;


/*Update Voltage Level of Power Plants without given Voltage in proc_power_plants_germany*/

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=1
WHERE capacity >=120.0 AND voltage_level is NULL /*Voltage_level =1 when capacity greater than 120 MW*/;


UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=3
WHERE capacity BETWEEN 17.5 AND 119.99 AND voltage_level is NULL /*Voltage_level =2 when capacity between 17.5 and 119.99 MW*/;
;
UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=4
WHERE capacity BETWEEN 4.5 AND 17.49 AND voltage_level is NULL
;
UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=5
WHERE capacity BETWEEN 0.3 AND 4.49 AND voltage_level is NULL /* Voltage_level =3 when capacity between 0.3 and 4.5 kV*/;
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=6
WHERE capacity BETWEEN 0.1 AND 0.29 AND voltage_level is NULL
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=7
WHERE capacity BETWEEN 0 AND 0.099 AND voltage_level is NULL /*voltage_level =1 when capacity lower than 0.1*/;


/*Assign voltage-entries to power plants in gridlevel 1 or 2*/

DROP TABLE IF EXISTS AA;
CREATE TEMP Table AA AS
SELECT proc_power_plant_germany.*
FROM orig_geo_powerplants.proc_power_plant_germany
WHERE proc_power_plant_germany.capacity >=120 AND proc_power_plant_germany.voltage IS NULL;
UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage=substr(osm_deu_substations_ehv.voltage,1,3)
FROM orig_osm.osm_deu_substations_ehv,orig_ego.ego_deu_voronoi_ehv, AA
WHERE ST_Intersects (ego_deu_voronoi_ehv.geom,AA.geom) AND osm_deu_substations_ehv.subst_id=ego_deu_voronoi_ehv.subst_id AND AA.gid=proc_power_plant_germany.gid;


/* Change fuel='multiple_non_renewable' to 'other_non_renewable' for compatibility reasons*/

UPDATE orig_geo_powerplants.proc_power_plant_germany
	SET fuel = 'other_non_renewable'
	WHERE fuel = 'multiple_non_renewable';



