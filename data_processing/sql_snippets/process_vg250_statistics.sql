DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_statistics_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_statistics_mview AS 
-- Area Sum
SELECT	'1' ::integer AS id,
	'1_sta' ::text AS table,
	'vg' ::text AS description,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
UNION ALL
SELECT	'3' ::integer AS id,
	'1_sta' ::text AS table,
	'deu' ::text AS description,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
WHERE	bez='Bundesrepublik'
UNION ALL
SELECT	'4' ::integer AS id,
	'1_sta' ::text AS table,
	'NOT deu' ::text AS description,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
WHERE	bez='--'
UNION ALL
SELECT	'5' ::integer AS id,
	'1_sta' ::text AS table,
	'land' ::text AS description,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
WHERE	gf='3' OR gf='4'
UNION ALL
SELECT	'6' ::integer AS id,
	'1_sta' ::text AS table,
	'water' ::text AS description,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
WHERE	gf='1' OR gf='2';

