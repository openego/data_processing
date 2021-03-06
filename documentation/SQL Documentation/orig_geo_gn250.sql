-- 

COMMENT ON TABLE  orig_geo_gn250.gn250_b IS
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
                   {"Name": "nnid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "datum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "oba",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "oba_wert",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sprache",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "genus",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sprache2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "genus2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zusatz",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rs",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "hoehe",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "hoehe_ger",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ewz",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ewz_ger",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gewk",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gemteil",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "virtuell",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gemeinde",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "verwgem",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "kreis",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "regbezirk",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bundesland",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "staat",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geola",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geobr",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gkre",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gkho",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "utmre",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "utmho",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "box_geo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "box_gk",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "box_utm",
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


SELECT obj_description('orig_geo_gn250.gn250_b'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_gn250.gn250_p IS
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
                   {"Name": "nnid",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "datum",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "oba",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "oba_wert",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sprache",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "genus",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "name2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sprache2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "genus2",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "zusatz",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ags",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rs",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "hoehe",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "hoehe_ger",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ewz",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "ewz_ger",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gewk",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gemteil",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "virtuell",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gemeinde",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "verwgem",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "kreis",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "regbezirk",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "bundesland",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "staat",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geola",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geobr",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gkre",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "gkho",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "utmre",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "utmho",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "box_geo",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "box_gk",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "box_utm",
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


SELECT obj_description('orig_geo_gn250.gn250_p'::regclass)::json;

--

