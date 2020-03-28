import pandas as pd
from egoio.tools import db
from egoio.db_tables.supply import VernetzenWindPotentialArea
from sqlalchemy.orm import sessionmaker
from sqlalchemy import func
import geopandas as gdp
from shapely import wkt
import os
import zipfile


DOWNLOADDIR = os.path.join(os.path.expanduser("~"), ".egon-pre-processing-cached/")
CRS = 4326


def vernetzen_windpotential_areas2shp():

    filename = "vernetzen_wind_potential_areas.shp"
    oedbtable2shp(VernetzenWindPotentialArea, filename)



def zipdir(path, ziph):
    # ziph is zipfile handle
    for root, dirs, files in os.walk(path):
        for file in files:
            ziph.write(os.path.join(root, file), arcname=file)


def oedbtable2shp(table_orm, filename):

    shp_dir = os.path.join(DOWNLOADDIR, filename.replace(".shp", ""))
    os.makedirs(shp_dir, exist_ok=True)
    shp_filename = os.path.join(shp_dir, filename)
    zip_filename = os.path.join(DOWNLOADDIR, filename.replace(".shp", ".zip"))

    engine_oedb = db.connection(readonly=True)
    session = sessionmaker(bind=engine_oedb)()

    table_query = session.query(
        table_orm.region_key,
        func.ST_AsText(func.ST_Transform(table_orm.geom, CRS)).label('geom'))

    table_df = pd.read_sql_query(table_query.statement,
                                 session.bind,
                                 index_col='region_key')

    table_df["geom"] = table_df["geom"].apply(wkt.loads)
    table_gdf = gdp.GeoDataFrame(table_df,
                                 geometry="geom",
                                 crs={'init': 'epsg:{}'.format(CRS)})

    table_gdf.to_file(shp_filename)

    zf = zipfile.ZipFile(
        zip_filename,
        mode='w',
        compression=zipfile.ZIP_DEFLATED)
    zipdir(shp_dir, zf)
    zf.close()


if __name__== "__main__":
    vernetzen_windpotential_areas2shp()