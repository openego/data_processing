/*
This scripts updates tables containing `renewable power plants <http://oep.iks.cs.ovgu.de/dataedit/view/model_draft/ego_dp_supply_res_powerplant>`_ and `conventional power plants <http://oep.iks.cs.ovgu.de/dataedit/view/model_draft/ego_dp_supply_conv_powerplant>`_ with information on the otg_id of substations which the generator is assigned to. 
The otg_id and subst_id of the substations are matched in tables containing information on `HV/MV substations <http://oep.iks.cs.ovgu.de/dataedit/view/model_draft/ego_grid_hvmv_substation>`_ and `EHV substations <http://oep.iks.cs.ovgu.de/dataedit/view/model_draft/ego_grid_ehv_substation>`_.  

Additionally the otg_id of offshore wind turbines is updated manually. The geometry of offshore wind power plants is matched with polygons representing a catchment area per relevant offshore grid connection point.  

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

SET otg_id = (CASE 	WHEN ST_Within(model_draft.ego_dp_supply_res_powerplant.geom, ST_Transform(ST_GeomFromText('Polygon((6.52991154226757331 55.0731495469060448, 6.76032878777667889 55.5415269292555891, 7.95630401446679425 55.49182999161460828, 8.23061025912049082 54.05536039374283064, 8.04682507520251633 53.92957832960381381, 6.52991154226757331 55.0731495469060448))', 4326), 4326))
			THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE (geom = '0101000020E6100000BB169FDC4B782240A84AC13A5BF54A40' AND v_nom = 380 AND scn_name = 'Status Quo'))

			WHEN ST_Within(model_draft.ego_dp_supply_res_powerplant.geom, ST_Transform(ST_GeomFromText('Polygon((5.85237511797294463 54.84951794763450295, 4.78532382627006481 54.35697386477539084, 6.3817861701545775 53.57925959134499294, 5.85237511797294463 54.84951794763450295))', 4326), 4326)) 
			THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE (geom = '0101000020E6100000E10EC4C4D53E1D4032D0841E19904A40' AND v_nom = 380 AND scn_name= 'Status Quo'))

			WHEN ST_Within(model_draft.ego_dp_supply_res_powerplant.geom, ST_Transform(ST_GeomFromText('Polygon((6.38727229504765148 53.58252052345604, 5.86060430531255516 54.84635981450501419, 6.54088379205372217 55.07943099765473249, 8.04408201275597889 53.93279988414769832, 6.38727229504765148 53.58252052345604))', 4326), 4326))
			THEN (SELECT bus_id FROM model_draft.ego_grid_pf_hv_bus WHERE (geom = '0101000020E6100000F6D6A6710E081D40B62017FD957D4A40' AND v_nom = 380 AND scn_name = 'Status Quo'))
			
			WHEN ST_Within(model_draft.ego_dp_supply_res_powerplant.geom, ST_Transform(ST_GeomFromText('Polygon((12.77312167058569869 55.19855141024020639, 12.49881542593200479 54.66908170513258369, 14.36409788957713651 54.76412687912878852, 14.39701463893557865 55.26744430972406974, 12.77312167058569869 55.19855141024020639))	', 4326), 4326))
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

