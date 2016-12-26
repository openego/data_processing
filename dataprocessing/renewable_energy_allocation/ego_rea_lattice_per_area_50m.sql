/*
lattice on bbox of loadarea with 50m per area
la 	- points inside loadarea

__copyright__ = "tba"
__license__ = "tba"
__author__ = "Ludee"
*/

-- substation id from mv-griddistrict
UPDATE 	model_draft.ego_lattice_la_50m AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	grid.gid AS gid,
			gd.subst_id AS subst_id
		FROM	model_draft.ego_lattice_la_50m AS grid,
			model_draft.ego_grid_mv_griddistrict AS gd
		WHERE  	gd.geom && grid.geom AND
			ST_CONTAINS(gd.geom,grid.geom)
		) AS t2
	WHERE  	t1.gid = t2.gid;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'model_draft' AS schema_name,
	'ego_grid_mv_griddistrict' AS table_name,
	'ego_rea_lattice_per_area_50m.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_grid_mv_griddistrict' ::regclass) ::json AS metadata
FROM	model_draft.ego_grid_mv_griddistrict;


-- area type for loadarea (la)
UPDATE 	model_draft.ego_lattice_la_50m AS t1
	SET  	area_type = t2.area_type
	FROM    (
		SELECT	grid.gid AS gid,
			'la' AS area_type
		FROM	model_draft.ego_lattice_la_50m AS grid,
			model_draft.ego_demand_loadarea AS la
		WHERE  	la.geom && grid.geom AND
			ST_CONTAINS(la.geom,grid.geom)
		) AS t2
	WHERE  	t1.gid = t2.gid;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'input' AS io,
	'model_draft' AS schema_name,
	'ego_demand_loadarea' AS table_name,
	'ego_rea_lattice_per_area_50m.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_demand_loadarea' ::regclass) ::json AS metadata
FROM	model_draft.ego_demand_loadarea;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_lattice_la_50m' AS table_name,
	'ego_rea_lattice_per_area_50m.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_lattice_la_50m' ::regclass) ::json AS metadata
FROM	model_draft.ego_lattice_la_50m;


-- mview points inside la
DROP MATERIALIZED VIEW IF EXISTS  	model_draft.ego_lattice_la_50m_la_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.ego_lattice_la_50m_la_mview AS
	SELECT	*
	FROM	model_draft.ego_lattice_la_50m
	WHERE	area_type = 'la';

-- index gist (geom)
CREATE INDEX 	ego_lattice_la_50m_la_mview_geom_idx
	ON 	model_draft.ego_lattice_la_50m_la_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_lattice_la_50m_la_mview OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_lattice_la_50m_la_mview 
	IS obj_description('model_draft.ego_lattice_la_50m' ::regclass) ::json;

-- add entry to scenario log table
INSERT INTO	model_draft.ego_scenario_log (version,io,schema_name,table_name,script_name,entries,status,user_name,timestamp,metadata)
SELECT	'0.2.1' AS version,
	'output' AS io,
	'model_draft' AS schema_name,
	'ego_lattice_la_50m_la_mview' AS table_name,
	'ego_rea_lattice_per_area_500m.sql' AS script_name,
	COUNT(*)AS entries,
	'OK' AS status,
	session_user AS user_name,
	NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp,
	obj_description('model_draft.ego_lattice_la_50m_la_mview' ::regclass) ::json AS metadata
FROM	model_draft.ego_lattice_la_50m_la_mview;
