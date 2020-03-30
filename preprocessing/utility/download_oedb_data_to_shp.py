import pandas as pd
from egoio.tools import db
from sqlalchemy.orm import sessionmaker
from sqlalchemy import func
import geopandas as gdp
from shapely import wkt
import zipfile
import os


DOWNLOADDIR = os.path.join(os.path.expanduser("~"), ".egon-pre-processing-cached/")


def zipdir(path, ziph):
    # ziph is zipfile handle
    for root, dirs, files in os.walk(path):
        for file in files:
            ziph.write(os.path.join(root, file), arcname=file)


def oedbtable2shp(table_orm, filename, crs, geometry_col, index_col):

    shp_dir = os.path.join(DOWNLOADDIR, filename.replace(".shp", ""))
    os.makedirs(shp_dir, exist_ok=True)
    shp_filename = os.path.join(shp_dir, filename)
    zip_filename = os.path.join(DOWNLOADDIR, filename.replace(".shp", ".zip"))

    engine_oedb = db.connection(readonly=True)
    session = sessionmaker(bind=engine_oedb)()

    table_query = session.query(
        table_orm.region_key,
        func.ST_AsText(func.ST_Transform(table_orm.geom, crs)).label(geometry_col))

    table_df = pd.read_sql_query(table_query.statement,
                                 session.bind,
                                 index_col=index_col)

    table_df[geometry_col] = table_df[geometry_col].apply(wkt.loads)
    table_gdf = gdp.GeoDataFrame(table_df,
                                 geometry=geometry_col,
                                 crs={'init': 'epsg:{}'.format(crs)})

    table_gdf.to_file(shp_filename)

    zf = zipfile.ZipFile(
        zip_filename,
        mode='w',
        compression=zipfile.ZIP_DEFLATED)
    zipdir(shp_dir, zf)
    zf.close()