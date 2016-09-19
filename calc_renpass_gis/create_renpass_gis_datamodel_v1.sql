/* renpass_gis Datamodel V1




*/


-- Sequence: calc_renpass_gis.renpass_gis_results_id_seq
-- DROP SEQUENCE calc_renpass_gis.renpass_gis_results_id_seq;

CREATE SEQUENCE calc_renpass_gis.renpass_gis_results_id_seq START 1;

-- Sequence: calc_renpass_gis.renpass_gis_scenario_id_seq
-- DROP SEQUENCE calc_renpass_gis.renpass_gis_scenario_id_seq;

CREATE SEQUENCE calc_renpass_gis.renpass_gis_scenario_id_seq START 1;

-- Sequence: calc_renpass_gis.renpass_gis_storage_id_seq
-- DROP SEQUENCE calc_renpass_gis.renpass_gis_storage_id_seq;

CREATE SEQUENCE calc_renpass_gis.renpass_gis_storage_id_seq START 1;

-- Sequence: calc_renpass_gis.renpass_gis_linear_transformer_id_seq
-- DROP SEQUENCE calc_renpass_gis.renpass_gis_linear_transformer_id_seq;

CREATE SEQUENCE calc_renpass_gis.renpass_gis_linear_transformer_id_seq START 1;

-- Sequence: calc_renpass_gis.renpass_gis_sink_id_seq
-- DROP SEQUENCE calc_renpass_gis.renpass_gis_sink_id_seq;
CREATE SEQUENCE calc_renpass_gis.renpass_gis_sink_id_seq START 1;

-- Sequence: calc_renpass_gis.renpass_gis_source_id_seq
-- DROP SEQUENCE calc_renpass_gis.renpass_gis_source_id_seq;
CREATE SEQUENCE calc_renpass_gis.renpass_gis_source_id_seq START 1;


     
-- Table: calc_renpass_gis.renpass_gis_source
-- DROP TABLE calc_renpass_gis.renpass_gis_source;

CREATE TABLE calc_renpass_gis.renpass_gis_source
(
  id bigint NOT NULL DEFAULT nextval('calc_renpass_gis.renpass_gis_source_id_seq'),
  scenario_id integer,
  label character varying(250),
  source character varying(250),
  target character varying(250),
  nominal_value numeric[],
  actual_value numeric[],
  fixed boolean,
  CONSTRAINT renpass_gis_source_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE calc_renpass_gis.renpass_gis_source
  OWNER TO oeuser;
COMMENT ON TABLE calc_renpass_gis.renpass_gis_source
  IS '{
"Name": "renpassG!S sources",
"Source": [{
                  "Name": "ZNES",
                  "URL":  "" }],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": [""],
"Description": ["Sources of renpassG!S with corresponding parameters"],
"Column": [
                   {"Name":"id", "Description":"", "Unit":""},
                   {"Name":"scenario_id", "Description":"reference to scenario", "Unit":""},
                   {"Name":"label", "Description":"unique object label", "Unit":""},
                   {"Name":"source", "Description":"", "Unit":""},
                   {"Name":"target", "Description":"", "Unit":""},
                   {"Name":"nominal_value", "Description":"", "Unit":""}
                   {"Name":"actual_value", "Description":"", "Unit":""}
                   {"Name":"fixed", "Description":"", "Unit":""}
],
"Changes":[
                   {"Name": "Martin Söthe",
                    "Mail": "",
                    "Date":  "",
                    "Comment": "Created table, added description" }],
"ToDo": [""],
"Licence": [""],
"Instructions for proper use": [""],
"Label": [""]
}''';

-- Table: calc_renpass_gis.renpass_gis_sink

-- DROP TABLE calc_renpass_gis.renpass_gis_sink;

CREATE TABLE calc_renpass_gis.renpass_gis_sink
(
  id bigint NOT NULL DEFAULT nextval('calc_renpass_gis.renpass_gis_sink_id_seq'),
  scenario_id integer,
  label character varying(250),
  source character varying(250),
  target character varying(250),
  nominal_value numeric[],
  actual_value numeric[],
  fixed boolean,
  CONSTRAINT renpass_gis_sink_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE calc_renpass_gis.renpass_gis_sink
  OWNER TO oeuser;
COMMENT ON TABLE calc_renpass_gis.renpass_gis_sink
  IS '{
"Name": "renpassG!S sink",
"Source": [{
                  "Name": "ZNES",
                  "URL":  "" }],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": [""],
"Description": ["Sources of renpassG!S with corresponding parameters"],
"Column": [
                   {"Name":"id", "Description":"", "Unit":""},
                   {"Name":"scenario_id", "Description":"reference to scenario", "Unit":""},
                   {"Name":"label", "Description":"unique object label", "Unit":""},
                   {"Name":"source", "Description":"", "Unit":""},
                   {"Name":"target", "Description":"", "Unit":""},
                   {"Name":"nominal_value", "Description":"", "Unit":""},
                   {"Name":"actual_value", "Description":"", "Unit":""},
                   {"Name":"fixed", "Description":"", "Unit":""}
],
"Changes":[
                   {"Name": "Martin Söthe",
                    "Mail": "",
                    "Date":  "",
                    "Comment": "Created table, added description" }],
"ToDo": [""],
"Licence": [""],
"Instructions for proper use": [""],
"Label": [""]
}''';


