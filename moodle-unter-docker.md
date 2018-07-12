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

`version: '2'`
Diese Zeile definiert die Version des docker-compose Files, und legt die Syntax fest. Für weitere Informationen, siehe [Compose file versions and upgrading
](https://docs.docker.com/compose/compose-file/compose-versioning/).

`services:`
Diese Zeile leitet die Konfiguration der zu startenden Container ein.

```  
mariadb:
    image: 'bitnami/mariadb:latest'
    container_name: swim-moodle-db```
Der Container "mariadb" wird definiert. Der Tag `image` definiert, welches Docker-Image verwendet werden soll. Sollte das gewählte Image lokal nicht gefunden werden, so lädt Docker es beim Start der Container herunter.  
Der Tag `container_name` definiert, mit welchem Namen der Container gestartet wird. Dieser Name gilt in Docker-internen Netzen als Hostname, und wird auch in allen Management-Tools für Docker verwendet.

  ```    
    environment:
      - MARIADB_USER=bn_moodle
      - MARIADB_DATABASE=bitnami_moodle
      - ALLOW_EMPTY_PASSWORD=yes
  ```
Über die Elemente in dem Tag `environment` werden Umgebungsvariablen an den Container übergeben 

  ```
      volumes:
      - 'mariadb_data:/bitnami'
 ```
 
 ```
       networks:
      - moodle-net
```
  moodle:
    image: 'bitnami/moodle:latest'
    container_name: swim-moodle
    labels:
      kompose.service.type: nodeport
    environment:
      - MARIADB_HOST=swim-moodle-db
      - MARIADB_PORT_NUMBER=3306
      - MOODLE_DATABASE_USER=bn_moodle
      - MOODLE_DATABASE_NAME=bitnami_moodle
      - ALLOW_EMPTY_PASSWORD=yes
    volumes:
      - '/mnt/swim/moodle-data/apache:/bitnami/apache'
      - '/mnt/swim/moodle-data/php:/bitnami/php'
      - '/mnt/swim/moodle-data/moodle:/bitnami/moodle'
    networks:
      - moodle-net
    depends_on:
      - mariadb

volumes:
  mariadb_data:
    driver: local
  moodle_data:
    driver: local

networks:
  moodle-net:
    external:
      name: moodle_moodle-net


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