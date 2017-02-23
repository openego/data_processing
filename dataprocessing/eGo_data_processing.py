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
        # 'ego_scenario_log_setup.sql',					# setup scenario log table
        # 'ego_boundaries_vg250_setup.sql',				# setup borders
        # 'analyse_osm_landuse.sql',                    # setup OSM landuse
        
        # 'get_substations.sql',                 		# Abstract substations of the high voltage level from osm data
        # 'get_substations_ehv.sql',             		# Abstract substations of the extra high voltage level from osm data
        # 'otg_id_to_substations.sql',           		# Assign osmTGmod-id to substations
        # 'ego_grid_hvmv_substation.sql',				# Create voronoi cells based on HV/MV substations
        # 'Voronoi_ehv.sql',						    # Create voronoi cells based on EHV substations
        
        # 'process_eGo_grid_district.sql',          	# mv griddistrict
        # 'setup_osm_landuse.sql', 						# osm landuse sector
        # 'process_eGo_osm_loads_industry.sql', 		# Identify industrial large scale consumer
        # 'process_eGo_osm_loads.sql',            		# osm loads
        # 'setup_zensus_population_per_ha.sql',   		# setup zensus
        # 'process_eGo_loads_melted.sql',        		# melt osm and zensus cluster
        # 'process_eGo_loads_per_grid_district.sql', 	# loadarea per mv-griddistrict
        # 'ego_demand_loads_per_mv_voronoi.sql', 	    # loadarea per mv-voronoi
        # 'process_eGo_consumption.sql',			   	# Allocate load to load areas
        # 'peak_load_per_load_area.py',				    # peak loads
        # 'ego_mv_griddistrict_results',                # results for mv-griddistrict
        # 'ego_paper_result.sql',						# results and statistics
       
        # 'voronoi_weatherpoint.sql',				    # Create voronoi cells based on weather points
        # 'calc_ego_hv_powerflow.sql',				    # Set schema/tables for EHV/HV powerflow calculations up
        # 'osmtgmod_to_pypsa.sql',					    # Include data from osmTGmod into EHV/HV powerflow schema
        # 'assignment_generator_bus.sql',               # Assign generators to corresponding substation
        # 'assignment_load_bus.sql',                    # Assign loads to their corresponding substation
        # 'renpass_gis_ResultsTOPF.sql',			    # Transfer renpassG!S results into the corresponding powerflow table
        # 'demand_per_mv_grid_district.py',			    # 
        # 'demandseries_TOPF.sql',					    # Insert demand series into corresponding powerflow table
        # 'LOPF_data.sql',							    # Set marginal costs for generators and storages
        
        # 'process_eGo_mvlv_substation.sql',			#
        # 'process_eGo_lv_grid_districts.sql'		    # 
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
