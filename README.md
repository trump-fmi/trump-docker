# trump-docker

Es gibt folgende Container, zum Bauen jeweils in den Ordner gehen und dann `docker build -t slothofanarchy/trump-$ORDNERNAME .`.
Da im Client und Mapnik IPs hardgecodet sind, muss zuerst der `trump-postgis` Container (`172.17.0.2`), dann der `trump-combined` Container (`172.17.0.3`) gestartet werden.
Das lässt sich sicher noch mit `docker compose` verbessern.

## trump-postgis
`docker pull slothofanarchy/trump-postgis:latest`

Erweitert von postgis (was das offizielle postgres Dockerfile erweitert).
Erstellt die passenden Datenbanken und User und durch ein weiteres start script werden die OSM Daten (nur beim ersten Start) reingeladen, dauert ca. ne Stunde.
Mit mehr RAM für Docker könnts schneller gehen (muss man dann im osm2gis Befehl anpassen).
Wichtig ist hier beim Start das env File mit anzugeben und ein volume (benötigt ca. 4GiB) damit die Daten nicht jedes mal konvertiert werden müssen:
`docker run -v /local/path/to/data/directory:/var/lib/postgresql/data --env-file=env -t slothofanarchy/trump-postgis`.

Auf Port `5432` hört postgres mit USer `osm` und ohne Passwort.
Da könnte man noch eins setzen (muss man dann in der carto config einfügen) oder den Port nicht öffnen und die Container direkt verbinden.

## trump-combined
`docker pull slothofanarchy/trump-combined:latest`

Enthält mittlerweile folgendes:

### Mapnik (renderd mit Apache)
Hierfür wird die Verbindung zum postgres Server benötigt.
Unter der URL sollte ein Bild laden, dann tut der Teil: http://172.17.0.3/osm_tiles/0/0/0.png

### Labelserver und Pipeline
Die laufen ebenfalls hier, da sich in dem Projekt [die API `:8080/labelCollections`](http://172.17.0.3:8080/labelCollections) befindet, die beschreibt welche Endpoints vorhanden sind.
Dort wird auch der Tileserver erwähnt und vom Client benutzt, aber nur wenn dieser lokal läuft, denn die Beschreibung wird aus der lokalen `renderd.conf` geholt und mit der eigenen IP advertised.

### Frontend
[Das Frontend](http://172.17.0.3) läuft auch hierin, da die Tiles sonst von einer anderen IP geladen würden, was durch die [Same-Origin-Policy](https://de.wikipedia.org/wiki/Same-Origin-Policy) verhindert wird.
Mit [CORS](https://de.wikipedia.org/wiki/Cross-Origin_Resource_Sharing) könnte man das in renderd oder Apache erlauben, das hat beim Setzen in Apache aber nur für manche Tiles funktioniert.
