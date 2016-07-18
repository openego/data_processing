# -*- coding: utf-8 -*-
"""
Created on Thu Jul  7 11:43:11 2016

@author: jonas.guetter
"""

import sqlalchemy as sqla
from sqlalchemy import func
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql.expression import literal
from numpy import *
from geoalchemy2 import Geometry
import re



def Position_ONTs(trafo_range,trafo_maxrange, db_connection,db_input_table,db_output_table_grids,
                  db_output_table_onts,db_output_table_load_areas_rest,input_schema,output_schema):


    meta = sqla.MetaData()
    engine = sqla.create_engine(db_connection, echo=False)
    connection = engine.connect() 
    Session = sessionmaker(bind=engine)
    session = Session()

    ################################# Erstelle Gitternetze für alle Lastgebiete

    # Öffne Tabelle, in der die Lastgebiete enthalten sind:
    load_areas = sqla.Table(db_input_table, meta, schema=input_schema,
                 autoload=True, autoload_with=engine)   
                 
    def CreateFishnet(nrow, ncol, xsize, ysize, x0, y0):
        
        # Konstruiere eine Gitterzelle:        
        cell = func.ST_GeomFromText(('POLYGON((0 0, 0' + ' ' + str(xsize) 
            + ',' + str(ysize) + ' ' + str(xsize) + ',' + str(ysize) + ' ' + '0,0 0))'),3035)
            

        # Dupliziere die Zelle für jede Position im Gitter einmal:
        if ncol > 0 and nrow > 0:
            
            geoms = []
            for i in range(0,ncol):
                for j in range(0,nrow):
                    query = sqla.select(
                        [func.ST_Translate(cell,i*xsize+x0,j*ysize+y0)]
                        ).alias('geom')
                    result = connection.execute(query)
                    for row in result:
                        row = str(row)
                        # Filtere mittels regulärem Ausdruck nur den relevanten Teil der Zeichenkette:
                        row = re.search('[0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ]+',row)  
                        row = row.group(0)
                        geoms.append(row)

            return geoms
        # Falls nrow oder ncol 0 sind, gebe leere Geometrie zurück:
        else:
            geom = 'POLYGON EMPTY'
