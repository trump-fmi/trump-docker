FROM debian:stretch-slim

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-combined"
LABEL org.label-schema.description="OSM Mapnik tile server, dynamic label server, OpenLayers Frontend"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run -itd --name trump-combined --network=trump --link trump-postgis -t slothofanarchy/trump-combined"


ENV CARTO_VERSION 4.21.1


RUN apt update && apt install -q -y apt-transport-https gnupg wget curl
# npm is needed for carto (mapnik style converter) and frontend
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN echo "deb https://apt.kitware.com/ubuntu/ xenial main" > /etc/apt/sources.list.d/cmake.list
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -
RUN apt update && apt install -q -y \
	# general
	wget curl unzip git sudo dumb-init \
	# mapnik
	libmapnik-dev apache2-dev gdal-bin mapnik-utils apache2 python-mapnik nodejs\
	# pipeline and labelserver
	golang make cmake python libcairo2-dev protobuf-compiler libprotoc-dev libcgal-dev libcppunit-dev libjsoncpp-dev fonts-dejavu
RUN npm install -g carto


# apache2 mod_tile module
RUN git clone https://github.com/openstreetmap/mod_tile.git
WORKDIR ./mod_tile
RUN ./autogen.sh && ./configure && make && make install && make install-mod_tile
WORKDIR /
RUN rm -rf /mod_tile

# apache config
RUN echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" > /etc/apache2/mods-available/mod_tile.load
RUN ln -s /etc/apache2/mods-available/mod_tile.load /etc/apache2/mods-enabled/
COPY ./apache-000-default.conf /etc/apache2/sites-enabled/000-default.conf

# renderd service and osm user
# init.d config for renderd service. Runs under user osm and with copied config
COPY renderd-service /etc/init.d/renderd
# renderd config contains path to mapnik and mod_tile tile dir
COPY ./renderd.conf /usr/local/etc/renderd.conf
RUN useradd -mg users -s /bin/bash osm
# tile cache dir
RUN mkdir -p /var/lib/mod_tile
RUN chown osm:users /var/lib/mod_tile

# Fix for pipeline dependency
RUN ln -s /usr/include/jsoncpp/json/ /usr/include/json

# generate tile style that is used by renderd
WORKDIR /home/osm
USER osm
RUN wget https://github.com/gravitystorm/openstreetmap-carto/archive/v$CARTO_VERSION.tar.gz
RUN tar xvf v$CARTO_VERSION.tar.gz
WORKDIR ./openstreetmap-carto-$CARTO_VERSION
# Don't place names
RUN sed -i '/placenames.mss/d' project.mml
# Set correct postgis host
RUN sed -i '/Datasource:/a \ \ \ \ \ \ host: trump-postgis' project.mml
RUN ./scripts/get-shapefiles.py
RUN carto project.mml > style.xml

# label server
# TODO to move label server and pipeline to another container, the API /labelCollection has to be configured to mention the tile server running on another host. Currently this is done by parsing the local renderd config
WORKDIR /home/osm
RUN mkdir /home/osm/go
RUN git clone https://github.com/trump-fmi/osm_label_server.git
WORKDIR ./osm_label_server
# config contains name of pbf.ce file
COPY --chown=osm:users labelserver-default.json default.json
RUN GOPATH=/home/osm/go go get -u github.com/trump-fmi/osm_label_server
RUN GOPATH=/home/osm/go go build

# pipeline
WORKDIR /home/osm
RUN wget https://download.geofabrik.de/europe/germany/baden-wuerttemberg-latest.osm.pbf
RUN git clone --recursive https://github.com/trump-fmi/label_pipeline.git
WORKDIR ./label_pipeline
# modified pipeline conf with fixed font path
COPY pipeline.conf ./config/example.conf
RUN ./install.sh
WORKDIR ./bin
RUN ./pipeline.sh ../config/example.conf /home/osm/baden-wuerttemberg-latest.osm.pbf
RUN cp example_labeling.ce /home/osm/osm_label_server/baden-wuerttemberg-latest.osm.pbf.ce
RUN rm /home/osm/baden-wuerttemberg-latest.osm.pbf
WORKDIR /home/osm
RUN rm -rf label_pipeline

# frontend
# TODO to move this to a separate container, CORS must be set by renderd. Setting it in apache helped load some, but not all tiles
RUN git clone https://github.com/trump-fmi/area-simplification-client.git
WORKDIR ./area-simplification-client
USER root
RUN npm install
RUN npm audit fix
RUN npm run build
RUN mv dist lib index.html /var/www/html/
RUN chown -R www-data: /var/www/html/


# remove build dependencies
RUN apt purge -y libmapnik-dev apache2-dev gdal-bin node-carto make cmake python libcairo2-dev protobuf-compiler libprotoc-dev libcgal-dev libcppunit-dev libjsoncpp-dev && apt autoremove -y

COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
# 80 for tiles and frontend, 8080 for labels
EXPOSE 80 8080
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]

