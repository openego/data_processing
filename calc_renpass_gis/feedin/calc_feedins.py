# -*- coding: utf-8 -*-
from geoalchemy2 import Geometry, shape
import configparser as cp
from oemof.db.config import get
from sqlalchemy.sql import func
from feedinlib import powerplants as plants, weather
from oemof.db import coastdat
from db import session, WindFeedin, SolarFeedin, Spatial, Region, conn

# load config parameters
FILE = "config.ini"
cfg = cp.ConfigParser()
cfg.read(FILE)

def asnum(x):
    try:
        return int(x)
    except ValueError:
        try:
            return float(x)
        except ValueError:
            return x

# retrieve all coastDat2 locations for Germany
spatial_ids = session.query(Spatial.gid, Spatial.geom).\
    filter(func.ST_Intersects(Spatial.geom, Region.geom)).\
           filter(Region.u_region_id == 'DE').all()
spatial_ids = [(gid, shape.to_shape(geom)) for gid, geom in spatial_ids]

# weather year
year = 2011
# create powerplants, specified by configuration file
enerconE126 = {k: asnum(v) for k,v in cfg.items('WindTurbine')}
E126_power_plant = plants.WindPowerPlant(**enerconE126)
yingli210 = {k: asnum(v) for k,v in cfg.items('PhotovoltaikModule')}
yingli_module = plants.Photovoltaic(**yingli210)

for gid, geom in spatial_ids:
    # create weather object
    wea = coastdat.get_weather(conn, geom, year)

    # create entry wind feedin
    wind = WindFeedin()
    wind.gid, wind.myyear, wind.feedin = gid, year,\
        E126_power_plant.feedin(weather=wea, installed_capacity=1).values
    session.add(wind)

    # create entry solar feedin
    solar = SolarFeedin()
    solar.gid, solar.myyear, solar.feedin = gid, year,\
        yingli_module.feedin(weather=wea, peak_power=1).values
    session.add(solar)
    session.flush()

session.commit()
