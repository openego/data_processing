



---------- ---------- ---------- ---------- ---------- ----------
-- "VORONOI"   2016-04-18 11:00   1s
---------- ---------- ---------- ---------- ---------- ----------





---------- ---------- ----------
-- VORONOI ON Substations IN vg250
---------- ---------- ----------

-- "VORONOI"   (OK!) -> 954.000ms =3.689
DROP TABLE IF EXISTS orig_ego.ego_deu_usw_voronoi;  -- NAME 1/2
WITH 
    -- Sample set of points to work with
    Sample AS (SELECT   ST_SetSRID(ST_Union(pts.geom), 0) AS geom
		FROM	orig_osm.osm_deu_substations AS pts),  -- INPUT
    -- Build edges and circumscribe points to generate a centroid
    Edges AS (
    SELECT id,
        UNNEST(ARRAY['e1','e2','e3']) EdgeName,
        UNNEST(ARRAY[
            ST_MakeLine(p1,p2) ,
            ST_MakeLine(p2,p3) ,
            ST_MakeLine(p3,p1)]) Edge,
        ST_Centroid(ST_ConvexHull(ST_Union(-- Done this way due to issues I had with LineToCurve
            ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p1,p2),ST_MakeLine(p2,p3)))),'LINE','CIRCULAR'),15),
            ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p2,p3),ST_MakeLine(p3,p1)))),'LINE','CIRCULAR'),15)
        ))) ct      
    FROM    (
        -- Decompose to points
        SELECT id,
            ST_PointN(g,1) p1,
            ST_PointN(g,2) p2,
            ST_PointN(g,3) p3
        FROM    (
            SELECT (gd).Path id, ST_ExteriorRing((gd).geom) g -- ID andmake triangle a linestring
            FROM (SELECT (ST_Dump(ST_DelaunayTriangles(geom))) gd FROM Sample) a -- Get Delaunay Triangles
            )b
        ) c
    )
SELECT ST_SetSRID((ST_Dump(ST_Polygonize(ST_Node(ST_LineMerge(ST_Union(v, (SELECT ST_ExteriorRing(ST_ConvexHull(ST_Union(ST_Union(ST_Buffer(edge,20),ct)))) FROM Edges))))))).geom, 2180) geom
INTO orig_ego.ego_deu_usw_voronoi		  -- NAME 2/2
FROM (
    SELECT  -- Create voronoi edges and reduce to a multilinestring
        ST_LineMerge(ST_Union(ST_MakeLine(
        x.ct,
        CASE 
        WHEN y.id IS NULL THEN
            CASE WHEN ST_Within(
                x.ct,
                (SELECT ST_ConvexHull(geom) FROM sample)) THEN -- Don't draw lines back towards the original set
                -- Project line out twice the distance from convex hull
                ST_MakePoint(ST_X(x.ct) + ((ST_X(ST_Centroid(x.edge)) - ST_X(x.ct)) * 200),ST_Y(x.ct) + ((ST_Y(ST_Centroid(x.edge)) - ST_Y(x.ct)) * 200))
            END
        ELSE 
            y.ct
        END
        ))) v
    FROM    Edges x 
        LEFT OUTER JOIN -- Self Join based on edges
        Edges y ON x.id <> y.id AND ST_Equals(x.edge,y.edge)
    ) z;

-- "Set PK"   (OK!) -> 100ms =0
ALTER TABLE orig_ego.ego_deu_usw_voronoi
	ADD COLUMN id serial,
	ADD PRIMARY KEY (id),
	ALTER COLUMN geom TYPE geometry(POLYGON,3035) USING ST_SETSRID(geom,3035);

-- "Create Index GIST (geom)"   (OK!) 11.000ms =0
CREATE INDEX	ego_deu_usw_voronoi_geom_idx
	ON	orig_ego.ego_deu_usw_voronoi
	USING	GIST (geom);






---------- ---------- ----------
-- VORONOI USW DEU GEM2
---------- ---------- ----------

