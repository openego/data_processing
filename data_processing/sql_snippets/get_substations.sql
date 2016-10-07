-- Copyright 2016 by NEXT ENERGY
-- Published under GNU GENERAL PUBLIC LICENSE Version 3 (see https://github.com/openego/data_processing/blob/master/LICENSE)

DROP TABLE IF EXISTS calc_ego_substation.ego_deu_substations CASCADE;
CREATE TABLE calc_ego_substation.ego_deu_substations (
            subst_id       serial NOT NULL,
            lon            float NOT NULL,
            lat            float NOT NULL,
            point	   geometry(Point,4326) NOT NULL,
            polygon	   geometry NOT NULL,	
            voltage        text,
            power_type     text,
            substation     text,
            osm_id         text PRIMARY KEY NOT NULL,
            osm_www        text NOT NULL,
            frequency      text,
            subst_name     text,
            ref            text,
            operator       text,
            dbahn          text,
            status   	   smallint NOT NULL);

DROP VIEW IF EXISTS calc_ego_substation.final_result CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.substations_to_drop CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.buffer_75 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.buffer_75_a CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.vg250_1_sta_union_mview CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.summary_de CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.summary CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.summary_total CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.netzinseln_110kV CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_substations_without_110kV_intersected_by_110kV_line CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_lines_110kV CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.node_substations_with_110kV CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_substations_without_110kV CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_substations_with_110kV CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_substations CASCADE;

--> WAY: create view of way substations:
CREATE VIEW calc_ego_substation.way_substations AS
SELECT openstreetmap.ego_deu_power_osm_ways.id, openstreetmap.ego_deu_power_osm_ways.tags, openstreetmap.ego_deu_power_osm_polygon.way
FROM openstreetmap.ego_deu_power_osm_ways JOIN openstreetmap.ego_deu_power_osm_polygon ON openstreetmap.ego_deu_power_osm_ways.id = openstreetmap.ego_deu_power_osm_polygon.osm_id
WHERE hstore(openstreetmap.ego_deu_power_osm_ways.tags)->'power' in ('substation','sub_station','station');

--> WAY: create view of way substations with 110kV:
CREATE VIEW calc_ego_substation.way_substations_with_110kV AS
SELECT * 
FROM calc_ego_substation.way_substations
WHERE '110000' = ANY( string_to_array(hstore(calc_ego_substation.way_substations.tags)->'voltage',';')) OR '60000' = ANY( string_to_array(hstore(calc_ego_substation.way_substations.tags)->'voltage',';'));

--> WAY: create view of substations without 110kV
CREATE VIEW calc_ego_substation.way_substations_without_110kV AS
SELECT * 
FROM calc_ego_substation.way_substations
WHERE not '110000' = ANY( string_to_array(hstore(calc_ego_substation.way_substations.tags)->'voltage',';')) AND not '60000' = ANY( string_to_array(hstore(calc_ego_substation.way_substations.tags)->'voltage',';')) or not exist(hstore(calc_ego_substation.way_substations.tags),'voltage');

--> NODE: create view of 110kV node substations:
CREATE VIEW calc_ego_substation.node_substations_with_110kV AS
SELECT openstreetmap.ego_deu_power_osm_nodes.id, openstreetmap.ego_deu_power_osm_nodes.tags, openstreetmap.ego_deu_power_osm_point.way
FROM openstreetmap.ego_deu_power_osm_nodes JOIN openstreetmap.ego_deu_power_osm_point ON openstreetmap.ego_deu_power_osm_nodes.id = openstreetmap.ego_deu_power_osm_point.osm_id
WHERE '110000' = ANY( string_to_array(hstore(openstreetmap.ego_deu_power_osm_nodes.tags)->'voltage',';')) and hstore(openstreetmap.ego_deu_power_osm_nodes.tags)->'power' in ('substation','sub_station','station') OR '60000' = ANY( string_to_array(hstore(openstreetmap.ego_deu_power_osm_nodes.tags)->'voltage',';')) and hstore(openstreetmap.ego_deu_power_osm_nodes.tags)->'power' in ('substation','sub_station','station');

--> LINES 110kV: create view of 110kV lines
CREATE VIEW calc_ego_substation.way_lines_110kV AS
SELECT openstreetmap.ego_deu_power_osm_ways.id, openstreetmap.ego_deu_power_osm_ways.tags, openstreetmap.ego_deu_power_osm_line.way 
FROM openstreetmap.ego_deu_power_osm_ways JOIN openstreetmap.ego_deu_power_osm_line ON openstreetmap.ego_deu_power_osm_ways.id = openstreetmap.ego_deu_power_osm_line.osm_id
WHERE '110000' = ANY( string_to_array(hstore(openstreetmap.ego_deu_power_osm_ways.tags)->'voltage',';')) 
		 AND NOT hstore(openstreetmap.ego_deu_power_osm_ways.tags)->'power' in ('minor_line','razed','dismantled:line','historic:line','construction','planned','proposed','abandoned:line','sub_station','abandoned','substation') OR '60000' = ANY( string_to_array(hstore(openstreetmap.ego_deu_power_osm_ways.tags)->'voltage',';')) 
		 AND NOT hstore(openstreetmap.ego_deu_power_osm_ways.tags)->'power' in ('minor_line','razed','dismantled:line','historic:line','construction','planned','proposed','abandoned:line','sub_station','abandoned','substation');

-- INTERSECTION: create view from substations without 110kV tag that contain 110kV line
CREATE VIEW calc_ego_substation.way_substations_without_110kV_intersected_by_110kV_line AS
SELECT DISTINCT calc_ego_substation.way_substations_without_110kV.* 
FROM calc_ego_substation.way_substations_without_110kV, calc_ego_substation.way_lines_110kV
WHERE ST_Contains(calc_ego_substation.way_substations_without_110kV.way,ST_StartPoint(calc_ego_substation.way_lines_110kV.way)) or ST_Contains(calc_ego_substation.way_substations_without_110kV.way,ST_EndPoint(calc_ego_substation.way_lines_110kV.way));

CREATE VIEW calc_ego_substation.netzinseln_110kV AS
SELECT 	*,
	'http://www.osm.org/way/'|| calc_ego_substation.way_substations_with_110kV.id as osm_www,
	'w'|| calc_ego_substation.way_substations_with_110kV.id as osm_id,
	'1'::smallint as status
FROM calc_ego_substation.way_substations_with_110kV
UNION 
SELECT *,
	'http://www.osm.org/way/'|| calc_ego_substation.way_substations_without_110kV_intersected_by_110kV_line.id as osm_www,
	'w'|| calc_ego_substation.way_substations_without_110kV_intersected_by_110kV_line.id as osm_id,
	'2'::smallint as status
FROM calc_ego_substation.way_substations_without_110kV_intersected_by_110kV_line
UNION 
SELECT *,
	'http://www.osm.org/node/'|| calc_ego_substation.node_substations_with_110kV.id as osm_www,
	'n'|| calc_ego_substation.node_substations_with_110kV.id as osm_id,
	'3'::smallint as status
FROM calc_ego_substation.node_substations_with_110kV;
--
-- create view summary_total that contains substations without any filter
CREATE VIEW calc_ego_substation.summary_total AS
SELECT  ST_X(ST_Centroid(ST_Transform(netzinsel.way,4326))) as lon,
	ST_Y(ST_Centroid(ST_Transform(netzinsel.way,4326))) as lat,
	ST_Centroid(ST_Transform(netzinsel.way,4326)) as point,
	ST_Transform(netzinsel.way,4326) as polygon,
	(CASE WHEN hstore(netzinsel.tags)->'voltage' <> '' THEN hstore(netzinsel.tags)->'voltage' ELSE '110000' END) as voltage, 
        hstore(netzinsel.tags)->'power' as power_type, 
        (CASE WHEN hstore(netzinsel.tags)->'substation' <> '' THEN hstore(netzinsel.tags)->'substation' ELSE 'NA' END) as substation, 
	netzinsel.osm_id as osm_id,
	osm_www,
	(CASE WHEN hstore(netzinsel.tags)->'frequency' <> '' THEN hstore(netzinsel.tags)->'frequency' ELSE 'NA' END) as frequency,
	(CASE WHEN hstore(netzinsel.tags)->'name' <> '' THEN hstore(netzinsel.tags)->'name' ELSE 'NA' END) as subst_name, 
	(CASE WHEN hstore(netzinsel.tags)->'ref' <> '' THEN hstore(netzinsel.tags)->'ref' ELSE 'NA' END) as ref, 
	(CASE WHEN hstore(netzinsel.tags)->'operator' <> '' THEN hstore(netzinsel.tags)->'operator' ELSE 'NA' END) as operator, 
	(CASE WHEN hstore(netzinsel.tags)->'operator' in ('DB_Energie','DB Netz AG','DB Energie GmbH','DB Netz')
	      THEN 'see operator' 
	      ELSE (CASE WHEN '16.7' = ANY( string_to_array(hstore(netzinsel.tags)->'frequency',';')) or '16.67' = ANY( string_to_array(hstore(netzinsel.tags)->'frequency',';')) 
	                 THEN 'see frequency' 
	                 ELSE 'no' 
	                 END)
	      END) as dbahn,
	status
FROM calc_ego_substation.netzinseln_110kV netzinsel ORDER BY osm_www;

-- create view that filters irrelevant tags
CREATE MATERIALIZED VIEW calc_ego_substation.summary AS
SELECT *
FROM calc_ego_substation.summary_total
WHERE dbahn = 'no' AND substation NOT IN ('traction','transition');

CREATE INDEX summary_gix ON calc_ego_substation.summary USING GIST (polygon);

-- eliminate substation that are not within VG250
CREATE MATERIALIZED VIEW calc_ego_substation.vg250_1_sta_union_mview AS 
SELECT 1 AS gid,
    'Bundesrepublik'::text AS bez,
    st_area(un.geom) / 10000::double precision AS area_km2,
    un.geom
FROM ( SELECT st_union(st_transform(vg.geom, 4326))::geometry(MultiPolygon,4326) AS geom
          FROM political_boundary.bkg_vg250_20160101_1_sta vg
          WHERE vg.bez::text = 'Bundesrepublik'::text) un;
CREATE INDEX vg250_1_sta_union_mview_gix ON calc_ego_substation.vg250_1_sta_union_mview USING GIST (geom);

CREATE VIEW calc_ego_substation.summary_de AS
SELECT *
FROM calc_ego_substation.summary, calc_ego_substation.vg250_1_sta_union_mview as vg
WHERE vg.geom && calc_ego_substation.summary.polygon 
AND ST_CONTAINS(vg.geom,calc_ego_substation.summary.polygon);

-- build function to buffer in meters around a geometry 
-- source: http://www.gistutor.com/postgresqlpostgis/6-advanced-postgresqlpostgis-tutorials/58-postgis-buffer-latlong-and-other-projections-using-meters-units-custom-stbuffermeters-function.html

-- Function: utmzone(geometry)
-- DROP FUNCTION utmzone(geometry);
-- Usage: SELECT ST_Transform(the_geom, utmzone(ST_Centroid(the_geom))) FROM sometable;
 
CREATE OR REPLACE FUNCTION utmzone(geometry)
RETURNS integer AS
$BODY$
DECLARE
geomgeog geometry;
zone int;
pref int;
 
BEGIN
geomgeog:= ST_Transform($1,4326);
 
IF (ST_Y(geomgeog))>0 THEN
pref:=32600;
ELSE
pref:=32700;
END IF;
 
zone:=floor((ST_X(geomgeog)+180)/6)+1;
 
RETURN zone+pref;
END;
$BODY$ LANGUAGE 'plpgsql' IMMUTABLE
COST 100;

-- Function: ST_Buffer_Meters(geometry, double precision)
-- DROP FUNCTION ST_Buffer_Meters(geometry, double precision);
-- Usage: SELECT ST_Buffer_Meters(the_geom, num_meters) FROM sometable; 
  
CREATE OR REPLACE FUNCTION ST_Buffer_Meters(geometry, double precision)
RETURNS geometry AS
$BODY$
DECLARE
orig_srid int;
utm_srid int;
 
BEGIN
orig_srid:= ST_SRID($1);
utm_srid:= utmzone(ST_Centroid($1));
 
RETURN ST_transform(ST_Buffer(ST_transform($1, utm_srid), $2), orig_srid);
END;
$BODY$ LANGUAGE 'plpgsql' IMMUTABLE
COST 100;

-- create view with buffer of 75m around polygons
CREATE MATERIALIZED VIEW calc_ego_substation.buffer_75 AS
SELECT osm_id, ST_Area(ST_Transform(calc_ego_substation.summary_de.polygon,4326)) as area, ST_Buffer_Meters(ST_Transform(calc_ego_substation.summary_de.polygon,4326), 75) as buffer_75
FROM calc_ego_substation.summary_de;

-- create second view with same data to compare
CREATE MATERIALIZED VIEW calc_ego_substation.buffer_75_a AS
SELECT osm_id, ST_Area(ST_Transform(calc_ego_substation.summary_de.polygon,4326)) as area_a, ST_Buffer_Meters(ST_Transform(calc_ego_substation.summary_de.polygon,4326), 75) as buffer_75_a
FROM calc_ego_substation.summary_de;

-- create view to eliminate smaller substations where buffers intersect
CREATE MATERIALIZED VIEW calc_ego_substation.substations_to_drop AS
SELECT DISTINCT
(CASE WHEN calc_ego_substation.buffer_75.area < calc_ego_substation.buffer_75_a.area_a THEN calc_ego_substation.buffer_75.osm_id ELSE calc_ego_substation.buffer_75_a.osm_id END) as osm_id,
(CASE WHEN calc_ego_substation.buffer_75.area < calc_ego_substation.buffer_75_a.area_a THEN calc_ego_substation.buffer_75.area ELSE calc_ego_substation.buffer_75_a.area_a END) as area,
(CASE WHEN calc_ego_substation.buffer_75.area < calc_ego_substation.buffer_75_a.area_a THEN calc_ego_substation.buffer_75.buffer_75 ELSE calc_ego_substation.buffer_75_a.buffer_75_a END) as buffer
FROM calc_ego_substation.buffer_75, calc_ego_substation.buffer_75_a
WHERE ST_Intersects(calc_ego_substation.buffer_75.buffer_75, calc_ego_substation.buffer_75_a.buffer_75_a)
AND NOT calc_ego_substation.buffer_75.osm_id = calc_ego_substation.buffer_75_a.osm_id;

-- filter those substations and create final_result
CREATE VIEW calc_ego_substation.final_result AS
SELECT * 
FROM calc_ego_substation.summary_de
WHERE calc_ego_substation.summary_de.osm_id NOT IN ( SELECT calc_ego_substation.substations_to_drop.osm_id FROM calc_ego_substation.substations_to_drop);

INSERT INTO calc_ego_substation.ego_deu_substations (lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, subst_name, ref, operator, dbahn, status)
SELECT lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, subst_name, ref, operator, dbahn, status
FROM calc_ego_substation.final_result;

DROP VIEW IF EXISTS calc_ego_substation.final_result CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.substations_to_drop CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.buffer_75 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.buffer_75_a CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.vg250_1_sta_union_mview CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.summary_de CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.summary CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.summary_total CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.netzinseln_110kV CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_substations_without_110kV_intersected_by_110kV_line CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_lines_110kV CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.node_substations_with_110kV CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_substations_without_110kV CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_substations_with_110kV CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_substations CASCADE;

GRANT ALL ON TABLE calc_ego_substation.ego_deu_substations TO oeuser WITH GRANT OPTION;
ALTER TABLE calc_ego_substation.ego_deu_substations OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'calc_ego_substation' AS schema_name,
		'ego_deu_substations' AS table_name,
		'get_substations.sql' AS script_name,
		COUNT(subst_id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_substation.ego_deu_substations;
        
