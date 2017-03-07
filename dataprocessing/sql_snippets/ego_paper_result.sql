/*
loadareas per mv-griddistrict
insert cutted load melt
exclude smaller 100m2

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
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



/* -- mv-griddistrict types
DROP TABLE IF EXISTS 	model_draft.ego_data_processing_results_mvgd CASCADE;
CREATE TABLE		model_draft.ego_data_processing_results_mvgd AS
	SELECT	subst_id,
		'0' ::integer AS type1,
		'0' ::integer AS type1_cnt,
		'0' ::integer AS type2,
		'0' ::integer AS type2_cnt,
		'0' ::integer AS type3,
		'0' ::integer AS type3_cnt,
		'0' ::char(1) AS "group",
		'0' ::integer AS gem,
		'0' ::integer AS gem_clean,
		'0' ::integer AS la_count,
		'0' ::decimal(10,1) AS area_ha,	
		'0' ::decimal(10,1) AS la_area,
		'0' ::decimal(10,1) AS free_area,
		'0' ::decimal(4,1) AS area_share,
		'0' ::numeric AS consumption,
		'0' ::numeric AS consumption_per_area,
		geom,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_grid_mv_griddistrict AS gd;
 */


DROP MATERIALIZED VIEW IF EXISTS political_boundary.bkg_vg250_6_gem_pts;
CREATE MATERIALIZED VIEW political_boundary.bkg_vg250_6_gem_pts AS
SELECT	id,
	ags_0,
	ST_PointOnSurface(geom) AS geom
FROM	political_boundary.bkg_vg250_6_gem;


/* -- bkg_vg250_6_gem_clean_pts
DROP MATERIALIZED VIEW IF EXISTS model_draft.ego_political_boundary_bkg_vg250_6_gem_clean_pts;
CREATE MATERIALIZED VIEW model_draft.ego_political_boundary_bkg_vg250_6_gem_clean_pts AS
SELECT	id,
	ags_0,
	ST_PointOnSurface(geom) AS geom
FROM	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean; */
	

-- Calculate statistics for BKG-vg250 
DROP MATERIALIZED VIEW IF EXISTS 	political_boundary.bkg_vg250_statistics_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_statistics_mview AS 
-- Calculate areas
SELECT	'1' ::integer AS id,
	'1_sta' ::text AS table,
	'vg' ::text AS descript_nameion,
	SUM(vg.area_ha) ::integer AS area_sum_ha
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
UNION ALL
SELECT	'3' ::integer AS id,
	'1_sta' ::text AS table,
	'deu' ::text AS descript_nameion,
	SUM(vg.area_ha) ::integer AS area_sum_ha
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	bez='Bundesrepublik'
UNION ALL
SELECT	'4' ::integer AS id,
	'1_sta' ::text AS table,
	'NOT deu' ::text AS descript_nameion,
	SUM(vg.area_ha) ::integer AS area_sum_ha
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	bez='--'
UNION ALL
SELECT	'5' ::integer AS id,
	'1_sta' ::text AS table,
	'land' ::text AS descript_nameion,
	SUM(vg.area_ha) ::integer AS area_sum_ha
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	gf='3' OR gf='4'
UNION ALL
SELECT	'6' ::integer AS id,
	'1_sta' ::text AS table,
	'water' ::text AS descript_nameion,
	SUM(vg.area_ha) ::integer AS area_sum_ha
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	gf='1' OR gf='2';

-- grant (oeuser)
ALTER TABLE political_boundary.bkg_vg250_statistics_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','political_boundary','bkg_vg250_statistics_mview','ego_paper_result.sql',' ');


-- drid district
/* SELECT	count(geom)
FROM	model_draft.ego_grid_mv_griddistrict_type1
WHERE	geom IS NOT NULL;

SELECT	count(geom)
FROM	model_draft.ego_grid_mv_griddistrict_type2
WHERE	geom IS NOT NULL;

SELECT	count(geom)
FROM	model_draft.ego_grid_mv_griddistrict_type3
WHERE	geom IS NOT NULL;


SELECT	count(id)
FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem
WHERE	subst_type = '1';

SELECT	count(id)
FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem
WHERE	subst_type = '2';

SELECT	count(id)
FROM	model_draft.ego_political_boundary_hvmv_subst_per_gem
WHERE	subst_type = '3'; */

/* -- LA Sizes
SELECT	'< 5 ha' AS name,
	count(la.geom)::integer AS count,
	count(*)::double precision / 208486 * 100 AS share,
	sum(la.area_ha) ::integer AS area
	FROM	model_draft.ego_demand_loadarea AS la
WHERE	area_ha < '5'
UNION ALL
SELECT	'> 500 ha' AS name,
	count(la.geom) AS count,
	count(la.geom)::double precision / 208486 * 100 AS share,
	sum(la.area_ha) ::integer AS area
	FROM	model_draft.ego_demand_loadarea AS la
WHERE	area_ha > '500'; */

/* 
-- Schnittlängen (Umrisse)
SELECT	'Raw LA' AS name,
	count(la.geom) AS number,
	ST_Perimeter(ST_Collect(la.geom))/1000000 AS perimeter_in_tkm 
FROM	model_draft.ego_demand_load_melt AS la
UNION ALL
SELECT	'LA/GD' AS name,
	count(la.geom) AS number,
	ST_Perimeter(ST_Collect(la.geom))/1000000 AS perimeter_in_tkm 
FROM	model_draft.ego_demand_loadarea AS la
UNION ALL
SELECT	'LA/VOI' AS name,
	count(la.geom) AS number,
	ST_Perimeter(ST_Collect(la.geom))/1000000 AS perimeter_in_tkm 
FROM	model_draft.ego_demand_loadarea_voi AS la;
 */

