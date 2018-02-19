/*
Quick workaround to transfer renpassG!S results into the corresponding powerflow table.

__copyright__ 	= "Europa Universitaet Flensburg, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "wolfbunke, MarlonSchlemminger"

TODO: storage in storage_pqset #1069
*/

-- Status Quo
-- aggregate nominal capacity on aggr_id FROM powerflow generators, keeping the source
DROP materialized view if EXISTS calc_renpass_gis.pf_pp_by_source_aggr_id;
CREATE materialized view calc_renpass_gis.pf_pp_by_source_aggr_id
AS
SELECT
SQ.aggr_id, SQ.source, SQ.p_nom / sum(SQ.p_nom) over (partition by SQ.source) AS fraction_of_installed
FROM
	(SELECT
	aggr_id,
	source,
	sum(p_nom) AS p_nom
	FROM model_draft.ego_supply_pf_generator_single
	WHERE scn_name = 'Status Quo'
	AND aggr_id IS NOT NULL
GROUP BY aggr_id, source) SQ;

-- map renpassG!S power sources to pf generators, aggr on fuel types, neglect efficiency classes
DROP materialized view if EXISTS calc_renpass_gis.pp_feedin_by_pf_source;
CREATE materialized view calc_renpass_gis.pp_feedin_by_pf_source
AS
SELECT
SQ.source, SQ.datetime, sum(SQ.val) AS val
FROM
	(SELECT
	CASE
	WHEN obj_label LIKE '%%gas%%' THEN 1
	when obj_label LIKE '%%lignite%%' THEN 2
	when obj_label LIKE '%%mixed_fuels%%' THEN 3
	when obj_label LIKE '%%oil%%' THEN 4
	when obj_label LIKE '%%uranium%%' THEN 5
	when obj_label LIKE '%%biomass%%' THEN 6
	when obj_label LIKE '%%hard_coal%%' THEN 8
	when obj_label LIKE '%%run_of_river%%' THEN 9
--	when obj_label LIKE '%%storage_phs%%' THEN 11
	when obj_label LIKE '%%solar%%' THEN 12
	when obj_label LIKE '%%wind%%' THEN 13
	END AS source,
	bus_label,
	obj_label,
	type,
	datetime,
	val
		FROM calc_renpass_gis.renpass_gis_results
	-- conds
	WHERE obj_label LIKE '%%DE%%' -- only Germany
	AND obj_label not LIKE '%%powerline%%' -- without any powerlines
	AND scenario_id = 43
	 -- take only one flow (input), storage output flow seems to be the right one (?)
	AND ((obj_label LIKE '%%storage%%' AND type = 'from_bus') or (obj_label not LIKE '%%storage%%' AND type = 'to_bus'))
) AS SQ
WHERE SQ.source IS not NULL
GROUP BY SQ.source, SQ.datetime;

-- get feedin per generator_id from ego_renewable_feedin
DROP materialized view IF EXISTS model_draft.ren_feedin_by_gen_id;
CREATE materialized view model_draft.ren_feedin_by_gen_id
AS
SELECT
gen.generator_id, feedin.feedin
FROM
	(SELECT
	aggr_id AS generator_id,
	w_id,
	source
	FROM
	model_draft.ego_supply_pf_generator_single 
	WHERE source IN (12, 13)
	AND scn_name = 'Status Quo'
	GROUP BY aggr_id, w_id, source) AS gen,
	(SELECT
	w_id,
	CASE
	WHEN source LIKE '%%solar%%' THEN 12
	WHEN source LIKE '%%wind%%' THEN 13
	END AS source,
	feedin
	FROM model_draft.ego_renewable_feedin) AS feedin
WHERE gen.source = feedin.source
	AND gen.w_id = feedin.w_id;
	

--
DELETE FROM model_draft.ego_grid_pf_hv_generator_pq_set;

-- construct array per aggr_id according to source timeseries for conventional
INSERT into model_draft.ego_grid_pf_hv_generator_pq_set (scn_name, generator_id, temp_id, p_set)
SELECT
	'Status Quo' AS scn_name,
	A.aggr_id,
	1 AS temp_id,
	array_agg(A.fraction_of_installed * B.val ORDER BY B.datetime) AS p_set
		FROM calc_renpass_gis.pf_pp_by_source_aggr_id A,
		calc_renpass_gis.pp_feedin_by_pf_source B
