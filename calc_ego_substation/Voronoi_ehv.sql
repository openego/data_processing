----------------------------------------------------------
-- VORONOI with  220 and 380 kV substations
----------------------------------------------------------


-- Add Dummy points 
INSERT INTO calc_ego_substation.ego_deu_substations_ehv (name, point, id, otg_id)
SELECT 'DUMMY', ST_TRANSFORM(geom,4326), subst_id, subst_id
FROM calc_ego_substation.substation_dummy;


-- Execute voronoi algorithm with 220 and 380 kV substations
DROP TABLE IF EXISTS calc_ego_substation.ego_deu_voronoi_ehv CASCADE;
WITH 
    -- Sample set of points to work with
    Sample AS (SELECT   ST_SetSRID(ST_Union(pts.point), 0) AS geom
		FROM	calc_ego_substation.ego_deu_substations_ehv AS pts
		/*WHERE pts.otg_id IS NOT NULL*/),  -- INPUT 1/2, this only includes substations with an otg_id
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
INTO calc_ego_substation.ego_deu_voronoi_ehv		  -- INPUT 2/2
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

-- "Create Index GIST (geom)"   (OK!) 11.000ms =0
CREATE INDEX	voronoi_ehv_geom_idx
	ON	calc_ego_substation.ego_deu_voronoi_ehv
	USING	GIST (geom);

-- "Set id and SRID"   (OK!) -> 100ms =0
ALTER TABLE calc_ego_substation.ego_deu_voronoi_ehv
	ADD COLUMN subst_id integer,
	ALTER COLUMN geom TYPE geometry(POLYGON,4326) USING ST_SETSRID(geom,4326);

UPDATE calc_ego_substation.ego_deu_voronoi_ehv a
	SET subst_id = b.id
	FROM calc_ego_substation.ego_deu_substations_ehv b
	WHERE ST_Intersects(a.geom, b.point) =TRUE; 

-- Delete Dummy-points from ehv_substations and ehv_voronoi 

DELETE FROM calc_ego_substation.ego_deu_voronoi_ehv 
	WHERE subst_id IN (SELECT id FROM calc_ego_substation.ego_deu_substations_ehv WHERE name = 'DUMMY');

DELETE FROM calc_ego_substation.ego_deu_substations_ehv WHERE name='DUMMY';

-- Set PK and FK 
ALTER TABLE calc_ego_substation.ego_deu_voronoi_ehv 
	ADD CONSTRAINT subst_fk FOREIGN KEY (subst_id) REFERENCES calc_ego_substation.ego_deu_substations_ehv (id),
	ADD PRIMARY KEY (subst_id);

ALTER TABLE calc_ego_substation.ego_deu_voronoi_ehv
  OWNER TO oeuser;

-- Clip voronoi with vg250

/* 
DROP TABLE IF EXISTS orig_ego.ego_vg250_voronoi_ehv;

SELECT g.id, ST_Intersection ( g.geom, ST_Transform(b.geom,4326)) as geom
INTO orig_ego.ego_vg250_voronoi_ehv;
FROM orig_ego.ego_deu_voronoi_ehv; AS g, gis.vg250_sta AS b WHERE gid=9;

ALTER TABLE orig_ego.ego_vg250_voronoi_ehv;
	ADD PRIMARY KEY (id);

CREATE INDEX	vg250_voronoi_ehv_geom_idx
	ON	orig_ego.ego_vg250_voronoi_ehv
	USING	GIST (geom); 
*/

