"""
eGo PreProcessing (eGoPP)

This script opens an oedb database connection and executes different parts of eGo.
Reads python and SQL scripts and gives logging infos during the execution.
Also see corresponding BPML diagram.

This file is part of project "open_eGo DataProcessing" (https://github.com/openego/data_processing/).
It's copyrighted by the contributors recorded in the version control history:
openego/data_processing/preprocessing/eGo_PreProcessing.py

SPDX-License-Identifier: AGPL-3.0-or-later
"""

__copyright__ = "Reiner Lemoine Institut"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://www.gnu.org/licenses/agpl-3.0.en.html"
__author__ = "gplssm, Ludee"

import logging
import time
import os
import subprocess
from dataprocessing.tools import io
from egoio.tools import db
from sqlalchemy import create_engine
import yaml
from urllib.request import urlretrieve

# Configure logging
logger = logging.getLogger('EEEE')
logger.setLevel(logging.INFO)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s %(message)s',
                              datefmt='%Y-%m-%d %I:%M:%S')
ch.setFormatter(formatter)
logger.addHandler(ch)

SCENARIOLOG = True
DOWNLOADDIR = os.path.join(os.path.expanduser("~"), ".egon-pre-processing-cached/")


def create_data_dir(dir=DOWNLOADDIR):
    """
    Parameters
    ----------
    dir: str
        Define alternative dir for chached data
    """

    os.makedirs(dir, exist_ok=True)
    logger.info('Cached data directory {} created (or already existed).'.format(dir))


def download_data(url, filename):

    file = os.path.join(DOWNLOADDIR, filename)

    if not os.path.isfile(file):
        urlretrieve(url, file)


def preprocessing():

    # get current time and inform about start
    total_time = time.time()
    logger.info('ego preprocessing started...')

    # create directory for cached downloaded data
    create_data_dir()

    # list of sql- and python-snippets that process the data in correct order
    script_dir = os.path.abspath(
        os.path.join(os.path.dirname(__file__)))

    snippets = [
     'ego_pre_voltage_level.sql',
     'ego_pre_slp_parameters.sql'
    ]
    datasets = yaml.load(open("import.yml"))#, Loader=Loader)

    # get database connection
    conn_oedb = db.connection(readonly=True).connect()
    engine_local = create_engine('postgresql+psycopg2://oeuser:egon@localhost:54321/dp')
    conn = engine_local.connect()

    # iterate over data sets
    for key, dataset in datasets.items():
        for download in dataset.get("required_data", []):
            download_data(download["url"], download["filename"])

        for script in dataset.get("scripts", []):

            # timing and logging
            snippet_time = time.time()
            logger.info("Execute '{}' ...".format(script["script"]))
            if script["language"] == 'SQL':
                if SCENARIOLOG is True:
                    snippet_str = open(os.path.join(script_dir, key, script["script"])).read()
                elif SCENARIOLOG is False:
                    snippet_str = "".join(
                        [l for l in open(os.path.join(script_dir, key, script["script"])).readlines()
                         if not l.startswith("SELECT scenario_log") and not l.startswith("SELECT ego_scenario_log")])

                # execute desired sql snippet
                conn.execution_options(autocommit=True).execute(snippet_str)
            elif script["language"] == 'python':
                filename = os.path.join(script_dir, key, script["script"])
                script_str = open(filename, "rb").read()

                # execute desired sql snippet
                exec(compile(script_str, filename, 'exec'))
            elif script["language"] == 'bash':
                filename = os.path.join(script_dir, key, script["script"])
                script_str = open(filename, "rb").read()

                # execute desired bash script
                rc = subprocess.call(script_str,
                                     cwd= os.path.join(script_dir, key),
                                     shell=True)
            else:
                raise NameError('{} is neither a python nor a sql script (at least it '
                                'has not the right extension). Please add an extension '
                                'to the script name (.py or .sql)'.format(script["script"]))

            # inform the user
            logger.info('...successfully done in {:.2f} seconds.'.format(
                time.time() - snippet_time))

    # close database connection
    conn.close()

    logger.info('eGo PreProcessing script successfully executed in {:.2f} seconds'.format(
        time.time() - total_time))


if __name__ == '__main__':
    preprocessing()
