FROM debian:buster-slim

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-label"
LABEL org.label-schema.description="OSM dynamic label API server (extracts labels from osm.pbf)"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run -itd --name trump-label --network=trump -v trump-docker_labels:/home/osm/labels --link trump-postgis -t slothofanarchy/trump-label"


ENV CARTO_VERSION 4.21.1

RUN apt update && apt install -q -y apt-transport-https gnupg wget curl
# npm is needed for carto (mapnik style converter) and frontend
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt update && apt install -q -y \
	# general
	wget curl git sudo \
	# pipeline and labelserver
	golang cmake make python libcairo2-dev protobuf-compiler libprotoc-dev libcgal-dev libcppunit-dev libjsoncpp-dev fonts-dejavu

# Fix for pipeline dependency
RUN ln -s /usr/include/jsoncpp/json/ /usr/include/json

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
RUN git clone --recursive https://github.com/SlothOfAnarchy/label_pipeline.git /home/osm/label_pipeline
WORKDIR /home/osm/label_pipeline
RUN ./install.sh
# volume dir for labels, so that the pipeline is not ran at every start
RUN mkdir /home/osm/labels

# remove build dependencies
USER root
RUN apt purge -y make cmake python libprotoc-dev libcppunit-dev && apt autoremove -y

COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
COPY update-labels.sh /usr/local/bin/update-labels

RUN /usr/local/bin/update-labels

# 8080 for labels
EXPOSE 8080
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
