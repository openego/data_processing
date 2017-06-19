﻿---------- ---------- ----------
---------- --SKRIPT-- OK! 11s
---------- ---------- ----------

-- Separate SPF-Testregion from VG250 Kreise   (OK!) -> 1.000ms =432
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_vg250.vg250_4_krs_spf_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_geo_vg250.vg250_4_krs_spf_mview AS 
 SELECT 	vg.gid,
		vg.gen AS name,
		ST_AREA(ST_Transform(vg.geom, 3035)) / 10000::double precision AS area_km2,
		vg.geom
   FROM orig_geo_vg250.vg250_4_krs vg
  WHERE vg.gen = 'Unterallgäu' OR vg.gen = 'Memmingen';

-- "Create Index (id)"   (OK!) -> 100ms =0
CREATE UNIQUE INDEX  	vg250_4_krs_spf_mview_gid_idx
		ON	orig_geo_vg250.vg250_4_krs_spf_mview (gid);

-- "Create Index GIST (geom)"   (OK!) -> 200ms =0
CREATE INDEX  	vg250_4_krs_spf_mview_geom_idx
	ON	orig_geo_vg250.vg250_4_krs_spf_mview
	USING	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_vg250.vg250_4_krs_spf_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_geo_vg250.vg250_4_krs_spf_mview OWNER TO oeuser;

---------- ---------- ---------- ---------- ---------- ----------
-- "LOADS"   2016-04-06 15:17   12s
---------- ---------- ---------- ---------- ---------- ----------




---------- ---------- ----------
-- "Create SPF"   2016-04-06 14:50   3s
---------- ---------- ----------

-- "Create Table SPF"   (OK!) 17.000ms =901
DROP TABLE IF EXISTS  	calc_ego_loads.ego_deu_loads_melted_spf;
CREATE TABLE         	calc_ego_loads.ego_deu_loads_melted_spf AS
	SELECT	lc.*,
		ST_CENTROID(lc.geom) :: geometry(Point, 3035) AS geom_centre
	FROM	calc_ego_loads.ego_deu_loads_melted AS lc,
		orig_geo_vg250.vg250_4_krs_spf_mview AS spf
	WHERE	ST_TRANSFORM(spf.geom,3035) && lc.geom  AND  
		ST_CONTAINS(ST_TRANSFORM(spf.geom,3035), ST_CENTROID(lc.geom));

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	calc_ego_loads.ego_deu_loads_melted_spf
	ADD PRIMARY KEY (id);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_loads_melted_spf_geom_idx
	ON	calc_ego_loads.ego_deu_loads_melted_spf
	USING	GIST (geom);

-- "Create Index GIST (geom_centre)"   (OK!) -> 150ms =0
CREATE INDEX  	ego_deu_loads_melted_spf_geom_centre_idx
    ON    	calc_ego_loads.ego_deu_loads_melted_spf
    USING     	GIST (geom_centre);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_loads.ego_deu_loads_melted_spf TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_loads.ego_deu_loads_melted_spf OWNER TO oeuser;

---------- ---------- ----------
---------- ---------- ----------
-- Cutting Loads with Grid Districts
---------- ---------- ----------

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	calc_ego_loads.ego_deu_loads_spf CASCADE;
CREATE TABLE         	calc_ego_loads.ego_deu_loads_spf (
		id SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	ego_deu_loads_spf_pkey PRIMARY KEY (id));

