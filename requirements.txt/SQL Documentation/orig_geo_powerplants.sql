
-- 

COMMENT ON TABLE  orig_geo_powerplants.generators_total IS
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
                   {"Name": "un_id",
                    "Description": "...",
                    "Unit": "" },  
                   {"Name": "re_id",
                    "Description": "...",
                    "Unit": "" },     
                   {"Name": "conv_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "aggr_id_pf",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "aggr_id_ms",
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


SELECT obj_description('orig_geo_powerplants.generators_total'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_powerplants.nep_2015_powerplants IS
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
                   {"Name": "bnetza_id",
                    "Description": "...",
                    "Unit": "" },  
                   {"Name": "tso",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "power_plant_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "unit_name",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "postcode",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "state",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "commissioning",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "chp",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "fuel",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rated_power",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rated_power_a2025",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rated_power_b2025",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rated_power_b2035",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rated_power_c2025",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "lat",
                    "Description": "...",
                    "Unit": "" },     
                   {"Name": "lon",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "location_checked",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" },                        
                   {"Name": "gid",
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


SELECT obj_description('orig_geo_powerplants.nep_2015_powerplants'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_powerplants.pf_generator_single IS
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
                   {"Name": "generator_id",
                    "Description": "...",
                    "Unit": "" },  
                   {"Name": "bus",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "dispatch",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "control",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom_extendable",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom_min",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_nom_max",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_min_pu_fixed",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "p_max_pu_fixed",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "sign",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "source",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "marginal_cost",
                    "Description": "...",
                    "Unit": "" },     
                   {"Name": "capital_cost",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "efficiency",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "w_id",
                    "Description": "...",
                    "Unit": "" },                        
                   {"Name": "aggr_id",
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


SELECT obj_description('orig_geo_powerplants.pf_generator_single'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_powerplants.proc_power_plant_germany IS
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
                   {"Name": "bnetza_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "company",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "name",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "postcode",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "city",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "street",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "state",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "block",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "commissioned_original",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "commissioned",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "retrofit",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "shutdown",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "status",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "fuel",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "technology",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "type",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "eeg",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "chp",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "capacity",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "capacity_uba",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "chp_capacity_uba",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "efficiency_data",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "efficiency_estimate",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "network_node",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "voltage",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "network_operator",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "name_uba",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "lat",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "lon",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "comment",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "voltage_level",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "otg_id",
                    "Description": "...",
                    "Unit": "" },                        
                   {"Name": "un_id",
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


SELECT obj_description('orig_geo_powerplants.proc_power_plant_germany'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_powerplants.proc_renewable_power_plants_germany IS
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
                   {"Name": "start_up_date",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "electrical_capacity",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "generation_type",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "generation_subtype",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "thermal_capacity",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "city",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "postcode",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "addresss",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "lon",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "lat",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "gps_accuracy",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "valididation",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "notification_reason",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "eeg_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "tso",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "tso_eic",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "dso_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "dso",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "voltage_level",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "network_node",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "power_plant_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "source",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "comment",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "voltage",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "otg_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "un_id",
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


SELECT obj_description('orig_geo_powerplants.proc_renewable_power_plants_germany'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_powerplants.proc_renewable_power_plants_nep2035 IS
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
                   {"Name": "scenario_year",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "electrical_capacity",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "generation_type",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "generation_subtype",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "thermal_capacity",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "nuts",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "lon",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "lat",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "voltage_level",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "network_node",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "source",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "comment",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "geom",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "voltage",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "otg_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "un_id",
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


SELECT obj_description('orig_geo_powerplants.proc_renewable_power_plants_nep2035'::regclass)::json;

--

-- 

COMMENT ON TABLE  orig_geo_powerplants.pv_dev_nep_germany_mun IS
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
                   {"Name": "pv_units",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pv_cap_2014",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pv_add_cap_2035",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage_level",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rs_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pv_avg_cap",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "pv_new_units",
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


SELECT obj_description('orig_geo_powerplants.pv_dev_nep_germany_mun'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_geo_powerplants.renewable_power_plants_germany IS
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
                   {"Name": "start_up_date",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "electrical_capacity",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "generation_type",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "generation_subtype",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "thermal_capacity",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "city",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "postcode",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "address",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "lon",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "lat",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "gps_accuracy",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "validation",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "notification_reason",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "eeg_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "tso",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "tso_eic",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "dso_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "dso",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "voltage_level",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "network_node",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "power_plant_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "source",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "comment",
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


SELECT obj_description('orig_geo_powerplants.renewable_power_plants_germany'::regclass)::json;

--



-- 

COMMENT ON TABLE  orig_geo_powerplants.renewable_power_plants_germany_to_region IS
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
                   {"Name": "re_id",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "subst_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "otg_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "un_id",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "nuts",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "rs_0",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "id_vg250",
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


SELECT obj_description('orig_geo_powerplants.renewable_power_plants_germany_to_region'::regclass)::json;

--


-- 

COMMENT ON TABLE  orig_geo_powerplants.voltage_level IS
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
                   {"Name": "voltage_level",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "voltage",
                    "Description": "...",
                    "Unit": "" },
                   {"Name": "voltage_disc",
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


SELECT obj_description('orig_geo_powerplants.voltage_level'::regclass)::json;

--


