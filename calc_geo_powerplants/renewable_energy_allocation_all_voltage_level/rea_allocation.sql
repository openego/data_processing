/* Reinvent the wheel again

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"


*/

-- 
-- DROP SCHEMA draft_ego_rea;

CREATE SCHEMA draft_ego_rea
  AUTHORIZATION oeuser;

GRANT ALL ON SCHEMA draft_ego_rea TO oeuser WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES IN SCHEMA draft_ego_rea
    GRANT INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLES
    TO oeuser;

ALTER DEFAULT PRIVILEGES IN SCHEMA draft_ego_rea
    GRANT SELECT, UPDATE, USAGE ON SEQUENCES
    TO oeuser;

ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_substation
    GRANT EXECUTE ON FUNCTIONS
    TO oeuser;
---




DROP TABLE IF EXISTS draft_ego_rea.ego_supply_rea_rtwa CASCADE;

CREATE TABLE draft_ego_rea.ego_supply_rea_rtwa (
	scn_name varchar,
	id bigint,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level smallint,
	source character varying,
	subst_id bigint,
	flag character varying,
	geom geometry(Point,3035),
	geom_line geometry(LineString,3035),
	geom_new geometry(Point,3035),
	PRIMARY KEY (scn_name, id));

INSERT INTO draft_ego_rea.ego_supply_rea_rtwa (scn_name, id, electrical_capacity, generation_type, generation_subtype, voltage_level, source, geom)
	SELECT	'Status Quo' as scn_name,
		id,
		electrical_capacity, 
		generation_type, 
		generation_subtype, 
		voltage_level, 
		source, 
		ST_TRANSFORM(geom,3035)
	FROM	supply.ego_renewable_powerplant
	WHERE	geom IS NOT NULL;

CREATE INDEX ON model_draft.ego_supply_rea_rtwa USING gist(geom);
CREATE INDEX ON model_draft.ego_supply_rea_rtwa USING btree(flag);
ALTER TABLE model_draft.ego_supply_rea_rtwa OWNER TO oeuser;

-- SETTING NEW SUBST_ID & GEOM FOR OUT OF MV-GDs EXCEPT OFFSHORE

UPDATE model_draft.ego_supply_rea_rtwa A
	SET subst_id = GD.subst_id 
		FROM model_draft.ego_grid_mv_griddistrict GD
		WHERE ST_Intersects(GD.geom, A.geom);

UPDATE model_draft.ego_supply_rea_rtwa
SET flag =
	CASE 	WHEN subst_id IS NULL AND generation_type = 'wind' AND generation_subtype = 'wind_offshore'	THEN 'offshore'
		WHEN subst_id IS NULL 										THEN 'out'    
	END;

UPDATE model_draft.ego_supply_rea_rtwa REA
	SET 	subst_id = SQ.subst_id,
		geom_new = SQ.geom,
		geom_line = ST_MAKELINE(REA.geom, SQ.geom)
		FROM (
			SELECT DISTINCT ON (A.id) A.id, B.subst_id, B.geom 
			FROM model_draft.ego_supply_rea_rtwa A, model_draft.ego_grid_hvmv_substation B
			WHERE flag = 'out' AND ST_DWithin(A.geom, B.geom, 100000)
			ORDER BY A.id, ST_distance(A.geom, B.geom)) SQ
		WHERE REA.id = SQ.id;

-- PREPARE OSM LAYER
--TODO: Does this have to be a table? Maybe a mview would be sufficient?
DROP TABLE IF EXISTS model_draft.ego_osm_agriculture_per_mvgd_rtwa CASCADE;

CREATE TABLE model_draft.ego_osm_agriculture_per_mvgd_rtwa (
	id serial,
	subst_id int,
	area_ha numeric,
	geom geometry(Polygon,3035),
	PRIMARY KEY (id));

INSERT INTO model_draft.ego_osm_agriculture_per_mvgd_rtwa (subst_id, area_ha, geom)
	Select 	GD.subst_id, 
		ST_AREA(OSM.geom) / 10000, 
		OSM.geom from 
	model_draft.ego_grid_mv_griddistrict GD,
	model_draft.ego_osm_sector_per_griddistrict_4_agricultural OSM
	Where ST_CONTAINS(GD.geom, OSM.geom)

CREATE INDEX ON model_draft.ego_osm_agriculture_per_mvgd_rtwa USING gist(geom);
ALTER TABLE model_draft.ego_osm_agriculture_per_mvgd_rtwa OWNER TO oeuser;
 

-- APPLYING METHODS

	-- POPULATE FLAGS
	
