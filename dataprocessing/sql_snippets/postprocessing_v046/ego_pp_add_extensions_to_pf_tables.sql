--- wind offshore---
UPDATE grid.ego_pf_hv_generator a
SET p_nom = w_off.p_nom_new
FROM 
(SELECT pf.generator_id, ext.p_nom + pf.p_nom as p_nom_new
FROM model_draft.ego_grid_pf_hv_extension_generator ext, model_draft.ego_grid_pf_hv_generator pf
WHERE ext.bus = pf.bus 
AND pf.source = ext.source 
AND pf.scn_name = 'NEP 2035'
AND ext.scn_name = 'extension_bugfix_wind_offshore'
AND pf.generator_id IN (SELECT d.generator_id
			FROM model_draft.ego_grid_pf_hv_generator d
			WHERE d.source = 17 AND 
			d.bus = pf.bus AND d.scn_name = pf.scn_name
			AND p_nom = (SELECT MAX(p_nom) FROM model_draft.ego_grid_pf_hv_generator
				WHERE source = 17 AND 
				bus =  pf.bus AND scn_name = pf.scn_name))
				) as w_off

WHERE a.version = 'v0.4.6' AND a.generator_id IN (w_off.generator_id) AND a.scn_name = 'NEP 2035';

/*SELECT sum(p_nom) FROM grid.ego_pf_hv_generator a
WHERE a.version = 'v0.4.6' AND a.source = 17 AND a.scn_name = 'NEP 2035';*/

UPDATE grid.ego_pf_hv_generator a
SET p_nom = w_off.p_nom_new
FROM
(SELECT pf.generator_id, ext.p_nom + pf.p_nom as p_nom_new
FROM model_draft.ego_grid_pf_hv_extension_generator ext, model_draft.ego_grid_pf_hv_generator pf
WHERE ext.bus = pf.bus 
AND pf.source = ext.source 
AND pf.scn_name = 'eGo 100'
AND ext.scn_name = 'extension_bugfix_wind_offshore_eGo100'
AND pf.generator_id IN (SELECT d.generator_id
			FROM model_draft.ego_grid_pf_hv_generator d
			WHERE d.source = 17 AND 
			d.bus = pf.bus AND d.scn_name = pf.scn_name
			AND p_nom = (SELECT MAX(p_nom) FROM model_draft.ego_grid_pf_hv_generator
				WHERE source = 17 AND 
				bus =  pf.bus AND scn_name = pf.scn_name))
				) as w_off

WHERE a.version = 'v0.4.6' AND a.generator_id IN (w_off.generator_id) AND a.scn_name = 'eGo 100';

/*SELECT sum(p_nom) FROM grid.ego_pf_hv_generator a
WHERE a.version = 'v0.4.6' AND a.source = 17 AND a.scn_name = 'eGo 100';*/

--- wind onshore ---
UPDATE grid.ego_pf_hv_generator a
SET p_nom = w_on.p_nom_new
FROM
(SELECT pf.bus, pf.generator_id,  pf.p_nom - decom.p_nom as p_nom_new
FROM model_draft.ego_grid_pf_hv_extension_generator decom, model_draft.ego_grid_pf_hv_generator pf
WHERE decom.bus = pf.bus 
AND pf.source = decom.source 
AND pf.scn_name = 'NEP 2035'
AND decom.scn_name = 'decommissioning_bugfix_pv_wind_nep'
AND pf.source = 13
AND pf.generator_id  = decom.generator_id) as w_on
WHERE a.version = 'v0.4.6' AND a.generator_id IN (w_on.generator_id) AND a.scn_name = 'NEP 2035';

/*SELECT sum(p_nom) FROM grid.ego_pf_hv_generator a
WHERE a.version = 'v0.4.6' AND a.source = 13 AND a.scn_name = 'NEP 2035';*/
--- solar ---

UPDATE grid.ego_pf_hv_generator a
SET p_nom = w_on.p_nom_new
FROM
(SELECT pf.bus, pf.generator_id,  pf.p_nom - decom.p_nom as p_nom_new
FROM model_draft.ego_grid_pf_hv_extension_generator decom, model_draft.ego_grid_pf_hv_generator pf
WHERE decom.bus = pf.bus 
AND pf.source = decom.source 
AND pf.scn_name = 'NEP 2035'
AND decom.scn_name = 'decommissioning_bugfix_pv_wind_nep'
AND pf.source = 12
AND pf.generator_id  = decom.generator_id) as w_on
WHERE a.version = 'v0.4.6' AND a.generator_id IN (w_on.generator_id) AND a.scn_name = 'NEP 2035';
/*SELECT sum(p_nom) FROM grid.ego_pf_hv_generator a
WHERE a.version = 'v0.4.6' AND a.source = 12 AND a.scn_name = 'NEP 2035';*/

DELETE FROM grid.ego_pf_hv_generator_pq_set WHERE generator_id IN 
(SELECT generator_id FROM grid.ego_pf_hv_generator WHERE p_nom <= 0 AND version = 'v0.4.6');
DELETE FROM grid.ego_pf_hv_generator WHERE p_nom <= 0 AND version = 'v0.4.6';

UPDATE grid.ego_pf_hv_generator a
SET p_nom = chp.p_nom_new
FROM
(SELECT pf.generator_id, ext.p_nom + pf.p_nom as p_nom_new
FROM model_draft.ego_grid_pf_hv_extension_generator ext, model_draft.ego_grid_pf_hv_generator pf
WHERE ext.bus = pf.bus 
AND pf.source = ext.source 
AND pf.scn_name = 'NEP 2035'
AND ext.scn_name = 'extension_chp_nep'
AND pf.generator_id IN (SELECT d.generator_id
			FROM model_draft.ego_grid_pf_hv_generator d
			WHERE d.source = 1 AND 
			d.bus = pf.bus AND d.scn_name = pf.scn_name
			AND p_nom = (SELECT MAX(p_nom) FROM model_draft.ego_grid_pf_hv_generator
				WHERE source = 1 AND 
				bus =  pf.bus AND scn_name = pf.scn_name))
				) as chp
WHERE a.version = 'v0.4.6' AND a.generator_id IN (chp.generator_id) AND a.scn_name = 'NEP 2035';


INSERT INTO grid.ego_pf_hv_generator
SELECT 'v0.4.6', 'NEP 2035', generator_id,bus,dispatch, control ,  p_nom,  p_nom_extendable, p_nom_min, p_nom_max, p_min_pu_fixed, p_max_pu_fixed,sign, source, marginal_cost, capital_cost, efficiency
FROM model_draft.ego_grid_pf_hv_extension_generator 
WHERE scn_name = 'extension_chp_nep'
AND bus NOT IN (SELECT bus FROM model_draft.ego_grid_pf_hv_generator WHERE scn_name = 'NEP 2035' AND source = 1)
/*SELECT sum(p_nom) FROM grid.ego_pf_hv_generator a
WHERE a.version = 'v0.4.6' AND a.source = 1 AND a.scn_name = 'NEP 2035';*/

