/*
osm landuse sector

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

---------- ---------- ---------- ---------- ---------- ---------- 
-- "2. Data Setup OSM"   2016-04-18 10:00 11s 
---------- ---------- ---------- ---------- ---------- ---------- 

-- -- "Validate (geom)"   (OK!) -> 100ms =0
-- DROP VIEW IF EXISTS	openstreetmap.osm_deu_polygon_error_geom_view CASCADE;
-- CREATE VIEW		openstreetmap.osm_deu_polygon_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	openstreetmap.osm_deu_polygon AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- grant (oeuser)
-- GRANT ALL ON TABLE	openstreetmap.osm_deu_polygon_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		openstreetmap.osm_deu_polygon_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 1.581.000ms =1
-- SELECT f_drop_view('{osm_deu_polygon_error_geom_view}', 'orig_osm');

---------- ---------- ----------
-- "Filter OSM Urban Landuse"
---------- ---------- ----------
-- ToDo: change "urban" to electrified

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','input','openstreetmap','osm_deu_polygon','ego_dp_loadarea_landuse.sql',' ');

-- filter urban
DROP TABLE IF EXISTS	openstreetmap.osm_deu_polygon_urban CASCADE;
CREATE TABLE		openstreetmap.osm_deu_polygon_urban AS
	SELECT	osm.gid ::integer AS gid,
		osm.osm_id ::integer AS osm_id,
		--osm.landuse ::text AS landuse,
		--osm.man_made ::text AS man_made,
		--osm.aeroway ::text AS aeroway,
		osm.name ::text AS name,
		--osm.way_area ::double precision AS way_area,
		'0' ::integer AS sector,
		ST_AREA(ST_TRANSFORM(osm.geom,3035))/10000 ::double precision AS area_ha,
		osm.tags ::hstore AS tags,
		'outside' ::text AS vg250,
		ST_MULTI(ST_TRANSFORM(osm.geom,3035)) ::geometry(MultiPolygon,3035) AS geom		
	FROM	openstreetmap.osm_deu_polygon AS osm
	WHERE	tags @> '"landuse"=>"residential"'::hstore OR 
		tags @> '"landuse"=>"commercial"'::hstore OR 
		tags @> '"landuse"=>"retail"'::hstore OR 
		tags @> '"landuse"=>"industrial;retail"'::hstore OR 
			
		tags @> '"landuse"=>"industrial"'::hstore OR 
		tags @> '"landuse"=>"port"'::hstore OR 
		tags @> '"man_made"=>"wastewater_plant"'::hstore OR
		tags @> '"aeroway"=>"terminal"'::hstore OR 
		tags @> '"aeroway"=>"gate"'::hstore OR 
		tags @> '"man_made"=>"works"'::hstore OR 
		
		tags @> '"landuse"=>"farmyard"'::hstore OR 
		tags @> '"landuse"=>"greenhouse_horticulture"'::hstore 
	
		--osm.landuse='residential' OR
		--osm.landuse='commercial' OR 
		--osm.landuse='retail' OR
		--osm.landuse='industrial;retail' OR
		--osm.landuse='industrial' OR 
		--osm.landuse='port' OR
		--osm.man_made='wastewater_plant' OR
		--osm.aeroway='terminal' OR
		--osm.aeroway='gate' OR
		--osm.man_made='works' OR
		--osm.landuse='farmyard' OR 
		--osm.landuse='greenhouse_horticulture'
	ORDER BY	osm.gid;

-- PK
ALTER TABLE openstreetmap.osm_deu_polygon_urban
	ADD PRIMARY KEY (gid);

-- index GIST (geom)
CREATE INDEX  	osm_deu_polygon_urban_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	openstreetmap.osm_deu_polygon_urban OWNER TO oeuser;


-- OSM Urban Landuse Inside vg250

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','input','political_boundary','bkg_vg250_1_sta_union_mview','ego_dp_loadarea_landuse.sql',' ');

-- Calculate 'inside' vg250
UPDATE 	openstreetmap.osm_deu_polygon_urban AS t1
	SET  	vg250 = t2.vg250
	FROM    (
		SELECT	osm.gid AS gid,
			'inside' ::text AS vg250
		FROM	political_boundary.bkg_vg250_1_sta_union_mview AS vg,
			openstreetmap.osm_deu_polygon_urban AS osm
		WHERE  	vg.geom && osm.geom AND
			ST_CONTAINS(vg.geom,osm.geom)
		) AS t2
	WHERE  	t1.gid = t2.gid;

-- Calculate 'crossing' vg250
UPDATE 	openstreetmap.osm_deu_polygon_urban AS t1
	SET  	vg250 = t2.vg250
	FROM    (
		SELECT	osm.gid AS gid,
			'crossing' ::text AS vg250
		FROM	political_boundary.bkg_vg250_1_sta_union_mview AS vg,
			openstreetmap.osm_deu_polygon_urban AS osm
		WHERE  	osm.vg250 = 'outside' AND
			vg.geom && osm.geom AND
			ST_Overlaps(vg.geom,osm.geom)
		) AS t2
	WHERE  	t1.gid = t2.gid;


-- OSM outside of vg250

-- OSM error vg250
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview CASCADE;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview AS
	SELECT	osm.*
	FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	osm.vg250 = 'outside' OR osm.vg250 = 'crossing';

-- index (id)
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_error_geom_vg250_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview (gid);

-- index GIST (geom)
CREATE INDEX  	osm_deu_polygon_urban_error_geom_vg250_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview
	USING	GIST (geom);

-- grant (oeuser)
ALTER TABLE	openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview OWNER TO oeuser;	


-- Sequence
DROP SEQUENCE IF EXISTS 	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview_id CASCADE;
CREATE SEQUENCE 		openstreetmap.osm_deu_polygon_urban_vg250_cut_mview_id;

-- grant (oeuser)
ALTER SEQUENCE		openstreetmap.osm_deu_polygon_urban_vg250_cut_mview_id OWNER TO oeuser;

-- Cutting 'crossing' with vg250
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_vg250_cut_mview AS
	SELECT	nextval('openstreetmap.osm_deu_polygon_urban_vg250_cut_mview_id') ::integer AS id,
		cut.gid ::integer AS gid,
		cut.osm_id ::integer AS osm_id,
		--cut.landuse ::text AS landuse,
		--cut.man_made ::text AS man_made,
		--cut.aeroway ::text AS aeroway,
		cut.name ::text AS name,
		--cut.way_area ::double precision AS way_area,
		cut.sector ::integer AS sector,
		cut.area_ha ::double precision AS area_ha,
		cut.tags ::hstore AS tags,
		cut.vg250 ::text AS vg250,
		GeometryType(cut.geom_new) ::text AS geom_type,
		ST_MULTI(ST_TRANSFORM(cut.geom_new,3035)) ::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT	poly.*,
			ST_INTERSECTION(poly.geom,cut.geom) AS geom_new
		FROM	openstreetmap.osm_deu_polygon_urban_error_geom_vg250_mview AS poly,
			political_boundary.bkg_vg250_1_sta_union_mview AS cut
		WHERE	poly.vg250 = 'crossing'
		) AS cut
	ORDER BY 	cut.gid;

-- index (id)
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_vg250_cut_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview (gid);

-- index GIST (geom)
CREATE INDEX  	osm_deu_polygon_urban_vg250_cut_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview
	USING	GIST (geom);

-- grant (oeuser)
ALTER TABLE	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview OWNER TO oeuser;

-- Find double entries (OK!) -> =0
-- SELECT 		gid, count(*)
-- FROM 		openstreetmap.osm_deu_polygon_urban_vg250_cut_mview
-- GROUP BY 	gid
-- HAVING 		count(*) > 1;


-- 'crossing' Polygon to MultiPolygon
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview AS
	SELECT	nextval('openstreetmap.osm_deu_polygon_gid_seq'::regclass) ::integer AS gid,
		cut.osm_id ::integer AS osm_id,
		--cut.landuse ::text AS landuse,
		--cut.man_made ::text AS man_made,
		--cut.aeroway ::text AS aeroway,
		cut.name ::text AS name,
		cut.sector ::integer AS sector,
		--cut.way_area ::double precision AS way_area,
		cut.area_ha ::double precision AS area_ha,
		cut.tags ::hstore AS tags,
		cut.vg250 ::text AS vg250,
		ST_MULTI(cut.geom) ::geometry(MultiPolygon,3035) AS geom
	FROM	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview AS cut
	WHERE	cut.geom_type = 'POLYGON';

-- index (id)
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_vg250_clean_cut_multi_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview (gid);

-- index GIST (geom)
CREATE INDEX  	osm_deu_polygon_urban_vg250_clean_cut_multi_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview
	USING	GIST (geom);

-- grant (oeuser)
ALTER TABLE	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview OWNER TO oeuser;

-- Find double entries (OK!) -> =0
-- SELECT 		gid, count(*)
-- FROM 		openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview
-- GROUP BY 	gid
-- HAVING 		count(*) > 1;

---------- ---------- ----------

-- clean cut
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_mview;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_mview AS
	SELECT	nextval('openstreetmap.osm_deu_polygon_gid_seq'::regclass) ::integer AS gid,
		cut.osm_id ::integer AS osm_id,
		--cut.landuse ::text AS landuse,
		--cut.man_made ::text AS man_made,
		--cut.aeroway ::text AS aeroway,
		cut.name ::text AS name,
		cut.sector ::integer AS sector,
		--cut.way_area ::double precision AS way_area,
		cut.area_ha ::double precision AS area_ha,
		cut.tags ::hstore AS tags,
		cut.vg250 ::text AS vg250,
		cut.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	openstreetmap.osm_deu_polygon_urban_vg250_cut_mview AS cut
	WHERE	cut.geom_type = 'MULTIPOLYGON';

-- index (id)
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_vg250_clean_cut_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_mview (gid);


-- remove 'outside' vg250
DELETE FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	osm.vg250 = 'outside';

-- remove 'outside' vg250
DELETE FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	osm.vg250 = 'crossing';

-- insert cut
INSERT INTO	openstreetmap.osm_deu_polygon_urban
	SELECT	clean.*
	FROM	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_mview AS clean
	ORDER BY 	clean.gid;

-- insert cut multi
INSERT INTO	openstreetmap.osm_deu_polygon_urban
	SELECT	clean.*
	FROM	openstreetmap.osm_deu_polygon_urban_vg250_clean_cut_multi_mview AS clean
	ORDER BY 	clean.gid;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','output','openstreetmap','osm_deu_polygon_urban','ego_dp_loadarea_landuse.sql',' ');

	
---------- ---------- ----------
-- "(Geo) Data Validation"
---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_error_geom_mview CASCADE;
-- CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_error_geom_mview AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	openstreetmap.osm_deu_polygon_urban AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- grant (oeuser)
-- GRANT ALL ON TABLE	openstreetmap.osm_deu_polygon_urban_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		openstreetmap.osm_deu_polygon_urban_error_geom_view OWNER TO oeuser;

---------- ---------- ----------

-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_error_geom_view CASCADE;
-- CREATE VIEW		openstreetmap.osm_deu_polygon_urban_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	openstreetmap.osm_deu_polygon_urban AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- grant (oeuser)
-- GRANT ALL ON TABLE	openstreetmap.osm_deu_polygon_urban_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		openstreetmap.osm_deu_polygon_urban_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{osm_deu_polygon_urban_error_geom_view}', 'orig_osm');


-- "Filter by Sector"

-- Sector 1. Residential
-- update sector
UPDATE 	openstreetmap.osm_deu_polygon_urban
SET  	sector = '1'
WHERE	tags @> '"landuse"=>"residential"'::hstore;

-- filter residential
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview CASCADE;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview AS
	SELECT	osm.*
	FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	sector = '1'
ORDER BY	osm.gid;

-- index (id)
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_1_residential_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview (gid);

-- index GIST (geom)
CREATE INDEX  	osm_deu_polygon_urban_sector_1_residential_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview
	USING	GIST (geom);
	
-- grant (oeuser)
ALTER TABLE	openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','output','openstreetmap','osm_deu_polygon_urban_sector_1_residential_mview','ego_dp_loadarea_landuse.sql',' ');


-- Sector 2. Retail
-- update sector
UPDATE 	openstreetmap.osm_deu_polygon_urban
SET  	sector = '2'
WHERE	tags @> '"landuse"=>"commercial"'::hstore OR 
		tags @> '"landuse"=>"retail"'::hstore OR 
		tags @> '"landuse"=>"industrial;retail"'::hstore;

-- Filter Retail
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview CASCADE;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview AS
	SELECT	osm.*
	FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	sector = '2'
ORDER BY	osm.gid;
    
-- index (id)
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_2_retail_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview (gid);

-- index GIST (geom)
CREATE INDEX  	osm_deu_polygon_urban_sector_2_retail_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview
	USING	GIST (geom);
	
-- grant (oeuser)
ALTER TABLE	openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','output','openstreetmap','osm_deu_polygon_urban_sector_2_retail_mview','ego_dp_loadarea_landuse.sql',' ');


-- Sector 3. Industrial
-- update sector
UPDATE 	openstreetmap.osm_deu_polygon_urban
SET  	sector = '3'
WHERE	tags @> '"landuse"=>"industrial"'::hstore OR 
		tags @> '"landuse"=>"port"'::hstore OR 
		tags @> '"man_made"=>"wastewater_plant"'::hstore OR
		tags @> '"aeroway"=>"terminal"'::hstore OR 
		tags @> '"aeroway"=>"gate"'::hstore OR 
		tags @> '"man_made"=>"works"'::hstore;


-- filter Industrial
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview CASCADE;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview AS
	SELECT	osm.*
	FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	sector = '3'
ORDER BY	osm.gid;

-- index (id)
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_3_industrial_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview (gid);

-- index GIST (geom)
CREATE INDEX  	osm_deu_polygon_urban_sector_3_industrial_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview
	USING	GIST (geom);
	
-- grant (oeuser)
ALTER TABLE	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','output','openstreetmap','osm_deu_polygon_urban_sector_3_industrial_mview','ego_dp_loadarea_landuse.sql',' ');


-- sector 4. Agricultural
-- update sector
UPDATE 	openstreetmap.osm_deu_polygon_urban
	SET  	sector = '4'
	WHERE	tags @> '"landuse"=>"farmyard"'::hstore OR 
		tags @> '"landuse"=>"greenhouse_horticulture"'::hstore;

-- filter agricultural
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview CASCADE;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview AS
	SELECT	osm.*
	FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	sector = '4'
	ORDER BY	osm.gid;

-- index (id)
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_4_agricultural_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview (gid);

-- index GIST (geom)
CREATE INDEX  	osm_deu_polygon_urban_sector_4_agricultural_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview
	USING	GIST (geom);

-- grant (oeuser)
ALTER TABLE	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.8','output','openstreetmap','osm_deu_polygon_urban_sector_4_agricultural_mview','ego_dp_loadarea_landuse.sql',' ');


-- -- "Validate (geom)"   (OK!) -> 22.000ms =0
-- DROP VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview_error_geom_view CASCADE;
-- CREATE VIEW		openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview_error_geom_view AS 
-- 	SELECT	test.id,
-- 		test.error,
-- 		reason(ST_IsValidDetail(test.geom)) AS error_reason,
-- 		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
-- 	FROM	(
-- 		SELECT	source.gid AS id,				-- PK
-- 			ST_IsValid(source.geom) AS error,
-- 			source.geom AS geom
-- 		FROM	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview AS source	-- Table
-- 		) AS test
-- 	WHERE	test.error = FALSE;
-- 
-- -- grant (oeuser)
-- GRANT ALL ON TABLE	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview_error_geom_view TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview_error_geom_view OWNER TO oeuser;
-- 
-- -- "Drop empty view"   (OK!) -> 100ms =1
-- SELECT f_drop_view('{osm_deu_polygon_urban_sector_4_agricultural_mview_error_geom_view}', 'orig_osm');


