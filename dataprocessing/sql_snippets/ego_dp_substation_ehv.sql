/*
This script abstracts substations of the extra high voltage level from openstreetmap data. 

__copyright__ = "NEXT ENERGY"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "lukasol, C. Matke"
*/

-- ehv substation
DROP TABLE IF EXISTS 	model_draft.ego_grid_ehv_substation CASCADE;
CREATE TABLE 		model_draft.ego_grid_ehv_substation (
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
DROP VIEW IF EXISTS model_draft.summary_de_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.summary_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.summary_total_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.substation_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.relation_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.node_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations CASCADE;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','openstreetmap','osm_deu_ways','get_substations_ehv.sql',' ');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','openstreetmap','osm_deu_polygon','get_substations_ehv.sql',' ');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','openstreetmap','osm_deu_line','get_substations_ehv.sql',' ');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','openstreetmap','osm_deu_nodes','get_substations_ehv.sql',' ');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','openstreetmap','osm_deu_rels','get_substations_ehv.sql',' ');


--> WAY: Erzeuge einen VIEW aus OSM way substations:
CREATE VIEW model_draft.way_substations AS
	SELECT 	openstreetmap.osm_deu_ways.id, openstreetmap.osm_deu_ways.tags, openstreetmap.osm_deu_polygon.geom
	FROM 	openstreetmap.osm_deu_ways JOIN openstreetmap.osm_deu_polygon ON openstreetmap.osm_deu_ways.id = openstreetmap.osm_deu_polygon.osm_id
	WHERE 	hstore(openstreetmap.osm_deu_ways.tags)->'power' in ('substation','sub_station','station')
	UNION
	SELECT 	openstreetmap.osm_deu_ways.id, openstreetmap.osm_deu_ways.tags, openstreetmap.osm_deu_line.geom
	FROM 	openstreetmap.osm_deu_ways JOIN openstreetmap.osm_deu_line ON openstreetmap.osm_deu_ways.id = openstreetmap.osm_deu_line.osm_id
	WHERE 	hstore(openstreetmap.osm_deu_ways.tags)->'power' in ('substation','sub_station','station');

CREATE VIEW model_draft.way_substations_with_hoes AS
	SELECT 	* 
	FROM 	model_draft.way_substations
	WHERE 	'220000' = ANY( string_to_array(hstore(model_draft.way_substations.tags)->'voltage',';')) 
		OR '380000' = ANY( string_to_array(hstore(model_draft.way_substations.tags)->'voltage',';')); 

--> NODE: Erzeuge einen VIEW aus OSM node substations:
CREATE VIEW model_draft.node_substations_with_hoes AS
	SELECT 	openstreetmap.osm_deu_nodes.id, openstreetmap.osm_deu_nodes.tags, openstreetmap.osm_deu_point.geom
	FROM 	openstreetmap.osm_deu_nodes JOIN openstreetmap.osm_deu_point ON openstreetmap.osm_deu_nodes.id = openstreetmap.osm_deu_point.osm_id
	WHERE 	'220000' = ANY( string_to_array(hstore(openstreetmap.osm_deu_nodes.tags)->'voltage',';')) 
		and hstore(openstreetmap.osm_deu_nodes.tags)->'power' in ('substation','sub_station','station') 
		OR '380000' = ANY( string_to_array(hstore(openstreetmap.osm_deu_nodes.tags)->'voltage',';')) 
		and hstore(openstreetmap.osm_deu_nodes.tags)->'power' in ('substation','sub_station','station');

--> RELATION: Erzeuge einen VIEW aus OSM relation substations:
-- Da die relations keine geometry besitzen wird mit folgender funktion der geometrische mittelpunkt der relation ermittelt, 
-- wobei hier der Mittelpunkt aus dem Rechteck ermittelt wird welches entsteht, wenn man die äußersten Korrdinaten für
-- longitude und latitude wählt
-- needs st_relation_geometry

CREATE VIEW model_draft.relation_substations_with_hoes AS
	SELECT 	openstreetmap.osm_deu_rels.id, openstreetmap.osm_deu_rels.tags, relation_geometry(openstreetmap.osm_deu_rels.members) as way
	FROM 	openstreetmap.osm_deu_rels 
	WHERE 	'220000' = ANY( string_to_array(hstore(openstreetmap.osm_deu_rels.tags)->'voltage',';')) 
		and hstore(openstreetmap.osm_deu_rels.tags)->'power' in ('substation','sub_station','station') 
		OR '380000' = ANY( string_to_array(hstore(openstreetmap.osm_deu_rels.tags)->'voltage',';')) 
		and hstore(openstreetmap.osm_deu_rels.tags)->'power' in ('substation','sub_station','station');

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
	SELECT 	*
	FROM 	model_draft.summary_total_hoes
	WHERE 	dbahn = 'no' AND substation NOT IN ('traction','transition');

