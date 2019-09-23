#!/usr/bin/env bash

# Fail when any command here fails
set -e

#until psql -h trump-postgis -U osm gis -c '\q'; do
#  >&2 echo "Postgres is unavailable - sleeping"
#  sleep 1
#done

# Download and import OSM source data if requested
if [ "${IMPORT_OSM:-true}" = true ]; then
    # Download OSM source data
    wget --no-verbose -O source_data.osm.pbf "$OSM_INPUT_URL"

    # Load rendering style
    wget --no-verbose "https://github.com/gravitystorm/openstreetmap-carto/archive/v$CARTO_VERSION.tar.gz"
    tar xvf "v$CARTO_VERSION.tar.gz"

    osm2pgsql --slim --drop --hstore --multi-geometry --keep-coastlines --unlogged --number-processes "$OSM2PGSQL_CPU" -C "$OSM2PGSQL_RAM" -H "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -S "openstreetmap-carto-$CARTO_VERSION/openstreetmap-carto.style" source_data.osm.pbf

    # OSM source is deleted below
fi

# Run area-preprocessing if requested; Compile latest binaries first
if [ "${RUN_PREPROCESSING:-true}" = true ]; then
    # Clean up left-over dirs
    rm -rf /tmp/area-types /tmp/area-preprocessing /tmp/topo_simplify

    # Clone our repos
    git clone https://github.com/trump-fmi/area-types.git /tmp/area-types
    git clone https://github.com/trump-fmi/area-preprocessing.git /tmp/area-preprocessing
    git clone https://github.com/trump-fmi/topo_simplify.git /tmp/topo_simplify
    git clone https://github.com/trump-fmi/area_labeling.git /tmp/area_labeling

    # Create build folders
    mkdir /tmp/topo_simplify/XFREE/build /tmp/topo_simplify/CTR/build /tmp/area_labeling/standalone_lib/build

    # Build xfree
    cd /tmp/topo_simplify/XFREE/build
    cmake .. && make

    # Build topo_simplify
    cd /tmp/topo_simplify/CTR/build
    cmake .. && make

    # Build area_labeling
    cd /tmp/area_labeling/standalone_lib/build
    cmake .. && make

    # Download source data
    wget --no-verbose -O /tmp/source_data.osm.pbf "$OSM_INPUT_URL"

    # Run preprocessing (osm.pbf input file is downloaded by the other osm init script)
    cd /tmp/area-preprocessing
    ./main.py

    # Cloned folders are removed below
fi

# Clean up even if script crashes
trap 'cd /tmp && rm -rf source_data.osm.pbf topo_simplify area-preprocessing area-types area_labeling' INT TERM EXIT