WHERE A.source = B.source
GROUP BY A.aggr_id;

-- set p_max_pu as timeseries from ego_renewable_feedin
UPDATE model_draft.ego_grid_pf_hv_generator_pq_set A
	SET p_max_pu = feedin.feedin
		FROM model_draft.ren_feedin_by_gen_id AS feedin
		WHERE A.generator_id = feedin.generator_id;
-- NEP 2035

-- aggregate nominal capacity on aggr_id FROM powerflow generators, keeping the source
DROP materialized view if EXISTS calc_renpass_gis.pf_pp_by_source_aggr_id;
CREATE materialized view calc_renpass_gis.pf_pp_by_source_aggr_id
AS
SELECT
NEP.aggr_id, NEP.source, NEP.p_nom / sum(NEP.p_nom) over (partition by NEP.source) AS fraction_of_installed
FROM
	(SELECT
	aggr_id,
	source,
	sum(p_nom) AS p_nom
	FROM model_draft.ego_supply_pf_generator_single
	WHERE scn_name = 'NEP 2035'
	AND aggr_id IS NOT NULL
	GROUP BY aggr_id, source) NEP;

-- map renpassG!S power sources to pf generators, aggr on fuel types, neglect efficiency classes
DROP materialized view if EXISTS calc_renpass_gis.pp_feedin_by_pf_source;
CREATE materialized view calc_renpass_gis.pp_feedin_by_pf_source
AS
SELECT
NEP.source, NEP.datetime, sum(NEP.val) AS val
FROM
	(SELECT
	CASE
	WHEN obj_label LIKE '%%gas%%' THEN 1
	when obj_label LIKE '%%lignite%%' THEN 2
	when obj_label LIKE '%%mixed_fuels%%' THEN 3
	when obj_label LIKE '%%oil%%' THEN 4
	when obj_label LIKE '%%uranium%%' THEN 5
	when obj_label LIKE '%%biomass%%' THEN 6
	when obj_label LIKE '%%hard_coal%%' THEN 8
	when obj_label LIKE '%%run_of_river%%' THEN 9
--	when obj_label LIKE '%%storage_phs%%' THEN 11
	when obj_label LIKE '%%solar%%' THEN 12
	when obj_label LIKE '%%wind%%' THEN 13
	END AS source,
	bus_label,
	obj_label,
	type,
	datetime,
	val
		FROM calc_renpass_gis.renpass_gis_results
	-- conds
	WHERE obj_label LIKE '%%DE%%' -- only Germany
	AND obj_label not LIKE '%%powerline%%' -- without any powerlines
	AND scenario_id = 38
	 -- take only one flow (input), storage output flow seems to be the right one (?)
	AND ((obj_label LIKE '%%storage%%' AND type = 'from_bus') or (obj_label not LIKE '%%storage%%' AND type = 'to_bus'))
) AS NEP
WHERE NEP.source IS not NULL
GROUP BY NEP.source, NEP.datetime;

-- get feedin per generator_id from ego_renewable_feedin
DROP materialized view IF EXISTS model_draft.ren_feedin_by_gen_id;
CREATE materialized view model_draft.ren_feedin_by_gen_id
AS
SELECT
gen.generator_id, feedin.feedin
FROM
	(SELECT
	aggr_id AS generator_id,
	w_id,
	source
	FROM
	model_draft.ego_supply_pf_generator_single 
	WHERE source IN (12, 13)
	AND scn_name = 'NEP 2035'
	GROUP BY aggr_id, w_id, source) AS gen,
	(SELECT
	w_id,
	CASE
	WHEN source LIKE '%%solar%%' THEN 12
	WHEN source LIKE '%%wind%%' THEN 13
	END AS source,
	feedin
	FROM model_draft.ego_renewable_feedin) AS feedin
WHERE gen.source = feedin.source
	AND gen.w_id = feedin.w_id;

-- construct array per aggr_id according to source timeseries
INSERT into model_draft.ego_grid_pf_hv_generator_pq_set (scn_name, generator_id, temp_id, p_set)
SELECT
	'NEP 2035' AS scn_name,
	A.aggr_id,
	1 AS temp_id,
	array_agg(A.fraction_of_installed * B.val ORDER BY B.datetime) AS p_set
		FROM calc_renpass_gis.pf_pp_by_source_aggr_id A,
		calc_renpass_gis.pp_feedin_by_pf_source B
