FROM debian:buster-slim

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-area"
LABEL org.label-schema.description="Python API to serve OSM borders from postgis"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run -itd --name trump-area --network=trump --link trump-postgis -t slothofanarchy/trump-area"

RUN apt update && apt install -y --no-install-recommends python3 git sudo python3-psycopg2 python3-jsonschema ca-certificates
RUN useradd -mg users -s /bin/bash area

USER area
RUN git clone https://github.com/trump-fmi/area-types.git /home/area/area-types
RUN git clone https://github.com/trump-fmi/area-server.git /home/area/area-server

# Server needs to be started here to reach the relative path ../area-types
WORKDIR /home/area/area-server
EXPOSE 8181
ENTRYPOINT ["./server.py"]