#            print(geom)
            return geom
    


    ############# Bestimme Parameter für CreateFishnet-Funktion:    
           
    
    ###### Bestimme Parameter nrow (Anzahl der Zeilen):
    nrow = []
    # Bestimme nrow mittels SQL-Abfrage:    
    for instance in session.query(load_areas):
         s = sqla.select([ (func.ROUND((func.ST_ymax(func.ST_Extent(instance.geom)) -  
             func.ST_ymin(func.ST_Extent(instance.geom))) /(trafo_range*2)))])
         result = connection.execute(s)
         # Wandle Datentyp um:        
         for row in result:
             row = str(row)
             # Lösche überflüssige Zeichen mittels eines regulären Ausdrucks:
             row = re.search('[0123456789]+',row)
             row = row.group(0)
             row = int(row)
             nrow.append(row)
    
         
    result.close()

    
    ###### Bestimme Parameter ncol (Anzahl der Spalten):
    ncol = []
    # Bestimme nrow mittels SQL-Abfrage:
    for instance in session.query(load_areas):
         s = sqla.select([ (func.ROUND((func.ST_xmax(func.ST_Extent(instance.geom)) -  
             func.ST_xmin(func.ST_Extent(instance.geom))) /(trafo_range*2)))])
         result = connection.execute(s)
         # Wandle Datentyp um:        
         for row in result:
             row = str(row)
             # Lösche überflüssige Zeichen mittels eines regulären Ausdrucks:
             row = re.search('[0123456789]+',row)
             row = row.group(0)
             row = int(row)
             ncol.append(row)
    
         
    result.close()

    ###### Bestimme Parameter x0 und y0:
    x0 = []
    y0 = []
    for instance in session.query(load_areas):
        x = sqla.select([func.ST_xmin(func.box2d(instance.geom))])
        y = sqla.select([func.ST_ymin(func.box2d(instance.geom))])
        resultx = connection.execute(x)
        resulty = connection.execute(y)
        for row in resultx:
            row = str(row)
            # Lösche überflüssige Zeichen mittels eines regulären Ausdrucks:
            row = re.search('[0123456789]+\.[01234567890]+',row)
            row = row.group(0)
            row = float(row)
            x0.append(row)
        for row in resulty:
            row = str(row)
            # Lösche überflüssige Zeichen mittels eines regulären Ausdrucks:
            row = re.search('[0123456789]+\.[01234567890]+',row)
            row = row.group(0)
            row = float(row)
            y0.append(row)
        
    ###### Bestimme Parameter xsize und ysize:

    xsize = trafo_range*2
    ysize = trafo_range*2
    
    ############# Erstelle Grids für alle Lastgebiete und schreibe sie in die Datenbank:
    
    # Erstelle neue Tabelle für die Gitternetze:

    Base = declarative_base()
    
    

    class ego_deu_ontgrids_test100(Base):
        __tablename__ = db_output_table_grids
        __table_args__ = {"schema": output_schema}

        id = Column(Integer, primary_key=True)
        geom = Column(Geometry(geometry_type="POLYGON", srid=3035))
    
    #ego_deu_ontgrids_test100.__table__.drop(engine, checkfirst=True)
    
    Base.metadata.create_all(engine)
    

       
    # Erstelle geom-Spalte
    geoms = []
    for i in range (0,len(ncol)):
        geoms.append(CreateFishnet(nrow[i],ncol[i],xsize,ysize,x0[i],y0[i]))
    
    # Erstelle ID-Spalte
    ids =[]
    counter = -1
    for i in range (0,len(geoms)):
        for j in range (0,len(geoms[i])):
            counter += 1
            ids.append(counter)
   
    # Fülle die Tabelle  und lade sie in die Datenbank:
    grids = []
    id_counter = -1

    for i in range (0,len(geoms)):
        
        # Nur nicht leere Geometrien werden in die Tabelle geschrieben:
        match = re.search('0.+',str(geoms[i]))        
        if match:
            for j in range(0,len(geoms[i])):
                id_counter +=1
                grids.append (ego_deu_ontgrids_test100(id= ids[id_counter],geom = geoms[i][j]))
                session.add(grids[id_counter])
                session.commit()

        else:
             pass           
    
    
    ################################# Finde Mittelpunkte der Gitternetzzellen innerhalb der Lastgebiete
    
    # Erstelle neue Tabelle für die Zellenmittelpunkte:    
    class ego_deu_onts_test100(Base):
        __tablename__ = db_output_table_onts
        __table_args__ = {"schema": output_schema}

        id = Column(Integer, primary_key=True)
        geom = Column(Geometry(geometry_type="POINT", srid=3035))

    #ego_deu_onts_test100.__table__.drop(engine, checkfirst=True)    
    
    Base.metadata.create_all(engine)
    
    # Öffne Tabelle, in der die Gitterzellen enthalten sind:
    grid_cells = sqla.Table(db_output_table_grids, meta, schema=output_schema,
                 autoload=True, autoload_with=engine)  
                 
    # Berechne diejenigen Mittelpunkte der Gitterzellen, die innerhalb von Lastgebieten liegen:
    geoms = []   

    s = sqla.select([func.ST_Centroid(grid_cells.c.geom), 
                     load_areas.c.geom, 
                     func.ST_Within(
                         func.ST_Centroid(grid_cells.c.geom),
                         load_areas.c.geom)
                    ])\
                    .where(
                         func.ST_Within(
                             func.ST_Centroid(grid_cells.c.geom),
                             load_areas.c.geom
                         ) == True
                    )
    # Schreibe Geometrien der errechneten Mittelpunkte in Liste
    result = connection.execute(s)
    for row in result:
        geoms.append(row[0])
    result.close()
    
    # Erstelle ID-Spalte
    ids =[]
    counter = -1
    for i in range (0,len(geoms)):
        ids.append(i)
    
    # Fülle die Tabelle  und lade sie in die Datenbank:
    grid_centroids = []
    id_counter = -1
    
    for i in range (0,len(geoms)):
        grid_centroids.append (ego_deu_onts_test100(id= ids[i],geom = geoms[i]))
        session.add(grid_centroids[i])
        session.commit()

    
    
    ################################# Füge den Lastgebieten, die aufgrund ihrer geringen Fläche keine ONTs zugeordnet bekommen haben, ihren Mittelpunkt als ONT-STandort hinzu
    
    # Öffne Tabelle, in der die ONT-Standorte enthalten sind:
    onts = sqla.Table(db_output_table_onts, meta, schema=output_schema,
                 autoload=True, autoload_with=engine)
    
    # Wähle die Lastgebiete, in denen sich noch kein ONT-STandort befindet
    
    s1 = sqla.select([load_areas.c.geom])\
        .where(
             func.ST_Within(onts.c.geom,load_areas.c.geom) == True
         )
    # Wähle die Mittelpunkte dieser Lastgebiete
    
    s = sqla.select([func.ST_Centroid(load_areas.c.geom)])\
        .where(
            ~load_areas.c.geom.in_(s1)
        )    
    
    # Füge die Mittelpunkte der ONT-Tabelle hinzu
    result = connection.execute(s)
    
    for row in result:
        row = ego_deu_onts_test100(id= len(ids),geom = row[0])
        ids.append(len(ids))
        session.add(row)
        session.commit()
    
    
    ################################# Identifiziere Restgebiete innerhalb der Lastgebiete mit hohem Abstand zu ONTs
    
    # Erstelle neue Tabelle für die Restgebiete:    
    class ego_deu_load_area_rest_test100(Base):
        __tablename__ = db_output_table_load_areas_rest
        __table_args__ = {"schema": output_schema}

        id = Column(Integer, primary_key=True)
        geom = Column(Geometry(geometry_type="POLYGON", srid=3035))
    
    #ego_deu_load_area_rest_test100.__table__.drop(engine, checkfirst=True)
    
    Base.metadata.create_all(engine)
    
    # Wähle die Restgebiete innerhalb der Lastgebiete oberhalb eines bestimmten Abstandes zum nächsten ONT

    s1 = func.ST_Union(load_areas.c.geom)
    s2 = func.ST_Union(
            func.ST_Buffer (onts.alias().c.geom,trafo_maxrange)
            )
        
    s3 = func.ST_Dump(
            func.ST_Difference(
                s1,
                s2
            )
         )
         
    s = sqla.select([s3])
    
    # Füge das Abfrageergebnis der Datenbanktabelle hinzu    
    result = connection.execute(s)
    id_ = 0
    
    for row in result:
        # Lösche überflüssige Zeichen mittels eines regulären Ausdrucks        
        row = str(row)
        row = re.search('0[01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ]+',row)
        row = row.group(0)
        row = ego_deu_load_area_rest_test100(id= id_,geom = row)
        
        id_ += 1
        session.add(row)
        session.commit()
    
    # Öffne Tabelle, in der die Restgebiete enthalten sind:
    onts = sqla.Table(db_output_table_load_areas_rest, meta, schema=output_schema,
                 autoload=True, autoload_with=engine) 
                 
    # Wähle die Mittelpunkte der Restgebiete und füge sie der ONT-Tabelle hinzu
    
    s = sqla.select([func.ST_Centroid(onts.c.geom)])  
    result = connection.execute(s)
    
    for row in result:
        row = ego_deu_onts_test100(id= len(ids),geom = row[0])
        ids.append(len(ids))

        session.add(row)
        session.commit()      
    
    ################################# Schließe Verbindungen und Prozesse
    ################################# Achtung: Verbindung zum Server wird damit unterbrochen!

    pg_stat_activity = sqla.Table('pg_stat_activity', meta,
                 autoload=True, autoload_with=engine)    
    
    s = sqla.select([func.pg_terminate_backend(pg_stat_activity.c.pid)]).where\
    (pg_stat_activity.c.state == 'idle' ) 

    result = connection.execute(s)    
    
    connection.close()
    session.close()
    
    return grids

    