WHERE A.source = B.source
GROUP BY A.aggr_id;

-- set p_max_pu as timeseries from ego_renewable_feedin
UPDATE model_draft.ego_grid_pf_hv_generator_pq_set A
	SET p_max_pu = feedin.feedin
		FROM model_draft.ren_feedin_by_gen_id AS feedin
		WHERE A.generator_id = feedin.generator_id;

--eGo100
-- aggregate nominal capacity on aggr_id FROM powerflow generators, keeping the source
DROP materialized view if EXISTS calc_renpass_gis.pf_pp_by_source_aggr_id;
CREATE materialized view calc_renpass_gis.pf_pp_by_source_aggr_id
AS
SELECT
eGo.aggr_id, eGo.source, eGo.p_nom / sum(eGo.p_nom) over (partition by eGo.source) AS fraction_of_installed
FROM
	(SELECT
	aggr_id,
	source,
	sum(p_nom) AS p_nom
	FROM model_draft.ego_supply_pf_generator_single
	WHERE scn_name = 'eGo 100'
	AND aggr_id IS NOT NULL
	GROUP BY aggr_id, source) eGo;

-- map renpassG!S power sources to pf generators, aggr on fuel types, neglect efficiency classes
DROP materialized view if EXISTS calc_renpass_gis.pp_feedin_by_pf_source;
CREATE materialized view calc_renpass_gis.pp_feedin_by_pf_source
AS
SELECT
eGo.source, eGo.datetime, sum(eGo.val) AS val
FROM
	(SELECT
	CASE
	WHEN obj_label LIKE '%%gas%%' THEN 1
	when obj_label LIKE '%%lignite%%' THEN 2
	when obj_label LIKE '%%mixed_fuels%%' THEN 3
	when obj_label LIKE '%%oil%%' THEN 4
	when obj_label LIKE '%%uranium%%' THEN 5
	when obj_label LIKE '%%biomass%%' THEN 6
	when obj_label LIKE '%%hard_coal%%' THEN 8
	when obj_label LIKE '%%run_of_river%%' THEN 9
--	when obj_label LIKE '%%storage_phs%%' THEN 11
	when obj_label LIKE '%%solar%%' THEN 12
	when obj_label LIKE '%%wind%%' THEN 13
	END AS source,
	bus_label,
	obj_label,
	type,
	datetime,
	val
		FROM calc_renpass_gis.renpass_gis_results
	-- conds
	WHERE obj_label LIKE '%%DE%%' -- only Germany
	AND obj_label not LIKE '%%powerline%%' -- without any powerlines
	AND scenario_id = 41
	 -- take only one flow (input), storage output flow seems to be the right one (?)
	AND ((obj_label LIKE '%%storage%%' AND type = 'from_bus') or (obj_label not LIKE '%%storage%%' AND type = 'to_bus'))
) AS eGo
WHERE eGo.source IS not NULL
GROUP BY eGo.source, eGo.datetime;

-- get feedin per generator_id from ego_renewable_feedin
DROP materialized view IF EXISTS model_draft.ren_feedin_by_gen_id;
CREATE materialized view model_draft.ren_feedin_by_gen_id
AS
SELECT
gen.generator_id, feedin.feedin
FROM
	(SELECT
	aggr_id AS generator_id,
	w_id,
	source
	FROM
	model_draft.ego_supply_pf_generator_single 
	WHERE source IN (12, 13)
	AND scn_name = 'eGo 100'
	GROUP BY aggr_id, w_id, source) AS gen,
	(SELECT
	w_id,
	CASE
	WHEN source LIKE '%%solar%%' THEN 12
	WHEN source LIKE '%%wind%%' THEN 13
	END AS source,
	feedin
	FROM model_draft.ego_renewable_feedin) AS feedin
WHERE gen.source = feedin.source
	AND gen.w_id = feedin.w_id;

