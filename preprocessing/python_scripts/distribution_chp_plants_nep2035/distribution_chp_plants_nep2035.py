# -*- coding: utf-8 -*-
"""
Created on Thu Nov 17 21:05:46 2016

 
This Programm will be distributed future build CHP (until 2035)

You need the following Information to start the calculation:

1. Table with datas of the status-quo plants.
2. Table with datas of the 4 tso's

First You will be asked if you want to save the result directly to the 
database or in a empty csv-file. Keep in mind if you want to save the result 
directly into the database the programm needs a long time (~15h). When you want
to save the result in a csv file, you will need a empty csv file with the name
chp_distribution.
After you save it in a csv file you can insert this datas with the sql-file 
("insert_csv_into_database.sql") to the database.

__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "mario kropshofer"

"""
##############################################################################
import getpass 

from sqlalchemy import (create_engine,MetaData)
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.automap import automap_base

print("How should the programm save the result?\n")
loop = True
while (loop == True):
    answer_result = input("Enter \"1\" for save the result directly to"+\
                    " database \n or \nenter \"2\" for saving the result"+
                    "in a csv-file. : \n")
    if((int(answer_result) == 1) or (int(answer_result) == 2)):
        loop == False
        break
    else:
        print('Your selection is wrong! Try again.')
    
    
    
print("Hello, \nBefore the programm can start, you must enter your"\
      "\nusername and password for entering the database:oedb \n")

username = input("Your username please :" )
#password=getpass.getpass("Insert your password: ")

password = input("Your password please :")

host = 'localhost'
database = 'oedb_local'
######################## Connection to the Database ##########################

section = 'Connection'

#Create Engine
engine_home = create_engine("postgresql+psycopg2://"+username+":"+\
                                        password+"@"+host+":5432/"+database)


session = sessionmaker(bind = engine_home)()
session_tso = sessionmaker(bind = engine_home)()

meta = MetaData()
meta.bind = engine_home

print("\nSuccessfully connected to the database\n")

##############################################################################
######################## KWK-Plants in Status_Quo ############################
##############################################################################

from sqlalchemy import or_,and_
#from status_quo_function import C_status_quo_functions

from shapely.wkb import loads
from geoalchemy2 import Geometry

print('Starting to collect Status-Quo Data and calculating.')

# Collection data from the database
meta.reflect(bind=engine_home, schema='supply'\
            ,only=['ego_renewable_powerplant'])
            
# Map to classes
Base = automap_base(metadata=meta)
Base.prepare()
          
SQL_Data = Base.classes.ego_renewable_powerplant

# Collection data from database by filtering plants 
# (gas or biomass and under 10MW) 
plants = session.query(SQL_Data).\
                        filter(and_(or_(SQL_Data.generation_type == 'biomass',\
                               SQL_Data.generation_type == 'gas'),\
                               SQL_Data.electrical_capacity <= 10000))\
                               .all()

plant_status_quo = [[],[]]

for plant in plants:
    plant_status_quo[0].append(float(plant.electrical_capacity))
    plant_status_quo[1].append(loads(bytes(plant.geom.data)))



# Sorting the collected plants in performance classes and count it
status_quo_performance_classes,\
status_quo_performance_classes_count =\
                                    C_status_quo_functions.sorting_BAFA(plants)
                                                
# Sorting the collected plants in ÜNB classes and count it
status_quo_TSO_performance,status_quo_TSO_count =\
                                    C_status_quo_functions.sorting_TSO(plants) 

#session.close()
                                                
# Overall performance of KWK-status_quo_plants
status_quo_overall_performance = sum(status_quo_performance_classes)

# Calculation of percent power play of status_quo_performance_classes (%)
status_quo_percent_power_play = C_status_quo_functions.\
                                share_power(status_quo_performance_classes)
                                
# Calculation of the average power each power_class
status_quo_average_power = C_status_quo_functions.\
                                average(status_quo_performance_classes,\
                                status_quo_performance_classes_count) 

# BAFA values are calculated with the datas of the following source:
# http://www.bafa.de/bafa/de/energie/kraft_waerme_kopplung/publikationen/
# statistik_kwkanlagen.pdf (14.11.2016)
# percent power play from BAFA-data (in %)
    # Index 0 : under 2kW
    # Index 1 : between 2kW and 10kW
    # Index 2 : between 10kW and 20kW
    # Index 3 : between 20kW and 50kW
    # Index 4 : between 50kW and 250kW
    # Index 5 : between 250kW and 500kW
    # Index 6 : between 500kW and 1.000kW
    # Index 7 : between 1.000kW and 2.000kW
    # Index 8 : between 2.000kW and 10.000kW
