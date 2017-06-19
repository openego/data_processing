-- Autor Wolf-Dieter Bunke
-- Date: 2016-12-15
--- --- -- ---- ------- --- ----------- --------- ------------- -------
-- Bug Fix Geometry position of RES 2035 to substation
--- --- -- ---- ------- --- ----------- --------- ------------- -------
-- Overvie of needed tabels:
--  orig_geo_powerplants.proc_renewable_power_plants_nep2035
--      *  voltage character varying,
--      *  subst_id bigint,
--      *  otg_id bigint,
--      *  un_id bigint,
--      *  geom geometry(Point,4326),
--      *  id bigint NOT NULL,
--  calc_ego_substation.ego_deu_substations
--      *   geom geometry(Point,3035)
--      *   otg_id bigint,
--      *   subst_id serial NOT NULL,
--      *   point geometry(Point,4326) NOT NULL,
--- --- -- ---- ------- --- ----------- --------- ------------- -------
-- Overview of non referenced res units in 2035
-- (1) N = 37.562 are missing
-- (2) N = 36.808
-- Query returned successfully: 715 rows affected, 01:22:3645 hours execution time.
-- (3) N = 36086


SELECT
count(*)
FROM
orig_geo_powerplants.proc_renewable_power_plants_nep2035
WHERE subst_id IS NULL
AND voltage_level >= 3;
--
-- take one id = 9517656
SELECT
*
FROM
orig_geo_powerplants.proc_renewable_power_plants_nep2035
WHERE subst_id IS NULL
limit 1;
--
-- substation N = 3606
SELECT
count(*)
FROM
calc_ego_substation.ego_deu_substations
;
--- --- -- ---- ------- --- ----------- --------- ------------- -------
-- INFO: http://www.bostongis.com/PrinterFriendly.aspx?content_name=postgis_nearest_neighbor
--       http://gis.stackexchange.com/questions/136403/postgis-nearest-point-with-st-distance
--- --- -- ---- ------- --- ----------- --------- ------------- -------
--
-- Unpdate missing relations
-- condition: subst_id IS NULL / voltage_level >= 3
--
--- --- -- ---- ------- --- ----------- --------- ------------- -------

--  run (1,2)
--
Update orig_geo_powerplants.proc_renewable_power_plants_nep2035 as C
set otg_id   = sub.otg_id,
    subst_id = sub.subst_id  
