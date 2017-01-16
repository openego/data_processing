#!/usr/bin/env python3
"""ego data processing
This script opens a oedb database connection and executes different parts of ego.
Reads python and SQL scripts and gives logging infos during the execution.
Also see corresponding BPML diagram.
"""

__copyright__ = "Copyright ego developer group"
__license__ = "GPLv3"

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

    # list of sql_snippets that process the data in correct order
    snippet_dir = os.path.abspath(
        os.path.join(os.path.dirname(__file__),
                             'sql_snippets'))
    script_dir = os.path.abspath(
        os.path.join(os.path.dirname(__file__),
                     'python_scripts'))

    snippets = [
        # 'ego_scenario_log_setup.sql',					# setup scenario log table
        # 'ego_boundaries_vg250_setup.sql',				# setup borders
        
        # 'get_substations.sql',                 		# setup hvmv substations
        # 'get_substations_ehv.sql',             		# setup ehv substations
        # 'otg_id_to_substations.sql',           		# assign osmTGmod-id
        # 'ego_grid_hvmv_substation.sql',				# hvmv substation voronoi
        # 'Voronoi_ehv.sql',						    # ehc substation voronoi
        
        # 'process_eGo_grid_district.sql',          	# mv griddistrict
        # 'setup_osm_landuse.sql', 						# osm landuse sector
        # 'process_eGo_osm_loads_industry.sql', 		# osm industry
        # 'process_eGo_osm_loads.sql',            		# osm loads
        # 'setup_zensus_population_per_ha.sql',   		# setup zensus
        # 'process_eGo_loads_melted.sql',        		# melt osm and zensus cluster
        # 'process_eGo_loads_per_grid_district.sql', 	# loadarea per mv-griddistrict
        # 'process_eGo_consumption.sql',			   	# consumption per loadarea
        # 'ego_paper_result.sql',						# results and statistics
       
        # 'voronoi_weatherpoint.sql',				    # weatherpoint voronoi
        # 'calc_ego_hv_powerflow.sql',				    # setup for hv powerflow
        'osmtgmod_to_pypsa.sql',					    # osmTGmod2pyPSA
        'assignment_generator_bus.sql',               # 
        'assignment_load_bus.sql',                    # 
        'renpass_gis_ResultsTOPF.sql',			    # 
        'demand_per_mv_grid_district.py',			    # 
        # 'demandseries_TOPF.sql',					    # 
        # 'LOPF_data.sql',							    # 
        # 'peak_load_per_load_area.py',				    # 
        
        # 'process_eGo_onts.sql',					    # 
        # 'process_eGo_lv_grid_districts.sql'		    # 
        ]

    # get database connection
    conn = io.oedb_session(section='oedb')

    # iterate over list of sql snippets and execute them
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
