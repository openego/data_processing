

-- Add Dummy points to substations (18 Points)
ALTER TABLE calc_ego_substation.substations_dummy 
DROP COLUMN IF EXISTS is_dummy;

ALTER TABLE calc_ego_substation.substations_dummy 
ADD COLUMN is_dummy boolean;

UPDATE calc_ego_substation.substations_dummy 
SET is_dummy = TRUE;

ALTER TABLE calc_ego_substation.ego_deu_onts 
DROP COLUMN IF EXISTS is_dummy;

ALTER TABLE calc_ego_substation.ego_deu_onts
ADD COLUMN is_dummy boolean;

INSERT INTO calc_ego_substation.ego_deu_onts (id,geom, is_dummy)
SELECT	
	dummy.subst_id+800000,
	ST_TRANSFORM(dummy.geom,3035),
	dummy.is_dummy
FROM 	calc_ego_substation.substations_dummy AS dummy;

---------------------


-- Execute voronoi algorithm
CREATE TABLE IF NOT EXISTS calc_ego_grid_district.ego_deu_LV_grid_districts_voronoi
(
  id serial NOT NULL,
  geom geometry(Polygon,3035),
  subst_id integer,
  CONSTRAINT ego_deu_lv_grid_districts_voronoi_pkey PRIMARY KEY (id)
);

TRUNCATE TABLE calc_ego_grid_district.ego_deu_LV_grid_districts_voronoi;

-- Begin loop over MS grid districts
DO
$$
DECLARE gd integer;
BEGIN
	FOR gd_id IN 1..3610
	LOOP
		EXECUTE

'WITH 
    -- Sample set of points to work with
    Sample AS (SELECT   ST_SetSRID(ST_Union(pts.geom), 0) AS geom
		FROM	calc_ego_substation.ego_deu_onts AS pts
		WHERE pts.subst_id = ' || gd_id || ' OR is_dummy = TRUE
		),  -- INPUT 1/2
    -- Build edges and circumscribe points to generate a centroid
    Edges AS (
    SELECT id,
        UNNEST(ARRAY[''e1'',''e2'',''e3'']) EdgeName,
        UNNEST(ARRAY[
            ST_MakeLine(p1,p2) ,
            ST_MakeLine(p2,p3) ,
            ST_MakeLine(p3,p1)]) Edge,
        ST_Centroid(ST_ConvexHull(ST_Union(-- Done this way due to issues I had with LineToCurve
            ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p1,p2),ST_MakeLine(p2,p3)))),''LINE'',''CIRCULAR''),15),
            ST_CurveToLine(REPLACE(ST_AsText(ST_LineMerge(ST_Union(ST_MakeLine(p2,p3),ST_MakeLine(p3,p1)))),''LINE'',''CIRCULAR''),15)
        ))) ct      
    FROM    (
        -- Decompose to points
        SELECT id,
            ST_PointN(g,1) p1,
            ST_PointN(g,2) p2,
            ST_PointN(g,3) p3
        FROM    (
            SELECT (gd).Path id, ST_ExteriorRing((gd).geom) g -- ID andmake triangle a linestring
            FROM (SELECT (ST_Dump(ST_DelaunayTriangles(geom))) gd FROM Sample) a -- Get Delaunay Triangles
            )b
        ) c
    )
INSERT INTO calc_ego_grid_district.ego_deu_LV_grid_districts_voronoi (geom, subst_id)	   -- INPUT 2/2
SELECT ST_SetSRID((ST_Dump(ST_Polygonize(ST_Node(ST_LineMerge(ST_Union(v, (SELECT ST_ExteriorRing(ST_ConvexHull(ST_Union(ST_Union(ST_Buffer(edge,20),ct)))) FROM Edges))))))).geom, 3035) geom, ' || gd_id || ' AS subst_id	  
FROM (
    SELECT  -- Create voronoi edges and reduce to a multilinestring
        ST_LineMerge(ST_Union(ST_MakeLine(
        x.ct,
        CASE 
        WHEN y.id IS NULL THEN
            CASE WHEN ST_Within(
                x.ct,
                (SELECT ST_ConvexHull(geom) FROM sample)) THEN -- Dont draw lines back towards the original set
                -- Project line out twice the distance from convex hull
                ST_MakePoint(ST_X(x.ct) + ((ST_X(ST_Centroid(x.edge)) - ST_X(x.ct)) * 200),ST_Y(x.ct) + ((ST_Y(ST_Centroid(x.edge)) - ST_Y(x.ct)) * 200))
            END
        ELSE 
            y.ct
        END
        ))) v
    FROM    Edges x 
        LEFT OUTER JOIN -- Self Join based on edges
        Edges y ON x.id <> y.id AND ST_Equals(x.edge,y.edge)
    ) z';

