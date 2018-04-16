
DROP TABLE IF EXISTS  model_draft.scn_nep2035_b2_line ;
CREATE TABLE model_draft.scn_nep2035_b2_line
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  project character varying,
  project_id bigint,
  startpunkt character varying,
  endpunkt character varying,
  spannung bigint,
  s_nom numeric DEFAULT 0,
  cables bigint,
  nova character varying,
  geom geometry(MultiLineString,4326)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.scn_nep2035_b2_line
  OWNER TO oeuser;
  
COPY model_draft.scn_nep2035_b2_line FROM '/home/clara/GitHub/data_processing/documentation/scn_nep2035_b2.csv' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS  model_draft.ego_grid_pf_hv_extension_temp_resolution;
CREATE TABLE model_draft.ego_grid_pf_hv_extension_temp_resolution AS (SELECT * FROM model_draft.ego_grid_pf_hv_temp_resolution);

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_source ;
CREATE TABLE model_draft.ego_grid_pf_hv_extension_source AS (SELECT * FROM model_draft.ego_grid_pf_hv_source);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_source
  OWNER TO oeuser;

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_storage;
CREATE TABLE model_draft.ego_grid_pf_hv_extension_storage
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  storage_id bigint NOT NULL,
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
  soc_initial double precision,
  soc_cyclic boolean DEFAULT false,
  max_hours double precision,
  efficiency_store double precision,
  efficiency_dispatch double precision,
  standing_loss double precision,
  CONSTRAINT extension_storage_data_pkey PRIMARY KEY (storage_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_storage
  OWNER TO oeuser;

DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_storage_pq_set;
CREATE TABLE model_draft.ego_grid_pf_hv_extension_storage_pq_set
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  storage_id bigint NOT NULL,
  temp_id integer NOT NULL,
  p_set double precision[],
  q_set double precision[],
  p_min_pu double precision[],
  p_max_pu double precision[],
  soc_set double precision[],
  inflow double precision[],
  CONSTRAINT extension_storage_pq_set_pkey PRIMARY KEY (storage_id, temp_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_storage_pq_set
  OWNER TO oeuser;
  
DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_extension_bus_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_extension_bus_id;
SELECT setval('model_draft.ego_grid_hv_extension_bus_id', (max(bus_id)+1)) FROM model_draft.ego_grid_pf_hv_bus;

DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_extension_line_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_extension_line_id;
SELECT setval('model_draft.ego_grid_hv_extension_line_id', (max(line_id)+1)) FROM model_draft.ego_grid_pf_hv_line;

DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_extension_transformer_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_extension_transformer_id;
SELECT setval('model_draft.ego_grid_hv_extension_transformer_id', (max(trafo_id)+1)) FROM model_draft.ego_grid_pf_hv_transformer;

DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_extension_link_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_extension_link_id;
SELECT setval('model_draft.ego_grid_hv_extension_link_id', 1); 

DELETE FROM model_draft.scn_nep2035_b2_line WHERE project = 'P200';

UPDATE model_draft.scn_nep2035_b2_line SET startpunkt = 'Graustein' WHERE startpunkt = 'Graustein ';



--- Create and fill extension-bus table ---
DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_bus CASCADE;

CREATE TABLE model_draft.ego_grid_pf_hv_extension_bus
(
  scn_name character varying NOT NULL DEFAULT 'extension_nep2035_confirmed'::character varying,
  bus_id bigint NOT NULL, -- Unit: n/a...
  v_nom double precision, -- Unit: kV...
  current_type text DEFAULT 'AC'::text, -- Unit: n/a...
  v_mag_pu_min double precision DEFAULT 0, -- Unit: per unit...
  v_mag_pu_max double precision, -- Unit: per unit...
  geom geometry(Point,4326),
  project character varying,
  bus_name character varying---,
  ---CONSTRAINT nep_bus_data_pkey PRIMARY KEY (bus_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_bus
  OWNER TO oeuser;

--- Insert buses from input-table ---	
INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (bus_id, geom, bus_name, project ) 
	SELECT nextval('model_draft.ego_grid_hv_extension_bus_id'), (SELECT ST_Transform(geom, 4326)), name, 'BBPlG'
	FROM 	grid.bnetza_vorhabenpunkte_bbplg;
	
INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (bus_id, geom, bus_name, project) 
	SELECT nextval('model_draft.ego_grid_hv_extension_bus_id'), (SELECT ST_Transform(geom, 4326)), name, 'EnLAG'
	FROM 	grid.bnetza_vorhabenpunkte_enlag;

--- Update bus_names when they don't fit to line start- or endpoint ---
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
					
--- Set v_nom of buses with line-table ---	
UPDATE model_draft.ego_grid_pf_hv_extension_bus a 
	SET	v_nom = (SELECT SUBSTRING(spannung  FROM '[0-9]+'):: int)
			FROM grid.bnetza_vorhaben_bbplg b
			WHERE ST_INTERSECTS (a.geom, (SELECT ST_BUFFER(ST_TRANSFORM(b.geom, 4326), 0.01)));
		
UPDATE model_draft.ego_grid_pf_hv_extension_bus a 
	SET	v_nom = (CASE WHEN v_nom IS NULL THEN (SELECT SUBSTRING(spannung  FROM '[0-9]+'):: int) ELSE v_nom END)
			FROM grid.bnetza_vorhaben_enlag b
			WHERE ST_INTERSECTS (a.geom, (SELECT ST_BUFFER(ST_TRANSFORM(b.geom, 4326), 0.01)));

--- Insert international buses
INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, geom, current_type, v_nom)
SELECT DISTINCT ON (bus_id)
	'extension_nep2035_confirmed',
	nextval('model_draft.ego_grid_hv_extension_bus_id'),
	geom, 
	'AC',
	380
FROM model_draft.ego_grid_pf_hv_bus WHERE v_nom = 380
AND geom IN ('0101000020E61000008219DE771A512C40E266B10F27CB4740','0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40', '0101000020E61000009459C1A8632233401DE697AA6FF04940', '0101000020E61000003CFBF04927521540885EE6B0A2154A40');


INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, geom, current_type, v_nom, bus_name)
VALUES	('extension_BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_extension_bus_id'),
	'0101000020E6100000351DBC74686A24405536F7CC1CFC4E40',
	'AC',
	380,
	'center NO'),
	
	('extension_BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_extension_bus_id'),
	'0101000020E61000003851291763E8114098865E2D305B4940',
	'AC',
	320,
	'center BE');

--- Set scenario-name for buses in scenario BE_NO ---
UPDATE model_draft.ego_grid_pf_hv_extension_bus a 
SET scn_name = CASE WHEN bus_name IN ('Wilster', 'Grenzkorridor IV', 'Oberzier', 'Bundesgrenze (BE)') THEN 'extension_BE_NO_NEP 2035' ELSE scn_name END;

--- Bus in Wilster is needed in both scenarios ---
INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, geom, current_type, v_nom, bus_name, project)
SELECT 'extension_nep2035_confirmed', nextval('model_draft.ego_grid_hv_extension_bus_id'), geom, current_type, v_nom, bus_name, project FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'Wilster';

UPDATE model_draft.ego_grid_pf_hv_extension_bus a 
SET v_nom = 380
WHERE bus_name = 'Wilster' AND scn_name = 'extension_BE_NO_NEP 2035';

DELETE FROM model_draft.ego_grid_pf_hv_extension_bus WHERE v_nom IS NULL;

--- Create and fill extension-line table ---
DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_line CASCADE;

