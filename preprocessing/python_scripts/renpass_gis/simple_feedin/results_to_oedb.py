"""
Write results of simple_feedin.py into the openEnergy Database.


links:

https://www.shanelynn.ie/select-pandas-dataframe-rows-and-columns-using-iloc-loc-and-ix/
http://www.datacarpentry.org/python-ecology-lesson/02-index-slice-subset/
ToDo:
    Insert capacity
    move to odeb
    update data_processing
"""

__copyright__ = "ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

import db
from sqlalchemy import (Column, Text, Integer, Float, ARRAY)
from sqlalchemy.ext.declarative import declarative_base

def df_to_renewable_feedin(df, weather_year):
    print('Creating table ego_renewable_feedin..')    
    Base = declarative_base()
    conn = db.conn
    
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
        w_id = k[1][:k[1].index('_')]
        source = k[2]
        weather_year = weather_year
        feedin = df[k].values.tolist()
        info = Ego_renewable_feedin(w_id=w_id,
                                    source=source,
                                    weather_year=weather_year,
                                    feedin=feedin)
        mappings.append(info)
        
    session.bulk_save_objects(mappings)
    #session.bulk_upgrade_mappings(Points, mappings)
    session.commit()
    
    print('Done!')

#Alter DB tables