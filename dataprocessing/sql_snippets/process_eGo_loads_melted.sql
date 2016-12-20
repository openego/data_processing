/*
combine osm and zensus load cluster
collect loads
buffer with 100m
validate geom
fix geoms with error

__copyright__ = "tba" 
__license__ = "tba" 
__author__ = "Ludee" 
*/

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'model_draft' AS schema_name,
	'ego_deu_loads_osm' AS table_name,
	'process_eGo_loads_melted.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_deu_loads_osm' ::regclass) ::json AS metadata
FROM	model_draft.ego_deu_loads_osm;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'model_draft' AS schema_name,
	'ego_social_zensus_load_cluster' AS table_name,
	'process_eGo_loads_melted.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_social_zensus_load_cluster' ::regclass) ::json AS metadata
FROM	model_draft.ego_social_zensus_load_cluster;

-- collect loads
DROP TABLE IF EXISTS	model_draft.ego_demand_load_collect CASCADE;
CREATE TABLE		model_draft.ego_demand_load_collect (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT	ego_demand_load_collect_pkey PRIMARY KEY (id));

-- insert loads OSM
INSERT INTO	model_draft.ego_demand_load_collect (geom)
	SELECT	osm.geom
	FROM	model_draft.ego_deu_loads_osm AS osm;

-- insert loads zensus cluster
INSERT INTO	model_draft.ego_demand_load_collect (geom)
	SELECT	zensus.geom
	FROM	model_draft.ego_social_zensus_load_cluster AS zensus;

-- create index GIST (geom)
CREATE INDEX	ego_demand_load_collect_geom_idx
	ON	model_draft.ego_demand_load_collect USING GIST (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_demand_load_collect TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_demand_load_collect OWNER TO oeuser;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'temp' AS io,
	'model_draft' AS schema_name,
	'ego_demand_load_collect' AS table_name,
	'process_eGo_loads_melted.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_demand_load_collect' ::regclass) ::json AS metadata
FROM	model_draft.ego_demand_load_collect;


-- buffer with 100m
DROP TABLE IF EXISTS	model_draft.ego_demand_load_collect_buffer100 CASCADE;
CREATE TABLE		model_draft.ego_demand_load_collect_buffer100 (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT	ego_demand_load_collect_buffer100_pkey PRIMARY KEY (id));

-- insert buffer
INSERT INTO	model_draft.ego_demand_load_collect_buffer100 (geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(poly.geom, 100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_demand_load_collect AS poly;

-- create index GIST (geom)
CREATE INDEX	ego_demand_load_collect_buffer100_geom_idx
	ON	model_draft.ego_demand_load_collect_buffer100
	USING	GIST (geom);
    
-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_demand_load_collect_buffer100 TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_demand_load_collect_buffer100 OWNER TO oeuser;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'temp' AS io,
	'model_draft' AS schema_name,
	'ego_demand_load_collect_buffer100' AS table_name,
	'process_eGo_loads_melted.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_demand_load_collect_buffer100' ::regclass) ::json AS metadata
FROM	model_draft.ego_demand_load_collect_buffer100;


-- unbuffer with 100m
DROP TABLE IF EXISTS	model_draft.ego_demand_load_melt CASCADE;
CREATE TABLE		model_draft.ego_demand_load_melt (
		id SERIAL,
		geom geometry(Polygon,3035),
CONSTRAINT	ego_demand_load_melt_pkey PRIMARY KEY (id));

-- insert buffer
INSERT INTO	model_draft.ego_demand_load_melt (geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
			ST_BUFFER(buffer.geom, -100)
		)))).geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_demand_load_collect_buffer100 AS buffer
	GROUP BY buffer.id
	ORDER BY buffer.id;

-- create index GIST (geom)
CREATE INDEX	ego_demand_load_melt_geom_idx
	ON	model_draft.ego_demand_load_melt
	USING	GIST (geom);
    
-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_demand_load_melt TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_demand_load_melt OWNER TO oeuser;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'temp' AS io,
	'model_draft' AS schema_name,
	'ego_demand_load_melt' AS table_name,
	'process_eGo_loads_melted.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_demand_load_melt' ::regclass) ::json AS metadata
