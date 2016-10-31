---------- ---------- ----------
---------- --SKRIPT-- OK! 28min
---------- ---------- ----------

---------- ---------- ---------- ---------- ---------- ----------
-- "Zensus MView"   2016-04-23 04:00  160s
---------- ---------- ---------- ---------- ---------- ----------

-- "MVIEW with -1"   (OK!) -> 33.00ms =3.177.723
DROP MATERIALIZED VIEW IF EXISTS	social.zensus_population_per_ha_mview CASCADE;
CREATE MATERIALIZED VIEW         	social.zensus_population_per_ha_mview AS
	SELECT	zensus.gid ::integer AS gid,
		zensus.population ::numeric(10,0) AS population,
		zensus.geom ::geometry(Point,3035) AS geom
	FROM	social.zensus_population_per_ha AS zensus
	WHERE	zensus.population >= 0;

-- "Create Index (gid)"   (OK!) -> 1.000ms =0
CREATE UNIQUE INDEX  	zensus_population_per_ha_mview_gid_idx
		ON	social.zensus_population_per_ha_mview (gid);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	zensus_population_per_ha_mview_geom_idx
    ON    	social.zensus_population_per_ha_mview
    USING     	GIST (geom);
    
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	social.zensus_population_per_ha_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		social.zensus_population_per_ha_mview OWNER TO oeuser;



---------- ---------- ---------- ---------- ---------- ----------
-- "Load Points Zensus"   2016-04-17 22:00   s
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table" (OK!) 4.000ms =3.177.723
DROP TABLE IF EXISTS	model_draft.ego_social_zensus_loads;
CREATE TABLE 		model_draft.ego_social_zensus_loads AS
	SELECT	row_number() OVER() AS id,
		zensus.gid ::integer AS gid,
		zensus.population ::integer AS population,
		'FALSE' ::boolean AS inside_la,
		zensus.geom ::geometry(Point,3035) AS geom
	FROM	social.zensus_population_per_ha_mview AS zensus;

-- "PK"   (OK!) 3.000ms =0
ALTER TABLE	model_draft.ego_social_zensus_loads
	ADD PRIMARY KEY (id);

-- "Create Index GIST (geom)"   (OK!) -> 43.000ms =0
CREATE INDEX  	ego_social_zensus_loads_geom_idx
	ON	model_draft.ego_social_zensus_loads
	USING	GIST (geom);

---------- ---------- ----------

-- "Calculate Inside Load Area"   (OK!) -> 160.000ms =2.483.755
UPDATE 	model_draft.ego_social_zensus_loads AS t1
SET  	inside_la = t2.inside_la
FROM    (
	SELECT	zensus.id AS id,
		'TRUE' ::boolean AS inside_la
	FROM	model_draft.ego_social_zensus_loads AS zensus,
		orig_osm.ego_deu_loads_osm AS osm
	WHERE  	osm.geom && zensus.geom AND
		ST_CONTAINS(osm.geom,zensus.geom)
	) AS t2
WHERE  	t1.id = t2.id;

-- "Remove Inside Load Area"   (OK!) 5.000ms =2.483.755
DELETE FROM	model_draft.ego_social_zensus_loads AS lp
	WHERE	lp.inside_la IS TRUE;

-- "Grant oeuser"   (OK!) -> 1.000ms =693.968
GRANT ALL ON TABLE 	model_draft.ego_social_zensus_loads TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_social_zensus_loads OWNER TO oeuser;


---------- ---------- ---------- ---------- ---------- ----------
-- "Load Points Grid"   2016-04-13 16:16   75s
---------- ---------- ---------- ---------- ---------- ----------

-- "Extend Table"   (OK!) 1.000ms =0
ALTER TABLE	model_draft.ego_social_zensus_loads
	ADD COLUMN geom_grid geometry(Polygon,3035);

-- "Load Point Grid"   (OK!) -> 12.000ms =693.968
UPDATE 	model_draft.ego_social_zensus_loads AS t1
SET  	geom_grid = t2.geom_grid
FROM    (
	SELECT	lp.id AS id,
		ST_SetSRID((ST_MakeEnvelope(
			ST_X(lp.geom)-50,
			ST_Y(lp.geom)-50,
			ST_X(lp.geom)+50,
			ST_Y(lp.geom)+50)),3035) AS geom_grid
	FROM	model_draft.ego_social_zensus_loads AS lp
	) AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_grid)"   (OK!) -> 10.000ms =0
CREATE INDEX  	ego_deu_loadcluster_geom_grid_idx
	ON	model_draft.ego_social_zensus_loads
	USING	GIST (geom_grid);

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_social_zensus_loads' AS table_name,
		'setup_zensus_population_per_ha.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_social_zensus_loads;

---------- ---------- ---------- ---------- ---------- ----------
-- "Cluster from Load Points"   2016-04-13 16:17   275s
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) -> 100ms =0
DROP TABLE IF EXISTS	model_draft.ego_social_zensus_loads_cluster CASCADE;
CREATE TABLE         	model_draft.ego_social_zensus_loads_cluster (
	cid serial,
	zensus_sum INT,
	area_ha INT,
	geom geometry(Polygon,3035),
	geom_buffer geometry(Polygon,3035),
	geom_centroid geometry(Point,3035),
	geom_surfacepoint geometry(Point,3035),
CONSTRAINT ego_social_zensus_loads_cluster_pkey PRIMARY KEY (cid));

-- "Insert Cluster"   (OK!) -> 140.000ms =454.112
INSERT INTO	model_draft.ego_social_zensus_loads_cluster(geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(grid.geom_grid)))).geom ::geometry(Polygon,3035) AS geom
	FROM    model_draft.ego_social_zensus_loads AS grid;

