""" This script assigns offshore timeseries data generated with feedinlib
as parameter p_max_pu to high-voltage powerflow generators
in case of neighbouring countries.
"""

__copyright__ = "ZNES Flensburg"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

import pandas as pd

from dataprocessing.tools.io import oedb_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy import case
from dataprocessing.python_scripts.functions.ego_scenario_log \
    import write_ego_scenario_log

from egoio.db_tables.model_draft import \
    EgoGridPfHvGenerator as Generator, \
    EgoGridPfHvGeneratorPqSet as PqSet, \
    EgoGridHvElectricalNeighboursBus as Neighbour
from ego_dp_powerflow_timeseries_generator_helper import OBJ_LABEL_TO_SOURCE,\
    TEMPID, missing_orm_classes

# Get database connection
conn = oedb_session(section='test')
Session = sessionmaker(bind=conn)
session = Session()

OffshorePoints, PowerClass, Feedin, *_, Results = missing_orm_classes(session)

# TODO: This part is used very often and could be outsourced
# Read in a DataFrame with data of neighbouring countries
# Filtered on id, v_nom
query = session.query(Neighbour)
neighbours = pd.read_sql(query.statement, query.session.bind)

ix = (neighbours['id'] <= 27) & (neighbours['v_nom'] == 380)
neighbours = neighbours.loc[ix, :]
neighbours.set_index('cntr_id', inplace=True)

# logging variable
logged = 0

# With OffshorePoints, a representation of iso-country-code to w_id,
# assign w_id to data of neighbouring countries
# Delete countries that have no w_id assigned / have no offshore generation
neighbours['w_id'] = pd.Series(dict(
    session.query(OffshorePoints.cntr_id, OffshorePoints.coastdat_id).all()))
neighbours = neighbours[~neighbours['w_id'].isna()].copy()
neighbours['w_id'] = neighbours['w_id'].astype(int)

# Map source name to source_id
sources = ['wind_offshore']
sources_dict = {v: k for k, v in OBJ_LABEL_TO_SOURCE.items() if k in sources}

# Map bus to w_id
bus_to_wid = dict(neighbours[['bus_id', 'w_id']].values.tolist())

# Wrap mapping case around Generator.bus to return w_id instead
casestr = case(bus_to_wid, value=Generator.bus, else_=None).label('w_id')

# Retrieve existing offshore Generators
query = session.query(Generator.scn_name, Generator.bus, Generator.generator_id, casestr).filter(
    Generator.bus.in_(neighbours.bus_id)).filter(Generator.source.in_(sources_dict))

generators = pd.read_sql(query.statement, query.session.bind)

# Select wind_offshore feedins that match the weather_id
query = session.query(
    Feedin.w_id, Feedin.feedin.label('p_max_pu')).filter(
        Feedin.source.in_(sources_dict.values()),
        Feedin.w_id.in_(generators.w_id),
        Feedin.power_class.in_([0, 4]))
feedins = pd.read_sql(query.statement, query.session.bind)

# Merge DataFrames on weather_id
# This is a many_to_one relation because of multiple scenarios
generators = generators.merge(feedins, on=['w_id'], how='inner', validate='many_to_one')
generators['temp_id'] = TEMPID

# Write PqSets to the database
fields = ['generator_id', 'p_max_pu', 'scn_name', 'temp_id']
for i in generators[fields].to_dict(orient='records'):
    session.add(PqSet(**i))

logged += len(generators)

session.commit()

write_ego_scenario_log(conn=conn,
                       version='v0.4.0',
                       io='input',
                       schema='model_draft',
                       table=PqSet.__tablename__,
                       script=__file__,
                       entries=logged)
