/* 
All tables from social have to be moved to social.
Metadata needs to be updatetd with newer version, new schema and error checking.
*/

-- 
COMMENT ON TABLE  social.bbsr_rag_city_and_mun_types_per_mun IS '{
	"Name": "BBSR - Raumabgrenzungen - Stadt- und Gemeindetyp - 2013",
	"Source": [{
		"Name": "Bundesinstitut für Bau-, Stadt- und Raumforschung (BBSR) - Downloads - Raumabgrenzungen: Referenzdateien und Karten",
		"URL":  "http://www.bbsr.bund.de/BBSR/DE/Raumbeobachtung/Downloads/downloads_node.html" }],
	"Reference date": "2013",
	"Date of collection": "08.12.2015",
	"Original file": "XXX",
	"Spatial resolution": ["Germany, Municipality"],
	"Description": ["City and Municipality types"],
	"Column": [
		{"Name": "mun_id", "Description": "Municipality key 2013", "Description German":"Kreisschlüssel 2013", "Unit": "" },
		{"Name": "mun_name", "Description": "Municipality name 2013", "Description German":"Kreisname 2013", "Unit": "" },
		{"Name": "munassn_id", "Description": "Municipal association key 2013", "Description German":"Kreisschlüssel 2013", "Unit": "" },
		{"Name": "munassn_name", "Description": "Municipal association name 2013", "Description German":"Kreisname 2013", "Unit": "" },
		{"Name": "pop_2013", "Description": "Population 2013", "Description German":"Bevölkerung 2013", "Unit": "" },
		{"Name": "area_sqm", "Description": "Area in square meter", "Description German":"Fläche in Quadratmeter", "Unit": "" },
		{"Name": "cm_typ", "Description": "City and municipality key 2013", "Description German":"Stadt- und Gemeindetyp 2013", "Unit": "" },
		{"Name": "cm_typ_name", "Description": "City and municipality name 2013", "Description German":"Stadt- und Gemeindetyp Name 2013", "Unit": "" },
		{"Name": "cm_typ_d", "Description": "City and municipality key differentiated 2013", "Description German":"Stadt- und Gemeindetyp differenziert 2013", "Unit": "" },
		{"Name": "cm_typ_d_name", "Description": "City and municipality name differentiated 2013", "Description German":"Stadt- und Gemeindetyp Name differenziert 2013", "Unit": "" }],
	"Changes":[
		{"Name":"Ludwig Schneider", "Mail":"ludwig.schenider@rl-institut.de", 
		"Date":"08.12.2015", "Comment":"Created table"},
		{"Name":"Ludwig Hülk", "Mail":"ludwig.huelk@rl-institut.de",
		"Date":"26.10.2016","Comment":"Moved table and update metadata"} ],
	"ToDo": [""],
	"Licence": ["Datenlizenz Deutschland – Namensnennung – Version 2.0 (dl-de/by-2-0; http://www.govdata.de/dl-de/by-2-0)"],
	"Instructions for proper use": ["Die Nutzer haben sicherzustellen, dass 1. alle den Daten, Metadaten, Karten und Webdiensten beigegebenen Quellenvermerke und sonstigen rechtlichen Hinweise erkennbar und in optischem Zusammenhang eingebunden werden. Die Nutzung bzw. der Abdruck ist nur mit vollständiger Angabe des Quellenvermerks (© BBSR Bonn 2015) gestattet. Bei der Darstellung auf einer Webseite ist (© Bundesinstitut für Bau-, Stadt- und Raumforschung) mit der URL (http://www.bbsr.bund.de) zu verlinken. 2. bei Veränderungen (insbesondere durch Hinzufügen neuer Inhalte), Bearbeitungen, neuen Gestaltungen oder sonstigen Abwandlungen mit einem Veränderungshinweis im beigegebenen Quellenvermerk Art und Urheberschaft der Veränderungen deutlich kenntlich gemacht wird. Bei Karten ist in diesem Fall das Logo des BBSR zu entfernen."]
	}';

SELECT obj_description('social.bbsr_rag_city_and_mun_types_per_mun' ::regclass) ::json;

--


-- 

COMMENT ON TABLE  social.bbsr_rag_municipality_and_municipal_association IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "mun_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "mun_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "munassn_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "munassn_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "munassn_location",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "area_sqm",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2013",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.bbsr_rag_municipality_and_municipal_association'::regclass)::json;

