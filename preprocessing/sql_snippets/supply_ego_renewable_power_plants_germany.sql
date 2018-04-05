/*
Setup for renewables power plants list of raw data of the status quo in Germany.

__copyright__ 	= "Europa-Universität Flensburg, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__  	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "wolfbunke"
*/

-- DROP TABLE supply.ego_renewable_powerplant;


CREATE TABLE supply.ego_renewable_powerplant
(
  id bigint NOT NULL,
  start_up_date timestamp without time zone,
  electrical_capacity numeric,
  generation_type text,
  generation_subtype character varying,
  thermal_capacity numeric,
  city character varying,
  postcode character varying,
  address character varying,
  lon numeric,
  lat numeric,
  gps_accuracy character varying,
  validation character varying,
  notification_reason character varying,
  eeg_id character varying,
  tso double precision,
  tso_eic character varying,
  dso_id character varying,
  dso character varying,
  voltage_level character varying,
  network_node character varying,
  power_plant_id character varying,
  source character varying,
  comment character varying,
  geom geometry(Point,4326),
  CONSTRAINT ego_renewable_powerplant_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE supply.ego_renewable_powerplant
  OWNER TO oeuser;
GRANT ALL ON TABLE supply.ego_renewable_powerplant TO oeuser;

-- set metadata
COMMENT ON TABLE supply.ego_renewable_powerplant IS '{
	"title": "Renewable power plants in Germany",
	"description": "This table contains a list of renewable energy power plants in Germany. This data join two sources: energymap.info, a data platform of the ''Deutsche Gesellschaft für Sonnenenergie e.V.'' and Bundesnetzagentur, the regularor together. ",
	"language": [ "eng", "ger"],
	"spatial": 
		{"location": "Germany",
		"extent": "europe",
		"resolution": "100 m"},
	"temporal": 
		{"reference_date": "2016-01-01",
		"start": "1900-01-01",
		"end": "2015-12-31",
		"resolution": ""},
	"sources": [
		{"name": "EnergyMap.info ", 
		"description": "Data provider how collects and clean TSO and DSO data of Germany", 
		"url": "http://www.energymap.info/download.html", 
		"license": "unknown ", 
		"copyright": "Deutsche Gesellschaft für Sonnenenergie e.V."},
		
		{"name": "Bundesnetzagentur (BNetzA)", 
		"description": "The Federal Network Agency for Electricity, Gas, Telecommunications, Posts and Railway Data is in Germany data provider of power plant", 
		"url": "https://www.bundesnetzagentur.de/DE/Sachgebiete/ElektrizitaetundGas/Unternehmen_Institutionen/ErneuerbareEnergien/Anlagenregister/Anlagenregister_Veroeffentlichung/Anlagenregister_Veroeffentlichungen_node.html", 
		"license": "Creative Commons Namensnennung-Keine Bearbeitung 3.0 Deutschland Lizenz", 
		"copyright": "© Bundesnetzagentur für Elektrizität, Gas, Telekommunikation, Post und Eisenbahnen; Pressestelle"}
	        ],
	"license": 
		{"id": "ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© ZNES Europa-Universität Flensburg"},
	"contributors": [
		{"name": "wolfbunke", "email": "", "date": "2016-06-16", "comment": "Update metadata version 1.3"}
		],
	"resources": [
		{"name": "supply.ego_renewable_power_plants_germany",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "id",	"description": "Unique identifier","unit": "" },
			{"name": "start_up_date","description": "start-up date","unit": "" },
			{"name": "electrical_capacity",	"description": "electrical capacity","unit": "kW" },
			{"name": "generation_type","description": "generation_type or main fuel type","unit": "" },
			{"name": "generation_subtype","description": "generation subtype","unit": "" },
			{"name": "thermal_capacity","description": "thermal capacity","unit": "kW" },
			{"name": "city","description": "Name of city or location","unit": "" },
			{"name": "postcode","description": "postcode","unit": "" },
			{"name": "address","description": "address","unit": "" },
			{"name": "lon",	"description": "longitude","unit": "" },
			{"name": "lat",	"description": "latitude","unit": "" },
			{"name": "gps_accuracy","description": "gps accuracy in meter",	"unit": "meter" },
			{"name": "validation",	"description": "validation comments",	"unit": "" },
			{"name":"notification_reason",	"description":"notification reason from BNetzA sources","unit":"" },
			{"name":"eeg_id","description":"EEG id of Unit","unit":"" },
			{"name":"tso",	"description":"Name of Transmission system operator","unit":"" },
			{"name":"tso_eic","description":"Name of Transmission system operator",	"unit":"" },
			{"name":"dso_id","description":"Name of District system operator","unit":"" },
			{"name":"dso",	"description":"Name of District system operator","unit":"" },
			{"name":"voltage_level","description":"voltage level",	"unit":"" },
			{"name":"network_node",	"description":"Name or code of network node","unit":"" },
			{"name":"power_plant_id","description":"power plant id from BNetzA","unit":"" },
			{"name":"source","description":"short Name of source: energymap or bnetza","unit":"" },
			{"name":"comment","description":"Further comment of changes","unit":"" },
			{"name":"geom",	"description":"Geometry","unit":"" } ] } ],
	"metadata_version": "1.3"}';

-- select description
SELECT obj_description('supply.ego_renewable_powerplant'::regclass)::json;


	