-- Table: calc_renpass_gis.renpass_gis_scenario

-- DROP TABLE calc_renpass_gis.renpass_gis_scenario;

CREATE TABLE calc_renpass_gis.renpass_gis_scenario
(

  id integer NOT NULL DEFAULT nextval('calc_renpass_gis.renpass_gis_scenario_id_seq'),
  name character varying(250)  UNIQUE NOT NULL,
  CONSTRAINT renpass_gis_scenario_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE calc_renpass_gis.renpass_gis_scenario
  OWNER TO oeuser;
COMMENT ON TABLE calc_renpass_gis.renpass_gis_scenario
  IS '{
"Name": "renpassG!S sink",
"Source": [{
                  "Name": "ZNES",
                  "URL":  "" }],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": [""],
"Description": ["Scenario definition table of renpassG!S"],
"Column": [
                   {"Name":"id", "Description":"scenario id", "Unit":""},
                   {"Name":"name", "Description":"scenario name", "Unit":""}


],
"Changes":[
                   {"Name": "Martin Söthe",
                    "Mail": "",
                    "Date":  "",
                    "Comment": "Created table, added description" }],
"ToDo": [""],
"Licence": [""],
"Instructions for proper use": [""],
"Label": [""]
}''';

-- Table: calc_renpass_gis.renpass_gis_linear_transformer

-- DROP TABLE calc_renpass_gis.renpass_gis_linear_transformer;

CREATE TABLE calc_renpass_gis.renpass_gis_linear_transformer
(
  id bigint NOT NULL DEFAULT nextval('calc_renpass_gis.renpass_gis_linear_transformer_id_seq'),
  scenario_id integer,
  label character varying(250),
  source character varying(250), --- check constraints()
  taget character varying(250),  --- check constraints()
  convertion_factor numeric[],
  summed_min numeric[],
  nominal_value  numeric[],
  actual_value  numeric[],
  fixed boolean,
  variable_cost numeric[],
  fixed_cost numeric[],
  flow_direction boolean, --(in,out)
  CONSTRAINT renpass_gis_linear_transformer_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE calc_renpass_gis.renpass_gis_linear_transformer
  OWNER TO oeuser;
COMMENT ON TABLE calc_renpass_gis.renpass_gis_linear_transformer
  IS '{
"Name": "renpassG!S results",
"Source": [{
                  "Name": "ZNES",
                  "URL":  "" }],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": [""],
"Description": ["Linear Transformer of renpassG!S"],
"Column": [
                   {"Name":"id", "Description":"", "Unit":""},
                   {"Name":"scenario_id", "Description":"", "Unit":""},
                   {"Name":"label", "Description":"", "Unit":""},
                   {"Name":"source", "Description":"", "Unit":""},
                   {"Name":"taget", "Description":"", "Unit":""},
                   {"Name":"convertion_factor", "Description":"", "Unit":""},
                   {"Name":"summed_min", "Description":"", "Unit":""},
                   {"Name":"nominal_value", "Description":"", "Unit":""},
                   {"Name":"actual_value", "Description":"", "Unit":""},                   
                   {"Name":"fixed", "Description":"", "Unit":""}, 
                   {"Name":"variable_cost", "Description":"", "Unit":""}, 
                   {"Name":"fixed_cost", "Description":"", "Unit":""}, 
                   {"Name":"flow_direction", "Description":"", "Unit":""}
],
"Changes":[
                   {"Name": "Martin Söthe",
                    "Mail": "",
                    "Date":  "",
                    "Comment": "Created table, added description" }],
"ToDo": [""],
"Licence": [""],
"Instructions for proper use": [""],
"Label": [""]
}''';


