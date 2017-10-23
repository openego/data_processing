""" This script creates the initial HV powerflow
"""

__copyright__ = "ZNES Flensburg"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = ""


import os, json, csv
from oemof.db import connection
from oemof.db.tools import change_owner_to, grant_db_access
from dataprocessing.tools.io import load_external_file
from egoio.db_tables.model_draft import Base, EgoGridPfHvSource
from sqlalchemy.orm import sessionmaker
from sqlalchemy.schema import DropTable
from sqlalchemy.ext.compiler import compiles

# Adapt SQL-Alchemy's postgresql dialect to include the CASCADE statement on
# DROP TABLE as described here:
# https://stackoverflow.com/questions/38678336/sqlalchemy-how-to-implement-drop-table-cascade
@compiles(DropTable, "postgresql")
def _compile_drop_table(element, compiler, **kwargs):
    return compiler.visit_drop_table(element) + " CASCADE"

# TODO Maybe use context manager for path manipulation
# https://stackoverflow.com/questions/431684/how-do-i-cd-in-python/13197763#13197763
conn = connection(section='local')
session = sessionmaker(bind=conn)()
engine = conn.engine
cwd = os.getcwd()
dirname = "/home/martin/open_eGo/data_processing/dataprocessing/python_scripts"
# wdir = os.path.dirname(__file__)
os.chdir(dirname)

###############################################################################
tablenames = ['model_draft.ego_grid_pf_hv_scenario_settings',
              'model_draft.ego_grid_pf_hv_source',
              'model_draft.ego_grid_pf_hv_bus',
              'model_draft.ego_grid_pf_hv_busmap',
              'model_draft.ego_grid_pf_hv_generator',
              'model_draft.ego_grid_pf_hv_line',
              'model_draft.ego_grid_pf_hv_load',
              'model_draft.ego_grid_pf_hv_storage',
              'model_draft.ego_grid_pf_hv_temp_resolution',
              'model_draft.ego_grid_pf_hv_transformer',
              'model_draft.ego_grid_pf_hv_bus_v_mag_set',
              'model_draft.ego_grid_pf_hv_generator_pq_set',
              'model_draft.ego_grid_pf_hv_load_pq_set',
              'model_draft.ego_grid_pf_hv_storage_pq_set']

for name in tablenames:
    # retrieve the Table object corresponding to the table name from ego.io
    # Base
    sqla_table = Base.metadata.tables[name]

    # drop the Table in the database
    sqla_table.drop(engine, checkfirst=True)

    # assign a comment from the comments subdirectory
    sqla_table.comment = str(load_external_file(fname=name + '.json',
                                                dpath='../comments/'))

    # recreate the Table in the database
    sqla_table.create(engine)

    # set ownership and permissions to oeuser
    schema, tablename_without_schema = name.split('.')

    change_owner_to(table=tablename_without_schema,
                    schema=schema,
                    conn=conn,
                    role='oeuser')

    grant_db_access(table=tablename_without_schema,
                    schema=schema,
                    conn=conn,
                    role='oeuser')

# Populate model_draft.ego_grid_pf_hv_source with sources
name = 'model_draft.ego_grid_pf_hv_source.csv'
for d in load_external_file(fname=name, dpath='../data/'):
    session.add(EgoGridPfHvSource(**d))
session.commit()
