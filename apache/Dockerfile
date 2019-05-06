FROM debian:stretch-slim

RUN apt update && apt install -y wget libmapnik-dev apache2-dev curl unzip gdal-bin node-carto git sudo dumb-init mapnik-utils

RUN git clone https://github.com/openstreetmap/mod_tile.git
WORKDIR ./mod_tile
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install
RUN make install-mod_tile

ENV CARTO_VERSION 2.41.0
RUN useradd -mg users -s /bin/bash osm

WORKDIR /home/osm
USER osm
RUN wget https://github.com/gravitystorm/openstreetmap-carto/archive/v$CARTO_VERSION.tar.gz
RUN tar xvf v$CARTO_VERSION.tar.gz
#RUN mv ./openstreetmap-carto-$CARTO_VERSION ./openstreetmap-carto
WORKDIR ./openstreetmap-carto-$CARTO_VERSION
RUN ./get-shapefiles.sh
RUN carto project.mml > style.xml

USER root
COPY ./renderd.conf /usr/local/etc/renderd.conf
COPY ./renderd /etc/init.d/renderd
RUN apt install -y apache2 python-mapnik
RUN mkdir -p /var/lib/mod_tile
RUN chown osm:users /var/lib/mod_tile
RUN echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" > /etc/apache2/mods-available/mod_tile.load
RUN ln -s /etc/apache2/mods-available/mod_tile.load /etc/apache2/mods-enabled/
COPY ./000-default.conf /etc/apache2/sites-enabled/000-default.conf
EXPOSE 80
ENTRYPOINT /bin/bash
CMD ["/etc/init.d/renderd" "start"]
CMD ["/usr/sbin/apachectl" "start"]
# /etc/init.d/renderd start
# /usr/sbin/apachectl start
