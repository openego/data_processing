
---------- ---------- ----------
-- Database setups   2016-04-17 21:00 1s
---------- ---------- ----------

-- -- Create schema for open_eGo
-- DROP SCHEMA IF EXISTS	orig_ego;
-- CREATE SCHEMA 		orig_ego;

-- -- Set default privileges for schema
-- ALTER DEFAULT PRIVILEGES IN SCHEMA orig_ego GRANT ALL ON TABLES TO oeuser;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA orig_ego GRANT ALL ON SEQUENCES TO oeuser;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA orig_ego GRANT ALL ON FUNCTIONS TO oeuser;

-- -- Grant all in schema
-- GRANT ALL ON SCHEMA 	orig_ego TO oeuser WITH GRANT OPTION;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA orig_ego TO oeuser;