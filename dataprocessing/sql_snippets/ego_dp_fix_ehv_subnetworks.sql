﻿﻿---- 380kV Berlin 
--- line doesn't exist in entso-e, substations are 110kV in osm 
-- delete 380kV buses nd lines and temporary reconnect one-ports
DELETE FROM model_draft.ego_grid_pf_hv_busmap WHERE scn_name = 'Status Quo';

UPDATE model_draft.ego_grid_pf_hv_generator
SET	bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE osm_name = 'Umspannwerk Biesdorf Nord' AND base_kv = 110)
WHERE bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE osm_name = 'Umspannwerk Biesdorf Nord' AND base_kv = 380);

UPDATE model_draft.ego_grid_pf_hv_load
SET	bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE osm_name = 'Umspannwerk Biesdorf Nord' AND base_kv = 110)
WHERE bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE osm_name = 'Umspannwerk Biesdorf Nord' AND base_kv = 380);

UPDATE model_draft.ego_grid_pf_hv_storage
SET	bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE osm_name = 'Umspannwerk Biesdorf Nord' AND base_kv = 110)
WHERE bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE osm_name = 'Umspannwerk Biesdorf Nord' AND base_kv = 380);

UPDATE model_draft.ego_grid_pf_hv_load
SET	bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE osm_name = 'Umspannwerk Lichtenberg' AND base_kv = 110)
WHERE bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE osm_name = 'Umspannwerk Lichtenberg' AND base_kv = 380);

UPDATE model_draft.ego_grid_pf_hv_storage
SET	bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE osm_name = 'Umspannwerk Lichtenberg' AND base_kv = 110)
WHERE bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE osm_name = 'Umspannwerk Lichtenberg' AND base_kv = 380);

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND bus_id IN (SELECT bus_i FROM grid.otg_ehvhv_bus_data
WHERE geom IN ('0101000020E6100000E6D4C59C60F02A40A254AE08CF424A40','0101000020E61000000F6844C4280B2B4074AC9C07C1424A40', '0101000020E61000008A5DDBDB2DE92A40372C5789C3424A40', '0101000020E6100000799F91F85E0B2B40277E8D4F25434A40', '0101000020E6100000ADA580B4FF112B40829EBC7E77434A40', '0101000020E6100000C8C54A64F5122B4012EB782DCC444A40')
AND base_kv = 380);

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE bus0 IN (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom IN ('0101000020E6100000E6D4C59C60F02A40A254AE08CF424A40','0101000020E61000000F6844C4280B2B4074AC9C07C1424A40', '0101000020E61000008A5DDBDB2DE92A40372C5789C3424A40', '0101000020E6100000799F91F85E0B2B40277E8D4F25434A40', '0101000020E6100000ADA580B4FF112B40829EBC7E77434A40', '0101000020E6100000C8C54A64F5122B4012EB782DCC444A40')
AND base_kv = 380);

DELETE FROM model_draft.ego_grid_pf_hv_transformer WHERE bus1 IN (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom IN ('0101000020E6100000E6D4C59C60F02A40A254AE08CF424A40','0101000020E61000000F6844C4280B2B4074AC9C07C1424A40', '0101000020E61000008A5DDBDB2DE92A40372C5789C3424A40', '0101000020E6100000799F91F85E0B2B40277E8D4F25434A40', '0101000020E6100000ADA580B4FF112B40829EBC7E77434A40', '0101000020E6100000C8C54A64F5122B4012EB782DCC444A40')
AND base_kv = 380);


---- 220kV Weiher
--- missing line from Weiher to Uchtelfangen
-- add line
INSERT INTO model_draft.ego_grid_pf_hv_line (line_id, bus0, bus1, s_nom, cables, frequency, topo, geom, length, x)
SELECT	nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 220 AND osm_name = 'KW Weiher'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 220 AND osm_name = 'Umspannwerk Uchtelfangen'),
	1040,
	6,
	50,
	'0102000020E610000002000000D6DAC30771211C402D969AACD8AA4840650A175E64FC1B4071A44A690DB04840',
	'0105000020E610000001000000010200000002000000D6DAC30771211C402D969AACD8AA4840650A175E64FC1B4071A44A690DB04840',
	5.23167613642908 * 1.15,
	5.23167613642908 * 1.15 * 314.15 * 0.001;	


---- 220kV Industriepark Höchst
--- wrong voltage-level 
-- change v_nom from 220kV to 110kV, add/delete buses, change one-ports buses
UPDATE model_draft.ego_grid_pf_hv_generator
SET	bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E6100000C208F2600E1321404EED06B1FE094940' AND base_kv = 110)
WHERE bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E6100000C208F2600E1321404EED06B1FE094940' AND base_kv = 220);

UPDATE model_draft.ego_grid_pf_hv_generator
SET	bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E610000091281516C01521401894D558490C4940' AND base_kv = 110)
WHERE bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E610000091281516C01521401894D558490C4940' AND base_kv = 220);

UPDATE model_draft.ego_grid_pf_hv_load
SET	bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E6100000C208F2600E1321404EED06B1FE094940' AND base_kv = 110)
WHERE bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E6100000C208F2600E1321404EED06B1FE094940' AND base_kv = 220);

UPDATE model_draft.ego_grid_pf_hv_load
SET	bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E610000091281516C01521401894D558490C4940' AND base_kv = 110)
WHERE bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E610000091281516C01521401894D558490C4940' AND base_kv = 220);

UPDATE model_draft.ego_grid_pf_hv_storage
SET	bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E6100000C208F2600E1321404EED06B1FE094940' AND base_kv = 110)
WHERE bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E6100000C208F2600E1321404EED06B1FE094940' AND base_kv = 220);

