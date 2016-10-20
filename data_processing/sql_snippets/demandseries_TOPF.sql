-- Assigment of otg_id for demand time series

DELETE FROM calc_ego_hv_powerflow.load_pq_set;
DELETE FROM calc_ego_hv_powerflow.temp_resolution;

INSERT INTO calc_ego_hv_powerflow.temp_resolution (temp_id, timesteps, resolution, start_time)
SELECT 1, 8760, 'h', TIMESTAMP '2011-01-01 00:00:00';

INSERT INTO calc_ego_hv_powerflow.load_pq_set (load_id, temp_id, p_set, q_set)
	SELECT
	result.otg_id,
	1,
	b.p_set,
	b.q_set

	FROM 
		(SELECT subst_id, otg_id FROM calc_ego_substation.ego_deu_substations) 
		AS result, calc_ego_loads.ego_demand_per_transition_point b
	WHERE b.id = result.otg_id;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'calc_ego_hv_powerflow' AS schema_name,
		'load_pq_set' AS table_name,
		'demandseries_TOPF.sql' AS script_name,
		COUNT(load_id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_hv_powerflow.load_pq_set;
