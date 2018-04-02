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
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy import MetaData, func, and_, case
from sqlalchemy.ext.automap import automap_base

from egoio.db_tables.model_draft import EgoSupplyPfGeneratorSingle as Generator,\
    EgoGridPfHvGeneratorPqSet as PqSet, EgoGridHvElectricalNeighboursBus

from ego_dp_powerflow_timeseries_generator_helper import SOURCE_TO_FUEL, SCENARIOMAP, \
    TEMPID, missing_orm_classes

# get database connection
conn = oedb_session(section='test')
Session = sessionmaker(bind=conn)
session = Session()

PowerClass, Feedin, *_, Results = missing_orm_classes(session)


###############################################################################


def _norm(x):
    return x / x.sum()

# delete all from model_draft.ego_grid_pf_hv_generator_pq_set
session.query(PqSet).delete()
session.commit()

# p_set
for scn_name, scn_nr in SCENARIOMAP.items():

    # dataframe from model_draft.pf_generator_single
    # with aggr_id, source, p_nom
    filters = (Generator.scn_name == scn_name, Generator.aggr_id != None)  # comma seperated in fiter() are internally joined using and_
    fields = [Generator.aggr_id, Generator.source,
              func.sum(Generator.p_nom).label('summed_p_nom')]
    grouper = Generator.aggr_id, Generator.source,
    query = session.query(*fields).filter(*filters).group_by(*grouper)

    generators = pd.read_sql(query.statement, query.session.bind)

    # create fraction of nominal power to total nominal power for each source
    generators['fraction_of_total_p_nom'] = \
        generators.groupby('source')['summed_p_nom'].apply(_norm)

    # dataframe from calc_renpass_gis.renpass_gis_results
    # optimal dispacth results directed towards buses
    # with obj_label, datetime, val
    filters = (Results.obj_label.like('%DE%'),
               ~Results.obj_label.like('%powerline%'),
               Results.type == 'to_bus',
               Results.scenario_id == scn_nr)
    fields = Results.obj_label, Results.datetime, Results.val
    query = session.query(*fields).filter(*filters)

    results = pd.read_sql(query.statement, query.session.bind)

    # map obj_label to corresponding source
    results['source'] = None
    for k, v in SOURCE_TO_FUEL.items():
        idx = results['obj_label'].str.contains(v)
        results.loc[idx, 'source'] = k

    # aggregate by source and datetime
    results = results.groupby(['source', 'datetime'], as_index=False).sum()

    # power generation timeseries for each source in list format
    results_s = results.groupby('source')['val'].apply(np.array)

    # map corresponding timeseries with each generator multiplied by fraction
    # of nominal power
    generators['p_set'] = generators['source'].map(results_s) * \
        generators['fraction_of_total_p_nom']

    # generators without p_set
    ix = generators['p_set'].isnull()
    print('Generators with sources {} have no p_sets assigned!'.format(
        generators[ix]['source'].unique()))
    generators.loc[ix, 'p_set'] = None

    # add columns
    empty = ['q_set', 'p_min_pu', 'p_max_pu']

    pqsets = pd.concat(
        [generators[['aggr_id', 'p_set']],
         pd.DataFrame(columns=empty)])

    pqsets.loc[:, empty] = None

    # add scenario name and temporal id
    pqsets['scn_name'] = scn_name
    pqsets['temp_id'] = TEMPID

    # rename column aggr_id to generator_id
    pqsets.rename(columns={'aggr_id': 'generator_id'}, inplace=True)

    # write to db
    for i in pqsets.to_dict(orient='records'):
        session.add(PqSet(**i))
    session.commit()


# p_max_pu
for scn_name, scn_nr in SCENARIOMAP.items():


    sources = ['wind_onshore', 'wind_offshore', 'solar']
    sources_dict = {v:k for k, v in SOURCE_TO_FUEL.items() if v in sources}
    casestr = case(sources_dict, value=Feedin.source, else_=None)

    filters = (Generator.scn_name == scn_name, Generator.aggr_id != None)
    fields = [Generator.aggr_id, Generator.source, Generator.w_id, Generator.power_class,
              func.sum(Generator.p_nom).label('summed_p_nom')]
    grouper = Generator.aggr_id, Generator.source, Generator.w_id, Generator.power_class

    t = session.query(*fields).group_by(*grouper).filter(*filters).subquery()

    query = session.query(t, Feedin.feedin).filter(t.c.w_id == Feedin.w_id,
        t.c.power_class == Feedin.power_class, t.c.source == casestr)

    generators = pd.read_sql(query.statement, query.session.bind)

    def weighted_average_feedin(x):

        # 1darray weights for number of feedins
        weights = np.array(_norm(x['summed_p_nom']))

        # ndarray of shape (timesteps, number of feedins)
        feedins = np.array(x['feedin'].tolist()).T

        # ndarray of shape (timesteps, number of feedins)
        weighted_feedins = np.multiply(weights, feedins)

        # return averaged feedin
        return np.sum(weighted_feedins, axis=1)

    p_max_pu = generators.groupby(['aggr_id', 'source'], as_index=False).\
        apply(weighted_average_feedin)
