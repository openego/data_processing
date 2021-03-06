/*
Cut Loadarea with MV Voronoi cells
Identify and exclude Loadarea smaller than 100m².
Generate Centre of Loadareas with Centroid and PointOnSurface.
Calculate population from Census 2011.
Cut all 4 OSM sectors with MV Griddistricts.
Calculate statistics like NUTS and AGS code.
Check for Loadareas without AGS code.


__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/


-- loadareas per mv-griddistrict
DROP TABLE IF EXISTS    model_draft.ego_demand_loadarea_voi CASCADE;
CREATE TABLE            model_draft.ego_demand_loadarea_voi (
    id SERIAL NOT NULL,
    subst_id integer,
    area_ha numeric,
    nuts varchar(5),
    rs_0 varchar(12),
    ags_0 varchar(12),
    otg_id integer,
    un_id integer,
    zensus_sum integer,
    zensus_count integer,
    zensus_density numeric,
    ioer_sum numeric,
    ioer_count integer,
    ioer_density numeric,
    sector_area_residential numeric,
    sector_area_retail numeric,
    sector_area_industrial numeric,
    sector_area_agricultural numeric,
    sector_area_sum numeric,	
    sector_share_residential numeric,
    sector_share_retail numeric,
    sector_share_industrial numeric,
    sector_share_agricultural numeric,
    sector_share_sum numeric,
    sector_count_residential integer,
    sector_count_retail integer,
    sector_count_industrial integer,
    sector_count_agricultural integer,
    sector_count_sum integer,
    sector_consumption_residential numeric,
    sector_consumption_retail numeric,
    sector_consumption_industrial numeric,
    sector_consumption_agricultural numeric,
    sector_consumption_sum numeric,
    geom_centroid geometry(POINT,3035),
    geom_surfacepoint geometry(POINT,3035),
    geom_centre geometry(POINT,3035),
    geom geometry(Polygon,3035),
    CONSTRAINT ego_demand_loadarea_voi_pkey PRIMARY KEY (id));

-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_loadarea_voi OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_demand_loadarea_voi IS '{ 
    "comment": "eGoDP - Temporary table", 
    "version": "v0.4.5" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_demand_load_melt','ego_dp_loadarea_loadcut_voronoi.sql',' ');

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_grid_hvmv_substation_voronoi','ego_dp_loadarea_loadcut_voronoi.sql',' ');

-- insert cutted load melt
INSERT INTO     model_draft.ego_demand_loadarea_voi (geom)
    SELECT  loads.geom ::geometry(Polygon,3035)
    FROM (
        SELECT (ST_DUMP(ST_SAFE_INTERSECTION(load.geom,dis.geom))).geom AS geom
        FROM    model_draft.ego_demand_load_melt AS load,
                model_draft.ego_grid_hvmv_substation_voronoi AS dis
        WHERE   load.geom && dis.geom
        ) AS loads
    WHERE   ST_GeometryType(loads.geom) = 'ST_Polygon';

-- index GIST (geom)
CREATE INDEX ego_demand_loadarea_voi_geom_idx
    ON model_draft.ego_demand_loadarea_voi USING gist (geom);

-- update area (area_ha)
UPDATE model_draft.ego_demand_loadarea_voi AS t1
    SET area_ha = t2.area
    FROM (
        SELECT  loads.id,
                ST_AREA(ST_TRANSFORM(loads.geom,3035))/10000 AS area
        FROM    model_draft.ego_demand_loadarea_voi AS loads
        ) AS t2
    WHERE   t1.id = t2.id;


-- Identify and exclude Loadarea smaller than 100m²
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_demand_loadarea_voi_smaller100m2_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.ego_demand_loadarea_voi_smaller100m2_mview AS
    SELECT  loads.id AS id,
            loads.area_ha AS area_ha,
            loads.geom AS geom
    FROM    model_draft.ego_demand_loadarea_voi AS loads
    WHERE   loads.area_ha < 0.001;

-- index (id)
CREATE UNIQUE INDEX ego_demand_loadarea_voi_smaller100m2_mview_id_idx
    ON model_draft.ego_demand_loadarea_voi_smaller100m2_mview (id);

-- index GIST (geom)
CREATE INDEX ego_demand_loadarea_voi_smaller100m2_mview_geom_idx
    ON model_draft.ego_demand_loadarea_voi_smaller100m2_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_loadarea_voi_smaller100m2_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_demand_loadarea_voi_smaller100m2_mview IS '{ 
    "comment": "eGoDP - Temporary table", 
    "version": "v0.4.5" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','temp','model_draft','ego_demand_loadarea_voi_smaller100m2_mview','ego_dp_loadarea_loadcut_voronoi.sql',' ');

-- Exclude Loadarea smaller than 100m²
DELETE FROM model_draft.ego_demand_loadarea_voi AS loads
    WHERE   loads.area_ha < 0.001;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_demand_loadarea_voi','ego_dp_loadarea_loadcut_voronoi.sql',' ');


-- Generate Centre of Loadareas with Centroid and PointOnSurface
-- centroid
UPDATE  model_draft.ego_demand_loadarea_voi AS t1
    SET geom_centroid = t2.geom_centroid
    FROM (
        SELECT  loads.id AS id,
                ST_Centroid(loads.geom) AS geom_centroid
        FROM    model_draft.ego_demand_loadarea_voi AS loads
        ) AS t2
    WHERE   t1.id = t2.id;

-- index GIST (geom_centroid)
CREATE INDEX ego_demand_loadarea_voi_geom_centroid_idx
    ON model_draft.ego_demand_loadarea_voi USING GIST (geom_centroid);


-- surfacepoint
UPDATE model_draft.ego_demand_loadarea_voi AS t1
    SET geom_surfacepoint = t2.geom_surfacepoint
    FROM (
        SELECT  loads.id AS id,
                ST_PointOnSurface(loads.geom) AS geom_surfacepoint
        FROM    model_draft.ego_demand_loadarea_voi AS loads
        ) AS t2
    WHERE   t1.id = t2.id;

-- index GIST (geom_surfacepoint)
CREATE INDEX ego_demand_loadarea_voi_geom_surfacepoint_idx
    ON model_draft.ego_demand_loadarea_voi USING GIST (geom_surfacepoint);


-- centre with centroid if inside loadarea
UPDATE model_draft.ego_demand_loadarea_voi AS t1
    SET geom_centre = t2.geom_centre
    FROM (
        SELECT  loads.id AS id,
                loads.geom_centroid AS geom_centre
        FROM    model_draft.ego_demand_loadarea_voi AS loads
        WHERE   loads.geom && loads.geom_centroid AND
                ST_CONTAINS(loads.geom,loads.geom_centroid)
        )AS t2
    WHERE   t1.id = t2.id;

-- centre with surfacepoint if outside area
UPDATE model_draft.ego_demand_loadarea_voi AS t1
    SET geom_centre = t2.geom_centre
    FROM (
        SELECT  loads.id AS id,
                loads.geom_surfacepoint AS geom_centre
        FROM    model_draft.ego_demand_loadarea_voi AS loads
        WHERE   loads.geom_centre IS NULL
        )AS t2
    WHERE   t1.id = t2.id;

-- create index GIST (geom_centre)
CREATE INDEX ego_demand_loadarea_voi_geom_centre_idx
    ON model_draft.ego_demand_loadarea_voi USING GIST (geom_centre);

/* -- validate geom_centre
SELECT  loads.id AS id
FROM    model_draft.ego_demand_loadarea_voi AS loads
WHERE   NOT ST_CONTAINS(loads.geom,loads.geom_centre);
*/
/*
-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','society','destatis_zensus_population_per_ha_mview','ego_dp_loadarea_loadcut_voronoi.sql',' ');

-- zensus 2011 population
UPDATE 	model_draft.ego_demand_loadarea_voi AS t1
	SET  	zensus_sum = t2.zensus_sum,
		zensus_count = t2.zensus_count,
		zensus_density = t2.zensus_density
	FROM    (SELECT	loads.id AS id,
			SUM(pts.population)::integer AS zensus_sum,
			COUNT(pts.geom)::integer AS zensus_count,
			(SUM(pts.population)/COUNT(pts.geom))::numeric AS zensus_density
		FROM	model_draft.ego_demand_loadarea_voi AS loads,
			society.destatis_zensus_population_per_ha_mview AS pts
		WHERE  	loads.geom && pts.geom AND
			ST_CONTAINS(loads.geom,pts.geom)
		GROUP BY loads.id
		)AS t2
	WHERE  	t1.id = t2.id;


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','economy','ioer_urban_share_industrial_centroid','ego_dp_loadarea_loadcut_voronoi.sql',' ');

-- ioer industry share
UPDATE 	model_draft.ego_demand_loadarea_voi AS t1
	SET  	ioer_sum = t2.ioer_sum,
		ioer_count = t2.ioer_count,
		ioer_density = t2.ioer_density
	FROM    (SELECT	loads.id AS id,
			SUM(pts.ioer_share)/100::numeric AS ioer_sum,
			COUNT(pts.geom)::integer AS ioer_count,
			(SUM(pts.ioer_share)/COUNT(pts.geom))::numeric AS ioer_density
		FROM	model_draft.ego_demand_loadarea_voi AS loads,
			economy.ioer_urban_share_industrial_centroid AS pts
		WHERE  	loads.geom && pts.geom AND
			ST_CONTAINS(loads.geom,pts.geom)
		GROUP BY loads.id
		)AS t2
	WHERE  	t1.id = t2.id;


-- 1. residential sector
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_griddistrict_1_residential CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_griddistrict_1_residential	 (
	id SERIAL NOT NULL,
	geom geometry(Polygon,3035),
	CONSTRAINT urban_sector_per_grid_district_1_residential_pkey PRIMARY KEY (id));

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','openstreetmap','osm_deu_polygon_urban_sector_1_residential_mview','ego_dp_loadarea_loadcut_voronoi.sql',' ');

-- intersect sector with mv-griddistrict
INSERT INTO     model_draft.ego_osm_sector_per_griddistrict_1_residential (geom)
	SELECT	loads.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(loads.geom,dis.geom))).geom AS geom
		FROM	openstreetmap.osm_deu_polygon_urban_sector_1_residential_mview AS loads,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE	loads.geom && dis.geom
		) AS loads
	WHERE	ST_GeometryType(loads.geom) = 'ST_Polygon';

-- index GIST (geom)
CREATE INDEX  	urban_sector_per_grid_district_1_residential_geom_idx
    ON    	model_draft.ego_osm_sector_per_griddistrict_1_residential USING GIST (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_osm_sector_per_griddistrict_1_residential OWNER TO oeuser;

-- sector stats
UPDATE 	model_draft.ego_demand_loadarea_voi AS t1
	SET  	sector_area_residential = t2.sector_area,
		sector_count_residential = t2.sector_count,
		sector_share_residential = t2.sector_area / t2.area_ha
	FROM    (
		SELECT	loads.id AS id,
			SUM(ST_AREA(sector.geom)/10000) AS sector_area,
			COUNT(sector.geom) AS sector_count,
			loads.area_ha AS area_ha
		FROM	model_draft.ego_osm_sector_per_griddistrict_1_residential AS sector,
			model_draft.ego_demand_loadarea_voi AS loads
		WHERE  	loads.geom && sector.geom AND  
			ST_INTERSECTS(loads.geom,ST_BUFFER(sector.geom,-1))
		GROUP BY loads.id
		) AS t2
	WHERE  	t1.id = t2.id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_osm_sector_per_griddistrict_1_residential','ego_dp_loadarea_loadcut_voronoi.sql',' ');


-- 2. retail sector
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_griddistrict_2_retail CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_griddistrict_2_retail	 (
	id SERIAL NOT NULL,
	geom geometry(Polygon,3035),
	CONSTRAINT urban_sector_per_grid_district_2_retail_pkey PRIMARY KEY (id));

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','openstreetmap','osm_deu_polygon_urban_sector_2_retail_mview','ego_dp_loadarea_loadcut_voronoi.sql',' ');

-- intersect sector with mv-griddistrict
INSERT INTO     model_draft.ego_osm_sector_per_griddistrict_2_retail (geom)
	SELECT	loads.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(loads.geom,dis.geom))).geom AS geom
		FROM	openstreetmap.osm_deu_polygon_urban_sector_2_retail_mview AS loads,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE	loads.geom && dis.geom
		) AS loads
	WHERE	ST_GeometryType(loads.geom) = 'ST_Polygon';

-- index GIST (geom)
CREATE INDEX  	urban_sector_per_grid_district_2_retail_geom_idx
    ON    	model_draft.ego_osm_sector_per_griddistrict_2_retail USING GIST (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_osm_sector_per_griddistrict_2_retail OWNER TO oeuser;

-- sector stats
UPDATE 	model_draft.ego_demand_loadarea_voi AS t1
	SET  	sector_area_retail = t2.sector_area,
		sector_count_retail = t2.sector_count,
		sector_share_retail = t2.sector_area / t2.area_ha
	FROM    (
		SELECT	loads.id AS id,
			SUM(ST_AREA(sector.geom)/10000) AS sector_area,
			COUNT(sector.geom) AS sector_count,
			loads.area_ha AS area_ha
		FROM	model_draft.ego_osm_sector_per_griddistrict_2_retail AS sector,
			model_draft.ego_demand_loadarea_voi AS loads
		WHERE  	loads.geom && sector.geom AND  
			ST_INTERSECTS(loads.geom,ST_BUFFER(sector.geom,-1))
		GROUP BY loads.id
		) AS t2
	WHERE  	t1.id = t2.id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_osm_sector_per_griddistrict_2_retail','ego_dp_loadarea_loadcut_voronoi.sql',' ');


-- 3. industrial sector
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_griddistrict_3_industrial CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_griddistrict_3_industrial	 (
	id SERIAL NOT NULL,
	geom geometry(Polygon,3035),
	CONSTRAINT urban_sector_per_grid_district_3_industrial_pkey PRIMARY KEY (id));

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','openstreetmap','osm_deu_polygon_urban_sector_3_industrial_mview','ego_dp_loadarea_loadcut_voronoi.sql',' ');

-- intersect sector with mv-griddistrict
INSERT INTO     model_draft.ego_osm_sector_per_griddistrict_3_industrial (geom)
	SELECT	loads.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(loads.geom,dis.geom))).geom AS geom
		FROM	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview AS loads,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE	loads.geom && dis.geom
		) AS loads
	WHERE	ST_GeometryType(loads.geom) = 'ST_Polygon';

-- index GIST (geom)
CREATE INDEX  	urban_sector_per_grid_district_3_industrial_geom_idx
    ON    	model_draft.ego_osm_sector_per_griddistrict_3_industrial USING GIST (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_osm_sector_per_griddistrict_3_industrial OWNER TO oeuser;

-- sector stats
UPDATE 	model_draft.ego_demand_loadarea_voi AS t1
	SET  	sector_area_industrial = t2.sector_area,
		sector_count_industrial = t2.sector_count,
		sector_share_industrial = t2.sector_area / t2.area_ha
	FROM    (
		SELECT	loads.id AS id,
			SUM(ST_AREA(sector.geom)/10000) AS sector_area,
			COUNT(sector.geom) AS sector_count,
			loads.area_ha AS area_ha
		FROM	model_draft.ego_osm_sector_per_griddistrict_3_industrial AS sector,
			model_draft.ego_demand_loadarea_voi AS loads
		WHERE  	loads.geom && sector.geom AND  
			ST_INTERSECTS(loads.geom,ST_BUFFER(sector.geom,-1))
		GROUP BY loads.id
		) AS t2
	WHERE  	t1.id = t2.id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_osm_sector_per_griddistrict_3_industrial','ego_dp_loadarea_loadcut_voronoi.sql',' ');


-- 4. agricultural sector
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_griddistrict_4_agricultural CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_griddistrict_4_agricultural	 (
		id SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	urban_sector_per_grid_district_4_agricultural_pkey PRIMARY KEY (id));

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','openstreetmap','osm_deu_polygon_urban_sector_4_agricultural_mview','ego_dp_loadarea_loadcut_voronoi.sql',' ');

-- intersect sector with mv-griddistrict
INSERT INTO     model_draft.ego_osm_sector_per_griddistrict_4_agricultural (geom)
	SELECT	loads.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(loads.geom,dis.geom))).geom AS geom
		FROM	openstreetmap.osm_deu_polygon_urban_sector_4_agricultural_mview AS loads,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE	loads.geom && dis.geom
		) AS loads
	WHERE	ST_GeometryType(loads.geom) = 'ST_Polygon';

-- index GIST (geom)
CREATE INDEX  	urban_sector_per_grid_district_4_agricultural_geom_idx
    ON    	model_draft.ego_osm_sector_per_griddistrict_4_agricultural USING GIST (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_osm_sector_per_griddistrict_4_agricultural OWNER TO oeuser;

-- sector stats
UPDATE 	model_draft.ego_demand_loadarea_voi AS t1
	SET  	sector_area_agricultural = t2.sector_area,
		sector_count_agricultural = t2.sector_count,
		sector_share_agricultural = t2.sector_area / t2.area_ha
	FROM    (
		SELECT	loads.id AS id,
			SUM(ST_AREA(sector.geom)/10000) AS sector_area,
			COUNT(sector.geom) AS sector_count,
			loads.area_ha AS area_ha
		FROM	model_draft.ego_osm_sector_per_griddistrict_4_agricultural AS sector,
			model_draft.ego_demand_loadarea_voi AS loads
		WHERE  	loads.geom && sector.geom AND  
			ST_INTERSECTS(loads.geom,ST_BUFFER(sector.geom,-1))
		GROUP BY loads.id
		) AS t2
	WHERE  	t1.id = t2.id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_osm_sector_per_griddistrict_4_agricultural','ego_dp_loadarea_loadcut_voronoi.sql',' ');


-- sector stats
UPDATE 	model_draft.ego_demand_loadarea_voi AS t1
	SET  	sector_area_sum = t2.sector_area_sum,
		sector_share_sum = t2.sector_share_sum,
		sector_count_sum = t2.sector_count_sum
	FROM    (
		SELECT	id,
			coalesce(load.sector_area_residential,0) + 
				coalesce(load.sector_area_retail,0) + 
				coalesce(load.sector_area_industrial,0) + 
				coalesce(load.sector_area_agricultural,0) AS sector_area_sum,
			coalesce(load.sector_share_residential,0) + 
				coalesce(load.sector_share_retail,0) + 
				coalesce(load.sector_share_industrial,0) + 
				coalesce(load.sector_share_agricultural,0) AS sector_share_sum,
			coalesce(load.sector_count_residential,0) + 
				coalesce(load.sector_count_retail,0) + 
				coalesce(load.sector_count_industrial,0) + 
				coalesce(load.sector_count_agricultural,0) AS sector_count_sum					
		FROM	model_draft.ego_demand_loadarea_voi AS load
		) AS t2
	WHERE  	t1.id = t2.id;
 */


