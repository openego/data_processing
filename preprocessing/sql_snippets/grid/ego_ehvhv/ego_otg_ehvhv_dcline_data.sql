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
COMMENT ON TABLE grid.otg_ehvhv_dcline_data IS '{
    "title": "EHV DC lines as processed by egoTGmod",
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
            {"name": "grid.otg_ehvhv_dcline_data",
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
                {"name": "br_status",
                "description": "initial branch status (1=in-service, 0=out-of-service)",
                "unit": ""},
                {"name": "pf",
                "description": "real power flow at from bus end",
                "unit": "MW"},
                {"name": "pt",
                "description": "real power flow at to bus end",
                "unit": "MW"},
                {"name": "qf",
                "description": "reactive power injected into from bus",
                "unit": "MVAr"},
                {"name": "qt",
                "description": "reactive power injected into to bus",
                "unit": "MVAr"},
                {"name": "vf",
                "description": "voltage magnitude setpoint at from bus",
                "unit": "p.u."},
                {"name": "vt",
                "description": "voltage magnitude setpoint at to bus",
                "unit": "p.u."},
                {"name": "pmin",
                "description": "if positive (negative), lower limit on pf (pt)",
                "unit": ""},
                {"name": "pmax",
                "description": "if positive (negative), upper limit of pf (pt)",
                "unit": ""},
                {"name": "qminf",
                "description": "lower limit on reactive power injection into from bus",
                "unit": "MVAr"},
                {"name": "qmaxf",
                "description": "upper limit on reactive power injection into from bus",
                "unit": "MVAr"},
                {"name": "qmint",
                "description": "lower limit on reactive power injection into to bus",
                "unit": "MVAr"},
                {"name": "qmaxt",
                "description": "upper limit on reactive power injection into to bus",
                "unit": "MVAr"},
                {"name": "loss0",
                "description": "coefficient l0 of constant term of linear loss function",
                "unit": "MW"},
                {"name": "loss1",
                "description": "coefficient l1 of linear term of linear loss function",
                "unit": "MW/MW"},
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
                "unit": ""}]}],
    "metadata_version": "1.3"}';
