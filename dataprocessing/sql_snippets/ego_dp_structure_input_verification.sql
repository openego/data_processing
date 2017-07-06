/*
Check the necessary input tables.
Return version of input tables.

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.10','check','political_boundary','bkg_vg250_1_sta','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','political_boundary','bkg_vg250_2_lan','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','political_boundary','bkg_vg250_4_krs','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','political_boundary','bkg_vg250_6_gem','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','openstreetmap','osm_deu_polygon','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','openstreetmap','osm_deu_ways','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','openstreetmap','osm_deu_nodes','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','openstreetmap','osm_deu_line','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','social','destatis_zensus_population_per_ha','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','economic','destatis_gva_per_district','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','demand','ego_demand_federalstate','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','supply','vernetzen_wind_potential_area','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','model_draft','ego_supply_res_powerplant_sq_mview','ego_dp_structure_versioning.sql','preprocessing verification');
SELECT ego_scenario_log('v0.2.10','check','model_draft','ego_supply_conv_powerplant_sq_mview','ego_dp_structure_versioning.sql','preprocessing verification');

-- input tables
SELECT	sub.oid,
	sub.database,
	sub.table_schema,
	sub.table_name,
	sub.path,
	sub.metadata::json ->>'title' AS metadata_title,
	sub.metadata::json #>>'{temporal,reference_date}' AS metadata_reference_date,
	sub.metadata
FROM	(SELECT	st.relid AS oid,
		table_catalog AS database,
		i.table_schema AS table_schema,
		i.table_name AS table_name,
		i.table_schema ||'.'|| i.table_name AS path,
		pgd.description AS metadata
	FROM	information_schema.tables AS i
		INNER JOIN pg_catalog.pg_statio_all_tables AS st ON (st.schemaname=i.table_schema and st.relname=i.table_name)
		INNER JOIN pg_catalog.pg_description AS pgd ON (pgd.objoid=st.relid)
		WHERE 	(table_schema='political_boundary' AND table_name='bkg_vg250_1_sta') OR
			(table_schema='political_boundary' AND table_name='bkg_vg250_2_lan') OR
			(table_schema='political_boundary' AND table_name='bkg_vg250_4_krs') OR
			(table_schema='political_boundary' AND table_name='bkg_vg250_6_gem') OR
			(table_schema='openstreetmap' AND table_name='osm_deu_polygon') OR
			(table_schema='openstreetmap' AND table_name='osm_deu_ways') OR 
			(table_schema='openstreetmap' AND table_name='osm_deu_nodes') OR
			(table_schema='openstreetmap' AND table_name='osm_deu_line') OR
			(table_schema='social' AND table_name='destatis_zensus_population_per_ha') OR
			(table_schema='economic' AND table_name='destatis_gva_per_district') OR
			(table_schema='demand' AND table_name='ego_demand_federalstate') OR
			(table_schema='supply' AND table_name='vernetzen_wind_potential_area') OR
			(table_schema='model_draft' AND table_name='ego_supply_res_powerplant_sq_mview') OR
			(table_schema='model_draft' AND table_name='ego_supply_conv_powerplant_sq_mview')
			) AS sub
ORDER BY table_schema, table_name;
