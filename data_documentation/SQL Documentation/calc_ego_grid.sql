
-- 

COMMENT ON TABLE  calc_ego_grid.ego_deu_mv_grids_vis IS
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
                   {"Name": "grid_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_mv_station",
                    "Description": "...",
                    "Unit": "" },
		   {"Name": "geom_mv_cable_dists",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_mv_circuit_breakers",
                    "Description": "...",
                    "Unit": "" },
		   {"Name": "geom_lv_load_area_centres",
                    "Description": "...",
                    "Unit": "" },
		   {"Name": "geom_lv_station",
                    "Description": "...",
                    "Unit": "" },
	           {"Name": "geom_mv_generators",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom_mv_lines",
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


SELECT obj_description('calc_ego_grid.ego_deu_mv_grids_vis'::regclass)::json;

--
