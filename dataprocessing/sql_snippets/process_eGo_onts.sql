-- (08:30 min)

CREATE OR REPLACE FUNCTION ST_CreateFishnet(
        nrow integer, ncol integer,
        xsize float8, ysize float8,
        x0 float8 DEFAULT 0, y0 float8 DEFAULT 0,
        
        OUT geom geometry)
    RETURNS SETOF geometry AS
$$
SELECT ST_Translate(cell, j * $3 + $5, i * $4 + $6) AS geom
FROM generate_series(0, $1 - 1) AS i,
     generate_series(0, $2 - 1) AS j,
(
SELECT ('POLYGON((0 0, 0 '||$4||', '||$3||' '||$4||', '||$3||' 0,0 0))')::geometry AS cell
) AS foo;
$$ LANGUAGE sql IMMUTABLE STRICT;


CREATE TABLE IF NOT EXISTS model_draft."ego_grid_lv_ontgrids"
(
  id serial NOT NULL,
  geom geometry(Polygon,3035),
  load_area_id integer,
  CONSTRAINT ego_grid_lv_ontgrids_pkey PRIMARY KEY (id)
);

TRUNCATE TABLE  model_draft."ego_grid_lv_ontgrids";
INSERT INTO model_draft."ego_grid_lv_ontgrids" (geom, load_area_id)

-- Erstelle ein Gitternetz auf der bbox der Lastgebiete:

	
	SELECT 
	-- Normalfall: mehrere Zellen pro Grid
	CASE WHEN ST_AREA (geom) > (3.1415926535 * 1152) THEN

	ST_SETSRID(ST_CREATEFISHNET(
		ROUND((ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))) /319)::integer,
		ROUND((ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))) /319)::integer,
		319,
		319,
		ST_xmin (box2d(geom)),
		ST_ymin (box2d(geom))
	),3035)::geometry(POLYGON,3035)  


	-- Spezialfall: bei kleinene Lastgebieten erstelle nur eine Zelle
	ELSE
	
	ST_SETSRID(ST_CREATEFISHNET(
		1,
		1,
		(ST_ymax(box2d(geom)) -  ST_ymin(box2d(geom))),
		(ST_xmax(box2d(geom)) -  ST_xmin(box2d(geom))),
		ST_xmin (box2d(geom)),
		ST_ymin (box2d(geom))
	),3035)::geometry(POLYGON,3035) 

	END AS geom, area.id AS load_area_id

FROM model_draft."ego_demand_loadarea" AS area INNER JOIN model_draft."ego_demand_load_area_peak_load" AS peak_load ON peak_load.id = area.id;



CREATE TABLE IF NOT EXISTS model_draft."ego_grid_mvlv_substation"
(
  geom geometry(Point,3035),
  id serial NOT NULL,
  is_dummy boolean,
  subst_id integer,
  load_area_id integer,
  CONSTRAINT ego_grid_mvlv_substation_pkey PRIMARY KEY (id)
);
  
TRUNCATE TABLE model_draft."ego_grid_mvlv_substation";
INSERT INTO model_draft."ego_grid_mvlv_substation" (geom, load_area_id)

-- Bestimme diejenigen Mittelpunkte der Grid-Polygone, die innerhalb der Lastgebiete liegen:
SELECT DISTINCT ST_CENTROID (grids.geom)::geometry(POINT,3035) AS geom, area.id AS load_area_id
FROM model_draft."ego_grid_lv_ontgrids" AS grids, model_draft."ego_demand_loadarea" AS area
WHERE ST_WITHIN(ST_CENTROID (grids.geom),area.geom)
	AND area.id = grids.load_area_id;

-- Füge den Lastgebieten, die aufgrund ihrer geringen Fläche keine ONTs zugeordnet bekommen haben, ihren Mittelpunkt als ONT-STandort hinzu: (01:54 min)
INSERT INTO model_draft."ego_grid_mvlv_substation" (geom, load_area_id)

SELECT
CASE WHEN ST_CONTAINS (geom,ST_CENTROID(area_without_ont.geom)) THEN 

ST_CENTROID(area_without_ont.geom)

ELSE

ST_POINTONSURFACE(area_without_ont.geom)

END, area_without_ont.id 

FROM

	(SELECT geom, id
	FROM model_draft."ego_demand_loadarea"
	EXCEPT
	SELECT l_area.geom AS geom, l_area.id
	FROM model_draft."ego_demand_loadarea" AS l_area, model_draft."ego_grid_mvlv_substation" AS ont
	WHERE ST_CONTAINS (l_area.geom, ont.geom)
	GROUP BY (l_area.id))
	AS area_without_ont
