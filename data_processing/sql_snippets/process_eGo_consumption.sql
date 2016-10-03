


DROP TABLE IF EXISTS 	calc_ego_loads.ego_deu_consumption CASCADE;
CREATE TABLE 		calc_ego_loads.ego_deu_consumption
(
	id integer NOT NULL,
	subst_id integer,
 	sector_area_residential numeric,
	sector_area_retail numeric,
	sector_area_industrial numeric,
	sector_area_agricultural numeric,
	sector_consumption_residential numeric,
	sector_consumption_retail numeric,
	sector_consumption_industrial numeric,
	sector_consumption_agricultural numeric,
	CONSTRAINT ego_deu_consumption_pkey PRIMARY KEY (id)
);

-- Set ID   (OK!) -> 100ms =206.846
INSERT INTO 	calc_ego_loads.ego_deu_consumption (id,subst_id,
													sector_area_residential,sector_area_retail,
													sector_area_industrial,sector_area_agricultural)
	SELECT 	id,
			subst_id,
			sector_area_residential,
			sector_area_retail,
			sector_area_industrial,
			sector_area_agricultural
	FROM 	calc_ego_loads.ego_deu_load_area;
	

-- Calculate the landuse area per district 

-- ALTER TABLE orig_ego_consumption.lak_consumption_per_district
-- 	ADD COLUMN area_retail numeric,
-- 	ADD COLUMN area_agriculture numeric,
-- 	ADD COLUMN area_tertiary_sector numeric;


-- Calculate the retail area per district

UPDATE orig_ego_consumption.lak_consumption_per_district a
SET area_retail = result.sum
FROM
( 
	SELECT 
	sum(sector_area_retail), 
	substr(nuts,1,5) 
	FROM calc_ego_loads.ego_deu_load_area
	GROUP BY substr(nuts,1,5)
) as result

WHERE result.substr = substr(a.eu_code,1,5);


-- Calculate the agricultural area per district

UPDATE orig_ego_consumption.lak_consumption_per_district a
SET area_agriculture = result.sum
FROM
( 
	SELECT 
	sum(sector_area_agricultural), 
	substr(nuts,1,5) 
	FROM calc_ego_loads.ego_deu_load_area
	GROUP BY substr(nuts,1,5)
) as result

WHERE result.substr = substr(a.eu_code,1,5);


-- Calculate area of tertiary sector by adding agricultural and retail area up


UPDATE orig_ego_consumption.lak_consumption_per_district 
	SET area_tertiary_sector = coalesce(area_retail,0) + coalesce(area_agriculture,0);


-- Calculate sector consumption of industry per loadarea

