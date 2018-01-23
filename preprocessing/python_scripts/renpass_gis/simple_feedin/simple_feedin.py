#!/bin/python
# -*- coding: utf-8 -*-
"""
Module to calculate solar, windonshore and windoffshore feedins based on
feedinlib. (https://github.com/oemof/feedinlib) Exports the data to a CSV-file.

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
correction_offshore : float
    Correction factor for windoffshore feedin.
correction_solar : float
    Correction factor for solar feedin.

Notes
-----
    db.Points has the following form. Type can be either windonshore,
    windoffshore or solar.

        [(<name_of_location>, <type>, <shapely.geometry.point.Point>),
         (<name_of_location>, ...)]

    Introduction of correction factors based on Wiese 2015, p.83
    http://www.reiner-lemoine-stiftung.de/pdf/dissertationen/Dissertation_Frauke_Wiese.pdf

TODO
----
    How to handle different timezones?
    Add scenario case
"""


__copyright__ = "ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "s3pp"

from feedinlib import powerplants as plants
from oemof.db import coastdat
import db
import pandas as pd
from results_to_oedb import df_to_db

points = db.Points
conn = db.conn
scenario_name = 'NEP 2035'
weather_year = 2011
filename = '2017-08-21_simple_feedin_ego-100-wj2011_all.csv'
config = r'C:\Users\marlo\Anaconda3\envs\renpass\Lib\site-packages\data_processing\preprocessing\python_scripts\renpass_gis\simple_feedin\config.ini'
correction_offshore = 0.83
correction_solar = 0.8


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
    #toDo
    # calculate feedins applying correction factors
    count = 0
    for name, type_of_generation, scenario, geom in points[0:50]:
        count += 1
        print(count)
        try:
            weather = coastdat.get_weather(conn, geom, weather_year)
        except IndexError:
            print('Geometry cannot be handled: %s, %s' % (geom.x, geom.y))
            continue
        
        if type_of_generation == 'windoffshore' and scenario == scenario_name:
            feedin = correction_offshore * powerplants[type_of_generation].\
                feedin(weather=weather, installed_capacity=1)
        elif type_of_generation == 'windonshore' and scenario == scenario_name:
            feedin = powerplants[type_of_generation].\
                feedin(weather=weather, installed_capacity=1)
        elif type_of_generation == 'solar' and scenario == scenario_name:
            feedin = correction_solar * powerplants[type_of_generation].\
                feedin(weather=weather, peak_power=1)
        
        temp[(scenario, name, type_of_generation)] = feedin

    print('Writing results to %s.' % filename)
    # write results to file
    df = pd.DataFrame(temp)
    #df_to_db(df)
    print('Done!')


if __name__ == '__main__':
    main()
