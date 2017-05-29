/*
copy a version from model_draft to OEP

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- SUBSTATION

-- EHV Substation versioning
/* DELETE FROM grid.ego_dp_ehv_substation
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_dp_ehv_substation
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_ehv_substation;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_dp_ehv_substation','ego_dp_versioning.sql','versioning');


-- HVMV Substation versioning
/* DELETE FROM grid.ego_dp_hvmv_substation
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_dp_hvmv_substation
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_hvmv_substation;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_dp_hvmv_substation','ego_dp_versioning.sql','versioning');


-- MVLV Substation versioning
/* DELETE FROM grid.ego_dp_mvlv_substation
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_dp_mvlv_substation
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_mvlv_substation;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_dp_mvlv_substation','ego_dp_versioning.sql','versioning');


-- CATCHMENT AREA

-- EHV Griddistrict versioning
/* DELETE FROM grid.ego_dp_ehv_griddistrict
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_dp_ehv_griddistrict
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_ehv_substation_voronoi;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_dp_ehv_griddistrict','ego_dp_versioning.sql','versioning');


-- MV Griddistrict versioning
/* DELETE FROM grid.ego_dp_mv_griddistrict
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_dp_mv_griddistrict
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_mv_griddistrict;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_dp_mv_griddistrict','ego_dp_versioning.sql','versioning');


-- LV Griddistrict versioning
/* DELETE FROM grid.ego_dp_lv_griddistrict
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_dp_lv_griddistrict
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_lv_griddistrict;

INSERT INTO grid.ego_dp_lv_griddistrict
	SELECT	'v0.2.9',
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
	
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_dp_lv_griddistrict','ego_dp_versioning.sql','versioning');


-- LOADAREA

-- Loadarea versioning
/* DELETE FROM demand.ego_dp_loadarea
	WHERE	version = 'v0.2.10'; */

INSERT INTO demand.ego_dp_loadarea
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_demand_loadarea;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','demand','ego_dp_loadarea','ego_dp_versioning.sql','versioning');


-- GENERATOR

-- conv versioning
/* DELETE FROM supply.ego_dp_conv_powerplant
	WHERE	version = 'v0.2.10'; */

INSERT INTO supply.ego_dp_conv_powerplant
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_supply_conv_powerplant;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','supply','ego_dp_conv_powerplant','ego_dp_versioning.sql','versioning');

-- res versioning
/* DELETE FROM supply.ego_dp_res_powerplant
	WHERE	version = 'v0.2.10'; */

INSERT INTO supply.ego_dp_res_powerplant
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_supply_res_powerplant;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','supply','ego_dp_res_powerplant','ego_dp_versioning.sql','versioning');


-- hv pf bus
/* DELETE FROM grid.ego_pf_hv_bus
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_pf_hv_bus
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_pf_hv_bus;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_bus','ego_dp_versioning.sql','versioning');

-- hv pf generator
/* DELETE FROM grid.ego_pf_hv_generator
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_pf_hv_generator
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_pf_hv_generator;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_generator','ego_dp_versioning.sql','versioning');


-- hv pf generator_pq_set
/* DELETE FROM grid.ego_pf_hv_generator_pq_set
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_pf_hv_generator_pq_set
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_pf_hv_generator_pq_set;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_generator_pq_set','ego_dp_versioning.sql','versioning');


-- hv pf line
/* DELETE FROM grid.ego_pf_hv_line
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_pf_hv_line
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_pf_hv_line;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_line','ego_dp_versioning.sql','versioning');


-- hv pf load
/* DELETE FROM grid.ego_pf_hv_load
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_pf_hv_load
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_pf_hv_load;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_load','ego_dp_versioning.sql','versioning');


-- hv pf load_pq_set
/* DELETE FROM grid.ego_pf_hv_load_pq_set
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_pf_hv_load_pq_set
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_pf_hv_load_pq_set;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_load_pq_set','ego_dp_versioning.sql','versioning');


-- hv pf source
/* DELETE FROM grid.ego_pf_hv_source
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_pf_hv_source
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_pf_hv_source;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_source','ego_dp_versioning.sql','versioning');


-- hv pf storage
/* DELETE FROM grid.ego_pf_hv_storage
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_pf_hv_storage
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_pf_hv_storage;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_storage','ego_dp_versioning.sql','versioning');


-- hv pf storage_pq_set
/* DELETE FROM grid.ego_pf_hv_storage_pq_set
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_pf_hv_storage_pq_set
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_pf_hv_storage_pq_set;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_storage_pq_set','ego_dp_versioning.sql','versioning');


-- hv pf temp_resolution
/* DELETE FROM grid.ego_pf_hv_temp_resolution
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_pf_hv_temp_resolution
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_pf_hv_temp_resolution;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_temp_resolution','ego_dp_versioning.sql','versioning');


-- hv pf transformer
/* DELETE FROM grid.ego_pf_hv_transformer
	WHERE	version = 'v0.2.10'; */
	
INSERT INTO grid.ego_pf_hv_transformer
	SELECT	'v0.2.10',
		*
	FROM	model_draft.ego_grid_pf_hv_transformer;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','result','grid','ego_pf_hv_transformer','ego_dp_versioning.sql','versioning');




-- overview
/* DELETE FROM model_draft.ego_scenario_overview
	WHERE	version = 'v0.2.10'; */

INSERT INTO model_draft.ego_scenario_overview (name,version,cnt)
	SELECT 	'grid.ego_dp_ehv_substation' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_dp_ehv_substation
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_dp_hvmv_substation' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_dp_hvmv_substation
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_dp_mvlv_substation' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_dp_mvlv_substation
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_dp_ehv_griddistrict' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_dp_ehv_griddistrict
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_dp_mv_griddistrict' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_dp_mv_griddistrict
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_dp_lv_griddistrict' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_dp_lv_griddistrict
	GROUP BY version
UNION ALL
	SELECT 	'demand.ego_dp_loadarea' AS name,
		version,
		count(*) AS cnt
	FROM 	demand.ego_dp_loadarea
	GROUP BY version 
UNION ALL
	SELECT 	'supply.ego_dp_conv_powerplant' AS name,
		version,
		count(*) AS cnt
	FROM 	supply.ego_dp_conv_powerplant
	GROUP BY version 
UNION ALL
	SELECT 	'supply.ego_dp_res_powerplant' AS name,
		version,
		count(*) AS cnt
	FROM 	supply.ego_dp_res_powerplant
	GROUP BY version 
UNION ALL
	SELECT 	'grid.ego_pf_hv_bus' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_pf_hv_bus
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_pf_hv_generator' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_pf_hv_generator
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_pf_hv_generator_pq_set' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_pf_hv_generator_pq_set
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_pf_hv_line' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_pf_hv_line
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_pf_hv_load' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_pf_hv_load
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_pf_hv_load_pq_set' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_pf_hv_load_pq_set
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_pf_hv_source' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_pf_hv_source
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_pf_hv_storage' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_pf_hv_storage
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_pf_hv_storage_pq_set' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_pf_hv_storage_pq_set
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_pf_hv_temp_resolution' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_pf_hv_temp_resolution
	GROUP BY version
UNION ALL
	SELECT 	'grid.ego_pf_hv_transformer' AS name,
		version,
		count(*) AS cnt
	FROM 	grid.ego_pf_hv_transformer
	GROUP BY version
	;
