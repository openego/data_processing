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
from sqlalchemy import case, func
from dataprocessing.python_scripts.functions.ego_scenario_log \
    import write_ego_scenario_log

from egoio.db_tables.climate import Cosmoclmgrid
from egoio.db_tables.model_draft import EgoSupplyPfGeneratorSingle \
    as GeneratorSingle, EgoGridPfHvGeneratorPqSet as PqSet, \
    EgoGridPfHvGenerator as Generator, \
    EgoGridPfHvGeneratorPqSet as PqSet, EgoGridHvElectricalNeighboursBus as Neighbour
from ego_dp_powerflow_timeseries_generator_helper import OBJ_LABEL_TO_SOURCE, SCENARIOMAP, \
    TEMPID, missing_orm_classes

# get database connection
conn = oedb_session(section='test')
Session = sessionmaker(bind=conn)
session = Session()

_, PowerClass, Feedin, *_, Results = missing_orm_classes(session)

# get DataFrame each row representing one electrical neighbour by applying
# filter on id and v_nom, not affected by scenario name
query = session.query(Neighbour)
neighbours = pd.read_sql(query.statement, query.session.bind)

ix = (neighbours['id'] <= 27) & (neighbours['v_nom'] == 380)
neighbours = neighbours.loc[ix, :]
neighbours.set_index('cntr_id', inplace=True)

# p_max_pu
logged = 0

t = session.query(Cosmoclmgrid.gid.label('w_id'), Neighbour.bus_id).filter(
    func.ST_Intersects(Cosmoclmgrid.geom, Neighbour.geom)).subquery()

sources = ['wind_onshore', 'solar']
sources_dict = {v: k for k, v in OBJ_LABEL_TO_SOURCE.items() if k in sources}

casestr = case(sources_dict, value=Generator.source, else_=None).label('source')

query = session.query(Generator.scn_name, Generator.generator_id, casestr, t.c.w_id).filter(
    Generator.bus.in_(neighbours.bus_id)).filter(
        t.c.bus_id == Generator.bus, Generator.source.in_(sources_dict))

# pd.DataFrame with generator_id, source, w_id
generators = pd.read_sql(query.statement, query.session.bind)

query = session.query(
    Feedin.w_id, Feedin.source, Feedin.feedin.label('p_max_pu')).filter(
        Feedin.w_id.in_(generators.w_id), Feedin.power_class.in_([0, 4]))
feedins = pd.read_sql(query.statement, query.session.bind)

#
generators = generators.merge(feedins, on=['source', 'w_id'], how='inner', validate='many_to_one')
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
