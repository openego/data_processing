-- calculate results and statistics for substation, load area, MV grid districts and consumption
DROP SEQUENCE 	model_draft.ego_paper_data_allocation_results_seq CASCADE;
CREATE SEQUENCE model_draft.eGo_paper_data_allocation_results_seq;

DROP TABLE IF EXISTS 	model_draft.eGo_paper_data_allocation_results CASCADE;
CREATE TABLE 		model_draft.eGo_paper_data_allocation_results AS
-- Count SUB
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'calc_ego_substation' ::text AS schema,
	'substation_110' ::text AS table,
	'Number of substations' ::text AS description,
	COUNT(subst_id) ::integer AS result,
	' ' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_substation.substation_110
UNION ALL
-- Count GD
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'calc_ego_grid_district' ::text AS schema,
	'grid_district' ::text AS table,
	'Number of grid districts' ::text AS description,
	COUNT(subst_id) ::integer AS result,
	' ' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_grid_district.grid_district

UNION ALL
-- Area vg250.gem
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'orig_vg250' ::text AS schema,
	'vg250_6_gem' ::text AS table,
	'Gemeinde area' ::text AS description,
	SUM(ST_AREA(geom)/10000) ::integer AS result,
	'km²' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	orig_vg250.vg250_6_gem
UNION ALL
-- Area GD
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'calc_ego_grid_district' ::text AS schema,
	'grid_district' ::text AS table,
	'Grid District area' ::text AS description,
	SUM(ST_AREA(geom)/10000) ::integer AS result,
	'km²' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_grid_district.grid_district

UNION ALL
-- Min area GD
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'calc_ego_grid_district' ::text AS schema,
	'grid_district' ::text AS table,
	'Minmal GD area' ::text AS description,
	MIN(ST_AREA(geom)/10000) ::decimal(10,1) AS result,
	'km²' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	orig_vg250.vg250_6_gem
UNION ALL
-- Max area GD
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'calc_ego_grid_district' ::text AS schema,
	'grid_district' ::text AS table,
	'Maximal GD area' ::text AS description,
	MAX(ST_AREA(geom)/10000) ::decimal(10,1) AS result,
	'km²' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_grid_district.grid_district

UNION ALL
-- Count LA
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'calc_ego_loads' ::text AS schema,
	'ego_deu_load_area' ::text AS table,
	'Number of Load Areas' ::text AS description,
	COUNT(id) ::integer AS result,
	' ' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_loads.ego_deu_load_area
UNION ALL
-- Area LA
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'calc_ego_loads' ::text AS schema,
	'ego_deu_load_area' ::text AS table,
	'Load Areas area' ::text AS description,
	SUM(ST_AREA(geom)/10000) ::decimal(10,1) AS result,
	'km²' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_loads.ego_deu_load_area

UNION ALL
-- Min area LA
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'calc_ego_loads' ::text AS schema,
	'ego_deu_load_area' ::text AS table,
	'Minmal LA area' ::text AS description,
	MIN(ST_AREA(geom)/10000) ::decimal(10,3) AS result,
	'km²' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_loads.ego_deu_load_area
UNION ALL
-- Max area LA
SELECT	nextval('model_draft.eGo_paper_data_allocation_results_seq'::regclass) AS id,
	'calc_ego_loads' ::text AS schema,
	'ego_deu_load_area' ::text AS table,
	'Maximal LA area' ::text AS description,
	MAX(ST_AREA(geom)/10000) ::decimal(10,3) AS result,
	'km²' ::text AS unit,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_loads.ego_deu_load_area


;

-- Set grants and owner
ALTER TABLE model_draft.ego_paper_data_allocation_results 
	OWNER TO oeuser,
	ADD PRIMARY KEY (id) ;
