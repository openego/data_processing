/*
Skript to allocate decentralized renewable power plants (dea)
Methods base on technology and voltage level
Uses different lattice from setup_ego_wpa_per_grid_district.sql

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

/* 1. M1-1
Move "biomass" & (renewable) "gas" to OSM agricultural areas.
The rest could not be allocated, consider in M4.
*/ 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_supply_res_powerplant','ego_dp_rea_m1.sql',' ');

-- MView M1-1
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m1_1_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m1_1_a_mview AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		ST_TRANSFORM(geom,3035) AS geom,
		rea_flag
	FROM 	model_draft.ego_supply_res_powerplant AS dea
	WHERE 	(dea.generation_type = 'biomass' OR dea.generation_type = 'gas') AND
		(dea.voltage_level = 4 OR dea.voltage_level = 5 OR
		dea.voltage_level = 6 OR dea.voltage_level = 7
		OR dea.voltage_level IS NULL );

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m1_1_a_mview_geom_idx
	ON model_draft.ego_supply_rea_m1_1_a_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m1_1_a_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_supply_rea_m1_1_a_mview','ego_dp_rea_m1.sql',' ');


-- rea_flag M1-1
UPDATE 	model_draft.ego_supply_res_powerplant AS dea
	SET	rea_flag = 'M1-1_rest'
	WHERE	(dea.generation_type = 'biomass' OR dea.generation_type = 'gas') AND
		(dea.voltage_level = 4 OR dea.voltage_level = 5 OR
		dea.voltage_level = 6 OR dea.voltage_level = 7
		OR dea.voltage_level IS NULL );


-- temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_1_dea_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m1_1_dea_temp (
	rea_sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	rea_flag character varying,
	CONSTRAINT ego_supply_rea_m1_1_dea_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m1_1_dea_temp_geom_idx
	ON model_draft.ego_supply_rea_m1_1_dea_temp USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_supply_rea_m1_1_dea_temp','ego_dp_rea_m1.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_1_osm_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m1_1_osm_temp (
	rea_sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_supply_rea_m1_1_osm_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m1_1_osm_temp_geom_idx
	ON model_draft.ego_supply_rea_m1_1_osm_temp USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_supply_rea_m1_1_osm_temp','ego_dp_rea_m1.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_1_jnt_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m1_1_jnt_temp (
	rea_sorted bigint NOT NULL,
	id bigint,
	rea_geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_supply_rea_m1_1_jnt_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m1_1_jnt_temp_geom_idx
	ON model_draft.ego_supply_rea_m1_1_jnt_temp USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_supply_rea_m1_1_jnt_temp','ego_dp_rea_m1.sql',' ');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_osm_sector_per_griddistrict_4_agricultural','ego_dp_rea_m1.sql',' ');

-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3609	-- subst_id
	LOOP
        EXECUTE '
		INSERT INTO model_draft.ego_supply_rea_m1_1_dea_temp
			SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as rea_sorted,
					dea.*
			FROM 	model_draft.ego_supply_rea_m1_1_a_mview AS dea
			WHERE 	dea.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_supply_rea_m1_1_osm_temp
			SELECT 	row_number() over (ORDER BY osm.area_ha DESC)as rea_sorted,
					osm.id,
					osm.subst_id,
					osm.area_ha,
					osm.geom
			FROM 	model_draft.ego_osm_sector_per_griddistrict_4_agricultural AS osm
			WHERE 	osm.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_supply_rea_m1_1_jnt_temp
			SELECT	dea.rea_sorted,
					dea.id,
					ST_MAKELINE(dea.geom,ST_CENTROID(osm.geom)) ::geometry(LineString,3035) AS rea_geom_line,
					ST_CENTROID(osm.geom) ::geometry(Point,3035) AS geom	-- NEW LOCATION!
			FROM	model_draft.ego_supply_rea_m1_1_dea_temp AS dea
			INNER JOIN model_draft.ego_supply_rea_m1_1_osm_temp AS osm ON (dea.rea_sorted = osm.rea_sorted);

		UPDATE 	model_draft.ego_supply_res_powerplant AS t1
			SET  	rea_geom_new = t2.rea_geom_new,
					rea_geom_line = t2.rea_geom_line,
					rea_flag = ''M1-1''
			FROM	(SELECT	m.id AS id,
					m.rea_geom_line,
					m.geom AS rea_geom_new
					FROM	model_draft.ego_supply_rea_m1_1_jnt_temp AS m
					)AS t2
			WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.ego_supply_rea_m1_1_dea_temp, model_draft.ego_supply_rea_m1_1_osm_temp, model_draft.ego_supply_rea_m1_1_jnt_temp;
		';
	END LOOP;
END;
$$;

-- M1-1 result
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m1_1_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m1_1_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_supply_res_powerplant AS dea
	WHERE	rea_flag = 'M1-1';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m1_1_mview_geom_idx
	ON model_draft.ego_supply_rea_m1_1_mview USING gist (geom);

-- create index GIST (rea_geom_line)
CREATE INDEX ego_supply_rea_m1_1_mview_rea_geom_line_idx
	ON model_draft.ego_supply_rea_m1_1_mview USING gist (rea_geom_line);

-- create index GIST (rea_geom_new)
CREATE INDEX ego_supply_rea_m1_1_mview_rea_geom_new_idx
	ON model_draft.ego_supply_rea_m1_1_mview USING gist (rea_geom_new);	

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m1_1_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_supply_rea_m1_1_mview','ego_dp_rea_m1.sql',' ');


-- M1-1 rest
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m1_1_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m1_1_rest_mview AS
	SELECT 	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		rea_flag
	FROM	model_draft.ego_supply_res_powerplant AS dea
	WHERE	dea.rea_flag = 'M1-1_rest';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m1_1_rest_mview_geom_idx
	ON model_draft.ego_supply_rea_m1_1_rest_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m1_1_rest_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_supply_rea_m1_1_rest_mview','ego_dp_rea_m1.sql',' ');

-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_1_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_1_osm_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_1_jnt_temp CASCADE;


/* 2. M1-2
Move "solar roof mounted" with "4" to OSM agricultural areas.
The rest could not be allocated, consider in M4.
*/

-- MView M1-2
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m1_2_a_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m1_2_a_mview AS
	SELECT	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		ST_TRANSFORM(geom,3035) AS geom,
		rea_flag
	FROM 	model_draft.ego_supply_res_powerplant AS dea
	WHERE 	(dea.voltage_level = 4 OR dea.voltage_level = 5) AND
		(dea.generation_subtype = 'solar_roof_mounted');

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m1_2_a_mview_geom_idx
	ON model_draft.ego_supply_rea_m1_2_a_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m1_2_a_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_supply_rea_m1_2_a_mview','ego_dp_rea_m1.sql',' ');


-- rea_flag M1-2
UPDATE 	model_draft.ego_supply_res_powerplant AS dea
	SET	rea_flag = 'M1-2_rest'
	WHERE	(dea.voltage_level = 4 OR dea.voltage_level = 5) AND
		(dea.generation_subtype = 'solar_roof_mounted');


-- create temporary tables for the loop
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_2_dea_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m1_2_dea_temp (
	rea_sorted bigint NOT NULL,
	id bigint NOT NULL,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	geom geometry(Point,3035),
	rea_flag character varying,
	CONSTRAINT ego_supply_rea_m1_2_dea_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m1_2_dea_temp_geom_idx
	ON model_draft.ego_supply_rea_m1_2_dea_temp USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_supply_rea_m1_2_dea_temp','ego_dp_rea_m1.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_2_osm_temp ;
CREATE TABLE 		model_draft.ego_supply_rea_m1_2_osm_temp (
	rea_sorted bigint NOT NULL,
	id integer,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_supply_rea_m1_2_osm_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m1_2_osm_temp_geom_idx
	ON model_draft.ego_supply_rea_m1_2_osm_temp USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_supply_rea_m1_2_osm_temp','ego_dp_rea_m1.sql',' ');

DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_2_jnt_temp CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_m1_2_jnt_temp (
	rea_sorted bigint NOT NULL,
	id bigint,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	subst_id integer,
	old_geom geometry(Point,3035),
	rea_geom_line geometry(LineString,3035),
	geom geometry(Point,3035),
	CONSTRAINT ego_supply_rea_m1_2_jnt_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m1_2_jnt_temp_geom_idx
	ON model_draft.ego_supply_rea_m1_2_jnt_temp USING gist (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_supply_rea_m1_2_jnt_temp','ego_dp_rea_m1.sql',' ');

-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3606	-- subst_id
	LOOP
        EXECUTE '
		INSERT INTO model_draft.ego_supply_rea_m1_2_dea_temp
			SELECT	row_number() over (ORDER BY dea.electrical_capacity DESC)as rea_sorted,
				dea.*
			FROM 	model_draft.ego_supply_rea_m1_2_a_mview AS dea
			WHERE 	dea.subst_id =' || gd || ';

		INSERT INTO model_draft.ego_supply_rea_m1_2_osm_temp
			SELECT 	row_number() over (ORDER BY osm.area_ha DESC)as rea_sorted,
				osm.id,
				osm.subst_id,
				osm.area_ha,
				osm.geom
			FROM 	model_draft.ego_osm_sector_per_griddistrict_4_agricultural AS osm
			WHERE 	subst_id =' || gd || ';

		INSERT INTO model_draft.ego_supply_rea_m1_2_jnt_temp
			SELECT	dea.rea_sorted,
				dea.id,
				dea.electrical_capacity,
				dea.generation_type,
				dea.generation_subtype,
				dea.voltage_level,
				dea.subst_id,
				dea.geom AS old_geom,
				ST_MAKELINE(dea.geom,ST_CENTROID(osm.geom)) ::geometry(LineString,3035) AS rea_geom_line,
				ST_CENTROID(osm.geom) ::geometry(Point,3035) AS geom 	-- NEW LOCATION!
			FROM	model_draft.ego_supply_rea_m1_2_dea_temp AS dea
			INNER JOIN model_draft.ego_supply_rea_m1_2_osm_temp AS osm ON (dea.rea_sorted = osm.rea_sorted);

		UPDATE 	model_draft.ego_supply_res_powerplant AS t1
			SET  	rea_geom_new = t2.rea_geom_new,
				rea_geom_line = t2.rea_geom_line,
				rea_flag = ''M1-2''
			FROM	(SELECT	m.id AS id,
					m.rea_geom_line,
					m.geom AS rea_geom_new
				FROM	model_draft.ego_supply_rea_m1_2_jnt_temp AS m
				)AS t2
			WHERE  	t1.id = t2.id;

		TRUNCATE TABLE model_draft.ego_supply_rea_m1_2_dea_temp, model_draft.ego_supply_rea_m1_2_osm_temp, model_draft.ego_supply_rea_m1_2_jnt_temp;
		';
	END LOOP;
END;
$$;

-- M1-2 result
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m1_2_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m1_2_mview AS
	SELECT 	dea.*
	FROM	model_draft.ego_supply_res_powerplant AS dea
	WHERE	rea_flag = 'M1-2';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m1_2_mview_geom_idx
	ON model_draft.ego_supply_rea_m1_2_mview USING gist (geom);

-- create index GIST (rea_geom_line)
CREATE INDEX ego_supply_rea_m1_2_mview_rea_geom_line_idx
	ON model_draft.ego_supply_rea_m1_2_mview USING gist (rea_geom_line);

-- create index GIST (rea_geom_new)
CREATE INDEX ego_supply_rea_m1_2_mview_rea_geom_new_idx
	ON model_draft.ego_supply_rea_m1_2_mview USING gist (rea_geom_new);	

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_supply_rea_m1_2_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_supply_rea_m1_2_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_supply_rea_m1_2_mview','ego_dp_rea_m1.sql',' ');

-- M1-2 rest
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m1_2_rest_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_m1_2_rest_mview AS
	SELECT 	id,
		electrical_capacity,
		generation_type,
		generation_subtype,
		voltage_level,
		subst_id,
		geom,
		rea_flag
	FROM	model_draft.ego_supply_res_powerplant AS dea
	WHERE	dea.rea_flag = 'M1-2_rest';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m1_2_rest_mview_geom_idx
	ON model_draft.ego_supply_rea_m1_2_rest_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m1_2_rest_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_supply_rea_m1_2_rest_mview','ego_dp_rea_m1.sql',' ');


-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_2_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_2_osm_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_2_jnt_temp CASCADE;

DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m1_1_a_mview CASCADE;
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m1_2_a_mview CASCADE;
