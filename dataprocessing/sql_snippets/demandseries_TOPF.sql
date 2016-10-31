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

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'calc_ego_hv_powerflow' AS schema_name,
		'load_pq_set' AS table_name,
		'demandseries_TOPF.sql' AS script_name,
		COUNT(load_id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_pf_hv_load_pq_set;
