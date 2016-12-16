/*
[...]

__copyright__ = "tba"
__license__ = "tba"
__author__ = "ludee"
*/

-- function
CREATE OR REPLACE FUNCTION ego_scenario_log(
	_version text, 
	_io text,
	_schema_name text,
	_table_name text,
	_script_name text,
	-count 
	_comment text)
RETURNS void AS
$BODY$
	BEGIN
		INSERT INTO model_draft.ego_scenario_log(
			version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
		VALUES(_version,
			_io, 
			_schema_name,
			_table_name, 
			_script_name, 
-- 			COUNT(*), 
			_comment,
			session_user,
			NOW() AT TIME ZONE 'Europe/Berlin',
			obj_description('grid.otg_ehvhv_bus_data' ::regclass) ::json);
	END;
$BODY$
LANGUAGE 'plpgsql' STABLE STRICT;

-- grant (oeuser)
ALTER FUNCTION		ego_scenario_log(text,text,text,text,text,text) OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
select * from ego_scenario_log('0.2','input','grid','otg_ehvhv_bus_data','get_substations_ehv.sql','test');