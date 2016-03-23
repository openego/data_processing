---------- ---------- ---------- ---------- ---------- ----------
-- "Load Points"
---------- ---------- ---------- ---------- ---------- ----------



---------- ---------- ---------- ---------- ---------- ----------
-- "Zensus Points"
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table" (OK!) 2.000ms =3.177.723
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_loadpoints_zensus;
CREATE TABLE 		orig_geo_rli.rli_deu_loadpoints_zensus AS
	SELECT	zensus.gid ::integer AS gid,
		zensus.population ::integer AS population,
		zensus.geom ::geometry(Point,3035) AS geom
	FROM	orig_destatis.zensus_population_per_ha_mview AS zensus;

-- "Extend Table"   (OK!) 10.000ms =0
ALTER TABLE	orig_geo_rli.rli_deu_loadpoints_zensus
	ADD COLUMN lp_id serial,
	ADD COLUMN inside_la boolean,
	ADD PRIMARY KEY (lp_id);

-- "Create Index GIST (geom)"   (OK!) -> 40.000ms =0
CREATE INDEX  	rli_deu_loadpoints_zensus_geom_idx
	ON	orig_geo_rli.rli_deu_loadpoints_zensus
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_rli.rli_deu_loadpoints_zensus TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_rli.rli_deu_loadpoints_zensus OWNER TO oeuser;


-- "Calculate Inside LA"   (OK!) -> 187.000ms =2.888.446
UPDATE 	orig_geo_rli.rli_deu_loadpoints_zensus AS t1
SET  	inside_la = t2.inside_la
FROM    (
	SELECT	lp.lp_id AS lp_id,
		TRUE AS inside_la
	FROM	orig_geo_rli.rli_deu_loadpoints_zensus AS lp,
		orig_geo_rli.rli_deu_loadarea AS la
	WHERE  	la.geom_buffer && lp.geom AND
		ST_CONTAINS(la.geom_buffer,lp.geom)
	) AS t2
WHERE  	t1.lp_id = t2.lp_id;

-- "Create Table"   (OK!) 2.000ms =289.277
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_loadpoints;
CREATE TABLE 		orig_geo_rli.rli_deu_loadpoints AS
	SELECT	lp.*
	FROM	orig_geo_rli.rli_deu_loadpoints_zensus AS lp
	WHERE	inside_la IS NOT TRUE;

-- "Extend Table"   (OK!) 2.000ms =0
ALTER TABLE	orig_geo_rli.rli_deu_loadpoints
	ADD PRIMARY KEY (lp_id);

-- "Create Index GIST (geom)"   (OK!) -> 3.000ms =0
CREATE INDEX  	rli_deu_loadpoints_geom_idx
	ON	orig_geo_rli.rli_deu_loadpoints
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_rli.rli_deu_loadpoints TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_rli.rli_deu_loadpoints OWNER TO oeuser;


---------- ---------- ---------- ---------- ---------- ----------
-- "Load Point Grid"
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_loadpoints_grid;
CREATE TABLE		orig_geo_rli.rli_deu_loadpoints_grid (
	lp_id INT,
	gid INT,
	population INT,
	geom geometry(Polygon, 3035),
	CONSTRAINT rli_deu_loadpoints_grid_pkey PRIMARY KEY (lp_id));

-- "Insert Grid"   (OK!) 3.000ms =289.277
INSERT INTO	orig_geo_rli.rli_deu_loadpoints_grid
	SELECT	pts.lp_id AS lp_id,
		pts.gid AS gid,
		pts.population AS population,
		ST_SetSRID((ST_MakeEnvelope(ST_X(pts.geom)-50,ST_Y(pts.geom)-50,ST_X(pts.geom)+50,ST_Y(pts.geom)+50)),3035) AS geom    
	FROM	orig_geo_rli.rli_deu_loadpoints AS pts;  

-- "Create Index GIST (geom)"   (OK!) -> 3.000ms =0
CREATE INDEX	rli_deu_loadpoints_grid_geom_idx
	ON	orig_geo_rli.rli_deu_loadpoints_grid
	USING	GIST (geom);

---------- ---------- ---------- ---------- ---------- ----------
-- "Cluster From Load Points"
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) -> 100ms =0
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_loadpoints_cluster CASCADE;
CREATE TABLE         	orig_geo_rli.rli_deu_loadpoints_cluster (
    cid serial,
    zensus_sum INT,
    area_ha INT,
    geom geometry(Polygon,3035),
    geom_centroid geometry(Point,3035),
    geom_surfacepoint geometry(Point,3035),
CONSTRAINT zensus_population_per_ha_grid_cluster_pkey PRIMARY KEY (cid));


