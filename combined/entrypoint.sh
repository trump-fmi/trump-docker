#!/bin/bash

# turn on bash's job control
set -m
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib:/home/osm/osm_label_server/lib
/usr/sbin/apachectl start &
/etc/init.d/renderd start &
cd /home/osm/osm_label_server && sudo -u osm /home/osm/osm_label_server/start.sh &
exec bash
