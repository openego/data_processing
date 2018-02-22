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
__author__ = "s3pp, MarlonSchlemminger"

from feedinlib import powerplants as plants
from oemof.db import coastdat
import db
import pandas as pd
from sqlalchemy import (Column, Text, Integer, Float, ARRAY)
from sqlalchemy.ext.declarative import declarative_base

points = db.Points
conn = db.conn
scenario_name = 'Status Quo'
weather_year = 2011
weather_scenario_id = 1
filename = '2017-08-21_simple_feedin_ego-100-wj2011_all.csv'
config = 'config.ini'
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
        
def df_to_renewable_feedin(df, weather_year, weather_scenario_id):
    print('Creating table ego_renewable_feedin..')    
    Base = declarative_base()
    
    class Ego_renewable_feedin(Base):
        __tablename__ = 'ego_renewable_feedin'
        __table_args__ = {'schema': 'model_draft'}
        
        weather_scenario_id = Column(Integer(), primary_key=True)
        w_id = Column(Integer(), primary_key=True)
        source = Column(Text(), primary_key=True)
        weather_year = Column(Integer(), primary_key=True)
        feedin = Column(ARRAY(Float))

    try:
        Ego_renewable_feedin.__table__.drop(conn)
    except:
        pass
    
    Base.metadata.create_all(conn) 
    
    print('Importing feedin to database..')
    
    # prepare DataFrames
    session = db.session
    #Points = db.Base.classes.ego_weather_measurement_point
    mappings = []

    # Insert Data to DB
    for k in df.columns:
        weather_scenario_id = weather_scenario_id
        w_id = k[0]
        source = k[1]
        weather_year = weather_year
        feedin = df[k].values.tolist()
        info = Ego_renewable_feedin(w_id=w_id,
                                    weather_scenario_id=weather_scenario_id,
                                    source=source,
                                    weather_year=weather_year,
                                    feedin=feedin)
        mappings.append(info)
        
    session.bulk_save_objects(mappings)
    session.commit()
    
    print('Done!')

#This function produces the bug that 8761 instead of 8760 values will be
#inserted into the feedin column. The last value is always NaN. 
#Pypsa can handle this because it only takes 8760 values anyways, but be aware of this.

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
    
    global points
    
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
    for coastdat_id, type_of_generation, geom in points:
        count += 1
        print(count)
        try:
            weather = coastdat.get_weather(conn, geom, weather_year)
        except IndexError:
            print('Geometry cannot be handled: %s, %s' % (geom.x, geom.y))
            continue
        
        if type_of_generation == 'windoffshore':
            feedin = correction_offshore * powerplants[type_of_generation].\
                feedin(weather=weather, installed_capacity=1)
        elif type_of_generation == 'windonshore':
            feedin = powerplants[type_of_generation].\
                feedin(weather=weather, installed_capacity=1)
        elif type_of_generation == 'solar':
            feedin = correction_solar * powerplants[type_of_generation].\
                feedin(weather=weather, peak_power=1)
        else:
            continue
        
        temp[(coastdat_id, type_of_generation)] = feedin.values

    #print('Writing results to %s.' % filename)
    # write results to file
    df = pd.DataFrame(temp)
    df_to_renewable_feedin(df, weather_year, weather_scenario_id)
    print('Done!')


if __name__ == '__main__':
    main()
