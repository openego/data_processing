------------
--- proc_power_plant_germany
------------


CREATE TABLE orig_geo_powerplants.proc_power_plant_germany AS
SELECT opsd_power_plants_germany.*
FROM orig_geo_opsd.opsd_power_plants_germany
;


COMMENT ON TABLE  orig_geo_powerplants.proc_power_plant_germany IS
'{
"Name": "eGo conventional powerplant list",
"Source": [{
                  "Name": "open_eGo data_processing",
                  "URL":  "https://github.com/openego/data_processing" }, 
	   {
                  "Name": "BNetzA Kraftwerksliste",
                  "URL":  "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html" }, 

{
                  "Name": "Umweltbundesamt Datenbank Kraftwerke in Deutschland",
                  "URL":  "http://www.umweltbundesamt.de/dokument/datenbank-kraftwerke-in-deutschland" }, 



],
"Reference date": "2016-02-08",
"Date of collection": "...",
"Original file": "proc_power_plant_germany.sql",
"Spatial resolution": ["Germany"],
"Description": ["This dataset contains processed information on powerplants from BNetzA and UBA-list"],
"Column": [
                   {"Name": "gid",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "bnetza_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "company",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "postcode",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "city",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "street",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "state",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "block",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "commissioned_original",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "commissioned",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "retrofit",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "shutdown",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "status",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "fuel",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "technology",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "type",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "eeg",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "chp",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "capacity",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "capacity_uba",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "chp_capacity_uba",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "efficiency_data",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "efficiency_estimate",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "network_node",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "voltage",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "network_operator",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "name_uba",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "lat",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "lon",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "comment",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "geom",
                    "Description": "geometry",
                    "Unit": "" }, 
                   {"Name": "voltage_level",
                    "Description": "voltage level to which generator is connected (partly calculated based on installed capacity)",
                    "Unit": "" }, 
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
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." },
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "27.10.2016",
                    "Comment": "added information to metadata" } 
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


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


/*Update Voltage Level of Power Plants in proc_power_plants_germany*/

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=1
WHERE capacity >=120.0 /*Voltage_level =1 when capacity greater than 120 MW*/;


UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=3
WHERE capacity BETWEEN 17.5 AND 119.99 /*Voltage_level =2 when capacity between 17.5 and 119.99 MW*/;
;
UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=4
WHERE capacity BETWEEN 4.5 AND 17.49
;
UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=5
WHERE capacity BETWEEN 0.3 AND 4.49 /* Voltage_level =3 when capacity between 0.3 and 4.5 kV*/;
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=6
WHERE capacity BETWEEN 0.1 AND 0.29
;

UPDATE orig_geo_powerplants.proc_power_plant_germany
SET voltage_level=7
WHERE capacity BETWEEN 0 AND 0.099 /*voltage_level =1 when capacity lower than 0.1*/
;


/* Change fuel='multiple_non_renewable' to 'other_non_renewable' for compatibility reasons*/

UPDATE orig_geo_powerplants.proc_power_plant_germany
	SET fuel = 'other_non_renewable'
	WHERE fuel = 'multiple_non_renewable';



