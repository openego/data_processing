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
COMMENT ON TABLE grid.ego_pf_hv_temp_resolution IS '{
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
            "copyright": "\u00a9 Flensburg University of Applied Sciences, Center for Sustainable Energy Systems",
            "name": "eGo dataprocessing",
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
