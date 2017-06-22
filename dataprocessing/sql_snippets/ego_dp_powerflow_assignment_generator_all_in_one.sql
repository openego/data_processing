/*
Assignment of generators to the relevant substation in the grid model based on grid districts for generators connected to the HV, MV or LV level. 
Generators connected to the EHV level are assigned based on voronoi cells. 
__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu, Ludee" 
*/

-- contains all generators (RE and conventional) but no duplicates
DROP TABLE IF EXISTS 	model_draft.ego_supply_generator CASCADE;
CREATE TABLE 		model_draft.ego_supply_generator (
	un_id 		serial NOT NULL, 
	re_id 		integer, 
	conv_id 	integer,
	aggr_id_pf 	integer, 
	aggr_id_ms 	integer, 
	geom 		geometry(Point,4326),
	CONSTRAINT ego_supply_generator_pkey PRIMARY KEY (un_id) );

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_generator OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_supply_res_powerplant','ego_dp_powerflow_assignment_generator.sql',' ');
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_supply_conv_powerplant','ego_dp_powerflow_assignment_generator.sql',' ');

INSERT INTO model_draft.ego_supply_generator (re_id, geom) 
	SELECT 	id, geom
	FROM 	model_draft.ego_supply_res_powerplant
	WHERE geom IS NOT NULL;

INSERT INTO model_draft.ego_supply_generator (conv_id, geom) 
	SELECT 	gid, geom
	FROM 	model_draft.ego_supply_conv_powerplant
	WHERE eeg NOT LIKE 'yes'; -- Duplicates that already occur in the eeg-list are ignored 

-- index GIST (geom)
CREATE INDEX 	ego_supply_generator_idx
	ON 	model_draft.ego_supply_generator USING gist (geom);

-- metadata
COMMENT ON TABLE  model_draft.ego_supply_generator IS
'{
"Name": "eGo generators merged",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["ego_dp_powerflow_assignment_generator.sql"],
"Column": [
                   {"Name": "un_id",
                    "Description": "unique id for unified generators (res and conv)",
                    "Unit": "" },  
                   {"Name": "re_id",
                    "Description": "id for res-generators",
                    "Unit": "" },     
                   {"Name": "conv_id",
                    "Description": "id for conventional generators",
                    "Unit": "" }, 
                   {"Name": "aggr_id_pf",
                    "Description": "aggregate id for hv powerflow",
                    "Unit": "" },
                   {"Name": "aggr_id_ms",
                    "Description": "aggregate id for mv powerflow",
                    "Unit": "" },                        
                   {"Name": "geom",
                    "Description": "geometry",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "05.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "",
                    "Date":  "27.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- select description
SELECT obj_description('model_draft.ego_supply_generator' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_supply_generator','ego_dp_powerflow_assignment_generator.sql',' ');


-- Update table on conventional power plants and add information on unified id of generators and information of relevant bus

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_mv_griddistrict','ego_dp_powerflow_assignment_generator.sql',' ');
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_ehv_substation_voronoi','ego_dp_powerflow_assignment_generator.sql',' ');
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_hvmv_substation','ego_dp_powerflow_assignment_generator.sql',' ');



-- Insert otg_id of bus
UPDATE model_draft.ego_supply_conv_powerplant a
	SET 	otg_id = b.otg_id 
	FROM 	model_draft.ego_grid_hvmv_substation b
	WHERE 	a.subst_id = b.subst_id AND voltage_level > 2;
	
UPDATE model_draft.ego_supply_conv_powerplant a
	SET 	otg_id = b.otg_id 
	FROM 	model_draft.ego_ehv_substation b
WHERE a.subst_id = b.subst_id AND voltage_level < 3;
