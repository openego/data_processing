---------- ---------- ----------
---------- --SKRIPT-- OK! 7min
---------- ---------- ----------


-- -- "Create Index GIST (geom)"   (OK!) -> 100ms =0
-- CREATE INDEX  	znes_deu_substations_filtered_geom_idx
-- 	ON	calc_gridcells_znes.znes_deu_substations_filtered
-- 	USING	GIST (geom);

-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	calc_gridcells_znes.znes_deu_substations_filtered TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		calc_gridcells_znes.znes_deu_substations_filtered OWNER TO oeuser;

---------- ---------- ----------
-- OSM Substations
---------- ---------- ----------

-- "Substations"   (OK!) 2.000ms =3.707
DROP TABLE IF EXISTS	orig_osm.osm_deu_substations CASCADE;
CREATE TABLE		orig_osm.osm_deu_substations AS
	SELECT	sub.subst_id ::integer AS subst_id,
		sub.name ::text AS subst_name,
		sub.voltage ::text AS subst_voltage,
		sub.power_typ ::text AS power_typ,
		sub.substation ::text AS substation,
		sub.operator ::text AS subst_operator,
		sub.status ::text AS subst_status,
		(ST_DUMP(ST_TRANSFORM(sub.geom,3035))).geom ::geometry(Point,3035) AS geom
	FROM	calc_gridcells_znes.substations_deu_voronoi AS sub,
		orig_geo_vg250.vg250_1_sta_union_mview AS vg
	WHERE	vg.geom && ST_TRANSFORM(sub.geom,3035) AND
		ST_CONTAINS(vg.geom,ST_TRANSFORM(sub.geom,3035));

-- "Set PK"   (OK!) -> 2.000ms =0
ALTER TABLE orig_osm.osm_deu_substations
	ADD COLUMN	ags_0 character varying(12),
	ADD PRIMARY KEY (subst_id);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	osm_deu_substations_geom_idx
	ON	orig_osm.osm_deu_substations
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_osm.osm_deu_substations TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_osm.osm_deu_substations OWNER TO oeuser;

---------- ---------- ----------

-- "Calculate Gemeindeschlüssel"   (OK!) -> 3.000ms =3.709
UPDATE 	orig_osm.osm_deu_substations AS t1
SET  	ags_0 = t2.ags_0
FROM    (
	SELECT	sub.subst_id AS subst_id,
		vg.ags_0 AS ags_0
	FROM	orig_osm.osm_deu_substations AS sub,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && sub.geom AND
		ST_CONTAINS(vg.geom,sub.geom)
	) AS t2
WHERE  	t1.subst_id = t2.subst_id;



---------- ---------- ----------
-- Substations per Municipalities
---------- ---------- ----------

-- "Municipalities"   (OK!) -> 28.000ms =12.528
DROP TABLE IF EXISTS	orig_ego.ego_deu_municipalities_sub CASCADE;
CREATE TABLE		orig_ego.ego_deu_municipalities_sub AS
	SELECT	vg.*
	FROM	orig_geo_vg250.vg250_6_gem_dump_mview AS vg;

-- "Set PK"   (OK!) -> 1.000ms =0
ALTER TABLE orig_ego.ego_deu_municipalities_sub
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_typ integer,
	ADD PRIMARY KEY (id);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_municipalities_sub_geom_idx
	ON	orig_ego.ego_deu_municipalities_sub
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_municipalities_sub TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub OWNER TO oeuser;

---------- ---------- ----------

-- "usw count"   (OK!) -> 1.000ms =2.267
UPDATE 	orig_ego.ego_deu_municipalities_sub AS t1
SET  	subst_sum = t2.subst_sum
FROM	(SELECT	mun.id AS id,
		COUNT(sub.geom)::integer AS subst_sum
	FROM	orig_ego.ego_deu_municipalities_sub AS mun,
		orig_osm.osm_deu_substations AS sub
	WHERE  	mun.geom && sub.geom AND
		ST_CONTAINS(mun.geom,sub.geom)
	GROUP BY mun.id
	)AS t2
WHERE  	t1.id = t2.id;



---------- ---------- ----------
-- "MViews"
---------- ---------- ----------

-- "MView I."   (OK!) -> 300ms =1.682
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_municipalities_sub_1_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_municipalities_sub_1_mview AS 
	SELECT	mun.id,
		mun.gen,
		mun.bez,
		mun.ags_0,
		'1' ::integer AS subst_typ,
		mun.geom :: geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub AS mun
	WHERE	mun.subst_sum = '1';

-- "Create Index (id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_municipalities_sub_1_mview_gid_idx
		ON	orig_ego.ego_deu_municipalities_sub_1_mview (id);

-- "Substation Type 1"   (OK!) -> 1.000ms =1.682
UPDATE 	orig_ego.ego_deu_municipalities_sub AS t1
SET  	subst_typ = t2.subst_typ
FROM	(SELECT	mun.id AS id,
		mun.subst_typ AS subst_typ
	FROM	orig_ego.ego_deu_municipalities_sub_1_mview AS mun )AS t2
WHERE  	t1.id = t2.id;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_municipalities_sub_1_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub_1_mview OWNER TO oeuser;

---------- ---------- ----------

-- "MView II."   (OK!) -> 100ms =585
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_municipalities_sub_2_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_municipalities_sub_2_mview AS 
	SELECT	mun.id,
		mun.gen,
		mun.bez,
		mun.ags_0,
		'2' ::integer AS subst_typ,
		mun.geom :: geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub AS mun
	WHERE	mun.subst_sum > '1';

-- "Create Index (id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_municipalities_sub_2_mview_gid_idx
		ON	orig_ego.ego_deu_municipalities_sub_2_mview (id);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_municipalities_sub_2_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub_2_mview OWNER TO oeuser;

