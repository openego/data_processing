/*
setup for hv powerflow

PF HV scenario settings
PF HV source
PF HV bus
PF HV busmap
PF HV generator
PF HV line
PF HV load
PF HV storage
PF HV temp resolution
PF HV transformer
PF HV mag set
PF HV generator PQ set		
PF HV load PQ set		
PF HV storage PQ set		

PF HV bus results
PF HV generator results
PF HV line results
PF HV storage results
PF HV line results
PF HV transformer results


__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "mariusves, IlkaCu, ulfmueller, Ludee, s3pp"
*/

--------------------------------------------------------------------
-------------------- Static component tables -----------------------
--------------------------------------------------------------------

-- PF HV scenario settings
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_scenario_settings CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_scenario_settings (
	scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
	bus character varying,
	bus_v_mag_set character varying,
	generator character varying,
	generator_pq_set character varying,
	line character varying,
	load character varying,
	load_pq_set character varying,
	storage character varying,
	storage_pq_set character varying,
	temp_resolution character varying,
	transformer character varying,
	CONSTRAINT scenario_settings_pkey PRIMARY KEY (scn_name) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_scenario_settings IS
'{
"Name": "Scenario settings hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "...",
"Original file": "ego_dp_powerflow_hv_setup.sql",
"Spatial resolution": ["Germany"],
"Description": ["Overview of scenarios for the hv powerflow"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "bus",
                    "Description": "scenario for bus dataset",
                    "Unit": "" },                   
                   {"Name": "bus_v_mag_set",
                    "Description": "scenario for bus dataset",
                    "Unit": "" },
                   {"Name": "generator",
                    "Description": "scenario for generator dataset",
                    "Unit": "" },
                   {"Name": "generator_pq_set",
                    "Description": "scenario for generator dataset",
                    "Unit": "" },
                   {"Name": "line",
                    "Description": "scenario for line dataset",
                    "Unit": "" },
                   {"Name": "load",
                    "Description": "scenario for load dataset",
                    "Unit": "" },
                   {"Name": "load_pq_set",
                    "Description": "scenario for load dataset",
                    "Unit": "" },
                   {"Name": "storage",
                    "Description": "scenario for storage dataset",
                    "Unit": "" },
                   {"Name": "storage_pq_set",
                    "Description": "scenario for storage dataset",
                    "Unit": "" },
                   {"Name": "temp_resolution",
                    "Description": "scenario for temp_resolution",
                    "Unit": "" },
                   {"Name": "transformer",
                    "Description": "scenario for transformer",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 

                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_scenario_settings' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_scenario_settings','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV source
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_source CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_source (
	source_id bigint NOT NULL,
	name text, -- Unit: n/a...
	co2_emissions double precision, -- Unit: tonnes/MWh...
	commentary text,
	CONSTRAINT source_data_pkey PRIMARY KEY (source_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_source IS
'{
"Name": "Sources hv powerflow ",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "ego_dp_powerflow_hv_setup.sql",
"Spatial resolution": ["Germany"],
"Description": ["Different generation types/sources considered in hv powerflow"],
"Column": [
                   {"Name": "source_id",
                    "Description": "unique source id",
                    "Unit": "" },
                   {"Name": "name",
                    "Description": "source name",
                    "Unit": "" },                   
                   {"Name": "co2_emissions",
                    "Description": "technology specific CO2 emissions ",
                    "Unit": "tonnes/MWh" },
                   {"Name": "commentary",
                    "Description": "...",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." },

                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" } 
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_source' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_source','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV bus
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_bus CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_bus (
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  bus_id bigint NOT NULL, -- Unit: n/a...
  v_nom double precision, -- Unit: kV...
  current_type text DEFAULT 'AC'::text, -- Unit: n/a...
  v_mag_pu_min double precision DEFAULT 0, -- Unit: per unit...
  v_mag_pu_max double precision, -- Unit: per unit...
  geom geometry(Point,4326),
  CONSTRAINT bus_data_pkey PRIMARY KEY (bus_id, scn_name) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_bus IS
'{
"Name": "hv powerflow bus",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "ego_dp_powerflow_hv_setup.sql",
"Spatial resolution": ["Germany"],
"Description": ["Bus considered in hv powerflow calculation"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "bus_id",
                    "Description": " unique id for bus, equivalent to id from osmtgmod",
                    "Unit": "" },
                   {"Name": "v_nom",
                    "Description": "nominal voltage",
                    "Unit": "kV" },
                   {"Name": "current_type",
                    "Description": "current type - AC or DC",
                    "Unit": "" },
                   {"Name": "v_mag_pu_min",
                    "Description": "Minimum desired voltage, per unit of v_nom",
                    "Unit": "per unit" },
                   {"Name": "v_mag_pu_max",
                    "Description": "Maximum desired voltage, per unit of v_nom",
                    "Unit": "per unit" },
                   {"Name": "geom",
                    "Description": "geometry of bus",
                    "Unit": "..." }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-String" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- PF HV busmap
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_busmap CASCADE;
CREATE TABLE model_draft.ego_grid_pf_hv_busmap (
	scn_name text,
	bus0 text,
	bus1 text,
	path_length numeric,
	PRIMARY KEY(scn_name, bus0, bus1));

COMMENT ON TABLE  model_draft.ego_grid_pf_hv_busmap IS
'{
"Name": "hv powerflow busmap",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2017
"Date of collection": ""
"Original file": "ego_dp_powerflow_hv_setup.sql",
"Spatial resolution": [""],
"Description": ["Bus to bus assignment by id to support PyPSA clustering."],
"Column": [
                   {"Name": "scn_name",
                    "Description": "name of scenario",
                    "Unit": "" },
                   {"Name": "bus0",
                    "Description": "source bus id",
                    "Unit": "" },
                   {"Name": "bus1",
                    "Description": "target bus id",
                    "Unit": "" },
                   {"Name": "path_length",
                    "Description": "Length of line between source and target bus.",
                    "Unit": "" }],
"Changes":[
                   {"Name": "s3pp",
                    "Mail": "",
                    "Date":  "02.06.2017",
                    "Comment": "Initial statement."}
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_bus' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_bus','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV generator
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_generator CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_generator (
	scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
	generator_id bigint NOT NULL, -- Unit: n/a...
	bus bigint, -- Unit: n/a...
	dispatch text DEFAULT 'flexible'::text, -- Unit: n/a...
	control text DEFAULT 'PQ'::text, -- Unit: n/a...
	p_nom double precision DEFAULT 0, -- Unit: MW...
	p_nom_extendable boolean DEFAULT false, -- Unit: n/a...
	p_nom_min double precision DEFAULT 0, -- Unit: MW...
	p_nom_max double precision, -- Unit: MW...
	p_min_pu_fixed double precision DEFAULT 0, -- Unit: per unit...
	p_max_pu_fixed double precision DEFAULT 1, -- Unit: per unit...
	sign double precision DEFAULT 1, -- Unit: n/a...
	source bigint, -- Unit: n/a...
	marginal_cost double precision, -- Unit: currency/MWh...
	capital_cost double precision, -- Unit: currency/MW...
	efficiency double precision, -- Unit: per unit...
	CONSTRAINT generator_data_pkey PRIMARY KEY (generator_id, scn_name),
	CONSTRAINT generator_data_source_fkey FOREIGN KEY (source) 
		REFERENCES model_draft.ego_grid_pf_hv_source (source_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_generator IS
'{
"Name": "Generator in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "ego_dp_powerflow_hv_setup.sql",
"Spatial resolution": ["Germany"],
"Description": ["Generators considered in hv powerflow"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "generator_id",
                    "Description": "unique id for generators",
                    "Unit": "" },                   
                   {"Name": "bus",
                    "Description": "id of associated bus",
                    "Unit": "" },
                   {"Name": "dispatch",
                    "Description": "Controllability of active power dispatch, must be flexible or variable.",
                    "Unit": "" },
                   {"Name": "control",
                    "Description": "P,Q,V control strategy, must be PQ, PV or Slack.",
                    "Unit": "" },
                   {"Name": "p_nom",
                    "Description": "Nominal power",
                    "Unit": "MW" },
                   {"Name": "p_nom_extendable",
                    "Description": "Switch to allow capacity p_nom to be extended",
                    "Unit": "" },
                   {"Name": "p_nom_min",
                    "Description": "If p_nom is extendable, set its minimum value",
                    "Unit": "" },
                   {"Name": "p_nom_max",
                    "Description": "If p_nom is extendable, set its maximum value (e.g. limited by potential)",
                    "Unit": "" },
                   {"Name": "p_min_pu_fixed",
                    "Description": "If control=flexible this gives the minimum output per unit of p_nom",
                    "Unit": "per unit" },
                   {"Name": "p_max_pu_fixed",
                    "Description": "If control=flexible this gives the maximum output per unit of p_nom, equivalent to a de-rating factor.",
                    "Unit": "per unit" },
                   {"Name": "sign",
                    "Description": "power sign",
                    "Unit": "" },
                   {"Name": "source",
                    "Description": "prime mover energy carrier",
                    "Unit": "" },
                   {"Name": "marginal_cost",
                    "Description": "Marginal cost of production of 1 MWh",
                    "Unit": "€/MWh" },
                   {"Name": "capital_cost",
                    "Description": "Capital cost of extending p_nom by 1 MW",
                    "Unit": "€/MW" },
                   {"Name": "efficiency",
                    "Description": "Ratio between primary energy and electrical energy",
                    "Unit": "per unit" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_generator' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_generator','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV line
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_line CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_line (
	scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
	line_id bigint NOT NULL, -- Unit: n/a...
	bus0 bigint, -- Unit: n/a...
	bus1 bigint, -- Unit: n/a...
	x numeric DEFAULT 0, -- Unit: Ohm...
	r numeric DEFAULT 0, -- Unit: Ohm...
	g numeric DEFAULT 0, -- Unit: Siemens...
	b numeric DEFAULT 0, -- Unit: Siemens...
	s_nom numeric DEFAULT 0, -- Unit: MVA...
	s_nom_extendable boolean DEFAULT false, -- Unit: n/a...
	s_nom_min double precision DEFAULT 0, -- Unit: MVA...
	s_nom_max double precision, -- Unit: MVA...
	capital_cost double precision, -- Unit: currency/MVA...
	length double precision, -- Unit: km...
	cables integer,
	frequency numeric,
	terrain_factor double precision DEFAULT 1, -- Unit: per unit...
	geom geometry(MultiLineString,4326),
	topo geometry(LineString,4326),
	CONSTRAINT line_data_pkey PRIMARY KEY (line_id, scn_name) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_line IS
'{
"Name": "Lines in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Electricity lines considered in hv powerflow calculations"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "line_id",
                    "Description": "unique identifier",
                    "Unit": "" },                   
                   {"Name": "bus0",
                    "Description": "Name of first bus to which branch is attached",
                    "Unit": "" },
                   {"Name": "bus1",
                    "Description": "Name of second bus to which branch is attached",
                    "Unit": "" },
                   {"Name": "x",
                    "Description": "Series reactance",
                    "Unit": "Ohm" },
                   {"Name": "r",
                    "Description": "Series resistance",
                    "Unit": "Ohm" },
                   {"Name": "g",
                    "Description": "Shunt conductivity",
                    "Unit": "Siemens" }, 
                   {"Name": "b",
                    "Description": "Shunt susceptance",
                    "Unit": "Siemens" }, 
                   {"Name": "s_nom",
                    "Description": "Limit of apparent power which can pass through branch",
                    "Unit": "MVA" }, 
                   {"Name": "s_nom_extendable",
                    "Description": "Switch to allow capacity s_nom to be extended",
                    "Unit": "" }, 
                   {"Name": "s_nom_min",
                    "Description": "If s_nom is extendable, set its minimum value",
                    "Unit": "MVA" }, 
                   {"Name": "s_nom_max",
                    "Description": "If s_nom is extendable in OPF, set its maximum value",
                    "Unit": "MVA" }, 
                   {"Name": "capital_cost",
                    "Description": "Capital cost of extending s_nom by 1 MVA",
                    "Unit": "€/MVA" }, 
                   {"Name": "length",
                    "Description": "Length of line",
                    "Unit": "km" }, 
                   {"Name": "cables",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "frequency",
                    "Description": "Frequency of line",
                    "Unit": "" }, 
                   {"Name": "terrain_factor",
                    "Description": "...",
                    "Unit": "" }, 
                   {"Name": "geom",
                    "Description": "geometry that depict the real route of the line",
                    "Unit": "" }, 
                   {"Name": "topo",
                    "Description": "topology that depicts a direct connection between both busses",
                    "Unit": "..." }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_line' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_line','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV load
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_load CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_load (
	scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
	load_id bigint NOT NULL, -- Unit: n/a...
	bus bigint, -- Unit: n/a...
	sign double precision DEFAULT (-1), -- Unit: n/a...
	e_annual double precision, -- Unit: MW...
	CONSTRAINT load_data_pkey PRIMARY KEY (load_id, scn_name) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_load IS
'{
"Name": "Load in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Loads considered in hv powerflow calculation"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "load_id",
                    "Description": "unique id",
                    "Unit": "" },                   
                   {"Name": "bus",
                    "Description": "id of associated bus",
                    "Unit": "" },
                   {"Name": "sign",
                    "Description": "power sign",
                    "Unit": "" },
                   {"Name": "e_annual",
                    "Description": "annual electricity consumption",
                    "Unit": "GWh" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_load' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_load','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV storage
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_storage CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_storage (
	scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
	storage_id bigint NOT NULL, -- Unit: n/a...
	bus bigint, -- Unit: n/a...
	dispatch text DEFAULT 'flexible'::text, -- Unit: n/a...
	control text DEFAULT 'PQ'::text, -- Unit: n/a...
	p_nom double precision DEFAULT 0, -- Unit: MW...
	p_nom_extendable boolean DEFAULT false, -- Unit: n/a...
	p_nom_min double precision DEFAULT 0, -- Unit: MW...
	p_nom_max double precision, -- Unit: MW...
	p_min_pu_fixed double precision DEFAULT 0, -- Unit: per unit...
	p_max_pu_fixed double precision DEFAULT 1, -- Unit: per unit...
	sign double precision DEFAULT 1, -- Unit: n/a...
	source bigint, -- Unit: n/a...
	marginal_cost double precision, -- Unit: currency/MWh...
	capital_cost double precision, -- Unit: currency/MW...
	efficiency double precision, -- Unit: per unit...
	soc_initial double precision, -- Unit: MWh...
	soc_cyclic boolean DEFAULT false, -- Unit: n/a...
	max_hours double precision, -- Unit: hours...
	efficiency_store double precision, -- Unit: per unit...
	efficiency_dispatch double precision, -- Unit: per unit...
	standing_loss double precision, -- Unit: per unit...
	CONSTRAINT storage_data_pkey PRIMARY KEY (storage_id, scn_name),
	CONSTRAINT storage_data_source_fkey FOREIGN KEY (source) 
		REFERENCES model_draft.ego_grid_pf_hv_source (source_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_storage IS
'{
"Name": "storage in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["storage units considered in hv powerflow calculations"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "storage_id",
                    "Description": "unique id",
                    "Unit": "" },
                   {"Name": "bus",
                    "Description": "id of associated bus",
                    "Unit": "" },
                   {"Name": "dispatch",
                    "Description": "Controllability of active power dispatch, must be flexible or variable",
                    "Unit": "" },
                   {"Name": "control",
                    "Description": "P,Q,V control strategy for PF, must be PQ, PV or Slack",
                    "Unit": "" },
                   {"Name": "p_nom",
                    "Description": "Nominal power",
                    "Unit": "MW" },
                   {"Name": "p_nom_extendable",
                    "Description": "Switch to allow capacity p_nom to be extended",
                    "Unit": "" },
                   {"Name": "p_nom_min",
                    "Description": "If p_nom is extendable in OPF, set its minimum value",
                    "Unit": "MW" },
                   {"Name": "p_nom_max",
                    "Description": "If p_nom is extendable in OPF, set its maximum value (e.g. limited by potential))",
                    "Unit": "MW" },
                   {"Name": "p_min_pu_fixed",
                    "Description": "If control=flexible this gives the minimum output per unit of p_nom for the OPF.",
                    "Unit": "per unit" },
                   {"Name": "p_max_pu_fixed",
                    "Description": "If control=flexible this gives the maximum output per unit of p_nom for the OPF, equivalent to a de-rating factor",
                    "Unit": "per unit" },
                   {"Name": "sign",
                    "Description": "power sign",
                    "Unit": "" },
                   {"Name": "source",
                    "Description": "Prime mover energy carrier",
                    "Unit": "" },
                   {"Name": "marginal_cost",
                    "Description": "Marginal cost of production of 1 MWh",
                    "Unit": "€/MWh" },
                   {"Name": "capital_cost",
                    "Description": "Capital cost of extending p_nom by 1 MW",
                    "Unit": "€/MW" },
                   {"Name": "efficiency",
                    "Description": "Ratio between primary energy and electrical energy",
                    "Unit": "per unit" },
                   {"Name": "soc_initial",
                    "Description": "State of charge before the snapshots in the OPF.",
                    "Unit": "MWh" },
                   {"Name": "soc_cyclic",
                    "Description": "Switch: if True, then state_of_charge_initial is ignored and the initial state of charge is set to the final state of charge for the group of snapshots in the OPF",
                    "Unit": "" },
                   {"Name": "max_hours",
                    "Description": "Maximum state of charge capacity in terms of hours at full output capacity p_nom",
                    "Unit": "hours" },
                   {"Name": "efficiency_store",
                    "Description": "Efficiency of storage on the way into the storage",
                    "Unit": "per unit" },                   
                   {"Name": "efficiency_dispatch",
                    "Description": "Efficiency of storage on the way out of the storage",
                    "Unit": "per unit" },
                   {"Name": "standing_loss",
                    "Description": "Losses per hour to state of charge",
                    "Unit": "per unit" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "Completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_storage' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_storage','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV temp resolution
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_temp_resolution CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_temp_resolution (
	temp_id bigint NOT NULL,
	timesteps bigint NOT NULL,
	resolution text, 
	start_time timestamp without time zone,
	CONSTRAINT temp_resolution_pkey PRIMARY KEY (temp_id) ) WITH ( OIDS=FALSE );

-- temp resolution
INSERT INTO model_draft.ego_grid_pf_hv_temp_resolution (temp_id, timesteps, resolution, start_time)
SELECT 1, 8760, 'h', TIMESTAMP '2011-01-01 00:00:00';

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_temp_resolution IS
'{
"Name": "temporal resolution hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "ego_dp_powerflow_hv_setup.sql",
"Spatial resolution": ["Germany"],
"Description": ["Temporal resolution of hv powerflow"],
"Column": [
                   {"Name": "temp_id",
                    "Description": "unique id",
                    "Unit": "" },
                   {"Name": "timesteps",
                    "Description": "timestep",
                    "Unit": "" },
                   {"Name": "resolution",
                    "Description": "temporal resolution",
                    "Unit": "" },
                   {"Name": "start_time",
                    "Description": "start time with style: YYYY-MM-DD HH:MM:SS",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." },
                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_temp_resolution' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_temp_resolution','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV transformer
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_transformer CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_transformer (
	scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
	trafo_id bigint NOT NULL, -- Unit: n/a...
	bus0 bigint, -- Unit: n/a...
	bus1 bigint, -- Unit: n/a...
	x numeric DEFAULT 0, -- Unit: Ohm...
	r numeric DEFAULT 0, -- Unit: Ohm...
	g numeric DEFAULT 0, -- Unit: Siemens...
	b numeric DEFAULT 0, -- Unit: Siemens...
	s_nom double precision DEFAULT 0, -- Unit: MVA...
	s_nom_extendable boolean DEFAULT false, -- Unit: n/a...
	s_nom_min double precision DEFAULT 0, -- Unit: MVA...
	s_nom_max double precision, -- Unit: MVA...
	tap_ratio double precision, -- Unit: 1...
	phase_shift double precision, -- Unit: Degrees...
	capital_cost double precision DEFAULT 0, -- Unit: currency/MVA...
	geom geometry(MultiLineString,4326),
	topo geometry(LineString,4326),
	CONSTRAINT transformer_data_pkey PRIMARY KEY (trafo_id, scn_name) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_transformer IS
'{
"Name": "Transformer in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "ego_dp_powerflow_hv_setup.sql",
"Spatial resolution": ["Germany"],
"Description": ["Transformer converts from one AC voltage level to another"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "trafo_id",
                    "Description": "unique id",
                    "Unit": "" },
                   {"Name": "bus0",
                    "Description": "Name of first bus to which branch is attached",
                    "Unit": "" },
                   {"Name": "bus1",
                    "Description": "Name of second bus to which branch is attached",
                    "Unit": "" },
                   {"Name": "x",
                    "Description": "Series reactance",
                    "Unit": "Ohm" },
                   {"Name": "r",
                    "Description": "Series resistance",
                    "Unit": "Ohm" },
                   {"Name": "g",
                    "Description": "Shunt conductivity",
                    "Unit": "Siemens" }, 
                   {"Name": "b",
                    "Description": "Shunt susceptance",
                    "Unit": "Siemens" }, 
                   {"Name": "s_nom",
                    "Description": "Limit of apparent power which can pass through branch",
                    "Unit": "MVA" }, 
                   {"Name": "s_nom_extendable",
                    "Description": "Switch to allow capacity s_nom to be extended",
                    "Unit": "" }, 
                   {"Name": "s_nom_min",
                    "Description": "If s_nom is extendable, set its minimum value",
                    "Unit": "MVA" }, 
                   {"Name": "s_nom_max",
                    "Description": "If s_nom is extendable in OPF, set its maximum value",
                    "Unit": "MVA" }, 
                   {"Name": "tap_ratio",
                    "Description": "Ratio of per unit voltages at each bus",
                    "Unit": "" },
                   {"Name": "phase_shift",
                    "Description": "Voltage phase angle shift",
                    "Unit": "degrees" },
                   {"Name": "capital_cost",
                    "Description": "Capital cost of extending s_nom by 1 MVA",
                    "Unit": "€/MVA" },
                   {"Name": "geom",
                    "Description": "geometry",
                    "Unit": "" },
                   {"Name": "topo",
                    "Description": "topology",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 

                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_transformer' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_transformer','ego_dp_powerflow_hv_setup.sql',' ');


--------------------------------------------------------------------
---------------------- Time series tables --------------------------
--------------------------------------------------------------------

-- PF HV mag set
DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_bus_v_mag_set CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_bus_v_mag_set (
	scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
	bus_id bigint NOT NULL,
	temp_id integer NOT NULL,
	v_mag_pu_set double precision[], -- Unit: per unit...
	CONSTRAINT bus_v_mag_set_pkey PRIMARY KEY (bus_id, temp_id, scn_name),
	CONSTRAINT bus_v_mag_set_temp_fkey FOREIGN KEY (temp_id) 
		REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_bus_v_mag_set IS
'{
"Name": "...",
"Source": [{ 	  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["..."],
"Column": [
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "bus_id",
                    "Description": "unique id of sorresponding bus",
                    "Unit": "" },
                   {"Name": "temp_id",
                    "Description": "id of temporal resolution",
                    "Unit": "" },
                   {"Name": "v_mag_pu_set",
                    "Description": "Voltage magnitude set point, per unit of v_nom",
                    "Unit": "per unit" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." },
                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_bus_v_mag_set' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_bus_v_mag_set','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV generator PQ set
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_generator_pq_set CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_generator_pq_set (
	scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
	generator_id bigint NOT NULL,
	temp_id integer NOT NULL,
	p_set double precision[], -- Unit: MW...
	q_set double precision[], -- Unit: MVar...
	p_min_pu double precision[], -- Unit: per unit...
	p_max_pu double precision[], -- Unit: per unit...
	CONSTRAINT generator_pq_set_pkey PRIMARY KEY (generator_id, temp_id, scn_name),
	CONSTRAINT generator_pq_set_temp_fkey FOREIGN KEY (temp_id) 
		REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_generator_pq_set IS
'{
"Name": "Generator time series hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Times series for generators considered in hv powerflow"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "generator_id",
                    "Description": "id of considered generator",
                    "Unit": "" },                   
                   {"Name": "temp_id",
                    "Description": "id of temporal resolution",
                    "Unit": "" },
                   {"Name": "p_set",
                    "Description": "active power set point",
                    "Unit": "MW" },
                   {"Name": "q_set",
                    "Description": "reactive power set point",
                    "Unit": "MVar" },
                   {"Name": "p_min_pu",
                    "Description": "If control=variable this gives the minimum output for each snapshot per unit of p_nom for the OPF",
                    "Unit": "per unit" },
                   {"Name": "p_max_pu",
                    "Description": "If control=variable this gives the maximum output for each snapshot per unit of p_nom for the OPF, relevant e.g. if for renewables the power output is limited by the weather",
                    "Unit": "per unit" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_generator_pq_set' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_generator_pq_set','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV load PQ set
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_load_pq_set CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_load_pq_set (
	scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
	load_id bigint NOT NULL,
	temp_id integer NOT NULL,
	p_set double precision[], -- Unit: MW...
	q_set double precision[], -- Unit: MVar...
	CONSTRAINT load_pq_set_pkey PRIMARY KEY (load_id, temp_id, scn_name),
	CONSTRAINT load_pq_set_temp_fkey FOREIGN KEY (temp_id) 
		REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_load_pq_set IS
'{
"Name": "Load time series hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Times series for loads considered in hv powerflow"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "load_id",
                    "Description": "unique load id",
                    "Unit": "" },                   
                   {"Name": "temp_id",
                    "Description": "id of temporal resolution",
                    "Unit": "" },
                   {"Name": "p_set",
                    "Description": "active power set point",
                    "Unit": "MW" },
                   {"Name": "q_set",
                    "Description": "reactive power set point",
                    "Unit": "MVar" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
		    {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_load_pq_set' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_load_pq_set','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV storage PQ set
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_storage_pq_set CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_storage_pq_set (
	scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
	storage_id bigint NOT NULL,
	temp_id integer NOT NULL,
	p_set double precision[], -- Unit: MW...
	q_set double precision[], -- Unit: MVar...
	p_min_pu double precision[], -- Unit: per unit...
	p_max_pu double precision[], -- Unit: per unit...
	soc_set double precision[], -- Unit: MWh...
	inflow double precision[], -- Unit: MW...
	CONSTRAINT storage_pq_set_pkey PRIMARY KEY (storage_id, temp_id, scn_name),
	CONSTRAINT storage_pq_set_temp_fkey FOREIGN KEY (temp_id) 
		REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_storage_pq_set IS
'{
"Name": "Storage time series hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Times series for storage units considered in hv powerflow"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "storage_id",
                    "Description": "unique storage id",
                    "Unit": "" },
                   {"Name": "temp_id",
                    "Description": "id for temporal resolution",
                    "Unit": "" },
                   {"Name": "p_set",
                    "Description": "active power set point",
                    "Unit": "MW" },
                   {"Name": "q_set",
                    "Description": "reactive power set point",
                    "Unit": "MVar" },
                   {"Name": "p_min_pu",
                    "Description": "If control=variable this gives the minimum output for each snapshot per unit of p_nom for the OPF",
                    "Unit": "per unit" },
                   {"Name": "p_max_pu",
                    "Description": "If control=variable this gives the maximum output for each snapshot per unit of p_nom for the OPF",
                    "Unit": "per unit" },
                   {"Name": "soc_set",
                    "Description": "State of charge set points for snapshots in the OPF",
                    "Unit": "MWh" },
                   {"Name": "inflow",
                    "Description": "Inflow to the state of charge, e.g. due to river inflow in hydro reservoir",
                    "Unit": "MW" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
                    {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_storage_pq_set' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_storage_pq_set','ego_dp_powerflow_hv_setup.sql',' ');

---------------------------------------------------------------
---------------------- Result tables --------------------------
---------------------------------------------------------------
-- PF HV results meta
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_meta CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_meta (
	result_id bigint NOT NULL,
	scn_name character varying,
	calc_date timestamp without time zone,
	method character varying,
	network_clustering boolean,
	gridversion character varying,
	start_h integer,
	end_h integer,
	solver character varying,
	branch_cap_factor double precision,
	storage_extendable boolean,
	load_shedding boolean,
	generator_noise boolean,
	commentary character varying,
	CONSTRAINT result_meta_pkey PRIMARY KEY (result_id)) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_meta IS
'{
"Name": "Results meta data of hv powerflow calculations",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Meta data for results of hv powerflow calculations"],
"Column": [		   {"Name": "result_id",
                    "Description": "Result ID",
                    "Unit": "" },
                   {"Name": "scn_name",
                    "Description": "scenario name",
                    "Unit": "" },
                   {"Name": "calc_date",
                    "Description": "Datetime of calculation start",
                    "Unit": "Datetime" },
				   {"Name": "calc_type",
                    "Description": "Type of powerflow calculation (pf/lopf/lpf)",
                    "Unit": "" },
				   {"Name": "commentary",
                    "Description": "Comment on the result data set",
                    "Unit": ""}],
"Changes":["..."],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_meta' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_meta','ego_dp_powerflow_hv_setup.sql',' ');

-- PF HV bus results
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_bus CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_bus (
  result_id bigint NOT NULL,
  bus_id bigint NOT NULL, -- Unit: n/a...
  v_nom double precision,
  current_type text,
  v_mag_pu_min double precision,
  v_mag_pu_max double precision,
  p double precision[],
  q double precision[],
  v_mag_pu double precision[],
  v_ang double precision[],
  marginal_price double precision[],
  geom geometry(Point,4326),
  CONSTRAINT bus_data_result_pkey PRIMARY KEY (result_id, bus_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_bus IS
'{
"Name": "hv powerflow bus result",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "ego_dp_powerflow_hv_setup.sql",
"Spatial resolution": ["Germany"],
"Description": ["Results of bus considered in hv powerflow calculation"],
"Column": [
                   {"Name": "result_id",
                    "Description": "Result ID",
                    "Unit": "" },
                   {"Name": "bus_id",
                    "Description": "unique id for bus, equivalent to id from osmtgmod",
                    "Unit": "" },
                   {"Name": "p",
                    "Description": "active power at bus (positive if net generation at bus)",
                    "Unit": "MW" },
				   {"Name": "q",
                    "Description": "reactive power (positive if net generation at bus)",
                    "Unit": "MVar" },
				   {"Name": "v_mag_pu",
                    "Description": "Voltage magnitude, per unit of v_nom",
                    "Unit": "per unit" },
				   {"Name": "v_ang",
                    "Description": "Voltage angle",
                    "Unit": "radians" },
				   {"Name": "marginal_price",
                    "Description": "Locational marginal price from LOPF from power balance constraint",
                    "Unit": "currency" }
					],
					
"Changes":["..."],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_bus' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_bus','ego_dp_powerflow_hv_setup.sql',' ');

-- PF HV generator results

DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_generator CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_generator (
	result_id bigint NOT NULL,
	generator_id bigint NOT NULL,
	bus bigint,
	dispatch text,
	control text,
	p_nom double precision,
	p_nom_extendable boolean, 
	p_nom_min double precision,
	p_nom_max double precision,
	p_min_pu_fixed double precision,
	p_max_pu_fixed double precision,
	sign double precision,
	source bigint,
	marginal_cost double precision,
	capital_cost double precision,
	efficiency double precision,
	p double precision[],
	q double precision[],
	p_nom_opt double precision,
	status bigint[],
	CONSTRAINT generator_data_result_pkey PRIMARY KEY (result_id, generator_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_generator IS
'{
"Name": "hv powerflow generator results",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "ego_dp_powerflow_hv_setup.sql",
"Spatial resolution": ["Germany"],
"Description": ["Results of generators considered in hv powerflow"],
"Column": [		   {"Name": "result_id",
                    "Description": "Result ID",
                    "Unit": "" },
                   {"Name": "generator_id",
                    "Description": "unique id for generators",
                    "Unit": "" },  
                   {"Name": "p",
                    "Description": "active power at bus (positive if net generation at bus)",
                    "Unit": "MW" },
				   {"Name": "q",
                    "Description": "reactive power (positive if net generation at bus)",
                    "Unit": "MVar" },
				   {"Name": "p_nom_opt",
                    "Description": "Optimised nominal power.",
                    "Unit": "MW" },
				   {"Name": "status",
                    "Description": "Status (1 is on, 0 is off). Only outputted if committable is True.",
                    "Unit": "" }
                   ],
"Changes":["..."],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_generator' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_generator','ego_dp_powerflow_hv_setup.sql',' ');

-- PF HV line results
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_line CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_line (
	result_id bigint NOT NULL,
	line_id bigint NOT NULL,
	bus0 bigint, -- Unit: n/a...
	bus1 bigint, -- Unit: n/a...
	x numeric, -- Unit: Ohm...
	r numeric, -- Unit: Ohm...
	g numeric, -- Unit: Siemens...
	b numeric, -- Unit: Siemens...
	s_nom numeric, -- Unit: MVA...
	s_nom_extendable boolean, -- Unit: n/a...
	s_nom_min double precision, -- Unit: MVA...
	s_nom_max double precision, -- Unit: MVA...
	capital_cost double precision, -- Unit: currency/MVA...
	length double precision, -- Unit: km...
	cables integer,
	frequency numeric,
	terrain_factor double precision DEFAULT 1,
	p0 double precision[],
	q0 double precision[],
	p1 double precision[],
	q1 double precision[],
	x_pu numeric, -- Unit: Ohm...
	r_pu numeric, -- Unit: Ohm...
	g_pu numeric, -- Unit: Siemens...
	b_pu numeric, -- Unit: Siemens...
	s_nom_opt numeric, -- Unit: MVA...
	geom geometry(MultiLineString,4326),
	topo geometry(LineString,4326),
	CONSTRAINT line_data_result_pkey PRIMARY KEY (result_id, line_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_line IS
'{
"Name": "Result of lines in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": [" Results of electricity lines considered in hv powerflow calculations"],
"Column": [		   {"Name": "result_id",
                    "Description": "Result ID",
                    "Unit": "" },
                   {"Name": "line_id",
                    "Description": "unique identifier",
                    "Unit": "" },
				   {"Name": "p0",
                    "Description": "active power at bus0 (positive if net generation at bus0)",
                    "Unit": "MW" },
				   {"Name": "q0",
                    "Description": "Reactive power at bus0 (positive if branch is withdrawing power from bus0).",
                    "Unit": "MVar" },	
				   {"Name": "p1",
                    "Description": "active power at bus1 (positive if net generation at bus1)",
                    "Unit": "MW" },
				   {"Name": "q1",
                    "Description": "Reactive power at bus1 (positive if branch is withdrawing power from bus1).",
                    "Unit": "MVar" },					
                   {"Name": "x_pu",
                    "Description": "Per unit series reactance calculated by PyPSA from x and bus.v_nom.",
                    "Unit": "per unit" },
                   {"Name": "r_pu",
                    "Description": "Per unit series resistance calculated by PyPSA from r and bus.v_nom",
                    "Unit": "per unit" },
                   {"Name": "g_pu",
                    "Description": "Per unit shunt conductivity calculated by PyPSA from g and bus.v_nom",
                    "Unit": "per unit" }, 
                   {"Name": "b_pu",
                    "Description": "Per unit shunt susceptance calculated by PyPSA from b and bus.v_nom",
                    "Unit": "per unit" }, 
                   {"Name": "s_nom_opt",
                    "Description": "Optimised capacity for apparent power.",
                    "Unit": "MVA" }],
"Changes":["..."],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_line' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_line','ego_dp_powerflow_hv_setup.sql',' ');

-- PF HV storage results
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_storage CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_storage (
	result_id bigint NOT NULL,
	storage_id bigint NOT NULL, -- Unit: n/a...
	bus bigint, -- Unit: n/a...
	dispatch text, -- Unit: n/a...
	control text, -- Unit: n/a...
	p_nom double precision, -- Unit: MW...
	p_nom_extendable boolean, -- Unit: n/a...
	p_nom_min double precision, -- Unit: MW...
	p_nom_max double precision, -- Unit: MW...
	p_min_pu_fixed double precision, -- Unit: per unit...
	p_max_pu_fixed double precision, -- Unit: per unit...
	sign double precision, -- Unit: n/a...
	source bigint, -- Unit: n/a...
	marginal_cost double precision, -- Unit: currency/MWh...
	capital_cost double precision, -- Unit: currency/MW...
	efficiency double precision, -- Unit: per unit...
	soc_initial double precision, -- Unit: MWh...
	soc_cyclic boolean DEFAULT false, -- Unit: n/a...
	max_hours double precision, -- Unit: hours...
	efficiency_store double precision, -- Unit: per unit...
	efficiency_dispatch double precision, -- Unit: per unit...
	standing_loss double precision,
	p double precision[],
	q double precision[],
	state_of_charge double precision[],
	spill double precision[],
	p_nom_opt double precision,
	CONSTRAINT storage_data_result_pkey PRIMARY KEY (result_id, storage_id)) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_storage IS
'{
"Name": " Result of storage in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["results of storage units considered in hv powerflow calculations"],
"Column": [		   {"Name": "result_id",
                    "Description": "Result ID",
                    "Unit": "" },
                   {"Name": "storage_id",
                    "Description": "unique id",
                    "Unit": "" },
				   {"Name": "p",
                    "Description": "active power at bus (positive if net generation at bus)",
                    "Unit": "MW" },
				   {"Name": "q",
                    "Description": "reactive power (positive if net generation at bus)",
                    "Unit": "MVar" },
				   {"Name": "state_of_charge",
                    "Description": "State of charge as calculated by the OPF.",
                    "Unit": "MWh" },
				   {"Name": "spill",
                    "Description": "Spillage for each snapshot.",
                    "Unit": "MW" },
				   {"Name": "p_nom_opt",
                    "Description": "Optimised nominal power.",
                    "Unit": "MW" }
                  ],
"Changes":["..."],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_storage' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_storage','ego_dp_powerflow_hv_setup.sql',' ');

-- PF HV transformer results

DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_transformer CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_transformer (
	result_id bigint NOT NULL,
	trafo_id bigint NOT NULL, -- Unit: n/a...
	bus0 bigint, -- Unit: n/a...
	bus1 bigint, -- Unit: n/a...
	x numeric, -- Unit: Ohm...
	r numeric, -- Unit: Ohm...
	g numeric, -- Unit: Siemens...
	b numeric, -- Unit: Siemens...
	s_nom numeric, -- Unit: MVA...
	s_nom_extendable boolean, -- Unit: n/a...
	s_nom_min double precision, -- Unit: MVA...
	s_nom_max double precision, -- Unit: MVA...
	tap_ratio double precision, -- Unit: 1...
	phase_shift double precision, -- Unit: Degrees...
	capital_cost double precision,
	p0 double precision[],
	q0 double precision[],
	p1 double precision[],
	q1 double precision[],
	x_pu numeric, -- Unit: Ohm...
	r_pu numeric, -- Unit: Ohm...
	g_pu numeric, -- Unit: Siemens...
	b_pu numeric, -- Unit: Siemens...
	s_nom_opt numeric, -- Unit: MVA...
	geom geometry(MultiLineString,4326),
	topo geometry(LineString,4326),
	CONSTRAINT transformer_data_result_pkey PRIMARY KEY (result_id, trafo_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_transformer IS
'{
"Name": "Transformer in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "ego_dp_powerflow_hv_setup.sql",
"Spatial resolution": ["Germany"],
"Description": ["Transformer converts from one AC voltage level to another"],
"Column": [		   {"Name": "result_id",
                    "Description": "Result ID",
                    "Unit": "" },
                   {"Name": "trafo_id",
                    "Description": "unique id",
                    "Unit": "" },
                   {"Name": "p0",
                    "Description": "active power at bus0 (positive if net generation at bus0)",
                    "Unit": "MW" },
				   {"Name": "q0",
                    "Description": "Reactive power at bus0 (positive if branch is withdrawing power from bus0).",
                    "Unit": "MVar" },	
				   {"Name": "p1",
                    "Description": "active power at bus1 (positive if net generation at bus1)",
                    "Unit": "MW" },
				   {"Name": "q1",
                    "Description": "Reactive power at bus1 (positive if branch is withdrawing power from bus1).",
                    "Unit": "MVar" },					
                   {"Name": "x_pu",
                    "Description": "Per unit series reactance calculated by PyPSA from x and bus.v_nom.",
                    "Unit": "per unit" },
                   {"Name": "r_pu",
                    "Description": "Per unit series resistance calculated by PyPSA from r and bus.v_nom",
                    "Unit": "per unit" },
                   {"Name": "g_pu",
                    "Description": "Per unit shunt conductivity calculated by PyPSA from g and bus.v_nom",
                    "Unit": "per unit" }, 
                   {"Name": "b_pu",
                    "Description": "Per unit shunt susceptance calculated by PyPSA from b and bus.v_nom",
                    "Unit": "per unit" }, 
                   {"Name": "s_nom_opt",
                    "Description": "Optimised capacity for apparent power.",
                    "Unit": "MVA" }],
"Changes":["..."],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_transformer' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_transformer','ego_dp_powerflow_hv_setup.sql',' ');


-------------------------------------------------------------------
--------------------------- Grant rights --------------------------
-------------------------------------------------------------------

ALTER TABLE model_draft.ego_grid_pf_hv_bus
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_bus TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_bus_v_mag_set
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_bus_v_mag_set TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_generator
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_generator TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_generator_pq_set
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_generator_pq_set TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_line
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_line TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_load
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_load TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_load_pq_set
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_load_pq_set TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_scenario_settings
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_scenario_settings TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_source
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_source TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_storage
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_storage TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_storage_pq_set
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_storage_pq_set TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_temp_resolution
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_temp_resolution TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_transformer
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_transformer TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_busmap
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_busmap TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_bus
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_bus TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_generator
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_generator TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_line
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_line TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_storage
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_storage TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_transformer
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_transformer TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_meta
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_meta TO oeuser;

-------------------------------------------------------------------
----------------------------- Comments ----------------------------
-------------------------------------------------------------------
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_bus.bus_id IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_bus.v_nom IS 'Unit: kV
Description: Nominal voltage
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_bus.current_type IS 'Unit: n/a
Description: Type of current (must be either "AC" or "DC").
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_bus.v_mag_pu_min IS 'Unit: per unit
Description: Minimum desired voltage, per unit of v_nom
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_bus.v_mag_pu_max IS 'Unit: per unit
Description: Maximum desired voltage, per unit of v_nom
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_bus_v_mag_set.v_mag_pu_set IS 'Unit: per unit
Description: Voltage magnitude set point, per unit of v_nom.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.generator_id IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.bus IS 'Unit: n/a
Description: name of bus to which generator is attached
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.dispatch IS 'Unit: n/a
Description: Controllability of active power dispatch, must be flexible or variable.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.control IS 'Unit: n/a
Description: P,Q,V control strategy for PF, must be PQ, PV or Slack.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.p_nom IS 'Unit: MW
Description: Nominal power for limits in OPF
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.p_nom_extendable IS 'Unit: n/a
Description: Switch to allow capacity p_nom to be extended in OPF.
Default: False
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.p_nom_min IS 'Unit: MW
Description: If p_nom is extendable in OPF, set its minimum value.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.p_nom_max IS 'Unit: MW
Description: If p_nom is extendable in OPF, set its maximum value (e.g. limited by potential).
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.p_min_pu_fixed IS 'Unit: per unit
Description: If control=flexible this gives the minimum output per unit of p_nom for the OPF.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.p_max_pu_fixed IS 'Unit: per unit
Description: If control=flexible this gives the maximum output per unit of p_nom for the OPF, equivalent to a de-rating factor.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.sign IS 'Unit: n/a
Description: power sign
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.source IS 'Unit: n/a
Description: Prime mover (e.g. coal, gas, wind, solar); required for CO2 calculation in OPF
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.marginal_cost IS 'Unit: currency/MWh
Description: Marginal cost of production of 1 MWh.	
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.capital_cost IS 'Unit: currency/MW
Description: Capital cost of extending p_nom by 1 MW.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.efficiency IS 'Unit: per unit
Description: Ratio between primary energy and electrical energy, e.g. takes value 0.4 for gas. This is important for determining CO2 emissions per MWh.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator_pq_set.p_set IS 'Unit: MW
Description: active power set point (for PF).
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator_pq_set.q_set IS 'Unit: MVar
Description: reactive power set point (for PF).
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator_pq_set.p_min_pu IS 'Unit: per unit
Description: If control=variable this gives the minimum output for each snapshot per unit of p_nom for the OPF.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator_pq_set.p_max_pu IS 'Unit: per unit
Description: If control=variable this gives the maximum output for each snapshot per unit of p_nom for the OPF, relevant e.g. if for renewables the power output is limited by the weather.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.line_id IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.bus0 IS 'Unit: n/a
Description: Name of first bus to which branch is attached. 
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.bus1 IS 'Unit: n/a
Description: Name of second bus to which branch is attached.
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.x IS 'Unit: Ohm
Description: series reactance; must be non-zero for AC branch in linear power flow; in non-linear power flow x+jr must be non-zero.
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.r IS 'Unit: Ohm
Description: Series resistance; must be non-zero for DC branch in linear power flow; in non-linear power flow x+jr must be non-zero.
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.g IS 'Unit: Siemens
Description: Shunt conductivity.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.b IS 'Unit: Siemens
Description: Shunt susceptance.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.s_nom IS 'Unit: MVA
Description: Limit of apparent power which can pass through branch.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.s_nom_extendable IS 'Unit: n/a
Description: Switch to allow capacity s_nom to be extended in OPF.
Default: False
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.s_nom_min IS 'Unit: MVA
Description: If s_nom is extendable in OPF, set its minimum value.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.s_nom_max IS 'Unit: MVA
Description: If s_nom is extendable in OPF, set its maximum value (e.g. limited by potential).
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.capital_cost IS 'Unit: currency/MVA
Description: Capital cost of extending s_nom by 1 MVA.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.length IS 'Unit: km
Description: Length of line, useful for calculating the capital cost.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_line.terrain_factor IS 'Unit: per unit
Description: Terrain factor for increasing capital cost.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_load.load_id IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_load.bus IS 'Unit: n/a
Description: Name of bus to which load is attached.
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_load.sign IS 'Unit: n/a
Description: power sign
Default: -1
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_load.e_annual IS 'Unit: MW
Description: 
Status: Input (not needd for PyPSA)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_load_pq_set.p_set IS 'Unit: MW
Description: Active power consumption (positive if the load is consuming power).
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_load_pq_set.q_set IS 'Unit: MVar
Description: 	Reactive power consumption (positive if the load is inductive).
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_source.name IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_source.co2_emissions IS 'Unit: tonnes/MWh
Description: Emissions in CO2-tonnes-equivalent per MWh of primary energy (e.g. has has 0.2 tonnes/MWh_thermal).
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.storage_id IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.bus IS 'Unit: n/a
Description: name of bus to which storage is attached
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.dispatch IS 'Unit: n/a
Description: Controllability of active power dispatch, must be flexible or variable.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.control IS 'Unit: n/a
Description: P,Q,V control strategy for PF, must be PQ, PV or Slack.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.p_nom IS 'Unit: MW
Description: Nominal power for limits in OPF
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.p_nom_extendable IS 'Unit: n/a
Description: Switch to allow capacity p_nom to be extended in OPF.
Default: False
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.p_nom_min IS 'Unit: MW
Description: If p_nom is extendable in OPF, set its minimum value.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.p_nom_max IS 'Unit: MW
Description: If p_nom is extendable in OPF, set its maximum value (e.g. limited by potential).
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.p_min_pu_fixed IS 'Unit: per unit
Description: If control=flexible this gives the minimum output per unit of p_nom for the OPF.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.p_max_pu_fixed IS 'Unit: per unit
Description: If control=flexible this gives the maximum output per unit of p_nom for the OPF, equivalent to a de-rating factor.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.sign IS 'Unit: n/a
Description: power sign
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.source IS 'Unit: n/a
Description: Prime mover (e.g. coal, gas, wind, solar); required for CO2 calculation in OPF
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.marginal_cost IS 'Unit: currency/MWh
Description: Marginal cost of production of 1 MWh.	
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.capital_cost IS 'Unit: currency/MW
Description: Capital cost of extending p_nom by 1 MW.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.efficiency IS 'Unit: per unit
Description: Ratio between primary energy and electrical energy, e.g. takes value 0.4 for gas. This is important for determining CO2 emissions per MWh.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.soc_initial IS 'Unit: MWh
Description: State of charge before the snapshots in the OPF.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.soc_cyclic IS 'Unit: n/a
Description: Switch: if True, then state_of_charge_initial is ignored and the initial state of charge is set to the final state of charge for the group of snapshots in the OPF.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.max_hours IS 'Unit: hours
Description: Maximum state of charge capacity in terms of hours at full output capacity p_nom
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.efficiency_store IS 'Unit: per unit
Description: Efficiency of storage on the way into the storage.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.efficiency_dispatch IS 'Unit: per unit
Description: Efficiency of storage on the way out of the storage.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.standing_loss IS 'Unit: per unit
Description: Losses per hour to state of charge.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage_pq_set.p_set IS 'Unit: MW
Description: active power set point (for PF).
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage_pq_set.q_set IS 'Unit: MVar
Description: reactive power set point (for PF).
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage_pq_set.p_min_pu IS 'Unit: per unit
Description: If control=variable this gives the minimum output for each snapshot per unit of p_nom for the OPF.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage_pq_set.p_max_pu IS 'Unit: per unit
Description: If control=variable this gives the maximum output for each snapshot per unit of p_nom for the OPF, relevant e.g. if for renewables the power output is limited by the weather.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage_pq_set.soc_set IS 'Unit: MWh
Description: State of charge set points for snapshots in the OPF.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage_pq_set.inflow IS 'Unit: MW
Description: Inflow to the state of charge, e.g. due to river inflow in hydro reservoir.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_temp_resolution.resolution IS 'example: h, 15min...';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_temp_resolution.start_time IS 'style: YYYY-MM-DD HH:MM:SS';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.trafo_id IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.bus0 IS 'Unit: n/a
Description: Name of first bus to which branch is attached. 
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.bus1 IS 'Unit: n/a
Description: Name of second bus to which branch is attached.
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.x IS 'Unit: Ohm
Description: eries reactance; must be non-zero for AC branch in linear power flow; in non-linear power flow x+jr must be non-zero.
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.r IS 'Unit: Ohm
Description: Series resistance; must be non-zero for DC branch in linear power flow; in non-linear power flow x+jr must be non-zero.
Status: Input (required)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.g IS 'Unit: Siemens
Description: Shunt conductivity.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.b IS 'Unit: Siemens
Description: Shunt susceptance.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.s_nom IS 'Unit: MVA
Description: Limit of apparent power which can pass through branch.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.s_nom_extendable IS 'Unit: n/a
Description: Switch to allow capacity s_nom to be extended in OPF.
Default: False
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.s_nom_min IS 'Unit: MVA
Description: If s_nom is extendable in OPF, set its minimum value.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.s_nom_max IS 'Unit: MVA
Description: If s_nom is extendable in OPF, set its maximum value (e.g. limited by potential).
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.tap_ratio IS 'Unit: 1
Description: Ratio of per unit voltages at each bus.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.phase_shift IS 'Unit: Degrees
Description: Voltage phase angle shift.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_transformer.capital_cost IS 'Unit: currency/MVA
Description: Capital cost of extending s_nom by 1 MVA.
Status: Input (optional)';

-------------------------------------------------------------------
----------------------------- INDEXING ----------------------------
-------------------------------------------------------------------

CREATE INDEX fki_generator_data_source_fk
  ON model_draft.ego_grid_pf_hv_generator
  USING btree
  (source);
  
CREATE INDEX fki_storage_data_source_fk
  ON model_draft.ego_grid_pf_hv_storage
  USING btree
  (source);
  
 CREATE INDEX fki_trafo_data_bus0_fk
  ON model_draft.ego_grid_pf_hv_transformer
  USING btree
  (bus0);
  
 CREATE INDEX fki_trafo_data_bus1_fk
  ON model_draft.ego_grid_pf_hv_transformer
  USING btree
  (bus1);

-------------------------------------------------------------------
--------------------- FILL SOURCES TABLE --------------------------
-------------------------------------------------------------------
  
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (1, 'gas', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (2, 'lignite', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (3, 'waste', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (4, 'oil', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (5, 'uranium', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (6, 'biomass', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (7, 'eeg_gas', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (8, 'coal', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (9, 'run_of_river', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (10, 'reservoir', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (11, 'pumped_storage', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (12, 'solar', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (13, 'wind', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (14, 'geothermal', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (15, 'other_non_renewable', NULL, NULL);
INSERT INTO model_draft.ego_grid_pf_hv_source VALUES (16, 'extendable_storage', NULL, NULL);
