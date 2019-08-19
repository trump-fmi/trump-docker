FROM nginx:latest

LABEL maintainer="slothofanarchy1@gmail.com"
LABEL org.label-schema.name="slothofanarchy/trump-client"
LABEL org.label-schema.description="OpenLayers Frontend with dynamic borders and labels"
LABEL org.label-schema.vcs-url="https://github.com/trump-fmi/trump-docker"
LABEL org.label-schema.docker.cmd="docker run -itd --name trump-client --network=trump -t slothofanarchy/trump-client"

RUN apt update && apt install -q -y apt-transport-https gnupg wget curl
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt update && apt install -q -y git nodejs

RUN git clone https://github.com/trump-fmi/area-simplification-client.git /tmp/area-simplification-client
WORKDIR /tmp/area-simplification-client
RUN npm install
RUN npm audit fix
RUN npm run build
RUN mv dist lib index.html config.json /usr/share/nginx/html
RUN chown -R nginx: /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
