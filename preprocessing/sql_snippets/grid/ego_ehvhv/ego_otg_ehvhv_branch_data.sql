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
COMMENT ON TABLE grid.otg_ehvhv_branch_data IS '{
    "title": "EHV and EV branches processed by egoTGmod",
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
            {"name": "grid.otg_ehvhv_branch_data",
            "format": "PostgreSQL",
            "fields": [
                {"name": "result_id",
                "description": "Database internal ID of result",
                "unit": ""},
                {"name": "view_id",
                "description": "ID for plotting purpose",
                "unit": ""},
                {"name": "branch_id",
                "description": "ID of branch",
                "unit": ""},
                {"name": "f_bus",
                "description": "from bus number",
                "unit": ""},
                {"name": "t_bus",
                "description": "to bus number",
                "unit": ""},
                {"name": "br_r",
                "description": "resistance",
                "unit": "p.u."},
                {"name": "br_x",
                "description": "reactance",
                "unit": "p.u."},
                {"name": "br_b",
                "description": "total line charging susceptance",
                "unit": "p.u."},
                {"name": "rate_a",
                "description": "MVA rating A (long term rating)",
                "unit": ""},
                {"name": "rate_b",
                "description": "MVA rating B (short term rating)",
                "unit": ""},
                {"name": "rate_c",
                "description": "MVA rating C (emergency rating)",
                "unit": ""},
                {"name": "tap",
                "description": "transformer off nominal turns ratio",
                "unit": ""},
                {"name": "shift",
                "description": "transformer phase shift angle",
                "unit": "degrees"},
                {"name": "br_status",
                "description": "initial branch status, 1 = in-service, 0 = out-of-service",
                "unit": ""},
                {"name": "link_type",
                "description": "Link Type (transformer = transformer,overhead line = line, underground cable = cable)",
                "unit": ""},
                {"name": "branch_voltage",
                "description": "Voltage of the overhead lines and underground cables",
                "unit": "kV"},
                {"name": "cables",
                "description": "Number of cables",
                "unit": ""},
                {"name": "frequency",
                "description": "frequency of the branch",
                "unit": "Hz"},
                {"name": "geom",
                "description": "Postgis WGS84 Multiline geometry",
                "unit": ""},
                {"name": "topo",
                "description": "Postgis WGS84 Linestring geometry",
                "unit": ""},
                {"name": "connected_via",
                "description": "States way of connection for synthetic branches: 1=connection of transfer-bus to closest substation, 2=connection of transfer-bus to closest line, 3=connection of a subgrid to the main grid.",
                "unit": ""}]}],
    "metadata_version": "1.3"}';
