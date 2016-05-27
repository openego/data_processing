# Copyright 2016 by NEXT ENERGY
# Published under GNU GENERAL PUBLIC LICENSE Version 3 (see https://github.com/openego/data_processing/blob/master/LICENSE)

import os
import sys
import optparse
import psycopg2
import logging

LOG_FILENAME = 'messages.log'
logging.basicConfig(filename=LOG_FILENAME, level = logging.NOTSET)
logging = logging.getLogger(__name__)

def dbconn_from_args(argv=sys.argv[1:], environ=os.environ):
    """
    Get database connection from command-line arguments or environment variables.
    Reuse environment variables from libpq/psql
    (see http://www.postgresql.org/docs/9.3/static/libpq-envars.html)
    """
    parser = optparse.OptionParser()
    parser.add_option("-D","--dbname", action="store", dest="dbname",
                      help="database name of the topology network")
    parser.add_option("-H","--dbhost", action="store", dest="dbhost",
                      help="database host address of the topology network")
    parser.add_option("-P","--dbport", action="store", dest="dbport",
                      help="database port of the topology network")
    parser.add_option("-U","--dbuser", action="store", dest="dbuser",
                      help="database user name of the topology network")
    parser.add_option("-X","--dbpwrd", action="store", dest="dbpwrd",
                      help="database user password of the topology network")

    (options, args) = parser.parse_args(argv)
    # Options have precedence over environment variables, which have
    # precedence over defaults.

    # NB: None (or null) host and port values are completely reasonable and
    # mean a local (unix domain socket) connection. This way postgresql can
    # be configured without network support, which is convenient and secure.
    dbhost = options.dbhost or environ.get('PGHOST','127.0.0.1')
    dbport = options.dbport or environ.get('PGPORT','5432')
    dbuser = options.dbuser or environ.get('PGUSER', 'postgres')
    # A None password is also valid but it implies the server must be configured
    # to support either 'trust' or 'ident' identification. For a local server this
    # is convenient, but it isn't secure for network installations. Review
    # man pg_hba.conf for the details.
    dbpwrd = options.dbpwrd or environ.get('PGPASSWORD')
    dbname = options.dbname or environ.get('PGDATABASE')

    try:
        return psycopg2.connect(host=dbhost, port=dbport, user=dbuser,
                                password=dbpwrd, database=dbname)
    except psycopg2.Error as e:
        logging.error("Could not connect to database with supplied information", exc_info=True)
        if len(argv) == 0 or len(args) == len(argv):
            parser.print_help()
        raise e