-- "Substation Type 2"   (OK!) -> 1.000ms =585
UPDATE 	orig_ego.ego_deu_municipalities_sub AS t1
SET  	subst_typ = t2.subst_typ
FROM	(SELECT	mun.id AS id,
		mun.subst_typ AS subst_typ
	FROM	orig_ego.ego_deu_municipalities_sub_2_mview AS mun )AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Substation Type 2"   (OK!) -> 200ms =2.027
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.osm_deu_substations_2_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.osm_deu_substations_2_mview AS
	SELECT	sub.subst_id ::integer AS subst_id,
		sub.subst_name ::text AS subst_name,
		sub.subst_voltage ::text AS subst_voltage,
		sub.power_typ ::text AS power_typ,
		sub.substation ::text AS substation,
		sub.subst_operator ::text AS subst_operator,
		sub.subst_status ::text AS subst_status,
		sub.ags_0 ::character varying(12) AS ags_0,
		'3' ::integer AS subst_typ,
		sub.geom ::geometry(Point,3035) AS geom
	FROM	orig_osm.osm_deu_substations AS sub,
		orig_ego.ego_deu_municipalities_sub_2_mview AS gem
	WHERE  	ST_CONTAINS(gem.geom,sub.geom);

-- "Create Index (subst_id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	osm_deu_substations_2_mview_gid_idx
		ON	orig_ego.osm_deu_substations_2_mview (subst_id);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.osm_deu_substations_2_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.osm_deu_substations_2_mview OWNER TO oeuser;


---------- ---------- ----------

-- "MView III."   (OK!) -> 22.000ms =10.261
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_municipalities_sub_3_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_municipalities_sub_3_mview AS 
	SELECT	mun.id,
		mun.gen,
		mun.bez,
		mun.ags_0,
		'3' ::integer AS subst_typ,
		mun.geom :: geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub AS mun
	WHERE	mun.subst_sum IS NULL;

-- "Create Index (id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_municipalities_sub_3_mview_gid_idx
		ON	orig_ego.ego_deu_municipalities_sub_3_mview (id);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_municipalities_sub_3_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub_3_mview OWNER TO oeuser;


-- "Substation Type 3"   (OK!) -> 1.000ms =10.261
UPDATE 	orig_ego.ego_deu_municipalities_sub AS t1
SET  	subst_typ = t2.subst_typ
FROM	(SELECT	mun.id AS id,
		'3'::integer AS subst_typ
	FROM	orig_ego.ego_deu_municipalities_sub_3_mview AS mun )AS t2
WHERE  	t1.id = t2.id;



---------- ---------- ----------
-- "Grid Districts"
---------- ---------- ----------

---------- ---------- ----------
-- "I. Gemeinden mit genau einem USW" 
---------- ---------- ----------

-- "Substations Template"   (OK!) -> 100ms =3.709
DROP TABLE IF EXISTS	orig_ego.ego_grid_districts_type_1 CASCADE;
CREATE TABLE		orig_ego.ego_grid_districts_type_1 AS
	SELECT	sub.subst_id ::integer AS subst_id,
		sub.subst_name ::text,
		sub.subst_voltage ::text,
		sub.power_typ ::text,
		sub.substation ::text,
		sub.subst_operator ::text,
		sub.subst_status ::text,
		sub.ags_0 ::character varying(12),
		ST_TRANSFORM(sub.geom,3035) ::geometry(Point,3035) AS geom_sub
	FROM	orig_osm.osm_deu_substations AS sub;

-- "Set PK"   (OK!) -> 100ms =0
ALTER TABLE orig_ego.ego_grid_districts_type_1
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_typ integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (subst_id);

-- "Create Index GIST (geom_sub)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districts_type_1_geom_sub_idx
	ON	orig_ego.ego_grid_districts_type_1
	USING	GIST (geom_sub);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districts_type_1_geom_mun_idx
	ON	orig_ego.ego_grid_districts_type_1
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_grid_districts_type_1 TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_grid_districts_type_1 OWNER TO oeuser;

---------- ---------- ----------

-- sub_id = gem.id
-- "update usw geom gem1"   (OK!) -> 1.000ms =1.682
UPDATE 	orig_ego.ego_grid_districts_type_1 AS t1
SET  	subst_sum  = t2.subst_sum,
	subst_typ = t2.subst_typ,
	geom = t2.geom
