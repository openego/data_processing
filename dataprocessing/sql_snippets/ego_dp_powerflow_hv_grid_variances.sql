DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_bus CASCADE;

CREATE TABLE model_draft.ego_grid_pf_hv_extension_bus
(
  scn_name character varying NOT NULL DEFAULT 'extension_NEP'::character varying,
  bus_id bigint NOT NULL, -- Unit: n/a...
  v_nom double precision, -- Unit: kV...
  current_type text DEFAULT 'AC'::text, -- Unit: n/a...
  v_mag_pu_min double precision DEFAULT 0, -- Unit: per unit...
  v_mag_pu_max double precision, -- Unit: per unit...
  geom geometry(Point,4326),
  project character varying,
  bus_name character varying,
  CONSTRAINT nep_bus_data_pkey PRIMARY KEY (bus_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_bus
  OWNER TO postgres;

	
INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (bus_id, geom, bus_name, project ) 
	SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), (SELECT ST_Transform(geom, 4326)), name, 'BBPlG'
	FROM 	grid2.bnetza_vorhabenpunkte_bbplg;
	
INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (bus_id, geom, bus_name, project) 
	SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), (SELECT ST_Transform(geom, 4326)), name, 'EnLAG'
	FROM 	grid2.bnetza_vorhabenpunkte_enlag;

UPDATE model_draft.ego_grid_pf_hv_extension_bus
	SET bus_name = (CASE bus_name	WHEN 'Adlkofen' THEN 'Adelkofen'
					WHEN 'Abzweig Simhar' THEN 'Simhar'
					WHEN 'Landesgrenze Bayern/Thüringen (Punkt Tschirn)' THEN 'Punkt Tschirn'
					WHEN 'Abzweig Parchim Süd' THEN 'Parchim Süd'
					WHEN 'Hamm-Uentrop' THEN 'Hamm/Uentrop'
					WHEN 'Landesgrenze BB/ST ' THEN 'Landesgrenze BB/ST'
					WHEN 'Stade West' THEN 'Stade'
					WHEN 'Landesgrenze NW/RP' THEN 'Landesgrenze RP/NW'
					WHEN 'Offshore Windpark Kriegers Flak 2 (DK)' THEN 'OWP Kriegers Flak (DK)'
					WHEN 'Offshore Windpark Baltic 2 (CGS)' THEN 'OWP Baltic 2 (Combined Grid Solution)'
					ELSE bus_name END);
	
UPDATE model_draft.ego_grid_pf_hv_extension_bus a 
	SET	v_nom = (SELECT SUBSTRING(spannung  FROM '[0-9]+'):: int)
			FROM grid2.bnetza_vorhaben_bbplg b
			WHERE ST_INTERSECTS (a.geom, (SELECT ST_BUFFER(ST_TRANSFORM(b.geom, 4326), 0.01)));
		
UPDATE model_draft.ego_grid_pf_hv_extension_bus a 
	SET	v_nom = (CASE WHEN v_nom IS NULL THEN (SELECT SUBSTRING(spannung  FROM '[0-9]+'):: int) ELSE v_nom END)
			FROM grid2.bnetza_vorhaben_enlag b
			WHERE ST_INTERSECTS (a.geom, (SELECT ST_BUFFER(ST_TRANSFORM(b.geom, 4326), 0.01)));

INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, geom, current_type, v_nom, bus_name)
VALUES	('BE_NO_NEP 2035', nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), '0101000020E6100000351DBC74686A24405536F7CC1CFC4E40', 'AC', 380, 'center NO'), --- NO
	('BE_NO_NEP 2035',nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), '0101000020E61000003851291763E8114098865E2D305B4940', 'AC', 320, 'center BE'), --- BE
	('BE_NO_eGo 100', nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), '0101000020E6100000351DBC74686A24405536F7CC1CFC4E40', 'AC', 380, 'center NO'), --- NO
	('BE_NO_eGo 100',nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), '0101000020E61000003851291763E8114098865E2D305B4940', 'AC', 320, 'center BE'), --- BE
	('extension_NEP',nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), '0101000020E610000002F13A34CAFA1C4084863976B8AD4A40', 'AC', 380, 'None'); --- 

DELETE FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'center';

UPDATE model_draft.ego_grid_pf_hv_extension_bus a 
SET scn_name = CASE WHEN bus_name IN ('Wilster', 'Grenzkorridor IV', 'Oberzier', 'Bundesgrenze (BE)') THEN 'BE_NO_NEP 2035' ELSE scn_name END;

INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, geom, current_type, v_nom, bus_name, project)
SELECT 'extension_NEP', nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'), geom, current_type, v_nom, bus_name, project FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'Wilster';

DELETE FROM model_draft.ego_grid_pf_hv_extension_bus WHERE v_nom IS NULL;


--- Create and fill table model_draft.ego_grid_pf_hv_extension_line
DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_line CASCADE;

CREATE TABLE model_draft.ego_grid_pf_hv_extension_line
(
  scn_name character varying NOT NULL DEFAULT 'extension_NEP'::character varying,
  line_id bigint NOT NULL, -- Unit: n/a...
  bus0 bigint, -- Unit: n/a...
  bus1 bigint, -- Unit: n/a...
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
  v_nom bigint, --- temp
  project character varying, --- temp
  project_id bigint, --- temp
  segment bigint, ---temp
  cable boolean DEFAULT FALSE, ---temp
 CONSTRAINT nep_line_data_pkey PRIMARY KEY (line_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_line
  OWNER TO postgres;

INSERT INTO model_draft.ego_grid_pf_hv_extension_line (line_id, geom, project, project_id, v_nom, segment, bus0, bus1, cable, length)
	SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'),
	(SELECT ST_Transform(geom, 4326)), rechtsgrundlage, vorhabennummer,
	(SELECT SUBSTRING(spannung  FROM '[0-9]+'):: int),
	(SELECT SUBSTRING(abschnitt  FROM '[0-9]+'):: int),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE a.anfangspunkt = c.bus_name AND 'BBPlG' = c.project),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE  a.endpunkt = c.bus_name AND 'BBPlG' = c.project),
	(CASE WHEN a.erdkabelpilot = 'ja' THEN TRUE ELSE FALSE END),
	(CASE WHEN a.art_der_geometrie = 'Luftlinie' THEN 1.14890133371257 * ST_Length(geom)/1000 ELSE ST_Length(geom)/1000 END)
	FROM grid2.bnetza_vorhaben_bbplg a WHERE technik = 'AC';--- AND stand_des_vorhabens != 'Vorhaben realisiert';

UPDATE model_draft.ego_grid_pf_hv_extension_line 
	SET 	bus1 = (CASE 	WHEN bus1 IS NULL THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'Conneforde') 
				WHEN project_id = 40 THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000044184DC838C2340199C783BF0CB4740') ELSE bus1 END),
		bus0 = (CASE WHEN bus0 IS NULL THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'Parchim Süd') ELSE bus0 END);
		
INSERT INTO model_draft.ego_grid_pf_hv_extension_line (line_id, geom, project, project_id, v_nom, segment, bus0, bus1, cable, length)
	SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'),
	(SELECT ST_Transform(geom, 4326)), rechtsgrundlage, vorhabennummer,
	(SELECT SUBSTRING(spannung  FROM '[0-9]+'):: int),
	(SELECT SUBSTRING(abschnitt  FROM '[0-9]+'):: int),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE a.anfangspunkt = c.bus_name AND 'EnLAG' = c.project),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE  a.endpunkt = c.bus_name AND 'EnLAG' = c.project),
	(CASE WHEN a.erdkabelpilot = 'ja' THEN TRUE ELSE FALSE END),
	(CASE WHEN a.art_der_geometrie = 'Luftlinie' THEN 1.14890133371257 * ST_Length(geom)/1000 ELSE ST_Length(geom)/1000 END)
	FROM grid2.bnetza_vorhaben_enlag a WHERE technik = 'AC'; --- AND stand_des_vorhabens != 'Vorhaben realisiert';

UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET scn_name = 'BE_NO_NEP 2035'
WHERE project = 'BBPlG' AND project_id IN (30,33);

