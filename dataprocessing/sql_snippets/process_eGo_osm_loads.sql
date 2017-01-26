/*
osm loads 
Excludes large scale consumer 
Buffer osm urban sectors with 100m 
Unbuffer buffer with -100m 

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','model_draft','ego_demand_hv_largescaleconsumer','process_eGo_osm_loads.sql',' ');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','openstreetmap','osm_deu_polygon_urban','process_eGo_osm_loads.sql',' ');

-- exclude large scale consumer
DELETE FROM openstreetmap.osm_deu_polygon_urban
	WHERE gid IN (SELECT polygon_id FROM model_draft.ego_demand_hv_largescaleconsumer);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','openstreetmap','osm_deu_polygon_urban','process_eGo_osm_loads.sql',' ');

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
			ST_BUFFER(osm.geom, 100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	openstreetmap.osm_deu_polygon_urban AS osm;

-- index (id)
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_buffer100_mview_gid_idx
	ON	model_draft.osm_deu_polygon_urban_buffer100_mview (id);

-- index GIST (geom)
CREATE INDEX  	osm_deu_polygon_urban_buffer100_mview_geom_idx
	ON	model_draft.osm_deu_polygon_urban_buffer100_mview USING GIST (geom);
    
-- grant (oeuser)
ALTER TABLE	model_draft.osm_deu_polygon_urban_buffer100_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','temp','model_draft','osm_deu_polygon_urban_buffer100_mview','process_eGo_osm_loads.sql',' ');


-- unbuffer with 100m
DROP TABLE IF EXISTS  	model_draft.ego_demand_la_osm CASCADE;
CREATE TABLE         	model_draft.ego_demand_la_osm (
	id SERIAL NOT NULL,
	area_ha double precision,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_demand_la_osm_pkey PRIMARY KEY (id));

-- insert buffer
INSERT INTO     model_draft.ego_demand_la_osm(area_ha,geom)
	SELECT	ST_AREA(buffer.geom)/10000 ::double precision AS area_ha,
		buffer.geom ::geometry(Polygon,3035) AS geom
	FROM	(SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(osm.geom, -100)
			)))).geom ::geometry(Polygon,3035) AS geom
		FROM	model_draft.osm_deu_polygon_urban_buffer100_mview AS osm) AS buffer;

-- index GIST (geom)
CREATE INDEX  	ego_demand_la_osm_geom_idx
	ON    	model_draft.ego_demand_la_osm USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_demand_la_osm OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_demand_la_osm IS '{
    "Name": "ego osm loads",
    "Source":   [{
	"Name": "open_eGo",
	"URL": "https://github.com/openego/data_processing"}],
    "Reference date": "2016",
    "Date of collection": "02.09.2016",
    "Original file": ["ego_grid_hvmv_substation"],
    "Spatial": [{
	"Resolution": "",
	"Extend": "Germany" }],
    "Description": ["osm laods"],
    "Column":[
        {"Name": "id", "Description": "Unique identifier", "Unit": " " },
        {"Name": "area_ha", "Description": "Area", "Unit": "ha" },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "17.12.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "", 
	"URL": "" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('model_draft.ego_demand_la_osm' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','ouput','model_draft','ego_demand_la_osm','process_eGo_osm_loads.sql',' ');


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


---------- ---------- ----------
-- Alternative Calculation with Table
---------- ---------- ----------

-- -- "Create Table"   (OK!) 200ms =0
-- DROP TABLE IF EXISTS  	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer CASCADE;
-- CREATE TABLE         	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer (
-- 		id SERIAL NOT NULL,
-- 		area_ha double precision,
-- 		geom geometry(Polygon,3035),
-- CONSTRAINT 	osm_deu_polygon_urban_buffer100_unbuffer_pkey PRIMARY KEY (id));
-- 
-- "Insert Buffer"   (OK!) 100.000ms =169.639
-- INSERT INTO     openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer(geom)
-- 	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
-- 			ST_BUFFER(ST_TRANSFORM(osm.geom,3035), -100)
-- 		)))).geom ::geometry(Polygon,3035) AS geom
-- 	FROM	openstreetmap.osm_deu_polygon_urban_buffer100_mview AS osm
-- 	GROUP BY osm.id
-- 	ORDER BY osm.id;
-- 
-- -- -- "Extend Table"   (OK!) 150ms =0
-- -- ALTER TABLE	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer
-- -- 	ADD COLUMN zensus_sum integer,
-- -- 	ADD COLUMN zensus_count integer,
-- -- 	ADD COLUMN zensus_density numeric,
-- -- 	ADD COLUMN ioer_sum numeric,
-- -- 	ADD COLUMN ioer_count integer,
-- -- 	ADD COLUMN ioer_density numeric,
-- -- 	ADD COLUMN area_ha numeric,
-- -- 	ADD COLUMN sector_area_residential numeric,
-- -- 	ADD COLUMN sector_area_retail numeric,
-- -- 	ADD COLUMN sector_area_industrial numeric,
-- -- 	ADD COLUMN sector_area_agricultural numeric,
-- -- 	ADD COLUMN sector_share_residential numeric,
-- -- 	ADD COLUMN sector_share_retail numeric,
-- -- 	ADD COLUMN sector_share_industrial numeric,
-- -- 	ADD COLUMN sector_share_agricultural numeric,
-- -- 	ADD COLUMN sector_count_residential integer,
-- -- 	ADD COLUMN sector_count_retail integer,
-- -- 	ADD COLUMN sector_count_industrial integer,
-- -- 	ADD COLUMN sector_count_agricultural integer,
-- -- 	ADD COLUMN mv_poly_id integer,
-- -- 	ADD COLUMN nuts varchar(5),
-- -- 	ADD COLUMN rs varchar(12),
-- -- 	ADD COLUMN ags_0 varchar(8),	
-- -- 	ADD COLUMN geom_centroid geometry(POINT,3035),
-- -- 	ADD COLUMN geom_surfacepoint geometry(POINT,3035),
-- -- 	ADD COLUMN geom_buffer geometry(Polygon,3035);
-- 
-- -- index GIST (geom)
-- CREATE INDEX  	osm_deu_polygon_urban_buffer100_unbuffer_geom_idx
--     ON    	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer
--     USING     	GIST (geom);
-- 
-- -- grant (oeuser)
-- GRANT ALL ON TABLE 	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer OWNER TO oeuser;



---------- ---------- ---------- ---------- ---------- ----------
-- "exclusion"
---------- ---------- ---------- ---------- ---------- ----------

-- -- "Update Area (area_ha)"   (OK!) -> 10.000ms =169.639
-- UPDATE 	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer AS t1
-- SET  	area_ha = t2.area
-- FROM    (
-- 	SELECT	la.id,
-- 		ST_AREA(ST_TRANSFORM(la.geom,3035))/10000 ::double precision AS area
-- 	FROM	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- 	) AS t2
-- WHERE  	t1.id = t2.id;

-- -- "Validate Area (area_ha) kleiner 100m²"   (OK!) 500ms =1.418
-- DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview CASCADE;
-- CREATE MATERIALIZED VIEW 		openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview AS 
-- 	SELECT 	la.id AS id,
-- 		la.area_ha AS area_ha,
-- 		la.geom AS geom
-- 	FROM 	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- 	WHERE	la.area_ha < 0.01;
-- GRANT ALL ON TABLE openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer_error_area_ha_mview TO oeuser WITH GRANT OPTION;
-- 
-- -- "Remove Errors (area_ha)"   (OK!) 700ms =1.418
-- DELETE FROM	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- 	WHERE	la.area_ha < 0.01;
-- 
-- -- "Validate Area (area_ha) Check"   (OK!) 400ms =0
-- SELECT 	la.id AS id,
-- 	la.area_ha AS area_ha,
-- 	la.geom AS geom
-- FROM 	openstreetmap.osm_deu_polygon_urban_buffer100_unbuffer AS la
-- WHERE	la.area_ha < 0.01;
