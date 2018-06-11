
----------------------
-- Conventional 
----------------------

-- Table: supply.ego_dp_conv_powerplant
-- DROP TABLE supply.ego_dp_conv_powerplant;

CREATE TABLE supply.ego_dp_conv_powerplant
(
  version text NOT NULL,
  gid integer NOT NULL,
  bnetza_id text,
  company text,
  name text,
  postcode text,
  city text,
  street text,
  state text,
  block text,
  commissioned_original text,
  commissioned double precision,
  retrofit double precision,
  shutdown double precision,
  status text,
  fuel text,
  technology text,
  type text,
  eeg text,
  chp text,
  capacity double precision,
  capacity_uba double precision,
  chp_capacity_uba double precision,
  efficiency_data double precision,
  efficiency_estimate double precision,
  network_node text,
  voltage text,
  network_operator text,
  name_uba text,
  lat double precision,
  lon double precision,
  comment text,
  geom geometry(Point,4326),
  voltage_level smallint,
  subst_id bigint,
  otg_id bigint,
  un_id bigint,
  preversion text,
  la_id integer,
  scenario text NOT NULL DEFAULT 'none'::text,
  flag text,
  nuts character varying,
  CONSTRAINT ego_dp_conv_powerplant_pkey PRIMARY KEY (version, scenario, gid)
)
WITH (
  OIDS=FALSE
);


ALTER TABLE supply.ego_dp_conv_powerplant
  OWNER TO oeuser;
GRANT ALL ON TABLE supply.ego_dp_conv_powerplant TO oeuser;


-- Index: supply.ego_dp_conv_powerplant_geom_idx
-- DROP INDEX supply.ego_dp_conv_powerplant_geom_idx;

CREATE INDEX ego_dp_conv_powerplant_geom_idx
  ON supply.ego_dp_conv_powerplant
  USING gist
  (geom);

-- add new column  
ALTER TABLE supply.ego_dp_res_powerplant
  ADD COLUMN  w_id bigint;

----------------------
-- Renewable 
----------------------

-- Table: supply.ego_dp_res_powerplant
-- DROP TABLE supply.ego_dp_res_powerplant;

CREATE TABLE supply.ego_dp_res_powerplant
(
  version text NOT NULL,
  id bigint NOT NULL,
  start_up_date timestamp without time zone,
  electrical_capacity numeric,
  generation_type text,
  generation_subtype character varying,
  thermal_capacity numeric,
  city character varying,
  postcode character varying,
  address character varying,
  lon numeric,
  lat numeric,
  gps_accuracy character varying,
  validation character varying,
  notification_reason character varying,
  eeg_id character varying,
  tso double precision,
  tso_eic character varying,
  dso_id character varying,
  dso character varying,
  voltage_level_var character varying,
  network_node character varying,
  power_plant_id character varying,
  source character varying,
  comment character varying,
  geom geometry(Point,4326),
  subst_id bigint,
  otg_id bigint,
  un_id bigint,
  voltage_level smallint,
  la_id integer,
  mvlv_subst_id integer,
  rea_sort integer,
  rea_flag character varying,
  rea_geom_line geometry(LineString,3035),
  rea_geom_new geometry(Point,3035),
  preversion text,
  flag character varying,
  scenario character varying NOT NULL DEFAULT 'none'::character varying,
  nuts character varying,
  CONSTRAINT ego_dp_res_powerplant_pkey PRIMARY KEY (version, scenario, id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE supply.ego_dp_res_powerplant
  OWNER TO oeuser;
GRANT ALL ON TABLE supply.ego_dp_res_powerplant TO oeuser;

-- Index: supply.ego_dp_res_powerplant_geom_idx
-- DROP INDEX supply.ego_dp_res_powerplant_geom_idx;

CREATE INDEX ego_dp_res_powerplant_geom_idx
  ON supply.ego_dp_res_powerplant
  USING gist
  (geom);

-- Index: supply.ego_dp_res_powerplant_rea_geom_new_idx
-- DROP INDEX supply.ego_dp_res_powerplant_rea_geom_new_idx;

CREATE INDEX ego_dp_res_powerplant_rea_geom_new_idx
  ON supply.ego_dp_res_powerplant
  USING gist
  (rea_geom_new);

-- add new column  
ALTER TABLE supply.ego_dp_res_powerplant
  ADD COLUMN  w_id bigint;
