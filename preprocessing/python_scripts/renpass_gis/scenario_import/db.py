# -*- coding: utf-8 -*-
"""SQLA ORM
"""


__copyright__ = "ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "s3pp"


from sqlalchemy import MetaData, create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.automap import automap_base
import configparser as cp
import os.path as path
import oedialect

# read configuration file
FILENAME = 'config.ini'
FILE = path.join(path.expanduser("~"), '.open_eGo', FILENAME)
cfg = cp.ConfigParser()
cfg.read(FILE)

# establish db connection
section = 'oedb'
conn = create_engine(
    "postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}".format(
        user=cfg.get(section, 'username'),
        password=cfg.get(section, 'password'),
        host=cfg.get(section, 'host'),
        port=cfg.get(section, 'port'),
        db=cfg.get(section, 'database')))

print("Connected to database.")

# map schema
session = sessionmaker(bind=conn)()

meta = MetaData()
meta.bind = conn
meta.reflect(bind=conn, schema='calc_renpass_gis',
             only=['renpass_gis_scenario',
                   'renpass_gis_linear_transformer',
                   'renpass_gis_source',
                   'renpass_gis_sink',
                   'renpass_gis_storage',
                   'renpass_gis_results'])

# map to classes
Base = automap_base(metadata=meta)
Base.prepare()

Scenario, LinearTransformer, Source, Sink, Storage, Results = \
    Base.classes.renpass_gis_scenario,\
    Base.classes.renpass_gis_linear_transformer,\
    Base.classes.renpass_gis_source,\
    Base.classes.renpass_gis_sink,\
    Base.classes.renpass_gis_storage,\
    Base.classes.renpass_gis_results
