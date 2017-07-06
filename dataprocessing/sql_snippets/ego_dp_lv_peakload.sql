/*
In progess

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee, jong42"
*/


-- collect and union
DROP TABLE IF EXISTS	model_draft.ego_grid_lv_griddistrict CASCADE;
CREATE TABLE         	model_draft.ego_grid_lv_griddistrict (
	id		integer,
	mvlv_subst_id	integer,
	subst_id	integer,
	la_id 		integer,
	nn		boolean,
	subst_cnt	integer,
	zensus_sum 	integer,
	zensus_count 	integer,
	zensus_density 		double precision,
	population_density 	double precision,
	area_ha 		double precision,
	sector_area_residential 	double precision,
	sector_area_retail 		double precision,
	sector_area_industrial 		double precision,
	sector_area_agricultural 	double precision,
	sector_area_sum 	double precision,
	sector_share_residential 	double precision,
	sector_share_retail 		double precision,
	sector_share_industrial 	double precision,
	sector_share_agricultural 	double precision,
	sector_share_sum 	double precision,
	sector_count_residential 	integer,
	sector_count_retail 		integer,
	sector_count_industrial 	integer,
	sector_count_agricultural 	integer,
	sector_count_sum 	integer,
	sector_consumption_residential 	double precision,
	sector_consumption_retail 	double precision,
	sector_consumption_industrial 	double precision,
	sector_consumption_agricultural double precision,
	sector_consumption_sum 	double precision,
	sector_peakload_residential 	double precision,
	sector_peakload_retail 		double precision,
	sector_peakload_industrial 	double precision,
	sector_peakload_agricultural 	double precision,
	geom		geometry(MultiPolygon,3035),
	CONSTRAINT ego_grid_lv_griddistrict_pkey PRIMARY KEY (id) );

-- grant (oeuser)
ALTER TABLE	model_draft.ego_grid_lv_griddistrict OWNER TO oeuser;

-- index GIST (geom)
CREATE INDEX	ego_grid_lv_griddistrict_gidx
	ON	model_draft.ego_grid_lv_griddistrict USING GIST (geom);

-- insert
INSERT INTO	model_draft.ego_grid_lv_griddistrict (id,mvlv_subst_id,subst_id,la_id,nn,geom)
	SELECT	*
	FROM	model_draft.ego_grid_lv_griddistrict_cut_nn_collect
	ORDER BY mvlv_subst_id;


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_grid_mvlv_substation','ego_dp_lv_peakload.sql',' ');

-- mvlv substation count
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
	SET  	subst_cnt = t2.subst_cnt
	FROM	(SELECT	a.id AS id,
			COUNT(b.geom)::integer AS subst_cnt
		FROM	model_draft.ego_grid_lv_griddistrict AS a,
			model_draft.ego_grid_mvlv_substation AS b
		WHERE  	a.geom && b.geom AND
			ST_CONTAINS(a.geom,b.geom)
		GROUP BY a.id
		)AS t2
	WHERE  	t1.id = t2.id;

-- update area (area_ha)
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
	SET  	area_ha = t2.area
	FROM    (SELECT	id,
			ST_AREA(ST_TRANSFORM(geom,3035))/10000 AS area
		FROM	model_draft.ego_grid_lv_griddistrict
		) AS t2
	WHERE  	t1.id = t2.id;
	
	
-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','social','destatis_zensus_population_per_ha_mview','ego_dp_lv_peakload.sql',' ');

-- zensus 2011 population
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
	SET  	zensus_sum = t2.zensus_sum,
		zensus_count = t2.zensus_count,
		zensus_density = t2.zensus_density
	FROM    (SELECT	a.id AS id,
			SUM(b.population)::integer AS zensus_sum,
			COUNT(b.geom_point)::integer AS zensus_count,
			(SUM(b.population)/COUNT(b.geom_point))::double precision AS zensus_density
		FROM	model_draft.ego_grid_lv_griddistrict AS a,
			social.destatis_zensus_population_per_ha_mview AS b
		WHERE  	a.geom && b.geom_point AND
			ST_CONTAINS(a.geom,b.geom_point)
		GROUP BY a.id
		)AS t2
	WHERE  	t1.id = t2.id;



-- 1. residential sector
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_lvgd_1_residential CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_lvgd_1_residential (
	id 	SERIAL NOT NULL,
	geom 	geometry(Polygon,3035),
	CONSTRAINT ego_osm_sector_per_lvgd_1_residential_pkey PRIMARY KEY (id));

-- index GIST (geom)
CREATE INDEX  	ego_osm_sector_per_lvgd_1_residential_gidx
    ON    	model_draft.ego_osm_sector_per_lvgd_1_residential USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_osm_sector_per_lvgd_1_residential OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_osm_sector_per_griddistrict_1_residential','ego_dp_lv_peakload.sql',' ');

