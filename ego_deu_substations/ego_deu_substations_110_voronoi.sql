----------------------------------------------------------
-- VORONOI with  110 kV substations
----------------------------------------------------------

-- Add Dummy points (18 Points)
INSERT INTO calc_ego_grid_districts.substations_110 (subst_id,subst_name,geom)
SELECT	dummy.subst_id AS subst_id,
	dummy.name AS subst_name,
	ST_TRANSFORM(dummy.geom,3035)
FROM 	calc_gridcells_znes.substations_dummy AS dummy;

-- Execute voronoi algorithm with 110 kV substations
DROP TABLE IF EXISTS calc_ego_grid_districts.substations_110_voronoi;
WITH 
    -- Sample set of points to work with
    Sample AS (SELECT   ST_SetSRID(ST_Union(pts.geom), 0) AS geom
		FROM	calc_ego_grid_districts.substations_110 AS pts),  -- INPUT 1/2
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
INTO calc_ego_grid_districts.substations_110_voronoi		  -- INPUT 2/2
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
ALTER TABLE calc_ego_grid_districts.substations_110_voronoi
	ADD COLUMN id serial,
	ADD COLUMN subst_id integer,
	ADD COLUMN subst_sum integer,
	ADD PRIMARY KEY (id),
	ALTER COLUMN geom TYPE geometry(POLYGON,3035) USING ST_SETSRID(geom,3035);

-- "Create Index GIST (geom)"   (OK!) 11.000ms =0
CREATE INDEX	substations_110_voronoi_geom_idx
	ON	calc_ego_grid_districts.substations_110_voronoi
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_grid_districts.substations_110_voronoi TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_districts.substations_110_voronoi OWNER TO oeuser;


-- Delete Dummy-points from 110 kV substations (18 Points)
DELETE FROM calc_ego_grid_districts.substations_110 WHERE subst_name='DUMMY';


-- Clip voronoi with vg250

/* 
DROP TABLE IF EXISTS calc_ego_grid_districts.ego_vg250_voronoi_110kv;

SELECT g.id, ST_Intersection ( g.geom, ST_Transform(b.geom,4326)) as geom
INTO calc_ego_grid_districts.ego_vg250_voronoi_110kv;
FROM calc_ego_grid_districts.ego_deu_voronoi_110kv; AS g, gis.vg250_sta AS b WHERE gid=9;

ALTER TABLE calc_ego_grid_districts.ego_vg250_voronoi_110kv;
	ADD PRIMARY KEY (id);

CREATE INDEX	vg250_voronoi_110kV_geom_idx
	ON	calc_ego_grid_districts.ego_vg250_voronoi_110kv
	USING	GIST (geom); 
*/

