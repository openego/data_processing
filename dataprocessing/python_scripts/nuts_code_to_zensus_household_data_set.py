# -*- coding: utf-8 -*-
"""
Created on Mon Sep  7 12:19:28 2020

@author: Gyde
"""

import os
import pandas as pd


def set_nuts_id(df_zensus,df_zensus_nuts):
    """
    
    Returns the nuts code depending on the id of the zensus square
    

    Parameter
    ---------
    df_zensus_nuts: DataFrame
                   DataFrame containing the zensus id and the corresponding 
                   nuts code of the district
    df_zensus:     Zensus
                   DataFrame including the ID of the zensus square 
                
    Returns
    ------
    nuts_code:    nuts_code
                  String
                  Code of the district
    """
    grid_id = df_zensus['grid_id']
    nuts_code = df_zensus_nuts['nuts'][(df_zensus_nuts["grid_id"]==grid_id)].iloc[0]
    return nuts_code

path=os.path.join('C:\\','Users','Gyde','Documents','HS_Flensburg',
                  'DemandRegio') #lokaler Ablageort

zensus_district_population = pd.read_csv(os.path.join
                                         (path,'Zensus_2011_Nuts_01_to_03.csv')) #Example Dataset

# import original data-set from Zensus2011 as csv
# Available here: https://www.zensus2011.de/DE/Home/Aktuelles/DemografischeGrunddaten.html
#
households_zensus = pd.read_csv(os.path.join(path,'Haushalte100m.csv'),
                                engine='python') 


# rename the columns to english
households_zensus.rename(columns={'Gitter_ID_100m':'grid_id',
                          'Gitter_ID_100m_neu':'grid_id_new',
                          'Merkmal':'attribute',
                          'Auspraegung_Code':'domain_code',
                          'Auspraegung_Text':'domain_text',
                          'Anzahl':'number',
                          'Anzahl_q':'number_q'},inplace=True)


# Filter household data with all rasters that are in Zensus population dataset
# in order to assign the nuts-code
zensus_district_households = households_zensus[['grid_id',
                             'number','attribute']][(households_zensus['grid_id'].
                             isin(zensus_district_population['grid_id']))
                            &(households_zensus['attribute']=='INSGESAMT')].copy()
                                         

# add column to household dataset that includes the nuts_id for the district
zensus_district_households['nuts']=zensus_district_households.apply(set_nuts_id,
                                              df_zensus_nuts=
                                              zensus_district_population,
                                              axis=1)

# export dataset 
zensus_district_households.to_csv(os.path.join(path,'Haushalte100m_inkl_nuts.csv'),index=False)











