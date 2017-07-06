/*

SQL Script which prepare and insert a conventional power plant data list by scenario
for the project open_eGo and the tools eTraGo and eDisGo.

__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

    
 
Notes:
------
   
  Part I:
           Set up Status Quo data and create standardized table of all scenarios
  Part II:
            Power plants by NEP 2035 scenario data
  Part III:
            Power plants by eGo 100 scenario data

Documentation:
--------------
 flags:
  repowering : old unit get an update of this electrical_capacity (plus or minus)
  commissioning: New unit by a scenario assumption     
  decommissioning: decommissioning of status quo units by a scenario assumption
  constantly: existing plant for status quo or other scenarios
  
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','supply','ego_dp_supply_conv_powerplant',' .sql','');

DROP TABLE IF EXISTS model_draft.ego_dp_supply_conv_powerplant CASCADE;
CREATE TABLE model_draft.ego_dp_supply_conv_powerplant
(
  version text NOT NULL,
  id integer NOT NULL,
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
  voltage_level smallint,
  subst_id bigint,
  otg_id bigint,
  un_id bigint,
  la_id integer,
  scenario text,
  flag text,
  nuts varchar
)
WITH (
  OIDS=FALSE
);

ALTER TABLE model_draft.ego_dp_supply_conv_powerplant
  OWNER TO oeuser;
  
GRANT ALL ON TABLE model_draft.ego_dp_supply_conv_powerplant TO oeuser;

--DROP INDEX model_draft.ego_dp_supply_res_powerplant_idx;
CREATE INDEX ego_dp_supply_conv_powerplant_idx
  ON model_draft.ego_dp_supply_conv_powerplant
  USING gist
  (geom);
-- metadata description
COMMENT ON TABLE model_draft.test_table IS '{
	"title": "Good example title",
	"description": "example metadata for example data",
	"language": [ "eng", "ger", "fre" ],
	"spatial": 
		{"location": "none",
		"extent": "europe",
		"resolution": "100 m"},
	"temporal": 
		{"reference_date": "2016-01-01",
		"start": "2017-01-01",
		"end": "2017-12-31",
		"resolution": "hour"},

	"spatial": [
		{"extend": "Germany",
		"resolution": "100m"} ],

-- set meta data
COMMENT ON TABLE model_draft.ego_dp_supply_conv_powerplant
 IS 
  '{
	"title": "eGo Conventional power plants in Germany by Scenario",
	"description": "This dataset contains an augmented and corrected power plant list based on the power plant list provided by the OPSD (BNetzA and UBA) and NEP Kraftwerksliste 2015 for the scenario B1-2035 and the ZNES scenario eGo 100 in 2050.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "Germany",
		"extent": "europe",
		"resolution": "100 m"},
	"temporal": 
		{"reference_date": "2016-01-01",
		"start": "1900-01-01",
		"end": "2049-12-31",
		"resolution": ""},
	"sources": [
		{"name": "eGo data processing", 
		"description": "Scripts with allocate Geometry by OpenStreetMap Objects or create future scenarios by high resolution geo-allocation", 
		"url": "https://github.com/openego/data_processing", 
		"license": "GNU Affero General Public License Version 3 (AGPL-3.0)", 
		"copyright": "© ZNES Europa-Universität Flensburg"},
		
		{"name": "Open Power System Data (OPSD)",
                "url":  "http://data.open-power-system-data.org/conventional_power_plants/2016-02-08/",
                "license": "Creative Commons Attribution 4.0 International", 
		"copyright": "© Open Power System Data. 2017"}, 

		{"name": "Bundesnetzagentur (BNetzA)", 
		"description": "The Federal Network Agency for Electricity, Gas, Telecommunications, Posts and Railway Data is in Germany data provider of power plant", 
		"url": "https://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/ErneuerbareEnergien/Anlagenregister/Anlagenregister_Veroeffentlichung/Anlagenregister_Veroeffentlichungen_node.html", 
		"license": "Creative Commons Namensnennung-Keine Bearbeitung 3.0 Deutschland Lizenz", 
		"copyright": "© Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen; Pressestelle"}
		 ],
	"license": [
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© ZNES Europa-Universität Flensburg"} ],
	"contributors": [
		{"name": "wolfbunke", "email": " ", "date": "01.06.2017", "comment": "Create and restructure scripts and table"}],
	"resources": [
		{"name": "model_draft.ego_dp_supply_conv_powerplant",		
		"format": "PostgreSQL",
		"fields": [
				{"name": "version", "description": "Version ID", "unit": "" },
				{"name": "id", "description": "Unique identifier", "unit": "" },
				{"name": "bnetza_id", "description": "Bundesnetzagentur unit ID", "unit": " " },			
				{"name": "company", "description": "Name of company", "unit": " " },				
				{"name": "name", "description": "name of unit ", "unit": " " },				
				{"name": "postcode", "description": "postcode ", "unit": " " },				
				{"name": "city", "description": "Name of City", "unit": " " },				
				{"name": "street", "description": "Street name, address", "unit": " " },				
				{"name": "state", "description": "Name of federate state of location", "unit": " " },				
				{"name": "block", "description": "Power plant block", "unit": " " },	
				{"name": "commissioned_original", "description": "Year of commissioning (raw data)", "unit": " " },	
				{"name": "commissioned", "description": "Year of commissioning", "unit": " " },	
				{"name": "retrofit", "description": "Year of modernization according to UBA data", "unit": " " },	
				{"name": "shutdown", "description": "Year of decommissioning", "unit": " " },	
				{"name": "status", "description": "Power plant status", "unit": " " },	
				{"name": "fuel", "description": "Used fuel or energy source", "unit": " " },	
				{"name": "technology", "description": "Power plant technology or sort", "unit": " " },	
				{"name": "type", "description": "Purpose of the produced power", "unit": " " },	
				{"name": "eeg", "description":  "Status of being entitled to a renumeration", "unit": " " },	
				{"name": "chp", "description": "Status of being able to supply heat", "unit": " " },	
				{"name": "capacity", "description": "Power capacity", "unit": " " },	
				{"name": "capacity_uba", "description": "Power capacity according to UBA data", "unit": " " },
				{"name": "chp_capacity_uba", "description":  "Heat capacity according to UBA data", "unit": " " },	
				{"name": "efficiency_data", "description": "Proportion between power output and input", "unit": " " },	
				{"name": "efficiency_estimate", "description": "Estimated proportion between power output and input", "unit": " " },
				{"name": "network_node", "description":  "Connection point to the electricity grid", "unit": " " },
				{"name": "voltage", "description": "Grid or transformation level of the network node", "unit": " " },
				{"name": "network_operator", "description": "Network operator of the grid or transformation level", "unit": " " },
				{"name": "name_uba", "description": "Power plant name according to UBA data", "unit": " " },
				{"name": "lat", "description": "Precise geographic coordinates - latitude", "unit": " " },
				{"name": "lon", "description": "Precise geographic coordinates - longitude", "unit": " " },
				{"name": "comment", "description": "Further comments", "unit": " " },
				{"name": "geom", "description": "Geometry Point", "unit": " " },
				{"name": "voltage_level", "description": " ", "unit": " " },
				{"name": "subst_id", "description": "Unique identifier of related substation", "unit": "" },
				{"name": "otg_id", "description": "Unique identifier of related substation from osmTGmod", "unit": "" },
				{"name": "un_id", "description": "Unique identifier of RES and CONV power plants", "unit": "" },
				{"name": "la_id", "description": "Unique identifier of RES and CONV power plants", "unit": "" },									
				{"name": "scenario", "description": "Name of scenario", "unit": "" },
				{"name": "flag", "description": "Flag of scenario changes of an power plant unit (repowering, decommission or commissioning).", "unit": "" },
				{"name": "nuts", "description": "NUTS ID).", "unit": ""} ] } ],
		"meta_version": "1.3" }';
	  
-- select description
SELECT obj_description('model_draft.ego_dp_supply_conv_powerplant'::regclass)::json;

--------------------------------------------------------------------------------
-- Part I
--          Insert conventional power plants Scenarios: Status-Quo
--------------------------------------------------------------------------------

INSERT INTO model_draft.ego_dp_supply_conv_powerplant
	SELECT 
	  'v0.3.0'::text  as version,
	  gid as id,
	  bnetza_id,
	  company,
	  name,
	  postcode,
	  city,
	  street,
	  state,
	  block,
	  commissioned_original,
	  commissioned,
	  retrofit,
	  shutdown,
	  status,
	  fuel,
	  technology,
	  type,
	  eeg,
	  chp,
	  capacity,
	  capacity_uba,
	  chp_capacity_uba,
	  efficiency_data,
	  efficiency_estimate,
	  network_node,
	  voltage,
	  network_operator,
	  name_uba,
	  lat,
	  lon,
	  comment,
	  geom,
	  voltage_level,
	  subst_id,
	  otg_id,
	  un_id,
	  NULL::int as la_id,
	  'Status Quo'::text as scenario,
	  NULL::text as flag,
	  NULL::text as nuts
	FROM
	  model_draft.ego_supply_conv_powerplant;

--------------------------------------------------------------------------------
-- Part II
--          Insert conventional power plants Scenarios: NEP 2035
--------------------------------------------------------------------------------
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','supply','ego_dp_supply_conv_powerplant',' .sql','');


INSERT INTO model_draft.ego_dp_supply_conv_powerplant
SELECT 
  'v0.3.0'::text  as version,
  b.max +row_number() over (ORDER BY gid) as id,
  bnetza_id,
  NULL::text as company,
  power_plant_name as name,
  postcode,
  NULL::text as city,
  NULL::text as street,
  state,
  unit_name as block,
  NULL::text as commissioned_original,
  commissioning As commissioned,
  NULL::numeric as retrofit,
  NULL::numeric as shutdown,
  NULL::text as status,
  fuel,
  NULL::text as technology,
  NULL::text as type,
  NULL::text as eeg,
  chp,
  rated_power_b2035 as capacity,
  NULL::numeric as capacity_uba,
  NULL::numeric as chp_capacity_uba,
  NULL::numeric as efficiency_data,
  NULL::numeric as efficiency_estimate,
  NULL::text as network_node,
  NULL::text as voltage,
  tso as network_operator,
  NULL::text as name_uba,
  lat,
  lon,
  'NEP2015 KW list'::text as comment,
  geom,
  voltage_level,
  subst_id,
  otg_id,
  un_id,
  NULL::int as la_id,
  'NEP 2035'::text as scenario,
  NULL::text as flag,
  NULL::text as nuts
FROM
  model_draft.ego_supply_conv_powerplant_2035,
   (
    SELECT max(id) as max
    FROM 	model_draft.ego_dp_supply_conv_powerplant
  ) as b;

-- update id's of same bnetza id
Update model_draft.ego_dp_supply_conv_powerplant A
  set id = sub.id  
FROM
(
  SELECT DISTINCT A.id, A.bnetza_id, A.scenario
  FROM model_draft.ego_dp_supply_conv_powerplant A
  INNER JOIN model_draft.ego_dp_supply_conv_powerplant B
  ON A.bnetza_id = B.bnetza_id
  WHERE A.scenario  in('Status Quo','NEP 2035')
  AND A.id != B.id
  Order by A.bnetza_id
 ) sub
WHERE sub.scenario = 'Status Quo'
AND A.bnetza_id = sub.bnetza_id 
AND A.scenario = 'NEP 2035';

--change flag
Update model_draft.ego_dp_supply_conv_powerplant A
  set flag = 'decommissioning'
Where  A.capacity = 0
AND scenario = 'NEP 2035';
--
Update model_draft.ego_dp_supply_conv_powerplant A
  set  flag = 'constantly' 
  WHERE scenario = 'Status Quo'

--------------------------------------------------------------------------------
-- Part III 
--          Add given Hydro storages
--	    Scenarios: ego 100%
--------------------------------------------------------------------------------

-- only pumed_storage for NEP2035 and Satatus Quo 
-- No entries or changes use of MView


<<<<<<< HEAD:preprocessing/sql_snippets/ego_dp_conv_by_scenario.sql
--------------------------------------------------------------------------------
-- Part IV 
--          Create Views by scenario
--	    Scenarios: ego 100%
--------------------------------------------------------------------------------

-- MView for Status Quo
DROP MATERIALIZED VIEW IF EXISTS  model_draft.ego_supply_conv_powerplant_sq_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_sq_mview AS
    SELECT *
    FROM model_draft.ego_dp_supply_conv_powerplant
    WHERE scenario = 'Status Quo';

-- grant (oeuser)    
ALTER TABLE model_draft.ego_supply_conv_powerplant_sq_mview OWNER TO oeuser;

-- MView for NEP 2035
DROP MATERIALIZED VIEW IF EXISTS model_draft.ego_supply_conv_powerplant_nep2035_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_nep2035_mview AS
    SELECT *
    FROM  model_draft.ego_dp_supply_conv_powerplant
    WHERE scenario = 'NEP 2035'
    AND   capacity >= 0 
    AND   fuel not in ('hydro', 'run_of_river', 'reservoir')
    ;

-- grant (oeuser)    
ALTER TABLE model_draft.ego_supply_conv_powerplant_nep2035_mview OWNER TO oeuser;

-- MView for eGo 100 
DROP MATERIALIZED VIEW IF EXISTS  model_draft.ego_supply_conv_powerplant_ego100_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_ego100_mview AS
	SELECT 
	  'v0.3.0'::text as version,
	  id,
	  bnetza_id,
	  company,
	  name,
	  postcode,
	  city,
	  street,
	  state,
	  block,
	  commissioned_original,
	  commissioned,
	  retrofit,
	  shutdown,
	  status,
	  fuel,
	  technology,
	  type,
	  eeg,
	  chp,
	  capacity,
	  capacity_uba,
	  chp_capacity_uba,
	  efficiency_data,
	  efficiency_estimate,
	  network_node,
	  voltage,
	  network_operator,
	  name_uba,
	  lat,
	  lon,
	  'pumed storage for eGo 100'::text as comment,
	  geom,
	  voltage_level,
	  subst_id,
	  otg_id,
	  un_id,
	  la_id,
	  'eGo 100'::text as scenario,
	  'constantly'::text as flag,
	  nuts
	FROM model_draft.ego_dp_supply_conv_powerplant
	WHERE scenario in('Status Quo','NEP 2035', 'eGo 100')
	AND fuel = 'pumped_storage'
	AND capacity >= 0;


-- grant (oeuser)    
ALTER TABLE model_draft.ego_supply_conv_powerplant_ego100_mview OWNER TO oeuser;
=======
>>>>>>> refactor/assignment_generator:dataprocessing/preprocessing/ego_dp_conv_by_scenario.sql
-- END
