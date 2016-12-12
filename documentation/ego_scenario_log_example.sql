/*
Example of the ego scenario log

__copyright__ = "Copyright ego developer group"
__license__ = "GPLv3"
*/

-- add entry to scenario log table
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
	obj_description('model_draft.table' ::regclass) ::json AS metadata
FROM	model_draft.table;
