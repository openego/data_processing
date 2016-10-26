DROP SCHEMA IF EXISTS calc_ego_hv_powerflow CASCADE;
CREATE SCHEMA calc_ego_hv_powerflow
  AUTHORIZATION oeuser;

--------------------------------------------------------------------
-------------------- Static component tables -----------------------
--------------------------------------------------------------------

CREATE TABLE calc_ego_hv_powerflow.scenario_settings
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

COMMENT ON TABLE  calc_ego_hv_powerflow.scenario_settings IS
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


CREATE TABLE calc_ego_hv_powerflow.source
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

COMMENT ON TABLE  calc_ego_hv_powerflow.source IS
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


CREATE TABLE calc_ego_hv_powerflow.bus
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

COMMENT ON TABLE  calc_ego_hv_powerflow.bus IS
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



CREATE TABLE calc_ego_hv_powerflow.generator
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
  CONSTRAINT generator_data_source_fkey FOREIGN KEY (source) REFERENCES calc_ego_hv_powerflow.source (source_id)
  
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE  calc_ego_hv_powerflow.generator IS
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
                    "Unit": "..." }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["Please complete"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


CREATE TABLE calc_ego_hv_powerflow.line
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

CREATE TABLE calc_ego_hv_powerflow.load
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



CREATE TABLE calc_ego_hv_powerflow.storage
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
  CONSTRAINT storage_data_source_fkey FOREIGN KEY (source) REFERENCES calc_ego_hv_powerflow.source (source_id)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE calc_ego_hv_powerflow.temp_resolution
(
  temp_id bigint NOT NULL,
  timesteps bigint NOT NULL,
  resolution text, -- example: h, 15min...
  start_time timestamp without time zone, -- style: YYYY-MM-DD HH:MM:SS
  CONSTRAINT temp_resolution_pkey PRIMARY KEY (temp_id)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE calc_ego_hv_powerflow.transformer
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

--------------------------------------------------------------------
---------------------- Time series tables --------------------------
--------------------------------------------------------------------
CREATE TABLE calc_ego_hv_powerflow.bus_v_mag_set
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  bus_id bigint NOT NULL,
  temp_id integer NOT NULL,
  v_mag_pu_set double precision[], -- Unit: per unit...
  CONSTRAINT bus_v_mag_set_pkey PRIMARY KEY (bus_id, temp_id, scn_name),
  CONSTRAINT bus_v_mag_set_temp_fkey FOREIGN KEY (temp_id) REFERENCES calc_ego_hv_powerflow.temp_resolution (temp_id)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE calc_ego_hv_powerflow.generator_pq_set
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  generator_id bigint NOT NULL,
  temp_id integer NOT NULL,
  p_set double precision[], -- Unit: MW...
  q_set double precision[], -- Unit: MVar...
  p_min_pu double precision[], -- Unit: per unit...
  p_max_pu double precision[], -- Unit: per unit...
  CONSTRAINT generator_pq_set_pkey PRIMARY KEY (generator_id, temp_id, scn_name),
  CONSTRAINT generator_pq_set_temp_fkey FOREIGN KEY (temp_id) REFERENCES calc_ego_hv_powerflow.temp_resolution (temp_id)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE calc_ego_hv_powerflow.load_pq_set
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  load_id bigint NOT NULL,
  temp_id integer NOT NULL,
  p_set double precision[], -- Unit: MW...
  q_set double precision[], -- Unit: MVar...
  CONSTRAINT load_pq_set_pkey PRIMARY KEY (load_id, temp_id, scn_name),
  CONSTRAINT load_pq_set_temp_fkey FOREIGN KEY (temp_id) REFERENCES calc_ego_hv_powerflow.temp_resolution (temp_id)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE calc_ego_hv_powerflow.storage_pq_set
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
  CONSTRAINT storage_pq_set_temp_fkey FOREIGN KEY (temp_id) REFERENCES calc_ego_hv_powerflow.temp_resolution (temp_id)
)
WITH (
  OIDS=FALSE
);


-------------------------------------------------------------------
--------------------------- Grant rights --------------------------
-------------------------------------------------------------------

ALTER TABLE calc_ego_hv_powerflow.bus
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.bus TO oeuser;

ALTER TABLE calc_ego_hv_powerflow.bus_v_mag_set
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.bus_v_mag_set TO oeuser;

ALTER TABLE calc_ego_hv_powerflow.generator
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.generator TO oeuser;

ALTER TABLE calc_ego_hv_powerflow.generator_pq_set
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.generator_pq_set TO oeuser;

ALTER TABLE calc_ego_hv_powerflow.line
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.line TO oeuser;

ALTER TABLE calc_ego_hv_powerflow.load
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.load TO oeuser;

ALTER TABLE calc_ego_hv_powerflow.load_pq_set
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.load_pq_set TO oeuser;

ALTER TABLE calc_ego_hv_powerflow.scenario_settings
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.scenario_settings TO oeuser;

ALTER TABLE calc_ego_hv_powerflow.source
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.source TO oeuser;

ALTER TABLE calc_ego_hv_powerflow.storage
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.storage TO oeuser;

ALTER TABLE calc_ego_hv_powerflow.storage_pq_set
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.storage_pq_set TO oeuser;

ALTER TABLE calc_ego_hv_powerflow.temp_resolution
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.temp_resolution TO oeuser;

ALTER TABLE calc_ego_hv_powerflow.transformer
  OWNER TO oeuser;
GRANT ALL ON TABLE calc_ego_hv_powerflow.transformer TO oeuser;

-------------------------------------------------------------------
----------------------------- Comments ----------------------------
-------------------------------------------------------------------
COMMENT ON COLUMN calc_ego_hv_powerflow.bus.bus_id IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.bus.v_nom IS 'Unit: kV
Description: Nominal voltage
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.bus.current_type IS 'Unit: n/a
Description: Type of current (must be either “AC” or “DC”).
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.bus.v_mag_pu_min IS 'Unit: per unit
Description: Minimum desired voltage, per unit of v_nom
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.bus.v_mag_pu_max IS 'Unit: per unit
Description: Maximum desired voltage, per unit of v_nom
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.bus_v_mag_set.v_mag_pu_set IS 'Unit: per unit
Description: Voltage magnitude set point, per unit of v_nom.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.generator_id IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.bus IS 'Unit: n/a
Description: name of bus to which generator is attached
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.dispatch IS 'Unit: n/a
Description: Controllability of active power dispatch, must be “flexible” or “variable”.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.control IS 'Unit: n/a
Description: P,Q,V control strategy for PF, must be “PQ”, “PV” or “Slack”.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.p_nom IS 'Unit: MW
Description: Nominal power for limits in OPF
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.p_nom_extendable IS 'Unit: n/a
Description: Switch to allow capacity p_nom to be extended in OPF.
Default: False
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.p_nom_min IS 'Unit: MW
Description: If p_nom is extendable in OPF, set its minimum value.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.p_nom_max IS 'Unit: MW
Description: If p_nom is extendable in OPF, set its maximum value (e.g. limited by potential).
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.p_min_pu_fixed IS 'Unit: per unit
Description: If control=”flexible” this gives the minimum output per unit of p_nom for the OPF.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.p_max_pu_fixed IS 'Unit: per unit
Description: If control=”flexible” this gives the maximum output per unit of p_nom for the OPF, equivalent to a de-rating factor.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.sign IS 'Unit: n/a
Description: power sign
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.source IS 'Unit: n/a
Description: Prime mover (e.g. coal, gas, wind, solar); required for CO2 calculation in OPF
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.marginal_cost IS 'Unit: currency/MWh
Description: Marginal cost of production of 1 MWh.	
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.capital_cost IS 'Unit: currency/MW
Description: Capital cost of extending p_nom by 1 MW.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator.efficiency IS 'Unit: per unit
Description: Ratio between primary energy and electrical energy, e.g. takes value 0.4 for gas. This is important for determining CO2 emissions per MWh.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator_pq_set.p_set IS 'Unit: MW
Description: active power set point (for PF).
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator_pq_set.q_set IS 'Unit: MVar
Description: reactive power set point (for PF).
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator_pq_set.p_min_pu IS 'Unit: per unit
Description: If control=”variable” this gives the minimum output for each snapshot per unit of p_nom for the OPF.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.generator_pq_set.p_max_pu IS 'Unit: per unit
Description: If control=”variable” this gives the maximum output for each snapshot per unit of p_nom for the OPF, relevant e.g. if for renewables the power output is limited by the weather.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.line_id IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.bus0 IS 'Unit: n/a
Description: Name of first bus to which branch is attached. 
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.bus1 IS 'Unit: n/a
Description: Name of second bus to which branch is attached.
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.x IS 'Unit: Ohm
Description: series reactance; must be non-zero for AC branch in linear power flow; in non-linear power flow x+jr must be non-zero.
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.r IS 'Unit: Ohm
Description: Series resistance; must be non-zero for DC branch in linear power flow; in non-linear power flow x+jr must be non-zero.
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.g IS 'Unit: Siemens
Description: Shunt conductivity.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.b IS 'Unit: Siemens
Description: Shunt susceptance.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.s_nom IS 'Unit: MVA
Description: Limit of apparent power which can pass through branch.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.s_nom_extendable IS 'Unit: n/a
Description: Switch to allow capacity s_nom to be extended in OPF.
Default: False
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.s_nom_min IS 'Unit: MVA
Description: If s_nom is extendable in OPF, set its minimum value.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.s_nom_max IS 'Unit: MVA
Description: If s_nom is extendable in OPF, set its maximum value (e.g. limited by potential).
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.capital_cost IS 'Unit: currency/MVA
Description: Capital cost of extending s_nom by 1 MVA.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.length IS 'Unit: km
Description: Length of line, useful for calculating the capital cost.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.line.terrain_factor IS 'Unit: per unit
Description: Terrain factor for increasing capital cost.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.load.load_id IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.load.bus IS 'Unit: n/a
Description: Name of bus to which load is attached.
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.load.sign IS 'Unit: n/a
Description: power sign
Default: -1
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.load.e_annual IS 'Unit: MW
Description: 
Status: Input (not needd for PyPSA)';
COMMENT ON COLUMN calc_ego_hv_powerflow.load_pq_set.p_set IS 'Unit: MW
Description: Active power consumption (positive if the load is consuming power).
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.load_pq_set.q_set IS 'Unit: MVar
Description: 	Reactive power consumption (positive if the load is inductive).
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.source.name IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.source.co2_emissions IS 'Unit: tonnes/MWh
Description: Emissions in CO2-tonnes-equivalent per MWh of primary energy (e.g. has has 0.2 tonnes/MWh_thermal).
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.storage_id IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.bus IS 'Unit: n/a
Description: name of bus to which storage is attached
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.dispatch IS 'Unit: n/a
Description: Controllability of active power dispatch, must be “flexible” or “variable”.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.control IS 'Unit: n/a
Description: P,Q,V control strategy for PF, must be “PQ”, “PV” or “Slack”.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.p_nom IS 'Unit: MW
Description: Nominal power for limits in OPF
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.p_nom_extendable IS 'Unit: n/a
Description: Switch to allow capacity p_nom to be extended in OPF.
Default: False
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.p_nom_min IS 'Unit: MW
Description: If p_nom is extendable in OPF, set its minimum value.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.p_nom_max IS 'Unit: MW
Description: If p_nom is extendable in OPF, set its maximum value (e.g. limited by potential).
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.p_min_pu_fixed IS 'Unit: per unit
Description: If control=”flexible” this gives the minimum output per unit of p_nom for the OPF.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.p_max_pu_fixed IS 'Unit: per unit
Description: If control=”flexible” this gives the maximum output per unit of p_nom for the OPF, equivalent to a de-rating factor.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.sign IS 'Unit: n/a
Description: power sign
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.source IS 'Unit: n/a
Description: Prime mover (e.g. coal, gas, wind, solar); required for CO2 calculation in OPF
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.marginal_cost IS 'Unit: currency/MWh
Description: Marginal cost of production of 1 MWh.	
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.capital_cost IS 'Unit: currency/MW
Description: Capital cost of extending p_nom by 1 MW.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.efficiency IS 'Unit: per unit
Description: Ratio between primary energy and electrical energy, e.g. takes value 0.4 for gas. This is important for determining CO2 emissions per MWh.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.soc_initial IS 'Unit: MWh
Description: State of charge before the snapshots in the OPF.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.soc_cyclic IS 'Unit: n/a
Description: Switch: if True, then state_of_charge_initial is ignored and the initial state of charge is set to the final state of charge for the group of snapshots in the OPF.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.max_hours IS 'Unit: hours
Description: Maximum state of charge capacity in terms of hours at full output capacity p_nom
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.efficiency_store IS 'Unit: per unit
Description: Efficiency of storage on the way into the storage.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.efficiency_dispatch IS 'Unit: per unit
Description: Efficiency of storage on the way out of the storage.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage.standing_loss IS 'Unit: per unit
Description: Losses per hour to state of charge.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage_pq_set.p_set IS 'Unit: MW
Description: active power set point (for PF).
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage_pq_set.q_set IS 'Unit: MVar
Description: reactive power set point (for PF).
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage_pq_set.p_min_pu IS 'Unit: per unit
Description: If control=”variable” this gives the minimum output for each snapshot per unit of p_nom for the OPF.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage_pq_set.p_max_pu IS 'Unit: per unit
Description: If control=”variable” this gives the maximum output for each snapshot per unit of p_nom for the OPF, relevant e.g. if for renewables the power output is limited by the weather.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage_pq_set.soc_set IS 'Unit: MWh
Description: State of charge set points for snapshots in the OPF.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.storage_pq_set.inflow IS 'Unit: MW
Description: Inflow to the state of charge, e.g. due to river inflow in hydro reservoir.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.temp_resolution.resolution IS 'example: h, 15min...';
COMMENT ON COLUMN calc_ego_hv_powerflow.temp_resolution.start_time IS 'style: YYYY-MM-DD HH:MM:SS';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.trafo_id IS 'Unit: n/a
Description: Unique name
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.bus0 IS 'Unit: n/a
Description: Name of first bus to which branch is attached. 
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.bus1 IS 'Unit: n/a
Description: Name of second bus to which branch is attached.
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.x IS 'Unit: Ohm
Description: eries reactance; must be non-zero for AC branch in linear power flow; in non-linear power flow x+jr must be non-zero.
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.r IS 'Unit: Ohm
Description: Series resistance; must be non-zero for DC branch in linear power flow; in non-linear power flow x+jr must be non-zero.
Status: Input (required)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.g IS 'Unit: Siemens
Description: Shunt conductivity.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.b IS 'Unit: Siemens
Description: Shunt susceptance.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.s_nom IS 'Unit: MVA
Description: Limit of apparent power which can pass through branch.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.s_nom_extendable IS 'Unit: n/a
Description: Switch to allow capacity s_nom to be extended in OPF.
Default: False
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.s_nom_min IS 'Unit: MVA
Description: If s_nom is extendable in OPF, set its minimum value.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.s_nom_max IS 'Unit: MVA
Description: If s_nom is extendable in OPF, set its maximum value (e.g. limited by potential).
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.tap_ratio IS 'Unit: 1
Description: Ratio of per unit voltages at each bus.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.phase_shift IS 'Unit: Degrees
Description: Voltage phase angle shift.
Status: Input (optional)';
COMMENT ON COLUMN calc_ego_hv_powerflow.transformer.capital_cost IS 'Unit: currency/MVA
Description: Capital cost of extending s_nom by 1 MVA.
Status: Input (optional)';

-------------------------------------------------------------------
----------------------------- INDEXING ----------------------------
-------------------------------------------------------------------

CREATE INDEX fki_generator_data_source_fk
  ON calc_ego_hv_powerflow.generator
  USING btree
  (source);
  
CREATE INDEX fki_storage_data_source_fk
  ON calc_ego_hv_powerflow.storage
  USING btree
  (source);
  
 CREATE INDEX fki_trafo_data_bus0_fk
  ON calc_ego_hv_powerflow.transformer
  USING btree
  (bus0);
  
 CREATE INDEX fki_trafo_data_bus1_fk
  ON calc_ego_hv_powerflow.transformer
  USING btree
  (bus1);

-------------------------------------------------------------------
--------------------- FILL SOURCES TABLE --------------------------
-------------------------------------------------------------------
  
INSERT INTO calc_ego_hv_powerflow.source VALUES (1, 'gas', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (2, 'lignite', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (3, 'waste', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (4, 'oil', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (5, 'uranium', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (6, 'biomass', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (7, 'eeg_gas', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (8, 'coal', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (9, 'run_of_river', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (10, 'reservoir', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (11, 'pumped_storage', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (12, 'solar', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (13, 'wind', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (14, 'geothermal', NULL, NULL);
INSERT INTO calc_ego_hv_powerflow.source VALUES (15, 'other_non_renewable', NULL, NULL);
