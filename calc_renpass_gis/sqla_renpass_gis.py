# coding: utf-8
from sqlalchemy import Column, DateTime, Float, ForeignKey, Integer, Numeric,\
create_engine, SmallInteger, String, Table, Text, text, MetaData, Sequence
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

section = 'Test'
conn = create_engine(
    "postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}".format(
        user=cfg.get(section, 'username'),
        password=cfg.get(section, 'password'),
        host=cfg.get(section, 'host'),
        port=cfg.get(section, 'port'),
        db=cfg.get(section, 'db')))

print("Connected.")

#session = sessionmaker(bind=conn)()
#session.execute(CreateSchema('calc_renpass_gis'))
#session.execute("SET search_path to 'calc_renpass_gis';show search_path;"):


metadata = MetaData(schema='calc_renpass_gis')
metadata.bind = conn
Base = declarative_base(metadata=metadata)

t_distribution_urid_to_nuts = Table(
    'distribution_urid_to_nuts', metadata,
    Column('scenario_name', String),
    Column('region_id', Integer),
    Column('dpr', SmallInteger, nullable=False),
    Column('nuts_id', String(14), nullable=False),
    Column('stat_levl_', SmallInteger, nullable=False),
    Column('region_key', String(12)),
    Column('urid', String(14)),
    schema='calc_renpass_gis'
)


t_new_windonshore = Table(
    'new_windonshore', metadata,
    Column('scenario_name', Text),
    Column('region_key', String),
    Column('year', Integer),
    Column('capacity', Float(53)),
    schema='calc_renpass_gis'
)


class ParameterEmission(Base):
    __tablename__ = 'parameter_emission'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    fuel = Column(String, primary_key=True)
    em_fuel = Column(Numeric(7, 3))


class ParameterRegion(Base):
    __tablename__ = 'parameter_region'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    gid = Column(Integer, Sequence('parameter_region_gid_seq', schema='calc_renpass_gis'), primary_key=True)
    u_region_id = Column(String(14), nullable=False)
    stat_level = Column(Integer)
    geom = Column(Geometry('MULTIPOLYGON', 4326))
    geom_point = Column(Geometry('POINT', 4326))


Base.metadata.create_all()

#class ParameterSolarFeedin(Base):
#    __tablename__ = 'parameter_solar_feedin'
#    __table_args__ = {'schema': 'calc_renpass_gis'}
#
#    gid = Column(Integer, primary_key=True, server_default=text("nextval('calc_renpass_gis.parameter_solar_feedin_gid_seq'::regclass)"))
#    year = Column(Integer)
#    feedin = Column(ARRAY(DOUBLE_PRECISION(precision=53)))
#    geom = Column(Geometry('POINT', 4326), index=True)
#

class ParameterThermalPowerplant(Base):
    __tablename__ = 'parameter_thermal_powerplant'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    fuel = Column(String(15), primary_key=True, nullable=False)
    type_of_generation = Column(String(10), primary_key=True, nullable=False)
    opex_fix = Column(Numeric(15, 3))
    opex_var = Column(Numeric(15, 3))