BAFA = [0.27,3.33,4.55,7.04,13.31,9.02,9.48,25.43,27.57]



# Addition datas from BAFA and Status_quo
add_BAFA_status_quo = C_status_quo_functions.\
                                add_2_lists(BAFA,status_quo_percent_power_play)

# Calculation average of the addition [in %]
percent_power_play_all = [a/2 for a in add_BAFA_status_quo]

print('Collection and calculation of Status-Quo Data is finished.')

##############################################################################
######################### Programm Start Parameter ###########################
##############################################################################

# whole energy from kwk-plants until 2035 (NEP2035)
# Source: https://www.netzentwicklungsplan.de/_NEP_file_transfer/
#                 NEP_2025_1_Entwurf_Kap_1_bis_3.pdf (14.11.2016)
kwk_energy_until_2035 = 5030000

print('\nShould the distrbution of KWK-Plants started with the plants'\
       ' from status quo or not?')
   

# Selection of the start conditions
loop = 'true'      
      
while(loop == 'true'):
    answer = input('enter "j" for yes and "n" for not :')
    if ((answer == 'j') or (answer == 'n')):
        loop == 'false'
        break
    else:
        print('Your selection is wrong! Try again.')
              

if (answer == 'j'):
    distribution_energy = kwk_energy_until_2035-status_quo_overall_performance
else:
    distribution_energy = kwk_energy_until_2035
    
##############################################################################
#################### Calculation of distribution energy ######################
##############################################################################

# percent power play of each TSO until 2035
# Index 0 : 50Hertz
# Index 1 : Amprion
# Index 2 : TransnetBW
# Index 3 : Tennet
percent_power_play_TSO = [0.3085,0.2811,0.1092,0.3012] 

# Calculate the energy for each TSO                 
distribution_energy_TSO = C_status_quo_functions.mul_num_list\
                           (distribution_energy,percent_power_play_TSO)   
                        
##############################################################################
##################### Collection of TSO_area data ############################
##############################################################################

from shapely.wkb import loads
from geoalchemy2 import Geometry
import geopandas
print('\nCollection of TSO-datas is started.')
                      
# Collection data from the database
"""meta.reflect(bind=engine_home, schema='tso', only=['deu3_tso'])
            
# Map to classes
Base = automap_base(metadata=meta)
Base.prepare()
          
SQL_Data = Base.classes.deu3_tso

# Collection data from database  
TSO = session_tso.query(SQL_Data.geog).all()
                              
# Change the geometrie values in a new parameter for calculation with them
tso_area = [(loads(bytes(geom[0].data))) for geom in TSO ]
"""
df = geopandas.read_file("/home/clara/Schreibtisch/DE_shape_TSO/DEU3_tso.shp")
tso_area=df['geometry']
# To close the connection to the database
#session_tso.close()
print('session of TSO is closed.')

print('Collection of TSO-datas is finished.')

##############################################################################
##################### Collection of loads_area data ##########################
##############################################################################

from sqlalchemy import desc

print('\nCollection of loads_area-datas is started.')

                      
# Collection data from the database
meta.reflect(bind=engine_home, schema='model_draft',\
                                                    only=['ego_demand_loadarea'])
            
# Map to classes
Base = automap_base(metadata=meta)
Base.prepare()
          
SQL_Data = Base.classes.ego_demand_loadarea

# Collection density data from database and sorted by density # filter(SQL_Data.id<1000).
density = session.query(SQL_Data).order_by(desc(SQL_Data.zensus_density),\
                                SQL_Data.id).all()
                            
# Collection geom data from database and transform in coordinate 4326
# and sorted by density 
geom = session.query(SQL_Data.geom_surfacepoint.ST_Transform(4326)).\
                           order_by(desc(SQL_Data.zensus_density),SQL_Data.id)\
                           .all()

# stored density values with id from database in a array with two lists.
# 0.list : id
# 1.list : density-value
loads_area = [[],[]]

for value in density:
    
    loads_area[0].append(value.id)
    #print(value.zensus_density)
    # Sort out the "None's"
    if(value.zensus_density == None):
        loads_area[1].append(0)
    else:
        loads_area[1].append(value.zensus_density)
    
# stored geometrie-data in two different ways   
# 2.list : original values
# 3.list : datas transformed for calculation
loads_area.append([])
loads_area.append([])

for value in geom:
    loads_area[2].append(value)
    loads_area[3].append(loads(bytes(value[0].data)))
    
print('Collection of loads_area-datas is finished.')

##############################################################################
############## Classification of the loads-areas in tso-areas ################
##############################################################################

from classification import C_classification

# According of the loads-area in tso and stored in loads_area with index 4
loads_area.append(C_classification.according_in_tso(tso_area,loads_area[3]))

