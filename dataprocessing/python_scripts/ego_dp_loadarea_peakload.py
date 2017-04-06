"""
Calculates peak load per load area
"""

__copyright__ 	= "Reiner Lemoine Institut, Flensburg University of Applied Sciences, Centre for Sustainable Energy Systems"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ 		= "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ 		= "gplssm, IlkaCu" 

import pandas as pd
from workalendar.europe import Germany
from datetime import time as settime
import time
from sqlalchemy.orm import sessionmaker

from demandlib import bdew as bdew, particular_profiles as profiles
from dataprocessing.tools import io, metadata
from egoio.db_tables.model_draft import EgoDemandLoadareaPeakLoad as orm_peak_load
from oemof.db import tools
from dataprocessing.python_scripts.functions.ego_scenario_log import write_ego_scenario_log

def get_load_areas_table(schema, table, index_col, conn, columns=None):
    r"""Retrieve load areas intermediate results table from oedb
    """

    # retrieve table with processed input data
    load_areas = pd.read_sql_table(table, conn, schema=schema,
                                    index_col=index_col, columns=columns)

    return load_areas


def add_sectoral_peak_load(load_areas, **kwargs):
    r"""Add peak load per sector based on given annual consumption
    """

    # define data year
    # TODO: in the future get this from somewhere else
    year = 2011

    # call demandlib
    # TODO: change to use new demandlib
    # read standard load profiles
    e_slp = bdew.ElecSlp(year, holidays=holidays)

    # multiply given annual demand with timeseries
    # elec_demand = e_slp.get_profile(load_areas['h0', 'g0', 'l0', 'i0'].to_dict())
    elec_demand = e_slp.get_profile(load_areas.to_dict())

    # tmp_peak_load = dm.electrical_demand(method='calculate_profile',
    #                                  year=year,
    #                                  ann_el_demand_per_sector= {
    #                                      'h0':
    #                                          load_areas['sector_consumption_residential'],
    #                                      'g0':
    #                                          load_areas['sector_consumption_retail'],
    #                                      'i0':
    #                                          load_areas['sector_consumption_industrial'],
    #                                     'l0':
    #                                         load_areas['sector_consumption_agricultural']}
    #                                  ).elec_demand
    # hack correct industrial profile into dataframe
    # print(load_areas['sector_consumption_industrial'])

    # if load_areas['sector_consumption_industrial'] == 0:
    #     load_areas['sector_consumption_industrial'] = 0.1

    # Add the slp for the industrial group
    ilp = profiles.IndustrialLoadProfile(e_slp.date_time_index,
                                         holidays=holidays)

    # Beginning and end of workday, weekdays and weekend days, and scaling factors
    # by default
    elec_demand['i0'] = ilp.simple_profile(
        load_areas['i0'],
        am=settime(6, 0, 0),
        pm=settime(22, 0, 0),
        profile_factors=
        {'week': {'day': 0.8, 'night': 0.6},
         'weekend': {'day': 0.6, 'night': 0.6}})

    # Resample 15-minute values to hourly values and sum across sectors
    elec_demand = elec_demand.resample('H').mean().fillna(0).max().to_frame().T

    # demand_industry = eb.IndustrialLoadProfile('simple_industrial_profile',
    #     **{'annual_demand': load_areas['sector_consumption_industrial'],
    #     'year': year,
    #     'am': settime(6, 0, 0),
    #     'pm': settime(22, 0, 0),
    #     'profile_factors':
    #         {'week': {'day': 0.8, 'night': 0.6},
    #         'weekend': {'day': 0.6, 'night': 0.6}}
    #     })
    # ind_demand = demand_industry.profile
    # elec_demand['i0'] = ind_demand

    peak_load = elec_demand.max(axis=0)

    return peak_load


