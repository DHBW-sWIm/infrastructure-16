# Moodle unter Docker

Zur Entwicklung von Plugins für Moodle besteht offensichtlich der Bedarf, diese Plugins auch zu testen. Zu diesem Zweck ist eine Instanz von Moodle nötig.  
Wie bereits erwähnt, wurde beschlossen, diese Instanz mittels Docker zu betreiben, um den "operational overhead" zu minimieren.

## Das Container-Image

Die Entwickler scheinen dem Konzept von Docker gegenüber [nicht wirklich offen gegenüber zu stehen.](https://moodle.org/mod/forum/discuss.php?d=278759) Es gibt keine offiziellen Container-Images, welche verwendet werden könnten, und jene, welche durch Einzelpersonen gebaut wurden, sind meist entweder veraltet oder nicht stabil genug für einen produktiven Einsatz.

Die Firma Bitnami, welche für viele Software-Lösungen aus dem Open-Source-Bereich fertig konfigurierte Anwendungspakete bereit stellt, betreibt ein Docker-Image von Moodle, welches regelmäßig Updates erhält. Auf der [Github-Seite des Images](https://github.com/bitnami/bitnami-docker-moodle) unterstützt Bitnami Benutzer bei Problemen über die Ticket-Funktion von Github.  
Dieses Image ist leicht zu konfigurieren, schnell zu starten und wird auf absehbare Zeit durch eine vertrauenswürdige Firma mit Aktualisierungen versorgt. Aus diesen Gründen wurde sich für dieses Image entschieden.

## Konfiguration

Um das Image an die Anforderungen des Projektes anzupassen, müssen bestimmte Konfigurationen vorgenommen werden. Im Weiteren werden die Inhalte des Compose-Files asuführlich erläutert, um die Konfiguration für jeden verständlich zu machen.  
Anschließend werden weitere Konfigurationen, die einmalig nach Start des Containers durchgeführt werden müssen, ausgeführt.

### docker-compose Datei

In der Datei [`moodle-compose.yml`](docker-compose/moodle-compose.yml) findet sich die gesamte Konfiguration des Container-Images für Moodle. Im Folgenden wird Zeile für Zeile dieser Datei erläutert, um eine Umkonfiguration durch nachfolgende Administratoren zu erleichtern.



### config.php

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