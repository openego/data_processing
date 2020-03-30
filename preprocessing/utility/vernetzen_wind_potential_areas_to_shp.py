from egoio.db_tables.supply import VernetzenWindPotentialArea
import os
from preprocessing.utility.download_oedb_data_to_shp import oedbtable2shp


CRS = 4326


def vernetzen_windpotential_areas2shp():

    filename = "vernetzen_wind_potential_areas.shp"
    oedbtable2shp(VernetzenWindPotentialArea, filename, CRS, "geom", "region_key")


if __name__== "__main__":
    vernetzen_windpotential_areas2shp()