END LOOP;

END;
$$;


	
-- Delete Dummy points from substations 
DELETE FROM calc_ego_substation.ego_deu_onts WHERE is_dummy = TRUE;

---------- ---------- ----------
-- CUT
---------- ---------- ----------


-- Cutting

CREATE TABLE IF NOT EXISTS calc_ego_grid_district.ego_deu_LV_cut
(
  id serial NOT NULL,
  geom geometry(Polygon,3035),
  load_area_id integer,
  ont_count integer,
  ont_id integer,
  merge_id integer,
  CONSTRAINT ego_deu_lv_cut_pkey PRIMARY KEY (id)
);
 
TRUNCATE TABLE 	calc_ego_grid_district.ego_deu_LV_cut ;
INSERT INTO		calc_ego_grid_district.ego_deu_LV_cut 
	SELECT	(ST_DUMP(ST_INTERSECTION(mun.geom,voi.geom))).geom ::geometry(Polygon,3035) AS geom, mun.id AS load_area_id
	FROM	calc_ego_loads.ego_deu_load_area AS mun,
		calc_ego_grid_district.ego_deu_LV_grid_districts_voronoi AS voi
	WHERE	mun.geom && voi.geom 
		AND mun.subst_id = voi.subst_id
		-- make sure the boundaries really intersect and not just touch each other
		AND (ST_GEOMETRYTYPE(ST_INTERSECTION(mun.geom,voi.geom)) = 'ST_Polygon' 
			OR ST_GEOMETRYTYPE(ST_INTERSECTION(mun.geom,voi.geom)) = 'ST_MultiPolygon' );


-- Lösche sehr kleine Gebiete; Diese sind meistens Bugs in den Grenzverläufen
DELETE FROM calc_ego_grid_district.ego_deu_LV_cut WHERE ST_AREA(geom) < 0.001;
	
-- Count substations per grid district



UPDATE 	calc_ego_grid_district.ego_deu_LV_cut AS t1
SET ont_count = 0;

UPDATE 	calc_ego_grid_district.ego_deu_LV_cut AS t1
SET  	ont_count = t2.count
FROM (SELECT COUNT (onts.geom) AS count,dist.id AS id
	FROM calc_ego_substation.ego_deu_onts AS onts, calc_ego_grid_district.ego_deu_LV_cut AS dist
	WHERE ST_CONTAINS (dist.geom,onts.geom)
	GROUP BY dist.id
      ) AS t2
WHERE t1.id = t2.id;


UPDATE 	calc_ego_grid_district.ego_deu_LV_cut AS t1
SET  	ont_id = t2.id
FROM calc_ego_substation.ego_deu_onts AS t2
WHERE ST_CONTAINS(t1.geom,t2.geom);

-- Add merge info


UPDATE 	calc_ego_grid_district.ego_deu_LV_cut AS t1
SET merge_id = t2.merge_id
FROM (
	WITH mins AS (
		SELECT regions.id AS regions_id, MIN(ST_DISTANCE(ST_CENTROID(regions.geom),onts.geom)) AS distance
		FROM
			calc_ego_substation.ego_deu_onts AS onts 
			INNER JOIN 
			calc_ego_grid_district.ego_deu_LV_cut AS regions ON onts.load_area_id = regions.load_area_id
			INNER JOIN 
			calc_ego_grid_district.ego_deu_LV_cut AS regions2 ON ST_INTERSECTS(regions.geom,regions2.geom)
		WHERE ST_CONTAINS (regions2.geom,onts.geom)
		GROUP BY regions_id

	)

	SELECT regions.id AS district_id, onts.id AS merge_id
	FROM
		calc_ego_substation.ego_deu_onts AS onts 
		INNER JOIN 
		calc_ego_grid_district.ego_deu_LV_cut AS regions ON onts.load_area_id = regions.load_area_id
		INNER JOIN
		mins ON mins.regions_id = regions.id
	WHERE  ST_DISTANCE(ST_CENTROID(regions.geom),onts.geom) = mins.distance
      ) AS t2
