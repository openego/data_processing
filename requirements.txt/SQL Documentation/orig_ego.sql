-- 

COMMENT ON TABLE  orig_ego.ego_deu_loads IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ego.ego_deu_loads'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_loads_collect IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ego.ego_deu_loads_collect'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_loads_consumption_spf IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ego.ego_deu_loads_consumption_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_loads_melted IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ego.ego_deu_loads_melted'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_loads_melted_cut_gem IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ego.ego_deu_loads_melted_cut_gem'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_deu_loads_melted_spf IS
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
                   {"Name": "geom_centre",
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


SELECT obj_description('orig_ego.ego_deu_loads_melted_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_loads_osm IS
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
                   {"Name": "area_ha",
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


SELECT obj_description('orig_ego.ego_deu_loads_osm'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_loads_spf IS
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
                   {"Name": "rs",
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ego.ego_deu_loads_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_loads_zensus IS
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
                   {"Name": "inside_ha",
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


SELECT obj_description('orig_ego.ego_deu_loads_zensus'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_deu_loads_zensus_cluster IS
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


SELECT obj_description('orig_ego.ego_deu_loads_zensus_cluster'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_municipalities_sub IS
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
                   {"Name": "sub_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_type",
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


SELECT obj_description('orig_ego.ego_deu_municipalities_sub'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_municipalities_sub_3_nn IS
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
                   {"Name": "sub_ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_type",
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ego.ego_deu_municipalities_sub_3_nn'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_peak_load_spf IS
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


SELECT obj_description('orig_ego.ego_deu_peak_load_spf'::regclass)::json;

--



-- 

COMMENT ON TABLE  orig_ego.ego_deu_substations_110 IS
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
                   {"Name": "sub_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags_0",
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


SELECT obj_description('orig_ego.ego_deu_substations_110'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_deu_substations_110_voronoi IS
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
                   {"Name": "sub_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_sum",
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


SELECT obj_description('orig_ego.ego_deu_substations_110_voronoi'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_deu_substations_110_voronoi_cut IS
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
                   {"Name": "sub_id",
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
                   {"Name": "sub_type",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_sub",
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


SELECT obj_description('orig_ego.ego_deu_substations_110_voronoi_cut'::regclass)::json;

--



-- 

COMMENT ON TABLE  orig_ego.ego_deu_substations_110_voronoi_cut_nn_collect IS
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
                   {"Name": "sub_id",
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


SELECT obj_description('orig_ego.ego_deu_substations_110_voronoi_cut_nn_collect'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_substations_add IS
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
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags_0",
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


SELECT obj_description('orig_ego.ego_substations_add'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_substations_plus IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ego.ego_deu_substations_plus'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_substations_voronoi IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ego.ego_deu_substations_voronoi'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_deu_substations_voronoi_cut IS
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
                   {"Name": "subst_typ",
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ego.ego_deu_substations_voronoi_cut'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_deu_substations_voronoi_cut_nn IS
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


SELECT obj_description('orig_ego.ego_deu_substations_voronoi_cut_nn'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.ego_deu_substations_voronoi_cut_nn_collect IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ego.ego_deu_substations_voronoi_cut_nn_collect'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_deu_voronoi_ehv IS
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
                    "Unit": "" },
                   {"Name": "id",
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


SELECT obj_description('orig_ego.ego_deu_voronoi_ehv'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_grid_districts IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ego.ego_grid_districts'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_grid_districts_collect IS
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
                   {"Name": "sub_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_sub",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_type",
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


SELECT obj_description('orig_ego.ego_grid_districts_collect'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_grid_districts_dump IS
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
                    "Unit": "" },
                   {"Name": "subst_sum",
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


SELECT obj_description('orig_ego.ego_grid_districts_dump'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_grid_districts_hull IS
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
                   {"Name": "area_ha",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "subst_sum",
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


SELECT obj_description('orig_ego.ego_grid_districts_hull'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_grid_districts_type_1 IS
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
                   {"Name": "sub_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_sub",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_type",
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


SELECT obj_description('orig_ego.ego_grid_districts_type_1'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_grid_districts_type_2 IS
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
                   {"Name": "sub_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_sub",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_type",
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


SELECT obj_description('orig_ego.ego_grid_districts_type_2'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.ego_grid_districts_type_3 IS
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
                   {"Name": "sub_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_sub",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sub_type",
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


SELECT obj_description('orig_ego.ego_grid_districts_type_3'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego.netzinseln_110 IS
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


SELECT obj_description('orig_ego.netzinseln_110'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego.vg250_6_gem_clean IS
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


SELECT obj_description('orig_ego.vg250_6_gem_clean'::regclass)::json;

--





