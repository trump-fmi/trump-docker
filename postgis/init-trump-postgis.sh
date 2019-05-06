#!/bin/bash
set -e
psql -U osm -c "CREATE EXTENSION hstore; CREATE EXTENSION postgis;" -d gis
osm2pgsql --slim -U osm -d gis --hstore -S openstreetmap-carto-$CARTO_VERSION/openstreetmap-carto.style baden-wuerttemberg-latest.osm.pbf
