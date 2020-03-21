.. image:: https://readthedocs.org/projects/data-processing/badge/?version=feature-readthedocs
    :target: http://data-processing.readthedocs.io/en/latest/?badge=feature-readthedocs
    :alt: Documentation Status
              
.. image:: https://openegoproject.files.wordpress.com/2017/02/open_ego_logo_breit.png?w=400


===================
eGo dataprocessing
===================

(geo)data processing, database setup, data validation

=========
Copyleft
=========
Code licensed under "GNU Affero General Public License Version 3 (AGPL-3.0)"
It is a collaborative work with several copyright owner:
Cite as "eGo dataprocessing © Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems © Europa-Universität Flensburg, Centre for Sustainable Energy Systems © Reiner Lemoine Institut © DLR Institute for Networked Energy Systems"

Installation
============

Installation of latest release

```
(sudo) pip3 install dataprocessing
```

Installation (of developer version) via pip on linux systems as follows

```
sudo pip3 install -e <path-to-data_processing-repo>
```

Troubleshooting

On Windows
***********

1. __Problem__: Installation of required package shapely fails. __Solution__: Install pre-build
 wheel from [here](http://www.lfd.uci.edu/~gohlke/pythonlibs/#shapely)


Run
====

 You can run data processing by calling command-line script

 ```
 ~$ ego_data_processing
 ```    

Local database with docker
==========================

You need to have `docker-compose` installed.

### Spin up database with docker

```
docker-compose up -d --build
```

### Database credentials

| database | dp |
| port | 54321 |
| user | oeuser |
| password | egon |