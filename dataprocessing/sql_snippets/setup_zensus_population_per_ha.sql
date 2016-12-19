/*
census 2011 population per ha 
Extract points with population (>0) from census in mview
Identify population in osm loads

__copyright__ = "tba" 
__license__ = "tba" 
__author__ = "Ludee" 
*/

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'social' AS schema_name,
	'destatis_zensus_population_per_ha' AS table_name,
	'setup_zensus_population_per_ha.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('social.destatis_zensus_population_per_ha' ::regclass) ::json AS metadata
FROM	social.destatis_zensus_population_per_ha;

-- zensus points with population 
DROP MATERIALIZED VIEW IF EXISTS	social.destatis_zensus_population_per_ha_mview CASCADE;
CREATE MATERIALIZED VIEW         	social.destatis_zensus_population_per_ha_mview AS
	SELECT	zensus.gid ::integer AS gid,
		zensus.population ::numeric(10,0) AS population,
		zensus.geom_point ::geometry(Point,3035) AS geom_point,
		zensus.geom ::geometry(Polygon,3035) AS geom
	FROM	social.destatis_zensus_population_per_ha AS zensus
	WHERE	zensus.population >= 0;
	
-- create index (id)
CREATE UNIQUE INDEX  	destatis_zensus_population_per_ha_mview_gid_idx
		ON	social.destatis_zensus_population_per_ha_mview (gid);

-- create index GIST (geom_point)
CREATE INDEX  	destatis_zensus_population_per_ha_mview_geom_point_idx
    ON    	social.destatis_zensus_population_per_ha_mview USING GIST (geom_point);
    
-- create index GIST (geom)
CREATE INDEX  	destatis_zensus_population_per_ha_mview_geom_idx
    ON    	social.destatis_zensus_population_per_ha_mview USING GIST (geom);
    
-- grant (oeuser)
GRANT ALL ON TABLE 	social.destatis_zensus_population_per_ha_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		social.destatis_zensus_population_per_ha_mview OWNER TO oeuser;

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

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
	SELECT	'0.2.1' AS version,
		'output' AS io,
		'social' AS schema_name,
		'destatis_zensus_population_per_ha_mview' AS table_name,
		'setup_zensus_population_per_ha.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
		obj_description('social.destatis_zensus_population_per_ha_mview' ::regclass) ::json AS metadata
	FROM	social.destatis_zensus_population_per_ha_mview;


-- zensus loads
DROP TABLE IF EXISTS  	model_draft.ego_social_zensus_load CASCADE;
CREATE TABLE         	model_draft.ego_social_zensus_load (
		id SERIAL NOT NULL,
		gid integer,
		population integer,
		inside_la boolean,
		geom_point geometry(Point,3035),
		geom geometry(Polygon,3035),
CONSTRAINT 	ego_social_zensus_load_pkey PRIMARY KEY (id));

-- insert zensus loads
INSERT INTO	model_draft.ego_social_zensus_load (gid,population,inside_la,geom_point,geom)
	SELECT	zensus.gid ::integer,
		zensus.population ::integer,
		'FALSE' ::boolean AS inside_la,
		zensus.geom_point ::geometry(Point,3035),
		zensus.geom ::geometry(Polygon,3035)
	FROM	social.destatis_zensus_population_per_ha_mview AS zensus;

-- create index GIST (geom_point)
CREATE INDEX  	ego_social_zensus_load_geom_point_idx
	ON	model_draft.ego_social_zensus_load USING GIST (geom_point);

-- create index GIST (geom)
CREATE INDEX  	ego_social_zensus_load_geom_idx
	ON	model_draft.ego_social_zensus_load USING GIST (geom);
	
-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'model_draft' AS schema_name,
	'ego_deu_loads_osm' AS table_name,
	'setup_zensus_population_per_ha.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_deu_loads_osm' ::regclass) ::json AS metadata
FROM	model_draft.ego_deu_loads_osm;
	
-- identify population in osm loads
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

/* -- make lattice from population
UPDATE 	model_draft.ego_social_zensus_load AS t1
SET  	geom = t2.geom
FROM    (
	SELECT	lp.id AS id,
		ST_SetSRID((ST_MakeEnvelope(
			ST_X(lp.geom)-50,
			ST_Y(lp.geom)-50,
			ST_X(lp.geom)+50,
			ST_Y(lp.geom)+50)),3035) AS geom
	FROM	model_draft.ego_social_zensus_load AS lp
	) AS t2
WHERE  	t1.id = t2.id; 

-- create index GIST (geom)
CREATE INDEX  	ego_deu_loadcluster_geom_idx
	ON	model_draft.ego_social_zensus_load USING GIST (geom);
*/

