# -*- coding: utf-8 -*-
"""
Created on Wed Mar 14 14:30:54 2018

__author__ = "MarlonSchlemminger, s3pp"
"""

import pandas as pd
import db
from sqlalchemy import (MetaData, and_, or_, Column, Text, text, Integer, Float, ARRAY)
from sqlalchemy.ext.automap import automap_base
from operator import itemgetter
from functions import C_choice_of_windgenerator
import pkg_resources
import re
from feedinlib import powerplants as plants
from oemof.db import coastdat
from sqlalchemy.ext.declarative import declarative_base

points = db.Points
conn = db.conn
session = db.session
meta = MetaData()

config = 'config.ini'
correction_offshore = 0.83
correction_solar = 0.8
correction_onshore = 0.6
weather_year = 2011
weather_scenario_id = 1

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


def collect_bnetza_data():
    """
    Collects data of wind turbines available in the BNetzA Anlagenstammdaten. 
    
    Parameters
    ----------
    
    Returns
    -------
    plants : DataFrame of all wind generators in BNetzA
    """
    meta.reflect(bind=conn, schema='model_draft', 
                 only=['bnetza_eeg_anlagenstammdaten_wind_classification'])
    Base = automap_base(metadata=meta)
    Base.prepare()
    
    Bnetza = Base.classes.bnetza_eeg_anlagenstammdaten_wind_classification
    
    query = session.query(Bnetza.installierte_leistung, 
                          Bnetza.wea_manufacturer, 
                          Bnetza.wea_type, 
                          Bnetza.nabenhöhe, 
                          Bnetza.rotordurchmesser).filter(Bnetza.seelage == None)
    plants = [(installierte_leistung, 
               wea_manufacturer, 
               wea_type, 
               nabenhöhe, 
               rotordurchmesser)
    for installierte_leistung, wea_manufacturer, wea_type, nabenhöhe, rotordurchmesser
    in query.all()]
    plants.sort(key=itemgetter(0))
    columns = ['capacity', 'manufacturer', 'type', 'hub', 'rotor']
    plants = pd.DataFrame(plants, columns=columns)
    
    return plants
    

def collect_ego_turbines():
    """
    Collects data of wind turbines used in the eGo database. 
    
    Parameters
    ----------
    
    Returns
    -------
    generators : capacity of turbines used in the eGo database
    """
    meta.reflect(bind=conn, schema='model_draft', 
                 only=['ego_dp_supply_res_powerplant'])
    Base = automap_base(metadata=meta)
    Base.prepare()
    
    Dp = Base.classes.ego_dp_supply_res_powerplant
    
    query = session.query(Dp.electrical_capacity).\
                        filter(and_(Dp.generation_subtype == 'wind_onshore',\
                        Dp.electrical_capacity < 7600 ,\
                        Dp.start_up_date > '1998-01-01 00:00:00',\
                        Dp.start_up_date < '2018-01-01 00:00:00'))
    
    Gens = [(electrical_capacity) for electrical_capacity in query.all()]
    generators = []
    for i in range(0, len(Gens)):
        generators.append(float(Gens[i][0]))
    generators.sort()
    
    return generators
    
    
def collect_energymap_data():
    """
    Collects data of wind turbines available in the energy map table. 
    
    Parameters
    ----------
    
    Returns
    -------
    windgenerator : DataFrame of all wind generators in energy_map
    """
    meta.reflect(bind=conn,schema='model_draft',only=['ego_supply_renewable_bneta_full_attribute'])
    Base = automap_base(metadata=meta)
    Base.prepare()
    
    SQL_data = Base.classes.ego_supply_renewable_bneta_full_attribute

    plants = session.query(SQL_data).\
                        filter(and_(SQL_data.energietraeger == 'Wind Land',or_\
                        (SQL_data.stillgelegt!='Ja',\
                        SQL_data.stillgelegt == None))).all()
                        
    windgenerator = [[],[],[],[],[]] 
    
    # index 0 : power in kW
    # index 1 : manufacturer of the windgenerator
    # index 2 : type of the generator
    # index 3 : hub height in meter
    # index 4 : rotor diameter in meter
    
    # power of each generator, but it's sorted by size
    sorted_windgenerator = []
    
    for plant in plants:
        sorted_windgenerator.append(float(plant.installierte_leistung))
        
        windgenerator[0].append(float(plant.installierte_leistung))
        windgenerator[1].append(plant.windanlagenhersteller)
        windgenerator[2].append(plant.anlagentyp)
        windgenerator[3].append(plant.nabenhoehe)
        windgenerator[4].append(plant.rotordurchmesser)
    
    sorted_windgenerator.sort()
    windgenerator[1] = C_choice_of_windgenerator.upper_string(windgenerator[1])
    windgenerator[2] = C_choice_of_windgenerator.upper_string(windgenerator[2])
    windgenerator = pd.DataFrame(windgenerator).transpose()
    columns = ['capacity', 'manufacturer', 'type', 'h_hub', 'd_rotor']
    windgenerator.columns = columns
    return windgenerator


