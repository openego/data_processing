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

COMMENT ON TABLE model_draft.ego_neighbours_offshore_point IS '{
	"title": "model_draft.ego_neighbours_offshore_point",
	"description": "Geometry of offshore windparks of Germanys electrical neighbours",
	"language": [],
	"spatial": 
		{"location": "Electrical neighbours of Germany",
		"extent": "",
		"resolution": ""},
	"temporal": 
		{"reference_date": "",
		"start": "",
		"end": "",
		"resolution": ""},
	"sources": [
		{"name": "FlEnS data", "description": "", "url": "https://github.com/znes/FlEnS/blob/master/open_eGo/modelpowerplants.geojson", "license": "", "copyright": ""} ],
	"license": 
		{"id": "",
		"name": "",
		"version": "",
		"url": "",
		"instruction": "",
		"copyright": ""},
	"contributors": [
		{"name": "Marlon Schlemminger", "email": "marlon@wmkamp46a.de", "date": "13.03.2018", "comment": ""}],
	"resources": [
		{"name": "",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "cntr_id", "description": "Country identifier", "unit": ""},
			{"name": "coastdat_id", "description": "Coasdat2 identifier", "unit": ""},
			{"name": "geom", "description": "Geometry", "unit": ""} ] } ],
	"metadata_version": "1.3"}';

-- select description
SELECT obj_description('model_draft.ego_neighbours_offshore_point' ::regclass) ::json;

DROP TABLE IF EXISTS model_draft.ego_weather_measurement_point;

CREATE TABLE model_draft.ego_weather_measurement_point
(
  coastdat_id bigint NOT NULL,
  type_of_generation text NOT NULL,
  wea_type text,
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

-- set wea_type
UPDATE model_draft.ego_weather_measurement_point
SET wea_type = wea
FROM (SELECT gid, wea_manufacturer||' '||wea_type AS wea
	FROM 
		(SELECT gid, wea_manufacturer, wea_type, COUNT(*) as cnt,
		ROW_NUMBER() OVER (PARTITION BY gid ORDER BY COUNT(*) DESC) AS rnk
		FROM climate.cosmoclmgrid a, model_draft.bnetza_eeg_anlagenstammdaten_wind_classification b
		WHERE ST_Intersects(a.geom, ST_Transform(b.geom, 4326))
		AND wea_type <> 'na'
		AND seelage IS NULL
		GROUP BY gid, wea_manufacturer, wea_type
		) as tg
	WHERE rnk = 1
	) a
WHERE coastdat_id = gid
AND type_of_generation = 'wind_onshore';

UPDATE model_draft.ego_weather_measurement_point
SET wea_type = wea
FROM (SELECT gid, wea_manufacturer||' '||wea_type AS wea
	FROM 
		(SELECT gid, wea_manufacturer, wea_type, COUNT(*) as cnt,
		ROW_NUMBER() OVER (PARTITION BY gid ORDER BY COUNT(*) DESC) AS rnk
		FROM climate.cosmoclmgrid a, model_draft.bnetza_eeg_anlagenstammdaten_wind_classification b
		WHERE ST_Intersects(a.geom, ST_Transform(b.geom, 4326))
		AND wea_type <> 'na'
		AND seelage IS NOT NULL
		GROUP BY gid, wea_manufacturer, wea_type
		) as tg
	WHERE rnk = 1
	) a
WHERE coastdat_id = gid
AND type_of_generation = 'wind_offshore';

DELETE FROM model_draft.ego_weather_measurement_point
WHERE wea_type IS NULL
AND type_of_generation IN ('wind_onshore', 'wind_offshore');

-- get data for most used wind turbines
DROP TABLE IF EXISTS model_draft.ego_wind_turbine_data;

CREATE TABLE model_draft.ego_wind_turbine_data
(
  type_of_generation text NOT NULL,
  wea text NOT NULL,
  d_rotor double precision NOT NULL,
  h_hub double precision NOT NULL,
  CONSTRAINT wind_turbine_data_pkey PRIMARY KEY (type_of_generation, wea)
  );
  
INSERT INTO model_draft.ego_wind_turbine_data (type_of_generation, wea, d_rotor, h_hub)
	(SELECT 'wind_onshore',
	wea_manufacturer||' '||wea_type,
	rotordurchmesser,
	nabenhöhe
	FROM 
		(SELECT wea_manufacturer, wea_type, rotordurchmesser, nabenhöhe, COUNT(*) AS cnt,
		ROW_NUMBER() OVER (PARTITION BY wea_type ORDER BY COUNT(*) DESC) AS rnk
		FROM model_draft.bnetza_eeg_anlagenstammdaten_wind_classification
		WHERE wea_type <> 'na'
		AND seelage IS NULL
		GROUP BY wea_manufacturer, wea_type, rotordurchmesser, nabenhöhe
		) AS tg
	WHERE rnk = 1
	AND wea_manufacturer||' '||wea_type IN (SELECT wea_type FROM model_draft.ego_weather_measurement_point)
	);

INSERT INTO model_draft.ego_wind_turbine_data (type_of_generation, wea, d_rotor, h_hub)
	(SELECT 'wind_offshore',
	wea_manufacturer||' '||wea_type,
	rotordurchmesser,
	nabenhöhe
	FROM 
		(SELECT wea_manufacturer, wea_type, rotordurchmesser, nabenhöhe, COUNT(*) AS cnt,
		ROW_NUMBER() OVER (PARTITION BY wea_type ORDER BY COUNT(*) DESC) AS rnk
		FROM model_draft.bnetza_eeg_anlagenstammdaten_wind_classification
		WHERE wea_type <> 'na'
		AND seelage IS NOT NULL
		GROUP BY wea_manufacturer, wea_type, rotordurchmesser, nabenhöhe
		) AS tg
	WHERE rnk = 1
	AND wea_manufacturer||' '||wea_type IN (SELECT wea_type FROM model_draft.ego_weather_measurement_point)
	);

COMMENT ON TABLE model_draft.ego_weather_measurement_point IS '{
	"title": "model_draft.ego_weather_measurement_point",
	"description": "Geometry of weather points for feedin timeseries calculation",
	"language": [],
	"spatial": 
		{"location": "Germany and its electrical neighbours and Baltic Sea/North Sea",
		"extent": "",
		"resolution": "Coasdat2 weather cells"},
	"temporal": 
		{"reference_date": "",
		"start": "",
		"end": "",
		"resolution": ""},
	"sources": [
		{"name": "open_eGo dataprocessing", "description": "", "url": "https://github.com/openego/data_processing", "license": "", "copyright": ""} ],
	"license": 
		{"id": "",
		"name": "",
		"version": "",
		"url": "",
		"instruction": "",
		"copyright": ""},
	"contributors": [
		{"name": "Marlon Schlemminger", "email": "marlon@wmkamp46a.de", "date": "13.03.2018", "comment": ""}],
	"resources": [
		{"name": "",		
		"format": "PostgreSQL",
		"fields": [
			{"name": "type_of_generation", "description": "Type of renewable generation", "unit": ""},
			{"name": "coastdat_id", "description": "Coasdat2 identifier", "unit": ""},
			{"name": "geom", "description": "Geometry", "unit": ""} ] } ],
	"metadata_version": "1.3"}';

SELECT obj_description('model_draft.ego_weather_measurement_point' ::regclass) ::json;