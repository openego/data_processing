 With gemeinden as
    (SELECT ags, nuts, ST_Transform(geom,4326) as geom
     from boundaries.bkg_vg250_6_gem), 
     zensus as
    (SELECT grid_id, x_mp, y_mp,population, 
    ST_Transform(geom_point,4326) as zensus_geom, gid
     from society.destatis_zensus_population_per_ha)
    SELECT gemeinden.*,zensus.*      
    FROM zensus, gemeinden
    WHERE ST_Contains(gemeinden.geom,zensus.zensus_geom);
