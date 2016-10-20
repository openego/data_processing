﻿-- Calculate the industrial area per district 

-- ALTER TABLE orig_ego_consumption.lak_consumption_per_district
-- 	ADD COLUMN area_industry numeric;

UPDATE orig_ego_consumption.lak_consumption_per_district a
SET area_industry = result.sum
FROM
( 
	SELECT 
	sum(area_ha), 
	substr(nuts,1,5) 
	FROM calc_ego_loads.landuse_industry
	GROUP BY substr(nuts,1,5)
) as result

WHERE result.substr = substr(a.eu_code,1,5);



------------------
-- "Calculate specific industrial consumption"
------------------

SELECT	sum(area_ha), substr(nuts,1,5) 
	INTO 	orig_ego_consumption.temp_table
	FROM 	calc_ego_loads.landuse_industrial
GROUP BY 	substr(nuts,1,5);

UPDATE orig_ego_consumption.lak_consumption_per_district a
	SET 	area_industry = sum
	FROM 	orig_ego_consumption.temp_table b
	WHERE 	b.substr = substr(a.eu_code,1,5);

DROP TABLE orig_ego_consumption.temp_table; 


-- "Calculate industrial consumption per industry polygon"

UPDATE 	orig_ego_consumption.lak_consumption_per_district
SET 	consumption_per_area_industry = elec_consumption_industry/area_industry;


-- "Export information on industrial area into calc_ego_loads.landuse_industry"

DROP TABLE IF EXISTS calc_ego_loads.landuse_industry;

SELECT * INTO calc_ego_loads.landuse_industry FROM orig_osm.osm_deu_polygon_urban_sector_3_industrial_mview; 

ALTER TABLE  calc_ego_loads.landuse_industry OWNER TO oeuser;

------------------
-- "Add and fill new columns with geometry information"
------------------


ALTER TABLE calc_ego_loads.landuse_industry
	ADD COLUMN geom_centroid geometry(POINT,3035),
	ADD COLUMN geom_surfacepoint geometry(POINT,3035),
	ADD COLUMN geom_centre geometry(POINT,3035),
	ADD COLUMN nuts varchar(5),
	ADD COLUMN consumption numeric, 
	ADD COLUMN peak_load numeric, 
	ADD PRIMARY KEY (gid);


-- "Update Centroid"   
UPDATE 	calc_ego_loads.landuse_industry AS t1
SET  	geom_centroid = t2.geom_centroid
FROM    (
	SELECT	ind.gid AS gid,
		ST_Centroid(ind.geom) AS geom_centroid
	FROM	calc_ego_loads.landuse_industry AS ind
	) AS t2
WHERE  	t1.gid = t2.gid;

-- "Create Index GIST (geom_centroid)"
CREATE INDEX  	landuse_industry_geom_centroid_idx
    ON    	calc_ego_loads.landuse_industry
    USING     	GIST (geom_centroid);

-- "Update PointOnSurface" 
UPDATE 	calc_ego_loads.landuse_industry AS t1
SET  	geom_surfacepoint = t2.geom_surfacepoint
FROM    (
	SELECT	ind.gid AS gid,
		ST_PointOnSurface(ind.geom) AS geom_surfacepoint
	FROM	calc_ego_loads.landuse_industry AS ind
	) AS t2
WHERE  	t1.gid = t2.gid;

-- "Create Index GIST (geom_surfacepoint)"
CREATE INDEX  	landuse_industry_geom_surfacepoint_idx
    ON    	calc_ego_loads.landuse_industry
    USING     	GIST (geom_surfacepoint);


---------- ---------- ----------
-- "Update Centre"
---------- ---------- ----------

-- "Update Centre with centroid if inside area"   
UPDATE 	calc_ego_loads.landuse_industry AS t1
SET  	geom_centre = t2.geom_centre
FROM	(
	SELECT	ind.gid AS gid,
		ind.geom_centroid AS geom_centre
	FROM	calc_ego_loads.landuse_industry AS ind
	WHERE  	ind.geom && ind.geom_centroid AND
		ST_CONTAINS(ind.geom,ind.geom_centroid)
	)AS t2
WHERE  	t1.gid = t2.gid;

-- "Update Centre with surfacepoint if outside area"   
UPDATE 	calc_ego_loads.landuse_industry AS t1
SET  	geom_centre = t2.geom_centre
FROM	(
	SELECT	ind.gid AS gid,
		ind.geom_surfacepoint AS geom_centre
	FROM	calc_ego_loads.landuse_industry AS ind
	WHERE  	ind.geom_centre IS NULL
	)AS t2
WHERE  	t1.gid = t2.gid;

-- "Create Index GIST (geom_centre)"   
CREATE INDEX  	landuse_industry_geom_centre_idx
    ON    	calc_ego_loads.landuse_industry
    USING     	GIST (geom_centre);

-- "Calculate NUTS"   
UPDATE calc_ego_loads.landuse_industry a
SET nuts = b.nuts
FROM orig_vg250.vg250_4_krs b
WHERE st_intersects(st_transform(st_setsrid(b.geom, 31467), 3035), a.geom_centre); 


