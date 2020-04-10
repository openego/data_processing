import os
import zipfile
import geopandas as gpd
import sqlalchemy
from geoalchemy2 import Geometry, WKTElement
from shapely.geometry import MultiPolygon


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
                               db, kwds["schema"],
                               index=False,
                               if_exists="replace",
                               chunksize=10000,
                               method="multi",
                               dtype={'geom': Geometry('POLYGON')}
                               )

    create_pkey_constraint = "ALTER TABLE {schema}.{table} ADD CONSTRAINT " \
                             "{table}_pkey PRIMARY KEY (gid);".format(**kwds)
    db.execution_options(autocommit=True).execute(create_pkey_constraint)

