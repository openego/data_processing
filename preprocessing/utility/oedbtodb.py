# -*- coding: utf-8 -*-
"""


Sources
-------
https://github.com/OpenEnergyPlatform/oedialect/blob/master/doc/example/oedialec
https://stackoverflow.com/questions/21770829/sqlalchemy-copy-schema-and-data-of-subquery-to-another-database
https://geoalchemy-2.readthedocs.io/en/latest/elements.html

"""

import oedialect

import sqlalchemy as sa

from egoio.tools import Base
from importlib import import_module
from sqlalchemy import event
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm.session import make_transient
from geoalchemy2.elements import WKBElement


def meta_url(schema, table):

    base = "https://openenergy-platform.org/api/v0/"
    return base + "schema/" + schema + "/tables/" + table + "/meta/"


def create_session(url):
    """ Returns SQLAlchemy session object

    Parameters
    ----------
    url : string
        Database dialect and connection arguments
    """
    engine = sa.create_engine(url)
    return sessionmaker(bind=engine)()


def unique_schema(qualified):
    """ Returns unique schema names

    Parameters
    ----------
    qualified : list
        List of qualified names in `schema.table` format
    """

    schemas = list(set([schema for schema, table in [i.split(".") for i in qualified]]))

    return schemas


def map_name_table(names, base):
    """ Create map from `schema.table` to associated table object

    Parameters
    ----------
    names : list
        List of qualified names in `schema.table` format
    base : `sqlalchemy.ext.declarative.api.Base`

    """
    mapper = {}

    for name, obj in base.metadata.tables.items():
        if name in names:
            mapper[name] = obj
    return mapper


def map_name_class(names, base):
    """ Create map from `schema.table` to class

    Parameters
    ----------
    names : list
        List of qualified names in `schema.table` format
    base : `sqlalchemy.ext.declarative.api.Base`

    Sources
    -------
        https://stackoverflow.com/questions/11668355/sqlalchemy-get-model-from-table-name-this-may-imply-appending-some-function-to

    """
    mapper = {}

    for cls in Base._decl_class_registry.values():
        if hasattr(cls, "__table__"):
            name = cls.__table__.schema + "." + cls.__tablename__
            if name in names:
                mapper[name] = cls
    return mapper


def main():
    """ """

    LOCAL = "postgresql+psycopg2://user:password@localhost:5432/database"
    REMOTE = "postgresql+oedialect://openenergy-platform.org"

    INPUT = {
        "environment.dlm250_geb01_f": None,
        "model_draft.wn_abw_ego_dp_hvmv_substation": {"version": "v0.3.0"},
    }

    source_session = create_session(REMOTE)
    target_session = create_session(LOCAL)

    schemas = unique_schema(INPUT)

    # https://stackoverflow.com/questions/41678073/import-class-from-module-dynamically

    # by importing a submodule the class registry
    # of `egoio.tools.Base` is extended with
    # all classes of the imported submodule
    for s in schemas:
        packagename = "egoio.db_tables"
        import_module(packagename + "." + s)

    class_map = map_name_class(INPUT.keys(), Base)
    table_map = map_name_table(INPUT.keys(), Base)

    # create schema if not exists
    # maybe as event hook?
    # https://github.com/sqlalchemy/sqlalchemy/issues/3982
    for schema in schemas:
        query = "CREATE SCHEMA IF NOT EXISTS {schema}".format(schema=schema)
        target_session.execute(query)
        target_session.commit()

    # create subset of database model in local database
    metadata = Base.metadata
    metadata.bind = target_session.connection().engine

    # https://stackoverflow.com/questions/19175311/how-to-create-only-one-table-with-sqlalchemy
    metadata.create_all(tables=table_map.values(), checkfirst=True)

    # retrieve data from remote database
    results = []

    for name, v in INPUT.items():
        query = source_session.query(class_map[name])
        if v:
            if "version" in v:
                query = query.filter(class_map[name].version == v["version"])
        for ds in query:
            make_transient(ds)
            results.append(ds)

    # create WKBElement from WKBElement ;)
    # otherwise database error about SRID being 0
    for r in results:
        for k, v in vars(r).items():
            if isinstance(v, WKBElement):
                wkb = WKBElement(v.data, srid=v.srid)
                setattr(r, k, wkb)
        target_session.add(r)

    target_session.commit()
    source_session.close()
    target_session.close()


if __name__ == "__main__":
    main()