UPDATE model_draft.ego_grid_pf_hv_extension_line 
	SET 	bus0 = (CASE	WHEN project = 'EnLAG' AND project_id = 15 AND segment = 5 THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E610000074B51EFDB6441C40CD0D1EEC4E4C4940' )
				WHEN project = 'EnLAG' AND project_id = 19 AND segment = 6 THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E61000005B50E484FEC21F4015BFC8E4906C4940') ELSE bus0 END),
		bus1 = (CASE	WHEN project = 'EnLAG' AND project_id = 15 AND segment = 4 THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E610000074B51EFDB6441C40CD0D1EEC4E4C4940' )
				WHEN project = 'EnLAG' AND project_id = 19 AND segment = 4 THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E61000005B50E484FEC21F4015BFC8E4906C4940') ELSE bus1 END);

		
UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	cables = (CASE 	WHEN (project = 'EnLAG' AND project_id IN (16,18,4,8,19,14,4,10)) OR (project = 'BBPlG' AND project_id IN (37,52,40,41,42,43,45,46,44,7,8,9,10,13,14,15,16,17,18,19,20,21,22,23,24,25,31,35,36)) THEN 3
			WHEN (project = 'EnLAG' AND project_id IN (2,3,11,5,13,1,6,2)) OR project = 'BBPlG' AND project_id IN (32, 6, 11, 12) THEN 6
			WHEN (project = 'EnLAG' AND project_id IN (15)) THEN 9
			WHEN (project = 'EnLAG' AND project_id IN (4)) OR (project = 'BBPlG' AND project_id IN (34)) THEN 12
			ELSE 3 END),
	topo = ST_MakeLine((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus0 = b.bus_id ), (SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus1 = b.bus_id ));

--insert new border-crossing-lines		
INSERT INTO model_draft.ego_grid_pf_hv_extension_line (line_id, topo,geom,  bus0, bus1, cables)
	 VALUES ( nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), '0102000020E6100000020000005A8198FA779F2140C36005117D734B409F1CB9F93CB22240346BAAA0021E4C40', ST_Multi('0102000020E6100000020000005A8198FA779F2140C36005117D734B409F1CB9F93CB22240346BAAA0021E4C40'),
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E61000005A8198FA779F2140C36005117D734B40'), 
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40' AND v_nom = 380 AND scn_name = 'NEP 2035'),
		3), 
		
		(nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), '0102000020E610000002000000CBCBCAAFFB972240C4BC5A83B4674B409F1CB9F93CB22240346BAAA0021E4C40', ST_Multi('0102000020E610000002000000CBCBCAAFFB972240C4BC5A83B4674B409F1CB9F93CB22240346BAAA0021E4C40'),
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000CBCBCAAFFB972240C4BC5A83B4674B40'), 
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40' AND v_nom = 380 AND scn_name = 'NEP 2035'),
		6),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), '0102000020E61000000200000039A7A68971BA2C40F85D3025D5954A409559C1A86322334019E697AA6FF04940', ST_Multi('0102000020E61000000200000039A7A68971BA2C40F85D3025D5954A409559C1A86322334019E697AA6FF04940'),
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E610000039A7A68971BA2C40F85D3025D5954A40'), 
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E61000009459C1A8632233401DE697AA6FF04940' AND v_nom = 380 AND scn_name = 'NEP 2035'),
		6),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), '0102000020E610000002000000BABD2DA4D1672D409F4D6995D2164A409559C1A86322334019E697AA6FF04940', ST_Multi('0102000020E610000002000000BABD2DA4D1672D409F4D6995D2164A409559C1A86322334019E697AA6FF04940'),
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000BABD2DA4D1672D409F4D6995D2164A40'), 
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E61000009459C1A8632233401DE697AA6FF04940' AND v_nom = 380 AND scn_name = 'NEP 2035'),
		3),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), '0102000020E61000000200000043504AD4C71E2A4013FABF88392248408F19DE771A512C40E166B10F27CB4740', ST_Multi('0102000020E61000000200000043504AD4C71E2A4013FABF88392248408F19DE771A512C40E166B10F27CB4740'),
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E610000043504AD4C71E2A4013FABF8839224840'), 
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E61000008219DE771A512C40E266B10F27CB4740' AND v_nom = 380 AND scn_name = 'NEP 2035'),
		12),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), '0102000020E610000002000000044184DC838C2340199C783BF0CB47408F19DE771A512C40E166B10F27CB4740', ST_Multi('0102000020E610000002000000044184DC838C2340199C783BF0CB47408F19DE771A512C40E166B10F27CB4740'),
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000044184DC838C2340199C783BF0CB4740'), 
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E61000008219DE771A512C40E266B10F27CB4740' AND v_nom = 380 AND scn_name = 'NEP 2035'),
		3),

		(nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), '0102000020E610000002000000983DE33110CC19405CB6AF40C6EE49403DFBF049275215408E5EE6B0A2154A40', ST_Multi('0102000020E610000002000000983DE33110CC19405CB6AF40C6EE49403DFBF049275215408E5EE6B0A2154A40'),
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000983DE33110CC19405CB6AF40C6EE4940'), 
		(SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E61000003CFBF04927521540885EE6B0A2154A40' AND v_nom = 380 AND scn_name = 'NEP 2035'),
		6);
		

UPDATE model_draft.ego_grid_pf_hv_extension_line a
	SET	length = (CASE WHEN length IS NULL THEN 1.14890133371257 * ST_Length(geom)/1000 ELSE length END); 
	
UPDATE model_draft.ego_grid_pf_hv_extension_line
	SET 	r = (CASE WHEN cable = FALSE AND cables != 0 THEN 0.028/(cables/3) * length WHEN cable = TRUE AND cables != 0 THEN 0.0175/(cables/3) END),
		x = (CASE WHEN cable = FALSE AND cables != 0 THEN 314.15 *0.8/(1000*cables/3) * length WHEN cable = TRUE AND cables != 0 THEN 0.3 * 0.31415 /(cables/3) END),
		s_nom = (CASE WHEN cable = FALSE AND cables != 0 THEN 1790 * (cables/3) WHEN cable = TRUE AND cables != 0 THEN 925 * (cables/3) END),
		frequency = 50;
DELETE FROM model_draft.ego_grid_pf_hv_extension_line WHERE geom IS NULL;

/*DELETE FROM model_draft.ego_grid_pf_hv_extension_line a USING model_draft.ego_grid_pf_hv_line b 
WHERE a.bus0=b.bus0 AND a.bus1 = b.bus1 AND a.geom=b.geom AND a.s_nom = b.s_nom;*/

--- Create and fill table model_draft.ego_grid_pf_hv_extension_link		
DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_link;

CREATE TABLE model_draft.ego_grid_pf_hv_extension_link
(
  scn_name character varying NOT NULL DEFAULT 'extension_NEP'::character varying,
  link_id bigint NOT NULL, -- Unit: n/a...
  bus0 bigint, -- Unit: n/a...
  bus1 bigint, -- Unit: n/a...
  efficiency double precision DEFAULT 1, -- Unit: pu
  p_nom numeric DEFAULT 0, -- Unit: MVA...
  p_nom_extendable boolean DEFAULT false, -- Unit: n/a...
  p_nom_min double precision DEFAULT 0, -- Unit: MVA...
  p_nom_max double precision, -- Unit: MVA...
  capital_cost double precision, -- Unit: currency/MVA...
  marginal_cost double precision,
  length double precision, -- Unit: km...
  terrain_factor double precision DEFAULT 1, -- Unit: per unit...
  geom geometry(MultiLineString,4326),
  topo geometry(LineString,4326),
  project text, --- temporary
  project_id bigint, --- temporary
  segment character varying, --- temporary
  v_nom bigint, --- temporary
  CONSTRAINT nep_link_data_pkey PRIMARY KEY (link_id, scn_name)
  
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_link
  OWNER TO postgres;

INSERT INTO model_draft.ego_grid_pf_hv_extension_link (scn_name, link_id, geom, project, project_id, segment, bus0, bus1) 
	SELECT 'extension_NEP',
	nextval('model_draft.ego_grid_hv_electrical_neighbours_link_id'),
	(SELECT ST_Transform(geom, 4326)),
	rechtsgrundlage,
	vorhabennummer,
	abschnitt, 	
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE a.anfangspunkt = c.bus_name AND 'BBPlG' = c.project AND c.scn_name = 'extension_NEP'),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE  a.endpunkt = c.bus_name AND c.scn_name = 'extension_NEP')
	FROM grid2.bnetza_vorhaben_bbplg a WHERE technik = 'DC' AND vorhabennummer NOT IN (30,33);

INSERT INTO model_draft.ego_grid_pf_hv_extension_link (scn_name, link_id, geom, project, project_id, segment, bus0, bus1) 
	SELECT 'BE_NO_NEP 2035', nextval('model_draft.ego_grid_hv_electrical_neighbours_link_id'),
	(SELECT ST_Transform(geom, 4326)),
	rechtsgrundlage,
	vorhabennummer,
	abschnitt,
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE a.anfangspunkt = c.bus_name AND 'BBPlG' = c.project AND c.scn_name = 'BE_NO_NEP 2035'),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE  a.endpunkt = c.bus_name AND c.scn_name = 'BE_NO_NEP 2035')
	FROM grid2.bnetza_vorhaben_bbplg a WHERE technik = 'DC' AND vorhabennummer IN (30,33);

DELETE FROM model_draft.ego_grid_pf_hv_extension_link WHERE segment = '2';

