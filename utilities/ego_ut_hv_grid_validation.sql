/*
validation tool for hv grid using TSO static grid models

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "mariusves"
*/
 
--------------------------------------------------------------------------------------------
----------------------------------/**-- STEP 0 --**\----------------------------------------
--------------------------------------------------------------------------------------------
 
----------------------------------------------------------
-- Preperation: Create tables for TSO data --
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS model_draft.ego_grid_pf_hv_val_amprion_line
(
  index bigint NOT NULL,
  element text,
  substation_from text,
  substation_to text,
  length_km double precision,
  r1_ohm double precision,
  x1_ohm double precision,
  b_my_s double precision,
  ir_a bigint,
  un_kv bigint,
  bus0_geom geometry(Point,4326),
  bus1_geom geometry(Point,4326),
  bus0 bigint,
  bus1 bigint,
  line_id bigint,
  tso_topo geometry(LineString,4326),
  CONSTRAINT amprion_line_pkey PRIMARY KEY (index)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS model_draft.ego_grid_pf_hv_val_amprion_transformer
(
  index bigint NOT NULL,
  element text,
  substation_location text,
  r1_pu double precision,
  x1_pu double precision,
  g_mikro_s double precision,
  b_mikro_s double precision,
  ir_a bigint,
  bus0_geom geometry(Point,4326),
  CONSTRAINT amprion_trans_pkey PRIMARY KEY (index)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS model_draft.ego_grid_pf_hv_val_hertz_line
(
  index bigint NOT NULL,
  id_hertz text,
  element text,
  substation_from text,
  substation_to text,
  line_name text,
  length_km double precision,
  r1_ohm double precision,
  x1_ohm double precision,
  c_micro_f double precision,
  ir_a bigint,
  un_kv bigint,
  bus0_geom geometry(Point,4326),
  bus1_geom geometry(Point,4326),
  bus0 bigint,
  bus1 bigint,
  line_id bigint,
  tso_topo geometry(LineString,4326),
  CONSTRAINT hertz_pkey PRIMARY KEY (index)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS model_draft.ego_grid_pf_hv_val_hertz_transformer
(
  index bigint NOT NULL,
  id_hertz text,
  element text,
  substation_location text,
  name text,
  ur1_kv bigint,
  ur2_kv bigint,
  sr_mva bigint,
  r1_ohm double precision,
  x1_ohm double precision,
  ir_a bigint,
  bus0_geom geometry(Point,4326),
  CONSTRAINT hertz_trans_pkey PRIMARY KEY (index)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS model_draft.ego_grid_pf_hv_val_tennet_line
(
  index bigint NOT NULL,
  id_tennet bigint,
  element text,
  substation_from text,
  substation_to text,
  line_name text,
  length_km double precision,
  r1_ohm double precision,
  x1_ohm double precision,
  c1_micro_f double precision,
  ir_a bigint,
  un_kv bigint,
  r1_ohm_pro_km double precision,
  x1_ohm_pro_km double precision,
  c1_micro_f_pro_km double precision,
  bus0_geom geometry(Point,4326),
  bus1_geom geometry(Point,4326),
  bus0 bigint,
  bus1 bigint,
  line_id bigint,
  tso_topo geometry(LineString,4326),
  CONSTRAINT tennet_line_pkey PRIMARY KEY (index)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS model_draft.ego_grid_pf_hv_val_transnetbw_line
(
  index bigint NOT NULL,
  element text,
  substation_from text,
  substation_to text,
  line_name text,
  length_km double precision,
  r1_ohm double precision,
  x1_ohm double precision,
  c1_micro_f double precision,
  sn_mva bigint,
  un_kv bigint,
  bus0_geom geometry(Point,4326),
  bus1_geom geometry(Point,4326),
  bus0 bigint,
  bus1 bigint,
  line_id bigint,
  tso_topo geometry(LineString,4326),
  CONSTRAINT transnetbw_line_pkey PRIMARY KEY (index)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS model_draft.ego_grid_pf_hv_val_transnetbw_transformer
(
  index bigint NOT NULL,
  element text,
  substation_location text,
  ur1_kv bigint,
  ur2_kv bigint,
  r1_pu double precision,
  x1_pu double precision,
  regelstufen bigint,
  spannungsdelta double precision,
  sr_mva bigint,
  bus0_geom geometry(Point,4326),
  CONSTRAINT transnetbw_trans_pkey PRIMARY KEY (index)
)
WITH (
  OIDS=FALSE
);
----------------------------------------------------------
-- Preperation: Grouping of grid.ego_pf_hv_line --
----------------------------------------------------------

-- ordering of bus0/bus1 so that it's always bus0 < bus1 (necessary for grouping)
UPDATE grid.ego_pf_hv_line b
SET 
bus0 = a.bus0,
bus1 = a.bus1
FROM
(SELECT 
	line_id,				
	CASE 
	WHEN bus0 < bus1 
	THEN bus0 
	ELSE bus1 
	END as bus0,
	CASE 
	WHEN bus0 < bus1 
	THEN bus1 
	ELSE bus0 
	END as bus1
FROM  grid.ego_pf_hv_line
ORDER BY line_id) as a
WHERE b.line_id = a.line_id AND
scn_name = 'Status Quo';

--order buses for transformers
UPDATE grid.ego_pf_hv_transformer b
SET 
bus0 = a.bus0,
bus1 = a.bus1
FROM
(SELECT 
	trafo_id,				
	CASE 
	WHEN bus0 < bus1 
	THEN bus0 
	ELSE bus1 
	END as bus0,
	CASE 
	WHEN bus0 < bus1 
	THEN bus1 
	ELSE bus0 
	END as bus1
FROM  grid.ego_pf_hv_transformer
ORDER BY trafo_id) as a
WHERE b.trafo_id = a.trafo_id AND
scn_name = 'Status Quo';


/*
Grouping of parallel lines in eGo grid model. Currently not completely implemented,
which is why this step is commented out.  

-- create new Status Quo grid model with parallel lines merged to one, 
-- delete old Status Quo afterwards!

INSERT INTO grid.ego_pf_hv_line (
scn_name,
line_id,
bus0,
bus1,
x,
r,
b,
s_nom,
length,
cables,
frequency,
geom,
topo)
SELECT 
	'Status Quo grouped' as scn_name,
	min(line_id),
	bus0,
	bus1,
	sum(x^(-1))^(-1) as x,
	sum(r^(-1))^(-1) as r,
	sum(b) as b,
	sum(s_nom) as s_nom,
	avg(length) as length,
	sum(cables) as cables,
	50 as frequency,
	min(geom) as geom,
	min(topo) as topo
FROM grid.ego_pf_hv_line
WHERE scn_name = 'Status Quo'
GROUP BY bus0,bus1;

DELETE FROM  grid.ego_pf_hv_line WHERE scn_name = 'Status Quo';
UPDATE grid.ego_pf_hv_line SET scn_name = 'Status Quo' WHERE scn_name = 'Status Quo grouped';


-- Create grid model OSM (lines)
DELETE FROM grid.ego_pf_hv_line WHERE scn_name='Status Quo OSM';
INSERT INTO grid.ego_pf_hv_line(
  scn_name, line_id, bus0, bus1, x, r, g, b, s_nom, length, cables, frequency, geom, topo )
SELECT 'Status Quo OSM', line_id, bus0, bus1, x, r, g, b, s_nom, length, cables, frequency, geom, topo 
FROM grid.ego_pf_hv_line
WHERE scn_name = 'Status Quo';

-- Create grid model OSM (transformers)
-- TRAFO:
DELETE FROM grid.ego_pf_hv_transformer WHERE scn_name='Status Quo OSM';
INSERT INTO grid.ego_pf_hv_transformer(
  scn_name, trafo_id, bus0, bus1, x, r, g, b, s_nom, tap_ratio, phase_shift, geom, topo ) 
SELECT 'Status Quo OSM', trafo_id, bus0, bus1, x, r, g, b, s_nom, 1, 0, geom, topo 
FROM grid.ego_pf_hv_transformer
WHERE scn_name = 'Status Quo';
*/

 
--------------------------------------------------------------------------------------------
----------------------------------/**-- STEP 1 --**\----------------------------------------
--------------------------------------------------------------------------------------------
 
/*
This step has to be carried out only once for each import of a new static grid model release by TSOs!

------------------------------
-- FIX ERRORS IN TSO TABLES --
------------------------------

--TransnetBW:

UPDATE model_draft.ego_grid_pf_hv_val_transnetbw_line 
SET substation_to = 'Neckarwestheim' 
WHERE substation_to = 'GKN';

UPDATE model_draft.ego_grid_pf_hv_val_transnetbw_line
SET substation_to = 'Hoheneck'
WHERE substation_to = 'Hoheneck ';

UPDATE model_draft.ego_grid_pf_hv_val_transnetbw_line
SET substation_from = 'Kühmoos'
WHERE substation_from = 'Kühmoos ';

UPDATE model_draft.ego_grid_pf_hv_val_transnetbw_line
SET substation_to = 'Kühmoos'
WHERE substation_to = 'Kühmoos ';

UPDATE model_draft.ego_grid_pf_hv_val_transnetbw_line
SET substation_from = 'GK Mannheim'
WHERE substation_from = 'GKM';

UPDATE model_draft.ego_grid_pf_hv_val_transnetbw_line
SET substation_to = 'GK Mannheim'
WHERE substation_to = 'GKM';

UPDATE model_draft.ego_grid_pf_hv_val_transnetbw_line
SET substation_from = 'Philippsburg'
WHERE substation_from = 'KKW Philippsburg';

UPDATE model_draft.ego_grid_pf_hv_val_transnetbw_line
SET substation_to = 'Philippsburg'
WHERE substation_to = 'KKW Philippsburg';

UPDATE model_draft.ego_grid_pf_hv_val_transnetbw_line
SET substation_from = 'Philippsburg'
WHERE substation_from = 'KKW Philippsburg ';

UPDATE model_draft.ego_grid_pf_hv_val_transnetbw_line
SET substation_to = 'Philippsburg'
WHERE substation_to = 'KKW Philippsburg ';

	
-- 50HERTZ TRAFO:

UPDATE model_draft.ego_grid_pf_hv_val_hertz_transformer 
SET ur1_kv = 380
WHERE ur1_kv = 400;
UPDATE model_draft.ego_grid_pf_hv_val_hertz_transformer 
SET ur2_kv = 220
WHERE ur2_kv = 231;

-- TenneT

UPDATE model_draft.ego_grid_pf_hv_val_tennet_line
SET substation_from = 'Büttel'
WHERE substation_from = 'Büttel';

UPDATE model_draft.ego_grid_pf_hv_val_tennet_line
SET substation_to = 'Büttel'
WHERE substation_to = 'Büttel';

UPDATE model_draft.ego_grid_pf_hv_val_tennet_line
SET substation_from = 'Brunsbüttel'
WHERE substation_from = 'Brunsbüttel';

UPDATE model_draft.ego_grid_pf_hv_val_tennet_line
SET substation_from = 'Brunsbüttel'
WHERE substation_from = 'Brunsbüttel';

UPDATE model_draft.ego_grid_pf_hv_val_tennet_line
SET substation_to = 'Brunsbüttel'
WHERE substation_to = 'Brunsbüttel';

UPDATE model_draft.ego_grid_pf_hv_val_tennet_line
SET substation_from = 'Würgassen'
WHERE substation_from = 'Wrgassen';

UPDATE model_draft.ego_grid_pf_hv_val_tennet_line
SET substation_to = 'Würgassen'
WHERE substation_to = 'Wrgassen';

UPDATE model_draft.ego_grid_pf_hv_val_tennet_line
SET substation_from = 'Lüneburg'
WHERE substation_from = 'Lüneburg';

UPDATE model_draft.ego_grid_pf_hv_val_tennet_line
SET substation_to = 'Lüneburg'
WHERE substation_to = 'Lüneburg';

UPDATE model_draft.ego_grid_pf_hv_val_tennet_line
SET substation_to = 'Lübeck'
WHERE substation_to = 'Lübeck';

UPDATE model_draft.ego_grid_pf_hv_val_tennet_line
SET substation_to = 'Lübeck'
WHERE substation_to = 'Lübeck';

-- UPDATE Tennet  Lines with newer lengths
UPDATE model_draft.ego_grid_pf_hv_val_tennet_line a
SET 
ir_a = b.ir_a,
length_km = b.lenght_km,
r1_ohm = b.r1_ohm,
x1_ohm = b.x1_ohm,
c1_micro_f = b.c1_mikro_f

FROM 
(SELECT line_name, ir_a, lenght_km, r1_ohm, x1_ohm, c1_mikro_f 
FROM
model_draft.ego_grid_pf_hv_val_tennet_line_updated
WHERE 
	lenght_km > 0 AND
	ir_a > 0 AND
	r1_ohm > 0 AND
	x1_ohm > 0 AND
	c1_mikro_f > 0) as b
WHERE a.line_name = b.line_name;
*/

 
--------------------------------------------------------------------------------------------
----------------------------------/**-- STEP 2 --**\----------------------------------------
--------------------------------------------------------------------------------------------
 

------------------------------------
-- CREATE TABLE FOR ALL TSO LINES --
------------------------------------

-- Table 1:  
DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_val_tso_lines;
CREATE TABLE model_draft.ego_grid_pf_hv_val_tso_lines
(
  index serial NOT NULL,
  tso_name text,
  tso_id integer,
  substation_from text,
  substation_to text,
  length_km double precision,
  r1_ohm numeric,
  x1_ohm numeric,
  b1_siemens numeric,
  s_nom bigint, 
  un_kv bigint,
  r1_ohm_pro_km numeric,
  x1_ohm_pro_km numeric,
  b1_siemens_pro_km numeric,
  bus0_geom geometry(Point,4326),
  bus1_geom geometry(Point,4326),
  bus0 bigint,
  bus1 bigint,
  numb_sys integer,
  useful boolean DEFAULT false,
  CONSTRAINT tso_lines_pkey PRIMARY KEY (index)
);

-- Table 2:  
DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_val_tso_lines_routing;
CREATE TABLE model_draft.ego_grid_pf_hv_val_tso_lines_routing
(
  index bigint NOT NULL,
  tso_name text,
  tso_id integer,
  substation_from text,
  substation_to text,
  length_km double precision,
  r1_ohm numeric,
  x1_ohm numeric,
  b1_siemens numeric,
  s_nom bigint, 
  un_kv bigint,
  r1_ohm_pro_km numeric,
  x1_ohm_pro_km numeric,
  b1_siemens_pro_km numeric,
  bus0_geom geometry(Point,4326),
  bus1_geom geometry(Point,4326),
  bus0 bigint,
  bus1 bigint,
  numb_sys integer,
  useful boolean DEFAULT false,
  CONSTRAINT tso_lines_routing_pkey PRIMARY KEY (index)
);


-- Table 3:  
DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_val_tso_transformers;
CREATE TABLE model_draft.ego_grid_pf_hv_val_tso_transformers
(
  index serial NOT NULL,
  tso_name text,
  tso_id integer,
  substation_name text,
  r1_ohm numeric,
  x1_ohm numeric,
  s_nom bigint,
  un_1_kv bigint,
  un_2_kv bigint,
  bus0_geom geometry(Point,4326),
  bus1_geom geometry(Point,4326),
  bus0 bigint,
  bus1 bigint,
  numb_sys integer,
  useful boolean DEFAULT false,
  CONSTRAINT tso_trafo_pkey PRIMARY KEY (index)
);

-- Table 4:  
DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_val_tso_transformers_routing;
CREATE TABLE model_draft.ego_grid_pf_hv_val_tso_transformers_routing
(
  index bigint NOT NULL,
  tso_name text,
  tso_id integer,
  substation_name text,
  r1_ohm numeric,
  x1_ohm numeric,
  s_nom bigint,
  un_1_kv bigint,
  un_2_kv bigint,
  bus0_geom geometry(Point,4326),
  bus1_geom geometry(Point,4326),
  bus0 bigint,
  bus1 bigint,
  numb_sys integer,
  useful boolean DEFAULT false,
  osm_trafo_id bigint,
  CONSTRAINT tso_trafo_routing_pkey PRIMARY KEY (index)
);

------------------------------------------------------
-- FILL TSO LINES TABLE WITH DATA FROM OTHER TABLES --
------------------------------------------------------
-- Amprion:
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_lines(
  tso_name,
  tso_id,
  substation_from,
  substation_to,
  length_km,
  r1_ohm,
  x1_ohm,
  b1_siemens, -- (capacitive susceptance) B = 2*50*pi() * C
  s_nom,
  un_kv) 
SELECT
  'Amprion',
  1,
  substation_from,
  substation_to,
  length_km,
  r1_ohm,
  x1_ohm,
  b_my_s*10^(-6),
  round(((ir_a::numeric/1000)*(|/3)*un_kv)::numeric),
  un_kv
FROM model_draft.ego_grid_pf_hv_val_amprion_line;

-- 50Hertz:
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_lines(
  tso_name,
  tso_id,
  substation_from,
  substation_to,
  length_km,
  r1_ohm,
  x1_ohm,
  b1_siemens,
  s_nom,
  un_kv) 
SELECT
  'Hertz',
  2,
  substation_from,
  substation_to,
  length_km,
  r1_ohm,
  x1_ohm,
  (c_micro_f * 2 * 50 * pi()) * 10^(-6),
  round(((ir_a::numeric/1000)*(|/3)*un_kv)::numeric),
  un_kv
FROM model_draft.ego_grid_pf_hv_val_hertz_line;

-- TenneT:
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_lines(
  tso_name,
  tso_id,
  substation_from,
  substation_to,
  length_km,
  r1_ohm,
  x1_ohm,
  b1_siemens,
  s_nom,
  un_kv,
  r1_ohm_pro_km,
  x1_ohm_pro_km,
  b1_siemens_pro_km) 
SELECT
  'Tennet',
  3,
  substation_from,
  substation_to,
  length_km,
  r1_ohm,
  x1_ohm,
  (c1_micro_f * 2 * 50 * pi()) * 10^(-6),
  round(((ir_a::numeric/1000)*(|/3)*un_kv)::numeric),
  un_kv,
  r1_ohm_pro_km,
  x1_ohm_pro_km,
  (c1_micro_f_pro_km * 2 * 50 * pi()) * 10^(-6)
FROM model_draft.ego_grid_pf_hv_val_tennet_line;

-- TransnetBW:
 INSERT INTO model_draft.ego_grid_pf_hv_val_tso_lines(
  tso_name,
  tso_id,
  substation_from,
  substation_to,
  length_km,
  r1_ohm,
  x1_ohm,
  b1_siemens,
  s_nom,
  un_kv) 
SELECT
  'TransnetBW',
  4,
  substation_from,
  substation_to,
  length_km,
  r1_ohm,
  x1_ohm,
  (c1_micro_f * 2 * 50 * pi()) * 10^(-6),
  sn_mva,
  un_kv
FROM model_draft.ego_grid_pf_hv_val_transnetbw_line; 


-- Sort substation names (like in Step 0)
UPDATE model_draft.ego_grid_pf_hv_val_tso_lines b
SET 
substation_from = a.substation_from,
substation_to = a.substation_to
FROM
(SELECT 
	index,				
	CASE 
	WHEN substation_from < substation_to 
	THEN substation_from 
	ELSE substation_to 
	END as substation_from,
	CASE 
	WHEN substation_from < substation_to 
	THEN substation_to 
	ELSE substation_from 
	END as substation_to
FROM  model_draft.ego_grid_pf_hv_val_tso_lines
ORDER BY index) as a
WHERE b.index = a.index;

------------------------------------------------------
-- FILL TSO TRAFO TABLE WITH DATA FROM OTHER TABLES --
------------------------------------------------------
-- Amprion:
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_transformers(
  tso_name,
  tso_id,
  substation_name,
  r1_ohm,
  x1_ohm,
  s_nom,
  un_1_kv,
  un_2_kv) 
SELECT
  'Amprion',
  1,
  substation_location,
  r1_pu,
  x1_pu,
  round(((ir_a::numeric/1000)*(|/3)*380)::numeric),
  380,
  220
FROM model_draft.ego_grid_pf_hv_val_amprion_transformer;

-- Hertz:
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_transformers(
  tso_name,
  tso_id,
  substation_name,
  r1_ohm,
  x1_ohm,
  s_nom,
  un_1_kv,
  un_2_kv) 
SELECT
  'Hertz',
  2,
  substation_location,
  r1_ohm,
  x1_ohm,
  sr_mva,
  ur1_kv,
  ur2_kv
FROM model_draft.ego_grid_pf_hv_val_hertz_transformer;


-- TransnetBW:
 INSERT INTO model_draft.ego_grid_pf_hv_val_tso_transformers(
  tso_name,
  tso_id,
  substation_name,
  r1_ohm,
  x1_ohm,
  s_nom,
  un_1_kv,
  un_2_kv) 
SELECT
  'TransnetBW',
  4,
  substation_location,  
  r1_pu,
  x1_pu,
  sr_mva,
  ur1_kv,
  ur2_kv
FROM model_draft.ego_grid_pf_hv_val_transnetbw_transformer; 

---------------------------------------
-- CALCULATE PER KM VALUES FOR R,X,C --
--------------------------------------- 
UPDATE model_draft.ego_grid_pf_hv_val_tso_lines
SET 
	r1_ohm_pro_km = r1_ohm / length_km,
	x1_ohm_pro_km = x1_ohm / length_km,
	b1_siemens_pro_km = b1_siemens / length_km

WHERE 
	r1_ohm_pro_km IS NULL AND
	x1_ohm_pro_km IS NULL AND
	b1_siemens_pro_km IS NULL AND
	length_km > 0;
	

 
--------------------------------------------------------------------------------------------
----------------------------------/**-- STEP 3 --**\----------------------------------------
--------------------------------------------------------------------------------------------
 

-----------------------------------------------------
-- GET SUBSTATION IDS FROM OSMTGMOD DIRECTLY FIRST --
-----------------------------------------------------
-- first direct match, then alike match
-- bus0
UPDATE model_draft.ego_grid_pf_hv_val_tso_lines a
	SET bus0 = b.bus_i
	FROM grid.otg_ehvhv_bus_data b
	WHERE b.osm_name = substation_from AND un_kv = b.base_kv;
	
UPDATE model_draft.ego_grid_pf_hv_val_tso_lines a
	SET bus0 = b.bus_i
	FROM grid.otg_ehvhv_bus_data b
	WHERE b.osm_name~* substation_from AND un_kv = b.base_kv AND bus0 IS NULL;
	
--bus1
UPDATE model_draft.ego_grid_pf_hv_val_tso_lines a
	SET bus1 = b.bus_i
	FROM grid.otg_ehvhv_bus_data b
	WHERE b.osm_name = substation_to AND un_kv = b.base_kv;
	
UPDATE model_draft.ego_grid_pf_hv_val_tso_lines a
	SET bus1 = b.bus_i
	FROM grid.otg_ehvhv_bus_data b
	WHERE b.osm_name~* substation_to AND un_kv = b.base_kv AND bus1 IS NULL;
	
	
-- SAME FOR TRAFOS:
--bus0
UPDATE model_draft.ego_grid_pf_hv_val_tso_transformers a
	SET bus0 = b.bus_i
	FROM grid.otg_ehvhv_bus_data b
	WHERE b.osm_name = substation_name AND un_1_kv = b.base_kv;
	
UPDATE model_draft.ego_grid_pf_hv_val_tso_transformers a
	SET bus0 = b.bus_i
	FROM grid.otg_ehvhv_bus_data b
	WHERE b.osm_name~* substation_name AND un_1_kv = b.base_kv AND bus0 IS NULL;
	
--bus1
UPDATE model_draft.ego_grid_pf_hv_val_tso_transformers a
	SET bus1 = b.bus_i
	FROM grid.otg_ehvhv_bus_data b
	WHERE b.osm_name = substation_name AND un_2_kv = b.base_kv;
	
UPDATE model_draft.ego_grid_pf_hv_val_tso_transformers a
	SET bus1 = b.bus_i
	FROM grid.otg_ehvhv_bus_data b
	WHERE b.osm_name~* substation_name AND un_2_kv = b.base_kv  AND bus1 IS NULL;
	
-- Results of this step:
SELECT 
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_lines) as "total lines",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_lines 
	WHERE (bus0 IS NULL AND bus1 IS  NULL)) as "lines: 0 bus ids",
	(SELECT count(*) FROM model_draft.ego_grid_pf_hv_val_tso_lines
	WHERE (bus0 IS NOT NULL OR bus1 IS NOT NULL) AND NOT (bus0 IS NOT NULL AND bus1 IS NOT NULL)) as "lines: 1 bus id",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_lines 
	WHERE (bus0 IS NOT NULL AND bus1 IS NOT NULL)) as "lines: 2 bus ids",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_transformers) as "total trafos",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_transformers 
	WHERE (bus0 IS NULL AND bus1 IS  NULL)) as "trafos: 0 bus ids",
	(SELECT count(*) FROM model_draft.ego_grid_pf_hv_val_tso_transformers
	WHERE (bus0 IS NOT NULL OR bus1 IS NOT NULL) AND NOT (bus0 IS NOT NULL AND bus1 IS NOT NULL)) as "trafos: 1 bus id",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_transformers 
	WHERE (bus0 IS NOT NULL AND bus1 IS NOT NULL)) as "trafos: 2 bus ids";	

 
--------------------------------------------------------------------------------------------
----------------------------------/**-- STEP 4 --**\----------------------------------------
--------------------------------------------------------------------------------------------
 

---------------------------------------------------------
-- ADD GEOMS OF RESPECTIVE VERTICES TO TSO LINE TABLES --
---------------------------------------------------------
-- lines:
UPDATE model_draft.ego_grid_pf_hv_val_tso_lines a
	SET bus0_geom = b.geom
	FROM model_draft.ego_grid_pf_hv_val_scigrid_vertices b
	WHERE substation_from = b.name;

UPDATE model_draft.ego_grid_pf_hv_val_tso_lines a
	SET bus1_geom = b.geom
	FROM model_draft.ego_grid_pf_hv_val_scigrid_vertices b
	WHERE substation_to = b.name;

-- trafos:
UPDATE model_draft.ego_grid_pf_hv_val_tso_transformers a
	SET bus0_geom = b.geom
	FROM model_draft.ego_grid_pf_hv_val_scigrid_vertices b
	WHERE substation_name = b.name;

UPDATE model_draft.ego_grid_pf_hv_val_tso_transformers a
	SET bus1_geom = b.geom
	FROM model_draft.ego_grid_pf_hv_val_scigrid_vertices b
	WHERE substation_name = b.name;	
	
--results:

SELECT 
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_lines) as "total lines",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_lines 
	WHERE (bus0_geom IS NULL AND bus1_geom IS  NULL)) as "lines: 0 bus geoms",
	(SELECT count(*) FROM model_draft.ego_grid_pf_hv_val_tso_lines
	WHERE (bus0_geom IS NOT NULL OR bus1_geom IS NOT NULL) AND NOT (bus0_geom IS NOT NULL AND bus1_geom IS NOT NULL)) as "lines: 1 bus geoms",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_lines 
	WHERE (bus0_geom IS NOT NULL AND bus1_geom IS NOT NULL)) as "lines: 2 bus geoms",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_transformers) as "total trafos",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_transformers 
	WHERE (bus0_geom IS NULL AND bus1_geom IS  NULL)) as "trafos: 0 bus geoms",
	(SELECT count(*) FROM model_draft.ego_grid_pf_hv_val_tso_transformers
	WHERE (bus0_geom IS NOT NULL OR bus1_geom IS NOT NULL) AND NOT (bus0_geom IS NOT NULL AND bus1_geom IS NOT NULL)) as "trafos: 1 bus geoms",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_transformers 
	WHERE (bus0_geom IS NOT NULL AND bus1_geom IS NOT NULL)) as "trafos: 2 bus geoms";
----------------------------------------------------
-- FIND NEAREST BUS_ID FROM otg_ehvhv_bus_data --
----------------------------------------------------
-- lines:
UPDATE model_draft.ego_grid_pf_hv_val_tso_lines a
SET bus0 = result_bus0.bus_id
FROM (SELECT DISTINCT ON (b.index) b.index, c.bus_i as bus_id, ST_Distance(b.bus0_geom::geography,c.geom::geography) AS distance  
	 FROM model_draft.ego_grid_pf_hv_val_tso_lines b, grid.otg_ehvhv_bus_data c
	 WHERE b.un_kv = c.base_kv AND c.osm_substation_id IS NOT NULL ORDER BY index, distance) AS result_bus0
WHERE distance < 1000 AND a.index = result_bus0.index AND a.bus0 IS NULL;

UPDATE model_draft.ego_grid_pf_hv_val_tso_lines a
SET bus1 = result_bus1.bus_id
FROM (SELECT DISTINCT ON (b.index) b.index, c.bus_i as bus_id, ST_Distance(b.bus1_geom::geography,c.geom::geography) AS distance  
	 FROM model_draft.ego_grid_pf_hv_val_tso_lines b, grid.otg_ehvhv_bus_data c
	 WHERE b.un_kv = c.base_kv AND c.osm_substation_id IS NOT NULL ORDER BY index, distance) AS result_bus1
WHERE distance < 1000 AND a.index = result_bus1.index AND a.bus1 IS NULL;

-- TOTAL: 618	
-- 0 bus ids: 3
-- 1 bus id: 68
-- 2 bus ids: 547
-- useful: 547/618 = 88.51 %

-- trafos:
UPDATE model_draft.ego_grid_pf_hv_val_tso_transformers a
SET bus0 = result_bus0.bus_id
FROM (SELECT DISTINCT ON (b.index) b.index, c.bus_i as bus_id, ST_Distance(b.bus0_geom::geography,c.geom::geography) AS distance  
	 FROM model_draft.ego_grid_pf_hv_val_tso_transformers b, grid.otg_ehvhv_bus_data c
	 WHERE b.un_1_kv = c.base_kv AND c.osm_substation_id IS NOT NULL ORDER BY index, distance) AS result_bus0
WHERE distance < 1000 AND a.index = result_bus0.index AND a.bus0 IS NULL;

UPDATE model_draft.ego_grid_pf_hv_val_tso_transformers a
SET bus1 = result_bus1.bus_id
FROM (SELECT DISTINCT ON (b.index) b.index, c.bus_i as bus_id, ST_Distance(b.bus1_geom::geography,c.geom::geography) AS distance  
	 FROM model_draft.ego_grid_pf_hv_val_tso_transformers b, grid.otg_ehvhv_bus_data c
	 WHERE b.un_2_kv = c.base_kv AND c.osm_substation_id IS NOT NULL ORDER BY index, distance) AS result_bus1
WHERE distance < 1000 AND a.index = result_bus1.index AND a.bus1 IS NULL;

-- results:

SELECT 
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_lines) as "total lines",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_lines 
	WHERE (bus0 IS NULL AND bus1 IS  NULL)) as "lines: 0 bus ids",
	(SELECT count(*) FROM model_draft.ego_grid_pf_hv_val_tso_lines
	WHERE (bus0 IS NOT NULL OR bus1 IS NOT NULL) AND NOT (bus0 IS NOT NULL AND bus1 IS NOT NULL)) as "lines: 1 bus id",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_lines 
	WHERE (bus0 IS NOT NULL AND bus1 IS NOT NULL)) as "lines: 2 bus ids",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_transformers) as "total trafos",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_transformers 
	WHERE (bus0 IS NULL AND bus1 IS  NULL)) as "trafos: 0 bus ids",
	(SELECT count(*) FROM model_draft.ego_grid_pf_hv_val_tso_transformers
	WHERE (bus0 IS NOT NULL OR bus1 IS NOT NULL) AND NOT (bus0 IS NOT NULL AND bus1 IS NOT NULL)) as "trafos: 1 bus id",
	(SELECT count(*) 
	FROM model_draft.ego_grid_pf_hv_val_tso_transformers 
	WHERE (bus0 IS NOT NULL AND bus1 IS NOT NULL)) as "trafos: 2 bus ids";	
 
--------------------------------------------------------------------------------------------
----------------------------------/**-- STEP 5 --**\----------------------------------------
--------------------------------------------------------------------------------------------
 

---------------------------------------------
-- CHECK IF TSO LINE IS USEFUL FOR ROUTING --
---------------------------------------------
UPDATE model_draft.ego_grid_pf_hv_val_tso_lines
SET useful = TRUE
WHERE 	(bus0 IS NOT NULL AND 
		bus1 IS NOT NULL) AND
		bus1 != bus0 AND
		length_km > 0 AND
		r1_ohm  > 0 AND
		x1_ohm  > 0 AND
		b1_siemens  > 0;

UPDATE model_draft.ego_grid_pf_hv_val_tso_transformers
SET useful = TRUE
WHERE 	bus0 IS NOT NULL AND 
		bus1 IS NOT NULL AND
		r1_ohm > 0 AND
		x1_ohm > 0;
--------------------------------------------
-- INSERT SINGLE LINES INTO ROUTING TABLE --	
--------------------------------------------
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_lines_routing
SELECT * FROM model_draft.ego_grid_pf_hv_val_tso_lines
	WHERE INDEX IN 
		(SELECT DISTINCT on (line_pair_id) unnest(lines) as tso_line 
		FROM
			(SELECT 
				row_number() OVER (ORDER BY array_agg(index)) as line_pair_id,
				array_agg(index) as lines, 
				array_agg(tso_name) as tso_names,
				array_agg(useful) as useful,
				count(*)
			FROM
				(SELECT  
					index,
					tso_name,
					substation_from,
					substation_to, 
					un_kv,
					useful
				FROM model_draft.ego_grid_pf_hv_val_tso_lines
				ORDER BY index	) as a
				GROUP BY substation_from,substation_to, un_kv
				HAVING 
				count(*) = 1 AND 
				array_agg(useful)::text !~ 'f') 
		as a);
-- 266 lines
				
-- If in two parallel lines, only 1 is useful, only this will be used		
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_lines_routing
SELECT * FROM model_draft.ego_grid_pf_hv_val_tso_lines
WHERE INDEX IN 
(SELECT tso_line FROM
	(SELECT unnest(lines) as tso_line, unnest(useful) as useful FROM
				(SELECT 
					row_number() OVER (ORDER BY array_agg(index)) as line_pair_id,
					array_agg(index) as lines, 
					array_agg(tso_name) as tso_names,
					array_agg(useful) as useful,
					count(*)
				FROM
					(SELECT  
						index,
						tso_name,
						substation_from,
						substation_to, 
						un_kv,
						useful
					FROM model_draft.ego_grid_pf_hv_val_tso_lines
					ORDER BY index	) as a
					GROUP BY substation_from,substation_to, un_kv
					HAVING 
					count(*) > 1 AND 
					array_agg(useful)::text ~ 'f' AND
					array_agg(useful)::text ~ 't' 
				)as a
	)as b
WHERE useful);
-- 2 lines"				
			
--------------------------------------------------------------
-- CHECK IF TSO LINE IS USEFUL MERGING MULTI-LINES (MANUAL) --
--------------------------------------------------------------
-- Requirements:
-- All agg_names of TSOs must be identical (e.g. no mix of Amprion/TenneT)

-- 2 PARALLEL Lines with varying TSO_names AND varying lengths (e.g. one Tennet, one Amprion):
-- Always take the LONGER line from each pair, since it fits the reality better 

INSERT INTO model_draft.ego_grid_pf_hv_val_tso_lines_routing(
	index,	tso_name, tso_id, substation_from, substation_to, length_km, x1_ohm, r1_ohm,
	b1_siemens,	s_nom, un_kv, bus0, bus1)
SELECT distinct ON (line_pair_id) 
	tso_line, tso_name, tso_id, substation_from, substation_to, length_km,
	x1_ohm, r1_ohm, b1_siemens, s_nom, un_kv, bus0, bus1
FROM
	(SELECT 
		line_pair_id, unnest(lines) as tso_line, unnest(length_km) as length_km, 
		unnest(tso_name) as tso_name, unnest(tso_id) as tso_id,	substation_from,
		substation_to, un_kv, x1_ohm, r1_ohm, b1_siemens, s_nom, bus0, bus1
	FROM
		(SELECT 
			row_number() OVER (ORDER BY array_agg(index)) as line_pair_id,
			array_agg(index) as lines, array_agg(tso_name) as tso_name,
			array_agg(tso_id) as tso_id, substation_from, substation_to, 
			min(un_kv) as un_kv, array_agg(length_km) as length_km,
			avg(x1_ohm) as x1_ohm, avg(r1_ohm) as r1_ohm, 
			avg(b1_siemens) as b1_siemens, avg(s_nom) as s_nom,
			min(bus0) as bus0, min(bus1) as bus1
		FROM
			(SELECT  
				index, tso_name,tso_id, substation_from, substation_to, un_kv,
				length_km, useful, r1_ohm, x1_ohm, b1_siemens, s_nom,
				bus0, bus1
			FROM model_draft.ego_grid_pf_hv_val_tso_lines
			WHERE useful) 
			as a
		GROUP BY substation_from,substation_to, un_kv
		HAVING 
			count(*) = 2 AND
			stddev_samp(tso_id) != 0 AND
			stddev_samp(length_km) > 1) 
		as b
	ORDER BY line_pair_id, length_km DESC) 
as c;
-- 3 lines


-- Same as above, but this time stddev_samp(length_km)<1, so lines are likely to be same
-- therefore, the average of the lengths will be taken:

INSERT INTO model_draft.ego_grid_pf_hv_val_tso_lines_routing(
	index,	tso_name, tso_id, substation_from, substation_to, length_km, x1_ohm, r1_ohm,
	b1_siemens,	s_nom, un_kv, bus0, bus1)
SELECT distinct ON (line_pair_id) 
	tso_line, tso_name, tso_id, substation_from, substation_to, length_km,
	x1_ohm, r1_ohm, b1_siemens, s_nom, un_kv, bus0, bus1
FROM
	(SELECT 
		line_pair_id, unnest(lines) as tso_line, length_km, 
		unnest(tso_name) as tso_name, unnest(tso_id) as tso_id,	substation_from,
		substation_to, un_kv, x1_ohm, r1_ohm, b1_siemens, s_nom, bus0, bus1
	FROM
		(SELECT 
			row_number() OVER (ORDER BY array_agg(index)) as line_pair_id,
			array_agg(index) as lines, array_agg(tso_name) as tso_name,
			array_agg(tso_id) as tso_id, substation_from, substation_to, 
			min(un_kv) as un_kv, avg(length_km) as length_km,
			avg(x1_ohm) as x1_ohm, avg(r1_ohm) as r1_ohm, 
			avg(b1_siemens) as b1_siemens, avg(s_nom) as s_nom,
			min(bus0) as bus0, min(bus1) as bus1
		FROM
			(SELECT  
				index, tso_name,tso_id, substation_from, substation_to, un_kv,
				length_km, useful, r1_ohm, x1_ohm, b1_siemens, s_nom,
				bus0, bus1
			FROM model_draft.ego_grid_pf_hv_val_tso_lines
			WHERE useful) 
			as a
		GROUP BY substation_from,substation_to, un_kv
		HAVING 
			count(*) = 2 AND
			stddev_samp(tso_id) != 0 AND
			stddev_samp(length_km) <= 1) 
		as b
	ORDER BY line_pair_id, tso_line DESC) 
as c;

-- 5 lines
	
UPDATE model_draft.ego_grid_pf_hv_val_tso_lines_routing
SET numb_sys = 1;	

-- DOUBLE/TRIPLE LINES:
-- MERGING where stddev_samp(length_km) < 1: 
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_lines_routing(
	index,	tso_name, tso_id, substation_from, substation_to, length_km, x1_ohm, r1_ohm,
	b1_siemens, s_nom, un_kv,bus0, bus1, numb_sys)

SELECT DISTINCT on (line_pair_id) 
	unnest(lines) as tso_line,
	tso_name, tso_id, substation_from, substation_to, length_km,
	x1_ohm, r1_ohm, b1_siemens, s_nom, un_kv,bus0, bus1,numb_sys
	FROM
	((
	SELECT 
			row_number() OVER (ORDER BY array_agg(index)) as line_pair_id,
			array_agg(index) as lines, min(tso_name) as tso_name, min(tso_id) as tso_id,
			substation_from, substation_to, min(un_kv) as un_kv, avg(length_km) as length_km,
			sum(x1_ohm^(-1))^(-1) as x1_ohm, sum(r1_ohm^(-1))^(-1) as r1_ohm,
			sum(b1_siemens) as b1_siemens, sum(s_nom) as s_nom, count(*) as numb_sys,
			min(bus0) as bus0, min(bus1) as bus1
	FROM
		(SELECT  
			index, tso_name, tso_id, substation_from, substation_to, un_kv,
			length_km, r1_ohm, x1_ohm, b1_siemens, s_nom, useful,
			bus0, bus1
		FROM model_draft.ego_grid_pf_hv_val_tso_lines
		WHERE useful) as a

	GROUP BY substation_from,substation_to, un_kv
	HAVING 
	count(*) > 1 AND 
	array_agg(useful)::text !~ 'f' AND
	stddev_samp(tso_id) = 0 AND
	stddev_samp(length_km) < 1
	)) as b;´
-- 99 lines

-- DOUBLE/TRIPLE LINES:
-- MERGING where stddev_samp(length_km) > 1: 
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_lines_routing(
	index,	tso_name, tso_id, substation_from, substation_to, length_km, x1_ohm, r1_ohm,
	b1_siemens, s_nom, un_kv,bus0, bus1, numb_sys)

SELECT DISTINCT on (line_pair_id) 
	unnest(lines) as tso_line,
	tso_name, tso_id, substation_from, substation_to, length_km,
	x1_ohm, r1_ohm, b1_siemens, s_nom, un_kv,bus0, bus1,numb_sys
	FROM
	((
	SELECT 
			row_number() OVER (ORDER BY array_agg(index)) as line_pair_id,
			array_agg(index) as lines, min(tso_name) as tso_name, min(tso_id) as tso_id,
			substation_from, substation_to, min(un_kv) as un_kv, max(length_km) as length_km,
			sum(x1_ohm^(-1))^(-1) as x1_ohm, sum(r1_ohm^(-1))^(-1) as r1_ohm,
			sum(b1_siemens) as b1_siemens, sum(s_nom) as s_nom, count(*) as numb_sys,
			min(bus0) as bus0, min(bus1) as bus1
	FROM
		(SELECT  
			index, tso_name, tso_id, substation_from, substation_to, un_kv,
			length_km, r1_ohm, x1_ohm, b1_siemens, s_nom, useful,
			bus0, bus1
		FROM model_draft.ego_grid_pf_hv_val_tso_lines
		WHERE useful) as a

	GROUP BY substation_from,substation_to, un_kv
	HAVING 
	count(*) > 1 AND 
	array_agg(useful)::text !~ 'f' AND
	stddev_samp(tso_id) = 0 AND
	stddev_samp(length_km) > 1
	)) as b;
-- 3 lines

-- Quad parallel lines with 2 TSOs:
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_lines_routing(
	index,	tso_name, tso_id, substation_from, substation_to, length_km, x1_ohm, r1_ohm,
	b1_siemens, s_nom, un_kv,bus0, bus1, numb_sys)
SELECT 
	min(tso_line) as index,
	min(tso_name) as tso_name,
	min(tso_id) as tso_id,
	min(substation_from) as substation_from,
	min(substation_to) as substation_to,
	avg(length_km) as length_km,
	avg(x1_ohm) as x1_ohm, 
	avg(r1_ohm) as r1_ohm,
	avg(b1_siemens) as b1_siemens, 
	avg(s_nom) as s_nom,
	min(un_kv) as un_kv,
	min(bus0) as bus0,
	min(bus1) as bus1,
	min(numb_sys) as numb_sys
	FROM
(SELECT 
	line_pair_id,
	min(tso_line) as tso_line,
	avg(length_km) as length_km,
	min(tso_name) as tso_name,
	tso_id,
	min(substation_from) as substation_from,
	min(substation_to) as substation_to,
	min(un_kv) as un_kv,
	sum(x1_ohm^(-1))^(-1) as x1_ohm, 
	sum(r1_ohm^(-1))^(-1) as r1_ohm,
	sum(b1_siemens) as b1_siemens, 
	sum(s_nom) as s_nom,
	min(bus0) as bus0,
	min(bus1) as bus1,
	count(*) as numb_sys
FROM
	(SELECT 
		line_pair_id, unnest(lines) as tso_line, unnest(length_km) as length_km, 
		unnest(tso_name) as tso_name, unnest(tso_id) as tso_id,	substation_from,
		substation_to, un_kv, unnest(x1_ohm) as x1_ohm, unnest(r1_ohm) as r1_ohm, 
		unnest(b1_siemens) as b1_siemens, unnest(s_nom) as s_nom, bus0, bus1
	FROM
		(SELECT 
			row_number() OVER (ORDER BY array_agg(index)) as line_pair_id,
			array_agg(index) as lines, array_agg(tso_name) as tso_name,
			array_agg(tso_id) as tso_id, substation_from, substation_to, 
			min(un_kv) as un_kv, array_agg(length_km) as length_km,
			array_agg(x1_ohm) as x1_ohm, array_agg(r1_ohm) as r1_ohm, 
			array_agg(b1_siemens) as b1_siemens, array_agg(s_nom) as s_nom,
			min(bus0) as bus0, min(bus1) as bus1
		FROM
			(SELECT  
				index, tso_name,tso_id, substation_from, substation_to, un_kv,
				length_km, useful, r1_ohm, x1_ohm, b1_siemens, s_nom,
				bus0, bus1
			FROM model_draft.ego_grid_pf_hv_val_tso_lines
			WHERE useful) 
			as a
		GROUP BY substation_from,substation_to, un_kv
		HAVING 
			count(*) > 2 AND
			stddev_samp(tso_id) != 0 AND
			stddev_samp(length_km) < 1) 
		as b
	ORDER BY line_pair_id, length_km DESC) 
	as c
GROUP BY line_pair_id, tso_id) 
as d
GROUP BY line_pair_id;
--3 lines 


-- Quad parallel lines with 2 TSOs AND stddev_samp(length_km) > 1:
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_lines_routing(
	index,	tso_name, tso_id, substation_from, substation_to, length_km, x1_ohm, r1_ohm,
	b1_siemens, s_nom, un_kv,bus0, bus1, numb_sys)
SELECT 
	min(tso_line) as index,
	min(tso_name) as tso_name,
	min(tso_id) as tso_id,
	min(substation_from) as substation_from,
	min(substation_to) as substation_to,
	max(length_km) as length_km,
	avg(x1_ohm) as x1_ohm, 
	avg(r1_ohm) as r1_ohm,
	avg(b1_siemens) as b1_siemens, 
	avg(s_nom) as s_nom,
	min(un_kv) as un_kv,
	min(bus0) as bus0,
	min(bus1) as bus1,
	min(numb_sys) as numb_sys
	FROM
(SELECT 
	line_pair_id,
	min(tso_line) as tso_line,
	avg(length_km) as length_km,
	min(tso_name) as tso_name,
	tso_id,
	min(substation_from) as substation_from,
	min(substation_to) as substation_to,
	min(un_kv) as un_kv,
	sum(x1_ohm^(-1))^(-1) as x1_ohm, 
	sum(r1_ohm^(-1))^(-1) as r1_ohm,
	sum(b1_siemens) as b1_siemens, 
	sum(s_nom) as s_nom,
	min(bus0) as bus0,
	min(bus1) as bus1,
	count(*) as numb_sys
FROM
	(SELECT 
		line_pair_id, unnest(lines) as tso_line, unnest(length_km) as length_km, 
		unnest(tso_name) as tso_name, unnest(tso_id) as tso_id,	substation_from,
		substation_to, un_kv, unnest(x1_ohm) as x1_ohm, unnest(r1_ohm) as r1_ohm, 
		unnest(b1_siemens) as b1_siemens, unnest(s_nom) as s_nom, bus0, bus1
	FROM
		(SELECT 
			row_number() OVER (ORDER BY array_agg(index)) as line_pair_id,
			array_agg(index) as lines, array_agg(tso_name) as tso_name,
			array_agg(tso_id) as tso_id, substation_from, substation_to, 
			min(un_kv) as un_kv, array_agg(length_km) as length_km,
			array_agg(x1_ohm) as x1_ohm, array_agg(r1_ohm) as r1_ohm, 
			array_agg(b1_siemens) as b1_siemens, array_agg(s_nom) as s_nom,
			min(bus0) as bus0, min(bus1) as bus1
		FROM
			(SELECT  
				index, tso_name,tso_id, substation_from, substation_to, un_kv,
				length_km, useful, r1_ohm, x1_ohm, b1_siemens, s_nom,
				bus0, bus1
			FROM model_draft.ego_grid_pf_hv_val_tso_lines
			WHERE useful) 
			as a
		GROUP BY substation_from,substation_to, un_kv
		HAVING 
			count(*) > 2 AND
			stddev_samp(tso_id) != 0 AND
			stddev_samp(length_km) > 1) 
		as b
	ORDER BY line_pair_id, length_km DESC) 
	as c
GROUP BY line_pair_id, tso_id
ORDER BY length_km DESC) 
as d
GROUP BY line_pair_id;

-- 1 line

UPDATE model_draft.ego_grid_pf_hv_val_tso_lines_routing
SET

	r1_ohm_pro_km = r1_ohm/length_km,
	x1_ohm_pro_km = x1_ohm/length_km,
	b1_siemens_pro_km = b1_siemens/length_km;

------------------------------
-- GROUP TRAFOS FOR ROUTING --
------------------------------
-- SINGLE TRAFOS:
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_transformers_routing
SELECT * FROM model_draft.ego_grid_pf_hv_val_tso_transformers
	WHERE INDEX IN 
		(SELECT DISTINCT on (trafo_pair_id) unnest(trafos) as tso_trafos 
		FROM
			(SELECT 
				row_number() OVER (ORDER BY array_agg(index)) as trafo_pair_id,
				array_agg(index) as trafos, 
				array_agg(tso_name) as tso_names,
				array_agg(useful) as useful,
				count(*)
			FROM
				(SELECT  
					index,
					tso_name,
					substation_name,
					useful
				FROM model_draft.ego_grid_pf_hv_val_tso_transformers
				ORDER BY index	) as a
				GROUP BY substation_name
				HAVING 
				count(*) = 1 AND 
				array_agg(useful)::text !~ 'f') 
		as a);
--25 trafos	
	
-- PARALLEL TRAFOS, only 1 useful:
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_transformers_routing
SELECT * FROM model_draft.ego_grid_pf_hv_val_tso_transformers
WHERE INDEX IN 
(SELECT tso_trafo FROM
	(SELECT unnest(trafos) as tso_trafo, unnest(useful) as useful FROM
				(SELECT 
					row_number() OVER (ORDER BY array_agg(index)) as line_pair_id,
					array_agg(index) as trafos, 
					array_agg(tso_name) as tso_names,
					array_agg(useful) as useful,
					count(*)
				FROM
					(SELECT  
						index,
						tso_name,
						substation_name,
						useful
					FROM model_draft.ego_grid_pf_hv_val_tso_transformers
					ORDER BY index	) as a
					GROUP BY substation_name
					HAVING 
					count(*) > 1 AND 
					array_agg(useful)::text ~ 'f' AND
					array_agg(useful)::text ~ 't' 
				)as a
	)as b
WHERE useful);	
-- 1 trafo
	
-- PARALLEL TRAFOS, both useful:
INSERT INTO model_draft.ego_grid_pf_hv_val_tso_transformers_routing(
	index,	tso_name, tso_id, substation_name, x1_ohm, r1_ohm, 
	s_nom, un_1_kv, un_2_kv,bus0, bus1, numb_sys)

SELECT DISTINCT on (trafo_pair_id) 
	unnest(trafos) as tso_trafos,
	tso_name, tso_id, substation_name,
	x1_ohm, r1_ohm, s_nom, un_1_kv, un_2_kv,bus0, bus1,numb_sys
	FROM
	((
	SELECT 
			row_number() OVER (ORDER BY array_agg(index)) as trafo_pair_id,
			array_agg(index) as trafos, min(tso_name) as tso_name, min(tso_id) as tso_id,
			substation_name, min(un_1_kv) as un_1_kv, min(un_2_kv) as un_2_kv,
			sum(x1_ohm^(-1))^(-1) as x1_ohm, sum(r1_ohm^(-1))^(-1) as r1_ohm,
			sum(s_nom) as s_nom, count(*) as numb_sys,
			min(bus0) as bus0, min(bus1) as bus1
	FROM
		(SELECT  
			index, tso_name, tso_id, substation_name, un_1_kv, un_2_kv,
			r1_ohm, x1_ohm, s_nom, useful,
			bus0, bus1
		FROM model_draft.ego_grid_pf_hv_val_tso_transformers
		WHERE useful) as a

	GROUP BY substation_name
	HAVING 
	count(*) > 1
	)) as b;
--12 trafos

-------------------------------
-- PREPERATIONS FOR ROUTING  --
-------------------------------
-- LINES
DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_val_osm_tso_translate;
CREATE TABLE model_draft.ego_grid_pf_hv_val_osm_tso_translate
(
  index serial NOT NULL,
  tso_line bigint,
  osm_line bigint,
  bus0 bigint,
  bus1 bigint,
  length double precision,
  r1_ohm_pro_km double precision,
  x1_ohm_pro_km double precision,
  b1_siemens_pro_km double precision,
  s_nom bigint,
  geom geometry(MultiLineString,4326),
  topo geometry(LineString,4326),
  useful boolean DEFAULT false,
  CONSTRAINT osm_tso_translate_pkey PRIMARY KEY (index)
)
WITH (
  OIDS=FALSE
);

--ORDER TRAFOS
UPDATE model_draft.ego_grid_pf_hv_val_tso_transformers_routing b
SET 
bus0 = a.bus0,
bus1 = a.bus1
FROM
(SELECT 
	index,				
	CASE 
	WHEN bus0 < bus1 
	THEN bus0 
	ELSE bus1 
	END as bus0,
	CASE 
	WHEN bus0 < bus1 
	THEN bus1 
	ELSE bus0 
	END as bus1
FROM  model_draft.ego_grid_pf_hv_val_tso_transformers_routing
ORDER BY index) as a
WHERE b.index = a.index;

 
--------------------------------------------------------------------------------------------
----------------------------------/**-- STEP 6 --**\----------------------------------------
--------------------------------------------------------------------------------------------
 

-----------------------------
-- CREATE ROUTING FUNCTION --
-----------------------------

CREATE OR REPLACE FUNCTION find_osm_tso_partner_line () RETURNS void
AS $$

DECLARE
v_branch RECORD;
v_result_seq RECORD;

BEGIN
TRUNCATE model_draft.ego_grid_pf_hv_val_osm_tso_translate;
FOR v_branch IN
	SELECT index as tso_index, bus0, bus1 FROM model_draft.ego_grid_pf_hv_val_tso_lines_routing
	
	LOOP
		FOR v_result_seq IN
			SELECT seq, id2 AS line_id, cost
					FROM pgr_dijkstra(
					'SELECT 
						line_id::integer as id, 
						bus0::integer as source, 
						bus1::integer as target, 
						length::double precision as cost 
					FROM grid.ego_pf_hv_line
					WHERE scn_name = ''Status Quo OSM'' AND
					bus0 IN (SELECT bus_i from grid.otg_ehvhv_bus_data) AND
					bus1 IN (SELECT bus_i from grid.otg_ehvhv_bus_data)',
					v_branch.bus0, 
					v_branch.bus1, 
					false, 
					false)
				LOOP
				
					INSERT INTO model_draft.ego_grid_pf_hv_val_osm_tso_translate
					(tso_line ,
					osm_line,
					bus0,
					bus1,
					length)
					SELECT 
					v_branch.tso_index,
					v_result_seq.line_id,
					v_branch.bus0,
					v_branch.bus1,
					v_result_seq.cost;
				END LOOP;
	END LOOP;
DELETE FROM model_draft.ego_grid_pf_hv_val_osm_tso_translate
WHERE osm_line <0;

UPDATE model_draft.ego_grid_pf_hv_val_osm_tso_translate a
SET 
	geom = b.geom,
	topo = b.topo
FROM grid.ego_pf_hv_line b
WHERE a.osm_line = b.line_id AND
	  scn_name = 'Status Quo OSM';

END
$$
LANGUAGE plpgsql;

---------------------------------------
-- IDENTIFY OSM LINES FROM TSO LINES --
---------------------------------------
SELECT find_osm_tso_partner_line ();

--Check results:
SELECT tso_line, array_agg(osm_line), count(*), sum(length)
FROM model_draft.ego_grid_pf_hv_val_osm_tso_translate
GROUP BY tso_line
ORDER BY count;


-----------------------------------
-- LENGTH COMPARISON FOR RESULTS --
-----------------------------------
UPDATE model_draft.ego_grid_pf_hv_val_osm_tso_translate
SET useful = True
WHERE tso_line IN
	(SELECT tso_line FROM
		(SELECT tso_line, length_osm/length_km as comp FROM
			(SELECT a.tso_line, a.osm_lines_array, a.length_osm, b.length_km FROM
				(SELECT tso_line, array_agg(osm_line) as osm_lines_array, sum(length) AS length_osm 
				FROM model_draft.ego_grid_pf_hv_val_osm_tso_translate a
				GROUP BY tso_line
				ORDER BY tso_line) AS a, model_draft.ego_grid_pf_hv_val_tso_lines_routing b
			WHERE b.index = a.tso_line) as c
		WHERE c.length_km >0) as d
	WHERE comp >0.9 AND comp < 1.1); -- allows for length variation of +-10%

SELECT 
(SELECT count(*) FROM model_draft.ego_grid_pf_hv_val_osm_tso_translate WHERE useful = true)/
(SELECT count(*) FROM model_draft.ego_grid_pf_hv_val_osm_tso_translate)::double precision*100;

-- useful: 1799
-- total: 2318
-- percentage: 77.61 %

DELETE FROM model_draft.ego_grid_pf_hv_val_osm_tso_translate
WHERE useful = FALSE;

------------------------------------------------
-- GET LINE SPECIFICATIONS IN TRANSLATE TABLE --
------------------------------------------------
UPDATE model_draft.ego_grid_pf_hv_val_osm_tso_translate a
SET r1_ohm_pro_km = result.r1_ohm_pro_km,
	x1_ohm_pro_km = result.x1_ohm_pro_km,
	b1_siemens_pro_km = result.b1_siemens_pro_km,
	s_nom = result.s_nom
FROM 
	(SELECT index, r1_ohm_pro_km, x1_ohm_pro_km, b1_siemens_pro_km, s_nom
	FROM model_draft.ego_grid_pf_hv_val_tso_lines_routing) as result
WHERE tso_line = result.index;

---------------------------------------
-- IDENTIFY OSM TRAFOS FROM TSO TRAFOS --
---------------------------------------
UPDATE model_draft.ego_grid_pf_hv_val_tso_transformers_routing a
SET osm_trafo_id = result.trafo_id
FROM 
(SELECT a.index, b.trafo_id, b.bus0, b.bus1
FROM model_draft.ego_grid_pf_hv_val_tso_transformers_routing a, grid.ego_pf_hv_transformer b WHERE b.scn_name = 'Status Quo OSM') as result
WHERE a.bus0 = result.bus0 AND a.bus1=result.bus1 AND a.index=result.index;
DELETE FROM model_draft.ego_grid_pf_hv_val_tso_transformers_routing  WHERE osm_trafo_id is NULL;

--36 Transformers identified
 
--------------------------------------------------------------------------------------------
----------------------------------/**-- STEP 7 --**\----------------------------------------
--------------------------------------------------------------------------------------------
 

--------------------------------
-- check duplicates at this state
---------------------------------

SELECT array_agg(index) as lines, osm_line, length, count(*)
FROM model_draft.ego_grid_pf_hv_val_osm_tso_translate
GROUP BY osm_line, length
HAVING count(*) > 1
ORDER BY count;

SELECT 
	osm_line,
	array_agg(tso_line) as tso_lines, 
	array_agg(r1_ohm_pro_km) as r1_ohm_pro_km, 
	array_agg(x1_ohm_pro_km) as x1_ohm_pro_km, 
	array_agg(b1_siemens_pro_km) as b1_siemens_pro_km, 
	array_agg(s_nom) as s_nom,
	length,
	count(*)
FROM model_draft.ego_grid_pf_hv_val_osm_tso_translate
GROUP BY osm_line, length
HAVING count(*) > 1
ORDER BY count;

SELECT 
	osm_line,
length,
	array_agg(tso_line) as tso_lines, 
	array_agg(round((r1_ohm_pro_km*length)::numeric,3)) as r1_ohm, 
	array_agg(round((x1_ohm_pro_km*length)::numeric,3)) as x1_ohm, 
	stddev_samp(round((r1_ohm_pro_km*length)::numeric,3)) as r_comp,
	stddev_samp(round((x1_ohm_pro_km*length)::numeric,3)) as x_comp,
	array_agg(s_nom) as s_nom,
	count(*)
FROM model_draft.ego_grid_pf_hv_val_osm_tso_translate
GROUP BY osm_line, length
HAVING count(*) > 1 and
stddev_samp(round((r1_ohm_pro_km*length)::numeric,3)) > 1 OR
stddev_samp(round((x1_ohm_pro_km*length)::numeric,3)) > 1
ORDER BY length DESC;

SELECT 
	osm_line,
	array_agg(tso_line) as tso_lines, 
	array_agg(s_nom) as s_nom, 
	stddev_samp(s_nom) as comp, 
	count(*)
FROM model_draft.ego_grid_pf_hv_val_osm_tso_translate
GROUP BY osm_line
HAVING count(*) > 1
ORDER BY comp;

---------------------------
-- CREATE NEW GRID MODEL --
---------------------------
DELETE FROM grid.ego_pf_hv_line
WHERE scn_name = 'Status Quo TSO';

INSERT INTO grid.ego_pf_hv_line(
  scn_name,
  line_id,
  bus0,
  bus1,
  x,
  r,
  g,
  b,
  s_nom,
  length,
  cables,
  frequency,
  geom,
  topo
)
SELECT 
  'Status Quo TSO',
  line_id,
  bus0,
  bus1,
  x,
  r,
  g,
  b,
  s_nom,
  length,
  cables,
  frequency,
  geom,
  topo
FROM grid.ego_pf_hv_line
WHERE scn_name = 'Status Quo OSM';

-- TRAFO:

DELETE FROM grid.ego_pf_hv_transformer
WHERE scn_name = 'Status Quo TSO';

INSERT INTO grid.ego_pf_hv_transformer(
  scn_name,
  trafo_id,
  bus0,
  bus1,
  x,
  r,
  g,
  b,
  s_nom,
  tap_ratio,
  phase_shift,
  geom,
  topo
)
SELECT 
  'Status Quo TSO',
  trafo_id,
  bus0,
  bus1,
  x,
  r,
  g,
  b,
  s_nom,
  1,
  0,
  geom,
  topo
 FROM grid.ego_pf_hv_transformer
 WHERE scn_name = 'Status Quo OSM';

--------------------------------
-- UPDATE TABLE WITH TSO DATA --
--------------------------------
-- LINES:
UPDATE grid.ego_pf_hv_line
SET 
x = result.x,
r = result.r,
b = result.b,
s_nom = result.s_nom
FROM
	(SELECT 
		osm_line, 
		avg(r1_ohm_pro_km)*length as r, 
		avg(x1_ohm_pro_km)*length as x,
		avg(b1_siemens_pro_km)*length as b,
		avg(s_nom) as s_nom
	FROM model_draft.ego_grid_pf_hv_val_osm_tso_translate
	GROUP BY osm_line, length)  as result
WHERE 
	scn_name = 'Status Quo TSO' AND 
	line_id = result.osm_line;

-- TRAFOS:

UPDATE grid.ego_pf_hv_transformer
SET 
x = result.x1_ohm,
r = result.r1_ohm,
s_nom = result.s_nom
FROM
(SELECT 
osm_trafo_id,
r1_ohm,
x1_ohm,
s_nom
FROM model_draft.ego_grid_pf_hv_val_tso_transformers_routing
WHERE osm_trafo_id IS NOT NULL) as result
WHERE 
	scn_name = 'Status Quo TSO' AND 
	trafo_id = result.osm_trafo_id;
	
 
--------------------------------------------------------------------------------------------
----------------------------------/**-- STEP X --**\----------------------------------------
--------------------------------------------------------------------------------------------
 
-- SWITCH CURRENT MODEL BACK TO OSM MODEL:

UPDATE grid.ego_pf_hv_line a
SET x = result.x, r = result.r, b = result.b, s_nom = result.s_nom
FROM
(SELECT line_id, x, r, b, s_nom 
FROM grid.ego_pf_hv_line WHERE scn_name='Status Quo OSM') as result
WHERE a.line_id = result.line_id AND
scn_name = 'Status Quo';

UPDATE grid.ego_pf_hv_transformer a
SET x = result.x, r = result.r, b = result.b, s_nom = result.s_nom
FROM
(SELECT trafo_id, x, r, b, s_nom 
FROM grid.ego_pf_hv_transformer WHERE scn_name='Status Quo OSM') as result
WHERE a.trafo_id = result.trafo_id AND
scn_name = 'Status Quo';