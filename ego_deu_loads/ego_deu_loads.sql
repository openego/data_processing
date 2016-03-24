
---------- ---------- ---------- ---------- ---------- ----------
-- "Collect Loads"   2016-03-24 14:35
---------- ---------- ---------- ---------- ---------- ----------

-- "Load Area & Load Point Cluster"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_load_collect CASCADE;
CREATE TABLE		orig_geo_rli.rli_deu_load_collect (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT	rli_deu_load_collect_pkey PRIMARY KEY (id));

-- "Insert Load Area"   (OK!) 7.000ms =139.446
INSERT INTO	orig_geo_rli.rli_deu_load_collect(geom)
	SELECT	la.geom
	FROM	orig_geo_rli.rli_deu_loadarea AS la;

-- "Insert Load Point Cluster"   (OK!) 2.000ms =153.267
INSERT INTO	orig_geo_rli.rli_deu_load_collect(geom)
	SELECT	cl.geom
	FROM	orig_geo_rli.rli_deu_loadpoints_cluster AS cl;

-- "Create Index GIST (geom)"   (OK!) 3.000ms =0
CREATE INDEX	rli_deu_load_collect_geom_idx
	ON	orig_geo_rli.rli_deu_load_collect
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_rli.rli_deu_load_collect TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_rli.rli_deu_load_collect OWNER TO oeuser;

---------- ---------- ---------- ---------- ---------- ----------
-- "Buffer (100m)"   2016-03-24 16:00
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_load_collect_buffer100;
CREATE TABLE		orig_geo_rli.rli_deu_load_collect_buffer100 (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT 	rli_deu_load_collect_buffer100_pkey PRIMARY KEY (id));

-- "Insert Buffer"   (OK!) 2.811.000ms =151.437
INSERT INTO	orig_geo_rli.rli_deu_load_collect_buffer100(geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(ST_TRANSFORM(poly.geom,3035), 100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_rli.rli_deu_load_collect AS poly;

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	rli_deu_load_collect_buffer100_geom_idx
	ON	orig_geo_rli.rli_deu_load_collect_buffer100
	USING	GIST (geom);
    
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_rli.rli_deu_load_collect_buffer100 TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_rli.rli_deu_load_collect_buffer100 OWNER TO oeuser;


---------- ---------- ---------- ---------- ---------- ----------
-- "Unbuffer [-100m]"
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_loads_buffer100_unbuffer;
CREATE TABLE	orig_geo_rli.rli_deu_loads_buffer100_unbuffer (
		uid SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT	rli_deu_loads_buffer100_unbuffer_pkey PRIMARY KEY (uid));

-- "Insert Buffer"   (OK!) 350.000ms =202.130
INSERT INTO	orig_geo_rli.rli_deu_loads_buffer100_unbuffer(geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(ST_TRANSFORM(buffer.geom,3035), -100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_rli.rli_deu_loads_buffer100 AS buffer
	GROUP BY buffer.id
	ORDER BY buffer.id;

-- "Extend Table"   (OK!) 150ms =0
ALTER TABLE	orig_geo_rli.rli_deu_loads_buffer100_unbuffer
	ADD COLUMN zensus_sum integer,
	ADD COLUMN zensus_count integer,
	ADD COLUMN zensus_density numeric,
	ADD COLUMN ioer_sum numeric,
	ADD COLUMN ioer_count integer,
	ADD COLUMN ioer_density numeric,
	ADD COLUMN area_ha numeric,
	ADD COLUMN sector_area_residential numeric,
	ADD COLUMN sector_area_retail numeric,
	ADD COLUMN sector_area_industrial numeric,
	ADD COLUMN sector_area_agricultural numeric,
	ADD COLUMN sector_share_residential numeric,
	ADD COLUMN sector_share_retail numeric,
	ADD COLUMN sector_share_industrial numeric,
	ADD COLUMN sector_share_agricultural numeric,
	ADD COLUMN sector_count_residential integer,
	ADD COLUMN sector_count_retail integer,
	ADD COLUMN sector_count_industrial integer,
	ADD COLUMN sector_count_agricultural integer,
	ADD COLUMN mv_poly_id integer,
	ADD COLUMN nuts varchar(5),
	ADD COLUMN rs varchar(12),
	ADD COLUMN ags_0 varchar(8),	
	ADD COLUMN geom_centroid geometry(POINT,3035),
	ADD COLUMN geom_surfacepoint geometry(POINT,3035),
	ADD COLUMN geom_buffer geometry(Polygon,3035);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	rli_deu_loads_buffer100_unbuffer_geom_idx
	ON	orig_geo_rli.rli_deu_loads_buffer100_unbuffer
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_rli.rli_deu_loads_buffer100_unbuffer TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_rli.rli_deu_loads_buffer100_unbuffer OWNER TO oeuser;

