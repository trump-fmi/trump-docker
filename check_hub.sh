#!//usr/bin/env bash

REGISTRY="docker.io"

for repo in $( cat docker-compose.yml|grep image|cut -d " " -f 6 ); do
    LATEST="$(wget -qO- http://$REGISTRY/v1/repositories/$repo/tags| echo $LATEST | sed "s/{//g" | sed "s/}//g" | sed "s/\"//g" | cut -d ' ' -f2)"
    RUNNING=$(docker inspect "$REGISTRY/$repo" | grep Id | sed "s/\"//g" | sed "s/,//g" |  tr -s ' ' | cut -d ' ' -f3)

    if [ "$RUNNING" == "$LATEST" ];then
        echo "Versions of $repo match, doing nothing"
    else
        echo "Running ($RUNNING) and latest version ($LATEST) of $repo differ. Restarting trump service."
        systemctl restart trump
        exit 0
    fi
done