WHERE t1.id = t2.district_id;

UPDATE 	calc_ego_grid_district.ego_deu_LV_cut AS t1
SET ont_id = merge_id
WHERE ont_count = 0;

----- bis hierhin 3h 13 min


-- Merge areas with same ONT_ID
CREATE TABLE IF NOT EXISTS calc_ego_grid_district.ego_deu_LV_grid_district_withoutpop
(
  id serial NOT NULL,
  geom geometry(Polygon,3035),
  load_area_id integer,
  CONSTRAINT ego_deu_lv_grid_district_withoutpop_pkey PRIMARY KEY (id)
);

TRUNCATE TABLE 	calc_ego_grid_district.ego_deu_LV_grid_district_withoutpop;
INSERT INTO		calc_ego_grid_district.ego_deu_LV_grid_district_withoutpop (geom,load_area_id)

SELECT (ST_DUMP(ST_UNION(cut.geom))).geom::geometry(Polygon,3035), onts.load_area_id
FROM calc_ego_grid_district.ego_deu_LV_cut AS cut
	INNER JOIN calc_ego_substation.ego_deu_onts AS onts
ON cut.ont_id = onts.id
WHERE ont_id >= 0
GROUP BY cut.ont_id, onts.load_area_id;

-------------------------------
-- Lösche Bezirke ohne Transformator
DELETE FROM calc_ego_grid_district.ego_deu_LV_grid_district_withoutpop AS districts
USING calc_ego_substation.ego_deu_onts AS onts
WHERE ST_INTERSECTS (onts.geom,districts.geom) = FALSE
	AND onts.id = districts.id;


-- Ordne Bezirke ohne Trafo benachbarten Bezirken mit Trafo zu
UPDATE calc_ego_grid_district.ego_deu_LV_grid_district_withoutpop AS districts
SET geom = ST_UNION(adjacent.geom, districts.geom)
FROM  ( SELECT ST_UNION(cut.geom) AS geom, districts.id AS district_id
	FROM calc_ego_grid_district.ego_deu_LV_grid_district_withoutpop AS districts,
		calc_ego_grid_district.ego_deu_LV_cut AS cut
	WHERE ST_TOUCHES(cut.geom,districts.geom)
	 AND NOT ST_GEOMETRYTYPE (ST_INTERSECTION(cut.geom,districts.geom)) = 'ST_Point'
	 AND cut.id IN (
		SELECT id FROM calc_ego_grid_district.ego_deu_LV_cut AS cut
		WHERE cut.id NOT IN (
			SELECT cut.id 
			FROM calc_ego_grid_district.ego_deu_LV_cut AS cut,
				calc_ego_grid_district.ego_deu_LV_grid_district_withoutpop AS districts
			WHERE ST_WITHIN(cut.geom,districts.geom)
			GROUP BY cut.id
		)
)
		
	GROUP BY districts.id
	) AS adjacent
WHERE districts.id = adjacent.district_id;



-- Add population
CREATE TABLE IF NOT EXISTS calc_ego_grid_district.ego_deu_LV_grid_district
(
  id serial NOT NULL,
  geom geometry(Polygon,3035),
  load_area_id integer,
  population integer,
  peak_load integer,
  area_ha integer,
  pop_density integer,
  structure_type text,
  CONSTRAINT ego_deu_lv_grid_district_pkey PRIMARY KEY (id)
);

TRUNCATE TABLE 	calc_ego_grid_district.ego_deu_LV_grid_district;

WITH pop AS (
	SELECT SUM(pts.population) AS population, grid_district.id AS grid_district_id
	FROM 	orig_destatis.zensus_population_per_ha AS pts, 
		calc_ego_grid_district.ego_deu_lv_grid_district_withoutpop AS grid_district
	WHERE ST_CONTAINS(grid_district.geom,pts.geom)
		AND pts.population > 0
	GROUP BY grid_district.id
) 
INSERT INTO		calc_ego_grid_district.ego_deu_LV_grid_district (geom,id,load_area_id,population)

SELECT t1.*,pop.population 
FROM calc_ego_grid_district.ego_deu_lv_grid_district_withoutpop AS t1 LEFT OUTER JOIN pop
	ON t1.id = pop.grid_district_id;

