/*
mvlv substation voronoi
voronoi polygons with eucldean distance / manhattan distance would be better but not available in sql

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "jong42, Ludee"
*/


-- add Dummy points to substations (18 Points)
ALTER TABLE model_draft.ego_grid_mvlv_substation
DROP COLUMN IF EXISTS is_dummy;

ALTER TABLE model_draft.ego_grid_mvlv_substation
ADD COLUMN is_dummy boolean;

INSERT INTO model_draft.ego_grid_mvlv_substation (mvlv_subst_id, geom, is_dummy)
SELECT	subst_id+800000,
	ST_TRANSFORM(geom,3035),
	TRUE
FROM model_draft.ego_grid_hvmv_substation_dummy;



-- execute voronoi with loop
DROP TABLE IF EXISTS 	model_draft.ego_grid_mvlv_substation_voronoi CASCADE;
CREATE TABLE		model_draft.ego_grid_mvlv_substation_voronoi (
	id 		serial NOT NULL,
	subst_id 	integer,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_grid_mvlv_substation_voronoi_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE 	model_draft.ego_grid_mvlv_substation_voronoi OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_grid_mvlv_substation_voronoi_geom_idx
	ON model_draft.ego_grid_mvlv_substation_voronoi USING GIST (geom);

-- loop over MV Griddistrict
DO
$$
DECLARE gd integer;
BEGIN
	FOR gd_id IN 1..3608
	LOOP
		EXECUTE

'WITH 
    -- Sample set of points to work with
    Sample AS (SELECT   ST_SetSRID(ST_Union(pts.geom), 0) AS geom
		FROM	model_draft.ego_grid_mvlv_substation AS pts
		WHERE pts.subst_id = ' || gd_id || ' OR is_dummy = TRUE
		),  -- INPUT 1/2
    -- Build edges and circumscribe points to generate a centroid
    Edges AS (
    SELECT id,
        UNNEST(ARRAY[''e1'',''e2'',''e3'']) EdgeName,
        UNNEST(ARRAY[
            ST_MakeLine(p1,p2) ,
            ST_MakeLine(p2,p3) ,
            ST_MakeLine(p3,p1)]) Edge,
        ST_Centroid(ST_ConvexHull(ST_Union(-- Done this way due to issues I had with LineToCurve
            ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p1,p2),ST_MakeLine(p2,p3)))),''LINE'',''CIRCULAR''),15),
            ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p2,p3),ST_MakeLine(p3,p1)))),''LINE'',''CIRCULAR''),15)
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
INSERT INTO model_draft.ego_grid_mvlv_substation_voronoi (geom, subst_id)	   -- INPUT 2/2
SELECT ST_SetSRID((ST_Dump(ST_Polygonize(ST_Node(ST_LineMerge(ST_Union(v, (SELECT ST_ExteriorRing(ST_ConvexHull(ST_Union(ST_Union(ST_Buffer(edge,20),ct)))) FROM Edges))))))).geom, 3035) geom, ' || gd_id || ' AS subst_id	  
FROM (
    SELECT  -- Create voronoi edges and reduce to a multilinestring
        ST_LineMerge(ST_Union(ST_MakeLine(
        x.ct,
        CASE 
        WHEN y.id IS NULL THEN
            CASE WHEN ST_Within(
                x.ct,
                (SELECT ST_ConvexHull(geom) FROM sample)) THEN -- Dont draw lines back towards the original set
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
    ) z';

END LOOP;

END;
$$;

-- Delete Dummy points from substations 
DELETE FROM model_draft.ego_grid_mvlv_substation WHERE is_dummy = TRUE;


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','temp','model_draft','ego_grid_mvlv_substation_voronoi','ego_dp_lv_substation_voronoi.sql',' ');



/* 
-- execute voronoi (experimental)
DROP TABLE IF EXISTS 	model_draft.ego_grid_mvlv_substation_voronoi_exp CASCADE;
CREATE TABLE		model_draft.ego_grid_mvlv_substation_voronoi_exp (
	id 		serial NOT NULL,
	subst_id 	integer,
	subst_cnt	integer,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_grid_mvlv_substation_voronoi_exp_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE 	model_draft.ego_grid_mvlv_substation_voronoi_exp OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX ego_grid_mvlv_substation_voronoi_exp_geom_idx
	ON model_draft.ego_grid_mvlv_substation_voronoi_exp USING GIST (geom);
	
-- Voronoi
WITH	-- sample set of points to work with
	Sample AS (SELECT   ST_SetSRID(ST_Union(ST_Collect(a.geom,b.geom)), 0) AS geom
	FROM	model_draft.ego_grid_mvlv_substation AS a,		-- input points
		model_draft.ego_grid_hvmv_substation_dummy AS b),  	-- dummy points
	-- Build edges and circumscribe points to generate centroids
	Edges AS (
	SELECT	id,
		UNNEST(ARRAY['e1','e2','e3']) EdgeName,
		UNNEST(ARRAY[
			ST_MakeLine(p1,p2) ,
			ST_MakeLine(p2,p3) ,
			ST_MakeLine(p3,p1)]) Edge,
		ST_Centroid(ST_ConvexHull(ST_Union(-- Done this way due to issues I had with LineToCurve
			ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p1,p2),ST_MakeLine(p2,p3)))),'LINE','CIRCULAR'),15),
			ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p2,p3),ST_MakeLine(p3,p1)))),'LINE','CIRCULAR'),15) ))) ct
	FROM ( 	
	-- Decompose to points
		SELECT 	id,
			ST_PointN(g,1) p1,
			ST_PointN(g,2) p2,
			ST_PointN(g,3) p3
		FROM    (
			SELECT (gd).Path id, ST_ExteriorRing((gd).geom) g -- ID andmake triangle a linestring
			FROM (SELECT (ST_Dump(ST_DelaunayTriangles(geom))) gd FROM Sample) a -- Get Delaunay Triangles
			)b
	) c )
SELECT ST_SetSRID((ST_Dump(ST_Polygonize(ST_Node(ST_LineMerge(ST_Union(v, (SELECT ST_ExteriorRing(ST_ConvexHull(ST_Union(ST_Union(ST_Buffer(edge,20),ct)))) FROM Edges))))))).geom, 2180) geom
INTO model_draft.ego_grid_mvlv_substation_voronoi_exp		  -- name 2/2
	FROM (SELECT  -- Create voronoi edges and reduce to a multilinestring
		ST_LineMerge(ST_Union(ST_MakeLine(
		x.ct,
		CASE
		WHEN y.id IS NULL THEN
		CASE WHEN ST_Within(x.ct,
		(SELECT ST_ConvexHull(geom) FROM sample)) THEN -- Don't draw lines back towards the original set
		-- Project line out twice the distance from convex hull
		ST_MakePoint(ST_X(x.ct) + ((ST_X(ST_Centroid(x.edge)) - ST_X(x.ct)) * 200),ST_Y(x.ct) + ((ST_Y(ST_Centroid(x.edge)) - ST_Y(x.ct)) * 200))
		END
		ELSE y.ct
		END ))) v
	FROM    Edges x
	LEFT OUTER JOIN -- Self Join based on edges
	Edges y ON x.id <> y.id AND ST_Equals(x.edge,y.edge)
	) z;
 */
/* -- set table
ALTER TABLE model_draft.ego_grid_mvlv_substation_voronoi_exp
	ADD COLUMN id serial,
	ADD COLUMN subst_id integer,
	ADD COLUMN subst_sum integer,
	ADD PRIMARY KEY (id),
	ALTER COLUMN geom TYPE geometry(POLYGON,3035) USING ST_SETSRID(geom,3035); */








/* 
-- voronoi algorithm
DROP TABLE IF EXISTS	model_draft.ego_grid_mvlv_substation_voronoi CASCADE;
CREATE TABLE 		model_draft.ego_grid_mvlv_substation_voronoi (
	id 		serial NOT NULL,
	subst_id 	integer,
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_grid_mvlv_substation_voronoi_pkey PRIMARY KEY (id) );

-- index GIST (geom)
CREATE INDEX	ego_grid_mvlv_substation_voronoi_geom_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mvlv_substation_voronoi OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_mvlv_substation','ego_dp_lv_griddistrict.sql',' ');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_hvmv_substation_dummy','ego_dp_lv_griddistrict.sql',' ');

-- loop over mv-griddistricts
DO
$$
DECLARE gd integer;
BEGIN
	FOR gd_id IN 1..1327
	LOOP
		EXECUTE
	'WITH 
		-- Sample set of points to work with
		Sample AS (SELECT   ST_SetSRID(ST_Union(ST_Collect(a.geom,b.geom)), 0) AS geom
			FROM	model_draft.ego_grid_mvlv_substation AS a,
				model_draft.ego_grid_hvmv_substation_dummy AS b
			WHERE 	a.subst_id = ' || gd_id || '
			),  -- INPUT 1/2
		-- Build edges and circumscribe points to generate centroids
		Edges AS (
		SELECT 	id,
			UNNEST(ARRAY[''e1'',''e2'',''e3'']) EdgeName,
			UNNEST(ARRAY[
			    ST_MakeLine(p1,p2) ,
			    ST_MakeLine(p2,p3) ,
			    ST_MakeLine(p3,p1)]) Edge,
			ST_Centroid(ST_ConvexHull(ST_Union(-- Done this way due to issues I had with LineToCurve
			    ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p1,p2),ST_MakeLine(p2,p3)))),''LINE'',''CIRCULAR''),15),
			    ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p2,p3),ST_MakeLine(p3,p1)))),''LINE'',''CIRCULAR''),15)
			))) ct      
		FROM    (
		-- Decompose to points
		SELECT 	id,
			ST_PointN(g,1) p1,
			ST_PointN(g,2) p2,
			ST_PointN(g,3) p3
		FROM    (
			SELECT (gd).Path id, ST_ExteriorRing((gd).geom) g -- ID andmake triangle a linestring
			FROM (SELECT (ST_Dump(ST_DelaunayTriangles(geom))) gd FROM Sample) a -- Get Delaunay Triangles
			)b
			) c
		)
	INSERT INTO model_draft.ego_grid_mvlv_substation_voronoi (geom, subst_id)	   -- INPUT 2/2
	SELECT ST_SetSRID((ST_Dump(ST_Polygonize(ST_Node(ST_LineMerge(ST_Union(v, (SELECT ST_ExteriorRing(ST_ConvexHull(ST_Union(ST_Union(ST_Buffer(edge,20),ct)))) FROM Edges))))))).geom, 3035) geom, ' || gd_id || ' AS subst_id	  
	FROM (
		SELECT  -- Create voronoi edges and reduce to a multilinestring
		ST_LineMerge(ST_Union(ST_MakeLine(
		x.ct,
		CASE 
		WHEN y.id IS NULL THEN
		    CASE WHEN ST_Within(
			x.ct,
			(SELECT ST_ConvexHull(geom) FROM sample)) THEN -- Dont draw lines back towards the original set
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
	    ) z';
END LOOP;
END;
$$;


-- loop over mv-griddistricts
DO
$$
DECLARE gd integer;
BEGIN
	FOR gd_id IN 1329..3608
	LOOP
		EXECUTE
	'WITH 
		-- Sample set of points to work with
		Sample AS (SELECT   ST_SetSRID(ST_Union(ST_Collect(a.geom,b.geom)), 0) AS geom
			FROM	model_draft.ego_grid_mvlv_substation AS a,
				model_draft.ego_grid_hvmv_substation_dummy AS b
			WHERE 	a.subst_id = ' || gd_id || '
			),  -- INPUT 1/2
		-- Build edges and circumscribe points to generate centroids
		Edges AS (
		SELECT 	id,
			UNNEST(ARRAY[''e1'',''e2'',''e3'']) EdgeName,
			UNNEST(ARRAY[
			    ST_MakeLine(p1,p2) ,
			    ST_MakeLine(p2,p3) ,
			    ST_MakeLine(p3,p1)]) Edge,
			ST_Centroid(ST_ConvexHull(ST_Union(-- Done this way due to issues I had with LineToCurve
			    ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p1,p2),ST_MakeLine(p2,p3)))),''LINE'',''CIRCULAR''),15),
			    ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p2,p3),ST_MakeLine(p3,p1)))),''LINE'',''CIRCULAR''),15)
			))) ct      
		FROM    (
		-- Decompose to points
		SELECT 	id,
			ST_PointN(g,1) p1,
			ST_PointN(g,2) p2,
			ST_PointN(g,3) p3
		FROM    (
			SELECT (gd).Path id, ST_ExteriorRing((gd).geom) g -- ID andmake triangle a linestring
			FROM (SELECT (ST_Dump(ST_DelaunayTriangles(geom))) gd FROM Sample) a -- Get Delaunay Triangles
			)b
			) c
		)
	INSERT INTO model_draft.ego_grid_mvlv_substation_voronoi (geom, subst_id)	   -- INPUT 2/2
	SELECT ST_SetSRID((ST_Dump(ST_Polygonize(ST_Node(ST_LineMerge(ST_Union(v, (SELECT ST_ExteriorRing(ST_ConvexHull(ST_Union(ST_Union(ST_Buffer(edge,20),ct)))) FROM Edges))))))).geom, 3035) geom, ' || gd_id || ' AS subst_id	  
	FROM (
		SELECT  -- Create voronoi edges and reduce to a multilinestring
		ST_LineMerge(ST_Union(ST_MakeLine(
		x.ct,
		CASE 
		WHEN y.id IS NULL THEN
		    CASE WHEN ST_Within(
			x.ct,
			(SELECT ST_ConvexHull(geom) FROM sample)) THEN -- Dont draw lines back towards the original set
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
	    ) z';
END LOOP;
END;
$$;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_mvlv_substation_voronoi IS '{
	"title": "eGoDP - MVLV Substation Voronoi",
	"description": "Voronoi for MVLV substation",
	"language": [ "eng", "ger" ],
	"reference_date": "2017",
	"sources": [
		{"name": "open_eGo", "description": "eGo dataprocessing",
		"url": "https://github.com/openego/data_processing", "license": "ODbL-1.0"} ],
	"spatial": [
		{"extend": "Germany",
		"resolution": " "} ],
	"license": [
		{"id": "tba",
		"name": "tba",
		"version": "tba",
		"url": "tba",
		"instruction": "tba"} ],
	"contributors": [
		{"name": "jong42", "email": " ",
		"date": "20.10.2016", "comment": "create table"},
		{"name": "jong42", "email": " ",
		"date": "27.10.2016", "comment": "change table names"},
		{"name": "Ludee", "email": " ",
		"date": "21.03.2017", "comment": "validate and restructure tables"},
		{"name": "Ludee", "email": " ",
		"date": "22.03.2017", "comment": "update metadata (1.1) and add license"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"name": "id", "description": "unique identifier", "unit": "" },
				{"name": "subst_id", "description": "HVMV substation ID", "unit": "" },
				{"name": "geom", "description": "geometry", "unit": "" } ]},
		"meta_version": "1.1" }] }';

-- select description
SELECT obj_description('model_draft.ego_grid_mvlv_substation_voronoi' ::regclass) ::json;
	
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_grid_mvlv_substation_voronoi','ego_dp_lv_griddistrict.sql',' ');

 */


/* 
-- remove dummy Voronoi
ALTER TABLE	model_draft.ego_grid_mvlv_substation_voronoi
	ADD COLUMN	cnt integer;

-- count mvlv_substation
UPDATE 	model_draft.ego_grid_mvlv_substation_voronoi AS t1
	SET  	cnt = t2.cnt
	FROM	(SELECT	a.id AS id,
			COUNT(b.geom)::integer AS cnt
		FROM	model_draft.ego_grid_mvlv_substation_voronoi AS a,
			model_draft.ego_grid_mvlv_substation AS b
		WHERE  	a.geom && b.geom AND
			ST_CONTAINS(a.geom,b.geom) AND
			a.subst_id = b.subst_id
		GROUP BY a.id
		)AS t2
	WHERE  	t1.id = t2.id;





DROP TABLE IF EXISTS	model_draft.ego_grid_mvlv_substation_voronoi_clean CASCADE;
CREATE TABLE 		model_draft.ego_grid_mvlv_substation_voronoi_clean (
	id 		serial NOT NULL,
	subst_id 	integer,		
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_grid_mvlv_substation_voronoi_pkey PRIMARY KEY (id) );

-- index GIST (geom)
CREATE INDEX	ego_grid_mvlv_substation_voronoi_clean_geom_idx
	ON	model_draft.ego_grid_mvlv_substation_voronoi_clean USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_mvlv_substation_voronoi_clean OWNER TO oeuser;

INSERT INTO	model_draft.ego_grid_mvlv_substation_voronoi_clean
	SELECT	*
	FROM	model_draft.ego_grid_mvlv_substation_voronoi
	WHERE	cnt = 1;

	
 */
