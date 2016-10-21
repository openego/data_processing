#!/usr/bin/env python3

from demandlib import bdew as bdew, particular_profiles as profiles
from egoio.db_tables.calc_ego_loads import EgoDeuConsumption as orm_loads,\
    EgoDemandPerTransitionPoint as orm_demand
from egoio.tools import db
from sqlalchemy.orm import sessionmaker
from sqlalchemy import func
from workalendar.europe import Germany
import pandas as pd
from datetime import time as settime
from math import sqrt
from dataprocessing.tools import io, metadata
import time


def demand_per_mv_grid_district():
    year = 2013
    schema = 'calc_ego_loads'
    target_table = 'ego_demand_per_transition_point'
    db_group = 'oeuser'

    columns_names = {'h0': 'residential',
                     'g0': 'retail',
                     'i0': 'industrial',
                     'l0': 'agricultural'}

    inv_columns_names = {v: k for k, v in columns_names.items()}

    # The following dictionary is create by "workalendar"
    # pip3 install workalendar

    cal = Germany()
    holidays = dict(cal.holidays(2010))

    # Alternatively, define holidays manually
    # holidays = {
    #     datetime.date(2010, 5, 24): 'Whit Monday',
    #     datetime.date(2010, 4, 5): 'Easter Monday',
    #     datetime.date(2010, 5, 13): 'Ascension Thursday',
    #     datetime.date(2010, 1, 1): 'New year',
    #     datetime.date(2010, 10, 3): 'Day of German Unity',
    #     datetime.date(2010, 12, 25): 'Christmas Day',
    #     datetime.date(2010, 5, 1): 'Labour Day',
    #     datetime.date(2010, 4, 2): 'Good Friday',
    #     datetime.date(2010, 12, 26): 'Second Christmas Day'}

    # retrieve sectoral demand from oedb

    # get database connection
    conn = io.oedb_session(section='oedb')
    Session = sessionmaker(bind=conn)
    session = Session()

    query_demand = session.query(orm_loads.otg_id,
                                 func.sum(orm_loads.sector_consumption_residential).\
                                 label('residential'),
                                 func.sum(orm_loads.sector_consumption_retail).label('retail'),
                                 func.sum(orm_loads.sector_consumption_industrial).\
                                 label('industrial'),
                                 func.sum(orm_loads.sector_consumption_agricultural).\
                                 label('agricultural')).\
                                 group_by(orm_loads.otg_id)

    annual_demand_df = pd.read_sql_query(
        query_demand.statement, session.bind, index_col='otg_id').fillna(0)
    annual_demand_df = annual_demand_df.loc[~pd.isnull(annual_demand_df.index)]


    large_scale_industrial = pd.read_sql_table('large_scale_consumer', conn, schema,
                                               index_col='id')


    # add extra industrial demand ontop of MV industrial demand
    annual_demand_df = pd.concat(
        [annual_demand_df,
         large_scale_industrial.groupby(
             by='otg_id').sum()['consumption']],
        axis=1)
    annual_demand_df['industrial'] = annual_demand_df[
        ['industrial', 'consumption']].sum(axis=1)
    annual_demand_df.drop('consumption', axis=1, inplace=True)

    # rename columns according to demandlib definitions
    annual_demand_df.rename(columns=inv_columns_names, inplace=True)

    # Delete current content from table
    session.query(orm_demand).delete()

    # iterate over substation retrieving sectoral demand at each of it
    for it, row in annual_demand_df.iterrows():
        # read standard load profiles
        e_slp = bdew.ElecSlp(year, holidays=holidays)

        # multiply given annual demand with timeseries
        elec_demand = e_slp.get_profile(row.to_dict())

        # Add the slp for the industrial group
        ilp = profiles.IndustrialLoadProfile(e_slp.date_time_index, holidays=holidays)

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
        elec_demand = elec_demand.resample('H').mean().sum(axis=1)

        # Convert from GW to MW
        active_power = elec_demand * 1e3

        # derive reactive power from active power
        reactive_power = ((active_power / 0.95)**2 - active_power**2).apply(sqrt)

        # Write to database
        demand2db = orm_demand(id=it,
                               p_set=active_power.tolist(),
                               q_set=reactive_power.tolist())
        session.add(demand2db)

        session.commit()

    # grant access to db_group
    db.grant_db_access(conn, schema, target_table, db_group)

    # change owner of table to db_group
    db.change_owner_to(conn, schema, target_table, db_group)

    # # add primary key constraint on id column
    # db.add_primary_key(conn, schema, target_table, 'id')

    # create metadata json str
    json_str = metadata.create_metadata_json(
        'Load time series at transition points',
        '',
        '2011',
        time.strftime("%d.%m.%Y"),
        'Open Energy Database, schema: {0}, table: {1}'.format(schema,
                                                               target_table),
        'Germany',
        'Active and reactive power demand time series per transition point',
        [{'Name': 'id',
          'Description': 'Unique identifier',
          'Unit': '-'},
         {'Name': 'active_power',
          'Description': 'Active power demand',
          'Unit': 'MW'},
         {'Name': 'reactive_power',
          'Description': 'Reactive power demand',
          'Unit': 'MW'}
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

if __name__ == '__main__':
    demand_per_mv_grid_district()

    # orm_demand.__table__.create(conn)