---- Insert border crossing links	
INSERT INTO model_draft.ego_grid_pf_hv_extension_link  (scn_name, link_id, bus0, bus1, geom, length, p_nom)
VALUES 	('BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_electrical_neighbours_link_id'),
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE b.bus_name = 'Grenzkorridor IV' AND b.scn_name = 'BE_NO_NEP 2035'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000351DBC74686A24405536F7CC1CFC4E40' AND scn_name = 'BE_NO_NEP 2035'),
	ST_Multi('0102000020E610000002000000301DBC74686A24405036F7CC1CFC4E40051BA7078E0B204041ACB82EE7304B40'),
	854.705317609461,
	1400),

	('BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_electrical_neighbours_link_id'),
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'Bundesgrenze (BE)' AND scn_name = 'BE_NO_NEP 2035'),
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE b.geom = '0101000020E61000003851291763E8114098865E2D305B4940' AND scn_name = 'BE_NO_NEP 2035'),
	ST_Multi('0102000020E610000002000000B61FABB9DE7B1840B13DB1ABC95B49403D51291763E8114096865E2D305B4940'),
	116.11179815711,
	1000);

UPDATE model_draft.ego_grid_pf_hv_extension_link a
	SET 	length =  1.15 * ST_Length(ST_GeographyFromText(ST_AsEWKT(geom)))/1000,
		p_nom = (CASE 	WHEN project_id IN (1,2,3,4,5) THEN 2000
				WHEN project_id = 30 THEN 1000
				WHEN project_id = 33 THEN 1400
				WHEN project_id = 29 THEN 400
				ELSE 2000 END),
		v_nom = (SELECT v_nom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus1 = b.bus_id),
		topo = (SELECT ST_MakeLine ((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id = a.bus0), (SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id = a.bus1) ));

UPDATE model_draft.ego_grid_pf_hv_extension_link a
	SET 	efficiency = 0.987*0.974^(length/1000),
		marginal_cost = 0;

INSERT INTO model_draft.ego_grid_pf_hv_extension_link (link_id, geom, project, project_id, segment, p_nom, bus0, bus1, scn_name, length, v_nom, efficiency, topo)
	SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_link_id'), geom, project, project_id, segment, p_nom, bus1, bus0, scn_name, length,  v_nom, efficiency, topo FROM model_draft.ego_grid_pf_hv_extension_link;


-- Table: model_draft.ego_grid_pf_hv_extension_trafo

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_trafo CASCADE;

CREATE TABLE model_draft.ego_grid_pf_hv_extension_trafo
(
  scn_name character varying NOT NULL DEFAULT 'extension_NEP'::character varying,
  trafo_id bigint NOT NULL,
  bus0 bigint,
  bus1 bigint,
  x numeric DEFAULT 0,
  r numeric DEFAULT 0,
  g numeric DEFAULT 0,
  b numeric DEFAULT 0,
  s_nom double precision DEFAULT 0,
  s_nom_extendable boolean DEFAULT false,
  s_nom_min double precision DEFAULT 0,
  s_nom_max double precision,
  tap_ratio double precision,
  phase_shift double precision,
  capital_cost double precision DEFAULT 0,
  geom geometry(MultiLineString,4326),
  topo geometry(LineString,4326),
  v0 double precision DEFAULT 0, --- temp
  v1 double precision DEFAULT 0, --- temp
  s0 double precision DEFAULT 0, --- temp
  s1 double precision DEFAULT 0, --- temp
  s_min double precision DEFAULT 0, --- temp
  CONSTRAINT nep_transformer_pkey PRIMARY KEY (trafo_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_trafo
  OWNER TO postgres;

INSERT INTO model_draft.ego_grid_pf_hv_extension_trafo (trafo_id, tap_ratio, phase_shift, bus0, v0)
SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'), 1, 0, bus0, v_nom  FROM model_draft.ego_grid_pf_hv_extension_line
	WHERE bus0 NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_line WHERE scn_name != 'decommissioning_NEP' );
		
INSERT INTO model_draft.ego_grid_pf_hv_extension_trafo (trafo_id, tap_ratio, phase_shift, bus0, v0)
SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'), 1, 0, bus1, v_nom  FROM model_draft.ego_grid_pf_hv_extension_line
	WHERE  bus1 NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_line WHERE scn_name != 'decommissioning_NEP' );

UPDATE model_draft.ego_grid_pf_hv_extension_trafo a
SET 	s0 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_pf_hv_extension_line b WHERE a.bus0 = b.bus1 OR a.bus0 = b.bus0);

INSERT INTO model_draft.ego_grid_pf_hv_extension_trafo (trafo_id, tap_ratio, phase_shift, scn_name, bus0, v0)
SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'), 1, 0, scn_name, bus0, v_nom FROM model_draft.ego_grid_pf_hv_extension_link WHERE bus0 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus
 WHERE bus_name IN ('center BE', 'center NO'));

UPDATE model_draft.ego_grid_pf_hv_extension_trafo a
SET 	s0 = (CASE WHEN s0 = 0 THEN (SELECT SUM(b.p_nom) FROM model_draft.ego_grid_pf_hv_extension_link b WHERE a.bus0 = b.bus1 OR a.bus0 = b.bus0) ELSE s0 END);
	
UPDATE model_draft.ego_grid_pf_hv_extension_trafo a
SET 	bus1 = (CASE WHEN bus1 IS NULL THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus c WHERE c.scn_name = 'NEP 2035' ORDER BY ST_Distance((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id = a.bus0 ), c.geom) LIMIT 1) ELSE bus1 END);
	
UPDATE model_draft.ego_grid_pf_hv_extension_trafo a
SET 	v1 = (CASE WHEN v1 IS NULL THEN (SELECT v_nom FROM model_draft.ego_grid_pf_hv_bus b WHERE a.bus1 = b.bus_id AND b.scn_name = 'NEP 2035') ELSE v1 END),
	topo = (SELECT ST_MakeLine((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id = bus0), (SELECT geom FROM model_draft.ego_grid_pf_hv_bus WHERE bus_id = bus1 AND scn_name = 'NEP 2035')));

UPDATE model_draft.ego_grid_pf_hv_extension_trafo a
SET	geom = ST_Multi(a.topo),
	s1 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_pf_hv_line b WHERE a.bus1 = b.bus0 OR a.bus1 = b.bus1);

UPDATE model_draft.ego_grid_pf_hv_extension_trafo 
SET 	s_min = (CASE 	WHEN s0 < s1 	THEN s0
			WHEN s1 <= s0 	THEN s1
			WHEN s1 IS NULL THEN s0
			WHEN s0 IS NULL THEN s1 END);

			
UPDATE model_draft.ego_grid_pf_hv_extension_trafo 
SET 	s_nom = (CASE 	WHEN s_min <= 600  THEN 600
			WHEN s_min > 600  AND s_min <= 1200 THEN 1200
			WHEN s_min > 1200 AND s_min <= 1600 THEN 1600
			WHEN s_min > 1600 AND s_min <= 2100 THEN 2100
			WHEN s_min > 2100 AND s_min <= 2600 THEN 2600
			WHEN s_min > 2600 AND s_min <= 4800 THEN 4800
			WHEN s_min > 4800 AND s_min <= 6000 THEN 6000
			WHEN s_min > 6000 AND s_min <= 7200 THEN 7200
			WHEN s_min > 7200 AND s_min <= 8000 THEN 8000
			WHEN s_min > 8000 AND s_min <= 9000 THEN 9000
			WHEN s_min > 9000 AND s_min <= 10800 THEN 10800
			WHEN s_min > 10800 --AND s_min <= 12000
			 THEN 12000
			END);

UPDATE model_draft.ego_grid_pf_hv_extension_trafo 
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
			WHEN 10800 THEN 0.00002
			WHEN 12000 THEN 0.00002
			END),
	tap_ratio = 1,
	phase_shift = 0;
			
				
--- Change all transformers with v0=v1 to lines

INSERT INTO model_draft.ego_grid_pf_hv_extension_line (line_id, bus0, bus1, geom, topo, v_nom, length, s_nom)
SELECT  nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), bus0, bus1, geom, topo, v0, ST_Length(ST_GeographyFromText(ST_AsEWKT(geom)))/1000, s_min  FROM model_draft.ego_grid_pf_hv_extension_trafo WHERE v0 = v1;

UPDATE model_draft.ego_grid_pf_hv_extension_line 
SET cable = (CASE WHEN x = 0 AND s_nom IN (925, 1850, 2775, 3750) THEN TRUE ELSE cable END);

UPDATE model_draft.ego_grid_pf_hv_extension_line 
SET	cables = (CASE 	WHEN cables IS NULL AND scn_name IN ('extension_NEP', 'BE_NO_NEP 2035') AND cable = TRUE THEN s_nom/925*3 
			WHEN cables IS NULL AND scn_name IN ('extension_NEP', 'BE_NO_NEP 2035') AND cable = FALSE THEN s_nom/1790*3 
			ELSE cables END);
			 
UPDATE model_draft.ego_grid_pf_hv_extension_line 
SET	x = (CASE WHEN x = 0 AND cables != 0 THEN (CASE WHEN cable = FALSE AND cables!= 0 THEN 314.15 *0.8/(1000*cables/3) * length ELSE 0.3 * 0.31415 /(cables/3) END) ELSE x END),
	frequency = 50;

DELETE FROM model_draft.ego_grid_pf_hv_extension_trafo WHERE geom IN (SELECT geom FROM model_draft.ego_grid_pf_hv_extension_line);


