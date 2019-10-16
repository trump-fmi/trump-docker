FROM debian:buster-slim

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-area"
LABEL org.label-schema.description="Python API to serve OSM borders and bended labels from postgis"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run --name trump-area --network=trump-docker_default --env-file=./area/env -itd slothofanarchy/trump-area"

RUN apt update \
  && apt install -y -q --no-install-recommends python3 git sudo python3-psycopg2 python3-jsonschema python3-aiohttp ca-certificates postgresql-client-11 \
  && apt autoremove -y \
  && apt clean \
  && rm -rf rm -rf /var/lib/apt/lists/*

RUN useradd -mg users -s /bin/bash area

USER area
RUN git clone https://github.com/trump-fmi/area-types.git /home/area/area-types
RUN git clone https://github.com/trump-fmi/area-server.git /home/area/area-server

USER root
# Server needs to be started here to reach the relative path ../area-types
WORKDIR /home/area/area-server
EXPOSE 8181
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
