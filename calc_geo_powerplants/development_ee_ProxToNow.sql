/*

1. Methodes of development of each type of generation
	solar -> own methode per mun (WIP)
	wind  -> by potental areas (Martin)
	geothermal -> status quo 
	hydro -> (run_of_river + reservoir) merched small and large 
		  size plants together. New capacity per unit proToNow per federal state assumption.
		  No changes of voltage level. 
	biomass -> New capacity per unit proToNow per federal state assumption.
		   No changes of voltage level. 
1.1 Formular:

    ProxToNow:
     P_inst(unit)/P_sum(federal state) * P_scn(Federal state)


ToDo: KWK Kleinstanlagen klären
      DEA Verteilung für Szenariodaten durchführen

	
*/


---
-- Create view with nuts id and polygones for federal states
---
CREATE MATERIALIZED VIEW orig_geo_vg250.vg250_2_lan_nuts_view AS 
  SELECT lan.ags_0,
    lan.gen,
    lan.nuts,
    st_union(st_transform(lan.geom, 3035)) AS geom
   FROM ( SELECT vg.ags_0,
             vg.nuts,
            replace(vg.gen::text, ' (Bodensee)'::text, ''::text) AS gen,
            vg.geom
           FROM orig_geo_vg250.vg250_2_lan vg) lan
  GROUP BY lan.ags_0, lan.gen,lan.nuts
  ORDER BY lan.ags_0
WITH DATA;

-- Grant on view
ALTER TABLE orig_geo_vg250.vg250_2_lan_nuts_view
  OWNER TO oeuser;
GRANT ALL ON TABLE orig_geo_vg250.vg250_2_lan_nuts_view TO oeuser WITH GRANT OPTION;

-------
---- Create new Table for NEP Scenario
----

 -- Drop Table orig_geo_powerplants.proc_renewable_power_plants_nep2035 CASCADE;

CREATE TABLE orig_geo_powerplants.proc_renewable_power_plants_nep2035
(
  id bigint NOT NULL,                            -- id given by proc_renewable_power_plants_germany
  scenario_year integer,                         -- year of scenario       
  electrical_capacity numeric,                   -- electrical capacity in kW
  generation_type text, 			 -- generaion type	
  generation_subtype character varying,          -- generation subtype 
  thermal_capacity numeric,                      -- thermal capacity of chp biomass, starting from August 2015
  nuts character varying,            	   	 -- nuts id
  lon numeric,                       		 -- lon from source
  lat numeric,                      		 -- lat from source
  voltage_level smallint,          		 -- voltage level from 1 till 7
  network_node character varying,  		 -- name of network node if exist from source
  source character varying,          		 -- source name
  comment character varying,        		 -- own comments
  geom geometry(Point,4326),        		 -- geom 
  voltage character varying,        		 -- voltage in kV calculated, partly not finished
  subst_id bigint,                  		 -- substation id
  otg_id bigint,                    		 --  
  un_id bigint,                     		 --    
  CONSTRAINT proc_renewable_power_plants_nep2035_pkey PRIMARY KEY (id)
);

-- Set Grant and index

CREATE INDEX proc_renewable_power_plants_nep2035_idx
  ON orig_geo_powerplants.proc_renewable_power_plants_nep2035
  USING gist
  (geom);

ALTER TABLE orig_geo_powerplants.proc_renewable_power_plants_nep2035
  OWNER TO oeuser;
  
GRANT ALL ON TABLE orig_geo_powerplants.proc_renewable_power_plants_nep2035 TO oeuser;


--- --------------------------------------------------
-- Biomass power plants
---

INSERT INTO orig_geo_powerplants.proc_renewable_power_plants_nep2035
SELECT
  id, 				-- 
  2035 AS scenario_year, 	-- 
  electrical_capacity ,  	-- 
  generation_type ,		-- 
  generation_subtype,   	-- 
  thermal_capacity, 		-- 
  NULL AS nuts,			-- 
  lon,  			-- 
  lat, 				-- 
  voltage_level,   		-- 
  network_node, 		--
  source,  		        -- 
  comment,  			--
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'biomass';

