---

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
  CONSTRAINT ego_grid_line_expansion_costs_pkey PRIMARY KEY (cost_id)
 
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_line_expansion_costs
  OWNER TO oeuser;
  
COMMENT ON TABLE model_draft.ego_grid_line_expansion_costs
  IS E'{
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
                    "name": "comment",
                    "unit": "",
                    "description": "Comment"
                },
                {
                    "name": "source",
                    "unit": "",
                    "description": "short name of data source"
                }
            ],
            "name": "model_draft.ego_grid_line_expansion_costs",
            "format": "sql"
        }
    ],
    "metadata_version": "1.3"
}';
