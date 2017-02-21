/*
This script does the allocation of renewable energy source units in Germany.
The allocation is done by three open_eGo scenarios: status-quo, NEP 2035 
and ZNES 100% RES.

__copyright__ = "Europa-Universität Flensburg, Centre for Sustainable Energy Systems"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "wolfbunke"


Input tables:
-------------

* model_draft.ego_lattice_50m 
* model_draft.ego_lattice_500m
* model_draft.ego_lattice_deu_500m
* model_draft.ego_supply_res_powerplant_2035
* model_draft.ego_supply_res_powerplant_2050
* 


Output tables:
--------------

* 



Methode:
--------


1. status quo data


Process steps:
--------------
'ego_lattice_500m.sql' 		 	# lattice (point grid) 500m
'ego_lattice_50m.sql'		 	# lattice (point grid) 50m
'ego_rea_wpa_per_mvgd.sql', 	 	# wind potential area
'ego_rea_lattice_per_area_500m.sql', 	# prepare 500m lattice
' ego_rea_lattice_per_area_50m.sql', 	# prepare 50m lattice
'ego_rea_setup.sql',		 	# setup table for allocation
'ego_rea_m1.sql',
'ego_rea_m2.sql',
'ego_rea_m3.sql',
'ego_rea_m4.sql',
'ego_rea_m5.sql',
'ego_rea_results.sql'


ToDo:
-----

* check lattice var.



*/