---
-- 	Set nuts
--- 
UPDATE orig_geo_powerplants.proc_renewable_power_plants_nep2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(ST_Transform(upt.geom, 3035), regions.geom)
;
---
--
-- check nuts id 
SELECT
  nuts,
  count(id),
  sum(electrical_capacity)
FROM
 orig_geo_powerplants.proc_renewable_power_plants_nep2035 
GROUp by nuts;
---
--- Fill emty nuts values by buffer
--
UPDATE orig_geo_powerplants.proc_renewable_power_plants_nep2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(St_Buffer(ST_Transform(upt.geom, 3035),1000), regions.geom)
AND upt.nuts  IS NULL;

--- ----------------------------------------------
-- Biomass Methode
-- increase installed capacity by NEP scenario data
-- No changes of voltage level
----
UPDATE orig_geo_powerplants.proc_renewable_power_plants_nep2035 as upt
set comment = upt.comment || ', Method ProxToNow Biomass',
    source = 'open_ego NEP 2015 B2035',
    electrical_capacity = CASE WHEN scn.capacity = 0 THEN 0 
	  ELSE (upt.electrical_capacity/ cap_sum)*scn.capacity*1000    
	 END 
FROM
  orig_scenario_data.nep_2015_scenario_capacities as scn,
  (SELECT nuts, sum(electrical_capacity) as cap_sum
   FROM orig_geo_powerplants.proc_renewable_power_plants_nep2035
   WHERE generation_type = 'biomass' Group by nuts
   ) count
WHERE scn.nuts = count.nuts 
AND   scn.nuts = upt.nuts 
AND   upt.nuts = count.nuts
AND   scn.generation_type = 'biomass' ;


--- --------------------------------------------
-- Geothermal Methode 
--   No changes set status quo
---
INSERT INTO orig_geo_powerplants.proc_renewable_power_plants_nep2035
SELECT
  id, 				--
  2035 AS scenario_year, 	--
  electrical_capacity ,  	-- in kW
  generation_type ,		--
  generation_subtype,   	--
  thermal_capacity, 		--
  NULL AS nuts,			-- nuts id of federal state
  lon,  			--
  lat, 				--	
  voltage_level,   		-- 
  network_node, 		--
  source,  		        -- orignal source name
  comment,  			-- Own comment
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'geothermal';

-- 
UPDATE orig_geo_powerplants.proc_renewable_power_plants_nep2035
set comment = comment || ', No changes status quo'
WHERE generation_type = 'geothermal';
--

UPDATE orig_geo_powerplants.proc_renewable_power_plants_nep2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(ST_Transform(upt.geom, 3035), regions.geom)
AND generation_type = 'geothermal'
;


--- --------------------------------------------------------
-- Hydro 
-- Insert large Hydro reservoir and run_of_river units from status Quo 
-- because of missing entries in NEP KW list
--

INSERT INTO orig_geo_powerplants.proc_renewable_power_plants_nep2035
SELECT
  9000000+row_number() over (ORDER BY gid) as id, -- create new ID
  2035 AS scenario_year, 			  
  capacity*1000 as electrical_capacity ,  	-- in kW
  'hydro' as generation_type ,		--
  fuel as generation_subtype,   	--
  NULL as thermal_capacity, 		--
  NULL AS nuts,			--
  lon,  			--
  lat, 				--	
  voltage_level,   		-- 
  network_node, 		--
  'OPSD powerplant list' as source,  	  -- orignal source name
  'add Hydro plants from conventional list' as comment,  -- Own comment
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_power_plant_germany
WHERE
fuel = 'reservoir'
OR fuel = 'run_of_river';
--
-- Insert 
--
INSERT INTO orig_geo_powerplants.proc_renewable_power_plants_nep2035
SELECT
  id, 				--
  2035 AS scenario_year, 	--
  electrical_capacity ,  	-- in kW
  'hydro' as generation_type ,		--
  generation_type as generation_subtype,   	--
  thermal_capacity, 		--
  NULL AS nuts,			-- nuts id of federal state
  lon,  			--
  lat, 				--	
  voltage_level,   		-- 
  network_node, 		--
  source,  		        -- orignal source name
  comment,  			-- Own comment
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'run_of_river';

