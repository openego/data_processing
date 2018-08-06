#!/bin/python
# -*- coding: utf-8 -*-
"""
This module uses the ORM of SQLAlchemy to create classes of relations of the
CoastDat2 database schema.

You have to create a configuration file in ~/.open_eGo/config.ini .

    [home]
    username =
    password =
    host =
    port =
    db =

"""


__copyright__ = "ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "s3pp"


from sqlalchemy import Column, MetaData, create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.automap import automap_base
from geoalchemy2 import Geometry, shape  # Geometry type used by SQLA
import configparser as cp
import os


def readcfg(path):
    """ Reads the configuration file

    Parameters
    ----------

    path : str
        Filepath.

    Returns
    -------
    cfg : configparser.ConfigParser
        Used for configuration file parser language.

    """

    cfg = cp.ConfigParser()
    cfg.read(path)

    return cfg


def dbconnect(section, cfg):
    """ Uses db connection parameters to establish a connection.

    Parameters
    ----------
    section : str
        Section in configuration file.
    cfg : configparser.ConfigParser
        Used for configuration file parser language.

    Returs
    ------
    conn : sqlalchemy.engine.Engine

    """

    conn = create_engine(
        "postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}".format(
            user=cfg.get(section, 'username'),
            password=cfg.get(section, 'password'),
            host=cfg.get(section, 'host'),
            port=cfg.get(section, 'port'),
            db=cfg.get(section, 'db')))
    return conn


def meta_definition(meta, conn):
    """ Populates SQLAlchemy Meta object
    """
    #meta.reflect(bind=conn, schema='coastdat')
    #meta.reflect(bind=conn, schema='model_draft',
    #             only=['ego_weather_measurement_point'])

    #meta.reflect(bind=conn, schema='public',
    #             only=['weather_measurement_point'])  # table with given/ own defined points


def other_classes():
    """ Maps additional classes not mapped by SQLAlchemy automap.

    Parameters
    ----------
    base : AutomapBase
        Auto-generates mapped classes.

    Notes
    -----
    Here define classes explicitly, if they are not auto-generated.
    """

    class Located(Base):
        __tablename__ = 'coastdat.located'
        __table_args__ = ({'autoload': True},)

    class Scheduled(Base):
        __tablename__ = 'coastdat.scheduled'
        __table_args__ = ({'autoload': True},)

    class Typified(Base):
        __tablename__ = 'coastdat.typified'
        __table_args__ = ({'autoload': True},)

    # Base.metadata.create_all()

    return Located, Scheduled, Typified

print('Connecting to database.')

# read configuration file
path = os.path.join(os.path.expanduser("~"), '.open_eGo', 'config.ini')
config = readcfg(path=path)

# establish DB connection
section = 'coastdat'
conn = dbconnect(section=section, cfg=config)

# instantiate container object MetaData
meta = MetaData()
meta.bind=conn
meta_definition(meta=meta, conn=conn)

# map classes, automap does not gather all classes
Base = automap_base(metadata=meta)

# map other classes; TODO: classes are locals of func
#Located, Scheduled, Typified = other_classes()

meta.reflect(bind=conn, schema='model_draft')
class Grid(Base):
    __tablename__ = 'model_draft.openfredgrid'
    __table_args__ = ({'autoload': True},)


Base.prepare()

# simplify class names
#Point = Base.classes.ego_weather_measurement_point

session = sessionmaker(bind=conn)()

print('Retrieve data...')
#query = session.query(Point.coastdat_id, Point.type_of_generation, Point.geom)
#Points =  [(coastdat_id, type_of_generation, shape.to_shape(geom))
#           for coastdat_id, type_of_generation, geom in query.all()]

print('Done!')

