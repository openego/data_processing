---------------------------------------------------------------
---------------------- Result tables --------------------------
---------------------------------------------------------------
-- PF HV results meta
--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_meta CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_meta (
  result_id bigint NOT NULL,
  scn_name character varying,
  calc_date timestamp without time zone,
  user_name character varying,
  method character varying,
  start_snapshot integer,
  end_snapshot integer,
  snapshots timestamp without time zone[],
  solver character varying,
  safe_results boolean DEFAULT FALSE,
  settings json,
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
                    "Description": "Scenario name",
                    "Unit": "" },
                   {"Name": "calc_date",
                    "Description": "Datetime of calculation start",
                    "Unit": "Datetime" },
                   {"Name": "user_name",
                    "Description": "Name of user who uploaded the results",
                    "Unit": "" },
				   {"Name": "method",
                    "Description": "Type of powerflow calculation (pf/lopf/lpf)",
                    "Unit": "" },
				   {"Name": "start_step",
                    "Description": "Start step of calculation range",
                    "Unit": "" },
				   {"Name": "end_step",
                    "Description": "End step of calculation range",
                    "Unit": "" },
				   {"Name": "snapshots",
                    "Description": "PyPSA snapshots",
                    "Unit": "" },
				   {"Name": "solver",
                    "Description": "Name of solver used in calculations",
                    "Unit": "" },
				   {"Name": "safe_results",
                    "Description": "True if results should not be deleted during result clean up",
                    "Unit": "" },
				   {"Name": "settings",
                    "Description": "All other settings used for the calculations",
                    "Unit": ""}
					],
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
--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_bus CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_bus (
  result_id bigint NOT NULL,
  bus_id bigint NOT NULL, -- Unit: n/a...
  x double precision,
  y double precision,
  v_nom double precision,
  current_type text,
  v_mag_pu_min double precision,
  v_mag_pu_max double precision,
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
				   {"Name": "x",
                    "Description": "longitude of the bus",
                    "Unit": "" },
				   {"Name": "y",
                    "Description": "latitude of the bus",
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
                    "Unit": "..." }
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

-- PF HV bus_t results
--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_bus_t CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_bus_t (
  result_id bigint NOT NULL,
  bus_id bigint NOT NULL, -- Unit: n/a...
  v_mag_pu_set double precision[],
  p double precision[],
  q double precision[],
  v_mag_pu double precision[],
  v_ang double precision[],
  marginal_price double precision[],
  CONSTRAINT bus_t_data_result_pkey PRIMARY KEY (result_id, bus_id) ) WITH ( OIDS=FALSE );
  
-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_bus_t IS
'{
"Name": "hv powerflow bus_t result",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "ego_dp_powerflow_hv_setup.sql",
"Spatial resolution": ["Germany"],
"Description": ["Results of bus_t considered in hv powerflow calculation"],
"Column": [  
				   {"Name": "result_id",
                    "Description": "Result ID",
                    "Unit": "" },
                   {"Name": "bus_id",
                    "Description": "unique id for bus, equivalent to id from osmtgmod",
                    "Unit": "" },
				   {"Name": "v_mag_pu_set",
                    "Description": "Voltage magnitude set point, per unit of v_nom",
                    "Unit": "per unit" },
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
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';
					
-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_bus_t' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_bus_t','ego_dp_powerflow_hv_setup.sql',' ');
  
-- PF HV generator results

--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_generator CASCADE; 
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
	p_nom_opt double precision,
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
                    "Unit": "per unit" },
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
SELECT obj_description('model_draft.ego_grid_pf_hv_result_generator' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_generator','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV generator_t results

--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_generator_t CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_generator_t (
	result_id bigint NOT NULL,
	generator_id bigint NOT NULL,
	p_set double precision[], -- Unit: MW...
	q_set double precision[], -- Unit: MVar...
	p_min_pu double precision[], -- Unit: per unit...
	p_max_pu double precision[],
	p double precision[],
	q double precision[],
	status bigint[],
	CONSTRAINT generator_t_data_result_pkey PRIMARY KEY (result_id, generator_id) ) WITH ( OIDS=FALSE );

COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_generator_t IS
'{
"Name": "hv powerflow generator_t results",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "ego_dp_powerflow_hv_setup.sql",
"Spatial resolution": ["Germany"],
"Description": ["Results of generators_t considered in hv powerflow"],
"Column": [		   {"Name": "result_id",
                    "Description": "Result ID",
                    "Unit": "" },
                   {"Name": "generator_id",
                    "Description": "unique id for generators",
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
                    "Unit": "per unit" },
				   {"Name": "p",
                    "Description": "active power at bus (positive if net generation at bus)",
                    "Unit": "MW" },
				   {"Name": "q",
                    "Description": "reactive power (positive if net generation at bus)",
                    "Unit": "MVar" },
				   {"Name": "status",
                    "Description": "Status (1 is on, 0 is off). Only outputted if committable is True.",
                    "Unit": "" }],
"Changes":["..."],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';				

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_generator_t' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_generator_t','ego_dp_powerflow_hv_setup.sql',' ');
					
					
-- PF HV line results
--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_line CASCADE; 
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
                   {"Name": "x_pu",
                    "Description": "Per unit series reactance calculated by PyPSA from x and bus.v_nom",
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
                    "Description": "Optimised capacity for apparent power",
                    "Unit": "MVA" }, 
                   {"Name": "geom",
                    "Description": "geometry that depict the real route of the line",
                    "Unit": "" }, 
                   {"Name": "topo",
                    "Description": "topology that depicts a direct connection between both busses",
                    "Unit": "..." }],
"Changes":["..."],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_line' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_line','ego_dp_powerflow_hv_setup.sql',' ');

