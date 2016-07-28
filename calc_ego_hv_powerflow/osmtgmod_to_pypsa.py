# -*- coding: utf-8 -*-
"""
Script for transferring data from osmTGmod results to PyPSA compatible tables
"""

import sqlalchemy
import pg8000
import pandas as pd
import time

print('\nStarting osmTGmod2pypsa script....\n')

# connection to source DB
print('Please provide connection parameters to SOURCE db:')

host1 = input('host (default 127.0.0.1): ') or '127.0.0.1'
port1 = input('port (default 5432): ') or '5432'
user1 = input('user (default postgres): ') or 'postgres'
database1 = input('database name: ')
password1 = input('password: ') 

con1 = sqlalchemy.create_engine('postgresql+pg8000://' + 
                                '%s:%s@%s:%s/%s' % (user1, password1, host1, port1, database1))
           
# connection to destination DB
print('\nPlease provide connection parameters to TARGET db:')

host2 = input('host: ')
port2 = input('port (default 5432): ') or '5432'
user2 = input('user: ')
database2 = input('database name: ')
password2 = input('password: ')

con2 = sqlalchemy.create_engine('postgresql+pg8000://' + 
                                '%s:%s@%s:%s/%s' % (user2, password2, host2, port2, database2))

result_id = input("\nPlease provide result_id: ")

print('\nImporting data...')

start_time = time.time()

# get relevant bus data                               
sql = '''SELECT 
  bus_i,
  base_kv,
  geom
  FROM calc_ego_osmtgmod.bus_data
  WHERE result_id = %s;''' % (result_id)
bus_data = pd.read_sql_query(sql,con1)

# get relevant branch data

sql = '''SELECT 
  branch_id,
  f_bus,
  t_bus,
  br_r,
  br_x,
  br_b,
  rate_a,
  branch_voltage,
  cables,
  frequency,
  geom,
  topo
  FROM calc_ego_osmtgmod.branch_data
  WHERE result_id = %s and link_type = 'line';''' % (result_id)
  
line_data = pd.read_sql_query(sql,con1)  
  
# get relevant transformer data
  
sql = '''SELECT 
  branch_id,
  f_bus,
  t_bus,
  br_x,
  rate_a,
  tap,
  shift,
  geom,
  topo
  FROM calc_ego_osmtgmod.branch_data
  WHERE result_id = %s and link_type = 'transformer';''' % (result_id)
  
transformer_data = pd.read_sql_query(sql,con1)    

# write to csv

#bus_data.to_csv(path_or_buf="bus_data.csv",index=False)
#line_data.to_csv(path_or_buf="line_data.csv",index=False)
#transformer_data.to_csv(path_or_buf="transformer_data.csv",index=False)


print("\nData imported after %s seconds." % int(time.time() - start_time))

yes_no = input('Continue data processing and upload? (y/n): ')

if yes_no == "y":
    print('\nAdjusting dataframes...')
    start_time = time.time()
    # rename of columns to fit pypsa requirements
    
    bus_data = bus_data.rename(index=str,columns={"bus_i":"bus_id","base_kv":"v_nom"})
    line_data = line_data.rename(index=str,columns={"branch_id":"line_id","f_bus":"bus0","t_bus":"bus1","br_r":"r","br_x":"x","br_b":"b","rate_a":"s_nom"})
    transformer_data = transformer_data.rename(index=str,columns={"branch_id":"trafo_id","f_bus":"bus0","t_bus":"bus1","br_x":"x","rate_a":"s_nom","tap":"tap_ratio","shift":"pashe_shift"})
    
    # create pandas as in target db
    bus_data_empty = pd.DataFrame(columns=['bus_id','v_nom','osm_name','current_type','v_mag_pu_min','v_mag_pu_max','geom'])
    line_data_empty = pd.DataFrame(columns=['line_id','bus0','bus1','x','r','g','b','s_nom','s_nom_extendable','s_nom_min','s_nom_max','capital_cost','length','cables','frequency','terrain_factor','geom','topo'])
    transformer_data_empty = pd.DataFrame(columns=['trafo_id','bus0','bus1','x','r','g','b','s_nom','s_nom_extendable','s_nom_min','s_nom_max','tap_ratio','pashe_shift','capital_cost','geom','topo'])
    
    # merging
    bus_data_new = bus_data_empty.append(bus_data)
    line_data_new = line_data_empty.append(line_data)
    transformer_data_new = transformer_data_empty.append(transformer_data)
    
    # column ordering 
    bus_data_new = bus_data_new[['bus_id','v_nom','osm_name','current_type','v_mag_pu_min','v_mag_pu_max','geom']]
    line_data_new = line_data_new[['line_id','bus0','bus1','x','r','g','b','s_nom','s_nom_extendable','s_nom_min','s_nom_max','capital_cost','length','cables','frequency','terrain_factor','geom','topo']]
    transformer_data_new = transformer_data_new[['trafo_id','bus0','bus1','x','r','g','b','s_nom','s_nom_extendable','s_nom_min','s_nom_max','tap_ratio','pashe_shift','capital_cost','geom','topo']]
    
    print('Dataframes adjusted!')
        
    # wipe target db
    print('\nWiping tables...')
    cur = con2.connect()
    trans = cur.begin()        
    cur.execute('TRUNCATE calc_ego_hv_powerflow.bus CASCADE;')      
    cur.execute('TRUNCATE calc_ego_hv_powerflow.line CASCADE;')
    cur.execute('TRUNCATE calc_ego_hv_powerflow.transformer CASCADE;')
    trans.commit()
    cur.close()
    
    print('Tables wiped!')
    
    #upload to new db 
    bus_data_new.to_sql('bus',con2,schema='calc_ego_hv_powerflow',if_exists='append',index=False)
    print('\nBus data uploaded')
    line_data_new.to_sql('line',con2,schema='calc_ego_hv_powerflow',if_exists='append',index=False)
    print('Line data uploaded')
    transformer_data_new.to_sql('transformer',con2,schema='calc_ego_hv_powerflow',if_exists='append',index=False)
    print('Transformer data uploaded')
    
    print('\nData has been transferred to target db after %s seconds!' % int(time.time() - start_time))
    
    # per unit to absolute values
    print('\nConverting r, x and b from per-unit to absolute values...')
    
    cur = con2.connect()
    trans = cur.begin()        
    cur.execute('UPDATE calc_ego_hv_powerflow.line SET r = r * ((SELECT v_nom FROM calc_ego_hv_powerflow.bus WHERE bus0 = bus_id)^2 / (100 * 10^6));')      
    cur.execute('UPDATE calc_ego_hv_powerflow.line SET x = x * ((SELECT v_nom FROM calc_ego_hv_powerflow.bus WHERE bus0 = bus_id)^2 / (100 * 10^6));')
    cur.execute('UPDATE calc_ego_hv_powerflow.line SET b = b * ((SELECT v_nom FROM calc_ego_hv_powerflow.bus WHERE bus0 = bus_id)^2 / (100 * 10^6));')
    cur.execute('UPDATE calc_ego_hv_powerflow.transformer SET x = x * ((SELECT max(v_nom) FROM calc_ego_hv_powerflow.bus WHERE bus_id = bus0 OR bus_id = bus1)^2 / (100 * 10^6));')
    trans.commit()
    cur.close()
    
    print('Values for r, x and b converted!')
    
    print ('\nAll data transferred and converted successfully!')
else:
    print('\nScript stopped')
