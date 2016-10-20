
-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	calc_ego_re.geo_pot_area_dump CASCADE;
CREATE TABLE         	calc_ego_re.geo_pot_area_dump (
		id SERIAL NOT NULL,
		--region_key character varying(12) NOT NULL,
		geom geometry(Polygon,3035),
CONSTRAINT 	geo_pot_area_dump_pkey PRIMARY KEY (id));

-- "Insert pots"   (OK!) 493.000ms =208.706
INSERT INTO     calc_ego_re.geo_pot_area_dump (geom)
	SELECT	(ST_DUMP(ST_MULTI(ST_UNION(
				ST_BUFFER(ST_BUFFER(ST_TRANSFORM(pot.geom,3035),-0,01),0,011)
		)))).geom AS geom
	FROM	calc_ego_re.geo_pot_area AS pot;

CREATE INDEX geo_pot_area_dump_idx
  ON calc_ego_re.geo_pot_area_dump
  USING gist
  (geom);

-- Validate (geom)   (OK!) -> 22.000ms =0
DROP VIEW IF EXISTS	calc_ego_re.geo_pot_area_dump_error_geom_view CASCADE;
CREATE VIEW		calc_ego_re.geo_pot_area_dump_error_geom_view AS 
	SELECT	test.id,
		test.error,
		reason(ST_IsValidDetail(test.geom)) AS error_reason,
		ST_SetSRID(location(ST_IsValidDetail(test.geom)),3035) ::geometry(Point,3035) AS error_location
	FROM	(
		SELECT	source.id AS id,				-- PK
			ST_IsValid(source.geom) AS error,
			source.geom AS geom
		FROM	calc_ego_re.geo_pot_area_dump AS source	-- Table
		) AS test
	WHERE	test.error = FALSE;

-- Drop empty view   (OK!) -> 100ms =1
SELECT f_drop_view('{geo_pot_area_dump_error_geom_view}', 'calc_ego_re');


-- -- -- 

-- "Create Table"   (OK!) 200ms =0
DROP TABLE IF EXISTS  	calc_ego_re.geo_pot_area_per_grid_district CASCADE;
CREATE TABLE         	calc_ego_re.geo_pot_area_per_grid_district (
		id SERIAL NOT NULL,
		subst_id integer,
		area_ha decimal,
		geom geometry(Polygon,3035),
CONSTRAINT 	geo_pot_area_per_grid_district_pkey PRIMARY KEY (id));

-- "Insert pots"   (OK!) 493.000ms =208.706
INSERT INTO     calc_ego_re.geo_pot_area_per_grid_district (area_ha, geom)
	SELECT	ST_AREA(cut.geom)/10000,
		cut.geom ::geometry(Polygon,3035)
	FROM	(SELECT ST_MakeValid((ST_DUMP(ST_MULTI(ST_INTERSECTION(pot.geom,dis.geom)))).geom) AS geom
		FROM	calc_ego_re.geo_pot_area_dump AS pot,
			calc_ego_grid_district.grid_district AS dis
		WHERE	pot.geom && dis.geom
		) AS cut
	WHERE	ST_IsValid(cut.geom) = 't' AND ST_GeometryType(cut.geom) = 'ST_Polygon';

-- Get substation ID   (OK!) 46.000ms =123.862
UPDATE 	calc_ego_re.geo_pot_area_per_grid_district AS t1
SET  	subst_id = t2.subst_id
FROM    (
	SELECT	pot.id AS id,
		gd.subst_id AS subst_id
	FROM	calc_ego_re.geo_pot_area_per_grid_district AS pot,
		calc_ego_grid_district.grid_district AS gd
	WHERE  	gd.geom && pot.geom AND
		ST_CONTAINS(gd.geom,ST_PointOnSurface(pot.geom))
	) AS t2
WHERE  	t1.id = t2.id;

