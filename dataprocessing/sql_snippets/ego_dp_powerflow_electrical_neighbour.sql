/*
The electricity grid model extracted from osmTGmod is limited to the German territory. This script adds border crossing 
lines and corresponding buses and transformers to all neighbouring countries which have a direct electrical connection 
to the German grid. 

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_bus_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_electrical_neighbours_bus_id;
SELECT setval('model_draft.ego_grid_hv_electrical_neighbours_bus_id', (MAX(bus_id)+1)) FROM model_draft.ego_grid_pf_hv_bus;


DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_line_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_electrical_neighbours_line_id;
SELECT setval('model_draft.ego_grid_hv_electrical_neighbours_line_id', (MAX(line_id)+1)) FROM model_draft.ego_grid_pf_hv_line;


DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_link_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_electrical_neighbours_link_id;
SELECT setval('model_draft.ego_grid_hv_electrical_neighbours_link_id', (MAX(link_id)+1)) FROM model_draft.ego_grid_pf_hv_link;


DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_transformer_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_electrical_neighbours_transformer_id;
SELECT setval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id', (MAX(trafo_id)+1)) FROM model_draft.ego_grid_pf_hv_transformer;


--- Create and fill table model_draft.ego_grid_hv_electrical_neighbours_bus

DROP TABLE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_bus;

CREATE TABLE model_draft.ego_grid_hv_electrical_neighbours_bus
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  bus_id bigint, -- Unit: n/a...
  central_bus boolean DEFAULT false, 
  v_nom double precision, -- Unit: kV...
  cntr_id text,
  current_type text DEFAULT 'AC'::text, -- Unit: n/a...
  v_mag_pu_min double precision DEFAULT 0, -- Unit: per unit...
  v_mag_pu_max double precision, -- Unit: per unit...
  geom geometry(Point,4326));

ALTER TABLE model_draft.ego_grid_hv_electrical_neighbours_bus
  OWNER TO oeuser;


INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_bus  (bus_id, cntr_id, v_nom, current_type)
(SELECT DISTINCT ON (voltage, country)
	nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
	country,
	voltage,
	(CASE WHEN dc = FALSE THEN 'AC' ELSE 'DC' END)
FROM model_draft.ego_grid_pp_entsoe_bus a
WHERE country NOT IN ('BE', 'NO', 'DE') AND under_construction = false AND dc = false AND symbol = 'Substation');

INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_bus (bus_id, v_nom, geom, cntr_id)
SELECT  nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
	base_kv,
	geom,
	cntr_id
FROM grid.otg_ehvhv_bus_data WHERE cntr_id NOT IN ('DE', 'BE', 'NO');


UPDATE model_draft.ego_grid_hv_electrical_neighbours_bus
	SET v_nom = (CASE v_nom WHEN 132 THEN 220
				WHEN 150 THEN 220
				WHEN 300 THEN 380
				WHEN 400 THEN 380
				ELSE v_nom END);


UPDATE model_draft.ego_grid_hv_electrical_neighbours_bus a
	SET 	geom = (CASE cntr_id 	WHEN 'AT' THEN '0101000020E61000008219DE771A512C40E266B10F27CB4740'
					WHEN 'BE' THEN '0101000020E61000003851291763E8114098865E2D305B4940'
					WHEN 'CH' THEN '0101000020E6100000CC34F5A862612040F35A1E0B14624740'
					WHEN 'CZ' THEN '0101000020E6100000DE42D8EF32F32E40445B2FB57DEF4840'
					WHEN 'DK' THEN '0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40'
					WHEN 'FR' THEN '0101000020E610000056B7521C607FFB3F0B27630507634740'
					WHEN 'NL' THEN '0101000020E61000003CFBF04927521540885EE6B0A2154A40'
					WHEN 'LU' THEN '0101000020E61000007B59331477881840DF8F4F135FE04840'
					WHEN 'NO' THEN '0101000020E6100000351DBC74686A24405536F7CC1CFC4E40'
					WHEN 'PL' THEN '0101000020E61000009459C1A8632233401DE697AA6FF04940'
					WHEN 'SE' THEN '0101000020E6100000781E63B01D002E40A292E70A7AB74E40' END ),
		central_bus = true;



DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE geom IS NULL OR v_nom = 750;

UPDATE model_draft.ego_grid_hv_electrical_neighbours_bus
	SET v_nom = (CASE v_nom WHEN 132 THEN 220
				WHEN 150 THEN 220
				WHEN 300 THEN 380
				WHEN 400 THEN 380
				ELSE v_nom END);
				
INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_bus (bus_id, v_nom, geom, cntr_id)
SELECT 	bus_i,
	base_kv,
	geom,
	cntr_id
FROM grid.otg_ehvhv_bus_data WHERE cntr_id NOT IN ('DE', 'BE', 'NO') OR (geom = '0101000020E610000060BB9D50CA422840B5CD3AA107124B40' AND base_kv = 380) ;

UPDATE model_draft.ego_grid_hv_electrical_neighbours_bus
	SET v_nom = (CASE v_nom WHEN 132 THEN 220
				WHEN 150 THEN 220
				WHEN 300 THEN 380
				WHEN 400 THEN 380
				ELSE v_nom END);
				
		
UPDATE model_draft.ego_grid_hv_electrical_neighbours_bus
SET 	bus_id = (SELECT DISTINCT ON (bus_i) bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E6100000A444C3ABCE9A254079A450D5E2F24A40' AND base_kv = 380),
	geom = '0101000020E6100000A444C3ABCE9A254079A450D5E2F24A40'		
WHERE cntr_id = 'SE' AND geom = '0101000020E61000004C93AD8960072A40DBBD816ED4B14B40';

--- Update voltage level of DC-buses to Denmark
/*UPDATE model_draft.ego_grid_hv_electrical_neighbours_bus
SET v_nom = 400
WHERE (cntr_id = 'DK' AND geom ='0101000020E6100000AFB9FEB858EC2740621AE148FB474B40') OR (geom = '0101000020E610000060BB9D50CA422840B5CD3AA107124B40') AND v_nom = 380;
*/

DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE (cntr_id = 'DK' AND geom ='0101000020E6100000AFB9FEB858EC2740621AE148FB474B40')
 OR (geom = '0101000020E610000060BB9D50CA422840B5CD3AA107124B40') AND v_nom = 380;
 
--- Insert buses for DC-lines
INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_bus (bus_id, v_nom, geom, cntr_id, central_bus)
VALUES	(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), 450, '0101000020E6100000A444C3ABCE9A254079A450D5E2F24A40', 'SE', FALSE), 
	(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), 450, '0101000020E6100000781E63B01D002E40A292E70A7AB74E40', 'SE', TRUE),
	(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), 400, '0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40', 'DK', TRUE), --- Center of DK
	(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), 400, '0101000020E610000032A490CBF66D2840DBDB2B66D70C4B40', 'DE', FALSE); --- Bentwisch HGÜ
	---(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), 400, '0101000020E610000060BB9D50CA422840B5CD3AA107124B40', 'DE', FALSE); --- between Bentwisch and DK

DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_bus a USING model_draft.ego_grid_hv_electrical_neighbours_bus b  WHERE a.cntr_id = b.cntr_id AND a.geom = b.geom AND a.v_nom = b.v_nom AND a.ctid > b.ctid OR a.cntr_id IS NULL OR a.v_nom IS NULL;

-- Create and fill table model_draft.ego_grid_hv_electrical_neighbours_line

DROP TABLE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_line ;


CREATE TABLE model_draft.ego_grid_hv_electrical_neighbours_line
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  line_id bigint NOT NULL, -- Unit: n/a...
  bus0 bigint, -- Unit: n/a...
  bus1 bigint, -- Unit: n/a...
  cntr_id_1 text,
  cntr_id_2 text,
  v_nom bigint,
  x numeric DEFAULT 0, -- Unit: Ohm...
  r numeric DEFAULT 0, -- Unit: Ohm...
  g numeric DEFAULT 0, -- Unit: Siemens...
  b numeric DEFAULT 0, -- Unit: Siemens...
  s_nom numeric DEFAULT 0, -- Unit: MVA...
  s_nom_extendable boolean DEFAULT false, -- Unit: n/a...
  s_nom_min double precision DEFAULT 0, -- Unit: MVA...
  s_nom_max double precision, -- Unit: MVA...
  capital_cost double precision, -- Unit: currency/MVA...
  length double precision, -- Unit: km...
  cables integer,
  frequency numeric,
  terrain_factor double precision DEFAULT 1, -- Unit: per unit...
  geom geometry(MultiLineString,4326),
  topo geometry(LineString,4326),
  CONSTRAINT neighbour_line_pkey PRIMARY KEY (line_id, scn_name)
);

