# trump-docker

work in progress

Zum Bauen muss im Ordner `label` und `postgis` jeweils diese Datei liegen: `https://download.geofabrik.de/europe/germany/baden-wuerttemberg-latest.osm.pbf`.
Das kann man später als wget command in die Dockerfiles einfügen aber mir hat das zu lang gedauert das bei jedem Build runterzuladen.

Es gibt folgende Container, zum Bauen jeweils in den Ordner gehen und dann `docker build -t slothofanarchy/trump-$ORDNERNAME .`

## trump-postgis
Erweitert von postgis (was das offizielle postgres Dockerfile erweitert)
Erstellt die passenden Datenbanken und User und durch ein weiteres start script werden die OSM Daten (nur beim ersten Start (?)) reingeladen, dauert ca. ne Stunde.
Mit mehr RAM für Docker könnts schneller gehen (muss man dann im osm2gis Befehl anpassen).
Port 5432
Wichtig ist hier beim Start das env File mit anzugeben:
`docker run --env-file=env -t slothofanarchy/trump-postgis`

## trump-apache
Zuständig für Mapnik (tile server) und später noch FrontEnd
Problem aktuell ist dass die Verbindung zu postgres im anderen Container nicht klappt.
Man kann mit `--link` Verbindungen zwischen Containern erstellen, das sollte an sich tun.
Hierzu erst den postgis Container starten und dann den apache: `docker run -it --link $POSTGIS_CONTAINER_ID slothofanarchy/trump-apache`.
Hab bisher aber nicht rausgefunden wie ich dem renderd beibringe den postgres unter der anderen IP zu nutzen (habs in der renderd.conf den HOST geändert, das hat nicht gelangt, vielleicht ist der auch für was anderes)
Port 80

## trump-label
Baut erst die Pipeline und führt sie aus und dann den labelserver
Port 8080

