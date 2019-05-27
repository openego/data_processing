

--- NEP 2035
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
	FROM model_draftALT.opsd_hourly_timeseries SQ
	WHERE timestamp BETWEEN '2011-01-01 00:00:00' AND '2011-12-31 23:00:00'
	 ),
	 (SELECT (array_agg (0*SQ.load_no ORDER BY SQ.timestamp))	
	FROM model_draftALT.opsd_hourly_timeseries SQ
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

DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_extension_generator_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_extension_generator_id;
SELECT setval('model_draft.ego_grid_hv_extension_generator_id',210000);

-- INSERT generator capacities
-- starting generator_id at 210000
-- BE_NO_NEP 2035
-- Source: ENTSOE2014a
---Description: 19:00pm values, Version 3 based on the EU longterm goals, See "Source". Original Data has been provided by ENTSO-E.

INSERT INTO model_draft.ego_grid_pf_hv_extension_generator (scn_name, generator_id, bus, p_nom, source)
VALUES('extension_BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center BE'),
	2290,
	6),
	('extension_BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center BE'),
	15590,
	1),
	('extension_BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center BE'),
	4540,
	13),
	('extension_BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center BE'),
	4000,
	17),
	('extension_BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center BE'),
	5740,
	12),
	('extension_BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT DISTINCT ON (bus_id) bus_id  FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center BE'),
	130,
	9),
	('extension_BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT DISTINCT ON (bus_id) bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center NO'),
	1300,
	1),
	('extension_BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT  DISTINCT ON (bus_id) bus_id  FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center NO'),
	5000,
	13),
	('extension_BE_NO_NEP 2035',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT DISTINCT ON (bus_id) bus_id   FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center NO'),
	37200,
	9);

UPDATE model_draft.ego_grid_pf_hv_extension_generator
SET dispatch='flexible' 
WHERE source < 9;

UPDATE model_draft.ego_grid_pf_hv_extension_generator
SET dispatch='variable' 
WHERE source > 9;

UPDATE model_draft.ego_grid_pf_hv_extension_generator
SET control='PV' 
WHERE p_nom>50;

UPDATE model_draft.ego_grid_pf_hv_extension_generator 
SET p_nom_min = 0,
p_nom_max = NULL;

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

-- import p_max_pu values from feedinlib-table
DROP MATERIALIZED VIEW IF EXISTS model_draft.extension_ren_feedin_foreign;
CREATE MATERIALIZED VIEW model_draft.extension_ren_feedin_foreign AS
SELECT
A.generator_id, B.feedin
FROM
	(SELECT
	feedin.w_id,
	CASE
		WHEN feedin.source LIKE '%%solar%%' THEN 12
		WHEN feedin.source LIKE '%%wind_onshore%%' THEN 13
	END AS source,
	feedin.feedin
	FROM 
	model_draft.ego_renewable_feedin AS feedin
	WHERE power_class IN (0, 4)
	) AS B,
	(SELECT 
	generators.generator_id,
	generators.source,
	buses.w_id
	FROM
		(SELECT
		neighbours.bus_id AS bus_id,
		weather.gid AS w_id
		FROM (SELECT * FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name IN ('center BE', 'center NO') AND scn_name = 'extension_BE_NO_NEP 2035') AS neighbours,
			climate.cosmoclmgrid AS weather
		WHERE ST_Intersects(weather.geom, neighbours.geom))
		AS buses,
	model_draft.ego_grid_pf_hv_extension_generator AS generators
	WHERE generators.bus = buses.bus_id
	AND generators.source IN (12, 13)
	AND generators.generator_id > 210000
	AND generators.scn_name = 'extension_BE_NO_NEP 2035'
	) AS A
WHERE A.w_id = B.w_id
AND A.source = B.source;

DELETE FROM model_draft.ego_grid_pf_hv_extension_generator_pq_set WHERE scn_name =  'extension_BE_NO_NEP 2035';

INSERT INTO model_draft.ego_grid_pf_hv_extension_generator_pq_set  (scn_name, temp_id, p_max_pu, generator_id)

SELECT 'extension_BE_NO_NEP 2035',1, feedin.feedin, feedin.generator_id
FROM model_draft.extension_ren_feedin_foreign AS feedin, model_draft.ego_grid_pf_hv_extension_generator AS A
WHERE A.generator_id = feedin.generator_id;

UPDATE model_draft.ego_grid_pf_hv_extension_generator_pq_set
SET p_set = p_max_pu;

