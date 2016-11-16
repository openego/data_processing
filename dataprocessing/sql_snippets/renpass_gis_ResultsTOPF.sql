/*
Quick workaround to transfer renpassG!S results into the corresponding powerflow table.

Author: Martin

TODO: storage in storage_pqset #1069
*/

-- DROP materialized view calc_renpass_gis.pf_pp_by_source_aggr_id
-- aggregate nominal capacity on aggr_id from powerflow generators, keeping the source
drop materialized view if exists calc_renpass_gis.pf_pp_by_source_aggr_id;
create materialized view calc_renpass_gis.pf_pp_by_source_aggr_id
as 
select 
SQ.aggr_id, SQ.source, SQ.p_nom / sum(SQ.p_nom) over (partition by SQ.source) as fraction_of_installed
from
(select aggr_id, source, sum(p_nom) as p_nom from model_draft.ego_supply_pf_generator_single group by aggr_id, source) SQ;

 
-- DROP materialized view calc_renpass_gis.pp_feedin_by_pf_source
-- map renpassG!S power sources to pf generators, aggr on fuel types, neglect efficiency classes
drop materialized view if exists calc_renpass_gis.pp_feedin_by_pf_source;
create materialized view calc_renpass_gis.pp_feedin_by_pf_source
as
select 
SQ.source, SQ.datetime, sum(SQ.val) as val
from
	(select 
	case 
	when obj_label like '%%gas%%' Then 1
	when obj_label like '%%lignite%%' Then 2
	when obj_label like '%%mixed_fuels%%' Then 3
	when obj_label like '%%oil%%' Then 4
	when obj_label like '%%uranium%%' Then 5
	when obj_label like '%%biomass%%' Then 6
	when obj_label like '%%hard_coal%%' Then 8
	when obj_label like '%%run_of_river%%' Then 9
--	when obj_label like '%%storage_phs%%' Then 11
	when obj_label like '%%solar%%' Then 12
	when obj_label like '%%wind%%' Then 13
	end as source,
	bus_label,
	obj_label,
	type,
	datetime,
	val
		from calc_renpass_gis.renpass_gis_results
	-- conds
	where obj_label like '%%DE%%' -- only Germany
	and obj_label not like '%%powerline%%' -- without any powerlines
	and scenario_id = 2 
	 -- take only one flow (input), storage output flow seems to be the right one (?)
	and ((obj_label like '%%storage%%' and type = 'output') or (obj_label not like '%%storage%%' and type = 'input'))
) as SQ
where SQ.source is not null
group by SQ.source, SQ.datetime;

--
DELETE FROM model_draft.ego_grid_pf_hv_generator_pq_set;
DELETE FROM model_draft.ego_grid_pf_hv_temp_resolution;

INSERT INTO model_draft.ego_grid_pf_hv_temp_resolution (temp_id, timesteps, resolution, start_time)
SELECT 1, 8760, 'h', TIMESTAMP '2011-01-01 00:00:00';

-- construct array per aggr_id according to source timeseries
Insert into model_draft.ego_grid_pf_hv_generator_pq_set (scn_name, generator_id, temp_id, p_set)
select 'Status Quo' as scn_name, A.aggr_id, 1 as temp_id, array_agg(A.fraction_of_installed * B.val order by B.datetime) as p_set from calc_renpass_gis.pf_pp_by_source_aggr_id A,
calc_renpass_gis.pp_feedin_by_pf_source B where A.source = B.source
group by A.aggr_id;


-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_grid_pf_hv_generator_pq_set' AS table_name,
		'renpass_gis_ResultsTOPF.sql' AS script_name,
		COUNT(generator_id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_pf_hv_generator_pq_set;

