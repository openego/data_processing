/*
calculate pekloads for loadareas
ToDo: translate peakload.py

__copyright__ 	= "Reiner Lemoine Institut"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "Ludee"
*/


/* refactoring

-- temporary storage for refactoring
DROP TABLE IF EXISTS 	model_draft.ego_demand_loadarea_temp CASCADE; 
CREATE TABLE 		model_draft.ego_demand_loadarea_temp AS
	TABLE model_draft.ego_demand_loadarea; 

-- grant (oeuser)
ALTER TABLE	model_draft.ego_demand_loadarea_temp 
	OWNER TO oeuser,
	ADD PRIMARY KEY (id);


-- loadareas per mv-griddistrict
DROP TABLE IF EXISTS  	model_draft.ego_demand_loadarea CASCADE;
CREATE TABLE         	model_draft.ego_demand_loadarea (
	id SERIAL NOT NULL,
	subst_id integer,
	area_ha numeric,
	nuts varchar(5),
	rs_0 varchar(12),
	ags_0 varchar(12),
	otg_id integer,
	un_id integer,
	zensus_sum integer,
	zensus_count integer,
	zensus_density numeric,
	ioer_sum numeric,
	ioer_count integer,
	ioer_density numeric,
	sector_area_residential numeric,
	sector_area_retail numeric,
	sector_area_industrial numeric,
	sector_area_agricultural numeric,
	sector_area_sum numeric,	
	sector_share_residential numeric,
	sector_share_retail numeric,
	sector_share_industrial numeric,
	sector_share_agricultural numeric,
	sector_share_sum numeric,
	sector_count_residential integer,
	sector_count_retail integer,
	sector_count_industrial integer,
	sector_count_agricultural integer,
	sector_count_sum integer,
	sector_consumption_residential double precision,
	sector_consumption_retail double precision,
	sector_consumption_industrial double precision,
	sector_consumption_agricultural double precision,
	sector_consumption_sum double precision,
	sector_peakload_residential double precision,
	sector_peakload_retail double precision,
	sector_peakload_industrial double precision,
	sector_peakload_agricultural double precision,
	geom_centroid geometry(POINT,3035),
	geom_surfacepoint geometry(POINT,3035),
	geom_centre geometry(POINT,3035),
	geom geometry(Polygon,3035),
	CONSTRAINT ego_demand_loadarea_pkey PRIMARY KEY (id));

-- grant (oeuser)
ALTER TABLE	model_draft.ego_demand_loadarea OWNER TO oeuser;


INSERT INTO	model_draft.ego_demand_loadarea (
	subst_id	,
	area_ha	,
	nuts	,
	rs_0	,
	ags_0	,
	otg_id	,
	un_id	,
	zensus_sum	,
	zensus_count	,
	zensus_density	,
	ioer_sum	,
	ioer_count	,
	ioer_density	,
	sector_area_residential	,
	sector_area_retail	,
	sector_area_industrial	,
	sector_area_agricultural	,
	sector_area_sum	,
	sector_share_residential	,
	sector_share_retail	,
	sector_share_industrial	,
	sector_share_agricultural	,
	sector_share_sum	,
	sector_count_residential	,
	sector_count_retail	,
	sector_count_industrial	,
	sector_count_agricultural	,
	sector_count_sum	,
	sector_consumption_residential	,
	sector_consumption_retail	,
	sector_consumption_industrial	,
	sector_consumption_agricultural	,
	sector_consumption_sum	,
	geom_centroid	,
	geom_surfacepoint	,
	geom_centre	,
	geom	)
SELECT 
	subst_id	,
	area_ha	,
	nuts	,
	rs_0	,
	ags_0	,
	otg_id	,
	un_id	,
	zensus_sum	,
	zensus_count	,
	zensus_density	,
	ioer_sum	,
	ioer_count	,
	ioer_density	,
	sector_area_residential	,
	sector_area_retail	,
	sector_area_industrial	,
	sector_area_agricultural	,
	sector_area_sum	,
	sector_share_residential	,
	sector_share_retail	,
	sector_share_industrial	,
	sector_share_agricultural	,
	sector_share_sum	,
	sector_count_residential	,
	sector_count_retail	,
	sector_count_industrial	,
	sector_count_agricultural	,
	sector_count_sum	,
	sector_consumption_residential	,
	sector_consumption_retail	,
	sector_consumption_industrial	,
	sector_consumption_agricultural	,
	sector_consumption_sum	,
	geom_centroid	,
	geom_surfacepoint	,
	geom_centre	,
	geom	
FROM	model_draft.ego_demand_loadarea_temp
ORDER BY id;

-- index GIST (geom)
CREATE INDEX  	ego_demand_loadarea_geom_idx
	ON    	model_draft.ego_demand_loadarea USING gist (geom);

-- index GIST (geom_centre)
CREATE INDEX  	ego_demand_loadarea_geom_centre_idx
	ON    	model_draft.ego_demand_loadarea USING gist (geom_centre);
 */


-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.9','input','model_draft','ego_demand_loadarea_peak_load','ego_dp_loadarea_peakload.sql','');

-- copy peakload to loadarea (temp)
UPDATE 	model_draft.ego_demand_loadarea AS t1
	SET	sector_peakload_residential = t2.residential,
		sector_peakload_retail = t2.retail,
		sector_peakload_industrial = t2.industrial,
		sector_peakload_agricultural = t2.agricultural
	FROM	(SELECT	a.id AS id,
			b.residential,
			b.retail,
			b.industrial,
			b.agricultural
		FROM	model_draft.ego_demand_loadarea AS a JOIN
			model_draft.ego_demand_loadarea_peak_load AS b ON (a.id = b.id)
		)AS t2
	WHERE  	t1.id = t2.id;

-- ego scenario log (version,io,schema_name,table_name,script_name,comment)
SELECT ego_scenario_log('v0.2.9','output','model_draft','ego_demand_loadarea','ego_dp_loadarea_peakload.sql','');
