/*
This script creates discrete materialized views (mview) for conventional and renewable power plants per scenario,
resulting in six different mviews for the three main scenarios considered in open_eGo.

__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

*/


--------------------------------------------------------------------------------
-- Part IV 
--          Create Views by scenario
--	    Scenarios: eGo100
--------------------------------------------------------------------------------

-- MView for Status Quo
DROP MATERIALIZED VIEW IF EXISTS  model_draft.ego_supply_conv_powerplant_sq_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_sq_mview AS
    SELECT *
    FROM model_draft.ego_dp_supply_conv_powerplant
    WHERE scenario = 'Status Quo'
    AND (shutdown IS NULL or shutdown >= 2015)
    AND capacity > 0 
    AND preversion = 'v0.3.0';

ALTER MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_sq_mview
    OWNER TO oeuser; 

-- MView for NEP 2035
DROP MATERIALIZED VIEW IF EXISTS model_draft.ego_supply_conv_powerplant_nep2035_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_nep2035_mview AS
    SELECT *
    FROM  model_draft.ego_dp_supply_conv_powerplant
    WHERE scenario = 'NEP 2035'
    AND   capacity > 0 
    AND   fuel not in ('hydro', 'run_of_river', 'reservoir')
    AND   (shutdown IS NULL or shutdown >= 2034)
    AND   preversion = 'v0.3.0';

ALTER MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_nep2035_mview
    OWNER TO oeuser;

-- MView for eGo100
DROP MATERIALIZED VIEW IF EXISTS  model_draft.ego_supply_conv_powerplant_ego100_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_ego100_mview AS
	SELECT 
	  preversion,
	  id,
	  bnetza_id,
	  company,
	  name,
	  postcode,
	  city,
	  street,
	  state,
	  block,
	  commissioned_original,
	  commissioned,
	  retrofit,
	  shutdown,
	  status,
	  fuel,
	  technology,
	  type,
	  eeg,
	  chp,
	  capacity,
	  capacity_uba,
	  chp_capacity_uba,
	  efficiency_data,
	  efficiency_estimate,
	  network_node,
	  voltage,
	  network_operator,
	  name_uba,
	  lat,
	  lon,
	  'pumed storage for eGo 100'::text as comment,
	  geom,
	  voltage_level,
	  subst_id,
	  otg_id,
	  un_id,
	  la_id,
	  'eGo 100'::text as scenario,
	  'constantly'::text as flag,
	  nuts
	FROM model_draft.ego_dp_supply_conv_powerplant
	WHERE scenario in('NEP 2035')
	AND fuel = 'pumped_storage'
	AND capacity > 0
	AND (shutdown IS NULL or shutdown >= 2049)
	AND preversion = 'v0.3.0';

ALTER MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_ego100_mview
    OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_supply_conv_powerplant_sq_mview','ego_dp_powerflow_create_pp_mview.sql',' ');
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_supply_conv_powerplant_nep2035_mview','ego_dp_powerflow_create_pp_mview.sql',' ');
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_supply_conv_powerplant_ego100_mview','ego_dp_powerflow_create_pp_mview.sql',' ');


--------------------------------------------------------------------------------
-- Part IV 
--          Create View with full dataset per scenario
--------------------------------------------------------------------------------

-- MView for Status Quo
DROP MATERIALIZED VIEW IF EXISTS  model_draft.ego_supply_res_powerplant_sq_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_res_powerplant_sq_mview AS
    SELECT *
    FROM model_draft.ego_dp_supply_res_powerplant
    WHERE scenario =  'Status Quo'
    AND electrical_capacity > 0
    AND preversion = 'v0.3.0';

ALTER MATERIALIZED VIEW model_draft.ego_supply_res_powerplant_sq_mview
    OWNER TO oeuser;

