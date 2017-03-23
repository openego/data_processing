/*
loadareas per mv-griddistrict
insert cutted load melt
exclude smaller 100m²

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

-- loadareas per mv-griddistrict
DROP TABLE IF EXISTS  	model_draft.ego_demand_loadarea CASCADE;
CREATE TABLE         	model_draft.ego_demand_loadarea (
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
	sector_consumption_residential double precision,
	sector_consumption_retail double precision,
	sector_consumption_industrial double precision,
	sector_consumption_agricultural double precision,
	sector_consumption_sum double precision,
	geom_centroid geometry(POINT,3035),
	geom_surfacepoint geometry(POINT,3035),
	geom_centre geometry(POINT,3035),
	geom geometry(Polygon,3035),
	CONSTRAINT ego_demand_loadarea_pkey PRIMARY KEY (id));

-- grant (oeuser)
ALTER TABLE	model_draft.ego_demand_loadarea OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_demand_load_melt','process_eGo_loads_per_grid_district.sql',' ');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_grid_mv_griddistrict','process_eGo_loads_per_grid_district.sql',' ');

-- insert cutted load melt
INSERT INTO     model_draft.ego_demand_loadarea (geom)
	SELECT	loads.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(load.geom,dis.geom))).geom AS geom
		FROM	model_draft.ego_demand_load_melt AS load,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE	load.geom && dis.geom
		) AS loads
	WHERE	ST_GeometryType(loads.geom) = 'ST_Polygon';

-- index GIST (geom)
CREATE INDEX  	ego_demand_loadarea_geom_idx
	ON    	model_draft.ego_demand_loadarea USING gist (geom);

-- update area (area_ha)
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	area_ha = t2.area
	FROM    (SELECT	loads.id,
			ST_AREA(ST_TRANSFORM(loads.geom,3035))/10000 AS area
		FROM	model_draft.ego_demand_loadarea AS loads
		) AS t2
	WHERE  	t1.id = t2.id;

	
-- validate area (area_ha) -> exclude smaller 100m²
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_demand_loadarea_smaller100m2_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_demand_loadarea_smaller100m2_mview AS
	SELECT 	loads.id AS id,
		loads.area_ha AS area_ha,
		loads.geom AS geom
	FROM 	model_draft.ego_demand_loadarea AS loads
	WHERE	loads.area_ha < 0.001;

-- index (id)
CREATE UNIQUE INDEX  	ego_demand_loadarea_smaller100m2_mview_id_idx
	ON	model_draft.ego_demand_loadarea_smaller100m2_mview (id);

-- index GIST (geom)
CREATE INDEX	ego_demand_loadarea_smaller100m2_mview_geom_idx
	ON	model_draft.ego_demand_loadarea_smaller100m2_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_demand_loadarea_smaller100m2_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_demand_loadarea_smaller100m2_mview','process_eGo_loads_per_grid_district.sql',' ');


-- remove errors (area_ha)
DELETE FROM	model_draft.ego_demand_loadarea AS loads
	WHERE	loads.area_ha < 0.001;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_demand_loadarea','process_eGo_loads_per_grid_district.sql',' ');


-- centroid
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	geom_centroid = t2.geom_centroid
	FROM    (
		SELECT	loads.id AS id,
			ST_Centroid(loads.geom) AS geom_centroid
		FROM	model_draft.ego_demand_loadarea AS loads
		) AS t2
	WHERE  	t1.id = t2.id;

-- index GIST (geom_centroid)
CREATE INDEX  	ego_demand_loadarea_geom_centroid_idx
	ON    	model_draft.ego_demand_loadarea USING GIST (geom_centroid);


-- surfacepoint
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	geom_surfacepoint = t2.geom_surfacepoint
	FROM    (
		SELECT	loads.id AS id,
			ST_PointOnSurface(loads.geom) AS geom_surfacepoint
		FROM	model_draft.ego_demand_loadarea AS loads
		) AS t2
	WHERE  	t1.id = t2.id;

-- index GIST (geom_surfacepoint)
CREATE INDEX  	ego_demand_loadarea_geom_surfacepoint_idx
	ON    	model_draft.ego_demand_loadarea USING GIST (geom_surfacepoint);


-- centre with centroid if inside loadarea
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	geom_centre = t2.geom_centre
	FROM	(
		SELECT	loads.id AS id,
			loads.geom_centroid AS geom_centre
		FROM	model_draft.ego_demand_loadarea AS loads
		WHERE  	loads.geom && loads.geom_centroid AND
			ST_CONTAINS(loads.geom,loads.geom_centroid)
		)AS t2
	WHERE  	t1.id = t2.id;

-- centre with surfacepoint if outside area
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	geom_centre = t2.geom_centre
	FROM	(
		SELECT	loads.id AS id,
			loads.geom_surfacepoint AS geom_centre
		FROM	model_draft.ego_demand_loadarea AS loads
		WHERE  	loads.geom_centre IS NULL
		)AS t2
	WHERE  	t1.id = t2.id;

-- create index GIST (geom_centre)
CREATE INDEX  	ego_demand_loadarea_geom_centre_idx
	ON    	model_draft.ego_demand_loadarea USING GIST (geom_centre);

/* -- validate geom_centre
	SELECT	loads.id AS id
	FROM	model_draft.ego_demand_loadarea AS loads
	WHERE  	NOT ST_CONTAINS(loads.geom,loads.geom_centre); */


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','social','destatis_zensus_population_per_ha_mview','process_eGo_loads_per_grid_district.sql',' ');

