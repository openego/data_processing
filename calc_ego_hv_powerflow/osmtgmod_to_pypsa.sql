-- osmTGmod2pyPSA

-- CLEAN UP OF TABLES
TRUNCATE calc_ego_hv_powerflow.bus CASCADE;
TRUNCATE calc_ego_hv_powerflow.line CASCADE;
TRUNCATE calc_ego_hv_powerflow.transformer CASCADE;

-- BUS DATA
INSERT INTO calc_ego_hv_powerflow.bus (bus_id, v_nom, geom)
SELECT 
  bus_i AS bus_id,
  base_kv AS v_nom,
  geom
  FROM calc_ego_osmtgmod.bus_data
  WHERE result_id = (SELECT max(result_id) FROM calc_ego_osmtgmod.bus_data);

-- BRANCH DATA
INSERT INTO calc_ego_hv_powerflow.line (line_id, bus0, bus1, x, r, b, s_nom, cables, frequency, geom, topo)
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
  FROM calc_ego_osmtgmod.branch_data
  WHERE result_id = (SELECT max(result_id) FROM calc_ego_osmtgmod.branch_data) and (link_type = 'line' or link_type = 'cable');
  
-- TRANSFORMER DATA
INSERT INTO calc_ego_hv_powerflow.transformer (trafo_id, bus0, bus1, x, s_nom, tap_ratio, phase_shift, geom, topo)
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
  FROM calc_ego_osmtgmod.branch_data
  WHERE result_id = (SELECT max(result_id) FROM calc_ego_osmtgmod.branch_data) and link_type = 'transformer';
  
  
-- per unit to absolute values

UPDATE calc_ego_hv_powerflow.line SET r = r * ((SELECT v_nom FROM calc_ego_hv_powerflow.bus WHERE bus0 = bus_id)^2 / (100 * 10^6));
UPDATE calc_ego_hv_powerflow.line SET x = x * ((SELECT v_nom FROM calc_ego_hv_powerflow.bus WHERE bus0 = bus_id)^2 / (100 * 10^6));
UPDATE calc_ego_hv_powerflow.line SET b = b * ((SELECT v_nom FROM calc_ego_hv_powerflow.bus WHERE bus0 = bus_id)^2 / (100 * 10^6));
UPDATE calc_ego_hv_powerflow.transformer SET x = x * ((SELECT max(v_nom) FROM calc_ego_hv_powerflow.bus WHERE bus_id = bus0 OR bus_id = bus1)^2 / (100 * 10^6));