CREATE TABLE model_draft.ego_grid_pf_hv_extension_line
(
  scn_name character varying NOT NULL DEFAULT 'extension_nep2035_confirmed'::character varying,
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
  nova character varying
 --CONSTRAINT nep_line_data_pkey PRIMARY KEY (line_id, scn_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE model_draft.ego_grid_pf_hv_extension_line
  OWNER TO oeuser;

--- Insert AC-lines from input table ---
INSERT INTO model_draft.ego_grid_pf_hv_extension_line (line_id, geom, project, project_id, v_nom, segment, bus0, bus1, cable, length, nova)
	SELECT nextval('model_draft.ego_grid_hv_extension_line_id'),
	(SELECT ST_Transform(geom, 4326)),
	rechtsgrundlage,
	vorhabennummer,
	(SELECT SUBSTRING(spannung  FROM '[0-9]+'):: int),
	(SELECT SUBSTRING(abschnitt  FROM '[0-9]+'):: int),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE a.anfangspunkt = c.bus_name),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE a.endpunkt = c.bus_name),
	(CASE WHEN a.erdkabelpilot = 'ja' THEN TRUE ELSE FALSE END),
	(CASE WHEN a.art_der_geometrie = 'Luftlinie' THEN 1.14890133371257 * ST_Length(geom)/1000 ELSE ST_Length(geom)/1000 END), --- update length with mean relation of length of geom to length of topo
	nova
	FROM grid.bnetza_vorhaben_bbplg a WHERE technik = 'AC' AND vorhabennummer NOT IN (26, 27, 44, 28); -- only insert line which do't exist in model

----DELETE FROM model_draft.ego_grid_pf_hv_extension_line WHERE geom = "0105000020141600000100000001020000000200000033333373FAF77E41343333A35FEF5441C2F5281C50F27E41CCCCCCEC94B55441";

--- Fix problems with assignemt of buses ---
UPDATE model_draft.ego_grid_pf_hv_extension_line 
	SET 	bus1 = (CASE 	WHEN bus1 IS NULL THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'Conneforde') 
				WHEN project_id = 40 THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000044184DC838C2340199C783BF0CB4740') ELSE bus1 END),
		bus0 = (CASE WHEN bus0 IS NULL THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'Parchim Süd') ELSE bus0 END);
		
INSERT INTO model_draft.ego_grid_pf_hv_extension_line (line_id, geom, project, project_id, v_nom, segment, bus0, bus1, cable, length, nova)
	SELECT nextval('model_draft.ego_grid_hv_extension_line_id'),
	(SELECT ST_Transform(geom, 4326)), rechtsgrundlage, vorhabennummer,
	(SELECT SUBSTRING(spannung  FROM '[0-9]+'):: int),
	(SELECT SUBSTRING(abschnitt  FROM '[0-9]+'):: int),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE a.anfangspunkt = c.bus_name),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE  a.endpunkt = c.bus_name ),
	(CASE WHEN a.erdkabelpilot = 'ja' THEN TRUE ELSE FALSE END),
	(CASE WHEN a.art_der_geometrie = 'Luftlinie' THEN 1.14890133371257 * ST_Length(geom)/1000 ELSE ST_Length(geom)/1000 END),
	nova
	FROM grid.bnetza_vorhaben_enlag a WHERE technik = 'AC' AND vorhabennummer NOT IN (10, 17, 20, 21, 7, 9); 