def df_to_renewable_feedin(df, weather_year, weather_scenario_id):
    """
    Transfers the calculated feedin timeseries into the database table 
    ego_renewable_feedin. 
    
    Parameters
    df : DataFrame with feedin timeseries
    weather_year : weather year of weather data
    weather_scenario_id : weather scenario id
    ----------
    
    Returns
    -------
    """
    print('Creating table ego_renewable_feedin..')    
    Base = declarative_base()
    
    class Ego_renewable_feedin(Base):
        __tablename__ = 'ego_renewable_feedin'
        __table_args__ = {'schema': 'model_draft'}
        
        weather_scenario_id = Column(Integer(), primary_key=True)
        w_id = Column(Integer(), primary_key=True)
        source = Column(Text(), primary_key=True)
        weather_year = Column(Integer(), primary_key=True)
        power_class = Column(Integer(), primary_key=True)
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
        power_class = k[2]
        feedin = df[k].values.tolist()
        info = Ego_renewable_feedin(w_id=w_id,
                                    weather_scenario_id=weather_scenario_id,
                                    source=source,
                                    weather_year=weather_year,
                                    power_class=power_class,
                                    feedin=feedin)
        mappings.append(info)
        
    session.bulk_save_objects(mappings)
    session.commit()
    
    print('Done!')


def get_power_classes(capacity):
    """
    Gets power classes.
    
    Parameters
    ----------
    capacity : list of capacities of all turbines used in the eGo database
    
    Returns
    -------
    power_classes : list with thresholds for power classes
    """
    max_power = max(capacity)
    power_classes = [max_power]
    
    x = 0  

    # Variable to guarantee to use the right parts in the loop
    new_class = True
    
    # Counter for number of windgenerators
    i = 0
    
    while(i < len(capacity)):
        if ((new_class == True) and (capacity[i] < power_classes[x])):
            power_classes.insert(x, round(capacity[i], -2))
            new_class = False
           
        elif(capacity[i] < power_classes[x+1]):
            t=power_classes.pop(x)
            power_classes.insert(x, round(capacity[i], -2))
    
        percent_of_plants_in_classes = C_choice_of_windgenerator.percent(capacity, power_classes)
        
        if ((percent_of_plants_in_classes[x] >= 0.1)):
            if((round(capacity[i], -2)) == (round(capacity[i+1], -2))):
                new_class = False
                i+=1
            else:
                x+=1
                new_class = True
                i+=1
        else:
            i+=1
        
    # change the last boarder, so that only the last boarder have a percentage 
    # under 0.1
    i = 0
    while(i < len(power_classes)):
        if((percent_of_plants_in_classes[len(power_classes)-1] <= 0.1)
            and
            (percent_of_plants_in_classes[len(power_classes)-2] <= 0.1)):
            power_classes.pop(len(power_classes)-2)
            percent_of_plants_in_classes =\
                  C_choice_of_windgenerator.percent(capacity, power_classes)
        else:
            break
        
        i+=1

    return power_classes

def get_plant_per_class(windgenerator, power_classes):
    """
    Calculates the most used plant per power class. If a turbine is not available
    in windlib, the second, third,.. most used turbine is taken until one is 
    available in windlib.
    
    Parameters
    ----------
    windgenerator : DataFrame of all wind generators in energy_map
    power_classes : list with threshold for power classes
    
    Returns
    -------
    selected_plants : DataFrame with most used turbines
    """
    
    windgenerator = windgenerator.sort_values(by='capacity')
    plants_per_classes = []
    lower = 0
    for upper in power_classes:
       plants_per_classes.append(
               windgenerator[(windgenerator['capacity'] >= lower) 
               & (windgenerator['capacity'] < upper)])
       lower = upper
      
    numbers = []
    for element in plants_per_classes:
        numbers.append(element.groupby(element.columns.tolist(), as_index=False).
                       size().reset_index().rename(columns={0:'count'}))
        
    selected_plants = []
    for element in numbers:
        selected_plants.append(element.sort_values(by='count', ascending=False).iloc[0])
        
    selected_plants = pd.DataFrame(selected_plants)
    selected_plants['power_class'] = power_classes
    
    not_in_windlib = turbine_in_windlib(selected_plants)
    position = 1
    
    while not_in_windlib.empty == False:
        for index, row in not_in_windlib.iterrows():
            numbers_index = power_classes.index(row['power_class'])
            power_class = selected_plants.ix[index]['power_class']
            selected_plants.ix[index] = numbers[numbers_index].\
                sort_values(by='count', ascending=False).iloc[position]
            selected_plants['power_class'][index] = power_class
            
        not_in_windlib = turbine_in_windlib(selected_plants)
        position += 1
        
    selected_plants['type'] = selected_plants['manufacturer']+' '+\
                                selected_plants['type']+' '+\
                                selected_plants['capacity'].map(int).map(str)
        
    return selected_plants

