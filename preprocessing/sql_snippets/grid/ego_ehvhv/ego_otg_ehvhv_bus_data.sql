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
COMMENT ON TABLE grid.otg_ehvhv_bus_data IS '{
    "title": "EHV and EV buses processed by egoTGmod",
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
            {"name": "grid.otg_ehvhv_bus_data",
            "format": "PostgreSQL",
            "fields": [
                {"name": "result_id",
                "description": "Database internal ID of result",
                "unit": ""},
                {"name": "view_id",
                "description": "ID for plotting purpose",
                "unit": ""},
                {"name": "bus_i",
                "description": "ID of bus",
                "unit": ""},
                {"name": "bus_type",
                "description": "bus type (1=PQ, 2=PV, 3=ref, 4=isolated)",
                "unit": ""},
                {"name": "pd",
                "description": "real power demand",
                "unit": "MW"},
                {"name": "qd",
                "description": "reactive power demand",
                "unit": "MVAr"},
                {"name": "gs",
                "description": "shunt conductance",
                "unit": ""},
                {"name": "bs",
                "description": "shunt susceptance",
                "unit": ""},
                {"name": "bus_area",
                "description": "area number",
                "unit": ""},
                {"name": "vm",
                "description": "voltage magnitude",
                "unit": "p.u."},
                {"name": "va",
                "description": "voltage angle",
                "unit": "degrees"},
                {"name": "base_kv",
                "description": "base voltage",
                "unit": "kV"},
                {"name": "zone",
                "description": "loss zone",
                "unit": ""},
                {"name": "vmax",
                "description": "maximum voltage magnitude",
                "unit": "p.u."},
                {"name": "vmin",
                "description": "minimum voltage magnitude",
                "unit": "p.u."},
                {"name": "osm_substation_id",
                "description": "osm id of substation (type=way)",
                "unit": ""},
                {"name": "cntr_id",
                "description": "country code of the node",
                "unit": ""},
                {"name": "frequency",
                "description": "frequency of the bus",
                "unit": "Hz"},
                {"name": "geom",
                "description": "Postgis WGS84 Point geometry",
                "unit": ""},
                {"name": "osm_name",
                "description": "name of bus in osm",
                "unit": ""}]}],
    "metadata_version": "1.3"}';
