-- Skript to generate regular grid points for different areas
-- Starting from a 500m grid for germany: deu_grid_500m
-- Entire bounding box with points outside Germany has 2.237.090 points!
-- Generate grid with grid skript

-- 0. deu_grid_500m		A regular 500m grid in Germany (vg250)
-- 1. deu_grid_500m_wpa		grid inside potential areas for wind energy (WindPotentialArea) (Weißflaechen)
-- 2. deu_grid_500m_la		grid inside ego load areas
-- 3. deu_grid_500m_out		grid not in 1. and 2.

-- 0. deu_grid_500m   (OK!) 253.000ms =1.525.632
DROP TABLE IF EXISTS  	calc_ego_re.deu_grid_500m CASCADE;
CREATE TABLE         	calc_ego_re.deu_grid_500m AS
	SELECT	grid.id ::integer AS id,
		'0' ::integer AS subst_id,
		'out' ::text AS area_type,
		grid.geom ::geometry(Point,3035) AS geom
	FROM	calc_ego_re.py_deu_grid_500m AS grid,
		orig_vg250.vg250_1_sta_union_mview AS deu
	WHERE	deu.geom && grid.geom AND
		ST_CONTAINS(deu.geom,grid.geom);

-- Add PK   (OK!) 2.500ms =*
ALTER TABLE	calc_ego_re.deu_grid_500m
	ADD PRIMARY KEY (id);

-- Create Index GIST (geom)   (OK!) 35.000ms =*
CREATE INDEX	deu_grid_500m_geom_idx
	ON	calc_ego_re.deu_grid_500m
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =*
GRANT ALL ON TABLE	calc_ego_re.deu_grid_500m TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_500m OWNER TO oeuser;

-- Get substation ID from Grid Districts   (OK!) 100.000ms =1.430.895
UPDATE 	calc_ego_re.deu_grid_500m AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	grid.id AS id,
		gd.subst_id AS subst_id
	FROM	calc_ego_re.deu_grid_500m AS grid,
		calc_ego_grid_district.grid_district AS gd
	WHERE  	gd.geom && grid.geom AND
		ST_CONTAINS(gd.geom,grid.geom)
	) AS t2
WHERE  	t1.id = t2.id;

-- Get area type for wpa   (OK!) 30.000ms =109.064
UPDATE 	calc_ego_re.deu_grid_500m AS t1
SET  	area_type = t2.area_type
FROM    (
	SELECT	grid.id AS id,
		'wpa' AS area_type
	FROM	calc_ego_re.deu_grid_500m AS grid,
		calc_ego_re.geo_pot_area_per_grid_district AS wpa
	WHERE  	wpa.geom && grid.geom AND
		ST_CONTAINS(wpa.geom,grid.geom)
	) AS t2
WHERE  	t1.id = t2.id;

-- Get area type for la   (OK!) 46.000ms =172.957
UPDATE 	calc_ego_re.deu_grid_500m AS t1
SET  	area_type = t2.area_type
FROM    (
	SELECT	grid.id AS id,
		'la' AS area_type
	FROM	calc_ego_re.deu_grid_500m AS grid,
		calc_ego_loads.ego_deu_load_area AS la
	WHERE  	la.geom && grid.geom AND
		ST_CONTAINS(la.geom,grid.geom)
	) AS t2
WHERE  	t1.id = t2.id;

-- Get area type for Load Area & WPA   (OK!) 10.000ms =775
UPDATE 	calc_ego_re.deu_grid_500m AS t1
SET  	area_type = t2.area_type
FROM    (
	SELECT	grid.id AS id,
		'wpa & la' AS area_type
	FROM	calc_ego_re.deu_grid_500m AS grid,
		calc_ego_loads.ego_deu_load_area AS la,
		calc_ego_re.geo_pot_area_per_grid_district AS wpa
	WHERE  	la.geom && grid.geom AND wpa.geom && grid.geom AND
		ST_CONTAINS(la.geom,grid.geom) AND ST_CONTAINS(wpa.geom,grid.geom)
	) AS t2
