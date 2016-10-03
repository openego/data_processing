---------- ---------- ---------- ---------- ---------- ----------
-- "GD Analysis"   2016-08-25 10:42   12s
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	calc_ego_grid_district.grid_district_data CASCADE;
CREATE TABLE         	calc_ego_grid_district.grid_district_data AS
	SELECT	gd.subst_id ::integer,
		gd.area_ha ::numeric,
		gd.geom ::geometry(MultiPolygon,3035)
	FROM	calc_ego_grid_district.grid_district AS gd;
	
-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	grid_district_data_geom_idx
	ON	calc_ego_grid_district.grid_district_data
	USING	GIST (geom);

-- "Extend Table"   (OK!) 100ms =0
ALTER TABLE	calc_ego_grid_district.grid_district_data
	ADD PRIMARY KEY (subst_id),
	ADD COLUMN zensus_sum integer,
	ADD COLUMN zensus_count integer,
	ADD COLUMN zensus_density numeric,
	ADD COLUMN population_density numeric;

-- "Zensus2011 Population"   (OK!) -> 62.000ms =3.610
UPDATE 	calc_ego_grid_district.grid_district_data AS t1
SET  	area_ha = t2.area_ha,
	zensus_sum = t2.zensus_sum,
	zensus_count = t2.zensus_count,
	zensus_density = t2.zensus_density,
	population_density = t2.population_density
FROM    (SELECT	gd.subst_id AS subst_id,
		ST_AREA(gd.geom)/10000 ::numeric AS area_ha,
		SUM(pts.population)::integer AS zensus_sum,
		COUNT(pts.geom)::integer AS zensus_count,
		(SUM(pts.population)/COUNT(pts.geom))::numeric AS zensus_density,
		(SUM(pts.population)/gd.area_ha)::numeric AS population_density
	FROM	calc_ego_grid_district.grid_district_data AS gd,
		orig_destatis.zensus_population_per_ha_mview AS pts
	WHERE  	gd.geom && pts.geom AND
		ST_CONTAINS(gd.geom,pts.geom)
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;


-- "Extend Table"   (OK!) 100ms =0
ALTER TABLE	calc_ego_grid_district.grid_district_data
	ADD COLUMN la_count integer,
	ADD COLUMN la_area numeric,
	ADD COLUMN consumption_sum numeric;

-- "LA data"   (OK!) -> 411.000ms =173.278
UPDATE 	calc_ego_grid_district.grid_district_data AS t1
SET  	la_count = t2.la_count,
	la_area = t2.la_area,
	consumption_sum = t2.consumption_sum
FROM    (SELECT	gd.subst_id AS subst_id,
		COUNT(la.geom_centre) ::integer AS la_count,
		SUM(la.area_ha) ::numeric AS la_area,
		SUM(la.sector_consumption_sum) ::numeric AS consumption_sum
	FROM	calc_ego_grid_district.grid_district_data AS gd,
		calc_ego_loads.ego_deu_load_area AS la
	WHERE  	gd.geom && la.geom_centre AND
		ST_CONTAINS(gd.geom,la.geom_centre)
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;


-- "Extend Table"   (OK!) 100ms =0
ALTER TABLE	calc_ego_grid_district.grid_district_data
	ADD COLUMN dea_count integer,
	ADD COLUMN dea_cap_sum integer;

-- "DEA data"   (OK!) -> 411.000ms =173.278
UPDATE 	calc_ego_grid_district.grid_district_data AS t1
SET  	dea_count = t2.dea_count,
	dea_cap_sum = t2.dea_cap_sum
FROM    (SELECT	gd.subst_id AS subst_id,
		COUNT(dea.geom) ::integer AS dea_count,
		SUM(dea.electrical_capacity) ::numeric AS dea_cap_sum
	FROM	calc_ego_grid_district.grid_district_data AS gd,
		calc_ego_re.ego_deu_dea AS dea
	WHERE  	gd.geom && dea.geom AND
		ST_CONTAINS(gd.geom,dea.geom)
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;