-- DELETE FROM orig_geo_powerplants.proc_renewable_power_plants_nep2035 WHERE generation_type = 'hydro';

-- set nuts

UPDATE orig_geo_powerplants.proc_renewable_power_plants_nep2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(ST_Transform(regions.geom, 4326), upt.geom)
AND generation_type = 'hydro'
;
--- Fill emty nuts values by buffer
--
UPDATE orig_geo_powerplants.proc_renewable_power_plants_nep2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(St_Buffer(upt.geom,0.02), ST_Transform(regions.geom, 4326))
AND upt.nuts  IS NULL
AND generation_type = 'hydro';
--
--
UPDATE orig_geo_powerplants.proc_renewable_power_plants_nep2035 
set nuts = 'AT'
WHERE nuts  IS NULL AND generation_type = 'hydro';


--

UPDATE orig_geo_powerplants.proc_renewable_power_plants_nep2035 as upt
set comment = upt.comment || ', Method ProxToNow Hydro',
    source = 'open_ego NEP 2015 B2035',
    electrical_capacity = CASE WHEN scn.capacity = 0 THEN upt.electrical_capacity
	  ELSE (upt.electrical_capacity/ cap_sum)*scn.capacity*1000    
	 END 
FROM
  orig_scenario_data.nep_2015_scenario_capacities as scn,
  (SELECT nuts, sum(electrical_capacity) as cap_sum
   FROM orig_geo_powerplants.proc_renewable_power_plants_nep2035
   WHERE generation_type = 'hydro' Group by nuts
   ) count
WHERE scn.nuts = count.nuts 
AND   scn.nuts = upt.nuts 
AND   upt.nuts = count.nuts
AND   scn.generation_type = 'hydro' 
AND   upt.generation_type = 'hydro';

--- -----------------------------------------------------------
-- Gas Methode
-- No changes yet
--  ToDo: small CHP units

INSERT INTO orig_geo_powerplants.proc_renewable_power_plants_nep2035
SELECT
  id, 				--
  2035 AS scenario_year, 	--
  electrical_capacity ,  	--
  generation_type ,		--
  generation_subtype,   	--
  thermal_capacity, 		--
  NULL AS nuts,			-- 
  lon,  			--
  lat, 				--	
  voltage_level,   		-- 
  network_node, 		--
  source,  		        -- 
  comment,  			-- 
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'gas';

-- set nuts

UPDATE orig_geo_powerplants.proc_renewable_power_plants_nep2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(ST_Transform(regions.geom, 4326), upt.geom)
AND generation_type = 'gas';

/*
SELECT
round(sum(electrical_capacity)/1000,2)
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'gas';
*/



---------
-- PV Methode 
--
/*

Step 1 capacity per municipality -> ProToNow
       Status Quo
Step 2 Structure of PV ( volatage level, size, Number)
Step 3 add new PV at center of municipality polygon
Step 4 add volatage level, etc.


List of DB tables:
ToDo: What is the diff between both tables beside number of entries
  * orig_geo_vg250.vg250_6_gem_clean
  * orig_geo_vg250.vg250_6_gem
*/

-- Drop Table orig_geo_powerplants.renewable_power_plants_germany_to_region CASCADE;

