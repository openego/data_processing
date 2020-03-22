/*
Scenario Log Function (Multiproject version)

Function to add an entry to the Scenario Log table:
ReeemProject/reeem_db/database_setup/utilities/reeem_setup_scenario_log.sql

Inputs:
    project,version,io,schema_name,table_name,script_name,comment

Outputs:
    id          SERIAL,
    project     text,
    version     text,
    io          text,
    schema_name text,
    table_name  text,
    script_name text,
    entries     integer,
    "comment"   text,
    user_name   text,
    "timestamp" timestamp,
    meta_data   text

__copyright__   = "© Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://www.gnu.org/licenses/agpl-3.0.en.html"
__author__      = "Ludwig Hülk"

 * This file is part of project "open_eGo DataProcessing" (https://github.com/openego/data_processing/).
 * It's copyrighted by the contributors recorded in the version control history:
 * openego/data_processing/preprocessing/scenario_log/function_scenario_log.sql
 * 
 * SPDX-License-Identifier: AGPL-3.0-or-later
*/

DROP FUNCTION IF EXISTS	 scenario_log(text,text,text,text,text,text,text);
CREATE OR REPLACE FUNCTION  scenario_log(text,text,text,text,text,text,text)
	RETURNS text AS 
	$$
	DECLARE
		_project		ALIAS FOR $1;
		_version		ALIAS FOR $2;
		_io			 ALIAS FOR $3;
		_schema_name	ALIAS FOR $4;
		_table_name	 ALIAS FOR $5;
		_script_name	ALIAS FOR $6;
		_comment		ALIAS FOR $7;
	BEGIN
		EXECUTE 'INSERT INTO model_draft.scenario_log ' ||
			'(project,version,io,schema_name,table_name,script_name,entries,comment,user_name,timestamp,meta_data)
			SELECT ' || quote_literal(_project) || ',' || 
				quote_literal(_version) || ',' || 
				quote_literal(_io) || ',' ||
				quote_literal(_schema_name) || ',' ||
				quote_literal(_table_name) || ',' ||
				quote_literal(_script_name) || ',' ||
				'COUNT(*),' ||
				quote_literal(_comment) || ',' || 
				'session_user,' ||
				E'NOW() AT TIME ZONE \'Europe/Berlin\' ,' ||
				E'obj_description(\'' || _schema_name || '.' || _table_name  || E'\' ::regclass) ::json ' || 
			'FROM ' || _schema_name || '.' || _table_name || ';' ;
		RETURN 'inserted';
	END;
	$$ LANGUAGE plpgsql;

-- access rights
ALTER FUNCTION              scenario_log(text,text,text,text,text,text,text) OWNER TO oeuser;
GRANT EXECUTE ON FUNCTION   scenario_log(text,text,text,text,text,text,text) TO oeuser;

