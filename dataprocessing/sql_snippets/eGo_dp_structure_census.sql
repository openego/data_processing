/*
census 2011 population per ha 
Extract points with population (>0) from census in mview

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.5','input','social','destatis_zensus_population_per_ha','eGo_dp_structure_census.sql',' ');

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
SELECT ego_scenario_log('v0.2.5','output','social','destatis_zensus_population_per_ha_mview','eGo_dp_structure_census.sql',' ');
