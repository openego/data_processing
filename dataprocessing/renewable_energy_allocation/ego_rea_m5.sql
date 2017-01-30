/*
Skript to allocate decentralized renewable power plants (dea)
Methods base on technology and voltage level
Uses different lattice from setup_ego_wpa_per_grid_district.sql

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

/* 6. M5
Relocate "solar" with "6" & "7" to la_grid.
There should be no rest.
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','input','model_draft','ego_supply_rea','ego_rea_m5.sql',' ');

-- MView M5 DEA 
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m5_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m5_a_mview AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM 	model_draft.ego_supply_rea AS dea
	WHERE 	(dea.voltage_level = '6' 
			OR dea.voltage_level = '7'
			OR dea.voltage_level IS NULL)
		AND 	dea.generation_type = 'solar'
		OR (dea.voltage_level = '7' AND dea.generation_type = 'wind');
		
-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m5_a_mview_geom_idx
	ON model_draft.ego_supply_rea_m5_a_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m5_a_mview OWNER TO oeuser;  

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_supply_rea_m5_a_mview','ego_rea_m5.sql',' ');


-- flag M5
UPDATE 	model_draft.ego_supply_rea AS dea
	SET	flag = 'M5_rest'
	WHERE 	(dea.voltage_level = '6' 
			OR dea.voltage_level = '7'
			OR dea.voltage_level IS NULL)
		AND 	dea.generation_type = 'solar'
		OR (dea.voltage_level = '7' AND dea.generation_type = 'wind')
		AND dea.subst_id IS NOT NULL;


-- temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m5_dea_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m5_dea_temp (
	sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	flag character varying,
	CONSTRAINT ego_supply_rea_m5_dea_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_supply_rea_m5_dea_temp_geom_idx
	ON model_draft.ego_supply_rea_m5_dea_temp USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','temp','model_draft','ego_supply_rea_m5_dea_temp','ego_rea_m5.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m5_grid_la_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m5_grid_la_temp (
	sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_type text,
	geom_box geometry(Polygon,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_supply_rea_m5_grid_la_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_supply_rea_m5_grid_la_temp_geom_idx
	ON model_draft.ego_supply_rea_m5_grid_la_temp USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','temp','model_draft','ego_supply_rea_m5_grid_la_temp','ego_rea_m5.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m5_jnt_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m5_jnt_temp (
	sorted bigint NOT NULL,
	id bigint,
	geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_supply_rea_m5_jnt_temp_pkey PRIMARY KEY (sorted));

CREATE INDEX ego_supply_rea_m5_jnt_temp_geom_idx
	ON model_draft.ego_supply_rea_m5_jnt_temp USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','temp','model_draft','ego_supply_rea_m5_jnt_temp','ego_rea_m5.sql',' ');


-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3606	-- subst_id
	LOOP
        EXECUTE '
		INSERT INTO model_draft.ego_supply_rea_m5_dea_temp
			SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as sorted,
			dea.*
			FROM 	model_draft.ego_supply_rea_m5_a_mview AS dea
			WHERE 	dea.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_supply_rea_m5_grid_la_temp
			SELECT 	row_number() over (ORDER BY RANDOM())as sorted,
			la.*
			FROM 	model_draft.ego_lattice_50m_la_mview AS la	-- INPUT LATTICE
			WHERE 	la.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_supply_rea_m5_jnt_temp
			SELECT	dea.sorted,
				dea.id,
				ST_MAKELINE(dea.geom,la.geom) ::geometry(LineString,3035) AS geom_line,
				la.geom ::geometry(Point,3035) AS geom 		-- NEW LOCATION!
			FROM	model_draft.ego_supply_rea_m5_dea_temp AS dea
			INNER JOIN model_draft.ego_supply_rea_m5_grid_la_temp AS la ON (dea.sorted = la.sorted);

		UPDATE 	model_draft.ego_supply_rea AS t1
			SET  	geom_new = t2.geom_new,
				geom_line = t2.geom_line,
				flag = ''M5''
			FROM	(SELECT	m.id AS id,
					m.geom_line,
					m.geom AS geom_new
				FROM	model_draft.ego_supply_rea_m5_jnt_temp AS m
				)AS t2
			WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.ego_supply_rea_m5_dea_temp, model_draft.ego_supply_rea_m5_grid_la_temp, model_draft.ego_supply_rea_m5_jnt_temp;
		';
	END LOOP;
END;
$$;

-- M5 result
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m5_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m5_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_supply_rea AS dea
	WHERE	flag = 'M5';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m5_mview_geom_idx
	ON model_draft.ego_supply_rea_m5_mview USING gist (geom);

-- create index GIST (geom_line)
CREATE INDEX ego_supply_rea_m5_mview_geom_line_idx
	ON model_draft.ego_supply_rea_m5_mview USING gist (geom_line);

-- create index GIST (geom_new)
CREATE INDEX ego_supply_rea_m5_mview_geom_new_idx
	ON model_draft.ego_supply_rea_m5_mview USING gist (geom_new);	

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m5_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_supply_rea_m5_mview','ego_rea_m5.sql',' ');


-- M5 rest
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m5_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m5_rest_mview AS
	SELECT 	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		flag
	FROM	model_draft.ego_supply_rea AS dea
	WHERE	dea.flag = 'M5_rest';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m5_rest_mview_geom_idx
	ON model_draft.ego_supply_rea_m5_rest_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m5_rest_mview OWNER TO oeuser;  

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_supply_rea_m5_rest_mview','ego_rea_m5.sql',' ');


-- update la_id from loadarea
UPDATE 	model_draft.ego_supply_rea AS t1
	SET  	la_id = t2.la_id
	FROM    (
		SELECT	dea.id AS id,
			la.id AS la_id
		FROM	model_draft.ego_supply_rea AS dea,
			model_draft.ego_demand_loadarea AS la
		WHERE  	la.geom && dea.geom_new AND
			ST_CONTAINS(la.geom,dea.geom_new)
		) AS t2
	WHERE  	t1.id = t2.id;

-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m5_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m5_grid_la_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m5_jnt_temp CASCADE;