UPDATE model_draft.ego_grid_pf_hv_extension_line 
	SET 	bus0 = (CASE	WHEN project = 'EnLAG' AND project_id = 15 AND segment = 5 THEN (SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E610000074B51EFDB6441C40CD0D1EEC4E4C4940' )
				WHEN project = 'EnLAG' AND project_id = 19 AND segment = 6 THEN (SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E61000005B50E484FEC21F4015BFC8E4906C4940') ELSE bus0 END),
		bus1 = (CASE	WHEN project = 'EnLAG' AND project_id = 15 AND segment = 4 THEN (SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E610000074B51EFDB6441C40CD0D1EEC4E4C4940' )
				WHEN project = 'EnLAG' AND project_id = 19 AND segment = 4 THEN (SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E61000005B50E484FEC21F4015BFC8E4906C4940') ELSE bus1 END);

--- Set number of systems in respect to NEP and data from ÜNB ---
UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	cables = (CASE 	WHEN (project = 'EnLAG' AND project_id IN (1, 13, 14, 15, 16, 18, 19, 5, 6 )) OR project = 'BBPlG' AND project_id IN (11, 15, 17, 19, 21, 32, 35, 39, 41, 42, 45, 6, 7, 8,14 )
				THEN 6
			WHEN (project = 'EnLAG' AND project_id IN (2)) OR (project = 'BBPlG' AND project_id IN (12, 27, 34))
				THEN 12
			ELSE 3 END);

--- Insert standard parameters from most used line ---	
UPDATE model_draft.ego_grid_pf_hv_extension_line
	SET	x = (CASE 	WHEN cable = FALSE AND cables != 0 THEN 0.9030765/  (cables/3) * length
				WHEN cable = TRUE AND cables != 0 THEN 0.3 * 0.31415 /(cables/3) END),
				
		s_nom = (CASE 	WHEN cable = FALSE AND cables != 0 THEN 2370 * (cables/3)
				WHEN cable = TRUE AND cables != 0 THEN 925 * (cables/3) END),
		frequency = 50;

--- Update parameters when line type is given from ÜNB or Planfeststellungunterlagen ---		
UPDATE model_draft.ego_grid_pf_hv_extension_line
SET	x = 0.8956759 /  (cables/3) * length,
	s_nom = 2685 * (cables/3)
WHERE (project= 'BBPlG' AND project_id IN (24)) OR (project= 'EnLAG' AND project_id IN (15,19,2));

UPDATE model_draft.ego_grid_pf_hv_extension_line
SET	x = 0.556975 /  (cables/3) * length,
	s_nom = 2920 * (cables/3)
WHERE (project= 'BBPlG' AND project_id IN (13,14,15,32,7,8)) OR (project= 'EnLAG' AND project_id IN (1,16,5,6));

UPDATE model_draft.ego_grid_pf_hv_extension_line
SET	x = 0.9030765 * (cables/3) * length,
	s_nom = 2370 * (cables/3)
WHERE (project= 'BBPlG' AND project_id IN (11,12,39,42,46,47)) OR (project= 'EnLAG' AND project_id IN (11));

UPDATE model_draft.ego_grid_pf_hv_extension_line
SET	x = 0.44528 * length,
	s_nom = 6055
WHERE project= 'EnLAG' AND project_id = 14;

UPDATE model_draft.ego_grid_pf_hv_extension_line
SET	x = 0.4559836* length,
	s_nom = 4160 * (cables/3)
WHERE project= 'EnLAG' AND project_id = 18;

--- Insert topo of lines ---
UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET topo = ST_MakeLine((SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus0 = b.bus_id AND a.scn_name = b.scn_name), (SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus1 = b.bus_id AND a.scn_name = b.scn_name ));

--- Update border-crossing lines to end at the middle of forigin country, length not updated to set investment costs later-- 	
UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	geom = (SELECT ST_Union ((ST_Multi('0102000020E610000002000000044184DC838C2340199C783BF0CB47408F19DE771A512C40E166B10F27CB4740')), a.geom)),
	bus1 = (SELECT DISTINCT ON (bus_id) bus_id FROM  model_draft.ego_grid_pf_hv_extension_bus  WHERE geom = '0101000020E61000008219DE771A512C40E266B10F27CB4740' AND v_nom = 380)
WHERE project = 'BBPlG' AND project_id = 40; 

UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	geom = (SELECT ST_Union ((ST_Multi('0102000020E61000000200000043504AD4C71E2A4013FABF88392248408F19DE771A512C40E166B10F27CB4740')), a.geom)),
	bus0 = (SELECT  DISTINCT ON (bus_id) bus_id FROM  model_draft.ego_grid_pf_hv_extension_bus  WHERE geom = '0101000020E61000008219DE771A512C40E266B10F27CB4740' AND v_nom = 380)
WHERE project = 'BBPlG' AND project_id = 32 AND bus0 IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'Bundesgrenze (AT)'); 

UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	geom = (SELECT ST_Union (ST_Multi('0102000020E6100000020000005A8198FA779F2140C36005117D734B409F1CB9F93CB22240346BAAA0021E4C40'), a.geom)),
	bus1 = (SELECT  DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus  WHERE geom = '0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40' AND v_nom = 380 )
WHERE project = 'BBPlG' AND project_id = 8 AND segment = 5; 

UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	geom = (SELECT ST_Union (ST_Multi('0102000020E610000002000000CBCBCAAFFB972240C4BC5A83B4674B409F1CB9F93CB22240346BAAA0021E4C40'), a.geom)),
	bus1 = (SELECT  DISTINCT ON (bus_id) bus_id FROM  model_draft.ego_grid_pf_hv_extension_bus  WHERE geom = '0101000020E6100000A01CB9F93CB22240376BAAA0021E4C40' AND v_nom = 380)
WHERE project = 'EnLAG' AND project_id = 1 AND segment = 5; 

UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	geom = (SELECT ST_Union (ST_Multi('0102000020E61000000200000039A7A68971BA2C40F85D3025D5954A409559C1A86322334019E697AA6FF04940'), a.geom)),
	bus1 = (SELECT  DISTINCT ON (bus_id) bus_id FROM  model_draft.ego_grid_pf_hv_extension_bus  WHERE geom = '0101000020E61000009459C1A8632233401DE697AA6FF04940' AND v_nom = 380)
WHERE project = 'EnLAG' AND project_id = 3 AND segment = 2; 

UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	geom = (SELECT ST_Union (ST_Multi('0102000020E610000002000000BABD2DA4D1672D409F4D6995D2164A409559C1A86322334019E697AA6FF04940'), a.geom)),
	bus1 = (SELECT  DISTINCT ON (bus_id) bus_id FROM  model_draft.ego_grid_pf_hv_extension_bus  WHERE geom = '0101000020E61000009459C1A8632233401DE697AA6FF04940' AND v_nom = 380)
WHERE project = 'EnLAG' AND project_id = 12 AND segment = 1; 

UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	geom = (SELECT ST_Union (ST_Multi('0102000020E610000002000000983DE33110CC19405CB6AF40C6EE49403DFBF049275215408E5EE6B0A2154A40'), a.geom)),
	bus1 = (SELECT  DISTINCT ON (bus_id) bus_id FROM  model_draft.ego_grid_pf_hv_extension_bus  WHERE geom = '0101000020E61000003CFBF04927521540885EE6B0A2154A40' AND v_nom = 380)
WHERE project = 'EnLAG' AND project_id = 13 AND segment = 2; 



DELETE FROM model_draft.ego_grid_pf_hv_extension_line WHERE geom IS NULL;


--- Create and fill table model_draft.ego_grid_pf_hv_extension_link		
DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_link;

CREATE TABLE model_draft.ego_grid_pf_hv_extension_link
(
  scn_name character varying NOT NULL DEFAULT 'extension_nep2035_confirmed'::character varying,
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
  OWNER TO oeuser;

--- Insert links from input table ---
INSERT INTO model_draft.ego_grid_pf_hv_extension_link (scn_name, link_id, geom, project, project_id, v_nom, segment, bus0, bus1) 
SELECT 'extension_nep2035_confirmed',
	nextval('model_draft.ego_grid_hv_extension_link_id'),
	(SELECT ST_Transform(geom, 4326)),
	rechtsgrundlage,
	vorhabennummer,
	(SELECT SUBSTRING(spannung  FROM '[0-9]+'):: int),
	abschnitt, 	
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE a.anfangspunkt = c.bus_name AND 'BBPlG' = c.project AND c.scn_name = 'extension_nep2035_confirmed'),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE  a.endpunkt = c.bus_name AND c.scn_name = 'extension_nep2035_confirmed')
FROM grid.bnetza_vorhaben_bbplg a
WHERE technik = 'DC' AND vorhabennummer NOT IN (30,33, 29);

INSERT INTO model_draft.ego_grid_pf_hv_extension_link (scn_name, link_id, geom, project, project_id, segment, v_nom,  bus0, bus1) 
SELECT 'extension_BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_extension_link_id'),
	(SELECT ST_Transform(geom, 4326)),
	rechtsgrundlage,
	vorhabennummer,
	abschnitt,
	(SELECT SUBSTRING(spannung  FROM '[0-9]+'):: int),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE a.anfangspunkt = c.bus_name AND c.scn_name = 'extension_BE_NO_NEP 2035'),
	(SELECT MIN(c.bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE  a.endpunkt = c.bus_name AND c.scn_name = 'extension_BE_NO_NEP 2035')
FROM grid.bnetza_vorhaben_bbplg a WHERE technik = 'DC' AND vorhabennummer IN (30,33);

DELETE FROM model_draft.ego_grid_pf_hv_extension_link WHERE segment = '2';

UPDATE model_draft.ego_grid_pf_hv_extension_link a
	SET 	length =  1.15 * ST_Length(ST_GeographyFromText(ST_AsEWKT(geom)))/1000;

--- Update border-crossing links, comparable to border-crossing lines ---	
UPDATE model_draft.ego_grid_pf_hv_extension_link a
SET  	geom = ST_Union((ST_Multi('0102000020E610000002000000B61FABB9DE7B1840B13DB1ABC95B49403D51291763E8114096865E2D305B4940')), a.geom),
	bus1 = (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE b.geom = '0101000020E61000003851291763E8114098865E2D305B4940' AND scn_name = 'extension_BE_NO_NEP 2035')
WHERE project = 'BBPlG' AND project_id = 30;

UPDATE model_draft.ego_grid_pf_hv_extension_link a
SET  	geom = ST_Union((ST_Multi('0102000020E610000002000000301DBC74686A24405036F7CC1CFC4E40051BA7078E0B204041ACB82EE7304B40')), a.geom),
	bus1 = (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000351DBC74686A24405536F7CC1CFC4E40' AND scn_name = 'extension_BE_NO_NEP 2035')
WHERE project = 'BBPlG' AND project_id = 33;

--- Set power of links in respect to NEP ---
UPDATE model_draft.ego_grid_pf_hv_extension_link a
	SET 	p_nom = (CASE 	WHEN project_id IN (1,2,3,4,5) THEN 2000
				WHEN project_id = 30 THEN 1000
				WHEN project_id = 33 THEN 1400
				WHEN project_id = 29 THEN 400
				ELSE 2000 END),
		topo = (SELECT ST_MakeLine ((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id = a.bus0 AND scn_name = a.scn_name), (SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id = a.bus1 AND scn_name = a.scn_name) ));

--- Set efficiency to 1, so one link can tranfer in both directions ---
UPDATE model_draft.ego_grid_pf_hv_extension_link a
	SET 	efficiency = 1,
		marginal_cost = 0;


--- Delete unused buses to avoid subnetworks ---
DELETE FROM model_draft.ego_grid_pf_hv_extension_bus a WHERE bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_line WHERE scn_name = a.scn_name)
AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_line WHERE scn_name = a.scn_name)
AND bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_link WHERE scn_name = a.scn_name) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_link WHERE scn_name = a.scn_name)
AND bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_transformer WHERE scn_name = a.scn_name) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_transformer WHERE scn_name = a.scn_name);