-- construct array per aggr_id according to source timeseries
INSERT into model_draft.ego_grid_pf_hv_generator_pq_set (scn_name, generator_id, temp_id, p_set)
SELECT
	'eGo 100' AS scn_name,
	A.aggr_id,
	1 AS temp_id,
	array_agg(A.fraction_of_installed * B.val ORDER BY B.datetime) AS p_set
		FROM calc_renpass_gis.pf_pp_by_source_aggr_id A,
		calc_renpass_gis.pp_feedin_by_pf_source B
WHERE A.source = B.source
GROUP BY A.aggr_id;

-- set p_max_pu as timeseries from ego_renewable_feedin
UPDATE model_draft.ego_grid_pf_hv_generator_pq_set A
	SET p_max_pu = feedin.feedin
		FROM model_draft.ren_feedin_by_gen_id AS feedin
		WHERE A.generator_id = feedin.generator_id;

ALTER MATERIALIZED VIEW model_draft.ren_feedin_by_gen_id
OWNER TO oeuser; 


------------------ NEIGHBOURING COUNTRIES
-- 1
DELETE FROM model_draft.ego_grid_pf_hv_generator WHERE generator_id > 200000 AND scn_name = 'Status Quo';
DELETE FROM model_draft.ego_grid_pf_hv_generator WHERE generator_id > 200000 AND scn_name = 'NEP 2035';
DELETE FROM model_draft.ego_grid_pf_hv_generator WHERE generator_id > 200000 AND scn_name = 'eGo 100';


-- INSERT params of LinearTransformers in model_draft.ego_grid_pf_hv_generator (countries besides Germany)
-- starting generator_id at 200000, bus_id for neighbouring countries > 2800000 atm
-- Status Quo
INSERT into model_draft.ego_grid_pf_hv_generator

	SELECT
	'Status Quo' AS scn_name,
	row_number() over () + 200000 AS generator_id,
	B.bus_id AS bus,
	'flexible' AS dispatch,
	'PV' AS control,
	nominal_value[1] AS p_nom,
	FALSE AS p_nom_extendable,
	NULL AS p_nom_max,
	0 AS p_nom_min,
	0 AS p_min_pu_fixed,
	1 AS p_max_pu_fixed,
	1 AS sign,
	CASE
		WHEN source LIKE '%%gas%%' THEN 1
		when source LIKE '%%lignite%%' THEN 2
		when source LIKE '%%mixed_fuels%%' THEN 3
		when source LIKE '%%oil%%' THEN 4
		when source LIKE '%%uranium%%' THEN 5
		when source LIKE '%%biomass%%' THEN 6
		when source LIKE '%%hard_coal%%' THEN 8
	END AS source
		FROM calc_renpass_gis.renpass_gis_linear_transformer A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where id <= 27
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON (substring(A.source, 1, 2) = B.cntr_id)
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.nominal_value IS not NULL
	AND A.nominal_value[1] > 0.001
	AND A.source not LIKE '%%powerline%%'
	AND A.scenario_id = 37;


-- NEP 2035

INSERT into model_draft.ego_grid_pf_hv_generator

	SELECT
	'NEP 2035' AS scn_name,
	row_number() over () + 200000 AS generator_id,
	B.bus_id AS bus,
	'flexible' AS dispatch,
	'PV' AS control,
	nominal_value[1] AS p_nom,
	FALSE AS p_nom_extendable,
	NULL AS p_nom_max,
	0 AS p_nom_min,
	0 AS p_min_pu_fixed,
	1 AS p_max_pu_fixed,
	1 AS sign,
	CASE
		WHEN source LIKE '%%gas%%' THEN 1
		when source LIKE '%%lignite%%' THEN 2
		when source LIKE '%%mixed_fuels%%' THEN 3
		when source LIKE '%%oil%%' THEN 4
		when source LIKE '%%uranium%%' THEN 5
		when source LIKE '%%biomass%%' THEN 6
		when source LIKE '%%hard_coal%%' THEN 8
	END AS source
		FROM calc_renpass_gis.renpass_gis_linear_transformer A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where id <= 27
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON (substring(A.source, 1, 2) = B.cntr_id)
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.nominal_value IS not NULL
	AND A.nominal_value[1] > 0.001
	AND A.source not LIKE '%%powerline%%'
	AND A.scenario_id = 38;

-- eGo 100