-- "Insert Loads"   (ERROR!) 10.000ms =967
INSERT INTO     calc_ego_loads.ego_deu_loads_spf (geom)
	SELECT	(ST_DUMP(ST_INTERSECTION(loads.geom,dis.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	calc_ego_loads.ego_deu_loads_melted_spf AS loads,
		calc_ego_loads.ego_grid_districts AS dis
	WHERE	loads.geom && dis.geom;
	--	AND dis.subst_id = 2155;

-- "Extend Table"   (OK!) 100ms =0
ALTER TABLE	calc_ego_loads.ego_deu_loads_spf
	ADD COLUMN zensus_sum integer,
	ADD COLUMN zensus_count integer,
	ADD COLUMN zensus_density numeric,
	ADD COLUMN ioer_sum numeric,
	ADD COLUMN ioer_count integer,
	ADD COLUMN ioer_density numeric,
	ADD COLUMN area_ha numeric,
	ADD COLUMN sector_area_residential numeric,
	ADD COLUMN sector_area_retail numeric,
	ADD COLUMN sector_area_industrial numeric,
	ADD COLUMN sector_area_agricultural numeric,
	ADD COLUMN sector_share_residential numeric,
	ADD COLUMN sector_share_retail numeric,
	ADD COLUMN sector_share_industrial numeric,
	ADD COLUMN sector_share_agricultural numeric,
	ADD COLUMN sector_count_residential integer,
	ADD COLUMN sector_count_retail integer,
	ADD COLUMN sector_count_industrial integer,
	ADD COLUMN sector_count_agricultural integer,
	ADD COLUMN subst_id integer,
	ADD COLUMN nuts varchar(5),
	ADD COLUMN rs varchar(12),
	ADD COLUMN ags_0 varchar(8),	
	ADD COLUMN geom_centroid geometry(POINT,3035),
	ADD COLUMN geom_surfacepoint geometry(POINT,3035),
	ADD COLUMN geom_centre geometry(POINT,3035);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	ego_deu_loads_spf_geom_idx
    ON    	calc_ego_loads.ego_deu_loads_spf
    USING     	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_loads.ego_deu_loads_spf TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_loads.ego_deu_loads_spf OWNER TO oeuser;

---------- ---------- ----------

-- "Update Area (area_ha)"   (OK!) -> 14.000ms =182.430
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	area_ha = t2.area
FROM    (
	SELECT	loads.id,
		ST_AREA(ST_TRANSFORM(loads.geom,3035))/10000 AS area
	FROM	calc_ego_loads.ego_deu_loads_spf AS loads
	) AS t2
WHERE  	t1.id = t2.id;

-- "Validate Area (area_ha) kleiner 100m²"   (OK!) 500ms =1.257
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_loads.ego_deu_loads_spf_error_area_ha_mview CASCADE;
CREATE MATERIALIZED VIEW 		calc_ego_loads.ego_deu_loads_spf_error_area_ha_mview AS 
	SELECT 	loads.id AS id,
		loads.area_ha AS area_ha,
		loads.geom AS geom
	FROM 	calc_ego_loads.ego_deu_loads_spf AS loads
	WHERE	loads.area_ha < 0.001;
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_loads.ego_deu_loads_spf_error_area_ha_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_loads.ego_deu_loads_spf_error_area_ha_mview OWNER TO oeuser;


-- "Remove Errors (area_ha)"   (OK!) 700ms =310
DELETE FROM	calc_ego_loads.ego_deu_loads_spf AS loads
	WHERE	loads.area_ha < 1;

-- -- "Validate Area (area_ha) Check"   (OK!) 84.000ms =81.161
-- SELECT 	loads.id AS id,
-- 	loads.area_ha AS area_ha,
-- 	loads.geom AS geom
-- FROM 	calc_ego_loads.ego_deu_loads_spf AS loads
-- WHERE	loads.area_ha < 1;



---------- ---------- ---------- ---------- ---------- ----------
-- "Calculate"
---------- ---------- ---------- ---------- ---------- ----------

---------- ---------- ----------
-- "Geometries"
---------- ---------- ----------

-- "Update Centroid"   (OK!) -> 28.000ms =181.173
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	geom_centroid = t2.geom_centroid
FROM    (
	SELECT	loads.id AS id,
		ST_Centroid(loads.geom) AS geom_centroid
	FROM	calc_ego_loads.ego_deu_loads_spf AS loads
	) AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_centroid)"   (OK!) -> 4.000ms =0
CREATE INDEX  	ego_deu_loads_spf_geom_centroid_idx
    ON    	calc_ego_loads.ego_deu_loads_spf
    USING     	GIST (geom_centroid);
    
---------- ---------- ----------

-- "Update PointOnSurface"   (OK!) -> 50.000ms =181.173
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	geom_surfacepoint = t2.geom_surfacepoint
FROM    (
	SELECT	loads.id AS id,
		ST_PointOnSurface(loads.geom) AS geom_surfacepoint
	FROM	calc_ego_loads.ego_deu_loads_spf AS loads
	) AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_surfacepoint)"   (OK!) ->  3.000ms =0
CREATE INDEX  	ego_deu_loads_spf_geom_surfacepoint_idx
    ON    	calc_ego_loads.ego_deu_loads_spf
    USING     	GIST (geom_surfacepoint);


---------- ---------- ----------
-- "Update Centre"
---------- ---------- ----------

-- "Update Centre with centroid if inside area"   (OK!) -> 19.000ms =174.097
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	geom_centre = t2.geom_centre
FROM	(
	SELECT	loads.id AS id,
		loads.geom_centroid AS geom_centre
	FROM	calc_ego_loads.ego_deu_loads_spf AS loads
	WHERE  	loads.geom && loads.geom_centroid AND
		ST_CONTAINS(loads.geom,loads.geom_centroid)
	)AS t2
WHERE  	t1.id = t2.id;

-- "Update Centre with surfacepoint if outside area"   (OK!) -> 2.000ms =7.076
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	geom_centre = t2.geom_centre
FROM	(
	SELECT	loads.id AS id,
		loads.geom_surfacepoint AS geom_centre
	FROM	calc_ego_loads.ego_deu_loads_spf AS loads
	WHERE  	loads.geom_centre IS NULL
	)AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_centre)"   (OK!) -> 2.000ms =0
