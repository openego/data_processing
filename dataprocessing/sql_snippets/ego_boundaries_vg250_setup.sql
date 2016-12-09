/* 
Copyright 2016 by open_eGo project
Published under GNU GENERAL PUBLIC LICENSE Version 3 (see https://github.com/openego/data_processing/blob/master/LICENSE)
Authors: Ludwig Hülk; Guido Pleßmann

ego data processing - setup borders
Inputs are german administrative borders (political_boundary.bkg_vg250)
Create mviews with transformed (EPSG:3035) and corrected geometries
Municipalities / Gemeinden are fragmented and cleaned from ringholes (bkg_vg250_6_gem_clean)
 */


-- 1. Nationalstaat (sta) - country (cntry)

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'input' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_1_sta' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_1_sta' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_1_sta;


-- 1. country - mview with tiny buffer because of intersection (in official data)
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_1_sta_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_1_sta_mview AS
	SELECT	vg.reference_date ::text,
		vg.id ::integer,
		vg.bez ::text,
		vg.gf ::double precision,
		ST_AREA(ST_TRANSFORM(vg.geom, 3035)) / 10000 ::double precision AS area_km2,
		ST_MULTI(ST_BUFFER(ST_TRANSFORM(vg.geom,3035),-0.001)) ::geometry(MultiPolygon,3035) AS geom
	FROM	political_boundary.bkg_vg250_1_sta AS vg
	WHERE	vg.reference_date = '2016-01-01'
	ORDER BY vg.id;

-- create index (id)
CREATE UNIQUE INDEX  	bkg_vg250_1_sta_mview_id_idx
		ON	political_boundary.bkg_vg250_1_sta_mview (id);

-- create index GIST (geom)
CREATE INDEX  	bkg_vg250_1_sta_mview_geom_idx
	ON	political_boundary.bkg_vg250_1_sta_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	political_boundary.bkg_vg250_1_sta_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_1_sta_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW political_boundary.bkg_vg250_1_sta_mview IS '{
    "Name": "BKG - Verwaltungsgebiete 1:250.000 - country mview",
    "Source":   [{
	"Name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data",
	"URL": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0"}],
    "Reference date": "2016-01-01",
    "Date of collection": "02.09.2015",
    "Original file": ["vg250_2015-01-01.gk3.shape.ebenen.zip"],
    "Spatial": [{
	"Resolution": "1:250.000",
	"Extend": "Germany; Nationalstaat (sta) - country (cntry)" }],
    "Description": ["Country mview with tiny buffer"],
    "Column":[
        {"Name": "reference_date", "Description": "Reference Year", "Unit": " " },
        {"Name": "id", "Description": "Unique identifier", "Unit": " " },
        {"Name": "bez", "Description": "Bezeichnung der Verwaltungseinheit", "Unit": " " },
	{"Name": "gf", "Description": "Geofaktor", "Unit": " " },
	{"Name": "area_km2", "Description": "Area in km²", "Unit": "km²" },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "16.11.2016", "Comment": "Added metadata" } ],
    "Notes": ["With tiny buffer because of intersection (in official data)"],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('political_boundary.bkg_vg250_1_sta_mview' ::regclass) ::json;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_1_sta_mview' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_1_sta_mview' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_1_sta_mview;


-- 1. country - error geom
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_1_sta_error_geom_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_1_sta_error_geom_mview AS 
	SELECT	sub.id AS id,
		sub.error AS error,
		sub.error_reason AS error_reason,
		ST_SETSRID(location(ST_IsValidDetail(sub.geom)),3035) ::geometry(Point,3035) AS geom
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			reason(ST_IsValidDetail(source.geom)) AS error_reason,
			source.geom AS geom
		FROM	political_boundary.bkg_vg250_1_sta AS source	-- Table
		WHERE	reference_date = '2016-01-01'
		) AS sub
	WHERE	sub.error = FALSE;

-- create index (id)
CREATE UNIQUE INDEX  	bkg_vg250_1_sta_error_geom_mview_id_idx
		ON	political_boundary.bkg_vg250_1_sta_error_geom_mview (id);