class ParameterWindCpcurve(Base):
    __tablename__ = 'parameter_wind_cpcurves'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    rli_anlagen_id = Column(String(70), primary_key=True)
    p_nenn = Column(Numeric)
    _0 = Column('0', Numeric)
    _0_5 = Column('0.5', Numeric)
    _1 = Column('1', Numeric)
    _1_5 = Column('1.5', Numeric)
    _2 = Column('2', Numeric)
    _2_5 = Column('2.5', Numeric)
    _3 = Column('3', Numeric)
    _3_5 = Column('3.5', Numeric)
    _4 = Column('4', Numeric)
    _4_5 = Column('4.5', Numeric)
    _5 = Column('5', Numeric)
    _5_5 = Column('5.5', Numeric)
    _6 = Column('6', Numeric)
    _6_5 = Column('6.5', Numeric)
    _7 = Column('7', Numeric)
    _7_5 = Column('7.5', Numeric)
    _8 = Column('8', Numeric)
    _8_5 = Column('8.5', Numeric)
    _9 = Column('9', Numeric)
    _9_5 = Column('9.5', Numeric)
    _10 = Column('10', Numeric)
    _10_5 = Column('10.5', Numeric)
    _11 = Column('11', Numeric)
    _11_5 = Column('11.5', Numeric)
    _12 = Column('12', Numeric)
    _12_5 = Column('12.5', Numeric)
    _13 = Column('13', Numeric)
    _13_5 = Column('13.5', Numeric)
    _14 = Column('14', Numeric)
    _14_5 = Column('14.5', Numeric)
    _15 = Column('15', Numeric)
    _15_5 = Column('15.5', Numeric)
    _16 = Column('16', Numeric)
    _16_5 = Column('16.5', Numeric)
    _17 = Column('17', Numeric)
    _17_5 = Column('17.5', Numeric)
    _18 = Column('18', Numeric)
    _18_5 = Column('18.5', Numeric)
    _19 = Column('19', Numeric)
    _19_5 = Column('19.5', Numeric)
    _20 = Column('20', Numeric)
    _20_5 = Column('20.5', Numeric)
    _21 = Column('21', Numeric)
    _21_5 = Column('21.5', Numeric)
    _22 = Column('22', Numeric)
    _22_5 = Column('22.5', Numeric)
    _23 = Column('23', Numeric)
    _23_5 = Column('23.5', Numeric)
    _24 = Column('24', Numeric)
    _24_5 = Column('24.5', Numeric)
    _25 = Column('25', Numeric)
    _25_5 = Column('25.5', Numeric)
    _26 = Column('26', Numeric)
    source = Column(String(60))
    modificationtimestamp = Column(DateTime)


class ParameterWindCurve(Base):
    __tablename__ = 'parameter_wind_curve'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    wind_speed = Column(Numeric(5, 2), primary_key=True, nullable=False)
    power_out = Column(Numeric(5, 2), nullable=False)
    type_id = Column(ForeignKey('calc_renpass_gis.parameter_wind_turbine.type_id', ondelete='CASCADE'), primary_key=True, nullable=False)

    type = relationship('ParameterWindTurbine')


#class ParameterWindFeedin(Base):
#    __tablename__ = 'parameter_wind_feedin'
#    __table_args__ = {'schema': 'calc_renpass_gis'}
#
#    gid = Column(Integer, primary_key=True, server_default=text("nextval('calc_renpass_gis.parameter_wind_feedin_gid_seq'::regclass)"))
#    year = Column(Integer)
#    feedin = Column(ARRAY(DOUBLE_PRECISION(precision=53)))
#    geom = Column(Geometry('POINT', 4326), index=True)
#

class ParameterWindTurbine(Base):
    __tablename__ = 'parameter_wind_turbine'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    type_id = Column(Integer, primary_key=True, server_default=text("nextval('calc_renpass_gis.parameter_wind_turbine_seq'::regclass)"))
    type_name = Column(Text)
    rotor_diameter = Column(Integer)
    hubheight = Column(Integer)
    rated_power = Column(Float(53))
    wtg_class = Column(Text)


class ParameterWindzone(Base):
    __tablename__ = 'parameter_windzones'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    gid = Column(Integer, primary_key=True, server_default=text("nextval('calc_renpass_gis.windzone_gid_seq'::regclass)"))
    zone = Column(SmallInteger)
    geom = Column(Geometry('MULTIPOLYGON', 4326), index=True)


class RegionScenario(Base):
    __tablename__ = 'region_scenario'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String)
    region_id = Column(Integer)
    dpr = Column(SmallInteger, primary_key=True, nullable=False)
    nuts_id = Column(String(14), primary_key=True, nullable=False)
    stat_levl_ = Column(SmallInteger, primary_key=True, nullable=False)
    region_key = Column(String(12))


class ScenarioBiomas(Base):
    __tablename__ = 'scenario_biomass'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String, primary_key=True, nullable=False)
    u_region_id = Column(String, primary_key=True, nullable=False)
    year = Column(Integer, primary_key=True, nullable=False)
    capacity = Column(Numeric(15, 3))
    amount = Column(Numeric(15, 3))


