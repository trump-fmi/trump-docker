FROM debian:buster-slim

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-mapnik"
LABEL org.label-schema.description="OSM Mapnik tile server with carto style rendering"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run --name trump-mapnik --network=trump-docker_default -v trump-docker_cache:/var/lib/mod_tile --env-file=./mapnik/env -itd slothofanarchy/trump-mapnik"


ENV CARTO_VERSION 4.23.0
ENV POSTGRES_PASSWORD nieVooghee9fioSheicaizeiQueeyi2KaCh7boh2lei7xoo9CohtaeTe3mum

RUN apt update \
  && apt install -y -q --no-install-recommends \
    # general
    wget git sudo ca-certificates postgresql-client-11 \
    # mapnik
    libmapnik-dev apache2-dev apache2 npm mapnik-utils g++ fonts-noto \
    # mapnik api
    golang \
  && apt autoremove -y \
  && apt clean \
  && rm -rf rm -rf /var/lib/apt/lists/*

# compile apache2 mod_tile module and renderd
RUN git clone https://github.com/openstreetmap/mod_tile.git /tmp/mod_tile
WORKDIR /tmp/mod_tile
RUN ./autogen.sh \
  && ./configure \
  && make -j$(nproc) \
  && make -j$(nproc) install \
  && make -j$(nproc) install-mod_tile \
  && rm -rf /tmp/mod_tile

# apache mapnik config
RUN echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" > /etc/apache2/mods-available/mod_tile.load
RUN ln -s /etc/apache2/mods-available/mod_tile.load /etc/apache2/mods-enabled/
COPY ./apache-000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN useradd -mg users -s /bin/bash osm
# renderd config contains path to mapnik and mod_tile tile dir
COPY --chown=osm:users ./renderd.conf /etc/renderd.conf
# sock file needs to exist w/ permissions to start renderd directly as osm user
RUN mkdir -p /var/run/renderd \
  && chown -R osm: /var/run/renderd
# tile cache dir
RUN mkdir -p /var/lib/mod_tile
RUN chown osm:users /var/lib/mod_tile

# generate tile style that is used by renderd
RUN npm install -g carto
USER osm
RUN git clone -b v$CARTO_VERSION https://github.com/gravitystorm/openstreetmap-carto.git /home/osm/openstreetmap-carto-$CARTO_VERSION
WORKDIR /home/osm/openstreetmap-carto-$CARTO_VERSION
# Don't place names, set correct postgis host
RUN sed -i '/placenames.mss/d' project.mml \
  && sed -i '/text-fill: @placenames;/d;/text-fill: @placenames-light;/d' amenity-points.mss \
  && sed -i '/Datasource:/a \ \ \ \ \ \ host: trump-postgis' project.mml \
  && sed -i "/Datasource:/a \ \ \ \ \ \ password: $POSTGRES_PASSWORD" project.mml
RUN ./scripts/get-shapefiles.py \
 && carto project.mml > style.xml \
 && rm -rf data \
 && ln -s /home/osm/openstreetmap-carto-$CARTO_VERSION/style.xml /home/osm/current-style.xml

# Mapnik tile API
RUN git clone https://github.com/trump-fmi/mapnik-tile-api.git
WORKDIR ./mapnik-tile-api
RUN GOPATH=/home/osm/go go get -u github.com/trump-fmi/mapnik-tile-api
RUN GOPATH=/home/osm/go go build

USER root
# remove build dependencies
RUN apt purge -y libmapnik-dev apache2-dev make python libcairo2-dev g++ \
  && apt autoremove -y \
  && apt clean

COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
# 80 for tiles and frontend, 8081 for tile endpoints
EXPOSE 80 8081
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
