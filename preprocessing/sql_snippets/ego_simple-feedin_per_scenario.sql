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
CREATE INDEX cosmoclmgrid_geom_gist
  ON calc_renpass_gis.coastdat_spatial
  USING gist
  (geom);

-- get data 
--INSERT INTO calc_renpass_gis.coastdat_spatial
--SELECT *
--FROM coastdat.spatial;


CREATE TABLE model_draft.ego_simple_feedin_full
(
  hour bigint NOT NULL,
  coastdat_id text NOT NULL,
  sub_id text NOT NULL,
  generation_type text NOT NULL,
  feedin text,
  CONSTRAINT ego_simple_feedin_test_pkey PRIMARY KEY (hour, coastdat_id, sub_id, generation_type)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_simple_feedin_full
  OWNER TO oeuser;

-- DROP TABLE model_draft.ego_weather_measurement_point;

CREATE TABLE model_draft.ego_weather_measurement_point
(
  name text NOT NULL,
  type_of_generation text NOT NULL,
  comment text,
  source text,
  scenario text NOT NULL,
  capacity_scale numeric,
  geom geometry(Point,4326),
  CONSTRAINT weather_measurement_point_pkey PRIMARY KEY (name, type_of_generation, scenario)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_weather_measurement_point
  OWNER TO oeuser;

-- DROP INDEX model_draft.ego_weather_measurement_point_geom_gist;
CREATE INDEX ego_weather_measurement_point_geom_gist
  ON model_draft.ego_weather_measurement_point
  USING gist
  (geom);




/*

﻿-- Count duplicates
SELECT 	hour,
	coastdat_id,
	sub_id,
	generation_type, 
	feedin,
	count(*) 
FROM model_draft.ego_simple_feedin_full
GROUP BY hour,coastdat_id,sub_id,generation_type,feedin
HAVING ( COUNT(*) > 1 );


SELECT
  coastdat_id,
  sub_id,
  generation_type,
  count(*)
FROM model_draft.ego_simple_feedin_full
Group by coastdat_id,  sub_id,  generation_type
*/
