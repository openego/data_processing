/*
Results for MV Griddistrict
After finishing the Loadareas we can aggregate the results for the MV Griddistricts:
Area of MV Griddistrict.
Municipality (Gemeinden).
Municipality parts (Gemeinde-Einzelteile).
Municipality types.
Population results.
Loadarea results (Area, Free area, Share).
Consumption results.

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_grid_mv_griddistrict','ego_dp_loadarea_griddistrict_results.sql',' ');

-- Area of MV Griddistrict
UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET area_ha = t2.area_ha
    FROM (
        SELECT  gd.subst_id,
                ST_AREA(gd.geom)/10000 AS area_ha
        FROM    model_draft.ego_grid_mv_griddistrict AS gd
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input', 'boundaries','bkg_vg250_6_gem','ego_dp_loadarea_griddistrict_results.sql',' ');

-- Municipality (Gemeinden)
UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET gem = t2.gem
    FROM (
        SELECT  gd.subst_id,
                COUNT(ST_PointOnSurface(gem.geom))::integer AS gem
        FROM    boundaries.bkg_vg250_6_gem AS gem,
                model_draft.ego_grid_mv_griddistrict AS gd
        WHERE   gd.geom && ST_TRANSFORM(gem.geom,3035) AND
                ST_CONTAINS(gd.geom,ST_PointOnSurface(ST_TRANSFORM(gem.geom,3035)))
        GROUP BY gd.subst_id
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;

    
-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_boundaries_bkg_vg250_6_gem_clean','ego_dp_loadarea_griddistrict_results.sql',' ');

-- Municipality parts (Gemeinde-Einzelteile)
UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET gem_clean = t2.gem_clean
    FROM (
        SELECT  gd.subst_id,
                COUNT(ST_PointOnSurface(gem.geom))::integer AS gem_clean
        FROM    model_draft.ego_boundaries_bkg_vg250_6_gem_clean AS gem,
                model_draft.ego_grid_mv_griddistrict AS gd
        WHERE   gd.geom && gem.geom AND
                ST_CONTAINS(gd.geom,ST_PointOnSurface(gem.geom))
        GROUP BY gd.subst_id
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_grid_mv_griddistrict_type1','ego_dp_loadarea_griddistrict_results.sql',' ');

-- Municipality types - Type1
UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET type1 = t2.type1
    FROM (
        SELECT  gd.subst_id,
                COUNT(ST_PointOnSurface(typ.geom))::integer AS type1
        FROM    model_draft.ego_grid_mv_griddistrict_type1 AS typ,
                model_draft.ego_grid_mv_griddistrict AS gd
        WHERE   gd.geom && typ.geom AND
                ST_CONTAINS(gd.geom,ST_PointOnSurface(typ.geom))
        GROUP BY gd.subst_id
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_boundaries_hvmv_subst_per_gem_1_mview','ego_dp_loadarea_griddistrict_results.sql',' ');

UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET type1_cnt = t2.type_cnt
    FROM (
        SELECT  gd.subst_id,
                COUNT(ST_PointOnSurface(typ.geom))::integer AS type_cnt
        FROM    model_draft.ego_boundaries_hvmv_subst_per_gem_1_mview AS typ,
                model_draft.ego_grid_mv_griddistrict AS gd
        WHERE   gd.geom && typ.geom AND
                ST_CONTAINS(gd.geom,ST_PointOnSurface(typ.geom))
        GROUP BY gd.subst_id
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_grid_mv_griddistrict_type2','ego_dp_loadarea_griddistrict_results.sql',' ');

-- Municipality types - Type2
UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET type2 = t2.type2
    FROM (
        SELECT  gd.subst_id,
                COUNT(ST_PointOnSurface(typ.geom))::integer AS type2
        FROM    model_draft.ego_grid_mv_griddistrict_type2 AS typ,
                model_draft.ego_grid_mv_griddistrict AS gd
        WHERE   gd.geom && typ.geom AND
                ST_CONTAINS(gd.geom,ST_PointOnSurface(typ.geom))
        GROUP BY gd.subst_id
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_grid_hvmv_substation_voronoi_cut','ego_dp_loadarea_griddistrict_results.sql',' ');

UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET type2_cnt = t2.type_cnt
    FROM (
        SELECT  gd.subst_id,
                COUNT(ST_PointOnSurface(typ.geom))::integer AS type_cnt
        FROM    model_draft.ego_grid_hvmv_substation_voronoi_cut AS typ,
                model_draft.ego_grid_mv_griddistrict AS gd
        WHERE   gd.geom && typ.geom AND
                ST_CONTAINS(gd.geom,ST_PointOnSurface(typ.geom))
        GROUP BY gd.subst_id
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_grid_mv_griddistrict_type3','ego_dp_loadarea_griddistrict_results.sql',' ');

-- Municipality types - Type3
UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET type3 = t2.type3
    FROM (
        SELECT  gd.subst_id,
                COUNT(ST_PointOnSurface(typ.geom))::integer AS type3
        FROM    model_draft.ego_grid_mv_griddistrict_type3 AS typ,
                model_draft.ego_grid_mv_griddistrict AS gd
        WHERE   gd.geom && typ.geom AND
                ST_CONTAINS(gd.geom,ST_PointOnSurface(typ.geom))
        GROUP BY gd.subst_id
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_boundaries_hvmv_subst_per_gem_3_mview','ego_dp_loadarea_griddistrict_results.sql',' ');

UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET type3_cnt = t2.type_cnt
    FROM (
        SELECT  gd.subst_id,
                COUNT(ST_PointOnSurface(typ.geom))::integer AS type_cnt
        FROM    model_draft.ego_boundaries_hvmv_subst_per_gem_3_mview AS typ,
                model_draft.ego_grid_mv_griddistrict AS gd
        WHERE   gd.geom && typ.geom AND
                ST_CONTAINS(gd.geom,ST_PointOnSurface(typ.geom))
        GROUP BY gd.subst_id
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;

-- Group
UPDATE model_draft.ego_grid_mv_griddistrict
    SET "group" = (SELECT
        CASE
            WHEN type1 = '1' AND type2 = '0' AND type3 = '1' THEN 'A' -- ländlich
            WHEN type1 = '0' AND type2 = '1' AND type3 = '1' THEN 'B'
            WHEN type1 = '1' AND type2 = '0' AND type3 = '0' THEN 'C'
            WHEN type1 = '0' AND type2 = '1' AND type3 = '0' THEN 'D' -- städtisch
        END);


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','society','destatis_zensus_population_per_ha_mview','ego_dp_loadarea_griddistrict_results.sql',' ');

-- Population results
UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET zensus_sum = t2.zensus_sum,
        zensus_count = t2.zensus_count,
        zensus_density = t2.zensus_density,
        population_density = t2.population_density
    FROM (
        SELECT  gd.subst_id AS subst_id,
                SUM(pts.population)::integer AS zensus_sum,
                COUNT(pts.geom_point)::integer AS zensus_count,
                (SUM(pts.population)/COUNT(pts.geom_point))::numeric AS zensus_density,
                (SUM(pts.population)/gd.area_ha)::numeric AS population_density
        FROM    model_draft.ego_grid_mv_griddistrict AS gd,
                society.destatis_zensus_population_per_ha_mview AS pts
        WHERE   gd.geom && pts.geom_point AND
                ST_CONTAINS(gd.geom,pts.geom_point)
        GROUP BY gd.subst_id
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_demand_loadarea','ego_dp_loadarea_griddistrict_results.sql',' ');

-- Loadarea results - count
UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET la_count = t2.la_count
    FROM (
        SELECT  gd.subst_id,
                COUNT(ST_PointOnSurface(la.geom))::integer AS la_count
        FROM    model_draft.ego_demand_loadarea AS la,
                model_draft.ego_grid_mv_griddistrict AS gd
        WHERE   gd.geom && la.geom AND
                ST_CONTAINS(gd.geom,ST_PointOnSurface(la.geom))
        GROUP BY gd.subst_id
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;

-- Loadarea results - area
UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET la_area = t2.la_area
    FROM (
        SELECT  gd.subst_id,
                SUM(ST_AREA(la.geom)/10000) ::decimal(10,3) AS la_area
        FROM    model_draft.ego_demand_loadarea AS la,
                model_draft.ego_grid_mv_griddistrict AS gd
        WHERE   gd.geom && la.geom AND
                ST_CONTAINS(gd.geom,ST_PointOnSurface(la.geom))
        GROUP BY gd.subst_id
        )AS t2
    WHERE  	t1.subst_id = t2.subst_id;

-- Loadarea results - free_area (not LA Area)
UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET free_area = t2.free_area
    FROM (
        SELECT  gd.subst_id,
                SUM(gd.area_ha)-SUM(gd.la_area) AS free_area
        FROM    model_draft.ego_grid_mv_griddistrict as gd
        GROUP BY gd.subst_id
        )AS t2
    WHERE  	t1.subst_id = t2.subst_id;

-- Loadarea results - free_area share
UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET area_share = t2.area_share
    FROM (
        SELECT  gd.subst_id,
                SUM(gd.la_area)/SUM(gd.area_ha)*100 AS area_share
        FROM    model_draft.ego_grid_mv_griddistrict as gd
        GROUP BY gd.subst_id
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;

/* 
SELECT  MAX(area_share) AS max,
        MIN(area_share) AS min
FROM    model_draft.ego_grid_mv_griddistrict ;
*/


