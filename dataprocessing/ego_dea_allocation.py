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
logger.info('eGo dea allocation started...')

# list of sql_scripts that process the data in correct order
script_dir = os.path.abspath(
    os.path.join(os.path.dirname(__file__),
                         'dea_allocation'))

scripts = [
    ## 'ego_deu_lattice.sql' 				# create a point grid (lattice) on the bbox of Germany / Only create once!
	# 'ego_rea_wpa_per_mvgd.sql', 			# wind potential area per grid district
    # 'ego_rea_lattice_per_area_500m.sql', 	# prepare 500m lattice
    # 'ego_rea_lattice_per_area_50m.sql', 	# prepare 50m lattice
	## 'ego_rea_lattice_per_area_34m.sql', 	# prepare 34m lattice -> do not do it, takes ages!
    # 'ego_dea_allocation_setup.sql',		# setup table for allocation
    # 'ego_dea_allocation_m1.sql',
    # 'ego_dea_allocation_m2.sql',
    # 'ego_dea_allocation_m3.sql',
    # 'ego_dea_allocation_m4.sql',
    # 'ego_dea_allocation_m5.sql',
    # 'ego_dea_allocation_results.sql'
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
