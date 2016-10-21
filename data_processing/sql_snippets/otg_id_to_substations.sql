-- Copyright 2016 by NEXT ENERGY
-- Published under GNU GENERAL PUBLIC LICENSE Version 3 (see https://github.com/openego/data_processing/blob/master/LICENSE)

-- script to assign osmTGmod-id to substation

-- update model_draft.ego_grid_hvmv_substation table with new column of respective osmtgmod bus_i
ALTER TABLE model_draft.ego_grid_hvmv_substation 
ADD COLUMN otg_id bigint;

-- fill table with bus_i from osmtgmod
UPDATE model_draft.ego_grid_hvmv_substation
SET otg_id = grid.otg_ehvhv_bus_data.bus_i
FROM grid.otg_ehvhv_bus_data
WHERE (SELECT TRIM(leading 'n' FROM TRIM(leading 'w' FROM model_draft.ego_grid_hvmv_substation.osm_id))::BIGINT)=grid.otg_ehvhv_bus_data.osm_substation_id; 

-- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.2' AS version,
	'model_draft' AS schema_name,
	'ego_grid_hvmv_substation' AS table_name,
	'otg_id_to_substations.sql' AS script_name,
	COUNT(subst_id)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_hvmv_substation;

-- do the same with model_draft.ego_grid_ehv_substation

-- update model_draft.ego_grid_ehv_substation table with new column of respective osmtgmod bus_i
ALTER TABLE model_draft.ego_grid_ehv_substation
ADD COLUMN otg_id bigint;

-- fill table with bus_i from osmtgmod
UPDATE model_draft.ego_grid_ehv_substation
SET otg_id = grid.otg_ehvhv_bus_data.bus_i
FROM grid.otg_ehvhv_bus_data
WHERE (SELECT TRIM(leading 'n' FROM TRIM(leading 'w' FROM TRIM(leading 'r' FROM model_draft.ego_grid_ehv_substation.osm_id)))::BIGINT)=grid.otg_ehvhv_bus_data.osm_substation_id; 

-- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.2' AS version,
	'model_draft' AS schema_name,
	'ego_grid_ehv_substation' AS table_name,
	'otg_id_to_substations.sql' AS script_name,
	COUNT(subst_id)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_ehv_substation;
