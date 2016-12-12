-- 

COMMENT ON TABLE  orig_ego_consumption.destatis_gva_per_districts IS
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
                   {"Name": "eu_code",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "district",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "total_gva",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gva_industry",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gva_tertiary_sector",
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


SELECT obj_description('orig_ego_consumption.destatis_gva_per_districts'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_ego_consumption.lak_consumption_per_district IS
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
                   {"Name": "eu_code",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "district",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "elec_consumption_industry",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "elec_consumption_tertiary_sector",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_industry",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_retail",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_agricultural",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "area_tertiary_sector",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "consumption_per_area_industry",
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


SELECT obj_description('orig_ego_consumption.lak_consumption_per_district'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego_consumption.lak_consumption_per_federalstate IS
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
                   {"Name": "eu_code",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "federal_states",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "elec_consumption_housholds",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "elec_consumption_industry",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "elec_consumption_tertiary_sector",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "population",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "elec_consumption_households_per_person",
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


SELECT obj_description('orig_ego_consumption.lak_consumption_per_federalstate'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_ego_consumption.lak_consumption_per_federalstates_per_gva IS
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
                   {"Name": "eu_code",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "federal_states",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "elec_consumption_industry",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "elec_consumption_tertiary_sector",
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


SELECT obj_description('orig_ego_consumption.lak_consumption_per_federalstates_per_gva'::regclass)::json;

--



