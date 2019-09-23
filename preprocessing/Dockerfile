FROM debian:buster-slim

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-preprocessing"
LABEL org.label-schema.description="Image that connects to postgis container and prepares OSM data for dynamic borders and labels"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run --network=trump-docker_default --env-file=./preprocessing/env -it slothofanarchy/trump-preprocessing:latest"

ENV CMAKE_VERSION 3.15.3

RUN apt update && apt install -y -q \
    curl wget git osm2pgsql ca-certificates make g++ \
    # needed to run area-preprocessing
    libpq-dev osmctools npm python3 python3-pip \
    # needed to build topo_simplify
    libboost-dev libcgal-dev \
    # needed for label blackbox
    libnlopt-dev pkg-config libnlopt-cxx-dev

# Install area-preprosessing module dependencies
RUN pip3 install psycopg2 jsonschema
RUN npm install -g osmtogeojson

# cmake on Debian Buster is too old to compile topo_simplify
WORKDIR /tmp
RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz
RUN tar -xzf cmake-$CMAKE_VERSION.tar.gz
WORKDIR cmake-$CMAKE_VERSION
RUN ./bootstrap && make && make install

# Cleanup
WORKDIR /tmp
RUN rm -rf cmake-$CMAKE_VERSION cmake-$CMAKE_VERSION.tar.gz

COPY env /etc/environment
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
ENTRYPOINT [ "/usr/local/sbin/entrypoint.sh" ]