class ScenarioElDemandAmount(Base):
    __tablename__ = 'scenario_el_demand_amount'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String(50), primary_key=True, nullable=False)
    u_region_id = Column(String(14), primary_key=True, nullable=False)
    year = Column(Integer, primary_key=True, nullable=False)
    amount = Column(Numeric(15, 3))
    shape_id = Column(String(50), nullable=False)


class ScenarioElDemandShape(Base):
    __tablename__ = 'scenario_el_demand_shape'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    shape_id = Column(String(50), primary_key=True, nullable=False)
    hour = Column(Integer, primary_key=True, nullable=False)
    value = Column(Numeric(25, 23))


class ScenarioGeothermal(Base):
    __tablename__ = 'scenario_geothermal'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String, primary_key=True, nullable=False)
    u_region_id = Column(String, primary_key=True, nullable=False)
    year = Column(Integer, primary_key=True, nullable=False)
    capacity = Column(Numeric(15, 3))


class ScenarioRegion(Base):
    __tablename__ = 'scenario_region'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    dpr_urid = Column(String(14), primary_key=True, nullable=False)
    sub_urid = Column(String(14), primary_key=True, nullable=False)
    scenario_name = Column(String(50), primary_key=True, nullable=False)


class ScenarioRenewable(Base):
    __tablename__ = 'scenario_renewable'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String(50), primary_key=True)
    scenario_solar = Column(String(50), nullable=False)
    scenario_biomass = Column(String(50), nullable=False)
    scenario_geothermal = Column(String(50), nullable=False)
    scenario_runofriver = Column(String(50), nullable=False)
    scenario_windoffshore = Column(String(50), nullable=False)
    scenario_windonshore = Column(String(50), nullable=False)
    changed_by = Column(String(20), server_default=text("current_user"))
    lastmodified = Column(DateTime, server_default=text("now()"))


class ScenarioResource(Base):
    __tablename__ = 'scenario_resource'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String, primary_key=True, nullable=False)
    year = Column(Integer, primary_key=True, nullable=False)
    u_region_id = Column(String(14), primary_key=True, nullable=False)
    fuel = Column(String(50), primary_key=True, nullable=False)
    price = Column(Numeric(10, 2))


class ScenarioRunofriver(Base):
    __tablename__ = 'scenario_runofriver'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String, primary_key=True, nullable=False)
    u_region_id = Column(String, primary_key=True, nullable=False)
    year = Column(Integer, primary_key=True, nullable=False)
    capacity = Column(Numeric(15, 3))


class ScenarioSetting(Base):
    __tablename__ = 'scenario_setting'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String(50), primary_key=True, nullable=False)
    scenario_year = Column(Integer, primary_key=True, nullable=False)
    weather_year = Column(Integer, nullable=False)
    scenario_el_demand_amount = Column(String(50), nullable=False)
    scenario_transshipment = Column(String(50), nullable=False)
    scenario_region = Column(String(50), nullable=False)
    scenario_renewable = Column(String(50), nullable=False)
    scenario_resource = Column(String(50), nullable=False)
    scenario_storage = Column(String(50), nullable=False)
    scenario_thermal_powerplant = Column(String(50), nullable=False)
    changed_by = Column(String(20), server_default=text("current_user"))
    lastmodified = Column(DateTime, server_default=text("now()"))


class ScenarioSolar(Base):
    __tablename__ = 'scenario_solar'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String, primary_key=True, nullable=False)
    u_region_id = Column(String, primary_key=True, nullable=False)
    year = Column(Integer, primary_key=True, nullable=False)
    capacity = Column(Numeric(15, 3))


