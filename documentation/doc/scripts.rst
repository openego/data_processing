=======================
Data processing scripts
=======================


Data processing
===============

SQL-Scripts
-----------

.. toctree::
   :maxdepth: 1
   :titlesonly:

   Dataprocessing <dataprocessing/modules>


Python-Scripts
--------------

[use sphinx doc strings]


Preprocessing
=============

SQL-Scripts
-----------
.. toctree::
   :maxdepth: 1
   :titlesonly:

   Preprocessing <preprocessing/modules>


Data processing
===============

The data processing is organized into separate parts which are executed in desired order.

.. image:: images/ego_dp_bpmn_sections.png

Each of these parts consists of multiple data processing steps that are stored in separate SQL files.
The following sections explain what is done in each section, which data is accessed, created or manipulated, and
which tables results of each script.


Input data chech
----------------

Check of data prepared for HV/EHV power grid calculations.

.. image:: images/ego_dp_bpmn_section_input_data_check.png
   :width: 800px

Substation
----------

Process data for sub-stations in grid levels from EHV to MV and create Voronoi cuts around HV sub-stations.

.. image:: images/ego_dp_bpmn_section_substation.png

Grid district
-------------

Derive medium-voltage grid districts from administrative boundaries and HV/MV sub-station locations.

.. image:: images/ego_dp_bpmn_section_griddistrict.png


Load area
---------

Define areas of electricity consumption categorized into energy consumption sectors.

.. image:: images/ego_dp_bpmn_section_loadarea.png

Low-voltage
-----------

Estimate medium/low-voltage sub-station locations and respective low-voltage grid districts.

.. image:: images/ego_dp_bpmn_section_lowvoltage.png

Renewable energy allocation (REA)
---------------------------------

Enrich renewable power plant data base with more plausible locations for power plants with unprecise information about
the location.

.. image:: images/ego_dp_bpmn_section_REA.png


Power flow
----------

Prepare PyPSA-compatible tables for power-flow calculation in the EHV/HV grid level.

.. image:: images/ego_dp_bpmn_section_powerflow.png

Post-processing
---------------

Post-process :ref:`Power flow` data.


.. image:: images/ego_dp_bpmn_section_postprocessing.png
   :width: 800px

Versioning
----------

Move resulting data to versioned schemas of the database.

.. image:: images/ego_dp_bpmn_section_versioning.png




SQL-Scripts
-----------

.. toctree::
   :maxdepth: 1
   :titlesonly:

   Dataprocessing <dataprocessing/modules>



