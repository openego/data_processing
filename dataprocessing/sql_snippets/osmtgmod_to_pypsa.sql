/*
osmTGmod2pyPSA

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu, Ludee" 
*/
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
  
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_grid_pf_hv_bus','osmtgmod_to_pypsa.sql',' ');

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

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_grid_pf_hv_line','osmtgmod_to_pypsa.sql',' ');

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

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_grid_pf_hv_transformer','osmtgmod_to_pypsa.sql',' ');

-- per unit to absolute values

UPDATE model_draft.ego_grid_pf_hv_line a
	SET 
		r = r * (((SELECT v_nom 
				FROM model_draft.ego_grid_pf_hv_bus 
				WHERE bus_id=bus1)*1000)^2 / (100 * 10^6)),
		x = x * (((SELECT v_nom 
				FROM model_draft.ego_grid_pf_hv_bus
				WHERE bus_id=bus1)*1000)^2 / (100 * 10^6)),
		b = b * (((SELECT v_nom 
				FROM model_draft.ego_grid_pf_hv_bus
				WHERE bus_id=bus1)*1000)^2 / (100 * 10^6));

UPDATE model_draft.ego_grid_pf_hv_transformer a
	SET 
		x = x * (((GREATEST(
				(SELECT v_nom as v_nom_bus0 FROM model_draft.ego_grid_pf_hv_bus WHERE bus_id = bus0), 
				(SELECT v_nom as v_nom_bus1 FROM model_draft.ego_grid_pf_hv_bus WHERE bus_id = bus1)))* 1000)^2 / (100 * 10^6));

-- calculate line length (in km) from geoms

UPDATE model_draft.ego_grid_pf_hv_line a
	SET 
		length = result.length
		FROM 
		(SELECT b.line_id, st_length(b.geom,false)/1000 as length 
		from model_draft.ego_grid_pf_hv_line b)
		as result
WHERE a.line_id = result.line_id;
