
---------- ---------- ---------- ---------- ---------- ----------
-- "LOADS"   2016-04-06 15:17   12s
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	orig_ego.ego_deu_loads CASCADE;
CREATE TABLE         	orig_ego.ego_deu_loads (
		id SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	ego_deu_loads_pkey PRIMARY KEY (id));

-- "Insert Loads"   (OK!) 10.000ms =182.430
INSERT INTO     orig_ego.ego_deu_loads (geom)
	SELECT	loads.geom AS geom
	FROM	orig_ego.ego_deu_loads_collect_buffer100_unbuffer AS loads;

-- "Extend Table"   (OK!) 100ms =0
ALTER TABLE	orig_ego.ego_deu_loads
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
	ADD COLUMN mv_poly_id integer,
	ADD COLUMN nuts varchar(5),
	ADD COLUMN rs varchar(12),
	ADD COLUMN ags_0 varchar(8),	
	ADD COLUMN geom_centroid geometry(POINT,3035),
	ADD COLUMN geom_surfacepoint geometry(POINT,3035)
	ADD COLUMN geom_centre geometry(POINT,3035);

-- "Create Index GIST (geom)"   (OK!) 2.000ms =0
CREATE INDEX  	ego_deu_loads_geom_idx
    ON    	orig_ego.ego_deu_loads
    USING     	GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_loads TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads OWNER TO oeuser;

---------- ---------- ----------

-- "Update Area (area_ha)"   (OK!) -> 14.000ms =182.430
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	area_ha = t2.area
FROM    (
	SELECT	loads.id,
		ST_AREA(ST_TRANSFORM(loads.geom,3035))/10000 AS area
	FROM	orig_ego.ego_deu_loads AS loads
	) AS t2
WHERE  	t1.id = t2.id;

-- "Validate Area (area_ha) kleiner 100m²"   (OK!) 500ms =1.257
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_loads_error_area_ha_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_loads_error_area_ha_mview AS 
	SELECT 	loads.id AS id,
		loads.area_ha AS area_ha,
		loads.geom AS geom
	FROM 	orig_ego.ego_deu_loads AS loads
	WHERE	loads.area_ha < 0.001;
	
-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_loads_error_area_ha_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_error_area_ha_mview OWNER TO oeuser;


-- "Remove Errors (area_ha)"   (OK!) 700ms =1.257
DELETE FROM	orig_ego.ego_deu_loads AS loads
	WHERE	loads.area_ha < 0.001;

-- "Validate Area (area_ha) Check"   (OK!) 84.000ms =81.161
SELECT 	loads.id AS id,
	loads.area_ha AS area_ha,
	loads.geom AS geom
FROM 	orig_ego.ego_deu_loads AS loads
WHERE	loads.area_ha <= 2;



---------- ---------- ---------- ---------- ---------- ----------
-- "Calculate"
---------- ---------- ---------- ---------- ---------- ----------

---------- ---------- ----------
-- "Geometries"
---------- ---------- ----------

-- "Update Centroid"   (OK!) -> 28.000ms =181.173
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	geom_centroid = t2.geom_centroid
FROM    (
	SELECT	loads.id AS id,
		ST_Centroid(loads.geom) AS geom_centroid
	FROM	orig_ego.ego_deu_loads AS loads
	) AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_centroid)"   (OK!) -> 4.000ms =0
CREATE INDEX  	ego_deu_loads_geom_centroid_idx
    ON    	orig_ego.ego_deu_loads
    USING     	GIST (geom_centroid);
    
---------- ---------- ----------

-- "Update PointOnSurface"   (OK!) -> 50.000ms =181.173
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	geom_surfacepoint = t2.geom_surfacepoint
FROM    (
	SELECT	loads.id AS id,
		ST_PointOnSurface(loads.geom) AS geom_surfacepoint
	FROM	orig_ego.ego_deu_loads AS loads
	) AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_surfacepoint)"   (OK!) ->  3.000ms =0
CREATE INDEX  	ego_deu_loads_geom_surfacepoint_idx
    ON    	orig_ego.ego_deu_loads
    USING     	GIST (geom_surfacepoint);


---------- ---------- ----------
-- "Update Centre"
---------- ---------- ----------

-- "Update Centre with centroid if inside area"   (OK!) -> 19.000ms =174.097
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	geom_centre = t2.geom_centre
FROM	(
	SELECT	loads.id AS id,
		loads.geom_centroid AS geom_centre
	FROM	orig_ego.ego_deu_loads AS loads
	WHERE  	loads.geom && loads.geom_centroid AND
		ST_CONTAINS(loads.geom,loads.geom_centroid)
	)AS t2
WHERE  	t1.id = t2.id;

