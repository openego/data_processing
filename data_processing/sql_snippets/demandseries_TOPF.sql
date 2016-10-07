-- Assigment of otg_id for demand time series (to be added to demand time series script, temporarily here)

INSERT INTO calc_ego_hv_powerflow.load_pq_set (load_id, temp_id, p_set)
	SELECT
	result.otg_id,
	1,
	b.demand

	FROM 
		(SELECT id, otg_id FROM calc_ego_substation.ego_deu_substations) 
		AS result, calc_ego_loads.ego_demand_per_transition_point b
	WHERE b.id = result.id;

