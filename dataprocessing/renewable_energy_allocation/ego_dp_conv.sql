
-- la_id
ALTER TABLE model_draft.ego_supply_conv_powerplant
	DROP COLUMN IF EXISTS	la_id CASCADE,
  	ADD COLUMN 		la_id integer;


-- update la_id from loadarea
UPDATE 	model_draft.ego_supply_conv_powerplant AS t1
	SET  	la_id = t2.la_id
	FROM    (
		SELECT	a.gid AS id,
			b.id AS la_id
		FROM	model_draft.ego_supply_conv_powerplant AS a,
			model_draft.ego_demand_loadarea AS b
		WHERE  	b.geom && ST_TRANSFORM(a.geom,3035) AND
			ST_CONTAINS(b.geom,ST_TRANSFORM(a.geom,3035))
		) AS t2
	WHERE  	t1.gid = t2.id;