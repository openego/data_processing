
-- 

COMMENT ON TABLE  calc_ego_mv_powerflow.bus IS
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
                   {"Name": "bus_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "v_nom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "v_mag_pu_min",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "v_mag_pu_max",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "scn_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "grid_id",
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


SELECT obj_description('calc_ego_mv_powerflow.bus'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_mv_powerflow.bus_v_mag_set IS
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
                   {"Name": "scn_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "temp_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "v_mag_pu_set",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "grid_id",
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


SELECT obj_description('calc_ego_mv_powerflow.bus_v_mag_set'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_mv_powerflow.generator IS
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
                   {"Name": "scn_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "generator_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "control",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_min_pu_fixed",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_max_pu_fixed",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sign",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "grid_id",
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


SELECT obj_description('calc_ego_mv_powerflow.generator'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_mv_powerflow.generator_pq_set IS
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
                   {"Name": "scn_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "generator_id",
                    "Description": "...",
                    "Unit": "" }
                   {"Name": "temp_id",
                    "Description": "...",
                    "Unit": "" }
                   {"Name": "p_set",
                    "Description": "...",
                    "Unit": "" }
                   {"Name": "q_set",
                    "Description": "...",
                    "Unit": "" }
                   {"Name": "p_min_pu",
                    "Description": "...",
                    "Unit": "" }
                   {"Name": "p_max_pu",
                    "Description": "...",
                    "Unit": "" }
                   {"Name": "grid_id",
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


SELECT obj_description('calc_ego_mv_powerflow.generator_pq_set'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_mv_powerflow.line IS
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
                   {"Name": "scn_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "line_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus1",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "x",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "r",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "g",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "b",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "s_nom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "lenght",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "cables",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "grid_id",
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


SELECT obj_description('calc_ego_mv_powerflow.line'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_mv_powerflow.load IS
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
                   {"Name": "scn_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "load_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sign",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "grid_id",
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


SELECT obj_description('calc_ego_mv_powerflow.load'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_mv_powerflow.load_pq_set IS
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
                   {"Name": "scn_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "load_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "temp_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_set",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "q_set",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "grid_id",
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


SELECT obj_description('calc_ego_mv_powerflow.load_pq_set'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_mv_powerflow.scenario_settings IS
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
                   {"Name": "scn_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus_v_mag_set",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "generator",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "generator_pq_set",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "line",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "load",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "load_pq_set",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "storage",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "storage_pq_set",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "temp_resolution",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "transformer",
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


SELECT obj_description('calc_ego_mv_powerflow.scenario_settings'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_mv_powerflow.temp_resolution IS
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
                   {"Name": "temp_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timesteps",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "resolution",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "start_time",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "grid_id",
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


SELECT obj_description('calc_ego_mv_powerflow.temp_resolution'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_mv_powerflow.transformer IS
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
                   {"Name": "scn_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "trafo_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus1",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "x",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "r",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "g",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "b",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "s_nom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tap_ratio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "grid_id",
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


SELECT obj_description('calc_ego_mv_powerflow.transformer'::regclass)::json;

--