INSERT into model_draft.ego_grid_pf_hv_generator

	SELECT
	'eGo 100' AS scn_name,
	row_number() over () + 200000 AS generator_id,
	B.bus_id AS bus,
	'flexible' AS dispatch,
	'PV' AS control,
	nominal_value[1] AS p_nom,
	FALSE AS p_nom_extendable,
	NULL AS p_nom_max,
	0 AS p_nom_min,
	0 AS p_min_pu_fixed,
	1 AS p_max_pu_fixed,
	1 AS sign,
	CASE
		WHEN source LIKE '%%gas%%' THEN 1
		when source LIKE '%%lignite%%' THEN 2
		when source LIKE '%%mixed_fuels%%' THEN 3
		when source LIKE '%%oil%%' THEN 4
		when source LIKE '%%uranium%%' THEN 5
		when source LIKE '%%biomass%%' THEN 6
		when source LIKE '%%hard_coal%%' THEN 8
	END AS source
		FROM calc_renpass_gis.renpass_gis_linear_transformer A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where id <= 27
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON (substring(A.source, 1, 2) = B.cntr_id)
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.nominal_value IS not NULL
	AND A.nominal_value[1] > 0.001
	AND A.source not LIKE '%%powerline%%'
	AND A.scenario_id = 39;

	


-- INSERT params of Source in model_draft.ego_grid_pf_hv_generator (countries besides Germany)
-- Status Quo
INSERT into model_draft.ego_grid_pf_hv_generator

	SELECT
	'Status Quo' AS scn_name,
	row_number() over () + (SELECT max(generator_id) FROM model_draft.ego_grid_pf_hv_generator) AS generator_id,
	B.bus_id AS bus,
	'variable' AS dispatch,
	'PV' AS control,
	nominal_value[1] AS p_nom,
	FALSE AS p_nom_extendable,
	NULL AS p_nom_max,
	0 AS p_nom_min,
	0 AS p_min_pu_fixed,
	1 AS p_max_pu_fixed,
	1 AS sign,
	CASE
		WHEN source LIKE '%%run_of_river%%' THEN 9
		WHEN source LIKE '%%solar%%' THEN 12
		WHEN source LIKE '%%wind%%' THEN 13
        END AS source
		FROM calc_renpass_gis.renpass_gis_source A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where id <= 27
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON (substring(A.source, 1, 2) = B.cntr_id)
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.nominal_value[1] > 0.001
	AND A.scenario_id = 37;

-- NEP 2035

INSERT into model_draft.ego_grid_pf_hv_generator

	SELECT
	'NEP 2035' AS scn_name,
	row_number() over () + (SELECT max(generator_id) FROM model_draft.ego_grid_pf_hv_generator) AS generator_id,
	B.bus_id AS bus,
	'variable' AS dispatch,
	'PV' AS control,
	nominal_value[1] AS p_nom,
	FALSE AS p_nom_extendable,
	NULL AS p_nom_max,
	0 AS p_nom_min,
	0 AS p_min_pu_fixed,
	1 AS p_max_pu_fixed,
	1 AS sign,
	CASE
		WHEN source LIKE '%%run_of_river%%' THEN 9
		WHEN source LIKE '%%solar%%' THEN 12
		WHEN source LIKE '%%wind%%' THEN 13
        END AS source
		FROM calc_renpass_gis.renpass_gis_source A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM 
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where id <= 27
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON (substring(A.source, 1, 2) = B.cntr_id)
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.nominal_value[1] > 0.001
	AND A.scenario_id = 38;

-- eGo 100

INSERT into model_draft.ego_grid_pf_hv_generator

	SELECT
	'eGo 100' AS scn_name,
	row_number() over () + (SELECT max(generator_id) FROM model_draft.ego_grid_pf_hv_generator) AS generator_id,
	B.bus_id AS bus,
	'variable' AS dispatch,
	'PV' AS control,
	nominal_value[1] AS p_nom,
	FALSE AS p_nom_extendable,
	NULL AS p_nom_max,
	0 AS p_nom_min,
	0 AS p_min_pu_fixed,
	1 AS p_max_pu_fixed,
	1 AS sign,
	CASE
		WHEN source LIKE '%%run_of_river%%' THEN 9
		WHEN source LIKE '%%solar%%' THEN 12
		WHEN source LIKE '%%wind%%' THEN 13
        END AS source
		FROM calc_renpass_gis.renpass_gis_source A join
		(
		SELECT
		*
		FROM
			(SELECT *,
			max(v_nom) over (partition by cntr_id) AS max_v_nom
			FROM 
			model_draft.ego_grid_hv_electrical_neighbours_bus
			where id <= 27
			) SQ
		WHERE SQ.v_nom = SQ.max_v_nom
		) B
		ON (substring(A.source, 1, 2) = B.cntr_id)
	WHERE substring(A.source, 1, 2) <> 'DE'
	AND A.nominal_value[1] > 0.001
	AND A.scenario_id = 39;


