#!/usr/bin/env bash

# Fail if any command fails
set -e
echo "Using the following URIs"
echo "TRUMP_MAPNIK_API_URI='$TRUMP_MAPNIK_API_URI'"
echo "TRUMP_MAPNIK_URI='$TRUMP_MAPNIK_URI'"
echo "TRUMP_LABEL_URI='$TRUMP_LABEL_URI'"
echo "TRUMP_AREA_URI='$TRUMP_AREA_URI'"

# Substitute only the given env variables in the original nginx.conf and write to nginx.conf.new
envsubst '$TRUMP_MAPNIK_API_URI $TRUMP_MAPNIK_URI $TRUMP_LABEL_URI $TRUMP_AREA_URI' < /etc/nginx/nginx.conf > /etc/nginx/nginx.conf.new
# Replace old by new config (this is necessary because writing directly to nginx.conf via shell redirection results in an empty file)
mv /etc/nginx/nginx.conf.new /etc/nginx/nginx.conf

exec nginx -g 'daemon off;'
