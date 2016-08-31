/*
Meta documentation for schema referencing of the oedb 
A further description can be found on http://wiki.openmod-initiative.org/wiki/DatabaseRules

This script provides a SQL Example and in order to comment your database schema on oedb.

*/

-- Set comment on schema

--COMMENT ON SCHEMA **myschema** IS NULL;

COMMENT ON SCHEMA **myschema** IS
'{
"Name": "Name of Schema",
"Description": ["This schema includes data tables of source 1"],
"Changes":[
                   {"Name": "Joe Nobody",
                    "Mail": "joe.nobody@gmail.com (fake)",
                    "Date":  "16.06.2016",
                    "Comment": "Add table XY" },

                   {"Name": "Joana Anybody",
                    "Mail": "joana.anybody@gmail.com (fake)",
                    "Date": "17.07.2014",
                    "Comment": "Delete table XYZ"}],

"ToDo": ["Add new tables"],
"Label": ["Tables of Geometries"]
}';

-- Select description 
SELECT obj_description(d.oid)::json
from pg_namespace d
WHERE nspname ='**myschema**'