ALTER TABLE model_draft.ego_grid_hv_electrical_neighbours_line
  OWNER TO oeuser;


INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_line (line_id, bus1, v_nom, cntr_id_2, cntr_id_1)
SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'),
	bus_id,
	v_nom,
	'DE',
	cntr_id
FROM model_draft.ego_grid_hv_electrical_neighbours_bus 
WHERE central_bus = FALSE AND current_type = 'AC' AND cntr_id != 'DE' ;

UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
SET bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus b WHERE a.cntr_id_1 = b.cntr_id AND a.v_nom = b.v_nom AND central_bus = TRUE);

	
--- Insert lines between electrical neigbours in respect to entso-e	
INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_line (line_id, cntr_id_1, cntr_id_2, v_nom, cables, s_nom)
SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), 
	country1 , 
	country2, 
	(CASE 	WHEN voltage = 110 THEN 110
		WHEN voltage IN (150, 132, 220) THEN 220
		WHEN voltage IN (300, 380) THEN 380
		END),
	3*circiuts,
	(CASE 	WHEN voltage = 110 THEN circiuts * 260
		WHEN voltage IN (150, 132, 220) THEN circiuts * 520
		WHEN voltage IN (300, 380) THEN circiuts * 1790
		END)
FROM model_draft.ego_grid_pp_entsoe_line 
WHERE country1 != country2 AND country1 IN (SELECT cntr_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus) AND country2 IN (SELECT cntr_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus) AND dc = false AND under_construction = false AND country1 != 'DE' AND country2 != 'DE';

	
--- Set cables and s_nom of lines in foregin countrys to values of border crossing lines
UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
SET	cables = (SELECT  sum(b.cables) FROM model_draft.ego_grid_pf_hv_line b  WHERE b.scn_name = 'Status Quo' AND b.bus0 = a.bus1 
	AND b.bus0 NOT IN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE central_bus = TRUE)),
	s_nom = (SELECT  sum(b.s_nom) FROM model_draft.ego_grid_pf_hv_line b WHERE b.scn_name = 'Status Quo' AND b.bus0 = a.bus1
	AND b.bus0 NOT IN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE central_bus = TRUE))
WHERE a.cntr_id_2 = 'DE';

UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
SET	cables = (SELECT  sum(b.cables) FROM model_draft.ego_grid_pf_hv_line b  WHERE b.scn_name = 'Status Quo' AND b.bus1 = a.bus1 
	AND (SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_bus WHERE bus_id = b.bus0) NOT IN (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE central_bus = TRUE)),
	s_nom = (SELECT  sum(b.s_nom) FROM model_draft.ego_grid_pf_hv_line b WHERE b.scn_name = 'Status Quo' AND b.bus1 = a.bus1
	AND (SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_bus WHERE bus_id = b.bus0) NOT IN (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE central_bus = TRUE))
WHERE a.cntr_id_2 = 'DE' AND cables is null ;



--- Set bus0 to central bus of country 1			
UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
SET bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus b WHERE a.cntr_id_1 = b.cntr_id AND a.v_nom = b.v_nom AND central_bus = TRUE);

--- Lines between electrical neighours: Set bus1 to central bus of country 2
UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
SET bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus b WHERE a.cntr_id_2 = b.cntr_id AND a.v_nom = b.v_nom AND central_bus = TRUE) 
WHERE a.cntr_id_2 != 'DE';

--- Set topo, frequency, length and geom
UPDATE model_draft.ego_grid_hv_electrical_neighbours_line
SET 	topo = (SELECT ST_MakeLine((SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus0), (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus1))),
	frequency = 50,
	length = (SELECT  ST_Length((SELECT ST_MakeLine((SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus0), (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus1))), true))/1000,
	geom = (SELECT (ST_Multi(ST_MakeLine((SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus0), (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus1)))));

