#!/bin/python
# -*- coding: utf-8 -*-
"""
Database dump CSV-file with lon/lat is converted to a git compatible geojson
format.

Attributes
----------
infile : str
    File path to database dump.
outfile : str
    File path to geojson file.

Notes
-----
Dump has to match geojson keys title, description, lon and lat.

"""


__copyright__ = "ZNES"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "s3pp"


import pandas as pd
import json
from os.path import expanduser

infile = '~/open_eGo/scenario/modelpowerplants.csv'
outfile = expanduser("")

df = pd.read_csv(infile, sep=";")
features = []
for ix, row in df.iterrows():

        # properties section
        properties = {"title": row['title'],
                      "description": row['description'],
                      "marker-size": "medium",
                      "marker-symbol": "triangle",
                      "stroke": "#555555"}

        # geometry section
        geometry = {"type": "Point",
                    "coordinates": [row['lon'], row['lat']]}

        # concat to feature
        feature = {"type": "Feature",
                   "geometry": geometry,
                   "properties": properties}

        features.append(feature)

feature_collection = {"type": "FeatureCollection",
                      "features": features}

with open(outfile, 'w') as out:
    json.dump(feature_collection, out)