--


-- 

COMMENT ON TABLE  social.bbsr_rag_spatial_types_per_mun IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "mun_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "mun_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "munassn_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "munassn_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "sp_typ_pop",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "sp_typ_loc",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.bbsr_rag_spatial_types_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  social.bbsr_rag_spatial_types_per_mun_key_loc IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "sp_typ_loc",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "sp_typ_loc_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "sp_typ_loc_name_ger",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.bbsr_rag_spatial_types_per_mun_key_loc'::regclass)::json;

--


-- 

COMMENT ON TABLE  social.bbsr_rag_spatial_types_per_mun_key_pop IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "sp_typ_pop",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "sp_typ_pop_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "sp_typ_pop_name_ger",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.bbsr_rag_spatial_types_per_mun_key_pop'::regclass)::json;

--


-- 

COMMENT ON TABLE  social.bbsr_rop2035_pop_forecast_by_agegroups_per_dist IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "district_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "district_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "age_group",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2012",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2013",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2014",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2015",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2016",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2017",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2018",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2019",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2020",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2021",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2022",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2023",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2024",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2025",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2026",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2027",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2028",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2029",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2030",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2031",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2032",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2033",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2034",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2035",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.bbsr_rop2035_pop_forecast_by_agegroups_per_dist'::regclass)::json;

--


-- 

COMMENT ON TABLE  social.bbsr_rop2035_pop_forecast_total_per_dist IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "district_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "district_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "age_group",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2012",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2013",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2014",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2015",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2016",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2017",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2018",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2019",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2020",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2021",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2022",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2023",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2024",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2025",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2026",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2027",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2028",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2029",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2030",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2031",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2032",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2033",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2034",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2035",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.bbsr_rop2035_pop_forecast_total_per_dist'::regclass)::json;

--

-- 

COMMENT ON TABLE  social.ego_deu_loads_zensus IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "gid",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "population",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "inside_la",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "geom_grid",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.ego_deu_loads_zensus'::regclass)::json;

--


-- 

COMMENT ON TABLE  social.ego_deu_loads_zensus_cluster IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "cid",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "zensus_sum",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "geom_buffer",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "geom_centroid",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "geom_surfacepoint",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.ego_deu_loads_zensus_cluster'::regclass)::json;

--

-- 

COMMENT ON TABLE  social.genesis_bldg_with_housing_and_flats_by_bldg_type_per_mun IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "mun_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "mun_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "bldg_housing_total",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "bldg_housing_house",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "bldg_housing_reshome",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "bldg_housing_other",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flat_housing_total",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flat_housing_house",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flat_housing_reshome",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flat_housing_other",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.genesis_bldg_with_housing_and_flats_by_bldg_type_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  social.genesis_bldg_with_housing_by_number_flats_per_mun IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "mun_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "mun_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "bldg_housing_total",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "bldg_housing_flat_1",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "bldg_housing_flat_2",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "bldg_housing_flat_3-6",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "bldg_housing_flat_7-12",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "bldg_housing_flat_13-",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.genesis_bldg_with_housing_by_number_flats_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  social.genesis_flats_by_living_space_classes_per_mun IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "mun_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "mun_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flats_total",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flats_0-40",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flats_40-59",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flats_60-79",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flats_80-99",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flats_100-119",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flats_120-139",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flats_140-159",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flats_160-179",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flats_180-199",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "flats_200-",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.genesis_flats_by_living_space_classes_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  social.genesis_pop_dev_by_gender_per_mun IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "mun_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "mun_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2013_total",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2013_male",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2013_female",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2012_total",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2012_male",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2012_female",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2011_total",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2011_male",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2011_female",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2010_total",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2010_male",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2010_female",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2009_total",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2009_male",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2009_female",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2008_total",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2008_male",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_2008_female",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.genesis_pop_dev_by_gender_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  social.genesis_residential_bldg_by_number_flats_per_mun IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "mun_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "mun_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "r_bldg_total",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "r_bldg_flat_1",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "r_bldg_flat_2",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "r_bldg_flat_3-6",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "r_bldg_flat_7-12",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "r_bldg_flat_13-",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.genesis_residential_bldg_by_number_flats_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  social.zensus_population_by_gender_per_mun IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "state_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "state_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "mun_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "mun_name",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "population",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_male",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_female",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "population_old",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_male_old",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_female_old",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_diff",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "pop_pct",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.zensus_population_by_gender_per_mun'::regclass)::json;

