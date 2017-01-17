/*
loadareas per mv-griddistrict
insert cutted load melt
exclude smaller 100m2

__copyright__ = "tba" 
__license__ = "tba" 
__author__ = "Ludee" 
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','model_draft','ego_grid_hvmv_substation','ego_paper_result.sql',' ');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','model_draft','ego_grid_mv_griddistrict','ego_paper_result.sql',' ');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','model_draft','ego_demand_loadarea','ego_paper_result.sql',' ');


-- results and statistics for substation, load area, MV grid districts and consumption
DROP TABLE IF EXISTS 	model_draft.ego_data_processing_results CASCADE;
CREATE TABLE 		model_draft.ego_data_processing_results (
	id SERIAL,
	schema_name text,
	table_name text,
	description text,
	result integer,
	unit text,
	timestamp timestamp,
	CONSTRAINT ego_data_processing_results_pkey PRIMARY KEY (id));

INSERT INTO model_draft.ego_data_processing_results (schema_name,table_name,description,result,unit,timestamp)
	-- Count SUB
	SELECT	'model_draft',
		'ego_grid_hvmv_substation',
		'Number of substations',
		COUNT(subst_id) ::integer AS result,
		' ' ::text AS unit,
		NOW() AT TIME ZONE 'Europe/Berlin'
	FROM	model_draft.ego_grid_hvmv_substation
	UNION ALL
	-- Count MVGD
	SELECT	'model_draft',
		'ego_grid_mv_griddistrict',
		'Number of grid districts',
		COUNT(subst_id) ::integer AS result,
		' ' ::text AS unit,
		NOW() AT TIME ZONE 'Europe/Berlin'
	FROM	model_draft.ego_grid_mv_griddistrict

	UNION ALL
	-- Area vg250.gem
	SELECT	'political_boundary',
		'bkg_vg250_6_gem',
		'Gemeinde area',
		SUM(ST_AREA(ST_TRANSFORM(geom,3025))/10000) ::integer AS result,
		'ha' ::text AS unit,
		NOW() AT TIME ZONE 'Europe/Berlin'
	FROM	political_boundary.bkg_vg250_6_gem
	UNION ALL	
	-- Area vg250.gem_clean
	SELECT	'model_draft',
		'ego_political_boundary_bkg_vg250_6_gem_clean',
		'Processed gemeinde area',
		SUM(ST_AREA(ST_TRANSFORM(geom,3025))/10000) ::integer AS result,
		'ha' ::text AS unit,
		NOW() AT TIME ZONE 'Europe/Berlin'
	FROM	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean
	UNION ALL
	-- Area GD
	SELECT	'model_draft',
		'ego_grid_mv_griddistrict',
		'Grid District area',
		SUM(ST_AREA(geom)/10000) ::integer AS result,
		'ha' ::text AS unit,
		NOW() AT TIME ZONE 'Europe/Berlin'
	FROM	model_draft.ego_grid_mv_griddistrict
	UNION ALL
	-- Min area GD calc
	SELECT	'model_draft',
		'ego_grid_mv_griddistrict',
		'Minmal GD area',
		MIN(ST_AREA(geom)/10000) ::decimal(10,1) AS result,
		'ha' ::text AS unit,
		NOW() AT TIME ZONE 'Europe/Berlin'
	FROM	model_draft.ego_grid_mv_griddistrict
	UNION ALL
	-- Min area GD area
	SELECT	'model_draft',
		'ego_grid_mv_griddistrict',
		'Minmal GD area',
		MIN(area_ha) ::decimal(10,1) AS result,
		'ha' ::text AS unit,
		NOW() AT TIME ZONE 'Europe/Berlin'
	FROM	model_draft.ego_grid_mv_griddistrict
	UNION ALL
	-- Max area GD
	SELECT	'model_draft',
		'ego_grid_mv_griddistrict',
		'Maximal GD area',
		MAX(ST_AREA(geom)/10000) ::decimal(10,1) AS result,
		'ha' ::text AS unit,
		NOW() AT TIME ZONE 'Europe/Berlin'
	FROM	model_draft.ego_grid_mv_griddistrict
	UNION ALL
	-- Count LA
	SELECT	'model_draft',
		'ego_demand_loadarea',
		'Number of Load Areas',
		COUNT(id) ::integer AS result,
		' ' ::text AS unit,
		NOW() AT TIME ZONE 'Europe/Berlin'
	FROM	model_draft.ego_demand_loadarea
	UNION ALL
	-- Area LA
	SELECT	'model_draft',
		'ego_demand_loadarea',
		'Load Areas area',
		SUM(ST_AREA(geom)/10000) ::decimal(10,1) AS result,
		'ha' ::text AS unit,
		NOW() AT TIME ZONE 'Europe/Berlin'
	FROM	model_draft.ego_demand_loadarea

	UNION ALL
	-- Min area LA
	SELECT	'model_draft',
		'ego_demand_loadarea',
		'Minmal LA area',
		MIN(ST_AREA(geom)/10000) ::decimal(10,3) AS result,
		'ha' ::text AS unit,
		NOW() AT TIME ZONE 'Europe/Berlin'
	FROM	model_draft.ego_demand_loadarea
	UNION ALL
	-- Max area LA
	SELECT	'model_draft',
		'ego_demand_loadarea',
		'Maximal LA area',
		MAX(ST_AREA(geom)/10000) ::decimal(10,3) AS result,
		'ha' ::text AS unit,
		NOW() AT TIME ZONE 'Europe/Berlin'
	FROM	model_draft.ego_demand_loadarea;

-- Set grants and owner
ALTER TABLE model_draft.ego_data_processing_results OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_data_processing_results','ego_paper_result.sql',' ');



-- mv-griddistrict types
DROP TABLE IF EXISTS 	model_draft.ego_data_processing_results_mvgd CASCADE;
CREATE TABLE		model_draft.ego_data_processing_results_mvgd AS
	SELECT	subst_id,
		'0' ::integer AS type1,
		'0' ::integer AS type1_cnt,
		'0' ::integer AS type2,
		'0' ::integer AS type2_cnt,
		'0' ::integer AS type3,
		'0' ::integer AS type3_cnt,
		'0' ::integer AS gem,
		'0' ::integer AS gem_clean,
		'0' ::integer AS la_count,
		'0' ::decimal(10,1) AS area_ha,	
		'0' ::decimal(10,1) AS la_area,
		'0' ::decimal(10,1) AS free_area,
		'0' ::decimal(4,1) AS area_share,		
		geom,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_grid_mv_griddistrict AS gd;

-- Type1
UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	type1 = t2.type1
FROM	(SELECT	gd.subst_id,
		COUNT(ST_PointOnSurface(typ.geom))::integer AS type1
	FROM	model_draft.ego_grid_mv_griddistrict_type1 AS typ,
		model_draft.ego_grid_mv_griddistrict AS gd
	WHERE	gd.geom && typ.geom AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(typ.geom))
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	type1_cnt = t2.type_cnt
FROM	(SELECT	gd.subst_id,
		COUNT(ST_PointOnSurface(typ.geom))::integer AS type_cnt
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_1_mview AS typ,
		model_draft.ego_grid_mv_griddistrict AS gd
	WHERE	gd.geom && typ.geom AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(typ.geom))
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

-- Type2
UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	type2 = t2.type2
FROM	(SELECT	gd.subst_id,
		COUNT(ST_PointOnSurface(typ.geom))::integer AS type2
	FROM	model_draft.ego_grid_mv_griddistrict_type2 AS typ,
		model_draft.ego_grid_mv_griddistrict AS gd
	WHERE	gd.geom && typ.geom AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(typ.geom))
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	type2_cnt = t2.type_cnt
FROM	(SELECT	gd.subst_id,
		COUNT(ST_PointOnSurface(typ.geom))::integer AS type_cnt
	FROM	model_draft.ego_grid_hvmv_substation_voronoi_cut AS typ,
		model_draft.ego_grid_mv_griddistrict AS gd
	WHERE	gd.geom && typ.geom AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(typ.geom))
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;


-- Type3
UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	type3 = t2.type3
FROM	(SELECT	gd.subst_id,
		COUNT(ST_PointOnSurface(typ.geom))::integer AS type3
	FROM	model_draft.ego_grid_mv_griddistrict_type3 AS typ,
		model_draft.ego_grid_mv_griddistrict AS gd
	WHERE	gd.geom && typ.geom AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(typ.geom))
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	type3_cnt = t2.type_cnt
FROM	(SELECT	gd.subst_id,
		COUNT(ST_PointOnSurface(typ.geom))::integer AS type_cnt
	FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem_3_mview AS typ,
		model_draft.ego_grid_mv_griddistrict AS gd
	WHERE	gd.geom && typ.geom AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(typ.geom))
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;


DROP MATERIALIZED VIEW IF EXISTS political_boundary.bkg_vg250_6_gem_pts;
CREATE MATERIALIZED VIEW political_boundary.bkg_vg250_6_gem_pts AS
SELECT	id,
	ags_0,
	ST_PointOnSurface(geom) AS geom
FROM	political_boundary.bkg_vg250_6_gem;

-- Gemeinden
UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	gem = t2.gem
FROM	(SELECT	gd.subst_id,
		COUNT(ST_PointOnSurface(gem.geom))::integer AS gem
	FROM	political_boundary.bkg_vg250_6_gem AS gem,
		model_draft.ego_grid_mv_griddistrict AS gd
	WHERE	gd.geom && ST_TRANSFORM(gem.geom,3035) AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(ST_TRANSFORM(gem.geom,3035)))
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

/* -- bkg_vg250_6_gem_clean_pts
DROP MATERIALIZED VIEW IF EXISTS model_draft.ego_political_boundary_bkg_vg250_6_gem_clean_pts;
CREATE MATERIALIZED VIEW model_draft.ego_political_boundary_bkg_vg250_6_gem_clean_pts AS
SELECT	id,
	ags_0,
	ST_PointOnSurface(geom) AS geom
FROM	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean; */

