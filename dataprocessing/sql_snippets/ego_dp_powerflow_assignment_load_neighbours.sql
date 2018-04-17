/* Create entries in hv load for all neighbouring countries and scenarios

__copyright__ 	= "Europa Universitaet Flensburg, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "wolfbunke, MarlonSchlemminger"
*/

-- DELETE
DELETE FROM model_draft.ego_grid_pf_hv_load WHERE bus IN (
SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus
WHERE central_bus = TRUE);

-- Status quo
INSERT into model_draft.ego_grid_pf_hv_load (scn_name, load_id, bus, sign)

	SELECT
	scn_name,
	load_id,
	bus_id AS bus,
	'-1' AS sign
		FROM
		(
		SELECT *,
		max(v_nom) OVER (PARTITION BY cntr_id) AS max_v_nom,
		row_number() OVER () + (SELECT max(load_id)
					FROM model_draft.ego_grid_pf_hv_load
					WHERE scn_name = 'Status Quo') AS load_id
		from model_draft.ego_grid_hv_electrical_neighbours_bus
		where central_bus = TRUE) SQ

		WHERE v_nom = max_v_nom;

-- NEP2035
INSERT into model_draft.ego_grid_pf_hv_load (scn_name, load_id, bus, sign)

	SELECT
	'NEP 2035',
	load_id,
	bus_id AS bus,
	'-1' AS sign
		FROM
		(
		SELECT *,
		max(v_nom) OVER (PARTITION BY cntr_id) AS max_v_nom,
		row_number() OVER () + (SELECT max(load_id)
					FROM model_draft.ego_grid_pf_hv_load
					WHERE scn_name = 'NEP 2035') AS load_id
		from model_draft.ego_grid_hv_electrical_neighbours_bus
		where central_bus = TRUE) NEP

	WHERE v_nom = max_v_nom;


-- eGo100
INSERT into model_draft.ego_grid_pf_hv_load (scn_name, load_id, bus, sign)

	SELECT
	'eGo 100',
	load_id,
	bus_id AS bus,
	'-1' AS sign
		FROM
		(
		SELECT *,
		max(v_nom) OVER (PARTITION BY cntr_id) AS max_v_nom,
		row_number() OVER () + (SELECT max(load_id)
					FROM model_draft.ego_grid_pf_hv_load
					WHERE scn_name = 'eGo 100') AS load_id
		from model_draft.ego_grid_hv_electrical_neighbours_bus
		where central_bus = TRUE
		) EGO
	WHERE v_nom = max_v_nom;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','output','model_draft','ego_grid_pf_hv_generator_pq_set','ego_dp_powerflow_timeseries_generator.sql',' ');
