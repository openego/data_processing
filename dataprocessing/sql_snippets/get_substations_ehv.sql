-- Copyright 2016 by NEXT ENERGY
-- Published under GNU GENERAL PUBLIC LICENSE Version 3 (see https://github.com/openego/data_processing/blob/master/LICENSE)

DROP TABLE IF EXISTS model_draft.ego_grid_ehv_substation CASCADE;
CREATE TABLE model_draft.ego_grid_ehv_substation (
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

DROP VIEW IF EXISTS model_draft.final_result_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.substations_to_drop_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.buffer_75_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.buffer_75_a_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.vg250_1_sta_union_mview CASCADE;
DROP VIEW IF EXISTS model_draft.summary_de_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.summary_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.summary_total_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.substation_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.relation_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.node_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations CASCADE;

--> WAY: Erzeuge einen VIEW aus OSM way substations:
CREATE VIEW model_draft.way_substations AS
SELECT openstreetmap.osm_deu_ways.id, openstreetmap.osm_deu_ways.tags, openstreetmap.osm_deu_polygon.geom
FROM openstreetmap.osm_deu_ways JOIN openstreetmap.osm_deu_polygon ON openstreetmap.osm_deu_ways.id = openstreetmap.osm_deu_polygon.osm_id
WHERE hstore(openstreetmap.osm_deu_ways.tags)->'power' in ('substation','sub_station','station');

CREATE VIEW model_draft.way_substations_with_hoes AS
SELECT * 
FROM model_draft.way_substations
WHERE '220000' = ANY( string_to_array(hstore(model_draft.way_substations.tags)->'voltage',';')) OR '380000' = ANY( string_to_array(hstore(model_draft.way_substations.tags)->'voltage',';')); 

--> NODE: Erzeuge einen VIEW aus OSM node substations:
CREATE VIEW model_draft.node_substations_with_hoes AS
SELECT openstreetmap.osm_deu_nodes.id, openstreetmap.osm_deu_nodes.tags, openstreetmap.osm_deu_point.geom
FROM openstreetmap.osm_deu_nodes JOIN openstreetmap.osm_deu_point ON openstreetmap.osm_deu_nodes.id = openstreetmap.osm_deu_point.osm_id
WHERE '220000' = ANY( string_to_array(hstore(openstreetmap.osm_deu_nodes.tags)->'voltage',';')) and hstore(openstreetmap.osm_deu_nodes.tags)->'power' in ('substation','sub_station','station') OR '380000' = ANY( string_to_array(hstore(openstreetmap.osm_deu_nodes.tags)->'voltage',';')) and hstore(openstreetmap.osm_deu_nodes.tags)->'power' in ('substation','sub_station','station');

--> RELATION: Erzeuge einen VIEW aus OSM relation substations:
-- Da die relations keine geometry besitzen wird mit folgender funktion der geometrische mittelpunkt der relation ermittelt, 
-- wobei hier der Mittelpunkt aus dem Rechteck ermittelt wird welches entsteht, wenn man die äußersten Korrdinaten für
-- longitude und latitude wählt
-- needs st_relation_geometry

CREATE VIEW model_draft.relation_substations_with_hoes AS
SELECT openstreetmap.osm_deu_rels.id, openstreetmap.osm_deu_rels.tags, relation_geometry(openstreetmap.osm_deu_rels.members) as way
FROM openstreetmap.osm_deu_rels 
WHERE '220000' = ANY( string_to_array(hstore(openstreetmap.osm_deu_rels.tags)->'voltage',';')) and hstore(openstreetmap.osm_deu_rels.tags)->'power' in ('substation','sub_station','station') OR '380000' = ANY( string_to_array(hstore(openstreetmap.osm_deu_rels.tags)->'voltage',';')) and hstore(openstreetmap.osm_deu_rels.tags)->'power' in ('substation','sub_station','station');

CREATE VIEW model_draft.substation_hoes AS
SELECT  *,
	'http://www.osm.org/relation/'|| model_draft.relation_substations_with_hoes.id as osm_www,
	'r'|| model_draft.relation_substations_with_hoes.id as osm_id,
	'1'::smallint as status
FROM model_draft.relation_substations_with_hoes
UNION
SELECT 	*,
	'http://www.osm.org/way/'|| model_draft.way_substations_with_hoes.id as osm_www,
	'w'|| model_draft.way_substations_with_hoes.id as osm_id,
	'2'::smallint as status
FROM model_draft.way_substations_with_hoes
UNION 
SELECT *,
	'http://www.osm.org/node/'|| model_draft.node_substations_with_hoes.id as osm_www,
	'n'|| model_draft.node_substations_with_hoes.id as osm_id,
	'4'::smallint as status
FROM model_draft.node_substations_with_hoes;

-- create view summary_total_hoes that contains substations without any filter
CREATE VIEW model_draft.summary_total_hoes AS
SELECT  ST_X(ST_Centroid(ST_Transform(substation.way,4326))) as lon,
	ST_Y(ST_Centroid(ST_Transform(substation.way,4326))) as lat,
	ST_Centroid(ST_Transform(substation.way,4326)) as point,
	ST_Transform(substation.way,4326) as polygon,
	(CASE WHEN hstore(substation.tags)->'voltage' <> '' THEN hstore(substation.tags)->'voltage' ELSE 'hoes' END) as voltage, 
        hstore(substation.tags)->'power' as power_type,
        (CASE WHEN hstore(substation.tags)->'substation' <> '' THEN hstore(substation.tags)->'substation' ELSE 'NA' END) as substation,  
	substation.osm_id as osm_id, 
	osm_www,
	(CASE WHEN hstore(substation.tags)->'frequency' <> '' THEN hstore(substation.tags)->'frequency' ELSE 'NA' END) as frequency,
	(CASE WHEN hstore(substation.tags)->'name' <> '' THEN hstore(substation.tags)->'name' ELSE 'NA' END) as subst_name, 
	(CASE WHEN hstore(substation.tags)->'ref' <> '' THEN hstore(substation.tags)->'ref' ELSE 'NA' END) as ref, 
	(CASE WHEN hstore(substation.tags)->'operator' <> '' THEN hstore(substation.tags)->'operator' ELSE 'NA' END) as operator, 
	(CASE WHEN hstore(substation.tags)->'operator' in ('DB_Energie','DB Netz AG','DB Energie GmbH','DB Netz')
	      THEN 'see operator' 
	      ELSE (CASE WHEN '16.7' = ANY( string_to_array(hstore(substation.tags)->'frequency',';')) or '16.67' = ANY( string_to_array(hstore(substation.tags)->'frequency',';')) 
	                 THEN 'see frequency' 
	                 ELSE 'no' 
	                 END)
	      END) as dbahn,
	status
FROM model_draft.substation_hoes substation ORDER BY osm_www;

-- create view that filters irrelevant tags
CREATE MATERIALIZED VIEW model_draft.summary_hoes AS
SELECT *
FROM model_draft.summary_total_hoes
WHERE dbahn = 'no' AND substation NOT IN ('traction','transition');

CREATE INDEX summary_hoes_gix ON model_draft.summary_hoes USING GIST (polygon);

-- eliminate substation that are not within VG250
CREATE MATERIALIZED VIEW model_draft.vg250_1_sta_union_mview AS 
 SELECT 1 AS gid,
    'Bundesrepublik'::text AS bez,
    st_area(un.geom) / 10000::double precision AS area_km2,
    un.geom
   FROM ( SELECT st_union(st_transform(vg.geom, 4326))::geometry(MultiPolygon,4326) AS geom
          FROM political_boundary.bkg_vg250_20160101_1_sta vg
          WHERE vg.bez::text = 'Bundesrepublik'::text) un;
CREATE INDEX vg250_1_sta_union_mview_gix ON model_draft.vg250_1_sta_union_mview USING GIST (geom);

CREATE VIEW model_draft.summary_de_hoes AS
SELECT *
FROM model_draft.summary_hoes, model_draft.vg250_1_sta_union_mview as vg
WHERE vg.geom && model_draft.summary_hoes.polygon 
AND ST_CONTAINS(vg.geom,model_draft.summary_hoes.polygon);

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
ALTER FUNCTION utmzone(geometry) OWNER TO oeuser;

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
ALTER FUNCTION ST_Buffer_Meters(geometry, double precision) OWNER TO oeuser;

-- create view with buffer of 75m around polygons
CREATE MATERIALIZED VIEW model_draft.buffer_75_hoes AS
SELECT osm_id, ST_Area(ST_Transform(model_draft.summary_de_hoes.polygon,4326)) as area, ST_Buffer_Meters(ST_Transform(model_draft.summary_de_hoes.polygon,4326), 75) as buffer_75
FROM model_draft.summary_de_hoes;

-- create second view with same data to compare
CREATE MATERIALIZED VIEW model_draft.buffer_75_a_hoes AS
SELECT osm_id, ST_Area(ST_Transform(model_draft.summary_de_hoes.polygon,4326)) as area_a, ST_Buffer_Meters(ST_Transform(model_draft.summary_de_hoes.polygon,4326), 75) as buffer_75_a
FROM model_draft.summary_de_hoes;

-- create view to eliminate smaller substations where buffers intersect
CREATE MATERIALIZED VIEW model_draft.substations_to_drop_hoes AS
SELECT DISTINCT
(CASE WHEN model_draft.buffer_75_hoes.area < model_draft.buffer_75_a_hoes.area_a THEN model_draft.buffer_75_hoes.osm_id ELSE model_draft.buffer_75_a_hoes.osm_id END) as osm_id,
(CASE WHEN model_draft.buffer_75_hoes.area < model_draft.buffer_75_a_hoes.area_a THEN model_draft.buffer_75_hoes.area ELSE model_draft.buffer_75_a_hoes.area_a END) as area,
(CASE WHEN model_draft.buffer_75_hoes.area < model_draft.buffer_75_a_hoes.area_a THEN model_draft.buffer_75_hoes.buffer_75 ELSE model_draft.buffer_75_a_hoes.buffer_75_a END) as buffer
FROM model_draft.buffer_75_hoes, model_draft.buffer_75_a_hoes
WHERE ST_Intersects(model_draft.buffer_75_hoes.buffer_75, model_draft.buffer_75_a_hoes.buffer_75_a)
AND NOT model_draft.buffer_75_hoes.osm_id = model_draft.buffer_75_a_hoes.osm_id;

-- filter those substations and create final_result_hoes
CREATE VIEW model_draft.final_result_hoes AS
SELECT * 
FROM model_draft.summary_de_hoes
WHERE model_draft.summary_de_hoes.osm_id NOT IN ( SELECT model_draft.substations_to_drop_hoes.osm_id FROM model_draft.substations_to_drop_hoes);

INSERT INTO model_draft.ego_grid_ehv_substation (lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, subst_name, ref, operator, dbahn, status)
SELECT lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, subst_name, ref, operator, dbahn, status
FROM model_draft.final_result_hoes;

DROP VIEW IF EXISTS model_draft.final_result_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.substations_to_drop_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.buffer_75_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.buffer_75_a_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.vg250_1_sta_union_mview CASCADE;
DROP VIEW IF EXISTS model_draft.summary_de_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.summary_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.summary_total_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.substation_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.relation_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.node_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations CASCADE;

GRANT ALL ON TABLE model_draft.ego_grid_ehv_substation TO oeuser WITH GRANT OPTION;
ALTER TABLE model_draft.ego_grid_ehv_substation OWNER TO oeuser;

-- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.2' AS version,
	'model_draft' AS schema_name,
	'ego_grid_ehv_substation' AS table_name,
	'get_substations_ehv.sql' AS script_name,
	COUNT(subst_id)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_ehv_substation;

COMMENT ON TABLE  model_draft.ego_grid_ehv_substation IS
'{
"Name": "...",
"Source": [{
                  "Name": "...",
                  "URL":  "..." }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["..."],
"Column": [
                   {"Name": "id",	
                    "Description": "serial id",
                    "Unit": "" },
                   {"Name": "lon",
                    "Description": "longitude of substation ",
                    "Unit": "" },
                   {"Name": "lat",
                    "Description": "latitude of substation ",
                    "Unit": "" },
                   {"Name": "point",
                    "Description": "point geometry of substation  (4326)",
                    "Unit": "" },
                   {"Name": "polygon",
                    "Description": "polygon geometry of substation",
                    "Unit": "" },
                   {"Name": "voltage",
                    "Description": "(all) voltage levels contained in substation",
                    "Unit": "V" },
                   {"Name": "power_type",
                    "Description": "value of osm key power",
                    "Unit": "" },
                   {"Name": "substation",
                    "Description": "value of osm key substation",
                    "Unit": "" },
                   {"Name": "osm_id",
                    "Description": "osm id of substation, begins with prefix r(relation), n(node) or w(way)",
                    "Unit": "" },
                   {"Name": "osm_www",
                    "Description": "hyperlink to osm source",
                    "Unit": "" },
                   {"Name": "frequency",
                    "Description": "frequency of substation",
                    "Unit": "Hz" },
                   {"Name": "subst_name",
                    "Description": "name of substation",
                    "Unit": "" },
                   {"Name": "ref",
                    "Description": "reference tag of substation",
                    "Unit": "" },
                   {"Name": "operator",
                    "Description": "operator(s) of substation",
                    "Unit": "" },
                   {"Name": "dbahn",
                    "Description": "states if substation is connected to railway grid and if yes the indicator",
                    "Unit": "" },
                   {"Name": "status",
                    "Description": "states the osm source of substation (1=relation, 2=way, 4=node)",
                    "Unit": "" },                   
                   {"Name": "otg_id",
                    "Description": "states the id of respective bus in osmtgmod",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Lukas Wienholt",
                    "Mail": "lukas.wienholt@next-energy.de",
                    "Date":  "20.10.2016",
                    "Comment": "..." }
                  ],
"ToDo": ["..."],
"Licence": ["GNU GPL3"],
"Instructions for proper use": ["..."]
}';


SELECT obj_description('model_draft.ego_grid_ehv_substation'::regclass)::json;

-- 
