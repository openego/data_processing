"""
Assign German timeseries data from hidden renpassG!S schema to high voltage
powerflow.
"""

__copyright__ 	= "ZNES Flensburg"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 		= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 		= "wolfbunke"

import pandas as pd
import numpby as np

from dataprocessing.tools.io import oedb_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy import MetaData, func
from sqlalchemy.ext.automap import automap_base

from egoio.db_tables.model_draft import EgoSupplyPfGeneratorSingle as Generator,\
    EgoGridPfHvGeneratorPqSet as PqSet, EgoGridHvElectricalNeighboursBus


SCENARIOMAP = {'Status Quo': 43, 'NEP 2035': 41, 'eGo 100': 40}

SOURCE_TO_FUEL = {
    1: 'gas', 2: 'lignite', 3: 'mixed_fuels', 4: 'oil',
    5: 'uranium', 6: 'biomass', 8: 'hard_coal', 9: 'run_of_river', 12: 'solar',
    13: 'wind', 14: 'geothermal', 15: 'other_non_renewable', 94: 'storage',
    95: 'load', 96: 'waste', 97: 'reservoir', 98: 'shortage', 99: 'excess'}

TEMPID = 1

# get database connection
conn = oedb_session(section='test')

Session = sessionmaker(bind=conn)
session = Session()

meta = MetaData()
meta.bind = conn
meta.reflect(bind=conn, schema='calc_renpass_gis',
             only=['renpass_gis_results'])

# map to classes
Base = automap_base(metadata=meta)
Base.prepare()

Results = Base.classes.renpass_gis_results

###############################################################################


def _norm(x):
    return x / x.sum()

# delete all from model_draft.ego_grid_pf_hv_generator_pq_set
session.query(PqSet).delete()
session.commit()

for scn_name, scn_nr in SCENARIOMAP.items():

    # dataframe from model_draft.pf_generator_single
    # with aggr_id, source, p_nom
    filters = (Generator.scn_name == scn_name, Generator.aggr_id != None)
    fields = [Generator.aggr_id, Generator.source,
              func.sum(Generator.p_nom).label('summed_p_nom')]
    grouper = Generator.aggr_id, Generator.source
    query = session.query(*fields).filter(*filters).group_by(*grouper)

    generators = pd.read_sql(query.statement, query.session.bind)

    # create fraction of nominal power to total nominal power for each source
    generators['fraction_of_total_p_nom'] = \
        generators.groupby('source')['summed_p_nom'].apply(_norm)

    # dataframe from calc_renpass_gis.renpass_gis_results
    # optimization results to buses
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
