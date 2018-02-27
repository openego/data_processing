
/*
This spript creates the table ego_grid_line_expansion_costs which is used in ego and eTraGO
as cost input.

__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"
*/

CREATE TABLE model_draft.ego_grid_line_expansion_costs
(
  cost_id bigint NOT NULL,
  voltage_level text,
  component text,
  measure text,
  investment_cost double precision,
  unit text,
  comment text,
  source text,
  capital_costs_pypsa double precision,
  CONSTRAINT ego_grid_line_expansion_costs_pkey PRIMARY KEY (cost_id)
 
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_line_expansion_costs
  OWNER TO oeuser;
  
COMMENT ON TABLE model_draft.ego_grid_line_expansion_costs
  IS '{
    "title": "eGo power line expansion costs",
    "description": "Assumption of power line expansion costs for eGo hv powerflow",
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
            "copyright": "\\u00a9 ZNES Europ-Universität Flensburg",
            "name": "eGo dataprocessing",
            "license": "GNU Affero General Public License Version 3 (AGPL-3.0)",
            "description": " "
        },
        {
            "url": "https://www.netzentwicklungsplan.de/sites/default/files/paragraphs-files/kostenschaetzungen_nep_2025_1_entwurf.pdf",
            "copyright": "\\u00a9 50Hertz Transmission GmbH, Amprion GmbH, TenneT TSO GmbH, TransnetBW GmbH",
            "name": "Netzentwicklungsplan 2015 erster Entwurf",
            "license": "unknown",
            "description": " "
        },
        {
            "url": "https://shop.dena.de/sortiment/detail/produkt/dena-verteilnetzstudie-ausbau-und-innovationsbedarf-der-stromverteilnetze-in-deutschland-bis-2030/",
            "copyright": "\\u00a9 Dena",
            "name": "dena-Verteilnetzstudie: Ausbau- und Innovationsbedarf der Stromverteilnetze in Deutschland bis 2030",
            "license": "unknown",
            "description": " "
        }
    ],
    "license": {
        "name": "Open Data Commons Open Database License 1.0",
        "copyright": "\\u00a9 Europa-Universität, Center for Sustainable Energy Systems",
        "url": "https://opendatacommons.org/licenses/odbl/1.0/",
        "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
        "version": "1.0",
        "id": "ODbL-1.0"
    },
    "contributors": [
        {
            "date": "2018-01-31",
            "comment": "Create table",
            "name": "wolf_bunke",
            "email": ""
        }
    ],
    "resources": [
        {
            "fields": [
                {
                    "name": "cost_id",
                    "unit": "",
                    "description": "unique id for costs entries"
                },
                {
                    "name": "voltage_level",
                    "unit": "kV",
                    "description": "Power voltage level of component"
                },
                {
                    "name": "component",
                    "unit": " ",
                    "description": "Name of component"
                },
                {
                    "name": "measure",
                    "unit": " ",
                    "description": "measure "
                },
		{
                    "name": "investment_cost",
                    "unit": "see column unit",
                    "description": "investment cost of component"
                },
		{
                    "name": "unit",
                    "unit": "",
                    "description": "Table of original units of the components"
                },
		{
                    "name": "comment",
                    "unit": "",
                    "description": "Comment"
                },
                {
                    "name": "source",
                    "unit": "",
                    "description": "short name of data source"
                },
		 {
                    "name": "capital_costs_pypsa",
                    "unit": "currency/MVA",
                    "description": "capital costs in pypsa formate"
                }
            ],
            "name": "model_draft.ego_grid_line_expansion_costs",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';

-- Insert data
INSERT INTO model_draft.ego_grid_line_expansion_costs (cost_id, voltage_level, component, measure, 
					   investment_cost, unit, comment, source, 
					   capital_costs_pypsa) 
VALUES 
(2, '380', 'line', '380-kV-Stromkreisauflage/Umbeseilung', 0.200000000000000011, 'Mio. €/km', 
	'auf Bestandsleitung pro Stromkreis', 'NEP 2025', 84.3881856540084385),
(1, '220', 'line', '220-kV-Stromkreisauflage/Umbeseilung', 0.149999999999999994, 'Mio. €/km', 
'auf Bestandsleitung pro Stromkreis', 'NEP 2025', NULL),
(3, '380', 'line', '380-kV-Neubau in bestehender Trasse Doppelleitung', 1.60000000000000009, 'Mio. €/km', 
'inkl. Rückbau der bestehenden Trasse', 'NEP 2025', 337.552742616033754),
(4, '380', 'line', '380-kV-Neubau in Doppelleitung', 1.5, 'Mio. €/km', 
'Neubautrasse, Hochstrom', 'NEP 2025', 316.455696202531669),
(16, '110', 'line', '110-kV-Stromkreisauflage/Umbeseilung', 0.0599999999999999978, 'Mio. €/km', 
'auf Bestandsleitung pro Stromkreis', ' dena Verteilnetzstudie 2030 S.146 ', NULL),
(17, '110', 'line', '110-kV-Neubau in bestehender Trasse Doppelleitung', 0.520000000000000018, 'Mio. €/km', 
'inkl. Rückbau der bestehenden Trasse', 'dena Verteilnetzstudie 2030 S.146 ', NULL),
(14, '380/110', 'transformer', '300 MVA', 5.20000000000000018, 'Mio. €/Stück', 'inkl. 110-kV-Schaltfeld und Kabelableitung
(ohne 380-kV-Schaltfeld)', 'NEP 2025', 17333),
(5, NULL, 'link', 'Neubau DC-Freileitung*', 1.5, 'Mio. €/km', 'Neubautrasse mit bis zu 4 GW', 'NEP 2025', 375),
(7, NULL, 'link', 'Neubau DC-Erdkabel', 4, 'Mio. €/km', 
'Neubautrasse mit 2 GW bei durchschnittlichen Gegebenheiten', 'NEP 2025', 2000),
(8, NULL, 'link', 'Neubau DC-Erdkabel', 8, 'Mio. €/km', 'Neubautrasse mit 2 x 2 GW bei durchschnittlichen Gegebenheiten', 
'NEP 2025', 2000),
(6, NULL, 'link', 'Umstellung Freileitung AC → DC', 0.200000000000000011, 'Mio. €/km', 
'AC-Bestandsleitung, Stromkreisauflage DC (Nachbeseilung), Kosten pro Stromkreis', 'NEP 2025', 100),
(15, '380/220', 'transformer', '600 MVA', 8.5, '', '', 'NEP 2025', 14166);
 -- End
