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
COMMENT ON TABLE model_draft.ego_grid_pf_hv_scenario_settings IS '{
    "title": "Scenario settings hv powerflow",
    "description": "Overview of scenarios for the hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "26.04.2017",
            "comment": "Create table"
        },
        {
            "name": "IlkaCu",
            "email": "",
            "date": "2018.02.03",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_scenario_settings",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "scenario name",
                    "unit": ""
                },
                {
                    "name": "bus",
                    "description": "scenario for bus dataset",
                    "unit": ""
                },
                {
                    "name": "bus_v_mag_set",
                    "description": "scenario for bus dataset",
                    "unit": ""
                },
                {
                    "name": "generator",
                    "description": "scenario for generator dataset",
                    "unit": ""
                },
		{   
		    "name": "generator_pq_set",
                    "description": "scenario for generator dataset",
                    "unit": "" 
		},
                {   
		    "name": "line",
                    "description": "scenario for line dataset",
                    "unit": "" 
		},
                {
		    "name": "load",
                    "description": "scenario for load dataset",
                    "unit": "" 
		},
                {
		    "name": "load_pq_set",
                    "description": "scenario for load dataset",
                    "unit": "" 
		},
                {
		    "name": "storage",
                    "description": "scenario for storage dataset",
                    "unit": "" 
		},
                {
		    "name": "storage_pq_set",
                    "description": "scenario for storage dataset",
                    "unit": "" 
		},
                {
		    "name": "temp_resolution",
                    "description": "scenario for temp_resolution",
                    "unit": "" 
		},
                {
		    "name": "transformer",
                    "description": "scenario for transformer",
                    "unit": "" 
		}
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_scenario_settings' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_scenario_settings','ego_dp_powerflow_hv_setup.sql',' ');


-- PF HV source
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_source CASCADE; 
CREATE TABLE 		model_draft.ego_grid_pf_hv_source (
	source_id bigint NOT NULL,
	name text, -- Unit: n/a...
	co2_emissions double precision, -- Unit: tonnes/MWh...
	commentary text,
	CONSTRAINT source_data_pkey PRIMARY KEY (source_id) ) WITH ( OIDS=FALSE );

