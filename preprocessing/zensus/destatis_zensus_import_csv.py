import os
import zipfile
import pandas as pd
import sqlalchemy


def import_zensus2011(file, path, db, year=2019, **kwds):

    if not db.dialect.has_schema(db, kwds["schema"]):
        db.execute(sqlalchemy.schema.CreateSchema(kwds["schema"]))

    csv_file = file.replace("zip", "csv")

    zip = zipfile.ZipFile(os.path.join(path, file))
    zip.extractall(path=path)

    # read with pandas
    zensus_raw = pd.read_csv(os.path.join(path, file), delimiter=";")
    zensus_raw.columns =["grid_id", "x_mp_100m", "y_mp_100m", "population"]
    # zensus_raw = zensus_raw.iloc[:20000]

    # create table from geopandas dataframe
    zensus_raw.to_sql(kwds["table"],
                      db, kwds["schema"],
                      index=False,
                      if_exists="replace",
                      chunksize=10000,
                      method="multi")
