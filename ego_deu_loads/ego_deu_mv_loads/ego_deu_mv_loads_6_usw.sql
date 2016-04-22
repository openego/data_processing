
---------- ---------- ---------- ---------- ---------- ----------
-- "Loads USW"
---------- ---------- ---------- ---------- ---------- ----------


---------- ---------- ----------
-- USW
---------- ---------- ----------

-- "Substations"   (OK!) 100ms =3.716
DROP TABLE IF EXISTS	orig_ego.ego_deu_mv_substations CASCADE;
CREATE TABLE		orig_ego.ego_deu_mv_substations AS
	SELECT	pts.subst_id ::integer AS subst_id,
		pts.name ::text AS subst_name,
		pts.voltage ::text AS subst_voltage,
		pts.power_typ ::text AS power_typ,
		pts.substation ::text AS substation,
		pts.operator ::text AS subst_operator,
		pts.status ::text AS subst_status,
		ST_TRANSFORM(pts.geom,3035) ::geometry(Point,3035) AS geom
	FROM	calc_gridcells_znes.znes_deu_substations_filtered AS pts
	WHERE	ST_CONTAINS(gem.geom,ST_TRANSFORM(pts.geom,3035));

-- "Create Index (subst_id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_mv_substations_gid_idx
		ON	orig_ego.ego_deu_mv_substations (subst_id);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_mv_substations_geom_idx
	ON	orig_ego.ego_deu_mv_substations
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_mv_substations TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_mv_substations OWNER TO oeuser;



---------- ---------- ----------
-- GEM_dump_usw
---------- ---------- ----------

-- "Gemeinde table"   (OK!) -> 500ms =12.528
DROP TABLE IF EXISTS	orig_ego.vg250_6_gem_dump_usw CASCADE;
CREATE TABLE		orig_ego.vg250_6_gem_dump_usw AS
	SELECT	vg.*
	FROM	orig_geo_vg250.vg250_6_gem_dump_mview AS vg;
	
-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	vg250_6_gem_dump_usw_geom_idx
	ON	orig_ego.vg250_6_gem_dump_usw
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.vg250_6_gem_dump_usw TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.vg250_6_gem_dump_usw OWNER TO oeuser;

-- "Set PK"   (OK!) -> 1.000ms =0
ALTER TABLE orig_ego.vg250_6_gem_dump_usw
	ADD COLUMN usw_sum integer,
	ADD COLUMN usw_cat integer,
	ADD PRIMARY KEY (id);

-- "usw count"   (OK!) -> 1.000ms =2.267
UPDATE 	orig_ego.vg250_6_gem_dump_usw AS t1
SET  	usw_sum = t2.usw_sum
FROM	(SELECT	gem.id AS id,
		COUNT(usw.geom)::integer AS usw_sum
	FROM	orig_ego.vg250_6_gem_dump_usw AS gem,
		orig_ego.ego_deu_mv_substations_mview AS usw
	WHERE  	ST_CONTAINS(gem.geom,ST_TRANSFORM(usw.geom,3035))
	GROUP BY gem.id
	)AS t2
WHERE  	t1.id = t2.id;



---------- ---------- ----------
-- "MViews"
---------- ---------- ----------

-- "MView I."   (OK!) -> 300ms =1.682
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.vg250_6_gem_dump_usw_1_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.vg250_6_gem_dump_usw_1_mview AS 
	SELECT	usw.*
	FROM	orig_ego.vg250_6_gem_dump_usw AS usw
	WHERE	usw_sum = '1';

-- "Create Index (id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	vg250_6_gem_dump_usw_1_mview_gid_idx
		ON	orig_ego.vg250_6_gem_dump_usw_1_mview (id);

-- "usw category"   (OK!) -> 1.000ms =1682
UPDATE 	orig_ego.vg250_6_gem_dump_usw AS t1
SET  	usw_cat = t2.usw_cat
FROM	(SELECT	gem.id AS id,
		'1'::integer AS usw_cat
	FROM	orig_ego.vg250_6_gem_dump_usw_1_mview AS gem )AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "MView II."   (OK!) -> 100ms =585
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.vg250_6_gem_dump_usw_2_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.vg250_6_gem_dump_usw_2_mview AS 
	SELECT	usw.*
	FROM	orig_ego.vg250_6_gem_dump_usw AS usw
	WHERE	usw_sum > '1';

