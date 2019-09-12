/*
eGo Data Processing result data versioning
Copy a version from model_draft to OEP schema

__copyright__   = "© Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/

-- POWERFLOW

-- hv pf bus
/* DELETE FROM grid.ego_pf_hv_bus
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_bus
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_bus;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_bus','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');

-- hv pf generator
/*DELETE SELECT *  FROM grid.ego_pf_hv_bus
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_generator
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_generator;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_generator','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf generator_pq_set
/* DELETE FROM grid.ego_pf_hv_generator_pq_set
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_generator_pq_set
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_generator_pq_set;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_generator_pq_set','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf line
/* DELETE FROM grid.ego_pf_hv_line
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_line
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_line;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_line','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');

-- hv pf link
/* DELETE FROM grid.ego_pf_hv_link
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_link
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_link;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_line','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf load
/* DELETE FROM grid.ego_pf_hv_load
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_load
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_load;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_load','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf load_pq_set
/* DELETE FROM grid.ego_pf_hv_load_pq_set
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_load_pq_set
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_load_pq_set;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_load_pq_set','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf source
/* DELETE FROM grid.ego_pf_hv_source
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_source
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_source;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_source','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf storage
/* DELETE FROM grid.ego_pf_hv_storage
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_storage
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_storage;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_storage','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf storage_pq_set
/* DELETE FROM grid.ego_pf_hv_storage_pq_set
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_storage_pq_set
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_storage_pq_set;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_storage_pq_set','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf temp_resolution
/* DELETE FROM grid.ego_pf_hv_temp_resolution
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_temp_resolution
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_temp_resolution;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_temp_resolution','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf transformer
/* DELETE FROM grid.ego_pf_hv_transformer
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_transformer
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_transformer;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_transformer','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');

-- hv pf extension bus
/* DELETE FROM grid.ego_pf_hv_extension_bus
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_extension_bus
	SELECT	'v0.4.6',
		 scn_name,  bus_id,  v_nom,  current_type,  v_mag_pu_min,  v_mag_pu_max,  geom	
	FROM	model_draft.ego_grid_pf_hv_extension_bus
	WHERE scn_name IN ('extension_nep2035_b2', 'decommissioning_nep2035_b2','extension_nep2035_confirmed', 'decommissioning_nep2035_confirmed', 'extension_BE_NO_NEP 2035', 'extension_BE_NO_eGo 100' );
-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_extension_bus','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');

-- hv pf extension generator
 /*DELETE FROM grid.ego_pf_hv_extension_generator
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_extension_generator
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_extension_generator
	WHERE scn_name IN ('extension_nep2035_b2', 'decommissioning_nep2035_b2','extension_nep2035_confirmed', 'decommissioning_nep2035_confirmed', 'extension_BE_NO_NEP 2035', 'extension_BE_NO_eGo 100' );

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_extension_generator','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf extension generator_pq_set
/* DELETE FROM grid.ego_pf_hv_generator_pq_set
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_extension_generator_pq_set
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_extension_generator_pq_set
	WHERE scn_name IN ('extension_nep2035_b2', 'decommissioning_nep2035_b2','extension_nep2035_confirmed', 'decommissioning_nep2035_confirmed', 'extension_BE_NO_NEP 2035', 'extension_BE_NO_eGo 100' );

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_extension_generator_pq_set','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf extension line
/* DELETE FROM grid.ego_pf_hv_extension_line
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_extension_line
	SELECT	'v0.4.6',
		 scn_name,  line_id ,  bus0, bus1, x, r, g, b, s_nom, s_nom_extendable, s_nom_min, s_nom_max, capital_cost, length, cables, frequency, terrain_factor, geom, topo, v_nom, project, project_id
	FROM	model_draft.ego_grid_pf_hv_extension_line
	WHERE scn_name IN ('extension_nep2035_b2', 'decommissioning_nep2035_b2','extension_nep2035_confirmed', 'decommissioning_nep2035_confirmed', 'extension_BE_NO_NEP 2035', 'extension_BE_NO_eGo 100' );

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_extension_line','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');

-- hv pf extension link
/* DELETE FROM grid.ego_pf_hv_extension_link
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_extension_link
	SELECT	'v0.4.6',
		 scn_name, link_id, bus0, bus1, efficiency, marginal_cost, p_nom, p_nom_extendable, p_nom_min, p_nom_max, capital_cost, length, terrain_factor,geom, topo, project, project_id
	FROM	model_draft.ego_grid_pf_hv_extension_link
	WHERE scn_name IN ('extension_nep2035_b2', 'decommissioning_nep2035_b2','extension_nep2035_confirmed', 'decommissioning_nep2035_confirmed', 'extension_BE_NO_NEP 2035', 'extension_BE_NO_eGo 100' );

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_extension_link','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf extension load
/* DELETE FROM grid.ego_pf_hv_extension_load
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_extension_load
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_extension_load
	WHERE scn_name IN ('extension_nep2035_b2', 'decommissioning_nep2035_b2','extension_nep2035_confirmed', 'decommissioning_nep2035_confirmed', 'extension_BE_NO_NEP 2035', 'extension_BE_NO_eGo 100' );

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_extension_load','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf extension load_pq_set
/* DELETE FROM grid.ego_pf_hv_extension_load_pq_set
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_extension_load_pq_set
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_extension_load_pq_set
	WHERE scn_name IN ('extension_nep2035_b2', 'decommissioning_nep2035_b2','extension_nep2035_confirmed', 'decommissioning_nep2035_confirmed', 'extension_BE_NO_NEP 2035', 'extension_BE_NO_eGo 100' );

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_extension_load_pq_set','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf extension source
/* DELETE FROM grid.ego_pf_hv_source
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_extension_source
	SELECT	'v0.4.6',
		source_id, name, co2_emissions, commentary
	FROM	model_draft.ego_grid_pf_hv_extension_source;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_extension_source','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf extension storage
/* DELETE FROM grid.ego_pf_hv_extension_storage
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_extension_storage
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_extension_storage
	WHERE scn_name IN ('extension_nep2035_b2', 'decommissioning_nep2035_b2','extension_nep2035_confirmed', 'decommissioning_nep2035_confirmed', 'extension_BE_NO_NEP 2035', 'extension_BE_NO_eGo 100' );

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_extension_storage','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf extension storage_pq_set
/* DELETE FROM grid.ego_pf_hv_extension_storage_pq_set
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_extension_storage_pq_set
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_extension_storage_pq_set
	WHERE scn_name IN ('extension_nep2035_b2', 'decommissioning_nep2035_b2','extension_nep2035_confirmed', 'decommissioning_nep2035_confirmed', 'extension_BE_NO_NEP 2035', 'extension_BE_NO_eGo 100' );

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_extension_storage_pq_set','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf extension temp_resolution
/* DELETE FROM grid.ego_pf_hv_extension_temp_resolution
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_extension_temp_resolution
	SELECT	'v0.4.6',
		*
	FROM	model_draft.ego_grid_pf_hv_extension_temp_resolution;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_extension_temp_resolution','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');


-- hv pf extension transformer
/* DELETE FROM grid.ego_pf_hv_extension_transformer
	WHERE	version = 'v0.4.6'; */
	
INSERT INTO grid.ego_pf_hv_extension_transformer
	SELECT	'v0.4.6',
		  scn_name, trafo_id, bus0,bus1, x, r, g, b, s_nom, s_nom_extendable, s_nom_min, s_nom_max, tap_ratio, phase_shift, capital_cost, geom, topo, project
	FROM	model_draft.ego_grid_pf_hv_extension_transformer
	WHERE scn_name IN ('extension_nep2035_b2', 'decommissioning_nep2035_b2','extension_nep2035_confirmed', 'decommissioning_nep2035_confirmed', 'extension_BE_NO_NEP 2035', 'extension_BE_NO_eGo 100' );

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.6','result','grid','ego_pf_hv_extension_transformer','ego_dp_versioning.sql','versioning only for ego_pf_hv tables');