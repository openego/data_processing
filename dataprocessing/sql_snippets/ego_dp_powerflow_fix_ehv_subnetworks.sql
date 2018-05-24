DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_fix_errors_bus_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_fix_errors_bus_id;
SELECT setval('model_draft.ego_grid_hv_fix_errors_bus_id', (max(bus_id)+1)) FROM model_draft.ego_grid_pf_hv_bus;

DROP SEQUENCE IF EXISTS  model_draft.ego_grid_hv_fix_errors_line_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_fix_errors_line_id;
SELECT setval('model_draft.ego_grid_hv_fix_errors_line_id', (max(line_id)+1)) FROM model_draft.ego_grid_pf_hv_line;

DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_fix_errors_transformer_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_fix_errors_transformer_id;
SELECT setval('model_draft.ego_grid_hv_fix_errors_transformer_id', (max(trafo_id)+1)) FROM model_draft.ego_grid_pf_hv_transformer;


---- 380kV Berlin 
--- line doesn't exist in entso-e, substations are 110kV in osm 
-- delete 380kV buses 

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
SELECT	nextval('model_draft.ego_grid_hv_fix_errors_line_id'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 220 AND osm_name = 'KW Weiher'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 220 AND osm_name = 'Umspannwerk Uchtelfangen'),
	1040,
	6,
	50,
	'0102000020E610000002000000D6DAC30771211C402D969AACD8AA4840650A175E64FC1B4071A44A690DB04840',
	'0105000020E610000001000000010200000002000000D6DAC30771211C402D969AACD8AA4840650A175E64FC1B4071A44A690DB04840',
	5.23167613642908 * 1.15,
	5.23167613642908 * 1.15 * 314.15 * 0.001/2;


INSERT INTO model_draft.ego_grid_pf_hv_bus (bus_id, v_nom, geom)
SELECT DISTINCT ON (geom)
	nextval('model_draft.ego_grid_hv_fix_errors_bus_id'),
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
SELECT 	nextval('model_draft.ego_grid_hv_fix_errors_line_id'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 220 AND osm_name = 'Umspannwerk Uchtelfangen'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 220 AND osm_name = 'Umspannwerk Heinitz'),
	10.6040557238013, 
	'0102000020E610000002000000650A175E64FC1B4071A44A690DB0484085E1E2CCE9771C40D1DD7BCF2EA94840',
	'0105000020E610000001000000010200000002000000650A175E64FC1B4071A44A690DB0484085E1E2CCE9771C40D1DD7BCF2EA94840',
	10.6040557238013 * 314 * 0.001/2,
	10.6040557238013 * 0.109/2,
	1040,
	6,
	50;

---- Verbindung Lübeck-Siems
INSERT INTO model_draft.ego_grid_pf_hv_bus (bus_id, v_nom, geom)
SELECT DISTINCT ON (geom)
	nextval('model_draft.ego_grid_hv_fix_errors_bus_id'),
	220,
	geom
FROM grid.otg_ehvhv_bus_data WHERE osm_name IN ('Umspannwerk Siems');

INSERT INTO model_draft.ego_grid_pf_hv_line (line_id, bus0, bus1, s_nom, topo, geom, length, x, cables, frequency)
SELECT	nextval('model_draft.ego_grid_hv_fix_errors_line_id'),
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
SELECT 	nextval('model_draft.ego_grid_hv_fix_errors_transformer_id'),
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 220 AND geom = '0101000020E6100000D38040358C8525403935408972F44A40'),
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND geom = '0101000020E6100000D38040358C8525403935408972F44A40'),
	600,
	9.68,
	0,
	1,
	'0102000020E610000002000000D38040358C8525403935408972F44A40D38040358C8525403935408972F44A40',
	'0105000020E610000001000000010200000002000000D38040358C8525403935408972F44A40D38040358C8525403935408972F44A40';

---- 380kV Plattling 
--- wrong line connection 
-- delete old line and add new one
INSERT INTO model_draft.ego_grid_pf_hv_bus (bus_id, v_nom, geom)
VALUES	(nextval('model_draft.ego_grid_hv_fix_errors_bus_id'),
	380,
	'0101000020E6100000E1F4899702B52940FA1DD48F97614840');
	
