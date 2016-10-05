from db import Scenario
from db import session
import pandas as pd


def arraytofloat(x):
    if isinstance(x, list) and len(x) == 1:
        return x[0]
    else:
        return x

path = '/home/martin/renpass_gis/scenarios/'


scenario_id = 1
scenario = session.query(Scenario).filter(Scenario.id == scenario_id).all()[0]


li = scenario.renpass_gis_storage_collection +\
    scenario.renpass_gis_source_collection +\
    scenario.renpass_gis_sink_collection


nodes_flows = []
for i in li:
    flow = vars(i)
    flow['class'] = i.__table__.name
    nodes_flows.append(flow)

nodes_flows = pd.DataFrame(nodes_flows)
nodes_flows = nodes_flows.applymap(arraytofloat)
nodes_flows['class'].replace({'renpass_gis_storage': 'Storage',
                              'renpass_gis_linear_transformer':
                              'LinearTransformer',
                              'renpass_gis_sink': 'Sink',
                              'renpass_gis_source': 'Source'}, inplace=True)

nodes_flows.drop('_sa_instance_state', 1, inplace=True)

nodes_flows_seq = pd.DataFrame()

dc = {}
for idx, row in nodes_flows.iterrows():
    for k, v in row.items():
        if isinstance(v, list) and len(v) > 1:
            nodes_flows.loc[idx, k] = 'seq'
            index = (row['class'], row['label'], row['source'], row['target'])
            dc[index] = v

nodes_flows_seq = pd.DataFrame(dc)

nodes_flows.set_index(['class', 'label', 'source', 'target'], inplace=True)
nodes_flows.to_csv(path + scenario.name + '_TEST.csv')
nodes_flows_seq.to_csv(path + scenario.name + '_seq_TEST.csv')
