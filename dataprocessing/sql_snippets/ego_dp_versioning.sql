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
	WHERE	version = 'v0.2.9'; */
	
INSERT INTO grid.ego_dp_ehv_substation
	SELECT	'v0.2.9',
		*
	FROM	model_draft.ego_grid_ehv_substation;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.9','result','grid','ego_dp_ehv_substation','ego_dp_versioning.sql','versioning');


-- HVMV Substation versioning
/* DELETE FROM grid.ego_dp_hvmv_substation
	WHERE	version = 'v0.2.9'; */
	
INSERT INTO grid.ego_dp_hvmv_substation
	SELECT	'v0.2.9',
		*
	FROM	model_draft.ego_grid_hvmv_substation;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.9','result','grid','ego_dp_hvmv_substation','ego_dp_versioning.sql','versioning');


-- MVLV Substation versioning
/* DELETE FROM grid.ego_dp_mvlv_substation
	WHERE	version = 'v0.2.9'; */
	
INSERT INTO grid.ego_dp_mvlv_substation
	SELECT	'v0.2.9',
		*
	FROM	model_draft.ego_grid_mvlv_substation;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.9','result','grid','ego_dp_mvlv_substation','ego_dp_versioning.sql','versioning');


-- CATCHMENT AREA

-- EHV Griddistrict versioning
/* DELETE FROM grid.ego_dp_ehv_griddistrict
	WHERE	version = 'v0.2.9'; */
	
INSERT INTO grid.ego_dp_ehv_griddistrict
	SELECT	'v0.2.9',
		*
	FROM	model_draft.ego_grid_ehv_substation_voronoi;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.9','result','grid','ego_dp_ehv_griddistrict','ego_dp_versioning.sql','versioning');


-- MV Griddistrict versioning
/* DELETE FROM grid.ego_dp_mv_griddistrict
	WHERE	version = 'v0.2.9'; */
	
INSERT INTO grid.ego_dp_mv_griddistrict
	SELECT	'v0.2.9',
		*
	FROM	model_draft.ego_grid_mv_griddistrict;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.9','result','grid','ego_dp_mv_griddistrict','ego_dp_versioning.sql','versioning');


-- LV Griddistrict versioning
/* DELETE FROM grid.ego_dp_lv_griddistrict
	WHERE	version = 'v0.2.9'; */
	
INSERT INTO grid.ego_dp_lv_griddistrict
	SELECT	'v0.2.9',
		*
	FROM	model_draft.ego_grid_lv_griddistrict;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.9','result','grid','ego_dp_lv_griddistrict','ego_dp_versioning.sql','versioning');


-- LOADAREA

-- Loadarea versioning
/* DELETE FROM demand.ego_dp_loadarea
	WHERE	version = 'v0.2.9'; */

INSERT INTO demand.ego_dp_loadarea
	SELECT	'v0.2.9',
		*
	FROM	model_draft.ego_demand_loadarea;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.9','result','demand','ego_dp_loadarea','ego_dp_versioning.sql','versioning');


-- GENERATOR

-- conv versioning
/* DELETE FROM supply.ego_dp_conv_powerplant
	WHERE	version = 'v0.2.9'; */

INSERT INTO supply.ego_dp_conv_powerplant
	SELECT	'v0.2.9',
		*
	FROM	model_draft.ego_supply_conv_powerplant;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.9','result','supply','ego_dp_conv_powerplant','ego_dp_versioning.sql','versioning');

-- res versioning
/* DELETE FROM supply.ego_dp_res_powerplant
	WHERE	version = 'v0.2.9'; */

INSERT INTO supply.ego_dp_res_powerplant
	SELECT	'v0.2.9',
		*
	FROM	model_draft.ego_supply_res_powerplant;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.9','result','supply','ego_dp_res_powerplant','ego_dp_versioning.sql','versioning');




-- overview
/* DELETE FROM model_draft.ego_scenario_overview
	WHERE	version = 'v0.2.9'; */

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
	;