FROM(
	SELECT B.subst_id,
	       B.otg_id,
		(SELECT A.id                        
		
		FROM orig_geo_powerplants.proc_renewable_power_plants_nep2035 A
                WHERE A.subst_id IS NULL 
                AND A.voltage_level >= 3	    
		ORDER BY  A.geom <#>  B.point LIMIT 1)  -- geom getauscht
	FROM calc_ego_substation.ego_deu_substations B
	
) as sub
WHERE C.id = sub.id 
;
-- (1) Query returned successfully: 740 rows affected, 01:26:3656 hours execution time.



-- New Query from Boston

SELECT DISTINCT ON(g1.id)  g1.id As gref_id, 
                --g1.description As gref_description, 
                g2.subst_id As subst_id, 
                g2.otg_id As otg_id  
    FROM orig_geo_powerplants.proc_renewable_power_plants_nep2035  As g1, 
         calc_ego_substation.ego_deu_substations As g2  
    WHERE g1.id <> g2.subst_id                    --- make no sence or? 
    AND   g1.subst_id IS NULL 
    AND   g1.voltage_level >= 3
    AND ST_DWithin(g1.geom, g2.point, 300)        -- Stop after 300 tries
    ORDER BY g1.id, ST_Distance(g1.geom, g2.point) 
Limit 1
---
-- Own query

SELECT
  A.id,
  B.subst_id,
  B.otg_id,
  ST_Distance(A.geom, B.point) as diss_dgree
FROM 
  orig_geo_powerplants.proc_renewable_power_plants_nep2035 A,
  calc_ego_substation.ego_deu_substations B
WHERE A.subst_id IS NULL 
AND   A.voltage_level >= 3
ORDER BY A.id,ST_Distance(A.geom, B.point)  
Limit 1;

--- --- -- ---- ------- --- ----------- --------- ------------- -------
--
--
--- --- -- ---- ------- --- ----------- --------- ------------- -------
-- Stabel Query
--
-- Query returned successfully: 36086 rows affected, 04:34 minutes execution time.
-- Das ging mir zu schnell

Create Table orig_geo_powerplants.res_power_plants_2035_to_substation
(
  res_id bigint,
  subst_id bigint,
  otg_id bigint,
  min_dis double precision
);
---
Insert into orig_geo_powerplants.res_power_plants_2035_to_substation (res_id,subst_id,otg_id,min_dis)
	SELECT 
	   DISTINCT ON (A.id) A.id as res_id , 
	     B.subst_id,
	     B.otg_id, 
	     ST_Distance(ST_Transform(A.geom,3035), B.geom)  as min_dis   --- falscher ausdruck? nur dis oder?
	FROM
	  orig_geo_powerplants.proc_renewable_power_plants_nep2035 A,
	  calc_ego_substation.ego_deu_substations B
	WHERE  A.voltage_level >= 3
	AND   A.subst_id IS NULL 
	ORDER BY  res_id, B.subst_id, B.otg_id, ST_Distance(ST_Transform(A.geom,3035), B.geom)
;
--- https://github.com/openego/data_processing/tree/master/calc_geo_powerplants




--(3) Funktioniert, für 40k Anlagen sind die Distanzen über 100 km offshore bietet hierbei keine Erklärung! KP, was da los ist

Update orig_geo_powerplants.proc_renewable_power_plants_nep2035 as C
set otg_id   = sub.otg_id,
    subst_id = sub.subst_id 
FROM(
		SELECT 
		   DISTINCT ON (A.id) A.id, 
		   B.subst_id,
		   B.otg_id, 
		   ST_Distance(ST_Transform(A.geom,3035), B.geom)  as dist
		FROM
		  orig_geo_powerplants.proc_renewable_power_plants_nep2035 A,
		  calc_ego_substation.ego_deu_substations B
		WHERE  A.voltage_level >= 3
		AND   A.subst_id IS NULL 
		ORDER BY  A.id, B.subst_id, B.otg_id, ST_Distance(ST_Transform(A.geom,3035), B.geom) --DESC --- möglicher fehler DESC   -- order id entnehmen?
	
	) as sub
WHERE C.id = sub.id 
AND C.subst_id IS NULL
;



--
--- --- -- ---- ------- --- ----------- --------- ------------- -------

 

SELECT
  DISTINCT ON (A.id) A.id,
  B.subst_id,
  B.otg_id,
  A.geom,
  B.geom,
  ST_Distance(ST_Transform(A.geom,3035), B.geom ) -- Luddee SRID
FROM
  orig_geo_powerplants.proc_renewable_power_plants_nep2035 A,
  calc_ego_substation.ego_deu_substations B
WHERE  A.voltage_level >= 3
ORDER BY A.id, B.subst_id, B.otg_id,ST_Distance(ST_Transform(A.geom,3035), B.geom) 

Limit 3;

--- Max Diss = 637,804.051913664 m!
-- ### ### ### Hier den für QGIS nehmen :) ##### ###
-- QUGIS View
---
SELECT
  A.idas gid,
--  B.subst_id,
 -- B.otg_id,
--ST_Distance(ST_Transform(A.geom,3035), B.geom),-- Luddee SRID
ST_MAKELINE(ST_Transform(A.geom,3035), B.geom)::geometry(LineString,3035) AS geom,
ST_MaxDistance(ST_Transform(A.geom,3035), B.geom) as max

FROM
  orig_geo_powerplants.proc_renewable_power_plants_nep2035 A,
  calc_ego_substation.ego_deu_substations B
WHERE  A.voltage_level >= 3
AND  B.subst_id = A.subst_id 
order by max DESC

--- ANzahl pro substation


Group by A.id--,  B.subst_id,  B.otg_id
Limit 3;


--ORDER BY A.id, B.subst_id, B.otg_id,ST_Distance(ST_Transform(A.geom,3035), B.geom) 










--- --- -- ---- ------- --- ----------- --------- ------------- -------
-- geom = Null = 32
SELECT 
count(*)
FROM orig_geo_powerplants.proc_renewable_power_plants_nep2035
WHERE geom IS NULL



--- --- -- ---- ------- --- ----------- --------- ------------- -------
---  Test SELECT 
--- --- -- ---- ------- --- ----------- --------- ------------- -------
SELECT
C.id,
sub.id,
sub.subst_id ,
sub.otg_id
    
FROM(
	SELECT B.subst_id,
	       B.otg_id,
		(SELECT A.id         -- RES id
		
		FROM orig_geo_powerplants.proc_renewable_power_plants_nep2035 A
                WHERE A.subst_id IS NULL 	
                AND A.voltage_level >= 3
		ORDER BY B.point <#> A.geom LIMIT 1)
	FROM calc_ego_substation.ego_deu_substations B
	limit 12
) as sub,
orig_geo_powerplants.proc_renewable_power_plants_nep2035 C
WHERE C.id = sub.id 

LIMIT 12

--- --- -- ---- ------- --- ----------- --------- ------------- -------
--- Check View distance Line
--- --- -- ---- ------- --- ----------- --------- ------------- -------
SELECT
A.id,
B.subst_id,
ST_Distance(A.geom,B.point)  as min_diss,  -- degress
ST_MAKELINE(A.geom,B.point) ::geometry(LineString,4326) AS geom_line
FROM
	orig_geo_powerplants.proc_renewable_power_plants_nep2035 A,
	calc_ego_substation.ego_deu_substations B
WHERE
B.subst_id=1925
AND 
A.id =9825780
;
-- END




 