---------- ---------- ----------
---------- --SKRIPT-- OK! 7min
---------- ---------- ----------

/* -- Create schemas for open_eGo
DROP SCHEMA IF EXISTS	calc_ego_substation CASCADE;
CREATE SCHEMA 		calc_ego_substation;

-- Set default privileges for schema
ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_substation GRANT ALL ON TABLES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_substation GRANT ALL ON SEQUENCES TO oeuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA calc_ego_substation GRANT ALL ON FUNCTIONS TO oeuser;

-- Grant all in schema
GRANT ALL ON SCHEMA 	calc_ego_substation TO oeuser WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA calc_ego_substation TO oeuser; */

---------- ---------- ----------
-- Substations 110 (mv)
---------- ---------- ----------

-- -- Substations   (OK!) 2.000ms =3.610
DROP TABLE IF EXISTS	calc_ego_substation.substation_110 CASCADE;
CREATE TABLE		calc_ego_substation.substation_110 AS
	SELECT	sub.id AS subst_id,
		sub.name AS subst_name,
		ST_TRANSFORM(sub.geom,3035) ::geometry(Point,3035) AS geom
	FROM	calc_ego_substation.ego_deu_substations AS sub;

-- Set PK   (OK!) -> 2.000ms =0
ALTER TABLE calc_ego_substation.substation_110
	ADD COLUMN	ags_0 character varying(12),
	ADD PRIMARY KEY (subst_id);

-- Create Index GIST (geom)   (OK!) -> 100ms =0
CREATE INDEX  	substations_110_geom_idx
	ON	calc_ego_substation.substation_110
	USING	GIST (geom);

-- Grant oeuser   (OK!) -> 100ms =0
GRANT ALL ON TABLE 	calc_ego_substation.substation_110 TO oeuser WITH GRANT OPTION;
ALTER TABLE		calc_ego_substation.substation_110 OWNER TO oeuser;