Create Table orig_geo_powerplants.renewable_power_plants_germany_to_region
(
re_id bigint NOT NULL,   	-- id from proc_renewable_power_plants_germany
subst_id bigint,      		-- substation ID
otg_id bigint,        		-- 
un_id bigint,         		--   
nuts character varying(5),	-- Nuts key for districts 
rs_0 character varying(12),	-- German Regionalschlüssel
id_vg250 bigint, 		-- ID of orig_geo_vg250.vg250_6_gem_clean table
CONSTRAINT renewable_power_plants_germany_to_region_pkey PRIMARY KEY (re_id)
);

ALTER TABLE orig_geo_powerplants.renewable_power_plants_germany_to_region
  OWNER TO oeuser;
  
GRANT ALL ON TABLE orig_geo_powerplants.renewable_power_plants_germany_to_region TO oeuser WITH GRANT OPTION;
GRANT ALL ON TABLE orig_geo_powerplants.renewable_power_plants_germany_to_region TO oerest WITH GRANT OPTION;

--- ---------------------------------------------------------------------------
-- DELETE FROM orig_geo_powerplants.renewable_power_plants_germany_to_region;

INSERT INTO orig_geo_powerplants.renewable_power_plants_germany_to_region (re_id,subst_id,otg_id,un_id)
SELECT
id as re_id,
subst_id,
otg_id,
un_id
FROM
orig_geo_powerplants.proc_renewable_power_plants_germany;

--
Update orig_geo_powerplants.renewable_power_plants_germany_to_region A
set id_vg250 = B.id,
    rs_0 = B.rs_0,
    nuts = B.nuts
FROM (
	SELECT
	D.id as re_id,
	C.id,
	C.rs_0,
	C.nuts    
	FROM orig_geo_vg250.vg250_6_gem_clean C,
	     orig_geo_powerplants.proc_renewable_power_plants_germany D
	WHERE ST_Intersects(ST_Transform(C.geom, 4326), D.geom)
      ) as B
WHERE B.re_id = A.re_id;
---
---

SELECT
count(*)
FROM orig_geo_powerplants.renewable_power_plants_germany_to_region 
WHERE nuts IS NULL;

-- Get nuts ID by buffering geometry 
-- ToDo noch mal ausführen!
Update orig_geo_powerplants.renewable_power_plants_germany_to_region A
set id_vg250 = C.id,
    rs_0 = C.rs_0,
    nuts = C.nuts
FROM
   (
	SELECT
	  A.re_id,
	  B.geom
	FROM
	orig_geo_powerplants.renewable_power_plants_germany_to_region A,
	orig_geo_powerplants.proc_renewable_power_plants_germany B
	WHERE A.re_id = B.id
	AND A.nuts IS NULL
  ) as AA,
  orig_geo_vg250.vg250_6_gem_clean C
WHERE ST_Intersects(ST_Transform(C.geom, 4326), ST_Buffer(AA.geom,10))
AND AA.re_id = A.re_id;
--
--

--- --------------------------------------------------------------------
--   Status Quo PV
--- 

-- DROP SEQUENCE orig_geo_powerplants.pv_dev_nep_germany_mun_id_seq;
CREATE SEQUENCE orig_geo_powerplants.pv_dev_nep_germany_mun_id_seq START 1;

-- DROP TABLE orig_geo_powerplants.pv_dev_nep_germany_mun CASCADE;

Create Table orig_geo_powerplants.pv_dev_nep_germany_mun
(
id bigint NOT NULL DEFAULT nextval('orig_geo_powerplants.pv_dev_nep_germany_mun_id_seq'::regclass),-- own id PK 
pv_units integer,      		-- number of PV units per mun and voltage level 
pv_cap_2014 integer,        	-- sum per region of 2014 in kW 
pv_add_cap_2035 integer,        -- sum per region of additional Capacity in 2035 kW 
voltage_level smallint,        	-- voltage_level from 1-7   
rs_0 character varying(12),	-- German Regionalschlüssel
pv_avg_cap integer, 		-- average capacity per region and voltage level
pv_new_units numeric(5,2), 		-- New number of region per voltage level 
CONSTRAINT pv_dev_nep_germany_mun_pkey PRIMARY KEY (id)
);
--
--

