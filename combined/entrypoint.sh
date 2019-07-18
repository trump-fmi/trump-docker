#!/bin/bash

# turn on bash's job control
set -m
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib:/home/osm/osm_label_server/lib
/usr/sbin/apachectl restart &
/etc/init.d/renderd restart &
cd /home/osm/osm_label_server
sudo -u osm /home/osm/osm_label_server/start.sh &
sudo -u osm /home/osm/mapnik-tile-api/mapnik-tile-api &
exec bash