-- "Update Centre with surfacepoint if outside area"   (OK!) -> 2.000ms =7.076
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	geom_centre = t2.geom_centre
FROM	(
	SELECT	loads.id AS id,
		loads.geom_surfacepoint AS geom_centre
	FROM	orig_ego.ego_deu_loads AS loads
	WHERE  	loads.geom_centre IS NULL
	)AS t2
WHERE  	t1.id = t2.id;

-- "Create Index GIST (geom_centre)"   (OK!) -> 2.000ms =0
CREATE INDEX  	ego_deu_loads_geom_centre_idx
    ON    	orig_ego.ego_deu_loads
    USING     	GIST (geom_centre);

-- "Validate Centre"   (OK!) -> 1.000ms =0
	SELECT	loads.id AS id
	FROM	orig_ego.ego_deu_loads AS loads
	WHERE  	NOT ST_CONTAINS(loads.geom,loads.geom_centre);

---------- ---------- ----------

-- "Surfacepoint outside area"   (OK!) 2.000ms =7.076
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_loads_centre_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_loads_centre_mview AS 
	SELECT	loads.id AS id,
		ST_Centroid(loads.geom) ::geometry(POINT,3035) AS geom_centroid
	FROM	orig_ego.ego_deu_loads AS loads
	WHERE  	NOT ST_CONTAINS(loads.geom,loads.geom_centroid);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_loads_centre_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_centre_mview OWNER TO oeuser;

---------- ---------- ----------
-- "Calculate Zensus2011 Population"
---------- ---------- ----------

-- "Zensus2011 Population"   (OK!) -> 411.000ms =163.465
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	zensus_sum = t2.zensus_sum,
	zensus_count = t2.zensus_count,
	zensus_density = t2.zensus_density
