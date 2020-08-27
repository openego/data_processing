import os
import zipfile
import geopandas as gpd
import sqlalchemy
from geoalchemy2 import Geometry
import time
from dataprocessing.tools import metadata
import json


CRS = 4326


# Function to generate WKB hex
def wkb_hexer(line):
    return line.wkb_hex


def import_cosmoclmgrid(file, path, db, **kwds):

    if not db.dialect.has_schema(db, kwds["schema"]):
        db.execute(sqlalchemy.schema.CreateSchema(kwds["schema"]))

    shp_file = file.replace(".zip", ".shp")
    subdir = file.replace(".zip", "")
    os.makedirs(os.path.join(path, subdir), exist_ok=True)

    zf = zipfile.ZipFile(os.path.join(path, file))
    zf.extractall(path=os.path.join(path, subdir))

    # read with pandas
    cosmoclmgrid = gpd.read_file(os.path.join(path, subdir, shp_file))

    cosmoclmgrid['geom'] = cosmoclmgrid['geometry'].apply(wkb_hexer)
    cosmoclmgrid.drop("geometry", axis=1, inplace=True)

    # create table from geopandas dataframe
    cosmoclmgrid.to_sql(kwds["table"],
                        db,
                        kwds["schema"],
                        index=False,
                        if_exists="replace",
                        chunksize=10000,
                        method="multi",
                        dtype={'geom': Geometry('POLYGON')}
                        )

    create_pkey_constraint = "ALTER TABLE {schema}.{table} ADD CONSTRAINT " \
                             "{table}_pkey PRIMARY KEY (gid);".format(**kwds)
    db.execution_options(autocommit=True).execute(create_pkey_constraint)

    # create metadata json str
    metadata_dict = {"name": "Spatial grid coastDat-2 re-analysis data set",
                     "title": "COSMO CLM grid",
                     "description": "This spatial grid provides reference polygons for coastDat-2 "
                                    "re-analysis data.",
                     "language": ["EN"],
                     "spatial": {
                         "location": "0.22 ° x 0.22 °",
                         "extent": "Europe",
                         "resolution": "0.22 ° x 0.22 °"
                     },
                     "temporal": {
                         "referenceDate": "2014",
                         "timeseries": {
                             "start": "",
                             "end": "",
                             "resolution": "",
                             "alignment": "",
                             "aggregationType": ""
                         }
                     },
                     "sources": [
                         {
                             "title": "coastDat-2 re-analysis data set",
                             "description": "coastDat-2 re-analysis data is a long-term backcasted "
                                            "climate data set based on the regional weather forceasting "
                                            "model COSMO CLM",
                             "path": "https://www.coastdat.de/about_us/index.php.en",
                             "licenses": [
                                 {
                                     "name": "",
                                     "title": "",
                                     "path": "",
                                     "instruction": "",
                                     "attribution": ""
                                 }
                             ]
                         }
                     ],
                     "licenses": [
                         {
                             "name": "Open Data Commons Open Database License 1.0",
                             "title": "",
                             "path": "https://opendatacommons.org/licenses/odbl/1.0/",
                             "instruction": "You are free: To Share, To Create, To Adapt; As long as you: Attribute, Share-Alike, Keep open!",
                             "attribution": "© Reiner Lemoine Institut"
                         }
                     ],
                     "contributors": [
                         {
                             "title": "Guido Pleßmann",
                             "email": "http://github.com/gplssm",
                             "date": time.strftime("%Y-%m-%d"),
                             "object": "",
                             "comment": "Only uploaded the data"
                         }
                     ],
                     "metaMetadata": {
                         "metadataVersion": "OEP-1.4.0",
                         "metadataLicense": {
                             "name": "CC0-1.0",
                             "title": "Creative Commons Zero v1.0 Universal",
                             "path": "https://creativecommons.org/publicdomain/zero/1.0/"
                         }
                     },
                     }

    json_str = "'" + json.dumps(metadata_dict) + "'"

    metadata.submit_comment(db, json_str, kwds["schema"], kwds["table"])
