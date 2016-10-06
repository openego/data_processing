# -*- coding: utf-8 -*-
from sqlalchemy import (Column, Float, ForeignKey, Integer, MetaData, String,
                        Table, join, create_engine, ForeignKeyConstraint,
                        Boolean, DateTime, Sequence)
from sqlalchemy.orm import sessionmaker, relationship, configure_mappers
# from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.ext.automap import automap_base
# from geoalchemy2 import Geometry, shape
import configparser as cp
# from sqlalchemy.sql import func
# from sqlalchemy.dialects import postgresql
import os.path as path

# read configuration file
FILENAME = 'config.ini'
FILE = path.join(path.expanduser("~"), '.open_eGo', FILENAME)
cfg = cp.ConfigParser()
cfg.read(FILE)

# establish db connection
section = 'Connection'
conn = create_engine(
    "postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}".format(
        user=cfg.get(section, 'username'),
        password=cfg.get(section, 'password'),
        host=cfg.get(section, 'host'),
        port=cfg.get(section, 'port'),
        db=cfg.get(section, 'db')))

print("Connected to database.")


# establish  second db connection to
# change of init file in .open_ego and Server connetion via ssh required
section2 = 'Coastdat'
conn2 = create_engine(
    "postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}".format(
        user=cfg.get(section2, 'username'),
        password=cfg.get(section2, 'password'),
        host=cfg.get(section2, 'host'),
        port=cfg.get(section2, 'port'),
        db=cfg.get(section2, 'db')))

print("Connected to database 2.")



# map schema
session = sessionmaker(bind=conn)()

meta = MetaData()
meta.bind = conn
meta.reflect(bind=conn, schema='calc_renpass_gis',
             only=['renpass_gis_scenario',
                   'renpass_gis_linear_transformer',
                   'renpass_gis_source',
                   'renpass_gis_sink',
                   'renpass_gis_storage'])

# map to classes
Base = automap_base(metadata=meta)
Base.prepare()

Scenario, LinearTransformer, Source, Sink, Storage = \
    Base.classes.renpass_gis_scenario,\
    Base.classes.renpass_gis_linear_transformer,\
    Base.classes.renpass_gis_source,\
    Base.classes.renpass_gis_sink,\
    Base.classes.renpass_gis_storage

# map schema of coastdat-2
session2 = sessionmaker(bind=conn)()

meta2 = MetaData()
meta2.bind = conn2
meta2.reflect(bind=conn2, schema='coastdat',
             only=['cosmoclmgrid',
                   'datatype',
                   'located',
                   'projection',
                   'scheduled',
                   'spatial',
                   'timeseries',                   
                   'typified',
                   'year'])


# map to classes of coastdat weather data
Coastdat = automap_base(metadata=meta2)
Coastdat.prepare()
 