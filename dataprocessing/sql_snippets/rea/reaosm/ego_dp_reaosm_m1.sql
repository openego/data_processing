/*
M1 biomass and solar to OSM agricultural
Allocates "biomass" & (renewable) "gas" to OSM agricultural areas.
The rest could not be allocated, consider in M4.

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee, Christian-rli"
*/

-- check
SELECT  generation_type, generation_subtype, count(*)
FROM    sandbox.ego_reaosm_m1_1_a_mview
GROUP BY generation_type, generation_subtype
ORDER BY generation_type, generation_subtype;

-- MView M1-1
DROP MATERIALIZED VIEW IF EXISTS    sandbox.ego_reaosm_m1_1_a_mview CASCADE;
CREATE MATERIALIZED VIEW            sandbox.ego_reaosm_m1_1_a_mview AS
    SELECT  id,
            electrical_capacity,
            generation_type,
            generation_subtype,
            voltage_level,
            subst_id,
            ST_TRANSFORM(geom,3035) AS geom,
            rea_flag
    FROM    sandbox.ego_dp_res_powerplant_reaosm
    WHERE   (generation_type = 'biomass' OR generation_type = 'gas')
            AND(voltage_level = 4 OR voltage_level = 5
                OR voltage_level = 6 OR voltage_level = 7
                OR voltage_level IS NULL );

-- create index GIST (geom)
CREATE INDEX ego_reaosm_m1_1_a_mview_geom_idx
    ON sandbox.ego_reaosm_m1_1_a_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE sandbox.ego_reaosm_m1_1_a_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_PP_REAOSM','v0.1','input','sandbox','ego_dp_res_powerplant_reaosm','ego_dp_reaosm_m1.sql',' ');
SELECT scenario_log('eGo_REAOSM','v0.1','temp','sandbox','ego_reaosm_m1_1_a_mview','ego_dp_reaosm_m1.sql',' ');


-- reaosm_flag M1-1
UPDATE sandbox.ego_dp_res_powerplant_reaosm AS dea
    SET reaosm_flag = 'M1-1_rest'
    WHERE   (dea.generation_type = 'biomass' OR dea.generation_type = 'gas') 
        AND (dea.voltage_level = 4 OR dea.voltage_level = 5 
            OR dea.voltage_level = 6 OR dea.voltage_level = 7
            OR dea.voltage_level IS NULL );


-- temporary tables for the loop
DROP TABLE IF EXISTS    sandbox.ego_reaosm_m1_1_dea_temp CASCADE;
CREATE TABLE            sandbox.ego_reaosm_m1_1_dea_temp (
    reaosm_sort bigint NOT NULL,
    id bigint NOT NULL,
    electrical_capacity numeric,
    generation_type text,
    generation_subtype character varying,
    voltage_level character varying,
    subst_id integer,
    geom geometry(Point,3035),
    reaosm_flag character varying,
    CONSTRAINT ego_reaosm_m1_1_dea_temp_pkey PRIMARY KEY (reaosm_sort));

CREATE INDEX ego_reaosm_m1_1_dea_temp_geom_idx
    ON sandbox.ego_reaosm_m1_1_dea_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
--SELECT scenario_log('eGo_REAOSM','v0.1','temp','sandbox','ego_reaosm_m1_1_dea_temp','ego_dp_reaosm_m1.sql',' ');

DROP TABLE IF EXISTS    sandbox.ego_reaosm_m1_1_osm_temp CASCADE;
CREATE TABLE            sandbox.ego_reaosm_m1_1_osm_temp (
    reaosm_sort bigint NOT NULL,
    id bigint,
    subst_id integer,
    geom geometry(Point,3035),
    CONSTRAINT ego_reaosm_m1_1_osm_temp_pkey PRIMARY KEY (reaosm_sort));

CREATE INDEX ego_reaosm_m1_1_osm_temp_geom_idx
    ON sandbox.ego_reaosm_m1_1_osm_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
--SELECT scenario_log('eGo_REAOSM','v0.1','temp','sandbox','ego_reaosm_m1_1_osm_temp','ego_dp_reaosm_m1.sql',' ');

DROP TABLE IF EXISTS    sandbox.ego_reaosm_m1_1_jnt_temp CASCADE;
CREATE TABLE            sandbox.ego_reaosm_m1_1_jnt_temp (
    reaosm_sort bigint NOT NULL,
    id bigint,
    reaosm_geom_line geometry(LineString,3035),
    geom geometry(Point,3035),
    CONSTRAINT ego_reaosm_m1_1_jnt_temp_pkey PRIMARY KEY (reaosm_sort));

