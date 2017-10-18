from oemof.db import connection
from egoio.db_tables.model_draft import Base
from sqlalchemy.orm import sessionmaker

conn = connection(section='local')
session = sessionmaker(bind=conn)()

tables = ['model_draft.ego_grid_pf_hv_scenario_settings',
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

for t in tables[:1]:
    tab = Base.metadata.tables[t]
    tab.drop(conn.engine)
