-- ()
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

DROP TABLE IF EXISTS calc_ego_re.deu_grid_34m;
CREATE TABLE calc_ego_re.deu_grid_34m AS

-- Erstelle ein Gitternetz auf der bbox der Lastgebiete:
SELECT ST_SETSRID(ST_CREATEFISHNET(
	ROUND((ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))) /34.3333333)::integer,
	ROUND((ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))) /34.3333333)::integer,
	34.3333333,
	34.3333333,
	ST_xmin (box2d(geom)),
	ST_ymin (box2d(geom))
),3035)::geometry(POLYGON,3035) AS geom

FROM (SELECT ST_TRANSFORM(ST_UNION(geom),3035) AS geom FROM orig_vg250.vg250_1_sta) AS t1 ;

-- Add ID
ALTER TABLE calc_ego_re.deu_grid_34m ADD "id" SERIAL;
ALTER TABLE calc_ego_re.deu_grid_34m ADD CONSTRAINT dea_grid_pkey PRIMARY KEY(id);

-- Add GIST Index
CREATE INDEX idx_deu_grid_34m_geom
  ON calc_ego_re.deu_grid_34m
  USING gist
  (geom);


-- Grant oeuser   
GRANT ALL ON TABLE 	calc_ego_re.deu_grid_34m TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_re.deu_grid_34m OWNER TO oeuser;
