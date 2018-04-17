"""
Assign German timeseries data from hidden renpassG!S schema to high voltage
powerflow.
"""

__copyright__ 	= "ZNES Flensburg"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 		= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 		= "wolfbunke"

import pandas as pd
import numpy as np

from dataprocessing.tools.io import oedb_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy import MetaData, func
from ego_dp_powerflow_timeseries_generator_helper import OBJ_LABEL_TO_SOURCE, SCENARIOMAP, \
    TEMPID, NEIGHBOURSID, _flatten, map_on_partial_string, renpass_gis_orm_classes
from egoio.db_tables.model_draft import EgoSupplyPfGeneratorSingle as Generator, \
    EgoGridPfHvGeneratorPqSet as PqSet, EgoGridHvElectricalNeighboursBus as Neighbour

conn = oedb_session(section='test')
Session = sessionmaker(bind=conn)
session = Session()

# obligatory delete statement based on NEIGHBOURSID
session.query(Generator).filter(Generator.generator_id >= NEIGHBOURSID).\
    delete(synchronize_session='fetch')

session.query(PqSet).filter(PqSet.generator_id >= NEIGHBOURSID).\
    delete(synchronize_session='fetch')


###############################################################################

Transformer, Source, Results = renpass_gis_orm_classes(session)

# get DataFrame each row representing one electrical neighbour by applying
# filter on id and v_nom, not affected by scenario name
query = session.query(Neighbour)
neighbours = pd.read_sql(query.statement, query.session.bind)

ix = (neighbours['id'] <= 27) & (neighbours['v_nom'] == 380)
neighbours = neighbours.loc[ix, :]
neighbours.set_index('cntr_id', inplace=True)


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
    # should be defined for the purpose of scenario definition very small values
    # are used in the scenario files.
    ix = generators['nominal_value'] < 1e-7
    generators = generators.loc[~ix, :]

    # source in the context of eGo has a different meaning. The column has to
    # be renamed
    generators.rename(columns={'source': 'renpass_gis_source'}, inplace=True)

    # map from obj label string -> source
    generators['source'] = map_on_partial_string(
        generators['label'], OBJ_LABEL_TO_SOURCE)

    generators['cntr_id'] = generators['label'].str[:2]

    # exclude Germany
    generators = generators.loc[generators['cntr_id'] != 'DE', :]

    # assign bus_ids according to neighbours DataFrame
    generators['bus'] = generators['cntr_id'].map(neighbours['bus_id'])

    # set control, and dispatch parameter
    generators['control'] = 'PV'
    generators['dispatch'] = generators['type'].map(
        {'linear transformer': 'flexible', 'source': 'variable'})

    # get corresponding optimization results from renpass_gis
    # obj_label, datetime, val
    filters = (~Results.obj_label.like('%DE%'),
               ~Results.obj_label.like('%GL%'),
               ~Results.obj_label.like('%powerline%'),
               Results.type == 'to_bus',
               Results.scenario_id == scn_nr)
    fields = Results.obj_label, Results.datetime, Results.val
    query = session.query(*fields).filter(*filters)
    results = pd.read_sql(query.statement, query.session.bind)

    # map from obj label string -> source
    results['source'] = map_on_partial_string(
        results['obj_label'], OBJ_LABEL_TO_SOURCE).astype(int)

    results['cntr_id'] = results['obj_label'].str[:2]
    results['bus'] = results['cntr_id'].map(neighbours['bus_id'])

    # create Series with bus_id, source and power generation / actual value
    # in list format
    results_s = results.groupby(['bus', 'source'])['val'].apply(np.array)
    results_s.name = 'p_set'

    # check all arrays are of the same length
    assert all(len(i) == len(results_s[0]) for i in results_s)

    # include timeseries data in generators DataFrame
    generators = generators.join(results_s, on=['bus', 'source'])

    # set scenario name, temporal id
    generators['scn_name'] = scn_name
    generators['temp_id'] = TEMPID

    generators['generator_id'] = generators.index + NEIGHBOURSID

    # prepare DataFrames to be exported
    generator_ex = generators[['scn_name', 'generator_id', 'bus', 'dispatch', 'control']]
    pqsets = generators[['scn_name', 'generator_id', 'temp_id', 'p_set']]

    # write to db
    for i in generator_ex.to_dict(orient='records'):
        session.add(Generator(**i))

    for i in pqsets.to_dict(orient='records'):
        session.add(PqSet(**i))

    session.commit()