if __name__ == '__main__':

    la_index_col = 'id'

    schema = 'model_draft'
    table = 'ego_demand_loadarea'
    target_table = 'ego_demand_loadarea_peak_load'
    year = 2011
    db_group = 'oeuser'

    cal = Germany()
    holidays = dict(cal.holidays(2011))

    # get database connection object
    conn = io.oedb_session(section='oedb')
    Session = sessionmaker(bind=conn)
    session = Session()

    # retrieve load areas table
    columns = [la_index_col,
               'sector_consumption_residential',
               'sector_consumption_retail',
               'sector_consumption_industrial',
               'sector_consumption_agricultural']

    load_areas = get_load_areas_table(schema, table, la_index_col, conn,
                                      columns=columns)

    write_ego_scenario_log(conn=conn,
                           version='v0.2.6',
                           io='input',
                           schema='model_draft',
                           table=table,
                           script='ego_dp_loadarea_peakload.py',
                           entries=len(load_areas))

    names_dc = {'sector_consumption_residential': 'h0',
                'sector_consumption_retail': 'g0',
                'sector_consumption_agricultural': 'l0',
                'sector_consumption_industrial': 'i0',}

    names_dc2 = {'h0': 'residential',
                 'g0': 'retail',
                 'l0': 'agricultural',
                 'i0': 'industrial'}

    # rename columns to demandlib compatible names
    load_areas.rename(columns=names_dc, inplace=True)

    # # delete old content from table
    # del_str = "DROP TABLE IF EXISTS {0}.{1} CASCADE;".format(
    #     schema, target_table)
    # conn.execute(del_str)

    # empty table or create
    try:
        orm_peak_load.__table__.create(conn)
    except:
        session.query(orm_peak_load).delete()
        session.commit()

    # Use above function `add_sectoral_peak_load` via apply
    # elec_demand = load_areas.fillna(0).apply(
    #     add_sectoral_peak_load, axis=1, args=())

    # read standard load profiles
    e_slp = bdew.ElecSlp(year, holidays=holidays)

    # Add the slp for the industrial group
    ilp = profiles.IndustrialLoadProfile(e_slp.date_time_index,
                                         holidays=holidays)

    # counter
    ctr = 0

    # iterate over substation retrieving sectoral demand at each of it
    for it, row in load_areas.iterrows():
        row = row.fillna(0)

        # multiply given annual demand with timeseries
        elec_demand = e_slp.get_profile(row.to_dict())


        # Beginning and end of workday, weekdays and weekend days, and scaling factors
        # by default
        elec_demand['i0'] = ilp.simple_profile(
            row['i0'],
            am=settime(6, 0, 0),
            pm=settime(22, 0, 0),
            profile_factors=
            {'week': {'day': 0.8, 'night': 0.6},
             'weekend': {'day': 0.6, 'night': 0.6}})

        # Resample 15-minute values to hourly values and sum across sectors
        elec_demand = elec_demand.resample('H').mean().fillna(0).max().to_frame().T#.max(axis=0)#.to_frame().unstack()#.\
        # to_frame(name='peak_load')
        elec_demand['id'] = it
        elec_demand.set_index('id', inplace=True)

        # rename columns
        elec_demand.rename(columns=names_dc2, inplace=True)

        # Add data to orm object
        peak_load = orm_peak_load(
            id=it,
            retail=float(elec_demand['retail']),
            residential=float(elec_demand['residential']),
            industrial=float(elec_demand['industrial']),
            agricultural=float(elec_demand['agricultural']))

        session.add(peak_load)

        # # write results to new database table
        # elec_demand.to_sql(target_table,
        #                      conn,
        #                      schema=schema,
        #                      index=True,
        #                      if_exists='fail')

        ctr += 1
        # commit data to database every 1000 datasets: This is done since pushing every
        # single dataset slows down entire script, single commiting in the end sometimes
        # leads to conn. timeout.
        if (ctr % 1000) == 0:
            session.commit()

    # commit remaining datasets that were not committed in loop above
    session.commit()

    # grant access to db_group
    tools.grant_db_access(conn, schema, target_table, db_group)

    # change owner of table to db_group
    tools.change_owner_to(conn, schema, target_table, db_group)

    # # add primary key constraint on id column
    # tools.add_primary_key(conn, schema, target_table, la_index_col)

    # create metadata json str
    json_str = metadata.create_metadata_json(
        'Peak load per load area',
        '',
        '2011',
        time.strftime("%d.%m.%Y"),
        'Open Energy Database, schema: {0}, table: {1}'.format(schema,
                                                               target_table),
        'Germany',
        'Sectoral peak of single load areas based on synthetic standard load ' +
        'profiles.',
        [{'Name': 'id',
          'Description': 'Unique identifier',
          'Unit': '-'},
         {'Name': 'g0',
          'Description': 'Peak demand of retail sector',
          'Unit': 'GW'},
         {'Name': 'h0',
          'Description': 'Peak demand of household sector',
          'Unit': 'GW'},
         {'Name': 'l0',
          'Description': 'Peak demand of agricultural sector',
          'Unit': 'GW'},
         {'Name': 'i0',
          'Description': 'Peak demand of industrial sector',
          'Unit': 'GW'}
         ],
        {'Name': 'Guido Pleßmann',
         'Mail': 'guido.plessmann@rl-institut.de',
         'Date': time.strftime("%d.%m.%Y"),
         'Comment': 'Initial creation of dataset'},
        'Be aware of applicability. Data bases on synthetic load profiles',
        '',
        ''
    )

    metadata.submit_comment(conn, json_str, schema, target_table)

    write_ego_scenario_log(conn=conn,
                           version='v0.2.6',
                           io='output',
                           schema='model_draft',
                           table=target_table,
                           script='ego_dp_loadarea_peakload.py',
                           entries=len(load_areas))

    conn.close()