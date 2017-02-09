"""
Create LV substations
"""

__copyright__ 	= "Reiner Lemoine Institut gGmbH"
__license__ 	= "GNU Affero General Public License Version 3 (AGPL-3.0)"
__url__         = "https://github.com/openego/data_processing/blob/master/LICENSE"
__author__ = "jong42"

import sqlalchemy as sqla
from sqlalchemy import func
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql.expression import literal
from numpy import *
from geoalchemy2 import Geometry
import re
from oemof import db
from egoio.tools import config as cfg
import os.path as path
import time


################################# Beziehe alle notwenigen Tabellen aus egoio:

filepath = path.join(path.dirname(path.realpath(__file__)))
cfg.load_config('config_eGo_substations_lv', filepath=filepath)

EgoDeuLoadArea_name = cfg.get('regions', 'load_areas')
from egoio.db_tables import calc_ego_loads as orm_calc_ego_loads
orm_load_areas = orm_calc_ego_loads.__getattribute__(EgoDeuLoadArea_name)

#PeakLoads_name = cfg.get('auxilliary_tables', 'peak_loads')
#orm_peak_loads = orm_calc_ego_loads.__getattribute__(PeakLoads_name)

EgoDeuOntGrid_name = cfg.get('auxilliary_tables', 'ontgrids')
from egoio.db_tables import calc_ego_grid_district as orm_calc_ego_grid_district
orm_ontgrids = orm_calc_ego_grid_district.__getattribute__(EgoDeuOntGrid_name)

EgoDeuOnts_name = cfg.get('substations', 'onts')
from egoio.db_tables import calc_ego_substation as orm_calc_ego_onts
orm_onts = orm_calc_ego_onts.__getattribute__(EgoDeuOnts_name)

EgoDeuLoadAreaRest_name = cfg.get('auxilliary_tables', 'load_area_rest')
orm_load_area_rest = orm_calc_ego_grid_district.__getattribute__(EgoDeuLoadAreaRest_name)


#################################

def Position_ONTs(trafo_range,
                  trafo_maxrange,
                  engine
                  ):


    meta = sqla.MetaData()
    conn = engine.connect()
    Session = sessionmaker(bind=conn)
    session = Session()

    ################################# Erstelle Gitternetze f??r alle Lastgebiete

    def CreateFishnet(nrow, ncol, xsize, ysize, x0, y0):

        # Konstruiere eine Gitterzelle:
        cell = func.ST_GeomFromText(('POLYGON((0 0, 0' + ' ' + str(xsize)
            + ',' + str(ysize) + ' ' + str(xsize) + ',' + str(ysize) + ' ' + '0,0 0))'),3035)


        # Dupliziere die Zelle f??r jede Position im Gitter einmal:
        if ncol > 0 and nrow > 0:

            geoms = []
            for i in range(0,ncol):
                for j in range(0,nrow):
                    query = sqla.select(
                        [func.ST_Translate(cell,i*xsize+x0,j*ysize+y0)]
                        ).alias('geom')
                    result = conn.execute(query)
                    for row in result:
                        row = str(row)
                        # Filtere mittels regul??rem Ausdruck nur den relevanten Teil der Zeichenkette:
                        row = re.search('[0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ]+',row)
                        row = row.group(0)
                        geoms.append(row)

            return geoms
        # Falls nrow oder ncol 0 sind, gebe leere Geometrie zur??ck:
        else:
            geom = 'POLYGON EMPTY'
