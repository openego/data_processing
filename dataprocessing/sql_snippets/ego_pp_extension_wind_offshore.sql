--- Insert missing wind_offhore generators at each woffshore-bus in germany 
--- p_nom = p_nom_nep - p_nom_ego_nep2035
--- NEP offshore buses manually maped with ego offshore-busses
DELETE FROM model_draft.ego_grid_pf_hv_extension_generator WHERE scn_name = 'extension_wind_offshore';
DELETE FROM model_draft.ego_grid_pf_hv_extension_generator_pq_set WHERE scn_name = 'extension_wind_offshore';

INSERT INTO model_draft.ego_grid_pf_hv_extension_generator (scn_name, generator_id, bus, source, p_nom)
VALUES ('extension_wind_offshore', 
	(SELECT GREATEST(MAX(a.generator_id), MAX(b.generator_id)) +1 FROM model_draft.ego_grid_pf_hv_generator a, model_draft.ego_grid_pf_hv_extension_generator b ),
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND scn_name = 'NEP 2035' AND geom = '0101000020E6100000F6D6A6710E081D40B62017FD957D4A40'),
	17,
	646.7),

	('extension_wind_offshore', 
	(SELECT GREATEST(MAX(a.generator_id), MAX(b.generator_id)) +2 FROM model_draft.ego_grid_pf_hv_generator a, model_draft.ego_grid_pf_hv_extension_generator b ),
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND scn_name = 'NEP 2035' AND geom = '0101000020E6100000E10EC4C4D53E1D4032D0841E19904A40'),
	17,
	50.0),

	
	('extension_wind_offshore', 
	(SELECT GREATEST(MAX(a.generator_id), MAX(b.generator_id)) +3 FROM model_draft.ego_grid_pf_hv_generator a, model_draft.ego_grid_pf_hv_extension_generator b ),
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND scn_name = 'NEP 2035' AND geom = '0101000020E6100000BB169FDC4B782240A84AC13A5BF54A40'),
	17,
	1333.9),

	('extension_wind_offshore', 
	(SELECT GREATEST(MAX(a.generator_id), MAX(b.generator_id)) +4 FROM model_draft.ego_grid_pf_hv_generator a, model_draft.ego_grid_pf_hv_extension_generator b ),
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND scn_name = 'NEP 2035' AND geom = '0101000020E6100000509011B4F05D2B4040490BB9CD114B40'),
	17,
	51.0);

--- Insert timeseries of missing wind offshore generators. 
--- p_max_pu copied from existing wind offshore generator at the same bus with the biggest p_nom	
INSERT INTO model_draft.ego_grid_pf_hv_extension_generator_pq_set (scn_name, generator_id, temp_id)
SELECT 'extension_wind_offshore', 
	generator_id,
	1
FROM model_draft.ego_grid_pf_hv_extension_generator 
WHERE scn_name = 'extension_wind_offshore';

UPDATE  model_draft.ego_grid_pf_hv_extension_generator_pq_set a
SET p_max_pu = (SELECT p_max_pu
		FROM model_draft.ego_grid_pf_hv_generator_pq_set c
		WHERE c.generator_id IN (SELECT d.generator_id
			FROM model_draft.ego_grid_pf_hv_generator d
			WHERE d.source = 17 AND 
			d.bus = (SELECT bus FROM model_draft.ego_grid_pf_hv_extension_generator b WHERE a.generator_id = b.generator_id)
			AND p_nom = (SELECT MAX(p_nom) FROM model_draft.ego_grid_pf_hv_generator
				WHERE source = 17 AND 
				bus = (SELECT bus FROM model_draft.ego_grid_pf_hv_extension_generator b WHERE a.generator_id = b.generator_id))))
WHERE  scn_name = 'extension_wind_offshore';

UPDATE  model_draft.ego_grid_pf_hv_extension_generator_pq_set a
SET p_set = p_max_pu
WHERE  scn_name = 'extension_wind_offshore';