INSERT INTO model_draft.ego_grid_pf_hv_line (line_id, bus0, bus1, topo, geom,length,  x,  s_nom, cables, frequency)
VALUES (nextval('model_draft.ego_grid_hv_fix_errors_line_id'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 380 AND osm_name = 'Umspannwerk Pleinting'),
	(SELECT DISTINCT ON (bus_id) bus_id FROM  model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND geom = '0101000020E6100000E1F4899702B52940FA1DD48F97614840'),
	'0102000020E61000000200000030AC43C5F4342A40D8CA9DE357554840E1F4899702B52940FA1DD48F97614840',
	'0105000020E610000001000000010200000032000000E1F4899702B52940FA1DD48F976148401D2C5217DFB629402B5327FB42614840CAF6C6B546B92940DE03745FCE604840DF1C098F91BB29403F41182E6160484075EF9705C9BD2940154152FAF85F4840EA91ABFD42C02940C81FB182845F484054AE4BE889C22940171A3ED8185F4840D5592DB0C7C4294041F0F8F6AE5E4840A65B1BCF0CC729409679ABAE435E4840AD6D8AC745C9294031395A7AD95D48402CADD05158CB2940D4827236785D48403535BF5076CD29402B3BB313145D484044F174F8B5CF2940EA5A7B9FAA5C4840EB3E5B62C0D12940B0D69AF7495C4840C30A5CC3B1D329400371C394ED5B4840A16BBAF9A1D52940C65E398C935B4840178F41DDF6D729404C112A82495B4840E58E482586DA2940F855B950F95A484042823D810BDD294038FEFAD7A85A48404CA59F7076DF2940E27899BC5C5A4840650CBD0F51E22940E256E652015A4840203FC0FFFBE42940B3B112F3AC594840C5CC9948C4E72940B6CA5D9555594840896A0025F4E929406304F97E0F59484025F4E967A0EC2940D07F0F5EBB58484035046CAC69EF2940CD1DA2766458484012A5BDC117F22940E6B4029E0F5848403CF4DDAD2CF5294024AF7378AD5748400E9D43BEF0F7294044937A05585748405820D50B99FA2940FE63213A04574840996AC1E677FD294020D099B4A956484063EA533310002A40BB39A63858564840B3CF639467022A40CFC023850D5648400848EAF307052A40A297512CB7554840AB871EE7EC072A4089FF852F5D554840A3135333B50A2A40BC2CDCA8045548403EE2FCF26E0D2A40ACA0B316B0544840A5486359D50F2A40E729615C6054484003931B45D6122A40351D4B6947544840C878944A78162A40CEEE7F3628544840F11879B4CC192A402321DB430C544840416150A6D11C2A40B35F77BAF3534840C1ADBB79AA1F2A403D57A53EDA534840F9307BD976222A404969368FC3534840032BE2CF4B242A4031E076B2E553484071766B990C272A4040C1C58A1A5448404301DBC188292A4063DD2EEA49544840C19206126F2C2A40058651B58254484048B599547E2F2A40ED22F197BB5448406B6A3414D2312A40006A0F20E8544840', 
	22.624793411008,
	314.15 * 0.0008 * 22.624793411008,
	1790,
	3,
	50),

	(nextval('model_draft.ego_grid_hv_fix_errors_line_id'),
	(SELECT DISTINCT ON (bus_id) bus_id FROM  model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND geom = '0101000020E6100000E1F4899702B52940FA1DD48F97614840'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 380 AND osm_name = 'Schwandorf'),
	'0102000020E610000002000000E1F4899702B52940FA1DD48F97614840BBEF0B431D2A2840230697C412A64840',
	'0105000020E610000003000000010200000006000000C0EF0B431D2A2840200697C412A64840B2C68FE7E92A2840E88E5951DEA5484060668E9BD02A2840C4149B45DEA5484026FC523F6F2A2840352CA116DEA5484071A4D8767F292840C0EAC891CEA548400A2DEBFEB1282840BCEBC781B2A548400102000000040000006B6A3414D2312A40006A0F20E85448405AFBF14D89322A40263218C8585548407AD10D034C332A40B566D0758655484044AC43C5F4342A40D9CA9DE3575548400102000000CE0000000A2DEBFEB1282840BCEBC781B2A5484067E77E98CE2828402497FF907EA54840D026874F3A292840823D810B0DA548408ED7721D99292840688297CFA8A4484084DCA051152A28403430F2B226A44840BFDD488F952A2840FDAEBE709DA348402B4F20EC142B2840CA260A3E17A34840C2590009792B2840E8065449AEA24840FC45BF6CF12B2840A19FA9D72DA24840031203136E2C28408CA03193A8A148402E07D561E02C2840A60EF27A30A14840E801E264D12E28407B88467710A1484060A7FD7B9531284063145F48E2A0484059880E81233528408CE8E802A8A048400475CAA31B392840847F113466A04840B47B4D6AC33C2840A3B1513129A04840683EE76ED73F2840F85BF1C3F79F484047489341A4412840C4E347A1D19F4840468E194DD3442840ECEA9FF18E9F4840C48FD6BDBA4728403E0F49884D9F4840D09D60FF754A2840319CC651149F4840558440D3B74D28400E2840B9129F4840D604ACB074512840F2BEE0890F9F4840BA7C355195542840CF4A5AF10D9F48406ADF3719B0572840EF5B08CD099F4840238216B7765B2840906D7429099F4840B05CCA541C5E28405E448078029F4840EFEC86C844612840F08398F0F09E4840A88A4E3BA164284039C3C36AE29E4840EDF1423A3C682840C49B9031D29E4840329FBD44066B28403CE3569CC59E484089A8D3CB396E2840C7BB2363B59E4840F10D85CFD6712840E1687D80A49E4840A125D9340075284015D4A6A0919E4840C86EB081BE76284032DD90EB4B9E484061F998B44E792840FDEC9117E39D48404F01D5E4CE792840768071BA769D484050768E5C927A28400DD30847DA9C4840E158BCFD5E7B284079D388F4369C4840F1F62004E47B284049BA66F2CD9B4840FADB5493967C284003CC7C073F9B484093F139C1487D284082F3F3F0AF9A4840AB6FAAFFBD7D28401222CFE4519A4840F17F4754A87E284001E77BFC94994840BC410F10277F284058B9612530994840291B7B9BA37F2840A4816962CB984840C5DF9B4B168028403128D36872984840F8F829334A8028406D09545ADA974840943AB7BF698028409C29BEEB7D974840667EDA4D95802840191AF44AFE964840B5F6E39B12812840AD78D965AE9648406242716CE2812840E55828E32996484035AB88E4758228400947DAD7CB95484079A235502A832840BBF1EEC858954840612129D8358428401258EF26AE9448409816F549EE842840E30D7A8038944840B00FFCB9B285284094957032BB93484062597A7E62862840748A9F104B934840EB45A3F1FA862840415365CEE99248406D4ECA49CD872840870B8A308F924840AD9E3825C588284045C9F50027924840E28A30EAFF8928400C923EADA29148406B4EB91D758B2840FD5DE9C6059148402E85515AC98C2840B741EDB7769048406166440EB68D284008AD872F13904840C5F13279B98E284004DD0319A68F48400AF31E679A902840C60B337E2B8F4840EC8E20F01B92284046990D32C98E48402AE9BC21E8932840E72620DC538E48407DEC8909C5952840FB952941DA8D4840A5468DAE7798284021E3F6706E8D4840E7954627A69A284089658E40178D4840A8A55E5C4F9D284066B8A6E5AC8C4840EE26F8A6E99F284078A27FDD448C48406C15B3147FA2284015A930B6108C4840D4884FF003A6284003A4479DCA8B4840361488E821A82840A32F73709F8B4840F743C769E3AB2840A00491A0538B4840EE00F4A045AF2840A5C5747C0F8B4840FFB7EDD68DB22840DE93E23ECD8A48407111291774B428403F092241A78A48402480F67EFEB62840A60A4625758A4840B032BF3F4AB9284052D4997B488A4840F6C2537E08BC28407EC34483148A48403636E0980ABE2840BC067DE9ED894840E785E05DD3C02840C54D57C1B9894840C5DC5ACB09C32840FEB1B5638F89484009A469F57AC42840082F0B372A894840589643E625C62840BB0D6ABFB5884840EA2DD45059C72840BC2EB2536288484005FE4BAD52C928407A05FDE0D78748404584DACAA6CB284032E5435035874840A2A476757DCD284056ECD401B5864840D51CC5DE30CE28408C0EED084C864840DA9486753ECF284099017855B18548404E97C5C4E6CF2840E7E4A0DF52854840D5BF35C181D228407978CF81E584484031653B3A09D428409A5A5B1DA584484031074147ABD6284020A8644A3584484047F9EEFBDCD92840AD0210D2AE8348409E06B1D8CBDB284012B57E445D8348406F5287CBE0DE2840848DA152DB8248405CCCCF0D4DE128407D5D86FF748248401FBDE13E72E3284051B0B5AD1C824840A96E89B729E52840EE485057D28148403242D36DE4E5284071CEE38B51814840F63988E7B6E628409B3347FBC48048404E42E90B21E72840A74709B07E80484012BC218D0AE828407BCCF6D7E17F48407480BB4791E828406056CD188B7F48407E4056A64EEA2840E94DA0E3FE7E484026DEA6E441EB2840932A9B83B17E48401C768478C9EC2840DA38622D3E7E4840116C01463CEE28406ECACB50CB7D4840175F590E99EF2840B24AE9995E7D4840DDCEBEF220F12840484A1F5FE77C48402CA0AB0892F22840F992D794757C48408C7D6E0D11F428408F78680EFF7B48408C88BDAB79F5284087DD770C8F7B484078E62F3E16F8284015B3B9C5577B48404076CD9A0EFB2840DBCD42F1197B484051BF0B5BB3FD284074DB74BAE27A48402F675B7281002940D4DC651AA87A48402DCDAD105603294069DDABFB6C7A4840C5758C2B2E06294058B329B2317A4840DDCAB7E3F2082940F25602CEF7794840FF31BE79BB0B294093A3A597BD79484073CAEDA87B0E294028B85851837948403CB02D4D5B11294083D4377A4679484065FF3C0D18142940FF44C07C0D794840BF72CE99FE1629406B28B517D17848400D0055DCB81929408934E0E297784840D96212899D1C29407E4397265B7848405B1A097E651F29403DD7F7E12078484051943AB7BF21294030C912E7F2774840C63945A22B242940794F2F42C27748406412E456F7262940E895FC998B77484063FDB0EFD4292940830BC3915177484049A2F20A9F2C2940DAF51CA21B774840F0976082642F294002767F06E57648407E384888F2312940C985144DB1764840FFBC5FBB6A342940B8509E1E80764840CC71B8A00837294003E32A604C76484085ABA8667B392940A49AA3D81B764840E443F57B073C2940ACAD3319E975484073F0F1AE1F3F29403D6D437BAB75484049A93A9AD9412940C4094CA7757548401F42A6C695442940B6D210FA3E754840F50AB034954629407728AF3A17754840737A83D49247294012BCC6D397744840F1CD80C4C0482940FB90B75CFD734840967DB2BD714929407D19D69EA37348406ADFDC5F3D4A2940E87CC2233B734840C4BC7D0C0C4B294028CB5A54D5724840E2033BFE0B4C2940337678BE557248406027501FDC4C2940DCA799A4E87148400EEDAD92D94E2940E3E13D07967148404FC9DEF714512940FA0159993A71484017B1F4465253294070445266DE704840102A2790C855294063B323D577704840C1D6B672405829404A2C84301270484061F1E54F655A29403C50A73CBA6F48400245D1A8655C2940FB0B981B676F4840ED24C742195F2940C967C3ABF66E484094BF7B478D6129407937BB5A936E4840ED35F39A0D6429407F29A84D416E4840C2F1214D61662940C3D89D49F66D4840F51E1D0D966829405389FC44AF6D4840823D810B0D6B29405270C2CE5E6D48404F53701D886D2940BDD930540F6D484070F32103D46F2940C4ACBC89C66C4840B1F4465277722940A9C0C936706C484032D6EDA29E74294085AC133C2A6C484052071E842577294044EC0214D96B4840386A85E97B79294005A96FF48C6B4840089E31827C7B2940C7CA79104C6B4840B7B82121257D2940A20337F7FC6A48403B8BDEA9807F2940A708CB338A6A4840C3E4FC039B81294029EACC3D246A48400EA320787C83294058665B17C8694840BB5A931392852940C77A0F3C636948405E6CB5E2768729409D2166400769484042621635F3872940FB35FEE9AB6848402F23AB11B0882940074E6CF420684840FABDA83869892940F9CFE4AC99674840DD32969F0A8A294011F0B5B123674840E1777874C88A29402614C7269E6648408DD5E6FF558B294007FE0120386648402FCAC749BC8B2940EC00E374ED65484076662728EA8D2940126C5CFFAE6548402CEADD697C9029406C996780666548408901B7932D932940F8CC48731A654840197DBBDBAB95294058CBF852D3644840C2572A5E1B9829408ECEF9298E6448406241ABDDC09A29406EBEB62341644840D988168F419D2940EB1791CDFA634840D8ED5811DA9F29407C5E961BB16348400BF7802F3BA22940154FE2186E634840429A0C22ADA42940EA1560692A6348408C45782057A7294030A3B327DC6248400FB16609D7A82940B18BFDC0B062484025523F1471AB2940A8DF2AF466624840B00A2F1C63AE294037177FDB136248405E471CB281B02940C72C7B12D8614840309DD66D50B3294082D94EA5B0614840E1F4899702B52940FA1DD48F97614840',
	90.5604456325126,
	314.15 * 0.0008 * 90.5604456325126,
	1790,
	3,
	50),

	(nextval('model_draft.ego_grid_hv_fix_errors_line_id'),
	(SELECT DISTINCT ON (bus_id) bus_id FROM  model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380 AND geom = '0101000020E6100000E1F4899702B52940FA1DD48F97614840'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 380 AND geom = '0101000020E6100000C000DCEF17B429409E0779BEB3614840'),
	'0102000020E610000002000000E1F4899702B52940FA1DD48F97614840C000DCEF17B429409E0779BEB3614840',
	'0105000020E610000001000000010200000002000000E1F4899702B52940FA1DD48F97614840C000DCEF17B429409E0779BEB3614840',
	0.162698660268822,
	314.15 * 0.0008 * 0.162698660268822,
	1790,
	3,
	50);

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE bus0 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 380 AND osm_name = 'Umspannwerk Pleinting') AND bus1 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 380 AND osm_name = 'Schwandorf');

