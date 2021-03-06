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
COMMENT ON TABLE grid.otg_ehvhv_results_metadata IS '{
    "title": "Collection of meta-data of egoTGmod results",
    "description": "...",
    "language": [ ""  ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": ""},
    "temporal": {
        "reference_date": "2016-10-20",
        "start": "",
        "end": "",
        "resolution": ""},
    "sources": [
            {"name": "OpenStreetMap",
            "description": "",
            "url": "https://github.com/openego/osmTGmod/tree/ego_otg",
            "license": "",
            "copyright": ""}],
    "license": {
        "id": "",
        "name": "Open Database License (ODbL) v1.0",
        "version": "",
        "url": "http://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "",
        "copyright": "NEXT ENERGY"},
    "contributors": [
            {"name": "Lukas Wienholt",
            "email": "lukas.wienholt@next-energy.de",
            "date": "2016-10-20",
            "comment": "..."},
            {"name": "Kilian Zimmerer",
            "email": "",
            "date": "2017-10-17",
            "comment": "Update metadata to v1.3"}],
    "resources": [
            {"name": "grid.otg_ehvhv_results_metadata",
            "format": "PostgreSQL",
            "fields": [
                {"name": "id",
                "description": "Result ID",
                "unit": ""},
                {"name": "osm_date",
                "description": "Date of osm-data",
                "unit": ""},
                {"name": "abstraction_date",
                "description": "Date of abstraction / osmTGmod processing",
                "unit": ""},
                {"name": "applied_plans",
                "description": "Applied grid extension plans",
                "unit": ""},
                {"name": "applied_year",
                "description": "Applied year of grid topology",
                "unit": ""},
                {"name": "user_comment",
                "description": "...",
                "unit": ""}]}],
    "metadata_version": "1.3"}';
