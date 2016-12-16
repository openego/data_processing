/*
script to assign osmTGmod-id to substation

__copyright__ = "NEXT ENERGY"
__license__ = "GNU GENERAL PUBLIC LICENSE Version 3 (see https://github.com/openego/data_processing/blob/master/LICENSE)"
__author__ = "lukasol, C. Matke"
*/

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'grid' AS schema_name,
	'otg_ehvhv_bus_data' AS table_name,
	'otg_id_to_substations.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('grid.otg_ehvhv_bus_data' ::regclass) ::json AS metadata
FROM	grid.otg_ehvhv_bus_data;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'model_draft' AS schema_name,
	'ego_grid_hvmv_substation' AS table_name,
	'otg_id_to_substations.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_grid_hvmv_substation' ::regclass) ::json AS metadata
FROM	model_draft.ego_grid_hvmv_substation;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'model_draft' AS schema_name,
	'ego_grid_ehv_substation' AS table_name,
	'otg_id_to_substations.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_grid_ehv_substation' ::regclass) ::json AS metadata
FROM	model_draft.ego_grid_ehv_substation;


-- update model_draft.ego_grid_hvmv_substation table with new column of respective osmtgmod bus_i
ALTER TABLE model_draft.ego_grid_hvmv_substation 
ADD COLUMN otg_id bigint;

-- fill table with bus_i from osmtgmod
UPDATE model_draft.ego_grid_hvmv_substation
SET otg_id = grid.otg_ehvhv_bus_data.bus_i
FROM grid.otg_ehvhv_bus_data
WHERE (SELECT TRIM(leading 'n' FROM TRIM(leading 'w' FROM model_draft.ego_grid_hvmv_substation.osm_id))::BIGINT)=grid.otg_ehvhv_bus_data.osm_substation_id; 

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_grid_hvmv_substation' AS table_name,
	'otg_id_to_substations.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_grid_hvmv_substation' ::regclass) ::json AS metadata
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

INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_grid_ehv_substation' AS table_name,
	'otg_id_to_substations.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_grid_ehv_substation' ::regclass) ::json AS metadata
FROM	model_draft.ego_grid_ehv_substation;

