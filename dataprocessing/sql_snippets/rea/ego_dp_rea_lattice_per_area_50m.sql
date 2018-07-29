/*
Prepare 500m lattice
Lattice on bounding box of Germany with 50m per area:
la  - points inside loadarea

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.4','input','model_draft','ego_grid_mv_griddistrict','ego_dp_rea_lattice_per_area_50m.sql',' ');

-- substation id from mv-griddistrict
UPDATE model_draft.ego_lattice_50m AS t1
    SET subst_id = t2.subst_id
    FROM    (
        SELECT  grid.id,
                gd.subst_id AS subst_id
        FROM    model_draft.ego_lattice_50m AS grid,
                model_draft.ego_grid_mv_griddistrict AS gd
        WHERE   gd.geom && grid.geom AND
                ST_CONTAINS(gd.geom,grid.geom)
        ) AS t2
    WHERE   t1.id = t2.id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.4','input','model_draft','ego_demand_loadarea','ego_dp_rea_lattice_per_area_50m.sql',' ');

-- area type for loadarea (la)
UPDATE model_draft.ego_lattice_50m AS t1
    SET area_type = t2.area_type
    FROM (
        SELECT  grid.id,
                'la' AS area_type
        FROM    model_draft.ego_lattice_50m AS grid,
                model_draft.ego_demand_loadarea AS la
        WHERE   la.geom && grid.geom AND
                ST_CONTAINS(la.geom,grid.geom)
        ) AS t2
    WHERE   t1.id = t2.id;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.4','output','model_draft','ego_lattice_50m','ego_dp_rea_lattice_per_area_50m.sql',' ');


-- mview points inside la
DROP MATERIALIZED VIEW IF EXISTS    model_draft.ego_lattice_50m_la_mview CASCADE;
CREATE MATERIALIZED VIEW            model_draft.ego_lattice_50m_la_mview AS
    SELECT  *
    FROM    model_draft.ego_lattice_50m
    WHERE   area_type = 'la';

-- index gist (geom)
CREATE INDEX ego_lattice_50m_la_mview_geom_idx
    ON model_draft.ego_lattice_50m_la_mview USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_lattice_50m_la_mview OWNER TO oeuser;

-- metadata
SELECT copy_comment_mview('model_draft.ego_lattice_50m','model_draft.ego_lattice_50m_la_mview');

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.4','output','model_draft','ego_lattice_50m_la_mview','ego_dp_rea_lattice_per_area_50m.sql',' ');
