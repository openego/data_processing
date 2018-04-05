-- Create MView with NUTS IDs

CREATE MATERIALIZED VIEW boundaries.bkg_vg250_2_lan_nuts_view AS 
 SELECT lan.ags_0,
    lan.gen,
    lan.nuts,
    st_union(st_transform(lan.geom, 3035)) AS geom
   FROM ( SELECT vg.ags_0,
            vg.nuts,
            replace(vg.gen::text, ' (Bodensee)'::text, ''::text) AS gen,
            vg.geom
           FROM boundaries.bkg_vg250_2_lan vg) lan
  GROUP BY lan.ags_0, lan.gen, lan.nuts
  ORDER BY lan.ags_0
WITH DATA;
