FROM debian:stretch-slim

ENV CARTO_VERSION 2.41.0

RUN apt update && apt install -q -y wget libmapnik-dev apache2-dev curl unzip gdal-bin node-carto git sudo dumb-init mapnik-utils apache2 python-mapnik

RUN git clone https://github.com/openstreetmap/mod_tile.git
WORKDIR ./mod_tile
RUN ./autogen.sh && ./configure && make && make install && make install-mod_tile
WORKDIR /
RUN rm -rf mod_tile

COPY renderd /etc/init.d/renderd
COPY ./renderd.conf /etc/renderd.conf
RUN useradd -mg users -s /bin/bash osm
RUN mkdir -p /var/lib/mod_tile
RUN chown osm:users /var/lib/mod_tile
RUN echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" > /etc/apache2/mods-available/mod_tile.load
RUN ln -s /etc/apache2/mods-available/mod_tile.load /etc/apache2/mods-enabled/
COPY ./000-default.conf /etc/apache2/sites-enabled/000-default.conf

WORKDIR /home/osm
USER osm
RUN wget https://github.com/gravitystorm/openstreetmap-carto/archive/v$CARTO_VERSION.tar.gz
RUN tar xvf v$CARTO_VERSION.tar.gz
WORKDIR ./openstreetmap-carto-$CARTO_VERSION
COPY project.mml project.mml
RUN ./get-shapefiles.sh
RUN carto project.mml > style.xml

USER root
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
EXPOSE 80
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