;

	
-- Lege Buffer um ONT-STandorte und ermittle die Teile der Lastgebiete, die sich nicht innerhalb dieser Buffer befinden
CREATE TABLE IF NOT EXISTS model_draft."ego_grid_lv_loadarearest"
(
  id serial NOT NULL,
  geom geometry(Polygon,3035),
  load_area_id integer NOT NULL,
  CONSTRAINT ego_grid_lv_loadarearest_pkey PRIMARY KEY (id)
);

TRUNCATE TABLE model_draft."ego_grid_lv_loadarearest";
INSERT INTO model_draft."ego_grid_lv_loadarearest" (geom, load_area_id)

SELECT (ST_DUMP(ST_DIFFERENCE(load_area.geom, area_with_onts.geom))).geom::geometry(Polygon,3035) AS geom, load_area.id AS load_area_id

FROM
	(SELECT ST_BUFFER(ST_UNION(onts.geom),576) AS geom,l_area.id AS id
	FROM model_draft.ego_grid_mvlv_substation AS onts, model_draft.ego_demand_loadarea AS l_area
	WHERE ST_CONTAINS (l_area.geom,onts.geom) AND (l_area.geom && onts.geom)
	GROUP BY l_area.id) AS area_with_onts

	INNER JOIN

	model_draft.ego_demand_loadarea AS load_area

	ON (load_area.id = area_with_onts.id )

WHERE  ST_AREA(ST_DIFFERENCE(load_area.geom, area_with_onts.geom)) > 0;


  
-- Bestimme die Mittelpunkte der Gebiete, die noch nicht durch ONT abgedeckt sind, und lege diese Mittelpunkte als ONT-Standorte fest
INSERT INTO model_draft.ego_grid_mvlv_substation (geom, load_area_id)
SELECT ST_CENTROID(geom)::geometry(POINT,3035), load_area_id FROM model_draft."ego_grid_lv_loadarearest"
;


-- Setze dummy-flag auf false für alle erzeugten ONTs
UPDATE model_draft."ego_grid_mvlv_substation" 
SET is_dummy = FALSE;

-- Füge Information für die substation_id hinzu

UPDATE 	model_draft."ego_grid_mvlv_substation" AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	ont.id AS id,
		gd.subst_id AS subst_id
	FROM	model_draft."ego_grid_mvlv_substation" AS ont,
		calc_ego_grid_district."model_draft.ego_grid_mv_griddistrict" AS gd
	WHERE  	gd.geom && ont.geom AND
		ST_CONTAINS(gd.geom,ont.geom)
	) AS t2
WHERE  	t1.id = t2.id;

-- Lösche Hilfstabellen 

DROP TABLE IF EXISTS model_draft."ego_grid_lv_ontgrids";
DROP TABLE IF EXISTS model_draft."ego_grid_lv_loadarearest";

-- Set comment on table
COMMENT ON TABLE model_draft."ego_grid_mvlv_substation" IS
'{
"Name": "eGo data processing - ego_grid_mvlv_substation",
"Source": [{
                  "Name": "open_eGo",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "2016-10-12",
"Original file": "process_eGo_onts.sql",
"Spatial resolution": ["germany"],
"Description": ["eGo data processing modeling of ONTs"],

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
				
				{"Name": "subst_id",
                "Description": "ID of the corresponding MV substation",
                "Unit": "" },

                				{"Name": "is_dummy",
                "Description": "True if the entry is a dummy entry",
                "Unit": "" }],

"Changes":[
                {"Name": "Jonas Gütter",
                "Mail": "jonas.guetter@rl-institut.de",
                "Date":  "20.10.2016",
                "Comment": "Created table" },
				{"Name": "Jonas Gütter",
                "Mail": "jonas.guetter@rl-institut.de",
                "Date":  "27.10.2016",
                "Comment": "Changed table names" }],

"ToDo": [""],
"Licence": ["tba"],
"Instructions for proper use": [""]
}'; 

-- Select description
SELECT obj_description('model_draft.ego_grid_mvlv_substation'::regclass)::json;

-- Add entry to scenario logtable
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
SELECT	'0.2' AS version,
	'model_draft' AS schema_name,
	'ego_grid_mvlv_substation' AS table_name,
	'process_eGo_onts.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	model_draft.table;