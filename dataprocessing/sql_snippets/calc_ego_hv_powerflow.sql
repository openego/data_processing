--------------------------------------------------------------------
-------------------- Static component tables -----------------------
--------------------------------------------------------------------

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_scenario_settings CASCADE; 

CREATE TABLE model_draft.ego_grid_pf_hv_scenario_settings
(
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
  CONSTRAINT scenario_settings_pkey PRIMARY KEY (scn_name)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE  model_draft.ego_grid_pf_hv_scenario_settings IS
'{
"Name": "Scenario settings hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "...",
"Original file": "calc_ego_hv_powerflow.sql",
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
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_source CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_source
(
  source_id bigint NOT NULL,
  name text, -- Unit: n/a...
  co2_emissions double precision, -- Unit: tonnes/MWh...
  commentary text,
  CONSTRAINT source_data_pkey PRIMARY KEY (source_id)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE  model_draft.ego_grid_pf_hv_source IS
'{
"Name": "Sources hv powerflow ",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "calc_ego_hv_powerflow.sql",
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
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" } 
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_bus CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_bus
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  bus_id bigint NOT NULL, -- Unit: n/a...
  v_nom double precision, -- Unit: kV...
  current_type text DEFAULT 'AC'::text, -- Unit: n/a...
  v_mag_pu_min double precision DEFAULT 0, -- Unit: per unit...
  v_mag_pu_max double precision, -- Unit: per unit...
  geom geometry(Point,4326),
  CONSTRAINT bus_data_pkey PRIMARY KEY (bus_id, scn_name)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE  model_draft.ego_grid_pf_hv_bus IS
'{
"Name": "hv powerflow bus",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "calc_ego_hv_powerflow.sql",
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
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-String" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_generator CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_generator
(
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
  CONSTRAINT generator_data_source_fkey FOREIGN KEY (source) REFERENCES model_draft.ego_grid_pf_hv_source (source_id)
  
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE  model_draft.ego_grid_pf_hv_generator IS
'{
"Name": "Generator in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "calc_ego_hv_powerflow.sql",
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
                    "Description": "Controllability of active power dispatch, must be “flexible” or “variable”.",
                    "Unit": "" },
                   {"Name": "control",
                    "Description": "P,Q,V control strategy, must be “PQ”, “PV” or “Slack”.",
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
                    "Description": "If control=”flexible” this gives the minimum output per unit of p_nom",
                    "Unit": "per unit" },
                   {"Name": "p_max_pu_fixed",
                    "Description": "If control=”flexible” this gives the maximum output per unit of p_nom, equivalent to a de-rating factor.",
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
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_line CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_line
(
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
  CONSTRAINT line_data_pkey PRIMARY KEY (line_id, scn_name)
)
WITH (
  OIDS=FALSE
);

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
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_load CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_load
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  load_id bigint NOT NULL, -- Unit: n/a...
  bus bigint, -- Unit: n/a...
  sign double precision DEFAULT (-1), -- Unit: n/a...
  e_annual double precision, -- Unit: MW...
  CONSTRAINT load_data_pkey PRIMARY KEY (load_id, scn_name)
)
WITH (
  OIDS=FALSE
);

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
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_storage CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_storage
(
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
  CONSTRAINT storage_data_source_fkey FOREIGN KEY (source) REFERENCES model_draft.ego_grid_pf_hv_source (source_id)
)
WITH (
  OIDS=FALSE
);

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
                    "Description": "Controllability of active power dispatch, must be “flexible” or “variable”",
                    "Unit": "" },
                   {"Name": "control",
                    "Description": "P,Q,V control strategy for PF, must be “PQ”, “PV” or “Slack”",
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
                    "Description": "If control=”flexible” this gives the minimum output per unit of p_nom for the OPF.",
                    "Unit": "per unit" },
                   {"Name": "p_max_pu_fixed",
                    "Description": "If control=”flexible” this gives the maximum output per unit of p_nom for the OPF, equivalent to a de-rating factor",
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
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "Completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_temp_resolution CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_temp_resolution
(
  temp_id bigint NOT NULL,
  timesteps bigint NOT NULL,
  resolution text, 
  start_time timestamp without time zone,
  CONSTRAINT temp_resolution_pkey PRIMARY KEY (temp_id)
)
WITH (
  OIDS=FALSE
);

INSERT INTO model_draft.ego_grid_pf_hv_temp_resolution (temp_id, timesteps, resolution, start_time)
SELECT 1, 8760, 'h', TIMESTAMP '2011-01-01 00:00:00';

COMMENT ON TABLE  model_draft.ego_grid_pf_hv_temp_resolution IS
'{
"Name": "temporal resolution hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "calc_ego_hv_powerflow.sql",
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
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_transformer CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_transformer
(
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
  CONSTRAINT transformer_data_pkey PRIMARY KEY (trafo_id, scn_name)
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE  model_draft.ego_grid_pf_hv_transformer IS
'{
"Name": "Transformer in hv powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "calc_ego_hv_powerflow.sql",
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
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


--------------------------------------------------------------------
---------------------- Time series tables --------------------------
--------------------------------------------------------------------

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_bus_v_mag_set CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_bus_v_mag_set
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  bus_id bigint NOT NULL,
  temp_id integer NOT NULL,
  v_mag_pu_set double precision[], -- Unit: per unit...
  CONSTRAINT bus_v_mag_set_pkey PRIMARY KEY (bus_id, temp_id, scn_name),
  CONSTRAINT bus_v_mag_set_temp_fkey FOREIGN KEY (temp_id) REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id)
)
WITH (
  OIDS=FALSE
);


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
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_generator_pq_set CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_generator_pq_set
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  generator_id bigint NOT NULL,
  temp_id integer NOT NULL,
  p_set double precision[], -- Unit: MW...
  q_set double precision[], -- Unit: MVar...
  p_min_pu double precision[], -- Unit: per unit...
  p_max_pu double precision[], -- Unit: per unit...
  CONSTRAINT generator_pq_set_pkey PRIMARY KEY (generator_id, temp_id, scn_name),
  CONSTRAINT generator_pq_set_temp_fkey FOREIGN KEY (temp_id) REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id)
)
WITH (
  OIDS=FALSE
);


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
                    "Description": "If control=”variable” this gives the minimum output for each snapshot per unit of p_nom for the OPF",
                    "Unit": "per unit" },
                   {"Name": "p_max_pu",
                    "Description": "If control=”variable” this gives the maximum output for each snapshot per unit of p_nom for the OPF, relevant e.g. if for renewables the power output is limited by the weather",
                    "Unit": "per unit" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';



DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_load_pq_set CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_load_pq_set
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  load_id bigint NOT NULL,
  temp_id integer NOT NULL,
  p_set double precision[], -- Unit: MW...
  q_set double precision[], -- Unit: MVar...
  CONSTRAINT load_pq_set_pkey PRIMARY KEY (load_id, temp_id, scn_name),
  CONSTRAINT load_pq_set_temp_fkey FOREIGN KEY (temp_id) REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id)
)
WITH (
  OIDS=FALSE
);

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
		    "Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';



DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_storage_pq_set CASCADE; 
CREATE TABLE model_draft.ego_grid_pf_hv_storage_pq_set
(
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
  CONSTRAINT storage_pq_set_temp_fkey FOREIGN KEY (temp_id) REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id)
)
WITH (
  OIDS=FALSE
);

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
                    "Unit": "MVar" }],
                   {"Name": "p_min_pu",
                    "Description": "If control=”variable” this gives the minimum output for each snapshot per unit of p_nom for the OPF",
                    "Unit": "per unit" },
                   {"Name": "p_max_pu",
                    "Description": "If control=”variable” this gives the maximum output for each snapshot per unit of p_nom for the OPF",
                    "Unit": "per unit" }],
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
                    "Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

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
Description: Type of current (must be either “AC” or “DC”).
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
Description: Controllability of active power dispatch, must be “flexible” or “variable”.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.control IS 'Unit: n/a
Description: P,Q,V control strategy for PF, must be “PQ”, “PV” or “Slack”.
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
Description: If control=”flexible” this gives the minimum output per unit of p_nom for the OPF.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator.p_max_pu_fixed IS 'Unit: per unit
Description: If control=”flexible” this gives the maximum output per unit of p_nom for the OPF, equivalent to a de-rating factor.
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
Description: If control=”variable” this gives the minimum output for each snapshot per unit of p_nom for the OPF.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_generator_pq_set.p_max_pu IS 'Unit: per unit
Description: If control=”variable” this gives the maximum output for each snapshot per unit of p_nom for the OPF, relevant e.g. if for renewables the power output is limited by the weather.
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
Description: Controllability of active power dispatch, must be “flexible” or “variable”.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.control IS 'Unit: n/a
Description: P,Q,V control strategy for PF, must be “PQ”, “PV” or “Slack”.
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
Description: If control=”flexible” this gives the minimum output per unit of p_nom for the OPF.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage.p_max_pu_fixed IS 'Unit: per unit
Description: If control=”flexible” this gives the maximum output per unit of p_nom for the OPF, equivalent to a de-rating factor.
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
Description: If control=”variable” this gives the minimum output for each snapshot per unit of p_nom for the OPF.
Status: Input (optional)';
COMMENT ON COLUMN model_draft.ego_grid_pf_hv_storage_pq_set.p_max_pu IS 'Unit: per unit
Description: If control=”variable” this gives the maximum output for each snapshot per unit of p_nom for the OPF, relevant e.g. if for renewables the power output is limited by the weather.
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
