/* 
renpass_gis schema


*/


-- Sequence: model_draft.renpass_gis_results_id_seq
-- DROP SEQUENCE model_draft.renpass_gis_results_id_seq;

CREATE SEQUENCE model_draft.renpass_gis_results_id_seq START 1;

-- Sequence: model_draft.renpass_gis_scenario_id_seq
-- DROP SEQUENCE model_draft.renpass_gis_scenario_id_seq;

CREATE SEQUENCE model_draft.renpass_gis_scenario_id_seq START 1;

-- Sequence: model_draft.renpass_gis_economic_storage_id_seq
-- DROP SEQUENCE model_draft.renpass_gis_economic_storage_id_seq;

CREATE SEQUENCE model_draft.renpass_gis_economic_storage_id_seq START 1;

-- Sequence: model_draft.renpass_gis_economic_linear_transformer_id_seq
-- DROP SEQUENCE model_draft.renpass_gis_economic_linear_transformer_id_seq;

CREATE SEQUENCE model_draft.renpass_gis_economic_linear_transformer_id_seq START 1;

-- Sequence: model_draft.renpass_gis_economic_sink_id_seq
-- DROP SEQUENCE model_draft.renpass_gis_economic_sink_id_seq;
CREATE SEQUENCE model_draft.renpass_gis_economic_sink_id_seq START 1;

-- Sequence: model_draft.renpass_gis_economic_source_id_seq
-- DROP SEQUENCE model_draft.renpass_gis_economic_source_id_seq;
CREATE SEQUENCE model_draft.renpass_gis_economic_source_id_seq START 1;


-- Table: model_draft.economic_weatherpoint

-- DROP TABLE model_draft.economic_weatherpoint;