# Calculation of density of each tso
# Index 0 : 50Hertz
# Index 1 : Amprion
# Index 2 : TransnetBW
# Index 3 : Tennet
TSO_density = C_classification.\
              classification_tso_density(loads_area[1],loads_area[4])
 
##############################################################################
##############  Calculation of reference energy of each tso ##################
##############################################################################

# Calculate the power per 1 person/km^2
basis_reference_tso = C_classification.\
          share_power_per_person_and_sqkm(distribution_energy_TSO,TSO_density) 

# Calculate the reference power for each load area and save it in Index 5
loads_area.append(C_classification.calc_reference_power(basis_reference_tso,\
                                                        loads_area[1],\
                                                        loads_area[4]))
                                                        
##############################################################################
############ Starting the distribution of KWK-plants in germany ##############
##############################################################################

from distribution_functions import C_distribution_function
import progressbar

print('Starting the distribution of KWK-plants in germany.')


# whole distribution energy as reference value
sum_distribution_energy = C_distribution_function.\
                                  distribution_energy(distribution_energy_TSO)

# Calculation the same like before for changeable variable
sum_distribution_energy_mom = C_distribution_function.\
                                  distribution_energy(distribution_energy_TSO)

# Calculation of the number of plants of each power_class     
number_power = C_distribution_function.number_power\
                               (percent_power_play_all,sum_distribution_energy,\
                               status_quo_average_power)

# percentage energy by fuels 
# Index 0 : gas
# Index 1 : hard coal
# Index 2 : brown coal
# Index 3 : mineral oil
# Index 4 : others
# The values are calculated by the data from the following source:
# https://www.netzentwicklungsplan.de/en/system/files/media/documents/
# 20140430_Entwurf_NEP2015_KW-Liste.pdf
percentage_fuels = [[76.56 , 0.56 , 1.06 , 5.35 , 16.46],\
                ['gas' , 'hard coal' , 'brown coal' , 'mineral oil', 'others']]


# serial number for check all datas of load_area                               
i = C_distribution_function.skip_none(loads_area[1])

# serial number for indexing the new plants
x = 0 

plant_list=[]

insert_bar = progressbar.ProgressBar(redirect_stdout = True)

#  distribution loop
while(sum_distribution_energy_mom >= status_quo_average_power[0]):
    
    
    # To break the distribution loop when no more load areas available
    if(i == len(loads_area[1])):
        break
    
    # Start energy for each load area
    energy_per_load_mom = 0
    
    while(energy_per_load_mom <= loads_area[5][i]):
        
        insert_bar.update(round(100-\
               (100*abs(sum_distribution_energy_mom/sum_distribution_energy))))
        
        # Select the energy of the right tso for calculation
        tso_energy = C_distribution_function.\
                   select_tso_energy(distribution_energy_TSO,loads_area[4][i])
        
        
        #Probability of construction of the different energy classes 
        # for plants
        probability_for_each_power_class = C_distribution_function.\
                                            probability_energy_class\
                                            (tso_energy,\
                                            status_quo_average_power,\
                                            percent_power_play_all,\
                                            number_power)
        
        # To choice a plant size                        
        plant_energy,number_power = C_distribution_function.plant_size_choice\
                                    (probability_for_each_power_class,\
                                    status_quo_average_power,\
                                    number_power)
        
        # if choice break, than break the loop for the load area
        if(plant_energy == 0):
            break        
        
        # To choose which typ of fuel this plant will be.
        fuel = C_distribution_function.\
                          fuel_choice(percentage_fuels[0],percentage_fuels[1])
        
        
        # Save datas of the current choosen plant in a list
        plant= [x,plant_energy,fuel,loads_area[4][i],loads_area[2][i][0]]       
        plant_list.append(plant)       

         # minimize the distribution energy 
        if(loads_area[4][i] == "50Hertz Transmission GmbH"):
            distribution_energy_TSO[0] += -plant_energy
        elif(loads_area[4][i] == "Amprion GmbH"):
            distribution_energy_TSO[1] += -plant_energy
        elif(loads_area[4][i] == "TransnetBW GmbH"):
            distribution_energy_TSO[2] += -plant_energy
        else: #(loads_area[4][i] == "TenneT TSO GmbH"):
            distribution_energy_TSO[3] += -plant_energy
            
        energy_per_load_mom += plant_energy
        
        # Calculation the rest of the distribution energy
        sum_distribution_energy_mom = C_distribution_function.\
                                  distribution_energy(distribution_energy_TSO)
    
        x+=1
    i+=1
 

##################### insert datas to the database or csv ####################  

# The plants will be insert in the database or in a csv-file

