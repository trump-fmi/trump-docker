FROM mdillon/postgis:9.6

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-postgis"
LABEL org.label-schema.description="PostgreSQL with postgis that imports OSM data with osm2pgsql"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd=" docker run -v ~/trump-data:/var/lib/postgresql/data --env-file=./env -t slothofanarchy/trump-postgis"

RUN apt update && apt install -y osm2pgsql wget 

ENV CARTO_VERSION 2.41.0

RUN wget https://github.com/gravitystorm/openstreetmap-carto/archive/v$CARTO_VERSION.tar.gz
RUN tar xvf v$CARTO_VERSION.tar.gz
RUN wget https://download.geofabrik.de/europe/germany/baden-wuerttemberg-latest.osm.pbf
COPY ./init-trump-postgis.sh /docker-entrypoint-initdb.d
# entrypoint is set by postgres layers, it executes the scripts in /docker-entrypoint-initdb.d if the datadir does not exist
