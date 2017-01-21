# coding: utf-8
from sqlalchemy import Column, DateTime, Float, ForeignKey, Integer, Numeric,\
create_engine, SmallInteger, String, Table, Text, text, MetaData, Sequence, Index
from geoalchemy2.types import Geometry
from sqlalchemy.dialects.postgresql.base import ARRAY, DOUBLE_PRECISION, NUMERIC
from sqlalchemy.orm import relationship, sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.schema import CreateSchema
import os.path as path
import configparser as cp

FILENAME = 'config.ini'
FILE = path.join(path.expanduser("~"), '.open_eGo', FILENAME)
cfg = cp.ConfigParser()
cfg.read(FILE)

print("Connecting to database")

section = 'oedb'
conn = create_engine(
    "postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}".format(
        user=cfg.get(section, 'username'),
        password=cfg.get(section, 'password'),
        host=cfg.get(section, 'host'),
        port=cfg.get(section, 'port'),
        db=cfg.get(section, 'db')))

print("Connected.")

#session = sessionmaker(bind=conn)()
conn.execute(CreateSchema('calc_renpass_gis'))

# in order to neglect schema
#session.execute("SET search_path to 'calc_renpass_gis';show search_path;"):

metadata = MetaData(schema='calc_renpass_gis')
metadata.bind = conn
Base = declarative_base(metadata=metadata)

class ParameterWindFeedin(Base):
    __tablename__ = 'parameter_wind_feedin'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    gid = Column(Integer,
                 Sequence('parameter_wind_feedin_gid_seq',
                          schema='calc_renpass_gis'),
                 primary_key=True)
    year = Column(Integer)
    feedin = Column(ARRAY(DOUBLE_PRECISION(precision=53)))
    geom = Column(Geometry('POINT', 4326))

#Index('parameter_wind_feedin_geom_gist', ParameterWindFeedin.geom,
#      postgresql_using='gist')

Base.metadata.create_all()
