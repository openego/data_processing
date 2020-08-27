import os
import zipfile
import sqlalchemy
import geopandas as gpd
import pandas as pd
from preprocessing.utility.utils import wkb_hexer
from geoalchemy2 import Geometry
from shapely.wkt import loads as wkt_loads


def certain_file_types(directory, extension):
    return (f for f in os.listdir(directory) if f.endswith('.' + extension))


def import_osmtgmod(file, path, db, **kwds):

    # Create schema if it does not exist
    if not db.dialect.has_schema(db, kwds["schema"]):
        db.execute(sqlalchemy.schema.CreateSchema(kwds["schema"]))

    # TODO: download and add metadata to osmtgmod zip
    # TODO: write metadata to local table (would this be easier when ORMs are used locally?)
    # TODO: Add primary keys to table

    # File names and paths
    file_base, file_ext = os.path.splitext(os.path.join(path, file))
    extracted_path = os.path.join(path, file_base)

    # Extract data from zip archive
    zip = zipfile.ZipFile(os.path.join(path, file))
    zip.extractall(path=extracted_path)

    # iterate through shapefiles and import to database
    for shp_file in certain_file_types(extracted_path, "shp"):
        df = gpd.read_file(os.path.join(extracted_path, shp_file))

        # Store geometries in WKB hex format
        df['geom'] = df['geometry'].apply(wkb_hexer)
        df.drop("geometry", axis=1, inplace=True)
        if "topo" in df.columns:
            df['topo'] = df['topo'].apply(wkt_loads)
            df['topo'] = df['topo'].apply(wkb_hexer)

        table = os.path.splitext(shp_file)[0]

        df.to_sql(table,
                  db,
                  kwds["schema"],
                  index=False,
                  if_exists="replace",
                  chunksize=10000,
                  method="multi",
                  dtype={'geom': Geometry(),
                         'topo': Geometry()}
                  )

    for csv_file in certain_file_types(extracted_path, "csv"):
        df = pd.read_csv(os.path.join(extracted_path, csv_file),
                         parse_dates=["osm_date", "abstraction_date"])

        table = os.path.splitext(csv_file)[0]

        df.to_sql(table,
                  db,
                  kwds["schema"],
                  index=False,
                  if_exists="replace"
                  )
