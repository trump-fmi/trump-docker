FROM debian:buster-slim

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-label"
LABEL org.label-schema.description="OSM dynamic label API server (extracts labels from osm.pbf)"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run --name trump-label --network=trump-docker_default -v trump-docker_labels:/home/osm/labels --env-file=./label/env -itd slothofanarchy/trump-label"


RUN apt update \
  && apt install -y -q --no-install-recommends apt-transport-https ca-certificates gnupg wget curl \
  && apt autoremove -y \
  && apt clean \
  && rm -rf rm -rf /var/lib/apt/lists/*

# npm is needed for carto (mapnik style converter) and frontend
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt update \
  && apt install -y -q --no-install-recommends \
    # general
    wget curl git sudo \
    # pipeline and labelserver
    golang g++ make cmake python libcairo2-dev protobuf-compiler libprotoc-dev libcgal-dev libcppunit-dev libjsoncpp-dev ttf-dejavu \
  && apt autoremove -y \
  && apt clean \
  && rm -rf rm -rf /var/lib/apt/lists/*

# Fixes for pipeline dependency
RUN ln -s /usr/include/jsoncpp/json/ /usr/include/json \
  && mkdir -p /usr/share/fonts/TTF/ \
  && ln -s /usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf /usr/share/fonts/TTF/DejaVuSansMono.ttf

# label server
RUN useradd -mg users -s /bin/bash osm
WORKDIR /home/osm
USER osm
RUN mkdir /home/osm/go
RUN git clone https://github.com/trump-fmi/modular_osm_label_server.git
WORKDIR ./modular_osm_label_server
RUN echo '[{"name" : "citynames", "path" : "/home/osm/labels/labels.osm.pbf.ce"}]' > default.json
RUN GOPATH=/home/osm/go go get -u github.com/trump-fmi/modular_osm_label_server
RUN GOPATH=/home/osm/go go build

# pipeline
RUN git clone --recursive https://github.com/krumpefp/label_pipeline.git /home/osm/label_pipeline
WORKDIR /home/osm/label_pipeline
RUN ./install.sh
# volume dir for labels, so that the pipeline is not ran at every start
RUN mkdir /home/osm/labels

# remove build dependencies
USER root
RUN apt purge -y python g++ make cmake libprotoc-dev libcppunit-dev \
  && apt autoremove -y \
  && apt clean \
  && rm -rf rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
COPY update-labels.sh /usr/local/bin/update-labels

RUN /usr/local/bin/update-labels

# 8080 for labels
EXPOSE 8080
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
