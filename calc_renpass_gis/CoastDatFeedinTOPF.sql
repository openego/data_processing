/* Query to determine feedin for solar & wind generators using normalized timeseries based on coastdat 
(open_eGo/data_processing/calc_renpass_gis/feedin)

__copyright__ = "ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

*/


-- wind

Insert into calc_ego_hv_powerflow.generator_pq_set (generator_id, temp_id, p_set)
	select
	PP.aggr_id as generator_id,
	1,
	array_agg(PP.sum_actual_feedin order by PP.rn) as p_set from
		(select
		LL.aggr_id,
		sum(LL.rn) as rn, -- foobar, but should be working, order on aggregated feedins
		sum(LL.actual_feedin) as sum_actual_feedin
		from
			(Select
			KK.*,
			row_number() over(partition by aggr_id, w_id) as aggr_rn -- row number for aggregating element-wise on same aggr_id, should be a function!
			from
				(
				Select
				MM.*,
				row_number() over () as rn -- row number for ordering
				from
					(
					select
					C.aggr_id,
					C.w_id,
					unnest(C.feedin) * C.p_nom as actual_feedin
					from
						(
						select
						A.aggr_id,
						A.w_id,
						A.p_nom,
						B.feedin
						from
							(
							select
							aggr_id,
							w_id,
							sum(p_nom) as p_nom
							from -- summed up per aggr_id and w_id
								orig_geo_powerplants.pf_generator_single
							where source = 13 and aggr_id is not Null and bus is not null
							group by aggr_id, w_id -- Limit 2
							) A,
							calc_renpass_gis.parameter_wind_feedin B
						where B.gid = A.w_id
						) C
					) MM
				) KK
			) LL group by LL.aggr_id, LL.aggr_rn
		) PP group by PP.aggr_id


-- solar
Insert into calc_ego_hv_powerflow.generator_pq_set (generator_id, temp_id, p_set)
	select
	PP.aggr_id as generator_id,
	1,
	array_agg(PP.sum_actual_feedin order by PP.rn) as p_set from
		(select
		LL.aggr_id,
		sum(LL.rn) as rn, -- foobar, but should be working, order on aggregated feedins
		sum(LL.actual_feedin) as sum_actual_feedin
		from
			(Select
			KK.*,
			row_number() over(partition by aggr_id, w_id) as aggr_rn -- row number for aggregating element-wise on same aggr_id, should be a function!
			from
				(
				Select
				MM.*,
				row_number() over () as rn -- row number for ordering
				from
					(
					select
					C.aggr_id,
					C.w_id,
					unnest(C.feedin) * C.p_nom as actual_feedin
					from
						(
						select
						A.aggr_id,
						A.w_id,
						A.p_nom,
						B.feedin
						from
							(
							select
							aggr_id,
							w_id,
							sum(p_nom) as p_nom
							from -- summed up per aggr_id and w_id
								orig_geo_powerplants.pf_generator_single
							where source = 12 and aggr_id is not Null and bus is not null
							group by aggr_id, w_id -- Limit 2
							) A,
							calc_renpass_gis.parameter_solar_feedin B
						where B.gid = A.w_id
						) C
					) MM
				) KK
			) LL group by LL.aggr_id, LL.aggr_rn
		) PP group by PP.aggr_id
