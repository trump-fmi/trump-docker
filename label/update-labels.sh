#!/usr/bin/env bash
wget -O /home/osm/labels/input.osm.pbf "${OSM_INPUT_URL-https://download.geofabrik.de/europe/germany-latest.osm.pbf}"
wget -O /home/osm/labels/pipeline.conf "${LABEL_CONFIG_URL-https://raw.githubusercontent.com/SlothOfAnarchy/label_pipeline/master/config/example.conf}"
cd /home/osm/label_pipeline
./bin/pipeline.sh /home/osm/labels/pipeline.conf /home/osm/labels/input.osm.pbf
mv *.ce /home/osm/labels/labels.osm.pbf.ce
rm /home/osm/labels/input.osm.pbf