FROM    (SELECT	loads.id AS id,
		SUM(pts.population)::integer AS zensus_sum,
		COUNT(pts.geom)::integer AS zensus_count,
		(SUM(pts.population)/COUNT(pts.geom))::numeric AS zensus_density
	FROM	orig_ego.ego_deu_loads AS loads,
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
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	ioer_sum = t2.ioer_sum,
	ioer_count = t2.ioer_count,
	ioer_density = t2.ioer_density
FROM    (SELECT	loads.id AS id,
		SUM(pts.ioer_share)/100::numeric AS ioer_sum,
		COUNT(pts.geom)::integer AS ioer_count,
		(SUM(pts.ioer_share)/COUNT(pts.geom))::numeric AS ioer_density
	FROM	orig_ego.ego_deu_loads AS loads,
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
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	sector_area_residential = t2.sector_area,
	sector_count_residential = t2.sector_count,
	sector_share_residential = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	orig_ego.osm_deu_polygon_urban_sector_1_residential_mview AS sector,
		orig_ego.ego_deu_loads AS loads	
	WHERE  	loads.geom && sector.geom AND  
		ST_CONTAINS(loads.geom,sector.geom)
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Sector Retail"   (OK!) -> 800.000ms =2.997
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	sector_area_retail = t2.sector_area,
	sector_count_retail = t2.sector_count,
	sector_share_retail = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	orig_ego.osm_deu_polygon_urban_sector_2_retail_mview AS sector,
		orig_ego.ego_deu_loads AS loads	
	WHERE  	loads.geom && sector.geom AND  
		ST_CONTAINS(loads.geom,sector.geom)
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Sector Industrial"   (OK!) -> 1.320.000ms =4.118
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	sector_area_industrial = t2.sector_area,
	sector_count_industrial = t2.sector_count,
	sector_share_industrial = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	orig_ego.osm_deu_polygon_urban_sector_3_industrial_mview AS sector,
		orig_ego.ego_deu_loads AS loads	
	WHERE  	loads.geom && sector.geom AND  
		ST_CONTAINS(loads.geom,sector.geom)
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Sector Agricultural"   (OK!) -> 1.856.000ms =5.270
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	sector_area_agricultural = t2.sector_area,
	sector_count_agricultural = t2.sector_count,
	sector_share_agricultural = t2.sector_area / t2.area_ha
FROM    (
	SELECT	loads.id AS id,
		SUM(ST_AREA(sector.geom)/10000) AS sector_area,
		COUNT(sector.geom) AS sector_count,
		loads.area_ha AS area_ha
	FROM	orig_ego.osm_deu_polygon_urban_sector_4_agricultural_mview AS sector,
		orig_ego.ego_deu_loads AS loads	
	WHERE  	loads.geom && sector.geom AND  
		ST_CONTAINS(loads.geom,sector.geom)
	GROUP BY loads.id
	) AS t2
WHERE  	t1.id = t2.id;


---------- ---------- ----------
-- "Calculate Codes"   2016-04-06 18:01
---------- ---------- ----------

-- "Transform VG250"   (OK!) -> 2.000ms =11.438
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_vg250.vg250_6_gem_mview CASCADE;
CREATE MATERIALIZED VIEW		orig_geo_vg250.vg250_6_gem_mview AS
	SELECT	vg.gid,
		vg.gen,
		vg.nuts,
		vg.rs,
		ags_0,
		ST_TRANSFORM(vg.geom,3035) AS geom
	FROM	orig_geo_vg250.vg250_6_gem AS vg
	ORDER BY vg.gid;

-- "Create Index GIST (geom)"   (OK!) -> 150ms =0
CREATE INDEX  	vg250_6_gem_mview_geom_idx
	ON	orig_geo_vg250.vg250_6_gem_mview
	USING	GIST (geom);

---------- ---------- ----------

-- "Calculate NUTS"   (OK!) -> 42.000ms =181.157
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	nuts = t2.nuts
FROM    (
	SELECT	loads.id AS id,
		vg.nuts AS nuts
	FROM	orig_ego.ego_deu_loads AS loads,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && loads.geom_centre AND
		ST_CONTAINS(vg.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Regionalschlüssel"   (OK!) -> 47.000ms =181.157
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	rs = t2.rs
FROM    (
	SELECT	loads.id AS id,
		vg.rs AS rs
	FROM	orig_ego.ego_deu_loads AS loads,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && loads.geom_centre AND
		ST_CONTAINS(vg.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ----------

-- "Calculate Gemeindeschlüssel"   (OK!) -> 50.000ms =181.157
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	ags_0 = t2.ags_0
FROM    (
	SELECT	loads.id AS id,
		vg.ags_0 AS ags_0
	FROM	orig_ego.ego_deu_loads AS loads,
		orig_geo_vg250.vg250_6_gem_mview AS vg
	WHERE  	vg.geom && loads.geom_centre AND
		ST_CONTAINS(vg.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

-- "Loads without AGS"   (OK!) 500ms =16
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_loads_error_noags_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_loads_error_noags_mview AS 
	SELECT	loads.id,
		loads.geom
	FROM	orig_ego.ego_deu_loads AS loads
	WHERE  	loads.ags_0 IS NULL;

---------- ---------- ----------

-- "Calculate MV-Key"   (OK!) -> 55.000ms =181.068
UPDATE 	orig_ego.ego_deu_loads AS t1
SET  	mv_poly_id = t2.mv_poly_id
FROM    (
	SELECT	loads.id AS id,
		mv.id AS mv_poly_id
	FROM	orig_ego.ego_deu_loads AS loads,
		orig_ego.ego_deu_mv_gridcell_full_mview AS mv
	WHERE  	mv.geom && loads.geom_centre AND
		ST_CONTAINS(mv.geom,loads.geom_centre)
	) AS t2
WHERE  	t1.id = t2.id;

-- "Loads without MV"   (OK!) 500ms =105
DROP MATERIALIZED VIEW IF EXISTS	orig_ego.ego_deu_loads_error_nomv_mview CASCADE;
CREATE MATERIALIZED VIEW 		orig_ego.ego_deu_loads_error_nomv_mview AS 
	SELECT	loads.id,
		loads.geom
	FROM	orig_ego.ego_deu_loads AS loads
	WHERE  	loads.mv_poly_id IS NULL;



---------- ---------- ----------
-- "Create SPF"   2016-04-07 11:34   3s
---------- ---------- ----------

-- "Create Table SPF"   (OK!) 3.000ms =884
DROP TABLE IF EXISTS  	orig_ego.ego_deu_loads_spf;
CREATE TABLE         	orig_ego.ego_deu_loads_spf AS
	SELECT	loads.*
	FROM	orig_ego.ego_deu_loads AS loads,
		orig_geo_vg250.vg250_4_krs_spf_mview AS spf
	WHERE	ST_TRANSFORM(spf.geom,3035) && loads.geom  AND  
		ST_CONTAINS(ST_TRANSFORM(spf.geom,3035), loads.geom_centre)
	ORDER BY loads.id;

-- "Ad PK"   (OK!) 150ms =0
ALTER TABLE	orig_ego.ego_deu_loads_spf
	ADD PRIMARY KEY (id);

-- "Create Index GIST (geom)"   (OK!) -> 100ms =0
CREATE INDEX  	ego_deu_loads_spf_geom_idx
	ON	orig_ego.ego_deu_loads_spf
	USING	GIST (geom);

-- "Create Index GIST (geom_centre)"   (OK!) -> 150ms =0
CREATE INDEX  	ego_deu_loads_spf_geom_centre_idx
    ON    	orig_ego.ego_deu_loads_spf
    USING     	GIST (geom_centre);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	orig_ego.ego_deu_loads_spf TO oeuser WITH GRANT OPTION;
ALTER TABLE		orig_ego.ego_deu_loads_spf OWNER TO oeuser;