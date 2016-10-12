/* 
Create different lattice for Germany 500m / 50m / (34m)
*/

-- Create a lattice on the bbox of Germany with 500m
DROP TABLE IF EXISTS 	model_draft.deu_lattice_500m;
CREATE TABLE 			model_draft.deu_lattice_500m AS
SELECT ST_SETSRID(ST_CreateFishnet(
	ROUND((ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))) /500)::integer,
	ROUND((ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))) /500)::integer,
	500,
	500,
	ST_xmin (box2d(geom)),
	ST_ymin (box2d(geom))
									),3035)::geometry(POLYGON,3035) AS geom
FROM (SELECT ST_TRANSFORM(ST_UNION(geom),3035) AS geom FROM orig_vg250.vg250_1_sta) AS t1 ;

-- Add ID
ALTER TABLE model_draft.deu_lattice_500m ADD "id" SERIAL;
ALTER TABLE model_draft.deu_lattice_500m ADD CONSTRAINT dea_grid_pkey PRIMARY KEY(id);

-- Add GIST Index
CREATE INDEX deu_lattice_500m_geom_idx
  ON model_draft.deu_lattice_500m
  USING gist
  (geom);

-- Grant oeuser   
GRANT ALL ON TABLE 	model_draft.deu_lattice_500m TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.deu_lattice_500m OWNER TO oeuser;