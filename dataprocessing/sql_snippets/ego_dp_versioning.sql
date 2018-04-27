/*
eGo Data Processing result data versioning
Copy a version from model_draft to OEP schema

__copyright__   = "© Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/


-- SUBSTATION

-- EHV Substation versioning
/* DELETE FROM grid.ego_dp_ehv_substation
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_dp_ehv_substation
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_ehv_substation;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_dp_ehv_substation','ego_dp_versioning.sql','versioning');


-- HVMV Substation versioning
/* DELETE FROM grid.ego_dp_hvmv_substation
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_dp_hvmv_substation
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_hvmv_substation;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_dp_hvmv_substation','ego_dp_versioning.sql','versioning');


-- MVLV Substation versioning
/* DELETE FROM grid.ego_dp_mvlv_substation
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_dp_mvlv_substation
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_mvlv_substation;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_dp_mvlv_substation','ego_dp_versioning.sql','versioning');


-- CATCHMENT AREA

-- EHV Griddistrict versioning
/* DELETE FROM grid.ego_dp_ehv_griddistrict
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_dp_ehv_griddistrict
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_ehv_substation_voronoi;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_dp_ehv_griddistrict','ego_dp_versioning.sql','versioning');


-- MV Griddistrict versioning
/* DELETE FROM grid.ego_dp_mv_griddistrict
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_dp_mv_griddistrict
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_mv_griddistrict;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_dp_mv_griddistrict','ego_dp_versioning.sql','versioning');


-- LV Griddistrict versioning
/* DELETE FROM grid.ego_dp_lv_griddistrict
	WHERE	version = 'v0.4.0'; */
	
--INSERT INTO grid.ego_dp_lv_griddistrict
--	SELECT	'v0.4.0',
--		*
--	FROM	model_draft.ego_grid_lv_griddistrict;

INSERT INTO grid.ego_dp_lv_griddistrict
	SELECT	'v0.4.0',
		id,
		mvlv_subst_id,
		subst_id,
		la_id,
		nn,
		subst_cnt,
		zensus_sum,
		zensus_count,
		zensus_density,
		population_density,
		area_ha,
		sector_area_residential,
		sector_area_retail,
		sector_area_industrial,
		sector_area_agricultural,
		sector_area_sum,
		sector_share_residential,
		sector_share_retail,
		sector_share_industrial,
		sector_share_agricultural,
		sector_share_sum,
		sector_count_residential,
		sector_count_retail,
		sector_count_industrial,
		sector_count_agricultural,
		sector_count_sum,
		sector_consumption_residential,
		sector_consumption_retail,
		sector_consumption_industrial,
		sector_consumption_agricultural,
		sector_consumption_sum,
		sector_peakload_residential, --verdreht
		sector_peakload_retail,
		sector_peakload_industrial,
		sector_peakload_agricultural,
		geom
	FROM	model_draft.ego_grid_lv_griddistrict;
	
-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_dp_lv_griddistrict','ego_dp_versioning.sql','versioning');


-- LOADAREA

-- Loadarea versioning
/* DELETE FROM demand.ego_dp_loadarea
	WHERE	version = 'v0.4.0'; */

INSERT INTO demand.ego_dp_loadarea
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_demand_loadarea;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','demand','ego_dp_loadarea','ego_dp_versioning.sql','versioning');


-- GENERATOR

-- conv versioning
/* DELETE FROM supply.ego_dp_conv_powerplant
	WHERE	version = 'v0.4.0'; */

INSERT INTO supply.ego_dp_conv_powerplant 
	SELECT	'v0.4.0',
  		id,
  		bnetza_id,
  		company,
  		name,
  		postcode,
  		city,
  		street,
  		state,
  		block,
  		commissioned_original,
  		commissioned,
  		retrofit,
  		shutdown,
  		status,
  		fuel,
  		technology,
  		type,
  		eeg,
  		chp,
  		capacity,
  		capacity_uba,
  		chp_capacity_uba,
  		efficiency_data,
  		efficiency_estimate,
  		network_node,
  		voltage,
  		network_operator,
  		name_uba,
  		lat,
  		lon,
  		comment,
  		geom,
  		voltage_level,
  		subst_id,
  		otg_id,
  		un_id,
		preversion,
  		la_id,
  		scenario,
  		flag,
  		nuts
	FROM	model_draft.ego_dp_supply_conv_powerplant;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','supply','ego_dp_conv_powerplant','ego_dp_versioning.sql','versioning');

-- res versioning
/* DELETE FROM supply.ego_dp_res_powerplant
	WHERE	version = 'v0.4.0'; */

