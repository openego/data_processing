


select t.table_schema,t.table_name, t.table_type, c.relname, c.relowner, u.usename
from information_schema.tables t
join pg_catalog.pg_class c on (t.table_name = c.relname)
join pg_catalog.pg_user u on (c.relowner = u.usesysid)
--where t.table_schema='model_draft'
and usename <> 'postgres'
ORDER BY t.table_schema,u.usename;

select t.*
from information_schema.tables t

select *
from pg_catalog.pg_class

select *
from pg_catalog.pg_user