CREATE INDEX summary_hoes_gix ON model_draft.summary_hoes USING GIST (polygon);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','political_boundary','bkg_vg250_1_sta_union_mview','get_substations_ehv.sql',' ');

-- eliminate substation that are not within VG250
CREATE VIEW model_draft.summary_de_hoes AS
	SELECT 	*
	FROM 	model_draft.summary_hoes, political_boundary.bkg_vg250_1_sta_union_mview as vg
	WHERE 	ST_Transform(vg.geom,4326) && model_draft.summary_hoes.polygon 
	AND 	ST_CONTAINS(ST_Transform(vg.geom,4326),model_draft.summary_hoes.polygon);

-- create view with buffer of 75m around polygons
CREATE MATERIALIZED VIEW model_draft.buffer_75_hoes AS
	SELECT 	osm_id, ST_Area(ST_Transform(model_draft.summary_de_hoes.polygon,4326)) as area, ST_Buffer_Meters(ST_Transform(model_draft.summary_de_hoes.polygon,4326), 75) as buffer_75
	FROM 	model_draft.summary_de_hoes;

-- create second view with same data to compare
CREATE MATERIALIZED VIEW model_draft.buffer_75_a_hoes AS
	SELECT 	osm_id, ST_Area(ST_Transform(model_draft.summary_de_hoes.polygon,4326)) as area_a, ST_Buffer_Meters(ST_Transform(model_draft.summary_de_hoes.polygon,4326), 75) as buffer_75_a
	FROM 	model_draft.summary_de_hoes;

-- create view to eliminate smaller substations where buffers intersect
CREATE MATERIALIZED VIEW model_draft.substations_to_drop_hoes AS
	SELECT DISTINCT
		(CASE WHEN model_draft.buffer_75_hoes.area < model_draft.buffer_75_a_hoes.area_a THEN model_draft.buffer_75_hoes.osm_id ELSE model_draft.buffer_75_a_hoes.osm_id END) as osm_id,
		(CASE WHEN model_draft.buffer_75_hoes.area < model_draft.buffer_75_a_hoes.area_a THEN model_draft.buffer_75_hoes.area ELSE model_draft.buffer_75_a_hoes.area_a END) as area,
		(CASE WHEN model_draft.buffer_75_hoes.area < model_draft.buffer_75_a_hoes.area_a THEN model_draft.buffer_75_hoes.buffer_75 ELSE model_draft.buffer_75_a_hoes.buffer_75_a END) as buffer
	FROM 	model_draft.buffer_75_hoes, model_draft.buffer_75_a_hoes
	WHERE 	ST_Intersects(model_draft.buffer_75_hoes.buffer_75, model_draft.buffer_75_a_hoes.buffer_75_a)
		AND NOT model_draft.buffer_75_hoes.osm_id = model_draft.buffer_75_a_hoes.osm_id;

-- filter those substations and create final_result_hoes
CREATE VIEW model_draft.final_result_hoes AS
	SELECT 	* 
	FROM 	model_draft.summary_de_hoes
	WHERE 	model_draft.summary_de_hoes.osm_id NOT IN ( SELECT model_draft.substations_to_drop_hoes.osm_id FROM model_draft.substations_to_drop_hoes);

INSERT INTO model_draft.ego_grid_ehv_substation (lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, subst_name, ref, operator, dbahn, status)
	SELECT 	lon, lat, point, polygon, voltage, power_type, substation, osm_id, osm_www, frequency, subst_name, ref, operator, dbahn, status
	FROM 	model_draft.final_result_hoes;

DROP VIEW IF EXISTS model_draft.final_result_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.substations_to_drop_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.buffer_75_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.buffer_75_a_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.summary_de_hoes CASCADE;
DROP MATERIALIZED VIEW IF EXISTS model_draft.summary_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.summary_total_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.substation_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.relation_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.node_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations_with_hoes CASCADE;
DROP VIEW IF EXISTS model_draft.way_substations CASCADE;

ALTER TABLE model_draft.ego_grid_ehv_substation OWNER TO oeuser;

COMMENT ON TABLE  model_draft.ego_grid_ehv_substation IS
'{
"Name": "Abstracted substations of extra high voltage",
"Source": [{
                  "Name": "OpenStreetMap",
                  "URL":  "www.openstreetmap.org" }],
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
"Licence": [{
	"Name":		"Open Database License (ODbL) v1.0",
	"URL":		"http://opendatacommons.org/licenses/odbl/1.0/",
	"Copyright": 	"NEXT ENERGY"}],
"Instructions for proper use": ["..."]
}';

SELECT obj_description('model_draft.ego_grid_ehv_substation'::regclass)::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_grid_ehv_substation','get_substations_ehv.sql',' ');