def power_class_to_db(power_classes, selected_plants):
    """
    Inserts the power classes used for the timeseries calculation into the 
    database table ego_power_class
    
    Parameters
    ----------
    
    Returns
    -------
    windgenerator : DataFrame of all wind generators in energy_map
    """
    
    print('Creating table power_class..')    
    Base = declarative_base()
    
    class Ego_power_class(Base):
        __tablename__ = 'ego_power_class'
        __table_args__ = {'schema': 'model_draft'}
        
        power_class_id = Column(Integer(), primary_key=True)
        lower_limit = Column(Float())
        upper_limit = Column(Float())
        wea = Column(Text())
        h_hub = Column(Float())
        d_rotor = Column(Float())


    conn.execute(text("DROP TABLE IF EXISTS model_draft.ego_power_class CASCADE"))
    
    Base.metadata.create_all(conn) 
    
    print('Importing power classes to database..')
    
    # prepare DataFrames
    session = db.session
    #Points = db.Base.classes.ego_weather_measurement_point
    mappings = []
    lower = 0
    power_class_id = 1
    # Insert Data to DB
    for upper in power_classes:
        wea = selected_plants['type'][selected_plants['power_class'] == upper].item()
        h_hub = selected_plants['h_hub'][selected_plants['power_class'] == upper].item()
        d_rotor = selected_plants['d_rotor'][selected_plants['power_class'] == upper].item()
        if power_class_id == len(power_classes):
            info = Ego_power_class(power_class_id=power_class_id,
                                    lower_limit=lower/1000,
                                    upper_limit=1000000000,
                                    wea=wea,
                                    h_hub=h_hub,
                                    d_rotor=d_rotor)
            mappings.append(info)
        else:
            info = Ego_power_class(power_class_id=power_class_id,
                                        lower_limit=lower/1000,
                                        upper_limit=upper/1000,
                                        wea=wea,
                                        h_hub=h_hub,
                                        d_rotor=d_rotor)
            mappings.append(info)
        
        lower = upper
        power_class_id += 1
        
    session.bulk_save_objects(mappings)
    session.commit()
    
    print('Done!')

def turbine_in_windlib(plants):
    """
    Checks if a given dataframe of turbines is available in the windlib cp_values
    file. Deletes all turbines from the dataframe which are available and returns
    the ones that are not.
    
    Parameters
    ----------
    plants : DataFrame of turbines
    
    Returns
    -------
    plants : modified dataframes without turbines available in windlib
    """

    resource_package = 'windpowerlib'
    resource_path = '/'.join(('data', 'cp_values.csv'))
    
    template = pkg_resources.resource_stream(resource_package, resource_path)
    cp_generators = pd.DataFrame.from_csv(template)
    for index, row in plants.iterrows():
        for name in cp_generators['rli_anlagen_id']:
            if row['type'] in name:
                split = re.split('(\d+)', name)
                if int(row[0]) == int(split[3]):
                    plants = plants.drop(row.name)
                    break
                
    return plants

def wind_dict(row):
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

    return {'d_rotor': float(row['d_rotor']),
            'h_hub': float(row['h_hub']),
            'wind_conv_type': row['type']}
                
              
def main():
    windgenerator = collect_energymap_data()
    capacity = collect_ego_turbines()
    power_classes = get_power_classes(capacity)
    selected_plants = get_plant_per_class(windgenerator, power_classes)
    power_class_to_db(power_classes, selected_plants)
    
    cfg = db.readcfg(config)
    temp = {}
    powerplants = {}
    powerplants['solar'] = plants.Photovoltaic(
        **{k: asnumber(v) for k, v in cfg.items('Photovoltaic')})
    
    powerplants['wind_offshore'] = plants.WindPowerPlant(
        **{k: asnumber(v) for k, v in cfg.items('WindTurbineOffshore')})
    
    print('Calculating feedins...')
    
    for coastdat_id, type_of_generation, geom in points:
        
        try:
            weather = coastdat.get_weather(conn, geom, weather_year)
        except IndexError:
            print('Geometry cannot be handled: %s, %s' % (geom.x, geom.y))
            continue
        
        if type_of_generation == 'wind_offshore':
            feedin = correction_offshore * powerplants[type_of_generation].\
                feedin(weather=weather, installed_capacity=1)
            power_class = 0
            temp[(coastdat_id, type_of_generation, power_class)] = feedin.values
                    
        elif type_of_generation == 'wind_onshore':
            power_class = 1
            for index, row in selected_plants.iterrows():
                plant = wind_dict(row)
                feedin = correction_onshore * plants.WindPowerPlant(**plant).\
                    feedin(weather=weather, installed_capacity=1)
                temp[(coastdat_id, type_of_generation, power_class)] = feedin.values
                power_class += 1
                    
        elif type_of_generation == 'solar':
            feedin = correction_solar * powerplants[type_of_generation].\
                feedin(weather=weather, peak_power=1)
            power_class = 0
            temp[(coastdat_id, type_of_generation, power_class)] = feedin.values
        else:
            continue
        
        #temp[(coastdat_id, type_of_generation)] = feedin.values

    df = pd.DataFrame(temp)
    df_to_renewable_feedin(df, weather_year, weather_scenario_id)
    print('Done!')


if __name__ == '__main__':
    main() 
                           
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
