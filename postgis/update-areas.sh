#!/usr/bin/env bash

# Fail immediately if one command fails
set -e

# Clone our repos
git clone https://github.com/trump-fmi/area-types.git /tmp/area-types
git clone https://github.com/trump-fmi/area-preprocessing.git /tmp/area-preprocessing
git clone https://github.com/trump-fmi/topo_simplify.git /tmp/topo_simplify

# Create build folders
mkdir /tmp/topo_simplify/XFREE/build /tmp/topo_simplify/CTR/build

# Build xfree
cd /tmp/topo_simplify/XFREE/build
cmake .. && make && mv xfree /usr/local/bin/

# Build topo_simplify
cd /tmp/topo_simplify/CTR/build
cmake .. && make && mv topo_simplify /usr/local/bin/

# Run preprocessing (osm.pbf input file is downloaded by the other osm init script)
cd /tmp/area-preprocessing
./main.py

# Remove folders in any case (even if script crashes)
trap 'cd /tmp && rm -rf topo_simplify area-preprocessing area-types' INT TERM EXIT
