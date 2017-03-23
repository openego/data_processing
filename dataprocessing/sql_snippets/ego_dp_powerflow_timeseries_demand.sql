/*
Insert demand series into pf-schema

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "ulfmueller, wbunke"
*/

-- Assignment of otg_id for demand time series

DELETE FROM model_draft.ego_grid_pf_hv_load_pq_set;

INSERT INTO model_draft.ego_grid_pf_hv_load_pq_set (load_id, temp_id, p_set, q_set)
	SELECT
	result.otg_id,
	1,
	b.p_set,
	b.q_set

	FROM 
		(SELECT subst_id, otg_id FROM model_draft.ego_grid_hvmv_substation) 
		AS result, model_draft.ego_demand_hvmv_demand b
	WHERE b.id = result.otg_id;

-- Insert demand timeseries for electrical neighbours based on renpass_gis
INSERT INTO model_draft.ego_grid_pf_hv_load_pq_set (scn_name, load_id, temp_id, p_set)

	SELECT
	'Status Quo' AS scn_name,
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
		AND B.id < 27
		AND A.type = 'from_bus'
		AND A.scenario_id = 37
		) SQ
		JOIN model_draft.ego_grid_pf_hv_load C on (C.bus = SQ.bus_id)
	WHERE SQ.v_nom = SQ.max_v_nom
	AND C.scn_name = 'Status Quo'
	GROUP BY C.load_id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_grid_pf_hv_load_pq_set','demandseries_TOPF.sql',' ');
