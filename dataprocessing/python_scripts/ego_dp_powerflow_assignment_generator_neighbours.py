""" Transfer renpassG!S scenario definition of LinearTransformers and Sources
to eGo powerflow generator table.
"""

__copyright__ 	= "ZNES Flensburg"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 		= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 		= "wolfbunke"

import pandas as pd

from dataprocessing.tools.io import oedb_session
from sqlalchemy.orm import sessionmaker
from ego_dp_powerflow_timeseries_generator_helper import OBJ_LABEL_TO_SOURCE, SCENARIOMAP, \
    TEMPID, NEIGHBOURSID, _flatten, map_on_partial_string, missing_orm_classes
from egoio.db_tables.model_draft import EgoSupplyPfGeneratorSingle as Generator, \
    EgoGridHvElectricalNeighboursBus as Neighbour

conn = oedb_session(section='test')
Session = sessionmaker(bind=conn)
session = Session()

# obligatory delete statement based on NEIGHBOURSID
session.query(Generator).filter(Generator.generator_id >= NEIGHBOURSID).\
    delete(synchronize_session='fetch')

###############################################################################

*_, Transformer, Source, Results = missing_orm_classes(session)

# get DataFrame each row representing one electrical neighbour by applying
# filter on id and v_nom, not affected by scenario name
query = session.query(Neighbour)
neighbours = pd.read_sql(query.statement, query.session.bind)

ix = (neighbours['id'] <= 27) & (neighbours['v_nom'] == 380)
neighbours = neighbours.loc[ix, :]
neighbours.set_index('cntr_id', inplace=True)

# for each scenario
for scn_name, scn_nr in SCENARIOMAP.items():

    # get renpass_gis scenario data on linear transformers. Parameters are
    # defined on those edges directed from the component to the bus.
    filters = [Transformer.scenario_id == scn_nr,
               ~Transformer.source.like('%powerline%'),
               Transformer.label == Transformer.source]  # direction

    query = session.query(Transformer).filter(*filters)
    transformers = pd.read_sql(query.statement, query.session.bind)
    transformers['type'] = 'linear transformer'

    # get data on sources
    filters = [Source.scenario_id == scn_nr, ~Source.label.like('GL%')]
    query = session.query(Source).filter(*filters)
    sources = pd.read_sql(query.statement, query.session.bind)
    sources['type'] = 'source'

    # sources and transformers, distinct in renpass_gis, are both seen as
    # generators and can be handled together
    generators = pd.concat([sources, transformers], ignore_index=True)

    # parameters in renpass_gis are not necessarily scalars and stored in lists
    # lists of len one are flattened
    generators = generators.applymap(_flatten)

    # 0 does not equal zero. In case a class with zero nominal value
    # should be defined for the purpose of scenario definition very small
    # values are used in the scenario files.
    ix = generators['nominal_value'] < 1e-7
    generators = generators.loc[~ix, :]

    # source in the context of eGo has a different meaning. The column has to
    # be renamed
    generators.rename(columns={'source': 'renpass_gis_source'}, inplace=True)

    # map from obj label string -> source
    generators['source'] = map_on_partial_string(
        generators['label'], {i: k for k, i in OBJ_LABEL_TO_SOURCE.items()})

    generators['cntr_id'] = generators['label'].str[:2]

    # exclude Germany
    generators = generators.loc[generators['cntr_id'] != 'DE', :]

    # exclude unmatched sources
    generators = generators.loc[~generators['source'].isnull(), :]

    # assign bus_ids according to neighbours DataFrame
    generators['bus'] = generators['cntr_id'].map(neighbours['bus_id'])

    # set control, and dispatch parameter
    generators['control'] = 'PV'
    generators['dispatch'] = generators['type'].map(
        {'linear transformer': 'flexible', 'source': 'variable'})

    # set scenario name, temporal id
    generators['scn_name'] = scn_name
    generators['temp_id'] = TEMPID
    generators['generator_id'] = generators.index + NEIGHBOURSID

    # prepare DataFrames to be exported
    generator_ex = generators[
        ['scn_name', 'generator_id', 'bus', 'dispatch', 'control', 'source']]

    # write to db
    for i in generator_ex.to_dict(orient='records'):
        session.add(Generator(**i))

    session.commit()
