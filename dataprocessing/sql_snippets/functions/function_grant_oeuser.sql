/*
[...]

__copyright__ = "tba"
__license__ = "tba"
__author__ = "ludee"
*/

-- function
CREATE OR REPLACE FUNCTION grant_oeuser(_tbl regclass) RETURNS integer AS
	$func$
	BEGIN
	EXECUTE format('ALTER TABLE %s OWNER TO oeuser;', _tbl);
	END;
	$func$
LANGUAGE plpgsql;

-- grant (oeuser)
ALTER FUNCTION	grant_oeuser(regclass) OWNER TO oeuser;

-- grant (oeuser) (schema_name,table_name)
SELECT grant_oeuser('model_draft.ego_scenario_log');
