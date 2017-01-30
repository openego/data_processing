/*
Skript to allocate decentralized renewable power plants (dea)
Methods base on technology and voltage level
Uses different lattice from setup_ego_wpa_per_grid_district.sql

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

-- number of grid_district -> 3606
	SELECT	COUNT(*)
	FROM	 model_draft.ego_grid_mv_griddistrict;

-- table for allocated dea
DROP TABLE IF EXISTS 	model_draft.ego_supply_rea CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea (
	id bigint,
	electrical_capacity numeric,
	generation_type text,
	generation_subtype character varying,
	voltage_level character varying,
	postcode character varying,
	source character varying,
	subst_id bigint,
	la_id integer,
	sort integer,
	flag character varying,
	geom geometry(Point,3035),
	geom_line geometry(LineString,3035),
	geom_new geometry(Point,3035),
CONSTRAINT ego_supply_rea_pkey PRIMARY KEY (id));

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','input','supply','ego_res_powerplant','ego_rea_setup.sql',' ');

-- insert DEA, with no geom excluded
INSERT INTO model_draft.ego_supply_rea (id, electrical_capacity, generation_type, generation_subtype, voltage_level, postcode, source, geom)
	SELECT	id, electrical_capacity, generation_type, generation_subtype, voltage_level, postcode, source, ST_TRANSFORM(geom,3035)
	FROM	supply.ego_res_powerplant
	WHERE	geom IS NOT NULL;

-- index GIST (geom)
CREATE INDEX	ego_supply_rea_geom_idx
	ON	model_draft.ego_supply_rea USING GIST (geom);

-- index GIST (geom_line)
CREATE INDEX ego_supply_rea_geom_line_idx
	ON model_draft.ego_supply_rea USING gist (geom_line);

-- index GIST (geom_new)
CREATE INDEX ego_supply_rea_geom_new_idx
	ON model_draft.ego_supply_rea USING gist (geom_new);

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','input','model_draft','ego_grid_mv_griddistrict','ego_rea_setup.sql',' ');

-- update subst_id from mv-griddistrict
UPDATE 	model_draft.ego_supply_rea AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	dea.id AS id,
			gd.subst_id AS subst_id
		FROM	model_draft.ego_supply_rea AS dea,
			model_draft.ego_grid_mv_griddistrict AS gd
		WHERE  	gd.geom && dea.geom AND
			ST_CONTAINS(gd.geom,dea.geom)
		) AS t2
	WHERE  	t1.id = t2.id;

-- flag reset
UPDATE 	model_draft.ego_supply_rea AS dea
	SET	flag = NULL,
		geom_new = NULL,
		geom_line = NULL;

-- re outside mv-griddistrict
UPDATE 	model_draft.ego_supply_rea AS dea
	SET	flag = 'out',
		geom_new = NULL,
		geom_line = NULL
	WHERE	dea.subst_id IS NULL;

-- re outside mv-griddistrict -> offshore wind
UPDATE 	model_draft.ego_supply_rea AS dea
	SET	flag = 'offshore',
		geom_new = NULL,
		geom_line = NULL
	WHERE	dea.subst_id IS NULL AND
		dea.generation_type = 'wind';

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_supply_rea','ego_rea_setup.sql',' ');


/*
Some re are outside Germany because of unknown inaccuracies.
They are moved to the next substation before the allocation methods.
Offshore wind power plants are not moved.
*/ 

-- re outside mv-griddistrict
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_out_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_out_mview AS
	SELECT	dea.*
	FROM 	model_draft.ego_supply_rea AS dea
	WHERE	flag = 'out' OR flag = 'offshore';

-- index GIST (geom)
CREATE INDEX ego_supply_rea_out_mview_geom_idx
	ON model_draft.ego_supply_rea_out_mview USING gist (geom);

-- index GIST (geom_line)
CREATE INDEX ego_supply_rea_out_mview_geom_line_idx
	ON model_draft.ego_supply_rea_out_mview USING gist (geom_line);

-- index GIST (geom_new)
CREATE INDEX ego_supply_rea_out_mview_geom_new_idx
	ON model_draft.ego_supply_rea_out_mview USING gist (geom_new);	

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_out_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','input','model_draft','ego_grid_hvmv_substation','ego_rea_setup.sql',' ');


-- new geom, DEA to next substation
DROP TABLE IF EXISTS	model_draft.ego_supply_rea_out_nn CASCADE;
CREATE TABLE 		model_draft.ego_supply_rea_out_nn AS 
	SELECT DISTINCT ON (dea.id)
		dea.id AS dea_id,
		dea.generation_type,
		sub.subst_id, 
		sub.geom ::geometry(Point,3035) AS geom_sub,
		ST_Distance(dea.geom,sub.geom) AS distance,
		dea.geom ::geometry(Point,3035) AS geom
	FROM 	model_draft.ego_supply_rea_out_mview AS dea,
		model_draft.ego_grid_hvmv_substation AS sub
	WHERE 	ST_DWithin(dea.geom,sub.geom, 100000) -- In a 100 km radius
	ORDER BY 	dea.id, ST_Distance(dea.geom,sub.geom);

