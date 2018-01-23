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

def df_to_db(df):
    print('Importing feedin to database..')
    # prepare DataFrames
    Points = db.Base.classes.ego_weather_measurement_point
    session = db.session
    mappings = []
    
    # Insert Data to DB
    for k in df.columns:
        info = {'name': k[1], 'type_of_generation': k[2], 'scenario': k[0], 'feedin': df[k].values}
        mappings.append(info)
        
    session.bulk_update_mappings(Points, mappings)
    session.commit()
    
    print('Done!')

#Alter DB tables
