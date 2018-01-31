/*
Setup simple feedin weather measurement point

__copyright__ 	= "Europa-Universität Flensburg, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	    = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	    = "wolfbunke"
*/


-- DROP TABLE calc_renpass_gis.coastdat_spatial CASCADE;
CREATE TABLE calc_renpass_gis.coastdat_spatial 
(
  gid serial NOT NULL,
  geom geometry(Point,4326),
  CONSTRAINT spatial_pkey PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE calc_renpass_gis.cosmoclmgrid
  OWNER TO oeuser;

-- Index: calc_renpass_gis.coastdat_spatial

-- DROP INDEX calc_renpass_gis.coastdat_spatial_geom_gist;
CREATE INDEX coastdat_spatial_geom_gist
  ON calc_renpass_gis.coastdat_spatial
  USING gist
  (geom);

-- get data 
--INSERT INTO calc_renpass_gis.coastdat_spatial
--SELECT *
--FROM coastdat.spatial;
/*
-- Table: model_draft.ego_simple_feedin_full
-- DROP TABLE model_draft.ego_simple_feedin_full;

-- DROP TABLE calc_renpass_gis.cosmoclmgrid CASCADE;
CREATE TABLE calc_renpass_gis.cosmoclmgrid
(
  gid serial NOT NULL,
  geom geometry(MultiPolygon,4326),
  CONSTRAINT cosmoclmgrid_pkey PRIMARY KEY (gid)
) 
WITH (
  OIDS=FALSE
);
ALTER TABLE calc_renpass_gis.cosmoclmgrid
  OWNER TO oeuser;

-- Index: calc_renpass_gis.coastdat_spatial
-- DROP INDEX calc_renpass_gis.cosmoclmgrid_geom_gist;
CREATE INDEX cosmoclmgrid_geom_gist
  ON calc_renpass_gis.cosmoclmgrid
  USING gist
  (geom);

-- get data 
--INSERT INTO calc_renpass_gis.cosmoclmgrid
--SELECT *
--FROM coastdat.cosmoclmgrid;
see: climate.cosmoclmgrid
*/

-- Set cosmoclmgrid gid as costdat_id to:
Update model_draft.ego_dp_supply_conv_powerplant as C
  set coastdat_gid = b.gid
From climate.cosmoclmgrid B
Where ST_Intersects(B.geom,C.geom);

Update model_draft.ego_dp_supply_res_powerplant as C
  set coastdat_gid = gid
From climate.cosmoclmgrid B
Where ST_Intersects(B.geom,C.geom);

DROP TABLE IF EXISTS model_draft.ego_weather_measurement_point;

CREATE TABLE model_draft.ego_weather_measurement_point
(
  coastdat_id bigint NOT NULL,
  type_of_generation text NOT NULL,
  geom geometry(Point,4326),
  CONSTRAINT weather_measurement_point_pkey PRIMARY KEY (coastdat_id, type_of_generation)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_weather_measurement_point
  OWNER TO postgres;

-- german points
INSERT INTO model_draft.ego_weather_measurement_point (coastdat_id, type_of_generation, geom)
SELECT 
	coastdat.gid,
	'solar',
	ST_Centroid(coastdat.geom)
FROM coastdat.cosmoclmgrid AS coastdat, 
	(SELECT ST_Transform(ST_Union(geom), 4326) AS geom
	FROM boundaries.bkg_vg250_1_sta
	WHERE reference_date = '2015-01-01') AS ger
WHERE ST_Intersects(ger.geom, coastdat.geom);


INSERT INTO model_draft.ego_weather_measurement_point (coastdat_id, type_of_generation, geom)
SELECT 
	coastdat.gid,
	'windonshore',
	ST_Centroid(coastdat.geom)
FROM coastdat.cosmoclmgrid AS coastdat, 
	(SELECT ST_Transform(ST_Union(geom), 4326) AS geom
	FROM boundaries.bkg_vg250_1_sta
	WHERE reference_date = '2015-01-01') AS ger
WHERE ST_Intersects(ger.geom, coastdat.geom);

--foreign points
INSERT INTO model_draft.ego_weather_measurement_point (coastdat_id, type_of_generation, geom)
SELECT 
	coastdat.gid,
	'solar',
	neighbour.geom
FROM coastdat.cosmoclmgrid AS coastdat,
	model_draft.ego_grid_hv_electrical_neighbours_bus AS neighbour
WHERE ST_Intersects(neighbour.geom, coastdat.geom)
ON CONFLICT DO NOTHING;


INSERT INTO model_draft.ego_weather_measurement_point (coastdat_id, type_of_generation, geom)
SELECT 
	coastdat.gid,
	'windonshore',
	neighbour.geom
FROM coastdat.cosmoclmgrid AS coastdat,
	model_draft.ego_grid_hv_electrical_neighbours_bus AS neighbour
WHERE ST_Intersects(neighbour.geom, coastdat.geom)
ON CONFLICT DO NOTHING;

-- offshore points both foreign and germans
INSERT INTO model_draft.ego_weather_measurement_point (coastdat_id, type_of_generation, geom)
SELECT 
	coastdat.gid,
	'windoffshore',
	ST_FlipCoordinates(offshore.column1)
FROM coastdat.cosmoclmgrid AS coastdat,
	(SELECT * FROM (VALUES (st_SetSrid(st_MakePoint(54.366667, 5.983333), 4326)::geometry(Point, 4326)),
	(st_SetSrid(st_MakePoint(55.6, 7.59), 4326)::geometry(Point, 4326)),
	(st_SetSrid(st_MakePoint(54.183333, 5.883333), 4326)::geometry(Point, 4326)),
	(st_SetSrid(st_MakePoint(58.269992, 6.327633), 4326)::geometry(Point, 4326)),
	(st_SetSrid(st_MakePoint(49.892, 0.227), 4326)::geometry(Point, 4326)),
	(st_SetSrid(st_MakePoint(55.9375, 14.993694), 4326)::geometry(Point, 4326)),
	(st_SetSrid(st_MakePoint(55.000, 17.3333333333), 4326)::geometry(Point, 4326))) AS geom) AS offshore
WHERE ST_Intersects(ST_FlipCoordinates(offshore.column1), coastdat.geom);

























