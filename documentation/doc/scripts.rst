=======================
Data processing scripts
=======================

The preparation of data in organized into :ref:`Preprocessing` and :ref:`Data processing`.
Scripts contained in the :ref:`Preprocessing` include import of raw and basic preparation for later use in scripts of
:ref:`Data processing`.

Preprocessing
=============

Overview on pre-processing scripts that import data and do basic preparation.
Data pre-processing steps partially depend on each other which is shown in the following figure.

.. image:: images/ego_dp-pre_bpmn_sections.png
   :width: 80%

Scenario log
------------

Prepare logging of data processing: create logging table and respective function that logs changes made to tables.

.. image:: images/ego_dp-pre_bpmn_section_scenario-log.png
   :width: 80%

RenpassG!S
----------

Using repassG!S for creating time series of renewable power plants feedin.

.. image:: images/ego_dp-pre_bpmn_section_renpassGIS.png
   :width: 80%

COSMO-CLM grid
--------------

Import spatial data grid for COSMO-CLM climate data.

.. image:: images/ego_dp-pre_bpmn_section_cosmoclmgrid.png
   :width: 70%

Zensus
------

Import Zensus data.

.. image:: images/ego_dp-pre_bpmn_section_zensus.png

Import data for administrative boundaries from VG250 data set.

.. image:: images/ego_dp-pre_bpmn_section_bkg-vg250.png

OpenStreetMap
-------------

Import OpenStreetMap (OSM) data from Geofabrik data dumps.

.. image:: images/ego_dp-pre_bpmn_section_openstreetmap.png

Standard load profile
---------------------

Insert standard load profile (SLP) parameters to database table.

.. image:: images/ego_dp-pre_bpmn_section_slp.png
   :width: 60%

Wind potential areas
--------------------

Import wind potential area data from VerNETZen project.

.. image:: images/ego_dp-pre_bpmn_section_wind_potential_areas.png
   :width: 90%


Demand at federal states
------------------------

Insert annual demand data at federal state level for different energy use sectors and disaggregate further.

.. image:: images/ego_dp-pre_bpmn_section_demand_federalstate.png
   :width: 80%

osmTGmod
--------

EHV and HV level grid obtained from OSM with osmTGmod.

.. image:: images/ego_dp-pre_bpmn_section_osmtgmod.png
   :width: 60%

Power plant data
----------------

Basic preparation of power plant data.

.. image:: images/ego_dp-pre_bpmn_section_supply.png


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




Additional information on SQL-Scripts
=====================================

.. toctree::
   :maxdepth: 1
   :titlesonly:

   Dataprocessing <dataprocessing/modules>
   Preprocessing <preprocessing/modules>



