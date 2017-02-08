/*
Setup for renewables power plants list

__copyright__ 	= "Europa-Universität Flensburg, Centre for Sustainable Energy Systems"
__license__ 	= ""
__url__ 	= ""
__author__ 	= "wolfbunke"
*/

-- DROP TABLE supply.ego_renewable_power_plants_germany;

/*

CREATE TABLE supply.ego_renewable_power_plants_germany
(
  id bigint NOT NULL,
  start_up_date timestamp without time zone,
  electrical_capacity numeric,
  generation_type text,
  generation_subtype character varying,
  thermal_capacity numeric,
  city character varying,
  postcode character varying,
  address character varying,
  lon numeric,
  lat numeric,
  gps_accuracy character varying,
  validation character varying,
  notification_reason character varying,
  eeg_id character varying,
  tso double precision,
  tso_eic character varying,
  dso_id character varying,
  dso character varying,
  voltage_level character varying,
  network_node character varying,
  power_plant_id character varying,
  source character varying,
  comment character varying,
  geom geometry(Point,4326),
  CONSTRAINT opsd_renewable_power_platns_germany_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE supply.ego_renewable_power_plants_germany
  OWNER TO oeuser;
GRANT ALL ON TABLE supply.ego_renewable_power_plants_germany TO oeuser;



COMMENT ON TABLE supply.ego_renewable_power_plants_germany
  IS '{"Name": "Renewable power plants in Germany",

"Source": [{
                     "Name": "EnergyMap",
                      "URL": "www.energymap.info" },
                     {
                     "Name": "Bundesnetzagentur (BNetzA)",
                      "URL": "www.bundesnetzagentur.de" }
],

"Reference date": ["31.12.2015"],

"Retrieved": ["16.03.2016"],

"Date of collection": ["31.12.2015"],

"Original file": ["eeg_anlagenregister_2015.08.utf8.csv.zip,Meldungen_Aug-Dez2015.xls, 2016_01_Veroeff_AnlReg.xls"],

"Spatial resolution": ["Germany"],

"Description": ["This table contains a list of renewable energy power plants in Germany. This data join two sources: energymap.info, a data platform of the ''Deutsche Gesellschaft für Sonnenenergie e.V.'' and Bundesnetzagentur, the regularor together."], 

"Regional level": ["minimum postcode level"],

"Column":[

	{"Name": "id",
	"Description": "Primary Key",
	"Unit": "" },

	{"Name": "start_up_date",
	"Description": "start-up date",
	"Unit": "" },

	{"Name": "electrical_capacity",
	"Description": "electrical capacity",
	"Unit": "kW" },

	{"Name": "generation_type",
	"Description": "generation_type or main fuel type",
	"Unit": "" },

	{"Name": "generation_subtype",
	"Description": "generation subtype",
	"Unit": "" },

	{"Name": "thermal_capacity",
	"Description": "thermal capacity",
	"Unit": "kW" },

	{"Name": "city",
	"Description": "Name of city or location",
	"Unit": "" },

	{"Name": "postcode",
	"Description": "postcode",
	"Unit": "" },

	{"Name": "address",
	"Description": "address",
	"Unit": "" },

	{"Name": "lon",
	"Description": "longitude",
	"Unit": "" },

	{"Name": "lat",
	"Description": "latitude",
	"Unit": "" },

	{"Name": "gps_accuracy",
	"Description": "gps accuracy in meter",
	"Unit": "meter" },

	{"Name": "validation",
	"Description": "validation comments",
	"Unit": "" },

	{"Name":"notification_reason",
	"Description":"notification reason from BNetzA sources",
	"Unit":"" },

	{"Name":"eeg_id",
	"Description":"EEG id of Unit",
	"Unit":"" },

	{"Name":"tso",
	"Description":"Name of Transmission system operator",
	"Unit":"" },

	{"Name":"tso_eic",
	"Description":"Name of Transmission system operator",
	"Unit":"" },

	{"Name":"dso_id",
	"Description":"Name of District system operator",
	"Unit":"" },

	{"Name":"dso",
	"Description":"Name of District system operator",
	"Unit":"" },

	{"Name":"voltage_level",
	"Description":"voltage level",
	"Unit":"" },

	{"Name":"network_node",
	"Description":"Name or code of network node",
	"Unit":"" },

	{"Name":"power_plant_id",
	"Description":"power plant id from BNetzA",
	"Unit":"" },

	{"Name":"source",
	"Description":"short Name of source: energymap or bnetza",
	"Unit":"" },

	{"Name":"comment",
	"Description":"Further comment of changes",
	"Unit":"" },

	{"Name":"geom",
	"Description":"Geometry",
	"Unit":"" }
],

"Changes":[
  { "Name":"Wolf-Dieter Bunke", 
    "Mail":"wolf-dieter.bunke@uni-flensburg.de", 
    "Date":"16.03.2016", 
    "Comment":"Created table" }],

"ToDo": ["ckeck licence"],

"Licence": [{"Name": "unspecified Licence",
                          "URL": " "}],

"Instructions for proper use": ["Always state licence"]}';
*/


