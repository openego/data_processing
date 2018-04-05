# -*- coding: utf-8 -*-
"""
This Programm includes all function of the programms "choice_of_windgenerator.py" 
and "time_series_wind_power.py".

__copyright__ = "Europa-Universität Flensburg - ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "mario kropshofer"
"""

from random import randint
import progressbar

class C_choice_of_windgenerator(object):
    """
    In this class are all functions for the programm 
    'choice_of_windgenerator.py'.
    """
    
    def upper_string(String):
        """
        This function is for changing the strings to strings with only upper 
        letters.
        
        For that it needs a list with strings.
        
        input parameter:
        ############################### String ###############################
        Sting is a list with n-values. Each value is a STRING.
        
        output parameter:
        ########################### output_strings ###########################
        This is also a list with the same size like the input parameter. Each
        value is a String but only with upper letters.
        """
        
        output_strings = []
        
        for word in String:
            if(word == None):
                output_strings.append("")
            else:
                output_strings.append(word.upper())
        
        return output_strings
        
    def percent(energy,classes):
        """
        This function calculate the percentage of each power class. For this it 
        needs two input parameters.
        
        input parameters:
        ############################### energy ###############################
        energy is a list with n-values. Each value is the energy in kW for the
        current plant.
        
        ############################## classes ###############################
        classes is a list with n-values. Each value is the boarder of each
        power class.
        
        output parameter:
        ############################## percent ###############################
        percent is a list with the same size of the parameter classes. The
        results of this function are the percentage for each power class.
        """
        
        length_energy = len(energy)
        length_classes = len(classes)
        
        percent=[]
        
        for number in classes:
            percent.append(0)
        
        i = 0
        
        while(i < length_energy):
            x = 0
            while(x < length_classes):
                if(energy[i] < classes[x]):
                    percent[x]+=1
                    break
                else:
                    x+=1
            i+=1
        
        
        
        length = len(percent)
        
        i = 0 
        
        while(i < length):
            percent[i]=round(percent[i]/length_energy,2)
            i+=1
        
        return percent
        
        
    def sorting(windgenerator,classes):
        """
        This function sorting the windgenerators in there power classes. For 
        this the function needs two input parameters.
        
        input paramerter:
        ########################### windgenerator ############################
        windgenerator is a list with five lists. 
        # list 0 : power in kW
        # list 1 : manufacturer of the windgenerator
        # list 2 : type of the generator
        # list 3 : hub height in meter
        # list 4 : rotor diameter in meter
        
        ############################## classes ###############################
        classes is a list with n-values. Each value is the boarder of each 
        power-class.
        
        output parameter:
        ######################### plants_in_classes ##########################
        plants_in_classes is a list with the same size like the parameter 
        classes. But each index is a list with datas of sorted plants.
        """

        length_classes = len(classes)

        plants_in_classes = []

        i = 0
        
        while(i < length_classes):
            plants_in_classes.append([])
            i+=1
        
        length_energy = len(windgenerator[0])
        
        i = 0
        
        while(i < length_energy):
            x = 0
            while(x < length_classes):
                if(windgenerator[0][i] < classes[x]):
                    index = len(plants_in_classes[x])
                    plants_in_classes[x].append([])
                    
                    plants_in_classes[x][index].append(windgenerator[0][i])
                    plants_in_classes[x][index].append(windgenerator[1][i])
                    plants_in_classes[x][index].append(windgenerator[2][i])
                    plants_in_classes[x][index].append(windgenerator[3][i])
                    plants_in_classes[x][index].append(windgenerator[4][i])
                    
                    break
                else:
                    x+=1
            i+=1
            
        return plants_in_classes
        
    def counting(plants_in_class):
        """
        This function counting the plants which are from the same type.
        
        import parameter:
        ########################## plants_in_class ###########################
        plants_in_class is a list with n-plants which are in the same power
        class. For each plant are save datas in the variable, for example:
        power, hub height or rotor diameter.
        
        output parameter:
        ############################### count ################################
        count is a list with n-lists. Each list represent one type of a
        generator. One of the lists have save all datas about the generator and
        how often it's count.
        """
        count = [[],[],[],[],[],[]]
        length = len(plants_in_class)
        i = 0
        while(i < length):
            check = True 
            if(i == 0):
                count[0].append(plants_in_class[i][0])
                count[1].append(plants_in_class[i][1])
                count[2].append(plants_in_class[i][2])
                count[3].append(plants_in_class[i][3])
                count[4].append(plants_in_class[i][4])
                count[5].append(1)
            else:
                length_count = len(count[0])
                
                y = 0
                while(y < length_count):
                    if(plants_in_class[i][2] == count[2][y]):
                        count[5][y]+=1
                        check = False
                    y+=1
                
                if(check == True):
                    count[0].append(plants_in_class[i][0])
                    count[1].append(plants_in_class[i][1])
                    count[2].append(plants_in_class[i][2])
                    count[3].append(plants_in_class[i][3])
                    count[4].append(plants_in_class[i][4])
                    count[5].append(1)
                    
                   
            i+=1                
        
        return count
        
    
    def selecting(numbers):
        """
        This function is for selecting the plants which are most used of each
        power class.
        
        input parameter:
        ############################## numbers ###############################
        numbers is a list with n-lists. Each list represent one type of a
        generator. One of the lists have save all datas about the generator and
        how often it's count.
        
        output parameter:
        ########################## selected_plants ###########################
        selected_plants is a list with n-values. This list represents the
        choosen generator and include all datas of this generator.
        """
        
        length_numbers = len(numbers[0])
        maximum = max(numbers[5])    
        select = []
            
        i = 0
        while(i < length_numbers):
            if(numbers[5][i] == maximum):
                select.append(i)
            i+=1
            
        length_select = len(select)
            
        size = round(100/length_select)
        random_number = randint(0,100)
            
        i = 0
        while(i < length_select):
            if(random_number <= size):
                index = select[i]
                break
            else:
                i+=1
                    
        selected_plant = []
        selected_plant.append(numbers[0][index])
        selected_plant.append(numbers[1][index])
        selected_plant.append(numbers[2][index])
        selected_plant.append(numbers[3][index])
        selected_plant.append(numbers[4][index])
            
        return selected_plant
                
            
