/*
census 2011 population per ha 
Extract points with population (>0) from census in mview

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','society','destatis_zensus_population_per_ha','eGo_dp_structure_census.sql',' ');

-- zensus points with population 
DROP MATERIALIZED VIEW IF EXISTS	society.destatis_zensus_population_per_ha_mview CASCADE;
CREATE MATERIALIZED VIEW         	society.destatis_zensus_population_per_ha_mview AS
	SELECT	a.gid 		::integer AS gid,
		a.population 	::numeric(10,0) AS population,
		a.geom_point 	::geometry(Point,3035) AS geom_point,
		a.geom 		::geometry(Polygon,3035) AS geom
	FROM	society.destatis_zensus_population_per_ha AS a
	WHERE	a.population >= 0 ;
	
-- index (id)
CREATE UNIQUE INDEX  	destatis_zensus_population_per_ha_mview_gid_idx
	ON	society.destatis_zensus_population_per_ha_mview (gid);

-- index gist (geom_point)
CREATE INDEX  	destatis_zensus_population_per_ha_mview_geom_point_idx
	ON    	society.destatis_zensus_population_per_ha_mview USING GIST (geom_point);
    
-- index gist (geom)
CREATE INDEX  	destatis_zensus_population_per_ha_mview_geom_idx
	ON    	society.destatis_zensus_population_per_ha_mview USING GIST (geom);
    
-- grant (oeuser)
ALTER TABLE	society.destatis_zensus_population_per_ha_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW society.destatis_zensus_population_per_ha_mview IS '{
	"title": "German Census 2011 - Population in 100m grid",
	"description": "example metadata for example data",
	"language": [ "eng", "ger", "fre" ],
	"reference_date": "2016-01-24",
	"sources": [
		{"name": "eGo dataprocessing", "description": " ", "url": "https://github.com/openego/data_processing", "license": "GNU Affero General Public License Version 3 (AGPL-3.0)", "copyright": "© Reiner Lemoine Institut"},
		{"name": "Statistisches Bundesamt (Destatis) - Zensus2011", "description": " ", "url": "https://www.destatis.de/DE/Methoden/Zensus_/Zensus.html", "license": "Datenlizenz Deutschland – Namensnennung – Version 2.0", "copyright": "Statistisches Bundesamt, Wiesbaden, Genesis-Online, 2016; Datenlizenz by-2-0"} ],
	"spatial": [
		{"extend": "Germany",
		"resolution": "100m"} ],
	"license": [
		{"id": "dl-de/by-2-0",
		"name": "Datenlizenz by-2-0",
		"version": "2.0",
		"url": "www.govdata.de/dl-de/by-2-0",
		"instruction": "Empfohlene Zitierweise des Quellennachweises: Datenquelle: Statistisches Bundesamt, Wiesbaden, Genesis-Online, <optional> Abrufdatum; Datenlizenz by-2-0. Quellenvermerk bei eigener Berechnung / Darstellung: Datenquelle: Statistisches Bundesamt, Wiesbaden, Genesis-Online, <optional> Abrufdatum; Datenlizenz by-2-0; eigene Berechnung/eigene Darstellung. In elektronischen Werken ist im Quellenverweis dem Begriff (Datenlizenz by-2-0) der Link www.govdata.de/dl-de/by-2-0 als Verknüpfung zu hinterlegen.",
		"copyright": "Statistisches Bundesamt, Wiesbaden, Genesis-Online; Datenlizenz by-2-0; eigene Berechnung"} ],
	"contributors": [
		{"Name": "Ludee", "Mail": "", "Date":  "03.02.2016","Comment": "Add table"},
		{"Name": "Ludee", "Mail": "", "Date":  "25.10.2016","Comment": "Move table and add metadata"},
		{"name": "Ludee", "email": "", "date": "21.03.2017", "comment": "Update metadata to 1.1"},
		{"name": "Ludee", "email": " ", "date": "2017-03-21", "comment": "Update metadata to 1.2"} ],
	"resources": [{
		"schema": {
			"fields": [
				{"Name": "gid",	"Description": "Unique identifier", "Unit": "" },
				{"Name": "grid_id", "Description": "Grid number of source", "Unit": "" },
				{"Name": "x_mp", "Description": "Latitude of centroid in (ETRS89 - LAEA; EPSG:3035)", "Unit": "" },
				{"Name": "y_mp", "Description": "Longitude of centroid in (ETRS89 - LAEA; EPSG:3035)", "Unit": "" },
				{"Name": "population", "Description": "Number of registred residents", "Unit": "human" },
				{"Name": "geom_point", "Description": "Geometry centroid", "Unit": "" },
				{"Name": "geom", "Description": "Geometry", "Unit": "" } ]},
		"meta_version": "1.2" }] }';

-- select description
SELECT obj_description('society.destatis_zensus_population_per_ha_mview' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','society','destatis_zensus_population_per_ha_mview','eGo_dp_structure_census.sql',' ');



-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','society','destatis_zensus_population_per_ha','eGo_dp_structure_census.sql',' ');

-- census points inside Germany (vg250)
DROP TABLE IF EXISTS	model_draft.destatis_zensus_population_per_ha_inside CASCADE;
CREATE TABLE		model_draft.destatis_zensus_population_per_ha_inside (
	gid integer,
	inside_borders boolean,
	CONSTRAINT destatis_zensus_population_per_ha_inside_pkey PRIMARY KEY (gid));

-- grant (oeuser)
ALTER TABLE model_draft.destatis_zensus_population_per_ha_inside OWNER TO oeuser;

INSERT INTO	model_draft.destatis_zensus_population_per_ha_inside (gid, inside_borders)
	SELECT	gid,
		FALSE 
	FROM	society.destatis_zensus_population_per_ha;

-- set if inside borders
UPDATE	model_draft.destatis_zensus_population_per_ha_inside AS t1
	SET	inside_borders = TRUE
	FROM	boundaries.bkg_vg250_1_sta_union_mview AS a,
		society.destatis_zensus_population_per_ha AS b
	WHERE  	a.geom && b.geom_point AND
		ST_CONTAINS(a.geom,b.geom_point) AND
		t1.gid = b.gid;

-- metadata
COMMENT ON TABLE model_draft.destatis_zensus_population_per_ha_inside IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.10" }' ;


-- zensus points with population inside vg250
DROP MATERIALIZED VIEW IF EXISTS	model_draft.destatis_zensus_population_per_ha_invg_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.destatis_zensus_population_per_ha_invg_mview AS
	SELECT	a.gid ::integer AS gid,
		a.population ::numeric(10,0) AS population,
		b.inside_borders ::boolean,
		a.geom_point ::geometry(Point,3035) AS geom_point,
		a.geom ::geometry(Polygon,3035) AS geom
	FROM	society.destatis_zensus_population_per_ha AS a
		JOIN model_draft.destatis_zensus_population_per_ha_inside AS b ON (a.gid = b.gid)
	WHERE	a.population >= 0 AND
		b.inside_borders = TRUE;

-- index (id)
CREATE UNIQUE INDEX  	destatis_zensus_population_per_ha_invg_mview_gid_idx
	ON	model_draft.destatis_zensus_population_per_ha_invg_mview (gid);

-- index gist (geom_point)
CREATE INDEX  	destatis_zensus_population_per_ha_invg_mview_geom_p_idx
	ON    	model_draft.destatis_zensus_population_per_ha_invg_mview USING GIST (geom_point);

-- index gist (geom)
CREATE INDEX  	destatis_zensus_population_per_ha_invg_mview_geom_idx
	ON    	model_draft.destatis_zensus_population_per_ha_invg_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.destatis_zensus_population_per_ha_invg_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.destatis_zensus_population_per_ha_invg_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.10" }' ;

-- select description
SELECT obj_description('model_draft.destatis_zensus_population_per_ha_invg_mview' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','destatis_zensus_population_per_ha_invg_mview','eGo_dp_structure_census.sql',' ');



-- zensus points with population outside vg250
DROP MATERIALIZED VIEW IF EXISTS	model_draft.destatis_zensus_population_per_ha_outvg_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.destatis_zensus_population_per_ha_outvg_mview AS
	SELECT	a.gid ::integer AS gid,
		a.population ::numeric(10,0) AS population,
		b.inside_borders ::boolean,
		a.geom_point ::geometry(Point,3035) AS geom_point,
		a.geom ::geometry(Polygon,3035) AS geom
	FROM	society.destatis_zensus_population_per_ha AS a
		JOIN model_draft.destatis_zensus_population_per_ha_inside AS b ON (a.gid = b.gid)
	WHERE	a.population >= 0 AND
		b.inside_borders = FALSE;

-- index (id)
CREATE UNIQUE INDEX  	destatis_zensus_population_per_ha_outvg_mview_gid_idx
	ON	model_draft.destatis_zensus_population_per_ha_outvg_mview (gid);

-- index gist (geom_point)
CREATE INDEX  	destatis_zensus_population_per_ha_outvg_mview_geom_p_idx
	ON    	model_draft.destatis_zensus_population_per_ha_outvg_mview USING GIST (geom_point);

-- index gist (geom)
CREATE INDEX  	destatis_zensus_population_per_ha_outvg_mview_geom_idx
	ON    	model_draft.destatis_zensus_population_per_ha_outvg_mview USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.destatis_zensus_population_per_ha_outvg_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.destatis_zensus_population_per_ha_outvg_mview IS '{
	"comment": "eGoDP - Temporary table",
	"version": "v0.2.10" }' ;

-- select description
SELECT obj_description('model_draft.destatis_zensus_population_per_ha_outvg_mview' ::regclass) ::json;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','destatis_zensus_population_per_ha_outvg_mview','eGo_dp_structure_census.sql',' ');

/* 
-- statistics
SELECT 	'destatis_zensus_population_per_ha (with -1!)' AS name,
	sum(population), 
	count(geom) AS census_count
FROM	society.destatis_zensus_population_per_ha
UNION ALL 
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
SELECT 	'destatis_zensus_population_per_ha_outvg_mview' AS name,
	sum(population), 
	count(geom) AS census_count
FROM	model_draft.destatis_zensus_population_per_ha_outvg_mview
UNION ALL 
SELECT 	'ego_demand_la_zensus' AS name,
	sum(population), 
	count(geom) AS census_count
FROM	model_draft.ego_demand_la_zensus
UNION ALL 
SELECT 	'ego_demand_la_zensus_cluster' AS name,
	sum(zensus_sum), 
	count(geom) AS census_count
FROM	model_draft.ego_demand_la_zensus_cluster
UNION ALL 
SELECT 	'ego_demand_loadarea' AS name,
	sum(zensus_sum) AS census_sum,
	sum(zensus_count) AS census_count
FROM  	model_draft.ego_demand_loadarea; */