-- "Create Index (id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	vg250_6_gem_dump_usw_2_mview_gid_idx
		ON	orig_ego.vg250_6_gem_dump_usw_2_mview (id);

-- "usw category"   (OK!) -> 1.000ms =585
UPDATE 	orig_ego.vg250_6_gem_dump_usw AS t1
SET  	usw_cat = t2.usw_cat
FROM	(SELECT	gem.id AS id,
		'2'::integer AS usw_cat
	FROM	orig_ego.vg250_6_gem_dump_usw_2_mview AS gem )AS t2
WHERE  	t1.id = t2.id;

----------

-- "usw in gem II."   (OK!) -> 200ms =2027
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_mv_substations_2_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_mv_substations_2_mview AS
	SELECT	usw.subst_id ::integer AS subst_id,
		usw.subst_name ::text AS subst_name,
		usw.subst_voltage ::text AS subst_voltage,
		usw.power_typ ::text AS power_typ,
		usw.substation ::text AS substation,
		usw.subst_operator ::text AS subst_operator,
		usw.subst_status ::text AS subst_status,
		usw.geom ::geometry(Point,3035) AS geom
	FROM	orig_ego.ego_deu_mv_substations_mview AS usw,
		orig_ego.vg250_6_gem_dump_usw_2_mview AS gem
	WHERE  	ST_CONTAINS(gem.geom,usw.geom);

---------- ---------- ----------

-- "MView III."   (OK!) -> 22.000ms =10.261
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.vg250_6_gem_dump_usw_3_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.vg250_6_gem_dump_usw_3_mview AS 
	SELECT	usw.*
	FROM	orig_ego.vg250_6_gem_dump_usw AS usw
	WHERE	usw_sum IS NULL;

-- "Create Index (id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	vg250_6_gem_dump_usw_3_mview_gid_idx
		ON	orig_ego.vg250_6_gem_dump_usw_3_mview (id);

-- "usw category"   (OK!) -> 1.000ms =10.261
UPDATE 	orig_ego.vg250_6_gem_dump_usw AS t1
SET  	usw_cat = t2.usw_cat
FROM	(SELECT	gem.id AS id,
		'3'::integer AS usw_cat
	FROM	orig_ego.vg250_6_gem_dump_usw_3_mview AS gem
	)AS t2
WHERE  	t1.id = t2.id;



---------- ---------- ----------
-- "Grid Districs"
---------- ---------- ----------

-- "Table Netzbezirke"   (OK!) -> 100ms =3.716
DROP TABLE IF EXISTS	orig_ego.ego_grid_districs CASCADE;
CREATE TABLE		orig_ego.ego_grid_districs AS
	SELECT	usw.subst_id AS sub_id,
		ST_TRANSFORM(usw.geom,3035) ::geometry(Point,3035) AS geom_subst
	FROM	orig_ego.ego_deu_mv_substations_mview AS usw;

-- "Set PK"   (OK!) -> 100ms =0
ALTER TABLE orig_ego.ego_grid_districs
	ADD COLUMN usw_sum integer,
	ADD COLUMN usw_cat integer,
	ADD COLUMN geom_gem geometry(Polygon,3035),
	ADD PRIMARY KEY (sub_id);

-- "Create Index GIST (geom_subst)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districs_geom_subst_idx
	ON	orig_ego.ego_grid_districs
	USING	GIST (geom_subst);



---------- ---------- ----------
-- "I. Gemeinden mit genau einem USW"
---------- ---------- ----------
-- sub_id = gem.id
-- "update usw geom gem1"   (OK!) -> 1.000ms =292
UPDATE 	orig_ego.ego_grid_districs AS t1
SET  	usw_sum  = t2.usw_sum,
	usw_cat = t2.usw_cat,
	geom_gem = t2.geom_gem
FROM	(SELECT	gem.id AS id,
		gem.usw_sum ::integer AS usw_sum,
		gem.usw_cat ::integer AS usw_cat,
		gem.geom ::geometry(Polygon,3035) AS geom_gem
	FROM	orig_ego.vg250_6_gem_dump_usw_1_mview AS gem )AS t2
