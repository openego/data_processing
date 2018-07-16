/*
This script provides a data check for the PF data set generated by the open_eGo data processing. 

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/




DROP TABLE IF EXISTS 	model_draft.ego_grid_pf_hv_data_check; 

CREATE TABLE 		model_draft.ego_grid_pf_hv_data_check (
     test_id serial,
     version character varying NOT NULL, 
     scn_name character varying NOT NULL,
     test character varying,
     table_name character varying,   
     count int, 
     CONSTRAINT hv_data_check_pkey PRIMARY KEY (version, scn_name, test)); 

ALTER TABLE 		model_draft.ego_grid_pf_hv_data_check
     owner to oeuser;  


-------------------
-- grid topology 
-------------------


-- Do all lines have defined buses in all three scenarios? 


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'lines with undefined buses',
   'model_draft.ego_grid_pf_hv_line',
   count(*) FROM model_draft.ego_grid_pf_hv_line 
      WHERE scn_name = 'Status Quo' AND 
       (bus0 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo') OR 
        bus1 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo')); 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'lines with undefined buses',
   'model_draft.ego_grid_pf_hv_line',
   count(*) FROM model_draft.ego_grid_pf_hv_line 
      WHERE scn_name = 'NEP 2035' AND 
       (bus0 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'NEP 2035') OR 
        bus1 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'NEP 2035')); 


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'lines with undefined buses',
   'model_draft.ego_grid_pf_hv_line',
   count(*) FROM model_draft.ego_grid_pf_hv_line 
      WHERE scn_name = 'eGo 100' AND 
       (bus0 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'eGo 100') OR 
        bus1 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'eGo 100')); 

-- Do any lines have NULL values in the bus columns? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'lines with NULL values for buses',
   'model_draft.ego_grid_pf_hv_line',
   count(*) FROM model_draft.ego_grid_pf_hv_line 
      WHERE scn_name = 'Status Quo' AND 
       (bus0 IS NULL OR 
        bus1 IS NULL); 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'lines with NULL values for buses',
   'model_draft.ego_grid_pf_hv_line',
   count(*) FROM model_draft.ego_grid_pf_hv_line 
      WHERE scn_name = 'NEP 2035' AND 
       (bus0 IS NULL OR 
        bus1 IS NULL); 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'lines with NULL values for buses',
   'model_draft.ego_grid_pf_hv_line',
   count(*) FROM model_draft.ego_grid_pf_hv_line 
      WHERE scn_name = 'eGo 100' AND 
       (bus0 IS NULL OR 
        bus1 IS NULL); 




-- Do all lines have defined buses in all three scenarios? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'transformers with undefined buses',
   'model_draft.ego_grid_pf_hv_transformer',
   count(*) FROM model_draft.ego_grid_pf_hv_transformer 
      WHERE scn_name = 'Status Quo' AND 
       (bus0 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo') OR 
        bus1 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo')); 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'transformers with undefined buses',
   'model_draft.ego_grid_pf_hv_transformer',
   count(*) FROM model_draft.ego_grid_pf_hv_transformer 
      WHERE scn_name = 'NEP 2035' AND 
       (bus0 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'NEP 2035') OR 
        bus1 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'NEP 2035')); 


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'transformers with undefined buses',
   'model_draft.ego_grid_pf_hv_transformer',
   count(*) FROM model_draft.ego_grid_pf_hv_transformer 
      WHERE scn_name = 'eGo 100' AND 
       (bus0 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'eGo 100') OR 
        bus1 NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'eGo 100')); 


-- Do any transformers have NULL values in the bus columns? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'transformers with NULL values for buses'
   'model_draft.ego_grid_pf_hv_transformer',,
   count(*) FROM model_draft.ego_grid_pf_hv_transformer 
      WHERE scn_name = 'Status Quo' AND 
       (bus0 IS NULL OR 
        bus1 IS NULL); 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'transformers with NULL values for buses',
   'model_draft.ego_grid_pf_hv_transformer',
   count(*) FROM model_draft.ego_grid_pf_hv_transformer
      WHERE scn_name = 'NEP 2035' AND 
       (bus0 IS NULL OR 
        bus1 IS NULL); 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'transformers with NULL values for buses',
   'model_draft.ego_grid_pf_hv_transformer',
   count(*) FROM model_draft.ego_grid_pf_hv_transformer 
      WHERE scn_name = 'eGo 100' AND 
       (bus0 IS NULL OR 
        bus1 IS NULL);


-- Are any EHV substations mistakenly assigned to 110 kV level in the final data model? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'EHV substation as 110 kV bus', 
   'model_draft.ego_grid_pf_hv_bus',
   count(*) FROM model_draft.ego_grid_pf_hv_bus 
      WHERE scn_name = 'Status Quo' AND 
	v_nom >110 AND 
        bus_id IN (SELECT otg_id FROM model_draft.ego_grid_hvmv_substation); 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'EHV substation as 110 kV bus', 
   'model_draft.ego_grid_pf_hv_bus',
   count(*) FROM model_draft.ego_grid_pf_hv_bus 
      WHERE scn_name = 'NEP 2035' AND 
	v_nom >110 AND 
        bus_id IN (SELECT otg_id FROM model_draft.ego_grid_hvmv_substation); 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'EHV substation as 110 kV bus', 
   'model_draft.ego_grid_pf_hv_bus',
   count(*) FROM model_draft.ego_grid_pf_hv_bus 
      WHERE scn_name = 'eGo 100' AND 
	v_nom >110 AND 
        bus_id IN (SELECT otg_id FROM model_draft.ego_grid_hvmv_substation); 

-------------------
-- generators and time series 
-------------------

-- Do all generators have defined buses? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'generators without defined buses',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_grid_pf_hv_generator
       WHERE scn_name = 'Status Quo' AND 
       (bus NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo') 
	OR bus IS NULL); 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'generators without defined buses',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_grid_pf_hv_generator
       WHERE scn_name = 'NEP 2035' AND 
       (bus NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'NEP 2035') 
	OR bus IS NULL); 


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'generators without defined buses',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_grid_pf_hv_generator
       WHERE scn_name = 'eGo 100' AND 
       (bus NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'eGo 100') 
	OR bus IS NULL); 


-- Do all generators in table pf_generator_single have an otg_id assigned? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'pf_generator_single without defined buses',
   'model_draft.ego_supply_pf_generator_single',
   count(*) FROM model_draft.ego_supply_pf_generator_single
       WHERE scn_name = 'Status Quo' AND 
       otg_id IS NULL; 


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'pf_generator_single without defined buses',
   'model_draft.ego_supply_pf_generator_single',
   count(*) FROM model_draft.ego_supply_pf_generator_single
       WHERE scn_name = 'NEP 2035' AND 
       otg_id IS NULL; 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'pf_generator_single without defined buses',
   'model_draft.ego_supply_pf_generator_single',
   count(*) FROM model_draft.ego_supply_pf_generator_single
       WHERE scn_name = 'eGo 100' AND 
       otg_id IS NULL; 

-- Do all generators which are not 'reservoir', 'geothermal' or 'other_non_renewable' have defined timeseries in all three scenarios? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'generators (source != 14, 15, 10) without time series',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_grid_pf_hv_generator 
       WHERE scn_name = 'Status Quo' AND 
       generator_id NOT IN (SELECT generator_id FROM model_draft.ego_grid_pf_hv_generator_pq_set WHERE scn_name = 'Status Quo') AND 
       source NOT IN (14, 15, 10); 


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'generators (source != 14, 15, 10) without time series',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_grid_pf_hv_generator 
       WHERE scn_name = 'NEP 2035' AND 
       generator_id NOT IN (SELECT generator_id FROM model_draft.ego_grid_pf_hv_generator_pq_set WHERE scn_name = 'NEP 2035') AND 
       source NOT IN (14, 15, 10); 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'generators (source != 14, 15, 10) without time series',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_grid_pf_hv_generator 
       WHERE scn_name = 'eGo 100' AND 
       generator_id NOT IN (SELECT generator_id FROM model_draft.ego_grid_pf_hv_generator_pq_set WHERE scn_name = 'eGo 100') AND 
       source NOT IN (14, 15, 10); 

-- Do all generator time series have defined generators in the data model? 


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'time series without defined generators',
   'model_draft.ego_grid_pf_hv_generator_pq_set',
   count(*) FROM model_draft.ego_grid_pf_hv_generator_pq_set 
       WHERE scn_name = 'Status Quo' AND 
       (generator_id NOT IN (SELECT generator_id FROM model_draft.ego_grid_pf_hv_generator WHERE scn_name = 'Status Quo') 
	OR generator_id IS NULL); 



INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'time series without defined generators',
   'model_draft.ego_grid_pf_hv_generator_pq_set',
   count(*) FROM model_draft.ego_grid_pf_hv_generator_pq_set 
       WHERE scn_name = 'NEP 2035' AND 
       (generator_id NOT IN (SELECT generator_id FROM model_draft.ego_grid_pf_hv_generator WHERE scn_name = 'NEP 2035')
       OR generator_id IS NULL);


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'time series without defined generators',
   'model_draft.ego_grid_pf_hv_generator_pq_set',
   count(*) FROM model_draft.ego_grid_pf_hv_generator_pq_set 
       WHERE scn_name = 'eGo 100' AND 
       (generator_id NOT IN (SELECT generator_id FROM model_draft.ego_grid_pf_hv_generator WHERE scn_name = 'eGo 100')
       OR generator_id IS NULL); 

-- Do any generators have timeseries with more than 8760 entries? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'generator time series with more than 8760 entries',
   'model_draft.ego_grid_pf_hv_generator_pq_set',
   count(*) FROM model_draft.ego_grid_pf_hv_generator_pq_set 
       WHERE array_length(p_set, 1) > 8760 AND scn_name = 'Status Quo';


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'generator time series with more than 8760 entries',
   'model_draft.ego_grid_pf_hv_generator_pq_set',
   count(*) FROM model_draft.ego_grid_pf_hv_generator_pq_set 
       WHERE array_length(p_set, 1) > 8760 AND scn_name = 'NEP 2035';


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'generator time series with more than 8760 entries',
   'model_draft.ego_grid_pf_hv_generator_pq_set',
   count(*) FROM model_draft.ego_grid_pf_hv_generator_pq_set 
       WHERE array_length(p_set, 1) > 8760 AND scn_name = 'eGo 100';


-- Is the control set for all generators complete? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'generator control incomplete',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_grid_pf_hv_generator
       WHERE control IS NULL AND scn_name = 'Status Quo';

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'generator control incomplete',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_grid_pf_hv_generator
       WHERE control IS NULL AND scn_name = 'NEP 2035';

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'generator control incomplete',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_grid_pf_hv_generator
       WHERE control IS NULL AND scn_name = 'eGo 100';


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'all',
   'generator control incomplete',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_supply_pf_generator_single
       WHERE control IS NULL;


-- Are there any generators without source? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'generator source incomplete',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_grid_pf_hv_generator
       WHERE source IS NULL AND scn_name = 'Status Quo';

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'generator source incomplete',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_grid_pf_hv_generator
       WHERE source IS NULL AND scn_name = 'NEP 2035';

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'generator source incomplete',
   'model_draft.ego_grid_pf_hv_generator',
   count(*) FROM model_draft.ego_grid_pf_hv_generator
       WHERE source IS NULL AND scn_name = 'eGo 100';


-------------------
-- loads and time series 
-------------------

-- Do all loads have defined buses? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'loads without defined buses',
   'model_draft.ego_grid_pf_hv_load',
   count(*) FROM model_draft.ego_grid_pf_hv_load
       WHERE scn_name = 'Status Quo' AND 
       (bus NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'Status Quo') 
	OR bus IS NULL); 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'loads without defined buses',
   'model_draft.ego_grid_pf_hv_load',
   count(*) FROM model_draft.ego_grid_pf_hv_load
       WHERE scn_name = 'NEP 2035' AND 
       (bus NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'NEP 2035') 
	OR bus IS NULL); 


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'loads without defined buses',
   'model_draft.ego_grid_pf_hv_load',
   count(*) FROM model_draft.ego_grid_pf_hv_load
       WHERE scn_name = 'eGo 100' AND 
       (bus NOT IN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE scn_name = 'eGo 100') 
	OR bus IS NULL); 


-- Do all loads have defined timeseries in all three scenarios? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'loads without time series',
   'model_draft.ego_grid_pf_hv_load',
   count(*) FROM model_draft.ego_grid_pf_hv_load 
       WHERE scn_name = 'Status Quo' AND 
       load_id NOT IN (SELECT load_id FROM model_draft.ego_grid_pf_hv_load_pq_set WHERE scn_name = 'Status Quo'); 


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'loads without time series',
   'model_draft.ego_grid_pf_hv_load',
   count(*) FROM model_draft.ego_grid_pf_hv_load 
       WHERE scn_name = 'NEP 2035' AND 
       load_id NOT IN (SELECT load_id FROM model_draft.ego_grid_pf_hv_load_pq_set WHERE scn_name = 'NEP 2035'); 


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'loads without time series',
   'model_draft.ego_grid_pf_hv_load',
   count(*) FROM model_draft.ego_grid_pf_hv_load 
       WHERE scn_name = 'eGo 100' AND 
       load_id NOT IN (SELECT load_id FROM model_draft.ego_grid_pf_hv_load_pq_set WHERE scn_name = 'eGo 100'); 

-- Do all load time series have defined loads in the data model? 


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'time series without defined loads',
   'model_draft.ego_grid_pf_hv_load_pq_set',
   count(*) FROM model_draft.ego_grid_pf_hv_load_pq_set 
       WHERE scn_name = 'Status Quo' AND 
       (load_id NOT IN (SELECT load_id FROM model_draft.ego_grid_pf_hv_load WHERE scn_name = 'Status Quo') 
	OR load_id IS NULL); 



INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'time series without defined loads',
   'model_draft.ego_grid_pf_hv_load_pq_set',
   count(*) FROM model_draft.ego_grid_pf_hv_load_pq_set 
       WHERE scn_name = 'NEP 2035' AND 
       (load_id NOT IN (SELECT load_id FROM model_draft.ego_grid_pf_hv_load WHERE scn_name = 'NEP 2035')
       OR load_id IS NULL);


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'time series without defined loads',
   'model_draft.ego_grid_pf_hv_load_pq_set',
   count(*) FROM model_draft.ego_grid_pf_hv_load_pq_set 
       WHERE scn_name = 'eGo 100' AND 
       (load_id NOT IN (SELECT load_id FROM model_draft.ego_grid_pf_hv_load WHERE scn_name = 'eGo 100')
       OR load_id IS NULL); 

-- Do any loads have timeseries with more than 8760 entries? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'Status Quo',
   'load time series with more than 8760 entries',
   'model_draft.ego_grid_pf_hv_load_pq_set',
   count(*) FROM model_draft.ego_grid_pf_hv_load_pq_set 
       WHERE array_length(p_set, 1) > 8760 AND scn_name = 'Status Quo';


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'NEP 2035',
   'load time series with more than 8760 entries',
   'model_draft.ego_grid_pf_hv_load_pq_set',
   count(*) FROM model_draft.ego_grid_pf_hv_load_pq_set 
       WHERE array_length(p_set, 1) > 8760 AND scn_name = 'NEP 2035';


INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'eGo 100',
   'load time series with more than 8760 entries',
   'model_draft.ego_grid_pf_hv_load_pq_set',
   count(*) FROM model_draft.ego_grid_pf_hv_load_pq_set 
       WHERE array_length(p_set, 1) > 8760 AND scn_name = 'eGo 100';

----------------
-- REA 
----------------

-- Were all renewable generators reallocated by the REA scripts? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'all',
   'generators without rea_geom_new',
   'model_draft.ego_dp_supply_res_powerplant',
   count(*) FROM model_draft_ego_dp_supply_res_powerplant
    	WHERE rea_geom_new IS NULL; 


----------------
-- MV grid districts
----------------

-- Are there any mv grid districts without assigned generators? 

INSERT INTO model_draft.ego_grid_pf_hv_data_check (version, scn_name, test, table_name, count)
   SELECT 
   'v0.4.2',
   'all',
   'mv grid districts without generators', 
   'model_draft.ego_grid_mv_griddistrict', 
   count(*) FROM model_draft.ego_grid_mv_griddistrict 
	WHERE subst_id NOT IN 
	  (SELECT subst_id FROM model_draft.ego_grid_hvmv_substation WHERE otg_id IN 
	    (SELECT bus FROM model_draft.ego_grid_pf_hv_generator));


----------------
-- Electrical neighbours
----------------

-- Are all electrical neighbours included in the data set? 

-- Are generators and generator time series assigned to all electrical neighbours? 

-- Are loads and load time series assigned to all electrical neighbours? 