#            print(geom)
            return geom



    ############# Bestimme Parameter f??r CreateFishnet-Funktion:
    # Bestimme Fl??che der bbox f??r Sonderfallbehandlung:
    area = []
    bbox_xsize = []
    bbox_ysize = []

    ###### Bestimme Fl??che und Ausdehnung der bbox f??r Ausnahmenbehandlung
    for instance in session.query(orm_load_areas):
        s = sqla.select([func.ST_xmax(func.box2d(instance.geom)) - func.ST_xmin(func.box2d(instance.geom)) ])
        result = conn.execute(s)
        for row in result:
            bbox_xsize.append (row [0])

    for instance in session.query(orm_load_areas):
        s = sqla.select([func.ST_ymax(func.box2d(instance.geom)) - func.ST_ymin(func.box2d(instance.geom)) ])
        result = conn.execute(s)
        for row in result:
            bbox_ysize.append (row [0])

    for instance in session.query(orm_load_areas):
        s = sqla.select([(func.ST_xmax(func.box2d(instance.geom)) - func.ST_xmin(func.box2d(instance.geom)))*
            (func.ST_ymax(func.box2d(instance.geom)) - func.ST_ymin(func.box2d(instance.geom))) ])
        result = conn.execute(s)
        for row in result:
            area.append (row [0])

    ###### Bestimme Parameter nrow (Anzahl der Zeilen):
    nrow = []
    # Bestimme nrow mittels SQL-Abfrage:
    for instance in session.query(orm_load_areas):
         s = sqla.select([ (func.ROUND((func.ST_ymax(func.ST_Extent(instance.geom)) -
             func.ST_ymin(func.ST_Extent(instance.geom))) /(trafo_range*2)))])
         result = conn.execute(s)
         # Wandle Datentyp um:

         for row in result:
            row = str(row)
            # L??sche ??berfl??ssige Zeichen mittels eines regul??ren Ausdrucks:
            row = re.search('[0123456789]+',row)
            row = row.group(0)
            row = int(row)
            nrow.append(row)

    result.close()


    ###### Bestimme Parameter ncol (Anzahl der Spalten):
    ncol = []
    # Bestimme ncol mittels SQL-Abfrage:
    for instance in session.query(orm_load_areas):
         s = sqla.select([ (func.ROUND((func.ST_xmax(func.ST_Extent(instance.geom)) -
             func.ST_xmin(func.ST_Extent(instance.geom))) /(trafo_range*2)))])
         result = conn.execute(s)
         # Wandle Datentyp um:
         for row in result:
           row = str(row)
           # L??sche ??berfl??ssige Zeichen mittels eines regul??ren Ausdrucks:
           row = re.search('[0123456789]+',row)
           row = row.group(0)
           row = int(row)
           ncol.append(row)


    result.close()

    ###### Bestimme Parameter x0 und y0:
    x0 = []
    y0 = []
    for instance in session.query(orm_load_areas):
        x = sqla.select([func.ST_xmin(func.box2d(instance.geom))])
        y = sqla.select([func.ST_ymin(func.box2d(instance.geom))])
        resultx = conn.execute(x)
        resulty = conn.execute(y)
        for row in resultx:
            row = str(row)
            # L??sche ??berfl??ssige Zeichen mittels eines regul??ren Ausdrucks:
            row = re.search('[0123456789]+\.[01234567890]+',row)
            row = row.group(0)
            row = float(row)
            x0.append(row)
        for row in resulty:
            row = str(row)
            # L??sche ??berfl??ssige Zeichen mittels eines regul??ren Ausdrucks:
            row = re.search('[0123456789]+\.[01234567890]+',row)
            row = row.group(0)
            row = float(row)
            y0.append(row)


    ###### Bestimme Parameter xsize und ysize:

    xsize = trafo_range*2
    ysize = trafo_range*2

    ###### Bestimme ID der Lastgebiete:
    la_id = []
    for instance in session.query(orm_load_areas):
        la_id.append(instance.id)

    #############

    # Leere die Tabellen aus der DB, um Duplikate zu vermeiden
    conn.execute(orm_load_area_rest.__table__.delete().where(True))
    conn.execute(orm_ontgrids.__table__.delete().where(True))

    session.commit()

    ############# Erstelle Grids f??r alle Lastgebiete und schreibe sie in die Datenbank:

    # Erstelle geom-Spalte
    geoms = []
    for i in range (0,len(ncol)):
        # Betrachte nur Lastgebiete, die nicht sehr klein sind:
        #if area[i] > 0.25*((trafo_range*2)**2):
            # f??r gro??e Lastegbiete erstelle das Gitternetz:
         if area[i] > (3.1415926535 * trafo_maxrange**2):
            geoms.append(CreateFishnet(nrow[i],ncol[i],xsize,ysize,x0[i],y0[i]))
                # f??r kleine Lastgebiete erstelle nur die bounding box :
         elif area[i] <= (3.1415926535 * trafo_maxrange**2):
                nrow[i] = 1
                ncol[i] = 1
                geoms.append (CreateFishnet(nrow[i], ncol[i],bbox_ysize[i],bbox_xsize[i],x0[i],y0[i]))
         else:
                print ('error at line 219')
    # Erstelle la_id-Spalte
    load_area_ids = []
    for i in range (0,len(ncol)):
        # Betrachte nur Lastgebiete, die nicht sehr klein sind:
        # if area[i] > 0.25*((trafo_range*2)**2):
        for j in range (0,(ncol[i]*nrow[i])):
             load_area_ids.append(la_id[i])

    # Erstelle ID-Spalte
    ids =[]
    counter = -1
    for i in range (0,len(geoms)):
        for j in range (0,len(geoms[i])):
            counter += 1
            ids.append(counter)

    # F??lle die Tabelle  und lade sie in die Datenbank:
    grids = []
    id_counter = -1

    for i in range (0,len(geoms)):

        # Nur nicht leere Geometrien werden in die Tabelle geschrieben:
        match = re.search('0.+',str(geoms[i]))
        if match:
            for j in range(0,len(geoms[i])):
                id_counter +=1
                grids.append (orm_ontgrids(id= ids[id_counter],geom = geoms[i][j],load_area_id = load_area_ids[id_counter]))
                session.add(grids[id_counter])
                session.commit()

        else:
             pass


    ################################# Finde Mittelpunkte der Gitternetzzellen innerhalb der Lastgebiete

    # Leere die Tabelle aus der DB, um Duplikate zu vermeiden
    conn.execute(orm_onts.__table__.delete())



    # Berechne diejenigen Mittelpunkte der Gitterzellen, die innerhalb von Lastgebieten liegen:
    geoms = []
    load_area_ids = []

    s = sqla.select([func.ST_Centroid(orm_ontgrids.geom),
                     orm_load_areas.geom,
                     func.ST_Within(
                         func.ST_Centroid(orm_ontgrids.geom),
                         orm_load_areas.geom),
                    orm_ontgrids.load_area_id
                    ])\
                    .where(
                         sqla.and_(
                             func.ST_Within(
                                 func.ST_Centroid(orm_ontgrids.geom),
                                 orm_load_areas.geom
                                 ) == True,
                             orm_ontgrids.load_area_id == orm_load_areas.id
                         )
                    )
    # Schreibe Geometrien der errechneten Mittelpunkte in Liste
    result = conn.execute(s)
    for row in result:
        geoms.append(row[0])
        load_area_ids.append(row[3])
    result.close()

    # Erstelle ID-Spalte
    ids =[]
    counter = -1
    for i in range (0,len(geoms)):
        ids.append(i)

    # F??lle die Tabelle  und lade sie in die Datenbank:
    grid_centroids = []
    id_counter = -1

    for i in range (0,len(geoms)):
        grid_centroids.append (orm_onts(id= ids[i],geom = geoms[i], load_area_id = load_area_ids[i]))
        session.add(grid_centroids[i])
        session.commit()



    ################################# F??ge den Lastgebieten, die aufgrund ihrer geringen Fl??che keine ONTs zugeordnet bekommen haben, ihren Mittelpunkt als ONT-STandort hinzu

    # W??hle die Mittelpunkte der Lastgebiete, in denen sich noch kein ONT befindet

    s1 = sqla.select([orm_load_areas.geom])\
        .where(
             func.ST_Within(orm_onts.geom,orm_load_areas.geom) == True
         )

        # Fall 1: Mittelpunkt des Lastgebiets liegt innerhalb des Lastgebiets
    s = sqla.select([func.ST_Centroid(orm_load_areas.geom), orm_load_areas.id])\
        .where(
            sqla.and_(
                ~orm_load_areas.geom.in_(s1),
                func.ST_Within(func.ST_Centroid(orm_load_areas.geom),orm_load_areas.geom)
            )
        )

       # Fall 2: Mittelpunkt des Lastgebiets liegt au??erhalb des Lastgebiets. W??hle
       #         dann nicht den Mittelpunkt, sondern den PointOnSurface

    s2 = sqla.select([func.ST_PointOnSurface(orm_load_areas.geom), orm_load_areas.id])\
        .where(
            sqla.and_(
                ~orm_load_areas.geom.in_(s1),
                ~func.ST_Within(func.ST_Centroid(orm_load_areas.geom),orm_load_areas.geom)
            )
        )

    # F??ge die Punkte der ONT-Tabelle hinzu

    # Fall 1
    result = conn.execute(s)

    for row in result:
        row = orm_onts(id= len(ids),geom = row[0],load_area_id = row[1])
        ids.append(len(ids))
        session.add(row)
        session.commit()

    # Fall 2
    result = conn.execute(s2)

    for row in result:
        row = orm_onts(id= len(ids),geom = row[0],load_area_id = row[1])
        ids.append(len(ids))
        session.add(row)
        session.commit()


    ################################# Identifiziere Restgebiete innerhalb der Lastgebiete mit hohem Abstand zu ONTs





    # W??hle die Restgebiete innerhalb der Lastgebiete oberhalb eines bestimmten Abstandes zum n??chsten ONT

    s1 = func.ST_Union(orm_load_areas.geom)
    s2 = func.ST_Union(
            func.ST_Buffer (orm_onts.geom,trafo_maxrange)
            )

    exec1 = conn.execute(s1)
    exec2 = conn.execute(s2)


    for row1 in exec1:
        for row2 in exec2:
            result1 = row1[0]
            result2 = row2[0]

            s3 = func.ST_Dump(
                    func.ST_Difference(
                        result1,
                        result2
                        )
                  )

            s = sqla.select([s3])

            # F??ge das Abfrageergebnis der Datenbanktabelle hinzu
            result = conn.execute(s)
            id_ = 0

            for row in result:

                # L??sche ??berfl??ssige Zeichen mittels eines regul??ren Ausdrucks
                row = str(row)

                row = re.search(',0[01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ]+',row)
                row = row.group(0)
                row = re.search('0[01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ]+',row)
                row = row.group(0)

                # F??ge ID des Lastgebiets hinzu
                s4 = sqla.select([orm_load_areas.id]).where(func.ST_Intersects(orm_load_areas.geom,row))
                result3 = conn.execute(s4)
                for row2 in result3:

                    row3 = orm_load_area_rest(id= id_,geom = row,load_area_id = row2[0])
                #
                id_ += 1

                session.add(row3)
                session.commit()


    # W??hle die Mittelpunkte der Restgebiete und f??ge sie der ONT-Tabelle hinzu

    s = sqla.select([func.ST_Centroid(orm_load_area_rest.geom),orm_load_area_rest.load_area_id])
    result = conn.execute(s)

    for row in result:
        row = orm_onts(id= len(ids),geom = row[0], load_area_id = row[1])
        ids.append(len(ids))

        session.add(row)
        session.commit()

    ################################# Gebe allen Nutzern Lese- und Schreibrechte auf die Tabelle:


    result = conn.execute("ALTER TABLE " + orm_onts.__table_args__['schema'] +"." + orm_onts.__tablename__+ " OWNER TO oeuser;\
                  GRANT ALL ON TABLE " + orm_onts.__table_args__['schema'] + "." + orm_onts.__tablename__ + " TO oeuser WITH GRANT OPTION;")
    ################################# L??sche alle Hilfstabellen, um ??bersichtlichkeit in der Datenbank zu erhalten

    #orm_ontgrids.__table__.drop(engine, checkfirst=True)
    #orm_load_area_rest.__table__.drop(engine, checkfirst=True)

    ################################# Schlie??e Verbindungen und Prozesse
    ################################# Achtung: Verbindung zum Server wird damit unterbrochen!

#    pg_stat_activity = sqla.Table('pg_stat_activity', meta,
#                 autoload=True, autoload_with=engine)
#
#    s = sqla.select([func.pg_terminate_backend(pg_stat_activity.c.pid)]).where\
#    (pg_stat_activity.c.state == 'idle')
#
#    result = conn.execute(s)

    #conn.close()
    session.close()

    return grids


if __name__ == '__main__':

    start = time.time()

    engine = db.engine(section='oedb')

    trafo_range = cfg.get('assumptions', 'trafo_range')
    trafo_maxrange = cfg.get('assumptions', 'trafo_maxrange')

    Position_ONTs(trafo_range,
                  trafo_maxrange,
                  engine
                  )

    end = time.time()
    print('elapsed time:')
    print ((float(end - start))/60)
