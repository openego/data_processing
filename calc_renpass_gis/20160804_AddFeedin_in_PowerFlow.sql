/* Query to determine feedin for solar & wind generators using normalized timeseries based on coastdat 
(open_eGo/data_processing/calc_renpass_gis/feedin)

Martin Söthe
...
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
Insert into calc_ego_hv_powerflow.generator_pq_set (generator_id, p_set, p_max_pu)
(
select Z.un_id as generator_id,
array_agg(Z.feedin order by Z.rn) as p_set,
-- over (order by Z.rn) as p_set
Z.normfeedin as p_max_pu
from
	(
	Select *, row_number() over () as rn -- for keeping array order while grouping, there must be a better way!
	from
		(
		select X.un_id, unnest(X.feedin) * X.electrical_capacity/1000 as feedin, X.feedin as normfeedin -- MW
		from
			(
			select
			B.un_id,
			A.feedin,
			B.electrical_capacity,
			A.geom <-> B.geom as dist,
			min(A.geom <-> B.geom) over (partition by B.un_id) as mindist from
				calc_renpass_gis.parameter_solar_feedin A,
				orig_geo_powerplants.proc_renewable_power_plants_germany B
			where generation_type = 'solar'
			limit 1000 -- limit!!!
			) as X

		where X.dist = X.mindist
		) as Y
	) as Z
Group by Z.un_id, Z.normfeedin
);
