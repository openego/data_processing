"""eGo Data Processing (eGoDP)
This script opens a oedb database connection and executes different parts of eGo.
Reads python and SQL scripts and gives logging infos during the execution.
Also see corresponding BPML diagram.
"""

__copyright__ = "Reiner Lemoine Institut"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "gplssm, Ludee"

import pandas as pd
import logging
import time
import os
import codecs
from tools import io

def data_processing():
    # Configure logging
    logger = logging.getLogger('EEEE')
    logger.setLevel(logging.INFO)
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s %(message)s',
                                  datefmt='%Y-%m-%d %I:%M:%S')
    ch.setFormatter(formatter)
    logger.addHandler(ch)

    # get current time and inform about start
    total_time = time.time()
    logger.info('ego data processing started...')

    # list of sql- and python-snippets that process the data in correct order
    snippet_dir = os.path.abspath(
        os.path.join(os.path.dirname(__file__),
                             'sql_snippets'))
    script_dir = os.path.abspath(
        os.path.join(os.path.dirname(__file__),
                     'python_scripts'))

    snippets = [
    ## INPUT DATA CHECK (eGoPP)
#        'ego_dp_structure_input_verification.sql',          # Input verification (eGoPP)

    ## SUBSTATION
#        'ego_dp_substation_hvmv.sql',                       # Abstract HVMV Substations of the high voltage level from OSM
#        'ego_dp_substation_ehv.sql',                        # Abstract EHV Substations of the extra high voltage level from OSM
#        'ego_dp_substation_otg.sql',                        # Assign osmTGmod-id to HVMV and EHV substations
#        'ego_dp_substation_hvmv_voronoi.sql',               # HVMV Voronoi cells based on HVMV substations
#        'ego_dp_substation_ehv_voronoi.sql',                # EHV Voronoi cells based on EHV substations

    ## GRIDDISTRICT
#        'ego_dp_mv_griddistrict.sql',                       # MV GridDistricts from municipalities and Voronoi cells
#        'ego_dp_substation_id_to_generator.sql',            # Assign Substation ID (subst_id) to Generator (Conventional and Renewable)

    ## LOADAREA
#        'ego_dp_loadarea_landuse.sql',                      # OSM landuse sectors
#        'ego_dp_loadarea_industry_consumer.sql',            # OSM Industry consumer
#        'ego_dp_loadarea_loads.sql',                        # OSM Loads from landuse
#        'ego_dp_loadarea_census.sql',                       # Loads from Census 2011
#        'ego_dp_loadarea_loadmelt.sql',                     # Melt loads from OSM landuse and Census 2011
#        'ego_dp_loadarea_loadcut_griddistrict.sql',         # Cut Loadarea with MV Griddistrict
#        'ego_dp_loadarea_loadcut_voronoi.sql',              # Cut Loadarea with MV Voronoi cells
#        'ego_dp_loadarea_consumption.sql',                  # Allocate consumption to Loadareas
#        'ego_dp_loadarea_peakload.sql',                     # Peak loads per Loadarea
#        'ego_dp_loadarea_griddistrict_results.sql',         # Results for MV Griddistrict
#        'ego_dp_loadarea_statistic.sql',                    # Results and statistics for eGoDP data

    ## LOWVOLTAGE
#        'ego_dp_lv_substation.sql',                         # MVLV Substation (ONT)
#        'ego_dp_lv_substation_voronoi.sql',                 # MVLV Substation Voronoi
#        'ego_dp_lv_loadcut.sql',                            # LV Loadcut
#        'ego_dp_lv_griddistrict.sql',                       # LV Griddistrict
#        'ego_dp_lv_consumption_peakload.sql',               # LV Consumption and Peakload

    ## REA
#        'rea/ego_dp_lattice_500m.sql',                      # Lattice (point grid) 500m
#        'rea/ego_dp_lattice_50m.sql',                       # Lattice (point grid) 50m
#        'rea/ego_dp_rea_wpa_per_mvgd.sql',                  # Wind potential area (WPA)
#        'rea/ego_dp_rea_lattice_per_area_500m.sql',         # Prepare 500m lattice
#        'rea/ego_dp_rea_lattice_per_area_50m.sql',          # Prepare 50m lattice
#        'rea/ego_dp_rea_setup.sql',                         # Setup tables for REA
#        'rea/ego_dp_rea_m1.sql',                            # M1 biomass and solar to OSM agricultural
#        'rea/ego_dp_rea_m2.sql',                            # M2 wind farms
#        'rea/ego_dp_rea_m3.sql',                            # M3 wind turbines to WPA
#        'rea/ego_dp_rea_m4.sql',                            # M4 other and rest
#        'rea/ego_dp_rea_m5.sql',                            # M5 LV to Loadarea
#        'rea/ego_dp_rea_results.sql',                       # Results and statistics

    ## POWERFLOW
	    
#	'ego_dp_powerflow_hv_setup.sql',			# Set schema/tables for EHV/HV powerflow calculations up
#	'ego_dp_powerflow_osmtgmod_to_pypsa.sql',		# Include data from osmTGmod into EHV/HV powerflow schema
#	'ego_dp_powerflow_electrical_neighbour.sql',		# Create border crossing lines and buses in neighbouring countries
#	'ego_dp_powerflow_fix_ehv_subnetworks.sql',		# Fix topological errors in eHV grid
#	'ego_dp_powerflow_grid_future_scenarios.sql',		# Copy grid to future scenarios 
	'ego_dp_powerflow_assignment_otgid.sql',		# assign otg_id to pp lists
	'ego_dp_powerflow_assignment_unid.sql',			# create a unified_id over all pp (res and conv)	    
	'ego_dp_powerflow_create_pp_mview.sql',			# create mviews to display power plants per scenario
	'ego_dp_powerflow_assignment_generator.sql',  		# Assign generators to corresponding substation (SQ, NEP2035, eGo100)
	'ego_dp_powerflow_assignment_load.sql',        		# Assign loads to their corresponding substation (SQ, NEP2035, eGo100)
	'ego_dp_powerflow_assignment_storage.sql',		# Assign storages to their corresponding substation (SQ, NEP 2035, eGo 100)
	'ego_dp_powerflow_timeseries_generator.sql',		# Transfer renpassG!S results into the corresponding powerflow table
	'ego_dp_powerflow_griddistrict_demand.py',		# Demand per MV Griddistrict
	'ego_dp_powerflow_timeseries_demand.sql',		# Insert demand series into corresponding powerflow table (SQ, NEP2035, eGo100)
	'ego_dp_powerflow_lopf_data.sql',			# Set marginal costs for generators and storages
	'ego_dp_data_check.sql',				# Check powerflow data for plausibility
    ## POST-PROCESSING
        'ego_pp_nep2035_grid_variations.sql'			# Create extension_tables and insert NEP-data
	
    ## VERSIONING
   	'ego_dp_versioning.sql',				# Versioning
#	'ego_dp_versioning_mviews.sql' ,			# Versioning of mviews

	

    
	## VACUUM FULL
#	 'ego_dp_vacuum_full.sql'
    ]

    # get database connection
    conn = io.oedb_session(section='ssh_ilka')

    # iterate over list of sql- and python-snippets and execute them
    for snippet in snippets:
        # timing and logging
        snippet_time = time.time()
        logger.info("Execute '{}' ...".format(snippet))
        if os.path.splitext(snippet)[1] == '.sql':
            snippet_str = open(os.path.join(snippet_dir, snippet)).read()

            # execute desired sql snippet
            conn.execution_options(autocommit=True).execute(snippet_str)
        elif os.path.splitext(snippet)[1] == '.py':
            filename = os.path.join(script_dir, snippet)
            script_str = open(filename, "rb").read()

            # execute desired sql snippet
            exec(compile(script_str, filename, 'exec'), globals())
        else:
            raise NameError('{} is neither a python nor a sql script (at least it '
                            'has not the right extension). Please add an extension '
                            'to the script name (.py or .sql)'.format(snippet))

        # inform the user
        logger.info('...successfully done in {:.2f} seconds.'.format(
            time.time() - snippet_time))

    # close database connection
    conn.close()

    logger.info('Data processing script successfully executed in {:.2f} seconds'.format(
        time.time() - total_time))


if __name__ == '__main__':
    data_processing()
