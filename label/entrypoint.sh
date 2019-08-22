#!/bin/bash

# turn on bash's job control
set -m
# Exit on errors
set -e

if [ ! -f /home/osm/labels/labels.osm.pbf.ce ]; then
    echo "/home/osm/labels/labels.osm.pbf.ce does not exist. Running label pipeline."
    /usr/local/bin/update-labels
fi

export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib:/home/osm/modular_osm_label_server/lib
cd /home/osm/modular_osm_label_server
sudo -u osm /home/osm/modular_osm_label_server/start.sh &

exec bash
