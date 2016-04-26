
---------- ---------- ----------
-- Function "f_drop_tables" in public
---------- ---------- ----------

DROP FUNCTION IF EXISTS f_drop_tables(text[],text);
CREATE OR REPLACE FUNCTION f_drop_tables(_tbls text[] = '{}'
                                       , _schema text = 'public'
                                       , OUT drop_ct int)  AS
$func$
DECLARE
   _tbl   text;                             -- loop var
   _empty bool;                             -- for empty check
BEGIN
   drop_ct := 0;                            -- init!
   FOR _tbl IN 
      SELECT quote_ident(table_schema) || '.'
          || quote_ident(table_name)        -- qualified & escaped table name
      FROM   information_schema.tables
      WHERE  table_schema = _schema
      AND    table_type   = 'BASE TABLE'
      AND    table_name   = ANY(_tbls)
   LOOP
      EXECUTE 'SELECT NOT EXISTS (SELECT 1 FROM ' || _tbl || ')'
      INTO _empty;                          -- check first, only lock if empty

      IF _empty THEN
         EXECUTE 'LOCK TABLE ' || _tbl;     -- now table is ripe for the plucking

         EXECUTE 'SELECT NOT EXISTS (SELECT 1 FROM ' || _tbl || ')'
         INTO _empty;                       -- recheck after lock

         IF _empty THEN
            EXECUTE 'DROP TABLE ' || _tbl;  -- go in for the kill
            drop_ct := drop_ct + 1;         -- count tables actually dropped
         END IF;
      END IF;
   END LOOP;
END
$func$ LANGUAGE plpgsql STRICT;

---------- ---------- ----------
-- Call Function

-- SELECT f_drop_tables('{foo1,foo2,foo3,foo4}');
-- SELECT f_drop_tables('{foo1,foo2,foo3,foo4}', 'schema');



---------- ---------- ----------
-- Function "f_drop_view" in public
---------- ---------- ----------

DROP FUNCTION IF EXISTS f_drop_view(text[],text) ;
CREATE OR REPLACE FUNCTION f_drop_view(_views text[] = '{}'
                                       , _schema text = 'public'
                                       , OUT drop_ct int)  AS
$func$
DECLARE
   _view   text;                             -- loop var
   _empty bool;                             -- for empty check
BEGIN
   drop_ct := 0;                            -- init!
   FOR _view IN 
      SELECT quote_ident(table_schema) || '.'
          || quote_ident(table_name)        -- qualified & escaped table name
      FROM   information_schema.tables
      WHERE  table_schema = _schema
      AND    table_type   = 'VIEW'
      AND    table_name   = ANY(_views)
   LOOP
      EXECUTE 'SELECT NOT EXISTS (SELECT 1 FROM ' || _view || ')'
      INTO _empty;                          -- check first, only lock if empty

      IF _empty THEN
         
         EXECUTE 'SELECT NOT EXISTS (SELECT 1 FROM ' || _view || ')'
         INTO _empty;                       -- recheck after lock

         IF _empty THEN
            EXECUTE 'DROP VIEW ' || _view;  -- go in for the kill
            drop_ct := drop_ct + 1;         -- count tables actually dropped
         END IF;
      END IF;
   END LOOP;
END
$func$ LANGUAGE plpgsql STRICT;

---------- ---------- ----------
-- Call Function

-- SELECT f_drop_view('{foo1,foo2,foo3,foo4}');
-- SELECT f_drop_view('{foo1,foo2,foo3,foo4}', 'schema');