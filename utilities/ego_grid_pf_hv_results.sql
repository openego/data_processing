
--DROP TABLE IF EXISTS grid.ego_pf_hv_result_meta;
CREATE TABLE grid.ego_pf_hv_result_meta
(
  result_id bigint NOT NULL,
  modeldraft_id bigint NOT NULL,
  scn_name character varying,
  calc_date timestamp without time zone,
  user_name character varying,
  method character varying,
  start_snapshot integer,
  end_snapshot integer,
  snapshots timestamp without time zone[],
  solver character varying,
  settings json,
  CONSTRAINT ego_pf_hv_result_meta_pkey PRIMARY KEY (result_id)
)
WITH (
  OIDS=FALSE
);

-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_meta OWNER TO oeuser;

COMMENT ON TABLE grid.ego_pf_hv_result_meta
  IS E'{
    "title": "eGo hv powerflow results - meta",
    "description": "Metadata of results from hv powerflow calculations",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "copyright": "\\u00a9 2016 Open Power System Data",
            "name": "Open Power System Data (OPSD)",
            "license": "MIT Licence",
            "description": " "
        },
        {
            "url": "www.energymap.info",
            "copyright": "",
            "name": "EnergyMap",
            "license": "",
            "description": " "
        },
        {
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "copyright": "",
            "name": "Bundesnetzagentur (BNetzA)",
            "license": "",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "result_id",
                    "unit": "",
                    "description": "Unique result ID"
                },
                {
                    "name": "modeldraft_id",
                    "unit": "",
                    "description": "Result ID used in the model_draft schema"
                },
				{
                    "name": "scn_name",
                    "unit": "",
                    "description": "Scenario name"
                },
				{
                    "name": "calc_date",
                    "unit": "Datetime",
                    "description": "Datetime of calculation start"
                },
				{
                    "name": "user_name",
                    "unit": "",
                    "description": "Name of user who uploaded the results"
                },
				{
                    "name": "method",
                    "unit": "",
                    "description": "Type of powerflow calculation (pf/lopf/lpf)"
                },
				{
                    "name": "start_snapshot",
                    "unit": "",
                    "description": "Start step of calculation range"
                },
				{
                    "name": "end_snapshot",
                    "unit": "",
                    "description": "End step of calculation range"
                },
				{
                    "name": "snapshots",
                    "unit": "",
                    "description": "PyPSA snapshots"
                },
				{
                    "name": "solver",
                    "unit": "",
                    "description": "Name of solver used in calculations"
                },
				{
                    "name": "settings",
                    "unit": "",
                    "description": "All other settings used for the calculations"
                }				
            ],
            "name": "grid.ego_pf_hv_result_meta",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';


-- select description
SELECT obj_description('grid.ego_pf_hv_result_meta' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_meta','ego_dp_structure_versioning.sql','hv pf result meta');
*/


--DROP TABLE  IF EXISTS grid.ego_pf_hv_result_bus;
CREATE TABLE grid.ego_pf_hv_result_bus
(
  result_id bigint NOT NULL,
  bus_id bigint NOT NULL,
  x double precision,
  y double precision,
  v_nom double precision,
  current_type text,
  v_mag_pu_min double precision,
  v_mag_pu_max double precision,
  geom geometry(Point,4326),
  CONSTRAINT ego_pf_hv_result_bus_pkey PRIMARY KEY (bus_id, result_id)
); 
--FK
ALTER TABLE grid.ego_pf_hv_result_bus
	ADD CONSTRAINT ego_pf_hv_result_bus_fkey FOREIGN KEY (result_id) 
	REFERENCES grid.ego_pf_hv_result_meta(result_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_bus OWNER TO oeuser;
-- index GIST (geom)
CREATE INDEX ego_pf_hv_result_bus_geom_idx
	ON grid.ego_pf_hv_result_bus USING GIST (geom);
	
COMMENT ON TABLE grid.ego_pf_hv_result_bus
  IS E'{
    "title": "eGo hv powerflow results - bus",
    "description": "Buses relevant for eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "result_id",
                    "unit": "",
                    "description": "unique result id corresponding to result_meta"
                },
                {
                    "name": "bus_id",
                    "unit": "",
                    "description": "unique id for bus, equivalent to id from osmtgmod"
                },
                {
                    "name": "x",
                    "unit": "",
                    "description": "longitude of the bus"
                },
				{
                    "name": "y",
                    "unit": "",
                    "description": "latitude of the bus"
                },
				{
                    "name": "v_nom",
                    "unit": "kV",
                    "description": "nominal voltage"
                },
                {
                    "name": "current_type",
                    "unit": "",
                    "description": "current type - AC or DC"
                },
                {
                    "name": "v_mag_pu_min",
                    "unit": "per unit",
                    "description": "Minimum desired voltage, per unit of v_nom"
                },
                {
                    "name": "v_mag_pu_max",
                    "unit": "per unit",
                    "description": "Maximum desired voltage, per unit of v_nom"
                },
                {
                    "name": "geom",
                    "unit": "...",
                    "description": "geometry of bus"
                }
            ],
            "name": "grid.ego_pf_hv_result_bus",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('grid.ego_pf_hv_result_bus' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_bus','ego_dp_structure_versioning.sql','hv pf result buses');
*/


--DROP TABLE  IF EXISTS grid.ego_pf_hv_result_bus_t;
CREATE TABLE grid.ego_pf_hv_result_bus_t
(
  result_id bigint NOT NULL,
  bus_id bigint NOT NULL,
  v_mag_pu_set double precision[],
  p double precision[],
  q double precision[],
  v_mag_pu double precision[],
  v_ang double precision[],
  marginal_price double precision[],
  CONSTRAINT ego_pf_hv_result_bus_t_pkey PRIMARY KEY (result_id, bus_id)
);

--FK
ALTER TABLE grid.ego_pf_hv_result_bus_t
	ADD CONSTRAINT ego_pf_hv_result_bus_t_fkey FOREIGN KEY (result_id) 
	REFERENCES grid.ego_pf_hv_result_meta(result_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_bus_t OWNER TO oeuser;
	
COMMENT ON TABLE grid.ego_pf_hv_result_bus_t
  IS E'{
    "title": "eGo hv powerflow results - bus_t",
    "description": "Results of time varying data of buses relevant for eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "result_id",
                    "unit": "",
                    "description": "unique result id corresponding to result_meta"
                },
                {
                    "name": "bus_id",
                    "unit": "",
                    "description": "unique id for bus, equivalent to id from osmtgmod"
                },
                {
                    "name": "v_mag_pu_set",
                    "unit": "per unit",
                    "description": "Voltage magnitude set point, per unit of v_nom"
                },
				{
                    "name": "p",
                    "unit": "MW",
                    "description": "active power at bus (positive if net generation at bus)"
                },
				{
                    "name": "q",
                    "unit": "MVar",
                    "description": "reactive power (positive if net generation at bus)"
                },
                {
                    "name": "v_mag_pu",
                    "unit": "per unit",
                    "description": "Voltage magnitude, per unit of v_nom"
                },
                {
                    "name": "v_ang",
                    "unit": "radians",
                    "description": "Voltage angle"
                },
                {
                    "name": "marginal_price",
                    "unit": "currency",
                    "description": "Locational marginal price from LOPF from power balance constraint"
                }
            ],
            "name": "grid.ego_pf_hv_result_bus_t",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';


