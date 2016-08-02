# -*- coding: utf-8 -*-
from sqlalchemy import (Column, Float, ForeignKey, Integer, MetaData, String,
                        Table, join, create_engine,ForeignKeyConstraint,
                        Boolean, DateTime, Sequence)
from sqlalchemy.orm import sessionmaker, relationship, configure_mappers
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.ext.automap import automap_base
from geoalchemy2 import Geometry, shape
import configparser as cp
from sqlalchemy.sql import func
from sqlalchemy.dialects import postgresql
import os.path as path

FILENAME = 'config.ini'
FILE = path.join(path.expanduser("~"), '.open_eGo', FILENAME)
cfg = cp.ConfigParser()
cfg.read(FILE)

print("Connecting to database")

section = 'Connection'
conn = create_engine(
    "postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}".format(
        user=cfg.get(section, 'username'),
        password=cfg.get(section, 'password'),
        host=cfg.get(section, 'host'),
        port=cfg.get(section, 'port'),
        db=cfg.get(section, 'db')))

session = sessionmaker(bind=conn)()

meta = MetaData()
meta.bind = conn
meta.reflect(bind=conn, schema='coastdat')

Base = automap_base(metadata=meta)

class Located(Base):
    __tablename__ = 'coastdat.located'
    __table_args__ = ({'autoload': True},)

class Scheduled(Base):
    __tablename__ = 'coastdat.scheduled'
    __table_args__ = ({'autoload': True},)

class Typified(Base):
    __tablename__ = 'coastdat.typified'
    __table_args__ = ({'autoload': True},)

meta.reflect(bind=conn, schema='app_renpassgis')

class Region(Base):
    __tablename__ = 'app_renpassgis.parameter_region'
    __table_args__ = ({'autoload': True},)

# create new relations in target scheme app_renpassgis
class WindFeedin(Base):
    __tablename__ = 'parameter_wind_feedin'
    __table_args__ = ({'schema': 'app_renpassgis',
                       'extend_existing': True},)
    gid = Column(Integer,
                 #ForeignKey('coastdat.spatial.gid'),
                 primary_key=True)
    myyear = Column('year', Integer)
                  #ForeignKey('coastdat.year.year'))
    feedin = Column(postgresql.ARRAY(Float))
    geom = Column(Geometry('POINT', 4326))

class SolarFeedin(Base):
    __tablename__ = 'parameter_solar_feedin'
    __table_args__ = ({'schema': 'app_renpassgis',
                       'extend_existing': True},)
    gid = Column(Integer,
                 #ForeignKey('coastdat.spatial.gid'),
                 primary_key=True)
    myyear = Column('year', Integer)
                 #ForeignKey('coastdat.year.year'))
    feedin = Column(postgresql.ARRAY(Float))
    geom = Column(Geometry('POINT', 4326))

Base.metadata.create_all()

Base.prepare()

# map other classes
Datatype, Projection, Spatial, Timeseries, Year = Base.classes.datatype,\
    Base.classes.projection, Base.classes.spatial, Base.classes.timeseries,\
    Base.classes.year
