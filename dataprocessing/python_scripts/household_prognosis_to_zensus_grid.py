# -*- coding: utf-8 -*-
"""
Created on Mon Sep  7 13:09:54 2020

@author: Gyde
"""

import pandas as pd
import os
import numpy as np

path=os.path.join('C:\\','Users','Gyde','Documents','HS_Flensburg','DemandRegio') #lokaler Ablageort


# Input: Zensus household dataset including the NUTS3-code 
zensus_district_households = pd.read_csv(os.path.join
                                         (path,'Haushalte100m_inkl_nuts.csv'),
                                         engine='python')

# Input: dataset on household prognosis for a specific year on district-level (NUTS3)

prognosis_households = pd.read_csv(os.path.join(path,'Haushalte2050.csv')) # source: DemandRedio
# sum up to total number of households
prognosis_households['total']=prognosis_households.sum(axis=1,numeric_only=True)

# Calculating the future households on zensus level
zensus_households_prognosis=pd.DataFrame()
for nuts in zensus_district_households.nuts.unique():
    subset = zensus_district_households[zensus_district_households.nuts==nuts].copy()
    subset['share_of_households']=subset['number']/subset['number'].sum()
    total_prognosis=prognosis_households.loc[prognosis_households.nuts3==nuts,
                                             'total'].values[0]
    subset['household_prognosis']=(subset['share_of_households']*
                                  total_prognosis)
    subset['household_prognosis_rounded']=subset['household_prognosis'].astype(int)
    subset['rest']=subset['household_prognosis']-subset['household_prognosis_rounded']
    # rounding process
    while (total_prognosis>subset['household_prognosis_rounded'].sum())==True:
        index=np.random.choice(subset.index.values[subset.rest==max(subset.rest)])
        subset.at[index, 'household_prognosis_rounded']+=1
        subset.at[index, 'rest']=0
    zensus_households_prognosis=pd.concat([zensus_households_prognosis,subset])
    
zensus_households_prognosis = zensus_households_prognosis[['grid_id',
                                                          'attribute',
                                                          'nuts',
                                                          'household_prognosis'
                                                          '_rounded']]

# Export dataset

