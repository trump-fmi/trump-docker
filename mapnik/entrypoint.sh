#!/bin/bash

# turn on bash's job control
set -m

# Fail when any command here fails
set -e
/usr/sbin/apachectl restart &
sudo -u osm /home/osm/go/bin/mapnik-tile-api &


until psql -h trump-postgis -U osm gis -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

# Directly run renderd in foreground mode
exec sudo -u osm /usr/local/bin/renderd -f
