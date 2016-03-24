
---------- ---------- ---------- ---------- ---------- ----------
-- "Collect Loads"   2016-03-24 17:15 10s
---------- ---------- ---------- ---------- ---------- ----------

-- "Load Area & Load Point Cluster"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_load_collect CASCADE;
CREATE TABLE		orig_geo_rli.rli_deu_load_collect (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT	rli_deu_load_collect_pkey PRIMARY KEY (id));

-- "Insert Load Area"   (OK!) 7.000ms =139.446
INSERT INTO	orig_geo_rli.rli_deu_load_collect (geom)
	SELECT	la.geom
	FROM	orig_geo_rli.rli_deu_loadarea AS la;

-- "Insert Load Point Cluster"   (OK!) 2.000ms =153.267
INSERT INTO	orig_geo_rli.rli_deu_load_collect (geom)
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
-- "Buffer (100m)"   2016-03-24 17:15 45min
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_load_collect_buffer100;
CREATE TABLE		orig_geo_rli.rli_deu_load_collect_buffer100 (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT 	rli_deu_load_collect_buffer100_pkey PRIMARY KEY (id));

-- "Insert Buffer"   (OK!) 2.811.000ms =151.437
INSERT INTO	orig_geo_rli.rli_deu_load_collect_buffer100 (geom)
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
-- "Unbuffer (-100m)"   2016-03-24 18:07 6min
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =0
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_loads_buffer100_unbuffer;
CREATE TABLE	orig_geo_rli.rli_deu_loads_buffer100_unbuffer (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT	rli_deu_loads_buffer100_unbuffer_pkey PRIMARY KEY (id));

-- "Insert Buffer"   (OK!) 350.000ms =202.130
INSERT INTO	orig_geo_rli.rli_deu_loads_buffer100_unbuffer (geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(ST_TRANSFORM(buffer.geom,3035), -100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_rli.rli_deu_loads_buffer100 AS buffer
	GROUP BY buffer.id
	ORDER BY buffer.id;

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	rli_deu_loads_buffer100_unbuffer_geom_idx
	ON	orig_geo_rli.rli_deu_loads_buffer100_unbuffer
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_rli.rli_deu_loads_buffer100_unbuffer TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_rli.rli_deu_loads_buffer100_unbuffer OWNER TO oeuser;

---------- ---------- ---------- ---------- ---------- ----------
-- "Cutting"
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 100ms =
DROP TABLE IF EXISTS	orig_geo_rli.rli_deu_loads_buffer100_unbuffer_cut;
CREATE TABLE	orig_geo_rli.rli_deu_loads_buffer100_unbuffer_cut (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT	rli_deu_loads_buffer100_unbuffer_cut_pkey PRIMARY KEY (id));

-- "Insert Cut"   (OK!) 350.000ms =
INSERT INTO	orig_geo_rli.rli_deu_loads_buffer100_unbuffer_cut (geom)
	SELECT	ST_INTERSECTION(poly.geom,cut.geom) ::geometry(Polygon,3035) AS geom
	FROM	orig_geo_rli.rli_deu_loads_buffer100_unbuffer AS poly,
		calc_gridcells_znes.znes_deu_gridcells_qgis AS cut
	GROUP BY poly.id
	ORDER BY poly.id;

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX	rli_deu_loads_buffer100_unbuffer_cut_geom_idx
	ON	orig_geo_rli.rli_deu_loads_buffer100_unbuffer_cut
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_rli.rli_deu_loads_buffer100_unbuffer_cut TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_rli.rli_deu_loads_buffer100_unbuffer_cut OWNER TO oeuser;