--- Update s_nom and cables when grid topology leads to over- or underestimation
UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
SET	cables = 9,
	s_nom = 1590
WHERE geom = '0105000020E6100000010000000102000000020000008219DE771A512C40E266B10F27CB4740F0D23C36B8E32A4052572D9F9B374840' AND s_nom = 550;

UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
SET	cables = 6,
	s_nom = 520
WHERE geom = '0105000020E6100000010000000102000000020000008219DE771A512C40E266B10F27CB4740E5D308A293662840C0907AF42BD24740' AND s_nom = 800;

UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
SET	cables = 12,
	s_nom = 1040
WHERE geom = '0105000020E6100000010000000102000000020000008219DE771A512C40E266B10F27CB4740565DD1F764672840609099B0A2D14740' AND cables = 15;

--- Adjust capacity of underground cables between Sweden and Denmark 
UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
SET	s_nom = 925
WHERE cntr_id_1 = 'DK' AND cntr_id_2 = 'SE' AND v_nom = 380;

UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
SET	s_nom = 550
WHERE cntr_id_1 = 'DK' AND cntr_id_2 = 'SE' AND v_nom = 220;


--- Set electrical parameters to standard-values of transmission lines
UPDATE model_draft.ego_grid_hv_electrical_neighbours_line
SET 	x = 	(CASE 	WHEN v_nom = 110 THEN 0.31415 *1.2 / (cables/3) * length
			WHEN v_nom = 220 THEN 0.31415  /(cables/3) * length
			WHEN v_nom = 380 THEN 0.31415 * 0.8 /(cables/3) * length
			END),
		
	r = 	(CASE 	WHEN v_nom = 110 THEN 0.109 / (cables/3) * length
			WHEN v_nom = 220 THEN 0.109 /(cables/3) * length
			WHEN v_nom = 380 THEN 0.028 /(cables/3) * length
			END);

DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_line WHERE cables IS NULL;

			
DROP TABLE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_transformer CASCADE;

CREATE TABLE model_draft.ego_grid_hv_electrical_neighbours_transformer
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  trafo_id bigint NOT NULL, -- Unit: n/a...
  bus0 bigint, -- Unit: n/a...
  bus1 bigint, -- Unit: n/a...
  cntr_id text,
  x numeric DEFAULT 0, -- Unit: Ohm...
  r numeric DEFAULT 0, -- Unit: Ohm...
  g numeric DEFAULT 0, -- Unit: Siemens...
  b numeric DEFAULT 0, -- Unit: Siemens...
  s_nom double precision DEFAULT 0, -- Unit: MVA...
  s_nom_extendable boolean DEFAULT false, -- Unit: n/a...
  s_nom_min double precision DEFAULT 0, -- Unit: MVA...
  s_nom_max double precision, -- Unit: MVA...
  tap_ratio double precision, -- Unit: 1...
  phase_shift double precision, -- Unit: Degrees...
  capital_cost double precision DEFAULT 0, -- Unit: currency/MVA...
  geom geometry(MultiLineString,4326),
  geom_point geometry (Point, 4326),
  topo geometry(LineString,4326),
  v1 double precision DEFAULT 0, -- Unit: MVA...
  v2 double precision DEFAULT 0, -- Unit: MVA...
  s1 double precision DEFAULT 0, -- Unit: MVA...
  s2 double precision DEFAULT 0, -- Unit: MVA...
  s_min double precision DEFAULT 0, -- Unit: MVA...
  CONSTRAINT neighbour_transformer_pkey PRIMARY KEY (trafo_id, scn_name)
);
ALTER TABLE model_draft.ego_grid_hv_electrical_neighbours_transformer
  OWNER TO oeuser;

--- Insert transformers to connect central buses
INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_transformer (trafo_id, bus0, cntr_id, v1, geom_point)
(SELECT 	nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
		bus_id,
		cntr_id,
		v_nom,
		geom
FROM model_draft.ego_grid_hv_electrical_neighbours_bus a 
WHERE cntr_id != 'DE' AND central_bus = TRUE);

