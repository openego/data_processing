#!/bin/python
# -*- coding: utf-8 -*-
"""
Module to calculate solar, windonshore and windoffshore feedins. Exports the
data to a CSV-file.

Attributes
----------
points : list
    List of data tuples.
filename : str
    File path for results CSV-file.
config : str
    File path of configuration file.
weather_year: int
    Year of CoastDat2 data.
conn : sqlalchemy.engine.Engine
    Database containing CoastDat2 schema.

Notes
-----
    db.Points has the following form. Type can be either windonshore,
    windoffshore or solar.

        [(<name_of_location>, <type>, <shapely.geometry.point.Point>),
         (<name_of_location>, ...)]

TODO
----
    How to handle different timezones?
"""

from feedinlib import powerplants as plants
from oemof.db import coastdat
import db
import pandas as pd

points = db.Points
conn = db.conn
weather_year = 2011
filename = 'SimpleFeedin.csv'
config = 'config.ini'


def asnumber(x):
    """ Tries to convert a string to a numeric format

    Parameters
    ----------
    x : str

    Returs
    ------
    x : int or float or str
    """

    try:
        return int(x)
    except ValueError:
        try:
            return float(x)
        except ValueError:
            return x


def to_dictionary(cfg, section):
    """ Writes section data of a configuration file to a dictionary

    Parameters
    ----------
    cfg : configparser.ConfigParser
        Used for configuration file parser language.
    section : str
        Section in configuration file.

    Returns
    -------
    dict
        Dictionary containing section data.
    """

    return {k: asnumber(v) for k, v in cfg.items(section)}


def main():
    """
    """

    cfg = db.readcfg(config)
    temp = {}
    powerplants = {}

    # instatiate feedinlib models in dictionary
    powerplants['windonshore'] = plants.WindPowerPlant(
        **to_dictionary(cfg=cfg, section='WindTurbineOnshore'))

    powerplants['windoffshore'] = plants.WindPowerPlant(
        **to_dictionary(cfg=cfg, section='WindTurbineOffshore'))

    powerplants['solar'] = plants.Photovoltaic(
        **to_dictionary(cfg=cfg, section='Photovoltaic'))

    print('Calculating feedins...')
    # calculate feedins
    for name, type_of_generation, geom in points:

        weather = coastdat.get_weather(conn, geom, weather_year)

        if type_of_generation != 'solar':
            feedin = powerplants[type_of_generation].\
                feedin(weather=weather, installed_capacity=1)
        else:
            feedin = powerplants[type_of_generation].\
                feedin(weather=weather, peak_power=1)

        temp[(name, type_of_generation)] = feedin

    print('Writing results to %s.' % filename)
    # write results to file
    df = pd.DataFrame(temp)
    df.to_csv(filename, index=False)

    print('Done!')


if __name__ == '__main__':
    main()
