
/*
M3b wind power plants to osm generator:source = wind and wpa
Allocates wind to OSM agricultural areas. Method is an adaptation of M3 and hence labeled M3b

todo: fix comments, temporary table names and variables to harmonize with name method 3b

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee, christian-rli"
*/



-- MView M3b_a
DROP MATERIALIZED VIEW IF EXISTS    sandbox.ego_reaosm_m3b_a_mview CASCADE;
CREATE MATERIALIZED VIEW            sandbox.ego_reaosm_m3b_a_mview AS
    SELECT  id,
            electrical_capacity,
            generation_type,
            generation_subtype,
            voltage_level,
            subst_id,
            ST_TRANSFORM(geom,3035) AS geom,
            rea_flag
    FROM    sandbox.ego_dp_res_powerplant_reaosm
    WHERE   (generation_type = 'wind')
            AND(voltage_level = 4 OR voltage_level = 5
                OR voltage_level = 6 OR voltage_level = 7
                OR voltage_level IS NULL );

-- create index GIST (geom)
CREATE INDEX ego_reaosm_m3b_a_mview_geom_idx
    ON sandbox.ego_reaosm_m3b_a_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE sandbox.ego_reaosm_m3b_a_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_PP_REAOSM','v0.1','input','sandbox','ego_dp_res_powerplant_reaosm','ego_dp_reaosm_m3b.sql',' ');
SELECT scenario_log('eGo_REAOSM','v0.1','temp','sandbox','ego_reaosm_m3b_a_mview','ego_dp_reaosm_m3b.sql',' ');

-- check
SELECT  generation_type, generation_subtype, count(*)
FROM    sandbox.ego_reaosm_m3b_a_mview
GROUP BY generation_type, generation_subtype
ORDER BY generation_type, generation_subtype;


-- reaosm_flag M3b_rest
UPDATE sandbox.ego_dp_res_powerplant_reaosm AS dea
    SET reaosm_flag = 'M3b_rest'
    WHERE   (dea.generation_type = 'wind') 
        AND (dea.voltage_level = 4 OR dea.voltage_level = 5 
            OR dea.voltage_level = 6 OR dea.voltage_level = 7
            OR dea.voltage_level IS NULL );


-- temporary tables for the loop
DROP TABLE IF EXISTS    sandbox.ego_reaosm_m3b_dea_temp CASCADE;
CREATE TABLE            sandbox.ego_reaosm_m3b_dea_temp (
    reaosm_sort bigint NOT NULL,
    id bigint NOT NULL,
    electrical_capacity numeric,
    generation_type text,
    generation_subtype character varying,
    voltage_level character varying,
    subst_id integer,
    geom geometry(Point,3035),
    reaosm_flag character varying,
    CONSTRAINT ego_reaosm_m3b_dea_temp_pkey PRIMARY KEY (reaosm_sort));

CREATE INDEX ego_reaosm_m3b_dea_temp_geom_idx
    ON sandbox.ego_reaosm_m3b_dea_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
--SELECT scenario_log('eGo_REAOSM','v0.1','temp','sandbox','ego_reaosm_m3b_dea_temp','ego_dp_reaosm_m3b.sql',' ');

DROP TABLE IF EXISTS    sandbox.ego_reaosm_m3b_osm_temp CASCADE;
CREATE TABLE            sandbox.ego_reaosm_m3b_osm_temp (
    reaosm_sort bigint NOT NULL,
    id bigint,
    subst_id integer,
    geom geometry(Point,3035),
    CONSTRAINT ego_reaosm_m3b_osm_temp_pkey PRIMARY KEY (reaosm_sort));

CREATE INDEX ego_reaosm_m3b_osm_temp_geom_idx
    ON sandbox.ego_reaosm_m3b_osm_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
--SELECT scenario_log('eGo_REAOSM','v0.1','temp','sandbox','ego_reaosm_m3b_osm_temp','ego_dp_reaosm_m3b.sql',' ');

DROP TABLE IF EXISTS    sandbox.ego_reaosm_m3b_jnt_temp CASCADE;
CREATE TABLE            sandbox.ego_reaosm_m3b_jnt_temp (
    reaosm_sort bigint NOT NULL,
    id bigint,
    reaosm_geom_line geometry(LineString,3035),
    geom geometry(Point,3035),
    CONSTRAINT ego_reaosm_m3b_jnt_temp_pkey PRIMARY KEY (reaosm_sort));

CREATE INDEX ego_reaosm_m3b_jnt_temp_geom_idx
    ON sandbox.ego_reaosm_m3b_jnt_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
--SELECT scenario_log('eGo_REAOSM','v0.1','temp','sandbox','ego_reaosm_m3b_jnt_temp','ego_dp_reaosm_m3b.sql',' ');

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
-- SELECT scenario_log('eGo_REAOSM','v0.1','input','model_draft','ego_osm_sector_per_griddistrict_4_agricultural','ego_dp_reaosm_m3b.sql',' ');