Insert into orig_geo_powerplants.pv_dev_nep_germany_mun (pv_units,pv_cap_2014,voltage_level,rs_0,pv_avg_cap)
SELECT
  count(A.*) as pv_units,
  sum(A.electrical_capacity) as pv_cap_2014,
  A.voltage_level,
  B.rs_0,
  avg(A.electrical_capacity) as pv_avg_cap
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany A, 
  orig_geo_vg250.vg250_6_gem_clean B
WHERE
  ST_Intersects(ST_Transform(B.geom, 4326), A.geom)
AND A.generation_type = 'solar'
Group by A.voltage_level, B.id, B.rs_0;


--- -----------------------------------------------------------------------------
-- PV ProxToNow per municipality and voltage level
---
/*
UPDATE orig_geo_powerplants.pv_dev_nep_germany_mun
 set     pv_add_cap_2035 = NULL;


1. Pro Gemeinde Polygon werden die PV Anlagen 2014 pro Voltage level, Anzahl und installierter Leistung aufsummiert,
   Eine Durchschnittliche Anlage wird pro Gemeinde und Voltagelevel gebildet
	Gemeinden und voltage level die nicht betroffen sind, werden nicht mehr berücksichtigt
2. Der Zubau pro Gemeinde und voltage level wird Proportional zu 2014 anhand der NEP 2035 Szenariodaten gebildet
   Formel P_add(Gemeinde,Voltage Level, 2035) =  (P_sum(Gemeinde,Voltage Level, 2014)/ P_sum(Bundesland,2014) 
						 ) x P_sum(Bundesland,2035) - P_sum(Gemeinde,Voltage Level, 2014)

3. Anhand der Zubauzahlen pro Gemeinde und voltage level wird die Anzahl neuer Anlagen anhand der durchschnittlichen
   Größe (kW) gebildet.

4. Die Status Quo Daten werden in orig_geo_powerplants.proc_renewable_power_plants_nep2035 überführt

5. Die neuen Anlagen werden anhand des Mittelpunktes der Gemeinde in orig_geo_powerplants.proc_renewable_power_plants_nep2035 
   hinzugefügt
   
6. Übergabe an weiten Skript zur Zuweisung der Netzknoten
               

*/



UPDATE orig_geo_powerplants.pv_dev_nep_germany_mun AA
set     pv_add_cap_2035 = ( (AA.pv_cap_2014::numeric / pv_sq_2014.fs_cap_2014::numeric)*pv_scn_2035.fs_cap_2035 
                             -AA.pv_cap_2014)::integer
                              
FROM
(
SELECT
 substring(A.rs_0 from 1 for 2) as rs,        -- Regionalschlüssel first 2 numbers = federal state
 scn.capacity*1000 as fs_cap_2035 ,           -- in kW
 scn.nuts  				      -- nuts code federal state
 FROM
   orig_geo_vg250.vg250_6_gem_clean A,
    orig_scenario_data.nep_2015_scenario_capacities scn
WHERE scn.nuts = substring(A.nuts from 1 for 3)
AND   scn.generation_type = 'solar' 
Group by substring(A.nuts from 1 for 3),rs,scn.capacity,scn.nuts
) as pv_scn_2035,
(
SELECT
   substring(A.rs_0 from 1 for 2) as rs,        -- Regionalschlüssel first 2 numbers = federal state
   sum(A.pv_cap_2014) as fs_cap_2014            -- in kW
FROM
  orig_geo_powerplants.pv_dev_nep_germany_mun A
Group by  substring(A.rs_0 from 1 for 2) 
) as pv_sq_2014
Where pv_scn_2035.rs = pv_sq_2014.rs
AND substring(AA.rs_0 from 1 for 2) =  pv_sq_2014.rs
AND substring(AA.rs_0 from 1 for 2) =  pv_scn_2035.rs
;

