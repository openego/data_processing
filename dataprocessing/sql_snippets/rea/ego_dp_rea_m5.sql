/*
M5 LV to Loadarea
Allocate "solar" with voltage levels "6" & "7" to Loadarea.
There should be no rest! But there is a Rest. Fix this bug @Ludee !

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_dp_supply_res_powerplant','ego_dp_rea_m5.sql',' ');

-- MView M5 DEA 
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_supply_rea_m5_a_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.ego_supply_rea_m5_a_mview AS
    SELECT  id,
            electrical_capacity,
            generation_type,
            generation_subtype,
            voltage_level,
            subst_id,
            ST_TRANSFORM(geom,3035) AS geom,
            rea_flag
    FROM    model_draft.ego_dp_supply_res_powerplant AS dea
    WHERE   (dea.voltage_level = 6 
            OR dea.voltage_level = 7
            OR dea.voltage_level IS NULL)
            AND dea.generation_type = 'solar'
            AND (dea.flag in ('commissioning','constantly')) 
            OR (dea.voltage_level = 7 AND dea.generation_type = 'wind');

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m5_a_mview_geom_idx
    ON model_draft.ego_supply_rea_m5_a_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m5_a_mview OWNER TO oeuser;  

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_supply_rea_m5_a_mview','ego_dp_rea_m5.sql',' ');


-- rea_flag M5
UPDATE model_draft.ego_dp_supply_res_powerplant
    SET rea_flag = 'M5_rest'
    WHERE   (voltage_level = 6 
            OR voltage_level = 7
            OR voltage_level IS NULL)
            AND generation_type = 'solar'
            AND (flag in ('commissioning','constantly'))
            OR (voltage_level = 7 AND generation_type = 'wind')
            AND subst_id IS NOT NULL;


-- temporary tables for the loop
DROP TABLE IF EXISTS    model_draft.ego_supply_rea_m5_dea_temp CASCADE;
CREATE TABLE            model_draft.ego_supply_rea_m5_dea_temp (
    rea_sorted bigint NOT NULL,
    id bigint NOT NULL,
    electrical_capacity numeric,
    generation_type text,
    generation_subtype character varying,
    voltage_level character varying,
    subst_id integer,
    geom geometry(Point,3035),
    rea_flag character varying,
    CONSTRAINT ego_supply_rea_m5_dea_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m5_dea_temp_geom_idx
    ON model_draft.ego_supply_rea_m5_dea_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','temp','model_draft','ego_supply_rea_m5_dea_temp','ego_dp_rea_m5.sql',' ');

DROP TABLE IF EXISTS    model_draft.ego_supply_rea_m5_grid_la_temp CASCADE;
CREATE TABLE            model_draft.ego_supply_rea_m5_grid_la_temp (
    rea_sorted bigint NOT NULL,
    id integer,
    subst_id integer,
    area_type text,
    geom_box geometry(Polygon,3035),
    geom geometry(Point,3035),
    CONSTRAINT ego_supply_rea_m5_grid_la_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m5_grid_la_temp_geom_idx
    ON model_draft.ego_supply_rea_m5_grid_la_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','temp','model_draft','ego_supply_rea_m5_grid_la_temp','ego_dp_rea_m5.sql',' ');

DROP TABLE IF EXISTS    model_draft.ego_supply_rea_m5_jnt_temp CASCADE;
CREATE TABLE            model_draft.ego_supply_rea_m5_jnt_temp (
    rea_sorted bigint NOT NULL,
    id bigint,
    rea_geom_line geometry(LineString,3035),
    geom geometry(Point,3035),
    CONSTRAINT ego_supply_rea_m5_jnt_temp_pkey PRIMARY KEY (rea_sorted));

CREATE INDEX ego_supply_rea_m5_jnt_temp_geom_idx
    ON model_draft.ego_supply_rea_m5_jnt_temp USING gist (geom);

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','temp','model_draft','ego_supply_rea_m5_jnt_temp','ego_dp_rea_m5.sql',' ');


-- loop for grid_district
DO
$$
DECLARE gd integer;
BEGIN
    FOR gd IN 1..3591   -- subst_id
    LOOP
        EXECUTE '
        INSERT INTO model_draft.ego_supply_rea_m5_dea_temp
            SELECT  row_number() over (ORDER BY dea.electrical_capacity DESC)as rea_sorted,
                    dea.*
            FROM    model_draft.ego_supply_rea_m5_a_mview AS dea
            WHERE   dea.subst_id =' || gd || ';

        INSERT INTO model_draft.ego_supply_rea_m5_grid_la_temp
            SELECT  row_number() over (ORDER BY RANDOM())as rea_sorted,
                    la.*
            FROM    model_draft.ego_lattice_50m_la_mview AS la -- INPUT LATTICE
            WHERE   la.subst_id =' || gd || ';

        INSERT INTO model_draft.ego_supply_rea_m5_jnt_temp
            SELECT  dea.rea_sorted,
                    dea.id,
                    ST_MAKELINE(dea.geom,la.geom) ::geometry(LineString,3035) AS rea_geom_line,
                    la.geom ::geometry(Point,3035) AS geom  -- NEW LOCATION!
            FROM    model_draft.ego_supply_rea_m5_dea_temp AS dea
            INNER JOIN model_draft.ego_supply_rea_m5_grid_la_temp AS la ON (dea.rea_sorted = la.rea_sorted);

        UPDATE model_draft.ego_dp_supply_res_powerplant AS t1
            SET rea_geom_new = t2.rea_geom_new,
                rea_geom_line = t2.rea_geom_line,
                rea_flag = ''M5''
            FROM    (SELECT m.id AS id,
                    m.rea_geom_line,
                    m.geom AS rea_geom_new
                    FROM    model_draft.ego_supply_rea_m5_jnt_temp AS m
                    )AS t2
            WHERE   t1.id = t2.id;

        TRUNCATE TABLE  model_draft.ego_supply_rea_m5_dea_temp, 
                        model_draft.ego_supply_rea_m5_grid_la_temp, 
                        model_draft.ego_supply_rea_m5_jnt_temp;
        ';
    END LOOP;
END;
$$;


-- M5 rest
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_supply_rea_m5_rest_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.ego_supply_rea_m5_rest_mview AS
    SELECT  id,
            electrical_capacity,
            generation_type,
            generation_subtype,
            voltage_level,
            subst_id,
            ST_TRANSFORM(geom,3035) AS geom,
            rea_flag
    FROM    model_draft.ego_dp_supply_res_powerplant
    WHERE   rea_flag = 'M5_rest';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m5_rest_mview_geom_idx
    ON model_draft.ego_supply_rea_m5_rest_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m5_rest_mview OWNER TO oeuser;  

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_supply_rea_m5_rest_mview','ego_dp_rea_m5.sql','Should be 0!');


-- Second loop for m5 rest for grid_district
DO
$$
DECLARE gd integer;
BEGIN
    FOR gd IN 1..3591   -- subst_id
    LOOP
        EXECUTE '
        INSERT INTO model_draft.ego_supply_rea_m5_dea_temp
            SELECT  row_number() over (ORDER BY dea.electrical_capacity DESC)as rea_sorted,
                    dea.*
            FROM    model_draft.ego_supply_rea_m5_rest_mview AS dea -- REST!!
            WHERE   dea.subst_id =' || gd || ';

        INSERT INTO model_draft.ego_supply_rea_m5_grid_la_temp
            SELECT  row_number() over (ORDER BY RANDOM())as rea_sorted,
                    la.*
            FROM    model_draft.ego_lattice_50m_la_mview AS la -- INPUT LATTICE
            WHERE   la.subst_id =' || gd || ';

        INSERT INTO model_draft.ego_supply_rea_m5_jnt_temp
            SELECT  dea.rea_sorted,
                    dea.id,
                    ST_MAKELINE(dea.geom,la.geom) ::geometry(LineString,3035) AS rea_geom_line,
                    la.geom ::geometry(Point,3035) AS geom  -- NEW LOCATION!
            FROM    model_draft.ego_supply_rea_m5_dea_temp AS dea
            INNER JOIN model_draft.ego_supply_rea_m5_grid_la_temp AS la ON (dea.rea_sorted = la.rea_sorted);

        UPDATE model_draft.ego_dp_supply_res_powerplant AS t1
            SET rea_geom_new = t2.rea_geom_new,
                rea_geom_line = t2.rea_geom_line,
                rea_flag = ''M5''
            FROM    (SELECT m.id AS id,
                    m.rea_geom_line,
                    m.geom AS rea_geom_new
                    FROM    model_draft.ego_supply_rea_m5_jnt_temp AS m
                    )AS t2
            WHERE   t1.id = t2.id;

        TRUNCATE TABLE  model_draft.ego_supply_rea_m5_dea_temp, 
                        model_draft.ego_supply_rea_m5_grid_la_temp, 
                        model_draft.ego_supply_rea_m5_jnt_temp;
        ';
    END LOOP;
END;
$$;


-- M5 rest
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_supply_rea_m5_rest_2_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.ego_supply_rea_m5_rest_2_mview AS
    SELECT  id,
            electrical_capacity,
            generation_type,
            generation_subtype,
            voltage_level,
            subst_id,
            geom,
            rea_flag
    FROM    model_draft.ego_dp_supply_res_powerplant AS dea
    WHERE   dea.rea_flag = 'M5_rest';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m5_rest_2_mview_geom_idx
    ON model_draft.ego_supply_rea_m5_rest_2_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m5_rest_2_mview OWNER TO oeuser;  

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_supply_rea_m5_rest_2_mview','ego_dp_rea_m5.sql','Should be 0!');


-- M5 result
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_supply_rea_m5_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.ego_supply_rea_m5_mview AS
    SELECT  dea.*
    FROM    model_draft.ego_dp_supply_res_powerplant AS dea
    WHERE   rea_flag = 'M5';

-- create index GIST (geom)
CREATE INDEX ego_supply_rea_m5_mview_geom_idx
    ON model_draft.ego_supply_rea_m5_mview USING gist (geom);

-- create index GIST (rea_geom_line)
CREATE INDEX ego_supply_rea_m5_mview_rea_geom_line_idx
    ON model_draft.ego_supply_rea_m5_mview USING gist (rea_geom_line);

-- create index GIST (rea_geom_new)
CREATE INDEX ego_supply_rea_m5_mview_rea_geom_new_idx
    ON model_draft.ego_supply_rea_m5_mview USING gist (rea_geom_new);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_m5_mview OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_supply_rea_m5_mview','ego_dp_rea_m5.sql',' ');


-- update la_id from loadarea
UPDATE model_draft.ego_dp_supply_res_powerplant AS t1
    SET la_id = t2.la_id
    FROM (SELECT  dea.id AS id,
                la.id AS la_id
        FROM    model_draft.ego_dp_supply_res_powerplant AS dea,
                model_draft.ego_demand_loadarea AS la
        WHERE   la.geom && dea.rea_geom_new AND
            ST_CONTAINS(la.geom,dea.rea_geom_new)
        ) AS t2
    WHERE   t1.id = t2.id;

-- update mvlv_subst_id from loadarea
UPDATE model_draft.ego_dp_supply_res_powerplant AS t1
    SET mvlv_subst_id = t2.mvlv_subst_id
    FROM (SELECT    a.id AS id,
                b.mvlv_subst_id AS mvlv_subst_id
        FROM    model_draft.ego_dp_supply_res_powerplant AS a,
                model_draft.ego_grid_lv_griddistrict AS b
        WHERE   b.geom && a.rea_geom_new AND
                ST_CONTAINS(b.geom,a.rea_geom_new)
        ) AS t2
    WHERE   t1.id = t2.id;

-- Drop temp
DROP TABLE IF EXISTS model_draft.ego_supply_rea_m5_dea_temp CASCADE;
DROP TABLE IF EXISTS model_draft.ego_supply_rea_m5_grid_la_temp CASCADE;
DROP TABLE IF EXISTS model_draft.ego_supply_rea_m5_jnt_temp CASCADE;

DROP MATERIALIZED VIEW IF EXISTS model_draft.ego_supply_rea_m5_a_mview CASCADE;
