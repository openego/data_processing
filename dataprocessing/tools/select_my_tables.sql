SELECT nsp.nspname as object_schema,
       cls.relname as object_name, 
       rol.rolname as owner, 
       case cls.relkind
         when 'r' then 'TABLE'
         when 'i' then 'INDEX'
         when 'S' then 'SEQUENCE'
         when 'v' then 'VIEW'
         when 'c' then 'TYPE'
         else cls.relkind::text
       end as object_type
from pg_class cls
  join pg_roles rol on rol.oid = cls.relowner
  join pg_namespace nsp on nsp.oid = cls.relnamespace
where nsp.nspname not in ('information_schema', 'pg_catalog')
  and nsp.nspname not like 'pg_toast%'
  and rol.rolname = current_user  --- remove this if you want to see all objects
order by nsp.nspname, cls.relname;