

DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_bus_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_electrical_neighbours_bus_id;
SELECT setval('model_draft.ego_grid_hv_electrical_neighbours_bus_id', (MAX(bus_id)+1)) FROM model_draft.ego_grid_pf_hv_bus;


DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_line_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_electrical_neighbours_line_id;
SELECT setval('model_draft.ego_grid_hv_electrical_neighbours_line_id', (MAX(line_id)+1)) FROM model_draft.ego_grid_pf_hv_line;


DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_transformer_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_electrical_neighbours_transformer_id;
SELECT setval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id', (MAX(trafo_id)+1)) FROM model_draft.ego_grid_pf_hv_transformer;


--- Create and fill table model_draft.ego_grid_hv_electrical_neighbours_bus

DROP TABLE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_bus;

CREATE TABLE model_draft.ego_grid_hv_electrical_neighbours_bus
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  bus_id bigint, -- Unit: n/a...
  v_nom double precision, -- Unit: kV...
  cntr_id text,
  current_type text DEFAULT 'AC'::text, -- Unit: n/a...
  v_mag_pu_min double precision DEFAULT 0, -- Unit: per unit...
  v_mag_pu_max double precision, -- Unit: per unit...
  geom geometry(Point,4326)--,
  --CONSTRAINT neighbour_bus_pkey PRIMARY KEY (bus_id, scn_name)
);


--- Alle Länder mit exisierenden Spannungsebenen eintragen und in den Landesmittelpunkt setzen

INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_bus  (bus_id, cntr_id, v_nom)
(SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), country, voltage FROM model_draft.entsoe_bus a WHERE country != 'DE' AND under_construction = false AND dc = false AND symbol = 'Substation');


INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_bus  (bus_id, cntr_id, v_nom)
(SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), cntr_id, base_kv FROM grid.otg_ehvhv_bus_data a WHERE cntr_id != 'DE');

UPDATE model_draft.ego_grid_hv_electrical_neighbours_bus
	SET v_nom = (CASE v_nom WHEN 132 THEN 220
				WHEN 150 THEN 220
				WHEN 300 THEN 380
				WHEN 400 THEN 380
				ELSE v_nom END);


UPDATE model_draft.ego_grid_hv_electrical_neighbours_bus a
	SET geom = (CASE cntr_id 	WHEN 'AT' THEN '0101000020E61000008219DE771A512C40E266B10F27CB4740'
					WHEN 'BE' THEN '0101000020E61000003851291763E8114098865E2D305B4940'
					WHEN 'CH' THEN '0101000020E6100000CC34F5A862612040F35A1E0B14624740'
					WHEN 'CZ' THEN '0101000020E6100000DE42D8EF32F32E40445B2FB57DEF4840'
					WHEN 'DK' THEN '0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40'
					WHEN 'FR' THEN '0101000020E610000056B7521C607FFB3F0B27630507634740'
					WHEN 'NL' THEN '0101000020E61000003CFBF04927521540885EE6B0A2154A40'
					WHEN 'LU' THEN '0101000020E61000007B59331477881840DF8F4F135FE04840'
					WHEN 'NO' THEN '0101000020E6100000351DBC74686A24405536F7CC1CFC4E40'
					WHEN 'PL' THEN '0101000020E61000009459C1A8632233401DE697AA6FF04940'
					WHEN 'SE' THEN '0101000020E6100000781E63B01D002E40A292E70A7AB74E40' END );


DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE geom IS NULL;

INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_bus (bus_id, v_nom, geom, cntr_id)
	SELECT bus_i, base_kv, geom, cntr_id FROM grid.otg_ehvhv_bus_data ;
		
DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE cntr_id = 'DE' OR cntr_id = 'BE' OR cntr_id = 'NO';

DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_bus a USING model_draft.ego_grid_hv_electrical_neighbours_bus b  WHERE a.cntr_id = b.cntr_id AND a.geom = b.geom AND a.v_nom = b.v_nom AND a.ctid > b.ctid OR a.cntr_id IS NULL OR a.v_nom IS NULL;

