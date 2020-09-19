===============
The open_eGo data processing
===============

This package contains the scripts of the data processing for the research project
`open_eGo <https://openegoproject.wordpress.com>`_.
More information about the project in :ref:`Open_eGo the project`.
An overview on data processing steps is given in :ref:`Data processing scripts`.

Installation
============

Installation of latest release

```
pip install dataprocessing
```

Installation (of developer version) via pip on linux systems as follows

```
sudo pip3 install -e <path-to-data_processing-repo>
```

Troubleshooting

On Windows
***********

1. __Problem__: Installation of required package shapely fails. __Solution__: Install pre-build
 wheel from `here <http://www.lfd.uci.edu/~gohlke/pythonlibs/#shapely>`_.


Run
====

You can run data processing by calling command-line script

```
~$ ego_data_processing
```
