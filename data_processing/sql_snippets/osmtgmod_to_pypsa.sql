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
  WHERE result_id = 2;

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
  WHERE result_id = 2 and (link_type = 'line' or link_type = 'cable');
  
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
  WHERE result_id = 2 and link_type = 'transformer';
  
  
-- per unit to absolute values

UPDATE calc_ego_hv_powerflow.line a
	SET 
		r = r * ((result.v_nom * 1000)^2 / (100 * 10^6)),
		x = x * ((result.v_nom * 1000)^2 / (100 * 10^6)),
		b = b * ((result.v_nom * 1000)^2 / (100 * 10^6)) 
		FROM 
			(SELECT bus_id, v_nom FROM calc_ego_hv_powerflow.bus)
			as result
WHERE a.bus0 = result.bus_id;


UPDATE calc_ego_hv_powerflow.transformer a
	SET 
		x = x * ((result.v_nom * 1000)^2 / (100 * 10^6))
		FROM 
			(SELECT 
			trafo_id, 
			GREATEST(
				(SELECT v_nom as v_nom_bus0 FROM calc_ego_hv_powerflow.bus WHERE bus_id = bus0), 
				(SELECT v_nom as v_nom_bus1 FROM calc_ego_hv_powerflow.bus WHERE bus_id = bus1)) 
				as v_nom 
			FROM calc_ego_hv_powerflow.transformer) as result
WHERE a.trafo_id = result.trafo_id;

-- calculate line length (in km) from geoms

UPDATE calc_ego_hv_powerflow.line a
	SET 
		length = result.length
		FROM 
		(SELECT b.line_id, st_length(b.geom,false)/1000 as length 
		from calc_ego_hv_powerflow.line b)
		as result
WHERE a.line_id = result.line_id;