ALTER TABLE	model_draft.ego_supply_rea_out_nn
	ADD PRIMARY KEY (dea_id),
	OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','temp','model_draft','ego_supply_rea_out_nn','ego_rea_setup.sql',' ');
	
-- new subst_id and geom_new with line
UPDATE 	model_draft.ego_supply_rea AS t1
	SET  	subst_id = t2.subst_id,
		geom_new = t2.geom_new,
		geom_line = t2.geom_line
	FROM	(SELECT	nn.dea_id AS dea_id,
			nn.subst_id AS subst_id,
			nn.geom_sub AS geom_new,
			ST_MAKELINE(nn.geom,nn.geom_sub) ::geometry(LineString,3035) AS geom_line
		FROM	model_draft.ego_supply_rea_out_nn AS nn,
			model_draft.ego_supply_rea AS dea
		WHERE  	flag = 'out'
		)AS t2
	WHERE  	t1.id = t2.dea_id;
	
-- re outside mv-griddistrict
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_out_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_out_mview AS
	SELECT	dea.*
	FROM 	model_draft.ego_supply_rea AS dea
	WHERE	flag = 'out' OR flag = 'offshore';

-- index GIST (geom)
CREATE INDEX ego_supply_rea_out_mview_geom_idx
	ON model_draft.ego_supply_rea_out_mview USING gist (geom);

-- index GIST (geom_line)
CREATE INDEX ego_supply_rea_out_mview_geom_line_idx
	ON model_draft.ego_supply_rea_out_mview USING gist (geom_line);

-- index GIST (geom_new)
CREATE INDEX ego_supply_rea_out_mview_geom_new_idx
	ON model_draft.ego_supply_rea_out_mview USING gist (geom_new);	

-- grant (oeuser)
ALTER TABLE model_draft.ego_supply_rea_out_mview OWNER TO oeuser;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','temp','model_draft','ego_supply_rea_out_mview','ego_rea_setup.sql',' ');

-- drop
DROP TABLE IF EXISTS	model_draft.ego_supply_rea_out_nn CASCADE;


/* 
Prepare a special OSM layer with farmyards per grid districts.
In Germany a lot of farmyard builings are used for renewable energy production with solar and biomass.
*/

-- OSM agricultural per grid district
DROP TABLE IF EXISTS 	model_draft.ego_osm_agriculture_per_mvgd CASCADE;
CREATE TABLE 		model_draft.ego_osm_agriculture_per_mvgd (
	id serial NOT NULL,
	subst_id integer,
	area_ha numeric,
	geom geometry(Polygon,3035),
	CONSTRAINT ego_osm_agriculture_per_mvgd_pkey PRIMARY KEY (id));

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','input','model_draft','ego_osm_sector_per_griddistrict_4_agricultural','ego_rea_setup.sql',' ');

-- insert data (osm agricultural)
INSERT INTO	model_draft.ego_osm_agriculture_per_mvgd (area_ha,geom)
	SELECT	ST_AREA(osm.geom)/10000, osm.geom
	FROM	model_draft.ego_osm_sector_per_griddistrict_4_agricultural AS osm;
	
-- update subst_id from grid_district
UPDATE 	model_draft.ego_osm_agriculture_per_mvgd AS t1
	SET  	subst_id = t2.subst_id
	FROM    (
		SELECT	osm.id AS id,
			dis.subst_id AS subst_id
		FROM	model_draft.ego_osm_agriculture_per_mvgd AS osm,
			model_draft.ego_grid_mv_griddistrict AS dis
		WHERE  	dis.geom && ST_CENTROID(osm.geom) AND
			ST_CONTAINS(dis.geom,ST_CENTROID(osm.geom))
		) AS t2
	WHERE  	t1.id = t2.id;

-- index GIST (geom)
CREATE INDEX ego_osm_agriculture_per_mvgd_geom_idx
	ON model_draft.ego_osm_agriculture_per_mvgd USING gist (geom);

-- grant (oeuser)
ALTER TABLE model_draft.ego_osm_agriculture_per_mvgd OWNER TO oeuser;  

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.3','output','model_draft','ego_osm_agriculture_per_mvgd','ego_rea_setup.sql',' ');


-- DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_out_mview CASCADE;



/* BNetzA MView
-- some dea are mapped good, could be excluded, but did not work to filter them!

-- Check for sources
	SELECT	dea.source
	FROM 	supply.ego_res_powerplant AS dea
	GROUP BY dea.source

-- Flag BNetzA
UPDATE 	model_draft.ego_supply_rea AS dea
	SET	flag = 'bnetza',
		geom_new = NULL,
		geom_line = NULL
	WHERE	dea.source = 'BNetzA' OR dea.source = 'BNetzA PV';

-- MView BNetzA
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_bnetza_mview CASCADE;
CREATE MATERIALIZED VIEW 		model_draft.ego_supply_rea_bnetza_mview AS
	SELECT	dea.*
	FROM 	model_draft.ego_supply_rea AS dea
	WHERE	flag = 'bnetza';

CREATE INDEX ego_supply_rea_bnetza_mview_geom_idx
	ON model_draft.ego_supply_rea_bnetza_mview USING gist (geom);

-- Drops
DROP MATERIALIZED VIEW IF EXISTS 	model_draft.ego_supply_rea_bnetza_mview CASCADE;
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
