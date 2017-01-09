/*
Skript to allocate decentralized renewable power plants (dea)
Methods base on technology and voltage level
Uses different lattice from setup_ego_wpa_per_grid_district.sql

__copyright__ = "tba"
__license__ = "tba"
__author__ = "Ludee"
*/

/* 5. M4
Move "wind" with "05 (MS)" & "06 (MS/NS)" to wpa_grid.
"solar ground" & "wind" ohne voltage & Rest M1-1 & Rest M1-2 & Rest M3.
Also considers rest of M1-1, M1-2 and M3.
There should be no rest!
*/ 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','input','model_draft','ego_supply_rea','ego_rea_m4.sql',' ');

-- MView M4
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m4_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m4_a_mview AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM 	model_draft.ego_supply_rea AS dea
	WHERE 	(dea.voltage_level = '04 (HS/MS)' OR dea.voltage_level = '05 (MS)')
		AND 	(dea.generation_subtype = 'solar_ground_mounted' 
			OR (dea.generation_type = 'solar' AND dea.generation_subtype IS NULL))
		OR (dea.voltage_level IS NULL AND dea.generation_type = 'wind')
		OR dea.flag = 'M1-1_rest'
		OR dea.flag = 'M1-2_rest'
		OR dea.flag = 'M3_rest'
		AND dea.subst_id IS NOT NULL;

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m4_a_mview_geom_idx
	ON model_draft.ego_supply_rea_m4_a_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m4_a_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_supply_rea_m4_a_mview','ego_rea_m4.sql',' ');


-- flag M4
UPDATE 	model_draft.ego_supply_rea AS dea
	SET	flag = 'M4_rest'
	WHERE	(dea.voltage_level = '04 (HS/MS)' OR dea.voltage_level = '05 (MS)')
		AND 	(dea.generation_subtype = 'solar_ground_mounted' 
			OR (dea.generation_type = 'solar' AND dea.generation_subtype IS NULL))
		OR (dea.voltage_level IS NULL AND dea.generation_type = 'wind')
		OR dea.flag = 'M1-1_rest'
		OR dea.flag = 'M1-2_rest'
		OR dea.flag = 'M3_rest'
		AND dea.subst_id IS NOT NULL;


-- temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_m4_dea_temp CASCADE;
CREATE TABLE 		model_draft.ego_m4_dea_temp (
	sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	flag character varying,
	CONSTRAINT ego_m4_dea_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m4_dea_temp_geom_idx
	ON model_draft.ego_m4_dea_temp USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','temp','model_draft','ego_m4_dea_temp','ego_rea_m4.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_m4_grid_wpa_temp CASCADE;
CREATE TABLE 		model_draft.ego_m4_grid_wpa_temp (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_type text,
	geom geometry(Point,3035),
	CONSTRAINT ego_m4_grid_wpa_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_m4_grid_wpa_temp_geom_idx
	ON model_draft.ego_m4_grid_wpa_temp USING gist (geom);
  
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','temp','model_draft','ego_m4_grid_wpa_temp','ego_rea_m4.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_m4_jnt_temp CASCADE;
CREATE TABLE 		model_draft.ego_m4_jnt_temp (
	sorted bigint NOT NULL,
	id bigint,
	geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_m4_jnt_temp_pkey PRIMARY KEY (sorted));
	
CREATE INDEX ego_m4_jnt_temp_geom_idx
	ON model_draft.ego_m4_jnt_temp USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','temp','model_draft','ego_m4_jnt_temp','ego_rea_m4.sql',' ');


-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3609	-- subst_id
	LOOP
        EXECUTE '
		INSERT INTO model_draft.ego_m4_dea_temp
			SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as sorted,
				dea.*
			FROM 	model_draft.ego_supply_rea_m4_a_mview AS dea
			WHERE 	dea.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_m4_grid_wpa_temp
			SELECT 	row_number() over (ORDER BY RANDOM())as sorted,
				wpa.*
			FROM 	model_draft.ego_lattice_deu_500m_out_mview AS wpa
			WHERE 	wpa.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_m4_jnt_temp
			SELECT	dea.sorted,
				dea.id,
				ST_MAKELINE(dea.geom,wpa.geom) ::geometry(LineString,3035) AS geom_line,
				wpa.geom ::geometry(Point,3035) AS geom 	-- NEW LOCATION!
			FROM	model_draft.ego_m4_dea_temp AS dea
			INNER JOIN model_draft.ego_m4_grid_wpa_temp AS wpa ON (dea.sorted = wpa.sorted);

		UPDATE 	model_draft.ego_supply_rea AS t1
			SET  	geom_new = t2.geom_new,
				geom_line = t2.geom_line,
				flag = ''M4''
			FROM	(SELECT	m.id AS id,
					m.geom_line,
					m.geom AS geom_new
				FROM	model_draft.ego_m4_jnt_temp AS m
				)AS t2
			WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.ego_m4_dea_temp, model_draft.ego_m4_grid_wpa_temp, model_draft.ego_m4_jnt_temp;
		';
	END LOOP;
END;
$$;

-- M4 result
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m4_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m4_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_supply_rea AS dea
	WHERE	flag = 'M4';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m4_mview_geom_idx
	ON model_draft.ego_supply_rea_m4_mview USING gist (geom);

-- create index GIST (geom_line)
CREATE INDEX ego_supply_rea_m4_mview_geom_line_idx
	ON model_draft.ego_supply_rea_m4_mview USING gist (geom_line);

-- create index GIST (geom_new)
CREATE INDEX ego_supply_rea_m4_mview_geom_new_idx
	ON model_draft.ego_supply_rea_m4_mview USING gist (geom_new);	

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m4_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_supply_rea_m4_mview','ego_rea_m4.sql',' ');


-- M4 rest
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m4_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m4_rest_mview AS
	SELECT 	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM	model_draft.ego_supply_rea AS dea
	WHERE	dea.flag = 'M4_rest';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m4_rest_mview_geom_idx
	ON model_draft.ego_supply_rea_m4_rest_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m4_rest_mview OWNER TO oeuser;  

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_supply_rea_m4_rest_mview','ego_rea_m4.sql',' ');


-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_m4_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_m4_grid_wpa_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_m4_jnt_temp CASCADE;