-- Table: model_draft.ego_grid_pf_hv_extension_load

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_load CASCADE;

CREATE TABLE model_draft.ego_grid_pf_hv_extension_load
(
  scn_name character varying NOT NULL DEFAULT 'BE and NO'::character varying,
  load_id bigint NOT NULL,
  bus bigint,
  sign double precision DEFAULT (-1),
  e_annual double precision,
  CONSTRAINT ext_load_data_pkey PRIMARY KEY (load_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_load
  OWNER TO postgres;

INSERT INTO model_draft.ego_grid_pf_hv_extension_load (scn_name, load_id, bus, sign)

VALUES 	('BE_NO_NEP 2035', 1000000, (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E61000003851291763E8114098865E2D305B4940' AND scn_name = 'BE_NO_NEP 2035'), '-1'),
	('BE_NO_NEP 2035', 1000001, (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000351DBC74686A24405536F7CC1CFC4E40' AND scn_name = 'BE_NO_NEP 2035'), '-1');
	

-- Table: model_draft.ego_grid_pf_hv_extension_load_pq_set

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_load_pq_set CASCADE;

CREATE TABLE model_draft.ego_grid_pf_hv_extension_load_pq_set
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  load_id bigint NOT NULL,
  temp_id integer NOT NULL,
  p_set double precision[],
  q_set double precision[],
  CONSTRAINT extension_load_pq_set_pkey PRIMARY KEY (load_id, temp_id, scn_name),
  CONSTRAINT extension_load_pq_set_temp_fkey FOREIGN KEY (temp_id)
      REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_load_pq_set
  OWNER TO postgres;
  
INSERT INTO model_draft.ego_grid_pf_hv_extension_load_pq_set (scn_name, load_id, temp_id, p_set)

 VALUES('BE_NO_NEP 2035' , 1000000 , 1, (SELECT (array_agg (SQ.load_be ORDER BY SQ.timestamp))	
	FROM model_draft.opsd_hourly_timeseries SQ
	WHERE timestamp BETWEEN '2010-12-31 23:00:00' AND '2011-12-31 23:00:00'
	 )),

	('BE_NO_NEP 2035' , 1000001 , 1,(SELECT (array_agg (SQ.load_no ORDER BY SQ.timestamp))	
	FROM model_draft.opsd_hourly_timeseries SQ
	WHERE timestamp BETWEEN '2010-12-31 23:00:00' AND '2011-12-31 23:00:00'
	 ));


-- Table: model_draft.ego_grid_pf_hv_extension_generator

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_generator CASCADE;

CREATE TABLE model_draft.ego_grid_pf_hv_extension_generator
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  generator_id bigint NOT NULL,
  bus bigint,
  dispatch text DEFAULT 'flexible'::text,
  control text DEFAULT 'PQ'::text,
  p_nom double precision DEFAULT 0,
  p_nom_extendable boolean DEFAULT false,
  p_nom_min double precision DEFAULT 0,
  p_nom_max double precision,
  p_min_pu_fixed double precision DEFAULT 0,
  p_max_pu_fixed double precision DEFAULT 1,
  sign double precision DEFAULT 1,
  source bigint,
  marginal_cost double precision,
  capital_cost double precision,
  efficiency double precision,
  CONSTRAINT generator_data_source_fkey FOREIGN KEY (source)
      REFERENCES model_draft.ego_grid_pf_hv_source (source_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_generator
  OWNER TO postgres;

-- INSERT params of LinearTransformers in model_draft.ego_grid_pf_hv_generator (countries besides Germany)
-- starting generator_id at 200000, bus_id for neighbouring countries > 2800000 atm
-- BE_NO_NEP 2035
INSERT into model_draft.ego_grid_pf_hv_extension_generator

	SELECT
	'BE_NO_NEP 2035' AS scn_name,
	row_number() over () + 210000 AS generator_id,
	B.bus_id AS bus,
	'flexible' AS dispatch,
	'PV' AS control,
	nominal_value[1] AS p_nom,
	FALSE AS p_nom_extendable,
	NULL AS p_nom_max,
	0 AS p_nom_min,
	0 AS p_min_pu_fixed,
	1 AS p_max_pu_fixed,
	1 AS sign,
	CASE
		WHEN source LIKE '%%gas%%' THEN 1
		when source LIKE '%%lignite%%' THEN 2
		when source LIKE '%%mixed_fuels%%' THEN 3
		when source LIKE '%%oil%%' THEN 4
		when source LIKE '%%uranium%%' THEN 5
		when source LIKE '%%biomass%%' THEN 6
		when source LIKE '%%hard_coal%%' THEN 8
	END AS source
		FROM calc_renpass_gis.renpass_gis_linear_transformer A join
		(
		SELECT
		*
		FROM
			(SELECT *
			
			FROM
			model_draft.ego_grid_pf_hv_extension_bus
			where bus_name = 'center BE'
			AND scn_name = 'BE_NO_NEP 2035'
			) SQ
		
		) B
		ON (substring(A.source, 1, 2) = 'BE')
	WHERE A.nominal_value IS not NULL
	AND A.nominal_value[1] > 0.001
	AND A.source not LIKE '%%powerline%%'
	AND A.scenario_id = 44;


-- INSERT params of Source in model_draft.ego_grid_pf_hv_generator (BE and NO)
-- BE_NO_NEP 2035
INSERT into model_draft.ego_grid_pf_hv_extension_generator

	SELECT
	'BE_NO_NEP 2035' AS scn_name,
	row_number() over () + (SELECT max(generator_id) FROM model_draft.ego_grid_pf_hv_generator) AS generator_id,
	B.bus_id AS bus,
	'variable' AS dispatch,
	'PV' AS control,
	nominal_value[1] AS p_nom,
	FALSE AS p_nom_extendable,
	NULL AS p_nom_max,
	0 AS p_nom_min,
	0 AS p_min_pu_fixed,
	1 AS p_max_pu_fixed,
	1 AS sign,
	CASE
		WHEN source LIKE '%%run_of_river%%' THEN 9
		WHEN source LIKE '%%solar%%' THEN 12
		WHEN source LIKE '%%wind%%' THEN 13
        END AS source
		FROM calc_renpass_gis.renpass_gis_source A join
		(
		SELECT
		*
		FROM
			(SELECT *
			FROM
			model_draft.ego_grid_pf_hv_extension_bus
			where bus_name = 'center BE' 
			AND scn_name = 'BE_NO_NEP 2035'
			) SQ
			) B
		ON (substring(A.source, 1, 2) = 'BE')
	WHERE A.nominal_value[1] > 0.001
	AND A.scenario_id = 44;


	INSERT into model_draft.ego_grid_pf_hv_extension_generator

	SELECT
	'BE_NO_NEP 2035' AS scn_name,
	row_number() over () + 220000 AS generator_id,
	B.bus_id AS bus,
	'flexible' AS dispatch,
	'PV' AS control,
	nominal_value[1] AS p_nom,
	FALSE AS p_nom_extendable,
	NULL AS p_nom_max,
	0 AS p_nom_min,
	0 AS p_min_pu_fixed,
	1 AS p_max_pu_fixed,
	1 AS sign,
	CASE
		WHEN source LIKE '%%gas%%' THEN 1
		when source LIKE '%%lignite%%' THEN 2
		when source LIKE '%%mixed_fuels%%' THEN 3
		when source LIKE '%%oil%%' THEN 4
		when source LIKE '%%uranium%%' THEN 5
		when source LIKE '%%biomass%%' THEN 6
		when source LIKE '%%hard_coal%%' THEN 8
	END AS source
		FROM calc_renpass_gis.renpass_gis_linear_transformer A join
		(
		SELECT
		*
		FROM
			(SELECT *
			
			FROM
			model_draft.ego_grid_pf_hv_extension_bus
			where bus_name = 'center NO'
			AND scn_name = 'BE_NO_NEP 2035'
			) SQ
		
		) B
		ON (substring(A.source, 1, 2) = 'NO')
	WHERE A.nominal_value IS not NULL
	AND A.nominal_value[1] > 0.001
	AND A.source not LIKE '%%powerline%%'
	AND A.scenario_id = 44;


-- INSERT params of Source in model_draft.ego_grid_pf_hv_generator (BE and NO)
-- BE_NO_NEP 2035
INSERT into model_draft.ego_grid_pf_hv_extension_generator

	SELECT
	'BE_NO_NEP 2035' AS scn_name,
	row_number() over () + (SELECT max(generator_id) FROM model_draft.ego_grid_pf_hv_extension_generator) AS generator_id,
	B.bus_id AS bus,
	'variable' AS dispatch,
	'PV' AS control,
	nominal_value[1] AS p_nom,
	FALSE AS p_nom_extendable,
	NULL AS p_nom_max,
	0 AS p_nom_min,
	0 AS p_min_pu_fixed,
	1 AS p_max_pu_fixed,
	1 AS sign,
	CASE
		WHEN source LIKE '%%run_of_river%%' THEN 9
		WHEN source LIKE '%%solar%%' THEN 12
		WHEN source LIKE '%%wind%%' THEN 13
        END AS source
		FROM calc_renpass_gis.renpass_gis_source A join
		(
		SELECT
		*
		FROM
			(SELECT *
			FROM
			model_draft.ego_grid_pf_hv_extension_bus
			where bus_name = 'center NO' 
			AND scn_name = 'BE_NO_NEP 2035'
			) SQ
			) B
		ON (substring(A.source, 1, 2) = 'NO')
	WHERE A.nominal_value[1] > 0.001
	AND A.scenario_id = 44;

UPDATE model_draft.ego_grid_pf_hv_extension_generator 
SET p_nom_min = 0,
p_nom_max = NULL;

-- Copy timeseries data
-- Table: model_draft.ego_grid_pf_hv_extension_generator_pq_set

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_generator_pq_set CASCADE;

CREATE TABLE model_draft.ego_grid_pf_hv_extension_generator_pq_set
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  generator_id bigint NOT NULL,
  temp_id integer NOT NULL,
  p_set double precision[],
  q_set double precision[],
  p_min_pu double precision[],
  p_max_pu double precision[],
  CONSTRAINT generator_pq_set_temp_fkey FOREIGN KEY (temp_id)
      REFERENCES model_draft.ego_grid_pf_hv_temp_resolution (temp_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_generator_pq_set
  OWNER TO postgres;

-- BE_NO_NEP 2035
Drop MATERIALIZED VIEW IF EXISTS calc_renpass_gis.extension_translate_to_pf;

CREATE MATERIALIZED VIEW calc_renpass_gis.extension_translate_to_pf AS
	SELECT
	SQ.generator_id,
	C.datetime,
	C.val
	FROM
		(SELECT *,
		CASE
			WHEN A.source =  1  THEN  'gas'
			WHEN A.source =  2  THEN  'lignite'
			WHEN A.source =  3  THEN  'mixed_fuels'
			WHEN A.source =  4  THEN  'oil'
			WHEN A.source =  5  THEN  'uranium'
			WHEN A.source =  6  THEN  'biomass'
			WHEN A.source =  8  THEN  'hard_coal'
			WHEN A.source =  9  THEN  'run_of_river'
			WHEN A.source =  12 THEN  'solar'
			WHEN A.source =  13 THEN  'wind'
		END AS renpass_gis_source
			FROM model_draft.ego_grid_pf_hv_extension_generator A join
			model_draft.ego_grid_pf_hv_extension_bus B
			ON (A.bus = B.bus_id)
		WHERE A.generator_id > 210000
		AND A.scn_name = 'BE_NO_NEP 2035'
		) SQ,
		calc_renpass_gis.renpass_gis_results C
	WHERE
	(C.obj_label LIKE '%%' || SQ.renpass_gis_source || '%%')
	AND C.scenario_id = 44
	AND C.type = 'to_bus';

-- Make an array, INSERT into generator_pq_set
INSERT into model_draft.ego_grid_pf_hv_extension_generator_pq_set (scn_name, generator_id, temp_id, p_set)

	SELECT 'BE_NO_NEP 2035' AS scn_name,
	SQ.generator_id,
	1 AS temp_id,
	array_agg(SQ.val ORDER BY SQ.datetime) AS p_set
		FROM
		(
		SELECT
		A.generator_id,
		A.datetime,
		A.val AS val
			FROM calc_renpass_gis.extension_translate_to_pf A join
			model_draft.ego_grid_pf_hv_extension_generator B
			USING (generator_id)
		) SQ
	GROUP BY generator_id;


UPDATE model_draft.ego_grid_pf_hv_extension_generator
SET marginal_cost =        -- operating costs + fuel costs + CO2 crt cost
(
CASE source                 -- source / renpass_gis NEP 2014
when 1 THEN (39.9344 + 2.0) -- gas / gas
when 2 THEN (13.2412 + 4.4)  -- lignite / lignite
when 3 THEN (16.9297 + 23.0) -- waste / waste
when 4 THEN (67.3643 + 1.5) -- oil / oil
when 5 THEN (4.9781 + 0.5)  -- uranium / uranium
when 6 THEN (27.5112 + 3.9) -- biomass / biomass
when 7 THEN (39.9344 + 2.0) -- eeg_gas / gas
when 8 THEN (20.7914 + 4.0) -- coal / hard_coal
ELSE 0                      -- run_of_river/reservoir/pumped_storage/solar/wind/geothermal/other_non_renewable
END)
WHERE scn_name = 'BE_NO_NEP 2035';

UPDATE model_draft.ego_grid_pf_hv_extension_generator_pq_set Y
SET p_max_pu = T3.p_max_pu
FROM (
	SELECT T2.generator_id, array_agg(T2.p_max_pu ORDER BY rn) as p_max_pu
	FROM (
		SELECT T1.*, row_number() over() AS rn -- row number introduced to keep array order
		FROM (
			SELECT
			B.generator_id,
			A.p_nom ,
			unnest(B.p_set) / A.p_nom AS p_max_pu
			FROM model_draft.ego_grid_pf_hv_extension_generator A
			JOIN model_draft.ego_grid_pf_hv_extension_generator_pq_set B USING (generator_id)
			WHERE A.dispatch = 'variable'
		) AS T1
	) AS T2
GROUP BY T2.generator_id
) T3 WHERE T3.generator_id = Y.generator_id;


DELETE FROM model_draft.ego_grid_pf_hv_extension_line WHERE scn_name = 'decommissioning_NEP';

INSERT INTO model_draft.ego_grid_pf_hv_extension_line (scn_name, line_id, geom, v_nom, bus0, bus1)
SELECT 'decommissioning_NEP', line_id, geom, 110, bus0, bus1 FROM model_draft.ego_grid_pf_hv_line
WHERE scn_name = 'NEP 2035' AND s_nom = 260 AND topo IN (
'0102000020E61000000200000034491737E0272240077FDE21ED414B401C09D91E62FC21405F82AED8BA4C4B40',
'0102000020E61000000200000017CA504549312240342D73AE813C4B4034491737E0272240077FDE21ED414B40',
'0102000020E610000002000000A7EE25E88A4D22401313D4F02D214B407A84E4AE6F392240155D7237E32F4B40',
'0102000020E6100000020000001954FC7A67EC2140F817BC009A564B403D85B762DAFE21408E4DE1F725524B40',
'0102000020E610000002000000E9482465B4B821400F0985DA6C654B401954FC7A67EC2140F817BC009A564B40',
'0102000020E6100000020000007A84E4AE6F392240155D7237E32F4B4017CA504549312240342D73AE813C4B40',
'0102000020E6100000020000003D85B762DAFE21408E4DE1F725524B4029CDE67118FC21404F779E78CE4C4B40',
'0102000020E610000002000000564589B8733922401DE884E04BFA4A404AE93EA5EF3A224038E5C06158FA4A40',
'0102000020E610000002000000564589B8733922401DE884E04BFA4A404AE93EA5EF3A224038E5C06158FA4A40',
'0102000020E61000000200000086123F927D202240BBB93B0FBB0A4B40010AE4C8B91F2240D8BF46EDD90A4B40',
'0102000020E61000000200000086123F927D202240BBB93B0FBB0A4B40010AE4C8B91F2240D8BF46EDD90A4B40'

);

INSERT INTO model_draft.ego_grid_pf_hv_extension_line (scn_name, line_id, geom, v_nom, bus0, bus1)
SELECT 'decommissioning_NEP', line_id, geom, 220, bus0, bus1 FROM model_draft.ego_grid_pf_hv_line
WHERE scn_name = 'NEP 2035' AND s_nom = 520 AND topo IN (
'0102000020E610000002000000076BF706BAF52A401C1252126D504A40B32781CD39042B40549F9A81804F4A40',
'0102000020E610000002000000D68ADB0D47E42940919F8D5C37484A4062C32EE5D76A2A404F475BF0FD564A40',
'0102000020E61000000200000015AA40D24C6C2A401BCE46F828574A40DF14FB7035872A4039883144A9594A40',
'0102000020E610000002000000B32781CD39042B40549F9A81804F4A407771C1D4596B2B40B98A9B0218454A40',
'0102000020E6100000020000008D2AC3B81B942A4061F3BBFAC2594A40076BF706BAF52A401C1252126D504A40',
'0102000020E610000002000000DF14FB7035872A4039883144A9594A408D2AC3B81B942A4061F3BBFAC2594A40',
'0102000020E61000000200000012EEDF06C6EB2B406713BB1171A04A405D8DEC4ACB102C4036B39602D2C04A40',
'0102000020E6100000020000005414F93FD10E2140935A28999CED484061BBC50D09312140B4999E0B7EF94840',
'0102000020E610000002000000E1D80EA1A58E2140DD572FD0FFFB4840BDF20F11ED5D21400F1DF11AAAF84840',
'0102000020E61000000200000061BBC50D09312140B4999E0B7EF948401DE90C8CBC582140ED63AA059BF84840',
'0102000020E610000002000000FC51D890878022403562D7B7A58E4A40E318C91EA14622401DEA77616B6C4A40',
'0102000020E610000002000000E318C91EA14622401DEA77616B6C4A409DA223B9FC372240E964A9F57E454A40',
'0102000020E6100000020000007657D17A53B42740AFEBBC32148C4A40795FF0C4075D2840126A865451E84A40',
'0102000020E610000002000000E6E37F97BE4427400D40FE2D5C224A40E59F747D7AC327409EB0694A578A4A40',
'0102000020E61000000200000032E884D041E71C40E37B35F6DBAC4A40DECCE847C31920408A58C4B0C3AA4A40',
'0102000020E6100000020000003014B01D8C2820408ACF9D60FF6D4A402B2BF290CE19204048AAEFFCA2AA4A40',
'0102000020E6100000020000000E6C9560714823400A151C5E102D4B40BA6B09F9A0072340F14C689258304B40',
'0102000020E6100000020000004AA4236F6F752340126C5CFFAE254B400E6C9560714823400A151C5E102D4B40',
'0102000020E610000002000000BA6B09F9A0072340F14C689258304B409FACBDF49BA2224083B5204A6A5B4B40',
'0102000020E6100000020000005B3DCC03FDFA2340EC34D25279E24A4069458AB7841224400992D2C7D7E64A40',
'0102000020E61000000200000069458AB7841224400992D2C7D7E64A40706C2C17E0452540DFCFDF3AB5F54A40',
'0102000020E610000002000000076BF706BAF52A401C1252126D504A40B32781CD39042B40549F9A81804F4A40',
'0102000020E6100000020000004AE93EA5EF3A224038E5C06158FA4A401FCC37EC08592240E12E562F1AF54A40',
'0102000020E6100000020000004B1A48BCE1332240139D6516A1FD4A404AE93EA5EF3A224038E5C06158FA4A40',
'0102000020E6100000020000006000868A162D2240C7AEA3607C004B404B1A48BCE1332240139D6516A1FD4A40',
'0102000020E61000000200000030CE29125D152240AFC623021F0B4B406000868A162D2240C7AEA3607C004B40',
'0102000020E610000002000000EB1AD24D071B22408A624DC00A154B4030CE29125D152240AFC623021F0B4B40',
'0102000020E61000000200000061862E3E62C523409CDBB9E8EB264840730C6DA57C812340EFD34C52F4D24740',
'0102000020E610000002000000D00F4E47BD642240209E89FCDB744840AA3AE6B2C6D922403AF0978F3F084840',
'0102000020E6100000020000003A84E0A7606F22400880E0E0C1014B406000868A162D2240C7AEA3607C004B40',
'0102000020E61000000200000030CE29125D152240AFC623021F0B4B40010AE4C8B91F2240D8BF46EDD90A4B40'
);

INSERT INTO model_draft.ego_grid_pf_hv_extension_line (scn_name, line_id, geom, v_nom, bus0, bus1)
SELECT 'decommissioning_NEP', line_id, geom, 220, bus0, bus1 FROM model_draft.ego_grid_pf_hv_line
WHERE scn_name = 'NEP 2035' AND s_nom = 1040 AND topo IN (
'0102000020E6100000020000007E025765387423408D1F37484D254B4054D1B3B4AEF82340A26C25CF50E24A40',
'0102000020E6100000020000001FCC37EC08592240E12E562F1AF54A405FE68585A460224085BB0E304EF44A40',
'0102000020E61000000200000051AAD8F3908022404323D8B8FE8E4A4030890EDCDCFF2240FD2E1114E4C54A40',
'0102000020E6100000020000001438FC94EA0023401A05EEF07AC54A404E3338A517142340F0CE90E0FCC74A40'
);


INSERT INTO model_draft.ego_grid_pf_hv_extension_line (scn_name, line_id, geom, s_nom, v_nom , bus0, bus1)
SELECT 'decommissioning_NEP', line_id, geom, s_nom, 380, bus0, bus1 FROM model_draft.ego_grid_pf_hv_line
WHERE scn_name = 'NEP 2035' AND s_nom = 1790 AND topo IN (
'0102000020E610000002000000E958EF8167402640E435AFEAAC7F49402459D130C6952840550B36BFAB954940',
'0102000020E6100000020000002279420AF917284002767F06E56549409F63F668601A284007E28629DB644940',
'0102000020E610000002000000E53FEE6CD91728409FFA511E27664940909F32A3C49F2940B8D507ED306E4940',
'0102000020E610000002000000E53FEE6CD91728409FFA511E276649402279420AF917284002767F06E5654940',
'0102000020E610000002000000FFBD2A26F24A2740D0D751D97644494084369435454F27400BC50C439A444940',
'0102000020E61000000200000084369435454F27400BC50C439A44494096BABFD595162840C3082B5FE1654940',
'0102000020E6100000020000002459D130C6952840550B36BFAB95494053D0ED258DA128406FA296E656984940',
'0102000020E6100000020000002279420AF917284002767F06E565494096BABFD595162840C3082B5FE1654940',
'0102000020E61000000200000096BABFD595162840C3082B5FE1654940E53FEE6CD91728409FFA511E27664940'

) ;

DELETE FROM model_draft.ego_grid_pf_hv_extension_line a USING model_draft.ego_grid_pf_hv_extension_line b
 WHERE a.scn_name = 'decommissioning_NEP' AND a.topo = '0102000020E610000002000000E958EF8167402640E435AFEAAC7F49402459D130C6952840550B36BFAB954940'
AND a.s_nom = 1790 AND a.line_id < b.line_id;

UPDATE model_draft.ego_grid_pf_hv_extension_line a 
SET v_nom = (CASE WHEN scn_name = 'decommissioning_NEP' THEN (SELECT v_nom FROM model_draft.ego_grid_pf_hv_bus b WHERE a.bus1 = b.bus_id AND b.scn_name = 'NEP 2035')  ELSE v_nom END);

-- Insert stublines to deleted lines
INSERT INTO model_draft.ego_grid_pf_hv_extension_trafo (trafo_id, bus1, v1)
	(SELECT nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),  bus_id, b.v_nom FROM model_draft.ego_grid_pf_hv_bus b, model_draft.ego_grid_pf_hv_extension_line c  
	WHERE c.scn_name = 'decommissioning_NEP' AND ST_Touches(b.geom, c.geom) AND c.v_nom = b.v_nom AND b.scn_name = 'NEP 2035');

DELETE FROM model_draft.ego_grid_pf_hv_extension_trafo a USING model_draft.ego_grid_pf_hv_extension_trafo b
WHERE a.bus1 = b.bus1 AND a.trafo_id > b.trafo_id AND a.v1=b.v1 AND a.v0 = b.v0 AND a.x = 0 AND a.scn_name = 'extension_NEP';


UPDATE model_draft.ego_grid_pf_hv_extension_trafo a 
	SET	bus0 = (CASE WHEN bus0 IS NULL THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus c ORDER BY ST_Distance((SELECT geom FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND bus_id = a.bus1 ), c.geom) LIMIT 1)
		ELSE bus0 END),
		v0 = (CASE WHEN v0 = 0 THEN (SELECT v_nom FROM model_draft.ego_grid_pf_hv_extension_bus c ORDER BY ST_Distance((SELECT geom FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND bus_id = a.bus1 ), c.geom) LIMIT 1)
		ELSE v0 END);
---

UPDATE model_draft.ego_grid_pf_hv_extension_trafo a
SET 	s0 = (CASE WHEN s0 = 0 THEN (SELECT SUM(b.p_nom) FROM model_draft.ego_grid_pf_hv_extension_link b WHERE a.bus0 = b.bus1 OR a.bus0 = b.bus0) ELSE s0 END);
	
--DELETE FROM model_draft.ego_grid_pf_hv_extension_trafo WHERE v0 IS NULL; 

UPDATE model_draft.ego_grid_pf_hv_extension_trafo a
SET 	bus1 = (CASE WHEN bus1 IS NULL THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus c WHERE c.scn_name = 'NEP 2035' ORDER BY ST_Distance((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id = a.bus0 ), c.geom) LIMIT 1) ELSE bus1 END);
	
UPDATE model_draft.ego_grid_pf_hv_extension_trafo a
SET 	v1 = (CASE WHEN v1 IS NULL THEN (SELECT v_nom FROM model_draft.ego_grid_pf_hv_bus b WHERE a.bus1 = b.bus_id AND b.scn_name = 'NEP 2035') ELSE v1 END),
	topo = (SELECT ST_MakeLine((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id = bus0), (SELECT geom FROM model_draft.ego_grid_pf_hv_bus WHERE bus_id = bus1 AND scn_name = 'NEP 2035')));

UPDATE model_draft.ego_grid_pf_hv_extension_trafo a
SET	geom = ST_Multi(a.topo),
	s1 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_pf_hv_line b WHERE a.bus1 = b.bus0 OR a.bus1 = b.bus1);

UPDATE model_draft.ego_grid_pf_hv_extension_trafo 
SET 	s_min = (CASE 	WHEN s0 < s1 	THEN s0
			WHEN s1 <= s0 	THEN s1
			WHEN s1 IS NULL THEN s0
			WHEN s0 IS NULL THEN s1 END);

			
UPDATE model_draft.ego_grid_pf_hv_extension_trafo 
SET 	s_nom = (CASE 	WHEN s_min <= 600  THEN 600
			WHEN s_min > 600  AND s_min <= 1200 THEN 1200
			WHEN s_min > 1200 AND s_min <= 1600 THEN 1600
			WHEN s_min > 1600 AND s_min <= 2100 THEN 2100
			WHEN s_min > 2100 AND s_min <= 2600 THEN 2600
			WHEN s_min > 2600 AND s_min <= 4800 THEN 4800
			WHEN s_min > 4800 AND s_min <= 6000 THEN 6000
			WHEN s_min > 6000 AND s_min <= 7200 THEN 7200
			WHEN s_min > 7200 AND s_min <= 8000 THEN 8000
			WHEN s_min > 8000 AND s_min <= 9000 THEN 9000
			WHEN s_min > 9000 AND s_min <= 10800 THEN 10800
			WHEN s_min > 10800 --AND s_min <= 12000
			 THEN 12000
			END);

UPDATE model_draft.ego_grid_pf_hv_extension_trafo 
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
			WHEN 10800 THEN 0.00002
			WHEN 12000 THEN 0.00002
			END),
	tap_ratio = 1,
	phase_shift = 0;

--- Change all transformers with v0=v1 to lines

INSERT INTO model_draft.ego_grid_pf_hv_extension_line (line_id, bus0, bus1, geom, topo, v_nom, length, s_nom)
SELECT  nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'), bus0, bus1, geom, topo, v0, ST_Length(ST_GeographyFromText(ST_AsEWKT(geom)))/1000, s_min  FROM model_draft.ego_grid_pf_hv_extension_trafo WHERE v0 = v1;

UPDATE model_draft.ego_grid_pf_hv_extension_line 
SET cable = (CASE WHEN x = 0 AND s_nom IN (925, 1850, 2775, 3750) THEN TRUE ELSE cable END);

UPDATE model_draft.ego_grid_pf_hv_extension_line 
SET	cables = (CASE 	WHEN cables IS NULL AND scn_name IN ('extension_NEP', 'BE_NO_NEP 2035') AND cable = TRUE THEN s_nom/925*3 
			WHEN cables IS NULL AND scn_name IN ('extension_NEP', 'BE_NO_NEP 2035') AND cable = FALSE THEN s_nom/1790*3 
			ELSE cables END);
			 
UPDATE model_draft.ego_grid_pf_hv_extension_line 
SET	x = (CASE WHEN x = 0 AND cables != 0 THEN (CASE WHEN cable = FALSE AND cables!= 0 THEN 314.15 *0.8/(1000*cables/3) * length ELSE 0.3 * 0.31415 /(cables/3) END) ELSE x END),
	frequency = 50;

DELETE FROM model_draft.ego_grid_pf_hv_extension_trafo WHERE geom IN (SELECT geom FROM model_draft.ego_grid_pf_hv_extension_line);
DELETE FROM model_draft.ego_grid_pf_hv_extension_trafo WHERE topo IS NULL;

DELETE FROM model_draft.ego_grid_pf_hv_extension_bus WHERE scn_name = 'extension_nep2035_b2';

DELETE FROM model_draft.ego_grid_pf_hv_extension_line WHERE scn_name = 'extension_nep2035_b2';

DELETE FROM model_draft.ego_grid_pf_hv_extension_line WHERE scn_name = 'decommissioning_nep2035_b2';

DELETE FROM model_draft.ego_grid_pf_hv_extension_link WHERE scn_name = 'extension_nep2035_b2';

DELETE FROM model_draft.ego_grid_pf_hv_extension_trafo WHERE scn_name = 'extension_nep2035_b2';


INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, v_nom, geom)
SELECT 'extension_nep2035_b2', bus_id, v_nom, geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE scn_name = 'extension_NEP';


INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, v_nom, geom, bus_name)
	SELECT DISTINCT ON (geom) 
		'extension_nep2035_b2',
		nextval('model_draft.ego_grid_hv_electrical_neighbours_bus_id'),
		380,
		geom,
		osm_name
	FROM grid2.otg_ehvhv_bus_data WHERE osm_name IN ('Umspannwerk Windpark Iven', 'Elsfleth', 'BASF', 'Station Wanne', 'Amelsbüren', 'Umspannwerk Gurtweil', 'Umspannwerk Stockach', 'Beuren', 'Pasewalk');


INSERT INTO model_draft.ego_grid_pf_hv_extension_line (scn_name, line_id, bus0, bus1, v_nom, s_nom, project) 
	SELECT
		'extension_nep2035_b2',
		nextval('model_draft.ego_grid_hv_electrical_neighbours_line_id'),
		CASE WHEN EXISTS (SELECT DISTINCT ON (bus_i) bus_i FROM grid2.otg_ehvhv_bus_data WHERE anfangspunkt = osm_name AND spannung = base_kv) THEN (SELECT MIN(bus_i) FROM grid2.otg_ehvhv_bus_data WHERE anfangspunkt = osm_name AND spannung = base_kv)
			ELSE (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE anfangspunkt = bus_name AND spannung = v_nom) END,
		CASE WHEN EXISTS (SELECT DISTINCT ON (bus_i) bus_i FROM grid2.otg_ehvhv_bus_data WHERE endpunkt = osm_name AND spannung = base_kv) THEN (SELECT MIN(bus_i) FROM grid2.otg_ehvhv_bus_data WHERE endpunkt = osm_name AND spannung = base_kv)
			ELSE (SELECT MIN(bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus WHERE endpunkt = bus_name AND spannung = v_nom) END,
		spannung,
		s_nom,
		project
	FROM grid2.scnario_nep2035_b2_line WHERE scn_name = 'extension_NEP2035_B2';

UPDATE model_draft.ego_grid_pf_hv_extension_line 
SET 	bus0 = (CASE project	WHEN 'P201' THEN (SELECT MIN(bus_id) FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E61000008219DE771A512C40E266B10F27CB4740' AND v_nom = 220 ) ELSE bus0 END), ---AT
	bus1 = (CASE project	WHEN 'P176' THEN (SELECT MIN(bus_id) FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E610000056B7521C607FFB3F0B27630507634740' AND v_nom = 380 ) ---FR
				WHEN 'P204' THEN (SELECT MIN(bus_id) FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E6100000CC34F5A862612040F35A1E0B14624740' AND v_nom = 380) ELSE bus1 END); ---CH

INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, v_nom, geom, bus_name, project)
	SELECT DISTINCT ON (bus_i)
		'extension_nep2035_b2',
		bus_i,
		base_kv,
		geom,
		osm_name, 
		'delete'
	FROM grid2.otg_ehvhv_bus_data WHERE bus_i IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_line ) OR bus_i IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_line);

INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, v_nom, geom, project)
	SELECT DISTINCT ON (bus_id)
		'extension_nep2035_b2',
		bus_id,
		v_nom,
		geom, 
		'delete'
	FROM model_draft.ego_grid_pf_hv_bus WHERE geom IN ('0101000020E61000008219DE771A512C40E266B10F27CB4740', '0101000020E610000056B7521C607FFB3F0B27630507634740', '0101000020E6100000CC34F5A862612040F35A1E0B14624740') AND 
		(bus_id IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_line ) OR bus_id IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_line));
 
UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	topo = ST_MakeLine((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus0 = b.bus_id AND a.scn_name = b.scn_name ), (SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus1 = b.bus_id AND a.scn_name = b.scn_name )),
	geom = ST_Multi(ST_MakeLine((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus0 = b.bus_id AND a.scn_name = b.scn_name ), (SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus1 = b.bus_id AND a.scn_name = b.scn_name ))),
	frequency = 50,
	length = 1.14890133371257/1000 * ST_Length(ST_Multi(ST_MakeLine((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus0 = b.bus_id AND a.scn_name = b.scn_name), (SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus1 = b.bus_id AND a.scn_name = b.scn_name ))))
WHERE scn_name = 'extension_nep2035_b2';
	
UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET x = (CASE s_nom	WHEN 1790 THEN 314.15 * length * 0.109
			WHEN 3580 THEN 314.15 * length * 0.109/2
			WHEN 2685 THEN 314.15 * length * 0.109
			WHEN 1850 THEN 314.15 * length * 0.109
			WHEN 520  THEN 314.15 * length * 0.109
			WHEN 5370 THEN 314.15 * length * 0.109
			END )
WHERE scn_name = 'extension_nep2035_b2';	

INSERT INTO model_draft.ego_grid_pf_hv_extension_line (scn_name, line_id, s_nom, topo, geom,bus0, bus1, v_nom)
	SELECT	DISTINCT ON (line_id)
		'decommissioning_nep2035_b2', 
		b.line_id,
		b.s_nom,
		b.topo,
		b.geom, 
		b.bus0,
		b.bus1,
		(CASE b.s_nom WHEN 260 THEN 110 WHEN 520 THEN 220 WHEN 1040 THEN 220 WHEN 1790 THEN 380 WHEN 3580 THEN 380 WHEN 925 THEN 380 WHEN 1850 THEN 380 END)
	FROM grid2.scnario_nep2035_b2_line a, model_draft.ego_grid_pf_hv_line b WHERE a.scn_name = 'decommissioning_NEP2035_B2' AND b.scn_name = 'Status Quo' AND a.topo = b.topo AND a.s_nom = b.s_nom;

--- Was ist mit 2 von 3??

INSERT INTO model_draft.ego_grid_pf_hv_extension_link (scn_name , link_id, p_nom, bus0, bus1, topo)
	SELECT 'extension_nep2035_b2',
		nextval('model_draft.ego_grid_hv_electrical_neighbours_link_id'),
		700,
		(SELECT MIN(bus_i) FROM grid2.otg_ehvhv_bus_data WHERE osm_name = 'Güstrow' AND base_kv = 380),
		(SELECT MIN(bus_id) FROM model_draft.ego_grid_pf_hv_bus WHERE geom = '0101000020E6100000781E63B01D002E40A292E70A7AB74E40' AND v_nom = 380 ),
		ST_MakeLine((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE bus_name = 'Güstrow' AND v_nom = 380), (SELECT geom FROM model_draft.ego_grid_pf_hv_bus b WHERE geom = '0101000020E6100000781E63B01D002E40A292E70A7AB74E40' AND v_nom = 380 AND 'NEP 2035' = b.scn_name ))
		;

UPDATE model_draft.ego_grid_pf_hv_extension_link a
SET 	geom = ST_Multi(topo),
	length = 1.14890133371257/1000 * ST_Length(ST_Multi(topo))
WHERE scn_name = 'extension_nep2035_b2';

UPDATE model_draft.ego_grid_pf_hv_extension_link a
SET 	efficiency = 0.987*0.974^(length/1000),
	marginal_cost = 0
WHERE scn_name = 'extension_nep2035_b2';

INSERT INTO model_draft.ego_grid_pf_hv_extension_link (link_id, geom, p_nom, bus0, bus1, scn_name, length, efficiency, topo, marginal_cost)
SELECT	nextval('model_draft.ego_grid_hv_electrical_neighbours_link_id'),
	geom,
	p_nom,
	bus1,
	bus0,
	scn_name,
	length, 
	efficiency,
	topo,
	marginal_cost
FROM model_draft.ego_grid_pf_hv_extension_link WHERE scn_name = 'extension_nep2035_b2';


INSERT INTO model_draft.ego_grid_pf_hv_extension_trafo (scn_name, trafo_id, bus0)
SELECT	scn_name, 
	nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	bus_id
FROM model_draft.ego_grid_pf_hv_extension_bus WHERE scn_name = 'extension_nep2035_b2' AND project != 'delete';

UPDATE model_draft.ego_grid_pf_hv_extension_trafo a 
SET	bus1 = (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus c WHERE c.scn_name = 'NEP 2035' ORDER BY ST_Distance((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id = a.bus0 and scn_name = a.scn_name), c.geom) LIMIT 1),
	tap_ratio = 1,
	phase_shift = 0	
WHERE scn_name = 'extension_nep2035_b2';	

INSERT INTO model_draft.ego_grid_pf_hv_extension_trafo (scn_name, trafo_id, bus1, v1)
(SELECT DISTINCT ON (bus_id)
	'extension_nep2035_b2',
	 nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	 bus_id,
	 b.v_nom
	 FROM model_draft.ego_grid_pf_hv_bus b, model_draft.ego_grid_pf_hv_extension_line c  
	 WHERE c.scn_name = 'decommissioning_nep2035_b2' AND ST_Touches(b.geom, c.geom) AND c.v_nom = b.v_nom );

INSERT INTO model_draft.ego_grid_pf_hv_extension_trafo (scn_name, trafo_id, bus1, v1)
(SELECT DISTINCT ON (bus_id)
	'extension_nep2035_b2',
	 nextval('model_draft.ego_grid_hv_electrical_neighbours_transformer_id'),
	 bus_id,
	 b.v_nom
	 FROM grid.ego_pf_hv_bus b, model_draft.ego_grid_pf_hv_extension_line c  
	 WHERE c.scn_name = 'decommissioning_nep2035_b2' AND c.bus0 = bus_id OR c.bus1 = bus_id AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_trafo));