-- zensus 2011 population
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	zensus_sum = t2.zensus_sum,
		zensus_count = t2.zensus_count,
		zensus_density = t2.zensus_density
	FROM    (SELECT	a.id AS id,
			SUM(b.population)::integer AS zensus_sum,
			COUNT(b.geom_point)::integer AS zensus_count,
			(SUM(b.population)/COUNT(b.geom_point))::numeric AS zensus_density
		FROM	model_draft.ego_demand_loadarea AS a,
			social.destatis_zensus_population_per_ha_mview AS b
		WHERE  	a.geom && b.geom_point AND
			ST_CONTAINS(a.geom,b.geom_point)
		GROUP BY a.id
		)AS t2
	WHERE  	t1.id = t2.id;


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','economic','ioer_urban_share_industrial_centroid','process_eGo_loads_per_grid_district.sql',' ');

-- ioer industry share
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	ioer_sum = t2.ioer_sum,
		ioer_count = t2.ioer_count,
		ioer_density = t2.ioer_density
	FROM    (SELECT	loads.id AS id,
			SUM(pts.ioer_share)/100::numeric AS ioer_sum,
			COUNT(pts.geom)::integer AS ioer_count,
			(SUM(pts.ioer_share)/COUNT(pts.geom))::numeric AS ioer_density
		FROM	model_draft.ego_demand_loadarea AS loads,
			economic.ioer_urban_share_industrial_centroid AS pts
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

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','openstreetmap','osm_deu_polygon_urban_sector_1_residential_mview','process_eGo_loads_per_grid_district.sql',' ');

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
ALTER TABLE	model_draft.ego_osm_sector_per_griddistrict_1_residential OWNER TO oeuser;

-- sector stats
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	sector_area_residential = t2.sector_area,
		sector_count_residential = t2.sector_count,
		sector_share_residential = t2.sector_area / t2.area_ha
	FROM    (
		SELECT	loads.id AS id,
			SUM(ST_AREA(sector.geom)/10000) AS sector_area,
			COUNT(sector.geom) AS sector_count,
			loads.area_ha AS area_ha
		FROM	model_draft.ego_osm_sector_per_griddistrict_1_residential AS sector,
			model_draft.ego_demand_loadarea AS loads
		WHERE  	loads.geom && sector.geom AND  
			ST_INTERSECTS(loads.geom,ST_BUFFER(sector.geom,-1))
		GROUP BY loads.id
		) AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_osm_sector_per_griddistrict_1_residential','process_eGo_loads_per_grid_district.sql',' ');


-- 2. retail sector
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_griddistrict_2_retail CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_griddistrict_2_retail	 (
	id SERIAL NOT NULL,
	geom geometry(Polygon,3035),
	CONSTRAINT urban_sector_per_grid_district_2_retail_pkey PRIMARY KEY (id));

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','openstreetmap','osm_deu_polygon_urban_sector_2_retail_mview','process_eGo_loads_per_grid_district.sql',' ');

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
ALTER TABLE	model_draft.ego_osm_sector_per_griddistrict_2_retail OWNER TO oeuser;

-- sector stats
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	sector_area_retail = t2.sector_area,
		sector_count_retail = t2.sector_count,
		sector_share_retail = t2.sector_area / t2.area_ha
	FROM    (
		SELECT	loads.id AS id,
			SUM(ST_AREA(sector.geom)/10000) AS sector_area,
			COUNT(sector.geom) AS sector_count,
			loads.area_ha AS area_ha
		FROM	model_draft.ego_osm_sector_per_griddistrict_2_retail AS sector,
			model_draft.ego_demand_loadarea AS loads
		WHERE  	loads.geom && sector.geom AND  
			ST_INTERSECTS(loads.geom,ST_BUFFER(sector.geom,-1))
		GROUP BY loads.id
		) AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_osm_sector_per_griddistrict_2_retail','process_eGo_loads_per_grid_district.sql',' ');


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','openstreetmap','osm_deu_polygon_urban','process_eGo_loads_per_grid_district.sql',' ');


-- filter Industrial without largescale
DROP MATERIALIZED VIEW IF EXISTS	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_nolargescale_mview CASCADE;
CREATE MATERIALIZED VIEW		openstreetmap.osm_deu_polygon_urban_sector_3_industrial_nolargescale_mview AS
	SELECT	osm.*
	FROM	openstreetmap.osm_deu_polygon_urban AS osm
	WHERE	sector = '3' AND gid NOT IN (SELECT polygon_id FROM model_draft.ego_demand_hv_largescaleconsumer)
ORDER BY	osm.gid;

-- index (id)
CREATE UNIQUE INDEX  	osm_deu_polygon_urban_sector_3_industrial_nolargescale_mview_gid_idx
		ON	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_nolargescale_mview (gid);

-- index GIST (geom)
CREATE INDEX  	osm_deu_polygon_urban_sector_3_industrial_nolargescale_mview_geom_idx
	ON	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_nolargescale_mview USING GIST (geom);
	
-- grant (oeuser)
ALTER TABLE	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_nolargescale_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','openstreetmap','osm_deu_polygon_urban_sector_3_industrial_nolargescale_mview','setup_osm_landuse.sql',' ');

/* -- check
SELECT	'industrial' AS name,
	count(ind.*) AS cnt
FROM	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_mview ind
UNION ALL
SELECT	'largescale' AS name,
	count(ls.*) AS cnt
FROM	model_draft.ego_demand_hv_largescaleconsumer ls
UNION ALL
SELECT	'nolargescale' AS name,
	count(nols.*) AS cnt
FROM	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_nolargescale_mview nols;
 */

-- 3. industrial sector
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_griddistrict_3_industrial CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_griddistrict_3_industrial	 (
	id SERIAL NOT NULL,
	geom geometry(Polygon,3035),
	CONSTRAINT urban_sector_per_grid_district_3_industrial_pkey PRIMARY KEY (id));

-- intersect sector with mv-griddistrict
INSERT INTO     model_draft.ego_osm_sector_per_griddistrict_3_industrial (geom)
	SELECT	loads.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(loads.geom,dis.geom))).geom AS geom
		FROM	openstreetmap.osm_deu_polygon_urban_sector_3_industrial_nolargescale_mview AS loads,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE	loads.geom && dis.geom
		) AS loads
	WHERE	ST_GeometryType(loads.geom) = 'ST_Polygon';

