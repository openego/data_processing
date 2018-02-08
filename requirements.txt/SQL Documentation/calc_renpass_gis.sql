
-- 

COMMENT ON TABLE  calc_renpass_gis.parameter_solar_feedin IS
'{
"Name": "...",
"Source": [{
                  "Name": "...",
                  "URL":  "..." }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["..."],
"Column": [
                   {"Name": "gid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "year",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "feedin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('calc_renpass_gis.parameter_solar_feedin'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_renpass_gis.parameter_wind_feedin IS
'{
"Name": "...",
"Source": [{
                  "Name": "...",
                  "URL":  "..." }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["..."],
"Column": [
                   {"Name": "gid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "year",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "feedin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('calc_renpass_gis.parameter_wind_feedin'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_renpass_gis.renpass_gis_linear_transformer IS
'{
"Name": "...",
"Source": [{
                  "Name": "...",
                  "URL":  "..." }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["..."],
"Column": [
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "scenario_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "label",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "source",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "target",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "conversion_factors",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "summed_min",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "nominal_value",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "actual_value",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "fixed",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "variable_costs",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "fixed_costs",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('calc_renpass_gis.renpass_gis_linear_transformer'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_renpass_gis.renpass_gis_result IS
'{
"Name": "...",
"Source": [{
                  "Name": "...",
                  "URL":  "..." }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["..."],
"Column": [
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "scenario_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus_label",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "obj_label",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "datetime",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "val",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('calc_renpass_gis.renpass_gis_result'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_renpass_gis.renpass_gis_scenario IS
'{
"Name": "...",
"Source": [{
                  "Name": "...",
                  "URL":  "..." }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["..."],
"Column": [
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('calc_renpass_gis.renpass_gis_scenario'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_renpass_gis.renpass_gis_sink IS
'{
"Name": "...",
"Source": [{
                  "Name": "...",
                  "URL":  "..." }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["..."],
"Column": [
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "scenario_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "label",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "source",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "target",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "nominal_value",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "actual_value",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "fixed",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('calc_renpass_gis.renpass_gis_sink'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_renpass_gis.renpass_gis_source IS
'{
"Name": "...",
"Source": [{
                  "Name": "...",
                  "URL":  "..." }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["..."],
"Column": [
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "scenario_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "label",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "source",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "target",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "nominal_value",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "actual_value",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "variable_costs",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "fixed",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('calc_renpass_gis.renpass_gis_source'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_renpass_gis.renpass_gis_storage IS
'{
"Name": "...",
"Source": [{
                  "Name": "...",
                  "URL":  "..." }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["..."],
"Column": [
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "scenario_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "label",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "source",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "target",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "conversion_factors",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "summed_min",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "nominal_value",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "min",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "max",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "actual_value",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "fixed",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "variable_costs",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "fixed_costs",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "nominal_capacity",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "capacity_loss",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "inflow_conversion_factor",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "outflow_conversion_factor",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "initial_capacity",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "capacity_min",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "capacity_max",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('calc_renpass_gis.renpass_gis_storage'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_renpass_gis.voronoi_weatherpoint IS
'{
"Name": "...",
"Source": [{
                  "Name": "...",
                  "URL":  "..." }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["..."],
"Column": [
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('calc_renpass_gis.voronoi_weatherpoint'::regclass)::json;

--