-- metadata
COMMENT ON TABLE model_draft.ego_grid_pf_hv_source IS '{
    "title": "eGo hv powerflow - sources",
    "description": "sources in eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "26.04.2017",
            "comment": "Create table"
        },
        {
            "name": "KilianZimmerer",
            "email": "",
            "date": "2017-6-27",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_source",
            "fromat": "sql",
            "fields": [
                {
                    "name": "source_id",
                    "description": "unique source id",
                    "unit": ""
                },
                {
                    "name": "name",
                    "description": "source name",
                    "unit": ""
                },
                {
                    "name": "co2_emissions",
                    "description": "technology specific CO2 emissions ",
                    "unit": "tonnes/MWh"
                },
                {
                    "name": "commentary",
                    "description": "...",
                    "unit": ""
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_source' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_source','ego_dp_powerflow_hv_setup.sql',' ');


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
COMMENT ON TABLE model_draft.ego_grid_pf_hv_bus IS '{
    "title": "eGo hv powerflow - bus",
    "description": "Buses relevant for eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Reiner Lemoine Institut"
        },
        {
            "name": "OpenStreetMap",
            "description": " ",
            "url": "http://www.openstreetmap.org/",
            "license": "Open Database License (ODbL) v1.0",
            "copyright": "\u00a9 OpenStreetMap contributors"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "26.04.2017",
            "comment": "Create table"
        },
        {
            "name": "KilianZimmerer",
            "email": "",
            "date": "2017-6-27",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_bus",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "name of corresponding scenario",
                    "unit": ""
                },
                {
                    "name": "bus_id",
                    "description": "unique id for bus, equivalent to id from osmtgmod",
                    "unit": ""
                },
                {
                    "name": "v_nom",
                    "description": "nominal voltage",
                    "unit": "kV"
                },
                {
                    "name": "current_type",
                    "description": "current type - AC or DC",
                    "unit": ""
                },
                {
                    "name": "v_mag_pu_min",
                    "description": "Minimum desired voltage, per unit of v_nom",
                    "unit": "per unit"
                },
                {
                    "name": "v_mag_pu_max",
                    "description": "Maximum desired voltage, per unit of v_nom",
                    "unit": "per unit"
                },
                {
                    "name": "geom",
                    "description": "geometry of bus",
                    "unit": "..."
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- PF HV busmap
DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_busmap CASCADE;
CREATE TABLE model_draft.ego_grid_pf_hv_busmap (
	scn_name text,
	bus0 text,
	bus1 text,
	path_length numeric,
	PRIMARY KEY(scn_name, bus0, bus1));

-- metadata
COMMENT ON TABLE model_draft.ego_grid_pf_hv_busmap IS '{
    "title": "HV powerflow busmap",
    "description": "Bus to bus assignment by id to support PyPSA clustering",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
    },
    "contributors": [
        {
            "name": "s3pp",
            "email": "",
            "date": "02.06.2017",
            "comment": "Initial statement"
        },
        {
            "name": "IlkaCu",
            "email": "",
            "date": "2018.02.03",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_busmap",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "name of scenario",
                    "unit": ""
                },
                {
                    "name": "bus0",
                    "description": "source bus id",
                    "unit": ""
                },
                {
                    "name": "bus1",
                    "description": "target bus id",
                    "unit": ""
                },
                {
                    "name": "path_length",
                    "description": "Length of line between source and target bus",
                    "unit": ""
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_bus' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_bus','ego_dp_powerflow_hv_setup.sql',' ');


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
COMMENT ON TABLE model_draft.ego_grid_pf_hv_generator IS '{
    "title": "eGo hv powerflow - generator",
    "description": "Generators relevant for eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Reiner Lemoine Institut"
        },
        {
            "name": "OpenStreetMap",
            "description": " ",
            "url": "http://www.openstreetmap.org/",
            "license": "Open Database License (ODbL) v1.0",
            "copyright": "\u00a9 OpenStreetMap contributors"
        },
        {
            "name": "Open Power System Data (OPSD)",
            "description": " ",
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "license": "MIT Licence",
            "copyright": "\u00a9 2016 Open Power System Data"
        },
        {
            "name": "EnergyMap",
            "description": " ",
            "url": "www.energymap.info",
            "license": "",
            "copyright": ""
        },
        {
            "name": "Bundesnetzagentur (BNetzA)",
            "description": " ",
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "license": "",
            "copyright": ""
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "26.04.2017",
            "comment": "Create table"
        },
        {
            "name": "KilianZimmerer",
            "email": "",
            "date": "2017-6-27",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_generator",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "name of corresponding scenario",
                    "unit": ""
                },
                {
                    "name": "generator_id",
                    "description": "ID of corresponding generator",
                    "unit": ""
                },
                {
                    "name": "bus",
                    "description": "id of associated bus",
                    "unit": ""
                },
                {
                    "name": "dispatch",
                    "description": "Controllability of active power dispatch, must be flexible or variable.",
                    "unit": ""
                },
                {
                    "name": "control",
                    "description": "P,Q,V control strategy, must be PQ, PV or Slack.",
                    "unit": ""
                },
                {
                    "name": "p_nom",
                    "description": "Nominal power",
                    "unit": "MW"
                },
                {
                    "name": "p_nom_extendable",
                    "description": "Switch to allow capacity p_nom to be extended",
                    "unit": ""
                },
                {
                    "name": "p_nom_min",
                    "description": "If p_nom is extendable, set its minimum value",
                    "unit": ""
                },
                {
                    "name": "p_nom_max",
                    "description": "If p_nom is extendable, set its maximum value (e.g. limited by potential)",
                    "unit": ""
                },
                {
                    "name": "p_min_pu_fixed",
                    "description": "If control=flexible this gives the minimum output per unit of p_nom",
                    "unit": "per unit"
                },
                {
                    "name": "p_max_pu_fixed",
                    "description": "If control=flexible this gives the maximum output per unit of p_nom, equivalent to a de-rating factor.",
                    "unit": "per unit"
                },
                {
                    "name": "sign",
                    "description": "power sign",
                    "unit": ""
                },
                {
                    "name": "source",
                    "description": "prime mover energy carrier",
                    "unit": ""
                },
                {
                    "name": "marginal_cost",
                    "description": "Marginal cost of production of 1 MWh",
                    "unit": "EUR/MWh"
                },
                {
                    "name": "capital_cost",
                    "description": "Capital cost of extending p_nom by 1 MW",
                    "unit": "EUR/MW"
                },
                {
                    "name": "efficiency",
                    "description": "Ratio between primary energy and electrical energy",
                    "unit": "per unit"
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_generator' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_generator','ego_dp_powerflow_hv_setup.sql',' ');


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
COMMENT ON TABLE model_draft.ego_grid_pf_hv_line IS '{
    "title": "eGo hv powerflow - lines",
    "description": "lines in eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
        },
        {
            "name": "OpenStreetMap",
            "description": " ",
            "url": "http://www.openstreetmap.org/",
            "license": "Open Database License (ODbL) v1.0",
            "copyright": "\u00a9 OpenStreetMap contributors"
        },
        {
            "name": "osmTGmod",
            "description": " ",
            "url": "https://github.com/openego/osmTGmod",
            "license": "Apache License 2.0",
            "copyright": "\u00a9 Wuppertal Institut"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "© DLR Institute for Networked Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "26.04.2017",
            "comment": "Create table"
        },
        {
            "name": "KilianZimmerer",
            "email": "",
            "date": "2017-6-27",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_line",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "name of corresponding scenario",
                    "unit": ""
                },
                {
                    "name": "line_id",
                    "description": "ID of line",
                    "unit": ""
                },
                {
                    "name": "bus0",
                    "description": "name of first bus to which branch is attached",
                    "unit": ""
                },
                {
                    "name": "bus1",
                    "description": "name of second bus to which branch is attached",
                    "unit": ""
                },
                {
                    "name": "x",
                    "description": "Series reactance",
                    "unit": "Ohm"
                },
                {
                    "name": "r",
                    "description": "Series resistance",
                    "unit": "Ohm"
                },
                {
                    "name": "g",
                    "description": "Shunt conductivity",
                    "unit": "Siemens"
                },
                {
                    "name": "b",
                    "description": "Shunt susceptance",
                    "unit": "Siemens"
                },
                {
                    "name": "s_nom",
                    "description": "Limit of apparent power which can pass through branch",
                    "unit": "MVA"
                },
                {
                    "name": "s_nom_extendable",
                    "description": "Switch to allow capacity s_nom to be extended",
                    "unit": ""
                },
                {
                    "name": "s_nom_min",
                    "description": "If s_nom is extendable, set its minimum value",
                    "unit": "MVA"
                },
                {
                    "name": "s_nom_max",
                    "description": "If s_nom is extendable in OPF, set its maximum value",
                    "unit": "MVA"
                },
                {
                    "name": "capital_cost",
                    "description": "capital cost of extending s_nom by 1 MVA",
                    "unit": "EUR/MVA"
                },
                {
                    "name": "length",
                    "description": "length of line",
                    "unit": "km"
                },
                {
                    "name": "cables",
                    "description": "...",
                    "unit": ""
                },
                {
                    "name": "frequency",
                    "description": "frequency of line",
                    "unit": ""
                },
                {
                    "name": "terrain_factor",
                    "description": "...",
                    "unit": ""
                },
                {
                    "name": "geom",
                    "description": "geometry that depict the real route of the line",
                    "unit": ""
                },
                {
                    "name": "topo",
                    "description": "topology that depicts a direct connection between both busses",
                    "unit": "..."
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';


-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_line' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_line','ego_dp_powerflow_hv_setup.sql',' ');


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
COMMENT ON TABLE model_draft.ego_grid_pf_hv_load IS '{
    "title": "eGo hv powerflow - loads",
    "description": "loads in eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
        },
        {
            "name": "OpenStreetMap",
            "description": " ",
            "url": "http://www.openstreetmap.org/",
            "license": "Open Database License (ODbL) v1.0",
            "copyright": "\u00a9 OpenStreetMap contributors"
        },
        {
            "name": "L\u00e4nderarbeitskreis Energiebilanzen",
            "description": " ",
            "url": "http://www.lak-energiebilanzen.de/seiten/energiebilanzenLaender.cfm",
            "license": " ",
            "copyright": " "
        },
        {
            "name": "Bayerisches Landesamt f\u00fcr Statistik und Datenverarbeitung",
            "description": " ",
            "url": "http://www.stmwi.bayern.de/fileadmin/user_upload/stmwivt/Themen/Energie_und_Rohstoffe/Dokumente_und_Cover/Energiebilanz/2014/B-03_bilanzjo_mgh_2014-03-07.pdf",
            "license": " ",
            "copyright": " "
        },
        {
            "name": "Hessisches Statistisches Landesamt",
            "description": " ",
            "url": "http://www.statistik-hessen.de/publikationen/download/277/index.html",
            "license": " ",
            "copyright": " "
        },
        {
            "name": "Statistisches Amt Mecklenburg-Vorpommern",
            "description": " ",
            "url": "https://www.destatis.de/GPStatistik/servlets/MCRFileNodeServlet/MVHeft_derivate_00000168/E453_2011_00a.pdf;jsessionid=CD300CD3A06FF85FDEA864FF4D91D880",
            "license": " ",
            "copyright": " "
        },
        {
            "name": "Nieders\u00e4chsisches Ministerium f\u00fcr Umwelt, Energie und Klimaschutz",
            "description": " ",
            "url": "http://www.umwelt.niedersachsen.de/energie/daten/co2bilanzen/niedersaechsische-energie--und-co2-bilanzen-2009-6900.html",
            "license": " ",
            "copyright": " "
        },
        {
            "name": "Information und Technik Nordrhein-Westfalen",
            "description": " ",
            "url": "https://webshop.it.nrw.de/gratis/E449%20201100.pdf",
            "license": " ",
            "copyright": " "
        },
        {
            "name": "Statistisches Landesamt Sachsen-Anhalt",
            "description": " ",
            "url": "http://www.stala.sachsen-anhalt.de/download/stat_berichte/6E402_j_2011.pdf",
            "license": " ",
            "copyright": " "
        },
        {
            "name": "Th\u00fcringer Landesamt f\u00fcr Statistik",
            "description": " ",
            "url": "http://www.statistik.thueringen.de/webshop/pdf/2011/05402_2011_00.pdf",
            "license": " ",
            "copyright": " "
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "26.04.2017",
            "comment": "Create table"
        },
        {
            "name": "KilianZimmerer",
            "email": "",
            "date": "2017-6-27",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_load",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "name of corresponding scenario",
                    "unit": ""
                },
                {
                    "name": "load_id",
                    "description": "unique id",
                    "unit": ""
                },
                {
                    "name": "bus",
                    "description": "id of associated bus",
                    "unit": ""
                },
                {
                    "name": "sign",
                    "description": "power sign",
                    "unit": ""
                },
                {
                    "name": "e_annual",
                    "description": "annual electricity consumption",
                    "unit": "GWh"
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_load' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_load','ego_dp_powerflow_hv_setup.sql',' ');


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
COMMENT ON TABLE model_draft.ego_grid_pf_hv_storage IS '{
    "title": "eGo hv powerflow - storage",
    "description": "Storages relevant for eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Reiner Lemoine Institut"
        },
        {
            "name": "OpenStreetMap",
            "description": " ",
            "url": "http://www.openstreetmap.org/",
            "license": "Open Database License (ODbL) v1.0",
            "copyright": "\u00a9 OpenStreetMap contributors"
        },
        {
            "name": "Open Power System Data (OPSD)",
            "description": " ",
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "license": "MIT Licence",
            "copyright": "\u00a9 2016 Open Power System Data"
        },
        {
            "name": "Bundesnetzagentur (BNetzA)",
            "description": " ",
            "url": "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html",
            "license": "",
            "copyright": ""
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\u00a9 Europa-Universitaet Flensburg, Center for Sustainable Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "26.04.2017",
            "comment": "Create table"
        },
        {
            "name": "KilianZimmerer",
            "email": "",
            "date": "2017-6-27",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_storage",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "name of corresponding scenario",
                    "unit": ""
                },
                {
                    "name": "storage_id",
                    "description": "ID of corresponding storage",
                    "unit": ""
                },
                {
                    "name": "bus",
                    "description": "id of associated bus",
                    "unit": ""
                },
                {
                    "name": "dispatch",
                    "description": "Controllability of active power dispatch, must be flexible or variable.",
                    "unit": ""
                },
                {
                    "name": "control",
                    "description": "P,Q,V control strategy, must be PQ, PV or Slack.",
                    "unit": ""
                },
                {
                    "name": "p_nom",
                    "description": "Nominal power",
                    "unit": "MW"
                },
                {
                    "name": "p_nom_extendable",
                    "description": "Switch to allow capacity p_nom to be extended",
                    "unit": ""
                },
                {
                    "name": "p_nom_min",
                    "description": "If p_nom is extendable, set its minimum value",
                    "unit": ""
                },
                {
                    "name": "p_nom_max",
                    "description": "If p_nom is extendable, set its maximum value (e.g. limited by potential)",
                    "unit": ""
                },
                {
                    "name": "p_min_pu_fixed",
                    "description": "If control=flexible this gives the minimum output per unit of p_nom",
                    "unit": "per unit"
                },
                {
                    "name": "p_max_pu_fixed",
                    "description": "If control=flexible this gives the maximum output per unit of p_nom, equivalent to a de-rating factor.",
                    "unit": "per unit"
                },
                {
                    "name": "sign",
                    "description": "power sign",
                    "unit": ""
                },
                {
                    "name": "source",
                    "description": "prime mover energy carrier",
                    "unit": ""
                },
                {
                    "name": "marginal_cost",
                    "description": "Marginal cost of production of 1 MWh",
                    "unit": "EUR/MWh"
                },
                {
                    "name": "capital_cost",
                    "description": "Capital cost of extending p_nom by 1 MW",
                    "unit": "EUR/MW"
                },
                {
                    "name": "efficiency",
                    "description": "Ratio between primary energy and electrical energy",
                    "unit": "per unit"
                },
                {
                    "name": "soc_initial",
                    "description": "State of charge before the snapshots in the OPF.",
                    "unit": "MWh"
                },
                {
                    "name": "soc_cyclic",
                    "description": "Switch: if True, then state_of_charge_initial is ignored and the initial state of charge is set to the final state of charge for the group of snapshots in the OPF",
                    "unit": ""
                },
                {
                    "name": "max_hours",
                    "description": "Maximum state of charge capacity in terms of hours at full output capacity p_nom",
                    "unit": "hours"
                },
                {
                    "name": "efficiency_store",
                    "description": "Efficiency of storage on the way into the storage",
                    "unit": "per unit"
                },
                {
                    "name": "efficiency_dispatch",
                    "description": "Efficiency of storage on the way out of the storage",
                    "unit": "per unit"
                },
                {
                    "name": "standing_loss",
                    "description": "Losses per hour to state of charge",
                    "unit": "per unit"
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_storage' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_storage','ego_dp_powerflow_hv_setup.sql',' ');


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
COMMENT ON TABLE model_draft.ego_grid_pf_hv_temp_resolution IS '{
    "title": "eGo hv powerflow - temp_resolution",
    "description": "Temporal resolution in eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "26.04.2017",
            "comment": "Create table"
        },
        {
            "name": "KilianZimmerer",
            "email": "",
            "date": "2017-6-27",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_temp_resolution",
            "fromat": "sql",
            "fields": [
                {
                    "name": "temp_id",
                    "description": "unique id",
                    "unit": ""
                },
                {
                    "name": "timesteps",
                    "description": "timestep",
                    "unit": ""
                },
                {
                    "name": "resolution",
                    "description": "temporal resolution",
                    "unit": ""
                },
                {
                    "name": "start_time",
                    "description": "start time with style: YYYY-MM-DD HH:MM:SS",
                    "unit": ""
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_temp_resolution' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_temp_resolution','ego_dp_powerflow_hv_setup.sql',' ');


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
COMMENT ON TABLE model_draft.ego_grid_pf_hv_transformer IS '{
    "title": "eGo hv powerflow - transformer",
    "description": "transformer in eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
        },
        {
            "name": "OpenStreetMap",
            "description": " ",
            "url": "http://www.openstreetmap.org/",
            "license": "Open Database License (ODbL) v1.0",
            "copyright": "\u00a9 OpenStreetMap contributors"
        },
        {
            "name": "osmTGmod",
            "description": " ",
            "url": "https://github.com/openego/osmTGmod",
            "license": "Apache License 2.0",
            "copyright": "\u00a9 Wuppertal Institut"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "© DLR Institute for Networked Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "26.04.2017",
            "comment": "Create table"
        },
        {
            "name": "KilianZimmerer",
            "email": "",
            "date": "2017-6-27",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_transformer",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "name of corresponding scenario",
                    "unit": ""
                },
                {
                    "name": "trafo_id",
                    "description": "ID of line",
                    "unit": ""
                },
                {
                    "name": "bus0",
                    "description": "name of first bus to which branch is attached",
                    "unit": ""
                },
                {
                    "name": "bus1",
                    "description": "name of second bus to which branch is attached",
                    "unit": ""
                },
                {
                    "name": "x",
                    "description": "Series reactance",
                    "unit": "Ohm"
                },
                {
                    "name": "r",
                    "description": "Series resistance",
                    "unit": "Ohm"
                },
                {
                    "name": "g",
                    "description": "Shunt conductivity",
                    "unit": "Siemens"
                },
                {
                    "name": "b",
                    "description": "Shunt susceptance",
                    "unit": "Siemens"
                },
                {
                    "name": "s_nom",
                    "description": "Limit of apparent power which can pass through branch",
                    "unit": "MVA"
                },
                {
                    "name": "s_nom_extendable",
                    "description": "Switch to allow capacity s_nom to be extended",
                    "unit": ""
                },
                {
                    "name": "s_nom_min",
                    "description": "If s_nom is extendable, set its minimum value",
                    "unit": "MVA"
                },
                {
                    "name": "s_nom_max",
                    "description": "If s_nom is extendable in OPF, set its maximum value",
                    "unit": "MVA"
                },
                {
                    "name": "tap_ratio",
                    "description": "Ratio of per unit voltages at each bus",
                    "unit": ""
                },
                {
                    "name": "phase_shift",
                    "description": "Voltage phase angle shift",
                    "unit": "degrees"
                },
                {
                    "name": "capital_cost",
                    "description": "capital cost of extending s_nom by 1 MVA",
                    "unit": "EUR/MVA"
                },
                {
                    "name": "geom",
                    "description": "geometry that depict the real route of the line",
                    "unit": ""
                },
                {
                    "name": "topo",
                    "description": "topology that depicts a direct connection between both busses",
                    "unit": "..."
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_transformer' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_transformer','ego_dp_powerflow_hv_setup.sql',' ');


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
COMMENT ON TABLE model_draft.ego_grid_pf_hv_bus_v_mag_set IS '{
    "title": "HV powerflow bus_v_mag_set",
    "description": "Voltage magnitude set point in HV powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "2018.02.03",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_bus_v_mag_set",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "name of scenario",
                    "unit": ""
                },
                {
                    "name": "bus_id",
                    "description": "unique id of corresponding bus",
                    "unit": ""
                },
                {
                    "name": "temp_id",
                    "description": "id of temporal resolution",
                    "unit": ""
                },
                {
                    "name": "v_mag_pu_set",
                    "description": "Voltage magnitude set point, per unit of v_nom",
                    "unit": ""
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_bus_v_mag_set' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_bus_v_mag_set','ego_dp_powerflow_hv_setup.sql',' ');


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
COMMENT ON TABLE model_draft.ego_grid_pf_hv_generator_pq_set IS '{
    "title": "eGo hv powerflow - generator time series",
    "description": "Time series of generators relevant for eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Europa-Universitaet Flensburg, Center for Sustainable Energy Systems"
        },
        {
            "name": "oemof feedinlib",
            "description": " ",
            "url": "https://github.com/oemof/feedinlib",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 oemof developing group"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\u00a9 Europa-Universitaet Flensburg, Center for Sustainable Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "26.04.2017",
            "comment": "Create table"
        },
        {
            "name": "KilianZimmerer",
            "email": "",
            "date": "2017-6-27",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_generator_pq_set",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "name of corresponding scenario",
                    "unit": ""
                },
                {
                    "name": "generator_id",
                    "description": "ID of corresponding generator",
                    "unit": ""
                },
                {
                    "name": "temp_id",
                    "description": "ID of temporal resolution",
                    "unit": ""
                },
                {
                    "name": "p_set",
                    "description": "active power set point (for PF)",
                    "unit": "MW"
                },
                {
                    "name": "q_set",
                    "description": "reactive power set point (for PF)",
                    "unit": "MVar"
                },
                {
                    "name": "p_min_pu",
                    "description": "If control=variable this gives the minimum output for each snapshot per unit of p_nom for the OPF",
                    "unit": "per unit"
                },
                {
                    "name": "p_max_pu",
                    "description": "If control=variable this gives the maximum output for each snapshot per unit of p_nom for the OPF",
                    "unit": "per unit"
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_generator_pq_set' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_generator_pq_set','ego_dp_powerflow_hv_setup.sql',' ');


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
COMMENT ON TABLE model_draft.ego_grid_pf_hv_load_pq_set IS '{
    "title": "eGo hv powerflow - loads",
    "description": "loads in eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing/blob/master/dataprocessing/python_scripts/demand_per_mv_grid_district.py",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Reiner Lemoine Institut"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\u00a9 Reiner Lemoine Institut"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "26.04.2017",
            "comment": "Create table"
        },
        {
            "name": "KilianZimmerer",
            "email": "",
            "date": "2017-6-27",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_load_pq_set",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "name of corresponding scenario",
                    "unit": ""
                },
                {
                    "name": "load_id",
                    "description": "unique id",
                    "unit": ""
                },
                {
                    "name": "temp_id",
                    "description": "id of temporal resolution",
                    "unit": ""
                },
                {
                    "name": "p_set",
                    "description": "active power set point",
                    "unit": "MW"
                },
                {
                    "name": "q_set",
                    "description": "reactive power set point",
                    "unit": "MVar"
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_load_pq_set' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_load_pq_set','ego_dp_powerflow_hv_setup.sql',' ');


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
COMMENT ON TABLE model_draft.ego_grid_pf_hv_storage_pq_set IS '{
    "title": "eGo hv powerflow - storage time series",
    "description": "Time series of storages relevant for eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": ""
    },
    "temporal": {
        "reference_date": " ",
        "start": "",
        "end": "",
        "resolution": ""
    },
    "sources": [
        {
            "name": "eGo dataprocessing",
            "description": " ",
            "url": "https://github.com/openego/data_processing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 Europa-Universitaet Flensburg, Center for Sustainable Energy Systems"
        },
        {
            "name": "oemof feedinlib",
            "description": " ",
            "url": "https://github.com/oemof/feedinlib",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\u00a9 oemof developing group"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "26.04.2017",
            "comment": "Create table"
        },
        {
            "name": "KilianZimmerer",
            "email": "",
            "date": "2017-6-27",
            "comment": "Update metadata to v1.3"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_storage_pq_set",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "name of corresponding scenario",
                    "unit": ""
                },
                {
                    "name": "storage_id",
                    "description": "ID of corresponding storage",
                    "unit": ""
                },
                {
                    "name": "temp_id",
                    "description": "ID of temporal resolution",
                    "unit": ""
                },
                {
                    "name": "p_set",
                    "description": "active power set point (for PF)",
                    "unit": "MW"
                },
                {
                    "name": "q_set",
                    "description": "reactive power set point (for PF)",
                    "unit": "MVar"
                },
                {
                    "name": "p_min_pu",
                    "description": "If control=variable this gives the minimum output for each snapshot per unit of p_nom for the OPF",
                    "unit": "per unit"
                },
                {
                    "name": "p_max_pu",
                    "description": "If control=variable this gives the maximum output for each snapshot per unit of p_nom for the OPF",
                    "unit": "per unit"
                },
                {
                    "name": "soc_set",
                    "description": "State of charge set points for snapshots in the OPF",
                    "unit": "MWh"
                },
                {
                    "name": "inflow",
                    "description": "Inflow to the state of charge, e.g. due to river inflow in hydro reservoir",
                    "unit": "MW"
                }
            ]
        }
    ],
    "metadata_version": "1.3"
}';

-- select description
SELECT obj_description('model_draft.ego_grid_pf_hv_storage_pq_set' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_storage_pq_set','ego_dp_powerflow_hv_setup.sql',' ');


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