DELETE FROM model_draft.ego_grid_pf_hv_transformer WHERE bus1 = (SELECT DISTINCT ON (bus_i) bus_i FROM  grid.otg_ehvhv_bus_data WHERE base_kv = 380AND geom = '0101000020E61000002F70D819E6B4294094DDFA53EE614840');
	
DELETE FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E61000002F70D819E6B4294094DDFA53EE614840' AND v_nom = 380;

---- 380kV Weisweiler
--- missing connection from powerstation to 380kV line
-- add 380kV line
INSERT INTO model_draft.ego_grid_pf_hv_line (line_id, bus0, bus1, topo, geom,length,  x,  s_nom, cables, frequency)
SELECT 	nextval('model_draft.ego_grid_hv_fix_errors_line_id'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 380 AND geom = '0101000020E610000050D9BE3268491940C27D4210236B4940'),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 380 AND geom = '0101000020E6100000FE4C1828844919408E469968EB6A4940'),
	'0102000020E61000000200000050D9BE3268491940C27D4210236B4940FE4C1828844919408E469968EB6A4940',
	'0105000020E61000000100000001020000000200000050D9BE3268491940C27D4210236B4940FE4C1828844919408E469968EB6A4940',
	0.189094013858938 * 1.15,
	314.15 * 0.0008 /2 *0.189094013858938 * 1.15,
	3580,
	6,
	50;
	

