# -*- coding: utf-8 -*-
"""
Created on Wed Jul 27 13:41:14 2016

@author: jonas.guetter
"""

import sqlalchemy as sqla
from sqlalchemy import func
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import sessionmaker, aliased
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql.expression import literal, join
#from numpy import *
from geoalchemy2 import Geometry
import re
from oemof import db
from egoio.tools import config as cfg
import os.path as path
import time
from sqlalchemy.dialects.postgresql import array

################################# Beziehe alle notwenigen Tabellen aus egoio:

filepath = path.join(path.dirname(path.realpath(__file__)))
cfg.load_config('config_lv_grid_districts', filepath=filepath)

SubstationDummy_name = cfg.get('voronoi auxiliaries', 'dummys')
from egoio.db_tables import calc_ego_substation as orm_calc_ego_substation
orm_dummy_onts = orm_calc_ego_substation.__getattribute__(SubstationDummy_name)

EgoDeuLoadArea_name = cfg.get('regions', 'load_areas')
from egoio.db_tables import calc_ego_loads as orm_calc_ego_loads
orm_load_areas = orm_calc_ego_loads.__getattribute__(EgoDeuLoadArea_name)

EgoDeuOnts_name = cfg.get('substations', 'onts')
from egoio.db_tables import calc_ego_substation as orm_calc_ego_onts
orm_onts = orm_calc_ego_onts.__getattribute__(EgoDeuOnts_name)

EgoDeuLvGridDistrictsVoronoi_name = cfg.get('voronoi auxiliaries', 'voronoi_polygons')
from egoio.db_tables import calc_ego_grid_district as orm_calc_ego_grid_district
orm_voronois = orm_calc_ego_grid_district.__getattribute__(EgoDeuLvGridDistrictsVoronoi_name)

EgoDeuLvGridDistrictsVoronoiCut_name = cfg.get('voronoi auxiliaries', 'voronoi_cuttings')
orm_voronoi_cuts = orm_calc_ego_grid_district.__getattribute__(EgoDeuLvGridDistrictsVoronoiCut_name)

EgoDeuLvGridDistrictsWithoutPop_name = cfg.get('grid districts', 'grid_districts_withoutpop')
orm_grid_dist_withoutpop = orm_calc_ego_grid_district.__getattribute__(EgoDeuLvGridDistrictsWithoutPop_name)

PopulationStats_name = cfg.get('statistics','population_stats')
from egoio.db_tables import orig_destatis as orm_destatis
orm_population_stats = orm_destatis.__getattribute__(PopulationStats_name)

Grid_Districts_name = cfg.get('grid districts','grid_districts')
orm_grid_districts = orm_calc_ego_grid_district.__getattribute__(Grid_Districts_name)
################################# Execute Voronoi algorithm


