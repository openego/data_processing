/*
Allocate consumption to Loadareas

__copyright__   = "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "IlkaCu, Ludee" 
*/


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_demand_per_district','ego_dp_loadarea_consumption.sql',' ');

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_demand_loadarea','ego_dp_loadarea_consumption.sql',' ');

-- landuse area per district 
ALTER TABLE model_draft.ego_demand_per_district
    DROP COLUMN IF EXISTS area_retail CASCADE,
    ADD COLUMN area_retail double precision,
    DROP COLUMN IF EXISTS area_agriculture CASCADE,
    ADD COLUMN area_agriculture double precision,
    DROP COLUMN IF EXISTS area_tertiary_sector CASCADE,
    ADD COLUMN area_tertiary_sector double precision;
 
-- retail area per district
UPDATE model_draft.ego_demand_per_district a
    SET area_retail = result.sum
    FROM ( 
        SELECT 
        sum(coalesce(sector_area_retail,0)), 
        substr(nuts,1,5) 
        FROM model_draft.ego_demand_loadarea
        GROUP BY substr(nuts,1,5)
    ) as result
    WHERE result.substr = substr(a.eu_code,1,5);

-- agricultural area per district
UPDATE model_draft.ego_demand_per_district a
    SET area_agriculture = result.sum
    FROM ( 
        SELECT 
        sum(coalesce(sector_area_agricultural,0)), 
        substr(nuts,1,5) 
        FROM model_draft.ego_demand_loadarea
        GROUP BY substr(nuts,1,5)
    ) as result
    WHERE result.substr = substr(a.eu_code,1,5);

-- area of tertiary sector by adding agricultural and retail area up
UPDATE model_draft.ego_demand_per_district 
    SET area_tertiary_sector = coalesce(area_retail,0) + coalesce(area_agriculture,0);


-- sector consumption of industry per loadarea
UPDATE model_draft.ego_demand_loadarea a
    SET   sector_consumption_industrial = sub.result 
    FROM (
        SELECT
            c.id,
            b.elec_consumption_industry/nullif(b.area_industry,0) * c.sector_area_industrial as result
        FROM
            model_draft.ego_demand_per_district b,
            model_draft.ego_demand_loadarea c
        WHERE
            c.nuts = b.eu_code
    ) AS sub
    WHERE sub.id = a.id;

-- sector consumption of retail per loadarea
UPDATE model_draft.ego_demand_loadarea a
    SET   sector_consumption_retail = sub.result 
    FROM (
        SELECT
            c.id,
            b.elec_consumption_tertiary_sector/nullif(b.area_tertiary_sector,0) * c.sector_area_retail as result
        FROM
            model_draft.ego_demand_per_district b,
            model_draft.ego_demand_loadarea c
        WHERE
            c.nuts = b.eu_code
    ) AS sub
    WHERE sub.id = a.id;

-- sector consumption of agriculture per loadarea
UPDATE model_draft.ego_demand_loadarea a
    SET   sector_consumption_agricultural = sub.result 
    FROM (
        SELECT
            c.id,
            b.elec_consumption_tertiary_sector/nullif(b.area_tertiary_sector,0) * c.sector_area_agricultural as result
        FROM
            model_draft.ego_demand_per_district b,
            model_draft.ego_demand_loadarea c
        WHERE
            c.nuts = b.eu_code
    ) AS sub
    WHERE sub.id = a.id;


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','demand','ego_demand_federalstate','ego_dp_loadarea_consumption.sql',' ');

-- sector consumption of residential per loadarea
UPDATE model_draft.ego_demand_loadarea a
    SET   sector_consumption_residential = sub.result 
    FROM (
        SELECT
            c.id,
            b.elec_consumption_households_per_person * c.zensus_sum as result
        FROM 
            demand.ego_demand_federalstate b,
            model_draft.ego_demand_loadarea c
        WHERE
            substring(c.nuts,1,3) = substring(b.eu_code, 1,3)
    ) AS sub
    WHERE sub.id = a.id;

/* -- geometry in consumption table -> SELF UPDATE?
UPDATE model_draft.ego_demand_loadarea a
    SET geom = b.geom
    FROM model_draft.ego_demand_loadarea b
    WHERE a.id = b.id;
*/

-- sector sum
UPDATE model_draft.ego_demand_loadarea AS t1
    SET sector_consumption_sum = t2.sector_consumption_sum
    FROM (
        SELECT  id,
            coalesce(load.sector_consumption_residential,0) + 
                coalesce(load.sector_consumption_retail,0) + 
                coalesce(load.sector_consumption_industrial,0) + 
                coalesce(load.sector_consumption_agricultural,0) AS sector_consumption_sum
        FROM    model_draft.ego_demand_loadarea AS load
        ) AS t2
    WHERE   t1.id = t2.id;

-- corresponding otg_id
UPDATE model_draft.ego_demand_loadarea a
    SET     otg_id = b.otg_id
    FROM    model_draft.ego_grid_hvmv_substation b
    WHERE   a.subst_id = b.subst_id; 

-- metadata
COMMENT ON TABLE  model_draft.ego_demand_loadarea IS
'{
"Name": "Electricity consumption per load area",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "",
"Date of collection": "19.10.2016",
"Original file": "ego_dp_loadarea_consumption.sql",
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
                    "Mail": "",
                    "Date":  "25.10.2016",
                    "Comment": "completed json-String" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_demand_loadarea' ::regclass) ::json;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_demand_loadarea','ego_dp_loadarea_consumption.sql',' ');
