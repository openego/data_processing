--(50 sec)--

-- Add Dummy points to substations (18 Points)
INSERT INTO calc_ego_substation.ego_deu_onts_ta (id,geom)
SELECT	dummy.subst_id,
	ST_TRANSFORM(dummy.geom,3035)
FROM 	calc_ego_substation.substation_dummy AS dummy;

---------------------



-- Execute voronoi algorithm 
DROP TABLE IF EXISTS calc_ego_grid_district.ego_deu_LV_grid_districts_ta_voronoi CASCADE;
WITH 
    -- Sample set of points to work with
    Sample AS (SELECT   ST_SetSRID(ST_Union(pts.geom), 0) AS geom
		FROM	calc_ego_substation.ego_deu_onts_ta AS pts),  -- INPUT 1/2
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
INTO calc_ego_grid_district.ego_deu_LV_grid_districts_ta_voronoi		  -- INPUT 2/2
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

-- "Set PK"   
ALTER TABLE calc_ego_grid_district.ego_deu_LV_grid_districts_ta_voronoi
	ADD COLUMN id serial,
	ADD PRIMARY KEY (id),
	ALTER COLUMN geom TYPE geometry(POLYGON,3035) USING ST_SETSRID(geom,3035);
	

-- "Create Index GIST (geom)"  
CREATE INDEX	ego_deu_LV_grid_districts_ta_voronoi_geom_idx
	ON	calc_ego_grid_district.ego_deu_LV_grid_districts_ta_voronoi
	USING	GIST (geom);

-- Grant oeuser   
GRANT ALL ON TABLE 	calc_ego_grid_district.ego_deu_LV_grid_districts_ta_voronoi TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_district.ego_deu_LV_grid_districts_ta_voronoi OWNER TO oeuser;

-- Delete Dummy points from substations 
DELETE FROM calc_ego_substation.ego_deu_onts_ta WHERE id >=9000;

---------- ---------- ----------
-- CUT
---------- ---------- ----------


-- Cutting 
DROP TABLE IF EXISTS	calc_ego_grid_district.ego_deu_LV_cut_ta CASCADE;
CREATE TABLE		calc_ego_grid_district.ego_deu_LV_cut_ta AS
	SELECT	(ST_DUMP(ST_INTERSECTION(mun.geom,voi.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	calc_ego_loads.ego_deu_load_area_ta AS mun,
		calc_ego_grid_district.ego_deu_LV_grid_districts_ta_voronoi AS voi
	WHERE	mun.geom && voi.geom;

-- Add ID
ALTER TABLE calc_ego_grid_district.ego_deu_LV_cut_ta
ADD COLUMN id serial,
ADD PRIMARY KEY (id);

-- Count substations per grid district
ALTER TABLE calc_ego_grid_district.ego_deu_LV_cut_ta
ADD COLUMN ont_count integer;

UPDATE 	calc_ego_grid_district.ego_deu_LV_cut_ta AS t1
SET ont_count = 0;

UPDATE 	calc_ego_grid_district.ego_deu_LV_cut_ta AS t1
SET  	ont_count = t2.count
FROM (SELECT COUNT (onts.geom) AS count,dist.id AS id
	FROM calc_ego_substation.ego_deu_onts_ta AS onts, calc_ego_grid_district.ego_deu_LV_cut_ta AS dist
	WHERE ST_CONTAINS (dist.geom,onts.geom)
	GROUP BY dist.id
      ) AS t2
WHERE t1.id = t2.id;

-- Add ont_ID
ALTER TABLE calc_ego_grid_district.ego_deu_LV_cut_ta
ADD COLUMN ont_id integer;

UPDATE 	calc_ego_grid_district.ego_deu_LV_cut_ta AS t1
SET  	ont_id = t2.id
FROM calc_ego_substation.ego_deu_onts_ta AS t2
WHERE ST_CONTAINS(t1.geom,t2.geom);

-- Add merge info
ALTER TABLE calc_ego_grid_district.ego_deu_LV_cut_ta
ADD COLUMN merge_id integer;

UPDATE 	calc_ego_grid_district.ego_deu_LV_cut_ta AS t1
SET merge_id = t2.merge_id
FROM (SELECT t1.id AS district_id,t3.id AS merge_id, MIN(ST_DISTANCE(ST_CENTROID(t1.geom),t3.geom))
	FROM calc_ego_grid_district.ego_deu_LV_cut_ta AS t1,
	        calc_ego_grid_district.ego_deu_LV_cut_ta AS t2,	
	        calc_ego_substation.ego_deu_onts_ta AS t3
	WHERE ST_CONTAINS(t2.geom,t3.geom)
		AND t1.ont_count = 0
		AND ST_TOUCHES (t1.geom,t2.geom)
		-- make sure that only geometries which have common borders are used
		AND ST_GEOMETRYTYPE(ST_INTERSECTION(t1.geom,t2.geom)) = 'ST_LineString'
	GROUP BY t1.id,t3.id
      ) AS t2
WHERE t1.id = t2.district_id;

UPDATE 	calc_ego_grid_district.ego_deu_LV_cut_ta AS t1
SET ont_id = merge_id
WHERE ont_count = 0;

-- Merge areas with same ONT_ID

DROP TABLE IF EXISTS	calc_ego_grid_district.ego_deu_LV_grid_district_ta_withoutpop;
CREATE TABLE		calc_ego_grid_district.ego_deu_LV_grid_district_ta_withoutpop AS

SELECT ST_UNION(cut.geom)::geometry(Polygon,3035) AS geom, cut.ont_id AS id, onts.load_area_id 
FROM calc_ego_grid_district.ego_deu_LV_cut_ta AS cut
	INNER JOIN calc_ego_substation.ego_deu_onts_ta AS onts
ON cut.ont_id = onts.id
WHERE ont_id >= 0
GROUP BY cut.ont_id, onts.load_area_id;

--INSERT INTO calc_ego_grid_district.ego_deu_LV_grid_district_ta_withoutpop (geom)
--SELECT	geom
--FROM 	calc_ego_grid_district.ego_deu_LV_cut_ta
--WHERE   ont_id IS NULL;

-- Add PK
ALTER TABLE calc_ego_grid_district.ego_deu_LV_grid_district_ta_withoutpop
ADD PRIMARY KEY (id);

-- Add population

DROP TABLE IF EXISTS	calc_ego_grid_district.ego_deu_LV_grid_district_ta;
CREATE TABLE		calc_ego_grid_district.ego_deu_LV_grid_district_ta AS

WITH pop AS (
	SELECT SUM(pts.population) AS population, grid_district.id AS grid_district_id
	FROM 	orig_destatis.zensus_population_per_ha AS pts, 
		calc_ego_grid_district.ego_deu_lv_grid_district_ta_withoutpop AS grid_district
	WHERE ST_CONTAINS(grid_district.geom,pts.geom)
		AND pts.population > 0
	GROUP BY grid_district.id
) 

SELECT t1.*,pop.population 
FROM calc_ego_grid_district.ego_deu_lv_grid_district_ta_withoutpop AS t1 INNER JOIN pop
	ON t1.id = pop.grid_district_id;

-- Add PK
ALTER TABLE calc_ego_grid_district.ego_deu_LV_grid_district_ta
ADD PRIMARY KEY (id);

-- Grant oeuser   
GRANT ALL ON TABLE 	calc_ego_grid_district.ego_deu_LV_grid_district_ta TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_grid_district.ego_deu_LV_grid_district_ta OWNER TO oeuser;

-- Delete unused table
DROP TABLE IF EXISTS	calc_ego_grid_district.ego_deu_LV_grid_district_ta_withoutpop;