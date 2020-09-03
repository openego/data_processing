# -*- coding: utf-8 -*-
"""
Created on Thu Jul 30 16:34:04 2020

@author: gthomsen
"""


import os
import pandas as pd
import numpy as np

def set_nuts_id(df_zensus,df_zensus_nuts):
    """
    
    Returns the nuts code depending on the id of the zensus square
    

    Parameter
    ---------
    df_age_factor: DataFrame
                   DataFrame containing the zensus id and the corresponding 
                   nuts code of the district
    df_zensus:     Zensus
                   DataFrame including the ID of the zensus square 
                
    Returns
    ------
    age_factor:    nuts_code
                   String
                   Code of the district
    """
    gitter_id = df_zensus['Gitter_ID_100m']
    nuts_code = df_zensus_nuts['nuts'][(df_zensus_nuts["gitter_id_100m"]==gitter_id)].iloc[0]
    return nuts_code

path=os.path.join('C:\\','Users','Gyde','Documents','HS_Flensburg','DemandRegio') #lokaler Ablageort
"""

1. Teil: Bevölkerungsdaten

"""
# 1. Input: Datensatz mit Bevölkerungsfortschreibung für betrachtetes Jahr auf
# Kreisebene inkl. Nuts-Code

prognose_bevoelkerung = pd.read_csv(os.path.join(path,'Bevölkerung2050.csv')) #DemandRegio Daten

# 2. Input: Zensusdaten mit Bevölkerungszahlen 2011 und NUTS-Code um zugehörigen 
# Kreis zu kennzeichnen (erstellt über SQL-Abfrage)

zensus_kreis = pd.read_csv(os.path.join(path,'Zensus_2011_Flensburg.csv')) #Beispielhaft für Flensburg


# Zeilen ohne Einwohner ausschließen

zensus_bewohnt = zensus_kreis[zensus_kreis.einwohner!=-1].copy()

# Berechnen der zukünftigen Bevölkerung je Zensus-Raster
zensus_bewohnt_prognose=pd.DataFrame()
for nuts in zensus_bewohnt.nuts.unique():
    subset = zensus_bewohnt[zensus_bewohnt.nuts==nuts].copy()
    subset['anteil_einwohner']=subset['einwohner']/subset['einwohner'].sum()
    subset['einwohner_prognose']=(subset['anteil_einwohner']*
                                  prognose_bevoelkerung.loc
                                  [prognose_bevoelkerung.nuts3==nuts,'value']
                                  .values[0])
    zensus_bewohnt_prognose=pd.concat([zensus_bewohnt_prognose,subset])
    
"""

2. Teil: Haushaltsdaten

"""

# 3. Input: Zensusdaten mit Haushaltszahlen 2011 
haushalte = pd.read_csv(os.path.join(path,'Haushalte100m.csv'),engine='python')

# 4. Input: Datensatz mit 'Haushaltsfortschreibung für betrachtetes Jahr auf
# Kreisebene inkl. Nuts-Code von DemandRegio

prognose_haushalte = pd.read_csv(os.path.join(path,'Haushalte2050.csv'))
prognose_haushalte['total']=prognose_haushalte.sum(axis=1,numeric_only=True)

# alle Zensusraster filtern, die NUTS-Gebieten zugeordnet wurden
haushalte_kreis = haushalte[['Gitter_ID_100m',
                             'Anzahl']][(haushalte['Gitter_ID_100m'].
                             isin(zensus_kreis['gitter_id_100m']))
                            &(haushalte['Merkmal']=='INSGESAMT')].copy()
  
# Nuts-Code als Spalte zum DataFrame hinzufügen
haushalte_kreis['nuts']=haushalte_kreis.apply(set_nuts_id,
                                              df_zensus_nuts=zensus_kreis,
                                              axis=1)
zensus_haushalte_prognose=pd.DataFrame()
for nuts in haushalte_kreis.nuts.unique():
    subset = haushalte_kreis[haushalte_kreis.nuts==nuts].copy()
    subset['anteil_haushalte']=subset['Anzahl']/subset['Anzahl'].sum()
    total_prognose=prognose_haushalte.loc[prognose_haushalte.nuts3==nuts,'total'].values[0]
    subset['haushalte_prognose']=(subset['anteil_haushalte']*
                                  total_prognose)
    subset['haushalte_prognose_gerundet']=subset['haushalte_prognose'].astype(int)
    subset['rest']=subset['haushalte_prognose']-subset['haushalte_prognose_gerundet']
    # Rundungsverfahren
    while (total_prognose>subset['haushalte_prognose_gerundet'].sum())==True:
        index=np.random.choice(subset.index.values[subset.rest==max(subset.rest)])
        subset.at[index, 'haushalte_prognose_gerundet']+=1
        subset.at[index, 'rest']=0
    zensus_haushalte_prognose=pd.concat([zensus_haushalte_prognose,subset])
    
# hier ggf. Export in Datenbank










  