UPDATE model_draft.ego_grid_hv_electrical_neighbours_bus
SET bus_id = (CASE WHEN cntr_id = 'SE' AND geom = '0101000020E61000004C93AD8960072A40DBBD816ED4B14B40' THEN (SELECT MIN(bus_i) FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E6100000A444C3ABCE9A254079A450D5E2F24A40' AND base_kv = 380)
		ELSE bus_id END),
	geom = (CASE WHEN cntr_id = 'SE' AND geom = '0101000020E61000004C93AD8960072A40DBBD816ED4B14B40' THEN '0101000020E6100000A444C3ABCE9A254079A450D5E2F24A40'
		ELSE geom END) ;

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


--ALTER TABLE model_draft.ego_grid_hv_electrical_neighbours_line
  --OWNER TO oeuser;


INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_line (line_id, bus1, v_nom, cntr_id_2, cntr_id_1)
	SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), bus_id, v_nom, 'DE', cntr_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus 
	WHERE ST_AsText(geom) NOT IN ((SELECT ST_AsText('0101000020E61000008219DE771A512C40E266B10F27CB4740')), (SELECT ST_AsText('0101000020E61000003851291763E8114098865E2D305B4940')),(SELECT ST_AsText('0101000020E6100000CC34F5A862612040F35A1E0B14624740')), (SELECT ST_AsText('0101000020E6100000DE42D8EF32F32E40445B2FB57DEF4840')),
			(SELECT ST_AsText('0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40')), (SELECT ST_AsText('0101000020E610000056B7521C607FFB3F0B27630507634740')), (SELECT ST_AsText('0101000020E61000003CFBF04927521540885EE6B0A2154A40')), (SELECT ST_AsText('0101000020E61000007B59331477881840DF8F4F135FE04840')),
			(SELECT ST_AsText('0101000020E6100000351DBC74686A24405536F7CC1CFC4E40')), (SELECT ST_AsText('0101000020E61000009459C1A8632233401DE697AA6FF04940')), (SELECT ST_AsText('0101000020E6100000781E63B01D002E40A292E70A7AB74E40')));

UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
	SET cables = 6;

		
INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_line (line_id, cntr_id_1, cntr_id_2, v_nom, cables)
	SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), country_1 , country_2, voltage, 3*circuits FROM model_draft.entsoe_link WHERE country_1 != country_2 
	AND country_1 IN (SELECT cntr_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus) AND country_2 IN (SELECT cntr_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus) AND dc = false AND under_construction = false;


UPDATE model_draft.ego_grid_hv_electrical_neighbours_line
	SET v_nom = (CASE v_nom WHEN 132 THEN 220
				WHEN 150 THEN 220
				WHEN 300 THEN 380
				ELSE v_nom END);

			
UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
	SET bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus b WHERE a.cntr_id_1 = b.cntr_id AND a.v_nom = b.v_nom AND ST_AsText(b.geom) IN ((SELECT ST_AsText('0101000020E61000008219DE771A512C40E266B10F27CB4740')), (SELECT ST_AsText('0101000020E61000003851291763E8114098865E2D305B4940')),(SELECT ST_AsText('0101000020E6100000CC34F5A862612040F35A1E0B14624740')), (SELECT ST_AsText('0101000020E6100000DE42D8EF32F32E40445B2FB57DEF4840')),
			(SELECT ST_AsText('0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40')), (SELECT ST_AsText('0101000020E610000056B7521C607FFB3F0B27630507634740')), (SELECT ST_AsText('0101000020E61000003CFBF04927521540885EE6B0A2154A40')), (SELECT ST_AsText('0101000020E61000007B59331477881840DF8F4F135FE04840')),
			(SELECT ST_AsText('0101000020E6100000351DBC74686A24405536F7CC1CFC4E40')), (SELECT ST_AsText('0101000020E61000009459C1A8632233401DE697AA6FF04940')), (SELECT ST_AsText('0101000020E6100000781E63B01D002E40A292E70A7AB74E40'))));



UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
	SET bus1 = (CASE WHEN bus1 IS NULL THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus b 
		WHERE a.cntr_id_2 = b.cntr_id AND a.v_nom = b.v_nom AND ST_AsText(b.geom)IN ((SELECT ST_AsText('0101000020E61000008219DE771A512C40E266B10F27CB4740')), (SELECT ST_AsText('0101000020E61000003851291763E8114098865E2D305B4940')),(SELECT ST_AsText('0101000020E6100000CC34F5A862612040F35A1E0B14624740')), (SELECT ST_AsText('0101000020E6100000DE42D8EF32F32E40445B2FB57DEF4840')),
			(SELECT ST_AsText('0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40')), (SELECT ST_AsText('0101000020E610000056B7521C607FFB3F0B27630507634740')), (SELECT ST_AsText('0101000020E61000003CFBF04927521540885EE6B0A2154A40')), (SELECT ST_AsText('0101000020E61000007B59331477881840DF8F4F135FE04840')),
			(SELECT ST_AsText('0101000020E6100000351DBC74686A24405536F7CC1CFC4E40')), (SELECT ST_AsText('0101000020E61000009459C1A8632233401DE697AA6FF04940')), (SELECT ST_AsText('0101000020E6100000781E63B01D002E40A292E70A7AB74E40')))) ELSE bus1 END );

  
