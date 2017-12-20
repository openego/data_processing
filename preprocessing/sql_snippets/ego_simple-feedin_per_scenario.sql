﻿/*
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


CREATE TABLE model_draft.ego_simple_feedin_full
(
  hour text NOT NULL,
  coastdat_id text bigint NOT NULL,
  sub_id text bigint,
  generation_type text NOT NULL,
  feedin text,
  scenario text NOT NULL,
  CONSTRAINT ego_simple_feedin_full_pkey PRIMARY KEY (scenario, coastdat_id, sub_id, generation_type, hour)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_simple_feedin_full
  OWNER TO oeuser;

-- Index: model_draft.ego_simple_feedin_full_idx
-- DROP INDEX model_draft.ego_simple_feedin_full_idx;

CREATE INDEX ego_simple_feedin_full_idx
  ON model_draft.ego_simple_feedin_full
  USING btree
  (scenario COLLATE pg_catalog."default", sub_id COLLATE pg_catalog."default");
--
/*
ALTER TABLE  model_draft.ego_simple_feedin_full
  ALTER COLUMN hour TYPE bigint USING hour::bigint;

ALTER TABLE  model_draft.ego_simple_feedin_full
  ALTER COLUMN coastdat_id TYPE bigint USING coastdat_id::bigint;

Update model_draft.ego_simple_feedin_full
    set sub_id = NULL
    WHERE sub_id ='_NULL_'  
    
ALTER TABLE  model_draft.ego_simple_feedin_full
  ALTER COLUMN sub_id TYPE bigint USING sub_id::bigint;
  
ALTER TABLE  model_draft.ego_simple_feedin_full
  ALTER COLUMN feedin TYPE numeric(23,20) USING feedin::numeric(23,20);
*/


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
-- Count duplicates
SELECT 	hour,
	coastdat_id,
	sub_id,
	generation_type, 
	feedin,
	count(*) 
FROM model_draft.ego_simple_feedin_full
GROUP BY hour,coastdat_id,sub_id,generation_type,feedin
HAVING ( COUNT(*) > 1 );
*/
-- 
-- Create weighten feedin curve py types and scenario
Alter Table model_draft.ego_simple_feedin_full 
add column weighted_feedin numeric(23,20);
--
Update model_draft.ego_simple_feedin_full ts
  set weighted_feedin = ts.feedin * mp.capacity_scale
FROM 
  model_draft.ego_weather_measurement_point mp
WHERE split_part(mp.name, '_', 1)::int = ts.coastdat_id  
AND split_part(mp.name, '_', 2)::int  = ts.sub_id 
AND mp.type_of_generation = ts.generation_type
AND mp.scenario =  ts.scenario
AND REGEXP_REPLACE(COALESCE(split_part(name, '_', 2), '0'), '[^0-9]*' ,'0')::integer !=0;

-- DROP MATERIALIZED VIEW IF EXISTS  model_draft.ego_renpassgis_simple_feedin_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_renpassgis_simple_feedin_mview AS
SELECT
hour, 
generation_type,
scenario,
sum(weighted_feedin) as total_cap_feedin
FROM model_draft.ego_simple_feedin_full
Group by hour, generation_type, scenario
Order by generation_type, scenario, hour
;

-- grant (oeuser)
ALTER TABLE model_draft.ego_renpassgis_simple_feedin_mview OWNER TO oeuser;