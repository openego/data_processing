/*
Script to process OpenStreetMap tables after import with osm2pgsql
Basic operations: move to schema; update pkey and index

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

/*
-- Tests for the loops
-- Select all tables with OSM in public
SELECT     *
FROM     information_schema.tables
WHERE     table_schema = 'public'
    AND table_name LIKE 'osm_deu_%';

-- Select all tables with OSM in public
SELECT     * 
FROM     pg_tables
WHERE     schemaname='public'
    AND tablename LIKE 'osm_deu_%';

-- Select all indexes with OSM in public
SELECT     * 
FROM     pg_indexes
WHERE     schemaname='public'
    AND tablename LIKE 'osm_deu_%'
    AND indexname LIKE '%_pkey';
*/ 

-- 0. grant oeuser
DO
$$
DECLARE
    row record;
BEGIN
    FOR row IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename LIKE 'osm_deu_%'
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(row.tablename) || ' OWNER TO oeuser;';
    END LOOP;
END;
$$;


-- 1. Remove wrong index
-- 1.1 Remove all wrong 'pkey' (_line, _point, _polygon, _roads)
DO
$$
DECLARE
    row record;
BEGIN
    FOR row IN SELECT indexname FROM pg_indexes 
    WHERE (schemaname='public' 
    AND indexname LIKE '%_pkey')
    AND (tablename LIKE '%_line'
    OR tablename LIKE '%_point'
    OR tablename LIKE '%_polygon'
    OR tablename LIKE '%_roads')
    LOOP
        EXECUTE 'DROP INDEX public.' || quote_ident(row.indexname) || ';';
    END LOOP;
END;
$$;

-- 1.2 Remove all wrong other indexes (_line, _point, _polygon, _roads)
DO
$$
DECLARE
    row record;
BEGIN
    FOR row IN SELECT indexname FROM pg_indexes 
    WHERE (schemaname='public' 
    AND indexname LIKE '%_index')
    LOOP
        EXECUTE 'DROP INDEX public.' || quote_ident(row.indexname) || ';';
    END LOOP;
END;
$$;

-- 2. Add column 'gid' serial
-- 3. Add primary keys
-- 4. Rename geo-column 'way' to 'geom'
DO
$$
DECLARE
    row record;
BEGIN
    FOR row IN SELECT tablename FROM pg_tables 
    WHERE schemaname='public' 
    AND (tablename LIKE '%_line'
    OR tablename LIKE '%_point'
    OR tablename LIKE '%_polygon'
    OR tablename LIKE '%_roads')
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(row.tablename) || ' ADD gid SERIAL;';
        EXECUTE 'ALTER TABLE public.' || quote_ident(row.tablename) || ' ADD PRIMARY KEY (gid);';
        EXECUTE 'ALTER TABLE public.' || quote_ident(row.tablename) || ' RENAME COLUMN way TO geom;';
    END LOOP;
END;
$$;


-- 5. Set geometry and SRID (original!)

-- ALTER TABLE public.osm_deu_line
--     ALTER COLUMN geom TYPE geometry(LineString,3857) 
--         USING ST_SetSRID(geom,3857);
-- 
-- ALTER TABLE public.osm_deu_point
--     ALTER COLUMN geom TYPE geometry(Point,3857) 
--         USING ST_SetSRID(geom,3857);
-- 
-- ALTER TABLE public.osm_deu_polygon
--     ALTER COLUMN geom TYPE geometry(MultiPolygon, 3857) 
--         USING ST_SetSRID(ST_MULTI(geom),3857);
-- 
-- ALTER TABLE public.osm_deu_roads
--     ALTER COLUMN geom TYPE geometry(LineString,3857) 
--         USING ST_SetSRID(geom,3857);


-- 6. Add index
-- 6.1 Add indexes GIST (geom)
DO
$$
DECLARE
    row record;
BEGIN
    FOR row IN SELECT tablename FROM pg_tables 
    WHERE schemaname='public' 
    AND (tablename LIKE '%_line'
    OR tablename LIKE '%_point'
    OR tablename LIKE '%_polygon'
    OR tablename LIKE '%_roads')
    LOOP
        EXECUTE 'CREATE INDEX ' || quote_ident(row.tablename) || '_geom_idx ON public.' || quote_ident(row.tablename) || ' USING gist (geom);';
    END LOOP;
END;
$$;

-- 6.2 Add indexes GIN (tags)
DO
$$
DECLARE
    row record;
BEGIN
    FOR row IN SELECT tablename FROM pg_tables 
    WHERE schemaname='public' 
    AND (tablename LIKE '%_line'
    OR tablename LIKE '%_point'
    OR tablename LIKE '%_polygon'
    OR tablename LIKE '%_roads')
    LOOP
        EXECUTE 'CREATE INDEX ' || quote_ident(row.tablename) || '_tags_idx ON public.' || quote_ident(row.tablename) || ' USING GIN (tags);';
    END LOOP;
END;
$$;



-- 7. Move all tables to new schema
DO
$$
DECLARE
    row record;
