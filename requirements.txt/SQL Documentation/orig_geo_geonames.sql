-- 

COMMENT ON TABLE  orig_geo_geonames.postcode_germany IS
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
                   {"Name": "country_code",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "postalcode",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "placename",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "adminname1",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "admincode1",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "adminname2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "admincode2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "adminname3",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "admincode3",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "latitude",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "longitude",
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


SELECT obj_description('orig_geo_geonames.postcode_germany'::regclass)::json;

--

