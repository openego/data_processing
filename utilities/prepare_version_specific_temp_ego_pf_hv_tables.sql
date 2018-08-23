CREATE TABLE model_draft.ego_grid_pf_hv_bus_v032
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  bus_id bigint NOT NULL,
  v_nom double precision,
  current_type text DEFAULT 'AC'::text,
  v_mag_pu_min double precision DEFAULT 0,
  v_mag_pu_max double precision,
  geom geometry(Point,4326),
  CONSTRAINT bus_v032_data_pkey PRIMARY KEY (bus_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_bus_v032
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_bus_v032 TO oeuser;
COMMENT ON TABLE model_draft.ego_grid_pf_hv_bus_v032
  IS E'{
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
            "copyright": "\\u00a9 Reiner Lemoine Institut"
        },
        {
            "name": "OpenStreetMap",
            "description": " ",
            "url": "http://www.openstreetmap.org/",
            "license": "Open Database License (ODbL) v1.0",
            "copyright": "\\u00a9 OpenStreetMap contributors"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
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


INSERT INTO model_draft.ego_grid_pf_hv_bus_v032
	SELECT 	scn_name,
		bus_id,
		v_nom ,
		current_type,
		v_mag_pu_min,
		v_mag_pu_max,
		geom
	FROM grid.ego_pf_hv_bus
	WHERE version = 'v0.3.2'; 



CREATE TABLE model_draft.ego_grid_pf_hv_generator_v032
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  generator_id bigint NOT NULL,
  bus bigint,
  dispatch text DEFAULT 'flexible'::text,
  control text DEFAULT 'PQ'::text,
  p_nom double precision DEFAULT 0,
  p_nom_extendable boolean DEFAULT false,
  p_nom_min double precision DEFAULT 0,
  p_nom_max double precision,
  p_min_pu_fixed double precision DEFAULT 0,
  p_max_pu_fixed double precision DEFAULT 1,
  sign double precision DEFAULT 1,
  source bigint,
  marginal_cost double precision,
  capital_cost double precision,
  efficiency double precision,
  CONSTRAINT generator_v032_pkey PRIMARY KEY (generator_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_generator_v032
  OWNER TO oeuser;
COMMENT ON TABLE model_draft.ego_grid_pf_hv_generator_v032
  IS E'{
    "title": "eGo hv powerflow - generator",
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
            "date": "26.04.2017",
            "comment": "Create table",
            "name": "IlkaCu",
            "email": ""
        },
        {
            "date": "2017-9-12",
            "comment": "Update metadata to v1.3",
            "name": "KilianZimmerer",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [

                {
                    "name": "scn_name",
                    "unit": "",
                    "description": "name of corresponding scenario"
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
                }
            ],
            "name": "grid.ego_pf_hv_generator",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';


INSERT INTO model_draft.ego_grid_pf_hv_generator_v032
	SELECT 	scn_name,
		generator_id,
		bus,
		dispatch,
		control,
		p_nom,
		p_nom_extendable,
		p_nom_min,
		p_nom_max,
		p_min_pu_fixed,
		p_max_pu_fixed,
		sign,
		source,
		marginal_cost,
		capital_cost,
		efficiency
	FROM grid.ego_pf_hv_generator
	WHERE version = 'v0.3.2'; 


CREATE TABLE model_draft.ego_grid_pf_hv_generator_pq_set_v032
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  generator_id bigint NOT NULL,
  temp_id integer NOT NULL,
  p_set double precision[],
  q_set double precision[],
  p_min_pu double precision[],
  p_max_pu double precision[],
  CONSTRAINT generator_pq_set__v032pkey PRIMARY KEY (generator_id, temp_id, scn_name),
  CONSTRAINT generator_pq_set_temp_fkey FOREIGN KEY (temp_id)
      REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_generator_pq_set_v032
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_generator_pq_set_v032 TO oeuser;
COMMENT ON TABLE model_draft.ego_grid_pf_hv_generator_pq_set_v032
  IS E'{
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
            "copyright": "\\u00a9 Europa-Universitaet Flensburg, Center for Sustainable Energy Systems"
        },
        {
            "name": "oemof feedinlib",
            "description": " ",
            "url": "https://github.com/oemof/feedinlib",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\\u00a9 oemof developing group"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\\u00a9 Europa-Universitaet Flensburg, Center for Sustainable Energy Systems"
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


INSERT INTO model_draft.ego_grid_pf_hv_generator_pq_set_v032
	SELECT 	scn_name,
	generator_id,
	temp_id,
	p_set,
	q_set,
	p_min_pu,
	p_max_pu
	FROM grid.ego_pf_hv_generator_pq_set
	WHERE version = 'v0.3.2'; 



CREATE TABLE model_draft.ego_grid_pf_hv_line_v032
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  line_id bigint NOT NULL,
  bus0 bigint,
  bus1 bigint,
  x numeric DEFAULT 0,
  r numeric DEFAULT 0,
  g numeric DEFAULT 0,
  b numeric DEFAULT 0,
  s_nom numeric DEFAULT 0,
  s_nom_extendable boolean DEFAULT false,
  s_nom_min double precision DEFAULT 0,
  s_nom_max double precision,
  capital_cost double precision,
  length double precision,
  cables integer,
  frequency numeric,
  terrain_factor double precision DEFAULT 1,
  geom geometry(MultiLineString,4326),
  topo geometry(LineString,4326),
  CONSTRAINT line_data_v032_pkey PRIMARY KEY (line_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_line_v032
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_line_v032 TO oeuser;
COMMENT ON TABLE model_draft.ego_grid_pf_hv_line_v032
  IS E'{
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
            "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
        },
        {
            "name": "OpenStreetMap",
            "description": " ",
            "url": "http://www.openstreetmap.org/",
            "license": "Open Database License (ODbL) v1.0",
            "copyright": "\\u00a9 OpenStreetMap contributors"
        },
        {
            "name": "osmTGmod",
            "description": " ",
            "url": "https://github.com/openego/osmTGmod",
            "license": "Apache License 2.0",
            "copyright": "\\u00a9 Wuppertal Institut"
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


INSERT INTO model_draft.ego_grid_pf_hv_line_v032
	SELECT 	
	scn_name,
	line_id,
	bus0,
	bus1,
	x,
	r,
	g,
	b,
	s_nom,
	s_nom_extendable,
	s_nom_min,
	s_nom_max,
	capital_cost,
	length,
	cables,
	frequency,
	terrain_factor,
	geom,
	topo
	FROM grid.ego_pf_hv_line
	WHERE version = 'v0.3.2'; 


CREATE TABLE model_draft.ego_grid_pf_hv_link_v032
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  link_id bigint NOT NULL,
  bus0 bigint,
  bus1 bigint,
  efficiency double precision DEFAULT 1,
  marginal_cost double precision DEFAULT 0,
  p_nom numeric DEFAULT 0,
  p_nom_extendable boolean DEFAULT false,
  p_nom_min double precision DEFAULT 0,
  p_nom_max double precision,
  capital_cost double precision,
  length double precision,
  terrain_factor double precision DEFAULT 1,
  geom geometry(MultiLineString,4326),
  topo geometry(LineString,4326),
  CONSTRAINT hv_link_data_v032_pkey PRIMARY KEY (link_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_link_v032
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_link_v032 TO oeuser;
COMMENT ON TABLE model_draft.ego_grid_pf_hv_link_v032
  IS E'{
    "title": "eGo hv powerflow - links",
    "description": "links in eGo hv powerflow",
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
            "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
        },
        {
            "name": "OpenStreetMap",
            "description": " ",
            "url": "http://www.openstreetmap.org/",
            "license": "Open Database License (ODbL) v1.0",
            "copyright": "\\u00a9 OpenStreetMap contributors"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
    },
    "contributors": [
        {
            "name": "IlkaCu",
            "email": "",
            "date": "08.02.2018",
            "comment": "Create table"
        }
    ],
    "resources": [
        {
            "name": "model_draft.ego_grid_pf_hv_link",
            "fromat": "sql",
            "fields": [
                {
                    "name": "scn_name",
                    "description": "name of corresponding scenario",
                    "unit": ""
                },
                {
                    "name": "link_id",
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
                    "name": "efficiency",
                    "description": "efficiency of power transfer from bus0 to bus1",
                    "unit": ""
                },
                {
                    "name": "p_nom",
                    "description": "limit of active power which can pass through link",
                    "unit": "MVA"
                },
                {
                    "name": "p_nom_extendable",
                    "description": "switch to allow capacity p_nom to be extended in OPF",
                    "unit": ""
                },
                {
                    "name": "p_nom_min",
                    "description": "minimum value, if p_nom is extendable",
                    "unit": "MVA"
                },
                {
                    "name": "p_nom_max",
                    "description": "maximum value, if p_nom is extendable",
                    "unit": "MVA"
                },
                {
                    "name": "capital_cost",
                    "description": "capital cost of extending p_nom by 1 MVA",
                    "unit": "EUR/MVA"
                },
                {
                    "name": "length",
                    "description": "length of line",
                    "unit": "km"
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


INSERT INTO model_draft.ego_grid_pf_hv_link_v032
	SELECT 	
	scn_name,
	link_id,
	bus0 ,
	bus1 ,
	efficiency,
	marginal_cost,
	p_nom ,
	p_nom_extendable,
	p_nom_min ,
	p_nom_max,
	capital_cost,
	length,
	terrain_factor,
	geom,
	topo
	FROM grid.ego_pf_hv_link
	WHERE version = 'v0.3.2'; 


CREATE TABLE model_draft.ego_grid_pf_hv_load_v032
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  load_id bigint NOT NULL,
  bus bigint,
  sign double precision DEFAULT '-1'::integer,
  e_annual double precision,
  CONSTRAINT load_data_v032_pkey PRIMARY KEY (load_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_load_v032
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_load_v032 TO oeuser;
COMMENT ON TABLE model_draft.ego_grid_pf_hv_load_v032
  IS E'{
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
            "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
        },
        {
            "name": "OpenStreetMap",
            "description": " ",
            "url": "http://www.openstreetmap.org/",
            "license": "Open Database License (ODbL) v1.0",
            "copyright": "\\u00a9 OpenStreetMap contributors"
        },
        {
            "name": "L\\u00e4nderarbeitskreis Energiebilanzen",
            "description": " ",
            "url": "http://www.lak-energiebilanzen.de/seiten/energiebilanzenLaender.cfm",
            "license": " ",
            "copyright": " "
        },
        {
            "name": "Bayerisches Landesamt f\\u00fcr Statistik und Datenverarbeitung",
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
            "name": "Nieders\\u00e4chsisches Ministerium f\\u00fcr Umwelt, Energie und Klimaschutz",
            "description": " ",
            "url": "http://www.umwelt.niedersachsen.de/energie/daten/co2bilanzen/niedersaechsische-energie--und-co2-bilanzen-2009-6900.html",
            "license": " ",
            "copyright": " "
        },
        {
            "name": "Statistische Berichte Energiebilanz und CO2-Bilanz in Nordrhein-Westfalen 2011",
            "description": " ",
            "url": "https://webshop.it.nrw.de",
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
            "name": "Th\\u00fcringer Landesamt f\\u00fcr Statistik",
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
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
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

INSERT INTO model_draft.ego_grid_pf_hv_load_v032
	SELECT 	
	scn_name,
	load_id,
	bus ,
	sign ,
	e_annual
	FROM grid.ego_pf_hv_load
	WHERE version = 'v0.3.2'; 


CREATE TABLE model_draft.ego_grid_pf_hv_load_pq_set_v032
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  load_id bigint NOT NULL,
  temp_id integer NOT NULL,
  p_set double precision[],
  q_set double precision[],
  CONSTRAINT load_pq_set_v032_pkey PRIMARY KEY (load_id, temp_id, scn_name),
  CONSTRAINT load_pq_set_temp_fkey FOREIGN KEY (temp_id)
      REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_load_pq_set_v032
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_load_pq_set_v032 TO oeuser;
COMMENT ON TABLE model_draft.ego_grid_pf_hv_load_pq_set_v032
  IS E'{
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
            "copyright": "\\u00a9 Reiner Lemoine Institut"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\\u00a9 Reiner Lemoine Institut"
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

INSERT INTO model_draft.ego_grid_pf_hv_load_pq_set_v032
	SELECT 	
	scn_name,
	load_id,
	temp_id,
	p_set,
	q_set
	FROM grid.ego_pf_hv_load_pq_set
	WHERE version = 'v0.3.2'; 


CREATE TABLE model_draft.ego_grid_pf_hv_storage_v032
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  storage_id bigint NOT NULL,
  bus bigint,
  dispatch text DEFAULT 'flexible'::text,
  control text DEFAULT 'PQ'::text,
  p_nom double precision DEFAULT 0,
  p_nom_extendable boolean DEFAULT false,
  p_nom_min double precision DEFAULT 0,
  p_nom_max double precision,
  p_min_pu_fixed double precision DEFAULT 0,
  p_max_pu_fixed double precision DEFAULT 1,
  sign double precision DEFAULT 1,
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
  CONSTRAINT storage_data_v032_pkey PRIMARY KEY (storage_id, scn_name),
  CONSTRAINT storage_data_source_fkey FOREIGN KEY (source)
      REFERENCES model_draft.ego_grid_pf_hv_source (source_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_storage_v032
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_storage_v032 TO oeuser;
COMMENT ON TABLE model_draft.ego_grid_pf_hv_storage_v032
  IS E'{
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
            "copyright": "\\u00a9 Reiner Lemoine Institut"
        },
        {
            "name": "OpenStreetMap",
            "description": " ",
            "url": "http://www.openstreetmap.org/",
            "license": "Open Database License (ODbL) v1.0",
            "copyright": "\\u00a9 OpenStreetMap contributors"
        },
        {
            "name": "Open Power System Data (OPSD)",
            "description": " ",
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "license": "MIT Licence",
            "copyright": "\\u00a9 2016 Open Power System Data"
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
        "copyright": "\\u00a9 Europa-Universitaet Flensburg, Center for Sustainable Energy Systems"
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


INSERT INTO model_draft.ego_grid_pf_hv_storage_v032
	SELECT 	
	scn_name,
	storage_id,
	bus ,
	dispatch ,
	control ,
	p_nom ,
	p_nom_extendable ,
	p_nom_min ,
	p_nom_max ,
	p_min_pu_fixed ,
	p_max_pu_fixed ,
	sign ,
	source ,
	marginal_cost ,
	capital_cost ,
	efficiency ,
	soc_initial ,
	soc_cyclic ,
	max_hours ,
	efficiency_store ,
	efficiency_dispatch ,
	standing_loss
	FROM grid.ego_pf_hv_storage
	WHERE version = 'v0.3.2'; 



CREATE TABLE model_draft.ego_grid_pf_hv_storage_pq_set_v032
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  storage_id bigint NOT NULL,
  temp_id integer NOT NULL,
  p_set double precision[],
  q_set double precision[],
  p_min_pu double precision[],
  p_max_pu double precision[],
  soc_set double precision[],
  inflow double precision[],
  CONSTRAINT storage_pq_set_v032_pkey PRIMARY KEY (storage_id, temp_id, scn_name),
  CONSTRAINT storage_pq_set_temp_fkey FOREIGN KEY (temp_id)
      REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_storage_pq_set_v032
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_storage_pq_set_v032 TO oeuser;
COMMENT ON TABLE model_draft.ego_grid_pf_hv_storage_pq_set_v032
  IS E'{
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
            "copyright": "\\u00a9 Europa-Universitaet Flensburg, Center for Sustainable Energy Systems"
        },
        {
            "name": "oemof feedinlib",
            "description": " ",
            "url": "https://github.com/oemof/feedinlib",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "copyright": "\\u00a9 oemof developing group"
        }
    ],
    "license": {
        "id": "ODbL-1.0",
        "name": "Open Data Commons Open Database License 1.0",
        "version": "1.0",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
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


INSERT INTO model_draft.ego_grid_pf_hv_storage_pq_set_v032
	SELECT 	
	scn_name,
	storage_id,
	temp_id,
	p_set,
	q_set,
	p_min_pu,
	p_max_pu,
	soc_set,
	inflow 
	FROM grid.ego_pf_hv_storage_pq_set
	WHERE version = 'v0.3.2'; 




CREATE TABLE model_draft.ego_grid_pf_hv_transformer_v032
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  trafo_id bigint NOT NULL,
  bus0 bigint,
  bus1 bigint,
  x numeric DEFAULT 0,
  r numeric DEFAULT 0,
  g numeric DEFAULT 0,
  b numeric DEFAULT 0,
  s_nom double precision DEFAULT 0,
  s_nom_extendable boolean DEFAULT false,
  s_nom_min double precision DEFAULT 0,
  s_nom_max double precision,
  tap_ratio double precision,
  phase_shift double precision,
  capital_cost double precision DEFAULT 0,
  geom geometry(MultiLineString,4326),
  topo geometry(LineString,4326),
  CONSTRAINT transformer_data_v032_pkey PRIMARY KEY (trafo_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_transformer_v032
  OWNER TO oeuser;
GRANT ALL ON TABLE model_draft.ego_grid_pf_hv_transformer_v032 TO oeuser;
COMMENT ON TABLE model_draft.ego_grid_pf_hv_transformer_v032
  IS E'{
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
            "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems"
        },
        {
            "name": "OpenStreetMap",
            "description": " ",
            "url": "http://www.openstreetmap.org/",
            "license": "Open Database License (ODbL) v1.0",
            "copyright": "\\u00a9 OpenStreetMap contributors"
        },
        {
            "name": "osmTGmod",
            "description": " ",
            "url": "https://github.com/openego/osmTGmod",
            "license": "Apache License 2.0",
            "copyright": "\\u00a9 Wuppertal Institut"
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


INSERT INTO model_draft.ego_grid_pf_hv_transformer_v032
	SELECT 	
	scn_name ,
	trafo_id ,
	bus0 ,
	bus1 ,
	x ,
	r ,
	g ,
	b ,
	s_nom ,
	s_nom_extendable ,
	s_nom_min ,
	s_nom_max ,
	tap_ratio,
	phase_shift ,
	capital_cost ,
	geom,
	topo
	FROM grid.ego_pf_hv_transformer
	WHERE version = 'v0.3.2'; 



CREATE TABLE model_draft.ego_grid_pf_hv_source_v032
(
  source_id bigint NOT NULL,
  name text,
  co2_emissions double precision,
  commentary text,
  CONSTRAINT source_v032_pkey PRIMARY KEY (source_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_source_v032
  OWNER TO oeuser;
COMMENT ON TABLE model_draft.ego_grid_pf_hv_source_v032
  IS E'{
    "title": "eGo hv powerflow - sources",
    "description": "sources in eGo hv powerflow",
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
            "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
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
            "date": "26.04.2017",
            "comment": "Create table",
            "name": "IlkaCu",
            "email": ""
        },
        {
            "date": "2017-9-12",
            "comment": "Update metadata to v1.3",
            "name": "KilianZimmerer",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "version",
                    "unit": "",
                    "description": "version id"
                },
                {
                    "name": "source_id",
                    "unit": "",
                    "description": "unique source id"
                },
                {
                    "name": "name",
                    "unit": "",
                    "description": "source name"
                },
                {
                    "name": "co2_emissions",
                    "unit": "tonnes/MWh",
                    "description": "technology specific CO2 emissions "
                },
                {
                    "name": "commentary",
                    "unit": "",
                    "description": "..."
                }
            ],
            "name": "grid.ego_pf_hv_source",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';


INSERT INTO model_draft.ego_grid_pf_hv_source_v032
	SELECT 	
	source_id,
	name,
	co2_emissions,
	commentary
	from grid.ego_pf_hv_source
	WHERE version = 'v0.3.2'; 


CREATE TABLE model_draft.ego_grid_pf_hv_temp_resolution_v032
(
  temp_id bigint NOT NULL,
  timesteps bigint NOT NULL,
  resolution text,
  start_time timestamp without time zone,
  CONSTRAINT temp_resolution_v032_pkey PRIMARY KEY (temp_id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_temp_resolution_v032
  OWNER TO oeuser;
COMMENT ON TABLE model_draft.ego_grid_pf_hv_temp_resolution_v032
  IS E'{
    "title": "eGo hv powerflow - temp_resolution",
    "description": "Temporal resolution in eGo hv powerflow",
    "language": [ "eng" ],
    "spatial": {
        "resolution": "",
        "location": "",
        "extend": ""
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
            "copyright": "\\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
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
            "date": "26.04.2017",
            "comment": "Create table",
            "name": "IlkaCu",
            "email": ""
        },
        {
            "date": "2017-9-12",
            "comment": "Update metadata to v1.3",
            "name": "KilianZimmerer",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "version",
                    "unit": "",
                    "description": "version id"
                },
                {
                    "name": "temp_id",
                    "unit": "",
                    "description": "unique id"
                },
                {
                    "name": "timesteps",
                    "unit": "",
                    "description": "timestep"
                },
                {
                    "name": "resolution",
                    "unit": "",
                    "description": "temporal resolution"
                },
                {
                    "name": "start_time",
                    "unit": "",
                    "description": "start time with style: YYYY-MM-DD HH:MM:SS"
                }
            ],
            "name": "grid.ego_pf_hv_temp_resolution",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';



INSERT INTO model_draft.ego_grid_pf_hv_temp_resolution_v032
	SELECT
	temp_id,
	timesteps,
	resolution,
	start_time
	from grid.ego_pf_hv_temp_resolution
	WHERE version = 'v0.3.2'; 