UPDATE calc_ego_loads.ego_deu_consumption a
SET   sector_consumption_industrial = sub.result 
FROM
(
	SELECT
	c.id,
	b.elec_consumption_industry/nullif(b.area_industry,0) * c.sector_area_industrial as result
	FROM
	orig_ego_consumption.lak_consumption_per_district b,
	calc_ego_loads.ego_deu_load_area c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.id = a.id;

-- Calculate sector consumption of tertiary sector per loadarea

UPDATE calc_ego_loads.ego_deu_consumption a
SET   sector_consumption_retail = sub.result 
FROM
(
	SELECT
	c.id,
	b.elec_consumption_tertiary_sector/nullif(b.area_tertiary_sector,0) * c.sector_area_retail as result
	FROM
	orig_ego_consumption.lak_consumption_per_district b,
	calc_ego_loads.ego_deu_load_area c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.id = a.id;

-- Calculate sector consumption of agriculture per loadarea

UPDATE calc_ego_loads.ego_deu_consumption a
SET   sector_consumption_agricultural = sub.result 
FROM
(
	SELECT
	c.id,
	b.elec_consumption_tertiary_sector/nullif(b.area_tertiary_sector,0) * c.sector_area_agricultural as result
	FROM
	orig_ego_consumption.lak_consumption_per_district b,
	calc_ego_loads.ego_deu_load_area c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.id = a.id;


-- Calculate sector consumption of households per loadarea

UPDATE calc_ego_loads.ego_deu_consumption a
SET   sector_consumption_residential = sub.result 
FROM
(
	SELECT
	c.id,
	b.elec_consumption_households_per_person * c.zensus_sum as result
	FROM 
	orig_ego_consumption.lak_consumption_per_federalstate b,
	calc_ego_loads.ego_deu_load_area c
	WHERE
	substring(c.nuts,1,3) = b.eu_code

) AS sub
WHERE
sub.id = a.id;

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_loads.ego_deu_consumption TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_loads.ego_deu_consumption OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'calc_ego_loads' AS schema_name,
		'ego_deu_consumption' AS table_name,
		'process_eGo_consumption.sql' AS script_name,
		COUNT(id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	calc_ego_loads.ego_deu_consumption;

---------- ---------- ----------

-- -- Consumption Join   (OK!) 10.000ms =206.846
-- DROP TABLE IF EXISTS 	calc_ego_loads.ego_deu_consumption_area CASCADE;
-- CREATE TABLE 		calc_ego_loads.ego_deu_consumption_area AS
-- 	SELECT	a.id,
-- 		a.subst_id,
-- 		a.sector_area_residential,
-- 		a.sector_area_retail,
-- 		a.sector_area_industrial,
-- 		a.sector_area_agricultural,
-- 		c.sector_consumption_residential,
-- 		c.sector_consumption_retail,
-- 		c.sector_consumption_industrial,
-- 		c.sector_consumption_agricultural,
-- 		coalesce(c.sector_consumption_residential,0) + 
-- 			coalesce(c.sector_consumption_retail,0) + 
-- 			coalesce(c.sector_consumption_industrial,0) + 
-- 			coalesce(c.sector_consumption_agricultural,0) AS consumption_sum,
-- 		a.geom ::geometry(Polygon,3035)
-- 	FROM	calc_ego_loads.ego_deu_load_area AS a JOIN calc_ego_loads.ego_deu_consumption AS c ON (a.id = c.id);
-- 
-- -- Ad PK   (OK!) 150ms =0
-- ALTER TABLE	calc_ego_loads.ego_deu_consumption_area
-- 	ADD PRIMARY KEY (id);
-- 
-- -- Create Index GIST (geom)   (OK!) 2.500ms =0
-- CREATE INDEX	ego_deu_consumption_area_geom_idx
-- 	ON	calc_ego_loads.ego_deu_consumption_area
-- 	USING	GIST (geom);
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	calc_ego_loads.ego_deu_consumption_area TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		calc_ego_loads.ego_deu_consumption_area OWNER TO oeuser;

---------- ---------- ----------

-- Create Test Area
DROP TABLE IF EXISTS	calc_ego_loads.ego_deu_consumption_ta CASCADE;
CREATE TABLE 		calc_ego_loads.ego_deu_consumption_ta AS
	SELECT	load.*
	FROM	calc_ego_loads.ego_deu_consumption AS load
	WHERE	subst_id = '372' OR
		subst_id = '387' OR
		subst_id = '373' OR
		subst_id = '407' OR
		subst_id = '403' OR
		subst_id = '482' OR
		subst_id = '416' OR
		subst_id = '425' OR
		subst_id = '491' OR
		subst_id = '368' OR
		subst_id = '360' OR
		subst_id = '571' OR
		subst_id = '593';

-- Ad PK   (OK!) 150ms =0
ALTER TABLE	calc_ego_loads.ego_deu_consumption_ta
	ADD PRIMARY KEY (id);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	calc_ego_loads.ego_deu_consumption_ta TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_loads.ego_deu_consumption_ta OWNER TO oeuser;

---------- ---------- ----------

-- -- Consumption Join   (OK!) 10.000ms =206.846
-- DROP TABLE IF EXISTS 	calc_ego_loads.ego_deu_consumption_area_ta CASCADE;
-- CREATE TABLE 		calc_ego_loads.ego_deu_consumption_area_ta AS
-- 	SELECT	a.id,
-- 		a.subst_id,
-- 		a.sector_area_residential,
-- 		a.sector_area_retail,
-- 		a.sector_area_industrial,
-- 		a.sector_area_agricultural,
-- 		c.sector_consumption_residential,
-- 		c.sector_consumption_retail,
-- 		c.sector_consumption_industrial,
-- 		c.sector_consumption_agricultural,
-- 		coalesce(c.sector_consumption_residential,0) + 
-- 			coalesce(c.sector_consumption_retail,0) + 
-- 			coalesce(c.sector_consumption_industrial,0) + 
-- 			coalesce(c.sector_consumption_agricultural,0) AS consumption_sum,
-- 		a.geom ::geometry(Polygon,3035)
-- 	FROM	calc_ego_loads.ego_deu_load_area_ta AS a JOIN calc_ego_loads.ego_deu_consumption_ta AS c ON (a.id = c.id);
-- 
-- -- Ad PK   (OK!) 150ms =0
-- ALTER TABLE	calc_ego_loads.ego_deu_consumption_area_ta
-- 	ADD PRIMARY KEY (id);
-- 
-- -- Create Index GIST (geom)   (OK!) 2.500ms =0
-- CREATE INDEX	ego_deu_consumption_area_ta_geom_idx
-- 	ON	calc_ego_loads.ego_deu_consumption_area_ta
-- 	USING	GIST (geom);
-- 
-- -- Grant oeuser   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	calc_ego_loads.ego_deu_consumption_area_ta TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		calc_ego_loads.ego_deu_consumption_area_ta OWNER TO oeuser;
