-- http://stackoverflow.com/questions/272438/setting-the-comment-of-a-column-to-that-of-another-column-in-postgresql

DROP FUNCTION IF EXISTS copy_comment_mview(varchar,varchar);
CREATE OR REPLACE FUNCTION copy_comment_mview(varchar,varchar) RETURNS int AS $PROC$
DECLARE
        src_tbl ALIAS FOR $1;
        dst_tbl ALIAS FOR $2;
        comment VARCHAR;
BEGIN
	EXECUTE 'SELECT obj_description(' || quote_literal(src_tbl) ||  ' ::regclass) ::json' INTO comment;

        EXECUTE 'COMMENT ON MATERIALIZED VIEW ' || dst_tbl || ' IS ' || quote_literal(comment);

        RETURN 1;
END;
$PROC$ LANGUAGE plpgsql;

-- grant (oeuser)
ALTER FUNCTION	copy_comment_mview(varchar,varchar) OWNER TO oeuser;
