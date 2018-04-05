/*
Peak loads per Loadarea
Uses SLP parameters per sectors.

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "gplssm, Ludee"
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_demand_loadarea','ego_dp_loadarea_peakload.sql',' ');
SELECT ego_scenario_log('v0.3.0','input','scenario','ego_slp_parameters','ego_dp_loadarea_peakload.sql',' ');

-- residential
UPDATE model_draft.ego_demand_loadarea as t1
    SET sector_peakload_residential = t2.peak_load
    FROM (
        SELECT  la.id,
                coalesce(slp.value * la.sector_consumption_residential,0) AS peak_load
        FROM    model_draft.ego_demand_loadarea AS la,
                scenario.ego_slp_parameters AS slp
        WHERE   slp.parameter = 'consumption_peak_h0'
        ) AS t2
    WHERE t1.id = t2.id;

-- retail
UPDATE model_draft.ego_demand_loadarea as t1
    SET sector_peakload_retail = t2.peak_load
    FROM (
        SELECT  la.id,
                coalesce(slp.value * la.sector_consumption_retail,0) AS peak_load
        FROM    model_draft.ego_demand_loadarea AS la,
                scenario.ego_slp_parameters AS slp
        WHERE   slp.parameter = 'consumption_peak_g0'
        ) AS t2
    WHERE t1.id = t2.id;

-- industrial
UPDATE model_draft.ego_demand_loadarea as t1
    SET sector_peakload_industrial = t2.peak_load
    FROM (
        SELECT  la.id,
                coalesce(slp.value * la.sector_consumption_industrial,0) AS peak_load
        FROM    model_draft.ego_demand_loadarea AS la,
                scenario.ego_slp_parameters AS slp
        WHERE   slp.parameter = 'consumption_peak_i0'
        ) AS t2
    WHERE t1.id = t2.id;

-- agricultural
UPDATE model_draft.ego_demand_loadarea as t1
    SET sector_peakload_agricultural = t2.peak_load
    FROM (
        SELECT  la.id,
                coalesce(slp.value * la.sector_consumption_agricultural,0) AS peak_load
        FROM    model_draft.ego_demand_loadarea AS la,
                scenario.ego_slp_parameters AS slp
        WHERE   slp.parameter = 'consumption_peak_l0'
        ) AS t2
    WHERE t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_demand_loadarea','ego_dp_loadarea_peakload.sql',' ');