-- loop for grid_district
DO
$$
DECLARE gd integer;
BEGIN
--    FOR gd IN 1..3591   -- subst_id
    FOR gd IN 1..3591   -- subst_id
    LOOP
        EXECUTE '
        INSERT INTO sandbox.ego_reaosm_m3b_dea_temp
            SELECT  row_number() over (ORDER BY electrical_capacity DESC) AS reaosm_sort,
                    *
            FROM    sandbox.ego_reaosm_m3b_a_mview
            WHERE   subst_id =' || gd || ';

        INSERT INTO sandbox.ego_reaosm_m3b_osm_temp
            SELECT  row_number() over (ORDER BY osm_id DESC) AS reaosm_sort,
                    osm_id,
                    subst_id,
                    geom
            FROM    sandbox.ego_pp_osm_deu_power_point_reaosm
            WHERE   rea_method = ''M3b''
                    AND subst_id =' || gd || ';

        INSERT INTO sandbox.ego_reaosm_m3b_osm_temp
            SELECT  COALESCE((
                        SELECT  MAX(reaosm_sort) 
                        FROM    sandbox.ego_reaosm_m3b_osm_temp), ''0'') 
                            + row_number() over (ORDER BY id DESC) AS reaosm_sort,
                    id,
                    subst_id,
                    geom
            FROM    sandbox.ego_osm_sector_per_griddistrict_4_wpa
            WHERE   subst_id =' || gd || ';

        INSERT INTO sandbox.ego_reaosm_m3b_jnt_temp
            SELECT  dea.reaosm_sort,
                    dea.id,
                    ST_MAKELINE(dea.geom,ST_CENTROID(osm.geom)) ::geometry(LineString,3035) AS reaosm_geom_line,
                    osm.geom ::geometry(Point,3035) AS geom    -- NEW LOCATION!
            FROM    sandbox.ego_reaosm_m3b_dea_temp AS dea
            INNER JOIN sandbox.ego_reaosm_m3b_osm_temp AS osm ON (dea.reaosm_sort = osm.reaosm_sort);

        UPDATE      sandbox.ego_dp_res_powerplant_reaosm AS t1
            SET     reaosm_geom_new = t2.reaosm_geom_new,
                    reaosm_geom_line = t2.reaosm_geom_line,
                    reaosm_flag = ''M3b''
            FROM    (SELECT m.id AS id,
                        m.reaosm_geom_line,
                        m.geom AS reaosm_geom_new
                    FROM    sandbox.ego_reaosm_m3b_jnt_temp AS m
                    )AS t2
            WHERE   t1.id = t2.id;

        TRUNCATE TABLE sandbox.ego_reaosm_m3b_dea_temp, sandbox.ego_reaosm_m3b_osm_temp, sandbox.ego_reaosm_m3b_jnt_temp;
        ';
    END LOOP;
END;
$$;




-- M3b result
DROP MATERIALIZED VIEW IF EXISTS    sandbox.ego_reaosm_m3b_mview CASCADE;
CREATE MATERIALIZED VIEW            sandbox.ego_reaosm_m3b_mview AS
    SELECT  dea.*
    FROM    sandbox.ego_dp_res_powerplant_reaosm AS dea
    WHERE   reaosm_flag = 'M3b';

-- create index GIST (geom)
CREATE INDEX ego_reaosm_m3b_mview_geom_idx
    ON sandbox.ego_reaosm_m3b_mview USING gist (geom);

-- create index GIST (rea_geom_line)
CREATE INDEX ego_reaosm_m3b_mview_rea_geom_line_idx
    ON sandbox.ego_reaosm_m3b_mview USING gist (rea_geom_line);

-- create index GIST (rea_geom_new)
CREATE INDEX ego_reaosm_m3b_mview_rea_geom_new_idx
    ON sandbox.ego_reaosm_m3b_mview USING gist (rea_geom_new);	

-- grant (oeuser)
ALTER TABLE sandbox.ego_reaosm_m3b_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
--SELECT scenario_log('eGo_REAOSM','v0.1','output','sandbox','ego_reaosm_m3b_mview','ego_dp_reaosm_m1.sql',' ');


-- M3b rest
DROP MATERIALIZED VIEW IF EXISTS    sandbox.ego_reaosm_m3b_rest_mview CASCADE;
CREATE MATERIALIZED VIEW            sandbox.ego_reaosm_m3b_rest_mview AS
    SELECT  id,
            electrical_capacity,
            generation_type,
            generation_subtype,
            voltage_level,
            subst_id,
            geom,
            reaosm_flag
    FROM    sandbox.ego_dp_res_powerplant_reaosm AS dea
    WHERE   dea.reaosm_flag = 'M3b_rest';

-- create index GIST (geom)
CREATE INDEX ego_reaosm_m3b_rest_mview_geom_idx
    ON sandbox.ego_reaosm_m3b_rest_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE sandbox.ego_reaosm_m3b_rest_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
--SELECT scenario_log('eGo_REAOSM','v0.1','output','sandbox','ego_reaosm_m3b_rest_mview','ego_dp_reaosm_m1.sql',' ');


-- Drop temp
DROP TABLE IF EXISTS    sandbox.ego_reaosm_m3b_dea_temp CASCADE;
DROP TABLE IF EXISTS    sandbox.ego_reaosm_m3b_osm_temp CASCADE;
DROP TABLE IF EXISTS    sandbox.ego_reaosm_m3b_jnt_temp CASCADE;


