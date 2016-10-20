-- ( 18)
CREATE OR REPLACE FUNCTION ST_CreateFishnet(
        nrow integer, ncol integer,
        xsize float8, ysize float8,
        x0 float8 DEFAULT 0, y0 float8 DEFAULT 0,
        
        OUT geom geometry)
    RETURNS SETOF geometry AS
$$
SELECT ST_Translate(cell, j * $3 + $5, i * $4 + $6) AS geom
FROM generate_series(0, $1 - 1) AS i,
     generate_series(0, $2 - 1) AS j,
(
SELECT ('POLYGON((0 0, 0 '||$4||', '||$3||' '||$4||', '||$3||' 0,0 0))')::geometry AS cell
) AS foo;
$$ LANGUAGE sql IMMUTABLE STRICT;

DROP TABLE IF EXISTS calc_ego_re.py_deu_grid_50m;
CREATE TABLE calc_ego_re.py_deu_grid_50m AS

-- Erstelle ein Gitternetz auf der bbox der Lastgebiete:
SELECT ST_SETSRID(ST_CREATEFISHNET(
	ROUND((ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))) /50)::integer,
	ROUND((ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))) /50)::integer,
	50,
	50,
	ST_xmin (box2d(geom)),
	ST_ymin (box2d(geom))
),3035)::geometry(POLYGON,3035) AS geom

FROM calc_ego_loads."ego_deu_load_area";


-- Add ID
ALTER TABLE calc_ego_re.py_deu_grid_50m ADD "id" SERIAL;
ALTER TABLE calc_ego_re.py_deu_grid_50m ADD CONSTRAINT dea_grid_pkey_50 PRIMARY KEY(id);

-- Add GIST Index
CREATE INDEX idx_deu_grid_50m_geom
  ON calc_ego_re.py_deu_grid_50m
  USING gist
  (geom);


-- Grant oeuser   
GRANT ALL ON TABLE 	calc_ego_re.py_deu_grid_50m TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.py_deu_grid_50m OWNER TO oeuser;
