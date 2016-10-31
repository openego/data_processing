DROP TABLE IF EXISTS model_draft.ego_demand_loads CASCADE;

CREATE TABLE model_draft.ego_demand_loads
(
  un_id serial NOT NULL, 
  ssc_id integer, 
  lsc_id integer,
  geom geometry(MultiPolygon,3035),
  CONSTRAINT generators_total_pkey PRIMARY KEY (un_id)
);

ALTER TABLE model_draft.ego_demand_loads
	OWNER TO oeuser;
	
DELETE FROM model_draft.ego_demand_loads; 

INSERT INTO model_draft.ego_demand_loads (ssc_id, geom) 
	SELECT id, ST_Multi(geom)
	FROM model_draft.ego_demand_per_load_area; 

INSERT INTO model_draft.ego_demand_loads (lsc_id, geom) 
	SELECT id, geom
	FROM model_draft.ego_demand_hv_largescaleconsumer; 

CREATE INDEX loads_total_idx
  ON model_draft.ego_demand_loads
  USING gist
  (geom);


COMMENT ON TABLE  model_draft.ego_demand_loads IS
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
DROP TABLE IF EXISTS model_draft.ego_demand_pf_load_single CASCADE;

CREATE TABLE model_draft.ego_demand_pf_load_single
(
  scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying,
  load_id bigint NOT NULL, -- Unit: n/a...
  bus bigint, -- Unit: n/a...
  sign double precision DEFAULT (-1), -- Unit: n/a...
  e_annual double precision, -- Unit: MW...
  CONSTRAINT load_data_pkey PRIMARY KEY (load_id),
  CONSTRAINT load_data_bus_fk FOREIGN KEY (bus, scn_name)
      REFERENCES model_draft.ego_grid_pf_hv_bus (bus_id, scn_name) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE model_draft.ego_grid_pf_hv_load
  OWNER TO oeuser;

-----------
-- Add un_id to load tables
-----------


-- Add un_id for small scale consumer (ssc) 

UPDATE model_draft.ego_demand_per_load_area a
	SET un_id = b.un_id 
	FROM model_draft.ego_demand_loads b
	WHERE a.id = b.ssc_id; 

-- Add un_id for large scale consumer (lsc)

UPDATE model_draft.ego_demand_hv_largescaleconsumer a
	SET un_id = b.un_id 
	FROM model_draft.ego_demand_loads b
	WHERE a.id = b.lsc_id; 

-------------
-- Insert load data into powerflow schema, that contains all generators seperately 
-------------

-- Add data for small scale consumer to pf_load_single 


INSERT INTO model_draft.ego_demand_pf_load_single (load_id, bus, e_annual)
	SELECT un_id, otg_id, (sector_consumption_residential+sector_consumption_retail+sector_consumption_industrial+sector_consumption_agricultural)
	FROM model_draft.ego_demand_per_load_area; 

-- Add data for large scale consumer to pf_load_single 

INSERT INTO model_draft.ego_demand_pf_load_single (load_id, bus, e_annual)
	SELECT un_id, otg_id, consumption
	FROM model_draft.ego_demand_hv_largescaleconsumer; 


COMMENT ON TABLE  model_draft.ego_demand_pf_load_single IS
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

INSERT INTO model_draft.ego_grid_pf_hv_load (e_annual, load_id, bus)
SELECT sum(e_annual), bus, bus 
FROM model_draft.ego_demand_pf_load_single a
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
FROM	model_draft.ego_grid_pf_hv_load;