CREATE INDEX  	ego_deu_loads_spf_geom_centre_idx
    ON    	calc_ego_loads.ego_deu_loads_spf
    USING     	GIST (geom_centre);

-- -- "Validate Centre"   (OK!) -> 1.000ms =0
-- 	SELECT	loads.id AS id
-- 	FROM	calc_ego_loads.ego_deu_loads_spf AS loads
-- 	WHERE  	NOT ST_CONTAINS(loads.geom,loads.geom_centre);

---------- ---------- ----------

-- "Surfacepoint outside area"   (OK!) 2.000ms =7.076
DROP MATERIALIZED VIEW IF EXISTS	calc_ego_loads.ego_deu_loads_spf_centre_mview CASCADE;
CREATE MATERIALIZED VIEW 		calc_ego_loads.ego_deu_loads_spf_centre_mview AS 
	SELECT	loads.id AS id,
		ST_Centroid(loads.geom) ::geometry(POINT,3035) AS geom_centroid
	FROM	calc_ego_loads.ego_deu_loads_spf AS loads
	WHERE  	NOT ST_CONTAINS(loads.geom,loads.geom_centroid);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_loads.ego_deu_loads_spf_centre_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_loads.ego_deu_loads_spf_centre_mview OWNER TO oeuser;

---------- ---------- ----------
-- "Calculate Zensus2011 Population"
---------- ---------- ----------

-- "Zensus2011 Population"   (OK!) -> 411.000ms =163.465
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	zensus_sum = t2.zensus_sum,
	zensus_count = t2.zensus_count,
	zensus_density = t2.zensus_density
FROM    (SELECT	loads.id AS id,
		SUM(pts.population)::integer AS zensus_sum,
		COUNT(pts.geom)::integer AS zensus_count,
		(SUM(pts.population)/COUNT(pts.geom))::numeric AS zensus_density
	FROM	calc_ego_loads.ego_deu_loads_spf AS loads,
		orig_destatis.zensus_population_per_ha_mview AS pts
	WHERE  	loads.geom && pts.geom AND
		ST_CONTAINS(loads.geom,pts.geom)
	GROUP BY loads.id
	)AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------
-- "Calculate IÖR Industry Share"
---------- ---------- ----------

-- "IÖR Industry Share"   (OK!) -> 167.000ms =42.120
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	ioer_sum = t2.ioer_sum,
	ioer_count = t2.ioer_count,
	ioer_density = t2.ioer_density
FROM    (SELECT	loads.id AS id,
		SUM(pts.ioer_share)/100::numeric AS ioer_sum,
		COUNT(pts.geom)::integer AS ioer_count,
		(SUM(pts.ioer_share)/COUNT(pts.geom))::numeric AS ioer_density
	FROM	calc_ego_loads.ego_deu_loads_spf AS loads,
		orig_ioer.ioer_urban_share_industrial_centroid AS pts
	WHERE  	loads.geom && pts.geom AND
		ST_CONTAINS(loads.geom,pts.geom)
	GROUP BY loads.id
	)AS t2
WHERE  	t1.id = t2.id;


---------- ---------- ----------
-- "Calculate Sectors"
---------- ---------- ----------

-- "Calculate Sector Residential"   (OK!) -> 64.000ms =11.873
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	sector_area_residential = t2.sector_area,
	sector_count_residential = t2.sector_count,
	sector_share_residential = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	orig_osm.osm_deu_polygon_urban_sector_1_residential_mview AS sector,
		calc_ego_loads.ego_deu_loads_spf AS loads	
	WHERE  	loads.geom && sector.geom AND  
		ST_CONTAINS(loads.geom,sector.geom)
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Sector Retail"   (OK!) -> 800.000ms =2.997
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	sector_area_retail = t2.sector_area,
	sector_count_retail = t2.sector_count,
	sector_share_retail = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	orig_osm.osm_deu_polygon_urban_sector_2_retail_mview AS sector,
		calc_ego_loads.ego_deu_loads_spf AS loads	
	WHERE  	loads.geom && sector.geom AND  
		ST_CONTAINS(loads.geom,sector.geom)
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Sector Industrial"   (OK!) -> 1.320.000ms =4.118
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	sector_area_industrial = t2.sector_area,
	sector_count_industrial = t2.sector_count,
	sector_share_industrial = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	orig_osm.osm_deu_polygon_urban_sector_3_industrial_mview AS sector,
		calc_ego_loads.ego_deu_loads_spf AS loads	
	WHERE  	loads.geom && sector.geom AND  
		ST_CONTAINS(loads.geom,sector.geom)
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Sector Agricultural"   (OK!) -> 1.856.000ms =5.270
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	sector_area_agricultural = t2.sector_area,
	sector_count_agricultural = t2.sector_count,
	sector_share_agricultural = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	orig_osm.osm_deu_polygon_urban_sector_4_agricultural_mview AS sector,
		calc_ego_loads.ego_deu_loads_spf AS loads	
	WHERE  	loads.geom && sector.geom AND  
		ST_CONTAINS(loads.geom,sector.geom)
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;


