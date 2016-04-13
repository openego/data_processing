
---------- ---------- ---------- ---------- ---------- ----------
-- "Setup"
---------- ---------- ---------- ---------- ---------- ----------

-- "Gemeinde table"   (OK!) -> 500ms =11.438
DROP TABLE IF EXISTS	orig_geo_vg250.vg250_6_gem_usw CASCADE;
CREATE TABLE		orig_geo_vg250.vg250_6_gem_usw AS
	SELECT	vg.*
	FROM	orig_geo_vg250.vg250_6_gem_mview AS vg;
	
-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	vg250_6_gem_usw_geom_idx
	ON	orig_geo_vg250.vg250_6_gem_usw
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_vg250.vg250_6_gem_usw TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_vg250.vg250_6_gem_usw OWNER TO oeuser;

-- "Set PK"   (OK!) -> 1.000ms =0
ALTER TABLE orig_geo_vg250.vg250_6_gem_usw
	ADD COLUMN usw_sum integer,
	ADD PRIMARY KEY (gid);

-- "usw count"   (OK!) -> 175.000ms =2.266
UPDATE 	orig_geo_vg250.vg250_6_gem_usw AS t1
SET  	usw_sum = t2.usw_sum
FROM	(SELECT	gem.gid AS gid,
		COUNT(usw.geom)::integer AS usw_sum
	FROM	orig_geo_vg250.vg250_6_gem_usw AS gem,
		calc_gridcells_znes.znes_deu_substations_filtered AS usw
	WHERE  	ST_CONTAINS(gem.geom,ST_TRANSFORM(usw.geom,3035))
	GROUP BY gem.gid
	)AS t2
WHERE  	t1.gid = t2.gid;

---------- ---------- ---------- ---------- ---------- ----------
-- "I. Gemeinden mit genau einem USW"
---------- ---------- ---------- ---------- ---------- ----------

-- "MView"   (OK!) -> 300ms =1.680
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.vg250_6_gem_usw_1_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.vg250_6_gem_usw_1_mview AS 
	SELECT	usw.*
	FROM	orig_geo_vg250.vg250_6_gem_usw AS usw
	WHERE	usw_sum = '1';

-- "Table USW"   (OK!) -> 100ms =3.716
DROP TABLE IF EXISTS	orig_geo_ego.ego_ms_netzbezirke CASCADE;
CREATE TABLE		orig_geo_ego.ego_ms_netzbezirke AS
	SELECT	usw.subst_id AS id,
		ST_TRANSFORM(usw.geom,3035) AS geom
	FROM	calc_gridcells_znes.znes_deu_substations_filtered AS usw;

-- "Set PK"   (OK!) -> 100ms =0
ALTER TABLE orig_geo_ego.ego_ms_netzbezirke
	ADD COLUMN geom_gem geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (id);
	
-- "usw geom"   (OK!) -> 4.000ms =3.716
UPDATE 	orig_geo_ego.ego_ms_netzbezirke AS t1
SET  	geom_gem = t2.geom_gem
FROM	(SELECT	nb.id AS id,
		gem.geom AS geom_gem
	FROM	orig_geo_vg250.vg250_6_gem_usw AS gem,
		orig_geo_ego.ego_ms_netzbezirke AS nb
	WHERE  	gem.usw_sum = '1'
	)AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ---------- ---------- ---------- ----------
-- "II. Gemeinden mit mehreren USW"
---------- ---------- ---------- ---------- ---------- ----------

-- "MView"   (OK!) -> 100ms =586
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.vg250_6_gem_usw_2_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.vg250_6_gem_usw_2_mview AS 
	SELECT	usw.*
	FROM	orig_geo_vg250.vg250_6_gem_usw AS usw
	WHERE	usw_sum > '1';

DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.vg250_6_gem_usw_2_pts_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.vg250_6_gem_usw_2_pts_mview AS 
	SELECT	'1' ::integer AS id,
		ST_SetSRID(ST_Union(usw.geom), 0) AS geom
	FROM	calc_gridcells_znes.znes_deu_substations_filtered AS usw
	WHERE	subst_id = '3791' OR subst_id = '3765';



-- (POSTGIS 2.3!!!)
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.vg250_6_gem_usw_2_voronoi_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.vg250_6_gem_usw_2_voronoi_mview AS 
	SELECT	gem2.gid AS id,
		ST_Voronoi(usw.geom,gem2.geom,30,true) AS geom
	FROM	orig_geo_ego.vg250_6_gem_usw_2_pts_mview AS usw,
		orig_geo_ego.vg250_6_gem_usw_2_mview AS gem2
	WHERE	gem2.gid = '4884'


---------- ---------- ---------- ---------- ---------- ----------
-- "III. Gemeinden ohne USW"
---------- ---------- ---------- ---------- ---------- ----------

-- "MView"   (OK!) -> 22.000ms =9.172
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.vg250_6_gem_usw_3_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_ego.vg250_6_gem_usw_3_mview AS 
	SELECT	usw.*
	FROM	orig_geo_vg250.vg250_6_gem_usw AS usw
	WHERE	usw_sum IS NULL;
