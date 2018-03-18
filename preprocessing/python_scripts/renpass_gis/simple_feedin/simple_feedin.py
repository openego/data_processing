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
from sqlalchemy import text
import re

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
        
def compatibility_windlib(turbines, default_onshore, default_offshore):
    
    for index, row in turbines.iterrows():
        if row['wea'].split(' ', 1)[0] == 'Adwen/Areva':
            if row['type_of_generation'] == 'wind_offshore':
                turbines.iloc[index, 4] = default_offshore
            elif row['type_of_generation'] == 'wind_onshore':
                turbines.iloc[index, 4] = default_onshore
        
        elif row['wea'].split(' ', 1)[0] == 'Enercon':
            turbines.iloc[index, 4] = turbines.iloc[index, 1].replace('-', ' ')
            turbines.iloc[index, 4] = turbines.iloc[index, 4].replace('/', ' ')
            turbines.iloc[index, 4] = turbines.iloc[index, 4].replace('50', '00')
        
        elif row['wea'].split(' ', 1)[0] == 'Eno':
            turbines.iloc[index, 4] = turbines.iloc[index, 1][4:9]
            turbines.iloc[index, 4] = turbines.iloc[index, 4][:3] + ' ' +\
                                        turbines.iloc[index, 4][3:]
        
        elif row['wea'].split(' ', 1)[0] == 'GE':
            if row['type_of_generation'] == 'wind_offshore':
                turbines.iloc[index, 4] = default_offshore
            elif row['type_of_generation'] == 'wind_onshore':
                turbines.iloc[index, 4] = default_onshore
            
        elif row['wea'].split(' ', 1)[0] == 'Nordex':
            turbines.iloc[index, 4] = turbines.iloc[index, 1].replace('AW', 'S')
            turbines.iloc[index, 4] = turbines.iloc[index, 4][:8] + ' ' +\
                                        turbines.iloc[index, 4][8:]
            turbines.iloc[index, 4] = turbines.iloc[index, 4].replace('/', ' ')
            
        elif row['wea'].split(' ', 1)[0] == 'Senvion/REpower':
            turbines.iloc[index, 4] = turbines.iloc[index, 1].replace('Senvion/REpower', 'REPOWER')
            turbines.iloc[index, 4] = turbines.iloc[index, 4].replace('/', ' ')
            split = re.split('(\d+)', turbines.iloc[index, 4])
            if split[0] == 'REPOWER MM':
                turbines.iloc[index, 4] = split[0]+' '+split[1]+split[2]+split[3]
            elif split[0] == 'REPOWER S':
                turbines.iloc[index, 4] = 'REPOWER '+str(float(split[3])/1000)+\
                                            ' M'+split[1]
        
        elif row['wea'].split(' ', 1)[0] == 'Siemens':
            split = re.split('(\d+)', turbines.iloc[index, 1])
            turbines.iloc[index, 4] = split[0]+' '+str(float(split[3])/1000)+\
                                        ' '+split[1]
        
        elif row['wea'].split(' ', 1)[0] == 'Vensys':
            split = re.split('(\d+)', turbines.iloc[index, 1])
            turbines.iloc[index, 4] = 'Vensys '+split[1]
            
        elif row['wea'].split(' ', 1)[0] == 'Vestas':
            split = re.split('(\d+)', turbines.iloc[index, 1])
            turbines.iloc[index, 4] = split[0]+' '+split[1]+' '+split[3]
    
    turbines['wea_windlib'] = turbines['wea_windlib'].str.upper()
        
    return turbines
        
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

    conn.execute(text("DROP TABLE IF EXISTS model_draft.ego_renewable_feedin CASCADE"))
    
#    try:
#        Ego_renewable_feedin.__table__.drop(conn)
#    except:
#        pass
    
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


def wind_dict(wea_type, type_of_generation, turbines):
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

    return {'d_rotor': turbines[(turbines['wea'] == wea_type) &
                                         (turbines['type_of_generation'] ==
                                         type_of_generation)].d_rotor.item(),
             'h_hub': turbines[(turbines['wea'] == wea_type) &\
                                 (turbines['type_of_generation'] ==\
                                 type_of_generation)].h_hub.item(),
             'wind_conv_type': turbines[(turbines['wea'] == wea_type) &\
                                (turbines['type_of_generation'] ==\
                                 type_of_generation)].wea_windlib.item()}

def main():
    """
    """
    
    global points
    
    cfg = db.readcfg(config)
    temp = {}
    powerplants = {}
    columns = ['type_of_generation', 'wea', 'd_rotor', 'h_hub']
    default_offshore = 'SIEMENS SWT 3.6 120'
    default_onshore = 'ENERCON E 70 2000'
    turbines = pd.DataFrame(db.Turbines, columns=columns)
    turbines['wea_windlib'] = ''
    # instatiate feedinlib models in dictionary

    powerplants['solar'] = plants.Photovoltaic(
        **to_dictionary(cfg=cfg, section='Photovoltaic'))

    print('Calculating feedins...')
    #toDo
    # calculate feedins applying correction factors
    turbines = compatibility_windlib(turbines, default_onshore, default_offshore)
    count = 0
    default = 0
    specific = 0
    for coastdat_id, type_of_generation, wea_type, geom in points:
        
        count += 1
        print(count)
        try:
            weather = coastdat.get_weather(conn, geom, weather_year)
        except IndexError:
            print('Geometry cannot be handled: %s, %s' % (geom.x, geom.y))
            continue
        
        if type_of_generation == 'wind_offshore':
            plant = wind_dict(wea_type, type_of_generation, turbines)
            try:
                feedin = correction_offshore * plants.WindPowerPlant(**plant).\
                    feedin(weather=weather, installed_capacity=1)
                specific += 1
            except:
                print(wea_type+' not found.')
                plant['wind_conv_type'] = default_offshore
                feedin = correction_offshore * plants.WindPowerPlant(**plant).\
                    feedin(weather=weather, installed_capacity=1)
                default += 1
                    
        elif type_of_generation == 'wind_onshore':
            plant = wind_dict(wea_type, type_of_generation, turbines)
            try:
                feedin = plants.WindPowerPlant(**plant).\
                    feedin(weather=weather, installed_capacity=1)
                specific += 1
            except:
                print(wea_type+' not found.')
                plant['wind_conv_type'] = default_onshore
                feedin = plants.WindPowerPlant(**plant).\
                    feedin(weather=weather, installed_capacity=1)
                default += 1
                    
        elif type_of_generation == 'solar':
            feedin = correction_solar * powerplants[type_of_generation].\
                feedin(weather=weather, peak_power=1)
        else:
            continue
        
        temp[(coastdat_id, type_of_generation)] = feedin.values

    #print('Writing results to %s.' % filename)
    # write results to file
    print('specific: ')
    print(specific)
    print('default: ')
    print(default)
    df = pd.DataFrame(temp)
    df_to_renewable_feedin(df, weather_year, weather_scenario_id)
    print('Done!')


if __name__ == '__main__':
    main()