-- grant (oeuser)
GRANT ALL ON TABLE 	model_draft.ego_social_zensus_load TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_social_zensus_load OWNER TO oeuser;	

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

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_social_zensus_load' AS table_name,
	'setup_zensus_population_per_ha.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_social_zensus_load' ::regclass) ::json AS metadata
FROM	model_draft.ego_social_zensus_load;


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

-- create index GIST (geom)
CREATE INDEX	ego_social_zensus_load_cluster_geom_idx
	ON	model_draft.ego_social_zensus_load_cluster
	USING	GIST (geom);

-- calculate cluster
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

-- create index GIST (geom)
CREATE INDEX	ego_social_zensus_load_cluster_geom_centroid_idx
	ON	model_draft.ego_social_zensus_load_cluster
	USING	GIST (geom_centroid);

-- create index GIST (geom)
CREATE INDEX	ego_social_zensus_load_cluster_geom_surfacepoint_idx
	ON	model_draft.ego_social_zensus_load_cluster
	USING	GIST (geom_surfacepoint);

-- grant (oeuser)
GRANT ALL ON TABLE 	model_draft.ego_social_zensus_load_cluster TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_social_zensus_load_cluster OWNER TO oeuser;

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


-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_social_zensus_load_cluster' AS table_name,
	'setup_zensus_population_per_ha.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_social_zensus_load_cluster' ::regclass) ::json AS metadata
FROM	model_draft.ego_social_zensus_load_cluster;


---------- ---------- ---------- ---------- ---------- ----------
-- "Create SPF"   2016-04-13 16:22  5s
---------- ---------- ---------- ---------- ---------- ----------

-- -- "Create Table SPF"   (OK!) 2.000ms =406
-- DROP TABLE IF EXISTS  	model_draft.ego_social_zensus_load_cluster_spf;
-- CREATE TABLE         	model_draft.ego_social_zensus_load_cluster_spf AS
-- 	SELECT	lp.*
-- 	FROM	model_draft.ego_social_zensus_load_cluster AS lp,
-- 		orig_geo_vg250.vg250_4_krs_spf_mview AS spf
-- 	WHERE	ST_TRANSFORM(spf.geom,3035) && lp.geom_centroid  AND  
-- 		ST_CONTAINS(ST_TRANSFORM(spf.geom,3035), lp.geom_centroid);
-- 
-- -- "Ad PK"   (OK!) 150ms =0
-- ALTER TABLE	model_draft.ego_social_zensus_load_cluster_spf
-- 	ADD PRIMARY KEY (cid);
-- 
-- -- create index GIST (geom)
-- CREATE INDEX  	ego_social_zensus_load_cluster_spf_geom_idx
-- 	ON	model_draft.ego_social_zensus_load_cluster_spf
-- 	USING	GIST (geom);
-- 
-- -- create index GIST (geom)
-- CREATE INDEX  	ego_social_zensus_load_cluster_spf_geom_surfacepoint_idx
--     ON    	model_draft.ego_social_zensus_load_cluster_spf
--     USING     	GIST (geom_surfacepoint);
-- 
-- -- create index GIST (geom_centroid)
-- CREATE INDEX  	ego_social_zensus_load_cluster_spf_geom_centroid_idx
--     ON    	model_draft.ego_social_zensus_load_cluster_spf
--     USING     	GIST (geom_centroid);
-- 
-- -- create index GIST (geom_buffer)
-- CREATE INDEX  	ego_social_zensus_load_cluster_spf_geom_buffer_idx
--     ON    	model_draft.ego_social_zensus_load_cluster_spf
--     USING     	GIST (geom_buffer);
-- 
-- -- grant (oeuser)
-- GRANT ALL ON TABLE 	model_draft.ego_deu_loads_zensus_cluster_spf TO oeuser WITH GRANT OPTION;
-- ALTER TABLE		model_draft.ego_deu_loads_zensus_cluster_spf OWNER TO oeuser;


-- zensus stats
DROP MATERIALIZED VIEW IF EXISTS	model_draft.zensus_population_per_load_area_stats_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.zensus_population_per_load_area_stats_mview AS
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
GRANT ALL ON TABLE 	model_draft.zensus_population_per_load_area_stats_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.zensus_population_per_load_area_stats_mview OWNER TO oeuser;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'zensus_population_per_load_area_stats_mview' AS table_name,
	'setup_zensus_population_per_ha.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.zensus_population_per_load_area_stats_mview' ::regclass) ::json AS metadata
FROM	model_draft.zensus_population_per_load_area_stats_mview;
