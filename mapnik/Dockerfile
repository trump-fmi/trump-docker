FROM debian:buster-slim

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-mapnik"
LABEL org.label-schema.description="OSM Mapnik tile server with carto style rendering"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run -itd --name trump-mapnik --network=trump --link trump-postgis -t slothofanarchy/trump-mapnik"


ENV CARTO_VERSION 4.21.1

RUN apt update && apt install --no-install-recommends -y \
	# general
	wget git sudo ca-certificates postgresql-client-11 \
	# mapnik
	libmapnik-dev apache2-dev apache2 npm mapnik-utils g++ fonts-noto \
	# mapnik api
	golang

# compile apache2 mod_tile module and renderd
RUN git clone https://github.com/openstreetmap/mod_tile.git /tmp/mod_tile
WORKDIR /tmp/mod_tile
RUN ./autogen.sh && ./configure && make -j4 && make -j4 install && make -j4 install-mod_tile 
RUN rm -rf /tmp/mod_tile

# apache mapnik config
RUN echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" > /etc/apache2/mods-available/mod_tile.load
RUN ln -s /etc/apache2/mods-available/mod_tile.load /etc/apache2/mods-enabled/
COPY ./apache-000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN useradd -mg users -s /bin/bash osm
# renderd config contains path to mapnik and mod_tile tile dir
COPY --chown=osm:users ./renderd.conf /etc/renderd.conf
# sock file needs to exist w/ permissions to start renderd directly as osm user
RUN mkdir -p /var/run/renderd && chown -R osm: /var/run/renderd
# tile cache dir
RUN mkdir -p /var/lib/mod_tile
RUN chown osm:users /var/lib/mod_tile

# generate tile style that is used by renderd
RUN npm install -g carto
USER osm
RUN git clone -b v$CARTO_VERSION https://github.com/gravitystorm/openstreetmap-carto.git /home/osm/openstreetmap-carto-$CARTO_VERSION
WORKDIR /home/osm/openstreetmap-carto-$CARTO_VERSION
# Don't place names, set correct postgis host
RUN sed -i '/placenames.mss/d' project.mml && sed -i '/Datasource:/a \ \ \ \ \ \ host: trump-postgis' project.mml
RUN ./scripts/get-shapefiles.py 
RUN carto project.mml > style.xml

# Mapnik tile API
RUN git clone https://github.com/trump-fmi/mapnik-tile-api.git
WORKDIR ./mapnik-tile-api
RUN GOPATH=/home/osm/go go get -u github.com/trump-fmi/mapnik-tile-api
RUN GOPATH=/home/osm/go go build

USER root
# remove build dependencies
RUN apt purge -y libmapnik-dev apache2-dev gdal-bin node-carto make cmake python libcairo2-dev protobuf-compiler libprotoc-dev libcgal-dev libcppunit-dev libjsoncpp-dev g++ && apt autoremove -y

COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
# 80 for tiles and frontend, 8081 for tile endpoints
EXPOSE 80 8081
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
