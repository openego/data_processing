/*
NOT WORKING YET!!!

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "jong42, Ludee"
*/


/* INSERT INTO	model_draft.ego_grid_mvlv_substation_voronoi_cut (la_id,geom)
	SELECT	a.id AS la_id,
		(ST_DUMP(ST_INTERSECTION(a.geom,b.geom))).geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_demand_loadarea AS a,
		model_draft.ego_grid_mvlv_substation_voronoi AS b
	WHERE	a.geom && b.geom 
		AND a.subst_id = b.subst_id
		-- make sure the boundaries really intersect and not just touch each other
		AND (ST_GEOMETRYTYPE(ST_INTERSECTION(a.geom,b.geom)) = 'ST_Polygon' 
			OR ST_GEOMETRYTYPE(ST_INTERSECTION(a.geom,b.geom)) = 'ST_MultiPolygon' )
		AND ST_isvalid(b.geom) AND ST_isvalid(a.geom);

-- Lösche sehr kleine Gebiete; Diese sind meistens Bugs in den Grenzverläufen
DELETE FROM model_draft.ego_grid_mvlv_substation_voronoi_cut WHERE ST_AREA(geom) < 0.001;


-- Count LV substations per LV grid district
UPDATE 	model_draft.ego_grid_mvlv_substation_voronoi_cut AS t1
	SET lvgd_count = 0; */

/* UPDATE 	model_draft.ego_grid_mvlv_substation_voronoi_cut AS t1
	SET  	lvgd_count = t2.count
	FROM (SELECT COUNT (onts.geom) AS count,dist.id AS id
		FROM model_draft.ego_grid_mvlv_substation AS onts, model_draft.ego_grid_mvlv_substation_voronoi_cut AS dist
		WHERE ST_CONTAINS (dist.geom,onts.geom)
		GROUP BY dist.id
	      ) AS t2
	WHERE t1.id = t2.id; */
