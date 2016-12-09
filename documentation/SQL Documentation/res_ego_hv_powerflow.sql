
-- 

COMMENT ON TABLE  res_ego_hv_powerflow.res_bus IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },  
                   {"Name": "bus_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "temp_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "control",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "p",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "q",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "v_mag_pu",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "v_ang",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "marginal_price",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "10.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('res_ego_hv_powerflow.res_bus'::regclass)::json;

--


-- 

COMMENT ON TABLE  res_ego_hv_powerflow.res_generator IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },  
                   {"Name": "generator_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "temp_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "control",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "p",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "q",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "p_nom_opt",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "10.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('res_ego_hv_powerflow.res_generator'::regclass)::json;

--


-- 

COMMENT ON TABLE  res_ego_hv_powerflow.res_line IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },  
                   {"Name": "line_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "temp_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "p0",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "q0",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "p1",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "q1",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "s_nom_opt",
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
                    "Date":  "10.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('res_ego_hv_powerflow.res_line'::regclass)::json;

--


-- 

COMMENT ON TABLE  res_ego_hv_powerflow.res_load IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },  
                   {"Name": "load_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "temp_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "q",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "10.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('res_ego_hv_powerflow.res_load'::regclass)::json;

--


-- 

COMMENT ON TABLE  res_ego_hv_powerflow.res_storage IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },  
                   {"Name": "storage_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "temp_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "p",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "q",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "soa",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "spill",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "p_nom_opt",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "10.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('res_ego_hv_powerflow.res_storage'::regclass)::json;

--


-- 

COMMENT ON TABLE  res_ego_hv_powerflow.res_transformer IS
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
                   {"Name": "result_id",
                    "Description": "...",
                    "Unit": "" },  
                   {"Name": "trafo_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "temp_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "control",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "p0",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "q0",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "p1",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "q1",
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
                    "Date":  "10.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('res_ego_hv_powerflow.res_transformer'::regclass)::json;

--


