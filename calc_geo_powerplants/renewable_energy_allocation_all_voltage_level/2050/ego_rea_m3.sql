/*
Skript to allocate decentralized renewable power plants (dea)
Methods base on technology and voltage level
Uses different lattice from setup_ego_wpa_per_grid_district.sql

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

/* 4. M3 
Move "wind" with "5" & "6" to wpa_grid.
Also considers rest of M2.
The rest could not be allocated, consider in M4.
*/ 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','input','model_draft','ego_supply_rea','ego_rea_m3.sql',' ');

-- MView M3
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m3_a_mview_2050 CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m3_a_mview_2050 AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM 	model_draft.ego_supply_rea AS dea
	WHERE 	(dea.voltage_level = 5 OR 
		dea.voltage_level = 6) AND 
		dea.generation_type = 'wind' OR 
		dea.flag = 'M2_rest' AND
		dea.subst_id IS NOT NULL ;

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m3_a_mview_geom_idx
  ON model_draft.ego_supply_rea_m3_a_mview_2050 USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m3_a_mview_2050 OWNER TO oeuser;  

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_supply_rea_m3_a_mview_2050','ego_rea_m3.sql',' ');


-- flag M3
UPDATE 	model_draft.ego_supply_rea AS dea
	SET	flag = 'M3_rest'
	WHERE	(dea.voltage_level = 5 OR 
		dea.voltage_level = 6) AND 
		dea.generation_type = 'wind' OR 
		dea.flag = 'M2_rest' AND
		dea.subst_id IS NOT NULL ;


-- temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m3_dea_temp_2050 CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m3_dea_temp_2050 (
	sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	flag character varying,
	CONSTRAINT ego_supply_rea_m3_dea_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_supply_rea_m3_dea_temp_geom_idx
  ON model_draft.ego_supply_rea_m3_dea_temp_2050 USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','temp','model_draft','ego_supply_rea_m3_dea_temp_2050','ego_rea_m3.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m3_grid_wpa_temp_2050 CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m3_grid_wpa_temp_2050 (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_type text,
	geom geometry(Point,3035),
	CONSTRAINT ego_supply_rea_m3_grid_wpa_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_supply_rea_m3_grid_wpa_temp_geom_idx
  ON model_draft.ego_supply_rea_m3_grid_wpa_temp_2050 USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','temp','model_draft','ego_supply_rea_m3_grid_wpa_temp_2050','ego_rea_m3.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m3_jnt_temp_2050 CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m3_jnt_temp_2050 (
	sorted bigint NOT NULL,
	id bigint,
	geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_supply_rea_m3_jnt_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_supply_rea_m3_jnt_temp_geom_idx
  ON model_draft.ego_supply_rea_m3_jnt_temp_2050 USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','temp','model_draft','ego_supply_rea_m3_jnt_temp_2050','ego_rea_m3.sql',' ');


-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3606	-- subst_id
	LOOP
        EXECUTE '
		INSERT INTO model_draft.ego_supply_rea_m3_dea_temp_2050
			SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as sorted,
				dea.*
			FROM 	model_draft.ego_supply_rea_m3_a_mview_2050 AS dea
			WHERE 	dea.subst_id =' || gd || ';;

		INSERT INTO model_draft.ego_supply_rea_m3_grid_wpa_temp_2050
			SELECT 	row_number() over (ORDER BY RANDOM())as sorted,
				wpa.id,
				wpa.subst_id,
				wpa.area_type,
				wpa.geom
			FROM 	model_draft.ego_lattice_500m_wpa_mview_2050 AS wpa
			WHERE 	wpa.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_supply_rea_m3_jnt_temp_2050
			SELECT	dea.sorted,
				dea.id,
				ST_MAKELINE(dea.geom,wpa.geom) ::geometry(LineString,3035) AS geom_line,
				wpa.geom ::geometry(Point,3035) AS geom 	-- NEW LOCATION!
			FROM	model_draft.ego_supply_rea_m3_dea_temp_2050 AS dea
			INNER JOIN model_draft.ego_supply_rea_m3_grid_wpa_temp_2050 AS wpa ON (dea.sorted = wpa.sorted);

		UPDATE 	model_draft.ego_supply_rea AS t1
			SET  	geom_new = t2.geom_new,
				geom_line = t2.geom_line,
				flag = ''M3''
			FROM	(SELECT	m.id AS id,
					m.geom_line,
					m.geom AS geom_new
				FROM	model_draft.ego_supply_rea_m3_jnt_temp_2050 AS m
				)AS t2
			WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.ego_supply_rea_m3_dea_temp_2050, model_draft.ego_supply_rea_m3_grid_wpa_temp_2050, model_draft.ego_supply_rea_m3_jnt_temp_2050;
		';
	END LOOP;
END;
$$;

-- M3 result
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m3_mview_2050 CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m3_mview_2050 AS
	SELECT 	dea.*
	FROM	model_draft.ego_supply_rea AS dea
	WHERE	flag = 'M3';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m3_mview_geom_idx
	ON model_draft.ego_supply_rea_m3_mview_2050 USING gist (geom);
	
-- create index GIST (geom_line)
CREATE INDEX ego_supply_rea_m3_mview_geom_line_idx
	ON model_draft.ego_supply_rea_m3_mview_2050 USING gist (geom_line);

-- create index GIST (geom_new)
CREATE INDEX ego_supply_rea_m3_mview_geom_new_idx
	ON model_draft.ego_supply_rea_m3_mview_2050 USING gist (geom_new);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m3_mview_2050 OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_supply_rea_m3_mview_2050','ego_rea_m3.sql',' ');


-- M3 rest
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m3_rest_mview_2050 CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m3_rest_mview_2050 AS
	SELECT 	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM	model_draft.ego_supply_rea AS dea
	WHERE	flag = 'M3_rest';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m3_rest_mview_geom_idx
	ON model_draft.ego_supply_rea_m3_rest_mview_2050 USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m3_rest_mview_2050 OWNER TO oeuser;  

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_supply_rea_m3_rest_mview_2050','ego_rea_m3.sql',' ');


-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m3_dea_temp_2050 CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m3_grid_wpa_temp_2050 CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m3_jnt_temp_2050 CASCADE;