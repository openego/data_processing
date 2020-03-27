import subprocess
import os


NUM_PROCESSES = 4
CACHE_SIZE = 4096


def osm2postgres(file, path, db_info):

    stylefile = os.path.join(os.path.dirname(os.path.abspath(__file__)), "oedb.style")
    pbf_file = os.path.join(path, file)

    db_info.update({"stylefile": stylefile, "pbffile": pbf_file})

    cmd = "osm2pgsql --create --slim --hstore-all --number-processes NUM_PROCESSES --cache CACHE_SIZE -H {host} -P {port} -d {database} -U {user} -p osm_deu -S {stylefile}  {pbffile}".format(**db_info)

    subprocess.run(cmd, shell=True, env={"PGPASSWORD": "egon"})


