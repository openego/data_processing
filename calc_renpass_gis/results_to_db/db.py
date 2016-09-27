# -*- coding: utf-8 -*-
from sqlalchemy import create_engine
import configparser as cp
import os.path as path

# read configuration file
FILENAME = 'config.ini'
FILE = path.join(path.expanduser("~"), '.open_eGo', FILENAME)
cfg = cp.ConfigParser()
cfg.read(FILE)

# establish db connection
section = 'Connection'
conn = create_engine(
    "postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}".format(
        user=cfg.get(section, 'username'),
        password=cfg.get(section, 'password'),
        host=cfg.get(section, 'host'),
        port=cfg.get(section, 'port'),
        db=cfg.get(section, 'db')))

print("Connected to database.")