-- Table: model_draft.ego_grid_pf_hv_extension_transformer
DROP TABLE IF EXISTS model_draft.ego_grid_pf_hv_extension_transformer CASCADE;

CREATE TABLE model_draft.ego_grid_pf_hv_extension_transformer
(
  scn_name character varying NOT NULL DEFAULT 'extension_nep2035_confirmed'::character varying,
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
  project character varying,
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
ALTER TABLE model_draft.ego_grid_pf_hv_extension_transformer
  OWNER TO oeuser;
  
--- Insert trafo to each overlay-bus ---
INSERT INTO model_draft.ego_grid_pf_hv_extension_transformer (scn_name, trafo_id, tap_ratio, phase_shift, bus1, v1, project)
SELECT scn_name, nextval('model_draft.ego_grid_hv_extension_transformer_id'),1, 0, bus_id, v_nom, project
FROM model_draft.ego_grid_pf_hv_extension_bus
WHERE scn_name != 'decommissioning_nep2035_confirmed' AND bus_name NOT IN ('center BE', 'center NO');

--- Set sum of incoming lines to s1 ---		
UPDATE model_draft.ego_grid_pf_hv_extension_transformer a
SET 	s1 = (SELECT SUM(b.s_nom)
FROM model_draft.ego_grid_pf_hv_extension_line b
WHERE a.bus1 = b.bus1 OR a.bus1 = b.bus0);

UPDATE model_draft.ego_grid_pf_hv_extension_transformer a
SET 	s1 = (CASE WHEN s0 IS NULL THEN (SELECT SUM(b.p_nom)
FROM model_draft.ego_grid_pf_hv_extension_link b
WHERE a.bus1 = b.bus1 OR a.bus1 = b.bus0) ELSE s0 END);

--- Update bus0 to be the nearest eHV-bus in the existing network ---	
UPDATE model_draft.ego_grid_pf_hv_extension_transformer a
SET 	bus0 = (CASE WHEN bus0 IS NULL THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus c WHERE c.v_nom != 110 AND c.scn_name = 'NEP 2035' 
ORDER BY ST_Distance((SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id = a.bus1 AND scn_name = a.scn_name ), c.geom) LIMIT 1) ELSE bus0 END);

--- Set v0 and topology --- 	
UPDATE model_draft.ego_grid_pf_hv_extension_transformer a
SET 	v0 = (SELECT v_nom FROM model_draft.ego_grid_pf_hv_bus b WHERE a.bus0 = b.bus_id AND b.scn_name = 'NEP 2035'),
	topo = (SELECT ST_MakeLine((SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id = bus1), (SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_bus WHERE bus_id = bus0 AND scn_name = 'NEP 2035')));

--- Set sum of incoming lines to s0 ---	
UPDATE model_draft.ego_grid_pf_hv_extension_transformer a
SET	geom = ST_Multi(a.topo),
	s0 = (SELECT SUM(b.s_nom)
FROM model_draft.ego_grid_pf_hv_line b
WHERE (a.bus0 = b.bus0 OR a.bus0 = b.bus1) AND scn_name = 'Status Quo');

--- Choose minimum sum of incomming lines to s_min ---
UPDATE model_draft.ego_grid_pf_hv_extension_transformer 
SET 	s_min = (CASE 	WHEN s0 < s1 	THEN s0
			WHEN s1 <= s0 	THEN s1
			WHEN s1 IS NULL THEN s0
			WHEN s0 IS NULL THEN s1 END);

--- Set s_nom in respect to s_min and trafos in existing network --- 			
UPDATE model_draft.ego_grid_pf_hv_extension_transformer 
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

--- Set capital costs for trafos ---			
UPDATE model_draft.ego_grid_pf_hv_extension_transformer a
SET	capital_cost = 14166,
	s_nom_min = 0,
	s_nom_max = s_nom
WHERE (v1 = 220 AND v0=380) OR (v0 = 220 AND v1=380);
				

--- Delete unsued buses ---
DELETE FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_line) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_line)
AND bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_link) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_link)
AND bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_transformer) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_transformer);


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
  OWNER TO oeuser;