UPDATE calc_ego_grid_district.ego_deu_LV_grid_district
SET population = 0
WHERE population IS NULL;

------------------------------------------
-- Create sector table
------------------------------------------
-- Wähle Sektorflächen für jeden Grid District aus:
CREATE TABLE IF NOT EXISTS calc_ego_grid_district.ego_deu_grid_district_sectors
(
  id serial NOT NULL,
  geom geometry,
  grid_district_id integer,
  load_area_id integer,
  sector text,
  population integer,
  area_ha integer,
  pop_density integer,
  peak_load_1 integer,
  peak_load_2 integer,
  CONSTRAINT ego_deu_grid_district_sectors_pkey PRIMARY KEY (id)
);

TRUNCATE TABLE calc_ego_grid_district.ego_deu_grid_district_sectors;
INSERT INTO calc_ego_grid_district.ego_deu_grid_district_sectors 

-- residential
SELECT (ST_DUMP(ST_INTERSECTION(ST_UNION(sector1.geom),grid_district.geom))).geom AS geom, grid_district.id AS grid_district_id, grid_district.load_area_id AS load_area_id, 'residential' AS sector
FROM 	calc_ego_loads.urban_sector_per_grid_district_1_residential AS sector1,
	calc_ego_grid_district.ego_deu_lv_grid_district AS grid_district
WHERE  ST_INTERSECTS(grid_district.geom,sector1.geom)
GROUP BY grid_district.id, grid_district.geom, load_area_id

UNION

-- retail
SELECT (ST_DUMP(ST_INTERSECTION(ST_UNION(sector2.geom),grid_district.geom))).geom AS geom, grid_district.id AS grid_district_id, grid_district.load_area_id AS load_area_id, 'retail' AS sector
FROM 	calc_ego_loads.urban_sector_per_grid_district_2_retail AS sector2,
	calc_ego_grid_district.ego_deu_lv_grid_district AS grid_district
WHERE  ST_INTERSECTS(grid_district.geom,sector2.geom)
GROUP BY grid_district.id, grid_district.geom, load_area_id

UNION

-- industrial
SELECT (ST_DUMP(ST_INTERSECTION(ST_UNION(sector3.geom),grid_district.geom))).geom AS geom, grid_district.id AS grid_district_id, grid_district.load_area_id AS load_area_id, 'industrial' AS sector
FROM 	calc_ego_loads.urban_sector_per_grid_district_3_industrial AS sector3,
	calc_ego_grid_district.ego_deu_lv_grid_district AS grid_district
WHERE  ST_INTERSECTS(grid_district.geom,sector3.geom)
GROUP BY grid_district.id, grid_district.geom, load_area_id

UNION

-- agricultural
SELECT (ST_DUMP(ST_INTERSECTION(ST_UNION(sector4.geom),grid_district.geom))).geom AS geom, grid_district.id AS grid_district_id, grid_district.load_area_id AS load_area_id, 'agricultural' AS sector
FROM 	calc_ego_loads.urban_sector_per_grid_district_4_agricultural AS sector4,
	calc_ego_grid_district.ego_deu_lv_grid_district AS grid_district
WHERE ST_INTERSECTS(grid_district.geom,sector4.geom)
GROUP BY grid_district.id, grid_district.geom, load_area_id;

-- Gebiete ohne OSM-Tagging
INSERT INTO calc_ego_grid_district.ego_deu_grid_district_sectors (geom,grid_district_id,load_area_id, sector)

SELECT ST_MULTI(ST_DIFFERENCE(districts.geom::geometry(POLYGON,3035),ST_MULTI(ST_UNION (sectors.geom)))) AS geom, districts.id, districts.load_area_id, 'no sector'
FROM calc_ego_grid_district.ego_deu_grid_district_sectors AS sectors,
	calc_ego_grid_district.ego_deu_lv_grid_district AS districts
WHERE districts.id = sectors.grid_district_id
	
GROUP BY districts.geom,districts.id,districts.load_area_id;


	
-- Lösche ungültige Geometrien
DELETE FROM calc_ego_grid_district.ego_deu_grid_district_sectors
WHERE ST_geometrytype(geom) = 'ST_GeometryCollection';


-- Füge Einwohnerzahl hinzu

