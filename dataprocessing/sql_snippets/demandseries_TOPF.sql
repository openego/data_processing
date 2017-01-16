/*


__copyright__ = "tba" 
__license__ = "tba" 
__author__ = "" 
*/

-- Assigment of otg_id for demand time series

DELETE FROM model_draft.ego_grid_pf_hv_load_pq_set;

INSERT INTO model_draft.ego_grid_pf_hv_load_pq_set (load_id, temp_id, p_set, q_set)
	SELECT
	result.otg_id,
	1,
	b.p_set,
	b.q_set

	FROM 
		(SELECT subst_id, otg_id FROM model_draft.ego_grid_hvmv_substation) 
		AS result, model_draft.ego_demand_hvmv_demand b
	WHERE b.id = result.otg_id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_grid_pf_hv_load_pq_set','demandseries_TOPF.sql',' ');