-- "VORONOI"   (OK!) -> 84.000ms =2.010
DROP TABLE IF EXISTS orig_ego.ego_deu_usw_voronoi_gem2;		-- TABLE 1/2
WITH 
    -- Sample set of points to work with
    Sample AS (SELECT   ST_SetSRID(ST_Union(pts.geom), 0) AS geom
		FROM	orig_ego.ego_deu_mv_substations_2_mview AS pts),  -- INPUT 1
    -- Build edges and circumscribe points to generate a centroid
    Edges AS (
    SELECT id,
        UNNEST(ARRAY['e1','e2','e3']) EdgeName,
        UNNEST(ARRAY[
            ST_MakeLine(p1,p2) ,
            ST_MakeLine(p2,p3) ,
            ST_MakeLine(p3,p1)]) Edge,
        ST_Centroid(ST_ConvexHull(ST_Union(-- Done this way due to issues I had with LineToCurve
            ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p1,p2),ST_MakeLine(p2,p3)))),'LINE','CIRCULAR'),15),
            ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p2,p3),ST_MakeLine(p3,p1)))),'LINE','CIRCULAR'),15)
        ))) ct      
    FROM    (
        -- Decompose to points
        SELECT id,
            ST_PointN(g,1) p1,
            ST_PointN(g,2) p2,
            ST_PointN(g,3) p3
        FROM    (
            SELECT (gd).Path id, ST_ExteriorRing((gd).geom) g -- ID andmake triangle a linestring
            FROM (SELECT (ST_Dump(ST_DelaunayTriangles(geom))) gd FROM Sample) a -- Get Delaunay Triangles
            )b
        ) c
    )
SELECT ST_SetSRID((ST_Dump(ST_Polygonize(ST_Node(ST_LineMerge(ST_Union(v, (SELECT ST_ExteriorRing(ST_ConvexHull(ST_Union(ST_Union(ST_Buffer(edge,20),ct)))) FROM Edges))))))).geom, 2180) geom
INTO orig_ego.ego_deu_usw_voronoi_gem2		  -- TABLE 2/2
FROM (
    SELECT  -- Create voronoi edges and reduce to a multilinestring
        ST_LineMerge(ST_Union(ST_MakeLine(
        x.ct,
        CASE 
        WHEN y.id IS NULL THEN
            CASE WHEN ST_Within(
                x.ct,
                (SELECT ST_ConvexHull(geom) FROM sample)) THEN -- Don't draw lines back towards the original set
                -- Project line out twice the distance from convex hull
                ST_MakePoint(ST_X(x.ct) + ((ST_X(ST_Centroid(x.edge)) - ST_X(x.ct)) * 200),ST_Y(x.ct) + ((ST_Y(ST_Centroid(x.edge)) - ST_Y(x.ct)) * 200))
            END
        ELSE 
            y.ct
        END
        ))) v
    FROM    Edges x 
        LEFT OUTER JOIN -- Self Join based on edges
        Edges y ON x.id <> y.id AND ST_Equals(x.edge,y.edge)
    ) z;

-- "Set PK"   (OK!) -> 100ms =0
ALTER TABLE orig_ego.ego_deu_usw_voronoi_gem2
	ADD COLUMN id serial,
	ADD COLUMN usw_sum integer,
	ADD PRIMARY KEY (id),
	ALTER COLUMN geom TYPE geometry(POLYGON,3035) USING ST_SETSRID(geom,3035);

-- "Create Index GIST (geom)"   (OK!) 11.000ms =0
CREATE INDEX	ego_deu_usw_voronoi_gem2_geom_idx
	ON	orig_ego.ego_deu_usw_voronoi_gem2
	USING	GIST (geom);

-- "usw count"   (OK!) -> 1.000ms =2.010
UPDATE 	orig_ego.ego_deu_usw_voronoi_gem2 AS t1
SET  	usw_sum = t2.usw_sum
FROM	(SELECT	gem.id AS id,
		COUNT(usw.geom)::integer AS usw_sum
	FROM	orig_ego.ego_deu_usw_voronoi_gem2 AS gem,
		orig_ego.ego_deu_mv_substations_2_mview AS usw
	WHERE  	ST_CONTAINS(gem.geom,ST_TRANSFORM(usw.geom,3035))
	GROUP BY gem.id
	)AS t2
