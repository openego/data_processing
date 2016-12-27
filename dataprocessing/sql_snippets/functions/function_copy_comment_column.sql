-- http://stackoverflow.com/questions/272438/setting-the-comment-of-a-column-to-that-of-another-column-in-postgresql

DROP FUNCTION IF EXISTS copy_comment_column(varchar,int,varchar,varchar);
CREATE OR REPLACE FUNCTION copy_comment_column(varchar,int,varchar,varchar) RETURNS int AS $PROC$
DECLARE
        src_tbl ALIAS FOR $1;
        src_col ALIAS FOR $2;
        dst_tbl ALIAS FOR $3;
        dst_col ALIAS FOR $4;
        row RECORD;
        oid INT;
        comment VARCHAR;
BEGIN
        FOR row IN EXECUTE 'SELECT DISTINCT tableoid FROM ' || quote_ident(src_tbl) LOOP
                oid := row.tableoid;
        END LOOP;

        FOR row IN EXECUTE 'SELECT col_description(' || quote_literal(oid) || ',' || quote_literal(src_col) || ')' LOOP
                comment := row.col_description;
        END LOOP;

        EXECUTE 'COMMENT ON COLUMN ' || quote_ident(dst_tbl) || '.' || quote_ident(dst_col) || ' IS ' || quote_literal(comment);

        RETURN 1;
END;
$PROC$ LANGUAGE plpgsql;