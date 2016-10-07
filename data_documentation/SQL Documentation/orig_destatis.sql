-- 

COMMENT ON TABLE  orig_destatis.bbsr_rag_city_and_mun_types_per_mun IS
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
                   {"Name": "mun_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "munassn_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "munassn_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2013",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_sqm",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "cm_typ",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "cm_typ_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "cm_typ_d",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "cm_typ_d_name",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.bbsr_rag_city_and_mun_types_per_mun'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_destatis.bbsr_rag_municipality_and_municipal_association IS
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
                   {"Name": "mun_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "munassn_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "munassn_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "munassn_location",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_sqm",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2013",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.bbsr_rag_municipality_and_municipal_association'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_destatis.bbsr_rag_spatial_types_per_mun IS
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
                   {"Name": "mun_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "munassn_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "munassn_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sp_typ_pop",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sp_typ_loc",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.bbsr_rag_spatial_types_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_destatis.bbsr_rag_spatial_types_per_mun_key_loc IS
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
                   {"Name": "sp_typ_loc",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sp_typ_loc_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sp_typ_loc_name_ger",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.bbsr_rag_spatial_types_per_mun_key_loc'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_destatis.bbsr_rag_spatial_types_per_mun_key_pop IS
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
                   {"Name": "sp_typ_pop",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sp_typ_pop_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sp_typ_pop_name_ger",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.bbsr_rag_spatial_types_per_mun_key_pop'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_destatis.bbsr_rop2035_pop_forecast_by_agegroups_per_dist IS
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
                   {"Name": "district_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "district_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "age_group",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2012",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2013",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2014",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2015",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2016",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2017",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2018",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2019",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2020",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2021",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2022",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2023",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2024",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2025",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2026",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2027",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2028",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2029",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2030",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2031",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2032",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2033",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2034",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2035",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.bbsr_rop2035_pop_forecast_by_agegroups_per_dist'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_destatis.bbsr_rop2035_pop_forecast_total_per_dist IS
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
                   {"Name": "district_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "district_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "age_group",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2012",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2013",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2014",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2015",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2016",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2017",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2018",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2019",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2020",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2021",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2022",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2023",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2024",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2025",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2026",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2027",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2028",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2029",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2030",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2031",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2032",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2033",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2034",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2035",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.bbsr_rop2035_pop_forecast_total_per_dist'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_destatis.ego_deu_loads_zensus IS
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
                   {"Name": "population",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "inside_la",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_grid",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.ego_deu_loads_zensus'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_destatis.ego_deu_loads_zensus_cluster IS
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
                   {"Name": "cid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zensus_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_buffer",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_centroid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_surfacepoint",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.ego_deu_loads_zensus_cluster'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_destatis.genesis_bldg_with_housing_and_flats_by_bldg_type_per_mun IS
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
                   {"Name": "mun_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bldg_housing_total",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bldg_housing_house",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bldg_housing_reshome",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bldg_housing_other",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flat_housing_total",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flat_housing_house",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flat_housing_reshome",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flat_housing_other",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.genesis_bldg_with_housing_and_flats_by_bldg_type_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_destatis.genesis_bldg_with_housing_by_number_flats_per_mun IS
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
                   {"Name": "mun_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bldg_housing_total",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bldg_housing_flat_1",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bldg_housing_flat_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bldg_housing_flat_3-6",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bldg_housing_flat_7-12",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bldg_housing_flat_13-",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.genesis_bldg_with_housing_by_number_flats_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_destatis.genesis_flats_by_living_space_classes_per_mun IS
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
                   {"Name": "mun_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flats_total",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flats_0-40",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flats_40-59",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flats_60-79",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flats_80-99",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flats_100-119",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flats_120-139",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flats_140-159",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flats_160-179",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flats_180-199",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "flats_200-",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.genesis_flats_by_living_space_classes_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_destatis.genesis_pop_dev_by_gender_per_mun IS
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
                   {"Name": "mun_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2013_total",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2013_male",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2013_female",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2012_total",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2012_male",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2012_female",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2011_total",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2011_male",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2011_female",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2010_total",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2010_male",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2010_female",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2009_total",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2009_male",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2009_female",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2008_total",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2008_male",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_2008_female",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.genesis_pop_dev_by_gender_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_destatis.genesis_residential_bldg_by_number_flats_per_mun IS
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
                   {"Name": "mun_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "r_bldg_total",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "r_bldg_flat_1",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "r_bldg_flat_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "r_bldg_flat_3-6",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "r_bldg_flat_7-12",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "r_bldg_flat_13-",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.genesis_residential_bldg_by_number_flats_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_destatis.zensus_population_by_gender_per_mun IS
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
                   {"Name": "state_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "state_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "mun_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "mun_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "population",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_male",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_female",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "population_old",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_male_old",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_female_old",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_diff",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pop_pct",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.zensus_population_by_gender_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_destatis.zensus_population_per_ha IS
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
                   {"Name": "gid_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "x_mp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "y_mp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "population",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.zensus_population_per_ha'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_destatis.zensus_population_per_ha_grid IS
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
                   {"Name": "gid_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "x_mp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "y_mp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "population",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.zensus_population_per_ha_grid'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_destatis.zensus_population_per_ha_grid_cluster IS
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
                   {"Name": "cid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "population",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_pts",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.zensus_population_per_ha_grid_cluster'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_destatis.zensus_population_per_ha_raster IS
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
                   {"Name": "rid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rast",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.zensus_population_per_ha_raster'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_destatis.zensus_population_per_ha_raster_title100 IS
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
                   {"Name": "rid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rast",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.zensus_population_per_ha_raster_title100'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_destatis.zensus_stats IS
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
                   {"Name": "scale",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "summe_einwohner",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "anzahl_zellen",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_destatis.zensus_stats'::regclass)::json;

--