-- set p_max_pu for foreign offshore generators
DROP MATERIALIZED VIEW IF EXISTS model_draft.extension_offshore_feedin_foreign;
CREATE MATERIALIZED VIEW model_draft.extension_offshore_feedin_foreign AS
SELECT
generator_id, scn_name, feedin
FROM
	(SELECT generator_id,
	bus,
	scn_name
	FROM model_draft.ego_grid_pf_hv_extension_generator
	WHERE generator_id > 210000 
	AND source = 17) 
	AS gen
		JOIN 
		(SELECT DISTINCT ON (bus_id) bus_id, 
		RIGHT(bus_name,2) AS cntr_id
		FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name IN ('center NO', 'center BE'))
		AS enb 
		ON (enb.bus_id = gen.bus)
			JOIN 
			(SELECT cntr_id,
			coastdat_id 
			FROM model_draft.ego_neighbours_offshore_point)
			AS nop 
			ON (nop.cntr_id = enb.cntr_id)
				JOIN 
				(SELECT w_id,
				feedin 
				FROM model_draft.ego_renewable_feedin)
				AS erf 
				ON (erf.w_id = nop.coastdat_id);


INSERT INTO model_draft.ego_grid_pf_hv_extension_generator_pq_set  (scn_name, temp_id, p_max_pu, generator_id)
SELECT 'extension_BE_NO_NEP 2035',1, feedin.feedin, feedin.generator_id 
FROM model_draft.extension_offshore_feedin_foreign AS feedin, model_draft.ego_grid_pf_hv_extension_generator AS A
WHERE A.generator_id = feedin.generator_id;

DELETE FROM model_draft.ego_grid_pf_hv_extension_storage WHERE scn_name = 'extension_BE_NO_NEP 2035';
DROP SEQUENCE IF EXISTS model_draft.ego_grid_hv_extension_storage_id CASCADE;
CREATE SEQUENCE model_draft.ego_grid_hv_extension_storage_id;
SELECT setval('model_draft.ego_grid_hv_extension_storage_id',210000);

-- Insert storage capacitys in Belgium and Norway
INSERT into model_draft.ego_grid_pf_hv_extension_storage (scn_name,storage_id,bus,dispatch,control,p_nom, p_nom_extendable, p_nom_min,p_min_pu_fixed,
  p_max_pu_fixed, sign, source, marginal_cost, capital_cost, efficiency, soc_initial, soc_cyclic, max_hours, efficiency_store, efficiency_dispatch, standing_loss)

  VALUES(
   'extension_BE_NO_NEP 2035', nextval('model_draft.ego_grid_hv_extension_storage_id'),
   (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus  WHERE bus_name = 'center NO'),
  'flexible','PV' ,800,FALSE,0,-1,1,1,11,0,0,1,0,true,6,0.88,0.89,0.00052
  ),

  ('extension_BE_NO_NEP 2035', nextval('model_draft.ego_grid_hv_extension_storage_id'),
  (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'center BE'),
  'flexible','PV',1890,FALSE,0,-1,1,1,11,0,0,1,0,true,6,0.88,0.89,0.00052
   );


  --- eGo 100

  --- Insert loads to the middle of belgium and norway
