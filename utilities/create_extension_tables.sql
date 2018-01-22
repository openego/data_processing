
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

CREATE TABLE model_draft.ego_grid_pf_hv_extension_temp_resolution AS (SELECT * FROM model_draft.ego_grid_pf_hv_temp_resolution);

CREATE TABLE model_draft.ego_grid_pf_hv_extension_source AS (SELECT * FROM model_draft.ego_grid_pf_hv_source);

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

