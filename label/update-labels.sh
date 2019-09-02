#!/usr/bin/env bash
wget -O /home/osm/input.osm.pbf "${OSM_INPUT_URL-https://download.geofabrik.de/europe/germany-latest.osm.pbf}"
cd /home/osm/label_pipeline
./bin/pipeline.sh ../config/example.conf /home/osm/input.osm.pbf
mv example_labeling.ce /home/osm/labels/labels.osm.pbf.ce
rm /home/osm/input.osm.pbf
