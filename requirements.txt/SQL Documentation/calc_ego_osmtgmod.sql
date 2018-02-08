
-- 

COMMENT ON TABLE  calc_ego_osmtgmod.branch_data IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "view_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "branch_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "f_bus",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "t_bus",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "br_r",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "br_x",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "br_b",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rate_a",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rate_b",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rate_c",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tap",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "shift",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "br_status",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "link_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "branch_voltage",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "cables",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "frequency",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "topo",
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


SELECT obj_description('calc_ego_osmtgmod.branch_data'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_osmtgmod.bus_data IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "view_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus_i",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pd",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "qd",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gs",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bs",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus_area",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "vm",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "va",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "base_kv",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zone",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "vmax",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "vmin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "osm_substation_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "cntr_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "frequency",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "osm_name",
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


SELECT obj_description('calc_ego_osmtgmod.bus_data'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_osmtgmod.dcline_data IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "view_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "dcline_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "f_bus",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "t_bus",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "br_status",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pf",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pt",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "qf",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "qt",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "vf",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "vt",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pmin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pmax",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "qminf",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "qmaxf",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "qmint",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "qmaxt",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "loss0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "loss1",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "link_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "branch_voltage",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "cables",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "frequency",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "topo",
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


SELECT obj_description('calc_ego_osmtgmod.dcline_data'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_osmtgmod.nuts3_subst IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "nuts_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "substation_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "percentage",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "distance",
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


SELECT obj_description('calc_ego_osmtgmod.nuts3_subst'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_osmtgmod.plz_subst IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "plz",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "substation_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "percentage",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "distance",
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


SELECT obj_description('calc_ego_osmtgmod.plz_subst'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_osmtgmod.problem_log IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "view_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "object_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "line_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "relation_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "way",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "cables",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "wires",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "frequency",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "problem",
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


SELECT obj_description('calc_ego_osmtgmod.problem_log'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_osmtgmod.results_metadata IS
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
                   {"Name": "osm_date",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "abstraction_date",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "applied_plans",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "applied_year",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "user_comment",
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


SELECT obj_description('calc_ego_osmtgmod.results_metadata'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_osmtgmod.substations IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "view_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "osm_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "s_long",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "center_geom",
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


SELECT obj_description('calc_ego_osmtgmod.substations'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_osmtgmod.view_results IS
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
                   {"Name": "result_id",
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


SELECT obj_description('calc_ego_osmtgmod.view_results'::regclass)::json;

--


