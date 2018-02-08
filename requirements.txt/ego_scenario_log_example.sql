/*
Example of the use of the function ego_scenario_log
The function add an entry to the table model_draft.ego_scenario_log

__copyright__ 	= "Copyright Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','test','model_draft','test_table','ego_scenario_log_example.sql','');
