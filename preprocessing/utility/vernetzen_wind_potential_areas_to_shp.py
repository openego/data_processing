from egoio.db_tables.supply import VernetzenWindPotentialArea
import os
from preprocessing.utility.download_oedb_data_to_shp import oedbtable2shp
from sqlalchemy import func
from sqlalchemy.orm import sessionmaker
from egoio.tools import db



CRS = 4326


def vernetzen_windpotential_areas2shp():

    filename = "vernetzen_wind_potential_areas.shp"

    engine_oedb = db.connection(readonly=True)
    session = sessionmaker(bind=engine_oedb)()

    table_query = session.query(
        VernetzenWindPotentialArea.region_key,
        func.ST_AsText(func.ST_Transform(VernetzenWindPotentialArea.geom, CRS)).label("geom"))

    oedbtable2shp(table_query, filename, CRS, "geom", "region_key")


if __name__== "__main__":
    vernetzen_windpotential_areas2shp()