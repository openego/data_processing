SELECT Distinct 
	A.generation_type,
	A.sum_sq,
	A.num_sq,
	B.generation_type,
	B.sum_2035,
	B.num_2035,
	C.generation_type,
	C.sum_2050,
	C.num_2050
FROM
(
	SELECT
		generation_type,
		round(sum(electrical_capacity)/1000000,2) as sum_sq, -- in GW
		count(*) as num_sq
	FROM
		model_draft.ego_supply_rea
	Group by generation_type
	Order by generation_type
) as A,
(
	SELECT
		generation_type ,
		round(sum(electrical_capacity)/1000000,2) as sum_2035, -- in GW
		count(*) as num_2035
	FROM
		model_draft.ego_supply_rea_2035
	Group by generation_type
	Order by generation_type
) as B ,
(
	SELECT
		generation_type ,
		round(sum(electrical_capacity)/1000000,2) as sum_2050, -- in GW
		count(*) as num_2050
	FROM
		model_draft.ego_supply_rea_2050
	Group by generation_type
	Order by generation_type
) as C
Where  A.generation_type = B.generation_type
And    C.generation_type = A.generation_type
Group by A.generation_type, B.generation_type, C.generation_type, A.sum_sq, A.num_sq, B.sum_2035, B.num_2035,C.sum_2050,C.num_2050
Order by A.generation_type
;