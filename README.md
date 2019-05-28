# trump-docker

## Container
Es gibt folgende Container, zum Bauen jeweils in den Ordner gehen und dann `docker build -t slothofanarchy/trump-$(basename $PWD) .`.

### trump-postgis
`docker pull slothofanarchy/trump-postgis:latest`

Erweitert von postgis (was das offizielle postgres Dockerfile erweitert).
Für die richtige Konfiguration der Datenbank muss das Environment-File `postgis/env` mit angegeben werden.
Es empfiehlt sich außerdem ein Volume mit anzugeben, da bei einer leeren Datenbank die OSM-Daten für Baden-Württemberg heruntergeladen und importiert werden, was ca. eine Stunde dauert.

Auf Port `5432` hört postgres mit User `osm` und ohne Passwort.
Da könnte man noch eins setzen (muss man dann in der carto config einfügen) oder den Port nicht öffnen da sich die Container im gleichen Netz befinden.

### trump-combined
`docker pull slothofanarchy/trump-combined:latest`

Enthält mittlerweile folgendes:

#### Mapnik (renderd mit Apache)
Hierfür wird die Verbindung zum postgres Server benötigt.
Unter der URL sollte ein Bild laden, dann tut der Teil: http://172.17.0.3/osm_tiles/0/0/0.png

#### Labelserver und Pipeline
Die laufen ebenfalls hier, da sich in dem Projekt [die API `:8080/labelCollections`](http://172.17.0.3:8080/labelCollections) befindet, die beschreibt welche Endpoints vorhanden sind.
Dort wird auch der Tileserver erwähnt und vom Client benutzt, aber nur wenn dieser lokal läuft, denn die Beschreibung wird aus der lokalen `renderd.conf` geholt und mit der eigenen IP advertised.

#### Frontend
[Das Frontend](http://172.17.0.3) läuft auch hierin, da die Tiles sonst von einer anderen IP geladen würden, was durch die [Same-Origin-Policy](https://de.wikipedia.org/wiki/Same-Origin-Policy) verhindert wird.
Mit [CORS](https://de.wikipedia.org/wiki/Cross-Origin_Resource_Sharing) könnte man das in renderd oder Apache erlauben, das hat beim Setzen in Apache aber nur für manche Tiles funktioniert.

## Usage

Alle Befehle beziehen sich auf das Rootverzeichnis als working directory.

### docker-compose

`docker-compose up --build`

### Einzelne Container

Zuerst muss ein Netzwerk für die Container erstellt werden: `docker network create trump`

Danach können die Container einzeln gestartet werden:
`docker run -id --name trump-postgis --network=trump -v trump-docker_data:/var/lib/postgresql/data --env-file=postgis/env -t slothofanarchy/trump-postgis`
`docker run -itd --name trump-combined --network=trump --link trump-postgis -t slothofanarchy/trump-combined`
