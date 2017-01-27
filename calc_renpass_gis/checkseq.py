""" checkseq

Usage:
  checkseq.py SEQ_DATA LABEL
  checkseq.py -h | --help

Examples:

  python3 checkseq.py path/to/scenario-seq.csv solar

Arguments:

  SEQ_DATA                   CSV-file with data for sequences.
  LABEL                      Label to search for in components.

Options:

  -h --help                  Show this screen and exit

"""

import pandas as pd
from docopt import docopt


def read_csv(**kwargs):
    """ Read and handle CSV-file.

    Parameters
    ----------
    **kwargs : key word arguments
        Arguments passed from command line

    Returns
    -------
    df : pd.DataFrame
        DataFrame with data for sequences.

    """

    df = pd.read_csv(kwargs['SEQ_DATA'], header=[1, 2, 3, 4], sep=',')
    df.dropna(axis=0, how='all', inplace=True)
    df.sort_index(inplace=True)
    df.drop('label', axis=1, inplace=True)
    df = df.astype(float)
    df.columns.names = ['label', 'source', 'target', 'value']
    return df


def main(**arguments):

    print("Reading CSV-file %s" % arguments['SEQ_DATA'])
    df = read_csv(**arguments)

    # select for label
    idx = df.columns.get_level_values('label').str.contains(arguments['LABEL'])
    df = df.loc[:, idx]

    print("\n\nMaximum value in each sequence with %s." % arguments['LABEL'])
    print("------------------------------------------------------")
    print(df.max())

    print("\n\nSummed up each sequence representing full-loadhours.")
    print("------------------------------------------------------")
    print(df.sum())

    print("Done.")

if __name__ == '__main__':
    arguments = docopt(__doc__)
    main(**arguments)