--

-- 

COMMENT ON TABLE  social.destatis_zensus_population_per_ha IS '{
	"Name": "German Census 2011 - Population in 100m grid",
	"Source": [{
		"Name": "Statistisches Bundesamt (Destatis)",
		"URL":  "https://www.destatis.de/DE/Methoden/Zensus_/Zensus.html" }],
	"Reference date": "2011",
	"Date of collection": "03.02.2016",
	"Original file": "https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Bevoelkerung_100m_Gitter.zip",
	"Spatial resolution": ["Germany"],
	"Description": ["National census in Germany in 2011"],
	"Column": [
		{"Name": "gid",	"Description": "Unique identifier", "Unit": "" },
		{"Name": "grid_id", "Description": "Grid number of source", "Unit": "" },
		{"Name": "x_mp", "Description": "Latitude of centroid in (ETRS89 - LAEA; EPSG:3035)", "Unit": "" },
		{"Name": "y_mp", "Description": "Longitude of centroid in (ETRS89 - LAEA; EPSG:3035)", "Unit": "" },
		{"Name": "population", "Description": "Number of registred residents", "Unit": "human" },
		{"Name": "geom_point", "Description": "Geometry centroid", "Unit": "" },
		{"Name": "geom", "Description": "Geometry", "Unit": "" } ],
	"Changes":[
		{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
		"Date":  "03.02.2016","Comment": "Added Table"},
		{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
		"Date":  "25.10.2016","Comment": "Moved table and add metadata"} ],
	"ToDo": [""],
	"Licence": ["Datenlizenz Deutschland – Namensnennung – Version 2.0"],
	"Instructions for proper use": ["Empfohlene Zitierweise des Quellennachweises: Datenquelle: Statistisches Bundesamt, Wiesbaden, Genesis-Online, <optional> Abrufdatum; Datenlizenz by-2-0. Quellenvermerk bei eigener Berechnung / Darstellung: Datenquelle: Statistisches Bundesamt, Wiesbaden, Genesis-Online, <optional> Abrufdatum; Datenlizenz by-2-0; eigene Berechnung/eigene Darstellung. In elektronischen Werken ist im Quellenverweis dem Begriff (Datenlizenz by-2-0) der Link www.govdata.de/dl-de/by-2-0 als Verknüpfung zu hinterlegen."]
	}';

SELECT obj_description('social.destatis_zensus_population_per_ha' ::regclass) ::json;

--


-- 

COMMENT ON TABLE  social.zensus_population_per_ha_grid IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "gid",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "gid_id",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "x_mp",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "y_mp",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "population",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.zensus_population_per_ha_grid'::regclass)::json;

--


-- 

COMMENT ON TABLE  social.zensus_population_per_ha_grid_cluster IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "cid",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "population",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "area_ha",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "geom_pts",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.zensus_population_per_ha_grid_cluster'::regclass)::json;

--


-- 

COMMENT ON TABLE  social.zensus_population_per_ha_raster IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "rid",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "rast",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.zensus_population_per_ha_raster'::regclass)::json;

--

-- 

COMMENT ON TABLE  social.zensus_population_per_ha_raster_title100 IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "rid",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "rast",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.zensus_population_per_ha_raster_title100'::regclass)::json;

--


-- 

COMMENT ON TABLE  social.zensus_stats IS
'{
"Name": "XXX",
"Source": [{
                  "Name": "XXX",
                  "URL":  "XXX" }],
"Reference date": "XXX",
"Date of collection": "XXX",
"Original file": "XXX",
"Spatial resolution": ["Germany"],
"Description": ["XXX"],
"Column": [
                   {"Name": "scale",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "summe_einwohner",
                    "Description": "XXX",
                    "Unit": "" },
                   {"Name": "anzahl_zellen",
                    "Description": "XXX",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "XXX" }
                  ],
"ToDo": ["Please complete"],
"Licence": ["XXX"],
"Instructions for proper use": ["XXX"]
}';


SELECT obj_description('social.zensus_stats'::regclass)::json;

--



