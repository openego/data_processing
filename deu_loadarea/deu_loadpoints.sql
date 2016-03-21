---------- ---------- ---------- ---------- ---------- ----------
-- "Load Points"
---------- ---------- ---------- ---------- ---------- ----------

-- 1. Zensus Punkte, die nicht in LA liegen
-- 2. LA, die nur "residential" haben und kein Zensus
-- 3. LA, die kleiner 2ha sind und nur "residential" haben

SELECT	SUM(zensus.population) AS people
FROM	orig_destatis.zensus_population_per_ha_mview AS zensus

UNION ALL

SELECT	SUM(lp.population) AS people
FROM	orig_geo_rli.rli_deu_loadpoints AS lp

---------- ---------- ----------


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

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_rli.rli_deu_loadpoints_zensus TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_rli.rli_deu_loadpoints_zensus OWNER TO oeuser;

-- "Create Index GIST (geom)"   (OK!) -> 40.000ms =0
CREATE INDEX  	rli_deu_loadpoints_zensus_geom_idx
	ON	orig_geo_rli.rli_deu_loadpoints_zensus
	USING	GIST (geom);

---------- ---------- ----------

-- "Calculate Inside LA"   (OK!) -> 210.000ms =2.873.049
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

-- "Create Table"   (OK!) 2.000ms =304.674
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_loadpoints;
CREATE TABLE 		orig_geo_rli.rli_deu_loadpoints AS
	SELECT	lp.*
	FROM	orig_geo_rli.rli_deu_loadpoints_zensus AS lp
	WHERE	inside_la IS NOT TRUE;

-- "Extend Table"   (OK!) 2.000ms =0
ALTER TABLE	orig_geo_rli.rli_deu_loadpoints
	ADD PRIMARY KEY (lp_id);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_geo_rli.rli_deu_loadpoints TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_rli.rli_deu_loadpoints OWNER TO oeuser;

-- "Create Index GIST (geom)"   (OK!) -> 8.000ms =0
CREATE INDEX  	rli_deu_loadpoints_geom_idx
	ON	orig_geo_rli.rli_deu_loadpoints
	USING	GIST (geom);



---------- ---------- ---------- TESTS

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

-- Zensus Punkte außerhalb der LG SPF (OK!) 2.000ms =477
DROP MATERIALIZED VIEW IF EXISTS	orig_destatis.zensus_population_per_ha_spf_satelliten;
CREATE MATERIALIZED VIEW 		orig_destatis.zensus_population_per_ha_spf_satelliten AS 
	SELECT 	zensus.*
	FROM 	orig_geo_rli_spf.zensus_population_per_ha_spf_pop AS zensus,
		(SELECT	ST_Union(geom_buffer) AS geom_lg
		FROM	orig_geo_rli_spf.rli_deu_lastgebiete_spf) AS lg
	WHERE	ST_CONTAINS(lg.geom_lg, zensus.geom) = 'f'

---------------

-- -- Zensus Punkte einfügen (OK!) ms =0
-- INSERT INTO	orig_geo_rli.rli_deu_lastgebiete_satelliten(gid,population,geom)
-- 	SELECT	zensus.gid,
-- 		zensus.population,
-- 		zensus.geom
-- 	FROM	orig_destatis.zensus_population_per_ha_satelliten AS zensus;

---------------

