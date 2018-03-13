# coding: utf-8
from sqlalchemy import ARRAY, BigInteger, Boolean, CheckConstraint, Column, Date, DateTime, Float, ForeignKey, ForeignKeyConstraint, Index, Integer, JSON, Numeric, SmallInteger, String, Table, Text, UniqueConstraint, text
from geoalchemy2.types import Geometry, Raster
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql.hstore import HSTORE
from sqlalchemy.dialects.postgresql.base import OID
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.dialects.postgresql import ARRAY, DOUBLE_PRECISION, INTEGER, NUMERIC, TEXT, BIGINT, TIMESTAMP, VARCHAR

from sqlalchemy.orm import sessionmaker
from egoio.tools import db

Base = declarative_base()
metadata = Base.metadata

import pandas as pd



# class for ego.io
class EgoGridLineExpansionCosts(Base):
    __tablename__ = 'ego_grid_line_expansion_costs'
    __table_args__ = {'schema': 'model_draft'}

    cost_id = Column(Integer, primary_key=True)
    voltage_level = Column(Text)
    measure = Column(Text)
    component = Column(Text)
    investment_cost = Column(Float(53))
    unit = Column(Text)
    comment = Column(Text)
    source = Column(Text)

# DB connection
conn = db.connection(section='oedb')
Session = sessionmaker(bind=conn)
session = Session()

# get data
df = pd.read_csv('https://raw.githubusercontent.com/openego/eGo/dev/ego'\
                            '/data/investment_costs_of_grid_%20measures.csv',
                            sep=',',
                            thousands='.',
                            decimal=',',
                            header=0)

df.rename(index=str, columns={"id": "cost_id", "Spannungsebene": "voltage_level",
                              "Anlage/Anlagenteil": "component",
                              "Maßnahme": "measure",
                              "\nInvestionskosten ": "investment_cost",
                              "Einheit": "unit",
                              "Bemerkung": "comment",
                              "Literatur": "source",
                              "Source": "url_source"
                              },inplace=True)

df.drop('url_source', axis=1, inplace=True)

df.to_sql('ego_grid_line_expansion_costs', conn, flavor=None,
            schema='model_draft', if_exists='append', index=False)

# toDo calculate investment_cost in €/MWkm
# add calculation as a new entry and filter by unit
