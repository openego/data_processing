"""

ToDO:
 * Greate one scaled time series
 * 
 
Database table: 
 * model_draft.ego_weather_measurement_point
 * model_draft.ego_simple_feedin_full


Change db.py and add ego_simple_feedin_full


""" 

__copyright__ = "ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolf_bunke"


from oemof.db import coastdat
import db
import pandas as pd

# get Classes and make settings
points = db.Points
conn = db.conn
scenario_name = 'eGo 100'
weather_year = 2011
filename = '2017-08-21_simple_feedin_ego-100-wj2011_all.csv'
config = 'config.ini'



import pandas as pd
import psycopg2
from sqlalchemy import create_engine
import numpy as np
from db import conn, readcfg, dbconnect
import os

# Settings
#filename = '2017-08-07_simple_feedin_All_subids_weatherids_ego_weatherYear2011.csv'
filename = 'simple_feedin_full.csv'
conn = conn
# read configuration file
path = os.path.join(os.path.expanduser("~"), '.open_eGo', 'config.ini')
config = readcfg(path=path)

# establish DB connection
section = 'oedb'
conn = dbconnect(section=section, cfg=config)
