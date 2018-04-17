""" This script assigns feedin timeseries data generated with feedinlib
to high-voltage powerflow generators.
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

from egoio.db_tables.model_draft import EgoSupplyPfGeneratorSingle \
    as GeneratorSingle, EgoGridPfHvGeneratorPqSet as PqSet
from ego_dp_powerflow_timeseries_generator_helper import OBJ_LABEL_TO_SOURCE, SCENARIOMAP, \
    TEMPID, missing_orm_classes

# get database connection
conn = oedb_session(section='test')
Session = sessionmaker(bind=conn)
session = Session()

PowerClass, Feedin, *_, Results = missing_orm_classes(session)

# p_max_pu
logged = 0
for scn_name, scn_nr in SCENARIOMAP.items():

    sources = ['wind_onshore', 'wind_offshore', 'solar']
    sources_dict = {k: v for k, v in OBJ_LABEL_TO_SOURCE.items() if k in sources}
    casestr = case(sources_dict, value=Feedin.source, else_=None)

    # construct subquery from PfGeneratorSingle with unique aggr_id, source,
    # w_id, power_class
    filters = (GeneratorSingle.scn_name == scn_name, GeneratorSingle.aggr_id != None)
    fields = [GeneratorSingle.aggr_id, GeneratorSingle.source,
              GeneratorSingle.w_id, GeneratorSingle.power_class]
    grouper = GeneratorSingle.aggr_id, GeneratorSingle.source,\
        GeneratorSingle.w_id, GeneratorSingle.power_class

    t = session.query(*fields).group_by(*grouper).filter(*filters).subquery()

    # use subquery to select the corresponding feedin
    query = session.query(t, Feedin.feedin.label('p_max_pu')).filter(t.c.w_id == Feedin.w_id,
        t.c.power_class == Feedin.power_class, t.c.source == casestr)

    generators = pd.read_sql(query.statement, query.session.bind)

    # rename column aggr_id to generator_id
    generators.rename(columns={'aggr_id': 'generator_id'}, inplace=True)

    generators['temp_id'] = TEMPID
    generators['scn_name'] = scn_name

    fields = ['generator_id', 'p_max_pu', 'scn_name', 'temp_id']
    for i in generators[fields].to_dict(orient='records'):
        session.add(PqSet(**i))

    session.commit()

    logged += len(generators)

write_ego_scenario_log(conn=conn,
                        version='v0.3.0',
                        io='input',
                        schema='model_draft',
                        table=PqSet.__tablename__,
                        script=__file__,
                        entries=logged)
