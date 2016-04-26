-- original
-- http://www.bostongis.com/PrinterFriendly.aspx?content_name=postgis_nearest_neighbor
-- If you needed to get the nearest neighbor for all records in a table, but you only need the first nearest neighbor for each, then you can use PostgreSQL's distinctive DISTINCT ON syntax. Which would look something like this :

SELECT DISTINCT ON (g1.gid)
	g1.gid As gref_gid,
	g1.description As gref_description,
	g2.gid As gnn_gid, 
        g2.description As gnn_description  
FROM 	sometable As g1,
	sometable As g2   
WHERE 	g1.gid <> g2.gid 
	AND ST_DWithin(g1.the_geom, g2.the_geom, 300)   
ORDER BY 	g1.gid, 
		ST_Distance(g1.the_geom,g2.the_geom);

-- -- -- -- --

-- gem WHERE usw_sum=0		orig_geo_ego.vg250_6_gem_usw_3_mview
-- usw		orig_geo_ego.ego_deu_mv_substations_mview

-- test1
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.nn_gem3_usw_mview;
CREATE MATERIALIZED VIEW 		orig_geo_ego.nn_gem3_usw_mview AS 
SELECT DISTINCT ON (g1.gid)
	g1.gid As gref_gid,
	g1.ags_0 As gref_ags_0,
	g1.geom AS gref_geom,
	g2.subst_id As gnn_gid, 
        g2.subst_name As gnn_subst_name,
	g2.geom AS gnn_geom
FROM 	orig_geo_ego.vg250_6_gem_usw_3_mview As g1, 
	orig_geo_ego.ego_deu_mv_substations_mview As g2   
WHERE 	g1.gid <> g2.subst_id
	AND ST_DWithin(g1.geom, g2.geom, 100000)   
ORDER BY 	g1.gid, 
		ST_Distance(g1.geom,g2.geom);


-- "gem dump"
SELECT 	(ST_Dump(ST_Boundary(nn.gref_geom))).geom ::geometry(LINESTRING,3035) AS geom
FROM	orig_geo_ego.nn_gem3_usw_mview AS nn
LIMIT 100;

-- "Sequence"   (OK!) 100ms =0
DROP SEQUENCE IF EXISTS 	nn_gem_usw_id CASCADE;
CREATE TEMP SEQUENCE 		nn_gem_usw_id;

-- "connect points"   (OK!) 1.000ms =9.172
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.nn_gem3_usw_line_mview;
CREATE MATERIALIZED VIEW 		orig_geo_ego.nn_gem3_usw_line_mview AS 
	SELECT 	nextval('nn_gem_usw_id') AS id,
		nn.gref_gid,
		nn.gnn_gid,
		ST_ShortestLine(	(ST_Dump(ST_Centroid(nn.gref_geom))).geom ::geometry(Point,3035),
				nn.gnn_geom ::geometry(Point,3035)
			) ::geometry(LineString,3035) AS geom
	FROM	orig_geo_ego.nn_gem3_usw_mview AS nn;

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	nn_gem3_usw_line_mview_gid_idx
		ON	orig_geo_ego.nn_gem3_usw_line_mview (id);