-- Gemeinde Parts
UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	gem_clean = t2.gem_clean
FROM	(SELECT	gd.subst_id,
		COUNT(ST_PointOnSurface(gem.geom))::integer AS gem_clean
	FROM	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean AS gem,
		model_draft.ego_grid_mv_griddistrict AS gd
	WHERE	gd.geom && gem.geom AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(gem.geom))
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

-- GD Area 3610
UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	area_ha = t2.area_ha
FROM	(SELECT	gd.subst_id,
		ST_AREA(gd.geom)/10000 AS area_ha
	FROM	model_draft.ego_grid_mv_griddistrict AS gd
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

-- LA Count
UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	la_count = t2.la_count
FROM	(SELECT	gd.subst_id,
		COUNT(ST_PointOnSurface(la.geom))::integer AS la_count
	FROM	model_draft.ego_demand_loadarea AS la,
		model_draft.ego_grid_mv_griddistrict AS gd
	WHERE	gd.geom && la.geom AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(la.geom))
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

-- LA Area 3606
UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	la_area = t2.la_area
FROM	(SELECT	gd.subst_id,
		SUM(ST_AREA(la.geom)/10000) ::decimal(10,3) AS la_area
	FROM	model_draft.ego_demand_loadarea AS la,
		model_draft.ego_grid_mv_griddistrict AS gd
	WHERE	gd.geom && la.geom AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(la.geom))
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

-- not LA Area (free_area)
UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	free_area = t2.free_area
FROM	(SELECT	gd.subst_id,
		SUM(gd.area_ha)-SUM(gd.la_area) AS free_area
	FROM	model_draft.ego_data_processing_results_mvgd as gd
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

-- not LA Area (free_area)
UPDATE 	model_draft.ego_data_processing_results_mvgd AS t1
SET  	area_share = t2.area_share
FROM	(SELECT	gd.subst_id,
		SUM(gd.la_area)/SUM(gd.area_ha)*100 AS area_share
	FROM	model_draft.ego_data_processing_results_mvgd as gd
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

SELECT	MAX(area_share) AS max,
	MIN(area_share) AS min
FROM	model_draft.ego_data_processing_results_mvgd ;

-- grant (oeuser)
ALTER TABLE model_draft.ego_data_processing_results_mvgd
	OWNER TO oeuser,
	ADD PRIMARY KEY (subst_id) ;

-- index GIST (geom)
CREATE INDEX  	ego_data_processing_results_mvgd_geom_idx
	ON	model_draft.ego_data_processing_results_mvgd USING GIST (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_data_processing_results_mvgd','ego_paper_result.sql',' ');

	

-- Calculate statistics for BKG-vg250 
DROP MATERIALIZED VIEW IF EXISTS 	political_boundary.bkg_vg250_statistics_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_statistics_mview AS 
-- Calculate areas
SELECT	'1' ::integer AS id,
	'1_sta' ::text AS table,
	'vg' ::text AS descript_nameion,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
UNION ALL
SELECT	'3' ::integer AS id,
	'1_sta' ::text AS table,
	'deu' ::text AS descript_nameion,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	bez='Bundesrepublik'
UNION ALL
SELECT	'4' ::integer AS id,
	'1_sta' ::text AS table,
	'NOT deu' ::text AS descript_nameion,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	bez='--'
UNION ALL
SELECT	'5' ::integer AS id,
	'1_sta' ::text AS table,
	'land' ::text AS descript_nameion,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	gf='3' OR gf='4'
UNION ALL
SELECT	'6' ::integer AS id,
	'1_sta' ::text AS table,
	'water' ::text AS descript_nameion,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	gf='1' OR gf='2';

-- grant (oeuser)
ALTER TABLE political_boundary.bkg_vg250_statistics_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','political_boundary','bkg_vg250_statistics_mview','ego_paper_result.sql',' ');


/* -- EWE Validation

-- substation in EWE   (OK!) 500ms =136
DROP MATERIALIZED VIEW IF EXISTS  	model_draft.ego_grid_hvmv_substation_ewe_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.ego_grid_hvmv_substation_ewe_mview AS
	SELECT	subs.*
	FROM	model_draft.ego_grid_hvmv_substation AS subs,
		model_draft.ego_grid_mv_griddistrict_ewe AS ewe
	WHERE  	ST_TRANSFORM(ewe.geom,3035) && subs.geom AND
		ST_CONTAINS(ST_TRANSFORM(ewe.geom,3035),subs.geom) ;

-- index GIST (geom)   (OK!) 1.000ms =*
CREATE INDEX	ego_deu_substations_ewe_mview_geom_idx
	ON	model_draft.ego_grid_hvmv_substation_ewe_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =*
GRANT ALL ON TABLE	model_draft.ego_grid_hvmv_substation_ewe_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_grid_hvmv_substation_ewe_mview OWNER TO oeuser;


-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_deu_substations_ewe_mview' AS table_name,
		'analyse_eGo_paper_result.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_grid_hvmv_substation_ewe_mview; */
	
	
