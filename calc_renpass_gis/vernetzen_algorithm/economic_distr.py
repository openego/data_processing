# -*- coding: utf-8 -*-
from geoalchemy2 import Geometry
from geoalchemy2.shape import to_shape
from sqlalchemy.sql import func
from db import (FederalStates, CosmoClmGrid, GeoPotArea, Timeseries, Datatype,
                ScenarioCapacities, Located, Scheduled, Typified, Spatial,
                Year, GridDistrict, session)
from helper import seq
from shapely.wkb import loads
from sqlalchemy import and_
from itertools import chain
from multiprocessing import Pool, cpu_count, Process
from numpy import mean
from itertools import groupby

# DATA IMPORT
###############################################################################

print("Database connection established.")

# import white area including coastdat id
ww_isection = session.query(CosmoClmGrid.gid,
                            func.ST_Intersection(CosmoClmGrid.geom,
                                            GeoPotArea.geom)).\
    filter(func.ST_Intersects(GeoPotArea.geom, CosmoClmGrid.geom))

ww_isection = [(wid, loads(bytes(geom.data))) for
          wid, geom in ww_isection]

# import grid districts
gds = session.query(GridDistrict.subst_id,
                    func.ST_Transform(GridDistrict.geom, 4326))
gds = [(sid, to_shape(geom)) for sid, geom in gds]

# import weadata data for Germany (roughly bounding box in cosmoclmgrid)
weadata = session.query(Spatial.gid, Timeseries.tsarray).\
    join(Located, Located.spatial_id == Spatial.gid).\
    join(Timeseries, Located.data_id == Timeseries.id).\
    join(Scheduled, Scheduled.data_id == Timeseries.id).\
    join(Year, Scheduled.time_id == Year.year).\
    join(Typified, Typified.data_id == Timeseries.id).\
    join(Datatype, Typified.type_id == Datatype.id).\
    filter(Year.year == 2011).\
    filter(and_(Spatial.gid / 1000 > 1115, Spatial.gid / 1000 < 1144,
                Spatial.gid % 1000 > 70, Spatial.gid % 1000 < 110)).\
    filter(Datatype.name == "WSS_10M")

weadata = weadata.all()

print("Data export finished.")

# DATA HANDLING
###############################################################################
# import pickle
# ww_isection = pickle.load(open("ww_isection.p", "rb"))
# gds = pickle.load(open("gds.p", "rb"))
# weadata = pickle.load(open("weadata.p", "rb"))
# cont = pickle.load(open("cont.p", "rb"))


# expand shapely MultiPolygons
ww_isection = [(wid, geo) for wid, geom in ww_isection for geo in seq(geom)]

gds = [(sid, geo) for sid, geom in gds for geo in seq(geom)]


# try to make polygons valid
ww_isection = [(wid, geom.buffer(0)) for wid, geom in ww_isection]
gds = [(sid, geom.buffer(0)) for sid, geom in gds]

# calc mean wind speed on 10m
weadata = {gid: mean(tsarray) for gid, tsarray in weadata}


def isection(n, m):
    for *k, g in n:
        for *kk, gg in m:
            if g.intersects(gg):
                yield (kk + k + [g.intersection(gg)])


cont = list(isection(ww_isection, gds))

cont = [tuple(k) + (g.area,) for *k, geom in cont for g in seq(geom)]

# add weather data
cont = [(sid, weadata[wid], area) for sid, wid, area in cont]


temp = cont

temp.sort(key=lambda x: x[0])

#TODO: transform unit to m^2
A = {} # total white area per grid district in m^2
Y = {} # average wind speed per grid district in m/s
I = {} #
A_occupied = {}
A_total = 2


gds = list(set([sid for sid, geom in gds]))

for sid, dss in groupby(temp, lambda x: x[0]):
    A[sid] = sum(list(area for sid, meanws, area in
                            (ds for ds in dss)))

for sid, dss in groupby(temp, lambda x: x[0]):
    Y[sid] = sum(list(meanws * area for sid, meanws, area in
                      (ds for ds in dss))) / A[sid]


# add 0 values
addkeys(gds, Y)
addkeys(gds, A)

# ALGORITHM
###############################################################################


def distribute(gds, A_n):
    Y_SUM = sum([Y[d] for d in gds])
    for d in gds:
        I[d] = Y[d] / Y_SUM
        update(d, I[d] * A_n)


def update(d, A_n):
    A_occupied[d] = A_n

def solution_not_found():
    cond = [A_occupied[d] <= A[d] for d in gds]
    return set(cond) != {True}

A_sub = A_total
gds_sub = gds.copy()

distribute(gds_sub, A_total)

count = 0
while solution_not_found():
    count += 1
    print(count)
    for d in gds_sub.copy():
        if A_occupied[d] > A[d]:
            update(d, A[d])
            A_sub -= A[d]
            print(A_sub)
            gds_sub.remove(d)
    distribute(gds_sub, A_sub)