UPDATE model_draft.ego_grid_hv_electrical_neighbours_line
	SET 	topo = (SELECT ST_MakeLine((SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus0), (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus1))),
		frequency = 50;


UPDATE model_draft.ego_grid_hv_electrical_neighbours_line
	SET length = (SELECT  ST_Length(topo, true))/1000;


UPDATE model_draft.ego_grid_hv_electrical_neighbours_line
	SET geom  = (SELECT  ST_Multi(topo));

UPDATE model_draft.ego_grid_hv_electrical_neighbours_line a
	SET cables = (SELECT SUM(cables) FROM  model_draft.ego_grid_hv_electrical_neighbours_line b  WHERE a.geom = b.geom AND a.v_nom = b.v_nom) ;

UPDATE model_draft.ego_grid_hv_electrical_neighbours_line 
	SET cables = (CASE 	WHEN geom = ('0105000020E6100000010000000102000000020000008219DE771A512C40E266B10F27CB474032A946544D292A40422619390B214840') AND v_nom = 220 THEN 9
				WHEN geom = ('0105000020E610000001000000010200000002000000CC34F5A862612040F35A1E0B14624740BBFA67BC63172040806EC383C1C64740') AND v_nom = 380 THEN 9
				WHEN geom = ('0105000020E610000001000000010200000002000000CC34F5A862612040F35A1E0B146247406642DD51AD172040829D51A9C8C64740') AND v_nom = 380 THEN 9
				ELSE cables
			END);

	
DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_line a USING model_draft.ego_grid_hv_electrical_neighbours_line b
  WHERE a.geom = b.geom AND a.v_nom = b.v_nom AND a.ctid < b.ctid;



UPDATE model_draft.ego_grid_hv_electrical_neighbours_line
	SET 	x = 	(CASE 	WHEN v_nom = 110 THEN 0.31415 *1.2 / (cables/3) * length
			WHEN v_nom = 220 THEN 0.31415  /(cables/3) * length
			WHEN v_nom = 380 THEN 0.31415 * 0.8 /(cables/3) * length
			END),
		
		r = 	(CASE 	WHEN v_nom = 110 THEN 0.109 / (cables/3) * length
				WHEN v_nom = 220 THEN 0.109 /(cables/3) * length
			WHEN v_nom = 380 THEN 0.028 /(cables/3) * length
			END),

		s_nom = (CASE 	WHEN v_nom = 110 THEN 260 * (cables/3) 
			WHEN v_nom = 220 THEN 520 * (cables/3) 
			WHEN v_nom = 380 THEN 1790 *(cables/3) 
			END);

DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_line WHERE cables IS NULL;

DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE ((bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_hv_electrical_neighbours_line)) AND (bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_hv_electrical_neighbours_line)));

			
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

INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_transformer (trafo_id, bus0, cntr_id, v1, geom_point)
	(SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'), bus_id, cntr_id, v_nom, geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus a 
	WHERE cntr_id != 'DE' AND ST_AsText(a.geom) IN ((SELECT ST_AsText('0101000020E61000008219DE771A512C40E266B10F27CB4740')), (SELECT ST_AsText('0101000020E61000003851291763E8114098865E2D305B4940')),(SELECT ST_AsText('0101000020E6100000CC34F5A862612040F35A1E0B14624740')), (SELECT ST_AsText('0101000020E6100000DE42D8EF32F32E40445B2FB57DEF4840')),
			(SELECT ST_AsText('0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40')), (SELECT ST_AsText('0101000020E610000056B7521C607FFB3F0B27630507634740')), (SELECT ST_AsText('0101000020E61000003CFBF04927521540885EE6B0A2154A40')), (SELECT ST_AsText('0101000020E61000007B59331477881840DF8F4F135FE04840')),
			(SELECT ST_AsText('0101000020E6100000351DBC74686A24405536F7CC1CFC4E40')), (SELECT ST_AsText('0101000020E61000009459C1A8632233401DE697AA6FF04940')), (SELECT ST_AsText('0101000020E6100000781E63B01D002E40A292E70A7AB74E40'))));

	
UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer a
	SET 	bus1 = 	(CASE	WHEN v1 = 110 THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus b WHERE v_nom = 220 AND a.cntr_id = b.cntr_id AND a.geom_point = b.geom)
				WHEN v1 = 220 THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus b WHERE v_nom = 380 AND a.cntr_id = b.cntr_id AND a.geom_point = b.geom) END ),
				
		v2 = 	(CASE 	WHEN v1 = 110 THEN 220
				ELSE 380 END);

DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_transformer WHERE bus1 IS NULL;


DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_transformer WHERE ST_AsText(geom_point) NOT IN ((SELECT ST_AsText('0101000020E61000008219DE771A512C40E266B10F27CB4740')), (SELECT ST_AsText('0101000020E61000003851291763E8114098865E2D305B4940')),(SELECT ST_AsText('0101000020E6100000CC34F5A862612040F35A1E0B14624740')), (SELECT ST_AsText('0101000020E6100000DE42D8EF32F32E40445B2FB57DEF4840')),
			(SELECT ST_AsText('0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40')), (SELECT ST_AsText('0101000020E610000056B7521C607FFB3F0B27630507634740')), (SELECT ST_AsText('0101000020E61000003CFBF04927521540885EE6B0A2154A40')), (SELECT ST_AsText('0101000020E61000007B59331477881840DF8F4F135FE04840')),
			(SELECT ST_AsText('0101000020E6100000351DBC74686A24405536F7CC1CFC4E40')), (SELECT ST_AsText('0101000020E61000009459C1A8632233401DE697AA6FF04940')), (SELECT ST_AsText('0101000020E6100000781E63B01D002E40A292E70A7AB74E40')));



UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer a
	SET s1 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_hv_electrical_neighbours_line b WHERE (a.cntr_id = b.cntr_id_1 OR a.cntr_id = b.cntr_id_2) AND v1 = b.v_nom);


UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer a
	SET s2 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_hv_electrical_neighbours_line b WHERE (a.cntr_id = b.cntr_id_1 OR a.cntr_id = b.cntr_id_2) AND v2 = b.v_nom);


UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer
	SET 	s_min = (CASE 	WHEN s1 < s2 	THEN s1
				WHEN s2 <= s1 	THEN s2
				WHEN s2 IS NULL THEN s1
				END);

			
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
				END);

			
UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer
	SET 	x = (CASE s_nom WHEN 1200 THEN 4.84
				WHEN 4800 THEN 1.21
				WHEN 2100 THEN 9.62667148
				WHEN 1600 THEN 3.63
				WHEN 600 THEN 9.68
				WHEN 6000 THEN 3.249
				WHEN 7200 THEN 2.80777136
				WHEN 2600 THEN 2.23384392
				WHEN 8000 THEN 2.43675
				WHEN 9000 THEN 2.166
				END),
			
		tap_ratio = 1,

		phase_shift = 0,

		topo = (SELECT ST_MakeLine((SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus0), (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus1)));

	
UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer
	SET geom  = (SELECT  ST_Multi(topo));

INSERT INTO model_draft.ego_grid_pf_hv_line (scn_name, line_id, bus0, bus1, x, r, s_nom, topo, geom, length, frequency, cables)
SELECT  'Status Quo', line_id, bus0, bus1, x, r, s_nom, topo, geom, length, frequency, cables FROM model_draft.ego_grid_hv_electrical_neighbours_line;

INSERT INTO model_draft.ego_grid_pf_hv_bus (scn_name, bus_id, v_nom, geom)
SELECT  'Status Quo',bus_id, v_nom, geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE cntr_id_2 != 'DE' AND ST_AsText(geom) IN ((SELECT ST_AsText('0101000020E61000008219DE771A512C40E266B10F27CB4740')), (SELECT ST_AsText('0101000020E61000003851291763E8114098865E2D305B4940')),(SELECT ST_AsText('0101000020E6100000CC34F5A862612040F35A1E0B14624740')), (SELECT ST_AsText('0101000020E6100000DE42D8EF32F32E40445B2FB57DEF4840')),
			(SELECT ST_AsText('0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40')), (SELECT ST_AsText('0101000020E610000056B7521C607FFB3F0B27630507634740')), (SELECT ST_AsText('0101000020E61000003CFBF04927521540885EE6B0A2154A40')), (SELECT ST_AsText('0101000020E61000007B59331477881840DF8F4F135FE04840')),
			(SELECT ST_AsText('0101000020E6100000351DBC74686A24405536F7CC1CFC4E40')), (SELECT ST_AsText('0101000020E61000009459C1A8632233401DE697AA6FF04940')), (SELECT ST_AsText('0101000020E6100000781E63B01D002E40A292E70A7AB74E40')));


INSERT INTO model_draft.ego_pf_hv_transformer (scn_name, trafo_id, bus0, bus1, x, s_nom, geom, tap_ratio, phase_shift)
SELECT 'Status Quo', trafo_id, bus0, bus1, x, s_nom, geom, tap_ratio, phase_shift FROM model_draft.ego_grid_hv_electrical_neighbours_transformer


