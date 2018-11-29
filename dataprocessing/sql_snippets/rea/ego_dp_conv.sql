/*
Skript to allocate conventional power plants to loadareas

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','input','model_draft','ego_dp_supply_conv_powerplant','ego_dp_conv.sql',' ');

-- la_id
ALTER TABLE model_draft.ego_dp_supply_conv_powerplant
	DROP COLUMN IF EXISTS	la_id CASCADE,
  	ADD COLUMN 		la_id integer;


-- update la_id from loadarea
UPDATE 	model_draft.ego_dp_supply_conv_powerplant AS t1
	SET  	la_id = t2.la_id
	FROM    (
		SELECT	a.gid AS id,
			b.id AS la_id
		FROM	model_draft.ego_dp_supply_conv_powerplant AS a,
			model_draft.ego_demand_loadarea AS b
		WHERE  	b.geom && ST_TRANSFORM(a.geom,3035) AND
			ST_CONTAINS(b.geom,ST_TRANSFORM(a.geom,3035))
		) AS t2
	WHERE  	t1.gid = t2.id;
	
-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_dp_supply_conv_powerplant','ego_dp_conv.sql',' ');
