FROM debian:buster-slim

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-preprocessing"
LABEL org.label-schema.description="Image that connects to postgis container and prepares OSM data for dynamic borders and labels"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run --network=trump-docker_default --env-file=./preprocessing/env -it slothofanarchy/trump-preprocessing:latest"

RUN apt update \
  && apt install -y -q --no-install-recommends \
    curl wget git osm2pgsql ca-certificates make g++ \
    # needed to run area-preprocessing
    libpq-dev osmctools npm python3 python3-setuptools python3-psutil python3-psycopg2 python3-jsonschema python3-numpy \
    # needed to build topo_simplify
    libboost-dev libcgal-dev \
    # needed for label blackbox
    cmake libnlopt-dev pkg-config libnlopt-cxx-dev \
  && apt autoremove -y \
  && apt clean \
  && rm -rf rm -rf /var/lib/apt/lists/*

# Install area-preprosessing module dependencies
RUN npm install -g osmtogeojson reproject

WORKDIR /tmp

COPY env /etc/environment
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
ENTRYPOINT [ "/usr/local/sbin/entrypoint.sh" ]
