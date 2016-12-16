/*
[...]

__copyright__ = "NEXT ENERGY"
__license__ = "GNU GENERAL PUBLIC LICENSE Version 3 (see https://github.com/openego/data_processing/blob/master/LICENSE)"
__author__ = "lukasol, C. Matke"
*/

DROP TABLE IF EXISTS model_draft.ego_grid_hvmv_substation CASCADE;
CREATE TABLE model_draft.ego_grid_hvmv_substation (
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

DROP VIEW IF EXISTS model_draft.final_result CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.substations_to_drop CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.buffer_75 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.buffer_75_a CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.vg250_1_sta_union_mview CASCADE;
DROP VIEW IF EXISTS model_draft.summary_de CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.summary CASCADE;
DROP VIEW IF EXISTS model_draft.summary_total CASCADE;
DROP VIEW IF EXISTS model_draft.substation_110kV CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations_without_110kV_intersected_by_110kV_line CASCADE;
DROP VIEW IF EXISTS model_draft.way_lines_110kV CASCADE;
DROP VIEW IF EXISTS model_draft.node_substations_with_110kV CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations_without_110kV CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations_with_110kV CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations CASCADE;

--> WAY: create view of way substations:
CREATE VIEW model_draft.way_substations AS
SELECT openstreetmap.osm_deu_ways.id, openstreetmap.osm_deu_ways.tags, openstreetmap.osm_deu_polygon.geom
FROM openstreetmap.osm_deu_ways JOIN openstreetmap.osm_deu_polygon ON openstreetmap.osm_deu_ways.id = openstreetmap.osm_deu_polygon.osm_id
WHERE hstore(openstreetmap.osm_deu_ways.tags)->'power' in ('substation','sub_station','station');
ALTER VIEW model_draft.way_substations OWNER TO oeuser;

--> WAY: create view of way substations with 110kV:
CREATE VIEW model_draft.way_substations_with_110kV AS
SELECT * 
FROM model_draft.way_substations
WHERE '110000' = ANY( string_to_array(hstore(model_draft.way_substations.tags)->'voltage',';')) OR '60000' = ANY( string_to_array(hstore(model_draft.way_substations.tags)->'voltage',';'));
ALTER VIEW model_draft.way_substations_with_110kV OWNER TO oeuser;

--> WAY: create view of substations without 110kV
CREATE VIEW model_draft.way_substations_without_110kV AS
SELECT * 
FROM model_draft.way_substations
WHERE not '110000' = ANY( string_to_array(hstore(model_draft.way_substations.tags)->'voltage',';')) AND not '60000' = ANY( string_to_array(hstore(model_draft.way_substations.tags)->'voltage',';')) or not exist(hstore(model_draft.way_substations.tags),'voltage');
ALTER VIEW model_draft.way_substations_without_110kV OWNER TO oeuser;

--> NODE: create view of 110kV node substations:
CREATE VIEW model_draft.node_substations_with_110kV AS
SELECT openstreetmap.osm_deu_nodes.id, openstreetmap.osm_deu_nodes.tags, openstreetmap.osm_deu_point.geom
FROM openstreetmap.osm_deu_nodes JOIN openstreetmap.osm_deu_point ON openstreetmap.osm_deu_nodes.id = openstreetmap.osm_deu_point.osm_id
WHERE '110000' = ANY( string_to_array(hstore(openstreetmap.osm_deu_nodes.tags)->'voltage',';')) and hstore(openstreetmap.osm_deu_nodes.tags)->'power' in ('substation','sub_station','station') OR '60000' = ANY( string_to_array(hstore(openstreetmap.osm_deu_nodes.tags)->'voltage',';')) and hstore(openstreetmap.osm_deu_nodes.tags)->'power' in ('substation','sub_station','station');
ALTER VIEW model_draft.node_substations_with_110kV OWNER TO oeuser;

--> LINES 110kV: create view of 110kV lines
CREATE VIEW model_draft.way_lines_110kV AS
SELECT openstreetmap.osm_deu_ways.id, openstreetmap.osm_deu_ways.tags, openstreetmap.osm_deu_line.geom 
FROM openstreetmap.osm_deu_ways JOIN openstreetmap.osm_deu_line ON openstreetmap.osm_deu_ways.id = openstreetmap.osm_deu_line.osm_id
WHERE '110000' = ANY( string_to_array(hstore(openstreetmap.osm_deu_ways.tags)->'voltage',';')) 
		 AND NOT hstore(openstreetmap.osm_deu_ways.tags)->'power' in ('minor_line','razed','dismantled:line','historic:line','construction','planned','proposed','abandoned:line','sub_station','abandoned','substation') OR '60000' = ANY( string_to_array(hstore(openstreetmap.osm_deu_ways.tags)->'voltage',';')) 
		 AND NOT hstore(openstreetmap.osm_deu_ways.tags)->'power' in ('minor_line','razed','dismantled:line','historic:line','construction','planned','proposed','abandoned:line','sub_station','abandoned','substation');
ALTER VIEW model_draft.way_lines_110kV OWNER TO oeuser;

-- INTERSECTION: create view from substations without 110kV tag that contain 110kV line
CREATE VIEW model_draft.way_substations_without_110kV_intersected_by_110kV_line AS
SELECT DISTINCT model_draft.way_substations_without_110kV.* 
FROM model_draft.way_substations_without_110kV, model_draft.way_lines_110kV
WHERE ST_Contains(model_draft.way_substations_without_110kV.geom,ST_StartPoint(model_draft.way_lines_110kV.geom)) or ST_Contains(model_draft.way_substations_without_110kV.geom,ST_EndPoint(model_draft.way_lines_110kV.geom));
ALTER VIEW model_draft.way_substations_without_110kV_intersected_by_110kV_line OWNER TO oeuser;

CREATE VIEW model_draft.substation_110kV AS
SELECT 	*,
	'http://www.osm.org/way/'|| model_draft.way_substations_with_110kV.id as osm_www,
	'w'|| model_draft.way_substations_with_110kV.id as osm_id,
	'1'::smallint as status
FROM model_draft.way_substations_with_110kV
UNION 
SELECT *,
	'http://www.osm.org/way/'|| model_draft.way_substations_without_110kV_intersected_by_110kV_line.id as osm_www,
	'w'|| model_draft.way_substations_without_110kV_intersected_by_110kV_line.id as osm_id,
	'2'::smallint as status
FROM model_draft.way_substations_without_110kV_intersected_by_110kV_line
UNION 
SELECT *,
	'http://www.osm.org/node/'|| model_draft.node_substations_with_110kV.id as osm_www,
	'n'|| model_draft.node_substations_with_110kV.id as osm_id,
	'3'::smallint as status
FROM model_draft.node_substations_with_110kV;
ALTER VIEW model_draft.substation_110kV OWNER TO oeuser;

-- create view summary_total that contains substations without any filter
CREATE VIEW model_draft.summary_total AS
SELECT  ST_X(ST_Centroid(ST_Transform(substation.geom,4326))) as lon,
	ST_Y(ST_Centroid(ST_Transform(substation.geom,4326))) as lat,
	ST_Centroid(ST_Transform(substation.geom,4326)) as point,
	ST_Transform(substation.geom,4326) as polygon,
	(CASE WHEN hstore(substation.tags)->'voltage' <> '' THEN hstore(substation.tags)->'voltage' ELSE '110000' END) as voltage, 
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
FROM model_draft.substation_110kV substation ORDER BY osm_www;
ALTER VIEW model_draft.summary_total OWNER TO oeuser;

-- create view that filters irrelevant tags
CREATE MATERIALIZED VIEW model_draft.summary AS
SELECT *
FROM model_draft.summary_total
WHERE dbahn = 'no' AND substation NOT IN ('traction','transition');
ALTER MATERIALIZED VIEW model_draft.summary OWNER TO oeuser;
CREATE INDEX summary_gix ON model_draft.summary USING GIST (polygon);

-- create view of political boundary VG250
CREATE MATERIALIZED VIEW model_draft.vg250_1_sta_union_mview AS 
SELECT 1 AS gid,
    'Bundesrepublik'::text AS bez,
    st_area(un.geom) / 10000::double precision AS area_km2,
    un.geom
FROM ( SELECT st_union(st_transform(vg.geom, 4326))::geometry(MultiPolygon,4326) AS geom
          FROM political_boundary.bkg_vg250_20160101_1_sta vg
          WHERE vg.bez::text = 'Bundesrepublik'::text) un;

ALTER MATERIALIZED VIEW model_draft.vg250_1_sta_union_mview OWNER TO oeuser;
CREATE INDEX vg250_1_sta_union_mview_gix ON model_draft.vg250_1_sta_union_mview USING GIST (geom);

-- eliminate substation that are not within VG250
CREATE VIEW model_draft.summary_de AS
SELECT *
FROM model_draft.summary, model_draft.vg250_1_sta_union_mview as vg
WHERE vg.geom && model_draft.summary.polygon 
AND ST_CONTAINS(vg.geom,model_draft.summary.polygon);
ALTER VIEW model_draft.summary_de OWNER TO oeuser;

-- create view with buffer of 75m around polygons
CREATE MATERIALIZED VIEW model_draft.buffer_75 AS
SELECT osm_id, ST_Area(ST_Transform(model_draft.summary_de.polygon,4326)) as area, ST_Buffer_Meters(ST_Transform(model_draft.summary_de.polygon,4326), 75) as buffer_75
FROM model_draft.summary_de;
ALTER MATERIALIZED VIEW model_draft.buffer_75 OWNER TO oeuser;

-- create second view with same data to compare
CREATE MATERIALIZED VIEW model_draft.buffer_75_a AS
SELECT osm_id, ST_Area(ST_Transform(model_draft.summary_de.polygon,4326)) as area_a, ST_Buffer_Meters(ST_Transform(model_draft.summary_de.polygon,4326), 75) as buffer_75_a
FROM model_draft.summary_de;
ALTER MATERIALIZED VIEW model_draft.buffer_75_a OWNER TO oeuser;

-- create view to eliminate smaller substations where buffers intersect
CREATE MATERIALIZED VIEW model_draft.substations_to_drop AS
SELECT DISTINCT
(CASE WHEN model_draft.buffer_75.area < model_draft.buffer_75_a.area_a THEN model_draft.buffer_75.osm_id ELSE model_draft.buffer_75_a.osm_id END) as osm_id,
(CASE WHEN model_draft.buffer_75.area < model_draft.buffer_75_a.area_a THEN model_draft.buffer_75.area ELSE model_draft.buffer_75_a.area_a END) as area,
(CASE WHEN model_draft.buffer_75.area < model_draft.buffer_75_a.area_a THEN model_draft.buffer_75.buffer_75 ELSE model_draft.buffer_75_a.buffer_75_a END) as buffer
FROM model_draft.buffer_75, model_draft.buffer_75_a
WHERE ST_Intersects(model_draft.buffer_75.buffer_75, model_draft.buffer_75_a.buffer_75_a)
AND NOT model_draft.buffer_75.osm_id = model_draft.buffer_75_a.osm_id;
ALTER MATERIALIZED VIEW model_draft.substations_to_drop OWNER TO oeuser;

-- filter those substations and create final_result
CREATE VIEW model_draft.final_result AS
SELECT * 
FROM model_draft.summary_de
WHERE model_draft.summary_de.osm_id NOT IN ( SELECT model_draft.substations_to_drop.osm_id FROM model_draft.substations_to_drop);
ALTER VIEW model_draft.final_result OWNER TO oeuser;

INSERT INTO model_draft.ego_grid_hvmv_substation (lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, subst_name, ref, operator, dbahn, status)
SELECT lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, subst_name, ref, operator, dbahn, status
FROM model_draft.final_result;

DROP VIEW IF EXISTS model_draft.final_result CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.substations_to_drop CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.buffer_75 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.buffer_75_a CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.vg250_1_sta_union_mview CASCADE;
DROP VIEW IF EXISTS model_draft.summary_de CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.summary CASCADE;
DROP VIEW IF EXISTS model_draft.summary_total CASCADE;
DROP VIEW IF EXISTS model_draft.substation_110kV CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations_without_110kV_intersected_by_110kV_line CASCADE;
DROP VIEW IF EXISTS model_draft.way_lines_110kV CASCADE;
DROP VIEW IF EXISTS model_draft.node_substations_with_110kV CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations_without_110kV CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations_with_110kV CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations CASCADE;

GRANT ALL ON TABLE model_draft.ego_grid_hvmv_substation TO oeuser WITH GRANT OPTION;
ALTER TABLE model_draft.ego_grid_hvmv_substation OWNER TO oeuser;

-- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.2' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_grid_hvmv_substation' AS table_name,
	'get_substations.sql' AS script_name,
	COUNT(subst_id)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_grid_hvmv_substation' ::regclass) ::json AS metadata
FROM	model_draft.ego_grid_hvmv_substation;

COMMENT ON TABLE  model_draft.ego_grid_hvmv_substation IS
'{
"Name": "Abstracted substations between high- and medium voltage",
"Source": [{
                  "Name": "OpenStreetMap",
                  "URL":  "www.openstreetmap.org" }],
"Reference date": "...",
"Date of collection": "...",
"Original file": "...",
"Spatial resolution": ["Germany"],
"Description": ["..."],
"Column": [
                   {"Name": "subst_id",	
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
                    "Description": "osm id of substation, begins with prefix n(node) or w(way)",
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
                    "Description": "states the osm source of substation (1=way, 2=way intersected by 110kV-line, 3=node)",
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
"Licence": [{
	"Name":		"Open Database License (ODbL) v1.0",
	"URL":		"http://opendatacommons.org/licenses/odbl/1.0/",
	"Copyright": 	"NEXT ENERGY"}],
"Instructions for proper use": ["..."]
}';

SELECT obj_description('model_draft.ego_grid_hvmv_substation'::regclass)::json;

--
        
