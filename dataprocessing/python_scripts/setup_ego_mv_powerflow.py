"""This script creates initial powerflow schemata in database
"""

__copyright__ = "Reiner Lemoine Institut gGmbH"
__license__ = "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__ = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "gplssm"


from oemof import db
from oemof.db import tools


def create_powerflow_schema(engine, schema, tables):
    """Creates new powerflow schema in database

    Parameters
    ----------
    engine: SQLalchemy engine
    tables: dict
        Values are list of columns/constraints
    """

    conn = engine.connect()

    group = 'oeuser'

    try:
        # create schema
        sql_create_schema = '''CREATE SCHEMA {0} AUTHORIZATION {1};
            '''.format(schema, group)

        conn.execute(sql_create_schema)

        # grant acess rights for schema
        tools.grant_schema(conn, schema, group)

        # alter privileges for schema
        sql_privileges_tables = '''ALTER DEFAULT PRIVILEGES IN SCHEMA {0}
            GRANT INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
            ON TABLES TO {1};'''.format(schema, group)
        conn.execute(sql_privileges_tables)

        sql_privileges_sequences = '''ALTER DEFAULT PRIVILEGES IN SCHEMA {0}
            GRANT SELECT, UPDATE, USAGE ON SEQUENCES TO {1};
            '''.format(schema, group)
        conn.execute(sql_privileges_sequences)

        sql_privileges_functions = '''ALTER  DEFAULT PRIVILEGES IN SCHEMA {0}
             GRANT EXECUTE ON FUNCTIONS TO {1};'''
        conn.execute(sql_privileges_functions)
    except:
        print('Schema {} already existed and is not created newly...'\
              .format(schema))


    # iterate over tables and create them

    sql_create = 'CREATE TABLE'

    for table in tables.keys():
        sql_create_table = sql_create + ' {0}.{1} ('.format(schema, table) + \
                ', '.join(tables[table]) +  ') WITH(OIDS = FALSE);'
        # try:
        conn.execute(sql_create_table)
        # except:
        #     print('Table {} already existed and is not created newly...'\
        #       .format(table))
        tools.grant_db_access(conn, schema, table, group)


    # Bus.metadata.drop_all(engine)


if __name__ == '__main__':
    """Create or delete powerflow schema"""

    engine = db.engine(section='oedb')

    schema = 'model_draft'

    # tables = [Bus, Line, Generator, Load, Storage, Source]

    tables = {
        'ego_grid_pf_mv_bus': ['bus_id character varying(25) NOT NULL', 'v_nom double precision',
                'v_mag_pu_min double precision DEFAULT 0',
                'v_mag_pu_max double precision',
                'geom geometry(Point,4326)',
                "scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying",
                "grid_id integer",
                'CONSTRAINT bus_data_pkey PRIMARY KEY (bus_id, scn_name)'],
        'ego_grid_pf_mv_generator': ["scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying",
            'generator_id character varying(25) NOT NULL', 'bus character varying(25)',
            "control text DEFAULT 'PQ'::text",
            'p_nom double precision DEFAULT 0',
            'p_min_pu_fixed double precision DEFAULT 0',
            'p_max_pu_fixed double precision DEFAULT 1',
            'sign double precision DEFAULT 1',
            "grid_id integer",
            'CONSTRAINT generator_data_pkey PRIMARY KEY (generator_id, scn_name)'],
        'ego_grid_pf_mv_line': ["scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying",
            'line_id character varying(25) NOT NULL', 'bus0 character varying(25)', 'bus1 character varying(25)',
            'x numeric DEFAULT 0',
            'r numeric DEFAULT 0',
            'g numeric DEFAULT 0',
            'b numeric DEFAULT 0',
            's_nom numeric DEFAULT 0',
            'length double precision',
            'cables integer',
            'geom geometry(LineString,4326)',
            "grid_id integer",
            'CONSTRAINT line_data_pkey PRIMARY KEY (line_id, scn_name)'],
        'ego_grid_pf_mv_load': ["scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying",
            "load_id character varying(25) NOT NULL",
            'bus character varying(25)',
            'sign double precision DEFAULT (-1)',
            "grid_id integer",
            'CONSTRAINT load_data_pkey PRIMARY KEY (load_id, scn_name)'],
        'ego_grid_pf_mv_temp_resolution': ['temp_id bigint NOT NULL',
            'timesteps bigint NOT NULL',
            'resolution text',
            'start_time timestamp without time zone', # style: YYYY-MM-DD HH:MM:SS
            "grid_id integer",
            'CONSTRAINT temp_resolution_pkey PRIMARY KEY (temp_id)'],
        'ego_grid_pf_mv_transformer': ["scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying",
            'trafo_id character varying(25) NOT NULL',
            'bus0 character varying(25)',
            'bus1 character varying(25)',
            'x numeric DEFAULT 0',
            'r numeric DEFAULT 0',
            'g numeric DEFAULT 0',
            'b numeric DEFAULT 0',
            's_nom double precision DEFAULT 0',
            'tap_ratio double precision',
            'geom geometry(Point,4326)',
            "grid_id integer",
            'CONSTRAINT transformer_data_pkey PRIMARY KEY (trafo_id, scn_name)'],
        'ego_grid_pf_mv_scenario_settings': ["scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying",
            'bus character varying',
            'bus_v_mag_set character varying',
            'generator character varying',
            'generator_pq_set character varying',
            'line character varying',
            'load character varying',
            'load_pq_set character varying',
            'storage character varying',
            'storage_pq_set character varying',
            'temp_resolution character varying',
            'transformer character varying',
            'CONSTRAINT scenario_settings_pkey PRIMARY KEY (scn_name)'],
        'ego_grid_pf_mv_bus_v_mag_set': ["scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying",
              'bus_id character varying(25) NOT NULL',
              'temp_id integer NOT NULL',
              'v_mag_pu_set double precision[]',
                "grid_id integer",
              'CONSTRAINT bus_v_mag_set_pkey PRIMARY KEY (bus_id, temp_id, scn_name)'],
              # 'CONSTRAINT bus_v_mag_set_temp_fkey FOREIGN KEY (temp_id) REFERENCES calc_ego_hv_powerflow.temp_resolution (temp_id)'],
        'ego_grid_pf_mv_generator_pq_set': ["scn_name character varying NOT NULL DEFAULT 'Status Quo'::character varying",
            'generator_id character varying(25) NOT NULL',
            'temp_id integer NOT NULL',
            'p_set double precision[]',
            'q_set double precision[]',
            'p_min_pu double precision[]',
            'p_max_pu double precision[]',
            "grid_id integer",
            'CONSTRAINT generator_pq_set_pkey PRIMARY KEY (generator_id, temp_id, scn_name)'],
            # 'CONSTRAINT generator_pq_set_temp_fkey FOREIGN KEY (temp_id) REFERENCES calc_ego_hv_powerflow.temp_resolution (temp_id)'],
        'ego_grid_pf_mv_load_pq_set': ["scn_name character varying NOT NULL "
                          "DEFAULT 'Status Quo'::character varying",
            'load_id character varying(25) NOT NULL',
            'temp_id integer NOT NULL',
            'p_set double precision[]',
            'q_set double precision[]',
            "grid_id integer",
            'CONSTRAINT load_pq_set_pkey '
            'PRIMARY KEY (load_id, temp_id, scn_name)'],
            # 'CONSTRAINT load_pq_set_temp_fkey FOREIGN KEY (temp_id) '
            # 'REFERENCES calc_ego_hv_powerflow.temp_resolution (temp_id)']
    }

    create_powerflow_schema(engine, schema, tables)