-- Consumption results
UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET consumption = t2.consumption
    FROM (
        SELECT  gd.subst_id,
                SUM(la.sector_consumption_sum)::numeric AS consumption
        FROM    model_draft.ego_demand_loadarea AS la,
                model_draft.ego_grid_mv_griddistrict AS gd
        WHERE   gd.subst_id = la.subst_id
        GROUP BY gd.subst_id
        )AS t2
    WHERE   t1.subst_id = t2.subst_id;

UPDATE model_draft.ego_grid_mv_griddistrict AS t1
    SET consumption_per_area = consumption *1000000 / area_ha;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_grid_mv_griddistrict','ego_dp_loadarea_griddistrict_results.sql',' ');


/* -- test
SELECT	SUM(mvgd.consumption)
	FROM	model_draft.ego_grid_mv_griddistrict AS mvgd
UNION ALL
SELECT	SUM(la.sector_consumption_sum)
	FROM	model_draft.ego_demand_loadarea AS la;
	
UPDATE 	model_draft.ego_grid_mv_griddistrict AS t1
	SET  	consumption_per_area = t2.consumption_per_area
	FROM	(SELECT	gd.subst_id,
			SUM(la.sector_consumption_sum)::integer AS consumption
		FROM	model_draft.ego_grid_mv_griddistrict AS mvgd
		WHERE	gd.subst_id = la.subst_id
		GROUP BY gd.subst_id
		)AS t2
	WHERE  	t1.subst_id = t2.subst_id; */


