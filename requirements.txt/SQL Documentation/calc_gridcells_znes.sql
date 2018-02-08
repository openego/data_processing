
-- 

COMMENT ON TABLE  calc_gridcells_znes.substation_dummy IS
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
                   {"Name": "lon",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "lat",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "power_typ",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "osm_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "osm_typ",
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
                   {"Name": "substation",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "operator",
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
                    "Date":  "04.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('calc_gridcells_znes.substation_dummy'::regclass)::json;

--

