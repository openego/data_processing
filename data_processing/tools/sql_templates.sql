/*
SQL templates and usefull snippets
Start an SQL script with a comment and infos
*/

-- create a table
DROP TABLE IF EXISTS  	model_draft.template_table CASCADE;
CREATE TABLE         	model_draft.template_table (
	id 		SERIAL NOT NULL,
	base_id 	integer,
	area_type 	text,
	geom_poly	geometry(Polygon,3035),
	geom		geometry(Point,3035),
	CONSTRAINT template_table_pkey PRIMARY KEY (id) ) ;

-- MView (filter and projection)
DROP MATERIALIZED VIEW IF EXISTS  	political_boundary.vg250_6_gem_berlin_mview CASCADE;
CREATE MATERIALIZED VIEW         	political_boundary.vg250_6_gem_berlin_mview AS
	SELECT	gid, gen, ags_0, ST_TRANSFORM(geom,3035) AS geom
	FROM	orig_vg250.vg250_6_gem
	WHERE	gen = 'Berlin';
	
-- insert data (lattice on Berlin)
INSERT INTO model_draft.template_table (area_type,geom_poly)
	SELECT 	'out' ::text AS area_type,
			ST_SETSRID(ST_CreateFishnet(
				ROUND((ST_ymax(box2d(box.geom)) -  ST_ymin(box2d(box.geom))) /500)::integer,
				ROUND((ST_xmax(box2d(box.geom)) -  ST_xmin(box2d(box.geom))) /500)::integer,
				500,
				500,
				ST_xmin (box2d(box.geom)),
				ST_ymin (box2d(box.geom))
			),3035)::geometry(POLYGON,3035) AS geom_poly
	FROM political_boundary.vg250_6_gem_berlin_mview AS box ;

-- create index GIST (geom_poly)
CREATE INDEX	template_table_geom_poly_idx
	ON	model_draft.template_table USING GIST (geom_poly) ;

-- update data (points from polygon)
UPDATE 	model_draft.template_table
	SET  	geom = ST_CENTROID(geom_poly)
	WHERE  	id = id ;

-- create index GIST (geom)
CREATE INDEX	template_table_geom_idx
	ON	model_draft.template_table
	USING	GIST (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.template_table TO oeuser WITH GRANT OPTION;
ALTER TABLE			model_draft.template_table OWNER TO oeuser;

-- update ID from polygon layer
UPDATE 	model_draft.template_table AS t1
SET  	base_id = t2.base_id,
		area_type = 'in'
FROM    (
	SELECT	point.id,
			poly.gid AS base_id		
	FROM	political_boundary.vg250_6_gem_berlin_mview AS poly,
			model_draft.template_table AS point
	WHERE  	poly.geom && point.geom AND
			ST_CONTAINS(poly.geom,point.geom)
		) AS t2
WHERE  	t1.id = t2.id;

-- scenario log
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'template_table' AS table_name,
		'sql_templates.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.template_table;

-- MView (filter and projection)
DROP MATERIALIZED VIEW IF EXISTS  	model_draft.template_table_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.template_table_mview AS
	SELECT	id, base_id, area_type, ST_TRANSFORM(geom,4326) AS geom
	FROM	model_draft.template_table
	WHERE	area_type = 'in';

-- create index GIST (geom)
CREATE INDEX	template_table_mview_geom_idx
	ON	model_draft.template_table_mview USING GIST (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.template_table_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE			model_draft.template_table_mview OWNER TO oeuser;

-- scenario log
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.1' AS version,
		'model_draft' AS schema_name,
		'template_table_mview' AS table_name,
		'sql_templates.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.template_table_mview;

-- metadata
COMMENT ON TABLE model_draft.template_table IS
	'{
	"Name": "Template table for sql snippets",
	"Source": [{
					  "Name": "open_eGo",
					  "URL":  "https://github.com/openego/data_processing" }],
	"Reference date": "2016",
	"Date of collection": "2016-10-15",
	"Original file": "sql_templates.sql",
	"Spatial resolution": ["Germany"],
	"Description": ["The script collects useful sql templates for PostgreSQL and PostGIS"],
	"Column": 	[
					{"Name": "id", "Description": "Unique identifier", "Unit": "" },
					{"Name": "base_id", "Description": "ID of the base layer", "Unit": "" },
					{"Name": "area_type", "Description": "Classify lattice points (in, out)", "Unit": "" },
					{"Name": "geom_poly", "Description": "Geometry polygon", "Unit": "" },
					{"Name": "geom", "Description": "Geometry point", "Unit": "" }
				],
	"Changes":	[
					{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
					"Date":  "15.10.2016", "Comment": "Created script" },
					{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
					"Date":  "15.10.2016", "Comment": "Added metadata" }
				],
	"ToDo": ["Add more examples, "],
	"Licence": ["tba"],
	"Instructions for proper use": [""]
	}' ; 
	
-- select description
SELECT obj_description('model_draft.template_table' ::regclass) ::json ;
	