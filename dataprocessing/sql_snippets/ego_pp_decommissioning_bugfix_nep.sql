
--- Fixes bug in preprocessing/sql_snippets/ego_dp_res_rea_by_scenario.sql (too much extension of wind and pv generators due to double 'rs' values in boundaries.bkg_vg250_6_gem_rs_mview)
--- by creating an decommissioing scnenario
---- wind onshore
INSERT INTO model_draft.ego_grid_pv_hv_extension_generator (scn_name, source, bus, p_nom, generator_id)

SELECT 
'decommissioning_bugfix_nep',
13,
otg_id, 
SUM(electrical_capacity)/1000,
(SELECT b.generator_id FROM model_draft.ego_grid_pf_hv_generator b
			WHERE b.source = 13 AND  b.scn_name = 'NEP 2035' AND otg_id=b.bus AND b.p_nom = (
				SELECT MAX(b.p_nom) FROM model_draft.ego_grid_pf_hv_generator b
				WHERE b.source = 13 AND  b.scn_name = 'NEP 2035' AND otg_id=b.bus))
FROM 

(SELECT  electrical_capacity, otg_id
FROM

(SELECT geom, electrical_capacity 
FROM model_draft.ego_dp_supply_res_powerplant
WHERE preversion = 'v0.3.0'
AND scenario='NEP 2035'
AND generation_type='wind'
AND source = 'NEP 2015 scenario B2035'
AND geom IN 
(SELECT ST_Transform(ST_Centroid(geom), 4326) 
	FROM boundaries.bkg_vg250_6_gem_rs_mview t1
	WHERE (SELECT count(*) FROM boundaries.bkg_vg250_6_gem_rs_mview t2 WHERE t1.rs = t2.rs) > 1
	AND t1.census_sum = (SELECT MAX (census_sum) FROM  boundaries.bkg_vg250_6_gem_rs_mview WHERE t1.rs=rs)
)) as decom

INNER JOIN grid.ego_dp_mv_griddistrict a ON ST_Intersects(decom.geom, ST_Transform(a.geom, 4326))

INNER JOIN grid.ego_dp_hvmv_substation c ON(a.subst_id = c.subst_id)

WHERE a.version='v0.4.5' 
AND c.version = 'v0.4.5' 

) as res

GROUP BY otg_id;


---- pv
INSERT INTO model_draft.ego_grid_pv_hv_extension_generator (scn_name, source, bus, p_nom, generator_id)

SELECT 
'decommissioning_bugfix_nep',
12,
otg_id, 
SUM(electrical_capacity)/1000,
(SELECT b.generator_id FROM model_draft.ego_grid_pf_hv_generator b
			WHERE b.source = 12 AND  b.scn_name = 'NEP 2035' AND otg_id=b.bus AND b.p_nom = (
				SELECT MAX(b.p_nom) FROM model_draft.ego_grid_pf_hv_generator b
				WHERE b.source = 12 AND  b.scn_name = 'NEP 2035' AND otg_id=b.bus))
FROM 

(SELECT  electrical_capacity, otg_id
FROM

(SELECT geom, electrical_capacity 
FROM model_draft.ego_dp_supply_res_powerplant
WHERE preversion = 'v0.3.0'
AND scenario='NEP 2035'
AND generation_type='solar'
AND source = 'NEP 2015 for 2035' ---solar
AND geom IN 
(SELECT ST_Transform(ST_Centroid(geom), 4326) 
	FROM boundaries.bkg_vg250_6_gem_rs_mview t1
	WHERE (SELECT count(*) FROM boundaries.bkg_vg250_6_gem_rs_mview t2 WHERE t1.rs = t2.rs) > 1
	AND t1.census_sum = (SELECT MAX (census_sum) FROM  boundaries.bkg_vg250_6_gem_rs_mview WHERE t1.rs=rs)
)) as decom

INNER JOIN grid.ego_dp_mv_griddistrict a ON ST_Intersects(decom.geom, ST_Transform(a.geom, 4326))

INNER JOIN grid.ego_dp_hvmv_substation c ON(a.subst_id = c.subst_id)

WHERE a.version='v0.4.5' 
AND c.version = 'v0.4.5' 

) as res

GROUP BY otg_id;
