/*
census 2011 population per ha 
Extract points with population (>0) from census in mview
Identify population in osm loads

__copyright__ = "tba" 
__license__ = "tba" 
__author__ = "Ludee" 
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','social','destatis_zensus_population_per_ha','setup_zensus_population_per_ha.sql',' ');

-- zensus points with population 
DROP MATERIALIZED VIEW IF EXISTS	social.destatis_zensus_population_per_ha_mview CASCADE;
CREATE MATERIALIZED VIEW         	social.destatis_zensus_population_per_ha_mview AS
	SELECT	zensus.gid ::integer AS gid,
		zensus.population ::numeric(10,0) AS population,
		zensus.geom_point ::geometry(Point,3035) AS geom_point,
		zensus.geom ::geometry(Polygon,3035) AS geom
	FROM	social.destatis_zensus_population_per_ha AS zensus
	WHERE	zensus.population >= 0;
	
-- index (id)
CREATE UNIQUE INDEX  	destatis_zensus_population_per_ha_mview_gid_idx
	ON	social.destatis_zensus_population_per_ha_mview (gid);

-- index gist (geom_point)
CREATE INDEX  	destatis_zensus_population_per_ha_mview_geom_point_idx
	ON    	social.destatis_zensus_population_per_ha_mview USING GIST (geom_point);
    
-- index gist (geom)
CREATE INDEX  	destatis_zensus_population_per_ha_mview_geom_idx
	ON    	social.destatis_zensus_population_per_ha_mview USING GIST (geom);
    
-- grant (oeuser)
ALTER TABLE	social.destatis_zensus_population_per_ha_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW social.destatis_zensus_population_per_ha_mview IS '{
	"Name": "German Census 2011 - Population in 100m grid",
	"Source": [{
		"Name": "Statistisches Bundesamt (Destatis)",
		"URL":  "https://www.destatis.de/DE/Methoden/Zensus_/Zensus.html" }],
	"Reference date": "2011",
	"Date of collection": "03.02.2016",
	"Original file": "https://www.zensus2011.de/SharedDocs/Downloads/DE/Pressemitteilung/DemografischeGrunddaten/csv_Bevoelkerung_100m_Gitter.zip",
	"Spatial resolution": ["Germany"],
	"Description": ["National census in Germany in 2011"],
	"Column": [
		{"Name": "gid",	"Description": "Unique identifier", "Unit": "" },
		{"Name": "grid_id", "Description": "Grid number of source", "Unit": "" },
		{"Name": "x_mp", "Description": "Latitude of centroid in (ETRS89 - LAEA; EPSG:3035)", "Unit": "" },
		{"Name": "y_mp", "Description": "Longitude of centroid in (ETRS89 - LAEA; EPSG:3035)", "Unit": "" },
		{"Name": "population", "Description": "Number of registred residents", "Unit": "human" },
		{"Name": "geom_point", "Description": "Geometry centroid", "Unit": "" },
		{"Name": "geom", "Description": "Geometry", "Unit": "" } ],
	"Changes":[
		{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
		"Date":  "03.02.2016","Comment": "Added Table"},
		{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
		"Date":  "25.10.2016","Comment": "Moved table and add metadata"} ],
	"ToDo": [""],
	"Licence": ["Datenlizenz Deutschland – Namensnennung – Version 2.0"],
	"Instructions for proper use": ["Empfohlene Zitierweise des Quellennachweises: Datenquelle: Statistisches Bundesamt, Wiesbaden, Genesis-Online, <optional> Abrufdatum; Datenlizenz by-2-0. Quellenvermerk bei eigener Berechnung / Darstellung: Datenquelle: Statistisches Bundesamt, Wiesbaden, Genesis-Online, <optional> Abrufdatum; Datenlizenz by-2-0; eigene Berechnung/eigene Darstellung. In elektronischen Werken ist im Quellenverweis dem Begriff (Datenlizenz by-2-0) der Link www.govdata.de/dl-de/by-2-0 als Verknüpfung zu hinterlegen."]
	}' ;
	
-- select description
SELECT obj_description('social.destatis_zensus_population_per_ha_mview' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','social','destatis_zensus_population_per_ha_mview','setup_zensus_population_per_ha.sql',' ');


-- zensus load
DROP TABLE IF EXISTS  	model_draft.ego_social_zensus_load CASCADE;
CREATE TABLE         	model_draft.ego_social_zensus_load (
	id SERIAL NOT NULL,
	gid integer,
	population integer,
	inside_la boolean,
	geom_point geometry(Point,3035),
	geom geometry(Polygon,3035),
	CONSTRAINT ego_social_zensus_load_pkey PRIMARY KEY (id));

-- insert zensus loads
INSERT INTO	model_draft.ego_social_zensus_load (gid,population,inside_la,geom_point,geom)
	SELECT	zensus.gid ::integer,
		zensus.population ::integer,
		'FALSE' ::boolean AS inside_la,
		zensus.geom_point ::geometry(Point,3035),
		zensus.geom ::geometry(Polygon,3035)
	FROM	social.destatis_zensus_population_per_ha_mview AS zensus;

-- index gist (geom_point)
CREATE INDEX  	ego_social_zensus_load_geom_point_idx
	ON	model_draft.ego_social_zensus_load USING GIST (geom_point);

-- index gist (geom)
CREATE INDEX  	ego_social_zensus_load_geom_idx
	ON	model_draft.ego_social_zensus_load USING GIST (geom);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','model_draft','ego_deu_loads_osm','setup_zensus_population_per_ha.sql',' ');
	
-- population in osm loads
UPDATE 	model_draft.ego_social_zensus_load AS t1
	SET  	inside_la = t2.inside_la
	FROM    (
		SELECT	zensus.id AS id,
			'TRUE' ::boolean AS inside_la
		FROM	model_draft.ego_social_zensus_load AS zensus,
			model_draft.ego_deu_loads_osm AS osm
		WHERE  	osm.geom && zensus.geom_point AND
			ST_CONTAINS(osm.geom,zensus.geom_point)
		) AS t2
	WHERE  	t1.id = t2.id;

-- remove identified population
DELETE FROM	model_draft.ego_social_zensus_load AS lp
	WHERE	lp.inside_la IS TRUE;

-- grant (oeuser)
ALTER TABLE	model_draft.ego_social_zensus_load OWNER TO oeuser;	

-- metadata
COMMENT ON TABLE model_draft.ego_social_zensus_load IS '{
    "Name": "ego zensus loads",
    "Source":   [{
	"Name": "open_eGo",
	"URL": "https://github.com/openego/data_processing"}],
    "Reference date": "2016",
    "Date of collection": "02.09.2016",
    "Original file": ["ego_grid_hvmv_substation"],
    "Spatial": [{
	"Resolution": "",
	"Extend": "Germany" }],
    "Description": ["osm laods"],
    "Column":[
        {"Name": "id", "Description": "Unique identifier", "Unit": " " },
        {"Name": "area_ha", "Description": "Area", "Unit": "ha" },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "17.12.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "", 
	"URL": "" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('model_draft.ego_social_zensus_load' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_social_zensus_load','setup_zensus_population_per_ha.sql',' ');


-- cluster from zensus load lattice
DROP TABLE IF EXISTS	model_draft.ego_social_zensus_load_cluster CASCADE;
CREATE TABLE         	model_draft.ego_social_zensus_load_cluster (
	cid serial,
	zensus_sum INT,
	area_ha INT,
	geom geometry(Polygon,3035),
	geom_buffer geometry(Polygon,3035),
	geom_centroid geometry(Point,3035),
	geom_surfacepoint geometry(Point,3035),
	CONSTRAINT ego_social_zensus_load_cluster_pkey PRIMARY KEY (cid));

-- insert cluster
INSERT INTO	model_draft.ego_social_zensus_load_cluster(geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(grid.geom)))).geom ::geometry(Polygon,3035) AS geom
	FROM    model_draft.ego_social_zensus_load AS grid;

-- index gist (geom)
CREATE INDEX	ego_social_zensus_load_cluster_geom_idx
	ON 	model_draft.ego_social_zensus_load_cluster USING GIST (geom);

-- cluster data
UPDATE 	model_draft.ego_social_zensus_load_cluster AS t1
	SET  	zensus_sum = t2.zensus_sum,
		area_ha = t2.area_ha,
		geom_buffer = t2.geom_buffer,
		geom_centroid = t2.geom_centroid,
		geom_surfacepoint = t2.geom_surfacepoint
	FROM    (
		SELECT	cl.cid AS cid,
			SUM(lp.population) AS zensus_sum,
			COUNT(lp.geom) AS area_ha,
			ST_BUFFER(cl.geom, 100) AS geom_buffer,
			ST_Centroid(cl.geom) AS geom_centroid,
			ST_PointOnSurface(cl.geom) AS geom_surfacepoint
		FROM	model_draft.ego_social_zensus_load AS lp,
			model_draft.ego_social_zensus_load_cluster AS cl
		WHERE  	cl.geom && lp.geom AND
			ST_CONTAINS(cl.geom,lp.geom)
		GROUP BY	cl.cid
		ORDER BY	cl.cid
		) AS t2
	WHERE  	t1.cid = t2.cid;

-- index gist (geom_centroid)
CREATE INDEX	ego_social_zensus_load_cluster_geom_centroid_idx
	ON	model_draft.ego_social_zensus_load_cluster USING GIST (geom_centroid);

-- index gist (geom_surfacepoint)
CREATE INDEX	ego_social_zensus_load_cluster_geom_surfacepoint_idx
	ON	model_draft.ego_social_zensus_load_cluster USING GIST (geom_surfacepoint);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_social_zensus_load_cluster OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_social_zensus_load_cluster IS '{
    "Name": "ego zensus loads cluster",
    "Source":   [{
	"Name": "open_eGo",
	"URL": "https://github.com/openego/data_processing"}],
    "Reference date": "2016",
    "Date of collection": "02.09.2016",
    "Original file": ["ego_grid_hvmv_substation"],
    "Spatial": [{
	"Resolution": "",
	"Extend": "Germany" }],
    "Description": ["osm laods"],
    "Column":[
        {"Name": "id", "Description": "Unique identifier", "Unit": " " },
        {"Name": "area_ha", "Description": "Area", "Unit": "ha" },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "17.12.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "", 
	"URL": "" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('model_draft.ego_social_zensus_load_cluster' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_social_zensus_load_cluster','setup_zensus_population_per_ha.sql',' ');


-- zensus stats
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_social_zensus_per_la_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.ego_social_zensus_per_la_mview AS
	SELECT	'zensus_deu' AS name,
		SUM(zensus.population) AS population
	FROM	social.destatis_zensus_population_per_ha_mview AS zensus
	UNION ALL
	SELECT	'zensus_loadpoints' AS name,
		SUM(lp.population) AS population
	FROM	model_draft.ego_social_zensus_load AS lp
	UNION ALL
	SELECT	'zensus_loadpoints_cluster' AS name,
		SUM(cl.zensus_sum) AS population
	FROM	model_draft.ego_social_zensus_load_cluster AS cl;

-- grant (oeuser)
ALTER TABLE	model_draft.ego_social_zensus_per_la_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','output','model_draft','ego_social_zensus_per_la_mview','setup_zensus_population_per_ha.sql',' ');
