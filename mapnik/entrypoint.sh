#!/bin/bash

# turn on bash's job control
set -m
/usr/sbin/apachectl restart &
/etc/init.d/renderd restart &
sudo -u osm /home/osm/go/bin/mapnik-tile-api &
exec bash