WHERE  	t1.id = t2.id;



-- 1. deu_grid_500m_wpa
-- Grid inside wpa   (OK!) 500ms =108.289
DROP MATERIALIZED VIEW IF EXISTS  	calc_ego_re.deu_grid_500m_wpa_mview CASCADE;
CREATE MATERIALIZED VIEW         	calc_ego_re.deu_grid_500m_wpa_mview AS
	SELECT	grid.*
	FROM	calc_ego_re.deu_grid_500m AS grid
	WHERE	area_type = 'wpa'

-- Create Index GIST (geom)   (OK!) 1.000ms =*
CREATE INDEX	deu_grid_500m_wpa_mview_geom_idx
	ON	calc_ego_re.deu_grid_500m_wpa_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms
GRANT ALL ON TABLE	calc_ego_re.deu_grid_500m_wpa_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_500m_wpa_mview OWNER TO oeuser;


-- 2. deu_grid_500m_la
-- Grid inside wpa   (OK!) 1.500ms =172.182
DROP MATERIALIZED VIEW IF EXISTS  	calc_ego_re.deu_grid_500m_la_mview CASCADE;
CREATE MATERIALIZED VIEW         	calc_ego_re.deu_grid_500m_la_mview AS
	SELECT	grid.*
	FROM	calc_ego_re.deu_grid_500m AS grid
	WHERE	area_type = 'la'

-- Create Index GIST (geom)   (OK!) 1.000ms =*
CREATE INDEX	deu_grid_500m_la_mview_geom_idx
	ON	calc_ego_re.deu_grid_500m_la_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms
GRANT ALL ON TABLE	calc_ego_re.deu_grid_500m_wpa_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_500m_wpa_mview OWNER TO oeuser;


-- X. deu_grid_500m_la_x
-- Grid inside wpa   (OK!) 1.500ms =775
DROP MATERIALIZED VIEW IF EXISTS  	calc_ego_re.deu_grid_500m_x_mview CASCADE;
CREATE MATERIALIZED VIEW         	calc_ego_re.deu_grid_500m_x_mview AS
	SELECT	grid.*
	FROM	calc_ego_re.deu_grid_500m AS grid
	WHERE	area_type = 'wpa & la'

-- Create Index GIST (geom)   (OK!) 1.000ms =*
CREATE INDEX	deu_grid_500m_x_mview_geom_idx
	ON	calc_ego_re.deu_grid_500m_x_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms
GRANT ALL ON TABLE	calc_ego_re.deu_grid_500m_x_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_500m_x_mview OWNER TO oeuser;


-- 3. deu_grid_500m_out
-- Grid inside wpa   (OK!) 1.500ms =1.244.386
DROP MATERIALIZED VIEW IF EXISTS  	calc_ego_re.deu_grid_500m_out_mview CASCADE;
CREATE MATERIALIZED VIEW         	calc_ego_re.deu_grid_500m_out_mview AS
	SELECT	grid.*
	FROM	calc_ego_re.deu_grid_500m AS grid
	WHERE	area_type = 'out'

-- Create Index GIST (geom)   (OK!) 10.000ms =*
CREATE INDEX	deu_grid_500m_out_mview_geom_idx
	ON	calc_ego_re.deu_grid_500m_out_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms
GRANT ALL ON TABLE	calc_ego_re.deu_grid_500m_out_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_500m_out_mview OWNER TO oeuser;


-- Counts
SELECT	'box' AS name,
	COUNT(grid.id) AS Count
FROM	calc_ego_re.grid_centroids AS grid
UNION ALL
SELECT	'all' AS name,
	COUNT(grid.id) AS Count
FROM	calc_ego_re.deu_grid_500m AS grid
UNION ALL
SELECT	'1. wpa' AS name,
	COUNT(grid.id) AS Count