-- Calculate statistics like NUTS and AGS code
-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_boundaries_bkg_vg250_6_gem_clean','ego_dp_loadarea_loadcut_voronoi.sql',' ');

-- nuts code (nuts)
UPDATE  model_draft.ego_demand_loadarea_voi AS t1
    SET nuts = t2.nuts
    FROM (
        SELECT  loads.id AS id,
                vg.nuts AS nuts
        FROM    model_draft.ego_demand_loadarea_voi AS loads,
                model_draft.ego_boundaries_bkg_vg250_6_gem_clean AS vg
        WHERE   vg.geom && loads.geom_centre AND
                ST_CONTAINS(vg.geom,loads.geom_centre)
        ) AS t2
    WHERE   t1.id = t2.id;

-- regionalschlüssel (rs_0)
UPDATE  model_draft.ego_demand_loadarea_voi AS t1
    SET rs_0 = t2.rs_0
    FROM (
        SELECT  loads.id,
                vg.rs_0
        FROM    model_draft.ego_demand_loadarea_voi AS loads,
                model_draft.ego_boundaries_bkg_vg250_6_gem_clean AS vg
        WHERE   vg.geom && loads.geom_centre AND
                ST_CONTAINS(vg.geom,loads.geom_centre)
        ) AS t2
    WHERE   t1.id = t2.id;

