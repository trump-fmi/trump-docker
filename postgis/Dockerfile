FROM mdillon/postgis:11

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-postgis"
LABEL org.label-schema.description="PostgreSQL with postgis that imports OSM data with osm2pgsql and extracts simplified area polygons"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run -id --name trump-postgis --network=trump -v trump-docker_data:/var/lib/postgresql/data --env-file=postgis/env -t slothofanarchy/trump-postgis"


ENV PYTHON_VERSION 3.7.3
ENV CGAL_VERSION 4.13.1

RUN apt update && apt install -y --no-install-recommends \
    curl wget git osm2pgsql ca-certificates\
    # needed to build python 3.7.3
    build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev \
    # needed to run area-preprocessing
    libpq-dev osmctools \
    # needed to build topo_simplify
    libboost-dev g++ cmake make

# Install npm and osmtogeojson
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt update && apt install -y nodejs npm
RUN npm install osmtogeojson

WORKDIR /tmp
# python3 is needed for f strings
RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz
RUN tar xf Python-$PYTHON_VERSION.tar.xz
WORKDIR ./Python-$PYTHON_VERSION
RUN ./configure --enable-optimizations && make -j4 && make install
WORKDIR /tmp

# Install area-preprosessing module dependencies
RUN pip3 install psycopg2 jsonschema

# CGAL on Debian stretch is too old to compile topo_simplify
RUN wget https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-$CGAL_VERSION/CGAL-$CGAL_VERSION.tar.xz
RUN tar xf CGAL-$CGAL_VERSION.tar.xz
WORKDIR /tmp/CGAL-$CGAL_VERSION
RUN cmake . && make -j4 && make install

# Cleanup
WORKDIR /tmp
RUN rm -rf Python-$PYTHON_VERSION Python-$PYTHON_VERSION.tar.xz CGAL-$CGAL_VERSION CGAL-$CGAL_VERSION.tar.xz
RUN apt purge -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libpq-dev && apt autoremove -y

# Entrypoint is set by postgres layers, it executes the scripts in /docker-entrypoint-initdb.d if the datadir does not exist
COPY ./import-osm.sh /usr/local/bin/import-osm
RUN ln -s /usr/local/bin/import-osm /docker-entrypoint-initdb.d/osm.sh
COPY ./update-areas.sh /usr/local/bin/update-areas
RUN ln -s /usr/local/bin/update-areas /docker-entrypoint-initdb.d/osm-areas.sh
COPY env /etc/environment