--- ---------------------------------------------------------------------
-- Count new additional Units -> new_units

UPDATE orig_geo_powerplants.pv_dev_nep_germany_mun AA
set     pv_new_units =  round(pv_add_cap_2035/pv_avg_cap); 

-- Controll PV development 

SELECT
substring(A.rs_0 from 1 for 2)  rs_fs,       		-- fs ID
SUM(A.pv_add_cap_2035)/1000 pv_add_cap_2035, 		-- additional Capacity in MW
sum(A.pv_cap_2014)/1000  pv_cap_2014,          		-- capacity 2014 im MW
scn.capacity_2035,                           		-- Scenario capacity 2035 in MW
(SUM(A.pv_add_cap_2035) +sum(A.pv_cap_2014))/1000 total -- in MW
FROM
 (
SELECT
  scn.nuts,
  substring(AA.rs_0 from 1 for 2) as rs,
  scn.capacity as capacity_2035,
  scn.generation_type
FROM
  orig_geo_vg250.vg250_6_gem_clean AA,
  orig_scenario_data.nep_2015_scenario_capacities as scn
WHERE scn.nuts = substring(AA.nuts from 1 for 3)
AND  scn.generation_type = 'solar'
group by scn.nuts, substring(AA.rs_0 from 1 for 2), substring(AA.nuts from 1 for 3),
         scn.capacity,scn.generation_type
) as scn,
 orig_geo_powerplants.pv_dev_nep_germany_mun A
WHERE scn.rs = substring(rs_0 from 1 for 2)
Group by substring(rs_0 from 1 for 2),scn.capacity_2035;

---  ---------------------------------------------------------------------------------
-- Take status Quo and Add new PV plants 
-- Insert new units by pv_new_units 
-- geom = centroid of mun geom , see http://postgis.net/docs/ST_PointOnSurface.html
-- generation_subtype is not defined 

INSERT INTO orig_geo_powerplants.proc_renewable_power_plants_nep2035
SELECT
  id, 				--
  2035 AS scenario_year, 	--
  electrical_capacity ,  	-- in kW
  generation_type ,		--
  generation_subtype,   	--
  thermal_capacity, 		--
  NULL AS nuts,			-- nuts id of federal state
  lon,  			--
  lat, 				--	
  voltage_level,   		-- 
  network_node, 		--
  source,  		        -- orignal source name
  comment,  			-- Own comment
  geom,  			--
  voltage,  			--
  subst_id,  			--
  otg_id,  			--
  un_id				--
FROM
  orig_geo_powerplants.proc_renewable_power_plants_germany
WHERE
generation_type = 'solar';

-- set nuts

UPDATE orig_geo_powerplants.proc_renewable_power_plants_nep2035 as upt
set nuts = regions.nuts
from 
  orig_geo_vg250.vg250_2_lan_nuts_view as regions
WHERE ST_Intersects(ST_Transform(regions.geom, 4326), upt.geom)
AND generation_type = 'solar';


---
-- Add new PV units 
---

Insert into orig_geo_powerplants.proc_renewable_power_plants_nep2035 (id,scenario_year,electrical_capacity,
generation_type, voltage_level, source, comment,geom)

	SELECT
	  sub2.max_rown + row_number() over () as id ,
	  2035  as scenario_year,
	  sub.electrical_capacity,
	  'solar'::text as generation_type,
	  sub.voltage_level,
	  'open_ego NEP 2015 B2035'::text as  source,
	  ', Method ProxToNow solar'::text as comment, 
	  sub.geom
	FROM (
	SELECT
	  A.rs_0,
	  A.voltage_level,
	  Case when A.pv_new_units = 0 Then A.pv_add_cap_2035
	       else  unnest(array_fill(A.pv_avg_cap, Array[A.pv_new_units])) END as electrical_capacity , -- in k
	 ST_Transform(ST_PointOnSurface(B.geom), 4326) as geom     
	FROM 
	  orig_geo_powerplants.pv_dev_nep_germany_mun A,
	  orig_geo_vg250.vg250_6_gem_clean B
	Where A.rs_0 = B.rs_0
	) as sub ,
	(Select
	 max(id) as max_rown
	 FROM
	  orig_geo_powerplants.proc_renewable_power_plants_nep2035
	  ) as sub2
