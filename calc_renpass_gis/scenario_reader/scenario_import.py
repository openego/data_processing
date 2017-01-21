#!/bin/python
""" scenario_import

Usage:
  scenario_import.py [options] NODE_DATA SEQ_DATA RESULTS_DATA
  scenario_import.py -h | --help

Examples:

  python scenario_import.py -p open_eGo -c 'Increased net transfer capacity NO'
    path/to/scenario.csv path/to/scenario-seq.csv path/to/results.csv

Arguments:

  NODE_DATA                  CSV-file containing data for nodes and flows.
  SEQ_DATA                   CSV-file with data for sequences.
  RESULTS_DATA               CSV-file containing results.

Options:

  -h --help                  Show this screen and exit.
  -n --name=NAME             Name of the scenario. [default: '']
  -p --project=PROJECT       Name of the related project. [default: open_eGo]
  -c --comment=COMMENT       Provide a comment. [default: '']
  -v --version=VERSION       Provide the version of renpass_gis.
                             [default: v0.1]
     --repository            If NODE_DATA is under git version control the
                             repository name and current commit is added.
     --sep=SEP               Delimiter used in CSV-files. [default: ,]

Notes:

    For DB connectivity a configuration file ~.open_eGo/config.ini containing
    the following section is needed.

    [oedb]
    username =
    password =
    host =
    port =

"""
import subprocess
import pandas as pd
from docopt import docopt
from pathlib import Path
from subprocess import CalledProcessError


def asfloat(x):
    try:
        # do not convert a boolean
        return float(x) if not isinstance(x, bool) else x
    except ValueError:
        return x


def read_input(**kwargs):
    """ Read CSV-files

    Parameters
    ----------
    **kwargs : key word arguments
        Arguments passed from command line

    Returns
    -------
    nodes_flows : DataFrame
        Containing data for nodes and flows.
    nodes_flows_seq: DataFrame
        Data for sequences.
    """

    nodes_flows = pd.read_csv(kwargs['NODE_DATA'], sep=kwargs['--sep'])
    nodes_flows_seq = pd.read_csv(kwargs['SEQ_DATA'],
                                  sep=kwargs['--sep'],
                                  header=None)
    nodes_flows_seq.dropna(axis=0, how='all', inplace=True)
    nodes_flows_seq.drop(0, axis=1, inplace=True)
    nodes_flows_seq = nodes_flows_seq.transpose()
    nodes_flows_seq.set_index([0, 1, 2, 3, 4], inplace=True)
    nodes_flows_seq.columns = range(0, len(nodes_flows_seq.columns))
    nodes_flows_seq = nodes_flows_seq.astype(float)

    return nodes_flows, nodes_flows_seq


def check_git(**kwargs):
    """ Extract git information

    Parameters
    ----------
    **kwargs : key word arguments
        Arguments passed from command line

    Returns
    -------
    whichrepo : str
        Name of the git repository.
    commit : str
        short git commit hash

    Raises
    ------
    CalledProcessError
        Parent directory no git repository

    Note
    ----
    Update global arguments with name of the repository and commit hash.

    """

    global arguments

    pardir = str(Path(kwargs['NODE_DATA']).parent)

    try:

        args = "basename `git rev-parse --show-toplevel`"
        output = subprocess.check_output(args, shell=True, cwd=pardir)
        arguments.update({'whichrepo': str(output, 'utf-8').rstrip()})

        args = ['git', 'rev-parse', '--short', 'HEAD']
        output = subprocess.check_output(args, cwd=pardir)
        arguments.update({'commit': str(output, 'utf-8').rstrip()})

    except CalledProcessError:
        print('"%s" seems not to be a git repository!' % pardir)


def write_info(**kwargs):
    """ Write key information about the scenario to the DB.

    Parameters
    ----------
    **kwargs : key word arguments
        Arguments passed from command line

    Note
    ----
    Update global dictionary with key 'id' (scenario_id) value as returned by
    DB.

    """

    global arguments

    whichrepo = arguments.get('whichrepo', '')
    commit = arguments.get('commit', '')

    scenario = Scenario(name=kwargs['--name'],
                        project=kwargs['--project'],
                        repository=whichrepo,
                        commit=commit,
                        compatibility=kwargs['--version'],
                        comment=kwargs['--comment'])
    session.add(scenario)
    session.commit()

    arguments.update({'id': scenario.id})


def write_data(nodes_flows, nodes_flows_seq, **kwargs):
    """ Write scenario data to the DB.

    Parameters
    ----------
    nodes_flows : pandas.DataFrame
        DataFrame with data for nodes and corresponding flows
    nodes_flows_seq : pandas.DataFrame
        DataFrame with sequence data for nodes/flows
    **kwargs : key word arguments
        Arguments passed from command line
    """

    global arguments

    # dictionary with all mapped tables
    class_dict = {'Source': Source, 'LinearTransformer': LinearTransformer,
                  'Sink': Sink, 'Storage': Storage}

    empty = []
    for idx, series in nodes_flows.iterrows():

        # filter for empty rows
        series = series.dropna()

        try:

            obj = class_dict[series['class']]()

        except KeyError:
            empty.append(idx)
            continue

        # map table fields to keys of row series
        for col in obj.__table__.columns.keys():

            ignore = ['id']

            if col == 'scenario_id':
                setattr(obj, col, arguments['id'])
                continue

            if col not in ignore and col in series:

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

    for l in empty:
        print('Comment or empty row at index %s.' % l)

    session.commit()


def write_results(**kwargs):
    """ Write results file to DB.

    Parameters
    ----------
    **kwargs : key word arguments
        Arguments passed from command line

    Note
    ----
    For higher performance a single insert statement is created.
    Faster than using SQLA ORM and SQLA CORE as described here:

    http://www.devx.com/dbzone/optimize-inserts-using-sqlalchemy.html
    """

    global arguments

    # read csv, add scenario_id
    df = pd.read_csv(kwargs['RESULTS_DATA'])
    df.columns = [c.lower() for c in df.columns]
    df.insert(0, 'scenario_id', arguments['id'])

    # single quotes around string cols necessary for query statement
    cols = ['datetime', 'bus_label', 'type', 'obj_label']
    df[cols] = df[cols].applymap(lambda x: "'" + x + "'")

    # best solution performance wise, a single insert statement is created
    records = [tuple(x) for x in df.values]

    records = ",".join("(" + ",".join(str(i) for i in r) + ")" for
                       r in records)

    target = Results.__table__.schema + '.' + Results.__table__.name

    head = ("INSERT INTO " + target + " (scenario_id,"
            " bus_label, type, obj_label, datetime, val) VALUES ")

    # export to db
    conn.execute(head + records)

def main(**arguments):

    nodes_flows, nodes_flows_seq = read_input(**arguments)

    if arguments['--repository']:
        check_git(**arguments)

    print('Writing scenario entry.')
    write_info(**arguments)

    print('Writing scenario data.')
    write_data(nodes_flows=nodes_flows,
               nodes_flows_seq=nodes_flows_seq,
               **arguments)

    print('Writing results to db.')
    write_results(**arguments)


if __name__ == '__main__':
    arguments = docopt(__doc__, version='scenario_import.py v0.1')
    print('Start!')
    from db import (LinearTransformer, Source, Sink, Scenario, Storage,
                    session, Results, conn)
    main(**arguments)
    print('Done!!!')
