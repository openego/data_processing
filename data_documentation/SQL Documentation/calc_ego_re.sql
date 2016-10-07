
-- 

COMMENT ON TABLE  calc_ego_re.dea_germany_per_generation_type_and_voltage_level IS
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
                   {"Name": "generation_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "generation_subtype",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage_level",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "capacity",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "count",
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


SELECT obj_description('calc_ego_re.dea_germany_per_generation_type_and_voltage_level'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.dea_germany_per_grid_district IS
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
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "lv_dea_cnt",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "lv_dea_capacity",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "mv_dea_cnt",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "mv_dea_capacity",
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


SELECT obj_description('calc_ego_re.dea_germany_per_grid_district'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.dea_germany_per_load_area IS
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
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "lv_dea_cnt",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "lv_dea_capacity",
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


SELECT obj_description('calc_ego_re.dea_germany_per_load_area'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.deu_grid_34m_la IS
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
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_type",
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


SELECT obj_description('calc_ego_re.deu_grid_34m_la'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.deu_grid_500m IS
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
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_type",
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


SELECT obj_description('calc_ego_re.deu_grid_500m'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_re.deu_grid_50m_la IS
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
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_type",
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


SELECT obj_description('calc_ego_re.deu_grid_50m_la'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_re.ego_deu_dea IS
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
                   {"Name": "sort",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "electrical_capacity",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "generator_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "generator_subtype",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage_level",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "la_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_line",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_new",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flag",
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


SELECT obj_description('calc_ego_re.ego_deu_dea'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_re.egp_deu_dea_m2_windfarm IS
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
                   {"Name": "farm_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "dea_cnt",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "electrical_capacity_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_new",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_line",
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


SELECT obj_description('calc_ego_re.egp_deu_dea_m2_windfarm'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.ego_deu_dea_out_nn IS
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
                   {"Name": "dea_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "generator_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_sub",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "distance",
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


SELECT obj_description('calc_ego_re.ego_deu_dea_out_nn'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.geo_pot_area IS
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
                   {"Name": "region_key",
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


SELECT obj_description('calc_ego_re.geo_pot_area'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.geo_pot_area_dump IS
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


SELECT obj_description('calc_ego_re.geo_pot_area_dump'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.geo_pot_area_per_grid_district IS
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
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
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


SELECT obj_description('calc_ego_re.geo_pot_area_per_grid_district'::regclass)::json;

--



-- 

COMMENT ON TABLE  calc_ego_re.grid_in_pot_area IS
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
                   {"Name": "grid_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pot_id",
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


SELECT obj_description('calc_ego_re.grid_in_pot_area'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.m3_grid_wpa_temp IS
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
                   {"Name": "sorted",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_type",
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


SELECT obj_description('calc_ego_re.m3_grid_wpa_temp'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.m4_dea_temp IS
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
                   {"Name": "sorted",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "electrical_capacity",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "generation_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "generation_subtype",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage_level",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flag",
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


SELECT obj_description('calc_ego_re.m4_dea_temp'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.m4_grid_wpa_temp IS
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
                   {"Name": "sorted",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_type",
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


SELECT obj_description('calc_ego_re.m4_grid_wpa_temp'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.m4_int_temp IS
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
                   {"Name": "sorted",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_line",
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


SELECT obj_description('calc_ego_re.m4_int_temp'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.m5_dea_temp IS
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
                   {"Name": "sorted",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "electrical_capacity",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "generation_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "generation_subtype",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage_level",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flag",
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


SELECT obj_description('calc_ego_re.m5_dea_temp'::regclass)::json;

--



-- 

COMMENT ON TABLE  calc_ego_re.m5_grid_la_temp IS
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
                   {"Name": "sorted",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_type",
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


SELECT obj_description('calc_ego_re.m5_grid_la_temp'::regclass)::json;

--



-- 

COMMENT ON TABLE  calc_ego_re.m5_int_temp IS
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
                   {"Name": "sorted",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_line",
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


SELECT obj_description('calc_ego_re.m5_int_temp'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.py_deu_grid_34m IS
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
                    "Unit": "" },
                   {"Name": "geom_pnt",
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


SELECT obj_description('calc_ego_re.py_deu_grid_34m'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_re.py_deu_grid_500m IS
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


SELECT obj_description('calc_ego_re.py_deu_grid_500m'::regclass)::json;

--



-- 

COMMENT ON TABLE  calc_ego_re.py_deu_grid_50m IS
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
                    "Unit": "" },
                   {"Name": "geom_pnt",
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


SELECT obj_description('calc_ego_re.py_deu_grid_50m'::regclass)::json;

--



-- 

COMMENT ON TABLE  calc_ego_re.urban_sector_per_grid_district_4_agricultural IS
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
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
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


SELECT obj_description('calc_ego_re.urban_sector_per_grid_district_4_agricultural'::regclass)::json;

--



