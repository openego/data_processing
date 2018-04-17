""" This script assign optimized dispatch timeseries data based on renpassG!S
results to high-voltage powerflow generators.
"""

__copyright__ = "ZNES Flensburg"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

import pandas as pd
import numpy as np
import logging

from dataprocessing.tools.io import oedb_session
from dataprocessing.python_scripts.functions.ego_scenario_log import write_ego_scenario_log
from sqlalchemy.orm import sessionmaker

from egoio.db_tables.model_draft import EgoGridPfHvGenerator as Generator, \
    EgoGridPfHvGeneratorPqSet as PqSet
from ego_dp_powerflow_timeseries_generator_helper import OBJ_LABEL_TO_SOURCE, SCENARIOMAP, \
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

# Assigning p_set for each scenario
logged = 0
for scn_name, scn_nr in SCENARIOMAP.items():

    # model_draft.ego_grid_pf_hv_generator -> pd.DataFrame
    query = session.query(Generator).filter(Generator.scn_name == scn_name)
    generators = pd.read_sql(query.statement, query.session.bind)

    assert set(generators['source'].isnull()) == {False}, "Source field empty in generators table."

    # create fraction of nominal power to total nominal power for each source
    generators['p_nom_fraction'] = generators.groupby('source')['p_nom'].\
        apply(_norm)

    # calc_renpass_gis.renpass_gis_results -> pd.DataFrame
    # contains inflows to buses in Germany excluding powerlines
    filters = (Results.obj_label.like('%DE%'),
               ~Results.obj_label.like('%powerline%'),
               Results.type == 'to_bus',
               Results.scenario_id == scn_nr)
    fields = Results.obj_label, Results.datetime, Results.val
    query = session.query(*fields).filter(*filters)

    results = pd.read_sql(query.statement, query.session.bind)

    # map obj_label to corresponding source
    results['source'] = None
    for k, v in OBJ_LABEL_TO_SOURCE.items():
        idx = results['obj_label'].str.contains(k)
        results.loc[idx, 'source'] = v

    # aggregate by source and datetime
    # in this step generation from mixed fuels and waste is summed up
    # assuming these sources have identical input parameters
    results = results.groupby(['source', 'datetime'], as_index=False).sum()

    # timeseries for each component in list format
    # contains excess, shortage, load, mixed fuels
    results_s = results.groupby('source')['val'].apply(np.array)

    # map corresponding timeseries with each generator multiplied by fraction
    # of nominal power
    generators['p_set'] = generators['source'].map(results_s) * \
        generators['p_nom_fraction']

    # https://github.com/znes/FlEnS/issues/3
    # inform the user about possible discrepancies
    # dataprocessing has no logging
    #for i, k in OBJ_LABEL_TO_SOURCE.items():
    #    if k not in generators['source'].values:
    #        logging.info("%s: %s: Object label %s is not matched in powerflow." % (
    #            __file__, scn_name, i))

    #for k in generators.source.unique():
    #    if k not in results_s.index:
    #        logging.info("%s: %s: Source %s is not matched in renpass_gis." % (
    #            __file__, scn_name, int(k)))

    # test for missing values for debugging
    assert set(generators['p_set'].isnull()) == {False}, "P_set field empty in generators table."

    # OR just get rid of generators with missing p_set
    generators = generators[~generators['p_set'].isnull()].copy()

    # remove solar and wind
    sources = [v for k, v in OBJ_LABEL_TO_SOURCE.items() if k in
               ['wind_offshore', 'wind_onshore', 'solar']]

    ix = generators['source'].isin(sources)
    generators = generators[~ix].copy()

    generators['temp_id'] = TEMPID
    fields = ['generator_id', 'p_set', 'scn_name', 'temp_id']
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
