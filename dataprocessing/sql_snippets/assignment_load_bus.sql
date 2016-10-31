DROP TABLE IF EXISTS calc_ego_loads.loads_total CASCADE;

CREATE TABLE calc_ego_loads.loads_total
(
  un_id serial NOT NULL, 
  ssc_id integer, 
  lsc_id integer,
  geom geometry(MultiPolygon,3035),
  CONSTRAINT generators_total_pkey PRIMARY KEY (un_id)
);

ALTER TABLE calc_ego_loads.loads_total
	OWNER TO oeuser;
	
DELETE FROM calc_ego_loads.loads_total; 

INSERT INTO calc_ego_loads.loads_total (ssc_id, geom) 
	SELECT id, ST_Multi(geom)
	FROM calc_ego_loads.ego_deu_consumption; 

INSERT INTO calc_ego_loads.loads_total (lsc_id, geom) 
	SELECT id, geom
	FROM calc_ego_loads.large_scale_consumer; 

CREATE INDEX loads_total_idx
  ON calc_ego_loads.loads_total
  USING gist
  (geom);


COMMENT ON TABLE  calc_ego_loads.loads_total IS
'{
"Name": "Merged loads",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "20. October 2016",
"Original file": "assignment_load_bus.sql",
"Spatial resolution": ["Germany"],
"Description": ["Unique identifier are assigned to loads from different voltage levels"],
"Column": [
                   {"Name": "un_id",
                    "Description": "unique identifier",
                    "Unit": "" },
                   {"Name": "ssc_id",
                    "Description": "id for small scale consumer",
                    "Unit": "" },
                   {"Name": "lsc_id",
                    "Description": "id for large scale consumer",
                    "Unit": "" },
                   {"Name": "geom",
                    "Description": "geometry",
                    "Unit": "" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 

                   {"Name": "IlkaCussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json string" }
                  ],
"ToDo": ["Add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';




-----
-- Create table to assign single load areas to a bus
-----
DROP TABLE IF EXISTS calc_ego_loads.pf_load_single CASCADE;

CREATE TABLE calc_ego_loads.pf_load_single
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  load_id bigint NOT NULL, -- Unit: n/a...
  bus bigint, -- Unit: n/a...
  sign double precision DEFAULT (-1), -- Unit: n/a...
  e_annual double precision, -- Unit: MW...
  CONSTRAINT load_data_pkey PRIMARY KEY (load_id),
  CONSTRAINT load_data_bus_fk FOREIGN KEY (bus, scn_name)
      REFERENCES calc_ego_hv_powerflow.bus (bus_id, scn_name) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE calc_ego_hv_powerflow.load
  OWNER TO oeuser;

-----------
-- Add un_id to load tables
-----------


-- Add un_id for small scale consumer (ssc) 

UPDATE calc_ego_loads.ego_deu_consumption a
	SET un_id = b.un_id 
	FROM calc_ego_loads.loads_total b
	WHERE a.id = b.ssc_id; 

-- Add un_id for large scale consumer (lsc)

UPDATE calc_ego_loads.large_scale_consumer a
	SET un_id = b.un_id 
	FROM calc_ego_loads.loads_total b
	WHERE a.id = b.lsc_id; 

-------------
-- Insert load data into powerflow schema, that contains all generators seperately 
-------------

-- Add data for small scale consumer to pf_load_single 


INSERT INTO calc_ego_loads.pf_load_single (load_id, bus, e_annual)
	SELECT un_id, otg_id, (sector_consumption_residential+sector_consumption_retail+sector_consumption_industrial+sector_consumption_agricultural)
	FROM calc_ego_loads.ego_deu_consumption; 

-- Add data for large scale consumer to pf_load_single 

INSERT INTO calc_ego_loads.pf_load_single (load_id, bus, e_annual)
	SELECT un_id, otg_id, consumption
	FROM calc_ego_loads.large_scale_consumer; 


COMMENT ON TABLE  calc_ego_loads.pf_load_single IS
'{
"Name": "Single loads for powerflow",
"Source": [{
                  "Name": "open_eGo data-processing",
                  "URL":  "https://github.com/openego/data_processing" }],
"Reference date": "2016",
"Date of collection": "20. October 2016",
"Original file": "assignment_load_bus.sql",
"Spatial resolution": ["Germany"],
"Description": ["non aggregated loads powerflow-ready"],
"Column": [
                   {"Name": "scn_name",
                    "Description": "name of scenario",
                    "Unit": "" },
                   {"Name": "load_id",
                    "Description": "id for single load",
                    "Unit": "" },
                   {"Name": "bus",
                    "Description": "id of associated bus",
                    "Unit": "" },
                   {"Name": "sign",
                    "Description": "power sign - negative for loads",
                    "Unit": "" },
                   {"Name": "e_annual",
                    "Description": "annual electricity consumption",
                    "Unit": "GWh" }],
"Changes":[
                   {"Name": "Mario Kropshofer",
                    "Mail": "mario.kropshofer2@stud.fh-flensburg.de",
                    "Date":  "04.10.2016",
                    "Comment": "..." }, 
                   {"Name": "Ilka Cussmann",
                    "Mail": "ilka.cussmann@hs-flensburg.de",
                    "Date":  "26.10.2016",
                    "Comment": "completed json-string" }
                  ],
"ToDo": ["add licence"],
"Licence": ["..."],
"Instructions for proper use": ["..."]
}';


-------------
-- Aggregate load per bus and insert into hv_powerflow schema 
-------------

INSERT INTO calc_ego_hv_powerflow.load (e_annual, load_id, bus)
SELECT sum(e_annual), bus, bus 
FROM calc_ego_loads.pf_load_single a
WHERE a.bus IS NOT NULL
GROUP BY a.bus;

-- Scenario eGo data processing
INSERT INTO	scenario.eGo_data_processing_clean_run (version,schema_name,table_name,script_name,entries,status,timestamp)
	SELECT	'0.2' AS version,
		'calc_ego_hv_powerflow' AS schema_name,
		'load' AS table_name,
		'assignment_load_bus.sql' AS script_name,
		COUNT(load_id)AS entries,
		'OK' AS status,
		NOW() AT TIME ZONE 'Europe/Berlin' AS timestamp
FROM	calc_ego_hv_powerflow.load;
