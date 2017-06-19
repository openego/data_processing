/*
Function to add an entry to the ego_scenario_log table

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

-- function
DROP FUNCTION IF EXISTS ego_scenario_log(text,text,text,text,text,text);
CREATE OR REPLACE FUNCTION ego_scenario_log(text,text,text,text,text,text)
	RETURNS int AS $PROC$
DECLARE
	_version 	ALIAS FOR $1;
	_io 		ALIAS FOR $2;
	_schema_name 	ALIAS FOR $3;
	_table_name 	ALIAS FOR $4;
	_script_name 	ALIAS FOR $5;
	_comment 	ALIAS FOR $6;

	BEGIN
		EXECUTE 'INSERT INTO model_draft.ego_scenario_log ' ||
			'(version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,meta_data)
			SELECT ' || quote_literal(_version) || ',' || 
				quote_literal(_io) || ',' ||
				quote_literal(_schema_name) || ',' ||
				quote_literal(_table_name) || ',' ||
				quote_literal(_script_name) || ',' ||
				'COUNT(*),' ||
				quote_literal(_comment) || ',' || 
				'session_user,' ||
				E'NOW() AT TIME ZONE \'Europe/Berlin\' ,' ||
				E'obj_description(\'' || _schema_name || '.' || _table_name  || E'\' ::regclass) ::json ' || 
			'FROM '	|| _schema_name || '.' || _table_name || ';' ;
		RETURN 1;
	END;
	$PROC$ LANGUAGE plpgsql;

-- grant (oeuser)
ALTER FUNCTION		ego_scenario_log(text,text,text,text,text,text) OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('0','input','model_draft','ego_scenario_log','function_ego_scenario_log.sql','Function test');
