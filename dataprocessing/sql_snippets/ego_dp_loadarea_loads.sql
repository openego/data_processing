/*
OSM Loads from landuse
Excludes large scale consumer.
Buffer OSM urban sectors with 100m
Unbuffer buffer with -100m

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_demand_hv_largescaleconsumer','ego_dp_loadarea_loads.sql',' ');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','openstreetmap','osm_deu_polygon_urban','ego_dp_loadarea_loads.sql',' ');

-- exclude large scale consumer
DELETE FROM openstreetmap.osm_deu_polygon_urban
	WHERE gid IN (SELECT polygon_id FROM model_draft.ego_demand_hv_largescaleconsumer);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','openstreetmap','osm_deu_polygon_urban','ego_dp_loadarea_loads.sql',' ');

-- sequence
DROP SEQUENCE IF EXISTS 	model_draft.osm_deu_polygon_urban_buffer100_mview_id CASCADE;
CREATE SEQUENCE 		model_draft.osm_deu_polygon_urban_buffer100_mview_id;

-- grant (oeuser)
ALTER SEQUENCE	model_draft.osm_deu_polygon_urban_buffer100_mview_id OWNER TO oeuser;

-- buffer with 100m
DROP MATERIALIZED VIEW IF EXISTS	model_draft.osm_deu_polygon_urban_buffer100_mview CASCADE;
CREATE MATERIALIZED VIEW		model_draft.osm_deu_polygon_urban_buffer100_mview AS
	SELECT	 nextval('model_draft.osm_deu_polygon_urban_buffer100_mview_id') ::integer AS id,
		(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(geom, 100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	openstreetmap.osm_deu_polygon_urban
    ORDER BY gid;

-- index (id)
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_buffer100_mview_gid_idx
	ON	model_draft.osm_deu_polygon_urban_buffer100_mview (id);

-- index GIST (geom)
CREATE INDEX  	osm_deu_polygon_urban_buffer100_mview_geom_idx
	ON	model_draft.osm_deu_polygon_urban_buffer100_mview USING GIST (geom);
    
-- grant (oeuser)
ALTER TABLE	model_draft.osm_deu_polygon_urban_buffer100_mview OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.osm_deu_polygon_urban_buffer100_mview IS '{
    "comment": "eGoDP - Temporary table", 
    "version": "v0.3.0",
    "published": "none" }';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','temp','model_draft','osm_deu_polygon_urban_buffer100_mview','ego_dp_loadarea_loads.sql',' ');


-- unbuffer with 100m
DROP TABLE IF EXISTS  	model_draft.ego_demand_la_osm CASCADE;
CREATE TABLE         	model_draft.ego_demand_la_osm (
	id SERIAL NOT NULL,
	area_ha double precision,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_demand_la_osm_pkey PRIMARY KEY (id));

-- insert buffer
INSERT INTO     model_draft.ego_demand_la_osm(area_ha,geom)
    SELECT  ST_AREA(buffer.geom)/10000 ::double precision AS area_ha,
            buffer.geom ::geometry(Polygon,3035) AS geom
    FROM    (SELECT (ST_DUMP(ST_MULTI(ST_UNION(
                        ST_BUFFER(osm.geom, -100)
                    )))).geom ::geometry(Polygon,3035) AS geom
            FROM    model_draft.osm_deu_polygon_urban_buffer100_mview AS osm
            ORDER BY gid
            ) AS buffer;

-- index GIST (geom)
CREATE INDEX  	ego_demand_la_osm_geom_idx
	ON    	model_draft.ego_demand_la_osm USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_demand_la_osm OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_demand_la_osm IS '{
    "comment": "eGoDP - Temporary table", 
    "version": "v0.3.0",
    "published": "none" }';

-- select description
SELECT obj_description('model_draft.ego_demand_la_osm' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','ouput','model_draft','ego_demand_la_osm','ego_dp_loadarea_loads.sql',' ');


-- DROP MATERIALIZED VIEW IF EXISTS model_draft.osm_deu_polygon_urban_buffer100_mview CASCADE;


---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	openstreetmap.ego_demand_la_osm_error_geom_view CASCADE;
-- CREATE VIEW		openstreetmap.ego_demand_la_osm_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.id AS id,			-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	openstreetmap.ego_demand_la_osm AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- grant (oeuser)
-- GRANT ALL ON TABLE	openstreetmap.ego_demand_la_osm_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		openstreetmap.ego_demand_la_osm_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{ego_demand_la_osm_error_geom_view}', 'openstreetmap');
