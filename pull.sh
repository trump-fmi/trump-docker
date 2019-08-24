#!/usr/bin/env bash
git fetch;
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

old_sum=$(docker images | sha256sum)
echo "Pulling docker-compose images..."
docker-compose pull -q
new_sum=$(docker images | sha256sum)

if [[ ("$old_sum" != "$new_sum") || ("$LOCAL" != "$REMOTE") ]]; then
    echo "Images or git changed ($old_sum vs $new_sum). Restarting trump service."
    systemctl restart trump
    docker images prune
else
    echo "Images have not been changed. Doing nothing".
fi