-- "Insert Cluster"   (OK!) -> 34.000ms =153.267
INSERT INTO	orig_geo_rli.rli_deu_loadpoints_cluster(geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(grid.geom)))).geom ::geometry(Polygon,3035) AS geom
	FROM    orig_geo_rli.rli_deu_loadpoints_grid AS grid


-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	rli_deu_loadpoints_cluster_geom_idx
	ON	orig_geo_rli.rli_deu_loadpoints_cluster
	USING	GIST (geom);

-- "Calculate Inside Cluster"   (OK!) -> 16.000ms =153.267
UPDATE 	orig_geo_rli.rli_deu_loadpoints_cluster AS t1
SET  	zensus_sum = t2.zensus_sum,
	area_ha = t2.area_ha,
	geom_centroid = t2.geom_centroid,
	geom_surfacepoint = t2.geom_surfacepoint
FROM    (
	SELECT	cl.cid AS cid,
		SUM(lp.population) AS zensus_sum,
		COUNT(lp.geom) AS area_ha,
		ST_Centroid(cl.geom) AS geom_centroid,
		ST_PointOnSurface(cl.geom) AS geom_surfacepoint
	FROM	orig_geo_rli.rli_deu_loadpoints AS lp,
		orig_geo_rli.rli_deu_loadpoints_cluster AS cl
	WHERE  	cl.geom && lp.geom AND
		ST_CONTAINS(cl.geom,lp.geom)
	GROUP BY	cl.cid
	ORDER BY	cl.cid
	) AS t2
WHERE  	t1.cid = t2.cid;


-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	rli_deu_loadpoints_cluster_geom_centroid_idx
	ON	orig_geo_rli.rli_deu_loadpoints_cluster
	USING	GIST (geom_centroid);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	rli_deu_loadpoints_cluster_geom_surfacepoint_idx
	ON	orig_geo_rli.rli_deu_loadpoints_cluster
	USING	GIST (geom_surfacepoint);

---------- ---------- ----------

-- Zensus Punkte, die nicht in LA liegen

-- "Population in Load Points"   (OK!) 1.000ms =80.324.282 / 4.112.902
SELECT	'zensus_deu' AS name,
	SUM(zensus.population) AS people
FROM	orig_destatis.zensus_population_per_ha_mview AS zensus
	UNION ALL
SELECT	'zensus_loadpoints' AS name,
	SUM(lp.population) AS people
FROM	orig_geo_rli.rli_deu_loadpoints AS lp
	UNION ALL
SELECT	'zensus_loadpoints_cluster' AS name,
	SUM(cl.zensus_sum) AS people
FROM	orig_geo_rli.rli_deu_loadpoints_cluster AS cl


---------- ---------- ---------- TESTS



-- -- "Union Load Area"   (OK!) 2.109.000ms =1
-- DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.rli_deu_loadarea_union_mview;
-- CREATE MATERIALIZED VIEW 		orig_geo_rli.rli_deu_loadarea_union_mview AS 
-- 	SELECT	ST_Union(la.geom_buffer) AS geom
-- 	FROM	orig_geo_rli.rli_deu_loadarea AS la;
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	orig_geo_rli.rli_deu_loadarea_union_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_geo_rli.rli_deu_loadarea_union_mview OWNER TO oeuser;
-- 
-- -- "Create Table" (OK!) 13.000ms =1
-- DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_loadarea_union;
-- CREATE TABLE 		orig_geo_rli.rli_deu_loadarea_union AS
-- 	SELECT	la.geom ::geometry(MultiPolygon,3035)
-- 	FROM	orig_geo_rli.rli_deu_loadarea_union_mview AS la;
-- 
-- -- "Extend Table"   (OK!) 12.000ms =0
-- ALTER TABLE	orig_geo_rli.rli_deu_loadarea_union
-- 	ADD COLUMN id integer,
-- 	ADD COLUMN inside_la boolean;
-- 
-- -- "Update Table"   (OK!) -> 98.404ms =168.095
-- UPDATE 	orig_geo_rli.rli_deu_loadarea_union
-- SET  	id = '1',
-- 	inside_la = TRUE;
-- 
-- -- "Extend Table"   (OK!) 12.000ms =0
-- ALTER TABLE	orig_geo_rli.rli_deu_loadarea_union
-- 	ADD PRIMARY KEY (id);
-- 
-- -- "Create Index GIST (geom)"   (OK!) -> 6.000ms =0
-- CREATE INDEX  	rli_deu_loadarea_union_geom_idx
-- 	ON	orig_geo_rli.rli_deu_loadarea_union
-- 	USING	GIST (geom);

