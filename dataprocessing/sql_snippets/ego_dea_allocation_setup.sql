/* 
Skript to allocate decentralized renewable power plants (dea)
Methods base on technology and voltage level
Uses different lattice from setup_ego_wpa_per_grid_district.sql
*/ 

-- number of grid_district -> 3609
	SELECT	COUNT(*)
	FROM	 model_draft.ego_grid_mv_griddistrict;

-- table for allocated dea
DROP TABLE IF EXISTS model_draft.ego_dea_allocation CASCADE;
CREATE TABLE model_draft.ego_dea_allocation (
	id bigint NOT NULL,
	sort integer,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	postcode character varying,
	subst_id integer,
	source character varying,
	la_id integer,
	flag character varying,
	geom geometry(Point,3035),
	geom_line geometry(LineString,3035),
	geom_new geometry(Point,3035),
CONSTRAINT ego_dea_allocation_pkey PRIMARY KEY (id));

-- insert DEA, with no geom excluded
INSERT INTO model_draft.ego_dea_allocation (id, electrical_capacity, generation_type, generation_subtype, voltage_level, postcode, source, geom)
	SELECT	id, electrical_capacity, generation_type, generation_subtype, voltage_level, postcode, source, ST_TRANSFORM(geom,3035)
	FROM	supply.ego_renewable_power_plants_germany
	WHERE	geom IS NOT NULL;

-- create index GIST (geom)
CREATE INDEX	ego_dea_allocation_geom_idx
	ON	model_draft.ego_dea_allocation USING GIST (geom);

-- create index GIST (geom_line)
CREATE INDEX ego_dea_allocation_geom_line_idx
	ON model_draft.ego_dea_allocation USING gist (geom_line);

-- create index GIST (geom_new)
CREATE INDEX ego_dea_allocation_geom_new_idx
	ON model_draft.ego_dea_allocation USING gist (geom_new);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation TO oeuser WITH GRANT OPTION;
ALTER TABLE			model_draft.ego_dea_allocation OWNER TO oeuser;

-- update subst_id from grid_district
UPDATE 	model_draft.ego_dea_allocation AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	dea.id AS id,
			gd.subst_id AS subst_id
		FROM	model_draft.ego_dea_allocation AS dea,
			model_draft.ego_grid_mv_griddistrict AS gd
		WHERE  	gd.geom && dea.geom AND
			ST_CONTAINS(gd.geom,dea.geom)
		) AS t2
	WHERE  	t1.id = t2.id;

-- flag reset
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = NULL,
		geom_new = NULL,
		geom_line = NULL;

-- DEA outside grid_district
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = 'out',
		geom_new = NULL,
		geom_line = NULL
	WHERE	dea.subst_id IS NULL;

-- DEA outside grid_district offshore wind
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = 'offshore',
		geom_new = NULL,
		geom_line = NULL
	WHERE	dea.subst_id IS NULL AND
		dea.generation_type = 'wind';


/*
Some DEA are outside Germany because of unknown inaccuracies.
They are moved to the next substation before the allocation methods.
Offshore wind power plants are not moved.
*/ 
    
-- MView DEA outside grid_district
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_out_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_out_mview AS
	SELECT	dea.*
	FROM 	model_draft.ego_dea_allocation AS dea
	WHERE	flag = 'out' OR flag = 'offshore';

-- create index GIST (geom)
CREATE INDEX ego_dea_allocation_out_mview_geom_idx
	ON model_draft.ego_dea_allocation_out_mview USING gist (geom);

-- create index GIST (geom_line)
CREATE INDEX ego_dea_allocation_out_mview_geom_line_idx
	ON model_draft.ego_dea_allocation_out_mview USING gist (geom_line);

-- create index GIST (geom_new)
CREATE INDEX ego_dea_allocation_out_mview_geom_new_idx
	ON model_draft.ego_dea_allocation_out_mview USING gist (geom_new);	

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_allocation_out_mview TO oeuser WITH GRANT OPTION;
ALTER TABLE		model_draft.ego_dea_allocation_out_mview OWNER TO oeuser;

-- New geom, DEA to next substation
DROP TABLE IF EXISTS	model_draft.ego_dea_allocation_out_nn CASCADE;
CREATE TABLE 		model_draft.ego_dea_allocation_out_nn AS 
	SELECT DISTINCT ON (dea.id)
		dea.id AS dea_id,
		dea.generation_type,
		sub.subst_id, 
		sub.geom ::geometry(Point,3035) AS geom_sub,
		ST_Distance(dea.geom,sub.geom) AS distance,
		dea.geom ::geometry(Point,3035) AS geom
	FROM 	model_draft.ego_dea_allocation_out_mview AS dea,
		calc_ego_substation.ego_deu_substations AS sub
	WHERE 	ST_DWithin(dea.geom,sub.geom, 100000) -- In a 100 km radius
	ORDER BY 	dea.id, ST_Distance(dea.geom,sub.geom);

