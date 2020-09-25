Getting started
===============



Installation and setup
----------------------

Installation of latest release

.. code-block:: python

   pip install dataprocessing

or download latest source code

.. code-block:: python

   git clone git@github.com:openego/data_processing.git

and install the developer version

.. code-block:: python

   pip install -e <path-to-data_processing-repo>


Troubleshooting
^^^^^^^^^^^^^^^

On Windows
""""""""""

1. **Problem**: Installation of required package shapely fails. **Solution**: Install pre-build
wheel from `here <http://www.lfd.uci.edu/~gohlke/pythonlibs/#shapely>`_.

Database with docker (optional)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You need to have `docker-compose` installed. And some more tools, see `requirements_system.txt`.

Spin up database with docker
""""""""""""""""""""""""""""

.. code-block:: bash

   docker-compose up -d --build

Database credentials
""""""""""""""""""""

======== ======
database dp
port     54321
user     oeuser
password egon
======== ======



Execute pre-processing
-----------------------

Execute

.. code-block:: bash

  python preprocessing/eGo_import_and_preprocessing.py

for starting pre-processing from scratch doing data import and a pre-processing of imported tables.

Once completed, export required schemas to SQL dump

*You might have to install `postgresql-client-11` from additional source to have a compatible client with the v11
dockered PostgreSQL database.*

.. code-block:: bash

   /usr/lib/postgresql/11/bin/pg_dump -d dp -U oeuser -p 54321 -h localhost -Fc -n model_draft -n openstreetmap -n boundaries -n society > `date -I`_eGo_data_pre-processing_bremen.backup

Re-import dumped data by

.. code-block:: bash

   /usr/lib/postgresql/11/bin/pg_restore -d dp -U oeuser -p 54321 -h localhost 2020-03-28_eGo_data_pre-processing_deu.backup

You can run data processing by calling command-line script

Execute data processing
------------------------


.. code-block:: bash

   python dataprocessing/eGo_data_processing.py
