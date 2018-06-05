DROP TABLE IF EXISTS model_draft.ego_grid_pp_entsoe_bus;

CREATE TABLE model_draft.ego_grid_pp_entsoe_bus
(  bus_id bigint,  
  station_id bigint, 
  voltage double precision, -- Unit: kV...
  dc boolean, 
  symbol character varying, 
  country text,
  under_construction boolean,
  geom geometry(Point));
    
COPY model_draft.ego_grid_pp_entsoe_bus  FROM '/home/clara/GitHub/data_processing/preprocessing/sql_snippets/entsoe/entsoe_buses.csv' DELIMITER ';' HEADER CSV;

DROP TABLE IF EXISTS model_draft.ego_grid_pp_entsoe_line;

CREATE TABLE model_draft.ego_grid_pp_entsoe_line
( link_id bigint,  
  bus0 bigint,
  bus1 bigint,
  voltage double precision, -- Unit: kV...
  circiuts bigint,
  dc boolean, 
  underground boolean,
  under_construction boolean,
  country1 character varying,
  country2 character varying,
  geom geometry(LineString));
  
COPY model_draft.ego_grid_pp_entsoe_line  FROM '/home/clara/GitHub/data_processing/preprocessing/sql_snippets/entsoe/entsoe_links.csv' DELIMITER ';' HEADER CSV;