FROM	model_draft.ego_demand_load_melt;


-- validate geom
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_demand_load_melt_error_geom_mview;
CREATE MATERIALIZED VIEW		model_draft.ego_demand_load_melt_error_geom_mview AS
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
		test.geom ::geometry(Polygon,3035) AS geom
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	model_draft.ego_demand_load_melt AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- create index (id)
CREATE UNIQUE INDEX  	ego_demand_load_melt_error_geom_mview_id_idx
		ON	model_draft.ego_demand_load_melt_error_geom_mview (id);

-- create index GIST (geom)
CREATE INDEX	ego_demand_load_melt_error_geom_mview_geom_idx
	ON	model_draft.ego_demand_load_melt_error_geom_mview
	USING	GIST (geom);
	
-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_demand_load_melt_error_geom_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_demand_load_melt_error_geom_mview OWNER TO oeuser;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'temp' AS io,
	'model_draft' AS schema_name,
	'ego_demand_load_melt_error_geom_mview' AS table_name,
	'process_eGo_loads_melted.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_demand_load_melt_error_geom_mview' ::regclass) ::json AS metadata
FROM	model_draft.ego_demand_load_melt_error_geom_mview;


-- fix geoms with error
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_demand_load_melt_error_geom_fix_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_demand_load_melt_error_geom_fix_mview AS
	SELECT	fix.id AS id,
		ST_IsValid(fix.geom) AS error,
		GeometryType(fix.geom) AS geom_type,
		ST_AREA(fix.geom) AS area,
		fix.geom_buffer ::geometry(POLYGON,3035) AS geom_buffer,
		fix.geom ::geometry(POLYGON,3035) AS geom
	FROM	(
		SELECT	fehler.id AS id,
			ST_BUFFER(fehler.geom, -1) AS geom_buffer,
			(ST_DUMP(ST_BUFFER(ST_BUFFER(fehler.geom, -1), 1))).geom AS geom
		FROM	model_draft.ego_demand_load_melt_error_geom_mview AS fehler
		) AS fix
	ORDER BY fix.id;

-- update fixed geoms
UPDATE 	model_draft.ego_demand_load_melt AS t1
SET	geom = t2.geom
FROM	(
	SELECT	fix.id AS id,
		fix.geom AS geom
	FROM	model_draft.ego_demand_load_melt_error_geom_fix_mview AS fix
	) AS t2
WHERE  	t1.id = t2.id;

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_demand_load_melt_error_geom_fix_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_demand_load_melt_error_geom_fix_mview OWNER TO oeuser;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'temp' AS io,
	'model_draft' AS schema_name,
	'ego_demand_load_melt_error_geom_fix_mview' AS table_name,
	'process_eGo_loads_melted.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_demand_load_melt_error_geom_fix_mview' ::regclass) ::json AS metadata
FROM	model_draft.ego_demand_load_melt_error_geom_fix_mview;


-- check for errors again!
SELECT	test.id AS id,
	test.error AS error,
	reason(ST_IsValidDetail(test.geom)) AS error_reason,
	ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location,
	ST_TRANSFORM(test.geom,3035) ::geometry(Polygon,3035) AS geom
FROM	(
	SELECT	source.id AS id,
		ST_IsValid(source.geom) AS error,
		source.geom ::geometry(Polygon,3035) AS geom
	FROM	model_draft.ego_demand_load_melt AS source
	) AS test
WHERE	test.error = FALSE;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_demand_load_melt' AS table_name,
	'process_eGo_loads_melted.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_demand_load_melt' ::regclass) ::json AS metadata
FROM	model_draft.ego_demand_load_melt;


/* -- drop temp
DROP TABLE IF EXISTS			model_draft.ego_demand_load_collect CASCADE;
DROP TABLE IF EXISTS			model_draft.ego_demand_load_collect_buffer100 CASCADE;
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_demand_load_melt_error_geom_mview;
DROP MATERIALIZED VIEW IF EXISTS	model_draft.ego_demand_load_melt_error_geom_fix_mview CASCADE;
 */