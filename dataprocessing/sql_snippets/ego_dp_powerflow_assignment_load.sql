/*
Similar to generators in the previous script the data on loads are converted and clustered to fit the data structure
needed for powerflow calculations. The electricity demand of small scale consumer and industrial large scale consumer is
considered. 

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

DROP TABLE IF EXISTS model_draft.ego_demand_loads CASCADE;

CREATE TABLE model_draft.ego_demand_loads
(
  un_id serial NOT NULL, 
  ssc_id integer, 
  lsc_id integer,
  geom geometry(MultiPolygon,3035),
  CONSTRAINT loads_total_pkey PRIMARY KEY (un_id)
);

ALTER TABLE model_draft.ego_demand_loads
	OWNER TO oeuser;
	
DELETE FROM model_draft.ego_demand_loads; 

INSERT INTO model_draft.ego_demand_loads (ssc_id, geom) 
	SELECT id, ST_Multi(geom)
	FROM model_draft.ego_demand_loadarea; 

INSERT INTO model_draft.ego_demand_loads (lsc_id, geom) 
	SELECT polygon_id, geom
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
"Original file": "ego_dp_powerflow_assignment_load.sql",
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
                    "Mail": "",
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
  CONSTRAINT load_single_pkey PRIMARY KEY (load_id),
  CONSTRAINT load_data_bus_fk FOREIGN KEY (bus, scn_name)
      REFERENCES model_draft.ego_grid_pf_hv_bus (bus_id, scn_name) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE model_draft.ego_demand_pf_load_single
  OWNER TO oeuser;



-----------
-- Add un_id to load tables
-----------


-- Add un_id for small scale consumer (ssc) -- WARNING: THIS IS A VIEW AND NOT loadarea @ILKA
UPDATE model_draft.ego_demand_loadarea a
	SET un_id = b.un_id 
	FROM model_draft.ego_demand_loads b
	WHERE a.id = b.ssc_id; 

-- Add un_id for large scale consumer (lsc)
UPDATE model_draft.ego_demand_hv_largescaleconsumer a
	SET un_id = b.un_id 
	FROM model_draft.ego_demand_loads b
	WHERE a.polygon_id = b.lsc_id; 

-------------
-- Insert load data into powerflow schema, that contains all loads seperately 
-------------

-- Add data for small scale consumer to pf_load_single 


INSERT INTO model_draft.ego_demand_pf_load_single (load_id, bus, e_annual)
	SELECT un_id, otg_id, sector_consumption_sum
	FROM model_draft.ego_demand_loadarea; 

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
"Original file": "ego_dp_powerflow_assignment_load.sql",
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
                    "Mail": "",
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

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.4','output','model_draft','ego_grid_pf_hv_load','ego_dp_powerflow_assignment_load.sql',' ');



-------------
-- Add information for future scenarios to hv_powerflow schema under the assumption that the consumption remains constant 
-------------

-- Loads in scenario 'NEP 2035' are equivalent to 'Status Quo'

DELETE FROM model_draft.ego_grid_pf_hv_load WHERE scn_name = 'NEP 2035'; 

INSERT INTO model_draft.ego_grid_pf_hv_load
SELECT 'NEP 2035', a.load_id, a.bus, a.sign, a.e_annual
FROM model_draft.ego_grid_pf_hv_load a
WHERE scn_name= 'Status Quo'; 

-- Loads in scenario 'eGo 100' are equivalent to 'Status Quo'

DELETE FROM model_draft.ego_grid_pf_hv_load WHERE scn_name = 'eGo 100'; 

INSERT INTO model_draft.ego_grid_pf_hv_load
SELECT 'eGo 100', a.load_id, a.bus, a.sign, a.e_annual
FROM model_draft.ego_grid_pf_hv_load a
WHERE scn_name= 'Status Quo'; 

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.4','output','model_draft','ego_grid_pf_hv_load','ego_dp_powerflow_assignment_load_nep2035.sql',' ');
