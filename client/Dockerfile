FROM nginx:latest

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-client"
LABEL org.label-schema.description="OpenLayers Frontend with dynamic borders and labels; proxy for the respective servers"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run --name trump-client --network=trump-docker_default --env-file=./client/env -itd slothofanarchy/trump-client"

RUN apt update \
  && apt install -q -y --no-install-recommends \
    apt-transport-https ca-certificates gnupg wget curl gettext-base \
  && apt autoremove -y \
  && apt clean \
  && rm -rf rm -rf /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt update \
  && apt install -q -y --no-install-recommends git nodejs

RUN git clone https://github.com/trump-fmi/area-simplification-client.git /tmp/area-simplification-client
WORKDIR /tmp/area-simplification-client
RUN npm install
RUN npm audit fix
RUN npm run build
RUN mv dist lib index.html config.json /usr/share/nginx/html
RUN chown -R nginx: /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
