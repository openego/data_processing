/*
SQL Script to create mviews diyplaying power plants by scenario.

__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

*/


--------------------------------------------------------------------------------
-- Part IV 
--          Create Views by scenario
--	    Scenarios: ego 100%
--------------------------------------------------------------------------------

-- MView for Status Quo
DROP MATERIALIZED VIEW IF EXISTS  model_draft.ego_supply_conv_powerplant_sq_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_sq_view AS
    SELECT *
    FROM model_draft.ego_dp_supply_conv_powerplant
    WHERE scenario = 'Status Quo';

-- MView for NEP 2035
DROP MATERIALIZED VIEW IF EXISTS model_draft.ego_supply_conv_powerplant_nep2035_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_nep2035_mview AS
    SELECT *
    FROM  model_draft.ego_dp_supply_conv_powerplant
    WHERE scenario = 'NEP 2035'
    AND   capacity >= 0 
    AND   fuel not in ('hydro', 'run_of_river', 'reservoir')
    ;

-- MView for eGo 100
DROP MATERIALIZED VIEW IF EXISTS  model_draft.ego_supply_conv_powerplant_ego100_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_conv_powerplant_ego2050_mview AS
	SELECT 
	  'tba'::text as version,
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
	WHERE scenario in('Status Quo','NEP 2035', 'eGo 100')
	AND fuel = 'pumped_storage'
	AND capacity >= 0;


--------------------------------------------------------------------------------
-- Part IV 
--          Create View with full dataset per scenario
--------------------------------------------------------------------------------

-- MView for Status Quo
DROP MATERIALIZED VIEW IF EXISTS  model_draft.ego_supply_res_powerplant_sq_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_res_powerplant_sq_mview AS
    SELECT *
    FROM model_draft.ego_dp_supply_res_powerplant
    WHERE scenario =  'Status Quo';

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
			Where scenario in ('NEP 2035', 'ego-nep2035')
			Group BY id
			Order by id)
		 AND scenario in ('NEP 2035', 'ego-nep2035')
		 ORDER BY id	
	) sub2
	Order by id;
-- 01:56:3626 hours execution time.

-- MView for eGo 100
DROP MATERIALIZED VIEW IF EXISTS model_draft.ego_supply_res_powerplant_ego100_mview CASCADE;
CREATE MATERIALIZED VIEW model_draft.ego_supply_res_powerplant_ego100_mview AS
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
			Where scenario in ('eGo 100')
			AND generation_subtype not in ('solar','wind_offshore')
			AND generation_type not in ('gas')
			AND flag in ('decommissioning')
			Group BY id
			Order by id)
		 AND scenario in ('eGo 100')
		 ORDER BY id	
	) sub2
        UNION 
	SELECT
	sub3.*
	FROM  ( 
		SELECT  DISTINCT ON (id)
		  *
		FROM
		  model_draft.ego_dp_supply_res_powerplant	
		WHERE id in (
			SELECT id
			FROM model_draft.ego_dp_supply_res_powerplant
			Where scenario in ('NEP 2035', 'ego-nep2035')
			AND generation_subtype in ('solar','wind_offshore')
			AND flag in ('commissioning')
			Group BY id
			Order by id)
		 AND scenario in ('NEP 2035', 'ego-nep2035')
		 ORDER BY id	
	) sub3
	Order by id;