---- Umspannwerk Marke
--- lines are not connected to the station in Marke
-- connect lines to the station

UPDATE model_draft.ego_grid_pf_hv_line
SET bus1 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 110 AND geom = '0101000020E6100000E68C989C3B86284098C783C0D9DE4940')
WHERE geom = '0105000020E610000002000000010200000003000000BC8CAC46C0862840B5D084DCFBDE494027214729D786284060BD40FFF3DE494069FE3D1D34882840A6CEED6F1ADF494001020000002E000000165685611B64284006E9184630E84940B225F5AFF6652840770E0AEF17E84940377F02DEB86728400CC2267C00E84940E39EF87B73692840547CD7FBE8E749406B4AB20E476B28406C9E7EABD0E74940A74AEF76186E2840490158D3ABE74940A83D80A037702840995CD60E90E74940344A97FE2571284098CC672F91E74940EED9CE520D7228406198028871E7494052031775F7722840D7DB0B7151E74940B11D8CD827742840D2F93ABA5BE74940EEA1D8655375284067AE1DD665E74940000CBA731777284096A1855F45E74940F6211400887828409A756B3E53E749404776A565A47A2840D3F0773936E74940209E25C8087C28401F5CF05822E74940BA539511727D28408EE5023C0EE74940DB1CE736E17E2840BE06335CD3E649403AAEEBBC328028407A2CC7759DE6494078C6AD388B8128402016C50666E64940D2D73DC3E5822840D73CA29D2EE649404F9FD3E24284284088026CF6F6E5494059A42EBE0D862840073AA462ADE5494096287B4B39872840C60490357EE5494013807F4A958828408A1B5CDF2CE5494015D67C4BEF8928402A6A7A9ADDE44940AFA4CB51368B2840397C77D091E44940927C2590128B2840CE5FD7E54AE44940CDC75AE8EF8A28401CC5837703E44940D83DC3E5C28A2840AE084845ADE3494053B648DA8D8A2840F6CCDC8D4FE34940824A4B9B608A2840FA0B3D62F4E24940E1DEEB5A318A28402DEBA3F89DE24940DED506825B8A28402509C21550E249406E2A9CEE868A284012DB824A01E24940615793A7AC8A28403F20D099B4E149403E5DDDB1D88A28400AE69E6461E14940642FCA22038B2840425DA45016E14940C753EAED2A8B2840F009C84DC3E04940CD5CE0F2588B2840E6E4EA6C6DE04940DE4FD724898B284031DE454E15E0494074A95B87B48B2840452E3883BFDF494031197DBBDB8B2840E86F9DDA74DF494098530262128A2840922749D74CDF4940C42F50AD19882840021B6BDA20DF4940BC8CAC46C0862840B5D084DCFBDE4940' AND s_nom = 520;