FROM	(SELECT	mun.ags_0 AS ags_0,
		mun.subst_sum ::integer AS subst_sum,
		mun.subst_typ ::integer AS subst_typ,
		ST_MULTI(mun.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub AS mun
	WHERE	subst_typ = '1')AS t2
WHERE  	t1.ags_0 = t2.ags_0;



---------- ---------- ---------- ---------- ---------- ----------
-- "II. Gemeinden mit mehreren USW"
---------- ---------- ---------- ---------- ---------- ----------


---------- ---------- ----------
-- VORONOI ON Substations IN vg250
---------- ---------- ----------
-- Hier kann das Voronoi berechnet werden. Alternativ kann unten ein anderes Table gewählt werden!

-- -- "VORONOI"   (OK!) -> 954.000ms =3.689
-- DROP TABLE IF EXISTS orig_ego.ego_deu_substations_voronoi;  -- NAME 1/2
-- WITH 
--     -- Sample set of points to work with
--     Sample AS (SELECT   ST_SetSRID(ST_Union(pts.geom), 0) AS geom
-- 		FROM	orig_osm.osm_deu_substations AS pts),  -- INPUT
--     -- Build edges and circumscribe points to generate a centroid
--     Edges AS (
--     SELECT id,
--         UNNEST(ARRAY['e1','e2','e3']) EdgeName,
--         UNNEST(ARRAY[
--             ST_MakeLine(p1,p2) ,
--             ST_MakeLine(p2,p3) ,
--             ST_MakeLine(p3,p1)]) Edge,
--         ST_Centroid(ST_ConvexHull(ST_Union(-- Done this way due to issues I had with LineToCurve
--             ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p1,p2),ST_MakeLine(p2,p3)))),'LINE','CIRCULAR'),15),
--             ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p2,p3),ST_MakeLine(p3,p1)))),'LINE','CIRCULAR'),15)
--         ))) ct      
--     FROM    (
--         -- Decompose to points
--         SELECT id,
--             ST_PointN(g,1) p1,
--             ST_PointN(g,2) p2,
--             ST_PointN(g,3) p3
--         FROM    (
--             SELECT (gd).Path id, ST_ExteriorRing((gd).geom) g -- ID andmake triangle a linestring
--             FROM (SELECT (ST_Dump(ST_DelaunayTriangles(geom))) gd FROM Sample) a -- Get Delaunay Triangles
--             )b
--         ) c
--     )
-- SELECT ST_SetSRID((ST_Dump(ST_Polygonize(ST_Node(ST_LineMerge(ST_Union(v, (SELECT ST_ExteriorRing(ST_ConvexHull(ST_Union(ST_Union(ST_Buffer(edge,20),ct)))) FROM Edges))))))).geom, 2180) geom
-- INTO orig_ego.ego_deu_substations_voronoi		  -- NAME 2/2
-- FROM (
--     SELECT  -- Create voronoi edges and reduce to a multilinestring
--         ST_LineMerge(ST_Union(ST_MakeLine(
--         x.ct,
--         CASE 
--         WHEN y.id IS NULL THEN
--             CASE WHEN ST_Within(
--                 x.ct,
--                 (SELECT ST_ConvexHull(geom) FROM sample)) THEN -- Don't draw lines back towards the original set
--                 -- Project line out twice the distance from convex hull
--                 ST_MakePoint(ST_X(x.ct) + ((ST_X(ST_Centroid(x.edge)) - ST_X(x.ct)) * 200),ST_Y(x.ct) + ((ST_Y(ST_Centroid(x.edge)) - ST_Y(x.ct)) * 200))
--             END
--         ELSE 
--             y.ct
--         END
--         ))) v
--     FROM    Edges x 
--         LEFT OUTER JOIN -- Self Join based on edges
--         Edges y ON x.id <> y.id AND ST_Equals(x.edge,y.edge)
--     ) z;

---------- ---------- ---------- Alternativer Input:

-- "Create Table with Voronoi-Polygons"   (OK!) -> 100ms =3.682
DROP TABLE IF EXISTS orig_ego.ego_deu_substations_voronoi;
CREATE TABLE orig_ego.ego_deu_substations_voronoi AS
	SELECT	voi.id,
		GeometryType(voi.geom) ::text AS geom_type,
		ST_MAKEVALID(ST_TRANSFORM(voi.geom),3035) ::geometry(Polygon,3035) AS geom
	FROM	calc_gridcells_znes.deu_voronoi AS voi;

---------- ---------- ----------

-- "Set PK"   (OK!) -> 100ms =0
ALTER TABLE orig_ego.ego_deu_substations_voronoi
	ADD COLUMN id serial,
	ADD COLUMN subst_id integer,
	ADD COLUMN subst_sum integer,
	ADD PRIMARY KEY (id),
	ALTER COLUMN geom TYPE geometry(Polygon,3035) USING ST_SETSRID(geom,3035);

-- "Create Index GIST (geom)"   (OK!) 11.000ms =0
CREATE INDEX	ego_deu_substations_voronoi_geom_idx
	ON	orig_ego.ego_deu_substations_voronoi
	USING	GIST (geom);

-- "Substation ID"   (OK!) -> 1.000ms =3.688
UPDATE 	orig_ego.ego_deu_substations_voronoi AS t1
SET  	subst_id = t2.subst_id
FROM	(SELECT	voi.id AS id,
		voi.subst_id ::integer AS subst_id
	FROM	orig_ego.ego_deu_substations_voronoi AS voi,
		orig_osm.osm_deu_substations AS sub
	WHERE  	ST_CONTAINS(voi.geom,ST_TRANSFORM(sub.geom,3035))
	GROUP BY voi.id
	)AS t2
WHERE  	t1.id = t2.id;

-- "Substation Count"   (OK!) -> 1.000ms =3.688
UPDATE 	orig_ego.ego_deu_substations_voronoi AS t1
SET  	subst_sum = t2.subst_sum
FROM	(SELECT	voi.id AS id,
		COUNT(sub.geom)::integer AS subst_sum
	FROM	orig_ego.ego_deu_substations_voronoi AS voi,
		orig_osm.osm_deu_substations AS sub
	WHERE  	ST_CONTAINS(voi.geom,ST_TRANSFORM(sub.geom,3035))
	GROUP BY voi.id
	)AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Voronoi Gridcells (voi)"   (OK!) 100ms =3.689
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_voronoi_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_substations_voronoi_mview AS
	SELECT	poly.id ::integer AS id,
		poly.subst_id ::integer AS subst_id,
		poly.subst_sum ::integer AS subst_sum,
		(ST_DUMP(ST_TRANSFORM(poly.geom,3035))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_substations_voronoi AS poly;

-- "Create Index (id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_mview_id_idx
		ON	orig_ego.ego_deu_substations_voronoi_mview (id);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_voronoi_mview_geom_idx
	ON	orig_ego.ego_deu_substations_voronoi_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_substations_voronoi_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_voronoi_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Validate (geom)"   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	orig_ego.ego_deu_substations_voronoi_error_geom_view CASCADE;
CREATE VIEW		orig_ego.ego_deu_substations_voronoi_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_ego.ego_deu_substations_voronoi AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_substations_voronoi_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_voronoi_error_geom_view OWNER TO oeuser;

-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_deu_substations_voronoi_error_geom_view}', 'orig_ego');



---------- ---------- ----------
-- "CUT"
---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.ego_deu_substations_voronoi_cut_id CASCADE;
CREATE SEQUENCE 		orig_ego.ego_deu_substations_voronoi_cut_id;