--- Insert loads to the middle of belgium and norway
INSERT INTO model_draft.ego_grid_pf_hv_extension_load (scn_name, load_id, bus, sign)
VALUES 	('extension_BE_NO_NEP 2035', 1000000, (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E61000003851291763E8114098865E2D305B4940' AND scn_name = 'extension_BE_NO_NEP 2035'), '-1'),
	('extension_BE_NO_NEP 2035', 1000001, (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000351DBC74686A24405536F7CC1CFC4E40' AND scn_name = 'extension_BE_NO_NEP 2035'), '-1');
	

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
  OWNER TO oeuser;

--- Insert load timeseries from opsd_hourly_timeseries ---
INSERT INTO model_draft.ego_grid_pf_hv_extension_load_pq_set (scn_name, load_id, temp_id, p_set, q_set)
VALUES('extension_BE_NO_NEP 2035' ,
	1000000 ,
	1,
	(SELECT (array_agg (SQ.load_be ORDER BY SQ.timestamp))	
	FROM model_draft.opsd_hourly_timeseries SQ
	WHERE timestamp BETWEEN '2011-01-01 00:00:00' AND '2011-12-31 23:00:00'
	 ),
	(SELECT (array_agg (0 *SQ.load_be ORDER BY SQ.timestamp))	
	FROM model_draft.opsd_hourly_timeseries SQ
	WHERE timestamp BETWEEN '2011-01-01 00:00:00' AND '2011-12-31 23:00:00'
	 )),

	('extension_BE_NO_NEP 2035' ,
	1000001 ,
	1,
	(SELECT (array_agg (SQ.load_no ORDER BY SQ.timestamp))	
	FROM model_draft.opsd_hourly_timeseries SQ
	WHERE timestamp BETWEEN '2011-01-01 00:00:00' AND '2011-12-31 23:00:00'
	 ),
	 (SELECT (array_agg (0*SQ.load_no ORDER BY SQ.timestamp))	
	FROM model_draft.opsd_hourly_timeseries SQ
	WHERE timestamp BETWEEN '2011-01-01 00:00:00' AND '2011-12-31 23:00:00'
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
  OWNER TO oeuser;

-- INSERT params of LinearTransformers in model_draft.ego_grid_pf_hv_generator (countries besides Germany)
-- starting generator_id at 200000, bus_id for neighbouring countries > 2800000 atm
-- BE_NO_NEP 2035
INSERT into model_draft.ego_grid_pf_hv_extension_generator

	SELECT
	'extension_BE_NO_NEP 2035' AS scn_name,
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
			AND scn_name = 'extension_BE_NO_NEP 2035'
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
	'extension_BE_NO_NEP 2035' AS scn_name,
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
			where bus_name = 'center BE' 
			AND scn_name = 'extension_BE_NO_NEP 2035'
			) SQ
			) B
		ON (substring(A.source, 1, 2) = 'BE')
	WHERE A.nominal_value[1] > 0.001
	AND A.scenario_id = 44;


	INSERT into model_draft.ego_grid_pf_hv_extension_generator

	SELECT
	'extension_BE_NO_NEP 2035' AS scn_name,
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
			AND scn_name = 'extension_BE_NO_NEP 2035'
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
	'extension_BE_NO_NEP 2035' AS scn_name,
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
			AND scn_name = 'extension_BE_NO_NEP 2035'
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
  OWNER TO oeuser;

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
		AND A.scn_name = 'extension_BE_NO_NEP 2035'
		) SQ,
		calc_renpass_gis.renpass_gis_results C
	WHERE
	(C.obj_label LIKE '%%' || SQ.renpass_gis_source || '%%')
	AND C.scenario_id = 44
	AND C.type = 'to_bus';

-- Make an array, INSERT into generator_pq_set
INSERT into model_draft.ego_grid_pf_hv_extension_generator_pq_set (scn_name, generator_id, temp_id, p_set)

	SELECT 'extension_BE_NO_NEP 2035' AS scn_name,
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
WHERE scn_name = 'extension_BE_NO_NEP 2035';

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


-- Insert decommisioning lines from input table model_draft.scn_nep2035_b2_line ---
INSERT INTO model_draft.ego_grid_pf_hv_extension_line (scn_name, line_id, s_nom, topo, geom,bus0, bus1, v_nom, project, project_id )
	SELECT	DISTINCT ON (line_id)
		'decommissioning_nep2035_confirmed', 
		b.line_id,
		a.s_nom,
		b.topo,
		b.geom, 
		b.bus0,
	        b.bus1,
		(CASE WHEN b.s_nom = 260 THEN 110 WHEN b.s_nom = 520 AND b.cables= 3 THEN 220  WHEN b.s_nom = 520 AND b.cables= 6 THEN 110 WHEN b.s_nom = 1040 THEN 220 WHEN b.s_nom = 1790 
		THEN 380 WHEN a.s_nom = 3580 THEN 380 WHEN a.s_nom = 925 THEN 380 WHEN a.s_nom =  1850 THEN 380 END),
		project,
		project_id
	FROM model_draft.scn_nep2035_b2_line a, model_draft.ego_grid_pf_hv_line b WHERE a.scn_name = 'decommissioning_nep2035_confirmed' AND b.scn_name = 'Status Quo' AND a.geom = b.geom AND a.s_nom = b.s_nom;

--- When not all systems will be decommissioned delete from table ---
DELETE FROM model_draft.ego_grid_pf_hv_extension_line a USING model_draft.ego_grid_pf_hv_extension_line b, model_draft.ego_grid_pf_hv_extension_line c 
WHERE a.nova = '2 von 3' AND a.line_id < b.line_id AND a.line_id < c.line_id;

--- Insert stublines as trafos to deleted lines ---
INSERT INTO model_draft.ego_grid_pf_hv_extension_transformer (scn_name, trafo_id, bus1, v1, capital_cost, project)
(SELECT DISTINCT ON (bus_id)
	'extension_nep2035_confirmed',
	nextval('model_draft.ego_grid_hv_extension_transformer_id'),  
	bus_id,
	b.v_nom,
	(CASE b.v_nom WHEN 110 THEN 17333 WHEN 220 THEN 14166 ELSE 0 END),
	project
FROM model_draft.ego_grid_pf_hv_bus b, model_draft.ego_grid_pf_hv_extension_line c  
WHERE c.scn_name = 'decommissioning_nep2035_confirmed' AND ST_Touches(b.geom, c.geom) AND c.v_nom = b.v_nom AND b.scn_name = 'Status Quo');
	
INSERT INTO model_draft.ego_grid_pf_hv_extension_transformer (scn_name, trafo_id, bus1, v1, capital_cost)
(SELECT DISTINCT ON (bus_id)
	'extension_nep2035_confirmed',
	 nextval('model_draft.ego_grid_hv_extension_transformer_id'),
	 bus_id,
	 b.v_nom,
	 17333
FROM model_draft.ego_grid_pf_hv_bus b
WHERE ((v_nom = 110 AND geom IN ('0101000020E6100000CA0F62BFC4FD214018163EFFE2FA4A40', '0101000020E6100000564589B8733922401DE884E04BFA4A40', '0101000020E61000005FE68585A460224085BB0E304EF44A40')) OR (v_nom = 380 AND geom = '0101000020E6100000A034005D509E2A4093C4BC00EC424A40')));

--- Set bus0 of stublines to nearest bus in overlay_network ---
UPDATE model_draft.ego_grid_pf_hv_extension_transformer a 
SET	bus0 = (CASE WHEN bus0 IS NULL THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE a.scn_name = c.scn_name
	ORDER BY ST_Distance((SELECT geom FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND bus_id = a.bus1 ), c.geom) LIMIT 1)
		ELSE bus0 END),
	v0 = (CASE WHEN v0 = 0 THEN (SELECT v_nom FROM model_draft.ego_grid_pf_hv_extension_bus c ORDER BY ST_Distance((SELECT geom FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND bus_id = a.bus1 ), c.geom) LIMIT 1)
		ELSE v0 END);

--- Set sum of connected lines to s0 ---
UPDATE model_draft.ego_grid_pf_hv_extension_transformer a
SET 	s0 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_pf_hv_extension_line b WHERE a.bus0 = b.bus1 OR a.bus0 = b.bus0)
WHERE s0 IS NULL OR s0=0;

--- Set v1 and topology of transformers ---	
UPDATE model_draft.ego_grid_pf_hv_extension_transformer a
SET 	v1 = (CASE WHEN v1 IS NULL THEN (SELECT v_nom FROM model_draft.ego_grid_pf_hv_bus b WHERE a.bus1 = b.bus_id AND b.scn_name = 'NEP 2035') ELSE v1 END),
	topo = (SELECT ST_MakeLine((SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE bus_id = bus1 AND a.scn_name = b.scn_name), (SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_bus WHERE bus_id = bus0 AND scn_name = 'NEP 2035')))
WHERE topo IS NULL; 

UPDATE model_draft.ego_grid_pf_hv_extension_transformer a
SET 	v1 = (CASE WHEN v1 IS NULL THEN (SELECT v_nom FROM model_draft.ego_grid_pf_hv_bus b WHERE a.bus1 = b.bus_id AND b.scn_name = 'NEP 2035') ELSE v1 END),
	topo = (SELECT ST_MakeLine((SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE bus_id = bus0 AND a.scn_name = b.scn_name), (SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_bus WHERE bus_id = bus1 AND scn_name = 'NEP 2035')))
WHERE topo IS NULL; 

UPDATE model_draft.ego_grid_pf_hv_extension_transformer a
SET	geom = ST_Multi(a.topo),
	s0 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_pf_hv_line b WHERE (a.bus0 = b.bus0 OR a.bus0 = b.bus1) AND scn_name = 'Status Quo');

UPDATE model_draft.ego_grid_pf_hv_extension_transformer 
SET 	s_min = (CASE 	WHEN s0 < s1 	THEN s0
			WHEN s1 <= s0 	THEN s1
			WHEN s1 IS NULL THEN s0
			WHEN s0 IS NULL THEN s1 END);

			
UPDATE model_draft.ego_grid_pf_hv_extension_transformer 
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

UPDATE model_draft.ego_grid_pf_hv_extension_transformer 
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
	
UPDATE model_draft.ego_grid_pf_hv_extension_transformer 
SET	s_nom_min = s_nom,
	s_nom_max = s_nom
WHERE capital_cost = 0;
	
UPDATE model_draft.ego_grid_pf_hv_extension_transformer 
SET	s_nom_min = 0,
	s_nom_max = s_nom
WHERE s_nom_max IS NULL;

--- Delete unused buses to avoid subnetworks ---
DELETE FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_line) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_line)
AND bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_link) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_link)
AND bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_transformer) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_transformer);

---- Scenario 'nep2035_b2' ----

INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, v_nom, geom, project, bus_name)
SELECT 'extension_nep2035_b2', bus_id, v_nom, geom, project, bus_name FROM model_draft.ego_grid_pf_hv_extension_bus WHERE scn_name = 'extension_nep2035_confirmed';

--- Insert forigin buses ---
INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, v_nom, geom)
VALUES ( 'extension_nep2035_b2',nextval('model_draft.ego_grid_hv_extension_bus_id'), 380,  '0101000020E610000056B7521C607FFB3F0B27630507634740'),
( 'extension_nep2035_b2',nextval('model_draft.ego_grid_hv_extension_bus_id'), 380, '0101000020E6100000CC34F5A862612040F35A1E0B14624740');

--- Insert buses from input table ---
INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, v_nom, geom, bus_name, project)
	SELECT DISTINCT ON (osm_name) 
		'extension_nep2035_b2',
		nextval('model_draft.ego_grid_hv_extension_bus_id'),
		b.spannung,
		a.geom,
		osm_name,
		'B2'
	FROM grid.otg_ehvhv_bus_data a, model_draft.scn_nep2035_b2_line b WHERE osm_name =  b.startpunkt OR osm_name = b.endpunkt OR osm_name = 'Güstrow' AND base_kv = 380;
	
--- Insert lines from input table ---
INSERT INTO model_draft.ego_grid_pf_hv_extension_line (scn_name, line_id, bus0, bus1, v_nom, s_nom, project, nova, cables) 
	SELECT
		'extension_nep2035_b2',
		nextval('model_draft.ego_grid_hv_extension_line_id'),
		(SELECT DISTINCT ON (bus_name) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE scn_name ='extension_nep2035_b2' AND startpunkt = bus_name AND v_nom = spannung  ),
		(SELECT DISTINCT ON (bus_name) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE endpunkt = bus_name AND v_nom = spannung AND scn_name ='extension_nep2035_b2'),
		spannung,
		s_nom,
		project,
		nova,
		cables
	FROM model_draft.scn_nep2035_b2_line WHERE scn_name = 'extension_NEP2035_B2';
	