BEGIN
    FOR row IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename LIKE 'osm_deu_%'
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(row.tablename) || ' SET SCHEMA openstreetmap;';
    END LOOP;
END;
$$;


-- 8. metadata
COMMENT ON TABLE openstreetmap.osm_deu_line IS '{
	"title": "OpenStreetMap (OSM) - Germany - Line",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "vector"},
	"temporal": 
		{"reference_date": "2016-10-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Geofabrik - Download - OpenStreetMap Data Extracts",
		"description": "",
		"url": "http://download.geofabrik.de/europe/germany.html",
		"license": "Open Data Commons Open Database License 1.0 (ODbL-1.0)",
		"copyright": "© OpenStreetMap contributors"} ],
	"license": 
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "http://www.openstreetmap.org/copyright/en",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© OpenStreetMap contributors"},
	"contributors": [
		{"name": "Martin Glauer", "mail": "", "date": "2016-10-10", "comment": "Create table with osm2pgsql"},
		{"name": "Ludee", "mail": "", "date": "2016-10-11", "comment": "Execute setup"},
		{"name": "Ludee", "mail": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_line",		
		"format": "sql",
		"fields": [
			{"name": "gid", "description": "Unique identifier", "unit": "none" },
			{"name": "osm_id", "description": "OSM identifier", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "geom", "description": "Geometry", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

COMMENT ON TABLE openstreetmap.osm_deu_nodes IS '{
	"title": "OpenStreetMap (OSM) - Germany - Nodes",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "none"},
	"temporal": 
		{"reference_date": "2016-10-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Geofabrik - Download - OpenStreetMap Data Extracts",
		"description": "",
		"url": "http://download.geofabrik.de/europe/germany.html",
		"license": "Open Data Commons Open Database License 1.0 (ODbL-1.0)",
		"copyright": "© OpenStreetMap contributors"} ],
	"license": 
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "http://www.openstreetmap.org/copyright/en",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© OpenStreetMap contributors"},
	"contributors": [
		{"name": "Martin Glauer", "mail": "", "date": "2016-10-10", "comment": "Create table with osm2pgsql"},
		{"name": "Ludee", "mail": "", "date": "2016-10-11", "comment": "Execute setup"},
		{"name": "Ludee", "mail": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_nodes",		
		"format": "sql",
		"fields": [
			{"name": "id", "description": "Unique identifier", "unit": "none" },
			{"name": "lat", "description": "Latitude", "unit": "none" },
			{"name": "lon", "description": "Longitutde", "unit": "none" },
			{"name": "tags", "description": "Tags", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

COMMENT ON TABLE openstreetmap.osm_deu_point IS '{
	"title": "OpenStreetMap (OSM) - Germany - Point",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "none"},
	"temporal": 
		{"reference_date": "2016-10-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Geofabrik - Download - OpenStreetMap Data Extracts",
		"description": "",
		"url": "http://download.geofabrik.de/europe/germany.html",
		"license": "Open Data Commons Open Database License 1.0 (ODbL-1.0)",
		"copyright": "© OpenStreetMap contributors"} ],
	"license": 
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "http://www.openstreetmap.org/copyright/en",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© OpenStreetMap contributors"},
	"contributors": [
		{"name": "Martin Glauer", "mail": "", "date": "2016-10-10", "comment": "Create table with osm2pgsql"},
		{"name": "Ludee", "mail": "", "date": "2016-10-11", "comment": "Execute setup"},
		{"name": "Ludee", "mail": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_point",		
		"format": "sql",
		"fields": [
			{"name": "gid", "description": "Unique identifier", "unit": "none" },
			{"name": "osm_id", "description": "OSM identifier", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "geom", "description": "Geometry", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

COMMENT ON TABLE openstreetmap.osm_deu_polygon IS '{
	"title": "OpenStreetMap (OSM) - Germany - Polygon",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "none"},
	"temporal": 
		{"reference_date": "2016-10-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Geofabrik - Download - OpenStreetMap Data Extracts",
		"description": "",
		"url": "http://download.geofabrik.de/europe/germany.html",
		"license": "Open Data Commons Open Database License 1.0 (ODbL-1.0)",
		"copyright": "© OpenStreetMap contributors"} ],
	"license": 
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "http://www.openstreetmap.org/copyright/en",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© OpenStreetMap contributors"},
	"contributors": [
		{"name": "Martin Glauer", "mail": "", "date": "2016-10-10", "comment": "Create table with osm2pgsql"},
		{"name": "Ludee", "mail": "", "date": "2016-10-11", "comment": "Execute setup"},
		{"name": "Ludee", "mail": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_polygon",		
		"format": "sql",
		"fields": [
			{"name": "gid", "description": "Unique identifier", "unit": "none" },
			{"name": "osm_id", "description": "OSM identifier", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "geom", "description": "Geometry", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

COMMENT ON TABLE openstreetmap.osm_deu_rels IS '{
	"title": "OpenStreetMap (OSM) - Germany - Rels",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "none"},
	"temporal": 
		{"reference_date": "2016-10-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Geofabrik - Download - OpenStreetMap Data Extracts",
		"description": "",
		"url": "http://download.geofabrik.de/europe/germany.html",
		"license": "Open Data Commons Open Database License 1.0 (ODbL-1.0)",
		"copyright": "© OpenStreetMap contributors"} ],
	"license": 
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "http://www.openstreetmap.org/copyright/en",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© OpenStreetMap contributors"},
	"contributors": [
		{"name": "Martin Glauer", "mail": "", "date": "2016-10-10", "comment": "Create table with osm2pgsql"},
		{"name": "Ludee", "mail": "", "date": "2016-10-11", "comment": "Execute setup"},
		{"name": "Ludee", "mail": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_rels",		
		"format": "sql",
		"fields": [
			{"name": "id", "description": "Unique identifier", "unit": "none" },
			{"name": "way_off", "description": "", "unit": "none" },
			{"name": "rel_off", "description": "", "unit": "none" },
			{"name": "parts", "description": "", "unit": "none" },
			{"name": "members", "description": "", "unit": "none" },
			{"name": "tags", "description": "", "unit": "none" },
			{"name": "pending", "description": "", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

COMMENT ON TABLE openstreetmap.osm_deu_roads IS '{
	"title": "OpenStreetMap (OSM) - Germany - Roads",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "none"},
	"temporal": 
		{"reference_date": "2016-10-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Geofabrik - Download - OpenStreetMap Data Extracts",
		"description": "",
		"url": "http://download.geofabrik.de/europe/germany.html",
		"license": "Open Data Commons Open Database License 1.0 (ODbL-1.0)",
		"copyright": "© OpenStreetMap contributors"} ],
	"license": 
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "http://www.openstreetmap.org/copyright/en",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© OpenStreetMap contributors"},
	"contributors": [
		{"name": "Martin Glauer", "mail": "", "date": "2016-10-10", "comment": "Create table with osm2pgsql"},
		{"name": "Ludee", "mail": "", "date": "2016-10-11", "comment": "Execute setup"},
		{"name": "Ludee", "mail": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_roads",		
		"format": "sql",
		"fields": [
			{"name": "gid", "description": "Unique identifier", "unit": "none" },
			{"name": "osm_id", "description": "OSM identifier", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "geom", "description": "Geometry", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

COMMENT ON TABLE openstreetmap.osm_deu_ways IS '{
	"title": "OpenStreetMap (OSM) - Germany - Ways",
	"description": "OpenStreetMap is a free, editable map of the whole world that is being built by volunteers largely from scratch and released with an open-content license.",
	"language": [ "eng", "ger" ],
	"spatial": 
		{"location": "none",
		"extent": "Germany",
		"resolution": "none"},
	"temporal": 
		{"reference_date": "2016-10-01",
		"start": "none",
		"end": "none",
		"resolution": "none"},
	"sources": [
		{"name": "Geofabrik - Download - OpenStreetMap Data Extracts",
		"description": "",
		"url": "http://download.geofabrik.de/europe/germany.html",
		"license": "Open Data Commons Open Database License 1.0 (ODbL-1.0)",
		"copyright": "© OpenStreetMap contributors"} ],
	"license": 
		{"id": 	"ODbL-1.0",
		"name": "Open Data Commons Open Database License 1.0",
		"version": "1.0",
		"url": "http://www.openstreetmap.org/copyright/en",
		"instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
		"copyright": "© OpenStreetMap contributors"},
	"contributors": [
		{"name": "Martin Glauer", "mail": "", "date": "2016-10-10", "comment": "Create table with osm2pgsql"},
		{"name": "Ludee", "mail": "", "date": "2016-10-11", "comment": "Execute setup"},
		{"name": "Ludee", "mail": "", "date": "2017-06-30", "comment": "Update metadata to 1.3"} ],
	"resources": [
		{"name": "openstreetmap.osm_deu_ways",		
		"format": "sql",
		"fields": [
			{"name": "id", "description": "Unique identifier", "unit": "none" },
			{"name": "nodes", "description": "", "unit": "none" },
			{"name": "tags", "description": "A tag consists of two items, a key and a value. Tags describe specific features of map elements (nodes, ways, or relations) or changesets. Both items are free format text fields, but often represent numeric or other structured items. Conventions are agreed on the meaning and use of tags, which are captured on this wiki.", "url": "http://wiki.openstreetmap.org/wiki/Tags", "unit": "none" },
			{"name": "pending", "description": "", "unit": "" } ] } ],
	"metadata_version": "1.3"}';

-- 9. scenario log

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_line','ego_pp_import_osm_deu.sql','setup osm tables');
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_nodes','ego_pp_import_osm_deu.sql','setup osm tables');
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_point','ego_pp_import_osm_deu.sql','setup osm tables');
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_polygon','ego_pp_import_osm_deu.sql','setup osm tables');
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_rels','ego_pp_import_osm_deu.sql','setup osm tables');
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_roads','ego_pp_import_osm_deu.sql','setup osm tables');
SELECT ego_scenario_log('v0.2.10','preprocessing','openstreetmap','osm_deu_ways','ego_pp_import_osm_deu.sql','setup osm tables');
