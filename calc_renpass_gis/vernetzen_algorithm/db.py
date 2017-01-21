#!/bin/python
# -*- coding: utf-8 -*-
"""
Enables DB access to tables on the oedb and on the VerNetzen server.

You have to create a configuration file in ~/.open_eGo/config.ini .

[oedb]
username =
password =
host =
port =
db =
[vernetzen]
username =
password =
host =
port =
db =

"""

from sqlalchemy import MetaData, create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.automap import automap_base
import configparser as cp
import os.path as path

FILENAME = 'config.ini'
FILE = path.join(path.expanduser("~"), '.open_eGo', FILENAME)
cfg = cp.ConfigParser()
cfg.read(FILE)


def conn_from_config(**kwargs):
    """
    """

    section = kwargs.get('section', None)
    conn = create_engine(
        "postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}".format(
            user=cfg.get(section, 'username'),
            password=cfg.get(section, 'password'),
            host=cfg.get(section, 'host'),
            port=cfg.get(section, 'port'),
            db=cfg.get(section, 'db')))
    return conn

# create database engines
vernetzen = conn_from_config(section='vernetzen')
oedb = conn_from_config(section='oedb')

meta = MetaData()

# engine is not globally bound, thus used in reflect. I'm not sure whether you
# can bind different engines to tables dynamically
meta.reflect(bind=vernetzen, schema='coastdat')
meta.reflect(bind=vernetzen, schema='vn_wind', only=['geo_pot_area_dump'])
meta.reflect(bind=vernetzen, schema='vn', only=['geo_federal_state'])
meta.reflect(bind=oedb, schema='calc_ego_grid_district',
             only=['grid_district'])
meta.reflect(bind=oedb, schema='orig_scenario_data',
             only=['nep_2015_scenario_capacities'])

# map classes ot Base
Base = automap_base(metadata=meta)

# add classes, that are not included
class Located(Base):
    __tablename__ = 'coastdat.located'
    __table_args__ = ({'autoload': True},)


class Scheduled(Base):
    __tablename__ = 'coastdat.scheduled'
    __table_args__ = ({'autoload': True},)


class Typified(Base):
    __tablename__ = 'coastdat.typified'
    __table_args__ = ({'autoload': True},)

Base.prepare()

# extract class names
FederalStates, CosmoClmGrid, GeoPotArea, Timeseries, Datatype,\
    ScenarioCapacities, Projection, Spatial, Year, GridDistrict =\
    Base.classes.geo_federal_state, Base.classes.cosmoclmgrid,\
    Base.classes.geo_pot_area_dump, Base.classes.timeseries, Base.classes.datatype,\
    Base.classes.nep_2015_scenario_capacities, Base.classes.projection,\
    Base.classes.spatial, Base.classes.year, Base.classes.grid_district


# bind classes to corresponding engine
Session = sessionmaker(binds={
    FederalStates: vernetzen,
    CosmoClmGrid: vernetzen,
    GeoPotArea: vernetzen,
    Timeseries: vernetzen,
    Datatype: vernetzen,
    Projection: vernetzen,
    Spatial: vernetzen,
    Year: vernetzen,
    Located: vernetzen,
    Scheduled: vernetzen,
    Typified: vernetzen,
    ScenarioCapacities: oedb,
    GridDistrict: oedb})

session = Session()