UPDATE model_draft.ego_grid_pf_hv_extension_trafo a 
SET	bus0 = (CASE WHEN bus0 IS NULL THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus c ORDER BY ST_Distance((SELECT geom FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND bus_id = a.bus1 ), c.geom) LIMIT 1)
		ELSE bus0 END)
WHERE scn_name = 'extension_nep2035_b2';	
		
UPDATE model_draft.ego_grid_pf_hv_extension_trafo a 
SET	s0 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_pf_hv_extension_line b WHERE scn_name = b.scn_name AND(a.bus0 = b.bus1 OR a.bus0 = b.bus0)),
	s1 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_pf_hv_line b WHERE scn_name = 'Status Quo' AND (a.bus0 = b.bus1 OR a.bus0 = b.bus0)),
	topo = (SELECT ST_MakeLine((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus b  WHERE bus_id = bus0 AND a.scn_name = b.scn_name), (SELECT geom FROM model_draft.ego_grid_pf_hv_bus b WHERE bus_id = bus1 AND scn_name = 'NEP 2035')))
WHERE scn_name = 'extension_nep2035_b2';	

UPDATE model_draft.ego_grid_pf_hv_extension_trafo a 
SET	geom = ST_Multi(topo),
	s_min = (CASE 	WHEN s0 < s1 	THEN s0
			WHEN s1 <= s0 	THEN s1
			WHEN s1 IS NULL THEN s0
			WHEN s0 IS NULL THEN s1 END)
