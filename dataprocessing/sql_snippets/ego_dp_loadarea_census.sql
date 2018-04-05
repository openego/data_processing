/*
Loads from Census 2011
Include Census 2011 population per ha.
Identify population in OSM loads.

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','destatis_zensus_population_per_ha_invg_mview','ego_dp_loadarea_census.sql',' ');

-- zensus load
DROP TABLE IF EXISTS  	model_draft.ego_demand_la_zensus CASCADE;
CREATE TABLE         	model_draft.ego_demand_la_zensus (
	id 		SERIAL NOT NULL,
	gid 		integer,
	population 	integer,
	inside_la 	boolean,
	geom_point 	geometry(Point,3035),
	geom 		geometry(Polygon,3035),
	CONSTRAINT ego_demand_la_zensus_pkey PRIMARY KEY (id));

-- insert zensus loads
INSERT INTO	model_draft.ego_demand_la_zensus (gid,population,inside_la,geom_point,geom)
	SELECT	gid ::integer,
		population ::integer,
		'FALSE' ::boolean AS inside_la,
		geom_point ::geometry(Point,3035),
		geom ::geometry(Polygon,3035)
	FROM	model_draft.destatis_zensus_population_per_ha_invg_mview
    ORDER BY gid;

-- index gist (geom_point)
CREATE INDEX  	ego_demand_la_zensus_geom_point_idx
	ON	model_draft.ego_demand_la_zensus USING GIST (geom_point);

-- index gist (geom)
CREATE INDEX  	ego_demand_la_zensus_geom_idx
	ON	model_draft.ego_demand_la_zensus USING GIST (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_demand_la_osm','ego_dp_loadarea_census.sql',' ');
	
-- population in osm loads
UPDATE 	model_draft.ego_demand_la_zensus AS t1
	SET  	inside_la = t2.inside_la
	FROM    (
		SELECT	zensus.id AS id,
			'TRUE' ::boolean AS inside_la
		FROM	model_draft.ego_demand_la_zensus AS zensus,
			model_draft.ego_demand_la_osm AS osm
		WHERE  	osm.geom && zensus.geom_point AND
			ST_CONTAINS(osm.geom,zensus.geom_point)
		) AS t2
	WHERE  	t1.id = t2.id;

-- remove identified population
DELETE FROM	model_draft.ego_demand_la_zensus AS lp
	WHERE	lp.inside_la IS TRUE;

-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_la_zensus OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_demand_la_zensus IS '{
    "comment": "eGoDP - Temporary table", 
    "version": "v0.3.0",
    "published": "none" }';

-- select description
SELECT obj_description('model_draft.ego_demand_la_zensus' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_demand_la_zensus','ego_dp_loadarea_census.sql',' ');


-- cluster from zensus load lattice
DROP TABLE IF EXISTS	model_draft.ego_demand_la_zensus_cluster CASCADE;
CREATE TABLE         	model_draft.ego_demand_la_zensus_cluster (
	cid serial,
	zensus_sum INT,
	area_ha INT,
	geom geometry(Polygon,3035),
	geom_buffer geometry(Polygon,3035),
	geom_centroid geometry(Point,3035),
	geom_surfacepoint geometry(Point,3035),
	CONSTRAINT ego_demand_la_zensus_cluster_pkey PRIMARY KEY (cid));

-- insert cluster
INSERT INTO	model_draft.ego_demand_la_zensus_cluster(geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(geom)))).geom ::geometry(Polygon,3035)
	FROM    model_draft.ego_demand_la_zensus
    ORDER BY gid;

-- index gist (geom)
CREATE INDEX ego_demand_la_zensus_cluster_geom_idx
    ON model_draft.ego_demand_la_zensus_cluster USING GIST (geom);

-- index gist (geom_centroid)
CREATE INDEX ego_demand_la_zensus_cluster_geom_centroid_idx
    ON model_draft.ego_demand_la_zensus_cluster USING GIST (geom_centroid);

-- index gist (geom_surfacepoint)
CREATE INDEX ego_demand_la_zensus_cluster_geom_surfacepoint_idx
    ON model_draft.ego_demand_la_zensus_cluster USING GIST (geom_surfacepoint);

-- grant (oeuser)
ALTER TABLE model_draft.ego_demand_la_zensus_cluster OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_demand_la_zensus_cluster IS '{
    "comment": "eGoDP - Temporary table", 
    "version": "v0.3.0",
    "published": "none" }';

-- insert cluster
INSERT INTO model_draft.ego_demand_la_zensus_cluster(geom)
    SELECT  (ST_DUMP(ST_MULTI(ST_UNION(grid.geom)))).geom ::geometry(Polygon,3035) AS geom
    FROM    model_draft.ego_demand_la_zensus AS grid;

-- cluster data
UPDATE model_draft.ego_demand_la_zensus_cluster AS t1
    SET zensus_sum = t2.zensus_sum,
        area_ha = t2.area_ha,
        geom_buffer = t2.geom_buffer,
        geom_centroid = t2.geom_centroid,
        geom_surfacepoint = t2.geom_surfacepoint
    FROM    (
        SELECT  cl.cid AS cid,
                SUM(lp.population) AS zensus_sum,
                COUNT(lp.geom) AS area_ha,
                ST_BUFFER(cl.geom, 100) AS geom_buffer,
                ST_Centroid(cl.geom) AS geom_centroid,
                ST_PointOnSurface(cl.geom) AS geom_surfacepoint
        FROM    model_draft.ego_demand_la_zensus AS lp,
                model_draft.ego_demand_la_zensus_cluster AS cl
        WHERE   cl.geom && lp.geom AND
                ST_CONTAINS(cl.geom,lp.geom)
        GROUP BY cl.cid
        ORDER BY cl.cid
        ) AS t2
    WHERE   t1.cid = t2.cid;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_demand_la_zensus_cluster','ego_dp_loadarea_census.sql',' ');


-- zensus stats
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_society_zensus_per_la_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.ego_society_zensus_per_la_mview AS
	SELECT 	'destatis_zensus_population_per_ha_mview' AS name,
		sum(population), 
		count(geom) AS census_count
	FROM	society.destatis_zensus_population_per_ha_mview
	UNION ALL 
	SELECT 	'destatis_zensus_population_per_ha_invg_mview' AS name,
		sum(population), 
		count(geom) AS census_count
	FROM	model_draft.destatis_zensus_population_per_ha_invg_mview
	UNION ALL 
	SELECT 	'ego_demand_la_zensus' AS name,
		sum(population), 
		count(geom) AS census_count
	FROM	model_draft.ego_demand_la_zensus
	UNION ALL 
	SELECT 	'ego_demand_la_zensus_cluster' AS name,
		sum(zensus_sum), 
		count(geom) AS census_count
	FROM	model_draft.ego_demand_la_zensus_cluster;

-- grant (oeuser)
ALTER TABLE model_draft.ego_society_zensus_per_la_mview OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_society_zensus_per_la_mview IS '{
    "comment": "eGoDP - Temporary table", 
    "version": "v0.3.0",
    "published": "none" }';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_society_zensus_per_la_mview','ego_dp_loadarea_census.sql',' ');