class ScenarioStorage(Base):
    __tablename__ = 'scenario_storage'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String(50), primary_key=True, nullable=False)
    u_region_id = Column(String(14), primary_key=True, nullable=False)
    year = Column(Integer, primary_key=True, nullable=False)
    type = Column(String(50), primary_key=True, nullable=False)
    capacity_in = Column(Numeric(15, 3))
    capacity_out = Column(Numeric(15, 3))
    energy = Column(Numeric(30, 3))
    efficiency_in = Column(Numeric(4, 3))
    efficiency_out = Column(Numeric(4, 3))
    self_discharge = Column(Numeric(4, 3))


class ScenarioThermalPowerplant(Base):
    __tablename__ = 'scenario_thermal_powerplant'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String(50), primary_key=True, nullable=False)
    fuel = Column(String(15), primary_key=True, nullable=False)
    type_of_generation = Column(String(5), primary_key=True, nullable=False)
    capacity = Column(Numeric(15, 3))
    year = Column(Integer, primary_key=True, nullable=False)
    u_region_id = Column(String(14), primary_key=True, nullable=False)
    efficiency = Column(ARRAY(NUMERIC()), primary_key=True, nullable=False)


class ScenarioTransshipment(Base):
    __tablename__ = 'scenario_transshipment'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String, primary_key=True, nullable=False)
    from_urid = Column(String(14), primary_key=True, nullable=False)
    to_urid = Column(String(14), primary_key=True, nullable=False)
    year = Column(Integer, primary_key=True, nullable=False)
    capacity = Column(Integer)
    grid_loss = Column(Numeric(3, 2))


class ScenarioWindoffshore(Base):
    __tablename__ = 'scenario_windoffshore'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String, primary_key=True, nullable=False)
    u_region_id = Column(String, primary_key=True, nullable=False)
    year = Column(Integer, primary_key=True, nullable=False)
    capacity = Column(Numeric(15, 3))


class ScenarioWindonshore(Base):
    __tablename__ = 'scenario_windonshore'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    scenario_name = Column(String, primary_key=True, nullable=False)
    u_region_id = Column(String, primary_key=True, nullable=False)
    year = Column(Integer, primary_key=True, nullable=False)
    capacity = Column(Numeric(15, 3))


t_scenario_windonshore_append = Table(
    'scenario_windonshore_append', metadata,
    Column('scenario_name', Text),
    Column('u_region_id', String(14)),
    Column('year', Integer),
    Column('capacity', Float(53)),
    schema='calc_renpass_gis'
)


class VernetzenGridLink(Base):
    __tablename__ = 'vernetzen_grid_links'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    l_id = Column(SmallInteger, primary_key=True)
    v_id_1 = Column(SmallInteger, nullable=False)
    v_id_2 = Column(SmallInteger, nullable=False)
    voltage = Column(Integer)
    cables = Column(SmallInteger)
    wires = Column(SmallInteger)
    frequency = Column(SmallInteger)
    length_m = Column(Integer)
    r = Column(Numeric(10, 5))
    x = Column(Numeric(10, 5))
    c = Column(Numeric(10, 5))
    i_th_max = Column(Numeric(10, 5))
    kind_of_current = Column(String(2))
    capacity = Column(Integer)
    kind_of_capacity = Column(String(25))
    kind_of_laying = Column(String(25))
    commissioning = Column(SmallInteger)
    decommission = Column(SmallInteger)
    delay = Column(SmallInteger)
    akzeptanz = Column(SmallInteger)
    status = Column(String(25))
    p_id = Column(SmallInteger)
    s_id = Column(SmallInteger)
    nova = Column(String(254))
    geom = Column(Geometry('LINESTRING', 4326))
    from_urid = Column(String(14))
    to_urid = Column(String(14))


class VernetzenGridVertice(Base):
    __tablename__ = 'vernetzen_grid_vertices'
    __table_args__ = {'schema': 'calc_renpass_gis'}

    v_id = Column(SmallInteger, primary_key=True)
    lon = Column(Numeric(10, 8))
    lat = Column(Numeric(10, 8))
    typ = Column(String)
    voltage = Column(String)
    commissioning = Column(Integer)
    name = Column(String)
    status = Column(String(25))
    geom = Column(Geometry('POINT', 4326))
    u_region_id = Column(String(14))

Base.metadata.create_all()
