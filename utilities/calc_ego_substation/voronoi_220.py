from geoalchemy2 import Geometry
import sqlalchemy as sqla
from sqlalchemy import func
from sqlalchemy.dialects.postgresql import array

def calculate_voronoi():
    meta = sqla.MetaData()

    engine = sqla.create_engine('postgres://user:pass@oe.iks.cs.ovgu.de:5432/oedb')
    connection = engine.connect()

    ehv = sqla.Table('osm_deu_substations_ehv', meta, schema='orig_osm',
                     autoload=True, autoload_with=engine)

    sample = sqla.select(
        [func.ST_SetSRID(func.ST_Union(ehv.c.geom), 0).label('geom')]
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
        func.ST_PointN(sqla.column('g'), 1).label('p2'),
        func.ST_PointN(sqla.column('g'), 1).label('p3')
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

    #input_2 = sqla.select(func.ST_SetSRID((func.ST_Dump(func.ST_Polygonize(func.ST_Node(func.ST_LineMerge(func.ST_Union(column('v'), 

    res = connection.execute(edges)
    for result in res:
        print(result)

if __name__ == '__main__':
    calculate_voronoi()
