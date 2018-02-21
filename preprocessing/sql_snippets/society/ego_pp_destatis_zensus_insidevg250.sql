/*
Zensus 2011 population per ha

Extract points with population (>0) from zensus in mview.
Check if zensus centroid is inside latest vg250 version.
Get all zensus points outside.

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_PP','PP1','input','society','destatis_zensus_population_per_ha','ego_pp_destatis_zensus_insidevg250.sql','none');
SELECT scenario_log('eGo_PP','PP1','input','boundaries','bkg_vg250_1_sta_union_mview','ego_pp_destatis_zensus_insidevg250.sql','none');

/*
-- zensus points with population (includes zensus points outside borders vg250)
DROP MATERIALIZED VIEW IF EXISTS    society.destatis_zensus_population_per_ha_mview CASCADE;
CREATE MATERIALIZED VIEW            society.destatis_zensus_population_per_ha_mview AS
    SELECT  a.gid,
            a.population,
            a.geom_point,
            a.geom
    FROM    society.destatis_zensus_population_per_ha AS a
    WHERE   a.population >= 0 ;

-- index
CREATE UNIQUE INDEX destatis_zensus_population_per_ha_mview_gid_idx
    ON society.destatis_zensus_population_per_ha_mview (gid);

CREATE INDEX destatis_zensus_population_per_ha_mview_geom_point_idx
    ON society.destatis_zensus_population_per_ha_mview USING GIST (geom_point);

CREATE INDEX destatis_zensus_population_per_ha_mview_geom_idx
    ON society.destatis_zensus_population_per_ha_mview USING GIST (geom);

-- access rights
ALTER TABLE society.destatis_zensus_population_per_ha_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW society.destatis_zensus_population_per_ha_mview IS '{ 
    "comment": "eGoPP - Temporary table", 
    "version": "PP1",
    "published": "none" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_PP','PP1','output','society','destatis_zensus_population_per_ha_mview','ego_pp_destatis_zensus_insidevg250.sql','none');
*/


-- zensus points inside Germany (vg250)
DROP TABLE IF EXISTS    model_draft.destatis_zensus_population_per_ha_inside CASCADE;
CREATE TABLE            model_draft.destatis_zensus_population_per_ha_inside (
    gid             integer,
    inside_borders  boolean,
    CONSTRAINT destatis_zensus_population_per_ha_inside_pkey PRIMARY KEY (gid));

-- access rights
ALTER TABLE model_draft.destatis_zensus_population_per_ha_inside OWNER TO oeuser;

-- insert all with inside borders "FALSE"
INSERT INTO model_draft.destatis_zensus_population_per_ha_inside (gid, inside_borders)
    SELECT  gid,
            FALSE
    FROM    society.destatis_zensus_population_per_ha;

-- update "TRUE" if inside borders
UPDATE model_draft.destatis_zensus_population_per_ha_inside AS t1
    SET     inside_borders = TRUE
    FROM    boundaries.bkg_vg250_1_sta_union_mview AS a,
            society.destatis_zensus_population_per_ha AS b
    WHERE   a.geom && b.geom_point AND
            ST_CONTAINS(a.geom,b.geom_point) AND
            t1.gid = b.gid;

-- metadata
COMMENT ON TABLE model_draft.destatis_zensus_population_per_ha_inside IS '{
    "comment": "eGoPP - Temporary table", 
    "version": "PP1",
    "published": "none" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_PP','PP1','output','model_draft','destatis_zensus_population_per_ha_inside','ego_pp_destatis_zensus_insidevg250.sql','none');


-- zensus points with population inside vg250
DROP MATERIALIZED VIEW IF EXISTS    model_draft.destatis_zensus_population_per_ha_invg_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.destatis_zensus_population_per_ha_invg_mview AS
    SELECT  a.gid,
            a.population,
            b.inside_borders,
            a.geom_point,
            a.geom
    FROM    society.destatis_zensus_population_per_ha_mview AS a
            JOIN model_draft.destatis_zensus_population_per_ha_inside AS b ON (a.gid = b.gid)
    WHERE   b.inside_borders = TRUE;

