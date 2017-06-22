/*
Setup OpenStreetMap (OSM) tables

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


/* 
-- TESTS:
-- Select all tables with OSM in public
SELECT     *
FROM     information_schema.tables
WHERE     table_schema = 'public'
    AND table_name LIKE 'osm_%';

-- Select all tables with OSM in public
SELECT     * 
FROM     pg_tables
WHERE     schemaname='public'
    AND tablename LIKE 'osm_%';

-- Select all indexes with OSM in public
SELECT     * 
FROM     pg_indexes
WHERE     schemaname='public'
    AND tablename LIKE 'osm_%'
    AND indexname LIKE '%_pkey';

-- 0. Create new schema
CREATE SCHEMA orig_osm;

-- 1. Move all tables to new schema
DO
$$
DECLARE
    row record;
BEGIN
    FOR row IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename LIKE 'osm_%'
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(row.tablename) || ' SET SCHEMA orig_osm;';
    END LOOP;
END;
$$;

-- 2. Remove all wrong 'pkey' indexes (_line, _point, _polygon, _roads)
DO
$$
DECLARE
    row record;
BEGIN
    FOR row IN SELECT indexname FROM pg_indexes 
    WHERE schemaname='orig_osm' 
    AND indexname LIKE '%_pkey'
    AND tablename LIKE '%_line'
    OR tablename LIKE '%_point'
    OR tablename LIKE '%_polygon'
    OR tablename LIKE '%_roads'
    LOOP
        EXECUTE 'DROP INDEX orig_osm.' || quote_ident(row.indexname) || ';';
    END LOOP;
END;
$$;

-- 3. Add column 'gid' serial
-- 4. Add primary keys
-- 5. Rename geo-column 'way' to 'geom'
DO
$$
DECLARE
    row record;
BEGIN
    FOR row IN SELECT tablename FROM pg_tables 
    WHERE schemaname='orig_osm' 
    AND tablename LIKE '%_line'
    OR tablename LIKE '%_point'
    OR tablename LIKE '%_polygon'
    OR tablename LIKE '%_roads'
    LOOP
        EXECUTE 'ALTER TABLE orig_osm.' || quote_ident(row.tablename) || ' ADD gid SERIAL;';
        EXECUTE 'ALTER TABLE orig_osm.' || quote_ident(row.tablename) || ' ADD PRIMARY KEY (gid);';
        EXECUTE 'ALTER TABLE orig_osm.' || quote_ident(row.tablename) || ' RENAME COLUMN way TO geom;';
    END LOOP;
END;
$$;

-- 6. Set geometry and SRID

ALTER TABLE orig_osm.osm_deu_line
    ALTER COLUMN geom TYPE geometry(LineString,3857) 
        USING ST_SetSRID(geom,3857);

ALTER TABLE orig_osm.osm_deu_point
    ALTER COLUMN geom TYPE geometry(Point,3857) 
        USING ST_SetSRID(geom,3857);

ALTER TABLE orig_osm.osm_deu_polygon
    ALTER COLUMN geom TYPE geometry(MultiPolygon, 3857) 
        USING ST_SetSRID(ST_MULTI(geom),3857);

ALTER TABLE orig_osm.osm_deu_roads
    ALTER COLUMN geom TYPE geometry(LineString,3857) 
        USING ST_SetSRID(geom,3857);

-- 7. Add indexes GIST (geom) and GIN (tags)
DO
$$
DECLARE
    row record;
BEGIN
    FOR row IN SELECT tablename FROM pg_tables 
    WHERE schemaname='orig_osm' 
    AND tablename LIKE '%_line'
    OR tablename LIKE '%_point'
    OR tablename LIKE '%_polygon'
    OR tablename LIKE '%_roads'
    LOOP
        EXECUTE 'CREATE INDEX ' || quote_ident(row.tablename) || '_geom_idx ON orig_osm.' || quote_ident(row.tablename) || ' USING gist (geom);';
        EXECUTE 'CREATE INDEX ' || quote_ident(row.tablename) || '_tags_idx ON orig_osm.' || quote_ident(row.tablename) || ' USING GIN (tags);';
    END LOOP;
END;
$$;
 */

-- metadata template
COMMENT ON TABLE openstreetmap.osm_deu_line IS '{
	"title": "OpenStreetMap (OSM) - Germany - Line",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"reference_date": "2016-10-01",
	"spatial": [
		{"extent": "Germany",
		"resolution": "vector"} ],
	"temporal": [
		{"start": "none",
		"end": "none",
		"resolution": "none"} ],
	"sources": [
		{"name": "Geofabrik - Download - OpenStreetMap Data Extracts", "description": "", "url": "http://download.geofabrik.de/europe/germany.html", "license": "Open Data Commons Open Database License 1.0 (ODbL-1.0)", "copyright": "© OpenStreetMap contributors"} ],
	"license": [
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "http://www.openstreetmap.org/copyright/en",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© OpenStreetMap contributors"} ],
	"contributors": [
		{"name": "Martin Glauer", "mail": "", "date": "2016-10-10", "comment": "Create table with osm2pgsql"},
		{"name": "Ludee", "mail": "", "date": "2016-10-11", "comment": "Execute setup"},
		{"name": "Ludee", "mail": "", "date": "2016-10-11", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_line",		
		"format": "sql",
		"fields": [
			{"name": "osm_id", "description": "OSM identifier", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "gid", "description": "OEP identifier", "unit": "none" },
			{"name": "geom", "description": "Geometry", "unit": "" }] }],
	"metadata_version": "1.3"}';

-- select description
SELECT obj_description('openstreetmap.osm_deu_line' ::regclass) ::json;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 