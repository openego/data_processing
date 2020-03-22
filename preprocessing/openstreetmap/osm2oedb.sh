export PGPASSWORD=egon
osm2pgsql --create --slim --hstore-all --number-processes 2 --cache 4096 -H localhost -P 54321 -d dp -U oeuser -p osm_deu -S oedb.style  bremen-latest.osm.pbf