--- Set second bus and voltage level on higher voltage side 	
UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer a
SET 	bus1 = 	(CASE	WHEN v1 = 110 THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus b WHERE v_nom = 220 AND a.cntr_id = b.cntr_id AND a.geom_point = b.geom)
			WHEN v1 = 220 THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus b WHERE v_nom = 380 AND a.cntr_id = b.cntr_id AND a.geom_point = b.geom) END ),
				
	v2 = 	(CASE 	WHEN v1 = 110 THEN 220
				ELSE 380 END);

DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_transformer WHERE bus1 IS NULL;

DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_transformer WHERE bus1 IN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE central_bus = FALSE);

--- Calculate sum of lines at each voltage level
UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer a
SET	s1 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_hv_electrical_neighbours_line b WHERE (a.cntr_id = b.cntr_id_1 OR a.cntr_id = b.cntr_id_2) AND v1 = b.v_nom),
	s2 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_hv_electrical_neighbours_line b WHERE (a.cntr_id = b.cntr_id_1 OR a.cntr_id = b.cntr_id_2) AND v2 = b.v_nom);

--- Choose minimum sum of incomming lines as transformer size
UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer
SET 	s_min = (CASE 	WHEN s1 < s2 	THEN s1
			WHEN s2 <= s1 	THEN s2
			WHEN s2 IS NULL THEN s1
			WHEN s1 IS NULL THEN s2
			END);

--- Choose transformer of existsing network in respect to calculated size 			
UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer
SET 	s_nom = (CASE	WHEN s_min <= 600  THEN 600
			WHEN s_min > 600  AND s_min <= 1200 THEN 1200
			WHEN s_min > 1200 AND s_min <= 1600 THEN 1600
			WHEN s_min > 1600 AND s_min <= 2100 THEN 2100
			WHEN s_min > 2100 AND s_min <= 2600 THEN 2600
			WHEN s_min > 2600 AND s_min <= 4800 THEN 4800
			WHEN s_min > 4800 AND s_min <= 6000 THEN 6000
			WHEN s_min > 6000 AND s_min <= 7200 THEN 7200
			WHEN s_min > 7200 AND s_min <= 8000 THEN 8000
			WHEN s_min > 8000 AND s_min <= 9000 THEN 9000
			WHEN s_min > 9000 AND s_min <= 13000 THEN 13000
			WHEN s_min > 13000 AND s_min <= 20000 THEN 20000
			WHEN s_min > 20000 AND s_min <= 33000 THEN 33000
			END);

--- Set electrical parameters of existing transformers			
UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer
SET 	x = (CASE s_nom WHEN 1200 THEN 0.0001
			WHEN 4800 THEN 0.000025
			WHEN 2100 THEN 0.00006667
			WHEN 1600 THEN 0.000075000000000000000000
			WHEN 600 THEN 0.00020000000000000000
			WHEN 6000 THEN 0.000022500000000000000000
			WHEN 7200 THEN 0.000019444400000000000000
			WHEN 2600 THEN 0.000046153800000000000000
			WHEN 8000 THEN 0.000016875000000000000000
			WHEN 9000 THEN 0.000015000000000000000000
			WHEN 13000 THEN 0.000010384600000000000000
			WHEN 20000 THEN 0.000006750000000000000000
			WHEN 33000 THEN 0.000004090910000000000000
			END),
			
	tap_ratio = 1,

	phase_shift = 0,

	topo = (SELECT ST_MakeLine((SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus0), (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus1)));