UPDATE model_draft.ego_grid_pf_hv_line
SET bus0 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 110 AND geom = '0101000020E6100000E68C989C3B86284098C783C0D9DE4940')
WHERE s_nom = 1040 AND geom = '0105000020E61000000100000001020000003400000069FE3D1D34882840A6CEED6F1ADF494069FE3D1D34882840A6CEED6F1ADF4940D034BCB43C8A28407668FDD247DF494054104DEA158C28409D88D92670DF4940F3C3526EEC8B28404D73E1F6BADF494081608E1EBF8B284089EFC4AC17E049404B2F206A918B2840B646A9296EE04940F1976082648B2840F522241CC4E0494058B66A323E8B2840F4401A040CE14940FC6E5FAC148B284074733B4558E14940C565CBA8E88A28407FA4880CABE14940A3E8818FC18A2840A96A82A8FBE14940C8DA3A93918A2840496F13494FE24940FFD0CC936B8A28405E3931DA99E24940FB7F304B968A28405CF80B87EFE24940AAE27CA0CB8A2840B4C3A92050E34940E540B4FBFA8A284072EA5E82AEE34940FD5877E2288B2840945742D202E4494098BFE72C588B2840B8BF69B05FE449403B6178DB3B8D2840EF3614E3A1E44940281A5A530F8F28406889DF5EE3E449407F2CE9CD4D902840FCBF8F0F1FE549404504D2B47A9128408CB5094158E549400F7D1C72D8922840C9E9EBF99AE54940097481261D9428406E293119D8E5494095DB51F75C9528403D30DBA914E64940CCCE47BEB7962840CF9662FD55E64940A5F6C7201C9828407D6C81F398E6494022B3695B839928401F66D421DCE64940F66F4D70A09A2840974DCAEE13E749409004D0DECF9B2840E6E324DE4BE7494007C36FF9FE9C2840C8478B3386E7494033A083D3279E28409C95A3B6C3E749400BDDDBE33B9F28409030B19EFFE74940BD2B71D355A02840F49A0DE83BE84940BF805EB873A12840C2E3367579E849401784F23E8EA2284033A0281AB5E849405876C1E09AA328401BAD591DEFE849401106F93482A4284066225B4C22E949406F5633219CA52840FE7F9C3061E949407F0FA848CFA628404CD18030A6E949409AEBD918E0A7284027101BD1E2E949406ECCA1FB28A92840BF8A42812DEA4940B782A62556AA284055EA48E471EA4940CA9BB28982AB284093F650ECB2EA4940F8C77BD5CAAC2840B52CA924FCEA4940C24AAA5BE2AD284095AC79443BEB49408F0BBDB497AF28403B3F202B53EB49408D92A17433B12840A14495AB69EB49403CE75DABF3B22840ED8B3A2982EB49402CC313D5B6B428404C3ED1D09AEB49402CC313D5B6B428404C3ED1D09AEB4940';

