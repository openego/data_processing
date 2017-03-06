"""eGo Data Processing (eGoDP)
This script opens a oedb database connection and executes different parts of eGo.
Reads python and SQL scripts and gives logging infos during the execution.
Also see corresponding BPML diagram.
"""

__copyright__ = "Reiner Lemoine Institut gGmbH"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "gplssm, Ludee"

import pandas as pd
import logging
import time
import os
import codecs
from tools import io

def data_processing():
    # Configure logging
    logger = logging.getLogger('EEEE')
    logger.setLevel(logging.INFO)
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s %(message)s',
                                  datefmt='%Y-%m-%d %I:%M:%S')
    ch.setFormatter(formatter)
    logger.addHandler(ch)

    # get current time and inform about start
    total_time = time.time()
    logger.info('ego data processing started...')

    # list of sql- and python-snippets that process the data in correct order
    snippet_dir = os.path.abspath(
        os.path.join(os.path.dirname(__file__),
                             'sql_snippets'))
    script_dir = os.path.abspath(
        os.path.join(os.path.dirname(__file__),
                     'python_scripts'))

    snippets = [
	    
	  	##PREPROCESSING  
	## 'ego_dp_preprocessing_conv_powerplant.sql',		# Preprocess conventional power plants list for further use
    	## 'ego_dp_preprocessing_res_powerplant.sql',		# Preprocess renewable power plants list for further use
   
		## STRUCTURE
         #'ego_scenario_log_setup.sql',				# Setup scenario log table
         #'ego_boundaries_vg250_setup.sql',			# Setup vg250 borders
         #'analyse_osm_landuse.sql',                    	# Filter OSM landuse
        
		## SUBSTATION
         #'get_substations.sql',                 		# Abstract HVMV Substations of the high voltage level from OSM
         #'get_substations_ehv.sql',             		# Abstract EHV Substations of the extra high voltage level from OSM
         #'otg_id_to_substations.sql',           		# Assign osmTGmod-id to HVMV and EHV substations
         #'ego_grid_hvmv_substation.sql',			# HVMV Voronoi cells based on HVMV substations
         #'Voronoi_ehv.sql',					# EHV Voronoi cells based on EHV substations
        
		## GRIDDISTRICT
         #'process_eGo_grid_district.sql',          		# MV Griddistricts from municipalities and Voronoi cells
		
		## LOADAREA
         #'setup_osm_landuse.sql', 				# OSM landuse sector
         'process_eGo_osm_loads_industry.sql', 		# Industry consumer
         'process_eGo_osm_loads.sql',            		# Loads from OSM landuse
         'setup_zensus_population_per_ha.sql',   		# Loads from Census
         'process_eGo_loads_melted.sql',        		# Melt OSM landuse and Zensus loads
         'process_eGo_loads_per_grid_district.sql', 		# Cut Loadarea with MV Griddistrict
         'ego_demand_loads_per_mv_voronoi.sql', 	    	# Cut Loadarea with MV Voronoi cells
         'process_eGo_consumption.sql',			# Allocate consumption to Loadareas
         'peak_load_per_load_area.py',				# Peak loads per Loadarea
         'ego_mv_griddistrict_results.sql',            	# Results for MV Griddistrict
         'ego_paper_result.sql',				# Results and statistics for eGoDP
       
		## POWERFLOW
        # 'voronoi_weatherpoint.sql',				# Create voronoi cells based on weather points
        # 'calc_ego_hv_powerflow.sql',				# Set schema/tables for EHV/HV powerflow calculations up
        # 'osmtgmod_to_pypsa.sql',				# Include data from osmTGmod into EHV/HV powerflow schema
        # 'assignment_generator_bus.sql',               	# Assign generators to corresponding substation
        # 'assignment_load_bus.sql',                    	# Assign loads to their corresponding substation
        # 'renpass_gis_ResultsTOPF.sql',			# Transfer renpassG!S results into the corresponding powerflow table
        # 'demand_per_mv_grid_district.py',			# 
        # 'demandseries_TOPF.sql',				# Insert demand series into corresponding powerflow table
        # 'LOPF_data.sql',					# Set marginal costs for generators and storages
        
		## LOWVOLTAGE
        # 'process_eGo_mvlv_substation.sql',			# MVLV Substation inside Loadarea
        # 'process_eGo_lv_grid_districts.sql'		    	# LV Griddistrict inside Loadarea
        ]

    # get database connection
    conn = io.oedb_session(section='oedb')

    # iterate over list of sql- and python-snippets and execute them
    for snippet in snippets:
        # timing and logging
        snippet_time = time.time()
        logger.info("Execute '{}' ...".format(snippet))
        if os.path.splitext(snippet)[1] == '.sql':
            snippet_str = open(os.path.join(snippet_dir, snippet)).read()

            # execute desired sql snippet
            conn.execution_options(autocommit=True).execute(snippet_str)
        elif os.path.splitext(snippet)[1] == '.py':
            filename = os.path.join(script_dir, snippet)
            script_str = open(filename, "rb").read()

            # execute desired sql snippet
            exec(compile(script_str, filename, 'exec'))
        else:
            raise NameError('{} is neither a python nor a sql script (at least it '
                            'has not the right extension). Please add an extension '
                            'to the script name (.py or .sql)'.format(snippet))

        # inform the user
        logger.info('...successfully done in {:.2f} seconds.'.format(
            time.time() - snippet_time))

    # close database connection
    conn.close()

    logger.info('Data processing script successfully executed in {:.2f} seconds'.format(
        time.time() - total_time))


if __name__ == '__main__':
    data_processing()