--- Insert transformers to DC-line-buses 
INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_transformer (tap_ratio, phase_shift, trafo_id, bus0, bus1, topo, s_nom, x)
VALUES	(1, 0, nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE v_nom = 450 AND central_bus = TRUE),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE cntr_id = 'SE' AND v_nom = 380 AND central_bus = TRUE),
	'0102000020E6100000020000006D1E63B01D002E409E92E70A7AB74E406D1E63B01D002E409E92E70A7AB74E40',
	1200, 0.0001 ), 

	(1, 0, nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE v_nom = 450 AND geom = '0101000020E6100000A444C3ABCE9A254079A450D5E2F24A40' ), 
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE v_nom = 380 AND geom = '0101000020E6100000A444C3ABCE9A254079A450D5E2F24A40'),
	'0102000020E6100000020000004C93AD8960072A40DBBD816ED4B14B404C93AD8960072A40DBBD816ED4B14B40',
	1200, 0.0001 ),

	--- Bentwisch HGÜ
	(1, 0, nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE v_nom = 400 AND geom = '0101000020E610000032A490CBF66D2840DBDB2B66D70C4B40'), 
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 380 AND osm_name = 'Bentwisch HGÜ'),
	'0102000020E61000000200000032A490CBF66D2840DBDB2B66D70C4B4032A490CBF66D2840DBDB2B66D70C4B40',
	1200, 0.0001 ),

	(1, 0, nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE v_nom = 400 AND cntr_id = 'DK' AND central_bus = TRUE ), 
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE v_nom = 380 AND cntr_id = 'DK' AND central_bus  = TRUE),
	'0102000020E610000002000000A01CB9F93CB22240376BAAA0021E4C40A01CB9F93CB22240376BAAA0021E4C40',
	1200, 0.0001 );

UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer
SET geom  = (SELECT  ST_Multi(topo));
	
DROP TABLE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_link CASCADE;

CREATE TABLE model_draft.ego_grid_hv_electrical_neighbours_link
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  link_id bigint NOT NULL,
  bus0 bigint,
  bus1 bigint,
  cntr_id_1 character varying, 
  cntr_id_2 character varying,
  v_nom bigint,
  efficiency double precision DEFAULT 1,
  p_nom numeric DEFAULT 0,
  p_nom_extendable boolean DEFAULT false,
  p_nom_min double precision DEFAULT 0,
  p_min_pu double precision, 
  p_max_pu double precision,
  p_nom_max double precision,
  capital_cost double precision,
  length double precision,
  terrain_factor double precision DEFAULT 1,
  geom geometry(MultiLineString,4326),
  topo geometry(LineString,4326)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE model_draft.ego_grid_hv_electrical_neighbours_link
  OWNER TO oeuser;