/* 
---------- ---------- ---------- ---------- ---------- ----------
-- "GD Analysis"   2016-08-25 10:42   12s
---------- ---------- ---------- ---------- ---------- ----------

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	model_draft.ego_grid_mv_griddistrict CASCADE;
CREATE TABLE         	model_draft.ego_grid_mv_griddistrict AS
	SELECT	gd.subst_id ::integer,
		gd.area_ha ::numeric,
		gd.geom ::geometry(MultiPolygon,3035)
	FROM	calc_ego_grid_district.grid_district AS gd;
	
-- Create Index GIST (geom)   (OK!) 2.500ms =0
CREATE INDEX	grid_district_data_geom_idx
	ON	model_draft.ego_grid_mv_griddistrict
	USING	GIST (geom);

-- "Extend Table"   (OK!) 100ms =0
ALTER TABLE	model_draft.ego_grid_mv_griddistrict
	ADD PRIMARY KEY (subst_id),
	ADD COLUMN zensus_sum integer,
	ADD COLUMN zensus_count integer,
	ADD COLUMN zensus_density numeric,
	ADD COLUMN population_density numeric;

-- "Zensus2011 Population"   (OK!) -> 62.000ms =3.610
UPDATE 	model_draft.ego_grid_mv_griddistrict AS t1
SET  	area_ha = t2.area_ha,
	zensus_sum = t2.zensus_sum,
	zensus_count = t2.zensus_count,
	zensus_density = t2.zensus_density,
	population_density = t2.population_density
FROM    (SELECT	gd.subst_id AS subst_id,
		ST_AREA(gd.geom)/10000 ::numeric AS area_ha,
		SUM(pts.population)::integer AS zensus_sum,
		COUNT(pts.geom)::integer AS zensus_count,
		(SUM(pts.population)/COUNT(pts.geom))::numeric AS zensus_density,
		(SUM(pts.population)/gd.area_ha)::numeric AS population_density
	FROM	model_draft.ego_grid_mv_griddistrict AS gd,
		society.destatis_zensus_population_per_ha_mview AS pts
	WHERE  	gd.geom && pts.geom AND
		ST_CONTAINS(gd.geom,pts.geom)
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;


-- "Extend Table"   (OK!) 100ms =0
ALTER TABLE	model_draft.ego_grid_mv_griddistrict
	ADD COLUMN la_count integer,
	ADD COLUMN la_area numeric,
	ADD COLUMN consumption_sum numeric;

-- "LA data"   (OK!) -> 411.000ms =173.278
UPDATE 	model_draft.ego_grid_mv_griddistrict AS t1
SET  	la_count = t2.la_count,
	la_area = t2.la_area,
	consumption_sum = t2.consumption_sum
FROM    (SELECT	gd.subst_id AS subst_id,
		COUNT(la.geom_centre) ::integer AS la_count,
		SUM(la.area_ha) ::numeric AS la_area,
		SUM(la.sector_consumption_sum) ::numeric AS consumption_sum
	FROM	model_draft.ego_grid_mv_griddistrict AS gd,
		calc_ego_loads.ego_deu_load_area AS la
	WHERE  	gd.geom && la.geom_centre AND
		ST_CONTAINS(gd.geom,la.geom_centre)
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;


-- "Extend Table"   (OK!) 100ms =0
ALTER TABLE	model_draft.ego_grid_mv_griddistrict
	ADD COLUMN dea_count integer,
	ADD COLUMN dea_cap_sum integer;

-- "DEA data"   (OK!) -> 411.000ms =173.278
UPDATE 	model_draft.ego_grid_mv_griddistrict AS t1
SET  	dea_count = t2.dea_count,
	dea_cap_sum = t2.dea_cap_sum
FROM    (SELECT	gd.subst_id AS subst_id,
		COUNT(dea.geom) ::integer AS dea_count,
		SUM(dea.electrical_capacity) ::numeric AS dea_cap_sum
	FROM	model_draft.ego_grid_mv_griddistrict AS gd,
		calc_ego_re.ego_deu_dea AS dea
	WHERE  	gd.geom && dea.geom AND
		ST_CONTAINS(gd.geom,dea.geom)
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;
 */