CREATE INDEX ego_reaosm_m1_1_jnt_temp_geom_idx
    ON sandbox.ego_reaosm_m1_1_jnt_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
--SELECT scenario_log('eGo_REAOSM','v0.1','temp','sandbox','ego_reaosm_m1_1_jnt_temp','ego_dp_reaosm_m1.sql',' ');

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
-- SELECT scenario_log('eGo_REAOSM','v0.1','input','model_draft','ego_osm_sector_per_griddistrict_4_agricultural','ego_dp_reaosm_m1.sql',' ');

-- loop for grid_district
DO
$$
DECLARE gd integer;
BEGIN
    FOR gd IN 1..3591   -- subst_id
    LOOP
        EXECUTE '
        INSERT INTO sandbox.ego_reaosm_m1_1_dea_temp
            SELECT  row_number() over (ORDER BY electrical_capacity DESC) AS reaosm_sort,
                    *
            FROM    sandbox.ego_reaosm_m1_1_a_mview
            WHERE   subst_id =' || gd || ';

        INSERT INTO sandbox.ego_reaosm_m1_1_osm_temp
            SELECT  row_number() over (ORDER BY osm_id DESC) AS reaosm_sort,
                    osm_id,
                    subst_id,
                    geom
            FROM    sandbox.ego_pp_osm_deu_power_point_reaosm
            WHERE   rea_method = ''M1''
                    AND subst_id =' || gd || ';

        INSERT INTO sandbox.ego_reaosm_m1_1_osm_temp
            SELECT  COALESCE((
                        SELECT  MAX(reaosm_sort) 
                        FROM    sandbox.ego_reaosm_m1_1_osm_temp), ''0'') 
                            + row_number() over (ORDER BY area_ha DESC) AS reaosm_sort,
                    id,
                    subst_id,
                    ST_CENTROID(geom) ::geometry(Point,3035)
            FROM    model_draft.ego_osm_sector_per_griddistrict_4_agricultural
            WHERE   subst_id =' || gd || ';

        INSERT INTO sandbox.ego_reaosm_m1_1_jnt_temp
            SELECT  dea.reaosm_sort,
                    dea.id,
                    ST_MAKELINE(dea.geom,ST_CENTROID(osm.geom)) ::geometry(LineString,3035) AS reaosm_geom_line,
                    osm.geom ::geometry(Point,3035) AS geom    -- NEW LOCATION!
            FROM    sandbox.ego_reaosm_m1_1_dea_temp AS dea
            INNER JOIN sandbox.ego_reaosm_m1_1_osm_temp AS osm ON (dea.reaosm_sort = osm.reaosm_sort);

        UPDATE      sandbox.ego_dp_res_powerplant_reaosm AS t1
            SET     reaosm_geom_new = t2.reaosm_geom_new,
                    reaosm_geom_line = t2.reaosm_geom_line,
                    reaosm_flag = ''M1-1''
            FROM    (SELECT m.id AS id,
                        m.reaosm_geom_line,
                        m.geom AS reaosm_geom_new
                    FROM    sandbox.ego_reaosm_m1_1_jnt_temp AS m
                    )AS t2
            WHERE   t1.id = t2.id;

        TRUNCATE TABLE sandbox.ego_reaosm_m1_1_dea_temp, sandbox.ego_reaosm_m1_1_osm_temp, sandbox.ego_reaosm_m1_1_jnt_temp;
        ';
    END LOOP;
END;
$$;

-- M1-1 result
DROP MATERIALIZED VIEW IF EXISTS    sandbox.ego_reaosm_m1_1_mview CASCADE;
CREATE MATERIALIZED VIEW            sandbox.ego_reaosm_m1_1_mview AS
    SELECT  dea.*
    FROM    sandbox.ego_dp_res_powerplant_reaosm AS dea
    WHERE   rea_flag = 'M1-1';

-- create index GIST (geom)
CREATE INDEX ego_reaosm_m1_1_mview_geom_idx
    ON sandbox.ego_reaosm_m1_1_mview USING gist (geom);

-- create index GIST (rea_geom_line)
CREATE INDEX ego_reaosm_m1_1_mview_rea_geom_line_idx
    ON sandbox.ego_reaosm_m1_1_mview USING gist (rea_geom_line);

