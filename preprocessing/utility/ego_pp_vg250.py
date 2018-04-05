"""
eGoPreProcessing vg250 borders
# configure logging
# create download folder
# define files for download
# download to folder and unzip
# load & import shapefiles
"""

__copyright__   = "Reiner Lemoine Institut"
__license__     = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__      = "Ludee"


import os, subprocess
import logging
import time
import urllib.request
import sqlalchemy
import shutil
import zipfile
import dateutil.parser as dparser

# start time
total_time = time.time()

# delete eGoPP folder
eGoPP_folder = r'C:/eGoPP/'
# if os.path.exists(eGoPP_folder):
#     shutil.rmtree(eGoPP_folder)
#     time.sleep(3)

# create new eGoPP folder
if not os.path.exists(eGoPP_folder):
    os.makedirs(eGoPP_folder)


# configure logging
logger = logging.getLogger('eGoPP')
logger.setLevel(logging.INFO)
# file handler (fh)
fh = logging.FileHandler(r'C:/eGoPP/ego_pp.log')
fh.setLevel(logging.INFO)
# console handler (ch)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
# create format
formatter = logging.Formatter('%(asctime)s %(levelname)s: %(message)s',
                                datefmt='%Y-%m-%d %I:%M:%S')
fh.setFormatter(formatter)
ch.setFormatter(formatter)
# add fh & ch
logger.addHandler(fh)
logger.addHandler(ch)

# logger
logger.info('eGoPreProcessing started!')


# choose your PostgreSQL version here
os.environ['PATH'] += r';C://Program Files/PostgreSQL/9.4\bin'
# http://www.postgresql.org/docs/current/static/libpq-envars.html
os.environ['PGHOST'] = 'localhost'
os.environ['PGPORT'] = '5432'
os.environ['PGUSER'] = ''
os.environ['PGPASSWORD'] = ''
os.environ['PGDATABASE'] = 'oedb'

# logger
logger.info(os.environ['PGDATABASE'] + " on "
    + os.environ['PGUSER'] + "@" 
    + os.environ['PGHOST'] + ":" 
    + os.environ['PGPORT'] )


# create download folder
download_folder = r'C:/eGoPP/vg250/'
if not os.path.exists(download_folder):
    os.makedirs(download_folder)
    logger.info("Create folder: '{}'".format(download_folder))


# define files for download
download_url = 'http://www.geodatenzentrum.de/auftrag1/archiv/vektor/vg250_ebenen/'
download_file_start = 'vg250_'
download_file_end = '-01-01.gk3.shape.ebenen.zip'
years = range(2000, 2018)
logger.info("Download from: '{}'".format(download_url))


# download to folder and unzip
for year in years:
    # download
    file_name = download_file_start + '{}'.format(year) + download_file_end
    logger.info("Download: " + file_name)
    url = download_url + '{}'.format(year) + "/" + file_name
    to_path = download_folder + file_name
    #urllib.request.urlretrieve (url, to_path)
    logger.info("Into: " + to_path)
    
    # unzip
    zip = zipfile.ZipFile(to_path)
    #zip.extractall(download_folder + file_name[:-4])
    logger.info("Unzip: " + file_name)


# logging time
logger.info('Downloads successfully executed in {:.2f} seconds!'.format(
        time.time() - total_time))


# load shapefiles
full_dir = os.walk(download_folder)
shapefile_list = []
for dirpaths, dirnames, files in full_dir:
    for file_ in files:
        if file_[-3:] == 'shp':
            # path
            shapefile_path = os.path.join(dirpaths, file_)
            logger.info("Shapefile path: " + shapefile_path)
            
            # extract date from string
            s = dirpaths.replace('\\'," ").replace('\v',' ')
            print(s)
            remove1 = [':','/','\\','_','.']
            for char in remove1: 
                s = s.replace(char," ")
            remove2 = ['C','vg250','g250','ebenen','gk3','eGoPP','shape','historisch','de0001','de0101','de0201','de0301','de0401','de0501','de0601','de0701','de0801','de0901','de1001','de1101',' ','mv','kreisreform',' ']
            for char in remove2: 
                s = s.replace(char,"")
            clean_str = s[:-10]
            print(clean_str)
            date_str = dparser.parse(clean_str,fuzzy=True).date()
            
            # table
            table_name = os.path.join(file_)[:-4] + "_" + date_str.strftime('%Y-%m-%d')
            logger.info("Table name: " + table_name)
            entry = []
            entry.append(shapefile_path)
            entry.append(table_name)
            shapefile_list.append(entry)

logger.info("Shapefile list: '{}'".format(shapefile_list))


# execute
for shape_path, table_name in shapefile_list:
    cmd = 'shp2pgsql "' + shape_path + '" boundaries.' + table_name + ' | psql > NUL'
    logger.info("Execute: " + cmd)
    subprocess.check_call(cmd, shell=True)

logger.info("Imported tables: '{}'".format([i[1] for i in shapefile_list]))


# logging time
logger.info('eGoPreProcessing successfully executed in {:.2f} seconds!'.format(
        time.time() - total_time))

# stop logging
logger.info("Stop logging")
logger.removeHandler(fh)
logger.removeHandler(ch)
fh.close()
ch.close()
