-- osmTGmod2pyPSA

-- CLEAN UP OF TABLES
TRUNCATE model_draft.ego_grid_pf_hv_bus CASCADE;
TRUNCATE model_draft.ego_grid_pf_hv_line CASCADE;
TRUNCATE model_draft.ego_grid_pf_hv_transformer CASCADE;

-- BUS DATA
INSERT INTO model_draft.ego_grid_pf_hv_bus (bus_id, v_nom, geom)
SELECT 
  bus_i AS bus_id,
  base_kv AS v_nom,
  geom
  FROM grid.otg_ehvhv_bus_data
  WHERE result_id = 1;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'calc_ego_hv_powerflow' AS schema_name,
		'bus' AS table_name,
		'osmtgmod_to_pypsa.sql' AS script_name,
		COUNT(bus_id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_pf_hv_bus;

-- BRANCH DATA
INSERT INTO model_draft.ego_grid_pf_hv_line (line_id, bus0, bus1, x, r, b, s_nom, cables, frequency, geom, topo)
SELECT 
  branch_id AS line_id,
  f_bus AS bus0,
  t_bus AS bus1,
  br_r AS r,
  br_x AS x,
  br_b as b,
  rate_a as s_nom,
  cables,
  frequency,
  geom,
  topo
  FROM grid.otg_ehvhv_branch_data
  WHERE result_id = 1 and (link_type = 'line' or link_type = 'cable');
  
-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'calc_ego_hv_powerflow' AS schema_name,
		'line' AS table_name,
		'osmtgmod_to_pypsa.sql' AS script_name,
		COUNT(line_id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_pf_hv_line;

-- TRANSFORMER DATA
INSERT INTO model_draft.ego_grid_pf_hv_transformer (trafo_id, bus0, bus1, x, s_nom, tap_ratio, phase_shift, geom, topo)
SELECT 
  branch_id AS trafo_id,
  f_bus AS bus0,
  t_bus AS bus1,
  br_x AS x,
  rate_a as s_nom,
  tap AS tap_ratio,
  shift AS phase_shift,
  geom,
  topo
  FROM grid.otg_ehvhv_branch_data
  WHERE result_id = 1 and link_type = 'transformer';
  
  
-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'calc_ego_hv_powerflow' AS schema_name,
		'transformer' AS table_name,
		'osmtgmod_to_pypsa.sql' AS script_name,
		COUNT(trafo_id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_pf_hv_transformer;

-- per unit to absolute values

UPDATE model_draft.ego_grid_pf_hv_line a
	SET 
		r = r * ((result.v_nom * 1000)^2 / (100 * 10^6)),
		x = x * ((result.v_nom * 1000)^2 / (100 * 10^6)),
		b = b * ((result.v_nom * 1000)^2 / (100 * 10^6)) 
		FROM 
			(SELECT bus_id, v_nom FROM model_draft.ego_grid_pf_hv_bus)
			as result
WHERE a.bus0 = result.bus_id;


UPDATE model_draft.ego_grid_pf_hv_transformer a
	SET 
		x = x * ((result.v_nom * 1000)^2 / (100 * 10^6))
		FROM 
			(SELECT 
			trafo_id, 
			GREATEST(
				(SELECT v_nom as v_nom_bus0 FROM model_draft.ego_grid_pf_hv_bus WHERE bus_id = bus0), 
				(SELECT v_nom as v_nom_bus1 FROM model_draft.ego_grid_pf_hv_bus WHERE bus_id = bus1)) 
				as v_nom 
			FROM model_draft.ego_grid_pf_hv_transformer) as result
WHERE a.trafo_id = result.trafo_id;

-- calculate line length (in km) from geoms

UPDATE model_draft.ego_grid_pf_hv_line a
	SET 
		length = result.length
		FROM 
		(SELECT b.line_id, st_length(b.geom,false)/1000 as length 
		from model_draft.ego_grid_pf_hv_line b)
		as result
WHERE a.line_id = result.line_id;
