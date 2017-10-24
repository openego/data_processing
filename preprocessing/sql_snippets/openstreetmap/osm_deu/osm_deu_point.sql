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
COMMENT ON TABLE openstreetmap.osm_deu_point IS '{
    "title": "OpenStreetMap - Germany",
    "description": "OSM Datensatz Deutschland",
    "language": [ ""  ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": ""},
    "temporal": {
        "reference_date": "2016-10-01",
        "start": "",
        "end": "",
        "resolution": ""},
    "sources": [
            {"name": "Geofabrik - Download - OpenStreetMap Data Extracts",
            "description": "",
            "url": "http://download.geofabrik.de/europe/germany.html#",
            "license": "",
            "copyright": ""}],
    "license": {
        "id": "",
        "name": "Open Data Commons Open Database Lizenz (ODbL)",
        "version": "",
        "url": "",
        "instruction": "Wir verlangen die Verwendung des Hinweises OpenStreetMap-Mitwirkende. Du musst auch klarstellen, dass die Daten unter der Open-Database-Lizenz verf\u00fcgbar sind, und, sofern du unsere Kartenkacheln verwendest, dass die Kartografie gem\u00e4\u00df CC BY-SA lizenziert ist. Du kannst dies tun, indem du auf www.openstreetmap.org/copyright verlinkst. Ersatzweise, und als Erfordernis, falls du OSM in Datenform weitergibst, kannst du die Lizenz(en) direkt verlinken und benennen. In Medien, in denen keine Links m\u00f6glich sind (z.B. gedruckten Werken), empfehlen wir dir, deine Leser direkt auf openstreetmap.org zu verweisen (m\u00f6glicherweise mit dem Erweitern von OpenStreetMap zur vollen Adresse), auf opendatacommons.org, und, sofern zutreffend, auf creativecommons.org. Der Hinweis sollte f\u00fcr eine durchsuchbare elektronische Karte in der Ecke der Karte stehen.",
        "copyright": ""},
    "contributors": [
            {"name": "Martin Glauer",
            "email": " ",
            "date": "2016-10-10",
            "comment": "Created table with osm2pgsql"},
            {"name": "Ludwig H\u00fclk",
            "email": "ludwig.huelk@rl-institut.de",
            "date": "2016-10-11",
            "comment": "Executed setup"},
            {"name": "Kilian Zimmerer",
            "email": "",
            "date": "2017-10-17",
            "comment": "Update metadata to v1.3"}],
    "resources": [
            {"name": "openstreetmap.osm_deu_point",
            "format": "PostgreSQL",
            "fields": [
                {"name": "osm_id",
                "description": "OSM ID",
                "unit": " "},
                {"name": "oedb.style",
                "description": "Keys defined in this file",
                "unit": " "}]}],
    "metadata_version": "1.3"}';
