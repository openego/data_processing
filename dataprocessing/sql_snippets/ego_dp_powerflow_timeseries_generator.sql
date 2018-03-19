/*
Quick workaround to transfer renpassG!S results into the corresponding powerflow table.

__copyright__ 	= "Europa Universitaet Flensburg, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "wolfbunke"

TODO: storage in storage_pqset #1069
*/


-- DELETE
DELETE FROM model_draft.ego_grid_pf_hv_load WHERE bus IN (
SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus
WHERE id <= 27);

-- INSERT neigbouring states in load table
-- Status Quo
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
		where id <= 27
		) SQ
	WHERE v_nom = max_v_nom;

-- NEP 2035

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
		where id <= 27
		) NEP
	WHERE v_nom = max_v_nom;


-- eGo 100

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
		where id <= 27
		) EGO
	WHERE v_nom = max_v_nom;







-- Demand timeseries

-- NEP 2035
/* Handled in  ego_dp_powerflow_load_timeseries_NEP2035.sql

INSERT INTO model_draft.ego_grid_pf_hv_load_pq_set (scn_name, load_id, temp_id, p_set)

	SELECT
	'NEP 2035' AS scn_name,
	C.load_id AS load_id,
	1 AS temp_id,
	array_agg(SQ.val ORDER BY SQ.datetime) AS p_set
	FROM
		(
		SELECT *,
		max(B.v_nom) over (partition by B.cntr_id) AS max_v_nom
			FROM calc_renpass_gis.renpass_gis_results A
			join model_draft.ego_grid_hv_electrical_neighbours_bus B
			ON (B.cntr_id = substring(A.obj_label, 1, 2))
		WHERE A.obj_label LIKE '%%load%%'
		AND B.id <= 27
		AND A.type = 'from_bus'
		AND A.scenario_id = 38
		) SQ
		JOIN model_draft.ego_grid_pf_hv_load C on (C.bus = SQ.bus_id)
	WHERE SQ.v_nom = SQ.max_v_nom
	AND C.scn_name = 'NEP 2035'
	GROUP BY C.load_id;
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_pf_hv_generator_pq_set','ego_dp_powerflow_timeseries_generator.sql',' ');