WHERE  	t1.id = t2.id;




---------- ---------- ----------
-- Nur innerhalb der gleichen Gemeinde!
---------- ---------- ----------

-- "USW"   (OK!) -> 100ms =2027
DROP TABLE IF EXISTS	orig_ego.ego_deu_mv_substations_2;
CREATE TABLE 		orig_ego.ego_deu_mv_substations_2 AS
	SELECT	usw.subst_id ::integer AS subst_id,
		usw.geom ::geometry(Point,3035) AS geom
	FROM	orig_ego.ego_deu_mv_substations_2_mview AS usw;

-- "Set PK"   (OK!) -> 100ms =0
ALTER TABLE orig_ego.ego_deu_mv_substations_2
	ADD COLUMN ags_0 varchar(12),
	ADD PRIMARY KEY (subst_id);

-- "Create Index GIST (geom)"   (OK!) 11.000ms =0
CREATE INDEX	ego_deu_mv_substations_2_geom_idx
	ON	orig_ego.ego_deu_mv_substations_2
	USING	GIST (geom);

-- "Calculate Gemeindeschlüssel"   (OK!) -> 50.000ms =2027
UPDATE 	orig_ego.ego_deu_mv_substations_2 AS t1
SET  	ags_0 = t2.ags_0
FROM    (
	SELECT	usw.subst_id AS subst_id,
		vg.ags_0 AS ags_0
	FROM	orig_ego.ego_deu_mv_substations_2 AS usw,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && usw.geom AND
		ST_CONTAINS(vg.geom,usw.geom)
	) AS t2
WHERE  	t1.subst_id = t2.subst_id;

---------- ---------- ----------




---------- ---------- ----------

-- "Next Neighbor"   (OK!) 1.000ms =4.924
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_usw_voronoi_gem2_0_nn_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_usw_voronoi_gem2_0_nn_mview AS 
SELECT DISTINCT ON (g1.id)
	g1.id As gref_id,
	g1.ags_0 As gref_ags_0,
	g1.geom AS gref_geom,
	g2.subst_id As gnn_id, 
	g2.geom AS gnn_geom
FROM 	orig_ego.ego_deu_usw_voi_cut As g1, 
	orig_ego.ego_deu_mv_substations_2 As g2   
WHERE 	g1.id <> g2.subst_id
	AND ST_DWithin(g1.geom, g2.geom, 100000)
	AND g1.ags_0 = g2.ags_0
ORDER BY 	g1.id, 
		ST_Distance(g1.geom,g2.geom);



-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	orig_ego.ego_deu_usw_voronoi_gem2_0_nn_line_mview_id CASCADE;
CREATE SEQUENCE 		orig_ego.ego_deu_usw_voronoi_gem2_0_nn_line_mview_id;

-- "connect points"   (OK!) 1.000ms =957
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_usw_voronoi_gem2_0_nn_line_mview;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_usw_voronoi_gem2_0_nn_line_mview AS 
	SELECT 	nextval('orig_ego.ego_deu_usw_voronoi_gem2_0_nn_line_mview_id') AS id,
		nn.gref_id,
		nn.gnn_id,
		(ST_Dump(ST_POINTONSURFACE(nn.gref_geom))).geom ::geometry(Point,3035) AS geom_centre,
		ST_ShortestLine(	(ST_Dump(ST_POINTONSURFACE(nn.gref_geom))).geom ::geometry(Point,3035),
					nn.gnn_geom ::geometry(Point,3035)
		) ::geometry(LineString,3035) AS geom
	FROM	orig_ego.ego_deu_usw_voronoi_gem2_0_nn_mview AS nn;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	ego_deu_usw_voronoi_gem2_0_nn_line_mview_id_idx
		ON	orig_ego.ego_deu_usw_voronoi_gem2_0_nn_line_mview (id);

-- "Create Index GIST (geom_centre)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_usw_voronoi_gem2_0_nn_line_mview_geom_centre_idx
	ON	orig_ego.ego_deu_usw_voronoi_gem2_0_nn_line_mview
	USING	GIST (geom_centre);

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_usw_voronoi_gem2_0_nn_line_mview_geom_idx
	ON	orig_ego.ego_deu_usw_voronoi_gem2_0_nn_line_mview
	USING	GIST (geom);

