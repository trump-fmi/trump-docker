# trump-docker

Zum Bauen muss im Ordner `label` und `postgis` jeweils diese Datei liegen: `https://download.geofabrik.de/europe/germany/baden-wuerttemberg-latest.osm.pbf`.
Das kann man später als wget command in die Dockerfiles einfügen aber mir hat das zu lang gedauert das bei jedem Build runterzuladen.

Es gibt folgende Container, zum Bauen jeweils in den Ordner gehen und dann `docker build -t slothofanarchy/trump-$ORDNERNAME .`.
Da die IPs aktuell noch hardgecodet sind müssen die Container in der genannten Reihenfolge gestartet werden und es dürfen keine anderen Container laufen.
Das lässt sich sicher mit `docker compose` lösen.

## trump-postgis
Erweitert von postgis (was das offizielle postgres Dockerfile erweitert).
Erstellt die passenden Datenbanken und User und durch ein weiteres start script werden die OSM Daten (nur beim ersten Start) reingeladen, dauert ca. ne Stunde.
Mit mehr RAM für Docker könnts schneller gehen (muss man dann im osm2gis Befehl anpassen).
Wichtig ist hier beim Start das env File mit anzugeben und ein volume damit die Daten nicht jedes mal konvertiert werden müssen:
`docker run -v /local/path/to/data/directory:/var/lib/postgresql/data --env-file=env -t slothofanarchy/trump-postgis`.

Port 5432

## trump-label
Baut erst die Pipeline und führt sie aus und dann den labelserver

Port 8080

## trump-mapnik
Enthält mapnik mit renderd und apache2, was eine Verbindung zum postgis Container erfordert.
Man kann mit `--link` Verbindungen zwischen Containern erstellen, das sollte an sich tun.
Hierzu erst den postgis Container starten und dann den apache: `docker run -it --link $POSTGIS_CONTAINER_ID slothofanarchy/trump-apache`.

Port 80

## trump-frontend
Zeigt aktuell nur eine weiße Seite an, muss man noch fixen.

Port 80