FROM	calc_ego_re.deu_grid_500m AS grid
WHERE	grid.area_type = 'wpa'
UNION ALL
SELECT	'2. la' AS name,
	COUNT(grid.id) AS Count
FROM	calc_ego_re.deu_grid_500m AS grid
WHERE	grid.area_type = 'la'
UNION ALL
SELECT	'X. wpa & la' AS name,
	COUNT(grid.id) AS Count
FROM	calc_ego_re.deu_grid_500m AS grid
WHERE	grid.area_type = 'wpa & la'
UNION ALL
SELECT	'3. out' AS name,
	COUNT(grid.id) AS Count
FROM	calc_ego_re.deu_grid_500m AS grid
WHERE	grid.area_type = 'out'



-- -- -- --
-- Skript to generate regular grid points for different areas
-- Starting from a 34m grid for germany: deu_grid_34m
-- Entire bounding box with points outside Germany has 2.237.090 points!
-- Generate grid with grid skript

-- 0. deu_grid_34m		A regular 34m grid in Germany (vg250)
-- 1. deu_grid_34m_wpa		grid inside potential areas for wind energy (WindPotentialArea) (Weißflaechen)
-- 2. deu_grid_34m_la		grid inside ego load areas
-- 3. deu_grid_34m_out		grid not in 1. and 2.

-- Add Column   (OK!) 100ms =*
ALTER TABLE	calc_ego_re.py_deu_grid_34m
	ADD COLUMN geom_pnt geometry(Point,3035);

-- Get Centroids   (OK!) 5.066.000ms =102.645.406 (1,5 std.)
UPDATE 	calc_ego_re.py_deu_grid_34m AS t1
SET  	geom_pnt = t2.geom_pnt
FROM    (
	SELECT	grid.id AS id,
		ST_CENTROID(grid.geom) ::geometry(Point,3035) AS geom_pnt
	FROM	calc_ego_re.py_deu_grid_34m AS grid
	) AS t2
WHERE  	t1.id = t2.id;

-- Create Index GIST (geom)   (OK!) 3.459.000ms =*
CREATE INDEX	py_deu_grid_34m_geom_pnt_idx
	ON	calc_ego_re.py_deu_grid_34m
	USING	GIST (geom);

-- X. deu_grid_34m_la   (OK!) 253.000ms =1.525.632
DROP TABLE IF EXISTS  	calc_ego_re.deu_grid_34m_la CASCADE;
CREATE TABLE         	calc_ego_re.deu_grid_34m_la AS
	SELECT	grid.id ::integer AS id,
		'0' ::integer AS subst_id,
		'la' ::text AS area_type,
		grid.geom_pnt ::geometry(Point,3035) AS geom
	FROM	calc_ego_re.py_deu_grid_34m AS grid,
		orig_vg250.vg250_1_sta_union_mview AS deu
	WHERE	deu.geom && grid.geom_pnt AND
		ST_CONTAINS(deu.geom,grid.geom_pnt);

-- Create Index GIST (geom)   (OK!) 10.000ms =*
CREATE INDEX	deu_grid_34m_la_geom_idx
	ON	calc_ego_re.deu_grid_34m_la
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms
GRANT ALL ON TABLE	calc_ego_re.deu_grid_34m_la TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_34m_la OWNER TO oeuser;

-- Get substation ID from Grid Districts   (OK!) 100.000ms =1.430.895
UPDATE 	calc_ego_re.deu_grid_34m_la AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	grid.id AS id,
		gd.subst_id AS subst_id
	FROM	calc_ego_re.deu_grid_34m_la AS grid,
		calc_ego_grid_district.grid_district AS gd
	WHERE  	gd.geom && grid.geom AND
		ST_CONTAINS(gd.geom,grid.geom)
	) AS t2
WHERE  	t1.id = t2.id;




-- -- FULL

