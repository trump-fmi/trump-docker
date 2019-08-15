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
	wget curl git sudo \
	# mapnik
	libmapnik-dev apache2-dev gdal-bin mapnik-utils apache2 python-mapnik nodejs\
	# pipeline and labelserver
	golang make python libcairo2-dev protobuf-compiler libprotoc-dev libcgal-dev libcppunit-dev libjsoncpp-dev fonts-dejavu

RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz
RUN tar -xzf cmake-$CMAKE_VERSION.tar.gz
WORKDIR cmake-$CMAKE_VERSION
RUN ./bootstrap && make && make install
WORKDIR /

# Fix for pipeline dependency
RUN ln -s /usr/include/jsoncpp/json/ /usr/include/json

# label server
RUN useradd -mg users -s /bin/bash osm
WORKDIR /home/osm
RUN mkdir /home/osm/go
RUN git clone https://github.com/trump-fmi/modular_osm_label_server.git
WORKDIR ./modular_osm_label_server
# config contains name of pbf.ce file
COPY --chown=osm:users labelserver-default.json default.json
RUN GOPATH=/home/osm/go go get -u github.com/trump-fmi/modular_osm_label_server
RUN GOPATH=/home/osm/go go build

# pipeline
WORKDIR /home/osm
RUN wget -O /home/osm/input.osm.pbf https://download.geofabrik.de/europe/germany/baden-wuerttemberg-latest.osm.pbf
RUN git clone --recursive https://github.com/trump-fmi/label_pipeline.git /home/osm/label_pipeline
WORKDIR /home/osm/label_pipeline
# modified pipeline conf with fixed font path
COPY pipeline.conf ./config/example.conf
RUN ./install.sh
WORKDIR ./bin
RUN ./pipeline.sh ../config/example.conf /home/osm/input.osm.pbf
RUN mv example_labeling.ce /home/osm/modular_osm_label_server/labels.osm.pbf.ce
RUN rm /home/osm/input.osm.pbf
WORKDIR /home/osm
RUN rm -rf label_pipeline

USER root
# remove build dependencies
RUN apt purge -y libmapnik-dev apache2-dev gdal-bin node-carto make cmake python libcairo2-dev protobuf-compiler libprotoc-dev libcgal-dev libcppunit-dev libjsoncpp-dev && apt autoremove -y

COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
# 8080 for labels
EXPOSE 8080
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

