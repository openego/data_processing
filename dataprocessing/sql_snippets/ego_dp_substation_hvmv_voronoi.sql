/*
hvmv substation voronoi
voronoi polygons with eucldean distance / manhattan distance would be better but not available in sql

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_grid_hvmv_substation','ego_grid_hvmv_substation.sql',' ');

-- set id as subst_id - move to get_substation.sql
ALTER TABLE	model_draft.ego_grid_hvmv_substation
	DROP COLUMN IF EXISTS 	ags_0 CASCADE,
	ADD COLUMN 		ags_0 text,
	DROP COLUMN IF EXISTS 	geom CASCADE,
	ADD COLUMN 		geom geometry(Point,3035);

UPDATE 	model_draft.ego_grid_hvmv_substation t1
	SET  	geom = ST_TRANSFORM(t1.point,3035)
	FROM	model_draft.ego_grid_hvmv_substation t2
	WHERE  	t1.subst_id = t2.subst_id;

-- index GIST (geom)
CREATE INDEX	ego_grid_hvmv_substation_geom_idx
	ON	model_draft.ego_grid_hvmv_substation USING GIST (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_political_boundary_bkg_vg250_6_gem_clean','ego_grid_hvmv_substation.sql',' ');

-- Gemeindeschlüssel
UPDATE 	model_draft.ego_grid_hvmv_substation AS t1
	SET  	ags_0 = t2.ags_0
	FROM    (
		SELECT	sub.subst_id AS subst_id,
			vg.ags_0 AS ags_0
		FROM	model_draft.ego_grid_hvmv_substation AS sub,
			model_draft.ego_political_boundary_bkg_vg250_6_gem_clean AS vg
		WHERE  	vg.geom && sub.geom AND
			ST_CONTAINS(vg.geom,sub.geom)
		) AS t2
	WHERE  	t1.subst_id = t2.subst_id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_grid_hvmv_substation','ego_grid_hvmv_substation.sql',' ');


-- create dummy points for voronoi calculation
DROP TABLE IF EXISTS 	model_draft.ego_grid_hvmv_substation_dummy CASCADE;
CREATE TABLE		model_draft.ego_grid_hvmv_substation_dummy (
	subst_id integer,
	subst_name text,
	geom geometry(Point,3035),
	CONSTRAINT ego_grid_hvmv_substation_dummy_pkey PRIMARY KEY (subst_id));

-- insert points around germany (18 Points)
INSERT INTO	model_draft.ego_grid_hvmv_substation_dummy (subst_id,subst_name,geom)
	SELECT '9001' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(3878765.05927874 3342870.31889155)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9002' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(3941166.84473566 3530017.71307212)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9003' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4033601.91782991 3691498.91137808)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9004' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4152362.22315766 3789791.51576683)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9005' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4329393.62365717 3830200.38704261)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9006' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4495844.04212254 3826709.11082927)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9007' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4645016.94115968 3729362.79329962)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9008' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4774984.93447502 3477163.19376104)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9009' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4843018.75954041 3201846.85332402)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9010' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4883145.96311377 2901213.21783621)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9011' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4847739.56682014 2666951.87655141)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9012' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4686275.85532184 2472337.14136933)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9013' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4486219.50548571 2392980.74648555)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9014' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4263444.02272107 2368483.9483323)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9015' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(4039063.04090959 2439583.67779797)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9016' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(3904569.75117475 2609736.50599677)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9017' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(3852322.49802 2849800.43518705)'),3035) ::geometry(Point,3035) AS geom UNION ALL 
	SELECT '9018' ::integer AS subst_id, 'DUMMY' AS subst_name, ST_SetSRID(ST_GeomFromText('POINT(3843258.70046489 3109607.27281094)'),3035) ::geometry(Point,3035) AS geom;

-- index GIST (geom)
CREATE INDEX	substations_dummy_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_dummy USING gist (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_hvmv_substation_dummy OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_grid_hvmv_substation_dummy IS '{
    "Name": "ego hvmv substation dummy points",
    "Source":   [{
	"Name": "open_eGo",
	"URL": "https://github.com/openego/data_processing"}],
    "Reference date": "2016",
    "Date of collection": "02.09.2016",
    "Original file": [""],
    "Spatial": [{
	"Resolution": "",
	"Extend": "Germany" }],
    "Description": ["Dummy points used for voronoi polygons"],
    "Column":[
        {"Name": "subst_id", "Description": "Substation ID", "Unit": " " },
        {"Name": "subst_name", "Description": "name is DUMMY", "Unit": " " },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludee", "Mail": "",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludee", "Mail": "",
	"Date":  "17.11.2016", "Comment": "Added Dummy from WKT" },
	{"Name": "Ludee", "Mail": "",
	"Date":  "17.11.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('model_draft.ego_grid_hvmv_substation_dummy' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_grid_hvmv_substation_dummy','ego_grid_hvmv_substation.sql',' ');


-- voronoi polygons with eucldean distance
DROP TABLE IF EXISTS model_draft.ego_grid_hvmv_substation_voronoi CASCADE; -- name 1/2
	WITH	-- sample set of points to work with
		Sample AS (SELECT   ST_SetSRID(ST_Union(ST_Collect(a.geom,b.geom)), 0) AS geom
		FROM	model_draft.ego_grid_hvmv_substation AS a,
			model_draft.ego_grid_hvmv_substation_dummy AS b),  -- input points
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
	INTO model_draft.ego_grid_hvmv_substation_voronoi		  -- name 2/2
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

-- set table
ALTER TABLE model_draft.ego_grid_hvmv_substation_voronoi
	ADD COLUMN id serial,
	ADD COLUMN subst_id integer,
	ADD COLUMN subst_sum integer,
	ADD PRIMARY KEY (id),
	ALTER COLUMN geom TYPE geometry(POLYGON,3035) USING ST_SETSRID(geom,3035);

-- index GIST (geom)
CREATE INDEX	ego_grid_hvmv_substation_voronoi_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_voronoi USING gist (geom);

-- grant (oeuser)
ALTER TABLE 	model_draft.ego_grid_hvmv_substation_voronoi OWNER TO oeuser;

/* -- delete dummy points from substations and voronoi (18 Points)
DELETE FROM model_draft.ego_grid_hvmv_substation WHERE subst_name='DUMMY';
DELETE FROM model_draft.ego_grid_hvmv_substation_voronoi WHERE subst_id IS NULL; */

-- metadata
COMMENT ON TABLE model_draft.ego_grid_hvmv_substation_voronoi IS '{
    "Name": "ego hvmv substation voronoi",
    "Source":   [{
	"Name": "open_eGo",
	"URL": "https://github.com/openego/data_processing"}],
    "Reference date": "2016",
    "Date of collection": "02.09.2016",
    "Original file": ["ego_grid_hvmv_substation"],
    "Spatial": [{
	"Resolution": "",
	"Extend": "Germany" }],
    "Description": ["Voronoi polygons for hvmv substation"],
    "Column":[
        {"Name": "id", "Description": "Unique identifier", "Unit": " " },
        {"Name": "subst_id", "Description": "Substation ID", "Unit": " " },
        {"Name": "subst_sum", "Description": "Number of substation per polygon (=1)", "Unit": " " },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludee", "Mail": "",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludee", "Mail": "",
	"Date":  "16.11.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('model_draft.ego_grid_hvmv_substation_voronoi' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_grid_hvmv_substation_voronoi','ego_grid_hvmv_substation.sql',' ');
