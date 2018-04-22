""" This script assigns solar and wind_onshore data generated with feedinlib
as p_max_pu parameter to high-voltage powerflow generators for neighbouring
countries.
"""
__copyright__ = "ZNES Flensburg"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"

import pandas as pd

from dataprocessing.tools.io import oedb_session
from sqlalchemy.orm import sessionmaker
from sqlalchemy import case, func
from dataprocessing.python_scripts.functions.ego_scenario_log \
    import write_ego_scenario_log

from egoio.db_tables.climate import Cosmoclmgrid
from egoio.db_tables.model_draft import \
    EgoSupplyPfGeneratorSingle as GeneratorSingle,
    EgoGridPfHvGeneratorPqSet as PqSet, \
    EgoGridPfHvGenerator as Generator, \
    EgoGridPfHvGeneratorPqSet as PqSet, \
    EgoGridHvElectricalNeighboursBus as Neighbour
from ego_dp_powerflow_timeseries_generator_helper import OBJ_LABEL_TO_SOURCE, SCENARIOMAP, \
    TEMPID, missing_orm_classes

# There is no need for a scenario loop. This can be done in one operation.

# Get database connection
conn = oedb_session(section='test')
Session = sessionmaker(bind=conn)
session = Session()

_, PowerClass, Feedin, *_, Results = missing_orm_classes(session)

# Read in a DataFrame with data of neighbouring countries
# Filtered on id, v_nom
query = session.query(Neighbour)
neighbours = pd.read_sql(query.statement, query.session.bind)

ix = (neighbours['id'] <= 27) & (neighbours['v_nom'] == 380)
neighbours = neighbours.loc[ix, :]
neighbours.set_index('cntr_id', inplace=True)

# logging variable
logged = 0

# Construct a subquery with w_id, bus_id based on intersecting geometries
t = session.query(Cosmoclmgrid.gid.label('w_id'), Neighbour.bus_id).filter(
    func.ST_Intersects(Cosmoclmgrid.geom, Neighbour.geom)).subquery()

# Make a mapping from source_id to source name
sources = ['wind_onshore', 'solar']
sources_dict = {v: k for k, v in OBJ_LABEL_TO_SOURCE.items() if k in sources}

# Wrap mapping case around Generator.source to retrieve source name
casestr = case(sources_dict, value=Generator.source, else_=None).label('source')

# Get generators and include w_id based on subquery, source name based on case
query = session.query(
    Generator.scn_name, Generator.generator_id, casestr, t.c.w_id).filter(
    Generator.bus.in_(neighbours.bus_id), t.c.bus_id == Generator.bus,
    Generator.source.in_(sources_dict))

generators = pd.read_sql(query.statement, query.session.bind)

# Get feedins and name timeseries p_max_pu
query = session.query(
    Feedin.w_id, Feedin.source, Feedin.feedin.label('p_max_pu')).filter(
        Feedin.w_id.in_(generators.w_id), Feedin.power_class.in_([0, 4]))
feedins = pd.read_sql(query.statement, query.session.bind)

# Merge DataFrames
# Assign p_max_pu to generator based on source, w_id
# This is many to one, because of multiple scenario values
generators = generators.merge(feedins, on=['source', 'w_id'], how='inner', validate='many_to_one')
generators['temp_id'] = TEMPID

# Construct PqSets and write to database
fields = ['generator_id', 'p_max_pu', 'scn_name', 'temp_id']
for i in generators[fields].to_dict(orient='records'):
    session.add(PqSet(**i))

logged += len(generators)

session.commit()

write_ego_scenario_log(conn=conn,
                        version='v0.4.0',
                        io='input',
                        schema='model_draft',
                        table=PqSet.__tablename__,
                        script=__file__,
                        entries=logged)