ALTER TABLE	model_draft.ego_dea_allocation_out_nn
	ADD PRIMARY KEY (dea_id),
	OWNER TO oeuser;

-- new subst_id and geom_new with line
UPDATE 	model_draft.ego_dea_allocation AS t1
	SET  	subst_id = t2.subst_id,
		geom_new = t2.geom_new,
		geom_line = t2.geom_line
	FROM	(SELECT	nn.dea_id AS dea_id,
			nn.subst_id AS subst_id,
			nn.geom_sub AS geom_new,
			ST_MAKELINE(nn.geom,nn.geom_sub) ::geometry(LineString,3035) AS geom_line
		FROM	model_draft.ego_dea_allocation_out_nn AS nn,
			model_draft.ego_dea_allocation AS dea
		WHERE  	flag = 'out'
		)AS t2
	WHERE  	t1.id = t2.dea_id;

-- drop
DROP TABLE IF EXISTS	model_draft.ego_dea_allocation_out_nn CASCADE;

-- scenario log
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_allocation_out_mview' AS table_name,
		'process_eGo_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_allocation_out_mview;


/* 
Prepare a special OSM layer with farmyards per grid districts.
In Germany a lot of farmyard builings are used for renewable energy production with solar and biomass.
*/

-- OSM agricultural per grid district
DROP TABLE IF EXISTS 	model_draft.ego_dea_agricultural_sector_per_grid_district CASCADE;
CREATE TABLE 		model_draft.ego_dea_agricultural_sector_per_grid_district (
	id serial NOT NULL,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_dea_agricultural_sector_per_grid_district_pkey PRIMARY KEY (id));

-- insert data (osm agricultural)
INSERT INTO	model_draft.ego_dea_agricultural_sector_per_grid_district (area_ha,geom)
	SELECT	ST_AREA(osm.geom)/10000, osm.geom
	FROM	model_draft.ego_osm_sector_per_griddistrict_4_agricultural AS osm;
	
-- update subst_id from grid_district
UPDATE 	model_draft.ego_dea_agricultural_sector_per_grid_district AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	osm.id AS id,
			dis.subst_id AS subst_id
		FROM	model_draft.ego_dea_agricultural_sector_per_grid_district AS osm,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE  	dis.geom && ST_CENTROID(osm.geom) AND
			ST_CONTAINS(dis.geom,ST_CENTROID(osm.geom))
		) AS t2
	WHERE  	t1.id = t2.id;

-- create index GIST (geom)
CREATE INDEX ego_dea_agricultural_sector_per_grid_district_geom_idx
	ON model_draft.ego_dea_agricultural_sector_per_grid_district USING gist (geom);

-- grant (oeuser)
GRANT ALL ON TABLE	model_draft.ego_dea_agricultural_sector_per_grid_district TO oeuser WITH GRANT OPTION;
ALTER TABLE			model_draft.ego_dea_agricultural_sector_per_grid_district OWNER TO oeuser;  

-- scenario log
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,user_name,timestamp)
	SELECT	'0.2' AS version,
		'model_draft' AS schema_name,
		'ego_dea_agricultural_sector_per_grid_district' AS table_name,
		'process_eGo_dea_allocation_methods.sql' AS script_name,
		COUNT(*)AS entries,
		'OK' AS status,
		session_user AS user_name,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
	FROM	model_draft.ego_dea_agricultural_sector_per_grid_district;


/* BNetzA MView
-- some dea are mapped good, could be excluded, but did not work to filter them!

-- Check for sources
	SELECT	dea.source
	FROM 	supply.ego_renewable_power_plants_germany AS dea
	GROUP BY dea.source

-- Flag BNetzA
UPDATE 	model_draft.ego_dea_allocation AS dea
	SET	flag = 'bnetza',
		geom_new = NULL,
		geom_line = NULL
	WHERE	dea.source = 'BNetzA' OR dea.source = 'BNetzA PV';

-- MView BNetzA
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_bnetza_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_dea_allocation_bnetza_mview AS
	SELECT	dea.*
	FROM 	model_draft.ego_dea_allocation AS dea
	WHERE	flag = 'bnetza';

CREATE INDEX ego_dea_allocation_bnetza_mview_geom_idx
	ON model_draft.ego_dea_allocation_bnetza_mview USING gist (geom);

-- Drops
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_dea_allocation_bnetza_mview CASCADE;
*/ 


-- DEA METHODS

/* Statistics (old, see scenario_log)
0. DEA (HV) -> 1.598.624
1. M1-1	biomass & gas 	-> osm_urban_4 	-> 16.062 / 15.090 -> 972 Rest! 	-ok
2. M1-2	solar_roof (04) -> osm_urban_4 	-> 21.535 / 18.290 -> 3.245 Rest! 	-ok
3. M2	wind (04)	-> wpa_farm	-> 2.127 / 2.097 -> 30 Rest! 		-ok
4. M3	wind (05 & 06)	-> grid_wpa	-> 13.543
5. M4	solar_gr & Rest	-> grid_out	-> 
6. M5	solar (07)	-> grid_la	->  
*/ 
