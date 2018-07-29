/*
LV Consumption and Peakload
Update LV Griddistrict table by
a. sectoral consumption in each LV Griddistrict
b. sectoral peak load in each LV Griddistrict

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "gplssm"
*/


-- Consumption

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.4','input','model_draft','ego_demand_loadarea','ego_dp_lv_consumption_peakload.sql',' ');
SELECT scenario_log('eGo_DP', 'v0.4.4','input','model_draft','ego_grid_lv_griddistrict','ego_dp_lv_consumption_peakload.sql',' ');

-- Residential
UPDATE model_draft.ego_grid_lv_griddistrict AS t1
    SET sector_consumption_residential = COALESCE(t2.real_cons,0)
    FROM  (
        WITH zensus_sum AS (
            SELECT  lvgd.la_id,
                    SUM(lvgd.zensus_sum) AS lvgd_zensus_sum
            FROM    model_draft.ego_grid_lv_griddistrict AS lvgd
            GROUP BY lvgd.la_id)
        SELECT
            lvgd.mvlv_subst_id as mvlv_subst_id,
            la.id AS la_id,
            la.sector_consumption_residential * lvgd.zensus_sum / zensus_sum.lvgd_zensus_sum AS real_cons
        FROM    model_draft.ego_demand_loadarea AS la
                INNER JOIN model_draft.ego_grid_lv_griddistrict AS lvgd ON (la.id = lvgd.la_id)
                INNER JOIN zensus_sum AS zensus_sum ON (zensus_sum.la_id = lvgd.la_id)
        ) AS t2
    WHERE t1.mvlv_subst_id = t2.mvlv_subst_id;


-- Retail
UPDATE model_draft.ego_grid_lv_griddistrict AS t1
    SET sector_consumption_retail = COALESCE(t2.real_cons,0)
    FROM  (
        WITH    lvgd_sector_area_retail_sum AS (
                SELECT  lvgd.la_id,
            SUM(lvgd.sector_area_retail) AS sum
            FROM    model_draft.ego_grid_lv_griddistrict AS lvgd
            GROUP BY lvgd.la_id)
        SELECT
            lvgd.mvlv_subst_id as mvlv_subst_id,
            la.id AS la_id,
            la.sector_consumption_retail * lvgd.sector_area_retail / sum.sum AS real_cons
        FROM    model_draft.ego_demand_loadarea AS la
            INNER JOIN model_draft.ego_grid_lv_griddistrict AS lvgd ON (la.id = lvgd.la_id)
            INNER JOIN lvgd_sector_area_retail_sum AS sum ON (sum.la_id = lvgd.la_id)
        ) AS t2
    WHERE t1.mvlv_subst_id = t2.mvlv_subst_id;


-- Industrial
UPDATE model_draft.ego_grid_lv_griddistrict AS t1
    SET sector_consumption_industrial = COALESCE(t2.real_cons,0)
    FROM  (
        WITH    lvgd_sector_area_industrial_sum AS (
                SELECT  lvgd.la_id,
            SUM(lvgd.sector_area_industrial) AS sum
            FROM    model_draft.ego_grid_lv_griddistrict AS lvgd
            GROUP BY lvgd.la_id)
        SELECT
            lvgd.mvlv_subst_id as mvlv_subst_id,
            la.id AS la_id,
            la.sector_consumption_industrial * lvgd.sector_area_industrial / sum.sum AS real_cons
        FROM    model_draft.ego_demand_loadarea AS la
            INNER JOIN model_draft.ego_grid_lv_griddistrict AS lvgd ON (la.id = lvgd.la_id)
            INNER JOIN lvgd_sector_area_industrial_sum AS sum ON (sum.la_id = lvgd.la_id)
        ) AS t2
    WHERE t1.mvlv_subst_id = t2.mvlv_subst_id;


-- Agricultural
UPDATE model_draft.ego_grid_lv_griddistrict AS t1
    SET sector_consumption_agricultural = COALESCE(t2.real_cons,0)
    FROM  (
        WITH    lvgd_sector_area_agricultural_sum AS (
                SELECT  lvgd.la_id,
            SUM(lvgd.sector_area_agricultural) AS sum
            FROM    model_draft.ego_grid_lv_griddistrict AS lvgd
            GROUP BY lvgd.la_id)
        SELECT
            lvgd.mvlv_subst_id as mvlv_subst_id,
            la.id AS la_id,
            la.sector_consumption_agricultural * lvgd.sector_area_agricultural / sum.sum AS real_cons
        FROM    model_draft.ego_demand_loadarea AS la
            INNER JOIN model_draft.ego_grid_lv_griddistrict AS lvgd ON (la.id = lvgd.la_id)
            INNER JOIN lvgd_sector_area_agricultural_sum AS sum ON (sum.la_id = lvgd.la_id)
        ) AS t2
    WHERE t1.mvlv_subst_id = t2.mvlv_subst_id;


-- Sum of all sectors
UPDATE model_draft.ego_grid_lv_griddistrict
    SET sector_consumption_sum = 
            sector_consumption_residential +
            sector_consumption_retail +
            sector_consumption_industrial +
            sector_consumption_agricultural;


-- Peakload

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.4','input','scenario','ego_slp_parameters','ego_dp_lv_consumption_peakload.sql',' ');

-- Residential
UPDATE model_draft.ego_grid_lv_griddistrict as t1
    SET sector_peakload_residential = t2.peak_load
    FROM (
        SELECT lvgd.mvlv_subst_id,
            slp.value * lvgd.sector_consumption_residential AS peak_load
        FROM 
        model_draft.ego_grid_lv_griddistrict AS lvgd,
        scenario.ego_slp_parameters AS slp
        WHERE slp.parameter = 'consumption_peak_h0') AS t2
    WHERE t1.mvlv_subst_id = t2.mvlv_subst_id;


-- Retail
UPDATE model_draft.ego_grid_lv_griddistrict as t1
    SET sector_peakload_retail = t2.peak_load
    FROM (
        SELECT lvgd.mvlv_subst_id,
            slp.value * lvgd.sector_consumption_retail AS peak_load
        FROM 
        model_draft.ego_grid_lv_griddistrict AS lvgd,
        scenario.ego_slp_parameters AS slp
        WHERE slp.parameter = 'consumption_peak_g0') AS t2
    WHERE t1.mvlv_subst_id = t2.mvlv_subst_id;


-- Industrial
UPDATE model_draft.ego_grid_lv_griddistrict as t1
    SET sector_peakload_industrial = t2.peak_load
    FROM (
        SELECT lvgd.mvlv_subst_id,
            slp.value * lvgd.sector_consumption_industrial AS peak_load
        FROM 
        model_draft.ego_grid_lv_griddistrict AS lvgd,
        scenario.ego_slp_parameters AS slp
        WHERE slp.parameter = 'consumption_peak_i0') AS t2
    WHERE t1.mvlv_subst_id = t2.mvlv_subst_id;


-- Agricultural
UPDATE model_draft.ego_grid_lv_griddistrict as t1
    SET sector_peakload_agricultural = t2.peak_load
    FROM (
        SELECT lvgd.mvlv_subst_id,
            slp.value * lvgd.sector_consumption_agricultural AS peak_load
        FROM 
        model_draft.ego_grid_lv_griddistrict AS lvgd,
        scenario.ego_slp_parameters AS slp
        WHERE slp.parameter = 'consumption_peak_l0') AS t2
    WHERE t1.mvlv_subst_id = t2.mvlv_subst_id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.4','output','model_draft','ego_grid_lv_griddistrict','ego_dp_lv_consumption_peakload.sql',' ');