---------- ---------- ----------

DROP TABLE IF EXISTS	orig_ego.ego_deu_usw_voronoi_gem2_0_nn CASCADE;
CREATE TABLE		orig_ego.ego_deu_usw_voronoi_gem2_0_nn AS 
	SELECT	nn.gnn_id As id, 
		ST_MAKEVALID(ST_MULTI(ST_UNION(nn.gref_geom))) ::geometry(MultiPolygon,3035) AS geom
	FROM	orig_ego.ego_deu_usw_voronoi_gem2_0_nn_mview AS nn
	GROUP BY nn.gnn_id;

-- "Set PK"   (OK!) -> 100ms =0
ALTER TABLE orig_ego.ego_deu_usw_voronoi_gem2_0_nn
	ADD COLUMN usw_sum integer,
	ADD PRIMARY KEY (id);

-- "Create Index GIST (geom)"   (OK!) 11.000ms =0
CREATE INDEX	ego_deu_usw_voronoi_gem2_0_nn_geom_idx
	ON	orig_ego.ego_deu_usw_voronoi_gem2_0_nn
	USING	GIST (geom);

-- "usw count"   (OK!) -> 1.000ms =2.010
UPDATE 	orig_ego.ego_deu_usw_voronoi_gem2_0_nn AS t1
SET  	usw_sum = t2.usw_sum
FROM	(SELECT	gem.id AS id,
		COUNT(usw.geom)::integer AS usw_sum
	FROM	orig_ego.ego_deu_usw_voronoi_gem2_0_nn AS gem,
		orig_ego.ego_deu_mv_substations_mview AS usw
	WHERE  	ST_CONTAINS(gem.geom,ST_TRANSFORM(usw.geom,3035))
	GROUP BY gem.id
	)AS t2
WHERE  	t1.id = t2.id;



---------- ---------- ----------

-- "voi"   (OK!) 100ms =3.693
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_usw_voronoi_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.ego_deu_usw_voronoi_mview AS
	SELECT	poly.id ::integer AS id,
		(ST_DUMP(ST_TRANSFORM(poly.geom,3035))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_usw_voronoi AS poly;

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_usw_voronoi_mview_geom_idx
	ON	orig_ego.ego_deu_usw_voronoi_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_usw_voronoi_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_usw_voronoi_mview OWNER TO oeuser;

---------- ---------- ----------	

-- "Validate (geom)"   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	orig_ego.ego_deu_usw_voronoi_mview_error_geom_view CASCADE;
CREATE VIEW		orig_ego.ego_deu_usw_voronoi_mview_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	orig_ego.ego_deu_usw_voronoi_mview AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_usw_voronoi_mview_error_geom_view TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_usw_voronoi_mview_error_geom_view OWNER TO oeuser;

-- "Drop empty view"   (OK!) -> 100ms =1
SELECT f_drop_view('{ego_deu_usw_voronoi_mview_error_geom_view}', 'orig_ego');

---------- ---------- ----------

-- -- "Cutter"   (OK!) 100ms =3.716
-- DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_mv_gridcell_full_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_ego.ego_deu_mv_gridcell_full_mview AS
-- 	SELECT	poly.id AS id,
-- 		(ST_DUMP(ST_TRANSFORM(poly.geom,3035))).geom ::geometry(Polygon,3035) AS geom
-- 	FROM	orig_ego.ego_deu_mv_gridcell_full AS poly;
-- 
-- -- "Create Index GIST (geom)"   (OK!) -> 100ms =0
-- CREATE INDEX  	ego_deu_mv_gridcell_full_mview_geom_idx
-- 	ON	orig_ego.ego_deu_mv_gridcell_full_mview
-- 	USING	GIST (geom);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	orig_ego.ego_deu_mv_gridcell_full_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_mv_gridcell_full_mview OWNER TO oeuser;
-- 
-- -- "Validate (geom)"   (OK!) -> 100ms =0
-- DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_mv_gridcell_full_mview_error_geom_mview CASCADE;
-- CREATE MATERIALIZED VIEW		orig_ego.ego_deu_mv_gridcell_full_mview_error_geom_mview AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		location(ST_IsValidDetail(test.geom)) ::geometry(Point,3035) AS error_location,
-- 		ST_TRANSFORM(test.geom,3035) ::geometry(Polygon,3035) AS geom
-- 	FROM	(
-- 		SELECT	source.id AS id,
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	orig_ego.ego_deu_mv_gridcell_full_mview AS source
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_ego.ego_deu_mv_gridcell_full_mview_error_geom_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_mv_gridcell_full_mview_error_geom_mview OWNER TO oeuser;



-- ---------- ---------- ---------- ---------- ---------- ----------
-- -- "Cutting SPF"   2016-04-04 17:08   1s
-- ---------- ---------- ---------- ---------- ---------- ----------
-- 
-- -- "Create Table"   (OK!) 100ms =0
-- DROP TABLE IF EXISTS	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf;
-- CREATE TABLE		orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf (
-- 		id SERIAL,
-- 		geom geometry(Polygon,3035),
-- CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_cut_spf_pkey PRIMARY KEY (id));
-- 
-- -- "Insert Cut"   (OK!) 500ms =1038
-- INSERT INTO	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf (geom)
-- 	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom,cut.geom))).geom ::geometry(Polygon,3035) AS geom
-- 	FROM	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_spf AS poly,
-- 		orig_ego.ego_deu_mv_gridcell_full_mview AS cut
-- 	WHERE	poly.geom && cut.geom;
-- 
-- -- "Create Index GIST (geom)"   (OK!) 2.000ms =0
-- CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_cut_spf_geom_idx
-- 	ON	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf
-- 	USING	GIST (geom);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_spf OWNER TO oeuser;


