from sqlalchemy import create_engine
import getpass
import sys

def oedb_session(section='oedb'):
    """Get SQLAlchemy session object with valid connection to OEDB"""

    # get session object by oemof.db tools (requires .oemof/config.ini
    try:
        from oemof import db
        conn = db.connection(section=section)

    except:
        print('Please provide connection parameters to database:\n' +
              'Hit [Enter] to take defaults')

        host = input('host (default 141.44.24.88): ') or 'oe.iws.cs.ovgu.de'
        port = input('port (default 5432): ') or '5432'
        database = input("database name (default 'oedb'): ") or 'oedb'
        user = input('user (default postgres): ')
        # password = input('password: ')
        password = getpass.getpass(prompt='password: ',
                                   stream=sys.stderr)
        conn = create_engine(
            'postgresql://' + '%s:%s@%s:%s/%s' % (user,
                                                  password,
                                                  host,
                                                  port,
                                                  database)).connect()

    return conn


def load_external_file(fname, dpath):
    """ Load external file based on the extension of the file

    # TODO This could also be a dinstinction based on functions comment / data?

    Parameters
    ----------
    fname : str
        Filename.
    dpath : str
        Path to the directory.

    Returns
    -------
    dict or list of records
    """

    fpath = dpath + fname

    def loadjson(f):
        return json.load(f)

    def loadcsv(f):
        return list(csv.DictReader(f))

    methods = {'.json': loadjson,
               '.csv' : loadcsv}

    f, file_extension = os.path.splitext(fname)

    try:
        with open(fpath) as f:
            return methods[file_extension](f)
    except FileNotFoundError:
        print('No external file found at %s.' % fpath)
