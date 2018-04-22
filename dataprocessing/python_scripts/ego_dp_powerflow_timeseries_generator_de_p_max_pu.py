""" This script assigns feedin timeseries data generated with feedinlib
as p_max_pu parameter to high-voltage powerflow generators within Germany.
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

# Get database connection
conn = oedb_session(section='test')
Session = sessionmaker(bind=conn)
session = Session()

_, PowerClass, Feedin, *_, Results = missing_orm_classes(session)

logged = 0
for scn_name, scn_nr in SCENARIOMAP.items():

    # Select the correct sources
    # Map source_id to feedin source name
    sources = ['wind_onshore', 'wind_offshore', 'solar']
    sources_dict = {
        k: v for k, v in OBJ_LABEL_TO_SOURCE.items() if k in sources}

    # Wrap case around feedin source to return source_id instead of name
    casestr = case(sources_dict, value=Feedin.source, else_=None)

    # Get a unique represenation of PfGeneratorSingle with regard to aggr_id,
    # source, w_id, power_class
    filters = (
        GeneratorSingle.scn_name == scn_name, GeneratorSingle.aggr_id != None)
    fields = [GeneratorSingle.aggr_id, GeneratorSingle.source,
              GeneratorSingle.w_id, GeneratorSingle.power_class]
    grouper = GeneratorSingle.aggr_id, GeneratorSingle.source,\
        GeneratorSingle.w_id, GeneratorSingle.power_class

    # Construct a subquery with filters, fields and grouper
    t = session.query(*fields).group_by(*grouper).filter(*filters).subquery()

    # Use subquery and Feedin table to get the correct feedin for each
    # generator
    query = session.query(t, Feedin.feedin.label('p_max_pu')).filter(
        t.c.w_id == Feedin.w_id, t.c.power_class == Feedin.power_class,
        t.c.source == casestr)

    generators = pd.read_sql(query.statement, query.session.bind)

    # Substation's aggr_id are the basis for generators in high-voltage
    # powerflow
    # Rename column aggr_id to generator_id
    generators.rename(columns={'aggr_id': 'generator_id'}, inplace=True)

    generators['temp_id'] = TEMPID
    generators['scn_name'] = scn_name

    # Select fields for PqSets
    # Write PqSets to database
    fields = ['generator_id', 'p_max_pu', 'scn_name', 'temp_id']
    for i in generators[fields].to_dict(orient='records'):
        session.add(PqSet(**i))

    session.commit()

    logged += len(generators)

write_ego_scenario_log(conn=conn,
                       version='v0.4.0',
                       io='input',
                       schema='model_draft',
                       table=PqSet.__tablename__,
                       script=__file__,
                       entries=logged)
