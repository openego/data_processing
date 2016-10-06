-- Copyright 2016 by NEXT ENERGY
-- Published under GNU GENERAL PUBLIC LICENSE Version 3 (see https://github.com/openego/data_processing/blob/master/LICENSE)

DROP TABLE IF EXISTS calc_ego_substation.ego_deu_substations_ehv CASCADE;
CREATE TABLE calc_ego_substation.ego_deu_substations_ehv (
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

DROP VIEW IF EXISTS calc_ego_substation.final_result_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.substations_to_drop_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.buffer_75_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.buffer_75_a_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.vg250_1_sta_union_mview CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.summary_de_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.summary_hoes CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.summary_total_hoes CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.netzinseln_hoes CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.relation_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.node_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_substations CASCADE;

--> WAY: Erzeuge einen VIEW aus OSM way substations:
CREATE VIEW calc_ego_substation.way_substations AS
SELECT openstreetmap.ego_deu_power_osm_ways.id, openstreetmap.ego_deu_power_osm_ways.tags, openstreetmap.ego_deu_power_osm_polygon.way
FROM openstreetmap.ego_deu_power_osm_ways JOIN openstreetmap.ego_deu_power_osm_polygon ON openstreetmap.ego_deu_power_osm_ways.id = openstreetmap.ego_deu_power_osm_polygon.osm_id
WHERE hstore(openstreetmap.ego_deu_power_osm_ways.tags)->'power' in ('substation','sub_station','station');

CREATE VIEW calc_ego_substation.way_substations_with_hoes AS
SELECT * 
FROM calc_ego_substation.way_substations
WHERE '220000' = ANY( string_to_array(hstore(calc_ego_substation.way_substations.tags)->'voltage',';')) OR '380000' = ANY( string_to_array(hstore(calc_ego_substation.way_substations.tags)->'voltage',';')); 

--> NODE: Erzeuge einen VIEW aus OSM node substations:
CREATE VIEW calc_ego_substation.node_substations_with_hoes AS
SELECT openstreetmap.ego_deu_power_osm_nodes.id, openstreetmap.ego_deu_power_osm_nodes.tags, openstreetmap.ego_deu_power_osm_point.way
FROM openstreetmap.ego_deu_power_osm_nodes JOIN openstreetmap.ego_deu_power_osm_point ON openstreetmap.ego_deu_power_osm_nodes.id = openstreetmap.ego_deu_power_osm_point.osm_id
WHERE '220000' = ANY( string_to_array(hstore(openstreetmap.ego_deu_power_osm_nodes.tags)->'voltage',';')) and hstore(openstreetmap.ego_deu_power_osm_nodes.tags)->'power' in ('substation','sub_station','station') OR '380000' = ANY( string_to_array(hstore(openstreetmap.ego_deu_power_osm_nodes.tags)->'voltage',';')) and hstore(openstreetmap.ego_deu_power_osm_nodes.tags)->'power' in ('substation','sub_station','station');

--> RELATION: Erzeuge einen VIEW aus OSM relation substations:
-- Da die relations keine geometry besitzen wird mit folgender funktion der geometrische mittelpunkt der relation ermittelt, 
-- wobei hier der Mittelpunkt aus dem Rechteck ermittelt wird welches entsteht, wenn man die äußersten Korrdinaten für
-- longitude und latitude wählt
-- Funktion erzeugt aus den relation parts vom type way einen gemittelten geometry point
DROP FUNCTION IF EXISTS relation_geometry (members text[]) ;
CREATE OR REPLACE FUNCTION relation_geometry (members text[]) 
RETURNS geometry 
AS $$
DECLARE 
way  geometry;
BEGIN
   way = (SELECT ST_SetSRID(ST_MakePoint((max(lon) + min(lon))/200.0,(max(lat) + min(lat))/200.0),900913) 
	  FROM openstreetmap.ego_deu_power_osm_nodes 
	  WHERE id in (SELECT unnest(nodes) 
             FROM openstreetmap.ego_deu_power_osm_ways 
             WHERE id in (SELECT trim(leading 'w' from member)::bigint 
			  FROM (SELECT unnest(members) as member) t
	                  WHERE member~E'[w,1,2,3,4,5,6,7,8,9,0]')));        
RETURN way;
END;
$$ LANGUAGE plpgsql;

CREATE VIEW calc_ego_substation.relation_substations_with_hoes AS
SELECT openstreetmap.ego_deu_power_osm_rels.id, openstreetmap.ego_deu_power_osm_rels.tags, relation_geometry(openstreetmap.ego_deu_power_osm_rels.members) as way
FROM openstreetmap.ego_deu_power_osm_rels 
WHERE '220000' = ANY( string_to_array(hstore(openstreetmap.ego_deu_power_osm_rels.tags)->'voltage',';')) and hstore(openstreetmap.ego_deu_power_osm_rels.tags)->'power' in ('substation','sub_station','station') OR '380000' = ANY( string_to_array(hstore(openstreetmap.ego_deu_power_osm_rels.tags)->'voltage',';')) and hstore(openstreetmap.ego_deu_power_osm_rels.tags)->'power' in ('substation','sub_station','station');

CREATE VIEW calc_ego_substation.netzinseln_hoes AS
SELECT  *,
	'http://www.osm.org/relation/'|| calc_ego_substation.relation_substations_with_hoes.id as osm_www,
	'r'|| calc_ego_substation.relation_substations_with_hoes.id as osm_id,
	'1'::smallint as status
FROM calc_ego_substation.relation_substations_with_hoes
UNION
SELECT 	*,
	'http://www.osm.org/way/'|| calc_ego_substation.way_substations_with_hoes.id as osm_www,
	'w'|| calc_ego_substation.way_substations_with_hoes.id as osm_id,
	'2'::smallint as status
FROM calc_ego_substation.way_substations_with_hoes
UNION 
SELECT *,
	'http://www.osm.org/node/'|| calc_ego_substation.node_substations_with_hoes.id as osm_www,
	'n'|| calc_ego_substation.node_substations_with_hoes.id as osm_id,
	'4'::smallint as status
FROM calc_ego_substation.node_substations_with_hoes;

-- create view summary_total_hoes that contains substations without any filter
CREATE VIEW calc_ego_substation.summary_total_hoes AS
SELECT  ST_X(ST_Centroid(ST_Transform(netzinsel.way,4326))) as lon,
	ST_Y(ST_Centroid(ST_Transform(netzinsel.way,4326))) as lat,
	ST_Centroid(ST_Transform(netzinsel.way,4326)) as point,
	ST_Transform(netzinsel.way,4326) as polygon,
	(CASE WHEN hstore(netzinsel.tags)->'voltage' <> '' THEN hstore(netzinsel.tags)->'voltage' ELSE 'hoes' END) as voltage, 
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
FROM calc_ego_substation.netzinseln_hoes netzinsel ORDER BY osm_www;

-- create view that filters irrelevant tags
CREATE MATERIALIZED VIEW calc_ego_substation.summary_hoes AS
SELECT *
FROM calc_ego_substation.summary_total_hoes
WHERE dbahn = 'no' AND substation NOT IN ('traction','transition');

CREATE INDEX summary_hoes_gix ON calc_ego_substation.summary_hoes USING GIST (polygon);

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

CREATE VIEW calc_ego_substation.summary_de_hoes AS
SELECT *
FROM calc_ego_substation.summary_hoes, calc_ego_substation.vg250_1_sta_union_mview as vg
WHERE vg.geom && calc_ego_substation.summary_hoes.polygon 
AND ST_CONTAINS(vg.geom,calc_ego_substation.summary_hoes.polygon);

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
CREATE MATERIALIZED VIEW calc_ego_substation.buffer_75_hoes AS
SELECT osm_id, ST_Area(ST_Transform(calc_ego_substation.summary_de_hoes.polygon,4326)) as area, ST_Buffer_Meters(ST_Transform(calc_ego_substation.summary_de_hoes.polygon,4326), 75) as buffer_75
FROM calc_ego_substation.summary_de_hoes;

-- create second view with same data to compare
CREATE MATERIALIZED VIEW calc_ego_substation.buffer_75_a_hoes AS
SELECT osm_id, ST_Area(ST_Transform(calc_ego_substation.summary_de_hoes.polygon,4326)) as area_a, ST_Buffer_Meters(ST_Transform(calc_ego_substation.summary_de_hoes.polygon,4326), 75) as buffer_75_a
FROM calc_ego_substation.summary_de_hoes;

-- create view to eliminate smaller substations where buffers intersect
CREATE MATERIALIZED VIEW calc_ego_substation.substations_to_drop_hoes AS
SELECT DISTINCT
(CASE WHEN calc_ego_substation.buffer_75_hoes.area < calc_ego_substation.buffer_75_a_hoes.area_a THEN calc_ego_substation.buffer_75_hoes.osm_id ELSE calc_ego_substation.buffer_75_a_hoes.osm_id END) as osm_id,
(CASE WHEN calc_ego_substation.buffer_75_hoes.area < calc_ego_substation.buffer_75_a_hoes.area_a THEN calc_ego_substation.buffer_75_hoes.area ELSE calc_ego_substation.buffer_75_a_hoes.area_a END) as area,
(CASE WHEN calc_ego_substation.buffer_75_hoes.area < calc_ego_substation.buffer_75_a_hoes.area_a THEN calc_ego_substation.buffer_75_hoes.buffer_75 ELSE calc_ego_substation.buffer_75_a_hoes.buffer_75_a END) as buffer
FROM calc_ego_substation.buffer_75_hoes, calc_ego_substation.buffer_75_a_hoes
WHERE ST_Intersects(calc_ego_substation.buffer_75_hoes.buffer_75, calc_ego_substation.buffer_75_a_hoes.buffer_75_a)
AND NOT calc_ego_substation.buffer_75_hoes.osm_id = calc_ego_substation.buffer_75_a_hoes.osm_id;

-- filter those substations and create final_result_hoes
CREATE VIEW calc_ego_substation.final_result_hoes AS
SELECT * 
FROM calc_ego_substation.summary_de_hoes
WHERE calc_ego_substation.summary_de_hoes.osm_id NOT IN ( SELECT calc_ego_substation.substations_to_drop_hoes.osm_id FROM calc_ego_substation.substations_to_drop_hoes);

INSERT INTO calc_ego_substation.ego_deu_substations_ehv (lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, subst_name, ref, operator, dbahn, status)
SELECT lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, subst_name, ref, operator, dbahn, status
FROM calc_ego_substation.final_result_hoes;

DROP VIEW IF EXISTS calc_ego_substation.final_result_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.substations_to_drop_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.buffer_75_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.buffer_75_a_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.vg250_1_sta_union_mview CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.summary_de_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS calc_ego_substation.summary_hoes CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.summary_total_hoes CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.netzinseln_hoes CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.relation_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.node_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS calc_ego_substation.way_substations CASCADE;

GRANT ALL ON TABLE calc_ego_substation.ego_deu_substations_ehv TO oeuser WITH GRANT OPTION;
ALTER TABLE calc_ego_substation.ego_deu_substations_ehv OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.1' AS version,
		'calc_ego_substation' AS schema_name,
		'ego_deu_substations_ehv' AS table_name,
		'get_substations_ehv.sql' AS script_name,
		COUNT(id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_substation.ego_deu_substations_ehv;
        
