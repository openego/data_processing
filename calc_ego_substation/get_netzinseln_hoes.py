# -*- coding: utf-8 -*-
# Copyright 2016 by NEXT ENERGY
# Published under GNU GENERAL PUBLIC LICENSE Version 3 (see https://github.com/openego/data_processing/blob/master/LICENSE)

"""
# How to use this script:
# python get_netzinseln.py input.csv output.csv

# input.csv is an input file that can be updated with new data by running this script. input.csv can be an empty .csv-file
# output.csv provides the results of this script in a .csv-table. please provide name for output file

"""
# PGCLUSTER=9.3/main
import os
from db_common import dbconn_from_args
import logging
logging = logging.getLogger(os.path.basename(__file__))
import sys
from time import localtime


def find_netzinseln(cur,conn):
    sql =   """
            DROP TABLE IF EXISTS "netzinsel_hoes" CASCADE;
            CREATE TABLE "netzinsel_hoes" (
            id             serial PRIMARY KEY NOT NULL,
            lon            float NOT NULL,
            lat            float NOT NULL,
            point	   geometry(Point,4326) NOT NULL,
            polygon	   geometry NOT NULL,	
            voltage        text,
            power_type     text,
            substation     text,
            osm_id         text NOT NULL,
            osm_www        text NOT NULL,
            frequency      text,
            name           text,
            ref            text,
            operator       text,
            dbahn          text,
            status   	   smallint NOT NULL,
            visible        smallint NOT NULL);  
          """
    cur.execute(sql)
    conn.commit()
  
    logging.info('Reading csv file: ' + str(sys.argv[1]))
    sql =   """ 
            COPY "netzinsel_hoes" 
            FROM STDIN 
            WITH CSV HEADER DELIMITER ',' QUOTE '''' ENCODING 'UTF8';
            """
    with open(sys.argv[1], 'r') as f:
        cur.copy_expert(sql, f)
    f.close()
    logging.info('Copied csv data in postgres table: ' + str(sys.argv[1]))
    sql =   """
            SELECT setval('"netzinsel_hoes_id_seq"', (SELECT MAX(id) FROM "netzinsel_hoes"));        
            UPDATE "netzinsel_hoes" SET visible = 0;
            """   
    cur.execute(sql)
    conn.commit()

    sql =   """
DROP VIEW IF EXISTS final_result CASCADE;
DROP VIEW IF EXISTS netzinseln_hoes CASCADE;
DROP VIEW IF EXISTS relation_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS node_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS way_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS way_substations CASCADE;

--> WAY: Erzeuge einen VIEW aus OSM way substations:
CREATE VIEW way_substations AS
SELECT planet_osm_ways.id, planet_osm_ways.tags, planet_osm_polygon.way
FROM planet_osm_ways JOIN planet_osm_polygon ON planet_osm_ways.id = planet_osm_polygon.osm_id
WHERE hstore(planet_osm_ways.tags)->'power' in ('substation','sub_station','station');

CREATE VIEW way_substations_with_hoes AS
SELECT * 
FROM way_substations
WHERE '220000' = ANY( string_to_array(hstore(way_substations.tags)->'voltage',';')) OR '380000' = ANY( string_to_array(hstore(way_substations.tags)->'voltage',';')); 

--> NODE: Erzeuge einen VIEW aus OSM node substations:
CREATE VIEW node_substations_with_hoes AS
SELECT planet_osm_nodes.id, planet_osm_nodes.tags, planet_osm_point.way
FROM planet_osm_nodes JOIN planet_osm_point ON planet_osm_nodes.id = planet_osm_point.osm_id
WHERE '220000' = ANY( string_to_array(hstore(planet_osm_nodes.tags)->'voltage',';')) and hstore(planet_osm_nodes.tags)->'power' in ('substation','sub_station','station') OR '380000' = ANY( string_to_array(hstore(planet_osm_nodes.tags)->'voltage',';')) and hstore(planet_osm_nodes.tags)->'power' in ('substation','sub_station','station');

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
	  FROM planet_osm_nodes 
	  WHERE id in (SELECT unnest(nodes) 
             FROM planet_osm_ways 
             WHERE id in (SELECT trim(leading 'w' from member)::bigint 
			  FROM (SELECT unnest(members) as member) t
	                  WHERE member~E'[w,1,2,3,4,5,6,7,8,9,0]')));        
RETURN way;
END;
$$ LANGUAGE plpgsql;

CREATE VIEW relation_substations_with_hoes AS
SELECT planet_osm_rels.id, planet_osm_rels.tags, relation_geometry(planet_osm_rels.members) as way
FROM planet_osm_rels 
WHERE '220000' = ANY( string_to_array(hstore(planet_osm_rels.tags)->'voltage',';')) and hstore(planet_osm_rels.tags)->'power' in ('substation','sub_station','station') OR '380000' = ANY( string_to_array(hstore(planet_osm_rels.tags)->'voltage',';')) and hstore(planet_osm_rels.tags)->'power' in ('substation','sub_station','station');

            """
    cur.execute(sql)
    conn.commit()
    logging.info('VIEWs created.')


    sql =   """

CREATE VIEW netzinseln_hoes AS
SELECT  *,
	'http://www.osm.org/relation/'|| relation_substations_with_hoes.id as osm_www,
	'r'|| relation_substations_with_hoes.id as osm_id,
	'1'::smallint as status
FROM relation_substations_with_hoes
UNION
SELECT 	*,
	'http://www.osm.org/way/'|| way_substations_with_hoes.id as osm_www,
	'w'|| way_substations_with_hoes.id as osm_id,
	'2'::smallint as status
FROM way_substations_with_hoes
UNION 
SELECT *,
	'http://www.osm.org/node/'|| node_substations_with_hoes.id as osm_www,
	'n'|| node_substations_with_hoes.id as osm_id,
	'4'::smallint as status
FROM node_substations_with_hoes;


CREATE VIEW final_result AS
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
	(CASE WHEN hstore(netzinsel.tags)->'name' <> '' THEN hstore(netzinsel.tags)->'name' ELSE 'NA' END) as name, 
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
FROM netzinseln_hoes netzinsel ORDER BY osm_www;

            """
    cur.execute(sql)
    conn.commit()
    logging.info('Final result created.')

    sql =   """
WITH new_values (lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, name, ref, operator, dbahn, status) as (
  SELECT * FROM final_result
),
upsert as
( 
    update "netzinsel_hoes" m 
        set lon = nv.lon,
            lat = nv.lat,
            point = nv.point,
            polygon = nv.polygon,
            voltage = nv.voltage,
            power_type = nv.power_type,
            substation = nv.substation,
            osm_id = nv.osm_id,
            osm_www = nv.osm_www,
            frequency = nv.frequency,
            name = nv.name,
            ref = nv.ref,
            operator = nv.operator,
            dbahn = nv.dbahn,
            status = nv.status,
            visible = 1
    FROM new_values nv
    WHERE m.osm_www = nv.osm_www
    RETURNING m.*
)
INSERT INTO "netzinsel_hoes" (lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, name, ref, operator, dbahn, status, visible)
SELECT lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, name, ref, operator, dbahn, status, 1
FROM new_values
WHERE NOT EXISTS (SELECT 1 
                  FROM upsert up 
                  WHERE up.osm_www = new_values.osm_www);
            """
    cur.execute(sql)
    conn.commit()

    sql =   """ 
            COPY (SELECT * FROM "netzinsel_hoes" ORDER BY id)
            TO STDOUT 
            WITH CSV HEADER DELIMITER ',' QUOTE '''' ENCODING 'UTF8' FORCE QUOTE voltage,power_type, osm_www, frequency, name, ref, operator, dbahn;
            """
    with open(sys.argv[2], 'w') as f:
        cur.copy_expert(sql, f)
    f.close()
    conn.close()

if __name__ == '__main__':
    try:
        conn       = dbconn_from_args()
        cur        = conn.cursor()
        if len(sys.argv)< 3: 
            logging.error('Need 2 arguments for input.csv and output.csv "python get_Netzinseln_hoes input.csv output.csv"')  
            logging.info('Both files input.csv and output.csv are needed. You may want to create an empty csv file with "touch input.csv" and then use "python get_Netzinseln_hoes input.csv output.csv" to start without previous Netzinsel analysis.')  
            quit()
        find_netzinseln(cur,conn)   
    except Exception, e:
        logging.error('Could not get Netzinseln.', exc_info=True)
        exit(1)        
