#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Apr 23 11:02:32 2019

@author: clara
"""
import getpass
from sqlalchemy import (create_engine,MetaData)
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.automap import automap_base
import csv
import pandas as pd   
from geoalchemy2.shape import to_shape
from geopandas import GeoSeries
from shapely.wkb import loads as load_wkb
from egoio.db_tables import  grid
from egoio.tools import db

def get_bus_id_from_mv_grid(subst_ids):
    """
        Queries the MV grid ID for a given eTraGo bus
        Parameters
        ----------
        bus_id : Pandas Dataframe
            eTraGo bus ID
        Returns
        -------
        subst_id : Pandas Series
            MV grid (ding0) and otg (eTraGo) ID
    """
    conn = db.connection(section='oedb')
    Session = sessionmaker(bind=conn)
    session = Session()
    
    bus_id = pd.DataFrame(index = subst_ids)
    

    ormclass_hvmv_subst = grid.__getattribute__(
                'EgoDpHvmvSubstation'
            )
    query = session.query(
                ormclass_hvmv_subst
            ).filter(
                ormclass_hvmv_subst.subst_id.in_(bus_id.index.values),
                ormclass_hvmv_subst.version == 'v0.4.5'
            )

    bus_id = pd.read_sql(
            query.statement, 
            query.session.bind,
            index_col = 'subst_id')['otg_id']      
    
    return bus_id


print("Hello, \nBefore the programm can start, you must enter your"\
      "\nusername and password for entering the database:oedb \n")

username = input("Your username please :" )
password= input("Your password please :")

host = 'oe2.iws.cs.ovgu.de'
database = 'oedb'
######################## Connection to the Database ##########################

section = 'Connection'

#Create Engine
engine_home = create_engine("postgresql+psycopg2://"+username+":"+\
                                        password+"@"+host+":5432/"+database)


session = sessionmaker(bind = engine_home)()

meta = MetaData()
meta.bind = engine_home

print("\nSuccessfully connected to the database\n")

##################### Collect CHP Distrivution from csv #######################
path_to_chp_distribution = '/home/clara/GitHub/data_processing-fix-18/calc_geo_powerplants/distribution_chp_plants_nep2035/chp_distribution_5GW.csv'

with open(path_to_chp_distribution, 'r') as f:
    reader = csv.reader(f, delimiter=',')
    your_list = list(reader)
    
df=pd.DataFrame(your_list, columns= your_list[0])
df=df[df.index>0]
cap_per_geom=pd.DataFrame(index=range(0, len(df.geom.unique())), 
                          columns= ['geom', 'electrical_capacity', 'geom_new'])
cap_per_geom.electrical_capacity=df.electrical_capacity.astype(float
                  ).groupby(df.geom).sum().values
                                                                              
cap_per_geom.geom=df.electrical_capacity.astype(float).groupby(
        df.geom).sum().index                                                                 

for i in cap_per_geom.index:
    cap_per_geom['geom_new'][i]=load_wkb(cap_per_geom['geom'][i], hex=True)
    

######################## Collect MV Grid Districts ##########################
meta.reflect(bind=engine_home, schema='grid', only=['ego_dp_mv_griddistrict'])
            
# Map to classes
Base = automap_base(metadata=meta)
Base.prepare()
          
SQL_Data = Base.classes.ego_dp_mv_griddistrict

# Collection data from database  
mv_griddistrict = session.query(
        SQL_Data.subst_id, SQL_Data.geom.ST_Transform(4326)
        ).filter(SQL_Data.version=='v0.4.5').all()
df_mv_gd=pd.DataFrame(mv_griddistrict, columns=['subst_id', 'geom'])

for i in df_mv_gd.index: 
    df_mv_gd.geom[i]=to_shape(df_mv_gd.geom[i])
    
cap_per_mv = pd.DataFrame(
        index=df_mv_gd.index, 
        columns=['subst_id', 'capacity', 'hv_bus_id'])

cap_per_mv['subst_id']= df_mv_gd['subst_id']
cap_per_mv['hv_bus_id']=get_bus_id_from_mv_grid(
        df_mv_gd['subst_id']).values.astype(str)

for i in cap_per_mv.index:
    cap_per_mv['capacity'][i]=cap_per_geom.electrical_capacity[
            GeoSeries(cap_per_geom.geom_new).intersects(df_mv_gd.geom[i])].sum()
    
    
######################## Create extension-scenario ##########################
cap_per_mv=pd.read_csv('/home/clara/Dokumente/open_ego/KWK extension/fertige_verteilung_5gw.csv')
df_ext = pd.DataFrame(index=cap_per_mv.index, columns = ['scn_name',
                                                         'generator_id',
                                                         'bus', 
                                                         'dispatch',
                                                         'control',
                                                         'p_nom',
                                                         'p_nom_extendable',
                                                         'p_nom_min',
                                                         'p_nom_max',
                                                         'p_min_pu_fixed',
                                                         'p_max_pu_fixed',
                                                         'sign', 'source',
                                                         'marginal_cost',
                                                         'capital_cost',
                                                         'efficiency'])


df_ext['scn_name'] = 'extension_chp'
df_ext['control']='PQ'
df_ext['dispatch']='flexible'
df_ext['p_nom_extendable']=False
df_ext['p_nom_min']=0
#df_ext['p_nom_max']=
df_ext['p_min_pu_fixed']=0
df_ext['p_max_pu_fixed']=1
df_ext['sign']=1
df_ext['source']=1
df_ext['marginal_cost']=41.9344
#df_ext['capital_cost']=0
#df_ext['efficiency']=1
df_ext['bus']=cap_per_mv['hv_bus_id']
df_ext['p_nom']=cap_per_mv['capacity']/1000
df_ext['generator_id']=990000+df_ext.index
df_ext.index=df_ext['generator_id']
df_ext=df_ext.drop('generator_id', axis=1)
username='clara'
password='3,1415'
host='localhost'
database='local'
#Create Engine
engine_home = create_engine("postgresql+psycopg2://"+username+":"+\
                                        password+"@"+host+":5432/"+database)


session = sessionmaker(bind = engine_home)()

meta = MetaData()
meta.bind = engine_home

print("\nSuccessfully connected to the database\n")

df_ext.to_sql('ego_grid_pf_hv_extension_generator', engine_home, schema='model_draft', if_exists= 'append')