UPDATE model_draft.ego_grid_pf_hv_storage
SET	bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E610000091281516C01521401894D558490C4940' AND base_kv = 110)
WHERE bus = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E610000091281516C01521401894D558490C4940' AND base_kv = 220);

INSERT INTO model_draft.ego_grid_pf_hv_bus (bus_id, v_nom, geom)
SELECT DISTINCT ON (geom)
	nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
	110,
	geom
FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E61000008FEB3AAF0C152140B97D456DD1094940';

UPDATE model_draft.ego_grid_pf_hv_line 
SET	bus1 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E610000091281516C01521401894D558490C4940' AND base_kv = 110),
	bus0 = (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E61000008FEB3AAF0C152140B97D456DD1094940' AND v_nom = 110),
	s_nom = 520,
	cables = 6,
	x = length * 314.15 * 0.0012/2
WHERE bus1 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E610000091281516C01521401894D558490C4940' AND base_kv = 220)
	AND bus0 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E61000008FEB3AAF0C152140B97D456DD1094940' AND base_kv = 220);

UPDATE model_draft.ego_grid_pf_hv_line 
SET	bus0 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E6100000C208F2600E1321404EED06B1FE094940' AND base_kv = 110),
	bus1 = (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E61000008FEB3AAF0C152140B97D456DD1094940' AND v_nom = 110),
	s_nom = 520,
	cables = 6,
	x = length * 314.15 * 0.0012/2
WHERE bus0 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E6100000C208F2600E1321404EED06B1FE094940' AND base_kv = 220)
	AND bus1 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E61000008FEB3AAF0C152140B97D456DD1094940' AND base_kv = 220);

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE bus_id IN 
(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom IN ('0101000020E61000008FEB3AAF0C152140B97D456DD1094940', '0101000020E6100000C208F2600E1321404EED06B1FE094940', '0101000020E610000091281516C01521401894D558490C4940') AND base_kv = 220);

---220kV subnetwork Heinitz/Saarstahl
--- add 220kV line from Uchtelfangen to Heinitz, in respect to osm and bing
-- this error is maybe fixed in osm 
INSERT INTO model_draft.ego_grid_pf_hv_line (line_id, bus0, bus1, length, topo, geom,  x, r, s_nom, cables, frequency)
SELECT 	nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 220 AND osm_name = 'Umspannwerk Uchtelfangen'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 220 AND osm_name = 'Umspannwerk Heinitz'),
	10.6040557238013, 
	'0102000020E610000002000000650A175E64FC1B4071A44A690DB0484085E1E2CCE9771C40D1DD7BCF2EA94840',
	'0105000020E610000001000000010200000002000000650A175E64FC1B4071A44A690DB0484085E1E2CCE9771C40D1DD7BCF2EA94840',
	10.6040557238013 * 314 * 0.001,
	10.6040557238013 * 0.109,
	1040,
	6,
	50;
	
---- Verbindung Lübeck-Siems
INSERT INTO model_draft.ego_grid_pf_hv_bus (bus_id, v_nom, geom)
SELECT DISTINCT ON (geom)
	nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
	220,
	geom
FROM grid.otg_ehvhv_bus_data WHERE osm_name IN ('Umspannwerk Siems');
	
INSERT INTO model_draft.ego_grid_pf_hv_line (line_id, bus0, bus1, s_nom, topo, geom, length, x, cables, frequency)
SELECT	nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 220 AND osm_name = 'Lübeck'),
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom = '0101000020E6100000D38040358C8525403935408972F44A40'),
	520,
	'0102000020E6100000020000006380D3776E4825406764811FA7F54A40D38040358C8525403935408972F44A40',
	'0105000020E6100000010000000102000000020000006380D3776E4825406764811FA7F54A40D38040358C8525403935408972F44A40',
	7.91338283450564 * 1.15,
	314.15 * 0.001 * 7.91338283450564 * 1.15,
	3,
	50;
	
INSERT INTO model_draft.ego_grid_pf_hv_transformer(trafo_id, bus0, bus1, s_nom, x, phase_shift, tap_ratio, topo, geom)
SELECT 	nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom = '0101000020E6100000D38040358C8525403935408972F44A40'),
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND geom = '0101000020E6100000D38040358C8525403935408972F44A40'),
	600,
	2,
	0,
	1,
	'0102000020E610000002000000D38040358C8525403935408972F44A40D38040358C8525403935408972F44A40',
	'0105000020E610000001000000010200000002000000D38040358C8525403935408972F44A40D38040358C8525403935408972F44A40';
	

---- 380kV Plattling 
--- wrong line connection 
-- delete old line and add new one
INSERT INTO model_draft.ego_grid_pf_hv_bus (bus_id, v_nom, geom)
VALUES	(nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
	380,
	'0101000020E6100000E1F4899702B52940FA1DD48F97614840');




---- 380kV Weisweiler
--- missing connection from powerstation to 380kV line
-- add 380kV line
INSERT INTO model_draft.ego_grid_pf_hv_line (line_id, bus0, bus1, topo, geom,length,  x,  s_nom, cables, frequency)
SELECT 	nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 380 AND geom = '0101000020E610000050D9BE3268491940C27D4210236B4940'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 380 AND geom = '0101000020E6100000FE4C1828844919408E469968EB6A4940'),
	'0102000020E61000000200000050D9BE3268491940C27D4210236B4940FE4C1828844919408E469968EB6A4940',
	'0105000020E61000000100000001020000000200000050D9BE3268491940C27D4210236B4940FE4C1828844919408E469968EB6A4940',
	0.189094013858938 * 1.15,
	314.15 * 0.001 /2 *0.189094013858938 * 1.15,
	3580,
	6,
	50;


DELETE  FROM model_draft.ego_grid_pf_hv_transformer WHERE bus1 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus) OR bus0 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus);
