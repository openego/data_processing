/*
Meta documentation for Data Referencing of the oedb 
A further description can be found on http://wiki.openmod-initiative.org/wiki/DatabaseRules

This script provides a SQL Example and in order to comment your database table on oedb.

*/

-- Set comment on table

COMMENT ON TABLE **myschema**.**mytable** IS
'{
"Name": "Original name of the data set",
"Source": [{
                  "Name": "Website of data",
                  "URL":  "www.website.com" }],
"Reference date": "2013",
"Date of collection": "01.08.2013",
"Original file": "346-22-5.xls",
"Spatial resolution": ["Germany"],
"Description": ["Example Data (annual totals)", "Regional level: national"],

"Column": [
                   {"Name": "id",
                    "Description": "Unique identifier",
                    "Unit": "" },

                   {"Name": "year",
                    "Description": "Reference Year",
                    "Unit": "" },

                   {"Name": "example_value",
                    "Description": "Some important value",
                    "Unit": "EUR" }],

"Changes":[
                   {"Name": "Joe Nobody",
                    "Mail": "joe.nobody@gmail.com (fake)",
                    "Date":  "16.06.2014",
                    "Comment": "Created table" },

                   {"Name": "Joana Anybody",
                    "Mail": "joana.anybody@gmail.com (fake)",
                    "Date": "17.07.2014",
                    "Comment": "Translated field names"}],

"ToDo": ["Some datasets are odd -&gt; Check numbers against another data"],
"Licence": ["Licence – Version 2.0 (dl-de/by-2-0; [http://www.govdata.de/dl-de/by-2-0])"],
"Instructions for proper use": ["Always state licence"],
"Label": ["Germany", "Example Data"]
}';

-- Select description 
SELECT obj_description('**myschema**.**mytable**'::regclass)::json