-- Table: calc_renpass_gis.renpass_gis_storage
-- DROP TABLE calc_renpass_gis.renpass_gis_storage;

CREATE TABLE calc_renpass_gis.renpass_gis_storage
(
  id bigint NOT NULL DEFAULT nextval('calc_renpass_gis.renpass_gis_storage_id_seq'),
  scenario_id integer,
  label character varying(250),
  source character varying(250), --- check constraints()
  taget character varying(250),  --- check constraints()
  convertion_factor numeric[],
  summed_min numeric[],
  nominal_value  numeric[],
  min numeric[],
  max numeric[],
  actual_value  numeric[],
  fixed boolean,
  variable_cost numeric[],
  fixed_cost numeric[],
  nominal_capacity numeric[],
  capacity_loss	numeric[],
  inflow_conversion_factor numeric[],
  outflow_conversion_factor numeric[],
  initial_capacity numeric[],	
  capacity_min	numeric[],
  capacity_max numeric[],
  flow_direction boolean, --(in,out)
  CONSTRAINT renpass_gis_storage_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE calc_renpass_gis.renpass_gis_storage
  OWNER TO oeuser;
COMMENT ON TABLE calc_renpass_gis.renpass_gis_storage
  IS '{
"Name": "renpassG!S results",
"Source": [{
                  "Name": "ZNES",
                  "URL":  "" }],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": [""],
"Description": ["Storage objects of renpassG!S"],
"Column": [
                   {"Name":"id", "Description":"", "Unit":""},
                   {"Name":"scenario_id", "Description":"", "Unit":""},
                   {"Name":"label", "Description":"", "Unit":""},
                   {"Name":"source", "Description":"", "Unit":""},
                   {"Name":"taget", "Description":"", "Unit":""},
                   {"Name":"convertion_factor", "Description":"", "Unit":""},
                   {"Name":"summed_min", "Description":"", "Unit":""},
                   {"Name":"nominal_value", "Description":"", "Unit":""},
                   {"Name":"min", "Description":"", "Unit":""},
                   {"Name":"max", "Description":"", "Unit":""},
                   {"Name":"actual_value", "Description":"", "Unit":""},                   
                   {"Name":"fixed", "Description":"", "Unit":""}, 
                   {"Name":"variable_cost", "Description":"", "Unit":""}, 
                   {"Name":"fixed_cost", "Description":"", "Unit":""}, 
                   {"Name":"nominal_capacity", "Description":"", "Unit":""},
                   {"Name":"capacity_loss", "Description":"", "Unit":""},
                   {"Name":"inflow_conversion_factor", "Description":"", "Unit":""},
                   {"Name":"outflow_conversion_factor", "Description":"", "Unit":""},                   
                   {"Name":"initial_capacity", "Description":"", "Unit":""}, 
                   {"Name":"capacity_min", "Description":"", "Unit":""}, 
                   {"Name":"capacity_max", "Description":"", "Unit":""}, 
                   {"Name":"flow_direction", "Description":"", "Unit":""}
],
"Changes":[
                   {"Name": "Martin Söthe",
                    "Mail": "",
                    "Date":  "",
                    "Comment": "Created table, added description" }],
"ToDo": [""],
"Licence": [""],
"Instructions for proper use": [""],
"Label": [""]
}''';


-- Table: calc_renpass_gis.renpass_gis_results

-- DROP TABLE calc_renpass_gis.renpass_gis_results;


CREATE TABLE calc_renpass_gis.renpass_gis_results
(
  id bigint  NOT NULL DEFAULT nextval('calc_renpass_gis.renpass_gis_results_id_seq'),
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
ALTER TABLE calc_renpass_gis.renpass_gis_results
  OWNER TO oeuser;
COMMENT ON TABLE calc_renpass_gis.renpass_gis_results
  IS '{
"Name": "renpassG!S results",
"Source": [{
                  "Name": "ZNES",
                  "URL":  "" }],
"Reference date": "",
"Date of collection": "",
"Original file": "",
"Spatial resolution": [""],
"Description": ["Results of renpassG!S"],
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
                    "Mail": "",
                    "Date":  "",
                    "Comment": "Created table, added description" }],
"ToDo": [""],
"Licence": [""],
"Instructions for proper use": [""],
"Label": [""]
}''';


