/*
SQL Script to create supply.ego_conv_powerplant and set meta data
Data: Status quo conventional power plants in Germany

__copyright__ = "Europa-Universität Flensburg, Fachhochschule Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke, IlkaCu"
*/

--------------------------------------------------------------------------------
-- Table: supply.ego_conv_powerplant
-- DROP TABLE supply.ego_conv_powerplant;
/*

CREATE TABLE supply.ego_conv_powerplant
(
  gid integer NOT NULL,
  bnetza_id text,
  company text,
  name text,
  postcode text,
  city text,
  street text,
  state text,
  block text,
  commissioned_original text,
  commissioned double precision,
  retrofit double precision,
  shutdown double precision,
  status text,
  fuel text,
  technology text,
  type text,
  eeg text,
  chp text,
  capacity double precision,
  capacity_uba double precision,
  chp_capacity_uba double precision,
  efficiency_data double precision,
  efficiency_estimate double precision,
  network_node text,
  voltage text,
  network_operator text,
  name_uba text,
  lat double precision,
  lon double precision,
  comment text,
  geom geometry(Point,4326),
  voltage_level double precision,
  subst_id bigint,
  otg_id bigint,
  un_id bigint,
  CONSTRAINT ego_conv_powerplant_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE supply.ego_conv_powerplant
  OWNER TO oeuser;
 */ 


supply.ego_conv_powerplant
 
 -------------------------------------------------------------------------------- 
COMMENT ON TABLE supply.ego_conv_powerplant
  IS '{
"Name": "eGo conventional powerplant list status quo",
"Source": [{
                  "Name": "open_eGo data_processing",
                  "URL":  "https://github.com/openego/data_processing" }, 
	   {
                  "Name": "BNetzA Kraftwerksliste",
                  "URL":  "http://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/Versorgungssicherheit/Erzeugungskapazitaeten/Kraftwerksliste/kraftwerksliste-node.html" }, 
{
                  "Name": "Umweltbundesamt Datenbank Kraftwerke in Deutschland",
                  "URL":  "http://www.umweltbundesamt.de/dokument/datenbank-kraftwerke-in-deutschland" },
 {
                  "Name": "Open Power System Data",
                  "URL":  "data.open-power-system-data.org/conventional_power_plants/" }                 
                                      ],
