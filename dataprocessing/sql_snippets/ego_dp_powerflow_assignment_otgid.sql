/*
Powerplant lists are updated with information on the otg_id of substations which the generators are assigned to.

__copyright__ 	= "Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "IlkaCu" 
*/


-- Insert otg_id of bus for res pp 
UPDATE model_draft.ego_dp_supply_res_powerplant a
	SET 	otg_id =b.otg_id 
	FROM 	model_draft.ego_grid_hvmv_substation b
	WHERE 	a.subst_id = b.subst_id AND voltage_level > 2;
	
UPDATE model_draft.ego_dp_supply_res_powerplant a
	SET 	otg_id = b.otg_id 
	FROM 	model_draft.ego_ehv_substation b
	WHERE 	a.subst_id = b.subst_id AND voltage_level < 3;


-- Insert otg_id of bus for conv pp
UPDATE model_draft.ego_dp_supply_conv_powerplant a
	SET 	otg_id =b.otg_id 
	FROM 	model_draft.ego_grid_hvmv_substation b
	WHERE 	a.subst_id = b.subst_id AND voltage_level > 2;
	
UPDATE model_draft.ego_dp_supply_conv_powerplant a
	SET 	otg_id = b.otg_id 
	FROM 	model_draft.ego_ehv_substation b
	WHERE 	a.subst_id = b.subst_id AND voltage_level < 3;
	
-- Update otg_id of offshore windturbines manually 

UPDATE model_draft.ego_dp_supply_res_powerplant

SET otg_id = (CASE 	WHEN ST_Within(model_draft.ego_dp_supply_res_powerplant.geom, ST_Transform(ST_GeomFromText('Polygon ((5.95173129831068426 55.37818807468978122, 6.77308878227293132 55.54526167457145647, 7.94556091586789481 55.49201720741838528, 8.2277066164656123 54.05646341504236574, 8.04587938719152795 53.93022020557216223, 6.55364212625248399 55.07064320311457095, 5.95173129831068426 55.37818807468978122))', 4326), 4326))
			THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE (geom = '0101000020E6100000BB169FDC4B782240A84AC13A5BF54A40' AND v_nom = 380 AND scn_name = 'Status Quo'))

			WHEN ST_Within(model_draft.ego_dp_supply_res_powerplant.geom, ST_Transform(ST_GeomFromText('Polygon ((6.38592218200828121 53.57746729981128908, 4.78788028334509264 54.35156267212201442, 5.27693283104780431 55.21565978044320389, 5.71269119085983501 55.31568685692229792, 5.86395263590250249 54.84868861398261686, 6.38592218200828121 53.57746729981128908))', 4326), 4326)) 
			THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE (geom = '0101000020E6100000E10EC4C4D53E1D4032D0841E19904A40' AND v_nom = 380 AND scn_name= 'Status Quo'))

			WHEN ST_Within(model_draft.ego_dp_supply_res_powerplant.geom, ST_Transform(ST_GeomFromText('Polygon ((5.9501638221962514 55.37729749203850105, 6.55403399528109176 55.07019441729961784, 8.04587938719152795 53.93010449812520335, 6.38611811652258865 53.57723457232420827, 5.86238515978807229 54.84835012881402605, 5.71190745280262213 55.31490686916314559, 5.9501638221962514 55.37729749203850105))', 4326), 4326))
			THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE (geom = '0101000020E6100000F6D6A6710E081D40B62017FD957D4A40' AND v_nom = 380 AND scn_name = 'Status Quo'))
			
			WHEN ST_Within(model_draft.ego_dp_supply_res_powerplant.geom, ST_Transform(ST_GeomFromText('Polygon((12.77312167058569869 55.19855141024020639, 12.49881542593200479 54.66908170513258369, 14.36409788957713651 54.76412687912878852, 14.39701463893557865 55.26744430972406974, 12.77312167058569869 55.19855141024020639))', 4326), 4326))
			THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE (geom = '0101000020E6100000509011B4F05D2B4040490BB9CD114B40' AND v_nom = 380 AND scn_name = 'Status Quo'))

			ELSE otg_id
			
END);


/*


-- Connect powerplants with voltage_level >=3 outside the grid district area to their nearest hv/mv-substation 

--Update model_draft.ego_supply_rea_2035 as C
--set otg_id   = sub.otg_id,
--    subst_id = sub.subst_id  
--FROM(
--	SELECT B.subst_id,
--	       B.otg_id,
--		(SELECT A.id                        
--		
--		FROM model_draft.ego_supply_rea_2035 A
--                WHERE A.subst_id IS NULL 
--                AND A.voltage_level >= 3	    
--		ORDER BY B.point <#> A.geom LIMIT 1)
--	FROM model_draft.ego_grid_hvmv_substation B
--) as sub
--WHERE C.id = sub.id 
--;


*/


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_dp_supply_res_powerplant','ego_dp_powerflow_assignment_otgid.sql',' ');
SELECT ego_scenario_log('v0.3.0','output','model_draft','ego_dp_supply_conv_powerplant','ego_dp_powerflow_assignment_otgid.sql',' ');

