
-- 

COMMENT ON TABLE  calc_ego_loads.calc_ego_peak_load IS
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
                   {"Name": "retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "agricultural",
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


SELECT obj_description('calc_ego_loads.calc_ego_peak_load'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.calc_ego_peak_load_ta IS
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
                   {"Name": "retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "agricultural",
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


SELECT obj_description('calc_ego_loads.calc_ego_peak_load_ta'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.calc_ego_peak_load_test IS
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
                   {"Name": "g0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "h0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "l0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "i0",
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


SELECT obj_description('calc_ego_loads.calc_ego_peak_load_test'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.ego_demand_per_transition_point IS
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


SELECT obj_description('calc_ego_loads.ego_demand_per_transition_point'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.ego_deu_consumption IS
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
                   {"Name": "sector_area_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_agricultural",
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


SELECT obj_description('calc_ego_loads.ego_deu_consumption'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.ego_deu_consumption_area IS
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
                   {"Name": "sector_area_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "consumption_sum",
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


SELECT obj_description('calc_ego_loads.ego_deu_consumption_area'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.ego_deu_consumption_area_ta IS
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
                   {"Name": "sector_area_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "consumption_sum",
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


SELECT obj_description('calc_ego_loads.ego_deu_consumption_area_ta'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_loads.ego_deu_consumption_ta IS
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
                   {"Name": "sector_area_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_agricultural",
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


SELECT obj_description('calc_ego_loads.ego_deu_consumption_ta'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_loads.ego_deu_load_area IS
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
                   {"Name": "zensus_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zensus_count",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zensus_density",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ioer_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ioer_count",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ioer_density",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_count_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_count_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_count_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_count_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
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
                   {"Name": "geom_centroid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_surfacepoint",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_centre",
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


SELECT obj_description('calc_ego_loads.ego_deu_load_area'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.ego_deu_load_area_little_ta IS
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
                   {"Name": "zensus_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zensus_count",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zensus_density",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ioer_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ioer_count",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ioer_density",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_count_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_count_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_count_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_count_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
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
                   {"Name": "geom_centroid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_surfacepoint",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_centre",
                    "Description": "...",
                    "Unit": "" }
                   {"Name": "sector_area_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_sum",
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


SELECT obj_description('calc_ego_loads.ego_deu_load_area_little_ta'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.ego_deu_load_area_ta IS
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
                   {"Name": "zensus_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zensus_count",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zensus_density",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ioer_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ioer_count",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ioer_density",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_area_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_share_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_count_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_count_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_count_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_count_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_residential",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_industrial",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector_consumption_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
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
                   {"Name": "geom_centroid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_surfacepoint",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_centre",
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


SELECT obj_description('calc_ego_loads.ego_deu_load_area_ta'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.ego_deu_loads_collect IS
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


SELECT obj_description('calc_ego_loads.ego_deu_loads_collect'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.ego_deu_loads_melted IS
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


SELECT obj_description('calc_ego_loads.ego_deu_loads_melted'::regclass)::json;

--



-- 

COMMENT ON TABLE  calc_ego_loads.landuse_industry IS
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
                   {"Name": "osm_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sector",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tags",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "vg250",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_centroid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_surfacepoint",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_centre",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "nuts",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "consumption",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "peak_load",
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


SELECT obj_description('calc_ego_loads.landuse_industry'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.large_scale_consumer IS
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
                   {"Name": "polygon_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "powerplant_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage_level",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "consumption",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "peak_load",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_centre",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "otg_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "un_id",
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


SELECT obj_description('calc_ego_loads.large_scale_consumer'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.load_per_griddistrict IS
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
                   {"Name": "consumption",
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


SELECT obj_description('calc_ego_loads.load_per_griddistrict'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.loads_total IS
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
                   {"Name": "un_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ssc_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "lsc_id",
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


SELECT obj_description('calc_ego_loads.loads_total'::regclass)::json;

--



-- 

COMMENT ON TABLE  calc_ego_loads.pf_load_single IS
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


SELECT obj_description('calc_ego_loads.pf_load_single'::regclass)::json;

--

-- 

COMMENT ON TABLE  calc_ego_loads.urban_sector_per_grid_district_1_residential IS
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


SELECT obj_description('calc_ego_loads.urban_sector_per_grid_district_1_residential'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.urban_sector_per_grid_district_2_retail IS
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


SELECT obj_description('calc_ego_loads.urban_sector_per_grid_district_2_retail'::regclass)::json;

--


-- 

COMMENT ON TABLE  calc_ego_loads.urban_sector_per_grid_district_3_industrial IS
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


SELECT obj_description('calc_ego_loads.urban_sector_per_grid_district_3_industrial'::regclass)::json;

--



-- 

COMMENT ON TABLE  calc_ego_loads.urban_sector_per_grid_district_4_agricultural IS
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


SELECT obj_description('calc_ego_loads.urban_sector_per_grid_district_4_agricultural'::regclass)::json;

--