---------- ---------- ---------- ---------- ---------- ----------
-- "Cutting DEU Voronoi"
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut;
CREATE TABLE	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut (
		id SERIAL,
		geom geometry(Polygon,3035),
		geom_buffer geometry(Polygon,3035),
CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_cut_pkey PRIMARY KEY (id));
	
-- "Insert Cut"   (OK!) 185.000ms =224.365
INSERT INTO	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut (geom, geom_buffer)
	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom,cut.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_loads_collect_buffer100_unbuffer AS poly,
		orig_ego.ego_deu_mv_gridcell_full_mview AS cut
	WHERE	poly.geom && cut.geom;

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_cut_geom_idx
	ON	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut OWNER TO oeuser;



---------- ---------- ---------- ---------- ---------- ----------
-- "Cutting DEU Gemeinde"
---------- ---------- ---------- ---------- ---------- ----------

-- "Cutter"   (OK!) 3.000ms =12.528
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.vg250_6_gem_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_ego.vg250_6_gem_mview AS
	SELECT	poly.gid AS id,
		(ST_DUMP(ST_TRANSFORM(poly.geom,3035))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_vg250.vg250_6_gem AS poly;

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	vg250_6_gem_mview_geom_idx
	ON	orig_ego.vg250_6_gem_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.vg250_6_gem_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.vg250_6_gem_mview OWNER TO oeuser;


---------- ---------- ----------


-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem;
CREATE TABLE		orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem (
		id SERIAL,
		geom geometry(Polygon,3035)
CONSTRAINT	ego_deu_loads_collect_buffer100_unbuffer_cut_gem_pkey PRIMARY KEY (id));

-- "Insert Cut"   (OK!) 330.000ms =210.298
INSERT INTO	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem (geom)
	SELECT	(ST_DUMP(ST_INTERSECTION(poly.geom,cut.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_ego.ego_deu_loads_collect_buffer100_unbuffer AS poly,
		orig_ego.vg250_6_gem_mview AS cut
	WHERE	poly.geom && cut.geom;

-- "Create Index GIST (geom)"   (OK!) 2.500ms =0
CREATE INDEX	ego_deu_loads_collect_buffer100_unbuffer_cut_gem_geom_idx
	ON	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_collect_buffer100_unbuffer_cut_gem OWNER TO oeuser;