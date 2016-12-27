-- table
DROP TABLE IF EXISTS  	model_draft.test_table CASCADE;
CREATE TABLE         	model_draft.test_table AS
	SELECT	*
	FROM	model_draft.ego_wpa
	WHERE 	id < '100';

-- grant (oeuser)
ALTER TABLE	model_draft.test_table OWNER TO oeuser;

-- metadata
SELECT copy_comment_table('model_draft.ego_wpa','model_draft.test_table');
SELECT obj_description('model_draft.test_table' ::regclass) ::json;


-- mview
DROP MATERIALIZED VIEW IF EXISTS  	model_draft.test_mview CASCADE;
CREATE MATERIALIZED VIEW         	model_draft.test_mview AS
	SELECT	*
	FROM	model_draft.ego_wpa
	WHERE 	id < '100';

-- grant (oeuser)
ALTER TABLE	model_draft.test_mview OWNER TO oeuser;

-- metadata
SELECT copy_comment_mview('model_draft.ego_wpa','model_draft.test_mview');
SELECT obj_description('model_draft.test_mview' ::regclass) ::json;