-- metadata
COMMENT ON TABLE grid.ego_pf_hv_storage_pq_set IS '{
    "title": "eGo hv powerflow - storage time series",
    "description": "Time series of storages relevant for eGo hv powerflow",
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
            "copyright": "\u00a9 Europa-Universitaet Flensburg, Center for Sustainable Energy Systems",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "https://github.com/oemof/feedinlib",
            "copyright": "\u00a9 oemof developing group",
            "name": "oemof feedinlib",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
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
                    "name": "storage_id",
                    "unit": "",
                    "description": "ID of corresponding storage"
                },
                {
                    "name": "temp_id",
                    "unit": "",
                    "description": "ID of temporal resolution"
                },
                {
                    "name": "p_set",
                    "unit": "MW",
                    "description": "active power set point (for PF)"
                },
                {
                    "name": "q_set",
                    "unit": "MVar",
                    "description": "reactive power set point (for PF)"
                },
                {
                    "name": "p_min_pu",
                    "unit": "per unit",
                    "description": "If control=variable this gives the minimum output for each snapshot per unit of p_nom for the OPF"
                },
                {
                    "name": "p_max_pu",
                    "unit": "per unit",
                    "description": "If control=variable this gives the maximum output for each snapshot per unit of p_nom for the OPF"
                },
                {
                    "name": "soc_set",
                    "unit": "MWh",
                    "description": "State of charge set points for snapshots in the OPF"
                },
                {
                    "name": "inflow",
                    "unit": "MW",
                    "description": "Inflow to the state of charge, e.g. due to river inflow in hydro reservoir"
                }
            ],
            "name": "grid.ego_pf_hv_storage_pq_set",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';
