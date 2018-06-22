/*
M3 wind turbines to WPA
Allocates "wind" turbines with voltage levels "5" & "6" to WPA.
Also considers rest of M2.
The rest could not be allocated, consider in M4.

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','input','model_draft','ego_dp_supply_res_powerplant','ego_dp_rea_m3.sql',' ');

-- MView M3
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m3_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m3_a_mview AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		ST_TRANSFORM(geom,3035) AS geom,
		rea_flag
	FROM 	model_draft.ego_dp_supply_res_powerplant AS dea
	WHERE 	(dea.voltage_level = 5 OR 
		dea.voltage_level = 6) AND 
		dea.generation_type = 'wind' OR 
		dea.rea_flag = 'M2_rest' AND
		 (dea.flag in ('commissioning','constantly'))
		AND dea.subst_id IS NOT NULL ;

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m3_a_mview_geom_idx
  ON model_draft.ego_supply_rea_m3_a_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m3_a_mview OWNER TO oeuser;  

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','temp','model_draft','ego_supply_rea_m3_a_mview','ego_dp_rea_m3.sql',' ');


-- rea_flag M3
UPDATE 	model_draft.ego_dp_supply_res_powerplant AS dea
	SET	rea_flag = 'M3_rest'
	WHERE	(dea.voltage_level = 5 OR 
		dea.voltage_level = 6) AND 
		dea.generation_type = 'wind' OR 
		dea.rea_flag = 'M2_rest' AND
		dea.subst_id IS NOT NULL 
		AND (dea.flag in ('commissioning','constantly'));


-- temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m3_dea_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m3_dea_temp (
	rea_sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	rea_flag character varying,
	CONSTRAINT ego_supply_rea_m3_dea_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m3_dea_temp_geom_idx
  ON model_draft.ego_supply_rea_m3_dea_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','temp','model_draft','ego_supply_rea_m3_dea_temp','ego_dp_rea_m3.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m3_grid_wpa_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m3_grid_wpa_temp (
	rea_sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_type text,
	geom geometry(Point,3035),
	CONSTRAINT ego_supply_rea_m3_grid_wpa_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m3_grid_wpa_temp_geom_idx
  ON model_draft.ego_supply_rea_m3_grid_wpa_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','temp','model_draft','ego_supply_rea_m3_grid_wpa_temp','ego_dp_rea_m3.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m3_jnt_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m3_jnt_temp (
	rea_sorted bigint NOT NULL,
	id bigint,
	rea_geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_supply_rea_m3_jnt_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m3_jnt_temp_geom_idx
  ON model_draft.ego_supply_rea_m3_jnt_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','temp','model_draft','ego_supply_rea_m3_jnt_temp','ego_dp_rea_m3.sql',' ');


-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3608	-- subst_id
	LOOP
        EXECUTE '
		INSERT INTO model_draft.ego_supply_rea_m3_dea_temp
			SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as rea_sorted,
				dea.*
			FROM 	model_draft.ego_supply_rea_m3_a_mview AS dea
			WHERE 	dea.subst_id =' || gd || ';;

		INSERT INTO model_draft.ego_supply_rea_m3_grid_wpa_temp
			SELECT 	row_number() over (ORDER BY RANDOM())as rea_sorted,
				wpa.id,
				wpa.subst_id,
				wpa.area_type,
				wpa.geom
			FROM 	model_draft.ego_lattice_500m_wpa_mview AS wpa
			WHERE 	wpa.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_supply_rea_m3_jnt_temp
			SELECT	dea.rea_sorted,
				dea.id,
				ST_MAKELINE(dea.geom,wpa.geom) ::geometry(LineString,3035) AS rea_geom_line,
				wpa.geom ::geometry(Point,3035) AS geom 	-- NEW LOCATION!
			FROM	model_draft.ego_supply_rea_m3_dea_temp AS dea
			INNER JOIN model_draft.ego_supply_rea_m3_grid_wpa_temp AS wpa ON (dea.rea_sorted = wpa.rea_sorted);

		UPDATE 	model_draft.ego_dp_supply_res_powerplant AS t1
			SET  	rea_geom_new = t2.rea_geom_new,
				rea_geom_line = t2.rea_geom_line,
				rea_flag = ''M3''
			FROM	(SELECT	m.id AS id,
					m.rea_geom_line,
					m.geom AS rea_geom_new
				FROM	model_draft.ego_supply_rea_m3_jnt_temp AS m
				)AS t2
			WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.ego_supply_rea_m3_dea_temp, model_draft.ego_supply_rea_m3_grid_wpa_temp, model_draft.ego_supply_rea_m3_jnt_temp;
		';
	END LOOP;
END;
$$;

-- M3 result
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m3_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m3_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_dp_supply_res_powerplant AS dea
	WHERE	rea_flag = 'M3';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m3_mview_geom_idx
	ON model_draft.ego_supply_rea_m3_mview USING gist (geom);
	
-- create index GIST (rea_geom_line)
CREATE INDEX ego_supply_rea_m3_mview_rea_geom_line_idx
	ON model_draft.ego_supply_rea_m3_mview USING gist (rea_geom_line);

-- create index GIST (rea_geom_new)
CREATE INDEX ego_supply_rea_m3_mview_rea_geom_new_idx
	ON model_draft.ego_supply_rea_m3_mview USING gist (rea_geom_new);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m3_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','output','model_draft','ego_supply_rea_m3_mview','ego_dp_rea_m3.sql',' ');


-- M3 rest
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m3_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m3_rest_mview AS
	SELECT 	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		rea_flag
	FROM	model_draft.ego_dp_supply_res_powerplant AS dea
	WHERE	rea_flag = 'M3_rest';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m3_rest_mview_geom_idx
	ON model_draft.ego_supply_rea_m3_rest_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m3_rest_mview OWNER TO oeuser;  

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.2','output','model_draft','ego_supply_rea_m3_rest_mview','ego_dp_rea_m3.sql',' ');


-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m3_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m3_grid_wpa_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m3_jnt_temp CASCADE;

DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m3_a_mview CASCADE;