--- Update bus1 of cross-border lines ---
UPDATE model_draft.ego_grid_pf_hv_extension_line 
SET 	bus1 = (CASE project	WHEN 'P176' THEN (SELECT MIN(bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E610000056B7521C607FFB3F0B27630507634740' AND v_nom = 380 ) ---FR
				WHEN 'P204' THEN (SELECT MIN(bus_id) FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000CC34F5A862612040F35A1E0B14624740' AND v_nom = 380) ELSE bus1 END); ---CH
				
INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, v_nom, geom, project)
	SELECT DISTINCT ON (bus_id)
		'extension_nep2035_b2',
		nextval('model_draft.ego_grid_hv_extension_bus_id'),
		v_nom,
		geom, 
		'B2'
	FROM model_draft.ego_grid_pf_hv_bus WHERE geom IN ('0101000020E6100000781E63B01D002E40A292E70A7AB74E40','0101000020E61000008219DE771A512C40E266B10F27CB4740', '0101000020E610000056B7521C607FFB3F0B27630507634740', '0101000020E6100000CC34F5A862612040F35A1E0B14624740') AND 
		(bus_id IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_line ) OR bus_id IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_line));

INSERT INTO model_draft.ego_grid_pf_hv_extension_bus (scn_name, bus_id, v_nom, geom, project)
	SELECT DISTINCT ON (bus_id)
		'extension_nep2035_b2',
		nextval('model_draft.ego_grid_hv_extension_bus_id'),
		v_nom,
		geom, 
		'B2'
	FROM model_draft.ego_grid_pf_hv_bus WHERE geom IN ('0101000020E6100000781E63B01D002E40A292E70A7AB74E40') AND v_nom = 380;


--- Update parameter of lines, length multiplied with mean rellation from length of geom to length of topo in existing network ---
UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	topo = ST_MakeLine((SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus0 = b.bus_id AND a.scn_name = b.scn_name ), (SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus1 = b.bus_id AND a.scn_name = b.scn_name )),
	geom = ST_Multi(ST_MakeLine((SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus0 = b.bus_id AND a.scn_name = b.scn_name ), (SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus1 = b.bus_id AND a.scn_name = b.scn_name ))),
	frequency = 50,
	length = 1.14890133371257/1000 * ST_Length(ST_Multi(ST_MakeLine((SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus0 = b.bus_id AND a.scn_name = b.scn_name),
	 (SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE a.bus1 = b.bus_id AND a.scn_name = b.scn_name ))), true)
WHERE scn_name = 'extension_nep2035_b2';
	
--- Update length of border crossing lines to length in german grid (in respect to NEP)---
UPDATE model_draft.ego_grid_pf_hv_extension_line 
SET length = (CASE project	WHEN 'P176' THEN 18
				WHEN 'P204' THEN 4
				ELSE length END),
	cable = (CASE WHEN project = 'P180' THEN TRUE ELSE FALSE END);

--- Set elctrical parameters, type of lines exept project P180 not given ---				
UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	x = (CASE project	WHEN 'P180' THEN 0.3 * 0.31415 /(cables/3) 
				WHEN 'P201' THEN 314.15 *1/(1000*cables/3) * length 
				ELSE 0.903070765 /  (cables/3) * length END)	
WHERE scn_name = 'extension_nep2035_b2';	

--- Insert decommissioning lines ---
INSERT INTO model_draft.ego_grid_pf_hv_extension_line (scn_name, line_id, s_nom, topo, geom,bus0, bus1, project, v_nom)
	SELECT	DISTINCT ON (line_id)
		'decommissioning_nep2035_b2', 
		b.line_id,
		b.s_nom,
		b.topo,
		b.geom, 
		b.bus0,
		b.bus1,
		project,
		(CASE b.s_nom WHEN 260 THEN 110 WHEN 520 THEN 220 WHEN 1040 THEN 220 WHEN 1790 THEN 380 WHEN 3580 THEN 380 WHEN 925 THEN 380 WHEN 1850 THEN 380 END)
	FROM model_draft.scn_nep2035_b2_line a, model_draft.ego_grid_pf_hv_line b WHERE a.scn_name = 'decommissioning_NEP2035_B2' 
	AND b.scn_name = 'Status Quo' AND a.geom = b.geom AND a.s_nom = b.s_nom;

--- Insert link (Hansa Power bridge)
INSERT INTO model_draft.ego_grid_pf_hv_extension_link (scn_name , link_id, p_nom, bus0, bus1, topo,length)
	SELECT 'extension_nep2035_b2',
		nextval('model_draft.ego_grid_hv_extension_link_id'),
		700,
		(SELECT DISTINCT ON (bus_name) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE scn_name = 'extension_nep2035_b2' AND bus_name = 'Güstrow' AND v_nom = 380),
		(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000781E63B01D002E40A292E70A7AB74E40' AND v_nom = 380 ),
		ST_MakeLine((SELECT DISTINCT ON (bus_name) geom FROM model_draft.ego_grid_pf_hv_extension_bus b WHERE bus_name = 'Güstrow' AND v_nom = 380 AND scn_name = 'extension_nep2035_b2'), (SELECT geom FROM model_draft.ego_grid_pf_hv_bus b WHERE geom = '0101000020E6100000781E63B01D002E40A292E70A7AB74E40' AND v_nom = 380 AND 'NEP 2035' = b.scn_name )),
		60;

UPDATE model_draft.ego_grid_pf_hv_extension_link a
SET 	geom = ST_Multi(topo)
WHERE scn_name = 'extension_nep2035_b2';

UPDATE model_draft.ego_grid_pf_hv_extension_link a
SET 	efficiency = 1,
	marginal_cost = 0,
	capital_cost = 375 * length
WHERE scn_name = 'extension_nep2035_b2';

--- Insert transformers to new buses ---
INSERT INTO model_draft.ego_grid_pf_hv_extension_transformer (scn_name, trafo_id, bus1, v1, project, capital_cost)
SELECT	scn_name, 
	nextval('model_draft.ego_grid_hv_extension_transformer_id'),
	bus_id,
	v_nom,
	'B2',
	(CASE v_nom WHEN 220 THEN 14166 WHEN 110 THEN 17333 ELSE 0 END)
FROM model_draft.ego_grid_pf_hv_extension_bus WHERE scn_name = 'extension_nep2035_b2' AND project = 'B2';

UPDATE model_draft.ego_grid_pf_hv_extension_transformer a 
SET	bus0 = (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus c WHERE c.v_nom != 110 AND c.scn_name = 'NEP 2035'
	ORDER BY ST_Distance((SELECT geom FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_id = a.bus1 AND scn_name = a.scn_name), c.geom) LIMIT 1),
	tap_ratio = 1,
	phase_shift = 0	
WHERE scn_name = 'extension_nep2035_b2';
	
UPDATE model_draft.ego_grid_pf_hv_extension_transformer a 
SET v0 =( SELECT DISTINCT ON (v_nom) v_nom FROM model_draft.ego_grid_pf_hv_bus c WHERE a.bus0 = c.bus_id)
WHERE scn_name = 'extension_nep2035_b2';

--- Insert stublines to decommissioning buses --- 
INSERT INTO model_draft.ego_grid_pf_hv_extension_transformer (scn_name, trafo_id, bus0, v0, project, capital_cost)
(SELECT DISTINCT ON (bus_id)
	'extension_nep2035_b2',
	 nextval('model_draft.ego_grid_hv_extension_transformer_id'),
	 bus_id,
	 b.v_nom,
	 'B2',
	 (CASE WHEN c.v_nom = 110 THEN 17333 WHEN c.v_nom = 220 THEN 14166 ELSE 0 END)
	 FROM model_draft.ego_grid_pf_hv_bus b, model_draft.ego_grid_pf_hv_extension_line c  
	 WHERE c.scn_name = 'decommissioning_nep2035_b2' AND ST_Touches(b.geom, c.geom) AND c.v_nom = b.v_nom );

UPDATE model_draft.ego_grid_pf_hv_extension_transformer a 
SET	bus1 = (CASE WHEN bus1 IS NULL THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE c.v_nom != 110 AND a.scn_name = c.scn_name
ORDER BY ST_Distance((SELECT geom FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo' AND bus_id = a.bus0 AND v_nom != 110 ), c.geom) LIMIT 1)
		ELSE bus1 END)
WHERE scn_name = 'extension_nep2035_b2';	

UPDATE model_draft.ego_grid_pf_hv_extension_transformer a 
SET v1 = (SELECT DISTINCT ON (bus_id) v_nom FROM model_draft.ego_grid_pf_hv_extension_bus c WHERE a.bus1 = c.bus_id)
WHERE scn_name = 'extension_nep2035_b2' AND v1 = 0 OR v1 IS NULL;
		
UPDATE model_draft.ego_grid_pf_hv_extension_transformer a 
SET	s1 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_pf_hv_extension_line b WHERE scn_name = b.scn_name AND(a.bus1 = b.bus1 OR a.bus1 = b.bus0)),
	s0 = (SELECT SUM(b.s_nom) FROM model_draft.ego_grid_pf_hv_line b WHERE scn_name = 'Status Quo' AND (a.bus0 = b.bus1 OR a.bus0 = b.bus0)),
	topo = (SELECT ST_MakeLine((SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_extension_bus b  WHERE bus_id = bus1 AND a.scn_name = b.scn_name), (SELECT DISTINCT ON (geom) geom FROM model_draft.ego_grid_pf_hv_bus b WHERE bus_id = bus0 AND scn_name = 'NEP 2035')))
WHERE scn_name = 'extension_nep2035_b2';	

UPDATE model_draft.ego_grid_pf_hv_extension_transformer a 
SET	geom = ST_Multi(topo),
	s_min = (CASE 	WHEN s0 < s1 	THEN s0
			WHEN s1 <= s0 	THEN s1
			WHEN s1 IS NULL THEN s0
			WHEN s0 IS NULL THEN s1 END)
WHERE scn_name = 'extension_nep2035_b2';		

UPDATE model_draft.ego_grid_pf_hv_extension_transformer 
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

UPDATE model_draft.ego_grid_pf_hv_extension_transformer 
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
	phase_shift = 0
WHERE scn_name = 'extension_nep2035_b2';


UPDATE model_draft.ego_grid_pf_hv_extension_transformer a
SET	s_nom_min = 0,
	s_nom_max = s_nom
WHERE scn_name = 'extension_nep2035_b2';

--- When v0 = v1 it's assumed that the trafo won't be needed in reality and just exists due to overlay character ---
UPDATE model_draft.ego_grid_pf_hv_extension_transformer a
SET	s_nom_min = s_nom,
	s_nom_max = s_nom
WHERE capital_cost = 0;

--- Insert into line_expansion assumed costs per MVA and km for lines, s_nom is estimated to be the most used one in NEP () ---
UPDATE  model_draft.ego_grid_line_expansion_costs
SET capital_costs_pypsa = investment_cost*1000000/2370
WHERE measure = '380-kV-Stromkreisauflage/Umbeseilung';

UPDATE  model_draft.ego_grid_line_expansion_costs
SET capital_costs_pypsa = investment_cost*1000000/4740
WHERE measure IN ('380-kV-Neubau in bestehender Trasse Doppelleitung','380-kV-Neubau in Doppelleitung') ;

----

--- Update NOVA to differentiate between 'Netzverstärkung: Stromkreisauflage/Umbeseilung' and 'Netzverstärkung: Neubau in bestehender Trasse' ---
UPDATE model_draft.ego_grid_pf_hv_extension_line
SET nova = (CASE	WHEN project = 'BBPlG' AND nova = 'Netzverstärkung' AND project_id IN (9,25, 46,43) THEN 'Netzverstärkung: Stromkreisauflage/Umbeseilung'
			WHEN project = 'BBPlG' AND nova = 'Netzverstärkung' AND project_id IN (44,10,11,12,13,14,15,15,18,19,20,21,24,26,27,28,32,34,38,39,40,41,42,45,47,6,7) THEN 'Netzverstärkung: Neubau in bestehender Trasse'
			WHEN project = 'BBPlG' AND nova = 'Neubau' THEN 'Netzausbau: Neubau in neuer Trasse'
			
			WHEN project = 'EnLAG' AND nova = 'Netzverstärkung' AND project_id IN (10,14,23,8) THEN 'Netzverstärkung: Stromkreisauflage/Umbeseilung'
			WHEN project = 'EnLAG' AND nova = 'Netzverstärkung' AND project_id IN (1,15,16,19) THEN 'Netzverstärkung: Neubau in bestehender Trasse'
			WHEN project = 'EnLAG' AND nova = 'Neubau' THEN 'Netzausbau: Neubau in neuer Trasse'
			ELSE nova END);
					
UPDATE model_draft.ego_grid_pf_hv_extension_line
SET nova = (CASE WHEN project = 'EnLAG' AND project_id = 14 AND segment = 3 THEN 'Netzverstärkung: Neubau in bestehender Trasse' 
		WHEN project = 'BBPlG' AND project_id = 19 AND bus0 = (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'Pfungstedt') THEN  'Netzverstärkung: Stromkreisauflage/Umbeseilung'
		WHEN project = 'BBPlG' AND project_id = 20 AND segment = 1 THEN 'Netzverstärkung: Stromkreisauflage/Umbeseilung'
		ELSE nova END);

--- Set capital costs for lines from table model_draft.ego_grid_line_expansion_costs ---	
UPDATE model_draft.ego_grid_pf_hv_extension_line
SET capital_cost = (CASE WHEN nova = 'Netzverstärkung: Stromkreisauflage/Umbeseilung' AND v_nom = 220 THEN ((SELECT capital_costs_pypsa FROM model_draft.ego_grid_line_expansion_costs WHERE cost_id = 1 ) * length)
			WHEN nova = 'Netzverstärkung: Stromkreisauflage/Umbeseilung' AND v_nom = 380 THEN ((SELECT capital_costs_pypsa FROM model_draft.ego_grid_line_expansion_costs WHERE cost_id = 2 ) * length)
			WHEN nova = 'Netzverstärkung: Neubau in bestehender Trasse' AND v_nom = 380 THEN ((SELECT capital_costs_pypsa FROM model_draft.ego_grid_line_expansion_costs WHERE cost_id = 3 ) * length)
			WHEN nova = 'Netzausbau: Neubau in neuer Trasse' AND v_nom = 380 THEN ((SELECT capital_costs_pypsa FROM model_draft.ego_grid_line_expansion_costs WHERE cost_id = 4 ) * length)
		ELSE 0 END);

--- Cables are about 6 times more expensive then lines, TenneT: https://www.tennet.eu/de/unser-netz/rund-um-den-netzausbau/erdverkabelung/erdkabel-und-freileitung-im-vergleich/ ---
UPDATE model_draft.ego_grid_pf_hv_extension_line
SET capital_cost = 6 * capital_cost
WHERE cable = TRUE;

UPDATE model_draft.ego_grid_pf_hv_extension_link
SET capital_cost = (CASE WHEN project_id IN(1,3,4,5,30) THEN ((SELECT capital_costs_pypsa FROM model_draft.ego_grid_line_expansion_costs WHERE cost_id = 7 ) * length)
			WHEN project_id = 2 THEN ((SELECT capital_costs_pypsa FROM model_draft.ego_grid_line_expansion_costs WHERE cost_id = 6 ) * length)
			WHEN project_id  IN (29,33) THEN ((SELECT capital_costs_pypsa FROM model_draft.ego_grid_line_expansion_costs WHERE cost_id = 5 ) * length) 
			ELSE capital_cost END);
			
--- Set s_nom_min and s_nom_max fpr lines, when lines are decommisioned, s_nom_min is s_nom of decommissioned line ---
UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET 	s_nom_min = (CASE WHEN EXISTS (SELECT * FROM model_draft.ego_grid_pf_hv_extension_line b WHERE b.scn_name = 'decommissioning_nep2035_confirmed' AND a.project = b.project AND a.project_id = b.project_id) AND a.nova IN ('Netzverstärkung: Stromkreisauflage/Umbeseilung', 'Netzverstärkung: Neubau in bestehender Trasse' )
		THEN (SELECT MAX(s_nom) FROM model_draft.ego_grid_pf_hv_extension_line b WHERE b.scn_name  = 'decommissioning_nep2035_confirmed' AND a.project = b.project AND a.project_id = b.project_id)
		ELSE 0 END),
	s_nom_max = s_nom
WHERE scn_name = 'extension_nep2035_confirmed';
			
UPDATE model_draft.ego_grid_pf_hv_extension_line a
SET	s_nom_min =  (CASE 	WHEN project IN ('P22', 'P26', 'P113', 'P123', 'P161', 'P172', 'P173', 'P205', 'P211', 'P214', 'P217', 'P219', 'P220')
					THEN 3580
				WHEN project IN ('P40', 'P159', 'P206', 'P215', 'P216', 'P218')
					THEN 1040
				WHEN project = 'P180' THEN 1850

			ELSE 0 END),
	s_nom_max = s_nom
WHERE scn_name = 'extension_nep2035_b2';

UPDATE model_draft.ego_grid_pf_hv_extension_link a
SET 	p_nom_min = 0,
	p_nom_max = p_nom;

DELETE FROM model_draft.ego_grid_pf_hv_extension_bus WHERE project = 'delete';

INSERT INTO model_draft.ego_grid_pf_hv_extension_line (scn_name, line_id, project, bus0, bus1, x,s_nom, s_nom_min, s_nom_max, capital_cost, length,cables, frequency ,terrain_factor,  geom ,topo )
SELECT 'extension_nep2035_b2',
	line_id,
	project,
	bus0,
	bus1,
	x,
	s_nom,
	s_nom_min,
	s_nom_max,
	capital_cost,
	length,
	cables,
	frequency ,
	terrain_factor, 
	geom, 
	topo
FROM model_draft.ego_grid_pf_hv_extension_line WHERE scn_name = 'extension_nep2035_confirmed';

INSERT INTO model_draft.ego_grid_pf_hv_extension_line (scn_name, line_id, project, bus0, bus1, x,s_nom , capital_cost, length,cables,frequency ,terrain_factor,  geom ,topo )
SELECT 'decommissioning_nep2035_b2',
	line_id, 
	project,
	bus0, 
	bus1, 
	x, 
	s_nom, 
	capital_cost, 
	length, 
	cables, 
	frequency ,
	terrain_factor, 
	geom, 
	topo 
FROM model_draft.ego_grid_pf_hv_extension_line WHERE scn_name = 'decommissioning_nep2035_confirmed';

INSERT INTO model_draft.ego_grid_pf_hv_extension_link (scn_name, link_id, bus0, bus1, efficiency, p_nom, p_nom_min, p_nom_max, capital_cost, marginal_cost, length, terrain_factor, geom, topo)
SELECT 'extension_nep2035_b2',
	link_id, 
	bus0, 
	bus1, 
	efficiency, 
	p_nom, 
	p_nom_min,
	p_nom_max,
	capital_cost, 
	marginal_cost, 
	length, 
	terrain_factor, 
	geom, 
	topo 
FROM model_draft.ego_grid_pf_hv_extension_link WHERE scn_name = 'extension_nep2035_confirmed';

INSERT INTO model_draft.ego_grid_pf_hv_extension_transformer (scn_name, trafo_id, project, bus0, bus1, x, s_nom, tap_ratio, phase_shift, capital_cost, geom, topo, s_nom_min, s_nom_max)
SELECT 'extension_nep2035_b2',
	trafo_id, 
	project,
	bus0, 
	bus1, 
	x, 
	s_nom, 
	tap_ratio, 
	phase_shift, 
	capital_cost, 
	geom, 
	topo,
	s_nom_min,
	s_nom_max
FROM model_draft.ego_grid_pf_hv_extension_transformer WHERE scn_name = 'extension_nep2035_confirmed';


UPDATE model_draft.ego_grid_pf_hv_extension_bus
SET current_type = 'AC';

--- Delete unused buses to avoid subnetworks---
DELETE FROM model_draft.ego_grid_pf_hv_extension_bus a WHERE bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_line WHERE scn_name = a.scn_name)
AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_line WHERE scn_name = a.scn_name)
AND bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_link WHERE scn_name = a.scn_name) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_link WHERE scn_name = a.scn_name)
AND bus_id NOT IN (SELECT bus0 FROM model_draft.ego_grid_pf_hv_extension_transformer WHERE scn_name = a.scn_name) AND bus_id NOT IN (SELECT bus1 FROM model_draft.ego_grid_pf_hv_extension_transformer WHERE scn_name = a.scn_name);


