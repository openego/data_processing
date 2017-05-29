# -*- coding: utf-8 -*-"""Created on Sat Nov 19 12:56:28 2016This file include all function of the chapter Starting the distribution of KWK-plants in germany. __copyright__ = "Europa-Universität Flensburg - ZNES"__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"__author__ = "mario kropshofer""""import randomfrom decimal import Decimalclass C_distribution_function(object):            def distribution_energy(tso_energy):                """        This function calculate the sum of energy of a list.        So it need only one input parameter.                Input parameter:                    ############################## tso_energy ############################        tso_energy is a list with 4 values. Each value include the         distribution energy of each tso.                 Index 0 : distribution engergy of the tso: 50Hertz         Index 1 : distribution engergy of the tso: Amprion        Index 2 : distribution engergy of the tso: TransnetBW         Index 3 : distribution engergy of the tso: TenneT                 Output parameter:                    ######################## sum_distribution_energy #####################        sum_distribution_energy is only value. This value is the sum of         distribution energy. The unit of them is kW.        """                sum_distribution_energy = sum(tso_energy)                        return sum_distribution_energy                    def number_power(percent_power_play,sum_energy,average_power):                """        This function calculate the number of plants for each power class.        For that it need 3 input parameters.                input parameter:                ######################## percent_power_play ##########################        percent_power_play is a list with 9 values. Each value is the         performance ratio in percent of each power class.The unit of this         values are Percent like [100%].                Index 0 : percentage energy of the sector: under 2kW        Index 1 : percentage energy of sector: between 2kW and 10kW        Index 2 : percentage energy of sector: between 10kW and 20kW        Index 3 : percentage energy of sector: between 20kW and 50kW        Index 4 : percentage energy of sector: between 50kW and 250kW        Index 5 : percentage energy of sector: between 250kW and 500kW        Index 6 : percentage energy of sector: between 500kW and 1.000kW        Index 7 : percentage energy of sector: between 1.000kW and 2.000kW        Index 8 : percentage energy of sector: between 2.000kW and 10.000kW                ########################### sum_energy ###############################        sum_energy is only one number. This value is the whole energy that         should be distributed. The unit of this value is kW.                ########################## average_power #############################        average_power is a list with 9 values. Each value is the average power         of a sector. The unit of the results are kW.            Index 0 : average of the sector: under 2kW        Index 1 : average of the sector: between 2kW and 10kW        Index 2 : average of the sector: between 10kW and 20kW        Index 3 : average of the sector: between 20kW and 50kW        Index 4 : average of the sector: between 50kW and 250kW        Index 5 : average of the sector: between 250kW and 500kW        Index 6 : average of the sector: between 500kW and 1.000kW        Index 7 : average of the sector: between 1.000kW and 2.000kW        Index 8 : average of in the sector: between 2.000kW and 10.000kW                The number of plants for each energy class will be calculated with the        multiplication between the whole energy and the percentage energy and        with the division of the results of the multiplication and average        power of each energy class.                Output Parameter:                ########################## number_power ##############################        number_power is a list with also 9 values. Each value is a number of         how many plants can build from a energy class.                Index 0 : number of plants to install in the sector:                                           under 2kW        Index 1 : number of plants to install in the sector:                                     between 2kW and 10kW        Index 2 : number of plants to install in the sector:                                     between 10kW and 20kW        Index 3 : number of plants to install in the sector:                                     between 20kW and 50kW        Index 4 : number of plants to install in the sector:                                     between 50kW and 250kW        Index 5 : number of plants to install in the sector:                                     between 250kW and 500kW        Index 6 : number of plants to install in the sector:                                     between 500kW and 1.000kW        Index 7 : number of plants to install in the sector:                                     between 1.000kW and 2.000kW        Index 8 : number of plants to install in in the sector:                                     between 2.000kW and 10.000kW        """                number_power=[]        i = 0                while(i<len(percent_power_play)):                        energy_per_power_class = sum_energy*(percent_power_play[i]/100)                        number_power.append(round(energy_per_power_class/average_power[i]))            i+=1                return number_power                                    def skip_none(density):                """        This function is needed to skip the collected density values which         have the value (None or "0"). Because the ordering of the collection        sorted the values according to the size, but a Value "None" is not a        number an the would be sorded before of the maximum Value.         This function need only one input parameter.                Input parameter:                ############################ density #################################        Density is a list with n-values. The number of values is depend of the        number of collected load areas. Each of the value is from typ NUMERIC.        The unit is: person/1ha.                The result of this function is the index of the first value, which         havn't the value None or zero.                Output parameter:                ################################ i ###################################        i is the Index of the first value, which havn't the value None or zero.                """                i=0 # serial number of maximum value                while(i < len(density)):            if((density[i] == 0) or (density[i] == None)):                i+=1            else:                break                    return i                            def select_tso_energy(energy_tso_mom,TSO):                """        This function is for choosing the right tso of the current load area                For that it needs 2 input parameters.                Input parameter:                ######################### energy_tso_mom #############################        energy_tso_mom is a list with 4 values. Each value represent the        current energy of a tso.                 Index 0 : Current engergy of the tso: 50Hertz         Index 1 : Current engergy of the tso: Amprion        Index 2 : Current engergy of the tso: TransnetBW         Index 3 : Current engergy of the tso: TenneT                 ################################ TSO #################################        TSO is only one values. The value is a STRING and it's represent the         membership of the current load area to one of the tso.                For the result the TSO-Value will be compared with the name of the         tso's of germany.        If it's find a match, it will be set the result with the current        energy of the choosen tso.                ############################ tso_energy ##############################        tso_energy is only one value. This value represent the current energy        of the choosen tso.        """                if(TSO == "50Hertz Transmission GmbH"):            tso_energy=energy_tso_mom[0]        elif(TSO == "Amprion GmbH"):            tso_energy=energy_tso_mom[1]        elif(TSO == "TransnetBW GmbH"):            tso_energy=energy_tso_mom[2]        else: #(TSO == "TenneT TSO GmbH"):            tso_energy=energy_tso_mom[3]                    return tso_energy                            def probability_energy_class(tso_energy,average_energy,\                                                    percentages,number_power):                """        This function calculate the probability of each energy class.        This Calculation need 4 input values.                Input parameters:                ############################ tso_energy ##############################        tso_energy is only one value. This value represent the current energy        of the choosen tso.                ########################## average_energy #############################        average_power is a list with 9 values. Each value is the average power         of a sector. The unit of the results are kW.            Index 0 : average of the sector: under 2kW        Index 1 : average of the sector: between 2kW and 10kW        Index 2 : average of the sector: between 10kW and 20kW        Index 3 : average of the sector: between 20kW and 50kW        Index 4 : average of the sector: between 50kW and 250kW        Index 5 : average of the sector: between 250kW and 500kW        Index 6 : average of the sector: between 500kW and 1.000kW        Index 7 : average of the sector: between 1.000kW and 2.000kW        Index 8 : average of in the sector: between 2.000kW and 10.000kW                ########################## percentages ###############################        percentages is a list with 9 values. Each value is the         performance ratio in percent of each power class.The unit of this         values are Percent like [100%].                Index 0 : percentage energy of the sector: under 2kW        Index 1 : percentage energy of sector: between 2kW and 10kW        Index 2 : percentage energy of sector: between 10kW and 20kW        Index 3 : percentage energy of sector: between 20kW and 50kW        Index 4 : percentage energy of sector: between 50kW and 250kW        Index 5 : percentage energy of sector: between 250kW and 500kW        Index 6 : percentage energy of sector: between 500kW and 1.000kW        Index 7 : percentage energy of sector: between 1.000kW and 2.000kW        Index 8 : percentage energy of sector: between 2.000kW and 10.000kW                ########################## number_power ##############################        number_power is a list with also 9 values. Each value is a number of         how many plants can build from a energy class.                Index 0 : number of plants to install in the sector:                                           under 2kW        Index 1 : number of plants to install in the sector:                                     between 2kW and 10kW        Index 2 : number of plants to install in the sector:                                     between 10kW and 20kW        Index 3 : number of plants to install in the sector:                                     between 20kW and 50kW        Index 4 : number of plants to install in the sector:                                     between 50kW and 250kW        Index 5 : number of plants to install in the sector:                                     between 250kW and 500kW        Index 6 : number of plants to install in the sector:                                     between 500kW and 1.000kW        Index 7 : number of plants to install in the sector:                                     between 1.000kW and 2.000kW        Index 8 : number of plants to install in in the sector:                                     between 2.000kW and 10.000kW                                            First will be checked the number of power plants of the current         energy class and if the tso_energy is bigger than the smallest average.        After that the interim result will be set to the percentage of the         energy class or to zero when all plans for the current energy class         allready build or the tso energy is bigger than the smallest average.        For the probality that no plant will build the interim result will be        multiplicated with for example 0.95. So that we have 5 percent         probality for build no power plant.This will be calculated for each         energy class.                After setting all energy classes, it will be calculate the probabilty        of each energy class for the current moment.                After calculation of probility of each energy class, this probilities        are saved like this in a ne list:                Index 0 = 0        Index 1 = probility [0] + value of index 0        Index 2 = probility [1] + value of index 1        Index 3 = probility [2] + value of index 2        Index 4 = probility [3] + value of index 3        Index 5 = probility [4] + value of index 4        Index 6 = probility [5] + value of index 5        Index 7 = probility [6] + value of index 6        Index 8 = probility [7] + value of index 7        Index 8 = probility [8] + value of index 8        Index 10 = 100                        Output parameter:                #################### probability_for_each_power_class ################        probability_for_each_power_class is a list with 11 values. The first        Value is zero and the last value is 100. Each other value represent        the probality of each ernergy class for this moment.                Index 0 : 0        Index 1 : probability energy of the sector: under 2kW +Index 0        Index 2 : percentage energy of sector: between 2kW and 10kW +Index 1        Index 3 : percentage energy of sector: between 10kW and 20kW +Index 2        Index 4 : percentage energy of sector: between 20kW and 50kW +Index 3        Index 5 : percentage energy of sector: between 50kW and 250kW +Index 4        Index 6 : percentage energy of sector: between 250kW and 500kW +Index 5        Index 7 : percentage energy of sector: between 500kW and 1.000kW +Index 6        Index 8 : percentage energy of sector: between 1.000kW and 2.000kW +Index 7        Index 9 : percentage energy of sector: between 2.000kW and 10.000kW +Index 8        Index 10 : 100                  """                        probability_for_each_power_class = [0]                i = 0                        while(i<len(percentages)):                        if(number_power[i] != 0):                if(tso_energy >= average_energy[i]):                    probability_for_each_power_class.append\                                                (percentages[i]*Decimal(0.95))                else:                    probability_for_each_power_class.append(0)            else:                probability_for_each_power_class.append(0)                        i+=1                    sum_of_probability = sum(probability_for_each_power_class)                i = 1                while(i<len(probability_for_each_power_class)):                        if(sum_of_probability == 0):                probability_for_each_power_class[i]=0            else:                probability_for_each_power_class[i]=\                                        round(95/sum_of_probability*\                                        probability_for_each_power_class[i])\                                        +probability_for_each_power_class[i-1]                        i+=1                    probability_for_each_power_class.append(100)                    return probability_for_each_power_class                                                def plant_size_choice(probabilities,average_energy,number_power):                """        This function is to choose a plant size, which will be set in the         current load area.                For that it's need 3 input parameters.                Input parameters:        ########################### probabilities ############################        probabilities is a list with 11 values. The first Value is zero and the        last value is 100. Each other value represent the probality of each         ernergy class for this moment.                Index 0 : 0        Index 1 : probability energy of the sector: under 2kW +Index 0        Index 2 : percentage energy of sector: between 2kW and 10kW +Index 1        Index 3 : percentage energy of sector: between 10kW and 20kW +Index 2        Index 4 : percentage energy of sector: between 20kW and 50kW +Index 3        Index 5 : percentage energy of sector: between 50kW and 250kW +Index 4        Index 6 : percentage energy of sector: between 250kW and 500kW +Index 5        Index 7 : percentage energy of sector: between 500kW and 1.000kW +Index 6        Index 8 : percentage energy of sector: between 1.000kW and 2.000kW +Index 7        Index 9 : percentage energy of sector: between 2.000kW and 10.000kW +Index 8        Index 10 : 100                        ########################## average_energy #############################        average_power is a list with 9 values. Each value is the average power         of a sector. The unit of the results are kW.            Index 0 : average of the sector: under 2kW        Index 1 : average of the sector: between 2kW and 10kW        Index 2 : average of the sector: between 10kW and 20kW        Index 3 : average of the sector: between 20kW and 50kW        Index 4 : average of the sector: between 50kW and 250kW        Index 5 : average of the sector: between 250kW and 500kW        Index 6 : average of the sector: between 500kW and 1.000kW        Index 7 : average of the sector: between 1.000kW and 2.000kW        Index 8 : average of in the sector: between 2.000kW and 10.000kW                ########################## number_power ##############################        number_power is a list with also 9 values. Each value is a number of         how many plants can build from a energy class.                Index 0 : number of plants to install in the sector:                                           under 2kW        Index 1 : number of plants to install in the sector:                                     between 2kW and 10kW        Index 2 : number of plants to install in the sector:                                     between 10kW and 20kW        Index 3 : number of plants to install in the sector:                                     between 20kW and 50kW        Index 4 : number of plants to install in the sector:                                     between 50kW and 250kW        Index 5 : number of plants to install in the sector:                                     between 250kW and 500kW        Index 6 : number of plants to install in the sector:                                     between 500kW and 1.000kW        Index 7 : number of plants to install in the sector:                                     between 1.000kW and 2.000kW        Index 8 : number of plants to install in in the sector:                                     between 2.000kW and 10.000kW                                                                                To choose a plant size, it will be set a random number between 0 and        100. After setting a random number it will be checked between which         probabilites it is.                After finding the right sector, the interim energy will be set to the         average energy of this sector. The number of plants for this sector        will be also minimized by one.                After the plant size is choosen, the interim energy will be         multiplicated with (1 plus a random number between -5 and 5 Percent)        This should realize the possible different powerplant sizes.                Output parameters:                ############################## energy ################################        energy is only one value. This value represent the plant size which         should set for the current load area.                ########################## number_power ##############################        number_power is the same like the input parameter, but one value is        minimized by one.                Index 0 : number of plants to install in the sector:                                           under 2kW        Index 1 : number of plants to install in the sector:                                     between 2kW and 10kW        Index 2 : number of plants to install in the sector:                                     between 10kW and 20kW        Index 3 : number of plants to install in the sector:                                     between 20kW and 50kW        Index 4 : number of plants to install in the sector:                                     between 50kW and 250kW        Index 5 : number of plants to install in the sector:                                     between 250kW and 500kW        Index 6 : number of plants to install in the sector:                                     between 500kW and 1.000kW        Index 7 : number of plants to install in the sector:                                     between 1.000kW and 2.000kW        Index 8 : number of plants to install in in the sector:                                     between 2.000kW and 10.000kW                """                # To create a random number        # This number is for chosen a size of plant        random_number = random.randint(0,100)                i=1                if(random_number == 0):            energy = average_energy[0]        else:             while(i<len(probabilities)):                                       if((probabilities[i-1] < random_number) \                                   and\                    (random_number <= probabilities[i])):                        if(i==10):                            energy = 0                            number_power = number_power                        else:                            energy = average_energy[i-1]                            number_power[i-1] = number_power[i-1]-1                        break                else:                    i+=1                standard_variance = random.randint(-500,500)/10000                energy = round(energy * Decimal(1+standard_variance),2)                        return [energy,number_power]                            def fuel_choice(percentage_fuels, fuel_name):                """        This function is for choosen a typ of fuel for the current plant.        It needs only one input parameter.                Input parameter:                ######################### percentage_fuels ###########################        percentage_fuels are two list of 5 values. Each value of the first list        represent the percentage energy of a generation subtyp and the seconde        list is the name of each fuel.                # Index 0 : gas        # Index 1 : hard coal        # Index 2 : brown coal        # Index 3 : mineral oil        # Index 4 : others                This values are in percent.                Output parameter:                ################################ fuel ################################        fuel is only one value. This value is a STRING and represent the         choosen fuel typ for the current plant.        """                                        percentages = [0]                i = 0        while(i<len(percentage_fuels)):            percentages.append((percentage_fuels[i]*100)+percentages[i])            i+=1                fuel_rand_number = random.randint(0,10000)                i = 1        while(i<len(percentages)):            if((percentages[i-1]<=fuel_rand_number)\                                        and(fuel_rand_number<percentages[i])):                fuel = fuel_name[i-1]                break            else:                i+=1                       if(i>=5):            fuel = fuel_name[4]                                return fuel                