def CreateGridDistricts():
    

    conn = engine.connect()
    Session = sessionmaker(bind=conn)
    session = Session()
    
    ################################ Füge Dummy-Punkte in ONT-Tabelle ein
    
    s = sqla.select([orm_dummy_onts.subst_id,func.ST_Transform(orm_dummy_onts.geom,3035),orm_dummy_onts.is_dummy])
    ins = orm_onts.__table__.insert().from_select(['id','geom','is_dummy'],s)
    result = conn.execute(ins)
    
    ################################

    ################################ Erstelle Voronoi-Polygone
    sample = sqla.select(
        [func.ST_SetSRID(func.ST_Union(orm_onts.geom), 0).label('geom')]
        ).alias('sample')


    def c2l(begin, middle, end):
        return func.ST_CurveToLine(
            func.REPLACE(
                func.ST_AsText(
                    func.ST_LineMerge(
                        func.ST_Union(
                            func.ST_MakeLine(sqla.column(begin),
                                             sqla.column(middle)),
                            func.ST_MakeLine(sqla.column(middle),
                                             sqla.column(end))
                        )
                    )
                ),
                'LINE',
                'CIRCULAR'
            ),
            15
        )

    delaunay_triangles = sqla.select([
        func.ST_Dump(
            func.ST_DelaunayTriangles(sample.c.geom)).label('gd')]).alias('a')

    triangle_lists = sqla.select([
        sqla.column('(gd).Path', is_literal=True).label('id'),
        func.ST_ExteriorRing(
            sqla.column('(gd).geom', is_literal=True)
        ).label('g')]).select_from(delaunay_triangles).alias('b')

    decomposed_points = sqla.select([
        sqla.column('id'),
        func.ST_PointN(sqla.column('g'), 1).label('p1'),
        func.ST_PointN(sqla.column('g'), 2).label('p2'),
        func.ST_PointN(sqla.column('g'), 3).label('p3')
        ]).select_from(triangle_lists).alias('c')

    edges = sqla.select([
        decomposed_points.c.id,
        func.UNNEST(array(['e1', 'e2', 'e3'])).label('EdgeName'),
        func.UNNEST(array([
            func.ST_MakeLine(sqla.column('p1'), sqla.column('p2')),
            func.ST_MakeLine(
                sqla.column('p2'), sqla.column('p3')),
            func.ST_MakeLine(
                sqla.column('p3'), sqla.column('p1'))])).label('Edge'),
        func.ST_Centroid(
            func.ST_ConvexHull(
                func.ST_Union(
                    c2l('p1', 'p2', 'p3'),
                    c2l('p2', 'p3', 'p1')))).label('ct')])
    
    
    alias1 = aliased(edges)
    alias2 = aliased(edges)
    
    case_stm1 = sqla.case(
        # When
        [(func.ST_Within(alias1.c.ct, sqla.select([func.ST_ConvexHull(sample.c.geom)]).label('ConHull')),
        # Then        
        func.ST_MakePoint(
            func.ST_X(alias1.c.ct)+((func.ST_X(func.ST_Centroid(alias1.c.Edge))-
                func.ST_X(alias1.c.ct))*200),
            func.ST_Y(alias1.c.ct)+((func.ST_Y(func.ST_Centroid(alias1.c.Edge))- 
                func.ST_Y(alias1.c.ct))*200)
        )
    )])
    
    case_stm2 = sqla.case(
        # When        
        [(alias2.c.id == None, 
        # Then
        case_stm1)],
        # Else        
        else_= alias2.c.ct)
        
    voronoi_edges = sqla.select([
        func.ST_Linemerge(
            func.ST_Union(func.ST_Makeline(alias1.c.ct,case_stm2))).label('geom')
        ]).select_from(sqla.join(
            alias1,alias2,sqla.and_(
                alias1.c.id != alias2.c.id,func.ST_Equals(alias1.c.Edge,alias2.c.Edge))
            )).alias('f')
    
  
    subex = sqla.select([
            func.ST_ExteriorRing(
                     func.ST_ConvexHull(
                             func.ST_Union(
                                  func.ST_Union(
                                       func.ST_Buffer(
                                              alias1.c.Edge,
                                              20
                                              ),
                                       alias1.c.ct
                                       )
                             )
                     )
            ).label('geom')
    ])   
    

    voronoi_polygons = sqla.select([
        func.ST_SetSRID(
            (func.ST_Dump(
                func.ST_Polygonize(
                    func.ST_Node(
                        func.ST_LineMerge(
                            func.ST_Union(
                                voronoi_edges.c.geom,
                                aliased(subex).c.geom
                            )
                        )
                    )
                )
            )).geom, 
            3035).label('geom')
        ])
        

    
    ################################ Schreibe Ergebnis in Tabelle:
    
    # Vor Tabellenerzeugung lösche die Tabelle aus der DB, falls vorhanden, um Duplikate zu vermeiden
    orm_voronois.__table__.drop(engine, checkfirst=True)    
#   
#    # Erzeuge neue Tabelle
    orm_calc_ego_grid_district.Base.metadata.create_all(engine)
#
#    # Fülle die Tabelle
    ID = 0
    res = conn.execute(voronoi_polygons)
    for result in res:
        #print(result[0])
        row = orm_voronois(id= ID,geom = result[0])
        session.add(row)
        session.commit()
        ID += 1
     
    # Gebe allen Nutzern Lese- und Schreibrechte auf die Tabelle:
    result = conn.execute("ALTER TABLE " + orm_voronois.__table_args__['schema'] +
                "." + orm_voronois.__tablename__+ " OWNER TO oeuser;\
                GRANT ALL ON TABLE " + orm_voronois.__table_args__['schema'] + 
                "." + orm_voronois.__tablename__ + " TO oeuser WITH GRANT OPTION;")
    
    
   
   
#   ################################ Lösche Dummy-Punkte aus ONT-Tabelle 
    
    s = orm_onts.__table__.delete().where(orm_onts.is_dummy = True)
    result = conn.execute(s)
    
    
#    ################################ Auschneidevorgang der Voronois mit Lastgebieten
    
    cuts = sqla.select([
        func.ST_Dump(
            func.ST_Intersection(orm_load_areas.geom,orm_voronois.geom)
        )
    ]).where(sqla.and_(
        orm_load_areas.geom.intersects(orm_voronois.geom),
        ~func.ST_Geometrytype(func.ST_Intersection(orm_load_areas.geom,orm_voronois.geom)) = 'ST_LineString')
        )
    
    res = conn.execute(cuts)
    ID = 0
        
    for result in res:
        
        row = str(result[0])
           
        row = re.search('0[01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ]+',row)
        row = row.group(0)
        
        row = orm_voronoi_cuts(id=ID, geom = row)
              
        session.add(row)
        session.commit()
        ID +=1
    
