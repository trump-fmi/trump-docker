FROM httpd:2.4.39

RUN apt update && apt install -y git

RUN git clone https://github.com/trump-fmi/ol-labels.git
RUN mv ./ol-labels/dist /usr/local/apache2/htdocs/
COPY index.html /usr/local/apache2/htdocs/
RUN chown -R www-data: /usr/local/apache2/htdocs/