--- Insert border-crossing and foregin DC-links 
INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_link (link_id, bus0, bus1, p_nom, length)
VALUES 	(nextval('model_draft.ego_grid_hv_electrical_neighbours_link_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE cntr_id = 'SE' AND central_bus = TRUE AND v_nom = 450), 
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE cntr_id = 'SE' AND central_bus = FALSE AND v_nom = 450),
	600,
	262),
	
	(nextval('model_draft.ego_grid_hv_electrical_neighbours_link_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE cntr_id = 'SE' AND central_bus = FALSE AND v_nom = 450),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE cntr_id = 'SE' AND central_bus = TRUE AND v_nom = 450),
	600,
	262);

INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_link (link_id, bus0, bus1, p_nom, length, geom)
VALUES	(nextval('model_draft.ego_grid_hv_electrical_neighbours_link_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE cntr_id = 'DK' AND central_bus = TRUE AND v_nom = 400),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE geom = '0101000020E610000032A490CBF66D2840DBDB2B66D70C4B40' AND v_nom = 400),
	600, --- source: Kontek - ABB
	170, --- source: Kontek - ABB
	(SELECT ST_Union((SELECT  ST_Multi(ST_MakeLine('0101000020E6100000AFB9FEB858EC2740621AE148FB474B40', '0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40'))),
	ST_Union('0105000020E610000001000000010200000002000000AFB9FEB858EC2740621AE148FB474B4060BB9D50CA422840B5CD3AA107124B40',
	(SELECT geom FROM grid.otg_ehvhv_branch_data WHERE topo = '0102000020E61000000200000032A490CBF66D2840DBDB2B66D70C4B4060BB9D50CA422840B5CD3AA107124B40' AND branch_voltage = 380000)))
	)),
	
	(nextval('model_draft.ego_grid_hv_electrical_neighbours_link_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE geom = '0101000020E610000032A490CBF66D2840DBDB2B66D70C4B40' AND v_nom = 400),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE cntr_id = 'DK' AND central_bus = TRUE AND v_nom = 400),
	600,--- source: Kontek - ABB
	170,--- source: Kontek - ABB
	(SELECT ST_Union((SELECT  ST_Multi(ST_MakeLine('0101000020E6100000AFB9FEB858EC2740621AE148FB474B40', '0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40'))),
	ST_Union('0105000020E610000001000000010200000002000000AFB9FEB858EC2740621AE148FB474B4060BB9D50CA422840B5CD3AA107124B40',
	(SELECT geom FROM grid.otg_ehvhv_branch_data WHERE topo = '0102000020E61000000200000032A490CBF66D2840DBDB2B66D70C4B4060BB9D50CA422840B5CD3AA107124B40' AND branch_voltage = 380000)))
	));
	
UPDATE model_draft.ego_grid_hv_electrical_neighbours_link
SET 	topo = (SELECT ST_MakeLine((SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus0), (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus1 AND scn_name = 'Status Quo'))),
	efficiency = 0.987*0.974^(length/1000);
	
UPDATE model_draft.ego_grid_hv_electrical_neighbours_link
SET 	geom  = (SELECT  ST_Multi(topo))
WHERE geom IS NULL;

		
DELETE FROM model_draft.ego_grid_pf_hv_link WHERE geom IN (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_link);

--- Delete lines from Bentwisch HGÜ to Denmark that have been replaced with link
DELETE FROM model_draft.ego_grid_pf_hv_line WHERE geom IN (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_link) OR
geom IN ('0105000020E610000001000000010200000002000000AFB9FEB858EC2740621AE148FB474B4060BB9D50CA422840B5CD3AA107124B40',
	(SELECT geom FROM grid.otg_ehvhv_branch_data WHERE topo = '0102000020E61000000200000032A490CBF66D2840DBDB2B66D70C4B4060BB9D50CA422840B5CD3AA107124B40' AND branch_voltage = 380000));

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE geom IN (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_line);

DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_line a USING model_draft.ego_grid_hv_electrical_neighbours_link b WHERE a.geom = b.geom;

DELETE FROM model_draft.ego_grid_pf_hv_bus a USING model_draft.ego_grid_hv_electrical_neighbours_bus b WHERE a.geom = b.geom AND b.central_bus = TRUE OR a.v_nom IN (400, 450) OR a.geom IN('0101000020E6100000AFB9FEB858EC2740621AE148FB474B40','0101000020E610000060BB9D50CA422840B5CD3AA107124B40');

INSERT INTO model_draft.ego_grid_pf_hv_bus (scn_name, bus_id, v_nom, geom, current_type)
SELECT  'Status Quo',bus_id, v_nom, geom, current_type FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE cntr_id != 'DE' AND central_bus = TRUE OR v_nom IN (400, 450) OR geom IN('0101000020E6100000AFB9FEB858EC2740621AE148FB474B40','0101000020E610000060BB9D50CA422840B5CD3AA107124B40');

DELETE FROM model_draft.ego_grid_pf_hv_transformer WHERE geom IN (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_transformer) OR bus0 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' );

INSERT INTO model_draft.ego_grid_pf_hv_line (scn_name, line_id, bus0, bus1, x, r, s_nom, topo, geom, length, frequency, cables)
SELECT  'Status Quo', line_id, bus0, bus1, x, r, s_nom, topo, geom, length, frequency, cables FROM model_draft.ego_grid_hv_electrical_neighbours_line;

INSERT INTO model_draft.ego_grid_pf_hv_link (scn_name, marginal_cost, link_id, bus0, bus1, efficiency, p_nom, topo, geom, length)
SELECT  'Status Quo', 0.01, link_id, bus0, bus1, efficiency, p_nom, topo, geom, length FROM model_draft.ego_grid_hv_electrical_neighbours_link;

INSERT INTO model_draft.ego_grid_pf_hv_transformer (scn_name, trafo_id, bus0, bus1, x, s_nom, geom, tap_ratio, phase_shift)
SELECT 'Status Quo', trafo_id, bus0, bus1, x, s_nom, geom, tap_ratio, phase_shift FROM model_draft.ego_grid_hv_electrical_neighbours_transformer;

	

