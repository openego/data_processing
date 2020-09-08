# -*- coding: utf-8 -*-
"""
Created on Thu Jul 30 16:34:04 2020

@author: gthomsen
"""


import os
import pandas as pd


path=os.path.join('C:\\','Users','Gyde','Documents','HS_Flensburg','DemandRegio') #lokaler Ablageort


# 1. Input: dataset on population prognosis for a specific year on district-level (NUTS3)

pop_prognosis = pd.read_csv(os.path.join(path,'Bevölkerung2050.csv')) # source: DemandRedio

# 2. Input: Zensus2011 population data including the NUTS3-Code for the district
# (created via SQL)

zensus_district = pd.read_csv(os.path.join(path,'Zensus_2011_Nuts_01_to_03.csv')) #Example Dataset


# create two DataFrames with inhabited and empty zensus grids

zensus_inhabited = zensus_district[zensus_district.population!=-1].copy()
zensus_empty = zensus_district[zensus_district.population==-1].copy()

# Calculating the future population on zensus level
zensus_inhabited_prognosis=pd.DataFrame()
for nuts in zensus_inhabited.nuts.unique():
    subset = zensus_inhabited[zensus_inhabited.nuts==nuts].copy()
    subset['share_of_population']=subset['population']/subset['population'].sum()
    subset['population_prognosis']=(subset['share_of_population']*
                                  pop_prognosis.loc
                                  [pop_prognosis.nuts3==nuts,'value']
                                  .values[0])
    zensus_inhabited_prognosis=pd.concat([zensus_inhabited_prognosis,subset])

# Join DataFrames with inhabited and empty zensus grids   
zensus_prognosis = pd.concat([zensus_inhabited_prognosis,zensus_empty]) 
del zensus_prognosis['population']
del zensus_prognosis['share_of_population']
zensus_prognosis['population_prognosis'].fillna(-1,inplace=True)
  
 
    
# export data 












  