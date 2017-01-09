/*
lattice on bbox of loadarea with 50m per area
la 	- points inside loadarea

__copyright__ = "tba"
__license__ = "tba"
__author__ = "Ludee"
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','input','model_draft','ego_grid_mv_griddistrict','ego_rea_lattice_per_area_50m.sql',' ');

-- substation id from mv-griddistrict
UPDATE 	model_draft.ego_lattice_la_50m AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	grid.id,
			gd.subst_id AS subst_id
		FROM	model_draft.ego_lattice_la_50m AS grid,
			model_draft.ego_grid_mv_griddistrict AS gd
		WHERE  	gd.geom && grid.geom AND
			ST_CONTAINS(gd.geom,grid.geom)
		) AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','input','model_draft','ego_demand_loadarea','ego_rea_lattice_per_area_50m.sql',' ');

-- area type for loadarea (la)
UPDATE 	model_draft.ego_lattice_la_50m AS t1
	SET  	area_type = t2.area_type
	FROM    (
		SELECT	grid.id,
			'la' AS area_type
		FROM	model_draft.ego_lattice_la_50m AS grid,
			model_draft.ego_demand_loadarea AS la
		WHERE  	la.geom && grid.geom AND
			ST_CONTAINS(la.geom,grid.geom)
		) AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_lattice_la_50m','ego_rea_lattice_per_area_50m.sql',' ');


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
ALTER TABLE model_draft.ego_lattice_la_50m_la_mview OWNER TO oeuser;

-- metadata
SELECT copy_comment_mview('model_draft.ego_lattice_la_50m','model_draft.ego_lattice_la_50m_la_mview');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_lattice_la_50m_la_mview','ego_rea_lattice_per_area_50m.sql',' ');
