# -*- coding: utf-8 -*-
"""
"""
from geoalchemy2 import Geometry, shape

from feedinlib import powerplants as plants, weather

from oemof.db import coastdat

from db import session, readcfg, Spatial, Region, conn
from sqlalchemy.sql import func

import pandas as pd


def asnumber(x):
    """
    """
    try:
        return int(x)
    except ValueError:

        try:
            return float(x)
        except ValueError:
            return x


def points():
    """
    """
    query = session.query(Region.u_region_id, Region.geom_point).\
        filter(func.length(Region.u_region_id) < 3)
    return [(name, shape.to_shape(geom),
             'solar') for name, geom in query.all()]


def to_dictionary(cfg, section):
    """
    """
    return {k: asnumber(v) for k,v in cfg.items(section)}



def main():

    results = {}
    powerplants = {}
    weather_year = 2011
    cfg = readcfg('config.ini')


    powerplants['windonshore'] = plants.WindPowerPlant(
        **to_dictionary(cfg=cfg, section='WindTurbineOnshore'))

    powerplants['windoffshore'] = plants.WindPowerPlant(
        **to_dictionary(cfg=cfg, section='WindTurbineOffshore'))

    powerplants['solar'] = plants.Photovoltaic(
        **to_dictionary(cfg=cfg, section='Photovoltaic'))

    for gid, geom, type_of_generation in points():
        weather = coastdat.get_weather(conn, geom, weather_year)
        if type_of_generation != 'solar':
            feedin = powerplants[type_of_generation].\
                feedin(weather=weather, installed_capacity=1)
        else:
            feedin = powerplants[type_of_generation].\
                feedin(weather=weather, peak_power=1)
        results[(gid, type_of_generation)] = feedin