-- "Create Index GIST (geom)"   (OK!) 5.000ms =0
CREATE INDEX	ego_social_zensus_loads_cluster_geom_idx
	ON	model_draft.ego_social_zensus_loads_cluster
	USING	GIST (geom);

-- "Calculate Inside Cluster"   (OK!) -> 100.000ms =454.112
UPDATE 	model_draft.ego_social_zensus_loads_cluster AS t1
SET  	zensus_sum = t2.zensus_sum,
	area_ha = t2.area_ha,
	geom_buffer = t2.geom_buffer,
	geom_centroid = t2.geom_centroid,
	geom_surfacepoint = t2.geom_surfacepoint
FROM    (
	SELECT	cl.cid AS cid,
		SUM(lp.population) AS zensus_sum,
		COUNT(lp.geom) AS area_ha,
		ST_BUFFER(cl.geom, 100) AS geom_buffer,
		ST_Centroid(cl.geom) AS geom_centroid,
		ST_PointOnSurface(cl.geom) AS geom_surfacepoint
	FROM	model_draft.ego_social_zensus_loads AS lp,
		model_draft.ego_social_zensus_loads_cluster AS cl
	WHERE  	cl.geom && lp.geom AND
		ST_CONTAINS(cl.geom,lp.geom)
	GROUP BY	cl.cid
	ORDER BY	cl.cid
	) AS t2
WHERE  	t1.cid = t2.cid;

-- "Create Index GIST (geom)"   (OK!) 8.000ms =0
CREATE INDEX	ego_social_zensus_loads_cluster_geom_centroid_idx
	ON	model_draft.ego_social_zensus_loads_cluster
	USING	GIST (geom_centroid);

-- "Create Index GIST (geom)"   (OK!) 5.000ms =0
CREATE INDEX	ego_social_zensus_loads_cluster_geom_surfacepoint_idx
	ON	model_draft.ego_social_zensus_loads_cluster
	USING	GIST (geom_surfacepoint);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	model_draft.ego_social_zensus_loads_cluster TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_social_zensus_loads_cluster OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_social_zensus_loads_cluster' AS table_name,
		'setup_zensus_population_per_ha.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_social_zensus_loads_cluster;

---------- ---------- ---------- ---------- ---------- ----------
-- "Create SPF"   2016-04-13 16:22  5s
---------- ---------- ---------- ---------- ---------- ----------

-- -- "Create Table SPF"   (OK!) 2.000ms =406
-- DROP TABLE IF EXISTS  	model_draft.ego_social_zensus_loads_cluster_spf;
-- CREATE TABLE         	model_draft.ego_social_zensus_loads_cluster_spf AS
-- 	SELECT	lp.*
-- 	FROM	model_draft.ego_social_zensus_loads_cluster AS lp,
-- 		orig_geo_vg250.vg250_4_krs_spf_mview AS spf
-- 	WHERE	ST_TRANSFORM(spf.geom,3035) && lp.geom_centroid  AND  
-- 		ST_CONTAINS(ST_TRANSFORM(spf.geom,3035), lp.geom_centroid);
-- 
-- -- "Ad PK"   (OK!) 150ms =0
-- ALTER TABLE	model_draft.ego_social_zensus_loads_cluster_spf
-- 	ADD PRIMARY KEY (cid);
-- 
-- -- "Create Index GIST (geom)"   (OK!) -> 100ms =0
-- CREATE INDEX  	ego_social_zensus_loads_cluster_spf_geom_idx
-- 	ON	model_draft.ego_social_zensus_loads_cluster_spf
-- 	USING	GIST (geom);
-- 
-- -- "Create Index GIST (geom_surfacepoint)"   (OK!) -> 150ms =0
-- CREATE INDEX  	ego_social_zensus_loads_cluster_spf_geom_surfacepoint_idx
--     ON    	model_draft.ego_social_zensus_loads_cluster_spf
--     USING     	GIST (geom_surfacepoint);
-- 
-- -- "Create Index GIST (geom_centroid)"   (OK!) -> 150ms =0
-- CREATE INDEX  	ego_social_zensus_loads_cluster_spf_geom_centroid_idx
--     ON    	model_draft.ego_social_zensus_loads_cluster_spf
--     USING     	GIST (geom_centroid);
-- 
-- -- "Create Index GIST (geom_buffer)"   (OK!) -> 150ms =0
-- CREATE INDEX  	ego_social_zensus_loads_cluster_spf_geom_buffer_idx
--     ON    	model_draft.ego_social_zensus_loads_cluster_spf
--     USING     	GIST (geom_buffer);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	model_draft.ego_deu_loads_zensus_cluster_spf TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		model_draft.ego_deu_loads_zensus_cluster_spf OWNER TO oeuser;


---------- ---------- ----------

-- Zensus Punkte, die nicht in LA liegen

-- "Population in Load Points"   (OK!) 1.000ms = 80.324.282 / 8.035.967
DROP MATERIALIZED VIEW IF EXISTS	model_draft.zensus_population_per_load_area_stats_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.zensus_population_per_load_area_stats_mview AS
SELECT	'zensus_deu' AS name,
	SUM(zensus.population) AS people
FROM	social.zensus_population_per_ha_mview AS zensus
	UNION ALL
SELECT	'zensus_loadpoints' AS name,
	SUM(lp.population) AS people
FROM	model_draft.ego_social_zensus_loads AS lp
	UNION ALL
SELECT	'zensus_loadpoints_cluster' AS name,
	SUM(cl.zensus_sum) AS people
FROM	model_draft.ego_social_zensus_loads_cluster AS cl;
