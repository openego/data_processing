
/*
Identify corresponding subst_id for all power plants according to their voltage_level and geometry. 
__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/

------------------
-- Conventional power plants
------------------


-- Identify corresponding bus with the help of grid districts
UPDATE model_draft.ego_dp_supply_conv_powerplant a
	SET 	subst_id = b.subst_id
	FROM	model_draft.ego_grid_mv_griddistrict b
	WHERE 	a.geom && ST_TRANSFORM(b.geom,4326)
		AND ST_Intersects(a.geom, ST_TRANSFORM(b.geom,4326)) 
		AND voltage_level >= 3; 

-- Identify corresponding bus with the help of ehv-Voronoi
UPDATE model_draft.ego_dp_supply_conv_powerplant a
	SET 	subst_id = b.subst_id
	FROM 	model_draft.ego_grid_ehv_substation_voronoi b
	WHERE 	a.geom && b.geom
		AND ST_Intersects(a.geom, b.geom)
		AND voltage_level <= 2;

-- Assign conventional pp with voltage_level >2 located outside of Germany to their closest 110 kV substation

ALTER TABLE model_draft.ego_dp_supply_conv_powerplant
   ADD COLUMN subst_id_NN int; 

UPDATE model_draft.ego_dp_supply_conv_powerplant a
   SET subst_id_NN = result.subst_id	
   FROM 
	(SELECT DISTINCT ON (pp.id) pp.id, subst.subst_id, ST_Distance(ST_Transform(subst.geom, 4326), pp.geom)  as dist
	   FROM model_draft.ego_dp_supply_conv_powerplant As pp, model_draft.ego_grid_hvmv_substation As subst   
	   ORDER BY pp.id, ST_Distance(ST_Transform(subst.geom, 4326), pp.geom), subst.subst_id) as result
	   WHERE a.id=result.id;

UPDATE model_draft.ego_dp_supply_conv_powerplant a
   SET subst_id=subst_id_NN
   WHERE subst_id IS NULL and voltage_level > 2; 

ALTER TABLE model_draft.ego_dp_supply_conv_powerplant 
   DROP COLUMN subst_id_NN; 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_dp_supply_conv_powerplant','ego_dp_substation_id_to_generator.sql',' ');

------------------
-- Renewable power plants
------------------

-- Identify corresponding bus with the help of grid districts
UPDATE model_draft.ego_dp_supply_res_powerplant a
	SET 	subst_id = b.subst_id
	FROM	model_draft.ego_grid_mv_griddistrict b
	WHERE 	a.geom && ST_TRANSFORM(b.geom,4326)
		AND ST_Intersects(a.geom, ST_TRANSFORM(b.geom,4326)) 
		AND voltage_level >= 3;  

-- Identify corresponding bus with the help of ehv-Voronoi
UPDATE model_draft.ego_dp_supply_res_powerplant a
	SET 	subst_id = b.subst_id
	FROM 	model_draft.ego_grid_ehv_substation_voronoi b
	WHERE 	a.geom && b.geom
		AND ST_Intersects(a.geom, b.geom)
AND voltage_level <= 2; 

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','input','model_draft','ego_dp_supply_res_powerplant','ego_dp_substation_id_to_generator.sql',' ');
