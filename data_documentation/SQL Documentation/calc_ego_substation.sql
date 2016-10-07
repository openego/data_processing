
-- 

COMMENT ON TABLE  calc_ego_substation.ego_deu_onts IS
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
                   {"Name": "is_dummy",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "load_area_id",
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


SELECT obj_description('calc_ego_substation.ego_deu_onts'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_substation.ego_deu_onts_little_ta IS
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
                    "Unit": "" },
                   {"Name": "load_area_id",
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


SELECT obj_description('calc_ego_substation.ego_deu_onts_little_ta'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_substation.ego_deu_onts_ta IS
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
                    "Unit": "" },
                   {"Name": "load_area_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "is_dummy",
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


SELECT obj_description('calc_ego_substation.ego_deu_onts_ta'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_substation.ego_deu_substations IS
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
                   {"Name": "lon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "lat",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "point",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "polygon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "power_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "substation",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "osm_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "osm_www",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "frequency",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ref",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "operator",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "dbahn",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "status",
                    "Description": "...",
                    "Unit": "" },                   
                   {"Name": "visible",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "otg_id",
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


SELECT obj_description('calc_ego_substation.ego_deu_substations'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_substation.ego_deu_substations_ehv IS
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
                   {"Name": "lon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "lat",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "point",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "polygon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "power_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "substation",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "osm_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "osm_www",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "frequency",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ref",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "operator",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "dbahn",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "status",
                    "Description": "...",
                    "Unit": "" },                   
                   {"Name": "visible",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "otg_id",
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


SELECT obj_description('calc_ego_substation.ego_deu_substations_ehv'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_substation.ego_deu_substations_voronoi IS
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
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_sum",
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


SELECT obj_description('calc_ego_substation.ego_deu_substations_voronoi'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_substation.ego_deu_substations_voronoi_cut IS
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
                   {"Name": "mun_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voi_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_sub",
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


SELECT obj_description('calc_ego_substation.ego_deu_substations_voronoi_cut'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_substation.ego_deu_substation_voronoi_cut_nn_collect IS
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


SELECT obj_description('calc_ego_substation.ego_deu_substation_voronoi_cut_nn_collect'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_substation.ego_deu_voronoi_ehv IS
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
                   {"Name": "subst_id",
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


SELECT obj_description('calc_ego_substation.ego_deu_voronoi_ehv'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_substation.subs_dea IS
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
                   {"Name": "wea_osm",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "wea_opsd",
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


SELECT obj_description('calc_ego_substation.subs_dea'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_substation.substation_dummy IS
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


SELECT obj_description('calc_ego_substation.substation_dummy'::regclass)::json;

--

