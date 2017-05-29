
-- tables with personal owner
SELECT t.table_schema,t.table_name, t.table_type, c.relname, c.relowner, u.usename
FROM information_schema.tables t
JOIN pg_catalog.pg_class c on (t.table_name = c.relname)
JOIN pg_catalog.pg_user u on (c.relowner = u.usesysid)
WHERE 	t.table_schema <> 'model_draft'
	AND usename <> 'postgres'
ORDER BY u.usename, t.table_schema;

SELECT t.*
FROM information_schema.tables t;

SELECT *
FROM pg_catalog.pg_class;

SELECT *
FROM pg_catalog.pg_user;