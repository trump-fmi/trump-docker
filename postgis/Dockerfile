FROM postgres:11

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-postgis"
LABEL org.label-schema.description="PostgreSQL with postgis that imports OSM data with osm2pgsql and extracts simplified area polygons"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run -id --name trump-postgis --network=trump -v trump-docker_data:/var/lib/postgresql/data --env-file=postgis/env -t slothofanarchy/trump-postgis"

ENV POSTGIS_MAJOR 2.5
ENV POSTGIS_VERSION 2.5.2+dfsg-1~exp1.pgdg90+1
ENV CMAKE_VERSION 3.15.3

RUN apt update \
    && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
    && apt install -y --no-install-recommends \
        # postgis
        postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
        postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
        postgis=$POSTGIS_VERSION \
        # general
        curl wget git osm2pgsql ca-certificates python3 python3-psycopg2 python3-jsonschema \
        # needed to run area-preprocessing
        libpq-dev osmctools \
        # needed to build both black boxes
        libcgal-dev libboost-dev g++ make \
        # needed for label blackbox
        pkg-config libnlopt-cxx-dev

# Install npm and osmtogeojson
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt update && apt install -y nodejs npm
RUN npm install -g osmtogeojson

#install cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz
RUN tar -xzf cmake-$CMAKE_VERSION.tar.gz
WORKDIR cmake-$CMAKE_VERSION
RUN ./bootstrap && make && make install
WORKDIR /

#install mpfr
RUN wget https://www.mpfr.org/mpfr-current/mpfr-$MPFR_VERSION.tar.xz
RUN tar xf mpfr-$MPFR_VERSION.tar.xz
WORKDIR mpfr-$MPFR_VERSION
RUN ./configure && make && make install
WORKDIR /

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
RUN rm -rf Python-$PYTHON_VERSION Python-$PYTHON_VERSION.tar.xz CGAL-$CGAL_VERSION CGAL-$CGAL_VERSION.tar.xz cmake-$CMAKE_VERSION cmake-$CMAKE_VERSION.tar.gz mpfr-$MPFR_VERSION mpfr-$MPFR_VERSION.tar.xz

# Entrypoint is set by postgres layers, it executes the scripts in /docker-entrypoint-initdb.d if the datadir does not exist
RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin/update-postgis
COPY ./import-osm.sh /usr/local/bin/import-osm
RUN ln -s /usr/local/bin/import-osm /docker-entrypoint-initdb.d/osm-1.sh
COPY ./update-areas.sh /usr/local/bin/update-areas
RUN ln -s /usr/local/bin/update-areas /docker-entrypoint-initdb.d/osm-2-areas.sh
COPY env /etc/environment
