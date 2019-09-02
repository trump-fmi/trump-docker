# trump-docker [![Build Status](https://travis-ci.org/trump-fmi/trump-docker.svg?branch=master)](https://travis-ci.org/trump-fmi/trump-docker)

This repository contains Docker images and a Docker compose file for the [TRUMP project](http://seeigel.informatik.uni-stuttgart.de).

## docker-compose

All Images can be found on [Docker hub](https://hub.docker.com/u/slothofanarchy) so you can just start everything with `docker-compose up`.
If you want to build the images by yourself, use `docker-compose up --build`.

Some settings like the OSM download URL can be adapted by editing [postgis/env](postgis/env) as well as [label/env](env).

## Images

The project consists of five Images, some of them depending on each other.

### trump-postgis

This image runs a postgresql database with the postgis extension to store the OSM data for Mapnik and the area server.
A volume is used to store the postgres data persistently.
On the first startup, the container will download the OSM source file and import it using `osm2pgsql` as well as extract its borders and areas using [area-preprocessing](https://github.com/trump-fmi/area-preprocessing).
These imports can also be ran manually later using `docker exec -it <container name or ID> import-osm` and `update-areas`, respectively.

### trump-mapnik

This is an image running Mapnik with apache2 and [openstreetmap-carto](https://github.com/gravitystorm/openstreetmap-carto).
It sources its OSM data from the postgis container.
It also serves the [mapnik-tile-api](https://travis-ci.org/trump-fmi/mapnik-tile-api).

### trump-label

This image runs the [modular_osm_label_server](https://github.com/trump-fmi/modular_osm_label_server), which gets its data from the [label_pipeline](https://github.com/trump-fmi/label_pipeline).
The source URL is set in the [label/env](label/env) file.
The download and conversion process may later be repeated by running `docker exec -it <container name or ID> update-labels`.

### trump-area

This image serves the [area-server](https://github.com/trump-fmi/area-server), which gets its data from the postgis container.
The [area-types](https://github.com/trump-fmi/area-types) repository is included.

### trump-client

This image serves the [area-simplification-client](https://github.com/trump-fmi/area-simplification-client) via nginx and acts as an reverse proxy to the APIs of other containers.

## systemd

If you clone this repository to `/opt/trump-docker`, you may use the provided [systemd service](trump.service) to run the project.
There is also a [service](docker-pull.service) and corresponding minutely [timer](docker-pull.timer) to update the containers if some images changed upstream.
