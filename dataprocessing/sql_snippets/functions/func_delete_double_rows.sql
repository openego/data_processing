﻿
---------- ---------- ----------
-- Delete double entries on "gid" 
---------- ---------- ----------

-- -- Find double entries (OK!) -> =18
-- SELECT 		gid, count(*)
-- FROM 		orig_geo_ego.osm_deu_polygon_spf
-- GROUP BY 	gid
-- HAVING 		count(*) > 1;
-- 
-- -- --  IF double 
-- -- Create nodubs (OK!)
-- DROP TABLE IF EXISTS	orig_geo_ego.osm_deu_polygon_spf_nodubs;
-- CREATE TABLE		orig_geo_ego.osm_deu_polygon_spf_nodubs AS
-- 	SELECT	osm.*
-- 	FROM	orig_geo_ego.osm_deu_polygon_spf AS osm
-- 	LIMIT 	0;
-- 
-- -- Add id (OK!)
-- ALTER TABLE 	orig_geo_ego.osm_deu_polygon_spf_nodubs
-- 	ADD column id serial;
-- 
-- -- Insert data (OK!) 94ms =1567
-- INSERT INTO	orig_geo_ego.osm_deu_polygon_spf_nodubs
-- 	SELECT	osm.*
-- 	FROM	orig_geo_ego.osm_deu_polygon_spf AS osm
-- ORDER BY 	gid;
-- 
-- -- Delete double entries (OK!) 62ms =-18
-- DELETE FROM orig_geo_ego.osm_deu_polygon_spf_nodubs
-- WHERE id IN (SELECT id
--               FROM (SELECT id,
--                              ROW_NUMBER() OVER (partition BY gid ORDER BY id) AS rnum
--                      FROM orig_geo_ego.osm_deu_polygon_spf_nodubs) t
--               WHERE t.rnum > 1);
-- 
-- -- Check for doubles again (OK!)
-- SELECT 		gid, count(*)
-- FROM 		orig_geo_ego.osm_deu_polygon_spf_nodubs
-- GROUP BY 	gid
-- HAVING 		count(*) > 1;
-- 
-- -- Set PK (OK!)
-- ALTER TABLE 	orig_geo_ego.osm_deu_polygon_spf_nodubs ADD PRIMARY KEY (gid);
-- 
-- -- Create new index (OK!)
-- CREATE INDEX  	osm_deu_polygon_spf_nodubs_geom_idx
--     ON    	orig_geo_ego.osm_deu_polygon_spf_nodubs
--     USING     	GIST (geom);