#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import logging
import time
import os
import codecs
from tools import io

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
logger.info('eGo data processing started...')

# list of sql_snippets that process the data in correct order
snippet_dir = os.path.abspath(
    os.path.join(os.path.dirname(__file__),
                         'sql_snippets'))
script_dir = os.path.abspath(
    os.path.join(os.path.dirname(__file__),
                 'python_scripts'))

snippets = [
    # # 'scenario_eGo_data_processing.sql',
    # # 'setup_bkg_vg250.sql',
    # 'get_substations.sql',
    # 'get_substations_ehv.sql',
    # 'otg_id_to_substations.sql',
    # 'process_eGo_substation.sql',
    # 'process_eGo_grid_district.sql',
    # 'setup_osm_landuse.sql',
    # 'process_eGo_osm_loads_industry.sql',
    # 'process_eGo_osm_loads.sql',
    # # 'setup_zensus_population_per_ha.sql',
    # 'process_eGo_loads_melted.sql',
    # 'process_eGo_loads_per_grid_district.sql',
    # 'process_eGo_consumption.sql',
    # 'analyse_eGo_paper_result.sql',
    # # 'setup_eGo_wpa_per_grid_district.sql',
    'setup_eGo_lattice_per_area.sql', # takes 24h
    # 'process_eGo_dea_allocation_methods.sql',
    # 'Voronoi_ehv.sql',
    # 'voronoi_weatherpoint.sql',
    # 'calc_ego_hv_powerflow.sql',
    # 'osmtgmod_to_pypsa.sql',
    # 'assignment_generator_bus.sql',
    # 'renpass_gis_ResultsTOPF.sql',
    # 'assignment_load_bus.sql',
    # 'demand_per_mv_grid_district.py',
    # 'demandseries_TOPF.sql',
    # 'peak_load_per_load_area.py'
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
