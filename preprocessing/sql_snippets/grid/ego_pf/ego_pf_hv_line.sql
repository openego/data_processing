-- metadata
COMMENT ON TABLE grid.ego_pf_hv_line IS '{
    "title": "eGo hv powerflow - lines",
    "description": "lines in eGo hv powerflow",
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
            "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "http://www.openstreetmap.org/",
            "copyright": "\u00a9 OpenStreetMap contributors",
            "name": "OpenStreetMap",
            "license": "Open Database License (ODbL) v1.0",
            "description": " "
        },
        {
            "url": "https://github.com/openego/osmTGmod",
            "copyright": "\u00a9 Wuppertal Institut",
            "name": "osmTGmod",
            "license": "Apache License 2.0",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\u00a9 NEXT ENERGY",
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
                    "name": "scn_name",
                    "unit": "",
                    "description": "name of corresponding scenario"
                },
                {
                    "name": "line_id",
                    "unit": "",
                    "description": "ID of line"
                },
                {
                    "name": "bus0",
                    "unit": "",
                    "description": "name of first bus to which branch is attached"
                },
                {
                    "name": "bus1",
                    "unit": "",
                    "description": "name of second bus to which branch is attached"
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
                    "unit": "EUR/MVA",
                    "description": "capital cost of extending s_nom by 1 MVA"
                },
                {
                    "name": "length",
                    "unit": "km",
                    "description": "length of line"
                },
                {
                    "name": "cables",
                    "unit": "",
                    "description": "..."
                },
                {
                    "name": "frequency",
                    "unit": "",
                    "description": "frequency of line"
                },
                {
                    "name": "terrain_factor",
                    "unit": "",
                    "description": "..."
                },
                {
                    "name": "geom",
                    "unit": "",
                    "description": "geometry that depict the real route of the line"
                },
                {
                    "name": "topo",
                    "unit": "...",
                    "description": "topology that depicts a direct connection between both busses"
                }
            ],
            "name": "grid.ego_pf_hv_line",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';
