


DROP TABLE IF EXISTS 	model_draft.ego_demand_per_load_area CASCADE;
CREATE TABLE 		model_draft.ego_demand_per_load_area 
(
	id integer NOT NULL,
	subst_id integer,
	otg_id integer,
	un_id integer,
 	sector_area_residential numeric,
	sector_area_retail numeric,
	sector_area_industrial numeric,
	sector_area_agricultural numeric,
	sector_consumption_residential numeric,
	sector_consumption_retail numeric,
	sector_consumption_industrial numeric,
	sector_consumption_agricultural numeric,
	geom geometry (Polygon,3035), 
	CONSTRAINT ego_deu_consumption_pkey PRIMARY KEY (id)
);

-- Set ID   (OK!) -> 100ms =206.846
INSERT INTO 	model_draft.ego_demand_per_load_area (id,subst_id,
		sector_area_residential,sector_area_retail,
		sector_area_industrial,sector_area_agricultural)
	SELECT 		id,
			subst_id,
			sector_area_residential,
			sector_area_retail,
			sector_area_industrial,
			sector_area_agricultural
	FROM 	model_draft.ego_demand_loadarea;
	

-- Calculate the landuse area per district 

-- ALTER TABLE model_draft.ego_demand_per_district
-- 	ADD COLUMN area_retail numeric,
-- 	ADD COLUMN area_agriculture numeric,
-- 	ADD COLUMN area_tertiary_sector numeric;


-- Calculate the retail area per district

UPDATE model_draft.ego_demand_per_district a
SET area_retail = result.sum
FROM
( 
	SELECT 
	--sum(sector_area_retail), --Merge-error???
 	sum(coalesce(sector_area_retail,0)), 
	substr(nuts,1,5) 
	FROM model_draft.ego_demand_loadarea
	GROUP BY substr(nuts,1,5)
) as result

WHERE result.substr = substr(a.eu_code,1,5);


-- Calculate the agricultural area per district

UPDATE model_draft.ego_demand_per_district a
SET area_agriculture = result.sum
FROM
( 
	SELECT 
	--sum(sector_area_agricultural), --Merge-error???
	sum(coalesce(sector_area_agricultural,0)), 
	substr(nuts,1,5) 
	FROM model_draft.ego_demand_loadarea
	GROUP BY substr(nuts,1,5)
) as result

WHERE result.substr = substr(a.eu_code,1,5);


-- Calculate area of tertiary sector by adding agricultural and retail area up


UPDATE model_draft.ego_demand_per_district 
	SET area_tertiary_sector = coalesce(area_retail,0) + coalesce(area_agriculture,0);


-- Calculate sector consumption of industry per loadarea

UPDATE model_draft.ego_demand_per_load_area a
SET   sector_consumption_industrial = sub.result 
FROM
(
	SELECT
	c.id,
	b.elec_consumption_industry/nullif(b.area_industry,0) * c.sector_area_industrial as result
	FROM
	model_draft.ego_demand_per_district b,
	model_draft.ego_demand_loadarea c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.id = a.id;

-- Calculate sector consumption of tertiary sector per loadarea

UPDATE model_draft.ego_demand_per_load_area a
SET   sector_consumption_retail = sub.result 
FROM
(
	SELECT
	c.id,
	b.elec_consumption_tertiary_sector/nullif(b.area_tertiary_sector,0) * c.sector_area_retail as result
	FROM
	model_draft.ego_demand_per_district b,
	model_draft.ego_demand_loadarea c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.id = a.id;

-- Calculate sector consumption of agriculture per loadarea

UPDATE model_draft.ego_demand_per_load_area a
SET   sector_consumption_agricultural = sub.result 
FROM
(
	SELECT
	c.id,
	b.elec_consumption_tertiary_sector/nullif(b.area_tertiary_sector,0) * c.sector_area_agricultural as result
	FROM
	model_draft.ego_demand_per_district b,
	model_draft.ego_demand_loadarea c
	WHERE
	c.nuts = b.eu_code
) AS sub
WHERE
sub.id = a.id;


-- Calculate sector consumption of households per loadarea

UPDATE model_draft.ego_demand_per_load_area a
SET   sector_consumption_residential = sub.result 
FROM
(
	SELECT
	c.id,
	b.elec_consumption_households_per_person * c.zensus_sum as result
	FROM 
	demand.ego_demand_federalstate b,
	model_draft.ego_demand_loadarea c
	WHERE
	substring(c.nuts,1,3) = substring(b.eu_code, 1,3)

) AS sub
WHERE
sub.id = a.id;

-- Add Geometry information in consumption table

UPDATE model_draft.ego_demand_per_load_area a
SET geom = b.geom
FROM model_draft.ego_demand_loadarea b
WHERE a.id = b.id;


-- Identify corresponding otg_id

UPDATE model_draft.ego_demand_per_load_area a
	SET otg_id = b.otg_id
	FROM model_draft.ego_grid_hvmv_substation b
WHERE a.subst_id = b.subst_id; 


-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_demand_per_load_area TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_demand_per_load_area OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'ego_demand_per_load_area' AS schema_name,
		'model_draft' AS table_name,
		'process_eGo_consumption.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_demand_per_load_area;


-- metadata

COMMENT ON TABLE  model_draft.ego_demand_per_load_area IS
'{
"Name": "Electricity consumption per load area",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "",
"Date of collection": "19.10.2016",
"Original file": "process_eGo_consumption.sql",
"Spatial resolution": ["Germany"],
"Description": ["Spatial allocation of electricity consumption to load_area "],
"Column": [
                   {"Name": "id",
                    "Description": "load area id",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "id of associated HV/MV substation",
                    "Unit": "" },
                   {"Name": "sector_area_residential",
                    "Description": "aggregated residential area",
                    "Unit": "ha" },
                   {"Name": "sector_area_retail",
                    "Description": "aggregated retail area",
                    "Unit": "ha" },
                   {"Name": "sector_area_industrial",
                    "Description": "aggregated industrial area",
                    "Unit": "ha" },
                   {"Name": "sector_area_agricultural",
                    "Description": "aggregated agricultural area",
                    "Unit": "ha" },
                   {"Name": "sector_consumption_residential",
                    "Description": "electricity consumption of households",
                    "Unit": "GWh" },
                   {"Name": "sector_consumption_retail",
                    "Description": "electricity consumption of retail sector",
                    "Unit": "GWh" },
                   {"Name": "sector_consumption_industrial",
                    "Description": "electricity consumption of industrial sector",
                    "Unit": "GWh" },
                   {"Name": "sector_consumption_agricultural",
                    "Description": "electricity consumption of agricultural sector",
                    "Unit": "GWh" },
                   {"Name": "geom",
                    "Description": "geometry of load area",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "25.10.2016",
                    "Comment": "completed json-String" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


