-- EWE Validation

-- substation in EWE   (OK!) 500ms =136
DROP MATERIALIZED VIEW IF EXISTS  	calc_ego_substation.substation_110_ewe_mview CASCADE;
CREATE MATERIALIZED VIEW         	calc_ego_substation.substation_110_ewe_mview AS
	SELECT	subs.*
	FROM	calc_ego_substation.substation_110 AS subs,
		calc_ego_grid_district.ewe_grid_district AS ewe
	WHERE  	ST_TRANSFORM(ewe.geom,3035) && subs.geom AND
		ST_CONTAINS(ST_TRANSFORM(ewe.geom,3035),subs.geom)

-- Create Index GIST (geom)   (OK!) 1.000ms =*
CREATE INDEX	substation_110_ewe_mview_geom_idx
	ON	calc_ego_substation.substation_110_ewe_mview
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =*
GRANT ALL ON TABLE	calc_ego_substation.substation_110_ewe_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_substation.substation_110_ewe_mview OWNER TO oeuser;