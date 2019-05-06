FROM mdillon/postgis:9.6

RUN apt update && apt install -y osm2pgsql wget 
#libmapnik-dev apache2-dev curl unzip gdal-bin node-carto git sudo dumb-init mapnik-utils

ENV CARTO_VERSION 2.41.0

RUN wget https://github.com/gravitystorm/openstreetmap-carto/archive/v$CARTO_VERSION.tar.gz
RUN tar xvf v$CARTO_VERSION.tar.gz
COPY ./baden-wuerttemberg-latest.osm.pbf $PWD
COPY ./init-trump-postgis.sh /docker-entrypoint-initdb.d