UPDATE model_draft.ego_grid_pf_hv_line
SET bus1 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 110 AND geom = '0101000020E6100000E68C989C3B86284098C783C0D9DE4940')
WHERE s_nom = 520 AND geom = '0105000020E61000000100000001020000001F0000003FBF396DD7C5284066DAA3DC22DC49403FBF396DD7C5284066DAA3DC22DC494034EDAC2704C428402B5E1BE038DC494042F806150BC2284018B1F44652DC4940C2413168D7BF284082AFE8D66BDC49402E1801BAD4BD2840B68075C185DC49406AFD2D01F8BB2840510F762F9CDC494075E789E76CB9284087D2CDB4B3DC4940CBC16C020CB728407C50AB43C9DC4940CF3A3EB555B428400A6D3997E2DC4940D4B430B033B228404E94CED1F4DC49405BE55311B8AF2840EE974F560CDD4940B7627FD93DAD2840427A8A1C22DD4940EA944737C2AA284037F867AB37DD49401351A79773A82840209A79724DDD49404EA14ED42DA628404BBB873A62DD4940F22BD67091A32840CED36F157ADD494001F676F0B8A12840CDF6D7E19EDD4940026A6AD95A9F2840204F26C9CEDD4940FD07477F1E9D2840DFD9684AFCDD494025C4A6DFCF9A28405B3B9B9F2CDE49402918DF6124992840672C9ACE4EDE4940D525E318C996284042F2295B7FDE494001B562C966942840723216F2ADDE494029DD4C3BEB91284016359886E1DE49400405DEC9A78F2840B892C2610EDF49404525BF8FB48D2840FCAD9D2809DF49405D959FAFB48B28404CA544B703DF4940B87E55890D8928405566EF31FDDE494094E7B0B10187284073874D64E6DE494094E7B0B10187284073874D64E6DE4940';

UPDATE model_draft.ego_grid_pf_hv_line
SET bus0 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 110 AND geom = '0101000020E6100000E68C989C3B86284098C783C0D9DE4940')
WHERE s_nom = 520 AND geom = '0105000020E61000000100000001020000002A0000003308628F3F872840068B1E53D2DE49400E901E752A872840C1971D3DD9DE494037525B8F67882840E2DC15B0D3DE4940E55E059DB5882840298705AD76DE494073CA92EF0889284060764F1E16DE49400E18247D5A89284044A9BD88B6DD49401FD55526A18928402961A6ED5FDD49405BC6979A4E882840EF05668522DD4940BFFB3E77DD8628404D0C1357DFDC4940BD7A70D28F852840E3E47E87A2DC494020B017AF1E842840E8B9CF3B5FDC4940F416B435C7822840C6D4A76620DC49407E2C335B6881284058B49487E0DB49405463F83E0B80284008DB3E9AA0DB4940E3B32BE3957E2840E97D88B25CDB4940A6619DCF257D2840BE2A61B719DB49406339F878D77B2840B3AFE18EDCDA494054D625998B7A28408BD3FF28A0DA4940A553B2F73D7928406944C42863DA4940BE384C8F01782840984B4FFD28DA4940033972EEC0762840154C46DFEED94940DA733EE19175284020717E79B7D949401AA54BFF927428407970C16389D9494013FEFB427E742840E1078C9A54D9494049275CD94F742840FE3DC27AEDD84940A79B1FDA22742840C6C551B989D849409C1DA9BEF3732840678AEF7A1FD849409B19A2AFC57328403166A60FB8D7494066EC3A0AC6732840589A4AF553D74940FA916CBFC673284006BD378600D74940B0027CB77973284023F6AEE6A5D64940789F3E5D3873284037FBA82B44D64940428EF7F422742840E94427F0F3D54940CE870C50BF742840D36C1E87C1D549405B417859B875284052C9EF236DD549401D6217A0C87628407407567A12D54940F9A067B3EA772840FEDA55A3B2D449409008D7EDFD772840A70705A568D449408E4AA07719782840019C285316D449402A9721E92E78284071276C9AD2D34940B4E6C75F5A782840D8344AF2B7D34940B4E6C75F5A782840D8344AF2B7D34940';

