-- Create Database table for Postgresql
-- Using csv structure and data from OPSD Project
-- More information: open-power-system-data.org/
-- http://data.open-power-system-data.org/datapackage_timeseries/


CREATE TABLE orig_geo_opsd.opsd_hourly_timeseries
(
timestamp timestamp without time zone,
load_AT numeric(12,2),
load_BA numeric(12,2),
load_BE numeric(12,2),
load_BG numeric(12,2),
load_CH numeric(12,2),
load_CS numeric(12,2),
load_CY numeric(12,2),
load_CZ numeric(12,2),
load_DE numeric(12,2),
load_DK numeric(12,2),
load_DKw numeric(12,2),
load_EE numeric(12,2),
load_ES numeric(12,2),
load_FI numeric(12,2),
load_FR numeric(12,2),
load_GB numeric(12,2),
load_GR numeric(12,2),
load_HR numeric(12,2),
load_HU numeric(12,2),
load_IE numeric(12,2),
load_IS numeric(12,2),
load_IT numeric(12,2),
load_LT numeric(12,2),
load_LU numeric(12,2),
load_LV numeric(12,2),
load_ME numeric(12,2),
load_MK numeric(12,2),
load_NI numeric(12,2),
load_NL numeric(12,2),
load_NO numeric(12,2),
load_PL numeric(12,2),
load_PT numeric(12,2),
load_RO numeric(12,2),
load_RS numeric(12,2),
load_SE numeric(12,2),
load_SI numeric(12,2),
load_SK numeric(12,2),
load_UAw numeric(12,2),
solar_DE_capacity numeric(12,2),
solar_DE_forecast numeric(12,2),
solar_DE_generation numeric(12,2),
solar_DE_profile numeric(12,2),
solar_DE50hertz_forecast numeric(12,2),
solar_DE50hertz_generation numeric(12,2),
solar_DEamprion_forecast numeric(12,2),
solar_DEamprion_generation numeric(12,2),
solar_DEtennet_forecast numeric(12,2),
solar_DEtennet_generation numeric(12,2),
solar_DEtransnetbw_forecast numeric(12,2),
solar_DEtransnetbw_generation numeric(12,2),
wind_DE_capacity numeric(12,2),
wind_DE_forecast numeric(12,2),
wind_DE_generation numeric(12,2),
wind_DE_profile numeric(12,2),
wind_DE50hertz_forecast numeric(12,2),
wind_DE50hertz_generation numeric(12,2),
wind_DEamprion_forecast numeric(12,2),
wind_DEamprion_generation numeric(12,2),
wind_DEtennet_forecast numeric(12,2),
wind_DEtennet_generation numeric(12,2),
wind_DEtransnetbw_forecast numeric(12,2),
wind_DEtransnetbw_generation numeric(12,2),
CONSTRAINT opsd_hourly_timeseries_pkey PRIMARY KEY (timestamp)
);
--
-- USE CSV import function of PgAdmin 3 in order to import data

--
COMMENT ON TABLE orig_geo_opsd.opsd_hourly_timeseries
  IS '
{"Name": "OPSD hourly timeseries",
"Source":[{
 "Name": "Website of data",
 "URL": "http://data.open-power-system-data.org/datapackage_timeseries/2016-03-18/" }],
"Reference date": ["01.01.2005 until 31.01.2016"]

"Date of collection": ["16.03.2016"],

"Original file": ["timeseries60min.csv"],

"Spatial resolution": ["Europe"],

"Description": ["This dataset contains timeseries data of wind and 
                 solar in-feed into the grids of German Transmission 
                 System Operators as well as load timeseries for 37 
                 European countries from ENTSO-E.", 

"Column":
[
{"Name":"timestamp",
"Description":"timestamp starting from 2005",
"Unit":"Start of timeperiod in UTC"
},
{"Name":"load_at",
"Description":"load_at",
"Unit":"MW" },

{"Name":"rest",
"Description":"...",
"Unit":"..." }
],

"Changes":[
  { "Name":"Wolf-Dieter Bunke", 
    "Mail":"wd.bunke@gmail.com", 
    "Date":"18.03.2016", 
    "Comment":"Created table" }],

"ToDo": ["Update Tabel, finish discription"],
"Licence": ["Several licences, work in progress of OPSD "],
"Instructions for proper use": ["Always state licence"]}
';

