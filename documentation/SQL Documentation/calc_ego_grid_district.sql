
-- 

COMMENT ON TABLE  calc_ego_grid_district.grid_district IS
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
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_sum",
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


SELECT obj_description('*calc_ego_grid_district.grid_district'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_grid_district.grid_district_collect IS
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
                   {"Name": "subst_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_sub",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
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


SELECT obj_description('calc_ego_grid_district.grid_district_collect'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_grid_district.grid_district_dump IS
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
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_cnt",
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


SELECT obj_description('calc_ego_grid_district.grid_district_dump'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_grid_district.grid_district_ta IS
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
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_type",
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


SELECT obj_description('calc_ego_grid_district.grid_district_ta'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_grid_district.grid_district_type_1 IS
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
                   {"Name": "subst_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_sub",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_type",
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


SELECT obj_description('calc_ego_grid_district.grid_district_type_1'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_grid_district.grid_district_type_2 IS
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
                   {"Name": "subst_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_sub",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_type",
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


SELECT obj_description('calc_ego_grid_district.grid_district_type_2'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_grid_district.grid_district_type_3 IS
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
                   {"Name": "subst_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_sub",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_type",
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


SELECT obj_description('calc_ego_grid_district.grid_district_type_3'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_grid_district.municipalities_subst IS
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
                   {"Name": "gid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gen",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bez",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bem",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "nuts",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rs_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "count_ring",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "path",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "is_ring",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_type",
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


SELECT obj_description('calc_ego_grid_district.municipalities_subst'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_grid_district.municipalities_subst_3_nn IS
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
                   {"Name": "mun_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "mun_ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_type",
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


SELECT obj_description('calc_ego_grid_district.municipalities_subst_3_nn'::regclass)::json;

--