-- Copy timeseries data
DELETE FROM model_draft.ego_grid_pf_hv_generator_pq_set WHERE generator_id > 200000 AND scn_name = 'Status Quo';
DELETE FROM model_draft.ego_grid_pf_hv_generator_pq_set WHERE generator_id > 200000 AND scn_name = 'NEP 2035';
DELETE FROM model_draft.ego_grid_pf_hv_generator_pq_set WHERE generator_id > 200000 AND scn_name = 'eGo 100';

-- CREATE a view containing data for generator_id's > 200000 for each timestep
-- SELECT * FROM calc_renpass_gis.translate_to_pf limit 1000;
-- Status Quo
DROP MATERIALIZED VIEW IF EXISTS calc_renpass_gis.translate_to_pf;

CREATE MATERIALIZED VIEW calc_renpass_gis.translate_to_pf AS
	SELECT
	SQ.generator_id,
	C.datetime,
	C.val
	FROM
		(SELECT *,
		CASE
			WHEN A.source =  1  THEN  'gas'
			WHEN A.source =  2  THEN  'lignite'
			WHEN A.source =  3  THEN  'mixed_fuels'
			WHEN A.source =  4  THEN  'oil'
			WHEN A.source =  5  THEN  'uranium'
			WHEN A.source =  6  THEN  'biomass'
			WHEN A.source =  8  THEN  'hard_coal'
			WHEN A.source =  9  THEN  'run_of_river'
			WHEN A.source =  12 THEN  'solar'
			WHEN A.source =  13 THEN  'wind'
		END AS renpass_gis_source
			FROM model_draft.ego_grid_pf_hv_generator A join
			model_draft.ego_grid_hv_electrical_neighbours_bus B
			ON (A.bus = B.bus_id)
		WHERE A.generator_id > 200000
		AND A.scn_name = 'Status Quo'
		) SQ,
		calc_renpass_gis.renpass_gis_results C
	WHERE
	(C.obj_label LIKE '%%' || SQ.cntr_id || '%%' || SQ.renpass_gis_source || '%%')
	AND C.scenario_id = 37
	AND C.type = 'to_bus';

-- create a view assigning a w_id to each foreign bus and the respective feedin
DROP MATERIALIZED VIEW IF EXISTS model_draft.ren_feedin_foreign;
CREATE MATERIALIZED VIEW model_draft.ren_feedin_foreign AS
SELECT
A.generator_id, B.feedin
FROM
	(SELECT
	feedin.w_id,
	CASE
		WHEN feedin.source LIKE '%%solar%%' THEN 12
		WHEN feedin.source LIKE '%%wind%%' THEN 13
	END AS source,
	feedin.feedin
	FROM 
	model_draft.ego_renewable_feedin AS feedin
	) AS B,
	(SELECT 
	generators.generator_id,
	generators.source,
	buses.w_id
	FROM
		(SELECT
		neighbours.bus_id AS bus_id,
		weather.gid AS w_id
		FROM model_draft.ego_grid_hv_electrical_neighbours_bus AS neighbours,
			coastdat.cosmoclmgrid AS weather
		WHERE ST_Intersects(weather.geom, neighbours.geom))
		AS buses,
	model_draft.ego_grid_pf_hv_generator AS generators
	WHERE generators.bus = buses.bus_id
	AND generators.source IN (12, 13)
	AND generators.generator_id > 200000
	AND generators.scn_name = 'Status Quo'
	) AS A
WHERE A.w_id = B.w_id
AND A.source = B.source;