-- Add FK's


ALTER TABLE calc_renpass_gis.renpass_gis_results  
   ADD CONSTRAINT results_scenario_fkey
   FOREIGN KEY (scenario_id) 
   REFERENCES calc_renpass_gis.renpass_gis_scenario(id);
--
ALTER TABLE calc_renpass_gis.renpass_gis_storage
   ADD CONSTRAINT renpass_gis_storage_fkey
   FOREIGN KEY (scenario_id) 
   REFERENCES calc_renpass_gis.renpass_gis_scenario(id);
--
ALTER TABLE calc_renpass_gis.renpass_gis_linear_transformer
   ADD CONSTRAINT renpass_gis_linear_transformer_fkey
   FOREIGN KEY (scenario_id) 
   REFERENCES calc_renpass_gis.renpass_gis_scenario(id);
--
ALTER TABLE calc_renpass_gis.renpass_gis_sink
   ADD CONSTRAINT renpass_gis_sink_fkey
   FOREIGN KEY (scenario_id) 
   REFERENCES calc_renpass_gis.renpass_gis_scenario(id);
--
ALTER TABLE calc_renpass_gis.renpass_gis_source
   ADD CONSTRAINT renpass_gis_source_fkey
   FOREIGN KEY (scenario_id) 
   REFERENCES calc_renpass_gis.renpass_gis_scenario(id);

--
-- Add Grand 

ALTER TABLE calc_renpass_gis.renpass_gis_source OWNER TO oeuser;
GRANT ALL ON SEQUENCE calc_renpass_gis.renpass_gis_source_id_seq TO oeuser;

ALTER TABLE calc_renpass_gis.renpass_gis_sink OWNER TO oeuser;
GRANT ALL ON SEQUENCE calc_renpass_gis.renpass_gis_sink_id_seq TO oeuser;

ALTER TABLE calc_renpass_gis.renpass_gis_results OWNER TO oeuser;
GRANT ALL ON SEQUENCE calc_renpass_gis.renpass_gis_results_id_seq TO oeuser;

ALTER TABLE calc_renpass_gis.renpass_gis_scenario OWNER TO oeuser;
GRANT ALL ON SEQUENCE calc_renpass_gis.renpass_gis_scenario_id_seq TO oeuser;

ALTER TABLE calc_renpass_gis.renpass_gis_linear_transformer OWNER TO oeuser;
GRANT ALL ON SEQUENCE calc_renpass_gis.renpass_gis_linear_transformer_id_seq TO oeuser;
 
ALTER TABLE calc_renpass_gis.renpass_gis_storage OWNER TO oeuser;
GRANT ALL ON SEQUENCE calc_renpass_gis.renpass_gis_storage_id_seq TO oeuser;
 



-- ToDOs
-- Add further check constraints for sources, etc.

/*
Open questions:

1.  calc_renpass_gis.renpass_gis_scenario id as sequence?
2.  check constraints -> controll order of data filling 


*/



/*
#########################################
How to create a scenario:


1. add scenario name into calc_renpass_gis.renpass_gis_scenario 


*/ 

/* Drop all


DROP SEQUENCE calc_renpass_gis.renpass_gis_sink_id_seq CASCADE;
DROP SEQUENCE calc_renpass_gis.renpass_gis_results_id_seq CASCADE;
DROP SEQUENCE calc_renpass_gis.renpass_gis_scenario_id_seq CASCADE;
DROP SEQUENCE calc_renpass_gis.renpass_gis_storage_id_seq CASCADE;
DROP SEQUENCE calc_renpass_gis.renpass_gis_source_id_seq CASCADE;
DROP SEQUENCE calc_renpass_gis.renpass_gis_linear_transformer_id_seq CASCADE;
DROP TABLE calc_renpass_gis.renpass_gis_source CASCADE; 
DROP TABLE calc_renpass_gis.renpass_gis_storage CASCADE;
DROP TABLE calc_renpass_gis.renpass_gis_sink CASCADE;
DROP TABLE calc_renpass_gis.renpass_gis_results CASCADE;
DROP TABLE calc_renpass_gis.renpass_gis_linear_transformer CASCADE;
DROP TABLE calc_renpass_gis.renpass_gis_scenario CASCADE;
 */