-- index
CREATE UNIQUE INDEX destatis_zensus_population_per_ha_invg_mview_gid_idx
    ON model_draft.destatis_zensus_population_per_ha_invg_mview (gid);

CREATE INDEX destatis_zensus_population_per_ha_invg_mview_geom_p_idx
    ON model_draft.destatis_zensus_population_per_ha_invg_mview USING GIST (geom_point);

CREATE INDEX destatis_zensus_population_per_ha_invg_mview_geom_idx
    ON model_draft.destatis_zensus_population_per_ha_invg_mview USING GIST (geom);

-- access rights
ALTER TABLE model_draft.destatis_zensus_population_per_ha_invg_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.destatis_zensus_population_per_ha_invg_mview IS '{
    "comment": "eGoPP - Temporary table", 
    "version": "PP1",
    "published": "none" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_PP','PP1','output','model_draft','destatis_zensus_population_per_ha_invg_mview','ego_pp_destatis_zensus_insidevg250.sql','none');


-- zensus points with population outside vg250
DROP MATERIALIZED VIEW IF EXISTS    model_draft.destatis_zensus_population_per_ha_outvg_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.destatis_zensus_population_per_ha_outvg_mview AS
    SELECT  a.gid,
            a.population,
            b.inside_borders,
            a.geom_point,
            a.geom
    FROM    society.destatis_zensus_population_per_ha_mview AS a
            JOIN model_draft.destatis_zensus_population_per_ha_inside AS b ON (a.gid = b.gid)
    WHERE   b.inside_borders = FALSE;

-- index
CREATE UNIQUE INDEX destatis_zensus_population_per_ha_outvg_mview_gid_idx
    ON model_draft.destatis_zensus_population_per_ha_outvg_mview (gid);

CREATE INDEX destatis_zensus_population_per_ha_outvg_mview_geom_p_idx
    ON model_draft.destatis_zensus_population_per_ha_outvg_mview USING GIST (geom_point);

CREATE INDEX destatis_zensus_population_per_ha_outvg_mview_geom_idx
    ON model_draft.destatis_zensus_population_per_ha_outvg_mview USING GIST (geom);

-- access rights
ALTER TABLE model_draft.destatis_zensus_population_per_ha_outvg_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.destatis_zensus_population_per_ha_outvg_mview IS '{
    "comment": "eGoPP - Temporary table", 
    "version": "PP1",
    "published": "none" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_PP','PP1','output','model_draft','destatis_zensus_population_per_ha_outvg_mview','ego_pp_destatis_zensus_insidevg250.sql','none');


-- drop
DROP TABLE IF EXISTS    model_draft.destatis_zensus_population_per_ha_inside CASCADE;


/* 
-- statistics
SELECT  'destatis_zensus_population_per_ha (with -1!)' AS name,
        sum(population), 
        count(geom) AS census_count
FROM    society.destatis_zensus_population_per_ha
UNION ALL 
SELECT  'destatis_zensus_population_per_ha_mview' AS name,
        sum(population), 
        count(geom) AS census_count
FROM    society.destatis_zensus_population_per_ha_mview
UNION ALL 
SELECT  'destatis_zensus_population_per_ha_invg_mview' AS name,
        sum(population), 
        count(geom) AS census_count
FROM    model_draft.destatis_zensus_population_per_ha_invg_mview
UNION ALL 
SELECT  'destatis_zensus_population_per_ha_outvg_mview' AS name,
        sum(population), 
        count(geom) AS census_count
FROM    model_draft.destatis_zensus_population_per_ha_outvg_mview
UNION ALL 
SELECT  'ego_demand_la_zensus' AS name,
        sum(population), 
        count(geom) AS census_count
FROM    model_draft.ego_demand_la_zensus
UNION ALL 
SELECT  'ego_demand_la_zensus_cluster' AS name,
        sum(zensus_sum), 
        count(geom) AS census_count
FROM    model_draft.ego_demand_la_zensus_cluster
UNION ALL 
SELECT  'ego_demand_loadarea' AS name,
        sum(zensus_sum) AS census_sum,
        sum(zensus_count) AS census_count
FROM    model_draft.ego_demand_loadarea;
*/
