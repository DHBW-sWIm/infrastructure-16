# Moodle unter Docker

## Das Container-Image

## Konfiguration

## docker-compose Datei

In der Datei [`moodle-compose.yml`](docker-compose/moodle-compose.yml) 

## Starten und Verwalten

Um Moodle und die damit verbundene Datenbank zu starten, wird folgendes Kommando verwendet:
`$ docker-compose -f moodle-compose.yml up -d`  
Dies startet die Einträge in der Datei `moodle-compose.yml` im "detached"-Modus (`-d`), die Container laufen also im Hintergrund.

Um die aktuellen Logs des Apache Webservers in dem Moodle-Container zu sehen, wird folgendes Kommando verwendet:
`$ docker logs -f swim-moodle`
Die Logs des Containers `swim-moodle` werden nun in Echtzeit angezeigt. Um die Logs des Datenbank-Containers zu sehen, wird der Name des Containers in obigem Befehl getauscht gegen `swim-moodle-db`.

Um mit der Datenbank zu interagieren, kann dieses Kommando verwendet werden:
`$ docker exec -ti swim-moodle-db mysql -u root`
Dieser Befehl führt auf dem Container interaktiv (`exec -ti`) das Kommando `mysql -u root`, welches eine Sitzung als Benutzer `root` in der Datenbank öffnet. 