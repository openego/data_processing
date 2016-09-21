-- -- -- --
-- Skript to generate regular grid points for different areas
-- Starting from a 34m grid for germany: deu_grid_50m
-- Entire bounding box with points outside Germany has 2.237.090 points!
-- Generate grid with grid skript


-- Add Column   (OK!) 100ms =*
ALTER TABLE	calc_ego_re.py_deu_grid_50m
	ADD COLUMN geom_pnt geometry(Point,3035);

-- Get Centroids   (OK!) ms =
UPDATE 	calc_ego_re.py_deu_grid_50m AS t1
SET  	geom_pnt = t2.geom_pnt
FROM    (
	SELECT	grid.id AS id,
		ST_CENTROID(grid.geom) ::geometry(Point,3035) AS geom_pnt
	FROM	calc_ego_re.py_deu_grid_50m AS grid
	) AS t2
WHERE  	t1.id = t2.id;

-- Create Index GIST (geom)   (OK!) 10.000ms =*
CREATE INDEX	py_deu_grid_50m_geom_pnt_idx
	ON	calc_ego_re.py_deu_grid_34m
	USING	GIST (geom);

-- X. deu_grid_34m_la   (OK!) ms =
DROP TABLE IF EXISTS  	calc_ego_re.deu_grid_50m_la CASCADE;
CREATE TABLE         	calc_ego_re.deu_grid_50m_la AS
	SELECT	grid.id ::integer AS id,
		'0' ::integer AS subst_id,
		'la' ::text AS area_type,
		grid.geom_pnt ::geometry(Point,3035) AS geom
	FROM	calc_ego_re.py_deu_grid_50m AS grid,
		orig_vg250.vg250_1_sta_union_mview AS deu
	WHERE	deu.geom && grid.geom_pnt AND
		ST_CONTAINS(deu.geom,grid.geom_pnt);

-- Create Index GIST (geom)   (OK!) 10.000ms =*
CREATE INDEX	deu_grid_50m_la_geom_idx
	ON	calc_ego_re.deu_grid_50m_la
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms
GRANT ALL ON TABLE	calc_ego_re.deu_grid_50m_la TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_50m_la OWNER TO oeuser;

-- Get substation ID from Grid Districts   (OK!) 100.000ms =1.430.895
UPDATE 	calc_ego_re.deu_grid_50m_la AS t1
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