---------- ---------- ----------

-- -- "Create Table" (OK!) 100ms =0
-- DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_loadpoints;
-- CREATE TABLE 		orig_geo_rli.rli_deu_loadpoints (
-- 	lp_id serial,
-- 	population integer,
-- 	inside_la boolean,
-- 	geom geometry(Point,3035),
-- CONSTRAINT rli_deu_loadpoints_pkey PRIMARY KEY (lp_id));


-- -- Zensus Punkte außerhalb der LG (zu lang!) .000ms =0
-- DROP MATERIALIZED VIEW IF EXISTS	orig_geo_rli.rli_deu_loadpoints_zensus_mview;
-- CREATE MATERIALIZED VIEW 		orig_geo_rli.rli_deu_loadpoints_zensus_mview AS 
-- 	SELECT 	zensus.gid,
-- 		zensus.population,
-- 		zensus.geom
-- 	FROM 	orig_destatis.zensus_population_per_ha_mview AS zensus,
-- 		orig_geo_rli.rli_deu_loadarea_union_mview AS la
-- 	WHERE	ST_CONTAINS(la.geom, zensus.geom) = 'f';
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	orig_geo_rli.rli_deu_loadarea_union_mview TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		orig_geo_rli.rli_deu_loadarea_union_mview OWNER TO oeuser

-- -- Zensus Punkte außerhalb der LG (zu lang) .000ms =0
-- DROP MATERIALIZED VIEW IF EXISTS	orig_destatis.zensus_population_per_ha_satelliten;
-- CREATE MATERIALIZED VIEW 		orig_destatis.zensus_population_per_ha_satelliten AS 
-- 	SELECT 	zensus.*
-- 	FROM 	orig_destatis.zensus_population_per_ha_mview AS zensus,
-- 		(SELECT	ST_Union(geom_buffer) AS geom_lg
-- 		FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff) AS lg
-- 	WHERE	ST_CONTAINS(lg.geom_lg, zensus.geom) = 'f';



-- -- Zensus Punkte außerhalb der LG (OK!) .000ms =0
-- DROP MATERIALIZED VIEW IF EXISTS	orig_destatis.zensus_population_per_ha_satelliten;
-- CREATE MATERIALIZED VIEW 		orig_destatis.zensus_population_per_ha_satelliten AS 
-- 	SELECT 	zensus.*
-- 	FROM 	orig_destatis.zensus_population_per_ha_mview AS zensus,
-- 		(SELECT	ST_Union(geom_buffer) AS geom_lg
-- 		FROM	orig_geo_rli.osm_deu_polygon_urban_buffer100_unbuff) AS lg
-- 	WHERE	ST_CONTAINS(lg.geom_lg, zensus.geom) = 'f';
---------------

-- -- Zensus Punkte außerhalb der LG SPF (OK!) 2.000ms =477
-- DROP MATERIALIZED VIEW IF EXISTS	orig_destatis.zensus_population_per_ha_spf_satelliten;
-- CREATE MATERIALIZED VIEW 		orig_destatis.zensus_population_per_ha_spf_satelliten AS 
-- 	SELECT 	zensus.*
-- 	FROM 	orig_geo_rli_spf.zensus_population_per_ha_spf_pop AS zensus,
-- 		(SELECT	ST_Union(geom_buffer) AS geom_lg
-- 		FROM	orig_geo_rli_spf.rli_deu_lastgebiete_spf) AS lg
-- 	WHERE	ST_CONTAINS(lg.geom_lg, zensus.geom) = 'f'

---------------

-- -- Zensus Punkte einfügen (OK!) ms =0
-- INSERT INTO	orig_geo_rli.rli_deu_lastgebiete_satelliten(gid,population,geom)
-- 	SELECT	zensus.gid,
-- 		zensus.population,
-- 		zensus.geom
-- 	FROM	orig_destatis.zensus_population_per_ha_satelliten AS zensus;

---------------

