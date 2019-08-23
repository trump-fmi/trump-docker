#!/usr/bin/env bash

old_sum=$(docker images | sha256sum)
echo "Pulling docker-compose images..."
docker-compose pull -q
new_sum=$(docker images | sha256sum)

if [ "$old_sum" != "$new_sum" ]; then
	echo "Images have been changed ($old_sum vs $new_sum). Restarting trump service."
	systemctl restart trump
else
	echo "Images have not been changed. Doing nothing".
fi