-- PF HV line results
--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_line_t CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_line_t (
	result_id bigint NOT NULL,
	line_id bigint NOT NULL,
	p0 double precision[],
	q0 double precision[],
	p1 double precision[],
	q1 double precision[],
	CONSTRAINT line_t_data_result_pkey PRIMARY KEY (result_id, line_id) ) WITH ( OIDS=FALSE );

	
-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_line_t IS
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
                    "Description": "Reactive power at bus0 (positive if branch is withdrawing power from bus0)",
                    "Unit": "MVar" },	
				   {"Name": "p1",
                    "Description": "active power at bus1 (positive if net generation at bus1)",
                    "Unit": "MW" },
				   {"Name": "q1",
                    "Description": "Reactive power at bus1 (positive if branch is withdrawing power from bus1)",
                    "Unit": "MVar" }],
"Changes":["..."],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';
					
-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_line_t' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_line_t','ego_dp_powerflow_hv_setup.sql',' ');
					
-- PF HV load results
--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_load CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_load (
	result_id bigint NOT NULL,
	load_id bigint NOT NULL, -- Unit: n/a...
	bus bigint, -- Unit: n/a...
	sign double precision, -- Unit: n/a...
	e_annual double precision, -- Unit: MW...
	CONSTRAINT load_data_result_pkey PRIMARY KEY (load_id, result_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_load IS
'{
"Name": "Results of load in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Results of loads considered in hv powerflow calculation"],
"Column": [
                   {"Name": "result_id",
                    "Description": "Result ID",
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
"Changes":["..."],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';			

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_load' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_load','ego_dp_powerflow_hv_setup.sql',' ');

-- PF HV load_t results
--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_load_t CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_load_t (
	result_id bigint NOT NULL,
	load_id bigint NOT NULL, -- Unit: n/a...
	p_set double precision[], -- Unit: MW...
	q_set double precision[], -- Unit: MVar...
	p double precision[], -- Unit: MW...
	q double precision[], -- Unit: MVar...
	CONSTRAINT load_t_data_result_pkey PRIMARY KEY (load_id, result_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_load_t IS
'{
"Name": "Results of load in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Results of loads considered in hv powerflow calculation"],
"Column": [
                   {"Name": "result_id",
                    "Description": "Result ID",
                    "Unit": "" },
                   {"Name": "load_id",
                    "Description": "unique id",
                    "Unit": "" },   
				   {"Name": "p_set",
                    "Description": "active power set point",
                    "Unit": "MW" },
                   {"Name": "q_set",
                    "Description": "reactive power set point",
                    "Unit": "MVar" },					
				   {"Name": "p",
                    "Description": "active power at bus (positive if net generation at bus)",
                    "Unit": "MW" },
				   {"Name": "q",
                    "Description": "reactive power (positive if net generation at bus)",
                    "Unit": "MVar" }
					],
"Changes":["..."],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';			

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_load_t' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_load_t','ego_dp_powerflow_hv_setup.sql',' ');
					
					
-- PF HV storage results
--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_storage CASCADE; 
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
                    "Description": "State of charge before the snapshots in the OPF",
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
                    "Unit": "per unit" },
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

-- PF HV storage results
--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_storage_t CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_storage_t (
	result_id bigint NOT NULL,
	storage_id bigint NOT NULL, -- Unit: n/a...
	p_set double precision[], -- Unit: MW...
	q_set double precision[], -- Unit: MVar...
	p_min_pu double precision[], -- Unit: per unit...
	p_max_pu double precision[], -- Unit: per unit...
	soc_set double precision[], -- Unit: MWh...
	inflow double precision[], -- Unit: MW...
	p double precision[],
	q double precision[],
	state_of_charge double precision[],
	spill double precision[],
	CONSTRAINT storage_data_t_result_pkey PRIMARY KEY (result_id, storage_id)) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_storage_t IS
'{
"Name": " Result of storage_t in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["results of storage_t units considered in hv powerflow calculations"],
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
                    "Unit": "MW" }
                  ],
"Changes":["..."],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_storage_t' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_storage_t','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV transformer results

--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_transformer CASCADE; 
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
                    "Unit": "MVA" },
                   {"Name": "geom",
                    "Description": "geometry",
                    "Unit": "" },
                   {"Name": "topo",
                    "Description": "topology",
                    "Unit": "" }],
"Changes":["..."],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_transformer' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_transformer','ego_dp_powerflow_hv_setup.sql',' ');


--DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_result_transformer_t CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_result_transformer_t (
	result_id bigint NOT NULL,
	trafo_id bigint NOT NULL, -- Unit: n/a...
	p0 double precision[],
	q0 double precision[],
	p1 double precision[],
	q1 double precision[],
	CONSTRAINT transformer_t_data_result_pkey PRIMARY KEY (result_id, trafo_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE  model_draft.ego_grid_pf_hv_result_transformer_t IS
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
                    "Unit": "MVar" }],
"Changes":["..."],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_result_transformer_t' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_result_transformer_t','ego_dp_powerflow_hv_setup.sql',' ');
-------------------------------------------------------------------
--------------------------- Grant rights --------------------------
-------------------------------------------------------------------

ALTER TABLE model_draft.ego_grid_pf_hv_result_bus
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_bus TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_bus_t
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_bus_t TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_generator
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_generator TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_generator_t
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_generator_t TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_line
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_line TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_line_t
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_line_t TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_load
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_load TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_load_t
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_load_t TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_storage
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_storage TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_storage_t
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_storage_t TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_transformer
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_transformer TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_transformer_t
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_transformer_t TO oeuser;

ALTER TABLE model_draft.ego_grid_pf_hv_result_meta
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_result_meta TO oeuser;
