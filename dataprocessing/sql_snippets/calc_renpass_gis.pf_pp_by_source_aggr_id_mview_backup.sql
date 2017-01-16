-- Materialized View: calc_renpass_gis.pf_pp_by_source_aggr_id

-- DROP MATERIALIZED VIEW calc_renpass_gis.pf_pp_by_source_aggr_id;

CREATE MATERIALIZED VIEW calc_renpass_gis.pf_pp_by_source_aggr_id AS 
 SELECT sq.aggr_id,
    sq.source,
    sq.p_nom / sum(sq.p_nom) OVER (PARTITION BY sq.source) AS fraction_of_installed
   FROM ( SELECT ego_supply_pf_generator_single.aggr_id,
            ego_supply_pf_generator_single.source,
            sum(ego_supply_pf_generator_single.p_nom) AS p_nom
           FROM model_draft.ego_supply_pf_generator_single
          WHERE ego_supply_pf_generator_single.scn_name::text = 'Status Quo'::text
          GROUP BY ego_supply_pf_generator_single.aggr_id, ego_supply_pf_generator_single.source) sq
WITH DATA;

ALTER TABLE calc_renpass_gis.pf_pp_by_source_aggr_id OWNER TO oeuser;