-- select description
SELECT obj_description('grid.ego_pf_hv_result_bus_t' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_bus_t','ego_dp_structure_versioning.sql','hv pf result buses_t');
*/


--DROP TABLE  IF EXISTS grid.ego_pf_hv_result_generator;
CREATE TABLE grid.ego_pf_hv_result_generator
(
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
  CONSTRAINT ego_pf_hv_result_generator_pkey PRIMARY KEY (result_id, generator_id)
);

--FK
ALTER TABLE grid.ego_pf_hv_result_generator
	ADD CONSTRAINT ego_pf_hv_result_generator_fkey FOREIGN KEY (result_id) 
	REFERENCES grid.ego_pf_hv_result_meta(result_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_generator OWNER TO oeuser;


COMMENT ON TABLE grid.ego_pf_hv_result_generator
  IS E'{
    "title": "eGo hv powerflow results - generator",
    "description": "Generators relevant for eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "copyright": "\\u00a9 2016 Open Power System Data",
            "name": "Open Power System Data (OPSD)",
            "license": "MIT Licence",
            "description": " "
        },
        {
            "url": "www.energymap.info",
            "copyright": "",
            "name": "EnergyMap",
            "license": "",
            "description": " "
        },
        {
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "copyright": "",
            "name": "Bundesnetzagentur (BNetzA)",
            "license": "",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
               {
                    "name": "result_id",
                    "unit": "",
                    "description": "unique result id corresponding to result_meta"
                },
                {
                    "name": "generator_id",
                    "unit": "",
                    "description": "ID of corresponding generator"
                },
                {
                    "name": "bus",
                    "unit": "",
                    "description": "id of associated bus"
                },
                {
                    "name": "dispatch",
                    "unit": "",
                    "description": "Controllability of active power dispatch, must be flexible or variable."
                },
                {
                    "name": "control",
                    "unit": "",
                    "description": "P,Q,V control strategy, must be PQ, PV or Slack."
                },
                {
                    "name": "p_nom",
                    "unit": "MW",
                    "description": "Nominal power"
                },
                {
                    "name": "p_nom_extendable",
                    "unit": "",
                    "description": "Switch to allow capacity p_nom to be extended"
                },
                {
                    "name": "p_nom_min",
                    "unit": "",
                    "description": "If p_nom is extendable, set its minimum value"
                },
                {
                    "name": "p_nom_max",
                    "unit": "",
                    "description": "If p_nom is extendable, set its maximum value (e.g. limited by potential)"
                },
                {
                    "name": "p_min_pu_fixed",
                    "unit": "per unit",
                    "description": "If control=flexible this gives the minimum output per unit of p_nom"
                },
                {
                    "name": "p_max_pu_fixed",
                    "unit": "per unit",
                    "description": "If control=flexible this gives the maximum output per unit of p_nom, equivalent to a de-rating factor."
                },
                {
                    "name": "sign",
                    "unit": "",
                    "description": "power sign"
                },
                {
                    "name": "source",
                    "unit": "",
                    "description": "prime mover energy carrier"
                },
                {
                    "name": "marginal_cost",
                    "unit": "EUR/MWh",
                    "description": "Marginal cost of production of 1 MWh"
                },
                {
                    "name": "capital_cost",
                    "unit": "EUR/MW",
                    "description": "Capital cost of extending p_nom by 1 MW"
                },
                {
                    "name": "efficiency",
                    "unit": "per unit",
                    "description": "Ratio between primary energy and electrical energy"
                },
                {
                    "name": "p_nom_opt",
                    "unit": "MW",
                    "description": "Optimised nominal power"
                }
            ],
            "name": "grid.ego_pf_hv_result_generator",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('grid.ego_pf_hv_result_generator' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_generator','ego_dp_structure_versioning.sql','hv pf result generator');
*/


--DROP TABLE  IF EXISTS grid.ego_pf_hv_result_generator_t;
CREATE TABLE grid.ego_pf_hv_result_generator_t
(
  result_id bigint NOT NULL,
  generator_id bigint NOT NULL,
  p_set double precision[],
  q_set double precision[],
  p_min_pu double precision[],
  p_max_pu double precision[],
  p double precision[],
  q double precision[],
  status bigint[],
  CONSTRAINT ego_pf_hv_result_generator_t_pkey PRIMARY KEY (result_id, generator_id)
);

--FK
ALTER TABLE grid.ego_pf_hv_result_generator_t
	ADD CONSTRAINT ego_pf_hv_result_generator_t_fkey FOREIGN KEY (result_id) 
	REFERENCES grid.ego_pf_hv_result_meta(result_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_generator_t OWNER TO oeuser;


COMMENT ON TABLE grid.ego_pf_hv_result_generator_t
  IS E'{
    "title": "eGo hv powerflow results - generator_t",
    "description": "Results of generators_t considered in eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "copyright": "\\u00a9 2016 Open Power System Data",
            "name": "Open Power System Data (OPSD)",
            "license": "MIT Licence",
            "description": " "
        },
        {
            "url": "www.energymap.info",
            "copyright": "",
            "name": "EnergyMap",
            "license": "",
            "description": " "
        },
        {
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "copyright": "",
            "name": "Bundesnetzagentur (BNetzA)",
            "license": "",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "result_id",
                    "unit": "",
                    "description": "unique result id corresponding to result_meta"
                },
                {
                    "name": "generator_id",
                    "unit": "",
                    "description": "ID of corresponding generator"
                },
                {
                    "name": "p_set",
                    "unit": "MW",
                    "description": "active power set point"
                },
				{
                    "name": "q_set",
                    "unit": "MVar",
                    "description": "reactive power set point"
                },
				{
                    "name": "p_min_pu",
                    "unit": "per unit",
                    "description": "If control=variable this gives the minimum output for each snapshot per unit of p_nom for the OPF"
                },
				{
                    "name": "p_max_pu",
                    "unit": "per unit",
                    "description": "If control=variable this gives the maximum output for each snapshot per unit of p_nom for the OPF, relevant e.g. if for renewables the power output is limited by the weather"
                },
				{
                    "name": "p",
                    "unit": "MW",
                    "description": "active power at bus (positive if net generation at bus)"
                },
				{
                    "name": "q",
                    "unit": "MVar",
                    "description": "reactive power (positive if net generation at bus)"
                },
				{
                    "name": "status",
                    "unit": "",
                    "description": "Status (1 is on, 0 is off). Only outputted if committable is True."
                }
            ],
            "name": "grid.ego_pf_hv_result_generator_t",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';


-- select description
SELECT obj_description('grid.ego_pf_hv_result_generator_t' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_generator_t','ego_dp_structure_versioning.sql','hv pf result generator_t');
*/

--DROP TABLE  IF EXISTS grid.ego_pf_hv_result_line;
CREATE TABLE grid.ego_pf_hv_result_line
(
  result_id bigint NOT NULL,
  line_id bigint NOT NULL,
  bus0 bigint,
  bus1 bigint,
  x numeric,
  r numeric,
  g numeric,
  b numeric,
  s_nom numeric,
  s_nom_extendable boolean,
  s_nom_min double precision,
  s_nom_max double precision,
  capital_cost double precision,
  length double precision,
  cables integer,
  frequency numeric,
  terrain_factor double precision DEFAULT 1,
  x_pu numeric,
  r_pu numeric,
  g_pu numeric,
  b_pu numeric,
  s_nom_opt numeric,
  geom geometry(MultiLineString,4326),
  topo geometry(LineString,4326),
  CONSTRAINT ego_pf_hv_result_line_pkey PRIMARY KEY (result_id, line_id)
)
WITH (
  OIDS=FALSE
);


--FK
ALTER TABLE grid.ego_pf_hv_result_line
	ADD CONSTRAINT ego_pf_hv_result_line_fkey FOREIGN KEY (result_id) 
	REFERENCES grid.ego_pf_hv_result_meta(result_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_line OWNER TO oeuser;


COMMENT ON TABLE grid.ego_pf_hv_result_line
  IS E'{
    "title": "eGo hv powerflow results - lines",
    "description": "Results of power lines considered in hv powerflow calculations",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "copyright": "\\u00a9 2016 Open Power System Data",
            "name": "Open Power System Data (OPSD)",
            "license": "MIT Licence",
            "description": " "
        },
        {
            "url": "www.energymap.info",
            "copyright": "",
            "name": "EnergyMap",
            "license": "",
            "description": " "
        },
        {
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "copyright": "",
            "name": "Bundesnetzagentur (BNetzA)",
            "license": "",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "result_id",
                    "unit": "",
                    "description": "unique result id corresponding to result_meta"
                },
                {
                    "name": "line_id",
                    "unit": "",
                    "description": "ID of corresponding line"
                },
                {
                    "name": "bus0",
                    "unit": "",
                    "description": "Name of first bus to which branch is attached"
                },
				{
                    "name": "bus1",
                    "unit": "",
                    "description": "Name of second bus to which branch is attached"
                },
				{
                    "name": "x",
                    "unit": "Ohm",
                    "description": "Series reactance"
                },
				{
                    "name": "r",
                    "unit": "Ohm",
                    "description": "Series resistance"
                },
				{
                    "name": "g",
                    "unit": "Siemens",
                    "description": "Shunt conductivity"
                },
				{
                    "name": "b",
                    "unit": "Siemens",
                    "description": "Shunt susceptance"
                },
				{
                    "name": "s_nom",
                    "unit": "MVA",
                    "description": "Limit of apparent power which can pass through branch"
                },
				{
                    "name": "s_nom_extendable",
                    "unit": "",
                    "description": "Switch to allow capacity s_nom to be extended"
                },
				{
                    "name": "s_nom_min",
                    "unit": "MVA",
                    "description": "If s_nom is extendable, set its minimum value"
                },
				{
                    "name": "s_nom_max",
                    "unit": "MVA",
                    "description": "If s_nom is extendable in OPF, set its maximum value"
                },
				{
                    "name": "capital_cost",
                    "unit": "€/MVA",
                    "description": "Capital cost of extending s_nom by 1 MVA"
                },
				{
                    "name": "length",
                    "unit": "km",
                    "description": "Length of line"
                },
				{
                    "name": "cables",
                    "unit": "",
                    "description": "Number of cables per line"
                },
				{
                    "name": "frequency",
                    "unit": "Hz",
                    "description": "Frequency of line"
                },
				{
                    "name": "terrain_factor",
                    "unit": "",
                    "description": "PyPSA terrain_factor"
                },
				{
                    "name": "x_pu",
                    "unit": "per unit",
                    "description": "Per unit series reactance calculated by PyPSA from x and bus.v_nom"
                },
				{
                    "name": "r_pu",
                    "unit": "per unit",
                    "description": "Per unit series resistance calculated by PyPSA from r and bus.v_nom"
                },
				{
                    "name": "g_pu",
                    "unit": "per unit",
                    "description": "Per unit shunt conductivity calculated by PyPSA from g and bus.v_nom"
                },
				{
                    "name": "b_pu",
                    "unit": "per unit",
                    "description": "Per unit shunt susceptance calculated by PyPSA from b and bus.v_nom"
                },
				{
                    "name": "s_nom_opt",
                    "unit": "MVA",
                    "description": "Optimised capacity for apparent power"
                },
				{
                    "name": "geom",
                    "unit": "geom",
                    "description": "geometry that depict the real route of the line"
                },
				{
                    "name": "topo",
                    "unit": "topo",
                    "description": "topology that depicts a direct connection between both busses"
                }
				
            ],
            "name": "grid.ego_pf_hv_result_line",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';


-- select description
SELECT obj_description('grid.ego_pf_hv_result_line' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_line','ego_dp_structure_versioning.sql','hv pf result line');
*/


--DROP TABLE  IF EXISTS grid.ego_pf_hv_result_line_t;
CREATE TABLE grid.ego_pf_hv_result_line_t
(
  result_id bigint NOT NULL,
  line_id bigint NOT NULL,
  p0 double precision[],
  q0 double precision[],
  p1 double precision[],
  q1 double precision[],
  CONSTRAINT ego_pf_hv_result_line_t_pkey PRIMARY KEY (result_id, line_id)
)
WITH (
  OIDS=FALSE
);

--FK
ALTER TABLE grid.ego_pf_hv_result_line_t
	ADD CONSTRAINT ego_pf_hv_result_line_t_fkey FOREIGN KEY (result_id) 
	REFERENCES grid.ego_pf_hv_result_meta(result_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_line_t OWNER TO oeuser;

COMMENT ON TABLE grid.ego_pf_hv_result_line_t
  IS E'{
    "title": "eGo hv powerflow results - line_t",
    "description": "Results of power line_t considered in hv powerflow calculations",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "copyright": "\\u00a9 2016 Open Power System Data",
            "name": "Open Power System Data (OPSD)",
            "license": "MIT Licence",
            "description": " "
        },
        {
            "url": "www.energymap.info",
            "copyright": "",
            "name": "EnergyMap",
            "license": "",
            "description": " "
        },
        {
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "copyright": "",
            "name": "Bundesnetzagentur (BNetzA)",
            "license": "",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "result_id",
                    "unit": "",
                    "description": "unique result id corresponding to result_meta"
                },
                {
                    "name": "line_id",
                    "unit": "",
                    "description": "ID of corresponding line"
                },
                {
                    "name": "p0",
                    "unit": "MW",
                    "description": "active power at bus0 (positive if net generation at bus0)"
                },
				{
                    "name": "q0",
                    "unit": "MVar",
                    "description": "Reactive power at bus0 (positive if branch is withdrawing power from bus0)"
                },
				{
                    "name": "p1",
                    "unit": "MW",
                    "description": "active power at bus1 (positive if net generation at bus1)"
                },
				{
                    "name": "q1",
                    "unit": "MVar",
                    "description": "Reactive power at bus1 (positive if branch is withdrawing power from bus1)"
                }				
            ],
            "name": "grid.ego_pf_hv_result_line_t",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';


-- select description
SELECT obj_description('grid.ego_pf_hv_result_line_t' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_line_t','ego_dp_structure_versioning.sql','hv pf result line_t');
*/

--DROP TABLE  IF EXISTS grid.ego_pf_hv_result_load;
CREATE TABLE grid.ego_pf_hv_result_load
(
  result_id bigint NOT NULL,
  load_id bigint NOT NULL,
  bus bigint,
  sign double precision,
  e_annual double precision,
  CONSTRAINT ego_pf_hv_result_load_pkey PRIMARY KEY (load_id, result_id)
)
WITH (
  OIDS=FALSE
);

--FK
ALTER TABLE grid.ego_pf_hv_result_load
	ADD CONSTRAINT ego_pf_hv_result_load_fkey FOREIGN KEY (result_id) 
	REFERENCES grid.ego_pf_hv_result_meta(result_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_load OWNER TO oeuser;

COMMENT ON TABLE grid.ego_pf_hv_result_load
  IS E'{
    "title": "eGo hv powerflow results - load",
    "description": "Results of loads considered in hv powerflow calculations",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "copyright": "\\u00a9 2016 Open Power System Data",
            "name": "Open Power System Data (OPSD)",
            "license": "MIT Licence",
            "description": " "
        },
        {
            "url": "www.energymap.info",
            "copyright": "",
            "name": "EnergyMap",
            "license": "",
            "description": " "
        },
        {
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "copyright": "",
            "name": "Bundesnetzagentur (BNetzA)",
            "license": "",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "result_id",
                    "unit": "",
                    "description": "unique result id corresponding to result_meta"
                },
                {
                    "name": "load_id",
                    "unit": "",
                    "description": "ID of load"
                },
                {
                    "name": "bus",
                    "unit": "",
                    "description": "ID of associated bus"
                },
				{
                    "name": "sign",
                    "unit": "",
                    "description": "power sign"
                },
				{
                    "name": "e_annual",
                    "unit": "GWh",
                    "description": "annual electricity consumption"
                }				
            ],
            "name": "grid.ego_pf_hv_result_load",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';


-- select description
SELECT obj_description('grid.ego_pf_hv_result_load' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_load','ego_dp_structure_versioning.sql','hv pf result load');
*/

--DROP TABLE  IF EXISTS grid.ego_pf_hv_result_load_t;
CREATE TABLE grid.ego_pf_hv_result_load_t
(
  result_id bigint NOT NULL,
  load_id bigint NOT NULL,
  p_set double precision[],
  q_set double precision[],
  p double precision[],
  q double precision[],
  CONSTRAINT ego_pf_hv_result_load_t_pkey PRIMARY KEY (load_id, result_id)
)
WITH (
  OIDS=FALSE
);

--FK
ALTER TABLE grid.ego_pf_hv_result_load_t
	ADD CONSTRAINT ego_pf_hv_result_load_t_fkey FOREIGN KEY (result_id) 
	REFERENCES grid.ego_pf_hv_result_meta(result_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_load_t OWNER TO oeuser;

COMMENT ON TABLE grid.ego_pf_hv_result_load_t
  IS E'{
    "title": "eGo hv powerflow results - load_t",
    "description": "Results of load_t considered in hv powerflow calculations",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "copyright": "\\u00a9 2016 Open Power System Data",
            "name": "Open Power System Data (OPSD)",
            "license": "MIT Licence",
            "description": " "
        },
        {
            "url": "www.energymap.info",
            "copyright": "",
            "name": "EnergyMap",
            "license": "",
            "description": " "
        },
        {
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "copyright": "",
            "name": "Bundesnetzagentur (BNetzA)",
            "license": "",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "result_id",
                    "unit": "",
                    "description": "unique result id corresponding to result_meta"
                },
                {
                    "name": "load_id",
                    "unit": "",
                    "description": "ID of load"
                },
                {
                    "name": "p_set",
                    "unit": "MW",
                    "description": "active power set point"
                },
				{
                    "name": "q_set",
                    "unit": "MVar",
                    "description": "reactive power set point"
                },
				{
                    "name": "p",
                    "unit": "MW",
                    "description": "active power at bus (positive if net generation at bus)"
                },	
				{
                    "name": "q",
                    "unit": "MVar",
                    "description": "reactive power (positive if net generation at bus)"
                }
            ],
            "name": "grid.ego_pf_hv_result_load_t",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';


-- select description
SELECT obj_description('grid.ego_pf_hv_result_load_t' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_load_t','ego_dp_structure_versioning.sql','hv pf result load_t');
*/


--DROP TABLE  IF EXISTS grid.ego_pf_hv_result_storage;
CREATE TABLE grid.ego_pf_hv_result_storage
(
  result_id bigint NOT NULL,
  storage_id bigint NOT NULL,
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
  soc_initial double precision,
  soc_cyclic boolean DEFAULT false,
  max_hours double precision,
  efficiency_store double precision,
  efficiency_dispatch double precision,
  standing_loss double precision,
  p_nom_opt double precision,
  CONSTRAINT ego_pf_hv_result_storage_pkey PRIMARY KEY (result_id, storage_id)
)
WITH (
  OIDS=FALSE
);


--FK
ALTER TABLE grid.ego_pf_hv_result_storage
	ADD CONSTRAINT ego_pf_hv_result_storage_fkey FOREIGN KEY (result_id) 
	REFERENCES grid.ego_pf_hv_result_meta(result_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_storage OWNER TO oeuser;


COMMENT ON TABLE grid.ego_pf_hv_result_storage
  IS E'{
    "title": "eGo hv powerflow results - storage",
    "description": "Results of storages relevant for eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "copyright": "\\u00a9 2016 Open Power System Data",
            "name": "Open Power System Data (OPSD)",
            "license": "MIT Licence",
            "description": " "
        },
        {
            "url": "www.energymap.info",
            "copyright": "",
            "name": "EnergyMap",
            "license": "",
            "description": " "
        },
        {
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "copyright": "",
            "name": "Bundesnetzagentur (BNetzA)",
            "license": "",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
               {
                    "name": "result_id",
                    "unit": "",
                    "description": "unique result id corresponding to result_meta"
                },
                {
                    "name": "storage_id",
                    "unit": "",
                    "description": "ID of corresponding storage"
                },
                {
                    "name": "bus",
                    "unit": "",
                    "description": "id of associated bus"
                },
                {
                    "name": "dispatch",
                    "unit": "",
                    "description": "Controllability of active power dispatch, must be flexible or variable."
                },
                {
                    "name": "control",
                    "unit": "",
                    "description": "P,Q,V control strategy, must be PQ, PV or Slack."
                },
                {
                    "name": "p_nom",
                    "unit": "MW",
                    "description": "Nominal power"
                },
                {
                    "name": "p_nom_extendable",
                    "unit": "",
                    "description": "Switch to allow capacity p_nom to be extended"
                },
                {
                    "name": "p_nom_min",
                    "unit": "",
                    "description": "If p_nom is extendable, set its minimum value"
                },
                {
                    "name": "p_nom_max",
                    "unit": "",
                    "description": "If p_nom is extendable, set its maximum value (e.g. limited by potential)"
                },
                {
                    "name": "p_min_pu_fixed",
                    "unit": "per unit",
                    "description": "If control=flexible this gives the minimum output per unit of p_nom"
                },
                {
                    "name": "p_max_pu_fixed",
                    "unit": "per unit",
                    "description": "If control=flexible this gives the maximum output per unit of p_nom, equivalent to a de-rating factor."
                },
                {
                    "name": "sign",
                    "unit": "",
                    "description": "power sign"
                },
                {
                    "name": "source",
                    "unit": "",
                    "description": "prime mover energy carrier"
                },
                {
                    "name": "marginal_cost",
                    "unit": "EUR/MWh",
                    "description": "Marginal cost of production of 1 MWh"
                },
                {
                    "name": "capital_cost",
                    "unit": "EUR/MW",
                    "description": "Capital cost of extending p_nom by 1 MW"
                },
                {
                    "name": "efficiency",
                    "unit": "per unit",
                    "description": "Ratio between primary energy and electrical energy"
                },
                 {
                    "name": "soc_initial",
                    "unit": "MWh",
                    "description": "State of charge before the snapshots in the OPF"
                },
                 {
                    "name": "soc_cyclic",
                    "unit": "",
                    "description": "Switch: if True, then state_of_charge_initial is ignored and the initial state of charge is set to the final state of charge for the group of snapshots in the OPF"
                },
                 {
                    "name": "max_hours",
                    "unit": "hours",
                    "description": "Maximum state of charge capacity in terms of hours at full output capacity p_nom"
                },
                 {
                    "name": "efficiency_store",
                    "unit": "per unit",
                    "description": "Efficiency of storage on the way into the storage"
                },
                 {
                    "name": "efficiency_dispatch",
                    "unit": "per unit",
                    "description": "Efficiency of storage on the way out of the storage"
                },
                 {
                    "name": "standing_loss",
                    "unit": "per unit",
                    "description": "Losses per hour to state of charge"
                },
                {
                    "name": "p_nom_opt",
                    "unit": "MW",
                    "description": "Optimised nominal power"
                }
            ],
            "name": "grid.ego_pf_hv_result_storage",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('grid.ego_pf_hv_result_storage' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_storage','ego_dp_structure_versioning.sql','hv pf result storage');
*/

--DROP TABLE  IF EXISTS grid.ego_pf_hv_result_storage_t;
CREATE TABLE grid.ego_pf_hv_result_storage_t
(
  result_id bigint NOT NULL,
  storage_id bigint NOT NULL,
  p_set double precision[],
  q_set double precision[],
  p_min_pu double precision[],
  p_max_pu double precision[],
  soc_set double precision[],
  inflow double precision[],
  p double precision[],
  q double precision[],
  state_of_charge double precision[],
  spill double precision[],
  CONSTRAINT ego_pf_hv_result_storage_t_pkey PRIMARY KEY (result_id, storage_id)
)
WITH (
  OIDS=FALSE
);

--FK
ALTER TABLE grid.ego_pf_hv_result_storage_t
	ADD CONSTRAINT ego_pf_hv_result_storage_t_fkey FOREIGN KEY (result_id) 
	REFERENCES grid.ego_pf_hv_result_meta(result_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_storage_t OWNER TO oeuser;


COMMENT ON TABLE grid.ego_pf_hv_result_storage_t
  IS E'{
    "title": "eGo hv powerflow results - storage_t",
    "description": "Results of storage_t relevant for eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "copyright": "\\u00a9 2016 Open Power System Data",
            "name": "Open Power System Data (OPSD)",
            "license": "MIT Licence",
            "description": " "
        },
        {
            "url": "www.energymap.info",
            "copyright": "",
            "name": "EnergyMap",
            "license": "",
            "description": " "
        },
        {
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "copyright": "",
            "name": "Bundesnetzagentur (BNetzA)",
            "license": "",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
               {
                    "name": "result_id",
                    "unit": "",
                    "description": "unique result id corresponding to result_meta"
                },
                {
                    "name": "storage_id",
                    "unit": "",
                    "description": "ID of corresponding storage"
                },
                {
                    "name": "p_set",
                    "unit": "MW",
                    "description": "active power set point"
                },
                {
                    "name": "q_set",
                    "unit": "MVar",
                    "description": "reactive power set point"
                },
                {
                    "name": "p_min_pu",
                    "unit": "per unit",
                    "description": "If control=variable this gives the minimum output for each snapshot per unit of p_nom for the OPF"
                },
                {
                    "name": "p_max_pu",
                    "unit": "per unit",
                    "description": "If control=variable this gives the maximum output for each snapshot per unit of p_nom for the OPF, relevant e.g. if for renewables the power output is limited by the weather"
                },
                {
                    "name": "soc_set",
                    "unit": "MWh",
                    "description": "State of charge set points for snapshots in the OPF"
                },
                {
                    "name": "inflow",
                    "unit": "MW",
                    "description": "Inflow to the state of charge, e.g. due to river inflow in hydro reservoir."
                },
                {
                    "name": "p",
                    "unit": "MW",
                    "description": "active power at bus (positive if net generation at bus)"
                },
                {
                    "name": "q",
                    "unit": "Mvar",
                    "description": "reactive power (positive if net generation at bus)"
                },
                {
                    "name": "state_of_charge",
                    "unit": "BBB",
                    "description": "State of charge as calculated by the OPF"
                },
                {
                    "name": "spill",
                    "unit": "MW",
                    "description": "Spillage for each snapshot"
                }                      
            ],
            "name": "grid.ego_pf_hv_result_storage_t",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('grid.ego_pf_hv_result_storage_t' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_storage_t','ego_dp_structure_versioning.sql','hv pf result storage_t');
*/

--DROP TABLE  IF EXISTS grid.ego_pf_hv_result_transformer;
CREATE TABLE grid.ego_pf_hv_result_transformer
(
  result_id bigint NOT NULL,
  trafo_id bigint NOT NULL,
  bus0 bigint,
  bus1 bigint,
  x numeric,
  r numeric,
  g numeric,
  b numeric,
  s_nom numeric,
  s_nom_extendable boolean,
  s_nom_min double precision,
  s_nom_max double precision,
  tap_ratio double precision,
  phase_shift double precision,
  capital_cost double precision,
  x_pu numeric,
  r_pu numeric,
  g_pu numeric,
  b_pu numeric,
  s_nom_opt numeric,
  geom geometry(MultiLineString,4326),
  topo geometry(LineString,4326),
  CONSTRAINT ego_pf_hv_result_transformer_pkey PRIMARY KEY (result_id, trafo_id)
)
WITH (
  OIDS=FALSE
);

--FK
ALTER TABLE grid.ego_pf_hv_result_transformer
	ADD CONSTRAINT ego_pf_hv_result_transformer_fkey FOREIGN KEY (result_id) 
	REFERENCES grid.ego_pf_hv_result_meta(result_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_transformer OWNER TO oeuser;


COMMENT ON TABLE grid.ego_pf_hv_result_transformer
  IS E'{
    "title": "eGo hv powerflow results - transformer",
    "description": "Results of transformers considered in hv powerflow calculations",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "copyright": "\\u00a9 2016 Open Power System Data",
            "name": "Open Power System Data (OPSD)",
            "license": "MIT Licence",
            "description": " "
        },
        {
            "url": "www.energymap.info",
            "copyright": "",
            "name": "EnergyMap",
            "license": "",
            "description": " "
        },
        {
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "copyright": "",
            "name": "Bundesnetzagentur (BNetzA)",
            "license": "",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "result_id",
                    "unit": "",
                    "description": "unique result id corresponding to result_meta"
                },
                {
                    "name": "line_id",
                    "unit": "",
                    "description": "ID of corresponding transformer"
                },
                {
                    "name": "bus0",
                    "unit": "",
                    "description": "Name of first bus to which branch is attached"
                },
				{
                    "name": "bus1",
                    "unit": "",
                    "description": "Name of second bus to which branch is attached"
                },
				{
                    "name": "x",
                    "unit": "Ohm",
                    "description": "Series reactance"
                },
				{
                    "name": "r",
                    "unit": "Ohm",
                    "description": "Series resistance"
                },
				{
                    "name": "g",
                    "unit": "Siemens",
                    "description": "Shunt conductivity"
                },
				{
                    "name": "b",
                    "unit": "Siemens",
                    "description": "Shunt susceptance"
                },
				{
                    "name": "s_nom",
                    "unit": "MVA",
                    "description": "Limit of apparent power which can pass through branch"
                },
				{
                    "name": "s_nom_extendable",
                    "unit": "",
                    "description": "Switch to allow capacity s_nom to be extended"
                },
				{
                    "name": "s_nom_min",
                    "unit": "MVA",
                    "description": "If s_nom is extendable, set its minimum value"
                },
				{
                    "name": "s_nom_max",
                    "unit": "MVA",
                    "description": "If s_nom is extendable in OPF, set its maximum value"
                },
				{
                    "name": "s_nom_max",
                    "unit": "MVA",
                    "description": "If s_nom is extendable in OPF, set its maximum value"
                },
				{
                    "name": "tap_ratio",
                    "unit": "",
                    "description": "Ratio of per unit voltages at each bus"
                },
				{
                    "name": "phase_shift",
                    "unit": "degrees",
                    "description": "Voltage phase angle shift"
                },
				{
                    "name": "capital_cost",
                    "unit": "€/MVA",
                    "description": "Capital cost of extending s_nom by 1 MVA"
                },
				{
                    "name": "x_pu",
                    "unit": "per unit",
                    "description": "Per unit series reactance calculated by PyPSA from x and bus.v_nom"
                },
				{
                    "name": "r_pu",
                    "unit": "per unit",
                    "description": "Per unit series resistance calculated by PyPSA from r and bus.v_nom"
                },
				{
                    "name": "g_pu",
                    "unit": "per unit",
                    "description": "Per unit shunt conductivity calculated by PyPSA from g and bus.v_nom"
                },
				{
                    "name": "b_pu",
                    "unit": "per unit",
                    "description": "Per unit shunt susceptance calculated by PyPSA from b and bus.v_nom"
                },
				{
                    "name": "s_nom_opt",
                    "unit": "MVA",
                    "description": "Optimised capacity for apparent power"
                },
				{
                    "name": "geom",
                    "unit": "geom",
                    "description": "geometry that depict the real route of the line"
                },
				{
                    "name": "topo",
                    "unit": "topo",
                    "description": "topology that depicts a direct connection between both busses"
                }
            ],
            "name": "grid.ego_pf_hv_result_transformer",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';


-- select description
SELECT obj_description('grid.ego_pf_hv_result_transformer' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_transformer','ego_dp_structure_versioning.sql','hv pf result transformer');
*/

--DROP TABLE  IF EXISTS grid.ego_pf_hv_result_transformer_t;
CREATE TABLE grid.ego_pf_hv_result_transformer_t
(
  result_id bigint NOT NULL,
  trafo_id bigint NOT NULL,
  p0 double precision[],
  q0 double precision[],
  p1 double precision[],
  q1 double precision[],
  CONSTRAINT ego_pf_hv_result_transformer_t_pkey PRIMARY KEY (result_id, trafo_id)
)
WITH (
  OIDS=FALSE
);

--FK
ALTER TABLE grid.ego_pf_hv_result_transformer_t
	ADD CONSTRAINT ego_pf_hv_result_transformer_t_fkey FOREIGN KEY (result_id) 
	REFERENCES grid.ego_pf_hv_result_meta(result_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
-- grant (oeuser)
ALTER TABLE	grid.ego_pf_hv_result_transformer_t OWNER TO oeuser;

COMMENT ON TABLE grid.ego_pf_hv_result_transformer_t
  IS E'{
    "title": "eGo hv powerflow results - transformer_t",
    "description": "Results of power line_t considered in hv powerflow calculations",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": "Germany"
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "url": "https://github.com/openego/data_processing",
            "copyright": "\\u00a9 Reiner Lemoine Institut",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "copyright": "\\u00a9 2016 Open Power System Data",
            "name": "Open Power System Data (OPSD)",
            "license": "MIT Licence",
            "description": " "
        },
        {
            "url": "www.energymap.info",
            "copyright": "",
            "name": "EnergyMap",
            "license": "",
            "description": " "
        },
        {
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "copyright": "",
            "name": "Bundesnetzagentur (BNetzA)",
            "license": "",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2017-11-21",
            "comment": "Create table",
            "name": "Mariusves",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "result_id",
                    "unit": "",
                    "description": "unique result id corresponding to result_meta"
                },
                {
                    "name": "line_id",
                    "unit": "",
                    "description": "ID of corresponding transformer"
                },
                {
                    "name": "p0",
                    "unit": "MW",
                    "description": "active power at bus0 (positive if net generation at bus0)"
                },
				{
                    "name": "q0",
                    "unit": "MVar",
                    "description": "Reactive power at bus0 (positive if branch is withdrawing power from bus0)"
                },
				{
                    "name": "p1",
                    "unit": "MW",
                    "description": "active power at bus1 (positive if net generation at bus1)"
                },
				{
                    "name": "q1",
                    "unit": "MVar",
                    "description": "Reactive power at bus1 (positive if branch is withdrawing power from bus1)"
                }				
            ],
            "name": "grid.ego_pf_hv_result_transformer_t",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';


-- select description
SELECT obj_description('grid.ego_pf_hv_result_transformer_t' ::regclass) ::json;

/*
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','result','grid','ego_pf_hv_result_transformer_t','ego_dp_structure_versioning.sql','hv pf result transformer_t');
*/
