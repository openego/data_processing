---
---
DROP SEQUENCE IF EXISTS	supply.nep_powerplant_seq CASCADE;
CREATE SEQUENCE supply.nep_powerplant_seq;


DROP TABLE IF EXISTS	supply.nep_powerplant CASCADE;
CREATE TABLE supply.nep_powerplant
(
  bnetza_id character varying,
  tso character varying,
  power_plant_name character varying,
  unit_name character varying,
  postcode character varying,
  state character varying,
  commissioning integer,
  chp character varying,
  fuel character varying,
  rated_power numeric,
  rated_power_a2025 numeric,
  rated_power_b2025 numeric,
  rated_power_b2035 numeric,
  rated_power_c2025 numeric,
  lat double precision,
  lon double precision,
  location_checked text,
  geom geometry(Point,4326),
  gid integer NOT NULL DEFAULT nextval('model_draft.nep_powerplant_seq'::regclass),
  CONSTRAINT nep_powerplants_pkey PRIMARY KEY (gid)
);

--
-- Set metadata
--

COMMENT ON TABLE  orig_geo_powerplants.nep_2015_powerplants IS
'{
"Name": "NEP 2015 List of Powerplants in Germany",
"Source": [{
                  "Name": "Kraftwerksliste zum Entwurf Szenariorahmen NEP/O-NEP 2015",
                  "URL":  "http://www.netzentwicklungsplan.de/file/2594/download?token=LnmZpfQa" }],
"Reference date": "30.04.2014",
"Date of collection": "22.08.2016",
"Original file": "nep_2015_kraftwerksliste_entwurf_140430.pdf",
"Spatial resolution": ["Germany"],
"Description": ["List of NEP 2015 powerplants. According to electrical Capacity as rated power per scenario. Geo-location added by research and comparison of OPSD powerplat list and the BNetzA ID."],
"Column": [
                   {"Name": "bnetza_id",
                    "Description": "Bundesnetzagentur unit ID",
                    "Unit": "" },  
                   {"Name": "tso",
                    "Description": "Name of transmission system operator",
                    "Unit": "" },
                   {"Name": "power_plant_name",
                    "Description": "name of powerplant",
                    "Unit": "" },
                   {"Name": "unit_name",
                    "Description": "name of powerplant unit",
                    "Unit": "" },
                   {"Name": "postcode",
                    "Description": "postcode",
                    "Unit": "" },
                   {"Name": "state",
                    "Description": "Name of federate state of location",
                    "Unit": "" },
                   {"Name": "commissioning",
                    "Description": "commissioning year",
                    "Unit": "a" },
                   {"Name": "chp",
                    "Description": "Use of combined heat and power technology",
                    "Unit": "" },
                   {"Name": "fuel",
                    "Description": "Name of fuel used by unit",
                    "Unit": "" },
                   {"Name": "rated_power",
                    "Description": "electrical Capacity as rated power",
                    "Unit": "MW" },
                   {"Name": "rated_power_a2025",
                    "Description": "electrical Capacity as rated power",
                    "Unit": "MW" },
                   {"Name": "rated_power_b2025",
                    "Description": "electrical Capacity as rated power",
                    "Unit": "MW" },
                   {"Name": "rated_power_b2035",
                    "Description": "electrical Capacity as rated power",
                    "Unit": "MW" },
                   {"Name": "rated_power_c2025",
                    "Description": "electrical Capacity as rated power",
                    "Unit": "MW" },
                   {"Name": "lat",
                    "Description": "latitude",
                    "Unit": "" },     
                   {"Name": "lon",
                    "Description": "longitude",
                    "Unit": "" }, 
                   {"Name": "location_checked",
                    "Description": "Validation Ckeck",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "Geometry Point",
                    "Unit": "" },                        
                   {"Name": "gid",
                    "Description": "geom ID",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Wolf-Dieter Bunke",
                    "Mail": "wolf-dieter.bunke@uni-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "change of meta documentation" }
                  ],
"ToDo": ["Check licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- check metadata
--
SELECT obj_description('orig_geo_powerplants.nep_2015_powerplants'::regclass)::json;
