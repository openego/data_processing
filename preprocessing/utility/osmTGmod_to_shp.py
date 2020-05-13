from egoio.db_tables.grid import OtgEhvhvBusDatum, OtgEhvhvBranchDatum, OtgEhvhvDclineDatum, OtgEhvhvResultsMetadatum
import os
from preprocessing.utility.download_oedb_data_to_shp import oedbtable2shp
from preprocessing.utility.utils import DOWNLOADDIR, zipdir
from sqlalchemy import func
from sqlalchemy.orm import sessionmaker
from egoio.tools import db
import zipfile


CRS = 4326


def osmTGmod2shp():

    filename_zip = "otg_ehvhv_data.zip"
    filename_bus = "otg_ehvhv_bus_data.shp"
    filename_branch = "otg_ehvhv_branch_data.shp"
    filename_dcline = "otg_ehvhv_dcline_data.shp"
    filename_results = "otg_ehvhv_results_metadata.csv"

    engine_oedb = db.connection(readonly=True)
    session = sessionmaker(bind=engine_oedb)()

    bus_query = session.query(
        OtgEhvhvBusDatum.result_id,
        OtgEhvhvBusDatum.view_id,
        OtgEhvhvBusDatum.bus_i,
        OtgEhvhvBusDatum.bus_type,
        OtgEhvhvBusDatum.pd,
        OtgEhvhvBusDatum.qd,
        OtgEhvhvBusDatum.gs,
        OtgEhvhvBusDatum.bs,
        OtgEhvhvBusDatum.bus_area,
        OtgEhvhvBusDatum.vm,
        OtgEhvhvBusDatum.va,
        OtgEhvhvBusDatum.base_kv,
        OtgEhvhvBusDatum.zone,
        OtgEhvhvBusDatum.vmax,
        OtgEhvhvBusDatum.vmin,
        OtgEhvhvBusDatum.osm_substation_id,
        OtgEhvhvBusDatum.cntr_id,
        OtgEhvhvBusDatum.frequency,
        OtgEhvhvBusDatum.osm_name,
        OtgEhvhvBusDatum.result,
        func.ST_AsText(func.ST_Transform(OtgEhvhvBusDatum.geom, CRS)).label("geom"))

    branch_query = session.query(
        OtgEhvhvBranchDatum.result_id,
        OtgEhvhvBranchDatum.view_id,
        OtgEhvhvBranchDatum.branch_id,
        OtgEhvhvBranchDatum.f_bus,
        OtgEhvhvBranchDatum.t_bus,
        OtgEhvhvBranchDatum.br_r,
        OtgEhvhvBranchDatum.br_x,
        OtgEhvhvBranchDatum.br_b,
        OtgEhvhvBranchDatum.rate_a,
        OtgEhvhvBranchDatum.rate_b,
        OtgEhvhvBranchDatum.rate_c,
        OtgEhvhvBranchDatum.tap,
        OtgEhvhvBranchDatum.shift,
        OtgEhvhvBranchDatum.br_status,
        OtgEhvhvBranchDatum.link_type,
        OtgEhvhvBranchDatum.branch_voltage,
        OtgEhvhvBranchDatum.cables,
        OtgEhvhvBranchDatum.frequency,
        OtgEhvhvBranchDatum.result,
        func.ST_AsText(func.ST_Transform(OtgEhvhvBranchDatum.geom, CRS)).label("geom"),
        func.ST_AsText(func.ST_Transform(OtgEhvhvBranchDatum.topo, CRS)).label("topo")
    )

    dcline_query = session.query(
        OtgEhvhvDclineDatum.result_id,
        OtgEhvhvDclineDatum.view_id,
        OtgEhvhvDclineDatum.dcline_id,
        OtgEhvhvDclineDatum.f_bus,
        OtgEhvhvDclineDatum.t_bus,
        OtgEhvhvDclineDatum.br_status,
        OtgEhvhvDclineDatum.pf,
        OtgEhvhvDclineDatum.pt,
        OtgEhvhvDclineDatum.qf,
        OtgEhvhvDclineDatum.qt,
        OtgEhvhvDclineDatum.vf,
        OtgEhvhvDclineDatum.vt,
        OtgEhvhvDclineDatum.pmin,
        OtgEhvhvDclineDatum.pmax,
        OtgEhvhvDclineDatum.qminf,
        OtgEhvhvDclineDatum.qmaxf,
        OtgEhvhvDclineDatum.qmint,
        OtgEhvhvDclineDatum.qmaxt,
        OtgEhvhvDclineDatum.loss0,
        OtgEhvhvDclineDatum.loss1,
        OtgEhvhvDclineDatum.link_type,
        OtgEhvhvDclineDatum.branch_voltage,
        OtgEhvhvDclineDatum.cables,
        OtgEhvhvDclineDatum.frequency,
        func.ST_AsText(func.ST_Transform(OtgEhvhvDclineDatum.geom, CRS)).label("geom"),
        func.ST_AsText(func.ST_Transform(OtgEhvhvDclineDatum.topo, CRS)).label("topo"),
        OtgEhvhvDclineDatum.result
    )

    results_query = session.query(
        OtgEhvhvResultsMetadatum.id,
        OtgEhvhvResultsMetadatum.osm_date,
        OtgEhvhvResultsMetadatum.abstraction_date,
        OtgEhvhvResultsMetadatum.applied_plans,
        OtgEhvhvResultsMetadatum.applied_year,
        OtgEhvhvResultsMetadatum.user_comment,
    )

    oedbtable2shp(bus_query, filename_bus, CRS, "geom", "view_id", zip_it=False)
    oedbtable2shp(branch_query, filename_branch, CRS, "geom", "view_id", zip_it=False)
    oedbtable2shp(dcline_query, filename_dcline, CRS, "geom", "view_id", zip_it=False)
    oedbtable2shp(results_query, filename_results, CRS, None, "id", zip_it=False)

    # zip all files into a single archive
    directories = [os.path.join(DOWNLOADDIR, os.path.splitext(f)[0]) for f in
                   [filename_bus, filename_branch, filename_dcline, filename_results]
                   ]
    with zipfile.ZipFile(
        os.path.join(DOWNLOADDIR, filename_zip),
        mode='w',
        compression=zipfile.ZIP_DEFLATED) as zf:

        for directory in directories:
            zipdir(directory, zf)
    zf.close()

if __name__== "__main__":
    osmTGmod2shp()