-- index GIST (geom)
CREATE INDEX  	urban_sector_per_grid_district_3_industrial_geom_idx
    ON    	model_draft.ego_osm_sector_per_griddistrict_3_industrial USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_osm_sector_per_griddistrict_3_industrial OWNER TO oeuser;

-- sector stats
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	sector_area_industrial = t2.sector_area,
		sector_count_industrial = t2.sector_count,
		sector_share_industrial = t2.sector_area / t2.area_ha
	FROM    (
		SELECT	loads.id AS id,
			SUM(ST_AREA(sector.geom)/10000) AS sector_area,
			COUNT(sector.geom) AS sector_count,
			loads.area_ha AS area_ha
		FROM	model_draft.ego_osm_sector_per_griddistrict_3_industrial AS sector,
			model_draft.ego_demand_loadarea AS loads
		WHERE  	loads.geom && sector.geom AND  
			ST_INTERSECTS(loads.geom,ST_BUFFER(sector.geom,-1))
		GROUP BY loads.id
		) AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_osm_sector_per_griddistrict_3_industrial','process_eGo_loads_per_grid_district.sql',' ');


-- 4. agricultural sector
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_griddistrict_4_agricultural CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_griddistrict_4_agricultural	 (
		id SERIAL NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	urban_sector_per_grid_district_4_agricultural_pkey PRIMARY KEY (id));

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','openstreetmap','osm_deu_polygon_urban_sector_4_agricultural_mview','process_eGo_loads_per_grid_district.sql',' ');

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
ALTER TABLE	model_draft.ego_osm_sector_per_griddistrict_4_agricultural OWNER TO oeuser;