-- gemeindeschlüssel (ags_0)
UPDATE  model_draft.ego_demand_loadarea_voi AS t1
    SET ags_0 = t2.ags_0
    FROM (
        SELECT  loads.id AS id,
                vg.ags_0 AS ags_0
        FROM    model_draft.ego_demand_loadarea_voi AS loads,
                model_draft.ego_boundaries_bkg_vg250_6_gem_clean AS vg
        WHERE   vg.geom && loads.geom_centre AND
                ST_CONTAINS(vg.geom,loads.geom_centre)
        ) AS t2
    WHERE   t1.id = t2.id;

-- substation id
UPDATE  model_draft.ego_demand_loadarea_voi AS t1
    SET subst_id = t2.subst_id
    FROM (
        SELECT  loads.id AS id,
                dis.subst_id AS subst_id
        FROM    model_draft.ego_demand_loadarea_voi AS loads,
                model_draft.ego_grid_mv_griddistrict AS dis
        WHERE   dis.geom && loads.geom_centre AND
                ST_CONTAINS(dis.geom,loads.geom_centre)
        ) AS t2
    WHERE   t1.id = t2.id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_demand_loadarea_voi','ego_dp_loadarea_loadcut_voronoi.sql',' ');


-- loads without ags_0
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_demand_loadarea_voi_error_noags_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.ego_demand_loadarea_voi_error_noags_mview AS
    SELECT  loads.id,
            loads.geom
    FROM    model_draft.ego_demand_loadarea_voi AS loads
    WHERE   loads.ags_0 IS NULL;

