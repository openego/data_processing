"""eGo Data Processing (eGoDP) - Renewable Energy Allocation (REA)
This script opens a oedb database connection and executes different parts of eGo.
Reads SQL scripts and gives logging infos during the execution.
Also see corresponding BPML diagram.
"""

__copyright__ = "Reiner Lemoine Institut gGmbH"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "Ludee"

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
logger.info('ego renewable_energy_allocation (ego_rea) started...')

# list of sql_scripts that process the data in correct order
script_dir = os.path.abspath(
    os.path.join(os.path.dirname(__file__),
                         'renewable_energy_allocation'))

scripts = [
    # 'ego_lattice_500m.sql', 				# lattice (point grid) 500m
    # 'ego_lattice_50m.sql', 				# lattice (point grid) 50m
    # 'ego_rea_wpa_per_mvgd.sql', 			# wind potential area
    # 'ego_rea_lattice_per_area_500m.sql', 	# prepare 500m lattice
    # 'ego_rea_lattice_per_area_50m.sql', 	# prepare 50m lattice
    # 'ego_rea_setup.sql',					# setup table for allocation
    # 'ego_rea_m1.sql',
    # 'ego_rea_m2.sql',
    # 'ego_rea_m3.sql',
    # 'ego_rea_m4.sql',
    # 'ego_rea_m5.sql',
    # 'ego_rea_results.sql'
    ]

# get database connection
conn = io.oedb_session(section='oedb')

# iterate over list of sql scripts and execute them
for script in scripts:
    # timing and logging
    script_time = time.time()
    logger.info("Execute '{}' ...".format(script))
    if os.path.splitext(script)[1] == '.sql':
        script_str = open(os.path.join(script_dir, script)).read()
        conn.execution_options(autocommit=True).execute(script_str)
        
    elif os.path.splitext(script)[1] == '.py':
        filename = os.path.join(script_dir, script)
        script_str = open(filename, "rb").read()
        exec(compile(script_str, filename, 'exec'))
        
    else:
        raise NameError('{} is not a sql script (at least it '
                        'has not the right extension). Please add an extension '
                        'to the script name (.sql)'.format(script))

    # inform the user
    logger.info('...successfully done in {:.2f} seconds.'.format(
        time.time() - script_time))

# close database connection
conn.close()

logger.info('Data processing script successfully executed in {:.2f} seconds'.format(
    time.time() - total_time))