;

-- ---------------------------------
-- Sort summary -> 1147084 new PV Systems for 2035


  
--DELETE FROM orig_geo_powerplants.proc_renewable_power_plants_nep2035
--WHERE comment = ', Method ProxToNow solar';
  
--- -- ---- -- - ---- ----- 
--- ToDo's and check-up 
----- --- - - ---- ---- 
/*
add Subtypes ?
new script or use of skript to get =
  voltage,
  subst_id,  			
  otg_id,  		
  un_id	
 Data
*/


--- # # # # # # # # # # # # # # #
-- 
-- Check Scenario Data per felderal state
--
--- # # # # # # # # # # # # # # #

SELECT
A.nuts,
B.gen,
A.generation_type,
round(sum(A.electrical_capacity)/1000000,2) as cap_sum -- in GW
FROM
 orig_geo_powerplants.proc_renewable_power_plants_nep2035 A,
 orig_geo_vg250.vg250_2_lan_nuts_view B
WHERE A.nuts = B.nuts

Group by A.nuts,A.generation_type,B.gen
Order by gen,generation_type;



--- ---------------------------------------------------------
-- QGIS DB View Scenario data per federal state
--- 
SELECT
a.gen,
a.nuts,
b.generation_type,
b.capacity,
a.geom
FROM
orig_geo_vg250.vg250_2_lan_nuts_view a,
orig_scenario_data.nep_2015_scenario_capacities as b
WHERE
a.nuts = b.nuts
AND
b.generation_type = 'biomass'
group by a.gen, a.geom, b.generation_type, a.nuts,b.capacity;


--- Status Quo Structure
--
SELECT
  count(renewable.id) amount,
  renewable.generation_type
from 
  orig_geo_powerplants.proc_renewable_power_plants_germany as renewable
Group by renewable.generation_type-- renewable.voltage_level


SELECT
  regions.gen,
  regions.nuts,
  count(renewable.id) amount,
  (sum(electrical_capacity)/1000) capacity, -- MW
  renewable.generation_type,
 -- renewable.voltage_level,
  count(renewable.voltage_level),
  scn.capacity as new ,
  (scn.capacity - (sum(electrical_capacity)/1000)) as diff, -- in MW
  (( scn.capacity*1000 - (sum(electrical_capacity)))/ count(renewable.id)) as add_per_unit -- in kW
from 
  orig_geo_powerplants.proc_renewable_power_plants_nep2035 as renewable,
  orig_geo_vg250.vg250_2_lan_nuts_view as regions,
  orig_scenario_data.nep_2015_scenario_capacities as scn
WHERE
renewable.generation_type = 'hydro'
AND 
scn.generation_type = 'hydro'
AND
 scn.nuts = regions.nuts
AND
ST_Intersects(ST_Transform(regions.geom, 4326), renewable.geom)
Group by renewable.generation_type,regions.nuts, regions.gen, scn.capacity, scn.nuts--, renewable.voltage_level
;

----
SELECT 
A.*,
B.geom
FROM
orig_geo_powerplants.pv_dev_nep_germany_mun A,
orig_geo_vg250.vg250_6_gem_clean B
WHERE B.rs_0 = A.rs_0


SELECT
count(*)
FROM
orig_geo_powerplants.proc_renewable_power_plants_germany 
WHERE generation_type = 'solar'

SELECT
*
FROM
orig_geo_vg250.vg250_6_gem_clean
LIMIT 1


