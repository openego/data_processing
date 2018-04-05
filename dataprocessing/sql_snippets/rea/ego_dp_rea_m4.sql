/*
M4 other and rest
Allocates "wind" with voltage levels "5" & "6" to WPA.
"solar ground" & "wind" ohne voltage & Rest M1-1 & Rest M1-2 & Rest M3.
Also considers rest of M1-1, M1-2 and M3.
There should be no rest!

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','input','model_draft','ego_dp_supply_res_powerplant','ego_dp_rea_m4.sql',' ');

-- MView M4
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m4_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m4_a_mview AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		ST_TRANSFORM(geom,3035) AS geom,
		rea_flag
	FROM 	model_draft.ego_dp_supply_res_powerplant AS dea
	WHERE 	(dea.voltage_level = 4 OR dea.voltage_level = 5)
	        AND (dea.flag in ('commissioning','constantly'))
		AND 	(dea.generation_subtype = 'solar_ground_mounted' 
			OR (dea.generation_type = 'solar' AND dea.generation_subtype IS NULL))
		OR (dea.voltage_level IS NULL AND dea.generation_type = 'wind')
		OR dea.rea_flag = 'M1-1_rest'
		OR dea.rea_flag = 'M1-2_rest'
		OR dea.rea_flag = 'M3_rest'
		AND dea.subst_id IS NOT NULL;

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m4_a_mview_geom_idx
	ON model_draft.ego_supply_rea_m4_a_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m4_a_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','temp','model_draft','ego_supply_rea_m4_a_mview','ego_dp_rea_m4.sql',' ');


-- rea_flag M4
UPDATE 	model_draft.ego_dp_supply_res_powerplant AS dea
	SET	rea_flag = 'M4_rest'
	WHERE	(dea.voltage_level = 4 OR dea.voltage_level = 5)
                AND (dea.flag in ('commissioning','constantly'))
		AND 	(dea.generation_subtype = 'solar_ground_mounted' 
			OR (dea.generation_type = 'solar' AND dea.generation_subtype IS NULL))
		OR (dea.voltage_level IS NULL AND dea.generation_type = 'wind')
		OR dea.rea_flag = 'M1-1_rest'
		OR dea.rea_flag = 'M1-2_rest'
		OR dea.rea_flag = 'M3_rest'
		AND dea.subst_id IS NOT NULL;


-- temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m4_dea_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m4_dea_temp (
	rea_sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	rea_flag character varying,
	CONSTRAINT ego_supply_rea_m4_dea_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m4_dea_temp_geom_idx
	ON model_draft.ego_supply_rea_m4_dea_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','temp','model_draft','ego_supply_rea_m4_dea_temp','ego_dp_rea_m4.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m4_grid_wpa_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m4_grid_wpa_temp (
	rea_sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_type text,
	geom_box geometry(Polygon,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_supply_rea_m4_grid_wpa_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m4_grid_wpa_temp_geom_idx
	ON model_draft.ego_supply_rea_m4_grid_wpa_temp USING gist (geom);
  
-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','temp','model_draft','ego_supply_rea_m4_grid_wpa_temp','ego_dp_rea_m4.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m4_jnt_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m4_jnt_temp (
	rea_sorted bigint NOT NULL,
	id bigint,
	rea_geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_supply_rea_m4_jnt_temp_pkey PRIMARY KEY (rea_sorted));
	
CREATE INDEX ego_supply_rea_m4_jnt_temp_geom_idx
	ON model_draft.ego_supply_rea_m4_jnt_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','temp','model_draft','ego_supply_rea_m4_jnt_temp','ego_dp_rea_m4.sql',' ');


-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3608	-- subst_id
	LOOP
        EXECUTE '
		INSERT INTO model_draft.ego_supply_rea_m4_dea_temp
			SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC) AS rea_sorted,
				dea.*
			FROM 	model_draft.ego_supply_rea_m4_a_mview AS dea
			WHERE 	dea.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_supply_rea_m4_grid_wpa_temp
			SELECT 	row_number() over (ORDER BY RANDOM())as rea_sorted,
				wpa.*
			FROM 	model_draft.ego_lattice_500m_out_mview AS wpa
			WHERE 	wpa.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_supply_rea_m4_jnt_temp
			SELECT	dea.rea_sorted,
				dea.id,
				ST_MAKELINE(dea.geom,wpa.geom) ::geometry(LineString,3035) AS rea_geom_line,
				wpa.geom ::geometry(Point,3035) AS geom 	-- NEW LOCATION!
			FROM	model_draft.ego_supply_rea_m4_dea_temp AS dea
			INNER JOIN model_draft.ego_supply_rea_m4_grid_wpa_temp AS wpa ON (dea.rea_sorted = wpa.rea_sorted);

		UPDATE 	model_draft.ego_dp_supply_res_powerplant AS t1
			SET  	rea_geom_new = t2.rea_geom_new,
				rea_geom_line = t2.rea_geom_line,
				rea_flag = ''M4''
			FROM	(SELECT	m.id AS id,
					m.rea_geom_line,
					m.geom AS rea_geom_new
				FROM	model_draft.ego_supply_rea_m4_jnt_temp AS m
				)AS t2
			WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.ego_supply_rea_m4_dea_temp, model_draft.ego_supply_rea_m4_grid_wpa_temp, model_draft.ego_supply_rea_m4_jnt_temp;
		';
	END LOOP;
END;
$$;

-- M4 result
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m4_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m4_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_dp_supply_res_powerplant AS dea
	WHERE	rea_flag = 'M4';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m4_mview_geom_idx
	ON model_draft.ego_supply_rea_m4_mview USING gist (geom);

-- create index GIST (rea_geom_line)
CREATE INDEX ego_supply_rea_m4_mview_rea_geom_line_idx
	ON model_draft.ego_supply_rea_m4_mview USING gist (rea_geom_line);

-- create index GIST (rea_geom_new)
CREATE INDEX ego_supply_rea_m4_mview_rea_geom_new_idx
	ON model_draft.ego_supply_rea_m4_mview USING gist (rea_geom_new);	

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m4_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','output','model_draft','ego_supply_rea_m4_mview','ego_dp_rea_m4.sql',' ');


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
		rea_flag
	FROM	model_draft.ego_dp_supply_res_powerplant AS dea
	WHERE	dea.rea_flag = 'M4_rest';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m4_rest_mview_geom_idx
	ON model_draft.ego_supply_rea_m4_rest_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m4_rest_mview OWNER TO oeuser;  

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','output','model_draft','ego_supply_rea_m4_rest_mview','ego_dp_rea_m4.sql',' ');


-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m4_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m4_grid_wpa_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m4_jnt_temp CASCADE;

DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m4_a_mview CASCADE;
