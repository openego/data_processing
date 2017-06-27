/*
Check the necessary input tables.
Return version of input tables.

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


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
			--(table_schema='economic' AND table_name='destatis_gva_per_district') OR
			(table_schema='demand' AND table_name='ego_demand_federalstate')
			) AS sub
ORDER BY table_schema, table_name;
