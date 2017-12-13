/*
A description of the module (short but could be more than one line).
Modules names should have short, all-lowercase names. 
The module name may have underscores if this improves readability.

__copyright__ 	= "Copyright Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "KilianZimmerer"
__contains__	= "url"
*/

-- metadata
COMMENT ON TABLE grid.ego_pf_hv_storage IS '{
    "title": "eGo hv powerflow - storage",
    "description": "Storages relevant for eGo hv powerflow",
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
            "copyright": "\u00a9 Reiner Lemoine Institut",
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
            "url": "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
            "copyright": "\u00a9 2016 Open Power System Data",
            "name": "Open Power System Data (OPSD)",
            "license": "MIT Licence",
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
        "copyright": "\u00a9 Europa-Universitaet Flensburg, Center for Sustainable Energy Systems",
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
                    "description": "State of charge before the snapshots in the OPF."
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
                }
            ],
            "name": "grid.ego_pf_hv_storage",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';
