/*
Import DESTATIS zensus 2011 table

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- zensus
CREATE TABLE society.destatis_zensus_population_per_ha (
	gid integer NOT NULL,
	grid_id character varying(254) NOT NULL,
	x_mp numeric(10,0),
	y_mp numeric(10,0),
	population numeric(10,0),
	geom_point geometry(Point,3035),
	geom geometry(Polygon,3035),
	CONSTRAINT destatis_zensus_population_per_ha_pkey PRIMARY KEY (gid));

-- grant (oeuser)
ALTER TABLE society.destatis_zensus_population_per_ha OWNER TO oeuser;

-- metadata
COMMENT ON TABLE  society.destatis_zensus_population_per_ha IS '{
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
	"ToDo": [" "],
	"Licence": ["..."],
	"Instructions for proper use": ["..."]
	}';

SELECT obj_description('society.destatis_zensus_population_per_ha' ::regclass) ::json;

-- index GIST (geom)
CREATE INDEX destatis_zensus_population_per_ha_geom_idx
	ON society.destatis_zensus_population_per_ha USING gist (geom);

-- index GIST (geom_point)
CREATE INDEX destatis_zensus_population_per_ha_geom_point_idx
	ON society.destatis_zensus_population_per_ha USING gist (geom_point);	

-- insert data
INSERT INTO society.destatis_zensus_population_per_ha
	SELECT	pnt.gid,pnt.grid_id,pnt.x_mp,pnt.y_mp,pnt.population,pnt.geom AS geom_point,poly.geom
	FROM	orig_destatis.zensus_population_per_ha AS pnt 
		JOIN orig_destatis.zensus_population_per_ha_grid AS poly ON (pnt.gid=poly.gid);

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','preprocessing','society','destatis_zensus_population_per_ha','ego_pp_destatis_zensus_import.sql','setup zensus table');
