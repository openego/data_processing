""" Helper functions and variables to handle renpass_gis tables.
"""

__copyright__ 	= "ZNES Flensburg"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 		= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 		= "wolfbunke"

import pandas as pd

from dataprocessing.tools.io import oedb_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy import MetaData
from sqlalchemy.ext.automap import automap_base

NEIGHBOURSID = 200000

SCENARIOMAP = {'Status Quo': 43, 'NEP 2035': 41, 'eGo 100': 40}

SOURCE_TO_FUEL = {
    1: 'gas', 2: 'lignite', 3: 'mixed_fuels', 4: 'oil',
    5: 'uranium', 6: 'biomass', 8: 'hard_coal', 9: 'run_of_river', 10: 'reservoir',
    12: 'solar', 13: 'wind_onshore', 14: 'geothermal', 15: 'other_non_renewable',
    16: 'wind_offshore', 94: 'storage', 95: 'load', 96: 'waste',
    97: 'reservoir', 98: 'shortage', 99: 'excess'}

TEMPID = 1

def renpass_gis_orm_classes(session):
    """
    Parameters
    ----------
    session : sqlalchemy.orm.session.Session
        Handling all conversations with the database

    Notes
    -----
    Relations in schema calc_renpass_gis are still not part of egoio. If this is
    changed in the future this function becomes obsolete.
    """

    meta = MetaData()
    meta.reflect(bind=session.bind, schema='calc_renpass_gis',
                only=['renpass_gis_linear_transformer',
                      'renpass_gis_source',
                      'renpass_gis_results'])

    # map to classes
    Base = automap_base(metadata=meta)
    Base.prepare()

    Transformer, Source, Results = Base.classes.renpass_gis_linear_transformer, \
        Base.classes.renpass_gis_source, Base.classes.renpass_gis_results

    return Transformer, Source, Results

def _flatten(x):
    if isinstance(x, list):
        return x[0] if len(x) == 1 else x
    else:
        return x


def map_on_partial_string(series, mapping):
    """ Map mapping values to string series.  """
    s = pd.Series(index=series.index)
    for k, v in mapping.items():
        ix = series.str.contains(v)
        s[ix] = k
    return s