UPDATE	calc_ego_grid_district.ego_deu_grid_district_sectors AS a
SET population = (SELECT population FROM(
			SELECT SUM(pts.population) AS population, sectors.id AS id
				FROM 	orig_destatis.zensus_population_per_ha AS pts, 
					calc_ego_grid_district.ego_deu_grid_district_sectors AS sectors
				WHERE ST_CONTAINS(sectors.geom,pts.geom)
					AND pts.population > 0
				GROUP BY sectors.id
			) AS b
		WHERE a.id = b.id);

UPDATE	calc_ego_grid_district.ego_deu_grid_district_sectors AS a
SET population = 0 WHERE population IS NULL;

-- Füge Fläche [ha] hinzu
UPDATE calc_ego_grid_district.ego_deu_grid_district_sectors AS sectors
SET area_ha =  ST_AREA(geom)*0.0001;

-- Füge Einwohnerdichte hinzu
UPDATE calc_ego_grid_district.ego_deu_grid_district_sectors AS sectors
SET pop_density =  population/area_ha
WHERE area_ha > 0;

-- Berechne Spitzenlast der Gebiete mit 2 verschiedenen Methoden

-- Methode 1: nach Fläche gewichtete Lastgebietsspitzenlasten

UPDATE calc_ego_grid_district.ego_deu_grid_district_sectors AS b
SET peak_load_1 =  (SELECT a.peak_load AS peak_load 
	FROM(SELECT (ST_AREA(sectors.geom) / ((l_area.sector_area_residential)* 10000)) * (peak.residential* 1000000)   AS peak_load, sectors.id 

		FROM calc_ego_grid_district.ego_deu_grid_district_sectors AS sectors,
				calc_ego_loads.ego_deu_load_area AS l_area,
				calc_ego_loads.calc_ego_peak_load AS peak

		WHERE sectors.sector = 'residential'
			AND l_area.id = sectors.load_area_id
			AND peak.id = l_area.id
			AND l_area.sector_area_residential > 0
			AND peak.residential > 0
			

		UNION

		SELECT (ST_AREA(sectors.geom) / ((l_area.sector_area_agricultural)* 10000)) * (peak.agricultural* 1000000) AS peak_load, sectors.id 

		FROM calc_ego_grid_district.ego_deu_grid_district_sectors AS sectors,
				calc_ego_loads.ego_deu_load_area AS l_area,
				calc_ego_loads.calc_ego_peak_load AS peak

		WHERE sectors.sector = 'agricultural'
			AND l_area.id = sectors.load_area_id
			AND peak.id = l_area.id
			AND l_area.sector_area_agricultural > 0
			AND peak.agricultural > 0

		UNION

		SELECT (ST_AREA(sectors.geom) / ((l_area.sector_area_industrial)* 10000)) * (peak.industrial* 1000000) AS peak_load, sectors.id 

		FROM calc_ego_grid_district.ego_deu_grid_district_sectors AS sectors,
				calc_ego_loads.ego_deu_load_area AS l_area,
				calc_ego_loads.calc_ego_peak_load AS peak

		WHERE sectors.sector = 'industrial'
			AND l_area.id = sectors.load_area_id
			AND peak.id = l_area.id
			AND l_area.sector_area_industrial > 0
			AND peak.industrial > 0

		UNION

		SELECT (ST_AREA(sectors.geom) / ((l_area.sector_area_retail)* 10000)) * (peak.retail* 1000000) AS peak_load, sectors.id 
		FROM calc_ego_grid_district.ego_deu_grid_district_sectors AS sectors,
				calc_ego_loads.ego_deu_load_area AS l_area,
				calc_ego_loads.calc_ego_peak_load AS peak

		WHERE sectors.sector = 'retail'
			AND l_area.id = sectors.load_area_id
			AND peak.id = l_area.id
			AND l_area.sector_area_retail > 0
			AND peak.retail > 0)AS a
	WHERE a.id = b.id);
-- Methode 2: Kerber-Formel anhand Einwohnerzahl


-- weniger dicht besiedelte Gebiete
UPDATE calc_ego_grid_district.ego_deu_grid_district_sectors AS b
SET peak_load_2 = (30 *(0.065 + (1-0.065)* (population / 2.1)^(-0.75))) * (population / 2.1) WHERE population > 0 AND pop_density <= 69.5;