-- create index GIST (geom)
CREATE INDEX  	bkg_vg250_1_sta_error_geom_mview_geom_idx
	ON	political_boundary.bkg_vg250_1_sta_error_geom_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	political_boundary.bkg_vg250_1_sta_error_geom_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_1_sta_error_geom_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW political_boundary.bkg_vg250_1_sta_error_geom_mview IS '{
    "Name": "BKG - Verwaltungsgebiete 1:250.000 - country mview errors",
    "Source":   [{
	"Name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data",
	"URL": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0"}],
    "Reference date": "2016-01-01",
    "Date of collection": "02.09.2015",
    "Original file": ["vg250_2015-01-01.gk3.shape.ebenen.zip"],
    "Spatial": [{
	"Resolution": "1:250.000",
	"Extend": "Germany; Nationalstaat (sta) - country (cntry)" }],
    "Description": ["Errors in country border"],
    "Column":[
        {"Name": "id", "Description": "Unique identifier", "Unit": " " },
        {"Name": "error", "Description": "Error", "Unit": " " },
	{"Name": "error_reason", "Description": "Error reason", "Unit": " " },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "16.11.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('political_boundary.bkg_vg250_1_sta_error_geom_mview' ::regclass) ::json;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_1_sta_error_geom_mview' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_1_sta_error_geom_mview' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_1_sta_error_geom_mview;


-- 1. country - union
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_1_sta_union_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_1_sta_union_mview AS
	SELECT	'2016-01-01' ::text AS reference_date,
		'1' ::integer AS id,
		'Bundesrepublik' ::text AS bez,
		ST_AREA(un.geom) / 10000 ::double precision AS area_km2,
		un.geom ::geometry(MultiPolygon,3035) AS geom
	FROM	(SELECT	ST_MakeValid(ST_UNION(ST_TRANSFORM(vg.geom,3035))) ::geometry(MultiPolygon,3035) AS geom
		FROM	political_boundary.bkg_vg250_1_sta AS vg
		WHERE	vg.bez = 'Bundesrepublik' AND reference_date = '2016-01-01'
		) AS un;

-- create index (id)
CREATE UNIQUE INDEX  	bkg_vg250_1_sta_union_mview_id_idx
		ON	political_boundary.bkg_vg250_1_sta_union_mview (id);

-- create index GIST (geom)
CREATE INDEX  	bkg_vg250_1_sta_union_mview_geom_idx
	ON	political_boundary.bkg_vg250_1_sta_union_mview USING gist (geom);
	
-- grant (oeuser)
GRANT ALL ON TABLE	political_boundary.bkg_vg250_1_sta_union_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_1_sta_union_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW political_boundary.bkg_vg250_1_sta_union_mview IS '{
    "Name": "BKG - Verwaltungsgebiete 1:250.000 - country mview union",
    "Source":   [{
	"Name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data",
	"URL": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0"}],
    "Reference date": "2016-01-01",
    "Date of collection": "02.09.2015",
    "Original file": ["vg250_2015-01-01.gk3.shape.ebenen.zip"],
    "Spatial": [{
	"Resolution": "1:250.000",
	"Extend": "Germany; Nationalstaat (sta) - country (cntry)" }],
    "Description": ["Geometry union"],
    "Column":[
        {"Name": "reference_date", "Description": "Reference Year", "Unit": " " },
        {"Name": "id", "Description": "Unique identifier", "Unit": " " },
        {"Name": "bez", "Description": "Bezeichnung der Verwaltungseinheit", "Unit": " " },
	{"Name": "area_km2", "Description": "Area in km²", "Unit": "km²" },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "16.11.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('political_boundary.bkg_vg250_1_sta_union_mview' ::regclass) ::json;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_1_sta_union_mview' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_1_sta_union_mview' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_1_sta_union_mview;


-- 1. state borders - bounding box
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_1_sta_bbox_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_1_sta_bbox_mview AS
	SELECT	'2016-01-01' ::text AS reference_date,
		'1' ::integer AS id,
		'Bundesrepublik' ::text AS bez,
		ST_AREA(un.geom) / 10000 ::double precision AS area_km2,
		un.geom ::geometry(Polygon,3035) AS geom
	FROM	(SELECT	ST_SetSRID(Box2D(vg.geom),3035) ::geometry(Polygon,3035) AS geom
		FROM	political_boundary.bkg_vg250_1_sta_union_mview AS vg
		) AS un;

-- create index (id)
CREATE UNIQUE INDEX  	bkg_vg250_1_sta_bbox_mview_id_idx
		ON	political_boundary.bkg_vg250_1_sta_bbox_mview (id);

-- create index GIST (geom)
CREATE INDEX  	bkg_vg250_1_sta_bbox_mview_geom_idx
	ON	political_boundary.bkg_vg250_1_sta_bbox_mview USING gist (geom);
	
-- grant (oeuser)
GRANT ALL ON TABLE	political_boundary.bkg_vg250_1_sta_bbox_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_1_sta_bbox_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW political_boundary.bkg_vg250_1_sta_bbox_mview IS '{
    "Name": "BKG - Verwaltungsgebiete 1:250.000 - country mview bounding box",
    "Source":   [{
	"Name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data",
	"URL": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0"}],
    "Reference date": "2016-01-01",
    "Date of collection": "02.09.2015",
    "Original file": ["vg250_2015-01-01.gk3.shape.ebenen.zip"],
    "Spatial": [{
	"Resolution": "1:250.000",
	"Extend": "Germany; Nationalstaat (sta) - country (cntry)" }],
    "Description": ["Geometry bounding box"],
    "Column":[
        {"Name": "reference_date", "Description": "Reference Year", "Unit": " " },
        {"Name": "id", "Description": "Unique identifier", "Unit": " " },
        {"Name": "bez", "Description": "Bezeichnung der Verwaltungseinheit", "Unit": " " },
	{"Name": "area_km2", "Description": "Area in km²", "Unit": "km²" },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "16.11.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('political_boundary.bkg_vg250_1_sta_bbox_mview' ::regclass) ::json;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_1_sta_bbox_mview' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_1_sta_bbox_mview' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_1_sta_bbox_mview;

	
-- 2. Bundesland (lan) - federal state (fst)

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'input' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_2_lan' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_2_lan' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_2_lan;

-- 2. federal state - mview with tiny buffer because of intersection (in official data)
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_2_lan_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_2_lan_mview AS
	SELECT	'2016-01-01' ::text AS reference_date,
		lan.ags_0 ::character varying(12) AS ags_0,
		lan.gen ::text AS gen,
		ST_UNION(ST_TRANSFORM(lan.geom,3035)) AS geom
	FROM	(SELECT	vg.ags_0,
			replace( vg.gen, ' (Bodensee)', '') as gen,
			vg.geom
		FROM	political_boundary.bkg_vg250_2_lan AS vg
		WHERE	vg.reference_date = '2016-01-01'
		) AS lan
	GROUP BY lan.ags_0,lan.gen
	ORDER BY lan.ags_0;

-- create index (id)
CREATE UNIQUE INDEX  	bkg_vg250_2_lan_mview_ags_0_idx
		ON	political_boundary.bkg_vg250_2_lan_mview (ags_0);

-- create index GIST (geom)
CREATE INDEX  	bkg_vg250_2_lan_mview_geom_idx
	ON	political_boundary.bkg_vg250_2_lan_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	political_boundary.bkg_vg250_2_lan_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_2_lan_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW political_boundary.bkg_vg250_2_lan_mview IS '{
    "Name": "BKG - Verwaltungsgebiete 1:250.000 - federal state mview",
    "Source":   [{
	"Name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data",
	"URL": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0"}],
    "Reference date": "2016-01-01",
    "Date of collection": "02.09.2015",
    "Original file": ["vg250_2015-01-01.gk3.shape.ebenen.zip"],
    "Spatial": [{
	"Resolution": "1:250.000",
	"Extend": "Germany; Bundesland (lan) - federal state (fst)" }],
    "Description": ["Federal state mview"],
    "Column":[
        {"Name": "reference_date", "Description": "Reference Year", "Unit": " " },
        {"Name": "ags_0", "Description": "Amtlicher Gemeindeschlüssel", "Unit": " " },
        {"Name": "gen", "Description": "Geografischer Name", "Unit": " " },
	{"Name": "area_km2", "Description": "Area in km²", "Unit": "km²" },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "16.11.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('political_boundary.bkg_vg250_2_lan_mview' ::regclass) ::json;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_2_lan_mview' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_2_lan_mview' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_2_lan_mview;


-- 4. Landkreis (krs) - district (dist)

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'input' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_4_krs' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_4_krs' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_4_krs;


-- 4. district - mview 
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_4_krs_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_4_krs_mview AS
	SELECT	vg.reference_date ::text AS reference_date,
		vg.id ::integer AS id,
		vg.gen ::text AS gen,
		vg.bez ::text AS bez,
		vg.nuts ::varchar(5) AS nuts,
		vg.rs_0 ::varchar(12) AS rs_0,
		vg.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(vg.geom) / 10000 ::double precision AS area_km2,
		ST_TRANSFORM(vg.geom,3035) ::geometry(MultiPolygon,3035) AS geom
	FROM	political_boundary.bkg_vg250_4_krs AS vg
	WHERE	vg.reference_date = '2016-01-01'
	ORDER BY vg.id;

-- create index (id)
CREATE UNIQUE INDEX  	bkg_vg250_4_krs_mview_id_idx
		ON	political_boundary.bkg_vg250_4_krs_mview (id);

-- create index GIST (geom)
CREATE INDEX  	bkg_vg250_4_krs_mview_geom_idx
	ON	political_boundary.bkg_vg250_4_krs_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	political_boundary.bkg_vg250_4_krs_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_4_krs_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW political_boundary.bkg_vg250_4_krs_mview IS '{
    "Name": "BKG - Verwaltungsgebiete 1:250.000 - federal state mview",
    "Source":   [{
	"Name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data",
	"URL": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0"}],
    "Reference date": "2016-01-01",
    "Date of collection": "02.09.2015",
    "Original file": ["vg250_2015-01-01.gk3.shape.ebenen.zip"],
    "Spatial": [{
	"Resolution": "1:250.000",
	"Extend": "Germany; Landkreis (krs) - district (dist)" }],
    "Description": ["Federal state mview"],
    "Column":[
        {"Name": "reference_date", "Description": "Reference Year", "Unit": " " },
	{"Name": "id", "Description": "Unique identifier", "Unit": " " },
        {"Name": "gen", "Description": "Geografischer Name", "Unit": " " },
	{"Name": "bez", "Description": "Bezeichnung der Verwaltungseinheit", "Unit": " " },
	{"Name": "nuts", "Description": "Europäischer Statistikschlüssel", "Unit": " " },
	{"Name": "rs_0", "Description": "Aufgefüllter Regionalschlüssel", "Unit": " " },
	{"Name": "ags_0", "Description": "Amtlicher Gemeindeschlüssel", "Unit": " " },
	{"Name": "area_km2", "Description": "Area in km²", "Unit": "km²" },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "16.11.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('political_boundary.bkg_vg250_4_krs_mview' ::regclass) ::json;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_4_krs_mview' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_4_krs_mview' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_4_krs_mview;


-- 6. Gemeinde (gem) - municipality (mun)

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'input' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_6_gem' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_6_gem' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_6_gem;


-- 6. municipality - mview
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_6_gem_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_6_gem_mview AS
	SELECT	vg.reference_date ::text AS reference_date,
		vg.id ::integer AS id,
		vg.gen ::text AS gen,
		vg.bez ::text AS bez,
		vg.bem ::text AS bem,
		vg.nuts ::varchar(5) AS nuts,
		vg.rs_0 ::varchar(12) AS rs_0,
		vg.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(vg.geom) / 1000 ::double precision AS area_ha,
		ST_TRANSFORM(vg.geom,3035) ::geometry(MultiPolygon,3035) AS geom
	FROM	political_boundary.bkg_vg250_6_gem AS vg
	WHERE	vg.reference_date = '2016-01-01'
	ORDER BY vg.id;

-- create index (id)
CREATE UNIQUE INDEX  	bkg_vg250_6_gem_mview_id_idx
		ON	political_boundary.bkg_vg250_6_gem_mview (id);

-- create index GIST (geom)
CREATE INDEX  	bkg_vg250_6_gem_mview_geom_idx
	ON	political_boundary.bkg_vg250_6_gem_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	political_boundary.bkg_vg250_6_gem_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_6_gem_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW political_boundary.bkg_vg250_6_gem_mview IS '{
    "Name": "BKG - Verwaltungsgebiete 1:250.000 - municipality mview",
    "Source":   [{
	"Name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data",
	"URL": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0"}],
    "Reference date": "2016-01-01",
    "Date of collection": "02.09.2015",
    "Original file": ["vg250_2015-01-01.gk3.shape.ebenen.zip"],
    "Spatial": [{
	"Resolution": "1:250.000",
	"Extend": "Germany; Gemeinde (gem) - municipality (mun)" }],
    "Description": ["Municipality mview"],
    "Column":[
        {"Name": "reference_date", "Description": "Reference Year", "Unit": " " },
	{"Name": "id", "Description": "Unique identifier", "Unit": " " },
        {"Name": "gen", "Description": "Geografischer Name", "Unit": " " },
	{"Name": "bez", "Description": "Bezeichnung der Verwaltungseinheit", "Unit": " " },
	{"Name": "nuts", "Description": "Europäischer Statistikschlüssel", "Unit": " " },
	{"Name": "rs_0", "Description": "Aufgefüllter Regionalschlüssel", "Unit": " " },
	{"Name": "ags_0", "Description": "Amtlicher Gemeindeschlüssel", "Unit": " " },
	{"Name": "area_km2", "Description": "Area in km²", "Unit": "km²" },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "16.11.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('political_boundary.bkg_vg250_6_gem_mview' ::regclass) ::json;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_6_gem_mview' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_6_gem_mview' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_6_gem_mview;


-- 6. municipality - error geom
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_6_gem_error_geom_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_6_gem_error_geom_mview AS 
	SELECT	sub.id AS id,
		sub.error AS error,
		sub.error_reason AS error_reason,
		ST_SETSRID(location(ST_IsValidDetail(sub.geom)),3035) ::geometry(Point,3035) AS geom
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			reason(ST_IsValidDetail(source.geom)) AS error_reason,
			source.geom AS geom
		FROM	political_boundary.bkg_vg250_6_gem_mview AS source	-- Table
		WHERE	reference_date = '2016-01-01'
		) AS sub
	WHERE	sub.error = FALSE;

-- create index (id)
CREATE UNIQUE INDEX  	bkg_vg250_6_gem_error_geom_mview_id_idx
		ON	political_boundary.bkg_vg250_6_gem_error_geom_mview (id);

-- create index GIST (geom)
CREATE INDEX  	bkg_vg250_6_gem_error_geom_mview_geom_idx
	ON	political_boundary.bkg_vg250_6_gem_error_geom_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	political_boundary.bkg_vg250_6_gem_error_geom_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_6_gem_error_geom_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW political_boundary.bkg_vg250_6_gem_error_geom_mview IS '{
    "Name": "BKG - Verwaltungsgebiete 1:250.000 - country mview errors",
    "Source":   [{
	"Name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data",
	"URL": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0"}],
    "Reference date": "2016-01-01",
    "Date of collection": "02.09.2015",
    "Original file": ["vg250_2015-01-01.gk3.shape.ebenen.zip"],
    "Spatial": [{
	"Resolution": "1:250.000",
	"Extend": "Germany; Gemeinde (gem) - municipality (mun)" }],
    "Description": ["Errors in country border"],
    "Column":[
        {"Name": "id", "Description": "Unique identifier", "Unit": " " },
        {"Name": "error", "Description": "Error", "Unit": " " },
	{"Name": "error_reason", "Description": "Error reason", "Unit": " " },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "16.11.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('political_boundary.bkg_vg250_6_gem_error_geom_mview' ::regclass) ::json;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_6_gem_error_geom_mview' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_6_gem_error_geom_mview' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_6_gem_error_geom_mview;


-- 6. municipality - dump

-- Sequence
DROP SEQUENCE IF EXISTS 	political_boundary.bkg_vg250_6_gem_dump_mview_id CASCADE;
CREATE SEQUENCE 		political_boundary.bkg_vg250_6_gem_dump_mview_id;

-- Transform bkg_vg250 Gemeinden   (OK!) -> 5.000ms =12.521
DROP MATERIALIZED VIEW IF EXISTS	political_boundary.bkg_vg250_6_gem_dump_mview CASCADE;
CREATE MATERIALIZED VIEW		political_boundary.bkg_vg250_6_gem_dump_mview AS
	SELECT	nextval('political_boundary.bkg_vg250_6_gem_dump_mview_id') AS id,
		vg.id ::integer AS old_id,
		vg.gen ::text AS gen,
		vg.bez ::text AS bez,
		vg.bem ::text AS bem,
		vg.nuts ::varchar(5) AS nuts,
		vg.rs_0 ::varchar(12) AS rs_0,
		vg.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(vg.geom) / 10000 ::double precision AS area_km2,
		ST_MakeValid((ST_DUMP(ST_TRANSFORM(vg.geom,3035))).geom) ::geometry(Polygon,3035) AS geom
	FROM	political_boundary.bkg_vg250_6_gem AS vg
	WHERE	gf = '4' -- Without water
	ORDER BY vg.id;

-- create index (id)
CREATE UNIQUE INDEX  	bkg_vg250_6_gem_dump_mview_id_idx
		ON	political_boundary.bkg_vg250_6_gem_dump_mview (id);

-- create index GIST (geom)
CREATE INDEX  	bkg_vg250_6_gem_dump_mview_geom_idx
	ON	political_boundary.bkg_vg250_6_gem_dump_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	political_boundary.bkg_vg250_6_gem_dump_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		political_boundary.bkg_vg250_6_gem_dump_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW political_boundary.bkg_vg250_6_gem_dump_mview IS '{
    "Name": "BKG - Verwaltungsgebiete 1:250.000 - municipality mview",
    "Source":   [{
	"Name": "Dienstleistungszentrum des Bundes für Geoinformation und Geodäsie - Open Data",
	"URL": "http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=14&gdz_user_id=0"}],
    "Reference date": "2016-01-01",
    "Date of collection": "02.09.2015",
    "Original file": ["vg250_2015-01-01.gk3.shape.ebenen.zip"],
    "Spatial": [{
	"Resolution": "1:250.000",
	"Extend": "Germany; Gemeinde (gem) - municipality (mun)" }],
    "Description": ["Municipality mview dump without water"],
    "Column":[
        {"Name": "reference_date", "Description": "Reference Year", "Unit": " " },
	{"Name": "id", "Description": "Unique identifier", "Unit": " " },
        {"Name": "gen", "Description": "Geografischer Name", "Unit": " " },
	{"Name": "bez", "Description": "Bezeichnung der Verwaltungseinheit", "Unit": " " },
	{"Name": "bem", "Description": "Bemerkung", "Unit": " " },
	{"Name": "nuts", "Description": "Europäischer Statistikschlüssel", "Unit": " " },
	{"Name": "rs_0", "Description": "Aufgefüllter Regionalschlüssel", "Unit": " " },
	{"Name": "ags_0", "Description": "Amtlicher Gemeindeschlüssel", "Unit": " " },
	{"Name": "area_km2", "Description": "Area in km²", "Unit": "km²" },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "16.11.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('political_boundary.bkg_vg250_6_gem_dump_mview' ::regclass) ::json;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'political_boundary' AS schema_name,
	'bkg_vg250_6_gem_dump_mview' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('political_boundary.bkg_vg250_6_gem_dump_mview' ::regclass) ::json AS metadata
FROM	political_boundary.bkg_vg250_6_gem_dump_mview;



-- ego

-- 6. municipality - geom clean of holes
DROP TABLE IF EXISTS	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean CASCADE;
CREATE TABLE		model_draft.ego_political_boundary_bkg_vg250_6_gem_clean (
	id SERIAL,
	old_id integer,
	gen text,
	bez text,
	bem text,
	nuts varchar(5),
	rs_0 varchar(12),
	ags_0 varchar(12),
	area_km2 decimal,
	count_hole integer,
	path integer[],
	is_hole boolean,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_political_boundary_bkg_vg250_6_gem_pkey PRIMARY KEY (id));

-- insert municipalities with rings
INSERT INTO	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean (old_id,gen,bez,bem,nuts,rs_0,ags_0,area_km2,count_hole,path,geom)
	SELECT	dump.id ::integer AS old_id,
		dump.gen ::text AS gen,
		dump.bez ::text AS bez,
		dump.bem ::text AS bem,
		dump.nuts ::varchar(5) AS nuts,
		dump.rs_0 ::varchar(12) AS rs_0,
		dump.ags_0 ::varchar(12) AS ags_0,
		ST_AREA(dump.geom) / 10000 ::decimal AS area_km2,
		dump.count_hole ::integer,
		dump.path ::integer[] AS path,
		dump.geom ::geometry(Polygon,3035) AS geom		
	FROM	(SELECT vg.id,
			vg.gen,
			vg.bez,
			vg.bem,
			vg.nuts,
			vg.rs_0,
			vg.ags_0,
			ST_NumInteriorRings(vg.geom) AS count_hole,
			(ST_DumpRings(vg.geom)).path AS path,
			(ST_DumpRings(vg.geom)).geom AS geom
		FROM	political_boundary.bkg_vg250_6_gem_dump_mview AS vg ) AS dump;

-- create index GIST (geom)
CREATE INDEX  	ego_political_boundary_bkg_vg250_6_gem_clean_geom_idx
	ON	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_political_boundary_bkg_vg250_6_gem_clean OWNER TO oeuser;


-- separate holes
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_political_boundary_bkg_vg250_6_gem_hole_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_political_boundary_bkg_vg250_6_gem_hole_mview AS 
SELECT 	mun.*
FROM	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean AS mun
WHERE	mun.path[1] <> 0;

-- create index (id)
CREATE UNIQUE INDEX  	ego_political_boundary_bkg_vg250_6_gem_hole_mview_id_idx
		ON	model_draft.ego_political_boundary_bkg_vg250_6_gem_hole_mview (id);

-- create index GIST (geom)
CREATE INDEX  	ego_political_boundary_bkg_vg250_6_gem_hole_mview_geom_idx
	ON	model_draft.ego_political_boundary_bkg_vg250_6_gem_hole_mview USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_political_boundary_bkg_vg250_6_gem_hole_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_political_boundary_bkg_vg250_6_gem_hole_mview OWNER TO oeuser;

-- metadata
COMMENT ON MATERIALIZED VIEW model_draft.ego_political_boundary_bkg_vg250_6_gem_hole_mview IS '{
    "Name": "ego municipality holes",
    "Source":   [{
	"Name": "open_eGo",
	"URL": "https://github.com/openego/data_processing"}],
    "Reference date": "2016",
    "Date of collection": "02.09.2016",
    "Original file": ["political_boundary.bkg_vg250_6_gem"],
    "Spatial": [{
	"Resolution": "1:250.000",
	"Extend": "Germany; Gemeinde (gem) - municipality (mun)" }],
    "Description": ["Municipality holes"],
    "Column":[
        {"Name": "id", "Description": "Unique identifier", "Unit": " " },
	{"Name": "old_id", "Description": "vg250 identifier", "Unit": " " },
        {"Name": "gen", "Description": "Geografischer Name", "Unit": " " },
	{"Name": "bez", "Description": "Bezeichnung der Verwaltungseinheit", "Unit": " " },
	{"Name": "bem", "Description": "Bemerkung", "Unit": " " },
	{"Name": "nuts", "Description": "Europäischer Statistikschlüssel", "Unit": " " },
	{"Name": "rs_0", "Description": "Aufgefüllter Regionalschlüssel", "Unit": " " },
	{"Name": "ags_0", "Description": "Amtlicher Gemeindeschlüssel", "Unit": " " },
	{"Name": "area_km2", "Description": "Area in km²", "Unit": "km²" },
	{"Name": "count_hole", "Description": "Number of holes", "Unit": " " },
	{"Name": "path", "Description": "Path number", "Unit": " " },
	{"Name": "hole", "Description": "True if hole", "Unit": " " },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "16.11.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('model_draft.ego_political_boundary_bkg_vg250_6_gem_hole_mview' ::regclass) ::json;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_political_boundary_bkg_vg250_6_gem_hole_mview' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_political_boundary_bkg_vg250_6_gem_hole_mview' ::regclass) ::json AS metadata
FROM	model_draft.ego_political_boundary_bkg_vg250_6_gem_hole_mview;


-- update holes
UPDATE 	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean AS t1
	SET  	is_hole = t2.is_hole
	FROM    (
		SELECT	gem.id AS id,
			'TRUE' ::boolean AS is_hole
		FROM	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean AS gem,
			model_draft.ego_political_boundary_bkg_vg250_6_gem_hole_mview AS hole
		WHERE  	gem.geom = hole.geom
		) AS t2
	WHERE  	t1.id = t2.id;

-- remove holes
DELETE FROM 	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean
WHERE		is_hole IS TRUE OR
		id = '9251' OR id = '8362'; -- Two special cases deleted manualy

-- metadata
COMMENT ON TABLE model_draft.ego_political_boundary_bkg_vg250_6_gem_clean IS '{
    "Name": "ego municipality clean",
    "Source":   [{
	"Name": "open_eGo",
	"URL": "https://github.com/openego/data_processing"}],
    "Reference date": "2016",
    "Date of collection": "02.09.2016",
    "Original file": ["political_boundary.bkg_vg250_6_gem"],
    "Spatial": [{
	"Resolution": "1:250.000",
	"Extend": "Germany; Gemeinde (gem) - municipality (mun)" }],
    "Description": ["Municipality without holes"],
    "Column":[
        {"Name": "id", "Description": "Unique identifier", "Unit": " " },
	{"Name": "old_id", "Description": "vg250 identifier", "Unit": " " },
        {"Name": "gen", "Description": "Geografischer Name", "Unit": " " },
	{"Name": "bez", "Description": "Bezeichnung der Verwaltungseinheit", "Unit": " " },
	{"Name": "bem", "Description": "Bemerkung", "Unit": " " },
	{"Name": "nuts", "Description": "Europäischer Statistikschlüssel", "Unit": " " },
	{"Name": "rs_0", "Description": "Aufgefüllter Regionalschlüssel", "Unit": " " },
	{"Name": "ags_0", "Description": "Amtlicher Gemeindeschlüssel", "Unit": " " },
	{"Name": "area_km2", "Description": "Area in km²", "Unit": "km²" },
	{"Name": "count_hole", "Description": "Number of holes", "Unit": " " },
	{"Name": "path", "Description": "Path number", "Unit": " " },
	{"Name": "hole", "Description": "True if hole", "Unit": " " },
	{"Name": "geom", "Description": "Geometry", "Unit": " " } ],
    "Changes":	[
        {"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "02.09.2015", "Comment": "Created mview" },
	{"Name": "Ludwig Hülk", "Mail": "ludwig.huelk@rl-institut.de",
	"Date":  "16.11.2016", "Comment": "Added metadata" } ],
    "Notes": [""],
    "Licence": [{
	"Name": "GNU GENERAL PUBLIC LICENSE Version 3", 
	"URL": "https://github.com/openego/data_processing/blob/master/LICENSE" }],
    "Instructions for proper use": [" "]
    }' ;

-- select description
SELECT obj_description('model_draft.ego_political_boundary_bkg_vg250_6_gem_clean' ::regclass) ::json;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_political_boundary_bkg_vg250_6_gem_clean' AS table_name,
	'ego_political_boundary_bkg_setup.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_political_boundary_bkg_vg250_6_gem_clean' ::regclass) ::json AS metadata
FROM	model_draft.ego_political_boundary_bkg_vg250_6_gem_clean;


---------- ---------- ----------

CREATE OR REPLACE VIEW political_boundary.bkg_vg250_statistics AS
-- Area Sum
-- 38162814 km²
SELECT	'vg' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
UNION ALL
-- 38141292 km²
SELECT	'deu' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	bez='Bundesrepublik'
UNION ALL
-- 38141292 km²
SELECT	'NOT deu' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	bez='--'
UNION ALL
-- 35718841 km²
SELECT	'land' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	gf='3' OR gf='4'
UNION ALL
-- 35718841 km²
SELECT	'water' ::text AS id,
	SUM(vg.area_km2) ::integer AS area_sum_km2
FROM	political_boundary.bkg_vg250_1_sta_mview AS vg
WHERE	gf='1' OR gf='2';
