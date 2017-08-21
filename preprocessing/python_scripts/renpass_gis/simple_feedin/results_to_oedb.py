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

import pandas as pd
import psycopg2
from sqlalchemy import create_engine
import numpy as np
from db import conn, readcfg, dbconnect
import os

# Settings
#filename = '2017-08-07_simple_feedin_All_subids_weatherids_ego_weatherYear2011.csv'
filename = 'simple_feedin_test.csv'
conn = conn
# read configuration file
path = os.path.join(os.path.expanduser("~"), '.open_eGo', 'config.ini')
config = readcfg(path=path)

# establish DB connection
section = 'oedb'
conn = dbconnect(section=section, cfg=config)

# load data from csv
time_series = pd.read_csv(filename,skiprows=1)
scenario_name = pd.read_csv(filename,header=None,nrows=1).iloc[0,0]


# prepare DataFrame
columns = ['hour','coastdat_id','sub_id', 'generation_type', 'feedin', 'scenario']
index = np.arange(1,len(time_series)-1)
db_structure = pd.DataFrame(columns=columns, index=index)

time_series.iloc[2,2]

# Insert Data to DB by DataFrame
for k in time_series.columns:
    # fill empty DataFrame
    m = k.index('_')
    n = k.index('_c')
    l = k[:m]     # coastdat_id
    p = k[m+1:n]  # substation_id
    db_structure['coastdat_id'] = l
    db_structure['sub_id'] = p
    db_structure['hour'] = index
    db_structure['generation_type'] = time_series.iloc[0,0]
    db_structure['feedin'] = time_series[k].shift(-1)
    db_structure['scenario'] = scenario_name
    db_structure = db_structure.reset_index(drop=True)

    # write to csv
    if not os.path.isfile('result_feedin.csv'):
        db_structure.to_csv('result_feedin.csv',header ='columns')
    else: # else it exists so append without writing the header
        db_structure.to_csv('result_feedin.csv',mode = 'a',header=False)

    # write df to database
    #db_structure.to_sql('ego_simple_feedin_full', conn, schema='model_draft',
    #if_exists='append',index=False)

print('Done!')

#Alter DB tables
