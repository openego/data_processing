/*
Function select important parameters of a table and it's metadata

NOT WORKING

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

-- function
DROP FUNCTION IF EXISTS 	query_metadata(text,text);
CREATE OR REPLACE FUNCTION 	query_metadata(text,text)
	RETURNS int AS $PROC$
DECLARE
	_schema_name 	ALIAS FOR $1;
	_table_name 	ALIAS FOR $2;

	BEGIN
		EXECUTE 
			'SELECT	sub.oid, ' ||
				'sub.database, ' ||
				'sub.table_schema, ' ||
				'sub.table_name, ' ||
				'sub.path, ' ||
				E'sub.metadata::json ->>\'title\' AS metadata_title, ' ||
				E'sub.metadata::json #>>\'{temporal,reference_date}\' AS metadata_reference_date, ' ||
				'sub.metadata '  ||
			E'FROM	(SELECT	st.relid AS oid,
					table_catalog AS database,
					i.table_schema AS table_schema,
					i.table_name AS table_name,
					i.table_schema ||\'.\'|| i.table_name AS path,
					pgd.description AS metadata
				FROM	information_schema.tables AS i
					INNER JOIN pg_catalog.pg_statio_all_tables AS st ON (st.schemaname=i.table_schema and st.relname=i.table_name)
					INNER JOIN pg_catalog.pg_description AS pgd ON (pgd.objoid=st.relid)'  ||
					E'WHERE table_schema=\'' || _schema_name || E'\' AND table_name=\'' || _table_name || E'\') AS sub;' ;	
		RETURN 1;
	END;
	$PROC$ LANGUAGE plpgsql;

-- grant (oeuser)
ALTER FUNCTION		query_metadata(text,text) OWNER TO oeuser;

--test
SELECT query_metadata('model_draft','test_table');


-- function
DROP FUNCTION IF EXISTS 	query_metadata(text,text);
CREATE OR REPLACE FUNCTION 	query_metadata(text,text)
	RETURNS text AS $PROC$
	DECLARE
		_schema_name 	ALIAS FOR $1;
		_table_name 	ALIAS FOR $2;
		query  text;
		
	BEGIN
		query := 'SELECT sub.oid, ' ||
				'sub.database, ' ||
				'sub.table_schema, ' ||
				'sub.table_name, ' ||
				'sub.path, ' ||
				E'sub.metadata::json ->>\'title\' AS metadata_title, ' ||
				E'sub.metadata::json #>>\'{temporal,reference_date}\' AS metadata_reference_date, ' ||
				'sub.metadata '  ||
			E'FROM	(SELECT	st.relid AS oid,
					table_catalog AS database,
					i.table_schema AS table_schema,
					i.table_name AS table_name,
					i.table_schema ||\'.\'|| i.table_name AS path,
					pgd.description AS metadata
				FROM	information_schema.tables AS i
					INNER JOIN pg_catalog.pg_statio_all_tables AS st ON (st.schemaname=i.table_schema and st.relname=i.table_name)
					INNER JOIN pg_catalog.pg_description AS pgd ON (pgd.objoid=st.relid)'  ||
					E'WHERE table_schema=\'' || _schema_name || E'\' AND table_name=\'' || _table_name || E'\') AS sub;' ;
		EXECUTE	query INTO meta;
		RETURN meta;
	END;
	$PROC$ LANGUAGE plpgsql;

-- grant (oeuser)
ALTER FUNCTION		query_metadata(text,text) OWNER TO oeuser;

--test
SELECT query_metadata('model_draft','test_table');