-- 01
-- create table and insert (OK!)
DROP TABLE IF EXISTS    tmp_destatis.zensus_population_per_ha;
CREATE TABLE         tmp_destatis.zensus_population_per_ha (
    gid        SERIAL NOT NULL,
    grid_id        character varying(254) NOT NULL,
    x_mp        numeric(10,0),
    y_mp        numeric(10,0),
    population     numeric(10,0),
    geom         geometry(Point,3035),
    CONSTRAINT zensus_population_per_ha_pkey PRIMARY KEY (gid));

-- 02
-- Insert (OK!)
INSERT INTO tmp_destatis.zensus_population_per_ha (grid_id,x_mp,y_mp,population,geom)(
    SELECT
        zensus.grid_id AS grid_id,
        zensus.x_mp_100m AS x_mp,
        zensus.y_mp_100m AS y_mp,
        zensus.population AS population,
        ST_SetSRID(ST_MakePoint(zensus.x_mp_100m, zensus.y_mp_100m),3035) AS geom
    FROM    tmp_destatis.zensus_2011_pop_per_ha AS zensus);

-- 03
-- Create index (OK!)
CREATE INDEX zensus_population_per_ha_geom_idx
  ON tmp_destatis.zensus_population_per_ha
  USING gist (geom);
  
-- 04
-- CREATE TABLE (OK!)
DROP TABLE IF EXISTS     tmp_destatis.zensus_population_per_ha_grid;
CREATE TABLE         tmp_destatis.zensus_population_per_ha_grid (
    gid INT,
    grid_id character varying(254) NOT NULL,
    x_mp numeric(10,0),
    y_mp numeric(10,0),
    population INT,
    geom geometry(Polygon, 3035),
    CONSTRAINT zensus_population_per_ha_grid_pkey PRIMARY KEY (gid));

-- 05
-- INSERT GRID (OK!)
INSERT INTO tmp_destatis.zensus_population_per_ha_grid
SELECT     pts.gid AS gid,
    pts.grid_id AS grid_id,
    pts.x_mp AS x_mp,
    pts.y_mp AS y_mp,
    pts.population AS population,
    ST_SetSRID((ST_MakeEnvelope(pts.x_mp-50,pts.y_mp-50,pts.x_mp+50,pts.y_mp+50)),3035) AS geom    
FROM     tmp_destatis.zensus_population_per_ha AS pts;

-- 06
-- CREATE INDEX GIST (OK!)
CREATE INDEX zensus_population_per_ha_grid_geom_idx
  ON     tmp_destatis.zensus_population_per_ha_grid
  USING GIST (geom);