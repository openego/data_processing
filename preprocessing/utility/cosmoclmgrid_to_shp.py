from egoio.db_tables.climate import Cosmoclmgrid
from preprocessing.utility.download_oedb_data_to_shp import oedbtable2shp
from sqlalchemy import func
from sqlalchemy.orm import sessionmaker
from egoio.tools import db


CRS = 4326


def cosmoclmgrid2shp():

    filename = "cosmoclmgrid.shp"

    engine_oedb = db.connection(readonly=True)
    session = sessionmaker(bind=engine_oedb)()

    query = session.query(Cosmoclmgrid.gid,
                          func.ST_AsText(func.ST_Transform(Cosmoclmgrid.geom, CRS)).label("geom"))

    oedbtable2shp(query, filename, CRS, "geom", "gid")



if __name__== "__main__":
    cosmoclmgrid2shp()