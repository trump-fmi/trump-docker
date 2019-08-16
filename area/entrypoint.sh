#!/bin/bash

# turn on bash's job control
set -m

# Fail when any command here fails
set -e

until psql -h trump-postgis -U osm gis -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

sudo -u area ./server.py &
exec bash