UPDATE model_draft.ego_supply_rea_rtwa
	SET flag = 
		CASE 	WHEN (generation_type = 'biomass' OR generation_type = 'gas') AND (voltage_level IN (4,5,6,7)) OR voltage_level IS NULL  	THEN 'M1-1 rest'
			WHEN generation_subtype = 'solar_roof_mounted' AND voltage_level IN (4,5)			 				THEN 'M1-2 rest'
			WHEN subst_id IS NULL AND generation_type = 'wind' AND generation_subtype = 'wind_offshore'					THEN 'offshore'
			WHEN generation_type = 'wind' AND voltage_level = 4										THEN 'M2 rest'
			WHEN generation_type = 'wind' AND voltage_level IN (5,6)									THEN 'M3 rest'
			ELSE flag    
		END


DO
$BODY$
BEGIN
FOREACH r in {'Status Quo', '', ''}:
	where scn_name = r

-- M1-1
--TODO: Need a check for data loss on inner join imo and way to handle it -- M4 ?! Also maybe better solution with LATERAL JOIN.

WITH osm_sorted AS (
	SELECT 
	subst_id,
	ST_CENTROID(geom) as geom, 
	row_number() OVER (PARTITION BY subst_id ORDER BY area_ha DESC) AS sorted
	FROM model_draft.ego_osm_agriculture_per_mvgd_rtwa
     ), supply_rea_sorted AS (
	SELECT 
	id, 
	subst_id,
	row_number() OVER (PARTITION BY subst_id ORDER BY electrical_capacity DESC) AS sorted
	--scn_name
	FROM model_draft.ego_supply_rea_rtwa 
	WHERE flag = 'M1-1 rest' -- AND scn_name = var
     )
UPDATE model_draft.ego_supply_rea_rtwa REA
	SET 	geom_new = SQ.geom,
		geom_line = ST_MAKELINE(REA.geom, SQ.geom),
		flag = 'M1-1'
FROM (osm_sorted JOIN supply_rea_sorted USING (subst_id, sorted)) SQ
WHERE SQ.id = REA.id; -- AND scn_name = var

-- M1-2

WITH osm_sorted AS (
	SELECT 
	subst_id,
	ST_CENTROID(geom) as geom, 
	row_number() OVER (PARTITION BY subst_id ORDER BY area_ha DESC) AS sorted
	FROM model_draft.ego_osm_agriculture_per_mvgd_rtwa
     ), supply_rea_sorted AS (
	SELECT 
	id, 
	subst_id,
	row_number() OVER (PARTITION BY subst_id ORDER BY electrical_capacity DESC) AS sorted
	--scn_name
	FROM model_draft.ego_supply_rea_rtwa 
	WHERE flag = 'M1-2 rest' -- AND scn_name = var
     )
UPDATE model_draft.ego_supply_rea_rtwa REA
	SET 	geom_new = SQ.geom,
		geom_line = ST_MAKELINE(REA.geom, SQ.geom),
		flag = 'M1-2'
FROM (osm_sorted JOIN supply_rea_sorted USING (subst_id, sorted)) SQ
WHERE SQ.id = REA.id; -- AND scn_name = var

-- M2
--TODO: Single purpose TABLE. Maybe we can use TEMP TABLES. This should be more readable. Maybe split first in two.

DROP TABLE IF EXISTS model_draft.ego_supply_rea_m2_temp CASCADE;
CREATE TABLE model_draft.ego_supply_rea_m2_temp AS
	WITH g (geom) AS (
	SELECT 
	(ST_DUMP(ST_MULTI(ST_UNION(ST_BUFFER(geom, 1000))))).geom ::geometry(Polygon, 3035)
	FROM model_draft.ego_supply_rea_rtwa
	-- and scn_name = 'Status Quo'
	WHERE flag = 'M2 rest'
        )
SELECT
array_agg(id) as ids,
NULL::bigint AS subst_id,
g.geom
FROM model_draft.ego_supply_rea_rtwa REA, g
WHERE ST_contains(g.geom, REA.geom) AND flag = 'M2 rest' -- and scn_name = 'Status Quo'
GROUP BY g.geom;
	
UPDATE model_draft.ego_supply_rea_m2_temp T
	SET subst_id = GD.subst_id
	FROM
	model_draft.ego_grid_mv_griddistrict GD
	WHERE ST_CONTAINS(GD.geom, ST_CENTROID(T.geom)); -- and scn_name = 'Status Quo'

WITH farm_sorted AS (
	SELECT 
	ids,
	subst_id, 
	row_number() OVER (PARTITION BY subst_id ORDER BY array_length(ids, 1) DESC) AS sorted,
	geom AS farm_geom
	FROM model_draft.ego_supply_rea_m2_temp
     ),	wpa_sorted AS (
	SELECT
	subst_id, geom AS wpa_geom, row_number() OVER (PARTITION BY subst_id ORDER BY area_ha DESC) AS sorted
	FROM model_draft.ego_supply_wpa_per_mvgd)
