import pandas as pd
from egoio.tools import db
from sqlalchemy.orm import sessionmaker
import geopandas as gdp
from shapely import wkt
import zipfile
import os
from preprocessing.utility.utils import DOWNLOADDIR, zipdir


def oedbtable2shp(table_query, filename, crs, geometry_col, index_col, zip_it=True):

    file_basename = os.path.basename(os.path.splitext(filename)[0])
    shp_dir = os.path.join(DOWNLOADDIR, file_basename)
    os.makedirs(shp_dir, exist_ok=True)
    shp_filename = os.path.join(shp_dir, filename)
    zip_filename = os.path.join(DOWNLOADDIR, file_basename + ".zip")

    engine_oedb = db.connection(readonly=True)
    session = sessionmaker(bind=engine_oedb)()

    table_df = pd.read_sql_query(table_query.statement,
                                 session.bind,
                                 index_col=index_col)

    if geometry_col:
        table_df[geometry_col] = table_df[geometry_col].apply(wkt.loads)
        table_gdf = gdp.GeoDataFrame(table_df,
                                     geometry=geometry_col,
                                     crs=crs)

        table_gdf.to_file(shp_filename)
    else:
        table_df.to_csv(shp_filename)

    if zip_it:
        zf = zipfile.ZipFile(
            zip_filename,
            mode='w',
            compression=zipfile.ZIP_DEFLATED)
        zipdir(shp_dir, zf)
        zf.close()