"Reference date": ["08.02.2016"],
"Date of collection": ["01.01.2016"],
"Original file": ["proc_power_plant_germany.sql"],
"Spatial resolution": ["Germany"],
"Description": ["This dataset contains processed information on powerplants from BNetzA and UBA-list from Germany"],
"Column": [
                   {"Name": "gid",
                    "Description": "geo id of entry",
                    "Unit": "" }, 
                   {"Name": "bnetza_id",
                    "Description": "id give by BNetzA",
                    "Unit": "" }, 
                   {"Name": "company",
                    "Description": "Name of company",
                    "Unit": "" }, 
                   {"Name": "name",
                    "Description": "Name of power plant or block",
                    "Unit": "" }, 
                   {"Name": "postcode",
                    "Description": "Postcode as specified in the BNetzA power plant list",
                    "Unit": "" }, 
                   {"Name": "city",
                    "Description": "City as specified in the BNetzA power plant list",
                    "Unit": "" }, 
                   {"Name": "street",
                    "Description": "Street as specified in the BNetzA power plant list",
                    "Unit": "" }, 
                   {"Name": "state",
                    "Description": "State as specified in the BNetzA power plant list",
                    "Unit": "" }, 
                   {"Name": "block",
                    "Description": "Block name as specified in the BNetzA power plant list",
                    "Unit": "" }, 
                   {"Name": "commissioned_original",
                    "Description": "Year of commissioning (raw data)",
                    "Unit": "" }, 
                   {"Name": "commissioned",
                    "Description": "Year of commissioning formatted as integer, using data from BNetzA and UBA",
                    "Unit": "" }, 
                   {"Name": "retrofit",
                    "Description": "Year of modernization according to UBA data",
                    "Unit": "" }, 
                   {"Name": "shutdown",
                    "Description": "Year of decommissioning based on BNetzA data",
                    "Unit": "" }, 
                   {"Name": "status",
                    "Description": "Power plant status",
                    "Unit": "" }, 
                   {"Name": "fuel",
                    "Description": "Used fuel or energy source",
                    "Unit": "" }, 
                   {"Name": "technology",
                    "Description": "Power plant technology or sort",
                    "Unit": "" }, 
                   {"Name": "type",
                    "Description": "Purpose of the produced power",
                    "Unit": "" }, 
                   {"Name": "eeg",
                    "Description": "Status of being entitled to a renumeration",
                    "Unit": "" }, 
                   {"Name": "chp",
                    "Description": "Status of being able to supply heat",
                    "Unit": "" }, 
                   {"Name": "capacity",
                    "Description": "Net installed capacity based on BNetzA",
                    "Unit": "MW" }, 
                   {"Name": "capacity_uba",
                    "Description": "Gross installed capacity according to UBA data",
                    "Unit": "MW" }, 
                   {"Name": "chp_capacity_uba",
                    "Description": "Heat capacity according to UBA data",
                    "Unit": "MW" }, 
                   {"Name": "efficiency_data",
                    "Description": "Proportion between power output and input, self researched values",
                    "Unit": "" }, 
                   {"Name": "efficiency_estimate",
                    "Description": "Estimated proportion between power output and input",
                    "Unit": "" }, 
                   {"Name": "network_node",
                    "Description": "Connection point to the electricity grid based on BNetzA data",
                    "Unit": "" }, 
                   {"Name": "voltage",
                    "Description": "Grid or transformation level of the network node based on BNetzA data",
                    "Unit": "" }, 
                   {"Name": "network_operator",
                    "Description": "Network operator of the grid or transformation level based on BNetzA data",
                    "Unit": "" }, 
                   {"Name": "name_uba",
                    "Description": "Power plant name as specified in the UBA power plant list",
                    "Unit": "" }, 
                   {"Name": "lat",
                    "Description": "Precise geographic coordinates - latitude",
                    "Unit": "" }, 
                   {"Name": "lon",
                    "Description": "Precise geographic coordinates - longitude",
                    "Unit": "" }, 
                   {"Name": "comment",
                    "Description": "Further comments",
                    "Unit": "" }, 
                   {"Name": "geom",
                    "Description": "geometry by lon and lat data",
                    "Unit": "" }, 
                   {"Name": "voltage_level",
                    "Description": "voltage level to which generator is connected (partly calculated based on installed capacity)",
                    "Unit": "" }, 
                   {"Name": "subst_id",
                    "Description": "id of associated substation",
                    "Unit": "" }, 
                   {"Name": "otg_id",
                    "Description": "otg_id of associated substation",
                    "Unit": "" },                        
                   {"Name": "un_id",
                    "Description": "unified id for res and conv powerplants",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Wolf-Dieter Bunke",
                    "Mail": "wolf-dieter.bunke@uni-flensburg.de",
                    "Date":  "02.02.2017",
                    "Comment": "Add missing meta for V2" },
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "27.10.2016",
                    "Comment": "added information to metadata" } 
                  ],
"Notes": [" "],
"Licence": [{
            "Name": "Open Database License (ODbL) v1.0",
	          "URL": "http://opendatacommons.org/licenses/odbl/1.0/",
	          "Copyright": 	"ZNES EUF"}],
"Instructions for proper use": ["..."]
}';

-- -- --- -- --- -- -- ---- -- --- -- -- - ---- ---- --- ----- ---- --- ---
-- check metadata

SELECT obj_description('supply.ego_conv_powerplant'::regclass)::json;
-- -- --- -- --- -- -- ---- -- --- -- -- - ---- ---- --- ----- ---- --- ---

-- Index: supply.ego_conv_powerplant_idx
-- DROP INDEX supply.ego_conv_powerplant_idx;

CREATE INDEX ego_conv_powerplant_idx
  ON supply.ego_conv_powerplant
  USING gist
  (geom);


