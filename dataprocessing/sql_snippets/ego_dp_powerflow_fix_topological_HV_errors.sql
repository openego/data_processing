----- Fix topological errors in HV grid ------

---- 380kV subnetwork Berlin
-- delete isolated busses
DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND geom = ('0101000020E61000008A5DDBDB2DE92A40372C5789C3424A40');

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND geom = ('0101000020E6100000ADA580B4FF112B40829EBC7E77434A40');

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND geom = ('0101000020E61000000F6844C4280B2B4074AC9C07C1424A40');

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND geom = ('0101000020E6100000E6D4C59C60F02A40A254AE08CF424A40');

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND geom = ('0101000020E6100000799F91F85E0B2B40277E8D4F25434A40');

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND geom = ('0101000020E6100000C8C54A64F5122B4012EB782DCC444A40');



---- 220kV subnetwork Industriepark Höchst
--- delete isolated busses, no line in entso-e
DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom = ('0101000020E61000008FEB3AAF0C152140B97D456DD1094940');

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom = ('0101000020E6100000C208F2600E1321404EED06B1FE094940');

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom = ('0101000020E610000091281516C01521401894D558490C4940');



---- 380kV subnetwork Lübeck
-- add 220kV line in respect to entso-e grid map


DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom = ('0101000020E6100000D38040358C8525403935408972F44A40');

DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom = ('0101000020E6100000C678831E204A25400CEE62F5A2F54A40');

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE topo = ('0102000020E61000000200000017026F377786254034AC9800B2F44A40C678831E204A25400CEE62F5A2F54A40')
		AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom =('0101000020E6100000C678831E204A25400CEE62F5A2F54A40'))
		OR bus1 = (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom =('0101000020E6100000C678831E204A25400CEE62F5A2F54A40'));

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE topo = ('0102000020E610000002000000C678831E204A25400CEE62F5A2F54A406380D3776E4825406764811FA7F54A40')
		AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E61000006380D3776E4825406764811FA7F54A40'))
		OR bus1 = (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E61000006380D3776E4825406764811FA7F54A40'));
		
INSERT INTO model_draft.ego_grid_pf_hv_bus (bus_id, v_nom, geom)

VALUES (nextval('model_draft.bus_id'),
	220,
	('0101000020E6100000D38040358C8525403935408972F44A40')),

	(nextval('model_draft.bus_id'),
	220,
	('0101000020E6100000C678831E204A25400CEE62F5A2F54A40'));
	

INSERT INTO model_draft.ego_grid_pf_hv_line (line_id, bus0, bus1, geom, topo, length, x, r, cables, s_nom, frequency)

VALUES (nextval('model_draft.line_id'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom =('0101000020E6100000C678831E204A25400CEE62F5A2F54A40')),
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom =('0101000020E6100000D38040358C8525403935408972F44A40')),
	('0105000020E61000000100000001020000003100000017026F377786254034AC9800B2F44A4017026F377786254034AC9800B2F44A4007A3EDF373862540003B376DC6F44A40FC9B06FB6586254090A740C120F54A40F14C68925886254090CEAF9C73F54A4069DCE56C4B862540B6BE4868CBF54A40FD1C7AE6408625403DCB3D6E09F64A40BA1803EB38862540D2BF6E2244F64A400E1A55E12A8625405E0B1FB699F64A40FCEDA1331F862540C72FBC92E4F64A405C69633612862540C455AF6C30F74A40D9B1B6CE64842540AB6DD45460F74A4021D099B4A9822540B0C67EBB91F74A407D4512184681254042131736B9F74A40A44F502F9D7F2540EF885462E8F74A402C1213D4F07D2540ADF3B92418F84A403EBFDEB3647C25400DAA0D4E44F84A40A1E0BDFE7F7B2540424A479451F84A4009D4AC7D4B7A2540F0FE78AF5AF84A409FFDED57A6782540A83B4F3C67F84A40271B6A6F4B772540DECD531D72F84A406D286B8AB6752540493FD0C07EF84A40D2AE9D83C27325403BA28C028EF84A40CE2F945D7A7125408BA5ED04A0F84A407640C868D36F2540310109D4ACF84A401EB7A9CB736E2540EA4317D4B7F84A40FE3BECCF8F6C254075BFF9C385F84A40A78CC92C8C6A25400133DFC14FF84A40470C9645BC68254014BAA69B1FF84A402396DE48EA662540A376BF0AF0F74A40E7165F590E652540F84E71C1BEF74A40976F229FFC6225400288163488F74A4038B23C597B612540E19A3BFA5FF74A40F7A864A5EE5F25404015376E31F74A40B9DF466F5D5E2540353B9C0A02F74A40F5B3A217FF5C2540BB7EC16ED8F64A407D32B55B815B2540BB185EA4ABF64A40C7B13F9AFB592540D28437B57DF64A40A0BE0A9524582540B9019F1F46F64A40147AFD497C562540FCB6161C14F64A40AD7B759F2D552540E743ABEEECF54A4007E3F1FE8953254065E3C116BBF54A406E0091D9B451254087A6ECF483F54A400854A4671F502540763D2C2F54F54A400A394AB9564E254074F629221EF54A40013DC38A094C254076DABF5719F54A4025BAC216164B254077F0B84D5DF54A40C678831E204A25400CEE62F5A2F54A40C678831E204A25400CEE62F5A2F54A40'),
	('0102000020E61000000200000017026F377786254034AC9800B2F44A40C678831E204A25400CEE62F5A2F54A40'),
	11.5574695399625,
	(11.5574695399625 * 314* 0.001),
	(11.5574695399625 * 0.109),
	3,
	520,
	50),

	(nextval('model_draft.line_id'),
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E61000006380D3776E4825406764811FA7F54A40')),
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom =('0101000020E6100000C678831E204A25400CEE62F5A2F54A40')),
	('0105000020E610000001000000010200000004000000C678831E204A25400CEE62F5A2F54A40C678831E204A25400CEE62F5A2F54A401444DD07204925402FDBF3A1B0F54A406380D3776E4825406764811FA7F54A40'),
	('0102000020E610000002000000C678831E204A25400CEE62F5A2F54A406380D3776E4825406764811FA7F54A40'),
	0.231201044118972,
	(0.231201044118972 * 314 * 0.001),
	(0.231201044118972 * 0.109),
	3,
	520,
	50);


