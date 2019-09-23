#!/usr/bin/env bash

# Fail immediately if one command fails
set -e

# Clean up left-over dirs
rm -rf /tmp/area-types /tmp/area-preprocessing /tmp/topo_simplify

# Clone our repos
git clone https://github.com/trump-fmi/area-types.git /tmp/area-types
git clone https://github.com/trump-fmi/area-preprocessing.git /tmp/area-preprocessing
git clone https://github.com/trump-fmi/topo_simplify.git /tmp/topo_simplify
git clone https://github.com/trump-fmi/area_labeling.git /tmp/area_labeling

# Create build folders
mkdir /tmp/topo_simplify/XFREE/build /tmp/topo_simplify/CTR/build

# Build xfree
cd /tmp/topo_simplify/XFREE/build
cmake .. && make

# Build topo_simplify
cd /tmp/topo_simplify/CTR/build
cmake .. && make

# Download source data
wget --no-verbose -O /tmp/source_data.osm.pbf "$OSM_INPUT_URL"

# Run preprocessing (osm.pbf input file is downloaded by the other osm init script)
cd /tmp/area-preprocessing
./main.py

# Remove folders in any case (even if script crashes)
trap 'cd /tmp && rm -rf topo_simplify area-preprocessing area-types' INT TERM EXIT