################################## Füge dem Cut-Layer die notwendigen Infos für 
################################## den Merge-Vorgang hinzu
    
    # Anzahl an ONTs innerhalb der Lastgebiete
    update = sqla.update(orm_voronoi_cuts.__table__)\
    .values(ont_count = 0)     
    
    conn.execute(update)
        
    ont_nr = aliased(sqla.select([
        func.Count(orm_onts.geom).label('count'),
        orm_voronoi_cuts.id.label('id')])\
    .where(func.ST_Contains(orm_voronoi_cuts.geom, orm_onts.geom)
        )\
    .group_by(orm_voronoi_cuts.id))    
    
    update = sqla.update(orm_voronoi_cuts.__table__)\
    .where(orm_voronoi_cuts.id == ont_nr.c.id)\
    .values (ont_count = ont_nr.c.count)    
    
    conn.execute(update)
    
    # ID des innenliegenden ONT für jedes Lastgebiet, falls vorhanden
    update = sqla.update(orm_voronoi_cuts.__table__)\
    .where(func.ST_Contains(orm_voronoi_cuts.geom,orm_onts.geom))\
    .values (ont_id = orm_onts.id) 
        
    conn.execute(update)
    
    # Für Lastgebiete ohne ONTs: Finde ID des ONT, zu dem das Lastgebiet 
    # zugeordnet werden soll
    
    t1 = aliased (orm_voronoi_cuts)
    t2 = aliased (orm_voronoi_cuts)
    t3 = aliased (orm_onts)    
    
    # Finde ID des nächstgelegenen ONTs
    mins = aliased( sqla.select([ 
        orm_voronoi_cuts.id,
        func.Min(func.ST_Distance(
            func.ST_Centroid(orm_voronoi_cuts.geom),
            orm_onts.geom)
            )
        ]).select_from(sqla.join(orm_voronoi_cuts,orm_onts,
            orm_voronoi_cuts.load_area_id == orm_onts.load_area_id)
        ).group_by(orm_voronoi_cuts.id)
    )
    
    regions = aliased(orm_voronoi_cuts)
    onts = aliased(orm_onts)
    
    ex = sqla.select([regions.id, onts.id        
        ])\
        .select_from(sqla.join(onts,regions, onts.load_area_id == regions.load_area_id),
            sqla.join(mins,regions, mins.regions_id == regions.id))\
        .where( func.ST_Distance(
            func.ST_Centroid(regions.geom),
            onts.geom) = mins.distance
        )
    
    update = sqla.update(orm_voronoi_cuts.__table__)\
    .where(orm_voronoi_cuts.id == ex.c.district_id)\
    .values(merge_id = ex.c.merge_id)
      
    
    conn.execute(update)
    
    # Übertrage ID aus merge_id-Spalte in ont_id-Spalte
    
    update = sqla.update(orm_voronoi_cuts.__table__)\
    .where(orm_voronoi_cuts.ont_count == 0)\
    .values(ont_id = orm_voronoi_cuts.merge_id)
    
    conn.execute(update)
    
    ################################# Verschmelze die Lastgebiete ohne ONT mit 
    ################################# den Lastgebieten ohne ONT
    
    
    cut = aliased(orm_voronoi_cuts)
    onts = aliased(orm_onts)    
    
    exp = sqla.select([func.ST_Union(cut.geom).label('geom'),cut.ont_id\
        .label('id'), onts.load_area_id])\
    .select_from(sqla.join(cut,onts,cut.ont_id == onts.id))\
    .where(cut.ont_id >= 0)\
    .group_by(cut.ont_id,onts.load_area_id)
    
    res = conn.execute(exp)
    
    for row in res:
        row =  orm_grid_dist_withoutpop(id=row [1], geom = row[0], load_area_id = row[2])
        session.add(row)
        session.commit()        
    
#    ################################# Füge Bevölkerungszahl hinzu
    
    pts = aliased(orm_population_stats)    
    grid_dist = aliased(orm_grid_dist_withoutpop)    
    
    subex = sqla.select([func.Sum(pts.population).label('population'),
                         grid_dist.id.label('grid_district_id')])\
    .where(sqla.and_(func.ST_Contains(grid_dist.geom,pts.geom),pts.population > 0))\
    .group_by(grid_dist.id)

    pop = aliased(subex)
    t1 = aliased (orm_grid_dist_withoutpop)
    
    exp = sqla.select([t1.id,t1.geom,t1.load_area_id,pop.c.population])\
    .select_from(sqla.join(t1,pop,t1.id == pop.c.grid_district_id))
    
    res = conn.execute(exp)
    
    indexname = 'ix_'+orm_grid_districts.__table_args__['schema']+'_'+orm_grid_districts.__tablename__+'_geom'
    
      
    session.execute("DROP INDEX IF EXISTS " + orm_grid_districts.__table_args__['schema'] + '.' + indexname)
    

    for row in res:

        row =  orm_grid_districts(id=row[0], geom = row[1], load_area_id = row[2], population = row[3])
        session.add(row)
        session.commit()
        
    
    # Gebe allen Nutzern Lese- und Schreibrechte auf die Tabelle:
    result = conn.execute("ALTER TABLE " + orm_grid_districts.__table_args__['schema'] +
                "." + orm_grid_districts.__tablename__+ " OWNER TO oeuser;\
                GRANT ALL ON TABLE " + orm_grid_districts.__table_args__['schema'] + 
                "." + orm_grid_districts.__tablename__ + " TO oeuser WITH GRANT OPTION;")


    ################################# Lösche ungenutzte Tabellen   



 
if __name__ == '__main__':
    
    start = time.time()

    engine = db.engine(section='oedb')


    CreateGridDistricts()
    
    end = time.time()
    print('elapsed time:')
    print ((float(end - start))/60)
    