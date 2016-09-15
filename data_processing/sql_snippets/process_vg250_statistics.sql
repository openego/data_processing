---------- ---------- ----------
---------- --SKRIPT-- OK! 13s
---------- ---------- ----------

-- Get statistics of the german municipalities

-- Error   (OK!) 47.000ms =143.293
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.vg250_statistics_mview CASCADE;
CREATE MATERIALIZED VIEW			political_boundary.vg250_statistics_mview AS 
-- Area Sum
-- 38162814 km²
SELECT	'vg' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
UNION ALL
-- 38141292 km²
SELECT	'deu' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
WHERE	bez='Bundesrepublik'
UNION ALL
-- 38141292 km²
SELECT	'NOT deu' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
WHERE	bez='--'
UNION ALL
-- 35718841 km²
SELECT	'land' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
WHERE	gf='3' OR gf='4'
UNION ALL
-- 35718841 km²
SELECT	'water' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	orig_vg250.vg250_1_sta_mview AS vg
WHERE	gf='1' OR gf='2';

