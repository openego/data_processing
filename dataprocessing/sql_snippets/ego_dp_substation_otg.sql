/*
Substation OTG-ID
Script to assign osmTGmod-id (OTG) to substation.

__copyright__   = "DLR Institute for Networked Energy Systems"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "lukasol, C. Matke"
*/


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','grid','otg_ehvhv_bus_data','ego_dp_substation_otg.sql',' ');
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_grid_hvmv_substation','ego_dp_substation_otg.sql',' ');
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_grid_ehv_substation','ego_dp_substation_otg.sql',' ');


-- update model_draft.ego_grid_hvmv_substation table with new column of respective osmtgmod bus_i
ALTER TABLE model_draft.ego_grid_hvmv_substation 
	ADD COLUMN otg_id bigint;

-- fill table with bus_i from osmtgmod
UPDATE model_draft.ego_grid_hvmv_substation
	SET 	otg_id = grid.otg_ehvhv_bus_data.bus_i
	FROM 	grid.otg_ehvhv_bus_data
	WHERE 	grid.otg_ehvhv_bus_data.base_kv <= 110 AND (SELECT TRIM(leading 'n' FROM TRIM(leading 'w' FROM model_draft.ego_grid_hvmv_substation.osm_id))::BIGINT)=grid.otg_ehvhv_bus_data.osm_substation_id; 

DELETE FROM model_draft.ego_grid_hvmv_substation WHERE otg_id IS NULL; 

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_grid_hvmv_substation','ego_dp_substation_otg.sql',' ');


-- do the same with model_draft.ego_grid_ehv_substation

-- update model_draft.ego_grid_ehv_substation table with new column of respective osmtgmod bus_i
ALTER TABLE model_draft.ego_grid_ehv_substation
	ADD COLUMN otg_id bigint;

-- fill table with bus_i from osmtgmod
UPDATE model_draft.ego_grid_ehv_substation
	SET otg_id = grid.otg_ehvhv_bus_data.bus_i
	FROM grid.otg_ehvhv_bus_data
	WHERE grid.otg_ehvhv_bus_data.base_kv > 110 AND(SELECT TRIM(leading 'n' FROM TRIM(leading 'w' FROM TRIM(leading 'r' FROM model_draft.ego_grid_ehv_substation.osm_id)))::BIGINT)=grid.otg_ehvhv_bus_data.osm_substation_id; 

DELETE FROM model_draft.ego_grid_ehv_substation WHERE otg_id IS NULL;

	-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_grid_ehv_substation','ego_dp_substation_otg.sql',' ');