/* 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_grid_hvmv_substation_voronoi_cut','process_eGo_grid_district.sql',' ');

	
	
	
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
SET  	ont_id = t2.id
FROM model_draft.ego_grid_mvlv_substation AS t2
WHERE ST_CONTAINS(t1.geom,t2.geom);

-- Add merge info


UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
SET merge_id = t2.merge_id
FROM (
	WITH mins AS (
		SELECT regions.id AS regions_id, MIN(ST_DISTANCE(ST_CENTROID(regions.geom),onts.geom)) AS distance
		FROM
			model_draft.ego_grid_mvlv_substation AS onts 
			INNER JOIN 
			model_draft.ego_grid_lv_griddistrict AS regions ON onts.load_area_id = regions.load_area_id
			INNER JOIN 
			model_draft.ego_grid_lv_griddistrict AS regions2 ON ST_INTERSECTS(regions.geom,regions2.geom)
		WHERE ST_CONTAINS (regions2.geom,onts.geom)
		GROUP BY regions_id

	)

	SELECT regions.id AS district_id, onts.id AS merge_id
	FROM
		model_draft.ego_grid_mvlv_substation AS onts 
		INNER JOIN 
		model_draft.ego_grid_lv_griddistrict AS regions ON onts.load_area_id = regions.load_area_id
		INNER JOIN
		mins ON mins.regions_id = regions.id
	WHERE  ST_DISTANCE(ST_CENTROID(regions.geom),onts.geom) = mins.distance
      ) AS t2
WHERE t1.id = t2.district_id;

UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
SET ont_id = merge_id
WHERE lvgd_count = 0;

----- bis hierhin 3h 13 min


-- Merge areas with same ONT_ID
CREATE TABLE IF NOT EXISTS model_draft."ego_grid_lv_griddistrictwithoutpop"
(
  id serial NOT NULL,
  geom geometry(Polygon,3035),
  load_area_id integer,
  CONSTRAINT ego_grid_lv_griddistrictwithoutpop_pkey PRIMARY KEY (id)
);

TRUNCATE TABLE 	model_draft."ego_grid_lv_griddistrictwithoutpop";
INSERT INTO		model_draft."ego_grid_lv_griddistrictwithoutpop" (geom,load_area_id)

SELECT (ST_DUMP(ST_UNION(cut.geom))).geom::geometry(Polygon,3035), onts.load_area_id
FROM model_draft.ego_grid_lv_griddistrict AS cut
	INNER JOIN model_draft.ego_grid_mvlv_substation AS onts
ON cut.ont_id = onts.id
WHERE ont_id >= 0
GROUP BY cut.ont_id, onts.load_area_id;

-------------------------------
-- Lösche Bezirke ohne Transformator
DELETE FROM model_draft."ego_grid_lv_griddistrictwithoutpop" AS districts
USING model_draft.ego_grid_mvlv_substation AS onts
WHERE ST_INTERSECTS (onts.geom,districts.geom) = FALSE
	AND onts.id = districts.id;


-- Ordne Bezirke ohne Trafo benachbarten Bezirken mit Trafo zu
UPDATE model_draft."ego_grid_lv_griddistrictwithoutpop" AS districts
SET geom = ST_UNION(adjacent.geom, districts.geom)
FROM  ( SELECT ST_UNION(cut.geom) AS geom, districts.id AS district_id
	FROM model_draft."ego_grid_lv_griddistrictwithoutpop" AS districts,
		model_draft.ego_grid_lv_griddistrict AS cut
	WHERE ST_TOUCHES(cut.geom,districts.geom)
	 AND NOT ST_GEOMETRYTYPE (ST_INTERSECTION(cut.geom,districts.geom)) = 'ST_Point'
	 AND cut.id IN (
		SELECT id FROM model_draft.ego_grid_lv_griddistrict AS cut
		WHERE cut.id NOT IN (
			SELECT cut.id 
			FROM model_draft.ego_grid_lv_griddistrict AS cut,
				model_draft."ego_grid_lv_griddistrictwithoutpop" AS districts
			WHERE ST_WITHIN(cut.geom,districts.geom)
			GROUP BY cut.id
		)
)
		
	GROUP BY districts.id
	) AS adjacent
WHERE districts.id = adjacent.district_id;


-- Add relation between LV grid districts and MVLV substations
-- step 1: add new col with MVLV subst id
ALTER TABLE model_draft.ego_grid_lv_griddistrict
ADD COLUMN mvlv_subst_id integer DEFAULT NULL;
-- step 2: write MVLV subst id to LV grid district table
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
SET  	mvlv_subst_id = t2.sub_id
FROM	(SELECT	gd.id AS gd_id,
	sub.id ::integer AS sub_id

	FROM	model_draft.ego_grid_lv_griddistrict AS gd,
		model_draft.ego_grid_mvlv_substation AS sub
	WHERE  	gd.load_area_id = sub.load_area_id AND
		gd.geom && sub.geom AND
		ST_CONTAINS(gd.geom,sub.geom)
	GROUP BY gd.id, sub.id
	) AS t2
WHERE  	t1.id = t2.gd_id;
 */

