/* 
SQL Script prepare coastDat-2 data for feedinlib calculation of renewable powerplants 

__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"	
      

Comments:
---------
Table works together with:
   data_processing/calc_renpass_gis/simple_feedin/simple_feedin.py

*/

-- Table: model_draft.ego_weather_measurement_point
-- DROP Table model_draft.ego_weather_measurement_point;

CREATE TABLE model_draft.ego_weather_measurement_point
(
  name text NOT NULL,
  type_of_generation text NOT NULL,
  comment text,
  source text,
  scnenario text,
  capacity_scale numeric,
  geom geometry(Point,4326),
  CONSTRAINT weather_measurement_point_pkey PRIMARY KEY (name, type_of_generation,scnenario)
);
ALTER TABLE model_draft.ego_weather_measurement_point
  OWNER TO oeuser;


-- Select wind_onshore -- 5722 rows
Insert Into model_draft.ego_weather_measurement_point
	SELECT
	CASE WHEN sub.subst_id IS NULL THEN
	sub.coastdat_gid||'_'||'_NULL_'|| '_coast_gid_subst_id' ELSE
	sub.coastdat_gid||'_'||sub.subst_id|| '_coast_gid_subst_id' END as name,
	'windonshore' as type_of_generation,
	'by sql query'as comment,
	'coastdat' as source,
	sub.scenario,
	sub.capacity_scale,
	sub.geom
	FROM (
	Select DISTINCT
		A.coastdat_gid,
		A.subst_id,
		A.generation_subtype, 
		count(A.*), 
		sum(A.electrical_capacity) as sum_cap_per_id,
		A.scenario,
		sum(A.electrical_capacity)/sum_cap as capacity_scale,	
		B.geom
	From model_draft.ego_dp_supply_res_powerplant A,
	     coastdat.spatial B,
         ( SELECT
             sum(electrical_capacity) as sum_cap,
             scenario
	   From model_draft.ego_dp_supply_res_powerplant
	   Where scenario in ('eGo 100', 'NEP 2035', 'Status Quo')
	   And generation_subtype in('wind_onshore') 
	   group by scenario
	 ) as C 
	Where A.scenario in ('eGo 100', 'NEP 2035', 'Status Quo')
	AND A.scenario = C.scenario
	And A.generation_subtype in('wind_onshore')
	And B.gid = A.coastdat_gid
	group by A.coastdat_gid, A.generation_subtype, B.geom, A.scenario, C.sum_cap, A.subst_id
	Order by A.scenario,A.subst_id
	) as sub
	;
	
-- wind_offshore -- 52 rows
Insert Into model_draft.ego_weather_measurement_point
	SELECT
	CASE WHEN sub.subst_id IS NULL THEN
	sub.coastdat_gid||'_'||'_NULL_'|| '_coast_gid_subst_id' ELSE
	sub.coastdat_gid||'_'||sub.subst_id|| '_coast_gid_subst_id' END as name,
	'windoffshore' as type_of_generation,
	'by sql query'as comment,
	'coastdat' as source,
	sub.scenario,
	sub.capacity_scale,
	sub.geom
	FROM (
	Select DISTINCT
		A.coastdat_gid,
		A.subst_id,
		A.generation_subtype, 
		count(A.*), 
		sum(A.electrical_capacity) as sum_cap_per_id,
		A.scenario,
		sum(A.electrical_capacity)/sum_cap as capacity_scale,	
		B.geom
	From model_draft.ego_dp_supply_res_powerplant A,
	     coastdat.spatial B,
         ( SELECT
             sum(electrical_capacity) as sum_cap,
             scenario
	   From model_draft.ego_dp_supply_res_powerplant
	   Where scenario in ('eGo 100', 'NEP 2035', 'Status Quo')
	   And generation_subtype in('wind_offshore') 
	   group by scenario
	 ) as C 
	Where A.scenario in ('eGo 100', 'NEP 2035', 'Status Quo')
	AND A.scenario = C.scenario
	And A.generation_subtype in('wind_offshore')
	And B.gid = A.coastdat_gid
	group by A.coastdat_gid, A.generation_subtype, B.geom, A.scenario, C.sum_cap, A.subst_id
	Order by A.scenario,A.subst_id
	) as sub
	;

-- solar -- 11983 rows
Insert Into model_draft.ego_weather_measurement_point
	SELECT
	CASE WHEN sub.subst_id IS NULL THEN
	sub.coastdat_gid||'_'||'_NULL_'|| '_coast_gid_subst_id' ELSE
	sub.coastdat_gid||'_'||sub.subst_id|| '_coast_gid_subst_id' END as name,
	'solar' as type_of_generation,
	'by sql query'as comment,
	'coastdat' as source,
	sub.scenario,
	sub.capacity_scale,
	sub.geom
	FROM (
	Select DISTINCT
		A.coastdat_gid,
		A.subst_id,
		A.generation_subtype, 
		count(A.*), 
		sum(A.electrical_capacity) as sum_cap_per_id,
		A.scenario,
		sum(A.electrical_capacity)/sum_cap as capacity_scale,	
		B.geom
	From model_draft.ego_dp_supply_res_powerplant A,
	     coastdat.spatial B,
         ( SELECT
             sum(electrical_capacity) as sum_cap,
             scenario
	   From model_draft.ego_dp_supply_res_powerplant
	   Where scenario in ('eGo 100', 'NEP 2035', 'Status Quo')
	   And generation_subtype in('solar') 
	   group by scenario
	 ) as C 
	Where A.scenario in ('eGo 100', 'NEP 2035', 'Status Quo')
	AND A.scenario = C.scenario
	And A.generation_subtype in('solar')
	And B.gid = A.coastdat_gid
	group by A.coastdat_gid, A.generation_subtype, B.geom, A.scenario, C.sum_cap, A.subst_id
	Order by A.scenario,A.subst_id
	) as sub
	;