class C_timeseries(object):
    """ This class includes all functions for the creation of timeseries."""

    def sorting(weather):
        """
        Each weather-point have 6 different parameter. This function sorts 
        the parameter so that every its easy to find the parameter.
        
        For that it needs only one input parameter.
        
        input parameter:
        ############################## weather ###############################
        weather is a list with n-values. Each value is a list and represent
        one parameter of one of the weather-points.
        index 0 : gid data
        index 1 : geom-data (geometry data)
        index 2 : tsarray (time series)
        index 3 : type_id (typ of parameter: 1=dhi 2=dirhi 3=temperatur 
                                             4=pressure 5=windspeed 6=z0)
        
        output parameter:
        ########################### sorted_weather ###########################
        sorted_weather is a list with n-values. The size of sorted_weather is
        the number of different weather-points. Each value is a list with 6
        time series for each parameter of the weather point.
        index n : list with values for each weatherpoint
        """
        # number of different weather-points
        number = len(weather)/6 # divident is 6 and is the number of different 
                                # parameter per weather-point        
        
        # list of already selected weather-points
        sorted_weather = []
        
        # geomety-list of already selected weather-points
        gid = []
        
        bar = progressbar.ProgressBar(redirect_stdout = True)
      
        i = 0
        while(i < number):
            bar.update(round((i/number)*100))
            x = 0
            new_point = False
            while(x < len(weather)):
                
                if((new_point == False)and(weather[x][0] in gid) == False):
                    gid.append(weather[x][0])
                    geom = weather[x][1]
                    sorted_weather.append([[],[],[],[],[],[]])
                    # index 0 : For dhi
                    # index 1 : For dirhi
                    # index 2 : temperature
                    # index 3 : pressure
                    # index 4 : windspeed
                    # index 5 : z0
                    sorted_weather[i][((weather[x][3])-1)] = weather[x][2]
                    new_point = True
               
                elif((new_point == True) and (weather[x][0] == gid[i])):
                    sorted_weather[i][((weather[x][3])-1)] = weather[x][2]
                    
                x+=1
                
            sorted_weather[i].append(geom)
            i+=1
                    
        return gid,sorted_weather
                        
    def distance(geom_wind,weather):
        """
        This function is finding the nearest weather-point to the wind plant.
        
        input parameter:
        ############################# geom_wind ##############################
        geom_wind is only one value. This value is the geographical point of 
        the current wind plant.
        
        ############################## weather ###############################
        weather is a list with n-values. The size of sorted_weather is
        the number of different weather-points. Each value is a list with 6
        time series for each parameter of the weather point.
        index n : list with values for each weatherpoint

        output parameter:
        ############################### index ################################
        index is only one value. This value represent the index of the nearest
        weather_point.
        """

        i = 0
        while(i < len(weather)):
            distance_value = geom_wind.distance(weather[i][6])
            
            if(i == 0):
                minimum_distance = distance_value
                index = i
            
            if(minimum_distance == 0):
                index = i
                break
            elif(distance_value < minimum_distance):
                minimum_distance = distance_value
                index = i
            
            i+=1
            
        return index
            
                        
    def classification_power(wind_plant,power_classes):
        """
        This function is finding the right power class for the current wind
        plant.

        input parameters:
        ############################# wind_plant #############################
        wind_plant have only one value. This value represent the power of the
        current plant. The unit of this plant must be kW.
        
        ########################### power_classes ############################
        power_classes is a list with n-values. Each value is a upper power 
        limit of an power class. The units must be also kW.
        
        output parameters:
        ############################### index ################################
        index have only one value. This value is the number (index) of the 
        selected power class.
        """
        
        i = 0
        while(i < len(power_classes)):
            if(wind_plant < power_classes[i]):
                index = i
                break
            elif(i == len(power_classes)-1):
                index = i
                break
            else:
                i+=1
        
        return index
         
    def district(current_time_series,geom_wind_plant,energy,grid_district):
        """
        This function classificate the current wind_plant to districts 
        and calculate the sum of time series for the selected district.
        
        import parameter:
        ######################### current_time_series ########################
        current_time_series is a list with n-values. Each value is the energy 
        in kWh which the current windplant per hour produced.
        
        ########################### geom_wind_plant ##########################
        geom_wind_plant have only one value. This value is the geometry-data
        of the current wind_plant.
        
        ############################### energy ###############################
        energy have only one value. This value is the power of the current 
        wind_plant. The unit of this value is kW.
        
        ############################ grid_district ###########################
        grid_district is a list with 2 lists. 
        list 0 : include all geometry-data of all districts
        list 1 : include the time series of each district.
        list 2 : sum of energy of all windplants in this district
        list 3 : full load hours per year of each district
        
        output parameter:
        ############################ grid_district ###########################
        grid_district is the same variable like the input parameter but 
        updated.
        """
        
        i = 0
        while(i < len(grid_district[0])):
            distance_value = geom_wind_plant.distance(grid_district[0][i])
            
            if(i == 0):
                minimum_distance = distance_value
                index = i
            elif(distance_value < minimum_distance):
                minimum_distance = distance_value
                index = i
            
            if(minimum_distance == 0):
                break
            
            
            i+=1
        
        if(len(grid_district[1][index]) == 0):
            grid_district[1][index] = current_time_series
        else:
            grid_district[1][index] =\
                    [sum(y) for y in zip(grid_district[1][index],\
                                              
                                              current_time_series)]
        grid_district[2][index] += energy
        
        grid_district[3][index] = \
                           sum(grid_district[1][index])/grid_district[2][index]
        
        return grid_district
            
        