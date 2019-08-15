FROM debian:stretch-slim

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-label"
LABEL org.label-schema.description="OSM dynamic label API server (extracts labels from osm.pbf)"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run -itd --name trump-label --network=trump --link trump-postgis -t slothofanarchy/trump-label"


ENV CARTO_VERSION 4.21.1
ENV CMAKE_VERSION 3.15.0

RUN apt update && apt install -q -y apt-transport-https gnupg wget curl
# npm is needed for carto (mapnik style converter) and frontend
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt update && apt install -q -y \
	# general
	wget curl unzip git sudo dumb-init \
	# mapnik
	libmapnik-dev apache2-dev gdal-bin mapnik-utils apache2 python-mapnik nodejs\
	# pipeline and labelserver
	golang make python libcairo2-dev protobuf-compiler libprotoc-dev libcgal-dev libcppunit-dev libjsoncpp-dev fonts-dejavu
RUN npm install -g carto
RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz
RUN tar -xzf cmake-$CMAKE_VERSION.tar.gz
WORKDIR cmake-$CMAKE_VERSION
RUN ./bootstrap && make && make install
WORKDIR /

# apache2 mod_tile module
RUN git clone https://github.com/openstreetmap/mod_tile.git
WORKDIR ./mod_tile
RUN ./autogen.sh && ./configure && make && make install && make install-mod_tile
WORKDIR /
RUN rm -rf /mod_tile

RUN useradd -mg users -s /bin/bash osm
# tile cache dir
RUN mkdir -p /var/lib/mod_tile
RUN chown osm:users /var/lib/mod_tile

# Fix for pipeline dependency
RUN ln -s /usr/include/jsoncpp/json/ /usr/include/json

# generate tile style that is used by renderd
WORKDIR /home/osm
USER osm
RUN wget https://github.com/gravitystorm/openstreetmap-carto/archive/v$CARTO_VERSION.tar.gz
RUN tar xvf v$CARTO_VERSION.tar.gz
WORKDIR ./openstreetmap-carto-$CARTO_VERSION
# Don't place names
RUN sed -i '/placenames.mss/d' project.mml
# Set correct postgis host
RUN sed -i '/Datasource:/a \ \ \ \ \ \ host: trump-postgis' project.mml
RUN ./scripts/get-shapefiles.py
RUN carto project.mml > style.xml

# label server
# TODO to move label server and pipeline to another container, the API /labelCollection has to be configured to mention the tile server running on another host. Currently this is done by parsing the local renderd config, see Mapnik tile API
WORKDIR /home/osm
RUN mkdir /home/osm/go
RUN git clone https://github.com/trump-fmi/osm_label_server.git
WORKDIR ./osm_label_server
# config contains name of pbf.ce file
COPY --chown=osm:users labelserver-default.json default.json
RUN GOPATH=/home/osm/go go get -u github.com/trump-fmi/osm_label_server
RUN GOPATH=/home/osm/go go build

# pipeline
WORKDIR /home/osm
RUN wget https://download.geofabrik.de/europe/germany/baden-wuerttemberg-latest.osm.pbf
RUN git clone --recursive https://github.com/trump-fmi/label_pipeline.git
WORKDIR ./label_pipeline
# modified pipeline conf with fixed font path
COPY pipeline.conf ./config/example.conf
RUN ./install.sh
WORKDIR ./bin
RUN ./pipeline.sh ../config/example.conf /home/osm/baden-wuerttemberg-latest.osm.pbf
RUN cp example_labeling.ce /home/osm/osm_label_server/baden-wuerttemberg-latest.osm.pbf.ce
RUN rm /home/osm/baden-wuerttemberg-latest.osm.pbf
WORKDIR /home/osm
RUN rm -rf label_pipeline

USER root
# remove build dependencies
RUN apt purge -y libmapnik-dev apache2-dev gdal-bin node-carto make cmake python libcairo2-dev protobuf-compiler libprotoc-dev libcgal-dev libcppunit-dev libjsoncpp-dev && apt autoremove -y

COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
# 8080 for labels
EXPOSE 8080
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