-- 0. deu_grid_34m   (OK!) 253.000ms =1.525.632
DROP TABLE IF EXISTS  	calc_ego_re.deu_grid_34m CASCADE;
CREATE TABLE         	calc_ego_re.deu_grid_34m AS
	SELECT	grid.id ::integer AS id,
		'0' ::integer AS subst_id,
		'out' ::text AS area_type,
		ST_CENTROID(grid.geom) ::geometry(Point,3035) AS geom
	FROM	calc_ego_re.py_deu_grid_34m AS grid,
		orig_vg250.vg250_1_sta_union_mview AS deu
	WHERE	deu.geom && grid.geom AND
		ST_CONTAINS(deu.geom,grid.geom);

-- Add PK   (OK!) 2.500ms =*
ALTER TABLE	calc_ego_re.deu_grid_500m
	ADD PRIMARY KEY (id);

-- Create Index GIST (geom)   (OK!) 35.000ms =*
CREATE INDEX	deu_grid_34m_geom_idx
	ON	calc_ego_re.deu_grid_34m
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =*
GRANT ALL ON TABLE	calc_ego_re.deu_grid_34m TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_34m OWNER TO oeuser;

-- Get substation ID from Grid Districts   (OK!) 100.000ms =1.430.895
UPDATE 	calc_ego_re.deu_grid_34m AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	grid.id AS id,
		gd.subst_id AS subst_id
	FROM	calc_ego_re.deu_grid_34m AS grid,
		calc_ego_grid_district.grid_district AS gd
	WHERE  	gd.geom && grid.geom AND
		ST_CONTAINS(gd.geom,grid.geom)
	) AS t2
WHERE  	t1.id = t2.id;

-- Get area type for wpa   (OK!) 30.000ms =109.064
UPDATE 	calc_ego_re.deu_grid_34m AS t1
SET  	area_type = t2.area_type
FROM    (
	SELECT	grid.id AS id,
		'wpa' AS area_type
	FROM	calc_ego_re.deu_grid_34m AS grid,
		calc_ego_re.geo_pot_area_per_grid_district AS wpa
	WHERE  	wpa.geom && grid.geom AND
		ST_CONTAINS(wpa.geom,grid.geom)
	) AS t2
WHERE  	t1.id = t2.id;

-- Get area type for la   (OK!) 46.000ms =172.957
UPDATE 	calc_ego_re.deu_grid_34m AS t1
SET  	area_type = t2.area_type
FROM    (
	SELECT	grid.id AS id,
		'la' AS area_type
	FROM	calc_ego_re.deu_grid_34m AS grid,
		calc_ego_loads.ego_deu_load_area AS la
	WHERE  	la.geom && grid.geom AND
		ST_CONTAINS(la.geom,grid.geom)
	) AS t2
WHERE  	t1.id = t2.id;

-- Get area type for Load Area & WPA   (OK!) 10.000ms =775
UPDATE 	calc_ego_re.deu_grid_34m AS t1
SET  	area_type = t2.area_type
FROM    (
	SELECT	grid.id AS id,
		'wpa & la' AS area_type
	FROM	calc_ego_re.deu_grid_34m AS grid,
		calc_ego_loads.ego_deu_load_area AS la,
		calc_ego_re.geo_pot_area_per_grid_district AS wpa
	WHERE  	la.geom && grid.geom AND wpa.geom && grid.geom AND
		ST_CONTAINS(la.geom,grid.geom) AND ST_CONTAINS(wpa.geom,grid.geom)
	) AS t2
WHERE  	t1.id = t2.id;



-- 1. deu_grid_34m_wpa
-- Grid inside wpa   (OK!) 34ms =108.289
DROP MATERIALIZED VIEW IF EXISTS  	calc_ego_re.deu_grid_34m_wpa_mview CASCADE;
CREATE MATERIALIZED VIEW         	calc_ego_re.deu_grid_34m_wpa_mview AS
	SELECT	grid.*
	FROM	calc_ego_re.deu_grid_34m AS grid
	WHERE	area_type = 'wpa'

