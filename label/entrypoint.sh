#!/bin/bash

# turn on bash's job control
set -m
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib:/home/osm/modular_osm_label_server/lib
cd /home/osm/modular_osm_label_server
sudo -u osm /home/osm/modular_osm_label_server/start.sh &
exec bash
