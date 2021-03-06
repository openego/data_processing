/*
analyse OSM landuse data

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','openstreetmap','osm_deu_polygon','ego_dp_structure_osm_landuse.sql',' ');

-- 2016-10-01 openstreetmap
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_landuse_mview CASCADE;
CREATE MATERIALIZED VIEW 		openstreetmap.osm_deu_polygon_landuse_mview AS
	SELECT	osm.gid, 
		osm.tags, 
		osm.geom
	FROM	openstreetmap.osm_deu_polygon AS osm
	WHERE	tags ? 'landuse'
	ORDER BY osm.osm_id;

-- index (id)
CREATE INDEX  	osm_deu_polygon_landuse_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_landuse_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	openstreetmap.osm_deu_polygon_landuse_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW openstreetmap.osm_deu_polygon_landuse_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.3.0" }' ;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','openstreetmap','osm_deu_polygon_landuse_mview','ego_dp_structure_osm_landuse.sql',' ');


/* 
-- 2016-01-13 orig_osm
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_landuse_20160113_mview CASCADE;
CREATE MATERIALIZED VIEW 		openstreetmap.osm_deu_landuse_20160113_mview AS
	SELECT	osm.gid, osm.tags, osm.geom
	FROM	orig_osm.osm_deu_polygon AS osm
	WHERE	tags ? 'landuse'
	ORDER BY osm.osm_id;

-- "Create Index GIST (geom)"   (OK!) -> 6.000ms =0
CREATE INDEX  	osm_deu_landuse_20160113_mview_geom_idx
	ON	openstreetmap.osm_deu_landuse_20160113_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	openstreetmap.osm_deu_landuse_20160113_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.osm_deu_landuse_20160113_mview OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'openstreetmap' AS schema_name,
		'osm_deu_landuse_20160113_mview' AS table_name,
		'ego_dp_structure_osm_landuse.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	openstreetmap.osm_deu_landuse_20160113_mview;


-- 2016-09-16 openstreetmap
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_landuse_20160916_mview CASCADE;
CREATE MATERIALIZED VIEW 		openstreetmap.osm_deu_landuse_20160916_mview AS
	SELECT	osm.gid, osm.tags, osm.geom
	FROM	openstreetmap.osm_deu_polygon AS osm
	WHERE	tags ? 'landuse'
	ORDER BY osm.osm_id;

-- "Create Index GIST (geom)"   (OK!) -> 6.000ms =0
CREATE INDEX  	osm_deu_landuse_20160916_mview_geom_idx
	ON	openstreetmap.osm_deu_landuse_20160916_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	openstreetmap.osm_deu_landuse_20160916_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.osm_deu_landuse_20160916_mview OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'openstreetmap' AS schema_name,
		'osm_deu_landuse_20160916_mview' AS table_name,
		'ego_dp_structure_osm_landuse.sql' AS script_name,
		COUNT(geom)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	openstreetmap.osm_deu_landuse_20160916_mview;


-- 2016-10-05 public
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_landuse_20161005_mview CASCADE;
CREATE MATERIALIZED VIEW 		openstreetmap.osm_deu_landuse_20161005_mview AS
	SELECT	row_number() OVER() AS "id",osm.osm_id, osm.tags, osm.way
	FROM	public.osm_deu_polygon AS osm
	WHERE	tags ? 'landuse'
	ORDER BY osm.osm_id;

-- "Create Index GIST (geom)"   (OK!) -> 6.000ms =0
CREATE INDEX  	osm_deu_landuse_20161005_mview_way_idx
	ON	openstreetmap.osm_deu_landuse_20161005_mview
	USING	GIST (way);

-- "Create Index (id)"   (OK!) -> 6.000ms =0
CREATE UNIQUE INDEX  	osm_deu_landuse_20161005_mview_osm_id_idx
	ON	openstreetmap.osm_deu_landuse_20161005_mview (id);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	openstreetmap.osm_deu_landuse_20161005_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		openstreetmap.osm_deu_landuse_20161005_mview OWNER TO oeuser;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'openstreetmap' AS schema_name,
		'osm_deu_landuse_20161005_mview' AS table_name,
		'ego_dp_structure_osm_landuse.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	openstreetmap.osm_deu_landuse_20161005_mview;
*/ 


/*
	SELECT	COUNT(osm.*) AS cnt
	FROM	public.osm_deu_polygon AS osm
	WHERE	tags ? 'landuse';

	SELECT	osm.osm_id,osm.tags
	FROM	public.osm_deu_polygon AS osm
	WHERE	tags ? 'landuse'
	ORDER BY osm.osm_id
	LIMIT 100;

	SELECT	osm.osm_id,osm.tags
	FROM	orig_osm.osm_deu_polygon AS osm
	WHERE	tags ? 'landuse'
	ORDER BY osm.osm_id
	LIMIT 100;
*/ 

