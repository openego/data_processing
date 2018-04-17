""" Assigns dispatch optimization results from renpassG!S to corresponding
hv powerflow generators for neighbouring countries
"""

__copyright__ 	= "ZNES Flensburg"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 		= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 		= "wolfbunke"

import pandas as pd
import numpy as np

from dataprocessing.tools.io import oedb_session
from sqlalchemy.orm import sessionmaker
from dataprocessing.python_scripts.functions.ego_scenario_log import write_ego_scenario_log
from ego_dp_powerflow_timeseries_generator_helper import OBJ_LABEL_TO_SOURCE, SCENARIOMAP, \
    TEMPID, NEIGHBOURSID, map_on_partial_string, missing_orm_classes
from egoio.db_tables.model_draft import EgoGridPfHvGenerator as Generator, \
    EgoGridPfHvGeneratorPqSet as PqSet, EgoGridHvElectricalNeighboursBus as Neighbour

conn = oedb_session(section='test')
Session = sessionmaker(bind=conn)
session = Session()

# obligatory delete statement based on NEIGHBOURSID
session.query(PqSet).filter(PqSet.generator_id >= NEIGHBOURSID).\
    delete(synchronize_session='fetch')


###############################################################################

PowerClass, Feedin, *_, Results = missing_orm_classes(session)

# get DataFrame each row representing one electrical neighbour by applying
# filter on id and v_nom, not affected by scenario name
query = session.query(Neighbour)
neighbours = pd.read_sql(query.statement, query.session.bind)

ix = (neighbours['id'] <= 27) & (neighbours['v_nom'] == 380)
neighbours = neighbours.loc[ix, :]
neighbours.set_index('cntr_id', inplace=True)

logged = 0
for scn_name, scn_nr in SCENARIOMAP.items():

    # model_draft.ego_grid_pf_hv_generator -> pd.DataFrame
    query = session.query(Generator).filter(
        Generator.scn_name == scn_name, Generator.generator_id >= NEIGHBOURSID)
    generators = pd.read_sql(query.statement, query.session.bind)

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
        results['obj_label'],
        {k: i for i, k in OBJ_LABEL_TO_SOURCE.items()})

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

    pqsets = generators[['scn_name', 'generator_id', 'temp_id', 'p_set']]

    # export to db
    for i in pqsets.to_dict(orient='records'):
        session.add(PqSet(**i))

    session.commit()

    logged += len(pqsets)

write_ego_scenario_log(conn=conn,
                       version='v0.4.0',
                       io='input',
                       schema='model_draft',
                       table=PqSet.__tablename__,
                       script=__file__,
                       entries=logged)
