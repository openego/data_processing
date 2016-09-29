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
snippet_dir = 'sql_snippets'
sql_snippets = ['setup_osm_landuse.sql']

# Ready:
# 'setup_bkg_vg250.sql',

# To be tested!
                # 'setup_osm_landuse.sql',
                # 'process_eGo_osm_loads_industry.sql',
                # 'process_eGo_osm_loads.sql',
                # 'setup_zensus_population_per_ha.sql',
                # 'process_eGo_loads_melted.sql',
                # 'process_eGo_substation.sql',
                # 'process_eGo_grid_district.sql',
                # 'process_eGo_loads_per_grid_district.sql',
                # 'process_eGo_consumption.sql',
                # 'analyse_eGo_paper_result.sql'


# get database connection
conn = io.oedb_session(section='oedb')

# iterate over list of sql snippets and execute them
for snippet in sql_snippets:
    # timing and logging
    snippet_time = time.time()
    logger.info("Execute '{}' ...".format(snippet))
    snippet_str = open(os.path.join(snippet_dir, snippet)).read()

    # execute desired sql snippet
    conn.execution_options(autocommit=True).execute(snippet_str)

    # inform the user
    logger.info('...successfully done in {:.2f} seconds.'.format(
        time.time() - snippet_time))

# close database connection
conn.close()

logger.info('Data processing script successfully executed in {:.2f} seconds'.format(
    time.time() - total_time))