WHERE  	t1.sub_id = t2.id;



---------- ---------- ----------
-- "II. Gemeinden mit mehreren USW"
---------- ---------- ----------

-- "Voronoi Gridcells (voi)"   (OK!) 100ms =3.711
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_usw_voi_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_usw_voi_mview AS
	SELECT	poly.id ::integer AS id,
		poly.subst_id ::integer AS subst_id,
		(ST_DUMP(ST_TRANSFORM(poly.geom,3035))).geom ::geometry(Polygon,3035) AS geom
	FROM	calc_gridcells_znes.znes_deu_gridcells_qgis AS poly;

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_usw_voi_mview_geom_idx
	ON	orig_ego.ego_deu_usw_voi_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_usw_voi_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_usw_voi_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Validate (geom)"   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	orig_ego.ego_deu_usw_voi_mview_error_geom_view CASCADE;
CREATE VIEW		orig_ego.ego_deu_usw_voi_mview_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_ego.ego_deu_usw_voi_mview AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_usw_voi_mview_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_usw_voi_mview_error_geom_view OWNER TO oeuser;

-- "Drop empty view"   (OK!) -> 100ms =1
SELECT f_drop_view('{ego_deu_usw_voi_mview_error_geom_view}', 'orig_ego');

-- Problem: leere voi-Teile

---------- ---------- ----------
-- "CUT"
---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.ego_deu_usw_voi_cut_id CASCADE;
CREATE SEQUENCE 		orig_ego.ego_deu_usw_voi_cut_id;