INSERT INTO supply.ego_dp_res_powerplant
	SELECT	'v0.4.0',
  		id,
  		start_up_date,
  		electrical_capacity,
  		generation_type,
  		generation_subtype,
  		thermal_capacity,
  		city,
  		postcode,
  		address,
  		lon,
  		lat,
  		gps_accuracy,
  		validation,
  		notification_reason,
  		eeg_id,
  		tso,
  		tso_eic,
  		dso_id,
  		dso,
  		voltage_level_var,
  		network_node,
  		power_plant_id,
  		source,
  		comment,
  		geom,
  		subst_id,
  		otg_id,
  		un_id,
  		voltage_level,
  		la_id,
  		mvlv_subst_id,
  		rea_sort,
  		rea_flag,
  		rea_geom_line,
  		rea_geom_new,
		preversion, 
		flag, 
		scenario, 
		nuts

	FROM	model_draft.ego_dp_supply_res_powerplant;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','supply','ego_dp_res_powerplant','ego_dp_versioning.sql','versioning');


-- POWERFLOW

-- hv pf bus
/* DELETE FROM grid.ego_pf_hv_bus
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_pf_hv_bus
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_pf_hv_bus;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_pf_hv_bus','ego_dp_versioning.sql','versioning');

-- hv pf generator
/* DELETE FROM grid.ego_pf_hv_generator
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_pf_hv_generator
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_pf_hv_generator;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_pf_hv_generator','ego_dp_versioning.sql','versioning');


-- hv pf generator_pq_set
/* DELETE FROM grid.ego_pf_hv_generator_pq_set
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_pf_hv_generator_pq_set
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_pf_hv_generator_pq_set;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_pf_hv_generator_pq_set','ego_dp_versioning.sql','versioning');


-- hv pf line
/* DELETE FROM grid.ego_pf_hv_line
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_pf_hv_line
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_pf_hv_line;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_pf_hv_line','ego_dp_versioning.sql','versioning');


-- hv pf load
/* DELETE FROM grid.ego_pf_hv_load
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_pf_hv_load
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_pf_hv_load;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_pf_hv_load','ego_dp_versioning.sql','versioning');


-- hv pf load_pq_set
/* DELETE FROM grid.ego_pf_hv_load_pq_set
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_pf_hv_load_pq_set
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_pf_hv_load_pq_set;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_pf_hv_load_pq_set','ego_dp_versioning.sql','versioning');


-- hv pf source
/* DELETE FROM grid.ego_pf_hv_source
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_pf_hv_source
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_pf_hv_source;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_pf_hv_source','ego_dp_versioning.sql','versioning');


-- hv pf storage
/* DELETE FROM grid.ego_pf_hv_storage
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_pf_hv_storage
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_pf_hv_storage;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_pf_hv_storage','ego_dp_versioning.sql','versioning');


-- hv pf storage_pq_set
/* DELETE FROM grid.ego_pf_hv_storage_pq_set
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_pf_hv_storage_pq_set
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_pf_hv_storage_pq_set;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_pf_hv_storage_pq_set','ego_dp_versioning.sql','versioning');


-- hv pf temp_resolution
/* DELETE FROM grid.ego_pf_hv_temp_resolution
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_pf_hv_temp_resolution
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_pf_hv_temp_resolution;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_pf_hv_temp_resolution','ego_dp_versioning.sql','versioning');


-- hv pf transformer
/* DELETE FROM grid.ego_pf_hv_transformer
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_pf_hv_transformer
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_pf_hv_transformer;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_pf_hv_transformer','ego_dp_versioning.sql','versioning');

-- hv pf line expansion cost

/* DELETE FROM grid.ego_line_expansion_costs
	WHERE	version = 'v0.4.0'; */
	
INSERT INTO grid.ego_line_expansion_costs
	SELECT	'v0.4.0',
		*
	FROM	model_draft.ego_grid_line_expansion_costs;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','grid','ego_line_expansion_costs','ego_dp_versioning.sql','versioning');


-- renewable time series
INSERT INTO  supply.ego_renewable_feedin
        SELECT	'v0.4.0',
		*
	FROM model_draft.ego_renewable_feedin

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','supply','ego_renewable_feedin','ego_dp_versioning.sql','versioning');

-- renewable wind parameters
INSERT INTO  supply.ego_power_class
        SELECT	'v0.4.0',
		*
	FROM model_draft.ego_power_class
	
-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.4.0','result','supply','ego_power_class','ego_dp_versioning.sql','versioning');
