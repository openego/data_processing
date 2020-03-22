import os
import zipfile
import subprocess


def certain_file_types(directory, extension):
    return (f for f in os.listdir(directory) if f.endswith('.' + extension))


def import_vg250(file, path, db_info, year=2019):

    zip = zipfile.ZipFile(os.path.join(path, file))
    zip.extractall(path=path)
    file_stripped, _ = os.path.splitext(file)
    file_splitted = file_stripped.split("_")
    dir1 = file_splitted[0] + "_" + str(year) + "-" + "_".join(file_splitted[1:])
    vg250_shp_path = os.path.join(path, dir1, "vg250_ebenen")
    table_date = "_" + "_".join(reversed(open(os.path.join(path, dir1, "aktualitaet.txt")).read().strip().split(".")))

    for f in certain_file_types(vg250_shp_path, "shp"):
        table_base_name, ext = os.path.splitext(f)
        tablename = table_base_name + table_date + ext
        cmd_shp = 'shp2pgsql "' + os.path.join(vg250_shp_path, f) + '" boundaries.{}'.format(tablename)
        cmd_pgql = ' | psql -h {host} -d {database} -U {user} -p {port}'.format(**db_info)
        cmd = cmd_shp + cmd_pgql

        subprocess.run(cmd, shell=True, env={"PGPASSWORD": "egon"})
