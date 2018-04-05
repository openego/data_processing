/*
Lattice (regular point grid) with 50m
Lattice on bounding box of Germany.

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"
*/

-- table for lattice 50m
DROP TABLE IF EXISTS    model_draft.ego_lattice_50m CASCADE;
CREATE TABLE            model_draft.ego_lattice_50m (
    id SERIAL NOT NULL,
    subst_id integer,
    area_type text,
    geom_box geometry(Polygon,3035),
    geom geometry(Point,3035),
CONSTRAINT 	ego_lattice_50m_pkey PRIMARY KEY (id));

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','input','boundaries','bkg_vg250_1_sta_union_mview','ego_dp_lattice_50m.sql',' ');

-- insert lattice
INSERT INTO     model_draft.ego_lattice_50m (geom_box)
    SELECT  ST_SETSRID(ST_CREATEFISHNET(
            ROUND((ST_ymax(box2d(geom)) - ST_ymin(box2d(geom))) /50)::integer,
            ROUND((ST_xmax(box2d(geom)) - ST_xmin(box2d(geom))) /50)::integer,
            50,
            50,
            ST_xmin (box2d(geom)),
            ST_ymin (box2d(geom))
        ),3035)::geometry(POLYGON,3035) AS geom
    FROM boundaries.bkg_vg250_1_sta_union_mview;

-- index gist (geom_box)
CREATE INDEX ego_lattice_50m_geom_box_idx
    ON model_draft.ego_lattice_50m USING gist (geom_box);

-- centroid
UPDATE model_draft.ego_lattice_50m
    SET geom = ST_CENTROID(geom_box);

-- index gist (geom)
CREATE INDEX ego_lattice_50m_geom_idx
    ON model_draft.ego_lattice_50m USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_lattice_50m OWNER TO oeuser;

-- metadata
COMMENT ON TABLE model_draft.ego_lattice_50m IS '{
    "comment": "eGoDP - Temporary table",
    "version": "v0.4.0" }';

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.0','output','model_draft','ego_lattice_50m','ego_dp_lattice_50m.sql',' ');