---------- ---------- ----------
-- "Calculate Codes"   2016-04-06 18:01
---------- ---------- ----------

-- "Calculate NUTS"   (OK!) -> 42.000ms =181.157
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	nuts = t2.nuts
FROM    (
	SELECT	loads.id AS id,
		vg.nuts AS nuts
	FROM	calc_ego_loads.ego_deu_loads_spf AS loads,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && loads.geom_centre AND
		ST_CONTAINS(vg.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Regionalschlüssel"   (OK!) -> 47.000ms =181.157
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	rs = t2.rs
FROM    (
	SELECT	loads.id AS id,
		vg.rs AS rs
	FROM	calc_ego_loads.ego_deu_loads_spf AS loads,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && loads.geom_centre AND
		ST_CONTAINS(vg.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Gemeindeschlüssel"   (OK!) -> 50.000ms =181.157
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	ags_0 = t2.ags_0
FROM    (
	SELECT	loads.id AS id,
		vg.ags_0 AS ags_0
	FROM	calc_ego_loads.ego_deu_loads_spf AS loads,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && loads.geom_centre AND
		ST_CONTAINS(vg.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

-- -- "Loads without AGS"   (OK!) 500ms =16
-- DROP MATERIALIZED VIEW IF EXISTS	calc_ego_loads.ego_deu_loads_spf_error_noags_mview CASCADE;
-- CREATE MATERIALIZED VIEW 		calc_ego_loads.ego_deu_loads_spf_error_noags_mview AS 
-- 	SELECT	loads.id,
-- 		loads.geom
-- 	FROM	calc_ego_loads.ego_deu_loads_spf AS loads
-- 	WHERE  	loads.ags_0 IS NULL;

---------- ---------- ----------

-- "Calculate Substation ID"   (OK!) -> 55.000ms =181.068
UPDATE 	calc_ego_loads.ego_deu_loads_spf AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	loads.id AS id,
		dis.subst_id AS subst_id
	FROM	calc_ego_loads.ego_deu_loads_spf AS loads,
		calc_ego_loads.ego_grid_districts AS dis
	WHERE  	dis.geom && loads.geom_centre AND
		ST_CONTAINS(dis.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;



-- 
-- ---------- ---------- ----------
-- -- "Create SPF"   2016-04-07 11:34   3s
-- ---------- ---------- ----------
-- 
-- -- "Create Table SPF"   (OK!) 3.000ms =884
-- DROP TABLE IF EXISTS  	calc_ego_loads.ego_deu_loads_spf;
-- CREATE TABLE         	calc_ego_loads.ego_deu_loads_spf AS
-- 	SELECT	loads.*
-- 	FROM	calc_ego_loads.ego_deu_loads_spf AS loads,
-- 		orig_geo_vg250.vg250_4_krs_spf_mview AS spf
-- 	WHERE	ST_TRANSFORM(spf.geom,3035) && loads.geom  AND  
-- 		ST_CONTAINS(ST_TRANSFORM(spf.geom,3035), loads.geom_centre)
-- 	ORDER BY loads.id;
-- 
-- -- "Ad PK"   (OK!) 150ms =0
-- ALTER TABLE	calc_ego_loads.ego_deu_loads_spf
-- 	ADD PRIMARY KEY (id);
-- 
-- -- "Create Index GIST (geom)"   (OK!) -> 100ms =0
-- CREATE INDEX  	ego_deu_loads_spf_geom_idx
-- 	ON	calc_ego_loads.ego_deu_loads_spf
-- 	USING	GIST (geom);
-- 
-- -- "Create Index GIST (geom_centre)"   (OK!) -> 150ms =0
-- CREATE INDEX  	ego_deu_loads_spf_geom_centre_idx
--     ON    	calc_ego_loads.ego_deu_loads_spf
--     USING     	GIST (geom_centre);
-- 
-- -- "Grant oeuser"   (OK!) -> 100ms =0
-- GRANT ALL ON TABLE 	calc_ego_loads.ego_deu_loads_spf TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		calc_ego_loads.ego_deu_loads_spf OWNER TO oeuser;