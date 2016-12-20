/*
loadareas per mv-griddistrict
insert cutted load melt
exclude smaller 100m²

__copyright__ = "tba" 
__license__ = "tba" 
__author__ = "Ludee" 
*/

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'model_draft' AS schema_name,
	'ego_grid_hvmv_substation' AS table_name,
	'analyse_eGo_paper_result.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_grid_hvmv_substation' ::regclass) ::json AS metadata
FROM	model_draft.ego_grid_hvmv_substation;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'model_draft' AS schema_name,
	'ego_grid_mv_griddistrict' AS table_name,
	'analyse_eGo_paper_result.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_grid_mv_griddistrict' ::regclass) ::json AS metadata
FROM	model_draft.ego_grid_mv_griddistrict;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'model_draft' AS schema_name,
	'ego_demand_loadarea' AS table_name,
	'analyse_eGo_paper_result.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_demand_loadarea' ::regclass) ::json AS metadata
FROM	model_draft.ego_demand_loadarea;


-- results and statistics for substation, load area, MV grid districts and consumption
DROP SEQUENCE IF EXISTS	model_draft.ego_paper_data_allocation_results_seq CASCADE;
CREATE SEQUENCE 	model_draft.eGo_paper_data_allocation_results_seq;

DROP TABLE IF EXISTS 	model_draft.eGo_paper_data_allocation_results CASCADE;
CREATE TABLE 		model_draft.eGo_paper_data_allocation_results AS
-- Count SUB
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'model_draft' ::text AS schema,
	'ego_grid_hvmv_substation' ::text AS table,
	'Number of substations' ::text AS descript_nameion,
	COUNT(subst_id) ::integer AS result,
	' ' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_hvmv_substation
UNION ALL
-- Count MVGD
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'model_draft' ::text AS schema,
	'ego_grid_mv_griddistrict' ::text AS table,
	'Number of grid districts' ::text AS descript_nameion,
	COUNT(subst_id) ::integer AS result,
	' ' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_mv_griddistrict

UNION ALL
-- Area vg250.gem
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'political_boundary' ::text AS schema,
	'bkg_vg250_6_gem' ::text AS table,
	'Gemeinde area' ::text AS descript_nameion,
	SUM(ST_AREA(ST_TRANSFORM(geom,3025))/10000) ::integer AS result,
	'ha' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	political_boundary.bkg_vg250_6_gem
UNION ALL
-- Area GD
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'model_draft' ::text AS schema,
	'ego_grid_mv_griddistrict' ::text AS table,
	'Grid District area' ::text AS descript_nameion,
	SUM(ST_AREA(geom)/10000) ::integer AS result,
	'ha' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_mv_griddistrict
UNION ALL
-- Min area GD calc
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'model_draft' ::text AS schema,
	'ego_grid_mv_griddistrict' ::text AS table,
	'Minmal GD area' ::text AS descript_nameion,
	MIN(ST_AREA(geom)/10000) ::decimal(10,1) AS result,
	'ha' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_mv_griddistrict
UNION ALL
-- Min area GD area
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'model_draft' ::text AS schema,
	'ego_grid_mv_griddistrict' ::text AS table,
	'Minmal GD area' ::text AS descript_nameion,
	MIN(area_ha) ::decimal(10,1) AS result,
	'ha' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_mv_griddistrict
UNION ALL
-- Max area GD
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'model_draft' ::text AS schema,
	'ego_grid_mv_griddistrict' ::text AS table,
	'Maximal GD area' ::text AS descript_nameion,
	MAX(ST_AREA(geom)/10000) ::decimal(10,1) AS result,
	'ha' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_grid_mv_griddistrict
UNION ALL
-- Count LA
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'model_draft' ::text AS schema,
	'ego_demand_loadarea' ::text AS table,
	'Number of Load Areas' ::text AS descript_nameion,
	COUNT(id) ::integer AS result,
	' ' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_demand_loadarea
UNION ALL
-- Area LA
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'model_draft' ::text AS schema,
	'ego_demand_loadarea' ::text AS table,
	'Load Areas area' ::text AS descript_nameion,
	SUM(ST_AREA(geom)/10000) ::decimal(10,1) AS result,
	'ha' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_demand_loadarea

UNION ALL
-- Min area LA
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'model_draft' ::text AS schema,
	'ego_demand_loadarea' ::text AS table,
	'Minmal LA area' ::text AS descript_nameion,
	MIN(ST_AREA(geom)/10000) ::decimal(10,3) AS result,
	'ha' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_demand_loadarea
UNION ALL
-- Max area LA
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'model_draft' ::text AS schema,
	'ego_demand_loadarea' ::text AS table,
	'Maximal LA area' ::text AS descript_nameion,
	MAX(ST_AREA(geom)/10000) ::decimal(10,3) AS result,
	'ha' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.ego_demand_loadarea;