---- 220kV subnetwork Kraftwerk Weiher
--- add 220kV line from Uchtelfangen to Weiher in respect to osm, bing and entso-e grid map
-- this error is maybe fixed in osm 

INSERT INTO model_draft.ego_grid_pf_hv_line (line_id, bus0, length, topo, x, r, s_nom, cables, frequency)

VALUES 	(nextval('model_draft.line_id'),
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E6100000D6DAC30771211C402D969AACD8AA4840')),
	6.04276667319728, 
	('0102000020E610000002000000DBDAC30771211C402C969AACD8AA4840600A175E64FC1B4074A44A690DB04840'),
	(6.04276667319728 * 314 * 0.001),
	(6.04276667319728 * 0.109),
	1040,
	6,
	50);
	

UPDATE model_draft.ego_grid_pf_hv_line

SET bus1 = (CASE 	WHEN ('0105000020E6100000010000000102000000130000003B85D49767FC1B400A31B1F90DB0484055CC04B6B1FF1B40C23972AEF4AF4840538C9112CF011C4049566CB9C3AF484094C7A805BB011C40EDCFB23695AF4840804D351B6A031C40D726E8C54BAF484086BAABA054071C40953FBD74F4AE4840BCC8F223AE091C40BCED6F25BCAE484057A62433FC0F1C40611A82F42EAE4840FAE3697EE30E1C4010C5AEB9D2AD4840C23569A9980D1C400F34C21A59AD4840E0FC7F0EA80C1C4028EAFB83F5AC4840FB8323D0D40D1C40D20026BDBAAC4840F3C3C9E52C141C40C55552FF6BAB4840A65BE282AE161C408778576827AB4840DC69290608191C40418FBF6008AB484084B49E28CB1A1C4065A8851317AB4840DF962CE80F1F1C4024DB6B0A29AB48400D58D0F0AA201C4060D4EB61D7AA4840D3695C787D211C402E5512D5D9AA4840' IN (SELECT geom FROM model_draft.ego_grid_pf_hv_line))
			THEN (CASE bus0 WHEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E6100000D6DAC30771211C402D969AACD8AA4840')) 
					THEN 0

					ELSE bus1
					END)
					
			ELSE (CASE bus0 WHEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E6100000D6DAC30771211C402D969AACD8AA4840')) 
					THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E6100000650A175E64FC1B4071A44A690DB04840'))

					ELSE bus1
					END)
			
		END );

		
		
UPDATE model_draft.ego_grid_pf_hv_line

