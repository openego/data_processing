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

You need to have `docker-compose` installed. And some more tools, see requirements_system.txt.

### Spin up database with docker

```
docker-compose up -d --build
```

### Database credentials

| database | dp |
| port | 54321 |
| user | oeuser |
| password | egon |


Usage
=====


Pre-processing
**************

Execute `eGo_import_and_preprocessing.py` for starting pre-processing from scratch doing data import and a pre-processing of imported tables.

Once completed, export required schemas to SQL dump

_You might have to install `postgresql-client-11` from additional source to have a compatible client with the v11 dockered PostgreSQL database._

```
 /usr/lib/postgresql/11/bin/pg_dump -d dp -U oeuser -p 54321 -h localhost -Fc -n model_draft -n openstreetmap -n boundaries -n society > `date -I`_eGo_data_pre-processing_bremen.backup
```

Import a dump by

```
/usr/lib/postgresql/11/bin/pg_restore -d dp -U oeuser -p 54321 -h localhost 2020-03-28_eGo_data_pre-processing_deu.backup
```
