/*
lattice on bbox of Germany with 500m per area
wpa 	- points inside wind potential area
la 	- points inside loadarea
x 	- points inside wind potential area and loadarea
out	- points outside area

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_grid_mv_griddistrict','ego_dp_rea_lattice_per_area_500m.sql',' ');

-- substation id from mv-griddistrict
UPDATE 	model_draft.ego_lattice_500m AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	grid.id,
			gd.subst_id
		FROM	model_draft.ego_lattice_500m AS grid,
			model_draft.ego_grid_mv_griddistrict AS gd
		WHERE  	gd.geom && grid.geom AND
			ST_CONTAINS(gd.geom,grid.geom)
		) AS t2
	WHERE  	t1.id = t2.id;

-- area type default outside
UPDATE 	model_draft.ego_lattice_500m AS t1
	SET  	area_type = 'out'
	WHERE	subst_id IS NULL;


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_supply_wpa_per_mvgd','ego_dp_rea_lattice_per_area_500m.sql',' ');
	
-- area type for wind potential area (wpa)
UPDATE 	model_draft.ego_lattice_500m AS t1
	SET  	area_type = t2.area_type
	FROM    (
		SELECT	grid.id,
			'wpa' AS area_type
		FROM	model_draft.ego_lattice_500m AS grid,
			model_draft.ego_supply_wpa_per_mvgd AS wpa
		WHERE  	wpa.geom && grid.geom AND
			ST_CONTAINS(wpa.geom,grid.geom)
		) AS t2
	WHERE  	t1.id = t2.id;
	
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','input','model_draft','ego_demand_loadarea','ego_dp_rea_lattice_per_area_500m.sql',' ');

-- area type for loadarea (la)
UPDATE 	model_draft.ego_lattice_500m AS t1
	SET  	area_type = t2.area_type
	FROM    (
		SELECT	grid.id,
			'la' AS area_type
		FROM	model_draft.ego_lattice_500m AS grid,
			model_draft.ego_demand_loadarea AS la
		WHERE  	la.geom && grid.geom AND
			ST_CONTAINS(la.geom,grid.geom)
		) AS t2
	WHERE  	t1.id = t2.id;


-- area type for wpa and la (x)
UPDATE 	model_draft.ego_lattice_500m AS t1
	SET  	area_type = t2.area_type
	FROM    (
		SELECT	grid.id,
			'x' AS area_type
		FROM	model_draft.ego_lattice_500m AS grid,
			model_draft.ego_demand_loadarea AS la,
			model_draft.ego_supply_wpa_per_mvgd AS wpa
		WHERE  	la.geom && grid.geom AND wpa.geom && grid.geom AND
			ST_CONTAINS(la.geom,grid.geom) AND ST_CONTAINS(wpa.geom,grid.geom)
		) AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_lattice_500m','ego_dp_rea_lattice_per_area_500m.sql',' ');


-- mview points inside wpa
DROP MATERIALIZED VIEW IF EXISTS  	model_draft.ego_lattice_500m_wpa_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.ego_lattice_500m_wpa_mview AS
	SELECT	*
	FROM	model_draft.ego_lattice_500m
	WHERE	area_type = 'wpa';

-- index gist (geom)
CREATE INDEX 	ego_lattice_500m_wpa_mview_geom_idx
	ON 	model_draft.ego_lattice_500m_wpa_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_lattice_500m_wpa_mview OWNER TO oeuser;

-- metadata
SELECT copy_comment_mview('model_draft.ego_lattice_500m','model_draft.ego_lattice_500m_wpa_mview');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','output','model_draft','ego_lattice_500m_wpa_mview','ego_dp_rea_lattice_per_area_500m.sql',' ');


-- mview points inside la
DROP MATERIALIZED VIEW IF EXISTS  	model_draft.ego_lattice_500m_la_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.ego_lattice_500m_la_mview AS
	SELECT	*
	FROM	model_draft.ego_lattice_500m
	WHERE	area_type = 'la';

-- index gist (geom)
CREATE INDEX 	ego_lattice_500m_la_mview_geom_idx
	ON 	model_draft.ego_lattice_500m_la_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_lattice_500m_la_mview OWNER TO oeuser;

-- metadata
SELECT copy_comment_mview('model_draft.ego_lattice_500m','model_draft.ego_lattice_500m_la_mview');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_lattice_500m_la_mview','ego_dp_rea_lattice_per_area_500m.sql',' ');


-- mview points inside wpa and la
DROP MATERIALIZED VIEW IF EXISTS  	model_draft.ego_lattice_500m_x_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.ego_lattice_500m_x_mview AS
	SELECT	*
	FROM	model_draft.ego_lattice_500m
	WHERE	area_type = 'x';

-- index gist (geom)
CREATE INDEX 	ego_lattice_500m_x_mview_geom_idx
	ON 	model_draft.ego_lattice_500m_x_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_lattice_500m_x_mview OWNER TO oeuser;

-- metadata
SELECT copy_comment_mview('model_draft.ego_lattice_500m','model_draft.ego_lattice_500m_x_mview');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_lattice_500m_x_mview','ego_dp_rea_lattice_per_area_500m.sql',' ');


-- mview points outside area
DROP MATERIALIZED VIEW IF EXISTS  	model_draft.ego_lattice_500m_out_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.ego_lattice_500m_out_mview AS
	SELECT	*
	FROM	model_draft.ego_lattice_500m
	WHERE	area_type = 'out';

-- index gist (geom)
CREATE INDEX 	ego_lattice_500m_out_mview_geom_idx
	ON 	model_draft.ego_lattice_500m_out_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_lattice_500m_out_mview OWNER TO oeuser;

-- metadata
SELECT copy_comment_mview('model_draft.ego_lattice_500m','model_draft.ego_lattice_500m_out_mview');

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.6','temp','model_draft','ego_lattice_500m_out_mview','ego_dp_rea_lattice_per_area_500m.sql',' ');
