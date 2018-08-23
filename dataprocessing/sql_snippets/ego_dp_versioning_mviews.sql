/*
eGo Data Processing result data versioning
Copy a version of mvies from model_draft to OEP schema

__copyright__ 	= "Europa-Universität Flensburg"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 	= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 	= "wolfbunke"
*/

-- Create MView with full dataset per scenario and conventional power plants for schema supply 

-- MView for Status Quo
DROP MATERIALIZED VIEW IF EXISTS  supply.ego_dp_conv_powerplant_sq_mview CASCADE;
CREATE MATERIALIZED VIEW supply.ego_dp_conv_powerplant_sq_mview AS
    SELECT DISTINCT *
    FROM supply.ego_dp_conv_powerplant
    WHERE scenario = 'Status Quo'
    AND (shutdown IS NULL or shutdown >= 2015)
    AND capacity > 0
    AND preversion = 'v0.3.0';
    --AND version in ('v0.4.4','v0.4.5');


ALTER MATERIALIZED VIEW supply.ego_dp_conv_powerplant_sq_mview
    OWNER TO oeuser; 

-- MView for NEP 2035
DROP MATERIALIZED VIEW IF EXISTS supply.ego_dp_conv_powerplant_nep2035_mview CASCADE;
CREATE MATERIALIZED VIEW supply.ego_dp_conv_powerplant_nep2035_mview AS
    SELECT DISTINCT*
    FROM  supply.ego_dp_conv_powerplant
    WHERE scenario = 'NEP 2035'
    AND   capacity > 0 
    AND   fuel not in ('hydro', 'run_of_river', 'reservoir')

    AND   (shutdown IS NULL or shutdown >= 2034)
    AND   preversion = 'v0.3.0';
    AND version in ('v0.4.4','v0.4.5');


ALTER MATERIALIZED VIEW supply.ego_dp_conv_powerplant_nep2035_mview
    OWNER TO oeuser;

-- MView for eGo 100
DROP MATERIALIZED VIEW IF EXISTS  supply.ego_dp_conv_powerplant_ego100_mview CASCADE;
CREATE MATERIALIZED VIEW supply.ego_dp_conv_powerplant_ego100_mview AS
	SELECT DISTINCT
	  version,
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
	FROM supply.ego_dp_conv_powerplant
	WHERE scenario in('NEP 2035')
	AND fuel = 'pumped_storage'
	AND capacity > 0
	AND (shutdown IS NULL or shutdown >= 2049)
	AND preversion = 'v0.3.0';
	AND version in ('v0.4.4','v0.4.5');

ALTER MATERIALIZED VIEW supply.ego_dp_conv_powerplant_ego100_mview
    OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.5','result','supply','ego_dp_conv_powerplant_sq_mview','ego_dp_versioning_mviews.sql','versioning');
SELECT scenario_log('eGo_DP','v0.4.5','result','supply','ego_dp_conv_powerplant_nep2035_mview','ego_dp_versioning_mviews.sql','versioning');
SELECT scenario_log('eGo_DP','v0.4.5','result','supply','ego_dp_conv_powerplant_ego100_mview','ego_dp_versioning_mviews.sql','versioning');

-- Create View with full dataset per scenario and renewables power plants

-- MView for Status Quo  
DROP MATERIALIZED VIEW IF EXISTS supply.ego_dp_res_powerplant_sq_mview CASCADE;
CREATE MATERIALIZED VIEW supply.ego_dp_res_powerplant_sq_mview AS
    SELECT DISTINCT*
    FROM supply.ego_dp_res_powerplant
    WHERE scenario =  'Status Quo'
    AND electrical_capacity > 0
    AND preversion = 'v0.3.0';
    --AND version in ('v0.4.2','v0.4.4','v0.4.5');


ALTER MATERIALIZED VIEW supply.ego_dp_res_powerplant_sq_mview
    OWNER TO oeuser;