/* 
-- Teil 2
SELECT	'Raw LA' AS name,
	'>500 EW/km2' AS PD,
	ST_Perimeter(ST_Collect(lapd.geom))/1000000 AS perimeter_in_tkm
FROM	(SELECT	la.id,
		la.subst_id,
		gem.pd_km2,
		la.ags_0 AS ags_0_la,
		gem.ags_0 AS ags_0_gem,
		la.geom
	FROM	model_draft.ego_demand_load_melt AS la JOIN political_boundary.bkg_vg250_6_gem_mview AS gem ON (la.ags_0 = gem.ags_0)
	) AS  lapd
WHERE	lapd.pd_km2 > '500'
UNION ALL

SELECT	'LA/GD' AS name,
	'>500 EW/km2' AS PD,
	ST_Perimeter(ST_Collect(lapd.geom))/1000000 AS perimeter_in_tkm
FROM	(SELECT	la.id,
		la.subst_id,
		gem.pd_km2,
		la.ags_0 AS ags_0_la,
		gem.ags_0 AS ags_0_gem,
		la.geom
	FROM	model_draft.ego_demand_loadarea AS la JOIN political_boundary.bkg_vg250_6_gem_mview AS gem ON (la.ags_0 = gem.ags_0)
	) AS  lapd
WHERE	lapd.pd_km2 > '500'
UNION ALL
SELECT	'LA/GD' AS name,
	'<500 EW/km2' AS PD,
	ST_Perimeter(ST_Collect(lapd.geom))/1000000 AS perimeter_in_tkm
FROM	(SELECT	la.id,
		la.subst_id,
		gem.pd_km2,
		la.ags_0 AS ags_0_la,
		gem.ags_0 AS ags_0_gem,
		la.geom
	FROM	model_draft.ego_demand_loadarea AS la JOIN political_boundary.bkg_vg250_6_gem_mview AS gem ON (la.ags_0 = gem.ags_0)
	) AS  lapd
WHERE	lapd.pd_km2 < '500'
UNION ALL

SELECT	'LA/VOI' AS name,
	'>500 EW/km2' AS PD,
	ST_Perimeter(ST_Collect(lapd.geom))/1000000 AS perimeter_in_tkm
FROM	(SELECT	la.id,
		la.subst_id,
		gem.pd_km2,
		la.ags_0 AS ags_0_la,
		gem.ags_0 AS ags_0_gem,
		la.geom
	FROM	model_draft.ego_demand_loadarea_voi AS la JOIN political_boundary.bkg_vg250_6_gem_mview AS gem ON (la.ags_0 = gem.ags_0)
	) AS  lapd
WHERE	lapd.pd_km2 > '500'
UNION ALL
SELECT	'LA/VOI' AS name,
	'<500 EW/km2' AS PD,
	ST_Perimeter(ST_Collect(lapd.geom))/1000000 AS perimeter_in_tkm
FROM	(SELECT	la.id,
		la.subst_id,
		gem.pd_km2,
		la.ags_0 AS ags_0_la,
		gem.ags_0 AS ags_0_gem,
		la.geom
	FROM	model_draft.ego_demand_loadarea_voi AS la JOIN political_boundary.bkg_vg250_6_gem_mview AS gem ON (la.ags_0 = gem.ags_0)
	) AS  lapd
WHERE	lapd.pd_km2 < '500'; */

/* name; pd; perimeter_in_tkm
"LA/GD";">500 EW/km2";62,4983117960233
"LA/VOI";">500 EW/km2";63,6139317047565

"LA/GD";"<500 EW/km2";312,901787628691
"LA/VOI";"<500 EW/km2";316,858435576254

delta_L_>500 = 0,5578099543666 tkm
delta_L_<500 = 1,9783239737815 tkm
*/


/* 
-- simplytry
DROP TABLE IF EXISTS model_draft.ego_grid_mv_griddistrict_simple;
CREATE TABLE model_draft.ego_grid_mv_griddistrict_simple
(
  subst_id integer NOT NULL,
  factor text,
  geom geometry(MultiPolygon,3035),
  CONSTRAINT ego_grid_mv_griddistrict_simple_pkey PRIMARY KEY (subst_id,factor)
);

INSERT INTO model_draft.ego_grid_mv_griddistrict_simple
	SELECT	gd.subst_id,
		'0.1',
		ST_Simplify(gd.geom,0.1)
	FROM	model_draft.ego_grid_mv_griddistrict gd
	WHERE	gd.subst_id = 406 ;

INSERT INTO model_draft.ego_grid_mv_griddistrict_simple
	SELECT	gd.subst_id,
		'1',
		ST_Simplify(gd.geom,1)
	FROM	model_draft.ego_grid_mv_griddistrict gd
	WHERE	gd.subst_id = 406 ;

INSERT INTO model_draft.ego_grid_mv_griddistrict_simple
	SELECT	gd.subst_id,
		'10',
		ST_Simplify(gd.geom,10)
	FROM	model_draft.ego_grid_mv_griddistrict gd
	WHERE	gd.subst_id = 406 ;

INSERT INTO model_draft.ego_grid_mv_griddistrict_simple
	SELECT	gd.subst_id,
		'100',
		ST_Simplify(gd.geom,100)
	FROM	model_draft.ego_grid_mv_griddistrict gd
	WHERE	gd.subst_id = 406 ;

INSERT INTO model_draft.ego_grid_mv_griddistrict_simple
	SELECT	gd.subst_id,
		'1000',
		ST_Simplify(gd.geom,1000)
	FROM	model_draft.ego_grid_mv_griddistrict gd
	WHERE	gd.subst_id = 406 ;
 */

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
	
	
