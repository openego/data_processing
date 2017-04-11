/*
Update LV grid district table by
 a. sectoral consumption in each LV grid district
 b. sectoral peak load in each LV grid district

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "gplssm"
*/

-- CONSUMPTION

-- residential
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
	SET sector_consumption_residential = COALESCE(t2.real_cons,0)
	FROM  (
		SELECT 	lvgd.mvlv_subst_id,
			la.sector_consumption_residential * lvgd.sector_area_residential / la.sector_area_residential AS real_cons
		FROM 	model_draft.ego_demand_loadarea AS la
			INNER JOIN model_draft.ego_grid_lv_griddistrict AS lvgd ON (la.id = lvgd.la_id)
		) AS t2
	WHERE t1.mvlv_subst_id = t2.mvlv_subst_id;


-- retail
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
	SET sector_consumption_retail = COALESCE(t2.real_cons,0)
	FROM  (
		SELECT 	lvgd.mvlv_subst_id,
			la.sector_consumption_retail * lvgd.sector_area_retail / la.sector_area_retail AS real_cons
		FROM 	model_draft.ego_demand_loadarea AS la
			INNER JOIN model_draft.ego_grid_lv_griddistrict AS lvgd ON (la.id = lvgd.la_id)
		) AS t2
	WHERE t1.mvlv_subst_id = t2.mvlv_subst_id;
	

-- industrial
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
	SET sector_consumption_industrial = COALESCE(t2.real_cons,0)
	FROM  (
		SELECT 	lvgd.mvlv_subst_id,
			la.sector_consumption_industrial * lvgd.sector_area_industrial / la.sector_area_industrial AS real_cons
		FROM 	model_draft.ego_demand_loadarea AS la
			INNER JOIN model_draft.ego_grid_lv_griddistrict AS lvgd ON (la.id = lvgd.la_id)
		) AS t2
	WHERE t1.mvlv_subst_id = t2.mvlv_subst_id;
	
	
-- agricultural
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
	SET sector_consumption_agricultural = COALESCE(t2.real_cons,0)
	FROM  (
		SELECT 	lvgd.mvlv_subst_id,
			la.sector_consumption_agricultural * lvgd.sector_area_agricultural / la.sector_area_agricultural AS real_cons
		FROM 	model_draft.ego_demand_loadarea AS la
			INNER JOIN model_draft.ego_grid_lv_griddistrict AS lvgd ON (la.id = lvgd.la_id)
		) AS t2
	WHERE t1.mvlv_subst_id = t2.mvlv_subst_id;
	
	
-- sum of all sectors
UPDATE 	model_draft.ego_grid_lv_griddistrict
	SET sector_consumption_sum = 
		sector_consumption_residential +
		sector_consumption_retail +
		sector_consumption_industrial +
		sector_consumption_agricultural;


-- PEAK LOAD
-- residential
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
	

-- retail
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
	
	
-- industrial
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
	
	
-- agricultural
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