-- intersect sector with mv-griddistrict
INSERT INTO     model_draft.ego_osm_sector_per_lvgd_1_residential (geom)
	SELECT	c.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(a.geom,b.geom))).geom AS geom
		FROM	model_draft.ego_osm_sector_per_griddistrict_1_residential AS a,
			model_draft.ego_grid_lv_griddistrict AS b
		WHERE	a.geom && b.geom
		) AS c
	WHERE	ST_GeometryType(c.geom) = 'ST_Polygon';

-- sector stats
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
	SET  	sector_area_residential = t2.sector_area,
		sector_count_residential = t2.sector_count,
		sector_share_residential = t2.sector_area / t2.area_ha
	FROM    (SELECT	b.id AS id,
			SUM(ST_AREA(a.geom)/10000) AS sector_area,
			COUNT(a.geom) AS sector_count,
			b.area_ha AS area_ha
		FROM	model_draft.ego_osm_sector_per_lvgd_1_residential AS a,
			model_draft.ego_grid_lv_griddistrict AS b
		WHERE  	b.geom && a.geom AND  
			ST_INTERSECTS(b.geom,ST_BUFFER(a.geom,-1))
		GROUP BY b.id
		) AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_osm_sector_per_lvgd_1_residential','ego_dp_lv_peakload.sql',' ');



-- 2. retail sector
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_lvgd_2_retail CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_lvgd_2_retail (
	id 	SERIAL NOT NULL,
	geom 	geometry(Polygon,3035),
	CONSTRAINT ego_osm_sector_per_lvgd_2_retail_pkey PRIMARY KEY (id));

-- index GIST (geom)
CREATE INDEX  	ego_osm_sector_per_lvgd_2_retail_gidx
    ON    	model_draft.ego_osm_sector_per_lvgd_2_retail USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_osm_sector_per_lvgd_2_retail OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_osm_sector_per_griddistrict_2_retail','ego_dp_lv_peakload.sql',' ');

-- intersect sector with mv-griddistrict
INSERT INTO     model_draft.ego_osm_sector_per_lvgd_2_retail (geom)
	SELECT	c.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(a.geom,b.geom))).geom AS geom
		FROM	model_draft.ego_osm_sector_per_griddistrict_2_retail AS a,
			model_draft.ego_grid_lv_griddistrict AS b
		WHERE	a.geom && b.geom
		) AS c
	WHERE	ST_GeometryType(c.geom) = 'ST_Polygon';

-- sector stats
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
	SET  	sector_area_retail = t2.sector_area,
		sector_count_retail = t2.sector_count,
		sector_share_retail = t2.sector_area / t2.area_ha
	FROM    (SELECT	b.id AS id,
			SUM(ST_AREA(a.geom)/10000) AS sector_area,
			COUNT(a.geom) AS sector_count,
			b.area_ha AS area_ha
		FROM	model_draft.ego_osm_sector_per_lvgd_2_retail AS a,
			model_draft.ego_grid_lv_griddistrict AS b
		WHERE  	b.geom && a.geom AND  
			ST_INTERSECTS(b.geom,ST_BUFFER(a.geom,-1))
		GROUP BY b.id
		) AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_osm_sector_per_lvgd_2_retail','ego_dp_lv_peakload.sql',' ');


-- 3. industrial sector
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_lvgd_3_industrial CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_lvgd_3_industrial (
	id 	SERIAL NOT NULL,
	geom 	geometry(Polygon,3035),
	CONSTRAINT ego_osm_sector_per_lvgd_3_industrial_pkey PRIMARY KEY (id));

-- index GIST (geom)
CREATE INDEX  	ego_osm_sector_per_lvgd_3_industrial_gidx
    ON    	model_draft.ego_osm_sector_per_lvgd_3_industrial USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_osm_sector_per_lvgd_3_industrial OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_osm_sector_per_griddistrict_3_industrial','ego_dp_lv_peakload.sql',' ');

-- intersect sector with mv-griddistrict
INSERT INTO     model_draft.ego_osm_sector_per_lvgd_3_industrial (geom)
	SELECT	c.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(a.geom,b.geom))).geom AS geom
		FROM	model_draft.ego_osm_sector_per_griddistrict_3_industrial AS a,
			model_draft.ego_grid_lv_griddistrict AS b
		WHERE	a.geom && b.geom
		) AS c
	WHERE	ST_GeometryType(c.geom) = 'ST_Polygon';