# Collection data from the database
"""meta.reflect(bind=engine_home, schema='supply'\
            ,only=['ego_renewable_power_plants_germany_kwk'])
            
# Map to classes
Base = automap_base(metadata=meta)
Base.prepare()
          
SQL_Data = Base.classes.ego_renewable_power_plants_germany_kwk"""

if(answer_result == 1):
    i=0
    
    insert_bar2 = progressbar.ProgressBar(redirect_stdout = True)
    
    while (i<len(plant_list)):

        insert_bar.update(round(i/len(plant_list)*100))
    
        # To insert the plant in the database
        session.add(SQL_Data(id=plant_list[i][0],\
                             start_up_date = "2035-01-01 00:00:00",\
                             electrical_capacity = plant_list[i][1],\
                             generation_type = "chp",\
                             generation_subtype = plant_list[i][2],\
                             # thermal_capacity = 0,\
                             # city = "",\
                             # postcode = "",\
                             # address = "",\
                             # lon = 0,\
                             # lat = 0,\
                             # gps_accuracy = "",\
                             # validation = "",\
                             # notification_reason ="",\
                             # eeg_id = "",\
                             # tso = 0,\
                             tso_eic = plant_list[i][3],\
                             # dso_id = "",\
                             # dso = "",\
                             voltage_level = "07 (NS)",\
                             # network_node = "",\
                             # power_plant_id = "",\
                             source = "Open_eGo CHP distribution",\
                             comment = "chp_NEP_2035_distribution",\
                             geom = plant_list[i][4]))
        session.commit()
        
        i+=1
elif(int(answer_result)==2):
    
    import csv

    with open('chp_distribution_sq.csv', 'w') as csvfile:
        fieldnames = ['id',\
                      'start_up_date' ,\
                      'electrical_capacity',\
                      'generation_type',
                      'generation_subtype',\
                      'thermal_capacity',\
                      'city',\
                      'postcode',\
                      'address',\
                      'lon',\
                      'lat',\
                      'gps_accuracy',\
                      'validation',\
                      'notification_reason',\
                      'eeg_id',\
                      'tso',\
                      'tso_eic',\
                      'dso_id',\
                      'dso',\
                      'voltage_level',\
                      'network_node',\
                      'power_plant_id',\
                      'source',\
                      'comment',\
                      'geom']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
    
        i = 0
        while(i < len(plant_list)):
            writer.writerow({'id': i, \
                             'start_up_date': '2035-01-01 00:00:00',\
                             'electrical_capacity' : plant_list[i][1],\
                             'generation_type' : 'chp',\
                             'generation_subtype' : plant_list[i][2],\
                             'tso_eic' : plant_list[i][3],\
                             'voltage_level' : '07 (NS)',\
                             'source' : 'Open_eGo CHP distribution',\
                             'comment' : 'chp_NEP_2035_distribution',\
                             'geom' : plant_list[i][4]})
            i+=1





print("Distribution is finished!")
"""
import csv
with open('/home/clara/GitHub/data_processing-fix-18/calc_geo_powerplants/distribution_chp_plants_nep2035/chp_distribution.csv', 'r') as f:
    reader = csv.reader(f)
    your_list = list(reader)
    
import pandas as pd   
df_full_extension=pd.DataFrame(your_list, columns= your_list[0])
df_full_extension=df_full_extension[df_full_extension.index>0]
full_cap_per_geom=df_full_extension.electrical_capacity.astype(float).groupby(df_full_extension.geom).sum()"""
"""# Collection data from the database
meta.reflect(bind=engine_home, schema='supply',only=['ego_dp_res_powerplant'])
            
# Map to classes
Base = automap_base(metadata=meta)
Base.prepare()
          
SQL_Data2 = Base.classes.ego_dp_res_powerplant

existing_extension = session.query(SQL_Data2)\
                .filter(SQL_Data2.comment == 'KWK_NEP_2035_distribution')

"""

print('\nImport the distrbution of KWK-Plants in model_draft'\
       ' as extension scenario?')
   

# Selection of the start conditions
loop = 'true'      
      
while(loop == 'true'):
    answer = input('enter "j" for yes and "n" for not :')
    if ((answer == 'j') or (answer == 'n')):
        loop == 'false'
        break
    else:
        print('Your selection is wrong! Try again.')
              

if (answer == 'j'):
    distribution_energy = kwk_energy_until_2035-status_quo_overall_performance
    
    import pandas as pd
    from geoalchemy2.shape import to_shape
    df=pd.DataFrame(plant_list, columns= ['id', 'p_nom', 'carrier', 'tso', 'geom'])

    for i in df.index:
       df['geom'][i]=to_shape(df['geom'][i])   