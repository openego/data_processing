
---------- ---------- ---------- ---------- ---------- ----------
-- "Setup"
---------- ---------- ---------- ---------- ---------- ----------

-- "Gemeinde table"   (OK!) -> 100ms =0
DROP TABLE IF EXISTS	orig_geo_vg250.vg250_6_gem_usw CASCADE;
CREATE TABLE			orig_geo_vg250.vg250_6_gem_usw AS
	SELECT	vg.*
	FROM	orig_geo_vg250.vg250_6_gem_mview;
	
-- "Create Index GIST (geom)"   (OK!) -> 150ms =0
CREATE INDEX  	vg250_6_gem_usw_geom_idx
	ON			orig_geo_vg250.vg250_6_gem_usw
	USING		GIST (geom);

-- "Grant oeuser"   (OK!) -> 100ms =0
GRANT ALL ON TABLE	orig_geo_vg250.vg250_6_gem_usw TO oeuser WITH GRANT OPTION;
ALTER TABLE			orig_geo_vg250.vg250_6_gem_usw OWNER TO oeuser;

-- "Set PK"   (OK!) -> 1.000ms =0
ALTER TABLE orig_geo_vg250.vg250_6_gem_usw
	ADD COLUMN usw_sum integer,
	ADD PRIMARY KEY (gid);

-- "usw count"   (OK!) -> 175.000ms =141.962
UPDATE 	orig_geo_vg250.vg250_6_gem_usw AS t1
SET  	usw_sum = t2.usw_sum
FROM	(SELECT	usw.gid AS gid,
				COUNT(usw.geom)::integer AS usw_sum
		FROM	orig_geo_vg250.vg250_6_gem_usw AS gem,
				orig_geo_ego.usw_full AS usw
		WHERE  	gem.geom && usw.geom AND
				ST_CONTAINS(gem.geom,usw.geom)
		)AS t2
WHERE  	t1.gid = t2.gid;

---------- ---------- ---------- ---------- ---------- ----------
-- "I. Gemeinden mit genau einem USW"
---------- ---------- ---------- ---------- ---------- ----------

-- "MView"   (OK!) -> 22.000ms =0
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.vg250_6_gem_usw_1_mview CASCADE;
CREATE MATERIALIZED VIEW			orig_geo_ego.vg250_6_gem_usw_1_mview AS 
	SELECT	usw.*
	FROM	orig_geo_vg250.vg250_6_gem_usw AS usw
	WHERE	usw_sum = '1';

-- "Table USW"   (OK!) -> 1.000ms =0
DROP TABLE IF EXISTS	orig_geo_ego.ego_ms_netzbezirke CASCADE;
CREATE TABLE			orig_geo_ego.ego_ms_netzbezirke AS
	SELECT	usw.id,
			usw.geom
	FROM	orig_geo_ego.usw_full AS usw;

-- "Set PK"   (OK!) -> 1.000ms =0
ALTER TABLE orig_geo_ego.ego_ms_netzbezirke
	ADD COLUMN geom_gem geometry(MultiPolygon,3035),
	ADD PRIMARY KEY (id);
	
-- "usw geom"   (OK!) -> 175.000ms =141.962
UPDATE 	orig_geo_ego.ego_ms_netzbezirke AS t1
SET  	geom_gem = t2.geom_gem
FROM	(SELECT	usw.id AS id,
				gem.geom AS geom_gem
		FROM	orig_geo_vg250.vg250_6_gem_usw AS gem,
				orig_geo_ego.usw_full AS usw
		WHERE  	gem.usw_sum = '1'
		)AS t2
WHERE  	t1.id = t2.id;

---------- ---------- ---------- ---------- ---------- ----------
-- "II. Gemeinden mit mehreren USW"
---------- ---------- ---------- ---------- ---------- ----------

-- "MView"   (OK!) -> 22.000ms =0
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.vg250_6_gem_usw_2_mview CASCADE;
CREATE MATERIALIZED VIEW			orig_geo_ego.vg250_6_gem_usw_2_mview AS 
	SELECT	usw.*
	FROM	orig_geo_vg250.vg250_6_gem_usw AS usw
	WHERE	usw_sum > '1';

---------- ---------- ---------- ---------- ---------- ----------
-- "III. Gemeinden ohne USW"
---------- ---------- ---------- ---------- ---------- ----------

-- "MView"   (OK!) -> 22.000ms =0
DROP MATERIALIZED VIEW IF EXISTS	orig_geo_ego.vg250_6_gem_usw_3_mview CASCADE;
CREATE MATERIALIZED VIEW			orig_geo_ego.vg250_6_gem_usw_3_mview AS 
	SELECT	usw.*
	FROM	orig_geo_vg250.vg250_6_gem_usw AS usw
	WHERE	usw_sum = '0';