-- "Cutting GEM II."   (OK!) 3.000ms =4.824
DROP TABLE IF EXISTS	orig_ego.ego_deu_substations_voronoi_cut CASCADE;
CREATE TABLE		orig_ego.ego_deu_substations_voronoi_cut AS
	SELECT	nextval('orig_ego.ego_deu_substations_voronoi_cut_id') AS id,
		voi.subst_id AS subst_id,
		gem.id AS mun_id,
		voi.id AS voi_id,
		gem.ags_0 AS ags_0,
		gem.subst_typ AS subst_typ,
		(ST_DUMP(ST_INTERSECTION(gem.geom,voi.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub_2_mview AS gem,
		orig_ego.ego_deu_substations_voronoi AS voi
	WHERE	gem.geom && voi.geom;

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	orig_ego.ego_deu_substations_voronoi_cut
	ADD COLUMN subst_sum integer,
	ADD COLUMN geom_sub geometry(Point,3035),
	ADD PRIMARY KEY (id);

-- "Count Substations in Voronoi Cuts"   (OK!) -> 1.000ms =2.026
UPDATE 	orig_ego.ego_deu_substations_voronoi_cut AS t1
SET  	subst_sum = t2.subst_sum,
	subst_id = t2.subst_id,
	geom_sub = t2.geom_sub
FROM	(SELECT	gem.id AS id,
		sub.subst_id AS subst_id,
		sub.geom AS geom_sub,
		COUNT(sub.geom)::integer AS subst_sum
	FROM	orig_ego.ego_deu_substations_voronoi_cut AS gem,
		orig_osm.osm_deu_substations AS sub
	WHERE  	ST_CONTAINS(gem.geom,ST_TRANSFORM(sub.geom,3035))
	GROUP BY gem.id,sub.subst_id
	)AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_geom_idx
	ON	orig_ego.ego_deu_substations_voronoi_cut
	USING	GIST (geom);

-- "Create Index GIST (geom_sub)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_geom_sub_idx
	ON	orig_ego.ego_deu_substations_voronoi_cut
	USING	GIST (geom_sub);
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_substations_voronoi_cut TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_voronoi_cut OWNER TO oeuser;

---------- ---------- ----------

-- "Validate (geom)"   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	orig_ego.ego_deu_substations_voronoi_cut_error_geom_view CASCADE;
CREATE VIEW		orig_ego.ego_deu_substations_voronoi_cut_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_ego.ego_deu_substations_voronoi_cut AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_substations_voronoi_cut_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_voronoi_cut_error_geom_view OWNER TO oeuser;

-- -- "Drop empty view"   (OK!) -> 100ms =1 (no error!)
-- SELECT f_drop_view('{ego_deu_substations_voronoi_cut_error_geom_view}', 'orig_ego');

---------- ---------- ----------

-- "Parts with substation"   (OK!) 100ms =3.689
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_voronoi_cut_1sub_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_substations_voronoi_cut_1sub_mview AS
SELECT	voi.*
FROM	orig_ego.ego_deu_substations_voronoi_cut AS voi
WHERE	subst_sum = 1;

-- "Create Index (id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_1sub_mview_id_idx
		ON	orig_ego.ego_deu_substations_voronoi_cut_1sub_mview (id);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_voronoi_cut_1sub_mview_geom_idx
	ON	orig_ego.ego_deu_substations_voronoi_cut_1sub_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_substations_voronoi_cut_1sub_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_voronoi_cut_1sub_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Parts without substation"   (OK!) 100ms =3.689
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_voronoi_cut_0sub_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_substations_voronoi_cut_0sub_mview AS
SELECT	voi.id,
	voi.subst_id,
	voi.mun_id,
	voi.voi_id,
	voi.ags_0,
	voi.subst_typ,
	voi.geom
FROM	orig_ego.ego_deu_substations_voronoi_cut AS voi
WHERE	subst_sum IS NULL;

-- "Create Index (id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_0sub_mview_id_idx
		ON	orig_ego.ego_deu_substations_voronoi_cut_0sub_mview (id);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_voronoi_cut_0sub_mview_geom_idx
	ON	orig_ego.ego_deu_substations_voronoi_cut_0sub_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_substations_voronoi_cut_0sub_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_voronoi_cut_0sub_mview OWNER TO oeuser;

---------- ---------- ----------

-- -- "Calculate Gemeindeschlüssel"   (OK!) -> 3.000ms =4.981
-- UPDATE 	orig_ego.ego_deu_substations_voronoi_cut AS t1
-- SET  	ags_0 = t2.ags_0
-- FROM    (
-- 	SELECT	cut.id AS id,
-- 		vg.ags_0 AS ags_0
-- 	FROM	orig_ego.ego_deu_substations_voronoi_cut AS cut,
-- 		orig_geo_vg250.vg250_6_gem_mview AS vg
-- 	WHERE  	vg.geom && ST_POINTONSURFACE(cut.geom) AND
-- 		ST_CONTAINS(vg.geom,ST_POINTONSURFACE(cut.geom))
-- 	) AS t2
-- WHERE  	t1.id = t2.id;


---------- ---------- ----------
-- Connect the cutted parts to the next substation
---------- ---------- ----------

-- "Next Neighbor"   (OK!) 1.000ms =4.820
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_mview AS 
SELECT DISTINCT ON (voi.id)
	voi.id AS voi_id,
	voi.ags_0 AS voi_ags_0,
	voi.geom AS geom_voi,
	sub.subst_id AS subst_id,
	sub.ags_0 AS ags_0,
	sub.geom AS geom_sub
FROM 	orig_ego.ego_deu_substations_voronoi_cut_0sub_mview AS voi,
	orig_ego.ego_deu_substations_voronoi_cut_1sub_mview AS sub
WHERE 	ST_DWithin(ST_ExteriorRing(voi.geom),ST_ExteriorRing(sub.geom), 50000) -- In a 50 km radius
	AND voi.ags_0 = sub.ags_0  -- only inside same mun
ORDER BY 	voi.id, 
		ST_Distance(ST_ExteriorRing(voi.geom),ST_ExteriorRing(sub.geom));
		
-- ST_Length(ST_CollectionExtract(ST_Intersection(a_geom, b_geom), 2)) -- Lenght of the shared border?

-- "Create Index (id)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_0sub_nn_mview_voi_id_idx
		ON	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_mview (voi_id);

-- "Create Index GIST (geom_voi)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_voronoi_cut_0sub_nn_mview_geom_voi_idx
	ON	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_mview
	USING	GIST (geom_voi);

-- "Create Index GIST (geom_sub)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_substations_voronoi_cut_0sub_nn_mview_geom_sub_idx
	ON	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_mview
	USING	GIST (geom_sub);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_mview OWNER TO oeuser;

---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_line_mview_id CASCADE;
CREATE SEQUENCE 		orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_line_mview_id;

-- "connect points"   (OK!) 1.000ms =4.714
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_line_mview;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_line_mview AS 
	SELECT 	nextval('orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_line_mview_id') AS id,
		nn.voi_id,
		nn.subst_id,
		(ST_Dump(ST_CENTROID(nn.geom_voi))).geom ::geometry(Point,3035) AS geom_centre,
		ST_ShortestLine(	(ST_Dump(ST_CENTROID(nn.geom_voi))).geom ::geometry(Point,3035),
					sub.geom ::geometry(Point,3035)
		) ::geometry(LineString,3035) AS geom
	FROM	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_mview AS nn,
		orig_osm.osm_deu_substations AS sub
	WHERE	sub.subst_id = nn.subst_id;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_0sub_nn_line_mview_id_idx
		ON	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_line_mview (id);

-- "Create Index GIST (geom_centre)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_0sub_nn_line_mview_geom_centre_idx
	ON	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_line_mview
	USING	GIST (geom_centre);

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_0sub_nn_line_mview_geom_idx
	ON	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_line_mview
	USING	GIST (geom);

---------- ---------- ----------

-- "Create Table"   (OK!) 4.000ms =2.026
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_union_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_union_mview AS 
	SELECT	nn.subst_id As subst_id, 
		ST_MULTI(ST_UNION(nn.geom_voi)) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_mview AS nn
	GROUP BY nn.subst_id;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_0sub_nn_union_mview_id_idx
		ON	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_union_mview (subst_id);

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_0sub_nn_union_mview_geom_idx
	ON	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_union_mview
	USING	GIST (geom);

---------- ---------- ----------

-- "Create Table"   (OK!) 4.000ms =0
DROP TABLE IF EXISTS	orig_ego.ego_deu_substations_voronoi_cut_nn_collect CASCADE;
CREATE TABLE		orig_ego.ego_deu_substations_voronoi_cut_nn_collect (
	id serial,
	subst_id integer,
	geom geometry(MultiPolygon,3035),
CONSTRAINT ego_deu_substations_voronoi_cut_nn_collect_pkey PRIMARY KEY (id));

-- "Insert parts with substations"   (OK!) 4.000ms =2.024
INSERT INTO     orig_ego.ego_deu_substations_voronoi_cut_nn_collect (subst_id,geom)
	SELECT	sub.subst_id AS subst_id,
		ST_MULTI(sub.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_substations_voronoi_cut_1sub_mview AS sub;

-- "Insert parts without substations union"   (OK!) 4.000ms =2.024
INSERT INTO     orig_ego.ego_deu_substations_voronoi_cut_nn_collect (subst_id,geom)
	SELECT	voi.subst_id AS subst_id,
		voi.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_substations_voronoi_cut_0sub_nn_union_mview AS voi;

-- "Create Index GIST (geom)"   (OK!) 11.000ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_nn_collect_geom_idx
	ON	orig_ego.ego_deu_substations_voronoi_cut_nn_collect
	USING	GIST (geom);

---------- ---------- ----------

-- "Create Table"   (OK!) 4.000ms =2.024
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_substations_voronoi_cut_nn_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_substations_voronoi_cut_nn_mview AS 
	SELECT	nn.subst_id As subst_id, 
		ST_MULTI(ST_UNION(nn.geom)) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_substations_voronoi_cut_nn_collect AS nn
	GROUP BY nn.subst_id;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_substations_voronoi_cut_nn_mview_id_idx
		ON	orig_ego.ego_deu_substations_voronoi_cut_nn_mview (subst_id);

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_substations_voronoi_cut_nn_mview_geom_idx
	ON	orig_ego.ego_deu_substations_voronoi_cut_nn_mview
	USING	GIST (geom);

---------- ---------- ----------

-- "Substations Template"   (OK!) -> 100ms =3.709
DROP TABLE IF EXISTS	orig_ego.ego_grid_districts_type_2 CASCADE;
CREATE TABLE		orig_ego.ego_grid_districts_type_2 AS
	SELECT	sub.subst_id ::integer AS subst_id,
		sub.subst_name ::text,
		sub.subst_voltage ::text,
		sub.power_typ ::text,
		sub.substation ::text,
		sub.subst_operator ::text,
		sub.subst_status ::text,
		sub.ags_0 ::character varying(12),
		ST_TRANSFORM(sub.geom,3035) ::geometry(Point,3035) AS geom_sub
	FROM	orig_osm.osm_deu_substations AS sub;

-- "Set PK"   (OK!) -> 100ms =0
ALTER TABLE orig_ego.ego_grid_districts_type_2
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_typ integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (subst_id);

-- "Create Index GIST (geom_sub)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districts_type_2_geom_sub_idx
	ON	orig_ego.ego_grid_districts_type_2
	USING	GIST (geom_sub);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districts_type_2_geom_mun_idx
	ON	orig_ego.ego_grid_districts_type_2
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_grid_districts_type_2 TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_grid_districts_type_2 OWNER TO oeuser;

---------- ---------- ----------

-- sub_id = id
-- "update sub geom gem2"   (OK!) -> 1.000ms =2.026
UPDATE 	orig_ego.ego_grid_districts_type_2 AS t1
SET  	subst_typ = t2.subst_typ,
	geom = t2.geom
FROM	(SELECT	nn.subst_id AS subst_id,
		'2' ::integer AS subst_typ,
		nn.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_substations_voronoi_cut_nn_mview AS nn )AS t2
WHERE  	t1.subst_id = t2.subst_id;

---------- ---------- ----------
-- 
-- -- "voi"   (OK!) 100ms =3.693
-- DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_usw_voronoi_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_ego.ego_deu_usw_voronoi_mview AS
-- 	SELECT	poly.id ::integer AS id,
-- 		(ST_DUMP(ST_TRANSFORM(poly.geom,3035))).geom ::geometry(Polygon,3035) AS geom
-- 	FROM	orig_ego.ego_deu_usw_voronoi AS poly;
-- 
-- -- "Create Index GIST (geom)"   (OK!) -> 100ms =0
-- CREATE INDEX  	ego_deu_usw_voronoi_mview_geom_idx
-- 	ON	orig_ego.ego_deu_usw_voronoi_mview
-- 	USING	GIST (geom);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	orig_ego.ego_deu_usw_voronoi_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_usw_voronoi_mview OWNER TO oeuser;
-- 
-- ---------- ---------- ----------	
-- 
-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	orig_ego.ego_deu_usw_voronoi_mview_error_geom_view CASCADE;
-- CREATE VIEW		orig_ego.ego_deu_usw_voronoi_mview_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	orig_ego.ego_deu_usw_voronoi_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_ego.ego_deu_usw_voronoi_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_usw_voronoi_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_deu_usw_voronoi_mview_error_geom_view}', 'orig_ego');

---------- ---------- ----------



---------- ---------- ----------

-- DROP MATERIALIZED VIEW IF EXISTS	orig_ego.vg250_6_gem_sub_2_pts_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_ego.vg250_6_gem_sub_2_pts_mview AS 
-- 	SELECT	'1' ::integer AS id,
-- 		ST_SetSRID(ST_Union(sub.geom), 0) AS geom
-- 	FROM	calc_gridcells_znes.znes_deu_substations_filtered AS sub
-- 	WHERE	subst_id = '3791' OR subst_id = '3765';

-- -- (POSTGIS 2.3!!!)
-- DROP MATERIALIZED VIEW IF EXISTS	orig_ego.vg250_6_gem_sub_2_voronoi_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_ego.vg250_6_gem_sub_2_voronoi_mview AS 
-- 	SELECT	gem2.gid AS id,
-- 		ST_Voronoi(sub.geom,gem2.geom,30,true) AS geom
-- 	FROM	orig_ego.vg250_6_gem_sub_2_pts_mview AS sub,
-- 		orig_ego.vg250_6_gem_sub_2_mview AS gem2
-- 	WHERE	gem2.gid = '4884'



---------- ---------- ----------
-- "III. Gemeinden ohne sub"
---------- ---------- ----------

-- gem WHERE subst_sum=0		orig_geo_ego.vg250_6_gem_sub_3_mview
-- sub				orig_geo_ego.ego_deu_mv_substations_mview

-- "Next Neighbor"   (OK!) 14.000ms =10.259
DROP TABLE IF EXISTS	orig_ego.ego_deu_municipalities_sub_3_nn CASCADE;
CREATE TABLE 		orig_ego.ego_deu_municipalities_sub_3_nn AS 
SELECT DISTINCT ON (mun.id)
	mun.id AS mun_id,
	mun.ags_0 AS mun_ags_0,
	sub.ags_0 AS sub_ags_0,
	sub.subst_id AS subst_id, 
	mun.subst_typ AS subst_typ,
	sub.geom ::geometry(Point,3035) AS geom_sub,
	ST_MULTI(mun.geom) ::geometry(MultiPolygon,3035) AS geom
FROM 	orig_ego.ego_deu_municipalities_sub_3_mview AS mun, 
	orig_osm.osm_deu_substations AS sub
WHERE 	ST_DWithin(ST_ExteriorRing(mun.geom),sub.geom, 50000) -- In a 50 km radius
ORDER BY 	mun.id, ST_Distance(ST_ExteriorRing(mun.geom),sub.geom);

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	orig_ego.ego_deu_municipalities_sub_3_nn
	ADD PRIMARY KEY (mun_id);

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
DROP INDEX IF EXISTS 	ego_deu_municipalities_sub_3_nn_geom_idx;
CREATE INDEX		ego_deu_municipalities_sub_3_nn_geom_idx
	ON	orig_ego.ego_deu_municipalities_sub_3_nn
	USING	GIST (geom);

-- "Create Index GIST (geom_sub)"   (OK!) 2.500ms =0
DROP INDEX IF EXISTS 	ego_deu_municipalities_sub_3_nn_geom_sub_idx;
CREATE INDEX		ego_deu_municipalities_sub_3_nn_geom_sub_idx
	ON	orig_ego.ego_deu_municipalities_sub_3_nn
	USING	GIST (geom_sub);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_municipalities_sub_3_nn TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub_3_nn OWNER TO oeuser;


---------- ---------- ----------
-- NN Line
---------- ---------- ----------

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.ego_deu_municipalities_sub_3_nn_line_id CASCADE;
CREATE SEQUENCE 		orig_ego.ego_deu_municipalities_sub_3_nn_line_id;

-- "connect points"   (OK!) 1.000ms =10.259
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_municipalities_sub_3_nn_line;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_municipalities_sub_3_nn_line AS 
	SELECT 	nextval('orig_ego.ego_deu_municipalities_sub_3_nn_line_id') AS id,
		nn.mun_id AS nn_id,
		nn.subst_id,
		(ST_Dump(ST_PointOnSurface(nn.geom))).geom ::geometry(Point,3035) AS geom_centre,
		ST_ShortestLine(	(ST_Dump(ST_PointOnSurface(nn.geom))).geom ::geometry(Point,3035),
					nn.geom_sub ::geometry(Point,3035)
		) ::geometry(LineString,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub_3_nn AS nn;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_municipalities_sub_3_nn_line_id_idx
		ON	orig_ego.ego_deu_municipalities_sub_3_nn_line (id);

-- "Create Index GIST (geom_centre)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_municipalities_sub_3_nn_line_geom_centre_idx
	ON	orig_ego.ego_deu_municipalities_sub_3_nn_line
	USING	GIST (geom_centre);

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_municipalities_sub_3_nn_line_geom_idx
	ON	orig_ego.ego_deu_municipalities_sub_3_nn_line
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_municipalities_sub_3_nn_line TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub_3_nn_line OWNER TO oeuser;


---------- ---------- ----------

-- UNION

-- "union mun"   (OK!) 33.000ms =2.115
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_municipalities_sub_3_nn_union CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_municipalities_sub_3_nn_union AS 
	SELECT	un.subst_id ::integer AS subst_id,
		un.subst_typ ::integer AS subst_typ,
		un.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT DISTINCT ON (nn.subst_id)
			nn.subst_id AS subst_id,
			nn.subst_typ AS subst_typ,
			ST_MULTI(ST_UNION(nn.geom)) AS geom
		FROM	orig_ego.ego_deu_municipalities_sub_3_nn AS nn
		GROUP BY nn.subst_id, nn.subst_typ) AS un;

-- "Create Index (subst_id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_municipalities_sub_3_nn_union_subst_id_idx
		ON	orig_ego.ego_deu_municipalities_sub_3_nn_union (subst_id);

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_municipalities_sub_3_nn_union_geom_idx
	ON	orig_ego.ego_deu_municipalities_sub_3_nn_union
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_municipalities_sub_3_nn_union TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_municipalities_sub_3_nn_union OWNER TO oeuser;

---------- ---------- ----------

-- "Substations Template"   (OK!) -> 100ms =3.707
DROP TABLE IF EXISTS	orig_ego.ego_grid_districts_type_3 CASCADE;
CREATE TABLE		orig_ego.ego_grid_districts_type_3 AS
	SELECT	sub.subst_id ::integer AS subst_id,
		sub.subst_name ::text,
		sub.subst_voltage ::text,
		sub.power_typ ::text,
		sub.substation ::text,
		sub.subst_operator ::text,
		sub.subst_status ::text,
		sub.ags_0 ::character varying(12),
		ST_TRANSFORM(sub.geom,3035) ::geometry(Point,3035) AS geom_sub
	FROM	orig_osm.osm_deu_substations AS sub;

-- "Set PK"   (OK!) -> 100ms =0
ALTER TABLE orig_ego.ego_grid_districts_type_3
	ADD COLUMN subst_sum integer,
	ADD COLUMN subst_typ integer,
	ADD COLUMN geom geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (subst_id);

-- "Create Index GIST (geom_sub)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districts_type_3_geom_sub_idx
	ON	orig_ego.ego_grid_districts_type_3
	USING	GIST (geom_sub);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_grid_districts_type_3_geom_mun_idx
	ON	orig_ego.ego_grid_districts_type_3
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_grid_districts_type_3 TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_grid_districts_type_3 OWNER TO oeuser;

---------- ---------- ----------

-- "update sub geom mun3"   (OK!) -> 1.000ms =2.115
UPDATE 	orig_ego.ego_grid_districts_type_3 AS t1
SET  	subst_typ = t2.subst_typ,
	geom = t2.geom
FROM	(SELECT	un.subst_id AS subst_id,
		un.subst_typ ::integer AS subst_typ,
		ST_MULTI(un.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_municipalities_sub_3_nn_union AS un ) AS t2
WHERE  	t1.subst_id = t2.subst_id;



---------- ---------- ----------
-- Collect the 3 Mun-types
---------- ---------- ----------

-- "Substations Template"   (OK!) -> 100ms =3.709
DROP TABLE IF EXISTS	orig_ego.ego_grid_districts_collect CASCADE;
CREATE TABLE		orig_ego.ego_grid_districts_collect (
	id SERIAL NOT NULL,
	subst_id integer,
	subst_name text,
	subst_voltage text,
	power_typ text,
	substation text,
	subst_operator text,
	subst_status text,
	ags_0 character varying(12),
	geom_sub geometry(Point,3035),
	subst_sum integer,
	subst_typ integer,
	geom geometry(MultiPolygon,3035),
	CONSTRAINT	ego_grid_districts_collect_pkey PRIMARY KEY (id));

-- "Insert 1"   (OK!) 100.000ms =3.709
INSERT INTO     orig_ego.ego_grid_districts_collect 
	(subst_id,subst_name,subst_voltage,power_typ,substation,
	subst_operator,subst_status,ags_0,geom_sub,subst_sum,subst_typ,geom)
	SELECT	*
	FROM	orig_ego.ego_grid_districts_type_1
	ORDER BY subst_id;

-- "Insert 2"   (OK!) 100.000ms =3.709
INSERT INTO     orig_ego.ego_grid_districts_collect 
	(subst_id,subst_name,subst_voltage,power_typ,substation,
	subst_operator,subst_status,ags_0,geom_sub,subst_sum,subst_typ,geom)
	SELECT	*
	FROM	orig_ego.ego_grid_districts_type_2
	ORDER BY subst_id;

-- "Insert 3"   (OK!) 100.000ms =3.707
INSERT INTO     orig_ego.ego_grid_districts_collect 
	(subst_id,subst_name,subst_voltage,power_typ,substation,
	subst_operator,subst_status,ags_0,geom_sub,subst_sum,subst_typ,geom)
	SELECT	*
	FROM	orig_ego.ego_grid_districts_type_3
	ORDER BY subst_id;

---------- ---------- ----------

-- UNION I + II + II

-- "union mun"   (OK!) 19.000ms =3.707
DROP TABLE IF EXISTS	orig_ego.ego_grid_districts CASCADE;
CREATE TABLE 		orig_ego.ego_grid_districts AS 
	SELECT	un.subst_id ::integer AS subst_id,
		ST_AREA(un.geom)/10000 AS area,
		un.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT DISTINCT ON (dis.subst_id)
			dis.subst_id AS subst_id,
			ST_MULTI(ST_UNION(ST_SNAP(dis.geom,vg.geom,1))) ::geometry(MultiPolygon,3035) AS geom
		FROM	orig_ego.ego_grid_districts_collect AS dis,
			orig_geo_vg250.vg250_6_gem_dump_mview AS vg
		GROUP BY dis.subst_id) AS un;

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	orig_ego.ego_grid_districts
	ADD COLUMN subst_sum integer,
	ADD PRIMARY KEY (subst_id);

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_grid_districts_geom_idx
	ON	orig_ego.ego_grid_districts
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_grid_districts TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_grid_districts OWNER TO oeuser;


-- "Count Substations in Grid Districts"   (OK!) -> 1.000ms =2.267
UPDATE 	orig_ego.ego_grid_districts AS t1
SET  	subst_sum = t2.subst_sum
FROM	(SELECT	dis.subst_id AS subst_id,
		COUNT(sub.geom)::integer AS subst_sum
	FROM	orig_ego.ego_grid_districts AS dis,
		orig_osm.osm_deu_substations AS sub
	WHERE  	dis.geom && sub.geom AND
		ST_CONTAINS(dis.geom,sub.geom)
	GROUP BY dis.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

---------- ---------- ----------	

-- "Validate (geom)"   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	orig_ego.ego_grid_districts_error_geom_view CASCADE;
CREATE VIEW		orig_ego.ego_grid_districts_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.subst_id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_ego.ego_grid_districts AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_grid_districts_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_grid_districts_error_geom_view OWNER TO oeuser;

-- "Drop empty view"   (OK!) -> 100ms =1
SELECT f_drop_view('{ego_grid_districts_error_geom_view}', 'orig_ego');

-- ---------- ---------- ----------
-- -- DUMP
-- ---------- ---------- ----------
-- 
-- -- "Sequence"   (OK!) 100ms =0
-- DROP SEQUENCE IF EXISTS 	orig_ego.ego_grid_districts_dump_id CASCADE;
-- CREATE SEQUENCE 		orig_ego.ego_grid_districts_dump_id;
-- 
-- -- "Dump"   (OK!) 19.000ms =4.091
-- DROP TABLE IF EXISTS	orig_ego.ego_grid_districts_dump CASCADE;
-- CREATE TABLE 		orig_ego.ego_grid_districts_dump AS 
-- 	SELECT	nextval('orig_ego.ego_deu_municipalities_sub_3_nn_line_id') AS id,
-- 		dump.subst_id ::integer AS subst_id,
-- 		ST_AREA(dump.geom)/1000 AS area_ha,
-- 		dump.geom ::geometry(Polygon,3035) AS geom
-- 	FROM	(SELECT dis.subst_id AS subst_id,
-- 			(ST_DUMP(dis.geom)).geom ::geometry(Polygon,3035) AS geom
-- 		FROM	orig_ego.ego_grid_districts AS dis) AS dump;
-- 
-- -- "Ad PK"   (OK!) 150ms =0
-- ALTER TABLE	orig_ego.ego_grid_districts_dump
-- 	ADD COLUMN subst_sum integer,
-- 	ADD PRIMARY KEY (id);
-- 
-- -- "Count Substations in Grid Districts"   (OK!) -> 1.000ms =2.267
-- UPDATE 	orig_ego.ego_grid_districts_dump AS t1
-- SET  	subst_sum = t2.subst_sum
-- FROM	(SELECT	dis.id AS id,
-- 		COUNT(sub.geom)::integer AS subst_sum
-- 	FROM	orig_ego.ego_grid_districts_dump AS dis,
-- 		orig_osm.osm_deu_substations AS sub
-- 	WHERE  	dis.geom && sub.geom AND
-- 		ST_CONTAINS(dis.geom,sub.geom)
-- 	GROUP BY dis.id
-- 	)AS t2
-- WHERE  	t1.id = t2.id;
-- 
-- -- "Create Index GIST (geom)"   (OK!) 2.500ms =0
-- CREATE INDEX	ego_grid_districts_dump_geom_idx
-- 	ON	orig_ego.ego_grid_districts_dump
-- 	USING	GIST (geom);

-- 
-- ---------- ---------- ----------
-- -- HULL
-- ---------- ---------- ----------
-- 
-- -- "hull"   (OK!) 19.000ms =4.091
-- DROP TABLE IF EXISTS	orig_ego.ego_grid_districts_hull CASCADE;
-- CREATE TABLE 		orig_ego.ego_grid_districts_hull AS 
-- 	SELECT	dis.subst_id ::integer AS subst_id,
-- 		ST_AREA(dis.geom)/1000 AS area_ha,
-- 		ST_MULTI(dis.geom) ::geometry(MultiPolygon,3035) AS geom
-- 	FROM	(SELECT dis.subst_id AS subst_id,
-- 			ST_BUFFER(dis.geom,1) AS geom
-- 		FROM	orig_ego.ego_grid_districts AS dis) AS dis;
-- 
-- -- "Ad PK"   (OK!) 150ms =0
-- ALTER TABLE	orig_ego.ego_grid_districts_hull
-- 	ADD COLUMN subst_sum integer,
-- 	ADD PRIMARY KEY (subst_id);
-- 
-- -- "Count Substations in Grid Districts"   (OK!) -> 1.000ms =2.267
-- UPDATE 	orig_ego.ego_grid_districts_hull AS t1
-- SET  	subst_sum = t2.subst_sum
-- FROM	(SELECT	dis.subst_id AS subst_id,
-- 		COUNT(sub.geom)::integer AS subst_sum
-- 	FROM	orig_ego.ego_grid_districts_hull AS dis,
-- 		orig_osm.osm_deu_substations AS sub
-- 	WHERE  	dis.geom && sub.geom AND
-- 		ST_CONTAINS(dis.geom,sub.geom)
-- 	GROUP BY dis.subst_id
-- 	)AS t2
-- WHERE  	t1.subst_id = t2.subst_id;
-- 
-- -- "Create Index GIST (geom)"   (OK!) 2.500ms =0
-- CREATE INDEX	ego_grid_districts_hull_geom_idx
-- 	ON	orig_ego.ego_grid_districts_hull
-- 	USING	GIST (geom);