-- "Cutting GEM II."   (OK!) 3.000ms =4.981
DROP TABLE IF EXISTS	orig_ego.ego_deu_usw_voi_cut CASCADE;
CREATE TABLE		orig_ego.ego_deu_usw_voi_cut AS
	SELECT	nextval('orig_ego.ego_deu_usw_voi_cut_id') AS id,
		gem.id AS gid,
		voi.id AS vid,
		gem.ags_0 AS ags_0,
		gem.usw_cat AS usw_cat,
		(ST_DUMP(ST_INTERSECTION(gem.geom,voi.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.vg250_6_gem_dump_usw_2_mview AS gem,
		orig_ego.ego_deu_usw_voi_mview AS voi
	WHERE	gem.geom && voi.geom;

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	orig_ego.ego_deu_usw_voi_cut
	ADD COLUMN voi_usw_sum integer,
	ADD PRIMARY KEY (id);

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_usw_voi_cut_geom_idx
	ON	orig_ego.ego_deu_usw_voi_cut
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_usw_voi_cut TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_usw_voi_cut OWNER TO oeuser;

-- "usw count"   (OK!) -> 1.000ms =2.021
UPDATE 	orig_ego.ego_deu_usw_voi_cut AS t1
SET  	voi_usw_sum = t2.voi_usw_sum
FROM	(SELECT	gem.id AS id,
		COUNT(usw.geom)::integer AS voi_usw_sum
	FROM	orig_ego.ego_deu_usw_voi_cut AS gem,
		orig_ego.ego_deu_mv_substations_mview AS usw
	WHERE  	ST_CONTAINS(gem.geom,ST_TRANSFORM(usw.geom,3035))
	GROUP BY gem.id
	)AS t2
WHERE  	t1.id = t2.id;

-- -- "Calculate Gemeindeschlüssel"   (OK!) -> 3.000ms =4.981
-- UPDATE 	orig_ego.ego_deu_usw_voi_cut AS t1
-- SET  	ags_0 = t2.ags_0
-- FROM    (
-- 	SELECT	cut.id AS id,
-- 		vg.ags_0 AS ags_0
-- 	FROM	orig_ego.ego_deu_usw_voi_cut AS cut,
-- 		orig_geo_vg250.vg250_6_gem_mview AS vg
-- 	WHERE  	vg.geom && ST_POINTONSURFACE(cut.geom) AND
-- 		ST_CONTAINS(vg.geom,ST_POINTONSURFACE(cut.geom))
-- 	) AS t2
-- WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- sub_id = id
-- "update usw geom gem2"   (OK!) -> 1.000ms =1.741
UPDATE 	orig_ego.ego_grid_districs AS t1
SET  	usw_sum  = t2.usw_sum,
	usw_cat = t2.usw_cat,
	geom_gem = t2.geom_gem
FROM	(SELECT	gem.id AS id,
		gem.gid AS gid,
		gem.vid AS vid,
		gem.ags_0 AS ags_0,
		gem.usw_cat AS usw_cat,
		gem.voi_usw_sum ::integer AS usw_sum,
		gem.geom ::geometry(Polygon,3035) AS geom_gem
	FROM	orig_ego.ego_deu_usw_voi_cut AS gem )AS t2
WHERE  	t1.sub_id = t2.id;

---------- ---------- ----------

-- DROP MATERIALIZED VIEW IF EXISTS	orig_ego.vg250_6_gem_usw_2_pts_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_ego.vg250_6_gem_usw_2_pts_mview AS 
-- 	SELECT	'1' ::integer AS id,
-- 		ST_SetSRID(ST_Union(usw.geom), 0) AS geom
-- 	FROM	calc_gridcells_znes.znes_deu_substations_filtered AS usw
-- 	WHERE	subst_id = '3791' OR subst_id = '3765';

-- -- (POSTGIS 2.3!!!)
-- DROP MATERIALIZED VIEW IF EXISTS	orig_ego.vg250_6_gem_usw_2_voronoi_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_ego.vg250_6_gem_usw_2_voronoi_mview AS 
-- 	SELECT	gem2.gid AS id,
-- 		ST_Voronoi(usw.geom,gem2.geom,30,true) AS geom
-- 	FROM	orig_ego.vg250_6_gem_usw_2_pts_mview AS usw,
-- 		orig_ego.vg250_6_gem_usw_2_mview AS gem2
-- 	WHERE	gem2.gid = '4884'



---------- ---------- ----------
-- "III. Gemeinden ohne USW"
---------- ---------- ----------

-- gem WHERE usw_sum=0		orig_geo_ego.vg250_6_gem_usw_3_mview
-- usw				orig_geo_ego.ego_deu_mv_substations_mview

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.vg250_6_gem_dump_usw_3_nn_id CASCADE;
CREATE SEQUENCE 		orig_ego.vg250_6_gem_dump_usw_3_nn_id;

-- "Next Neighbor"   (OK!) 53.000ms =9.318
DROP TABLE IF EXISTS	orig_ego.vg250_6_gem_dump_usw_3_nn CASCADE;
CREATE TABLE 		orig_ego.vg250_6_gem_dump_usw_3_nn AS 
SELECT DISTINCT ON (gem.gid)
	nextval('orig_ego.vg250_6_gem_dump_usw_3_nn_id') AS id,
	gem.gid As gem_gid,
	gem.ags_0 As gem_ags_0,
	gem.geom ::geometry(Polygon,3035) AS gem_geom,
	sub.subst_id As sub_id, 
        sub.subst_name As sub_subst_name,
	sub.geom ::geometry(Point,3035) AS sub_geom,
	gem.ags_0 AS ags_0,
	gem.usw_cat AS usw_cat,
	gem.usw_sum ::integer AS usw_sum
FROM 	orig_ego.vg250_6_gem_dump_usw_3_mview As gem, 
	orig_ego.ego_deu_mv_substations_mview As sub   
WHERE 	gem.gid <> sub.subst_id
	AND ST_DWithin(gem.geom, sub.geom, 100000)
ORDER BY 	gem.gid, 
		ST_Distance(gem.geom,sub.geom);

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	orig_ego.vg250_6_gem_dump_usw_3_nn
	ADD PRIMARY KEY (id);

-- "Create Index GIST (gem_geom)"   (OK!) 2.500ms =0
DROP INDEX IF EXISTS 	vg250_6_gem_dump_usw_3_nn_gem_geom_idx;
CREATE INDEX		vg250_6_gem_dump_usw_3_nn_gem_geom_idx
	ON	orig_ego.vg250_6_gem_dump_usw_3_nn
	USING	GIST (gem_geom);

-- "Create Index GIST (sub_geom)"   (OK!) 2.500ms =0
DROP INDEX IF EXISTS 	vg250_6_gem_dump_usw_3_nn_sub_geom_idx;
CREATE INDEX		vg250_6_gem_dump_usw_3_nn_sub_geom_idx
	ON	orig_ego.vg250_6_gem_dump_usw_3_nn
	USING	GIST (sub_geom);

---------- ---------- ----------
-- NN Line
---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.vg250_6_gem_dump_usw_3_nn_line_id CASCADE;
CREATE SEQUENCE 		orig_ego.vg250_6_gem_dump_usw_3_nn_line_id;

-- "connect points"   (OK!) 1.000ms =9.318
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.vg250_6_gem_dump_usw_3_nn_line;
CREATE MATERIALIZED VIEW 		orig_ego.vg250_6_gem_dump_usw_3_nn_line AS 
	SELECT 	nextval('orig_ego.vg250_6_gem_dump_usw_3_nn_line_id') AS id,
		nn.gem_gid,
		nn.sub_id,
		(ST_Dump(ST_Centroid(nn.gem_geom))).geom ::geometry(Point,3035) AS geom_centre,
		ST_ShortestLine(	(ST_Dump(ST_Centroid(nn.gem_geom))).geom ::geometry(Point,3035),
					nn.sub_geom ::geometry(Point,3035)
		) ::geometry(LineString,3035) AS geom
	FROM	orig_ego.vg250_6_gem_dump_usw_3_nn AS nn;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_6_gem_dump_usw_3_nn_line_id_idx
		ON	orig_ego.vg250_6_gem_dump_usw_3_nn_line (id);

-- "Create Index GIST (geom_centre)"   (OK!) 2.500ms =0
CREATE INDEX	vg250_6_gem_dump_usw_3_nn_line_geom_centre_idx
	ON	orig_ego.vg250_6_gem_dump_usw_3_nn_line
	USING	GIST (geom_centre);

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	vg250_6_gem_dump_usw_3_nn_line_geom_idx
	ON	orig_ego.vg250_6_gem_dump_usw_3_nn_line
	USING	GIST (geom);

---------- ---------- ----------

-- UNION

-- "union gem"   (OK!) 5.000ms =2.111
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.vg250_6_gem_dump_usw_3_nn_union CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.vg250_6_gem_dump_usw_3_nn_union AS 
	SELECT	un.sub_id ::integer AS sub_id,
		un.usw_cat ::integer AS usw_cat,
		un.usw_sum ::integer AS usw_sum,
		un.geom ::geometry(Polygon,3035) AS geom
	FROM	(SELECT DISTINCT ON (nn.sub_id)
			nn.sub_id AS sub_id,
			nn.usw_cat AS usw_cat,
			nn.usw_sum AS usw_sum,
			(ST_DUMP(ST_UNION(nn.gem_geom))).geom AS geom
		FROM	orig_ego.vg250_6_gem_dump_usw_3_nn AS nn
		GROUP BY nn.sub_id, nn.usw_cat, nn.usw_sum) AS un;

-- "Create Index (sub_id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_6_gem_dump_usw_3_nn_union_sub_id_idx
		ON	orig_ego.vg250_6_gem_dump_usw_3_nn_union (sub_id);

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	vg250_6_gem_dump_usw_3_nn_union_geom_idx
	ON	orig_ego.vg250_6_gem_dump_usw_3_nn_union
	USING	GIST (geom);

---------- ---------- ----------

-- "update usw geom gem2"   (OK!) -> 1.000ms =1741
UPDATE 	orig_ego.ego_grid_districs AS t1
SET  	usw_sum  = t2.usw_sum,
	usw_cat = t2.usw_cat,
	geom_gem = t2.geom_gem
FROM	(SELECT	gem.id AS id,
		gem.gid AS gid,
		gem.vid AS vid,
		gem.ags_0 AS ags_0,
		gem.usw_cat ::integer AS usw_cat,
		gem.voi_usw_sum ::integer AS usw_sum,
		gem.geom ::geometry(Polygon,3035) AS geom_gem
	FROM	orig_ego.vg250_6_gem_dump_usw_3_nn_union AS gem )AS t2
WHERE  	t1.id = t2.id;












