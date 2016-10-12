
ALTER TABLE calc_ego_substation.ego_deu_onts
	ADD COLUMN subst_id integer;


UPDATE 	calc_ego_substation.ego_deu_onts AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	ont.id AS id,
		gd.subst_id AS subst_id
	FROM	calc_ego_substation.ego_deu_onts AS ont,
		calc_ego_grid_district.grid_district AS gd
	WHERE  	gd.geom && ont.geom AND
		ST_CONTAINS(gd.geom,ont.geom)
	) AS t2
WHERE  	t1.id = t2.id;

