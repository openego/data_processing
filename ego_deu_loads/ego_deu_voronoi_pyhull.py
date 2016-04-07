# -*- coding: utf-8 -*-
"""
Created on Thu Jan 14 16:40:02 2016

@author: ilka
"""

import sqlalchemy
import pandas as pd
import psycopg2
import matplotlib.pyplot as plt
import numpy as np

# Connection to database which includes data on 110 kV substations
con = sqlalchemy.create_engine('postgresql+psycopg2://user:password@localhost:5432/db')
sql = """SELECT subst_id, lon, lat FROM calc_gridcells_znes.substations_filtered"""
df = pd.read_sql_query(sql, con)
df.sort('subst_id')

# Merge the two lists together 
points = []
points = df.reset_index()[['lon', 'lat']].values.tolist()


from pyhull.voronoi import VoronoiTess
v = VoronoiTess(points)

vertices = v.vertices
points = v.points
regions = v.regions
ridges = v.ridges

# Initializing lists for loops
rel=[]
reg_vert=[]

# Create table to drop data
sql= """DROP TABLE IF EXISTS calc_gridcells_znes.voronoi_polygons"""
con.engine.execute(sql)
sql=""" CREATE TABLE calc_gridcells_znes.voronoi_polygons (
            region_id             serial PRIMARY KEY NOT NULL,
            vertices              text,
            polygon_geom          geometry);"""
con.engine.execute(sql)


for j in range(len(regions)): 

    rel=regions[j]
    
    vel=[]
    # Loop to cluster geographies per region 
    for i in range(len(rel)):
        vel.append(vertices[rel[i]])
            
    str1 = ','.join(str(e) for e in vel)
    
# Adjust format of str1 to make it readable for PostGIS
    str1 = str1.replace(',','')
    str1 = str1.replace('][',',')
    str1 = str1.replace('[','(')  
    str1 = str1.replace(']',')')
    str2 = "LINESTRING"+str1
    sql = """INSERT INTO calc_gridcells_znes.voronoi_polygons (vertices) VALUES ('{0}')""".format(str2)
    con.engine.execute(sql)
    reg_vert.append(vel)
            

sql = """Update calc_gridcells_znes.voronoi_polygons b
             set polygon_geom = ST_MakePolygon(ST_AddPoint(foo.open_line, ST_StartPoint(foo.open_line)))
             FROM (
             SELECT region_id , ST_GeomFromText(vertices,4326) As open_line from calc_gridcells_znes.voronoi_polygons) As foo
             WHERE foo.region_id = b.region_id;"""
             
con.engine.execute(sql)

sql = """ALTER TABLE calc_gridcells_znes.voronoi_polygons
         ALTER COLUMN polygon_geom TYPE geometry(POLYGON, 4326) USING ST_Transform(ST_SetSRID(polygon_geom,4326),4326);"""
con.engine.execute(sql) 



