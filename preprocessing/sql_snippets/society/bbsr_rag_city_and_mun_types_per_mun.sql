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
COMMENT ON TABLE society.bbsr_rag_city_and_mun_types_per_mun IS '{
    "title": "BBSR - Raumabgrenzungen - Stadt- und Gemeindetyp - 2013",
    "description": "City and Municipality types",
    "language": [ ""  ],
    "spatial": {
        "location": "",
        "extend": "Germany",
        "resolution": "Municipality"},
    "temporal": {
        "reference_date": "2013",
        "start": "",
        "end": "",
        "resolution": ""},
    "sources": [
            {"name": "Bundesinstitut f\u00fcr Bau-, Stadt- und Raumforschung (BBSR) - Downloads - Raumabgrenzungen: Referenzdateien und Karten",
            "description": "",
            "url": "http://www.bbsr.bund.de/BBSR/DE/Raumbeobachtung/Downloads/downloads_node.html",
            "license": "",
            "copyright": ""}],
    "license": {
        "id": "",
        "name": "Datenlizenz Deutschland \u2013 Namensnennung \u2013 Version 2.0 (dl-de/by-2-0; http://www.govdata.de/dl-de/by-2-0)",
        "version": "",
        "url": "",
        "instruction": "Die Nutzer haben sicherzustellen, dass 1. alle den Daten, Metadaten, Karten und Webdiensten beigegebenen Quellenvermerke und sonstigen rechtlichen Hinweise erkennbar und in optischem Zusammenhang eingebunden werden. Die Nutzung bzw. der Abdruck ist nur mit vollst\u00e4ndiger Angabe des Quellenvermerks (\u00a9 BBSR Bonn 2015) gestattet. Bei der Darstellung auf einer Webseite ist (\u00a9 Bundesinstitut f\u00fcr Bau-, Stadt- und Raumforschung) mit der URL (http://www.bbsr.bund.de) zu verlinken. 2. bei Ver\u00e4nderungen (insbesondere durch Hinzuf\u00fcgen neuer Inhalte), Bearbeitungen, neuen Gestaltungen oder sonstigen Abwandlungen mit einem Ver\u00e4nderungshinweis im beigegebenen Quellenvermerk Art und Urheberschaft der Ver\u00e4nderungen deutlich kenntlich gemacht wird. Bei Karten ist in diesem Fall das Logo des BBSR zu entfernen.",
        "copyright": ""},
    "contributors": [
            {"name": "Ludwig Schneider",
            "email": "ludwig.schenider@rl-institut.de",
            "date": "2015-12-08",
            "comment": "Created table"},
            {"name": "Ludwig H\u00fclk",
            "email": "ludwig.huelk@rl-institut.de",
            "date": "2016-10-26",
            "comment": "Moved table and update metadata"},
            {"name": "Kilian Zimmerer",
            "email": "",
            "date": "2017-10-17",
            "comment": "Update metadata to v1.3"}],
    "resources": [
            {"name": "society.bbsr_rag_city_and_mun_types_per_mun",
            "format": "PostgreSQL",
            "fields": [
                {"name": "mun_id",
                "description": "Municipality key 2013",
                "unit": ""},
                {"name": "mun_name",
                "description": "Municipality name 2013",
                "unit": ""},
                {"name": "munassn_id",
                "description": "Municipal association key 2013",
                "unit": ""},
                {"name": "munassn_name",
                "description": "Municipal association name 2013",
                "unit": ""},
                {"name": "pop_2013",
                "description": "Population 2013",
                "unit": ""},
                {"name": "area_sqm",
                "description": "Area in square meter",
                "unit": ""},
                {"name": "cm_typ",
                "description": "City and municipality key 2013",
                "unit": ""},
                {"name": "cm_typ_name",
                "description": "City and municipality name 2013",
                "unit": ""},
                {"name": "cm_typ_d",
                "description": "City and municipality key differentiated 2013",
                "unit": ""},
                {"name": "cm_typ_d_name",
                "description": "City and municipality name differentiated 2013",
                "unit": ""}]}],
    "metadata_version": "1.3"}';

