FROM debian:stretch-slim

RUN apt update && apt install -y golang wget git make cmake python libcairo2-dev protobuf-compiler libprotoc-dev libcgal-dev libcppunit-dev libjsoncpp-dev
RUN ln -s /usr/include/jsoncpp/json/ /usr/include/json

RUN git clone https://github.com/trump-fmi/osm_label_server.git

COPY baden-wuerttemberg-latest.osm.pbf baden-wuerttemberg-latest.osm.pbf
RUN git clone --recursive https://github.com/krumpefp/label_pipeline.git
WORKDIR ./label_pipeline
COPY example.conf ./config/
RUN ./install.sh
WORKDIR ./bin
RUN apt install -y fonts-dejavu
RUN ./pipeline.sh ../config/example.conf /baden-wuerttemberg-latest.osm.pbf
RUN cp example_labeling.ce /osm_label_server/baden-wuerttemberg-latest.osm.pbf.ce
RUN rm /baden-wuerttemberg-latest.osm.pbf

WORKDIR /
RUN mkdir ./go
ENV GOPATH $PWD/go
WORKDIR ./osm_label_server
COPY default.json default.json
RUN go get -u github.com/trump-fmi/osm_label_server
RUN go build
EXPOSE 8080
ENTRYPOINT ./start.sh
#ENTRYPOINT /bin/bash

