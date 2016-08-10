/* Query to determine feedin for solar & wind generators using normalized timeseries based on coastdat 
(open_eGo/data_processing/calc_renpass_gis/feedin)

Martin Söthe
...
*/


-- wind


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
				calc_renpass_gis.parameter_wind_feedin A,
				orig_geo_powerplants.proc_renewable_power_plants_germany B
			where generation_type = 'wind' 
			--limit 1000 -- limit!!!
			) as X

		where X.dist = X.mindist
		) as Y
	) as Z
Group by Z.un_id, Z.normfeedin
);


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