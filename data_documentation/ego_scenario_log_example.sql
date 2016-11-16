/* 
Copyright 2016 by open_eGo project
Published under GNU GENERAL PUBLIC LICENSE Version 3 (see https://github.com/openego/data_processing/blob/master/LICENSE)
Authors: Ludwig Hülk; Guido Pleßmann

Example of the ego scenario log
*/

-- add entry to scenario logtable
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'table' AS table_name,
	'script.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	SELECT obj_description('model_draft.table' ::regclass) ::json AS metadata
FROM	model_draft.table;
