/*
voronoi with weatherpoints

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu, Ludee" 
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','calc_renpass_gis','parameter_solar_feedin','voronoi_weatherpoint.sql',' ');

-- Add Dummy points 
INSERT INTO calc_renpass_gis.parameter_solar_feedin (year, geom)
	SELECT 	'9999', ST_TRANSFORM(geom,4326)
	FROM 	model_draft.ego_grid_hvmv_substation_dummy;


-- Execute voronoi algorithm with weather points
DROP TABLE IF EXISTS model_draft.renpassgis_economic_weatherpoint_voronoi CASCADE;
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
INTO model_draft.renpassgis_economic_weatherpoint_voronoi		  -- INPUT 2/2
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

-- index GIST (geom)
CREATE INDEX	voronoi_weatherpoint_geom_idx
	ON	model_draft.renpassgis_economic_weatherpoint_voronoi USING GIST (geom);

-- set id and SRID
ALTER TABLE model_draft.renpassgis_economic_weatherpoint_voronoi
	ADD COLUMN id integer,
	ALTER COLUMN geom TYPE geometry(POLYGON,4326) USING ST_SETSRID(geom,4326);

UPDATE model_draft.renpassgis_economic_weatherpoint_voronoi a
	SET id = b.gid
	FROM calc_renpass_gis.parameter_solar_feedin b
	WHERE ST_Intersects(a.geom, b.geom) =TRUE; 

-- Delete Dummy-points
DELETE FROM model_draft.renpassgis_economic_weatherpoint_voronoi 
	WHERE id IN (SELECT gid FROM calc_renpass_gis.parameter_solar_feedin WHERE year = 9999);

DELETE FROM model_draft.renpassgis_economic_weatherpoint_voronoi 
	WHERE id IS NULL; 

DELETE FROM calc_renpass_gis.parameter_solar_feedin WHERE year=9999;

-- Set PK and FK 
ALTER TABLE model_draft.renpassgis_economic_weatherpoint_voronoi
	ADD PRIMARY KEY (id);

-- grant (oeuser)
ALTER TABLE model_draft.renpassgis_economic_weatherpoint_voronoi OWNER TO oeuser;

-- metadata
COMMENT ON TABLE  model_draft.renpassgis_economic_weatherpoint_voronoi IS
'{
"Name": "Voronoi weatherpoints",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["Voronoi cells calculated on the basis of weatherpoints from renpassGIS"],
"Column": [
                   {"Name": "geom",
                    "Description": "geometry",
                    "Unit": "" },
                   {"Name": "id",
                    "Description": "unique id",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','renpassgis_economic_weatherpoint_voronoi','voronoi_weatherpoint.sql',' ');
