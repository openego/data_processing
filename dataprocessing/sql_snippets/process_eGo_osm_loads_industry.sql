--------------
-- Calculate specific electricity consumption per million Euro GVA for each federal state
--------------

DROP TABLE IF EXISTS model_draft.ego_demand_per_gva;

CREATE TABLE model_draft.ego_demand_per_gva AS 
( 
SELECT  a.eu_code, 
 	a.federal_states, 
 	a.elec_consumption_industry/b.gva_industry AS elec_consumption_industry, 
 	a.elec_consumption_tertiary_sector/b.gva_tertiary_sector AS elec_consumption_tertiary_sector 
FROM  	demand.ego_demand_federalstate a, 
 	economic.destatis_gva_per_district b 
WHERE a.eu_code = b.eu_code 
ORDER BY eu_code 
) 
; 
ALTER TABLE model_draft.ego_demand_per_gva
ADD PRIMARY KEY (eu_code),
OWNER TO oeuser;


-- "Add Meta-documentation"

COMMENT ON TABLE  demand.ego_demand_federalstates_per_gva IS
'{
"Name": "Specific electricity consumption per gross value added",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2011",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Electricity consumption of the industrial and tertiary sector divided by the respective gross value added"],
"Column": [
                   {"Name": "eu_code",
                    "Description": "eu_code for nuts region",
                    "Unit": "" },
                   {"Name": "federal_states",
                    "Description": "name of federal state",
                    "Unit": "" },
                   {"Name": "elec_consumption_industry",
                    "Description": "specific electricity consumption per Million Euro of gva of the industrial sector",
                    "Unit": "GWh/Million Euro" },
                   {"Name": "elec_consumption_tertiary_sector",
                    "Description": "specific electricity consumption per Million Euro of gva of the tertiary sector",
                    "Unit": "GWh/Million Euro" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }, 
	  	   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "25.10.2016",
                    "Comment": "Completed json-String" }
                  ],
