----------------------------------------------------------
-- VORONOI with  220 kV substations
----------------------------------------------------------

 
/*
-- Filter substations with voltage of 220 kV into new table

CREATE TABLE orig_osm.osm_deu_substations_220kv AS
SELECT * FROM orig_osm.osm_deu_substations_hoes
WHERE voltage LIKE '%220000%';

ALTER TABLE orig_osm.osm_deu_substations_220kv
ADD PRIMARY KEY (id); 
*/


-- Add Dummy points 
INSERT INTO orig_osm.osm_deu_substations_220kv (name, geom, id)
SELECT name, geom, subst_id
FROM calc_gridcells_znes.substations_dummy;


-- Execute voronoi algorithm with 220 kV substations
DROP TABLE IF EXISTS orig_ego.ego_deu_voronoi_220kv;
WITH 
    -- Sample set of points to work with
    Sample AS (SELECT   ST_SetSRID(ST_Union(pts.geom), 0) AS geom
		FROM	orig_osm.osm_deu_substations_220kv AS pts),  -- INPUT 1/2
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
INTO orig_ego.ego_deu_voronoi_220kv;		  -- INPUT 2/2
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
ALTER TABLE orig_ego.ego_deu_voronoi_220kv
	ADD COLUMN id serial,
	ADD PRIMARY KEY (id),
	ALTER COLUMN geom TYPE geometry(POLYGON,4326) USING ST_SETSRID(geom,4326);

-- "Create Index GIST (geom)"   (OK!) 11.000ms =0
CREATE INDEX	voronoi_220kv_geom_idx
	ON	orig_ego.ego_deu_voronoi_220kv
	USING	GIST (geom);


-- Delete Dummy-points from 220 kV substations 

DELETE FROM orig_osm.osm_deu_substations_220kv WHERE name='DUMMY';

-- Clip voronoi with vg250

/* 
DROP TABLE IF EXISTS voronoi.deu_voronoi_220kV;

SELECT g.id, ST_Intersection ( g.geom, ST_Transform(b.geom,4326)) as geom
INTO orig_ego.ego_vg250_voronoi_220kv;
FROM orig_ego.ego_deu_voronoi_220kv; AS g, gis.vg250_sta AS b WHERE gid=9;

ALTER TABLE orig_ego.ego_vg250_voronoi_220kv;
	ADD PRIMARY KEY (id);

CREATE INDEX	vg250_voronoi_220kV_geom_idx
	ON	orig_ego.ego_vg250_voronoi_220kv
	USING	GIST (geom); 
*/

