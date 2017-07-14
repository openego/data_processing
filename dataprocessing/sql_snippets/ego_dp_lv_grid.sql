/*


__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "EL; Ludee"
__contains__	= "http://stackoverflow.com/questions/383692/what-is-json-and-why-would-i-use-it","https://specs.frictionlessdata.io/data-package/"
*/


-- Next Neighbor
DROP TABLE IF EXISTS	model_draft.ego_grid_lv_building_connection CASCADE;
CREATE TABLE         	model_draft.ego_grid_lv_building_connection (
	id	 	serial,
	a_id 		integer,
	b_id 		integer,
	geom_line	geometry(LineString,3035),
	distance	double precision,
	CONSTRAINT ego_grid_lv_building_connection_pkey PRIMARY KEY (id) );

INSERT INTO model_draft.ego_grid_lv_building_connection (a_id,b_id,geom_line,distance)
	SELECT DISTINCT ON (a.gid)
		a.gid,
		b.osm_id,
		ST_ShortestLine(
			ST_ExteriorRing(a.geom) ::geometry(Polygon,3035),
			b.geom ::geometry(LineString,3035)
			) ::geometry(LineString,3035) AS geom_line,
		ST_Distance(ST_ExteriorRing(a.geom),(b.geom))
	FROM 	openstreetmap.osm_deu_polygon_building_mview AS a,	-- fragments
		openstreetmap.osm_deu_line_street_mview AS b		-- target
	WHERE 	ST_DWithin(ST_ExteriorRing(a.geom),(b.geom), 1000) 	-- In a 1 km radius
	ORDER BY a.gid, ST_Distance(ST_ExteriorRing(a.geom),(b.geom));

-- index GIST (geom)
CREATE INDEX  	ego_grid_lv_building_connection_ageom_idx
	ON	model_draft.ego_grid_lv_building_connection USING GIST (geom);

-- index GIST (geom)
CREATE INDEX  	ego_grid_lv_building_connection_geom_line_idx
	ON	model_draft.ego_grid_lv_building_connection USING GIST (geom_line);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_lv_building_connection OWNER TO oeuser;
