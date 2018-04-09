""" Helper functions and variables to handle renpass_gis tables.
"""

__copyright__ 	= "ZNES Flensburg"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 		= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 		= "wolfbunke"

import pandas as pd

from dataprocessing.tools.io import oedb_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy import MetaData, Column, Integer, Float, Text, text
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.dialects.postgresql import ARRAY, DOUBLE_PRECISION


NEIGHBOURSID = 200000

SCENARIOMAP = {'Status Quo': 43, 'NEP 2035': 41, 'eGo 100': 40}

# list of available fuel types in eGo scenarios
OBJ_LABEL_TO_SOURCE = {
    'gas': 1,
    'lignite': 2,
    'waste': 3,
    'mixed_fuels': 3,
    'oil': 4,
    'uranium': 5,
    'biomass': 6,
    'chp': 7,  # is this correct?
    'hard_coal': 8,
    'run_of_river': 9,
    'reservoir': 10,
    'solar': 12,
    'wind_onshore': 13,
    'geothermal': 14,
    'wind_offshore': 17,
    'storage_redox_flow': 99,
    'storage_pumped_hydro': 99,
    'storage_lithium_ion': 99,
    'storage_hydrogen': 99,
    'storage_phs': 99,
    'storage_a_caes': 99,
    'load': 99,
    'shortage': 99,
    'excess': 99}

TEMPID = 1

def missing_orm_classes(session):
    """ Not yet implemented in ego.io

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

	# ormclasses not part of egoio yet
    class EgoPowerClass(Base):
        __tablename__ = 'ego_power_class'
        __table_args__ = {'schema': 'model_draft'}

        power_class_id = Column(Integer, primary_key=True, server_default=text("nextval('model_draft.ego_power_class_power_class_id_seq'::regclass)"))
        lower_limit = Column(Float(53))
        upper_limit = Column(Float(53))
        wea = Column(Text)
        h_hub = Column(Float(53))
        d_rotor = Column(Float(53))


    class EgoRenewableFeedin(Base):
        __tablename__ = 'ego_renewable_feedin'
        __table_args__ = {'schema': 'model_draft'}

        weather_scenario_id = Column(Integer, primary_key=True, nullable=False)
        w_id = Column(Integer, primary_key=True, nullable=False)
        source = Column(Text, primary_key=True, nullable=False)
        weather_year = Column(Integer, primary_key=True, nullable=False)
        power_class = Column(Integer, primary_key=True, nullable=False)
        feedin = Column(ARRAY(DOUBLE_PRECISION(precision=53)))

    Base.prepare()

    Transformer, Source, Results = Base.classes.renpass_gis_linear_transformer, \
        Base.classes.renpass_gis_source, Base.classes.renpass_gis_results

    return EgoPowerClass, EgoRenewableFeedin, Transformer, Source, Results


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
