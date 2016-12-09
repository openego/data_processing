
-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.bus IS
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
                   {"Name": "v_nom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "current_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_type",
                    "Description": "...",
                    "Unit": "..." }],
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


SELECT obj_description('calc_ego_hv_powerflow.bus'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.bus_v_mag_set IS
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
                    "Unit": "..." }],
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


SELECT obj_description('calc_ego_hv_powerflow.bus_v_mag_set'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.generator IS
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
                   {"Name": "dispatch",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "control",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom_extendable",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom_min",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom_max",
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
                   {"Name": "source",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "marginal_cost",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "capital_cost",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "efficiency",
                    "Description": "...",
                    "Unit": "..." }],
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


SELECT obj_description('calc_ego_hv_powerflow.generator'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.generator_pq_set IS
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
                   {"Name": "temp_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_set",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "q_set",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_min_pu",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_max_pu",
                    "Description": "...",
                    "Unit": "..." }],
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


SELECT obj_description('calc_ego_hv_powerflow.generator_pq_set'::regclass)::json;


-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.line IS
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
                   {"Name": "s_nom_extendable",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "s_nom_min",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "s_nom_max",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "capital_cost",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "length",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "cables",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "frequency",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "terrain_factor",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "topo",
                    "Description": "...",
                    "Unit": "..." }],
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


SELECT obj_description('calc_ego_hv_powerflow.line'::regclass)::json;


-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.load IS
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
                   {"Name": "e_annual",
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


SELECT obj_description('calc_ego_hv_powerflow.load'::regclass)::json;



-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.load_pq_set IS
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


SELECT obj_description('calc_ego_hv_powerflow.load_pq_set'::regclass)::json;



-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.scenario_settings IS
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


SELECT obj_description('calc_ego_hv_powerflow.scenario_settings'::regclass)::json;



-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.source IS
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
                   {"Name": "source_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },                   
                   {"Name": "co2_emissions",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "commentary",
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


SELECT obj_description('calc_ego_hv_powerflow.source'::regclass)::json;




-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.storage IS
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
                   {"Name": "storage_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bus",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "dispatch",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "control",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom_extendable",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom_min",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom_max",
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
                   {"Name": "source",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "marginal_cost",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "capital_cost",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "efficiency",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "soc_initial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "soc_cyclic",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "max_hours",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "efficiency_store",
                    "Description": "...",
                    "Unit": "" },                   
                   {"Name": "efficiency_dispatch",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "standing_loss",
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


SELECT obj_description('calc_ego_hv_powerflow.storage'::regclass)::json;




-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.storage_pq_set IS
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
                   {"Name": "storage_id",
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
                   {"Name": "p_min_pu",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_max_pu",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "soc_set",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "inflow",
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


SELECT obj_description('calc_ego_hv_powerflow.storage_pq_set'::regclass)::json;


-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.temp_resolution IS
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


SELECT obj_description('calc_ego_hv_powerflow.temp_resolution'::regclass)::json;



-- 

COMMENT ON TABLE  calc_ego_hv_powerflow.transformer IS
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
                   {"Name": "s_nom_extendable",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "s_nom_min",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "s_nom_max",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tap_ratio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "phase_shift",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "capital_cost",
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


SELECT obj_description('calc_ego_hv_powerflow.transformer'::regclass)::json;








