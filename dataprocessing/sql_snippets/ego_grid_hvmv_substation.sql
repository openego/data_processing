
-- Set id as subst_id
ALTER TABLE	model_draft.ego_grid_hvmv_substation
	DROP COLUMN IF EXISTS 	ags_0 CASCADE,
	ADD COLUMN 		ags_0 text,
	DROP COLUMN IF EXISTS 	geom CASCADE,
	ADD COLUMN 		geom geometry(Point,3035);

UPDATE 	model_draft.ego_grid_hvmv_substation t1
SET  	geom = ST_TRANSFORM(t1.point,3035)
FROM	model_draft.ego_grid_hvmv_substation t2
WHERE  	t1.subst_id = t2.subst_id;

-- "Create Index GIST (geom)"   (OK!) 11.000ms =0
CREATE INDEX	ego_grid_hvmv_substation_idx
	ON	model_draft.ego_grid_hvmv_substation
	USING	GIST (geom);

-- "Calculate Gemeindeschlüssel"   (OK!) -> 50.000ms =181.157
UPDATE 	model_draft.ego_grid_hvmv_substation AS t1
SET  	ags_0 = t2.ags_0
FROM    (
	SELECT	sub.subst_id AS subst_id,
		vg.ags_0 AS ags_0
	FROM	model_draft.ego_grid_hvmv_substation AS sub,
		orig_vg250.vg250_6_gem_clean AS vg
	WHERE  	vg.geom && sub.geom AND
		ST_CONTAINS(vg.geom,sub.geom)
	) AS t2
WHERE  	t1.subst_id = t2.subst_id;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_grid_hvmv_substation' AS table_name,
		'process_eGo_substation.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_grid_hvmv_substation;

----------------------------------------------------------
-- Create Voronoi Polygons from 110kV Substations
----------------------------------------------------------

DROP TABLE IF EXISTS 	model_draft.ego_grid_substation_dummy CASCADE;
CREATE TABLE		model_draft.ego_grid_substation_dummy AS
	SELECT	dummy.subst_id ::integer,
		dummy.name ::text AS subst_name,
		ST_TRANSFORM(dummy.geom,3035) ::geometry(Point,3035) AS geom
	FROM	model_draft.ego_grid_substation_dummy AS dummy
	ORDER BY dummy.subst_id; -- TODO: Create from Points from Script

ALTER TABLE model_draft.ego_grid_substation_dummy
	ADD PRIMARY KEY (subst_id);

-- "Create Index GIST (geom)"   (OK!) 11.000ms =0
CREATE INDEX	substations_dummy_geom_idx
	ON	model_draft.ego_grid_substation_dummy
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_grid_substation_dummy TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_substation_dummy OWNER TO oeuser;

---------------------

/* -- Add Dummy points to substation (18 Points)
INSERT INTO model_draft.ego_grid_hvmv_substation (subst_id,subst_name,geom)
SELECT	dummy.subst_id,
	dummy.subst_name,
	ST_TRANSFORM(dummy.geom,3035)
FROM 	model_draft.ego_grid_substation_dummy AS dummy; */

---------------------

-- Execute voronoi algorithm with 110 kV substations   (OK!) -> 227.000ms =3.628
DROP TABLE IF EXISTS model_draft.ego_grid_hvmv_substation_voronoi CASCADE; -- Name 1/2
WITH
    -- Sample set of points to work with
    Sample AS (SELECT   ST_SetSRID(ST_Union(ST_Collect(pts.geom,dum.geom)), 0) AS geom
		FROM	model_draft.ego_grid_hvmv_substation AS pts,
			model_draft.ego_grid_substation_dummy AS dum),  -- INPUT POINTS
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
INTO model_draft.ego_grid_hvmv_substation_voronoi		  -- Name 2/2
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

---------------------

-- "Set PK"   (OK!) -> 100ms =0
ALTER TABLE model_draft.ego_grid_hvmv_substation_voronoi
	ADD COLUMN id serial,
	ADD COLUMN subst_id integer,
	ADD COLUMN subst_sum integer,
	ADD PRIMARY KEY (id),
	ALTER COLUMN geom TYPE geometry(POLYGON,3035) USING ST_SETSRID(geom,3035);

-- "Create Index GIST (geom)"   (OK!) 11.000ms =0
CREATE INDEX	ego_deu_substations_voronoi_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_grid_hvmv_substation_voronoi TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_hvmv_substation_voronoi OWNER TO oeuser;

-- Delete Dummy-points from substations (18 Points)
DELETE FROM model_draft.ego_grid_hvmv_substation WHERE subst_name='DUMMY';


-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_grid_hvmv_substation' AS table_name,
		'process_eGo_substation.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_grid_hvmv_substation_voronoi;