UPDATE model_draft.ego_grid_pf_hv_line
SET bus0 = (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE base_kv = 110 AND geom = '0101000020E6100000E68C989C3B86284098C783C0D9DE4940')
WHERE s_nom = 520 AND geom = '0105000020E6100000010000000102000000410000003308628F3F872840068B1E53D2DE49403308628F3F872840068B1E53D2DE494021C610A5628828402544543C89DE4940A7875748AF882840EFF4392D2EDE494016BA5C0E05892840EC055559CADD4940BAB42B3E4F89284037A38BF271DD4940EF5FB422C5872840704EDB7525DD49402DB87AA9338628409980046AD6DC49408D16FB26A8842840C07EE3C688DC494035C69805248328408C8FAA8141DC4940D4635B069C812840E027582DFADB49401E3691990B802840F37A8BE2B0DB4940B4C46FAF717E28407975334866DB4940C4A92050477D284005CF73FA30DB49407C9C69C2F67B284007EE409DF2DA4940DD66857D967A2840A54DD53DB2DA49407561FFD027792840DF910C946FDA494080619E3AFB772840A24CFE8238DA4940F3E7DB82A5762840D41D7A41FAD949404BA82A7E9D752840F2800DE3C9D9494021DFEF6140742840C01C870B8AD94940FF4A427D2672284026E2ADF36FD9494009D51753FA6F28401649601855D949400577FB07EC6D2840653C4A253CD949402C387293076C2840003153A40CD94940645694B7C86A2840974E35C4C2D84940B4D0292389692840C3E96EE877D84940B9910DFF44682840E4665D482CD8494049EA4EC12B67284080E89326EFD749405D01E0336D66284001608610A1D749402F0906C6B0652840AC22DC6454D749408FDC3FBBE8642840E20E2FE301D74940C0C1CD98386428405AF9C0E9B8D64940D363A593B6622840833BAB60AFD649405B046B419460284054162AA4A1D649403181B630665E2840C7BA5DD493D649408514F2F7415C2840C2429C3D86D6494070F2B62D255A2840A52CE86278D649405BDF76572C58284040EE6CD96BD6494045C82F720556284083B2DFC95DD64940C88ED7CDD6532840F52801D64FD64940B4DF2417AD512840D3DF4BE141D649404692C5A28E4F2840397AA12534D64940A6E727E66A4D28403A07CF8426D649406EC72F174C4B2840A0A124C918D64940E3A8DC442D492840727CA30C0BD649400A01AF850F4728402610655EFDD549409E1BE43FEE442840F7EAE3A1EFD5494076487BCDBC42284087A8C29FE1D5494084A279008B402840D6480158D3D54940AC62E06F6A3E2840A723809BC5D549400951BEA0853C28406077BAF3C4D5494021C19EC0853A2840AE8ACB4CC4D549405B3A30CA7D382840499748B3C3D549402BC0779B3736284002EB820BC3D54940A2A41BBC0A342840BB3EBD63C2D549400735327ED03128402C28B110C2D549408BFED0CC932F2840F157B730C1D54940E8F9D346752E2840E57BEB68C1D549404F07B29E5A2D28406DDCAC0B89D54940F55CF0B3DB2C28407ADC01E841D54940BFBED6A5462C28406F974748EED44940D9182AB5CD2B2840CD13BEADAAD449406AE21DE0492B284047C2082B5FD449406AE21DE0492B284047C2082B5FD44940';

DELETE FROM model_draft.ego_grid_pf_hv_line WHERE s_nom = 260 AND geom = '0105000020E6100000010000000102000000040000003308628F3F872840068B1E53D2DE49400E901E752A872840C1971D3DD9DE49405E72929C02872840A308A9DBD9DE494094E7B0B10187284073874D64E6DE4940';

---- Umspannwerk Jessen Nord
--- missing 110kV lines
-- add lines manually, THIS MIGHT BE FIXED WHEN UPDATING OSM-DATA!

