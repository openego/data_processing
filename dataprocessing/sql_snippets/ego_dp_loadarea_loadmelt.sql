/*
Melt loads from OSM landuse and Census 2011
Collect loads from both sources.
Buffer collected loads with with 100m.
Unbuffer the collection with 100m.
Validate the melted geometries.
Fix geometries with error.
Check again for errors.

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/

-- collect loads
DROP TABLE IF EXISTS	model_draft.ego_demand_load_collect CASCADE;
CREATE TABLE		model_draft.ego_demand_load_collect (
	id SERIAL,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_demand_load_collect_pkey PRIMARY KEY (id));

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','input','model_draft','ego_demand_la_osm','ego_dp_loadarea_loadmelt.sql',' ');

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','input','model_draft','ego_demand_la_zensus_cluster','ego_dp_loadarea_loadmelt.sql',' ');

-- insert loads OSM
INSERT INTO	model_draft.ego_demand_load_collect (geom)
	SELECT	geom
	FROM	model_draft.ego_demand_la_osm
    ORDER BY gid;

-- insert loads zensus cluster
INSERT INTO	model_draft.ego_demand_load_collect (geom)
	SELECT	geom
	FROM	model_draft.ego_demand_la_zensus_cluster
    ORDER BY cid;

-- index GIST (geom)
CREATE INDEX ego_demand_load_collect_geom_idx
    ON model_draft.ego_demand_load_collect USING GIST (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_load_collect OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_demand_load_collect IS '{
    "comment": "eGoDP - Temporary table", 
    "version": "v0.4.0",
    "published": "none" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','temp','model_draft','ego_demand_load_collect','ego_dp_loadarea_loadmelt.sql',' ');


-- buffer with 100m
DROP TABLE IF EXISTS	model_draft.ego_demand_load_collect_buffer100 CASCADE;
CREATE TABLE		model_draft.ego_demand_load_collect_buffer100 (
	id SERIAL,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_demand_load_collect_buffer100_pkey PRIMARY KEY (id));

-- insert buffer
INSERT INTO	model_draft.ego_demand_load_collect_buffer100 (geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(geom, 100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_demand_load_collect
    ORDER BY id;

-- index GIST (geom)
CREATE INDEX ego_demand_load_collect_buffer100_geom_idx
    ON model_draft.ego_demand_load_collect_buffer100 USING GIST (geom);
    
-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_load_collect_buffer100 OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_demand_load_collect_buffer100 IS '{
    "comment": "eGoDP - Temporary table", 
    "version": "v0.4.0",
    "published": "none" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','temp','model_draft','ego_demand_load_collect_buffer100','ego_dp_loadarea_loadmelt.sql',' ');


-- unbuffer with 99m
DROP TABLE IF EXISTS	model_draft.ego_demand_load_melt CASCADE;
CREATE TABLE		model_draft.ego_demand_load_melt (
	id SERIAL,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_demand_load_melt_pkey PRIMARY KEY (id));

-- insert buffer
INSERT INTO	model_draft.ego_demand_load_melt (geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(buffer.geom, -99)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_demand_load_collect_buffer100 AS buffer
	GROUP BY buffer.id
	ORDER BY buffer.id;

-- index GIST (geom)
CREATE INDEX ego_demand_load_melt_geom_idx
    ON model_draft.ego_demand_load_melt USING GIST (geom);
    
-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_load_melt OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_demand_load_melt IS '{
    "comment": "eGoDP - Temporary table", 
    "version": "v0.4.0",
    "published": "none" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','temp','model_draft','ego_demand_load_melt','ego_dp_loadarea_loadmelt.sql',' ');


-- Validate the melted geometries
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_demand_load_melt_error_geom_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.ego_demand_load_melt_error_geom_mview AS
    SELECT  test.id,
            test.error,
            reason(ST_IsValidDetail(test.geom)) AS error_reason,
            ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
            test.geom ::geometry(Polygon,3035) AS geom
    FROM (
        SELECT  source.id AS id,    -- PK
                ST_IsValid(source.geom) AS error,
                source.geom AS geom
        FROM    model_draft.ego_demand_load_melt AS source  -- Table
        ) AS test
    WHERE   test.error = FALSE;

-- index (id)
CREATE UNIQUE INDEX ego_demand_load_melt_error_geom_mview_id_idx
    ON model_draft.ego_demand_load_melt_error_geom_mview (id);

-- index GIST (geom)
CREATE INDEX ego_demand_load_melt_error_geom_mview_geom_idx
    ON model_draft.ego_demand_load_melt_error_geom_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_load_melt_error_geom_mview OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_demand_load_melt_error_geom_mview IS '{
    "comment": "eGoDP - Temporary table", 
    "version": "v0.4.0",
    "published": "none" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','temp','model_draft','ego_demand_load_melt_error_geom_mview','ego_dp_loadarea_loadmelt.sql',' ');


-- Fix geometries with error
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_demand_load_melt_error_geom_fix_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.ego_demand_load_melt_error_geom_fix_mview AS
    SELECT  fix.id AS id,
            ST_IsValid(fix.geom) AS error,
            GeometryType(fix.geom) AS geom_type,
            ST_AREA(fix.geom) AS area,
            fix.geom_buffer ::geometry(POLYGON,3035) AS geom_buffer,
            fix.geom ::geometry(POLYGON,3035) AS geom
    FROM (
        SELECT  fehler.id AS id,
                ST_BUFFER(fehler.geom, -1) AS geom_buffer,
                (ST_DUMP(ST_BUFFER(ST_BUFFER(fehler.geom, -1), 1))).geom AS geom
        FROM    model_draft.ego_demand_load_melt_error_geom_mview AS fehler
        ) AS fix
    ORDER BY fix.id;

-- index (id)
CREATE UNIQUE INDEX ego_demand_load_melt_error_geom_fix_mview_id_idx
    ON model_draft.ego_demand_load_melt_error_geom_fix_mview (id);

-- index GIST (geom)
CREATE INDEX ego_demand_load_melt_error_geom_fix_mview_geom_idx
    ON model_draft.ego_demand_load_melt_error_geom_fix_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_load_melt_error_geom_fix_mview OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_demand_load_melt_error_geom_fix_mview IS '{
    "comment": "eGoDP - Temporary table", 
    "version": "v0.4.0",
    "published": "none" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','temp','model_draft','ego_demand_load_melt_error_geom_fix_mview','ego_dp_loadarea_loadmelt.sql',' ');


-- update fixed geoms
UPDATE model_draft.ego_demand_load_melt AS t1
    SET geom = t2.geom
    FROM (
        SELECT  fix.id AS id,
                fix.geom AS geom
        FROM    model_draft.ego_demand_load_melt_error_geom_fix_mview AS fix
        ) AS t2
    WHERE   t1.id = t2.id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','output','model_draft','ego_demand_load_melt','ego_dp_loadarea_loadmelt.sql',' ');


-- Check again for errors.
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_demand_load_melt_error_2_geom_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.ego_demand_load_melt_error_2_geom_mview AS
    SELECT  test.id AS id,
            test.error AS error,
            reason(ST_IsValidDetail(test.geom)) AS error_reason,
            ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
            ST_TRANSFORM(test.geom,3035) ::geometry(Polygon,3035) AS geom
    FROM (
        SELECT  source.id AS id,
                ST_IsValid(source.geom) AS error,
                source.geom ::geometry(Polygon,3035) AS geom
        FROM    model_draft.ego_demand_load_melt AS source
        ) AS test
    WHERE   test.error = FALSE;

-- index (id)
CREATE UNIQUE INDEX ego_demand_load_melt_error_2_geom_mview_id_idx
    ON model_draft.ego_demand_load_melt_error_2_geom_mview (id);

-- index GIST (geom)
CREATE INDEX ego_demand_load_melt_error_2_geom_mview_geom_idx
    ON model_draft.ego_demand_load_melt_error_2_geom_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_load_melt_error_2_geom_mview OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_demand_load_melt_error_2_geom_mview IS '{
    "comment": "eGoDP - Temporary table", 
    "version": "v0.4.0",
    "published": "none" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','temp','model_draft','ego_demand_load_melt_error_2_geom_mview','ego_dp_loadarea_loadmelt.sql',' ');


/* -- drop temp
DROP TABLE IF EXISTS                model_draft.ego_demand_load_collect CASCADE;
DROP TABLE IF EXISTS                model_draft.ego_demand_load_collect_buffer100 CASCADE;
DROP TABLE IF EXISTS                model_draft.ego_demand_load_melt CASCADE;
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_demand_load_melt_error_geom_mview CASCADE;
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_demand_load_melt_error_geom_fix_mview CASCADE;
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_demand_load_melt_error_2_geom_mview CASCADE;
 */