UPDATE model_draft.ego_supply_rea_rtwa REA
	SET	geom_new = ST_PointOnSurface(SQ.wpa_geom),
		geom_line = ST_MAKELINE(ST_CENTROID(SQ.farm_geom),ST_PointOnSurface(SQ.wpa_geom)),
		flag = 'M2'
	FROM (SELECT *, unnest(ids) AS id FROM wpa_sorted JOIN farm_sorted USING (subst_id, sorted)) SQ
	WHERE REA.id = SQ.id -- and scn_name = 'Status Quo'

-- M3
-- TODO: Takes a while. Maybe BTree on ego_lattice_500m increases performance.

WITH points_on_wpa AS (
	SELECT
	area_type,  
	geom, 
	subst_id, 
	row_number() OVER (PARTITION BY subst_id) AS rn 
	FROM model_draft.ego_lattice_500m 
	WHERE area_type = 'wpa' 
     ), supply_rea_random AS (
	SELECT  
	id, flag,
	subst_id, 
	row_number() OVER (PARTITION BY subst_id ORDER BY RANDOM()) AS rn 
	FROM model_draft.ego_supply_rea_rtwa 
	WHERE (flag = 'M3 rest' OR flag = 'M2 rest')
	-- AND scn_name =
	)		
UPDATE model_draft.ego_supply_rea_rtwa REA
	SET 	geom_new = SQ.geom,
		geom_line = ST_MAKELINE(REA.geom, SQ.geom),
		flag = 'M3'
FROM (points_on_wpa JOIN supply_rea_random USING (subst_id, rn)) SQ
WHERE SQ.id = REA.id; -- AND scn_name = var

-- M4

	-- POPULATE FLAG

UPDATE model_draft.ego_supply_rea_rtwa
	SET flag = 'M4 rest'
	WHERE 	voltage_level IN (4,5)
		AND ((generation_type = 'solar' AND generation_subtype IS NULL) OR generation_subtype = 'solar_ground_mounted')
	OR (generation_type = 'wind' AND voltage_level IS NULL)
	OR flag in ('M1-1 rest', 'M1-2 rest', 'M3 rest') AND subst_id IS NOT NULL;
	

WITH points_out_of_wpa AS (
	SELECT
	area_type,  
	geom, 
	subst_id, 
	row_number() OVER (PARTITION BY subst_id) AS rn 
	FROM model_draft.ego_lattice_500m 
	WHERE area_type = 'out' 
     ), supply_rea_random AS (
	SELECT  
	id, flag,
	subst_id, 
	row_number() OVER (PARTITION BY subst_id ORDER BY RANDOM()) AS rn 
	FROM model_draft.ego_supply_rea_rtwa 
	WHERE 'M4 rest'
	-- AND scn_name =
	)		
UPDATE model_draft.ego_supply_rea_rtwa REA
	SET 	geom_new = SQ.geom,
		geom_line = ST_MAKELINE(REA.geom, SQ.geom),
		flag = 'M4'
FROM (points_out_of_wpa JOIN supply_rea_random USING (subst_id, rn)) SQ
WHERE SQ.id = REA.id; -- AND scn_name = var


-- M5

	-- POPULATE FLAG
	
UPDATE 	model_draft.ego_supply_rea
	SET flag = 'M5 rest'
	WHERE 	(voltage_level IN (6,7) OR voltage_level IS NULL)
		AND generation_type = 'solar'
	OR (voltage_level = 7 AND generation_type = 'wind')
	AND subst_id IS NOT NULL;


WITH points_on_wpa AS (
	SELECT
	area_type,  
	geom, 
	subst_id, 
	row_number() OVER (PARTITION BY subst_id) AS rn 
	FROM model_draft.ego_lattice_50m 
	WHERE area_type = 'la' 
     ), supply_rea_random AS (
	SELECT  
	id, flag,
	subst_id, 
	row_number() OVER (PARTITION BY subst_id ORDER BY RANDOM()) AS rn 
	FROM model_draft.ego_supply_rea_rtwa 
	WHERE 'M5 rest'
	-- AND scn_name =
	)		
UPDATE model_draft.ego_supply_rea_rtwa REA
	SET 	geom_new = SQ.geom,
		geom_line = ST_MAKELINE(REA.geom, SQ.geom),
		flag = 'M5'
FROM (points_on_wpa JOIN supply_rea_random USING (subst_id, rn)) SQ
WHERE SQ.id = REA.id; -- AND scn_name = var
