#!/bin/bash
set -e
# Add extensions. postgis was probably already added by Docker
psql -U "$POSTGRES_USER" -c "CREATE EXTENSION postgis;" -d "$POSTGRES_DB";
psql -U "$POSTGRES_USER" -c "CREATE EXTENSION hstore;" -d "$POSTGRES_DB";

cd /tmp
# Download OSM source data
wget -O source_data.osm.pbf "$OSM_INPUT_URL"

# Load rendering style
wget "https://github.com/gravitystorm/openstreetmap-carto/archive/v$CARTO_VERSION.tar.gz"
tar xvf "v$CARTO_VERSION.tar.gz"

osm2pgsql --slim --drop --hstore --multi-geometry --keep-coastlines --unlogged --number-processes "$OSM2PGSQL_CPU" -C "$OSM2PGSQL_RAM" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -S "openstreetmap-carto-$CARTO_VERSION/openstreetmap-carto.style" source_data.osm.pbf

rm source_data.osm.pbf