---- Add population
--CREATE TABLE IF NOT EXISTS model_draft."ego_grid_lv_grid_district"
--(
--  id serial NOT NULL,
--  geom geometry(Polygon,3035),
--  load_area_id integer,
--  population integer,
--  peak_load integer,
--  area_ha integer,
--  pop_density integer,
--  structure_type text,
--  CONSTRAINT ego_grid_lv_grid_district_pkey PRIMARY KEY (id)
--);
--
--TRUNCATE TABLE 	model_draft."ego_grid_lv_grid_district";
--
--WITH pop AS (
--	SELECT SUM(pts.population) AS population, grid_district.id AS grid_district_id
--	FROM 	social."zensus_population_per_ha" AS pts,
--		model_draft."ego_grid_lv_griddistrictwithoutpop" AS grid_district
--	WHERE ST_CONTAINS(grid_district.geom,pts.geom)
--		AND pts.population > 0
--	GROUP BY grid_district.id
--)
--INSERT INTO		model_draft."ego_grid_lv_grid_district" (geom,id,load_area_id,population)
--
--SELECT t1.*,pop.population
--FROM model_draft."ego_grid_lv_griddistrictwithoutpop" AS t1 LEFT OUTER JOIN pop
--	ON t1.id = pop.grid_district_id;
--
--UPDATE model_draft."ego_grid_lv_grid_district"
--SET population = 0
--WHERE population IS NULL;
--
--------------------------------------------
---- Create sector table
--------------------------------------------
---- Wähle Sektorflächen für jeden Grid District aus:
--CREATE TABLE IF NOT EXISTS model_draft."ego_grid_lv_griddistrictsectors"
--(
--  id serial NOT NULL,
--  geom geometry,
--  grid_district_id integer,
--  load_area_id integer,
--  sector text,
--  population integer,
--  area_ha integer,
--  pop_density integer,
--  peak_load_1 integer,
--  peak_load_2 integer,
--  CONSTRAINT ego_grid_lv_griddistrictsectors_pkey PRIMARY KEY (id)
--);
--
--TRUNCATE TABLE model_draft."ego_grid_lv_griddistrictsectors";
--INSERT INTO model_draft."ego_grid_lv_griddistrictsectors"
--
---- residential
--SELECT (ST_DUMP(ST_INTERSECTION(ST_UNION(sector1.geom),grid_district.geom))).geom AS geom, grid_district.id AS grid_district_id, grid_district.load_area_id AS load_area_id, 'residential' AS sector
--FROM 	model_draft."ego_osm_sector_per_griddistrict_1_residential" AS sector1,
--	model_draft."ego_grid_lv_grid_district" AS grid_district
--WHERE  ST_INTERSECTS(grid_district.geom,sector1.geom)
--GROUP BY grid_district.id, grid_district.geom, load_area_id
--
--UNION
--
---- retail
--SELECT (ST_DUMP(ST_INTERSECTION(ST_UNION(sector2.geom),grid_district.geom))).geom AS geom, grid_district.id AS grid_district_id, grid_district.load_area_id AS load_area_id, 'retail' AS sector
--FROM 	model_draft."ego_osm_sector_per_griddistrict_2_retail" AS sector2,
--	model_draft."ego_grid_lv_grid_district" AS grid_district
--WHERE  ST_INTERSECTS(grid_district.geom,sector2.geom)
--GROUP BY grid_district.id, grid_district.geom, load_area_id
--
--UNION
--
---- industrial
--SELECT (ST_DUMP(ST_INTERSECTION(ST_UNION(sector3.geom),grid_district.geom))).geom AS geom, grid_district.id AS grid_district_id, grid_district.load_area_id AS load_area_id, 'industrial' AS sector
--FROM 	model_draft."ego_osm_sector_per_griddistrict_3_industrial" AS sector3,
--	model_draft."ego_grid_lv_grid_district" AS grid_district
--WHERE  ST_INTERSECTS(grid_district.geom,sector3.geom)
--GROUP BY grid_district.id, grid_district.geom, load_area_id
--
--UNION
--
---- agricultural
--SELECT (ST_DUMP(ST_INTERSECTION(ST_UNION(sector4.geom),grid_district.geom))).geom AS geom, grid_district.id AS grid_district_id, grid_district.load_area_id AS load_area_id, 'agricultural' AS sector
--FROM 	model_draft."ego_osm_sector_per_griddistrict_4_agricultural" AS sector4,
--	model_draft."ego_grid_lv_grid_district" AS grid_district
--WHERE ST_INTERSECTS(grid_district.geom,sector4.geom)
--GROUP BY grid_district.id, grid_district.geom, load_area_id;
--
---- Gebiete ohne OSM-Tagging
--INSERT INTO model_draft."ego_grid_lv_griddistrictsectors" (geom,grid_district_id,load_area_id, sector)
--
--SELECT ST_MULTI(ST_DIFFERENCE(districts.geom::geometry(POLYGON,3035),ST_MULTI(ST_UNION (sectors.geom)))) AS geom, districts.id, districts.load_area_id, 'no sector'
--FROM model_draft."ego_grid_lv_griddistrictsectors" AS sectors,
--	model_draft."ego_grid_lv_grid_district" AS districts
--WHERE districts.id = sectors.grid_district_id
--
--GROUP BY districts.geom,districts.id,districts.load_area_id;
--
--
--
---- Lösche ungültige Geometrien
--DELETE FROM model_draft."ego_grid_lv_griddistrictsectors"
--WHERE ST_geometrytype(geom) = 'ST_GeometryCollection';
--
--
---- Füge Einwohnerzahl hinzu
--
--UPDATE	model_draft."ego_grid_lv_griddistrictsectors" AS a
--SET population = (SELECT population FROM(
--			SELECT SUM(pts.population) AS population, sectors.id AS id
--				FROM 	social."zensus_population_per_ha" AS pts,
--					model_draft."ego_grid_lv_griddistrictsectors" AS sectors
--				WHERE ST_CONTAINS(sectors.geom,pts.geom)
--					AND pts.population > 0
--				GROUP BY sectors.id
--			) AS b
--		WHERE a.id = b.id);
--
--UPDATE	model_draft."ego_grid_lv_griddistrictsectors" AS a
--SET population = 0 WHERE population IS NULL;
--
---- Füge Fläche [ha] hinzu
--UPDATE model_draft."ego_grid_lv_griddistrictsectors" AS sectors
--SET area_ha =  ST_AREA(geom)*0.0001;
--
---- Füge Einwohnerdichte hinzu
--UPDATE model_draft."ego_grid_lv_griddistrictsectors" AS sectors
--SET pop_density =  population/area_ha
--WHERE area_ha > 0;
--
---- Berechne Spitzenlast der Gebiete mit 2 verschiedenen Methoden
--
---- Methode 1: nach Fläche gewichtete Lastgebietsspitzenlasten
--
--UPDATE model_draft."ego_grid_lv_griddistrictsectors" AS b
--SET peak_load_1 =  (SELECT a.peak_load AS peak_load
--	FROM(SELECT (ST_AREA(sectors.geom) / ((l_area.sector_area_residential)* 10000)) * (peak.residential* 1000000)   AS peak_load, sectors.id
--
--		FROM model_draft."ego_grid_lv_griddistrictsectors" AS sectors,
--				model_draft.ego_demand_loadarea AS l_area,
--				model_draft."ego_demand_loadarea_peak_load" AS peak
--
--		WHERE sectors.sector = 'residential'
--			AND l_area.id = sectors.load_area_id
--			AND peak.id = l_area.id
--			AND l_area.sector_area_residential > 0
--			AND peak.residential > 0
--
--
--		UNION
--
--		SELECT (ST_AREA(sectors.geom) / ((l_area.sector_area_agricultural)* 10000)) * (peak.agricultural* 1000000) AS peak_load, sectors.id
--
--		FROM model_draft."ego_grid_lv_griddistrictsectors" AS sectors,
--				model_draft.ego_demand_loadarea AS l_area,
--				model_draft."ego_demand_loadarea_peak_load" AS peak
--
--		WHERE sectors.sector = 'agricultural'
--			AND l_area.id = sectors.load_area_id
--			AND peak.id = l_area.id
--			AND l_area.sector_area_agricultural > 0
--			AND peak.agricultural > 0
--
--		UNION
--
--		SELECT (ST_AREA(sectors.geom) / ((l_area.sector_area_industrial)* 10000)) * (peak.industrial* 1000000) AS peak_load, sectors.id
--
--		FROM model_draft."ego_grid_lv_griddistrictsectors" AS sectors,
--				model_draft.ego_demand_loadarea AS l_area,
--				model_draft."ego_demand_loadarea_peak_load" AS peak
--
--		WHERE sectors.sector = 'industrial'
--			AND l_area.id = sectors.load_area_id
--			AND peak.id = l_area.id
--			AND l_area.sector_area_industrial > 0
--			AND peak.industrial > 0
--
--		UNION
--
--		SELECT (ST_AREA(sectors.geom) / ((l_area.sector_area_retail)* 10000)) * (peak.retail* 1000000) AS peak_load, sectors.id
--		FROM model_draft."ego_grid_lv_griddistrictsectors" AS sectors,
--				model_draft.ego_demand_loadarea AS l_area,
--				model_draft."ego_demand_loadarea_peak_load" AS peak
--
--		WHERE sectors.sector = 'retail'
--			AND l_area.id = sectors.load_area_id
--			AND peak.id = l_area.id
--			AND l_area.sector_area_retail > 0
--			AND peak.retail > 0)AS a
--	WHERE a.id = b.id);
---- Methode 2: Kerber-Formel anhand Einwohnerzahl
--
--
---- weniger dicht besiedelte Gebiete
--UPDATE model_draft."ego_grid_lv_griddistrictsectors" AS b
--SET peak_load_2 = (30 *(0.065 + (1-0.065)* (population / 2.1)^(-0.75))) * (population / 2.1) WHERE population > 0 AND pop_density <= 69.5;
--
---- dichter besiedelte Gebiete
--UPDATE model_draft."ego_grid_lv_griddistrictsectors" AS b
--SET peak_load_2 = (30 *(0.065 + (1-0.065)* (population / 1.9)^(-0.75))) * (population / 1.9) WHERE population > 0 AND pop_density > 69.5;
--
--UPDATE model_draft."ego_grid_lv_griddistrictsectors" AS b
--SET peak_load_2 = 0 WHERE population = 0;
--
--
--
---------------------------------------------------------
---- back to grid_district table
---------------------------------------------------------
--
--
---- Add peak loads
--
--UPDATE model_draft."ego_grid_lv_grid_district" AS districts
--SET peak_load = (SELECT SUM(peak_load) AS peak_load FROM
--			-- Methode 1 für agricultural, industrial und retail-Flächen
--			(SELECT peak_load_1 AS peak_load, id, grid_district_id, population, sector
--			FROM model_draft."ego_grid_lv_griddistrictsectors"
--			WHERE sector = 'agricultural' OR sector = 'industrial' OR sector = 'retail'
--
--			UNION
--			-- Methode 2 für residential- und unklassifizierte Flächen
--			SELECT peak_load_2 AS peak_load, id, grid_district_id, population, sector
--			FROM model_draft."ego_grid_lv_griddistrictsectors"
--			WHERE sector = 'residential' OR sector = 'no sector'
--			) AS a
--		WHERE districts.id = a.grid_district_id
--
--		GROUP BY a.grid_district_id)
-- ;
--
--
--
--
--UPDATE model_draft."ego_grid_lv_grid_district" AS districts
--SET area_ha =  ST_AREA(geom)*0.0001;
--
---- Add population_density
--UPDATE model_draft."ego_grid_lv_grid_district" AS districts
--SET pop_density =  population/area_ha;
--
---- Add structure type
--
--UPDATE model_draft."ego_grid_lv_grid_district" AS districts
--SET structure_type = 'rural'
--WHERE pop_density >= 0
--	AND pop_density <= 33;
--
--UPDATE model_draft."ego_grid_lv_grid_district" AS districts
--SET structure_type = 'urban'
--WHERE pop_density > 33;
	

----- Delete auxilliary tables
--DROP TABLE IF EXISTS model_draft.ego_grid_mvlv_substation_voronoi;
--DROP TABLE IF EXISTS model_draft."ego_grid_lv_grid_district";
--DROP TABLE IF EXISTS model_draft."ego_grid_lv_griddistrictwithoutpop";
--DROP TABLE IF EXISTS model_draft."ego_grid_lv_griddistrictsectors";
