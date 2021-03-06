/*

All generators from the `conventional <http://oep.iks.cs.ovgu.de/dataedit/view/model_draft/ego_dp_supply_conv_powerplant>`_ and `renewable <http://oep.iks.cs.ovgu.de/dataedit/view/model_draft/ego_dp_supply_res_powerplant>`_ power plant list are brought together in a `central generator list <http://oep.iks.cs.ovgu.de/dataedit/view/model_draft/ego_supply_generator>`_.
A unified id (un_id) is assigned to those generators listed. Information on the un_id is then added to the conventional and renewable power plant lists.  

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/


-------------------------
-- Create table which includes conventional and renewable power plants and introduce unified ID over all technologies and scenarios
-------------------------


-- contains all generators (RE and conventional) but no duplicates for all scenarios
DROP TABLE IF EXISTS 	model_draft.ego_supply_generator CASCADE;
CREATE TABLE 		model_draft.ego_supply_generator (
	un_id 		serial NOT NULL, 
	re_id 		integer, 
	conv_id 	integer,
	aggr_id_pf 	integer, 
	aggr_id_ms 	integer, 
	geom 		geometry(Point,4326),
	CONSTRAINT ego_supply_generator_pkey PRIMARY KEY (un_id) );

ALTER TABLE model_draft.ego_supply_generator OWNER TO oeuser;


INSERT INTO model_draft.ego_supply_generator (re_id, geom) 
	SELECT 	id, geom
	FROM 	model_draft.ego_dp_supply_res_powerplant
	WHERE geom IS NOT NULL;

INSERT INTO model_draft.ego_supply_generator (conv_id, geom) 
	SELECT 	id, geom
	FROM 	model_draft.ego_dp_supply_conv_powerplant
	WHERE eeg IS NULL OR eeg = 'no'; -- Duplicates that already occur in the eeg-list are ignored 

-- index GIST (geom)
CREATE INDEX 	ego_supply_generator_idx
	ON 	model_draft.ego_supply_generator USING gist (geom);


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_supply_generator','ego_dp_powerflow_assignment_unid.sql',' ');
	

-- Update power plant tables and add information on unified id of generators

UPDATE model_draft.ego_dp_supply_res_powerplant SET un_id = NULL; 
UPDATE model_draft.ego_dp_supply_conv_powerplant SET un_id = NULL; 

-- Update un_id from generators_total  
UPDATE model_draft.ego_dp_supply_conv_powerplant a
	SET 	un_id = b.un_id 
	FROM 	model_draft.ego_supply_generator b
	WHERE 	a.id = b.conv_id; 


-- Update un_id from generators_total 
UPDATE model_draft.ego_dp_supply_res_powerplant a
	SET 	un_id = b.un_id 
	FROM 	model_draft.ego_supply_generator b
	WHERE 	a.id = b.re_id; 



-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_dp_supply_res_powerplant','ego_dp_powerflow_assignment_unid.sql',' ');
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_dp_supply_conv_powerplant','ego_dp_powerflow_assignment_unid.sql',' ');