-- sector stats
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	sector_area_agricultural = t2.sector_area,
		sector_count_agricultural = t2.sector_count,
		sector_share_agricultural = t2.sector_area / t2.area_ha
	FROM    (
		SELECT	loads.id AS id,
			SUM(ST_AREA(sector.geom)/10000) AS sector_area,
			COUNT(sector.geom) AS sector_count,
			loads.area_ha AS area_ha
		FROM	model_draft.ego_osm_sector_per_griddistrict_4_agricultural AS sector,
			model_draft.ego_demand_loadarea AS loads
		WHERE  	loads.geom && sector.geom AND  
			ST_INTERSECTS(loads.geom,ST_BUFFER(sector.geom,-1))
		GROUP BY loads.id
		) AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_osm_sector_per_griddistrict_4_agricultural','process_eGo_loads_per_grid_district.sql',' ');


-- sector stats
UPDATE 	model_draft.ego_demand_loadarea AS t1
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
		FROM	model_draft.ego_demand_loadarea AS load
		) AS t2
	WHERE  	t1.id = t2.id;


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_political_boundary_bkg_vg250_6_gem_clean','process_eGo_loads_per_grid_district.sql',' ');

-- nuts code (nuts)
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	nuts = t2.nuts
	FROM    (
		SELECT	loads.id AS id,
			vg.nuts AS nuts
		FROM	model_draft.ego_demand_loadarea AS loads,
			model_draft.ego_political_boundary_bkg_vg250_6_gem_clean AS vg
		WHERE  	vg.geom && loads.geom_centre AND
			ST_CONTAINS(vg.geom,loads.geom_centre)
		) AS t2
	WHERE  	t1.id = t2.id;

-- regionalschlüssel (rs_0)
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	rs_0 = t2.rs_0
	FROM    (
		SELECT	loads.id,
			vg.rs_0
		FROM	model_draft.ego_demand_loadarea AS loads,
			model_draft.ego_political_boundary_bkg_vg250_6_gem_clean AS vg
		WHERE  	vg.geom && loads.geom_centre AND
			ST_CONTAINS(vg.geom,loads.geom_centre)
		) AS t2
	WHERE  	t1.id = t2.id;