-- Set grants and owner
ALTER TABLE model_draft.ego_paper_data_allocation_results 
	OWNER TO oeuser,
	ADD PRIMARY KEY (id) ;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'eGo_paper_data_allocation_results' AS table_name,
	'analyse_eGo_paper_result.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.eGo_paper_data_allocation_results' ::regclass) ::json AS metadata
FROM	model_draft.eGo_paper_data_allocation_results;


-- mv-griddistrict types
DROP TABLE IF EXISTS 	model_draft.eGo_paper_data_allocation_mvgd CASCADE;
CREATE TABLE		model_draft.eGo_paper_data_allocation_mvgd AS
-- MVGD types
SELECT	subst_id,
	'0' ::integer AS type1,
	'0' ::integer AS type2,
	'0' ::integer AS type3,
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

-- Type1 1724
UPDATE 	model_draft.eGo_paper_data_allocation_mvgd AS t1
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

-- Type2 1886
UPDATE 	model_draft.eGo_paper_data_allocation_mvgd AS t1
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

-- Type3 2077
UPDATE 	model_draft.eGo_paper_data_allocation_mvgd AS t1
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

DROP MATERIALIZED VIEW IF EXISTS political_boundary.bkg_vg250_6_gem_pts;
CREATE MATERIALIZED VIEW political_boundary.bkg_vg250_6_gem_pts AS
SELECT	id,
	ags_0,
	ST_PointOnSurface(geom) AS geom
FROM	political_boundary.bkg_vg250_6_gem;

-- Gem 2716
UPDATE 	model_draft.eGo_paper_data_allocation_mvgd AS t1
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

-- Gem Parts 2731
UPDATE 	model_draft.eGo_paper_data_allocation_mvgd AS t1
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
UPDATE 	model_draft.eGo_paper_data_allocation_mvgd AS t1
SET  	area_ha = t2.area_ha
FROM	(SELECT	gd.subst_id,
		ST_AREA(gd.geom)/10000 AS area_ha
	FROM	model_draft.ego_grid_mv_griddistrict AS gd
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

-- LA Count
UPDATE 	model_draft.eGo_paper_data_allocation_mvgd AS t1
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
UPDATE 	model_draft.eGo_paper_data_allocation_mvgd AS t1
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
UPDATE 	model_draft.eGo_paper_data_allocation_mvgd AS t1
SET  	free_area = t2.free_area
FROM	(SELECT	gd.subst_id,
		SUM(gd.area_ha)-SUM(gd.la_area) AS free_area
	FROM	model_draft.eGo_paper_data_allocation_mvgd as gd
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

-- not LA Area (free_area)
UPDATE 	model_draft.eGo_paper_data_allocation_mvgd AS t1
SET  	area_share = t2.area_share
FROM	(SELECT	gd.subst_id,
		SUM(gd.la_area)/SUM(gd.area_ha)*100 AS area_share
	FROM	model_draft.eGo_paper_data_allocation_mvgd as gd
	GROUP BY gd.subst_id
	)AS t2
WHERE  	t1.subst_id = t2.subst_id;

SELECT	MAX(area_share) AS max,
	MIN(area_share) AS min
FROM	model_draft.eGo_paper_data_allocation_mvgd ;

-- Set grants and owner
ALTER TABLE model_draft.eGo_paper_data_allocation_mvgd
	OWNER TO oeuser,
	ADD PRIMARY KEY (subst_id) ;

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	eGo_paper_data_allocation_mvgd_geom_idx
	ON	model_draft.eGo_paper_data_allocation_mvgd
	USING	GIST (geom);

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'eGo_paper_data_allocation_mvgd' AS table_name,
	'analyse_eGo_paper_result.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.eGo_paper_data_allocation_mvgd' ::regclass) ::json AS metadata
FROM	model_draft.eGo_paper_data_allocation_mvgd;
	

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

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE	political_boundary.bkg_vg250_statistics_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_statistics_mview OWNER TO oeuser;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_statistics_mview' AS table_name,
	'analyse_eGo_paper_result.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_statistics_mview' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_statistics_mview;



/* -- EWE Validation

-- substation in EWE   (OK!) 500ms =136
DROP MATERIALIZED VIEW IF EXISTS  	model_draft.ego_grid_hvmv_substation_ewe_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.ego_grid_hvmv_substation_ewe_mview AS
	SELECT	subs.*
	FROM	model_draft.ego_grid_hvmv_substation AS subs,
		model_draft.ego_grid_mv_griddistrict_ewe AS ewe
	WHERE  	ST_TRANSFORM(ewe.geom,3035) && subs.geom AND
		ST_CONTAINS(ST_TRANSFORM(ewe.geom,3035),subs.geom) ;

-- Create Index GIST (geom)   (OK!) 1.000ms =*
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
	
	