SET geom = (CASE 	WHEN bus0 = ((SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E6100000D6DAC30771211C402D969AACD8AA4840')))
				THEN ('0105000020E6100000010000000102000000130000003B85D49767FC1B400A31B1F90DB0484055CC04B6B1FF1B40C23972AEF4AF4840538C9112CF011C4049566CB9C3AF484094C7A805BB011C40EDCFB23695AF4840804D351B6A031C40D726E8C54BAF484086BAABA054071C40953FBD74F4AE4840BCC8F223AE091C40BCED6F25BCAE484057A62433FC0F1C40611A82F42EAE4840FAE3697EE30E1C4010C5AEB9D2AD4840C23569A9980D1C400F34C21A59AD4840E0FC7F0EA80C1C4028EAFB83F5AC4840FB8323D0D40D1C40D20026BDBAAC4840F3C3C9E52C141C40C55552FF6BAB4840A65BE282AE161C408778576827AB4840DC69290608191C40418FBF6008AB484084B49E28CB1A1C4065A8851317AB4840DF962CE80F1F1C4024DB6B0A29AB48400D58D0F0AA201C4060D4EB61D7AA4840D3695C787D211C402E5512D5D9AA4840')

			ELSE geom 
		END);



---220kV subnetwork Heinitz/Saarstahl
--- add 220kV line from Uchtelfangen to Heinitz, in respect to osm and bing
-- this error is maybe fixed in osm 

INSERT INTO model_draft.ego_grid_pf_hv_line (line_id, bus0, length, topo, x, r, s_nom, cables, frequency)

VALUES 	(nextval('model_draft.line_id'),
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E610000085E1E2CCE9771C40D1DD7BCF2EA94840')),
	12.788235590227,
	('0102000020E61000000200000082E1E2CCE9771C40D0DD7BCF2EA94840600A175E64FC1B4074A44A690DB04840'),
	(12.788235590227 * 314 * 0.001),
	(12.788235590227 * 0.109),
	1040,
	6,
	50);

UPDATE model_draft.ego_grid_pf_hv_line

SET bus1 = (CASE 	WHEN ('0105000020E61000000100000001020000001200000076306AC304781C40A61FEBCE30A94840850D43448A771C40489B436C4BA94840D2CD2927ED7B1C40D32CCDFC7EA948401FAB21F7F47E1C40B27654DBBFA94840F14DB94EAE7D1C40D7B0277B73AA484035877E3B71701C403756096F20AB4840975DE43C9A631C40E9B215B141AB48404E9C811D2E511C40398C7C6334AB48404ED6A3F7774E1C4052EFCF259DAB48403D16DC63974D1C4087FBAF3909AC48404E12555EA33E1C4001733AAA44AC4840FBFFD4091E321C40ED09A4B630AC4840C78AF5C9FE251C400E31D214AAAC4840763E539B2F1C1C4092A3D004C3AC48406FECB9290D141C40C57DED43E4AD484065488746C8031C402BCB893A55AF484091DF11C958021C4062F67D5C99AF4840423C3CD39AFC1B409419DAA912B04840' IN (SELECT geom FROM model_draft.ego_grid_pf_hv_line))
			THEN (CASE bus0 WHEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E610000085E1E2CCE9771C40D1DD7BCF2EA94840')) 
					THEN 0

					ELSE bus1
					END)
					
			ELSE (CASE bus0 WHEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E610000085E1E2CCE9771C40D1DD7BCF2EA94840')) 
					THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E6100000650A175E64FC1B4071A44A690DB04840'))

					ELSE bus1
					END)
			
		END );



		
UPDATE model_draft.ego_grid_pf_hv_line

SET geom = (CASE 	WHEN (bus0 = (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND v_nom = 220 AND geom =('0101000020E610000085E1E2CCE9771C40D1DD7BCF2EA94840')))
				THEN ('0105000020E61000000100000001020000001200000076306AC304781C40A61FEBCE30A94840850D43448A771C40489B436C4BA94840D2CD2927ED7B1C40D32CCDFC7EA948401FAB21F7F47E1C40B27654DBBFA94840F14DB94EAE7D1C40D7B0277B73AA484035877E3B71701C403756096F20AB4840975DE43C9A631C40E9B215B141AB48404E9C811D2E511C40398C7C6334AB48404ED6A3F7774E1C4052EFCF259DAB48403D16DC63974D1C4087FBAF3909AC48404E12555EA33E1C4001733AAA44AC4840FBFFD4091E321C40ED09A4B630AC4840C78AF5C9FE251C400E31D214AAAC4840763E539B2F1C1C4092A3D004C3AC48406FECB9290D141C40C57DED43E4AD484065488746C8031C402BCB893A55AF484091DF11C958021C4062F67D5C99AF4840423C3CD39AFC1B409419DAA912B04840')

			ELSE geom 
		END);
		

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE bus1 = 0;

		
		
