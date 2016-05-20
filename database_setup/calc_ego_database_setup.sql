
---------- ---------- ----------
-- Database setups   2016-05-20 17:00 1s
---------- ---------- ----------

-- -- Create schemas for open_eGo
-- DROP SCHEMA IF EXISTS	orig_ego;
-- CREATE SCHEMA 		orig_ego;

-- -- Set default privileges for schema
-- ALTER DEFAULT PRIVILEGES IN SCHEMA orig_ego GRANT ALL ON TABLES TO oeuser;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA orig_ego GRANT ALL ON SEQUENCES TO oeuser;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA orig_ego GRANT ALL ON FUNCTIONS TO oeuser;

-- -- Grant all in schema
-- GRANT ALL ON SCHEMA 	orig_ego TO oeuser WITH GRANT OPTION;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA orig_ego TO oeuser;