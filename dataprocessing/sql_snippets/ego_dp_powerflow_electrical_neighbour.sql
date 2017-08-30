/*
Creates border crossing lines and buses for electrical neighbours

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

DROP SEQUENCE IF EXISTS	 model_draft.ego_grid_hv_electrical_neighbours_bus_id CASCADE;
CREATE SEQUENCE		 model_draft.ego_grid_hv_electrical_neighbours_bus_id;
ALTER SEQUENCE		 model_draft.ego_grid_hv_electrical_neighbours_bus_id; 
SELECT setval('model_draft.ego_grid_hv_electrical_neighbours_bus_id', (max(bus_id)+1)) FROM model_draft.ego_grid_pf_hv_bus;

DROP SEQUENCE IF EXISTS  model_draft.ego_grid_hv_electrical_neighbours_line_id CASCADE;
CREATE SEQUENCE		 model_draft.ego_grid_hv_electrical_neighbours_line_id;
ALTER SEQUENCE		 model_draft.ego_grid_hv_electrical_neighbours_line_id; 
SELECT setval('model_draft.ego_grid_hv_electrical_neighbours_line_id', (max(line_id)+1)) FROM model_draft.ego_grid_pf_hv_line;

DROP SEQUENCE IF EXISTS  model_draft.ego_grid_hv_electrical_neighbours_transformer_id CASCADE;
CREATE SEQUENCE 	 model_draft.ego_grid_hv_electrical_neighbours_transformer_id;
ALTER SEQUENCE		 model_draft.ego_grid_hv_electrical_neighbours_transformer_id; 
SELECT setval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id', (max(trafo_id)+1)) FROM model_draft.ego_grid_pf_hv_transformer;


--- Create and fill table model_draft.ego_grid_hv_electrical_neighbours_bus

DROP TABLE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_bus CASCADE;

CREATE TABLE model_draft.ego_grid_hv_electrical_neighbours_bus
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  bus_id bigint NOT NULL, -- Unit: n/a...
  v_nom double precision, -- Unit: kV...
  id bigint NOT NULL,
  cntr_id text,
  current_type text DEFAULT 'AC'::text, -- Unit: n/a...
  v_mag_pu_min double precision DEFAULT 0, -- Unit: per unit...
  v_mag_pu_max double precision, -- Unit: per unit...
  geom geometry(Point,4326),
  CONSTRAINT neighbour_bus_pkey PRIMARY KEY (bus_id, scn_name)
);


ALTER TABLE model_draft.ego_grid_hv_electrical_neighbours_bus
  OWNER TO oeuser;

INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_bus (bus_id, v_nom, geom, cntr_id, id) 
	
	VALUES (nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		110,
		'0101000020E61000008219DE771A512C40E266B10F27CB4740',
		'AT',
		1),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		220,
		'0101000020E61000008219DE771A512C40E266B10F27CB4740',
		'AT',
		2),
		
		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		380,
		'0101000020E61000008219DE771A512C40E266B10F27CB4740',
		'AT',
		3),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		110,
		'0101000020E6100000CC34F5A862612040F35A1E0B14624740',
		'CH',
		4),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		220,
		'0101000020E6100000CC34F5A862612040F35A1E0B14624740',
		'CH',
		5),
		
		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		380,
		'0101000020E6100000CC34F5A862612040F35A1E0B14624740',
		'CH',
		6),
		
		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		110,
		'0101000020E6100000DE42D8EF32F32E40445B2FB57DEF4840',
		'CZ',
		7),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		220,
		'0101000020E6100000DE42D8EF32F32E40445B2FB57DEF4840',
		'CZ',
		8),
		

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		380,
		'0101000020E6100000DE42D8EF32F32E40445B2FB57DEF4840',
		'CZ',
		9),
		
		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		110,
		'0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40',
		'DK',
		10),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		220,
		'0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40',
		'DK',
		11),
		

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		380,
		'0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40',
		'DK',
		12),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		110,
		'0101000020E610000056B7521C607FFB3F0B27630507634740',
		'FR',
		13),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		220,
		'0101000020E610000056B7521C607FFB3F0B27630507634740',
		'FR',
		14),
		

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		380,
		'0101000020E610000056B7521C607FFB3F0B27630507634740',
		'FR',
		15),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		110,
		'0101000020E61000007B59331477881840DF8F4F135FE04840',
		'LU',
		16),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		220,
		'0101000020E61000007B59331477881840DF8F4F135FE04840',
		'LU',
		17),
		

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		380,
		'0101000020E61000007B59331477881840DF8F4F135FE04840',
		'LU',
		18),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		110,
		'0101000020E61000003CFBF04927521540885EE6B0A2154A40',
		'NL',
		19),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		220,
		'0101000020E61000003CFBF04927521540885EE6B0A2154A40',
		'NL',
		20),
		

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		380,
		'0101000020E61000003CFBF04927521540885EE6B0A2154A40',
		'NL',
		21),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		110,
		'0101000020E61000009459C1A8632233401DE697AA6FF04940',
		'PL',
		22),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		220,
		'0101000020E61000009459C1A8632233401DE697AA6FF04940',
		'PL',
		23),
		

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		380,
		'0101000020E61000009459C1A8632233401DE697AA6FF04940',
		'PL',
		24),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		110,
		'0101000020E6100000781E63B01D002E40A292E70A7AB74E40',
		'SE',
		25),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		220,
		'0101000020E6100000781E63B01D002E40A292E70A7AB74E40',
		'SE',
		26),
		

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		380,
		'0101000020E6100000781E63B01D002E40A292E70A7AB74E40',
		'SE',
		27);


INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_bus (bus_id, v_nom, geom, cntr_id, id)
	
SELECT bus_i, base_kv, geom, cntr_id, bus_i
FROM grid.otg_ehvhv_bus_data WHERE frequency = 50;


DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE cntr_id = 'DE';
DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE cntr_id IS NULL;


INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_bus (bus_id, v_nom, geom, cntr_id, id)
SELECT bus_i, base_kv, geom, 'SE', bus_i 
FROM grid.otg_ehvhv_bus_data WHERE (geom = '0101000020E6100000A444C3ABCE9A254079A450D5E2F24A40' AND base_kv = 380);



-- Create and fill table model_draft.ego_grid_hv_electrical_neighbours_line

DROP TABLE IF EXISTS model_draft.ego_grid_hv_electrical_neighbours_line ;

CREATE TABLE model_draft.ego_grid_hv_electrical_neighbours_line
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  line_id bigint NOT NULL, -- Unit: n/a...
  bus0 bigint, -- Unit: n/a...
  bus1 bigint, -- Unit: n/a...
  cntr_id text,
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


INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_line (line_id, bus1, v_nom, cntr_id)

SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), bus_id, v_nom, cntr_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus where id > 27;



UPDATE model_draft.ego_grid_hv_electrical_neighbours_line
SET bus0 =    
( CASE    
	WHEN (cntr_id = 'AT' AND v_nom = 110) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=1)
	WHEN (cntr_id = 'AT' AND v_nom = 220 OR cntr_id = 'AT' AND v_nom = 150) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=2)
	WHEN (cntr_id = 'AT' AND v_nom = 380 OR cntr_id = 'AT' AND v_nom = 400) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=3)

	WHEN (cntr_id = 'CH' AND v_nom = 110) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=4)
	WHEN (cntr_id = 'CH' AND v_nom = 220 OR cntr_id = 'CH' AND v_nom = 150) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=5)
	WHEN (cntr_id = 'CH' AND v_nom = 380 OR cntr_id = 'CH' AND v_nom = 400) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=6)

	WHEN (cntr_id = 'CZ' AND v_nom = 110) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=7)
	WHEN (cntr_id = 'CZ' AND v_nom = 220 OR cntr_id = 'CZ' AND v_nom = 150) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=8)
	WHEN (cntr_id = 'CZ' AND v_nom = 380 OR cntr_id = 'CZ' AND v_nom = 400) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=9)

	WHEN (cntr_id = 'DK' AND v_nom = 110) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=10)
	WHEN (cntr_id = 'DK' AND v_nom = 220 OR cntr_id = 'DK' AND v_nom = 150) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=11)
	WHEN (cntr_id = 'DK' AND v_nom = 380 OR cntr_id = 'DK' AND v_nom = 400) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=12)

	WHEN (cntr_id = 'FR' AND v_nom = 110) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=13)
	WHEN (cntr_id = 'FR' AND v_nom = 220) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=14)
	WHEN (cntr_id = 'FR' AND v_nom = 380 OR cntr_id = 'FR' AND v_nom = 400) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=15)

	WHEN (cntr_id = 'LU' AND v_nom = 110) 					THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=16)
	WHEN (cntr_id = 'LU' AND v_nom = 220) 					THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=17)
	WHEN (cntr_id = 'LU' AND v_nom = 380) 					THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=18)

	WHEN (cntr_id = 'NL' AND v_nom = 110) 					THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=19)
	WHEN (cntr_id = 'NL' AND v_nom = 220) 					THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=20)
	WHEN (cntr_id = 'NL' AND v_nom = 380)					THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=21)

	WHEN (cntr_id = 'PL' AND v_nom = 110) 					THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=22)
	WHEN (cntr_id = 'PL' AND v_nom = 220) 					THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=23)
	WHEN (cntr_id = 'PL' AND v_nom = 380) 					THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=24)
	
	WHEN (cntr_id = 'SE' AND v_nom = 110) 					THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=25)
	WHEN (cntr_id = 'SE' AND v_nom = 220) 					THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=26)
	WHEN (cntr_id = 'SE' AND v_nom = 380 OR cntr_id = 'SE' AND v_nom = 450) THEN (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=27)
	ELSE 0
END );



UPDATE model_draft.ego_grid_hv_electrical_neighbours_line
SET topo = (SELECT ST_MakeLine((SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus0), (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus1)));

UPDATE model_draft.ego_grid_hv_electrical_neighbours_line
SET length = (SELECT  ST_Length(topo));


UPDATE model_draft.ego_grid_hv_electrical_neighbours_line
SET geom  = (SELECT  ST_Multi(topo));


UPDATE model_draft.ego_grid_hv_electrical_neighbours_line 

SET s_nom = (CASE	WHEN geom = ('0105000020E6100000010000000102000000020000008219DE771A512C40E266B10F27CB474032A946544D292A40422619390B214840') AND v_nom = 220 THEN 1560
			WHEN geom = ('0105000020E610000001000000010200000002000000CC34F5A862612040F35A1E0B14624740BBFA67BC63172040806EC383C1C64740') AND v_nom = 380 THEN 5370
			WHEN geom = ('0105000020E610000001000000010200000002000000CC34F5A862612040F35A1E0B146247406642DD51AD172040829D51A9C8C64740') AND v_nom = 380 THEN 5370

			WHEN v_nom = 110 THEN 520  -- 2 Systeme 
			WHEN v_nom = 220 THEN 1040 -- 2 Systeme
			WHEN v_nom = 380 THEN 3580 -- 2 Systeme 
			END);

UPDATE model_draft.ego_grid_hv_electrical_neighbours_line

SET x = (CASE 	
	WHEN topo = ('0102000020E610000002000000C8DE41A2BFBE2540BA432F489F9F47408F19DE771A512C40E166B10F27CB4740') AND v_nom = 220 	THEN 5810.613491830431488
	WHEN topo = ('0102000020E610000002000000C8DE41A2BFBE2540BA432F489F9F47408F19DE771A512C40E166B10F27CB4740') AND v_nom = 380 	THEN 63.0337730012699329293891200
	WHEN topo = ('0102000020E610000002000000104130A248A6214028CB5A54D5D74740CE34F5A862612040F95A1E0B14624740') AND v_nom = 110	THEN 135.6050633079444
	WHEN topo = ('0102000020E610000002000000F1E9FBBA1D6F214076583C5002DF4740CE34F5A862612040F95A1E0B14624740') AND v_nom = 110	THEN 138.725512099140
	WHEN topo = ('0102000020E610000002000000B0AD9FFEB37E2040C7212C746FCE4740CE34F5A862612040F95A1E0B14624740') AND v_nom = 380	THEN 30.9020738413218200
	WHEN topo = ('0102000020E610000002000000C147B368F04D1F4091F8CBDD9DC84740CE34F5A862612040F95A1E0B14624740') AND v_nom = 110	THEN 111.88722256053768
	WHEN topo = ('0102000020E610000002000000DF22E6481D831F40ABE39DE85FC64740CE34F5A862612040F95A1E0B14624740') AND v_nom = 110	THEN 108.32499216676452
	WHEN topo = ('0102000020E610000002000000BDA94885B1912940C39CA04D0ED74840CD42D8EF32F32E40405B2FB57DEF4840') AND v_nom = 380	THEN 52.3326561015831390
	WHEN topo = ('0102000020E610000002000000A0200C97B0CB22404CD82379D36B4B409F1CB9F93CB22240346BAAA0021E4C40') AND v_nom = 110 	THEN 186.0179690169384
	WHEN topo = ('0102000020E6100000020000007C15CF8F75CB224085F12E72AA6B4B409F1CB9F93CB22240346BAAA0021E4C40') AND v_nom = 110	THEN 186.1845039338184
	WHEN topo = ('0102000020E61000000200000080B33973B4BB2240C9A0246E5F6A4B409F1CB9F93CB22240346BAAA0021E4C40') AND v_nom = 110	THEN 187.5017868466176
	WHEN topo = ('0102000020E610000002000000349765998F251940F963FFE1539948404EB7521C607FFB3F0A27630507634740') AND v_nom = 380	THEN 70.7659475988600600
	WHEN topo = ('0102000020E6100000020000001609B7C6B1CF1B40E4F2C418FD8F4A403DFBF049275215408E5EE6B0A2154A40') AND v_nom = 380	THEN 56.9952217390133984
	WHEN topo = ('0102000020E61000000200000044C02154A9D91B40F651FCCEE5184A403DFBF049275215408E5EE6B0A2154A40') AND v_nom = 380	THEN 11.624
	WHEN topo = ('0102000020E610000002000000C2D4E0C7E2281840CAF89C60A48C49403DFBF049275215408E5EE6B0A2154A40') AND v_nom = 380	THEN 32.8987170760166344
	WHEN topo = ('0102000020E610000002000000CDAFE600C1F42C4053680F6A75984A409559C1A86322334019E697AA6FF04940') AND v_nom = 220	THEN 109.328685296483677891692800
	WHEN topo = ('0102000020E6100000020000000C79043752EE2D405FCDA6C8C68649409559C1A86322334019E697AA6FF04940') AND v_nom = 380	THEN 76.3690567655928191131608000
	WHEN topo = ('0102000020E610000002000000643B84961ACE224013DED4F6656D4B409F1CB9F93CB22240346BAAA0021E4C40') AND v_nom = 220	THEN 55.982260315162501294462765475
	WHEN topo = ('0102000020E6100000020000000CE5E901986B2A40E6DA06A4B3434940CD42D8EF32F32E40405B2FB57DEF4840') AND v_nom = 380	THEN 47.66677822

	WHEN s_nom = 520  THEN (0.3769911184/2 * length)   -- 2 Systeme
	WHEN s_nom = 1040 THEN (0.000314159265/2 * length) -- 2 Systeme
	WHEN s_nom = 3580 THEN (0.2513274123/2  * length)  -- 2 Systeme
	WHEN s_nom = 1560 THEN (0.000314159265/3 * length) -- 3 Systeme
	WHEN s_nom = 5370 THEN (0.2513274123/3 * length)   -- 3 Systeme
	END);

UPDATE model_draft.ego_grid_hv_electrical_neighbours_line

SET r = (CASE 	
	WHEN topo = ('0102000020E610000002000000C8DE41A2BFBE2540BA432F489F9F47408F19DE771A512C40E166B10F27CB4740') AND v_nom = 220 	THEN 473.18244077693802267804613122
	WHEN topo = ('0102000020E610000002000000C8DE41A2BFBE2540BA432F489F9F47408F19DE771A512C40E166B10F27CB4740') AND v_nom = 380 	THEN 7.022495587502248
	WHEN topo = ('0102000020E610000002000000104130A248A6214028CB5A54D5D74740CE34F5A862612040F95A1E0B14624740') AND v_nom = 110	THEN 12.317459917138283
	WHEN topo = ('0102000020E610000002000000F1E9FBBA1D6F214076583C5002DF4740CE34F5A862612040F95A1E0B14624740') AND v_nom = 110	THEN 12.60090068233855
	WHEN topo = ('0102000020E610000002000000B0AD9FFEB37E2040C7212C746FCE4740CE34F5A862612040F95A1E0B14624740') AND v_nom = 380	THEN 2.8640946487078760
	WHEN topo = ('0102000020E610000002000000C147B368F04D1F4091F8CBDD9DC84740CE34F5A862612040F95A1E0B14624740') AND v_nom = 110	THEN 10.1630893825821726
	WHEN topo = ('0102000020E610000002000000DF22E6481D831F40ABE39DE85FC64740CE34F5A862612040F95A1E0B14624740') AND v_nom = 110	THEN 9.8395201218144439
	WHEN topo = ('0102000020E610000002000000BDA94885B1912940C39CA04D0ED74840CD42D8EF32F32E40405B2FB57DEF4840') AND v_nom = 380	THEN 5.8811481959750809
	WHEN topo = ('0102000020E610000002000000A0200C97B0CB22404CD82379D36B4B409F1CB9F93CB22240346BAAA0021E4C40') AND v_nom = 110	THEN 16.896632185705238
	WHEN topo = ('0102000020E6100000020000007C15CF8F75CB224085F12E72AA6B4B409F1CB9F93CB22240346BAAA0021E4C40') AND v_nom = 110	THEN 16.911759107321838
	WHEN topo = ('0102000020E61000000200000080B33973B4BB2240C9A0246E5F6A4B409F1CB9F93CB22240346BAAA0021E4C40') AND v_nom = 110	THEN 17.031412305234432
	WHEN topo = ('0102000020E610000002000000349765998F251940F963FFE1539948404EB7521C607FFB3F0A27630507634740') AND v_nom = 380	THEN 5.0350040689247411
	WHEN topo = ('0102000020E6100000020000001609B7C6B1CF1B40E4F2C418FD8F4A403DFBF049275215408E5EE6B0A2154A40') AND v_nom = 380	THEN 4.6400348170039073
	WHEN topo = ('0102000020E61000000200000044C02154A9D91B40F651FCCEE5184A403DFBF049275215408E5EE6B0A2154A40') AND v_nom = 380	THEN 1.214
	WHEN topo = ('0102000020E610000002000000C2D4E0C7E2281840CAF89C60A48C49403DFBF049275215408E5EE6B0A2154A40') AND v_nom = 380	THEN 3.4867140095083182
	WHEN topo = ('0102000020E610000002000000CDAFE600C1F42C4053680F6A75984A409559C1A86322334019E697AA6FF04940') AND v_nom = 220	THEN 37.932437491995488
	WHEN topo = ('0102000020E6100000020000000C79043752EE2D405FCDA6C8C68649409559C1A86322334019E697AA6FF04940') AND v_nom = 380	THEN 8.508159017345820
	WHEN topo = ('0102000020E610000002000000643B84961ACE224013DED4F6656D4B409F1CB9F93CB22240346BAAA0021E4C40') AND v_nom = 220	THEN 8.736451301750197968536128100
	WHEN topo = ('0102000020E6100000020000000CE5E901986B2A40E6DA06A4B3434940CD42D8EF32F32E40405B2FB57DEF4840') AND v_nom = 380	THEN 3.644465672WHEN s_nom = 520 THEN (0.109/2 * length)  -- 2 Systeme

	WHEN s_nom = 1040 THEN (0.109/2 * length) -- 2 Systeme
	WHEN s_nom = 3580 THEN (0.028/2 * length) -- 2 Systeme
	WHEN s_nom = 1560 THEN (0.109/3 * length) -- 3 Systeme
	WHEN s_nom = 5370 THEN (0.028/3 * length) -- 3 Systeme 
	END);


UPDATE model_draft.ego_grid_hv_electrical_neighbours_line 
SET frequency = 50;


UPDATE model_draft.ego_grid_hv_electrical_neighbours_line 
SET cables = 3;


-- Create and fill table: model_draft.ego_grid_hv_electrical_neighbours_transformer

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
  topo geometry(LineString,4326),
  s1 double precision DEFAULT 0, -- Unit: MVA...
  s2 double precision DEFAULT 0, -- Unit: MVA...
  s_min double precision DEFAULT 0, -- Unit: MVA...
  CONSTRAINT neighbour_transformer_pkey PRIMARY KEY (trafo_id, scn_name)
);


ALTER TABLE model_draft.ego_grid_hv_electrical_neighbours_transformer
  OWNER TO oeuser;


INSERT INTO model_draft.ego_grid_hv_electrical_neighbours_transformer (trafo_id, bus0, bus1, cntr_id)

VALUES (nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 1),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 2),
	'AT'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 2),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 3),
	'AT'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 4),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 5),
	'CH'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 5),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 6),
	'CH'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 7),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 8),
	'CZ'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 8),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 9),
	'CZ'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 10),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 11),
	'DK'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 11),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 12),
	'DK'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 13),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 14),
	'FR'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 14),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 15),
	'FR'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 16),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 17),
	'LU'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 17),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 18),
	'LU'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 19),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 20),
	'NL'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 20),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 21),
	'NL'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 22),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 23),
	'PL'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 23),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 24),
	'PL'),

	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 25),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 26),
	'SE'),


	(nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 26),
	(SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id = 27),
	'SE');


UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer
SET topo = (SELECT ST_MakeLine((SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus0), (SELECT geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE bus_id = bus1)));


UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer
SET geom  = (SELECT  ST_Multi(topo));

UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer

 SET s1 = (CASE 	WHEN cntr_id = 'AT' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=1) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'AT' AND v_nom = 110))
			WHEN cntr_id = 'AT' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=2) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'AT' AND v_nom = 220))
			WHEN cntr_id = 'CH' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=4) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'CH' AND v_nom = 110))
			WHEN cntr_id = 'CH' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=5) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'CH' AND v_nom = 220))
			WHEN cntr_id = 'CZ' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=7) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'CZ' AND v_nom = 110))
			WHEN cntr_id = 'CZ' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=8) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'CZ' AND v_nom = 220))
			WHEN cntr_id = 'DK' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=10) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'DK' AND v_nom = 110))
			WHEN cntr_id = 'DK' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=11) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'DK' AND v_nom = 220))
			WHEN cntr_id = 'FR' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=13) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'FR' AND v_nom = 110))
			WHEN cntr_id = 'FR' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=14) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'FR' AND v_nom = 220))
			WHEN cntr_id = 'LU' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=16) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'LU' AND v_nom = 110))
			WHEN cntr_id = 'LU' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=17) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'LU' AND v_nom = 220))
			WHEN cntr_id = 'NL' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=19) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'NL' AND v_nom = 110))
			WHEN cntr_id = 'NL' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=20) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'NL' AND v_nom = 220))
			WHEN cntr_id = 'PL' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=22) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'PL' AND v_nom = 110))
			WHEN cntr_id = 'PL' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=23) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'PL' AND v_nom = 220))
			WHEN cntr_id = 'SE' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=25) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'SE' AND v_nom = 110))
			WHEN cntr_id = 'SE' AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=26) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'SE' AND v_nom = 220))
			END);


UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer

 SET s2 = (CASE 	WHEN cntr_id = 'AT' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=2) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'AT' AND v_nom = 220))
			WHEN cntr_id = 'AT' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=3) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'AT' AND v_nom = 380))
			WHEN cntr_id = 'CH' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=5) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'CH' AND v_nom = 220))
			WHEN cntr_id = 'CH' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=6) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'CH' AND v_nom = 380))
			WHEN cntr_id = 'CZ' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=8) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'CZ' AND v_nom = 220))
			WHEN cntr_id = 'CZ' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=9) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'CZ' AND v_nom = 380))
			WHEN cntr_id = 'DK' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=11) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'DK' AND v_nom = 220))
			WHEN cntr_id = 'DK' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=12) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'DK' AND v_nom = 380))
			WHEN cntr_id = 'FR' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=14) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'FR' AND v_nom = 220))
			WHEN cntr_id = 'FR' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=15) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'FR' AND v_nom = 380))
			WHEN cntr_id = 'LU' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=17) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'LU' AND v_nom = 220))
			WHEN cntr_id = 'LU' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=18) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'LU' AND v_nom = 380))
			WHEN cntr_id = 'NL' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=20) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'NL' AND v_nom = 220))
			WHEN cntr_id = 'NL' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=21) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'NL' AND v_nom = 380))
			WHEN cntr_id = 'PL' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=23) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'PL' AND v_nom = 220))
			WHEN cntr_id = 'PL' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=24) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'PL' AND v_nom = 380))
			WHEN cntr_id = 'SE' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=26) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'SE' AND v_nom = 220))
			WHEN cntr_id = 'SE' AND bus1 = (SELECT bus_id FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id=27) THEN (SELECT SUM (s_nom) FROM  model_draft.ego_grid_hv_electrical_neighbours_line WHERE (cntr_id = 'SE' AND v_nom = 380))
			END);


UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer


SET s_min = (CASE 	WHEN s1 < s2 THEN s1
			WHEN s2 <= s1 THEN s2
			WHEN s2 IS NULL THEN s1
			END);


UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer


SET s_nom = (CASE	WHEN s_min <= 600  THEN 600
			WHEN s_min > 600  AND s_min <= 1200 THEN 1200
			WHEN s_min > 1200 AND s_min <= 1600 THEN 1600
			WHEN s_min > 1600 AND s_min <= 2100 THEN 2100
			WHEN s_min > 2100 AND s_min <= 2600 THEN 2600
			WHEN s_min > 2600 AND s_min <= 4800 THEN 4800
			WHEN s_min > 4800 AND s_min <= 6000 THEN 6000
			WHEN s_min > 6000 AND s_min <= 7200 THEN 7200
			END);
			
UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer
SET x = (CASE s_nom 	WHEN 1200 THEN 4.84
			WHEN 4800 THEN 1.21
			WHEN 2100 THEN 9.62667148
			WHEN 1600 THEN 3.63
			WHEN 600 THEN 9.68
			WHEN 6000 THEN 3.249
			WHEN 7200 THEN 2.80777136
			WHEN 2600 THEN 2.23384392
			END);
			
UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer 
SET tap_ratio = 1;

UPDATE model_draft.ego_grid_hv_electrical_neighbours_transformer
SET phase_shift = 0;

DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_transformer WHERE x IS NULL;

DELETE FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE v_nom <> 380 AND bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_hv_electrical_neighbours_line );

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_hv_electrical_neighbours_transformer','ego_dp_powerflow_electrical_neighbour.sql',' ');
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_hv_electrical_neighbours_bus','ego_dp_powerflow_electrical_neighbour.sql',' ');
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_grid_hv_electrical_neighbours_line','ego_dp_powerflow_electrical_neighbour.sql',' ');


-- Include border crossing lines, transformer and buses for neighbouring states (electrical neighbours) for Status Quo
INSERT INTO model_draft.ego_grid_pf_hv_line (scn_name, line_id, bus0, bus1, x, r, s_nom, topo, geom, length, frequency, cables)
SELECT 'Status Quo', line_id, bus0, bus1, x, r, s_nom, topo, geom, length, frequency, cables FROM model_draft.ego_grid_hv_electrical_neighbours_line;

INSERT INTO model_draft.ego_grid_pf_hv_bus (scn_name, bus_id, v_nom, geom)
SELECT 'Status Quo',bus_id, v_nom, geom FROM model_draft.ego_grid_hv_electrical_neighbours_bus WHERE id < 28;

INSERT INTO model_draft.ego_grid_pf_hv_transformer (scn_name, trafo_id, bus0, bus1, x, s_nom, geom, tap_ratio, phase_shift)
SELECT 'Status Quo', trafo_id, bus0, bus1, x, s_nom, geom, tap_ratio, phase_shift FROM model_draft.ego_grid_hv_electrical_neighbours_transformer