-- sector stats
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
	SET  	sector_area_industrial = t2.sector_area,
		sector_count_industrial = t2.sector_count,
		sector_share_industrial = t2.sector_area / t2.area_ha
	FROM    (SELECT	b.id AS id,
			SUM(ST_AREA(a.geom)/10000) AS sector_area,
			COUNT(a.geom) AS sector_count,
			b.area_ha AS area_ha
		FROM	model_draft.ego_osm_sector_per_lvgd_3_industrial AS a,
			model_draft.ego_grid_lv_griddistrict AS b
		WHERE  	b.geom && a.geom AND  
			ST_INTERSECTS(b.geom,ST_BUFFER(a.geom,-1))
		GROUP BY b.id
		) AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_osm_sector_per_lvgd_3_industrial','ego_dp_lv_peakload.sql',' ');



-- 4. agricultural sector
DROP TABLE IF EXISTS  	model_draft.ego_osm_sector_per_lvgd_4_agricultural CASCADE;
CREATE TABLE         	model_draft.ego_osm_sector_per_lvgd_4_agricultural (
	id 	SERIAL NOT NULL,
	geom 	geometry(Polygon,3035),
	CONSTRAINT ego_osm_sector_per_lvgd_4_agricultural_pkey PRIMARY KEY (id));

-- index GIST (geom)
CREATE INDEX  	ego_osm_sector_per_lvgd_4_agricultural_gidx
    ON    	model_draft.ego_osm_sector_per_lvgd_4_agricultural USING GIST (geom);

-- grant (oeuser)
ALTER TABLE	model_draft.ego_osm_sector_per_lvgd_4_agricultural OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','input','model_draft','ego_osm_sector_per_griddistrict_4_agricultural','ego_dp_lv_peakload.sql',' ');

-- intersect sector with mv-griddistrict
INSERT INTO     model_draft.ego_osm_sector_per_lvgd_4_agricultural (geom)
	SELECT	c.geom ::geometry(Polygon,3035)
	FROM	(SELECT (ST_DUMP(ST_SAFE_INTERSECTION(a.geom,b.geom))).geom AS geom
		FROM	model_draft.ego_osm_sector_per_griddistrict_4_agricultural AS a,
			model_draft.ego_grid_lv_griddistrict AS b
		WHERE	a.geom && b.geom
		) AS c
	WHERE	ST_GeometryType(c.geom) = 'ST_Polygon';

-- sector stats
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
	SET  	sector_area_agricultural = t2.sector_area,
		sector_count_agricultural = t2.sector_count,
		sector_share_agricultural = t2.sector_area / t2.area_ha
	FROM    (SELECT	b.id AS id,
			SUM(ST_AREA(a.geom)/10000) AS sector_area,
			COUNT(a.geom) AS sector_count,
			b.area_ha AS area_ha
		FROM	model_draft.ego_osm_sector_per_lvgd_4_agricultural AS a,
			model_draft.ego_grid_lv_griddistrict AS b
		WHERE  	b.geom && a.geom AND  
			ST_INTERSECTS(b.geom,ST_BUFFER(a.geom,-1))
		GROUP BY b.id
		) AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','output','model_draft','ego_osm_sector_per_lvgd_4_agricultural','ego_dp_lv_peakload.sql',' ');


-- sector stats
UPDATE 	model_draft.ego_grid_lv_griddistrict AS t1
	SET  	sector_area_sum = t2.sector_area_sum,
		sector_share_sum = t2.sector_share_sum,
		sector_count_sum = t2.sector_count_sum
	FROM    (
		SELECT	id,
			coalesce(sector_area_residential,0) + 
				coalesce(sector_area_retail,0) + 
				coalesce(sector_area_industrial,0) + 
				coalesce(sector_area_agricultural,0) AS sector_area_sum,
			coalesce(sector_share_residential,0) + 
				coalesce(sector_share_retail,0) + 
				coalesce(sector_share_industrial,0) + 
				coalesce(sector_share_agricultural,0) AS sector_share_sum,
			coalesce(sector_count_residential,0) + 
				coalesce(sector_count_retail,0) + 
				coalesce(sector_count_industrial,0) + 
				coalesce(sector_count_agricultural,0) AS sector_count_sum					
		FROM	model_draft.ego_grid_lv_griddistrict
		) AS t2
	WHERE  	t1.id = t2.id;


/* -- add count
ALTER TABLE grid.ego_dp_mvlv_substation
	DROP COLUMN IF EXISTS subst_cnt,
	ADD COLUMN subst_cnt integer;

-- mvlv substation count
UPDATE 	grid.ego_dp_mvlv_substation AS t1
	SET  	subst_cnt = t2.subst_cnt
	FROM	(SELECT	a.mvlv_subst_id AS id,
			COUNT(b.geom)::integer AS subst_cnt
		FROM	grid.ego_dp_mvlv_substation AS a,
			grid.ego_dp_lv_griddistrict AS b
		WHERE  	a.geom && b.geom AND
			ST_CONTAINS(b.geom,a.geom)
		GROUP BY a.mvlv_subst_id
		)AS t2
	WHERE  	t1.mvlv_subst_id = t2.id; */
	
	
	
	