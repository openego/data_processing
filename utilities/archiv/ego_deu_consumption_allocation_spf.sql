
---------- ---------- ----------
-- "Create Consumption Loads SPF"   2016-04-07 11:43   1s
---------- ---------- ----------

-- "Create Table Consumption"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_ego.ego_deu_loads_consumption_spf;
CREATE TABLE 		orig_ego.ego_deu_loads_consumption_spf (
	id integer NOT NULL,
	sector_consumption_residential numeric,
	sector_consumption_retail numeric,
	sector_consumption_industrial numeric,
	sector_consumption_agricultural numeric,
	CONSTRAINT ego_deu_loads_consumption_spf_pkey PRIMARY KEY (id));

-- "Insert Loads"   (OK!) 150ms =884
INSERT INTO orig_ego.ego_deu_loads_consumption_spf (id)
	SELECT	loads.id
	FROM	orig_ego.ego_deu_loads_spf AS loads;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_loads_consumption_spf TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_consumption_spf OWNER TO oeuser;


---------- ---------- ----------
-- "Create Consumption Loads SPF"   2016-04-07 11:43   1s
---------- ---------- ----------

-- Calculate the industrial area per district 

SELECT	sum(sector_area_industrial), substr(nuts,1,5) 
	INTO 	orig_consumption_znes.temp_table
	FROM 	orig_ego.ego_deu_loads_spf
GROUP BY 	substr(nuts,1,5);

UPDATE orig_consumption_znes.lak_consumption_per_district a
	SET 	area_industry = sum
	FROM 	orig_consumption_znes.temp_table b
	WHERE 	b.substr = substr(a.eu_code,1,5);

DROP TABLE IF EXISTS orig_consumption_znes.temp_table;


-- Calculate the retail area per district

SELECT sum(sector_area_retail), substr(nuts,1,5) 
	INTO 	orig_consumption_znes.temp_table
	FROM 	orig_ego.ego_deu_loads_spf
GROUP BY 	substr(nuts,1,5);

UPDATE orig_consumption_znes.lak_consumption_per_district a
	SET 	area_retail = sum
	FROM 	orig_consumption_znes.temp_table b
	WHERE 	b.substr = substr(a.eu_code,1,5);

DROP TABLE IF EXISTS orig_consumption_znes.temp_table;


-- Calculate the agricultural area per district

SELECT sum(sector_area_agricultural), substr(nuts,1,5) 
	INTO 	orig_consumption_znes.temp_table
	FROM 	orig_ego.ego_deu_loads_spf
GROUP BY 	substr(nuts,1,5);

UPDATE orig_consumption_znes.lak_consumption_per_district a
	SET 	area_agriculture = sum
	FROM 	orig_consumption_znes.temp_table b
	WHERE 	b.substr = substr(a.eu_code,1,5);

DROP TABLE IF EXISTS orig_consumption_znes.temp_table;


-- Calculate area of tertiary sector by adding agricultural and retail area up

UPDATE	orig_consumption_znes.lak_consumption_per_district 
SET 	area_tertiary_sector = coalesce(area_retail,0) + coalesce(area_agriculture,0);

-- Calculate electricity demand per loadarea

UPDATE 	orig_consumption_znes.lak_consumption_per_district
SET 	consumption_per_area_tertiary_sector = elec_consumption_tertiary_sector/nullif(area_tertiary_sector,0);

UPDATE 	orig_consumption_znes.lak_consumption_per_district
SET 	consumption_per_area_industry = elec_consumption_industry/nullif(area_industry,0);



---------- ---------- ----------
-- "Create Sector Consumption SPF"   2016-04-07 11:43   1s
---------- ---------- ----------

-- Calculate sector consumption of industry per loadarea

UPDATE 	orig_ego.ego_deu_loads_consumption_spf a
SET   	sector_consumption_industrial = sub.result 
FROM
(
	SELECT
	c.id,
	b.consumption_per_area_industry * c.sector_area_industrial as result
	FROM
	orig_consumption_znes.lak_consumption_per_district b,
	orig_ego.ego_deu_loads_spf c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.id = a.id;

-- Calculate sector consumption of tertiary sector per loadarea

UPDATE orig_ego.ego_deu_loads_consumption_spf a
SET   sector_consumption_retail = sub.result 
FROM
(
	SELECT
	c.id,
	b.consumption_per_area_tertiary_sector * c.sector_area_retail as result
	FROM
	orig_consumption_znes.lak_consumption_per_district b,
	orig_ego.ego_deu_loads_spf c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.id = a.id;

-- Calculate sector consumption of agriculture per loadarea

UPDATE orig_ego.ego_deu_loads_consumption_spf a
SET   sector_consumption_agricultural = sub.result 
FROM
(
	SELECT
	c.id,
	b.consumption_per_area_tertiary_sector * c.sector_area_agricultural as result
	FROM
	orig_consumption_znes.lak_consumption_per_district b,
	orig_ego.ego_deu_loads_spf c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.id = a.id;


-- Calculate sector consumption of households per loadarea

UPDATE orig_ego.ego_deu_loads_consumption_spf a
SET   sector_consumption_residential = sub.result 
FROM
(
	SELECT
	c.id,
	b.elec_consumption_households_per_person * c.zensus_sum as result
	FROM 
	orig_consumption_znes.lak_consumption_per_federalstate b,
	orig_ego.ego_deu_loads_spf c
	WHERE
	substring(c.nuts,1,3) = b.eu_code

) AS sub
WHERE
sub.id = a.id;

