
-- 

COMMENT ON TABLE  orig_ioer.ioer_urban_share_industrial_centroid IS
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
                   {"Name": "rid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ioer_share",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "10.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('orig_ioer.ioer_urban_share_industrial_centroid'::regclass)::json;

--

