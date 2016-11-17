/* 
Skript to generate regular grid points / lattice for different areas
Starting from a 500m lattice for germany
Entire bounding box with points outside Germany has 2.237.090 points!
Generate lattice with LATTICE_SCRIPT.py
*/ 

/* 
Create a regular 50m grid in Germany (vg250)
*/ 

/* create lattice
-- ego_lattice_deu_50m
DROP TABLE IF EXISTS  	model_draft.ego_lattice_deu_50m CASCADE;
CREATE TABLE         	model_draft.ego_lattice_deu_50m (
	gid 		SERIAL NOT NULL,
	subst_id 	integer,
	area_type 	text,
	geom_poly	geometry(Polygon,3035),
	geom		geometry(Point,3035),
	CONSTRAINT ego_lattice_deu_50m_pkey PRIMARY KEY (gid) );

-- Create lattice
INSERT INTO model_draft.ego_lattice_deu_50m (area_type,geom_poly)
SELECT 	'out' ::text AS area_type,
	ST_SETSRID(ST_CreateFishnet(
		ROUND((ST_ymax(box2d(box.geom)) -  ST_ymin(box2d(box.geom))) /50)::integer,
		ROUND((ST_xmax(box2d(box.geom)) -  ST_xmin(box2d(box.geom))) /50)::integer,
		50,
		50,
		ST_xmin (box2d(box.geom)),
		ST_ymin (box2d(box.geom))
	),3035)::geometry(POLYGON,3035) AS geom_poly
	FROM orig_vg250.vg250_1_sta_union_mview AS box ;

-- Create Index GIST (geom_poly)
CREATE INDEX	ego_lattice_deu_50m_geom_poly_idx
	ON	model_draft.ego_lattice_deu_50m USING GIST (geom_poly);
	
-- Get substation ID from grid districts
UPDATE 	model_draft.ego_lattice_deu_50m
SET  	geom = ST_CENTROID(geom_poly)
WHERE  	gid = gid;
	
-- Create Index GIST (geom)
CREATE INDEX	ego_lattice_deu_50m_geom_idx
	ON	model_draft.ego_lattice_deu_50m USING GIST (geom);

-- Grant oeuser
GRANT ALL ON TABLE	model_draft.ego_lattice_deu_50m TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_lattice_deu_50m OWNER TO oeuser;
 */
 
 
-- Get substation ID from grid districts
UPDATE 	model_draft.ego_lattice_deu_50m AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	grid.gid AS gid,
			gd.subst_id AS subst_id
		FROM	model_draft.ego_lattice_deu_50m AS grid,
			model_draft.ego_grid_mv_griddistrict AS gd
		WHERE  	gd.geom && grid.geom AND
			ST_CONTAINS(gd.geom,grid.geom)
		) AS t2
	WHERE  	t1.gid = t2.gid;

-- Get area type for la
UPDATE 	model_draft.ego_lattice_deu_50m AS t1
	SET  	area_type = t2.area_type
	FROM    (
		SELECT	grid.gid AS gid,
			'la' AS area_type
		FROM	model_draft.ego_lattice_deu_50m AS grid,
			model_draft.ego_demand_loadarea AS la
		WHERE  	la.geom && grid.geom AND
			ST_CONTAINS(la.geom,grid.geom)
		) AS t2
	WHERE  	t1.gid = t2.gid;

-- scenario log
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_lattice_deu_50m' AS table_name,
		'setup_eGo_lattice_per_area.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_lattice_deu_50m;

	
-- MViews 

-- ego_lattice_deu_50m_la
-- Points inside wpa 
DROP MATERIALIZED VIEW IF EXISTS  	model_draft.ego_lattice_deu_50m_la_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.ego_lattice_deu_50m_la_mview AS
	SELECT	gid, subst_id, geom
	FROM	model_draft.ego_lattice_deu_50m
	WHERE	area_type = 'la';

-- Create Index GIST (geom)
CREATE INDEX	ego_lattice_deu_50m_mview_geom_idx
	ON	model_draft.ego_lattice_deu_50m_la_mview USING GIST (geom);

-- Grant oeuser
GRANT ALL ON TABLE	model_draft.ego_lattice_deu_50m_la_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_lattice_deu_50m_la_mview OWNER TO oeuser;

-- scenario log
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_lattice_deu_50m_la_mview' AS table_name,
		'setup_eGo_lattice_per_area.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_lattice_deu_50m_la_mview;

-- metadata
COMMENT ON TABLE model_draft.ego_lattice_deu_50m IS '{
	"Name": "eGo data processing - lattice on load area with 50m",
	"Source": [{
		"Name": "open_eGo",
		"URL":  "https://github.com/openego/data_processing" }],
	"Reference date": "2016",
	"Date of collection": "2016-10-01",
	"Original file": "setup_eGo_create_lattice.sql",
	"Spatial resolution": ["Germany"],
	"Description": ["eGo data processing - regular grid with 50m on load areas"],
	"Column": [
		{"Name": "id", "Description": "Unique identifier", "Unit": "" },
		{"Name": "subst_id", "Description": "Substation ID", "Unit": "" },
		{"Name": "area_type", "Description": "Classify lattice points (la, out)", "Unit": "" },
		{"Name": "geom_poly", "Description": "Geometry polygon", "Unit": "" },
		{"Name": "geom", "Description": "Geometry point", "Unit": "" }],
	"Changes":[
		{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
		"Date":  "01.10.2016", "Comment": "Created table" },
		{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
		"Date":  "12.10.2016", "Comment": "Add metadata" },
		{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
		"Date":  "14.10.2016", "Comment": "Restructured lattice scripts" },
		{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
		"Date":  "17.10.2016", "Comment": "Restructured metadata" } ],
	"ToDo": [""],
	"Licence": ["tba"],
	"Instructions for proper use": [""]
	}' ; 

-- select description
SELECT obj_description('model_draft.ego_lattice_deu_50m' ::regclass) ::json ;