INSERT INTO model_draft.ego_grid_pf_hv_bus  (scn_name, bus_id, v_nom, geom)
VALUES  ('Status Quo', nextval('model_draft.ego_grid_hv_fix_errors_bus_id'), 110, ST_SetSRID(ST_Point(13.0317764, 51.7792147), 4326)),
	('Status Quo', nextval('model_draft.ego_grid_hv_fix_errors_bus_id'), 110, ST_SetSRID(ST_Point(13.0289850, 51.7797518), 4326));

INSERT INTO model_draft.ego_grid_pf_hv_line (scn_name,line_id, bus0, bus1, x, r, g, b, s_nom, length, cables, frequency, geom, topo )
VALUES
    ('Status Quo',
    nextval('model_draft.ego_grid_hv_fix_errors_line_id'),
    (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE osm_name = 'UW Jessen Nord' AND base_kv = 110),
    (SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = ST_SetSRID(ST_Point(13.0317764, 51.7792147), 4326) AND v_nom = 110),
    0.6138,
    0.17754,
    0,
    0.000019455,
    520,
    3.3,
    6, 
    50, 
    '0105000020E610000001000000010200000002000000B9910DFF44102A40FE87AA4EBDE34940204C62AEFA1D2A402EA5F4F75DE64940',
    '0102000020E610000002000000B9910DFF44102A40FE87AA4EBDE34940204C62AEFA1D2A402EA5F4F75DE64940'
    ),

    ('Status Quo',
    nextval('model_draft.ego_grid_hv_fix_errors_line_id'),
    (SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE osm_name = 'UW Jessen Nord' AND base_kv = 110),
    (SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = ST_SetSRID(ST_Point(13.0289850, 51.7797518), 4326) AND v_nom = 110),
    0.6138,
    0.17754,
    0,
    0.000019455,
    520,
    3.3,
    6,
    50, 
    '0105000020E6100000010000000102000000020000002D26361FD70E2A40A2FF2FE8CEE34940204C62AEFA1D2A402EA5F4F75DE64940',
    '0102000020E6100000020000002D26361FD70E2A40A2FF2FE8CEE34940204C62AEFA1D2A402EA5F4F75DE64940');

UPDATE model_draft.ego_grid_pf_hv_line 
  SET
    bus1 = (SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom =  ST_SetSRID(ST_Point(13.0317764, 51.7792147), 4326) AND v_nom = 110),
    length = 15.9,
    x = 6,
    r = 1.735,
    b = 0.0000475,
    geom ='0105000020E610000001000000010200000002000000B9910DFF44102A40FE87AA4EBDE349406D49FDAB7D682A40EC2411D033DA4940',
    topo = '0102000020E610000002000000B9910DFF44102A40FE87AA4EBDE349406D49FDAB7D682A40EC2411D033DA4940'
  WHERE topo = '0102000020E6100000020000006D49FDAB7D682A40EC2411D033DA49406AB8C23255F22940ED1AB07B44E54940' AND s_nom = 260
;

INSERT INTO model_draft.ego_grid_pf_hv_line (scn_name,line_id, bus0, bus1, x, r, g, b, s_nom, length, cables, frequency, geom, topo )
VALUES	('Status Quo',
	nextval('model_draft.ego_grid_hv_fix_errors_line_id'),
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = ST_SetSRID(ST_Point(13.0317764, 51.7792147), 4326) AND v_nom = 110),
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = ST_SetSRID(ST_Point(13.0289850, 51.7797518), 4326) AND v_nom = 110),
	0.0755, 0.0218, 0, 0.000000597, 260, 0.2, 3, 50, 
	'0105000020E610000001000000010200000002000000B9910DFF44102A40FE87AA4EBDE349402D26361FD70E2A40A2FF2FE8CEE34940',
	'0102000020E610000002000000B9910DFF44102A40FE87AA4EBDE349402D26361FD70E2A40A2FF2FE8CEE34940'
	),

	('Status Quo',
	nextval('model_draft.ego_grid_hv_fix_errors_line_id'),
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = ST_SetSRID(ST_Point(13.0289850, 51.7797518), 4326) AND v_nom = 110),
	(SELECT bus_i FROM grid.otg_ehvhv_bus_data WHERE geom = '0101000020E61000006AB8C23255F22940ED1AB07B44E54940' AND base_kv = 110),
	1.547, 0.447, 0, 0.000012249, 260, 4.1, 3, 50, 
	'0105000020E6100000010000000102000000020000006AB8C23255F22940ED1AB07B44E549402D26361FD70E2A40A2FF2FE8CEE34940',
	'0102000020E6100000020000006AB8C23255F22940ED1AB07B44E549402D26361FD70E2A40A2FF2FE8CEE34940');


DELETE FROM model_draft.ego_grid_pf_hv_transformer WHERE bus1 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus) OR bus0 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus);