WHERE scn_name = 'extension_nep2035_b2';		

UPDATE model_draft.ego_grid_pf_hv_extension_trafo 
SET 	s_nom = (CASE 	WHEN s_min <= 600  THEN 600
			WHEN s_min > 600  AND s_min <= 1200 THEN 1200
			WHEN s_min > 1200 AND s_min <= 1600 THEN 1600
			WHEN s_min > 1600 AND s_min <= 2100 THEN 2100
			WHEN s_min > 2100 AND s_min <= 2600 THEN 2600
			WHEN s_min > 2600 AND s_min <= 4800 THEN 4800
			WHEN s_min > 4800 AND s_min <= 6000 THEN 6000
			WHEN s_min > 6000 AND s_min <= 7200 THEN 7200
			WHEN s_min > 7200 AND s_min <= 8000 THEN 8000
			WHEN s_min > 8000 AND s_min <= 9000 THEN 9000
			WHEN s_min > 9000 AND s_min <= 10800 THEN 10800
			WHEN s_min > 10800 --AND s_min <= 12000
			 THEN 12000
			END)
WHERE scn_name = 'extension_nep2035_b2';

UPDATE model_draft.ego_grid_pf_hv_extension_trafo 
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
			WHEN 10800 THEN 0.00002
			WHEN 12000 THEN 0.00002
			END)
