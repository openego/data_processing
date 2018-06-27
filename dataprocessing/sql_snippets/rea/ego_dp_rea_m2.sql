/*
M2 wind farms
Allocates "wind" turbines with voltage level 4 to WPA as wind farms.
The rest could not be allocated, consider in M3.

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','input','model_draft','ego_dp_supply_res_powerplant','ego_dp_rea_m2.sql',' ');
 
-- MView M2
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m2_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m2_a_mview AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		ST_TRANSFORM(geom,3035) AS geom,
		rea_flag
	FROM 	model_draft.ego_dp_supply_res_powerplant AS dea
	WHERE 	(dea.voltage_level = 4 AND 
		dea.generation_type = 'wind')
		AND (dea.flag in ('commissioning','constantly') 
		AND dea.generation_subtype not in ('wind_offshore'));

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m2_a_mview_geom_idx
	ON model_draft.ego_supply_rea_m2_a_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m2_a_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','temp','model_draft','ego_supply_rea_m2_a_mview','ego_dp_rea_m2.sql',' ');


-- rea_flag M2
UPDATE 	model_draft.ego_dp_supply_res_powerplant AS dea
	SET	rea_flag = 'M2_rest'
	WHERE	dea.voltage_level = 4 AND 
		dea.generation_type = 'wind'
		AND (dea.flag in ('commissioning','constantly') 
		AND dea.generation_subtype not in ('wind_offshore'));


-- get windfarms   (OK!) -> 485.000ms =317
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m2_windfarm CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m2_windfarm (
	farm_id serial,
	subst_id integer,
	area_ha decimal,
	dea_cnt integer,
	electrical_capacity_sum numeric,
	rea_geom_new geometry(Polygon,3035),
	rea_geom_line geometry(LineString,3035),
	geom geometry(Polygon,3035),
	CONSTRAINT ego_supply_rea_m2_windfarm_pkey PRIMARY KEY (farm_id));

-- insert data (windfarm)
INSERT INTO model_draft.ego_supply_rea_m2_windfarm (area_ha,geom)
	SELECT	ST_AREA(farm.geom_farm),
		farm.geom_farm
	FROM	(SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
				ST_BUFFER(ST_TRANSFORM(dea.geom,3035), 1000)
			)))).geom ::geometry(Polygon,3035) AS geom_farm
		FROM 	model_draft.ego_dp_supply_res_powerplant AS dea
		WHERE 	(dea.voltage_level = 4) AND
			(dea.generation_type = 'wind')
			AND (dea.flag in ('commissioning','constantly') 
		AND dea.generation_subtype not in ('wind_offshore'))
		) AS farm;

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m2_windfarm_geom_idx
	ON model_draft.ego_supply_rea_m2_windfarm USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m2_windfarm OWNER TO oeuser;

-- update subst_id from grid_district
UPDATE 	model_draft.ego_supply_rea_m2_windfarm AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	farm.farm_id AS farm_id,
			gd.subst_id AS subst_id
		FROM	model_draft.ego_supply_rea_m2_windfarm AS farm,
			model_draft.ego_grid_mv_griddistrict AS gd
		WHERE  	gd.geom && ST_CENTROID(farm.geom) AND
			ST_CONTAINS(gd.geom,ST_CENTROID(farm.geom))
		) AS t2
	WHERE  	t1.farm_id = t2.farm_id;

-- update wind farm data
UPDATE 	model_draft.ego_supply_rea_m2_windfarm AS t1
	SET  	dea_cnt = t2.dea_cnt,
		electrical_capacity_sum = t2.electrical_capacity_sum
	FROM    (
		SELECT	farm.farm_id AS farm_id,
			COUNT(dea.geom) AS dea_cnt,
			SUM(dea.electrical_capacity) AS electrical_capacity_sum
		FROM	model_draft.ego_dp_supply_res_powerplant AS dea,
			model_draft.ego_supply_rea_m2_windfarm AS farm
		WHERE  	(dea.voltage_level = 4 AND
			dea.generation_type = 'wind') 
			AND (dea.flag in ('commissioning','constantly') 
		        AND dea.generation_subtype not in ('wind_offshore')) 
		        AND (farm.geom && dea.geom AND ST_CONTAINS(farm.geom,dea.geom))
		GROUP BY farm.farm_id
		) AS t2
	WHERE  	t1.farm_id = t2.farm_id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','temp','model_draft','ego_supply_rea_m2_windfarm','ego_dp_rea_m2.sql',' ');

-- update DEA in wind farms
UPDATE 	model_draft.ego_dp_supply_res_powerplant AS t1
	SET  	rea_sort = t2.farm_id   -- temporary store farm_id in rea_sort!
	FROM    (
		SELECT	dea.id AS id,
			farm.farm_id AS farm_id
		FROM	model_draft.ego_dp_supply_res_powerplant AS dea,
			model_draft.ego_supply_rea_m2_windfarm AS farm
		WHERE  	(dea.voltage_level = 4 AND
			dea.generation_type = 'wind') 
			AND (dea.flag in ('commissioning','constantly') 
			AND dea.generation_subtype not in ('wind_offshore')) 
			AND (farm.geom && dea.geom AND ST_CONTAINS(farm.geom,dea.geom))
		) AS t2
	WHERE  	t1.id = t2.id;


-- temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m2_farm_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m2_farm_temp (
	rea_sorted bigint NOT NULL,
	farm_id bigint NOT NULL,
	subst_id integer,
	area_ha numeric,
	dea_cnt integer,
	electrical_capacity_sum numeric,
	rea_geom_new geometry(Point,3035),
	rea_geom_line geometry(LineString,3035),
	geom geometry(Polygon,3035),
	rea_flag character varying,
	CONSTRAINT ego_supply_rea_m2_farm_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m2_farm_temp_geom_idx
	ON model_draft.ego_supply_rea_m2_farm_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','temp','model_draft','ego_supply_rea_m2_farm_temp','ego_dp_rea_m2.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m2_wpa_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m2_wpa_temp (
	rea_sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_supply_rea_m2_wpa_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m2_wpa_temp_geom_idx
	ON model_draft.ego_supply_rea_m2_wpa_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','temp','model_draft','ego_supply_rea_m2_wpa_temp','ego_dp_rea_m2.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m2_jnt_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m2_jnt_temp (
	rea_sorted bigint NOT NULL,
	farm_id bigint,
	subst_id integer,
	rea_geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_supply_rea_m2_jnt_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m2_jnt_temp_geom_idx
	ON model_draft.ego_supply_rea_m2_jnt_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','temp','model_draft','ego_supply_rea_m2_jnt_temp','ego_dp_rea_m2.sql',' ');

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','input','model_draft','ego_supply_wpa_per_mvgd','ego_dp_rea_m2.sql',' ');


-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3591	-- subst_id
	LOOP
        EXECUTE '
		INSERT INTO model_draft.ego_supply_rea_m2_farm_temp
			SELECT	row_number() over (ORDER BY farm.dea_cnt DESC)as rea_sorted,
				farm.*
			FROM 	model_draft.ego_supply_rea_m2_windfarm AS farm
			WHERE 	farm.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_supply_rea_m2_wpa_temp
			SELECT 	row_number() over (ORDER BY wpa.area_ha DESC)as rea_sorted,
				wpa.*
			FROM 	model_draft.ego_supply_wpa_per_mvgd AS wpa
			WHERE 	wpa.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_supply_rea_m2_jnt_temp
			SELECT	farm.rea_sorted,
				farm.farm_id,
				farm.subst_id,
				ST_MAKELINE(ST_CENTROID(farm.geom),ST_PointOnSurface(wpa.geom)) ::geometry(LineString,3035) AS rea_geom_line,
				ST_PointOnSurface(wpa.geom) ::geometry(Point,3035) AS geom	-- NEW LOCATION!
			FROM	model_draft.ego_supply_rea_m2_farm_temp AS farm
			INNER JOIN model_draft.ego_supply_rea_m2_wpa_temp AS wpa ON (farm.rea_sorted = wpa.rea_sorted);

		UPDATE 	model_draft.ego_dp_supply_res_powerplant AS t1
			SET  	rea_geom_new = t2.rea_geom_new,
				rea_geom_line = t2.rea_geom_line,
				rea_flag = ''M2''
			FROM	(SELECT	m.farm_id AS farm_id,
					m.rea_geom_line,
					m.geom AS rea_geom_new
				FROM	model_draft.ego_supply_rea_m2_jnt_temp AS m
				)AS t2
			WHERE  	t1.rea_sort = t2.farm_id;

		TRUNCATE TABLE model_draft.ego_supply_rea_m2_farm_temp, model_draft.ego_supply_rea_m2_wpa_temp, model_draft.ego_supply_rea_m2_jnt_temp;
		';
	END LOOP;
END;
$$;

-- M2 result
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m2_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m2_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_dp_supply_res_powerplant AS dea
	WHERE	rea_flag = 'M2';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m2_mview_geom_idx
	ON model_draft.ego_supply_rea_m2_mview USING gist (geom);

-- create index GIST (rea_geom_line)
CREATE INDEX ego_supply_rea_m2_mview_rea_geom_line_idx
	ON model_draft.ego_supply_rea_m2_mview USING gist (rea_geom_line);

-- create index GIST (rea_geom_new)
CREATE INDEX ego_supply_rea_m2_mview_rea_geom_new_idx
	ON model_draft.ego_supply_rea_m2_mview USING gist (rea_geom_new);	

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m2_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','output','model_draft','ego_supply_rea_m2_mview','ego_dp_rea_m2.sql',' ');


-- M2 rest
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m2_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m2_rest_mview AS
	SELECT 	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		rea_flag
	FROM	model_draft.ego_dp_supply_res_powerplant AS dea
	WHERE	rea_flag = 'M2_rest';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m2_rest_mview_geom_idx
	ON model_draft.ego_supply_rea_m2_rest_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m2_rest_mview OWNER TO oeuser;	

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','output','model_draft','ego_supply_rea_m2_rest_mview','ego_dp_rea_m2.sql',' ');


-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m2_farm_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m2_wpa_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m2_jnt_temp CASCADE;

DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m2_a_mview CASCADE;
-- DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m2_windfarm CASCADE;
