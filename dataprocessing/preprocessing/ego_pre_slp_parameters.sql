/*
Create table with assumptions and parameters on standard load profiles (SLP)

WARNING: It drops the table and deletes old entries when executed!

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "gplssm"
*/

-- create empty parameters table
DROP TABLE IF EXISTS	scenario.ego_slp_parameters CASCADE;
CREATE TABLE 		scenario.ego_slp_parameters (
	parameter 	text,
	value	double precision,
	unit text,
	CONSTRAINT ego_slp_parameters_pkey PRIMARY KEY (parameter));

-- grant (oeuser)
ALTER TABLE	scenario.ego_slp_parameters OWNER TO oeuser;


-- scenario list
INSERT INTO	scenario.ego_slp_parameters (parameter, value, unit) VALUES
	('consumption_peak_h0',0.00021371999999999998, 'kW/kWh'),
	('consumption_peak_g0',0.00024040000000000002, 'kW/kWh'),
	('consumption_peak_g1',0.00048948, 'kW/kWh'),
	('consumption_peak_g2',0.00025124, 'kW/kWh'),
	('consumption_peak_g3',0.00015448, 'kW/kWh'),
	('consumption_peak_g4',0.00023051999999999998, 'kW/kWh'),
	('consumption_peak_g5',0.00025592, 'kW/kWh'),
	('consumption_peak_g6',0.000299, 'kW/kWh'),
	('consumption_peak_l0',0.00024035999999999998, 'kW/kWh'),
	('consumption_peak_l1',0.00030524, 'kW/kWh'),
	('consumption_peak_l2',0.00021384, 'kW/kWh'),
	('consumption_peak_i0', 0.000132, 'kW/kWh');

-- metadata
COMMENT ON TABLE scenario.ego_slp_parameters IS '{
	"title": "eGo dataprocessing - SLP parameters",
	"description": "Set of parameters (sometimes assumptions) that are required to calculate sectoral peak within LV grid districts. The parameters consumption_peak_{h,g,l}{0..6} (i.e. consumption_peak_g0) reflect the ratio of peak demand (in kW) to annual consumption (kWh). This parameter can be used to determine a peak load based on given annual consuption.",
	"language": [ "eng"],
	"reference_date": " ",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ",
		"url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": "Repräsentative VDEW-Lastprofile", "description": "Autoren: Hermann Meier and Christian Fünfgeld and Thomas Adam and Bernd Schiefdecker",
		"url": " ", "license": " ", "copyright": " "} ],
	"spatial": [
		{"extend": "",
		"resolution": ""} ],
	"license": [
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "https://opendatacommons.org/licenses/odbl/1.0/",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© Reiner Lemoine Institut"} ],
	"contributors": [
		{"name": "gplssm", "email": "", "date": "19.04.2017", "comment": "Create table and insert initial parameters" }],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "parameter", "description": "name of parameter", "unit": " " },
				{"name": "value", "description": "numeric value of parameter", "unit": "various, see column unit" },
				{"name": "unit", "description": "unit of parameter value in each row", "unit": " " } ]},
		"meta_version": "1.2"}] }' ;

-- select description
SELECT obj_description('scenario.ego_slp_parameters' ::regclass) ::json;


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','input','scenario','ego_slp_parameters','ego_slp_parameters.sql','Create SLP parameter table');
