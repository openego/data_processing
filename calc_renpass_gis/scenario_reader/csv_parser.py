from db import LinearTransformer, Source, Sink, Scenario, Storage, session
import pandas as pd


def asfloat(x):
    try:
        # do not convert boolean
        return float(x) if not isinstance(x, bool) else x
    except ValueError:
        return x

# path to scenario
path = '~/oemof/examples/solph/nodes_from_csv/scenarios/'

file_nodes_flows = 'nep_2014.csv'
file_nodes_flows_sequences = 'nep_2014_seq.csv'

delimiter = ','

# read in csv files
nodes_flows = pd.read_csv(path + file_nodes_flows, sep=delimiter)
nodes_flows_seq = pd.read_csv(path + file_nodes_flows_sequences, sep=delimiter,
                              header=None)
nodes_flows_seq.dropna(axis=0, how='all', inplace=True)
nodes_flows_seq.drop(0, axis=1, inplace=True)
nodes_flows_seq = nodes_flows_seq.transpose()
nodes_flows_seq.set_index([0, 1, 2, 3, 4], inplace=True)
nodes_flows_seq.columns = range(0, len(nodes_flows_seq.columns))
nodes_flows_seq = nodes_flows_seq.astype(float)

# create new scenario
scenario_name = 'nep_2014'

sc = Scenario(name=scenario_name)
session.add(sc)
session.commit()

# dictionary with all mapped tables
dc = {'Source': Source, 'LinearTransformer': LinearTransformer,
      'Sink': Sink, 'Storage': Storage}

empty = []
for idx, series in nodes_flows.iterrows():

    # filter for empty rows
    series = series.dropna()

    try:

        obj = dc[series['class']]()

    except KeyError:
        empty.append(idx)
        continue

    # map table fields to keys of row series
    for col in obj.__table__.columns.keys():

        to_ignore = ['id', 'flow_direction']

        if col == 'scenario_id':
            setattr(obj, col, sc.id)
            continue

        if col not in to_ignore and col in series:

            prop = asfloat(series[col])

            if prop == 'seq':
                seq = nodes_flows_seq.loc[series['class'],
                                          series['label'],
                                          series['source'],
                                          series['target'],
                                          col]
                setattr(obj, col, list(seq))

            elif isinstance(prop, float):
                setattr(obj, col, [prop])

            else:
                setattr(obj, col, prop)

    session.add(obj)

print('Comment or empty row at index {li}.'.format(li=empty))

session.commit()