-----------------
-- "Calculate the electricty consumption for each industry polygon"
-----------------

UPDATE 	calc_ego_loads.landuse_industry a
SET   	consumption = sub.result 
FROM
(
	SELECT
	c.gid,
	b.elec_consumption_industry/b.area_industry * c.area_ha as result
	FROM
	orig_ego_consumption.lak_consumption_per_district b,
	calc_ego_loads.landuse_industry c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.gid = a.gid;

-----------------
-- "Calculate the peak load for each industry polygon"
-----------------


UPDATE calc_ego_loads.landuse_industry
SET peak_load = consumption*(0.00013247226362); -- Add different factor to calculate the peak load




-----------------
-- "Identify large scale consumer"
-----------------

DROP TABLE IF EXISTS calc_ego_loads.large_scale_consumer;

CREATE TABLE calc_ego_loads.large_scale_consumer AS
	(
	SELECT	osm_deu_polygon_urban_sector_3_industrial_mview.gid AS polygon_id,
		osm_deu_polygon_urban_sector_3_industrial_mview.area_ha AS area_ha,
		proc_power_plant_germany.gid AS powerplant_id,
		proc_power_plant_germany.voltage_level AS voltage_level
	FROM 	orig_geo_powerplants.proc_power_plant_germany, 
		orig_osm. osm_deu_polygon_urban_sector_3_industrial_mview
	WHERE	(voltage_level='3' OR voltage_level='2'OR voltage_level='1')
	AND 	ST_Intersects (proc_power_plant_germany.geom, (ST_transform (osm_deu_polygon_urban_sector_3_industrial_mview.geom,4326))));

ALTER TABLE  calc_ego_loads.large_scale_consumer OWNER TO oeuser;


DELETE FROM calc_ego_loads.large_scale_consumer
WHERE polygon_id IN (SELECT polygon_id
              FROM (SELECT polygon_id,
                             ROW_NUMBER() OVER (partition BY powerplant_id ORDER BY (-area_ha)) AS rnum
                     FROM calc_ego_loads.large_scale_consumer) t
              WHERE t.rnum > 1);

ALTER TABLE calc_ego_loads.large_scale_consumer
	ADD COLUMN id serial, 
	ADD COLUMN consumption numeric, 
	ADD COLUMN peak_load numeric,
	ADD COLUMN geom_centre geometry(Point,3035),
	ADD PRIMARY KEY (id);

ALTER TABLE calc_ego_loads.large_scale_consumer ALTER COLUMN polygon_id SET DEFAULT NULL;


----------------
-- Add industrial areas where limit value of peak load exceeds 17.5 MW
----------------

INSERT INTO calc_ego_loads.large_scale_consumer (polygon_id, area_ha) 
	SELECT gid, area_ha
	FROM calc_ego_loads.landuse_industry
	WHERE peak_load >= 0.0175; 

-- Add consumption, peak_load and geom_centre for industry polygons

UPDATE calc_ego_loads.large_scale_consumer
	SET geom_centre = b.geom_centre 
	FROM calc_ego_loads.landuse_industry b
	WHERE polygon_id = b.gid;

UPDATE calc_ego_loads.large_scale_consumer
	SET consumption = b.consumption 
	FROM calc_ego_loads.landuse_industry b
	WHERE polygon_id = b.gid;  

UPDATE calc_ego_loads.large_scale_consumer
	SET peak_load = b.peak_load 
	FROM calc_ego_loads.landuse_industry b
	WHERE polygon_id = b.gid;
 
-- Update voltage_level for polygons without powerplant 

UPDATE calc_ego_loads.large_scale_consumer
	SET voltage_level = '3'
	WHERE peak_load >= 0.0175 AND peak_load < 0.12 AND powerplant_id IS NULL; 

UPDATE calc_ego_loads.large_scale_consumer
	SET voltage_level = '1'
	WHERE peak_load >= 0.12 AND powerplant_id IS NULL; 


-- Delete duplicates of polygon_id with the same voltage_level 

DELETE FROM calc_ego_loads.large_scale_consumer
WHERE id IN (SELECT id
              FROM (SELECT id,
                             ROW_NUMBER() OVER (partition BY polygon_id, voltage_level ORDER BY (id)) AS rnum
                     FROM calc_ego_loads.large_scale_consumer) t
              WHERE t.rnum > 1);

-- Delete duplicates of polygon_id ordered by voltage_level 

DELETE FROM calc_ego_loads.large_scale_consumer
WHERE id IN (SELECT id
              FROM (SELECT id,
                             ROW_NUMBER() OVER (partition BY polygon_id ORDER BY (voltage_level)) AS rnum
                     FROM calc_ego_loads.large_scale_consumer) t
              WHERE t.rnum > 1);



/*﻿ 
SELECT polygon_id, 
 COUNT(polygon_id) AS NumOccurrences
FROM calc_ego_loads.large_scale_consumer
GROUP BY polygon_id
HAVING ( COUNT(polygon_id) > 1 )
*/


-- Remove industrial loads from orig_osm.ego_deu_loads_osm