-- gemeindeschlüssel (ags_0)
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	ags_0 = t2.ags_0
	FROM    (
		SELECT	loads.id AS id,
			vg.ags_0 AS ags_0
		FROM	model_draft.ego_demand_loadarea AS loads,
			model_draft.ego_political_boundary_bkg_vg250_6_gem_clean AS vg
		WHERE  	vg.geom && loads.geom_centre AND
			ST_CONTAINS(vg.geom,loads.geom_centre)
		) AS t2
	WHERE  	t1.id = t2.id;

-- substation id
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	loads.id AS id,
			dis.subst_id AS subst_id
		FROM	model_draft.ego_demand_loadarea AS loads,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE  	dis.geom && loads.geom_centre AND
			ST_CONTAINS(dis.geom,loads.geom_centre)
		) AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_demand_loadarea','process_eGo_loads_per_grid_district.sql',' ');


-- loads without ags_0
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_demand_loadarea_error_noags_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_demand_loadarea_error_noags_mview AS
	SELECT	loads.id,
		loads.geom
	FROM	model_draft.ego_demand_loadarea AS loads
	WHERE  	loads.ags_0 IS NULL;

-- index (id)
CREATE UNIQUE INDEX  	ego_demand_loadarea_error_noags_mview_id_idx
	ON	model_draft.ego_demand_loadarea_error_noags_mview (id);

-- index GIST (geom)
CREATE INDEX	ego_demand_loadarea_error_noags_mview_geom_idx
	ON	model_draft.ego_demand_loadarea_error_noags_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_demand_loadarea_error_noags_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_demand_loadarea_error_noags_mview','process_eGo_loads_per_grid_district.sql',' ');


/* 
-- test area (ta)
DROP TABLE IF EXISTS	model_draft.ego_demand_loadarea_ta CASCADE;
CREATE TABLE 		model_draft.ego_demand_loadarea_ta AS
	SELECT	load.*
	FROM	model_draft.ego_demand_loadarea AS load
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
ALTER TABLE	model_draft.ego_demand_loadarea_ta
	ADD PRIMARY KEY (id);

-- index GIST (geom)
CREATE INDEX	ego_demand_loadarea_ta_geom_idx
	ON	model_draft.ego_demand_loadarea_ta USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_demand_loadarea_ta OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_demand_loadarea_ta','process_eGo_loads_per_grid_district.sql',' ');
*/ 
 
/* 
-- SPF test area (spf)
DROP TABLE IF EXISTS  	model_draft.ego_demand_loadarea_spf;
CREATE TABLE         	model_draft.ego_demand_loadarea_spf AS
	SELECT	loads.*
	FROM	model_draft.ego_demand_loadarea AS loads,
		orig_vg250.vg250_4_krs_spf_mview AS spf
	WHERE	ST_TRANSFORM(spf.geom,3035) && loads.geom  AND  
		ST_CONTAINS(ST_TRANSFORM(spf.geom,3035), loads.geom_centre)
	ORDER BY loads.id;

-- PK
ALTER TABLE	model_draft.ego_demand_loadarea_spf
	ADD PRIMARY KEY (id);

-- index GIST (geom)
CREATE INDEX  	ego_demand_loadarea_spf_geom_idx
	ON	model_draft.ego_demand_loadarea_spf USING GIST (geom);

-- index GIST (geom_centre)
CREATE INDEX  	ego_demand_loadarea_spf_geom_centre_idx
	ON    	model_draft.ego_demand_loadarea_spf USING GIST (geom_centre);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_demand_loadarea_spf OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_demand_loadarea_spf','process_eGo_loads_per_grid_district.sql',' ');
*/ 