WHERE scn_name = 'extension_nep2035_b2';

DELETE FROM model_draft.ego_grid_pf_hv_extension_bus WHERE project = 'delete';

INSERT INTO model_draft.ego_grid_pf_hv_extension_line (scn_name, line_id, bus0, bus1, x,s_nom , capital_cost, length,cables,frequency ,terrain_factor,  geom ,topo )
SELECT 'extension_nep2035_b2', line_id, bus0, bus1, x, s_nom, capital_cost, length, cables, frequency ,terrain_factor, geom, topo FROM model_draft.ego_grid_pf_hv_extension_line WHERE scn_name = 'extension_NEP';

INSERT INTO model_draft.ego_grid_pf_hv_extension_link (scn_name, link_id, bus0, bus1, efficiency, p_nom, capital_cost, marginal_cost, length, terrain_factor, geom, topo)
SELECT 'extension_nep2035_b2', link_id*1000, bus0, bus1, efficiency, p_nom, capital_cost, marginal_cost, length, terrain_factor, geom, topo FROM model_draft.ego_grid_pf_hv_extension_link WHERE scn_name = 'extension_NEP';

INSERT INTO model_draft.ego_grid_pf_hv_extension_trafo (scn_name, trafo_id, bus0, bus1, x, s_nom, tap_ratio, phase_shift, capital_cost, geom, topo)
SELECT 'extension_nep2035_b2', trafo_id, bus0, bus1, x, s_nom, tap_ratio, phase_shift, capital_cost, geom, topo FROM model_draft.ego_grid_pf_hv_extension_trafo WHERE scn_name = 'extension_NEP';

DELETE FROM model_draft.ego_grid_pf_hv_extension_trafo  WHERE x IS NULL;


UPDATE model_draft.ego_grid_pf_hv_extension_bus
SET current_type = 'AC';

--- Delete unused buses 
DELETE FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_line) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_line)
AND bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_link) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_link)
AND bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_trafo) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_trafo);