"ToDo": ["Add Licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


--------------
-- Calculate electricity consumption per district based on gross value added
--------------
DROP TABLE IF EXISTS model_draft.ego_demand_per_district;

CREATE TABLE model_draft.ego_demand_per_district as 
( 
SELECT b.eu_code, 
 
b.district, 
a.elec_consumption_industry * b.gva_industry as elec_consumption_industry, 
a.elec_consumption_tertiary_sector * b.gva_tertiary_sector AS elec_consumption_tertiary_sector 
FROM  	model_draft.ego_demand_per_gva a, 
 	economic.destatis_gva_per_district b
WHERE SUBSTR (a.eu_code,1,3) = SUBSTR(b.eu_code,1,3)  
) 
; 
ALTER TABLE model_draft.ego_demand_per_district
ADD PRIMARY KEY (eu_code),
OWNER TO oeuser;



COMMENT ON TABLE  model_draft.ego_demand_per_district IS
'{
"Name": "Electricity consumption per administrative district",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2011",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Electricity consumption calculated for every administrative district in Germany"],
"Column": [
                   {"Name": "eu_code",
                    "Description": "eu_code for nuts region",
                    "Unit": "" },
                   {"Name": "district",
                    "Description": "name of administrative district",
                    "Unit": "" },
                   {"Name": "elec_consumption_industry",
                    "Description": "electricity consumption of industrial sector",
                    "Unit": "GWh" },
                   {"Name": "elec_consumption_tertiary_sector",
                    "Description": "electricity consumption of tertiary sector",
                    "Unit": "GWh" },
                   {"Name": "area_industry",
                    "Description": "industrial osm-area within the administrative district",
                    "Unit": "ha" },
                   {"Name": "area_retail",
                    "Description": "retail osm-area within the administrative district",
                    "Unit": "ha" },
                   {"Name": "area_agricultural",
                    "Description": "agricultural osm-area within the administrative district",
                    "Unit": "ha" },
                   {"Name": "area_tertiary_sector",
                    "Description": "retail and agricultural osm-area within the administrative district",
                    "Unit": "ha" },
                   {"Name": "consumption_per_area_industry",
                    "Description": "specific consumption of industrial sector per ha within the administrative district",
                    "Unit": "GWh/ha" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "25.10.2016",
                    "Comment": "Completed meta-dokumentation" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

------------------
-- "Export information on the industrial area into model_draft.ego_landuse_industry"
------------------

DROP TABLE IF EXISTS model_draft.ego_landuse_industry CASCADE;
SELECT 	* 
INTO model_draft.ego_landuse_industry 
FROM openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview; 

ALTER TABLE  model_draft.ego_landuse_industry OWNER TO oeuser;


-- "Calculate industrial consumption per industry polygon"

UPDATE 	model_draft.ego_demand_per_district
SET 	consumption_per_area_industry = elec_consumption_industry/area_industry;


-- "Export information on industrial area into model_draft.ego_landuse_industry"

DROP TABLE IF EXISTS model_draft.ego_landuse_industry;
SELECT 	* 
INTO model_draft.ego_landuse_industry 
FROM openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview; 

ALTER TABLE  model_draft.ego_landuse_industry OWNER TO oeuser;

------------------
-- "Add and fill new columns with geometry information"
------------------


ALTER TABLE model_draft.ego_landuse_industry
	ADD COLUMN geom_centroid geometry(POINT,3035),
	ADD COLUMN geom_surfacepoint geometry(POINT,3035),
	ADD COLUMN geom_centre geometry(POINT,3035),
	ADD COLUMN nuts varchar(5),
	ADD COLUMN consumption numeric, 
	ADD COLUMN peak_load numeric, 
	ADD PRIMARY KEY (gid);


-- "Update Centroid"   
UPDATE 	model_draft.ego_landuse_industry AS t1
SET  	geom_centroid = t2.geom_centroid
FROM    (
	SELECT	ind.gid AS gid,
		ST_Centroid(ind.geom) AS geom_centroid
	FROM	model_draft.ego_landuse_industry AS ind
	) AS t2
WHERE  	t1.gid = t2.gid;

-- "Create Index GIST (geom_centroid)"
CREATE INDEX  	landuse_industry_geom_centroid_idx
    ON    	model_draft.ego_landuse_industry
    USING     	GIST (geom_centroid);

-- "Update PointOnSurface" 
UPDATE 	model_draft.ego_landuse_industry AS t1
SET  	geom_surfacepoint = t2.geom_surfacepoint
FROM    (
	SELECT	ind.gid AS gid,
		ST_PointOnSurface(ind.geom) AS geom_surfacepoint
	FROM	model_draft.ego_landuse_industry AS ind
	) AS t2
WHERE  	t1.gid = t2.gid;

-- "Create Index GIST (geom_surfacepoint)"
CREATE INDEX  	landuse_industry_geom_surfacepoint_idx
    ON    	model_draft.ego_landuse_industry
    USING     	GIST (geom_surfacepoint);


---------- ---------- ----------
-- "Update Centre"
---------- ---------- ----------

-- "Update Centre with centroid if inside area"   
UPDATE 	model_draft.ego_landuse_industry AS t1
SET  	geom_centre = t2.geom_centre
FROM	(
	SELECT	ind.gid AS gid,
		ind.geom_centroid AS geom_centre
	FROM	model_draft.ego_landuse_industry AS ind
	WHERE  	ind.geom && ind.geom_centroid AND
		ST_CONTAINS(ind.geom,ind.geom_centroid)
	)AS t2
WHERE  	t1.gid = t2.gid;

-- "Update Centre with surfacepoint if outside area"   
UPDATE 	model_draft.ego_landuse_industry AS t1
SET  	geom_centre = t2.geom_centre
FROM	(
	SELECT	ind.gid AS gid,
		ind.geom_surfacepoint AS geom_centre
	FROM	model_draft.ego_landuse_industry AS ind
	WHERE  	ind.geom_centre IS NULL
	)AS t2
WHERE  	t1.gid = t2.gid;

-- "Create Index GIST (geom_centre)"   
CREATE INDEX  	landuse_industry_geom_centre_idx
    ON    	model_draft.ego_landuse_industry
    USING     	GIST (geom_centre);

-- -- "Calculate NUTS" = 58.869 -> 154sec
-- UPDATE 	model_draft.ego_landuse_industry a
-- SET 	nuts = b.nuts
-- FROM 	political_boundary.bkg_vg250_4_krs b
-- WHERE 	st_intersects(st_transform(st_setsrid(b.geom, 31467), 3035), a.geom_centre); 

-- Using Index and MView
-- "Calculate NUTS" = 58.869 -> 5sec
UPDATE 	model_draft.ego_landuse_industry a
SET 	nuts = b.nuts
FROM 	political_boundary.bkg_vg250_4_krs_mview b
WHERE 	b.geom && a.geom_centre AND
	st_intersects(b.geom, a.geom_centre); 


-----------------
-- "Calculate the electricty consumption for each industry polygon"
-----------------

UPDATE 	model_draft.ego_landuse_industry a
SET   	consumption = sub.result 
FROM
(
	SELECT
	c.gid,
	b.elec_consumption_industry/b.area_industry * c.area_ha as result
	FROM
	model_draft.ego_demand_per_district b,
	model_draft.ego_landuse_industry c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.gid = a.gid;

-----------------
-- "Calculate the peak load for each industry polygon"
-----------------

UPDATE model_draft.ego_landuse_industry
SET peak_load = consumption*(0.00013247226362); -- Add different factor to calculate the peak load

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	landuse_industry_geom_idx
    ON    	model_draft.ego_landuse_industry
    USING     	GIST (geom);

-- "Add metadata"

COMMENT ON TABLE  model_draft.ego_landuse_industry IS
'{
"Name": "Industrial landuse area",
"Source": [{
                  "Name": "open_eGo data_processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "October 2016",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Collection of osm polygons with a tag landuse=industrial"],
"Column": [
                   {"Name": "gid",
                    "Description": "unique id",
                    "Unit": "" },
                   {"Name": "osm_id",
                    "Description": "osm-id",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "name",
                    "Unit": "" },
                   {"Name": "sector",
                    "Description": "Integer to identify the landuse sector",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "landuse area",
                    "Unit": "ha" },
                   {"Name": "tags",
                    "Description": "osm-tags",
                    "Unit": "" },
                   {"Name": "vg250",
                    "Description": "check if landuse are is inside the german vg250-polygon",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "geometry polygon",
                    "Unit": "" },
                   {"Name": "geom_centroid",
                    "Description": "centroid of polygon",
                    "Unit": "" },
                   {"Name": "geom_surfacepoint",
                    "Description": "Surfacepoint of polygon",
                    "Unit": "" },
                   {"Name": "geom_centre",
                    "Description": "centre of polygon",
                    "Unit": "" },
                   {"Name": "nuts",
                    "Description": "nuts code for corresponding administrative district",
                    "Unit": "" },
                   {"Name": "consumption",
                    "Description": "electricity consumption associated with polygon",
                    "Unit": "GWh" },
                   {"Name": "peak_load",
                    "Description": "peak load associated with polygon",
                    "Unit": "MW" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "25.10.2016",
                    "Comment": "Completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'landuse_industry' AS table_name,
		'process_eGo_osm_loads_industry.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_landuse_industry;



	
-----------------
-- "Identify large scale consumer"
-----------------

DROP TABLE IF EXISTS model_draft.ego_demand_hv_largescaleconsumer CASCADE;

CREATE TABLE model_draft.ego_demand_hv_largescaleconsumer AS
	(
	SELECT	osm_deu_polygon_urban_sector_3_industrial_mview.gid AS polygon_id,
		osm_deu_polygon_urban_sector_3_industrial_mview.area_ha AS area_ha,
		proc_power_plant_germany.gid AS powerplant_id,
		proc_power_plant_germany.voltage_level AS voltage_level
	FROM 	supply.ego_conv_powerplant, 
		openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview
	WHERE	(voltage_level='3' OR voltage_level='2'OR voltage_level='1')
	AND 	ST_Intersects (proc_power_plant_germany.geom, (ST_transform (osm_deu_polygon_urban_sector_3_industrial_mview.geom,4326))));

ALTER TABLE  model_draft.ego_demand_hv_largescaleconsumer OWNER TO oeuser;


DELETE FROM model_draft.ego_demand_hv_largescaleconsumer
WHERE polygon_id IN (SELECT polygon_id
              FROM (SELECT polygon_id,
                             ROW_NUMBER() OVER (partition BY powerplant_id ORDER BY (-area_ha)) AS rnum
                     FROM model_draft.ego_demand_hv_largescaleconsumer) t
              WHERE t.rnum > 1);

ALTER TABLE model_draft.ego_demand_hv_largescaleconsumer
	ADD COLUMN id serial,
	ADD COLUMN subst_id integer, 
	ADD COLUMN otg_id integer,  
	ADD COLUMN un_id integer,
	ADD COLUMN consumption numeric, 
	ADD COLUMN numeric,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD COLUMN geom_centre geometry(Point,3035),
	ADD PRIMARY KEY (id);

ALTER TABLE model_draft.ego_demand_hv_largescaleconsumer ALTER COLUMN polygon_id SET DEFAULT NULL;


----------------
-- Add industrial areas where limit value of peak load exceeds 17.5 MW
----------------

INSERT INTO model_draft.ego_demand_hv_largescaleconsumer (polygon_id, area_ha) 
	SELECT gid, area_ha
	FROM model_draft.ego_landuse_industry
	WHERE peak_load >= 0.0175; 

-- Add consumption, peak_load and geom_centre for industry polygons

UPDATE model_draft.ego_demand_hv_largescaleconsumer
	SET geom = b.geom
	FROM model_draft.ego_landuse_industry b
	WHERE polygon_id = b.gid;

UPDATE model_draft.ego_demand_hv_largescaleconsumer
	SET geom_centre = b.geom_centre 
	FROM model_draft.ego_landuse_industry b
	WHERE polygon_id = b.gid;

UPDATE model_draft.ego_demand_hv_largescaleconsumer
	SET consumption = b.consumption 
	FROM model_draft.ego_landuse_industry b
	WHERE polygon_id = b.gid;  

UPDATE model_draft.ego_demand_hv_largescaleconsumer
	SET peak_load = b.peak_load 
	FROM model_draft.ego_landuse_industry b
	WHERE polygon_id = b.gid;
 
-- Update voltage_level for polygons without powerplant 

UPDATE model_draft.ego_demand_hv_largescaleconsumer
	SET voltage_level = '3'
	WHERE peak_load >= 0.0175 AND peak_load < 0.12 AND powerplant_id IS NULL; 

UPDATE model_draft.ego_demand_hv_largescaleconsumer
	SET voltage_level = '1'
	WHERE peak_load >= 0.12 AND powerplant_id IS NULL; 


-- Delete duplicates of polygon_id with the same voltage_level 

DELETE FROM model_draft.ego_demand_hv_largescaleconsumer
WHERE id IN (SELECT id
              FROM (SELECT id,
                             ROW_NUMBER() OVER (partition BY polygon_id, voltage_level ORDER BY (id)) AS rnum
                     FROM model_draft.ego_demand_hv_largescaleconsumer) t
              WHERE t.rnum > 1);

-- Delete duplicates of polygon_id ordered by voltage_level 

DELETE FROM model_draft.ego_demand_hv_largescaleconsumer
WHERE id IN (SELECT id
              FROM (SELECT id,
                             ROW_NUMBER() OVER (partition BY polygon_id ORDER BY (voltage_level)) AS rnum
                     FROM model_draft.ego_demand_hv_largescaleconsumer) t
              WHERE t.rnum > 1);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	large_scale_consumer_geom_idx
    ON    	model_draft.ego_demand_hv_largescaleconsumer
    USING     	GIST (geom);
			  
-- "Create Index GIST (geom_centre)"   (OK!) 2.000ms =0
CREATE INDEX  	large_scale_consumer_geom_centre_idx
    ON    	model_draft.ego_demand_hv_largescaleconsumer
    USING     	GIST (geom_centre);


-- Identify corresponding bus for large scale consumer (lsc) with the help of ehv-voronoi

UPDATE model_draft.ego_demand_hv_largescaleconsumer a
	SET subst_id = b.subst_id
	FROM calc_ego_substation.ego_deu_voronoi_ehv b
	WHERE ST_Intersects (ST_Transform(a.geom,4326), b.geom) =TRUE;

UPDATE model_draft.ego_demand_hv_largescaleconsumer a
	SET otg_id = b.otg_id
	FROM model_draft.ego_grid_hvmv_substation b
	WHERE a.subst_id = b.subst_id; 


COMMENT ON TABLE  model_draft.ego_demand_hv_largescaleconsumer IS
'{
"Name": "Large scale consumer in EHV-level",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Identified industrial large scale consumer with a connection to the EHV-grid"],
"Column": [
                   {"Name": "polygon_id",
                    "Description": "unique id for osm industry-polygon",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "area of polygon",
                    "Unit": "ha" },
                   {"Name": "powerplant_id",
                    "Description": "id of powerplants on the considered polygons",
                    "Unit": "" },
                   {"Name": "voltage_level",
                    "Description": "voltage level of the consumers grid connection",
                    "Unit": "" },
                   {"Name": "id",
                    "Description": "unique id",
                    "Unit": "" },
                   {"Name": "consumption",
                    "Description": "electricity consumption of associated industry polygon",
                    "Unit": "GWh" },
                   {"Name": "peak_load",
                    "Description": "peak-load of associated industry polygon",
                    "Unit": "MW" },
                   {"Name": "geom",
                    "Description": "geometry of industry-polygon",
                    "Unit": "" },
                   {"Name": "geom_centre",
                    "Description": "centre of industry-polygon",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "id of associated substation",
                    "Unit": "" },
                   {"Name": "otg_id",
                    "Description": "otg_id of associated substation",
                    "Unit": "" },
                   {"Name": "un_id",
                    "Description": "unique id of loads",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "25.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

			  
-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'large_scale_consumer' AS table_name,
		'process_eGo_osm_loads_industry.sql' AS script_name,
		COUNT(geom_centre)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_demand_hv_largescaleconsumer;

/*﻿ 
SELECT polygon_id, 
 COUNT(polygon_id) AS NumOccurrences
FROM model_draft.ego_demand_hv_largescaleconsumer
GROUP BY polygon_id
HAVING ( COUNT(polygon_id) > 1 )
*/


-- Remove industrial loads from openstreetmap.ego_deu_loads_osm
