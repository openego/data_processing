/*
Setup simple feedin weather measurement point

__copyright__ 	= "Europa-Universität Flensburg, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	    = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	    = "wolfbunke, MarlonSchlemminger"
*/


-- DROP TABLE calc_renpass_gis.coastdat_spatial CASCADE;-- 
-- CREATE TABLE calc_renpass_gis.coastdat_spatial 
-- (
--   gid serial NOT NULL,
--   geom geometry(Point,4326),
--   CONSTRAINT spatial_pkey PRIMARY KEY (gid)
-- )
-- WITH (
--   OIDS=FALSE
-- );
-- ALTER TABLE calc_renpass_gis.cosmoclmgrid
--   OWNER TO oeuser;
-- 
-- -- Index: calc_renpass_gis.coastdat_spatial
-- 
-- -- DROP INDEX calc_renpass_gis.coastdat_spatial_geom_gist;
-- CREATE INDEX coastdat_spatial_geom_gist
--   ON calc_renpass_gis.coastdat_spatial
--   USING gist
--   (geom);
-- 
-- -- get data 
-- --INSERT INTO calc_renpass_gis.coastdat_spatial
-- --SELECT *
-- --FROM coastdat.spatial;
-- /*
-- -- Table: model_draft.ego_simple_feedin_full
-- -- DROP TABLE model_draft.ego_simple_feedin_full;
-- 
-- -- DROP TABLE calc_renpass_gis.cosmoclmgrid CASCADE;
-- CREATE TABLE calc_renpass_gis.cosmoclmgrid
-- (
--   gid serial NOT NULL,
--   geom geometry(MultiPolygon,4326),
--   CONSTRAINT cosmoclmgrid_pkey PRIMARY KEY (gid)
-- ) 
-- WITH (
--   OIDS=FALSE
-- );
-- ALTER TABLE calc_renpass_gis.cosmoclmgrid
--   OWNER TO oeuser;
-- 
-- -- Index: calc_renpass_gis.coastdat_spatial
-- -- DROP INDEX calc_renpass_gis.cosmoclmgrid_geom_gist;
-- CREATE INDEX cosmoclmgrid_geom_gist
--   ON calc_renpass_gis.cosmoclmgrid
--   USING gist
--   (geom);
-- 
-- -- get data 
-- --INSERT INTO calc_renpass_gis.cosmoclmgrid
-- --SELECT *
-- --FROM coastdat.cosmoclmgrid;
-- see: climate.cosmoclmgrid
-- */
-- 
-- -- Set cosmoclmgrid gid as costdat_id to:
-- Update model_draft.ego_dp_supply_conv_powerplant as C
--   set coastdat_gid = b.gid
-- From climate.cosmoclmgrid B
-- Where ST_Intersects(B.geom,C.geom);
-- 
-- Update model_draft.ego_dp_supply_res_powerplant as C
--   set coastdat_gid = gid
-- From climate.cosmoclmgrid B
-- Where ST_Intersects(B.geom,C.geom);
-- 

DROP TABLE IF EXISTS model_draft.ego_neighbours_offshore_point;

CREATE TABLE model_draft.ego_neighbours_offshore_point
(
  cntr_id text NOT NULL,
  coastdat_id bigint, 
  geom geometry(Point,4326),
  CONSTRAINT neighbours_offshore_point_pkey PRIMARY KEY (cntr_id)
);

INSERT INTO model_draft.ego_neighbours_offshore_point (cntr_id, geom)
VALUES
('DK', ST_SetSRID(ST_MakePoint(7.59, 55.6), 4326)),
('NL', ST_SetSRID(ST_MakePoint(5.883333, 54.183333), 4326)),
('NO', ST_SetSRID(ST_MakePoint(6.327633, 58.269992), 4326)),
('FR', ST_SetSRID(ST_MakePoint(0.227, 49.892), 4326)),
('SE', ST_SetSRID(ST_MakePoint(14.993694, 55.9375), 4326)),
('PL', ST_SetSRID(ST_MakePoint(17.3333333333, 55.000), 4326))
;

UPDATE model_draft.ego_neighbours_offshore_point a
	SET coastdat_id = climate.gid
		FROM climate.cosmoclmgrid AS climate
		WHERE ST_Intersects(climate.geom, a.geom)
;

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
-- ALTER TABLE model_draft.ego_weather_measurement_point
--   OWNER TO oeuser;

-- german points
INSERT INTO model_draft.ego_weather_measurement_point (coastdat_id, type_of_generation, geom)
SELECT 
	coastdat.gid,
	'solar',
	ST_Centroid(coastdat.geom)
FROM climate.cosmoclmgrid AS coastdat,
	(SELECT ST_Transform(ST_Union(geom), 4326) AS geom
	FROM boundaries.bkg_vg250_1_sta
	WHERE reference_date = '2015-01-01') AS ger
WHERE ST_Intersects(ger.geom, coastdat.geom);


INSERT INTO model_draft.ego_weather_measurement_point (coastdat_id, type_of_generation, geom)
SELECT 
	coastdat.gid,
	'wind_onshore',
	ST_Centroid(coastdat.geom)
FROM climate.cosmoclmgrid AS coastdat,
	(SELECT ST_Transform(ST_Union(geom), 4326) AS geom
	FROM boundaries.bkg_vg250_1_sta
	WHERE reference_date = '2015-01-01') AS ger
WHERE ST_Intersects(ger.geom, coastdat.geom);

INSERT INTO model_draft.ego_weather_measurement_point (coastdat_id, type_of_generation, geom)
SELECT 
	coastdat.gid,
	'wind_offshore',
	ST_Centroid(coastdat.geom)
FROM climate.cosmoclmgrid AS coastdat, 
	(SELECT ST_Union(geom) AS geom FROM model_draft.renpass_gis_parameter_region WHERE u_region_id LIKE 'DEow%') AS offshore
WHERE ST_Intersects(offshore.geom, coastdat.geom);

--foreign points
INSERT INTO model_draft.ego_weather_measurement_point (coastdat_id, type_of_generation, geom)
SELECT 
	coastdat.gid,
	'solar',
	neighbour.geom
FROM climate.cosmoclmgrid AS coastdat,
	model_draft.ego_grid_hv_electrical_neighbours_bus AS neighbour
WHERE ST_Intersects(neighbour.geom, coastdat.geom)
ON CONFLICT DO NOTHING;


INSERT INTO model_draft.ego_weather_measurement_point (coastdat_id, type_of_generation, geom)
SELECT 
	coastdat.gid,
	'wind_onshore',
	neighbour.geom
FROM climate.cosmoclmgrid AS coastdat,
	model_draft.ego_grid_hv_electrical_neighbours_bus AS neighbour
WHERE ST_Intersects(neighbour.geom, coastdat.geom)
ON CONFLICT DO NOTHING;

INSERT INTO model_draft.ego_weather_measurement_point (coastdat_id, type_of_generation, geom)
SELECT 
	coastdat.gid,
	'wind_offshore',
	neighbour.geom
FROM climate.cosmoclmgrid AS coastdat,
	model_draft.ego_neighbours_offshore_point AS neighbour
WHERE ST_Intersects(neighbour.geom, coastdat.geom)
ON CONFLICT DO NOTHING;