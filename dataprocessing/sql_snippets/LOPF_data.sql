/* 
LOPF data -
Setting marginal_cost ( operating cost + fuel cost + CO2 crt cost ) 
in model_draft.ego_grid_pf_hv_generator according to renpass_gis, NEP 2014 scenario.
In addition p_max_pu is set for all generators with variable dispatch based on p_max_pu = p_set / p_nom .

Martin
*/

UPDATE model_draft.ego_grid_pf_hv_generator
SET marginal_cost =        -- operating costs + fuel costs + CO2 crt cost
(
CASE source                 -- source / renpass_gis NEP 2014 
when 1 THEN (30.3012 + 2.0) -- gas / gas
when 2 THEN (6.3761 + 4.4)  -- lignite / lignite
when 3 THEN (8.6470 + 23.0) -- waste / waste
when 4 THEN (39.5156 + 1.5) -- oil / oil
when 5 THEN (4.1832 + 0.5)  -- uranium / uranium
when 6 THEN (20.0586 + 3.9) -- biomass / biomass
when 7 THEN (30.3012 + 2.0) -- eeg_gas / gas
when 8 THEN (10.9541 + 4.0) -- coal / hard_coal
ELSE 0                      -- run_of_river/reservoir/pumped_storage/solar/wind/geothermal/other_non_renewable
END);


-- Scenario eGo data processing
INSERT INTO     scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
    SELECT  '0.2' AS version,
    'model_draft' AS schema_name,
    'ego_grid_pf_hv_generator' AS table_name,
    'LOPF_data.sql' AS script_name,
    COUNT(marginal_cost)AS entries,
    'OK' AS status,
    NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
    FROM    model_draft.ego_grid_pf_hv_generator;


-- set p_max_pu
-- TODO: outermost subquery needed?
UPDATE model_draft.ego_grid_pf_hv_generator_pq_set Y
SET p_max_pu = T3.p_max_pu
FROM (
	SELECT T2.generator_id, array_agg(T2.p_max_pu ORDER BY rn) as p_max_pu
	FROM
		(
			SELECT T1.*, row_number() over() AS rn -- row number introduced to keep array order
			FROM (
				SELECT 
				B.generator_id, 
				A.p_nom , 
				unnest(B.p_set) / A.p_nom AS p_max_pu 
				FROM model_draft.ego_grid_pf_hv_generator A
				JOIN model_draft.ego_grid_pf_hv_generator_pq_set  B USING (generator_id)
				WHERE A.dispatch = 'variable'
			) AS T1
		) AS T2 
	GROUP BY T2.generator_id
) T3 WHERE T3.generator_id = Y.generator_id;


-- Scenario eGo data processing
INSERT INTO     scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
    SELECT  '0.2' AS version,
    'model_draft' AS schema_name,
    'ego_grid_pf_hv_generator_pq_set' AS table_name,
    'LOPF_data.sql' AS script_name,
    COUNT(p_max_pu)AS entries,
    'OK' AS status,
    NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
    FROM    model_draft.ego_grid_pf_hv_generator_pq_set;

