-- Add Dummy points 
INSERT INTO calc_renpass_gis.parameter_solar_feedin (year, geom)
SELECT '9999', ST_TRANSFORM(geom,4326)
FROM calc_ego_substation.substation_dummy;


-- Execute voronoi algorithm with weather points
DROP TABLE IF EXISTS calc_renpass_gis.voronoi_weatherpoint;
WITH 
    -- Sample set of points to work with
    Sample AS (SELECT   ST_SetSRID(ST_Union(pts.geom), 0) AS geom
		FROM	calc_renpass_gis.parameter_solar_feedin AS pts),  -- INPUT 1/2
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
INTO calc_renpass_gis.voronoi_weatherpoint		  -- INPUT 2/2
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
CREATE INDEX	voronoi_weatherpoint_geom_idx
	ON	calc_renpass_gis.voronoi_weatherpoint
	USING	GIST (geom);

-- "Set id and SRID"   (OK!) -> 100ms =0
ALTER TABLE calc_renpass_gis.voronoi_weatherpoint
	ADD COLUMN id integer,
	ALTER COLUMN geom TYPE geometry(POLYGON,4326) USING ST_SETSRID(geom,4326);

UPDATE calc_renpass_gis.voronoi_weatherpoint a
	SET id = b.gid
	FROM calc_renpass_gis.parameter_solar_feedin b
	WHERE ST_Intersects(a.geom, b.geom) =TRUE; 

-- Delete Dummy-points

DELETE FROM calc_renpass_gis.voronoi_weatherpoint 
	WHERE id IN (SELECT gid FROM calc_renpass_gis.parameter_solar_feedin WHERE year = 9999);

DELETE FROM calc_renpass_gis.voronoi_weatherpoint 
	WHERE id IS NULL; 

DELETE FROM calc_renpass_gis.parameter_solar_feedin WHERE year=9999;

-- Set PK and FK 
ALTER TABLE calc_renpass_gis.voronoi_weatherpoint
	ADD PRIMARY KEY (id);

ALTER TABLE calc_renpass_gis.voronoi_weatherpoint
  OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'calc_renpass_gis' AS schema_name,
		'voronoi_weatherpoint' AS table_name,
		'voronoi_weatherpoint.sql' AS script_name,
		COUNT(id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_renpass_gis.voronoi_weatherpoint;