CREATE TABLE model_draft.economic_weatherpoint
(
  gid serial NOT NULL,
  year integer,
  geom geometry(Point,4326),
  CONSTRAINT economic_weatherpoint_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.economic_weatherpoint
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.economic_weatherpoint TO oeuser;

-- Index: model_draft.idx_economic_weatherpoint_geom

-- DROP INDEX model_draft.idx_economic_weatherpoint_geom;

CREATE INDEX idx_economic_weatherpoint_geom
  ON model_draft.economic_weatherpoint
  USING gist
  (geom);

COMMENT ON TABLE model_draft.economic_weatherpoint
  IS '{
"Name": "weather point location",
"Source": [{
                  "Name": "",
                  "URL":  "" }],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": ["Germany"],
"Description": [""],
"Column": [
                   {"Name":"gid", "Description":"Unique identifier", "Unit":""},
                   {"Name":"year", "Description":"Reference year", "Unit":""},
                   {"Name":"geom", "Description":"Point geometry", "Unit":""},
],
"Changes":[
                   {"Name": "Martin Söthe",
                    "Mail": "martin.soethe@uni-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "Created an empty table." }],
"ToDo": ["Determine license. Add data."],
"Licence": [""],
"Instructions for proper use": [""],
"Label": [""]
}''';



     
-- Table: model_draft.renpass_gis_economic_source
-- DROP TABLE model_draft.renpass_gis_economic_source;

CREATE TABLE model_draft.renpass_gis_economic_source
(
  id bigint NOT NULL DEFAULT nextval('model_draft.renpass_gis_economic_source_id_seq'),
  scenario_id integer,
  label character varying(250),
  source character varying(250),
  target character varying(250),
  nominal_value numeric[],
  actual_value numeric[],
  variable_costs numeric[],
  fixed boolean,
  CONSTRAINT renpass_gis_economic_source_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.renpass_gis_economic_source
  OWNER TO oeuser;
COMMENT ON TABLE model_draft.renpass_gis_economic_source
  IS '{
"Name": "eGo renpassG!S source",
"Source": [{
                  "Name": "ZNES",
                  "URL":  "https://github.com/znes/renpass_gis" },
		{"Name": "Open Energy Modelling Framework",
		 "URL": "https://github.com/oemof"}],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": [""],
"Description": ["For more information please read the renpassG!S or oemof documentation."],
"Column": [
                   {"Name":"id", "Description":"Unique identifier", "Unit":""},
                   {"Name":"scenario_id", "Description":"Reference to scenario_id", "Unit":""},
                   {"Name":"label", "Description":"", "Unit":""},
                   {"Name":"source", "Description":"", "Unit":""},
                   {"Name":"target", "Description":"", "Unit":""},
                   {"Name":"nominal_value", "Description":"", "Unit":""},
                   {"Name":"actual_value", "Description":"", "Unit":""},
		   {"Name": "variable_costs", "Description": "", "Unit": "" },
                   {"Name":"fixed", "Description":"", "Unit":""}
],
"Changes":[
                   {"Name": "Martin Söthe",
                    "Mail": "martin.soethe@uni-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "Created an empty table." }],
"ToDo": ["Determine licence. Add scenario data."],
"Licence": [""],
"Instructions for proper use": [""],
"Label": ["oemof", "renpassG!S"]
}''';

-- Table: model_draft.renpass_gis_economic_sink

-- DROP TABLE model_draft.renpass_gis_economic_sink;

CREATE TABLE model_draft.renpass_gis_economic_sink
(
  id bigint NOT NULL DEFAULT nextval('model_draft.renpass_gis_economic_sink_id_seq'),
  scenario_id integer,
  label character varying(250),
  source character varying(250),
  target character varying(250),
  nominal_value numeric[],
  actual_value numeric[],
  fixed boolean,
  CONSTRAINT renpass_gis_economic_sink_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.renpass_gis_economic_sink
  OWNER TO oeuser;
COMMENT ON TABLE model_draft.renpass_gis_economic_sink
  IS '{
"Name": "eGo renpassG!S sink",
"Source": [{
                  "Name": "ZNES",
                  "URL":  "https://github.com/znes/renpass_gis" },
		{"Name": "Open Energy Modelling Framework",
		 "URL": "https://github.com/oemof"}],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": [""],
"Description": ["For more information please read the renpassG!S or oemof documentation."],
"Column": [
                   {"Name":"id", "Description":"Unique identifier", "Unit":""},
                   {"Name":"scenario_id", "Description":"Reference to scenario_id", "Unit":""},
                   {"Name":"label", "Description":"", "Unit":""},
                   {"Name":"source", "Description":"", "Unit":""},
                   {"Name":"target", "Description":"", "Unit":""},
                   {"Name":"nominal_value", "Description":"", "Unit":""}
                   {"Name":"actual_value", "Description":"", "Unit":""}
                   {"Name":"fixed", "Description":"", "Unit":""}
],
"Changes":[
                   {"Name": "Martin Söthe",
                    "Mail": "martin.soethe@uni-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "Created an empty table." }],
"ToDo": ["Determine licence. Add scenario data."],
"Licence": [""],
"Instructions for proper use": [""],
"Label": ["oemof", "renpassG!S"]
}''';


-- Table: model_draft.renpass_gis_scenario

-- DROP TABLE model_draft.renpass_gis_scenario;

CREATE TABLE model_draft.renpass_gis_scenario
(

  id integer NOT NULL DEFAULT nextval('model_draft.renpass_gis_scenario_id_seq'),
  name character varying(250)  UNIQUE NOT NULL,
  CONSTRAINT renpass_gis_scenario_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.renpass_gis_scenario
  OWNER TO oeuser;
COMMENT ON TABLE model_draft.renpass_gis_scenario
  IS '{
"Name": "renpassG!S scenario",
"Source": [{
                  "Name": "ZNES",
                  "URL":  "https://github.com/znes/renpass_gis" }],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": [""],
"Description": ["Definition table for all scenarios"],
"Column": [
                   {"Name":"id", "Description":"Scenario id", "Unit":""},
                   {"Name":"name", "Description":"Scenario name", "Unit":""}


],
"Changes":[
                   {"Name": "Martin Söthe",
                    "Mail": "",
                    "Date":  "",
                    "Comment": "Created empty table." }],
"ToDo": ["Add data."],
"Licence": [""],
"Instructions for proper use": [""],
"Label": [""]
}''';

-- Table: model_draft.renpass_gis_economic_linear_transformer

-- DROP TABLE model_draft.renpass_gis_economic_linear_transformer;

CREATE TABLE model_draft.renpass_gis_economic_linear_transformer
(
  id bigint NOT NULL DEFAULT nextval('model_draft.renpass_gis_economic_linear_transformer_id_seq'),
  scenario_id integer,
  label character varying(250),
  source character varying(250), --- check constraints()
  target character varying(250),  --- check constraints()
  conversion_factors numeric[],
  summed_min numeric[],
  nominal_value  numeric[],
  actual_value  numeric[],
  fixed boolean,
  variable_costs numeric[],
  fixed_costs numeric[],
  CONSTRAINT renpass_gis_economic_linear_transformer_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.renpass_gis_economic_linear_transformer
  OWNER TO oeuser;
COMMENT ON TABLE model_draft.renpass_gis_economic_linear_transformer
  IS '{
"Name": "eGo renpassG!S linear transformer",
"Source": [{
                  "Name": "ZNES",
                  "URL":  "https://github.com/znes/renpass_gis" },
		{"Name": "Open Energy Modelling Framework",
		 "URL": "https://github.com/oemof"}],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": [""],
"Description": ["For more information please read the renpassG!S or oemof documentation."],
"Column": [
                   {"Name":"id", "Description":"", "Unit":""},
                   {"Name":"scenario_id", "Description":"", "Unit":""},
                   {"Name":"label", "Description":"", "Unit":""},
                   {"Name":"source", "Description":"", "Unit":""},
                   {"Name":"target", "Description":"", "Unit":""},
                   {"Name":"conversion_factors", "Description":"", "Unit":""},
                   {"Name":"summed_min", "Description":"", "Unit":""},
                   {"Name":"nominal_value", "Description":"", "Unit":""},
                   {"Name":"actual_value", "Description":"", "Unit":""},                   
                   {"Name":"fixed", "Description":"", "Unit":""}, 
                   {"Name":"variable_costs", "Description":"", "Unit":""}, 
                   {"Name":"fixed_costs", "Description":"", "Unit":""}
],
"Changes":[
                   {"Name": "Martin Söthe",
                    "Mail": "martin.soethe@uni-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "Created an empty table." }],
"ToDo": ["Determine licence. Add scenario data."],
"Licence": [""],
"Instructions for proper use": [""],
"Label": ["oemof", "renpassG!S"]
}''';


-- Table: model_draft.renpass_gis_economic_storage
-- DROP TABLE model_draft.renpass_gis_economic_storage;

CREATE TABLE model_draft.renpass_gis_economic_storage
(
  id bigint NOT NULL DEFAULT nextval('model_draft.renpass_gis_economic_storage_id_seq'),
  scenario_id integer,
  label character varying(250),
  source character varying(250), --- check constraints()
  target character varying(250),  --- check constraints()
  conversion_factors numeric[],
  summed_min numeric[],
  nominal_value  numeric[],
  min numeric[],
  max numeric[],
  actual_value  numeric[],
  fixed boolean,
  variable_costs numeric[],
  fixed_costs numeric[],
  nominal_capacity numeric[],
  capacity_loss	numeric[],
  inflow_conversion_factor numeric[],
  outflow_conversion_factor numeric[],
  initial_capacity numeric[],	
  capacity_min	numeric[],
  capacity_max numeric[],
  CONSTRAINT renpass_gis_economic_storage_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.renpass_gis_economic_storage
  OWNER TO oeuser;
COMMENT ON TABLE model_draft.renpass_gis_economic_storage
  IS '{
"Name": "eGo renpassG!S storage",
"Source": [{
                  "Name": "ZNES",
                  "URL":  "https://github.com/znes/renpass_gis" },
		{"Name": "Open Energy Modelling Framework",
		 "URL": "https://github.com/oemof"}],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": [""],
"Description": ["For more information please read the renpassG!S or oemof documentation."],
"Column": [
                   {"Name":"id", "Description":"", "Unit":""},
                   {"Name":"scenario_id", "Description":"", "Unit":""},
                   {"Name":"label", "Description":"", "Unit":""},
                   {"Name":"source", "Description":"", "Unit":""},
                   {"Name":"target", "Description":"", "Unit":""},
                   {"Name":"conversion_factors", "Description":"", "Unit":""},
                   {"Name":"summed_min", "Description":"", "Unit":""},
                   {"Name":"nominal_value", "Description":"", "Unit":""},
                   {"Name":"min", "Description":"", "Unit":""},
                   {"Name":"max", "Description":"", "Unit":""},
                   {"Name":"actual_value", "Description":"", "Unit":""},                   
                   {"Name":"fixed", "Description":"", "Unit":""}, 
                   {"Name":"variable_costs", "Description":"", "Unit":""}, 
                   {"Name":"fixed_costs", "Description":"", "Unit":""}, 
                   {"Name":"nominal_capacity", "Description":"", "Unit":""},
                   {"Name":"capacity_loss", "Description":"", "Unit":""},
                   {"Name":"inflow_conversion_factor", "Description":"", "Unit":""},
                   {"Name":"outflow_conversion_factor", "Description":"", "Unit":""},                   
                   {"Name":"initial_capacity", "Description":"", "Unit":""}, 
                   {"Name":"capacity_min", "Description":"", "Unit":""}, 
                   {"Name":"capacity_max", "Description":"", "Unit":""}
],
"Changes":[
                   {"Name": "Martin Söthe",
                    "Mail": "martin.soethe@uni-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "Created an empty table." }],
"ToDo": ["Determine licence. Add scenario data."],
"Licence": [""],
"Instructions for proper use": [""],
"Label": ["oemof", "renpassG!S"]
}''';


-- Table: model_draft.renpass_gis_results

-- DROP TABLE model_draft.renpass_gis_results;


CREATE TABLE model_draft.renpass_gis_results
(
  id bigint  NOT NULL DEFAULT nextval('model_draft.renpass_gis_results_id_seq'),
  scenario_id integer,
  bus_label character varying(250),
  type character varying(250),
  obj_label character varying(250),
  datetime timestamp without time zone,
  val numeric,
  CONSTRAINT renpass_gis_results_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.renpass_gis_results
  OWNER TO oeuser;
COMMENT ON TABLE model_draft.renpass_gis_results
  IS '{
"Name": "eGo renpassG!S results",
"Source": [{
                  "Name": "ZNES",
                  "URL":  "https://github.com/znes/renpass_gis" },
		{"Name": "Open Energy Modelling Framework",
		 "URL": "https://github.com/oemof"}],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": [""],
"Description": ["For more information please read the renpassG!S or oemof documentation."],
"Column": [
                   {"Name":"id", "Description":"", "Unit":""},
                   {"Name":"scenario_id", "Description":"", "Unit":""},
                   {"Name":"bus_label", "Description":"", "Unit":""},
                   {"Name":"type", "Description":"", "Unit":""},
                   {"Name":"obj_label", "Description":"", "Unit":""},
                   {"Name":"datetime", "Description":"", "Unit":""},
                   {"Name":"val", "Description":"", "Unit":""},
],
"Changes":[
                   {"Name": "Martin Söthe",
                    "Mail": "martin.soethe@uni-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "Created an empty table." }],
"ToDo": ["Determine licence. Add scenario data."],
"Licence": [""],
"Instructions for proper use": [""],
"Label": ["oemof", "renpassG!S"]
}''';


-- Add FK's


ALTER TABLE model_draft.renpass_gis_results  
   ADD CONSTRAINT results_scenario_fkey
   FOREIGN KEY (scenario_id) 
   REFERENCES model_draft.renpass_gis_scenario(id);
--
ALTER TABLE model_draft.renpass_gis_economic_storage
   ADD CONSTRAINT renpass_gis_economic_storage_fkey
   FOREIGN KEY (scenario_id) 
   REFERENCES model_draft.renpass_gis_scenario(id);
--
ALTER TABLE model_draft.renpass_gis_economic_linear_transformer
   ADD CONSTRAINT renpass_gis_economic_linear_transformer_fkey
   FOREIGN KEY (scenario_id) 
   REFERENCES model_draft.renpass_gis_scenario(id);
--
ALTER TABLE model_draft.renpass_gis_economic_sink
   ADD CONSTRAINT renpass_gis_economic_sink_fkey
   FOREIGN KEY (scenario_id) 
   REFERENCES model_draft.renpass_gis_scenario(id);
--
ALTER TABLE model_draft.renpass_gis_economic_source
   ADD CONSTRAINT renpass_gis_economic_source_fkey
   FOREIGN KEY (scenario_id) 
   REFERENCES model_draft.renpass_gis_scenario(id);

--
-- Add Grand 

ALTER TABLE model_draft.renpass_gis_economic_source OWNER TO oeuser;
GRANT ALL ON SEQUENCE model_draft.renpass_gis_economic_source_id_seq TO oeuser;

ALTER TABLE model_draft.renpass_gis_economic_sink OWNER TO oeuser;
GRANT ALL ON SEQUENCE model_draft.renpass_gis_economic_sink_id_seq TO oeuser;

ALTER TABLE model_draft.renpass_gis_results OWNER TO oeuser;
GRANT ALL ON SEQUENCE model_draft.renpass_gis_results_id_seq TO oeuser;

ALTER TABLE model_draft.renpass_gis_scenario OWNER TO oeuser;
GRANT ALL ON SEQUENCE model_draft.renpass_gis_scenario_id_seq TO oeuser;

ALTER TABLE model_draft.renpass_gis_economic_linear_transformer OWNER TO oeuser;
GRANT ALL ON SEQUENCE model_draft.renpass_gis_economic_linear_transformer_id_seq TO oeuser;
 
ALTER TABLE model_draft.renpass_gis_economic_storage OWNER TO oeuser;
GRANT ALL ON SEQUENCE model_draft.renpass_gis_economic_storage_id_seq TO oeuser;
 



-- ToDOs
-- Add further check constraints for sources, etc.

/*
Open questions:

1.  model_draft.renpass_gis_scenario id as sequence?
2.  check constraints -> controll order of data filling 


*/



/*
#########################################
How to create a scenario:


1. add scenario name into model_draft.renpass_gis_scenario 


*/ 

/* Drop all


DROP SEQUENCE model_draft.renpass_gis_economic_sink_id_seq CASCADE;
DROP SEQUENCE model_draft.renpass_gis_results_id_seq CASCADE;
DROP SEQUENCE model_draft.renpass_gis_scenario_id_seq CASCADE;
DROP SEQUENCE model_draft.renpass_gis_economic_storage_id_seq CASCADE;
DROP SEQUENCE model_draft.renpass_gis_economic_source_id_seq CASCADE;
DROP SEQUENCE model_draft.renpass_gis_economic_linear_transformer_id_seq CASCADE;
DROP TABLE model_draft.renpass_gis_economic_source CASCADE; 
DROP TABLE model_draft.renpass_gis_economic_storage CASCADE;
DROP TABLE model_draft.renpass_gis_economic_sink CASCADE;
DROP TABLE model_draft.renpass_gis_results CASCADE;
DROP TABLE model_draft.renpass_gis_economic_linear_transformer CASCADE;
DROP TABLE model_draft.renpass_gis_scenario CASCADE;
 */