-- index (id)
CREATE UNIQUE INDEX ego_demand_loadarea_voi_error_noags_mview_id_idx
    ON model_draft.ego_demand_loadarea_voi_error_noags_mview (id);

-- index GIST (geom)
CREATE INDEX ego_demand_loadarea_voi_error_noags_mview_geom_idx
    ON model_draft.ego_demand_loadarea_voi_error_noags_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_loadarea_voi_error_noags_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_demand_loadarea_voi_error_noags_mview IS '{
    "comment": "eGoDP - Temporary table",
    "version": "v0.4.5" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','temp','model_draft','ego_demand_loadarea_voi_error_noags_mview','ego_dp_loadarea_loadcut_voronoi.sql',' ');


/* 
-- test area (ta)
DROP TABLE IF EXISTS	model_draft.ego_demand_loadarea_voi_ta CASCADE;
CREATE TABLE 		model_draft.ego_demand_loadarea_voi_ta AS
	SELECT	load.*
	FROM	model_draft.ego_demand_loadarea_voi AS load
	WHERE	subst_id = '372' OR
		subst_id = '387' OR
		subst_id = '373' OR
		subst_id = '407' OR
		subst_id = '403' OR
		subst_id = '482' OR
		subst_id = '416' OR
		subst_id = '425' OR
		subst_id = '491' OR
		subst_id = '368' OR
		subst_id = '360' OR
		subst_id = '571' OR
		subst_id = '593';

-- PK
ALTER TABLE model_draft.ego_demand_loadarea_voi_ta
	ADD PRIMARY KEY (id);

-- index GIST (geom)
CREATE INDEX	ego_demand_loadarea_voi_ta_geom_idx
    ON model_draft.ego_demand_loadarea_voi_ta USING GIST (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_loadarea_voi_ta OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','temp','model_draft','ego_demand_loadarea_voi_ta','ego_dp_loadarea_loadcut_voronoi.sql',' ');
*/ 
 