-- MView for NEP 2035
DROP MATERIALIZED VIEW IF EXISTS supply.ego_dp_res_powerplant_nep2035_mview CASCADE;
CREATE MATERIALIZED VIEW supply.ego_dp_res_powerplant_nep2035_mview AS
	SELECT 
	sub.*
	FROM  ( 
		SELECT DISTINCT ON (id||version)
		  *
		FROM
		  supply.ego_dp_res_powerplant
			WHERE id||version not in (
			SELECT  id||version
			FROM supply.ego_dp_res_powerplant
			WHERE version in ('v0.4.4','v0.4.5')
			Group BY id||version
			HAVING count(*) > 1
			Order by id||version)
		 AND scenario = 'Status Quo'
		 And preversion = 'v0.3.0'
		 AND version in ('v0.4.4','v0.4.5')
		 AND electrical_capacity > 0
		 ORDER BY id||version	
		 ) as sub
	UNION 
	SELECT 
	sub2.*
	FROM  ( 
		SELECT DISTINCT ON (id||version)
		  *
		FROM
		  supply.ego_dp_res_powerplant
		WHERE id||version in (
			SELECT  id||version
			FROM supply.ego_dp_res_powerplant
			WHERE scenario in ('NEP 2035')

			AND version in ('v0.4.4','v0.4.5')
			Group BY id||version
			Order by id||version)
		 AND scenario in ('NEP 2035')
		 And preversion = 'v0.3.0'
		 AND version in ('v0.4.4','v0.4.5')
		 AND electrical_capacity > 0
		 ORDER BY id||version	
	) sub2
	Order by id;

ALTER MATERIALIZED VIEW supply.ego_dp_res_powerplant_nep2035_mview
    OWNER TO oeuser; 
    
-- MView for eGo 100
DROP MATERIALIZED VIEW IF EXISTS supply.ego_dp_res_powerplant_ego100_mview CASCADE;
CREATE MATERIALIZED VIEW supply.ego_dp_res_powerplant_ego100_mview AS
	SELECT DISTINCT ON (id||version)
	sub.*
	FROM  ( 
		SELECT DISTINCT ON (id||version)
		  *
		FROM
		  supply.ego_dp_res_powerplant
			WHERE id||version not in (
			SELECT id||version
			FROM supply.ego_dp_res_powerplant
			WHERE version in ('v0.4.4','v0.4.5')
			Group BY id||version
			HAVING count(*) > 1
			Order by id||version)
		 AND scenario = 'Status Quo'
		 AND preversion = 'v0.3.0'
		 AND version in ('v0.4.4','v0.4.5')
		 AND electrical_capacity > 0
		 AND generation_type in ('solar','wind')
		 AND generation_subtype not in ('wind_offshore')
		 ORDER BY id||version	
		 ) as sub
	UNION 
	SELECT DISTINCT ON (id||version)
	sub2.*
	FROM  ( 
		SELECT  DISTINCT ON (id||version)
		  *
		FROM
		  supply.ego_dp_res_powerplant
		WHERE id||version in (
			SELECT id||version
			FROM supply.ego_dp_res_powerplant
			WHERE scenario in ('eGo 100')
			AND generation_type not in ('gas')
			AND version in ('v0.4.4','v0.4.5')
			AND flag in ('commissioning', 'repowering')
			Group BY id||version
			Order by id||version)
		 AND scenario in ('eGo 100')
		 And preversion = 'v0.3.0'
		 AND version in ('v0.4.4','v0.4.5')
		 AND electrical_capacity > 0
		 ORDER BY id||version	
	) sub2
        UNION 
	SELECT DISTINCT ON (id||version)
	sub3.*
	FROM  ( 
		SELECT  DISTINCT ON (id||version)
		  *
		FROM
		  supply.ego_dp_res_powerplant
		WHERE id||version in (
			SELECT id||version
			FROM supply.ego_dp_res_powerplant
			WHERE scenario in ('NEP 2035')
			AND version in ('v0.4.4','v0.4.5')
			AND generation_type not in ('biomass','gas','reservoir','run_of_river')
			AND flag in ('commissioning', 'repowering')
			AND generation_subtype not in ('wind_offshore')
			Group BY id||version
			Order by id||version)
		 AND scenario in ('NEP 2035')
		 And preversion = 'v0.3.0'
		 AND version in ('v0.4.4','v0.4.5')
		 AND electrical_capacity > 0
		 ORDER BY id||version	
	) sub3
	Order by id;

ALTER MATERIALIZED VIEW supply.ego_dp_res_powerplant_ego100_mview
    OWNER TO oeuser;

-- scenario log (project,version,io,schema_name,table_name,script_name,comment)
SELECT scenario_log('eGo_DP','v0.4.5','result','supply','ego_dp_res_powerplant_sq_mview','ego_dp_versioning_mviews.sql','versioning');
SELECT scenario_log('eGo_DP','v0.4.5','result','supply','ego_dp_res_powerplant_nep2035_mview','ego_dp_versioning_mviews.sql','versioning');
SELECT scenario_log('eGo_DP','v0.4.5','result','supply','ego_dp_res_powerplant_ego100_mview','ego_dp_versioning_mviews.sql','versioning');