-- dichter besiedelte Gebiete
UPDATE calc_ego_grid_district.ego_deu_grid_district_sectors AS b
SET peak_load_2 = (30 *(0.065 + (1-0.065)* (population / 1.9)^(-0.75))) * (population / 1.9) WHERE population > 0 AND pop_density > 69.5;

UPDATE calc_ego_grid_district.ego_deu_grid_district_sectors AS b
SET peak_load_2 = 0 WHERE population = 0;



-------------------------------------------------------
-- back to grid_district table
-------------------------------------------------------


-- Add peak loads

UPDATE calc_ego_grid_district.ego_deu_LV_grid_district AS districts
SET peak_load = (SELECT SUM(peak_load) AS peak_load FROM
			-- Methode 1 für agricultural, industrial und retail-Flächen
			(SELECT peak_load_1 AS peak_load, id, grid_district_id, population, sector 
			FROM calc_ego_grid_district.ego_deu_grid_district_sectors
			WHERE sector = 'agricultural' OR sector = 'industrial' OR sector = 'retail'

			UNION
			-- Methode 2 für residential- und unklassifizierte Flächen
			SELECT peak_load_2 AS peak_load, id, grid_district_id, population, sector 
			FROM calc_ego_grid_district.ego_deu_grid_district_sectors
			WHERE sector = 'residential' OR sector = 'no sector' 
			) AS a
		WHERE districts.id = a.grid_district_id

		GROUP BY a.grid_district_id)
 ;




UPDATE calc_ego_grid_district.ego_deu_LV_grid_district AS districts
SET area_ha =  ST_AREA(geom)*0.0001;

-- Add population_density
UPDATE calc_ego_grid_district.ego_deu_LV_grid_district AS districts
SET pop_density =  population/area_ha;

-- Add structure type

UPDATE calc_ego_grid_district.ego_deu_LV_grid_district AS districts
SET structure_type = 'rural'
WHERE pop_density >= 0
	AND pop_density <= 33;

UPDATE calc_ego_grid_district.ego_deu_LV_grid_district AS districts
SET structure_type = 'urban'
WHERE pop_density > 33;
	

----- Delete auxilliary tables

DROP TABLE IF EXISTS calc_ego_grid_district.ego_deu_LV_grid_districts_voronoi;
DROP TABLE IF EXISTS calc_ego_grid_district.ego_deu_LV_cut;
DROP TABLE IF EXISTS calc_ego_grid_district.ego_deu_LV_grid_district_withoutpop;
DROP TABLE IF EXISTS calc_ego_grid_district.ego_deu_grid_district_sectors;

-- Set comment on table
COMMENT ON TABLE calc_ego_grid_district.ego_deu_lv_grid_district IS
'{
"Name": "eGo data processing - ego_deu_lv_grid_district",
"Source": [{
                  "Name": "open_eGo",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "2016-10-12",
"Original file": "process_eGo_lv_grid_districts.sql",
"Spatial resolution": ["germany"],
"Description": ["eGo data processing modeling of LV grid districts"],

"Column": [
                {"Name": "id",
                "Description": "Unique identifier",
                "Unit": "" },
				
				{"Name": "geom",
                "Description": "Geometry",
                "Unit": "" },
				
				{"Name": "load_area_id",
                "Description": "ID of the corresponding load area",
                "Unit": "" },
				
				{"Name": "population",
                "Description": "number of residents in the district",
                "Unit": "residents" },

                		{"Name": "peak_load",
                "Description": "estimated peak_load in the district",
                "Unit": "kW" },

                              	{"Name": "area_ha",
                "Description": "area of the the district",
                "Unit": "ha" },

                                {"Name": "pop_density",
                "Description": "population density in the district",
                "Unit": "residents/ha" },

                                {"Name": "structure_type",
                "Description": "structure type of the the district (urban, rural)",
                "Unit": "" }],


"Changes":[
                {"Name": "Jonas Gütter",
                "Mail": "jonas.guetter@rl-institut.de",
                "Date":  "20.10.2016",
                "Comment": "Created table" }],

"ToDo": [""],
"Licence": ["tba"],
"Instructions for proper use": [""]
}'; 

-- Select description
SELECT obj_description('calc_ego_grid_district.ego_deu_lv_grid_district'::regclass)::json;

-- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.1' AS version,
	'model_draft' AS schema_name,
	'ego_deu_lv_grid_district' AS table_name,
	'process_eGo_lv_grid_districts.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.table;