-- Make an array, INSERT into generator_pq_set
INSERT into model_draft.ego_grid_pf_hv_generator_pq_set (scn_name, generator_id, temp_id, p_set)

	SELECT 'Status Quo' AS scn_name,
	SQ.generator_id,
	1 AS temp_id,
	array_agg(SQ.val ORDER BY SQ.datetime) AS p_set
		FROM
		(
		SELECT
		A.generator_id,
		A.datetime,
		A.val AS val
			FROM calc_renpass_gis.translate_to_pf A join
			model_draft.ego_grid_pf_hv_generator B
			USING (generator_id)
		) SQ
	GROUP BY generator_id;

-- set p_max_pu as timeseries from ego_renewable_feedin
UPDATE model_draft.ego_grid_pf_hv_generator_pq_set A
	SET p_max_pu = feedin.feedin
		FROM model_draft.ren_feedin_foreign AS feedin
		WHERE A.generator_id = feedin.generator_id;

-- NEP 2035

Drop MATERIALIZED VIEW IF EXISTS calc_renpass_gis.translate_to_pf;

CREATE MATERIALIZED VIEW calc_renpass_gis.translate_to_pf AS
	SELECT
	NEP.generator_id,
	C.datetime,
	C.val
	FROM
		(SELECT *,
		CASE
			WHEN A.source =  1  THEN  'gas'
			WHEN A.source =  2  THEN  'lignite'
			WHEN A.source =  3  THEN  'mixed_fuels'
			WHEN A.source =  4  THEN  'oil'
			WHEN A.source =  5  THEN  'uranium'
			WHEN A.source =  6  THEN  'biomass'
			WHEN A.source =  8  THEN  'hard_coal'
			WHEN A.source =  9  THEN  'run_of_river'
			WHEN A.source =  12 THEN  'solar'
			WHEN A.source =  13 THEN  'wind'
		END AS renpass_gis_source
			FROM model_draft.ego_grid_pf_hv_generator A join
			model_draft.ego_grid_hv_electrical_neighbours_bus B
			ON (A.bus = B.bus_id)
		WHERE A.generator_id > 200000
		AND A.scn_name = 'NEP 2035'
		) NEP,
		calc_renpass_gis.renpass_gis_results C
	WHERE
	(C.obj_label LIKE '%%' || NEP.cntr_id || '%%' || NEP.renpass_gis_source || '%%')
	AND C.scenario_id = 38
	AND C.type = 'to_bus';

-- create a view assigning a w_id to each foreign bus and the respective feedin
DROP MATERIALIZED VIEW IF EXISTS model_draft.ren_feedin_foreign;
CREATE MATERIALIZED VIEW model_draft.ren_feedin_foreign AS
SELECT
A.generator_id, B.feedin
FROM
	(SELECT
	feedin.w_id,
	CASE
		WHEN feedin.source LIKE '%%solar%%' THEN 12
		WHEN feedin.source LIKE '%%wind%%' THEN 13
	END AS source,
	feedin.feedin
	FROM 
	model_draft.ego_renewable_feedin AS feedin
	) AS B,
	(SELECT 
	generators.generator_id,
	generators.source,
	buses.w_id
	FROM
		(SELECT
		neighbours.bus_id AS bus_id,
		weather.gid AS w_id
		FROM model_draft.ego_grid_hv_electrical_neighbours_bus AS neighbours,
			coastdat.cosmoclmgrid AS weather
		WHERE ST_Intersects(weather.geom, neighbours.geom))
		AS buses,
	model_draft.ego_grid_pf_hv_generator AS generators
	WHERE generators.bus = buses.bus_id
	AND generators.source IN (12, 13)
	AND generators.generator_id > 200000
	AND generators.scn_name = 'NEP 2035'
	) AS A
WHERE A.w_id = B.w_id
AND A.source = B.source;

-- Make an array, INSERT into generator_pq_set
INSERT into model_draft.ego_grid_pf_hv_generator_pq_set (scn_name, generator_id, temp_id, p_set)

	SELECT 'NEP 2035' AS scn_name,
	NEP.generator_id,
	1 AS temp_id,
	array_agg(NEP.val ORDER BY NEP.datetime) AS p_set
		FROM
		(
		SELECT
		A.generator_id,
		A.datetime,
		A.val AS val
			FROM calc_renpass_gis.translate_to_pf A join
			model_draft.ego_grid_pf_hv_generator B
			USING (generator_id)
		) NEP
	GROUP BY generator_id;