INSERT INTO model_draft.ego_grid_pf_hv_extension_load (scn_name, load_id, bus, sign)
VALUES 	('extension_BE_NO_eGo 100', 1000000, (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E61000003851291763E8114098865E2D305B4940' AND scn_name = 'extension_BE_NO_NEP 2035'), '-1'),
	('extension_BE_NO_eGo 100', 1000001, (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE geom = '0101000020E6100000351DBC74686A24405536F7CC1CFC4E40' AND scn_name = 'extension_BE_NO_NEP 2035'), '-1');


INSERT INTO model_draft.ego_grid_pf_hv_extension_load_pq_set (scn_name, load_id, temp_id, p_set, q_set)
SELECT 'extension_BE_NO_eGo 100' , load_id, temp_id, p_set, q_set
FROM model_draft.ego_grid_pf_hv_extension_load_pq_set WHERE scn_name = 'extension_BE_NO_NEP 2035';

	 
-- INSERT generator capacities
-- starting generator_id at 210000
-- BE_NO_NEP 2035
-- Source: eHighway 2050
---Description: 100% RES scenario
DELETE FROM model_draft.ego_grid_pf_hv_extension_generator WHERE scn_name = 'extension_BE_NO_eGo 100';
INSERT INTO model_draft.ego_grid_pf_hv_extension_generator (scn_name, generator_id, bus, p_nom, source)
VALUES('extension_BE_NO_eGo 100',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center BE' AND scn_name = 'extension_BE_NO_eGo 100'),
	4750,
	6),
	('extension_BE_NO_eGo 100',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center BE' AND scn_name = 'extension_BE_NO_eGo 100'),
	2500,
	1),
	('extension_BE_NO_eGo 100',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center BE' AND scn_name = 'extension_BE_NO_eGo 100'),
	10903,
	13),
	('extension_BE_NO_eGo 100',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center BE' AND scn_name = 'extension_BE_NO_eGo 100'),
	3000,
	17),
	('extension_BE_NO_eGo 100',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center BE' AND scn_name = 'extension_BE_NO_eGo 100'),
	24087,
	12),
	('extension_BE_NO_eGo 100',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center BE' AND scn_name = 'extension_BE_NO_eGo 100'),
	332,
	9),
	('extension_BE_NO_eGo 100',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center NO' AND scn_name = 'extension_BE_NO_eGo 100'),
	3000,
	17),
	('extension_BE_NO_eGo 100',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center NO' AND scn_name = 'extension_BE_NO_eGo 100'),
	12175,
	13),
	('extension_BE_NO_eGo 100',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center NO' AND scn_name = 'extension_BE_NO_eGo 100'),
	5364,
	12),
	('extension_BE_NO_eGo 100',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center NO' AND scn_name = 'extension_BE_NO_eGo 100'),
	28414,
	9),
	('extension_BE_NO_eGo 100',
	nextval('model_draft.ego_grid_hv_extension_generator_id'), 
	(SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name='center NO' AND scn_name = 'extension_BE_NO_eGo 100'),
	42473,
	10);

UPDATE model_draft.ego_grid_pf_hv_extension_generator
SET p_min_pu_fixed = 0.65
WHERE source = 9;

UPDATE model_draft.ego_grid_pf_hv_extension_generator
SET dispatch='flexible' 
WHERE source < 9;

UPDATE model_draft.ego_grid_pf_hv_extension_generator
SET dispatch='variable' 
WHERE source > 9;

UPDATE model_draft.ego_grid_pf_hv_extension_generator
SET control='PV' 
WHERE p_nom>50;

UPDATE model_draft.ego_grid_pf_hv_extension_generator 
SET p_nom_min = 0,
p_nom_max = NULL;

UPDATE model_draft.ego_grid_pf_hv_extension_generator
SET marginal_cost =        -- operating costs + fuel costs + CO2 crt cost
(
CASE source                 -- source / renpass_gis NEP 2014
when 1 THEN (56.06) -- gas / gas
when 6 THEN (31.63) -- biomass / biomass
ELSE 0                      -- run_of_river/reservoir/pumped_storage/solar/wind/geothermal/other_non_renewable
END)
WHERE scn_name = 'extension_BE_NO_eGo 100';


DROP MATERIALIZED VIEW IF EXISTS model_draft.extension_ren_feedin_foreign;
CREATE MATERIALIZED VIEW model_draft.extension_ren_feedin_foreign AS
SELECT
A.generator_id, B.feedin
FROM
	(SELECT
	feedin.w_id,
	CASE
		WHEN feedin.source LIKE '%%solar%%' THEN 12
		WHEN feedin.source LIKE '%%wind_onshore%%' THEN 13
	END AS source,
	feedin.feedin
	FROM 
	model_draft.ego_renewable_feedin AS feedin
	WHERE power_class IN (0, 4)
	) AS B,
	(SELECT 
	generators.generator_id,
	generators.source,
	buses.w_id
	FROM
		(SELECT
		neighbours.bus_id AS bus_id,
		weather.gid AS w_id
		FROM (SELECT * FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name IN ('center BE', 'center NO')  AND scn_name = 'extension_BE_NO_eGo 100') AS neighbours,
			climate.cosmoclmgrid AS weather
		WHERE ST_Intersects(weather.geom, neighbours.geom))
		AS buses,
	model_draft.ego_grid_pf_hv_extension_generator AS generators
	WHERE generators.bus = buses.bus_id
	AND generators.source IN (12, 13)
	AND generators.scn_name = 'extension_BE_NO_eGo 100'
	) AS A
WHERE A.w_id = B.w_id
AND A.source = B.source;

DELETE FROM model_draft.ego_grid_pf_hv_extension_generator_pq_set WHERE scn_name = 'extension_BE_NO_eGo 100';

INSERT INTO model_draft.ego_grid_pf_hv_extension_generator_pq_set  (scn_name, temp_id, p_max_pu, generator_id)
SELECT 'extension_BE_NO_eGo 100',1, feedin.feedin, feedin.generator_id
FROM model_draft.extension_ren_feedin_foreign AS feedin, model_draft.ego_grid_pf_hv_extension_generator AS A
WHERE A.generator_id = feedin.generator_id;


DROP MATERIALIZED VIEW IF EXISTS model_draft.extension_offshore_feedin_foreign;
CREATE MATERIALIZED VIEW model_draft.extension_offshore_feedin_foreign AS
SELECT
generator_id, scn_name, feedin
FROM
	(SELECT generator_id,
	bus,
	scn_name
	FROM model_draft.ego_grid_pf_hv_extension_generator
	WHERE generator_id > 210000 
	AND source = 17
	AND scn_name='extension_BE_NO_eGo 100') 
	AS gen
		JOIN 
		(SELECT bus_id, 
		RIGHT(bus_name,2) AS cntr_id
		FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name IN ('center NO', 'center BE') AND scn_name='extension_BE_NO_eGo 100')
		AS enb 
		ON (enb.bus_id = gen.bus)
			JOIN 
			(SELECT cntr_id,
			coastdat_id 
			FROM model_draft.ego_neighbours_offshore_point)
			AS nop 
			ON (nop.cntr_id = enb.cntr_id)
				JOIN 
				(SELECT w_id,
				feedin 
				FROM model_draft.ego_renewable_feedin)
				AS erf 
				ON (erf.w_id = nop.coastdat_id);


INSERT INTO model_draft.ego_grid_pf_hv_extension_generator_pq_set  (scn_name, temp_id, p_max_pu, generator_id)
SELECT 'extension_BE_NO_eGo 100',1, feedin.feedin, feedin.generator_id 
FROM model_draft.extension_offshore_feedin_foreign AS feedin, model_draft.ego_grid_pf_hv_extension_generator AS A
WHERE A.generator_id = feedin.generator_id;

UPDATE model_draft.ego_grid_pf_hv_extension_generator_pq_set
SET p_set = p_max_pu;


DELETE FROM model_draft.ego_grid_pf_hv_extension_storage WHERE scn_name = 'extension_BE_NO_eGo 100';
-- Insert storage capacitys in Belgium and Norway
INSERT into model_draft.ego_grid_pf_hv_extension_storage (scn_name, storage_id, bus, dispatch, control, p_nom,
  sign, source, marginal_cost, capital_cost, efficiency, soc_initial, soc_cyclic, max_hours, efficiency_store, efficiency_dispatch, standing_loss)
  
VALUES('extension_BE_NO_eGo 100',nextval('model_draft.ego_grid_hv_extension_storage_id'),
  (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'center NO' AND scn_name = 'extension_BE_NO_eGo 100'),
  'flexible','PV',17291,1,11,0,0,1,0,true,6,0.88,0.89,0.00052), ---PSP Norway

  ('extension_BE_NO_eGo 100',nextval('model_draft.ego_grid_hv_extension_storage_id'),
  (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'center BE' AND scn_name = 'extension_BE_NO_eGo 100'),
  'flexible','PV',2308,1,11,0,0,1,0,true,6,0.88,0.89,0.00052), -- PSP Belgium

  ('extension_BE_NO_eGo 100',nextval('model_draft.ego_grid_hv_extension_storage_id'),
  (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'center BE' AND scn_name = 'extension_BE_NO_eGo 100'),
  'flexible','PV', 1807.41,1,18,0,0,1,0,true,168,0.785,0.57,0.000694), -- Hydro Belgium

  ('extension_BE_NO_eGo 100',nextval('model_draft.ego_grid_hv_extension_storage_id'),
  (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'center NO' AND scn_name = 'extension_BE_NO_eGo 100'),
  'flexible','PV', 0.08,1,19,0,0,1,0,true,6,0.9487,0.9487,0.000417), -- Battery Norway

  ('extension_BE_NO_eGo 100',nextval('model_draft.ego_grid_hv_extension_storage_id'),
  (SELECT bus_id FROM model_draft.ego_grid_pf_hv_extension_bus WHERE bus_name = 'center BE' AND scn_name = 'extension_BE_NO_eGo 100'),
  'flexible','PV',328.29 ,1,19,0,0,1,0,true,6,0.9487,0.9487,0.000417); -- Battery Beligum
  
  