/* 
-- SPF test area (spf)
DROP TABLE IF EXISTS  	model_draft.ego_demand_loadarea_voi_spf;
CREATE TABLE         	model_draft.ego_demand_loadarea_voi_spf AS
	SELECT	loads.*
	FROM	model_draft.ego_demand_loadarea_voi AS loads,
		orig_vg250.vg250_4_krs_spf_mview AS spf
	WHERE	ST_TRANSFORM(spf.geom,3035) && loads.geom  AND  
		ST_CONTAINS(ST_TRANSFORM(spf.geom,3035), loads.geom_centre)
	ORDER BY loads.id;

-- PK
ALTER TABLE model_draft.ego_demand_loadarea_voi_spf
	ADD PRIMARY KEY (id);

-- index GIST (geom)
CREATE INDEX  	ego_demand_loadarea_voi_spf_geom_idx
    ON model_draft.ego_demand_loadarea_voi_spf USING GIST (geom);

-- index GIST (geom_centre)
CREATE INDEX  	ego_demand_loadarea_voi_spf_geom_centre_idx
	ON    	model_draft.ego_demand_loadarea_voi_spf USING GIST (geom_centre);

-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_loadarea_voi_spf OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','temp','model_draft','ego_demand_loadarea_voi_spf','ego_dp_loadarea_loadcut_voronoi.sql',' ');
*/ 