UPDATE model_draft.ego_grid_pf_hv_generator_pq_set A
	SET p_max_pu = feedin.feedin
		FROM model_draft.ren_feedin_foreign AS feedin
		WHERE A.generator_id = feedin.generator_id;
	
-- eGo 100

Drop MATERIALIZED VIEW IF EXISTS calc_renpass_gis.translate_to_pf;

CREATE MATERIALIZED VIEW calc_renpass_gis.translate_to_pf AS
	SELECT
	EGO.generator_id,
	C.datetime,
	C.val
	FROM
		(SELECT *,
		CASE
			WHEN A.source =  1  THEN  'gas'
			WHEN A.source =  2  THEN  'lignite'
			WHEN A.source =  3  THEN  'mixed_fuels'
			WHEN A.source =  4  THEN  'oil'
			WHEN A.source =  5  THEN  'uranium'
			WHEN A.source =  6  THEN  'biomass'
			WHEN A.source =  8  THEN  'hard_coal'
			WHEN A.source =  9  THEN  'run_of_river'
			WHEN A.source =  12 THEN  'solar'
			WHEN A.source =  13 THEN  'wind'
		END AS renpass_gis_source
			FROM model_draft.ego_grid_pf_hv_generator A join
			model_draft.ego_grid_hv_electrical_neighbours_bus B
			ON (A.bus = B.bus_id)
		WHERE A.generator_id > 200000
		AND A.scn_name = 'eGo 100'
		) EGO,
		calc_renpass_gis.renpass_gis_results C
	WHERE
	(C.obj_label LIKE '%%' || EGO.cntr_id || '%%' || EGO.renpass_gis_source || '%%')
	AND C.scenario_id = 38
	AND C.type = 'to_bus';

-- create a view assigning a w_id to each foreign bus and the respective feedin
DROP MATERIALIZED VIEW IF EXISTS model_draft.ren_feedin_foreign;
CREATE MATERIALIZED VIEW model_draft.ren_feedin_foreign AS
SELECT
A.generator_id, B.feedin
FROM
	(SELECT
	feedin.w_id,
	CASE
		WHEN feedin.source LIKE '%%solar%%' THEN 12
		WHEN feedin.source LIKE '%%wind%%' THEN 13
	END AS source,
	feedin.feedin
	FROM 
	model_draft.ego_renewable_feedin AS feedin
	) AS B,
	(SELECT 
	generators.generator_id,
	generators.source,
	buses.w_id
	FROM
		(SELECT
		neighbours.bus_id AS bus_id,
		weather.gid AS w_id
		FROM model_draft.ego_grid_hv_electrical_neighbours_bus AS neighbours,
			coastdat.cosmoclmgrid AS weather
		WHERE ST_Intersects(weather.geom, neighbours.geom))
		AS buses,
	model_draft.ego_grid_pf_hv_generator AS generators
	WHERE generators.bus = buses.bus_id
	AND generators.source IN (12, 13)
	AND generators.generator_id > 200000
	AND generators.scn_name = 'eGo 100'
	) AS A
WHERE A.w_id = B.w_id
AND A.source = B.source;

-- Make an array, INSERT into generator_pq_set
INSERT into model_draft.ego_grid_pf_hv_generator_pq_set (scn_name, generator_id, temp_id, p_set)

	SELECT 'eGo 100' AS scn_name,
	EGO.generator_id,
	1 AS temp_id,
	array_agg(EGO.val ORDER BY EGO.datetime) AS p_set
		FROM
		(
		SELECT
		A.generator_id,
		A.datetime,
		A.val AS val
			FROM calc_renpass_gis.translate_to_pf A join
			model_draft.ego_grid_pf_hv_generator B
			USING (generator_id)
		) EGO
	GROUP BY generator_id;

-- set p_max_pu as timeseries from ego_renewable_feedin
UPDATE model_draft.ego_grid_pf_hv_generator_pq_set A
	SET p_max_pu = feedin.feedin
		FROM model_draft.ren_feedin_foreign AS feedin
		WHERE A.generator_id = feedin.generator_id;

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
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_pf_hv_generator_pq_set','ego_dp_powerflow_timeseries_generator.sql',' ');
