﻿/*

SQL Script which checks the allogation of renewable energy units in germany by all open_ego scenarios.

__copyright__ = "Europa-Universität Flensburg, Centre for Sustainable Energy Systems"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"
*/


-- SELECT units which not intersects with the griddistrict polygone
Select
count(res.id)
From
supply.ego_renewable_power_plants_germany as res
WHERE res.id NOT IN (
			Select
			A.id
			From
			supply.ego_res_powerplant A,
			model_draft.ego_grid_mv_griddistrict C
			Where 
			ST_Intersects(ST_Transform(A.geom, 3035), C.geom)
		   )  
;
 -- result: number of units in supply.ego_renewable_power_plants_germany  = 

 
SELECT
count(*)
FROM 
supply.ego_res_powerplant 
WHERE subst_id IS NULL;
--- 

-- supply.ego_res_powerplant