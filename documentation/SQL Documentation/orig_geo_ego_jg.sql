-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_loads IS
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
                   {"Name": "mv_poly_id",
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_loads'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_loads_collect IS
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_loads_collect'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_loads_collect_buffer100 IS
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_loads_collect_buffer100'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_loads_collect_buffer100_unbuffer IS
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
                   {"Name": "geom_centroid",
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_loads_collect_buffer100_unbuffer'::regclass)::json;

--
-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_loads_collect_buffer100_unbuffer_cut IS
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
                   {"Name": "geom_buffer",
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_loads_collect_buffer100_unbuffer_cut'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_loads_collect_buffer100_unbuffer_cut_gem IS
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_loads_collect_buffer100_unbuffer_cut_gem'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_loads_collect_buffer100_unbuffer_cut_spf IS
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_loads_collect_buffer100_unbuffer_cut_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_loads_collect_buffer100_unbuffer_spf IS
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
                   {"Name": "geom_centroid",
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_loads_collect_buffer100_unbuffer_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_loads_consumption_spf IS
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_loads_consumption_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_loads_spf IS
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
                   {"Name": "mv_poly_id",
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_loads_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_loads_zensus IS
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_loads_zensus'::regclass)::json;

--
-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_mv_gridcell_full IS
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_mv_gridcell_full'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_osm_loadarea IS
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
                   {"Name": "mv_poly_id",
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
                   {"Name": "geom_buffer",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "la_id",
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_osm_loadarea'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_osm_loadarea_spf IS
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
                   {"Name": "mv_poly_id",
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
                   {"Name": "geom_buffer",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "la_id",
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_osm_loadarea_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_zensus_loadpoints_cluster IS
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_zensus_loadpoints_cluster'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_deu_zensus_loadpoints_cluster_spf IS
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


SELECT obj_description('orig_geo_ego_jg.ego_deu_zensus_loadpoints_cluster_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.ego_ms_netzbezirke IS
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
                   {"Name": "geom_gem",
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


SELECT obj_description('orig_geo_ego_jg.ego_ms_netzbezirke'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_MS_Bies IS
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
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descriptio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestamp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitudemo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessellate",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibility",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworder",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descript_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestam_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessella_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibili_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworde_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon_2",
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


SELECT obj_description('orig_geo_ego_jg.jg_MS_Bies'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_MS_Breit IS
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
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descriptio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestamp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitudemo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessellate",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibility",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworder",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descript_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestam_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessella_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibili_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworde_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon_2",
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


SELECT obj_description('orig_geo_ego_jg.jg_MS_Breit'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_MS_Buch IS
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
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descriptio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestamp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitudemo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessellate",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibility",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworder",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descript_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestam_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessella_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibili_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworde_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon_2",
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


SELECT obj_description('orig_geo_ego_jg.jg_MS_Buch'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_MS_Horg IS
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
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descriptio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestamp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitudemo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessellate",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibility",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworder",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descript_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestam_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessella_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibili_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworde_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon_2",
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


SELECT obj_description('orig_geo_ego_jg.jg_MS_Horg'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_MS_Lage IS
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
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descriptio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestamp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitudemo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessellate",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibility",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworder",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descript_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestam_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessella_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibili_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworde_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon_2",
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


SELECT obj_description('orig_geo_ego_jg.jg_MS_Lage'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_MS_Leng IS
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
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descriptio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestamp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitudemo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessellate",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibility",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworder",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descript_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestam_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessella_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibili_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworde_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon_2",
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


SELECT obj_description('orig_geo_ego_jg.jg_MS_Leng'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_MS_Memm IS
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
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descriptio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestamp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitudemo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessellate",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibility",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworder",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descript_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestam_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessella_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibili_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworde_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon_2",
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


SELECT obj_description('orig_geo_ego_jg.jg_MS_Memm'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_MS_Obau IS
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
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descriptio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestamp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitudemo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessellate",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibility",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworder",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descript_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestam_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessella_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibili_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworde_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon_2",
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


SELECT obj_description('orig_geo_ego_jg.jg_MS_Obau'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_MS_Otto IS
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
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descriptio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestamp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitudemo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessellate",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibility",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworder",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descript_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestam_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessella_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibili_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworde_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon_2",
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


SELECT obj_description('orig_geo_ego_jg.jg_MS_Otto'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_MS_Untei IS
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
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descriptio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestamp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitudemo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessellate",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibility",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworder",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descript_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestam_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessella_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibili_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworde_2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon_2",
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


SELECT obj_description('orig_geo_ego_jg.jg_MS_Untei'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_MS_spf IS
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
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pid",
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


SELECT obj_description('orig_geo_ego_jg.jg_MS_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_MS_spf_bb IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_geo_ego_jg.jg_MS_spf_bb'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_NS_Tus IS
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
                   {"Name": "Name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "descriptio",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "timestamp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "begin",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "end",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "altitudemo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "tessellate",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "extrude",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "visibility",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "draworder",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "icon",
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


SELECT obj_description('orig_geo_ego_jg.jg_NS_Tus'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_NS_Tus_Hausanschluesse IS
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
                   {"Name": "Name",
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


SELECT obj_description('orig_geo_ego_jg.jg_NS_Tus_Hausanschluesse'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_NS_Tus_angles IS
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
                   {"Name": "p2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p1",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p3",
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


SELECT obj_description('orig_geo_ego_jg.jg_NS_Tus_angles'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_NS_Tus_angles_gis IS
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


SELECT obj_description('orig_geo_ego_jg.jg_NS_Tus_angles_gis'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_NS_Tus_cont_3.75 IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_geo_ego_jg.jg_NS_Tus_cont_3.75'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_NS_Tus_cont_9.75 IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_geo_ego_jg.jg_NS_Tus_cont_9.75'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_NS_Tus_final IS
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
                   {"Name": "Name",
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


SELECT obj_description('orig_geo_ego_jg.jg_NS_Tus_final'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_ONTs_spf IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_geo_ego_jg.jg_ONTs_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_bboxes_spf IS
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
                   {"Name": "zensus_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zensus_count",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zensus_density",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "onts",
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


SELECT obj_description('orig_geo_ego_jg.jg_bboxes_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_osm_tus_streets IS
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
                   {"Name": "osm_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "highway",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "aerialway",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "barrier",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "man_made",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "z_order",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "other_tags",
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


SELECT obj_description('orig_geo_ego_jg.jg_osm_tus_streets'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_osm_tus_streets_final IS
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
                   {"Name": "osm_id",
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


SELECT obj_description('orig_geo_ego_jg.jg_osm_tus_streets_final'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_pop_spf IS
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


SELECT obj_description('orig_geo_ego_jg.jg_pop_spf'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_populated_areas_ls IS
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
                   {"Name": "box_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zensus_sum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "onts",
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


SELECT obj_description('orig_geo_ego_jg.jg_populated_areas_ls'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_geo_ego_jg.jg_streets_buffered_9.75 IS
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
                   {"Name": "osm_id",
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


SELECT obj_description('orig_geo_ego_jg.jg_streets_buffered_9.75'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_geo_ego_jg.osm_deu_polygon_urban IS
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
                   {"Name": "landuse",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "man_made",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "aeroway",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "way_area",
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


SELECT obj_description('orig_geo_ego_jg.osm_deu_polygon_urban'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_geo_ego_jg.osm_deu_polygon_urban_buffer100_unbuffer IS
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
                   {"Name": "uid",
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
                   {"Name": "mv_poly_id",
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
                   {"Name": "geom_buffer",
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


SELECT obj_description('orig_geo_ego_jg.osm_deu_polygon_urban_buffer100_unbuffer'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_geo_ego_jg.test_2_voronoi IS
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


SELECT obj_description('orig_geo_ego_jg.test_2_voronoi'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_geo_ego_jg.test_2_voronoi_pts IS
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


SELECT obj_description('orig_geo_ego_jg.test_2_voronoi_pts'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.test_voronoi IS
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
                   {"Name": "name",
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


SELECT obj_description('orig_geo_ego_jg.test_voronoi'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.test_voronoi_geom IS
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
                    "Date":  "05.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_geo_ego_jg.test_voronoi_geom'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.test_voronoi_pts IS
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


SELECT obj_description('orig_geo_ego_jg.test_voronoi_pts'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_geo_ego_jg.test_voronoi_pts_geom IS
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


SELECT obj_description('orig_geo_ego_jg.test_voronoi_pts_geom'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_ego_jg.usw_voronoi IS
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


SELECT obj_description('orig_geo_ego_jg.usw_voronoi'::regclass)::json;

--