-- MView for NEP 2035
DROP MATERIALIZED VIEW IF EXISTS model_draft.ego_supply_res_powerplant_nep2035_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_res_powerplant_nep2035_mview AS
	SELECT
	sub.*
	FROM  ( 
		SELECT DISTINCT ON (id)
		  *
		FROM
		  model_draft.ego_dp_supply_res_powerplant 
			WHERE id not in (
			SELECT id
			FROM model_draft.ego_dp_supply_res_powerplant
			Group BY id
			HAVING count(*) > 1
			Order by id)
		 AND scenario = 'Status Quo'
		 And preversion = 'v0.3.0'
		 AND electrical_capacity > 0
		 ORDER BY id	
		 ) as sub
	UNION 
	SELECT
	sub2.*
	FROM  ( 
		SELECT  DISTINCT ON (id)
		  *
		FROM
		  model_draft.ego_dp_supply_res_powerplant	
		WHERE id in (
			SELECT id
			FROM model_draft.ego_dp_supply_res_powerplant
			Where scenario in ('NEP 2035')
			Group BY id
			Order by id)
		 AND scenario in ('NEP 2035')
		 And preversion = 'v0.3.0'
		 AND electrical_capacity > 0
		 ORDER BY id	
	) sub2
	Order by id;
	

ALTER MATERIALIZED VIEW model_draft.ego_supply_res_powerplant_nep2035_mview
    OWNER TO oeuser;

-- MView for eGo 100

DROP MATERIALIZED VIEW IF EXISTS model_draft.ego_supply_res_powerplant_ego100_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_res_powerplant_ego100_mview AS
	SELECT DISTINCT ON (id)
	sub.*
	FROM  ( 
		SELECT DISTINCT ON (id)
		  *
		FROM
		  model_draft.ego_dp_supply_res_powerplant 
			WHERE id not in (
			SELECT id
			FROM model_draft.ego_dp_supply_res_powerplant
			Group BY id
			HAVING count(*) > 1
			Order by id)
		 AND scenario = 'Status Quo'
		 And preversion = 'v0.3.0'
		 AND electrical_capacity > 0
		 AND generation_type in ('solar','wind')
		 AND generation_subtype not in ('wind_offshore')
		 ORDER BY id	
		 ) as sub
	UNION 
	SELECT DISTINCT ON (id)
	sub2.*
	FROM  ( 
		SELECT  DISTINCT ON (id)
		  *
		FROM
		  model_draft.ego_dp_supply_res_powerplant	
		WHERE id in (
			SELECT id
			FROM model_draft.ego_dp_supply_res_powerplant
			Where scenario in ('eGo 100')
			AND generation_type not in ('gas')
			AND flag in ('commissioning', 'repowering')
			Group BY id
			Order by id)
		 AND scenario in ('eGo 100')
		 And preversion = 'v0.3.0'
		 AND electrical_capacity > 0
		 ORDER BY id	
	) sub2
        UNION 
	SELECT DISTINCT ON (id)
	sub3.*
	FROM  ( 
		SELECT DISTINCT ON (id)
		  *
		FROM
		  model_draft.ego_dp_supply_res_powerplant	
		WHERE id in (
			SELECT id
			FROM model_draft.ego_dp_supply_res_powerplant
			Where scenario in ('NEP 2035')
			AND generation_type not in ('biomass','gas','reservoir','run_of_river')
			AND generation_subtype not in ('wind_offshore')
			AND flag in ('commissioning', 'repowering')
			Group BY id
			Order by id)
		 AND scenario in ('NEP 2035')
		 And preversion = 'v0.3.0'
		 AND electrical_capacity > 0
		 ORDER BY id	
	) sub3
	Order by id;
	

ALTER MATERIALIZED VIEW model_draft.ego_supply_res_powerplant_ego100_mview
    OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_supply_res_powerplant_sq_mview','ego_dp_powerflow_create_pp_mview.sql',' ');
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_supply_res_powerplant_nep2035_mview','ego_dp_powerflow_create_pp_mview.sql',' ');
SELECT scenario_log('eGo_DP', 'v0.4.5','output','model_draft','ego_supply_res_powerplant_ego100_mview','ego_dp_powerflow_create_pp_mview.sql',' ');