-- Create Index GIST (geom)   (OK!) 1.000ms =*
CREATE INDEX	deu_grid_34m_wpa_mview_geom_idx
	ON	calc_ego_re.deu_grid_34m_wpa_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms
GRANT ALL ON TABLE	calc_ego_re.deu_grid_34m_wpa_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_34m_wpa_mview OWNER TO oeuser;


-- 2. deu_grid_34m_la
-- Grid inside wpa   (OK!) 1.34ms =172.182
DROP MATERIALIZED VIEW IF EXISTS  	calc_ego_re.deu_grid_34m_la_mview CASCADE;
CREATE MATERIALIZED VIEW         	calc_ego_re.deu_grid_34m_la_mview AS
	SELECT	grid.*
	FROM	calc_ego_re.deu_grid_34m AS grid
	WHERE	area_type = 'la'

-- Create Index GIST (geom)   (OK!) 1.000ms =*
CREATE INDEX	deu_grid_34m_la_mview_geom_idx
	ON	calc_ego_re.deu_grid_34m_la_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms
GRANT ALL ON TABLE	calc_ego_re.deu_grid_34m_wpa_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_34m_wpa_mview OWNER TO oeuser;


-- X. deu_grid_34m_la_x
-- Grid inside wpa   (OK!) 1.34ms =775
DROP MATERIALIZED VIEW IF EXISTS  	calc_ego_re.deu_grid_34m_x_mview CASCADE;
CREATE MATERIALIZED VIEW         	calc_ego_re.deu_grid_34m_x_mview AS
	SELECT	grid.*
	FROM	calc_ego_re.deu_grid_34m AS grid
	WHERE	area_type = 'wpa & la'

-- Create Index GIST (geom)   (OK!) 1.000ms =*
CREATE INDEX	deu_grid_34m_x_mview_geom_idx
	ON	calc_ego_re.deu_grid_34m_x_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms
GRANT ALL ON TABLE	calc_ego_re.deu_grid_34m_x_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_34m_x_mview OWNER TO oeuser;


-- 3. deu_grid_34m_out
-- Grid inside wpa   (OK!) 1.34ms =1.244.386
DROP MATERIALIZED VIEW IF EXISTS  	calc_ego_re.deu_grid_34m_out_mview CASCADE;
CREATE MATERIALIZED VIEW         	calc_ego_re.deu_grid_34m_out_mview AS
	SELECT	grid.*
	FROM	calc_ego_re.deu_grid_34m AS grid
	WHERE	area_type = 'out'

-- Create Index GIST (geom)   (OK!) 10.000ms =*
CREATE INDEX	deu_grid_34m_out_mview_geom_idx
	ON	calc_ego_re.deu_grid_34m_out_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms
GRANT ALL ON TABLE	calc_ego_re.deu_grid_34m_out_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_34m_out_mview OWNER TO oeuser;

-- Counts
SELECT	'box' AS name,
	COUNT(grid.id) AS Count
FROM	calc_ego_re.py_deu_grid_34m AS grid
UNION ALL
SELECT	'all' AS name,
	COUNT(grid.id) AS Count
FROM	calc_ego_re.deu_grid_34m AS grid
UNION ALL
SELECT	'1. wpa' AS name,
	COUNT(grid.id) AS Count
FROM	calc_ego_re.deu_grid_34m AS grid
WHERE	grid.area_type = 'wpa'
UNION ALL
SELECT	'2. la' AS name,
	COUNT(grid.id) AS Count
FROM	calc_ego_re.deu_grid_34m AS grid
WHERE	grid.area_type = 'la'
UNION ALL
SELECT	'X. wpa & la' AS name,
	COUNT(grid.id) AS Count
FROM	calc_ego_re.deu_grid_34m AS grid
WHERE	grid.area_type = 'wpa & la'
UNION ALL
SELECT	'3. out' AS name,
	COUNT(grid.id) AS Count
FROM	calc_ego_re.deu_grid_34m AS grid
WHERE	grid.area_type = 'out'