""" This script assigns feedin timeseries data generated with feedinlib
to high-voltage powerflow generators for neighbouring countries.
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

from egoio.db_tables.model_draft import EgoGridPfHvGenerator as Generator, \
    EgoGridPfHvGeneratorPqSet as PqSet, EgoGridHvElectricalNeighboursBus as Neighbour
from ego_dp_powerflow_timeseries_generator_helper import OBJ_LABEL_TO_SOURCE,\
    TEMPID, missing_orm_classes

# get database connection
conn = oedb_session(section='test')
Session = sessionmaker(bind=conn)
session = Session()

OffshorePoints, PowerClass, Feedin, *_, Results = missing_orm_classes(session)

# get DataFrame each row representing one electrical neighbour by applying
# filter on id and v_nom, not affected by scenario name
query = session.query(Neighbour)
neighbours = pd.read_sql(query.statement, query.session.bind)

ix = (neighbours['id'] <= 27) & (neighbours['v_nom'] == 380)
neighbours = neighbours.loc[ix, :]
neighbours.set_index('cntr_id', inplace=True)

# p_max_pu
logged = 0

# assign w_id to neighbours definition
neighbours['w_id'] = pd.Series(dict(
    session.query(OffshorePoints.cntr_id, OffshorePoints.coastdat_id).all()))
neighbours = neighbours[~neighbours['w_id'].isna()].copy()
neighbours['w_id'] = neighbours['w_id'].astype(int)

sources = ['wind_offshore']
sources_dict = {v: k for k, v in OBJ_LABEL_TO_SOURCE.items() if k in sources}

bus_to_wid = dict(neighbours[['bus_id', 'w_id']].values.tolist())

casestr = case(bus_to_wid, value=Generator.bus, else_=None).label('w_id')

query = session.query(Generator.scn_name, Generator.bus, Generator.generator_id, casestr).filter(
    Generator.bus.in_(neighbours.bus_id)).filter(Generator.source.in_(sources_dict))

generators = pd.read_sql(query.statement, query.session.bind)

query = session.query(
    Feedin.w_id, Feedin.feedin.label('p_max_pu')).filter(
        Feedin.w_id.in_(generators.w_id), Feedin.power_class.in_([0, 4]))
feedins = pd.read_sql(query.statement, query.session.bind)

generators = generators.merge(feedins, on=['w_id'], how='inner', validate='many_to_one')
generators['temp_id'] = TEMPID

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