-- create index GIST (rea_geom_new)
CREATE INDEX ego_reaosm_m1_1_mview_rea_geom_new_idx
    ON sandbox.ego_reaosm_m1_1_mview USING gist (rea_geom_new);	

-- grant (oeuser)
ALTER TABLE sandbox.ego_reaosm_m1_1_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
--SELECT scenario_log('eGo_REAOSM','v0.1','output','sandbox','ego_reaosm_m1_1_mview','ego_dp_reaosm_m1.sql',' ');


-- M1-1 rest
DROP MATERIALIZED VIEW IF EXISTS    sandbox.ego_reaosm_m1_1_rest_mview CASCADE;
CREATE MATERIALIZED VIEW            sandbox.ego_reaosm_m1_1_rest_mview AS
    SELECT  id,
            electrical_capacity,
            generation_type,
            generation_subtype,
            voltage_level,
            subst_id,
            geom,
            rea_flag
    FROM    sandbox.ego_dp_res_powerplant_reaosm AS dea
    WHERE   dea.rea_flag = 'M1-1_rest';

-- create index GIST (geom)
CREATE INDEX ego_reaosm_m1_1_rest_mview_geom_idx
    ON sandbox.ego_reaosm_m1_1_rest_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE sandbox.ego_reaosm_m1_1_rest_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
--SELECT scenario_log('eGo_REAOSM','v0.1','output','sandbox','ego_reaosm_m1_1_rest_mview','ego_dp_reaosm_m1.sql',' ');


-- Drop temp
DROP TABLE IF EXISTS    sandbox.ego_reaosm_m1_1_dea_temp CASCADE;
DROP TABLE IF EXISTS    sandbox.ego_reaosm_m1_1_osm_temp CASCADE;
DROP TABLE IF EXISTS    sandbox.ego_reaosm_m1_1_jnt_temp CASCADE;


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
	FROM 	sandbox.ego_dp_res_powerplant_reaosm AS dea
	WHERE 	(dea.voltage_level = 4 OR dea.voltage_level = 5) AND
		(dea.generation_subtype = 'solar_roof_mounted')
		AND (dea.flag in ('commissioning','constantly'));

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m1_2_a_mview_geom_idx
	ON model_draft.ego_supply_rea_m1_2_a_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m1_2_a_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','temp','model_draft','ego_supply_rea_m1_2_a_mview','ego_dp_reaosm_m1.sql',' ');


-- rea_flag M1-2
UPDATE 	sandbox.ego_dp_res_powerplant_reaosm AS dea
	SET	rea_flag = 'M1-2_rest'
	WHERE	(dea.voltage_level = 4 OR dea.voltage_level = 5) AND
		(dea.generation_subtype = 'solar_roof_mounted')
		AND (dea.flag in ('commissioning','constantly'));


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

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','temp','model_draft','ego_supply_rea_m1_2_dea_temp','ego_dp_reaosm_m1.sql',' ');

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

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','temp','model_draft','ego_supply_rea_m1_2_osm_temp','ego_dp_reaosm_m1.sql',' ');

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

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','temp','model_draft','ego_supply_rea_m1_2_jnt_temp','ego_dp_reaosm_m1.sql',' ');

-- loop for grid_district
DO
$$
DECLARE	gd integer;
BEGIN
	FOR gd IN 1..3591	-- subst_id
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

		UPDATE 	sandbox.ego_dp_res_powerplant_reaosm AS t1
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
	FROM	sandbox.ego_dp_res_powerplant_reaosm AS dea
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

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','output','model_draft','ego_supply_rea_m1_2_mview','ego_dp_reaosm_m1.sql',' ');

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
	FROM	sandbox.ego_dp_res_powerplant_reaosm AS dea
	WHERE	dea.rea_flag = 'M1-2_rest';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m1_2_rest_mview_geom_idx
	ON model_draft.ego_supply_rea_m1_2_rest_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m1_2_rest_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_REAOSM','v0.1','output','model_draft','ego_supply_rea_m1_2_rest_mview','ego_dp_reaosm_m1.sql',' ');


-- Drop temp
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_2_dea_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_2_osm_temp CASCADE;
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea_m1_2_jnt_temp CASCADE;

--DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_reaosm_m1_1_a_mview CASCADE;
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_m1_2_a_mview CASCADE;
