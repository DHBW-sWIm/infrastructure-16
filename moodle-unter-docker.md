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
Über die Elemente in dem Tag `environment` werden Umgebungsvariablen an den Container übergeben. Viele Container nutzen diesen Weg, um beim Start interne Konfigurationen durchzuführen. Im Falle des MariaDB-Containers wird hier ein DB-Schema angelegt (`MARIADB_DATABASE=bitnami_moodle`), ein Standard-Benutzer wird eingerichtet (`MARIADB_USER=bn_moodle`) und der Login als dieser Benutzer ohne Password wird erlaubt (`ALLOW_EMPTY_PASSWORD=yes`).

  ```
      volumes:
      - 'mariadb_data:/bitnami'
 ```
Um Daten persistent über einen Neustart des Containers zu speichern, wird ein `volume` eingerichtet. Die Schreibweise verlinkt einen Speicherplatz auf dem lokalen System (Der String vor dem Doppelpunkt) auf einen Pfad in dem Container (der Pfad nach dem Doppelpunkt).  
Sollte der String für den Speicherplatz auf dem lokalen System keinem Pfad entsprechen, wie hier in dieser Konfiguration, so legt Docker ein sogenanntes Volume an - im Grunde nur eine andere Art von Pfad, bei welcher sich Docker darum kümmert, wo die Daten persistent auf dem lokalen System gespeichert werden.
 
 ```
       networks:
      - moodle-net
```
Um verschiedene Container miteinander reden zu lassen, müssen sich diese im selben Netzwerk befinden. Zu diesem Zweck erlaubt Docker das Erzeugen von virtuellen Netzwerken. In diesem Falle sind alle Container im selben Netz, `moodle-net`.
<br>
```
  moodle:
    image: 'bitnami/moodle:latest'
    container_name: swim-moodle
```
Der Container "moodle" wird definiert. Der Tag `image` definiert, welches Docker-Image verwendet werden soll. Sollte das gewählte Image lokal nicht gefunden werden, so lädt Docker es beim Start der Container herunter.  
Der Tag `container_name` definiert, mit welchem Namen der Container gestartet wird. Dieser Name gilt in Docker-internen Netzen als Hostname, und wird auch in allen Management-Tools für Docker verwendet.

```
    labels:
      kompose.service.type: nodeport
```
Der Tag `labels` fügt Metadaten zu einer Container-Instanz hinzu. Tatsächlich scheint der Verzicht auf diese Konfiguration den Container nicht zu beeinflussen. Da Moodle aber teilweise sehr seltsame Wege geht, wurde nicht riskiert, durch Weglassen dieser Konfiguration eine Funktionalität einzuschränken.

```
    environment:
      - MARIADB_HOST=swim-moodle-db
      - MARIADB_PORT_NUMBER=3306
      - MOODLE_DATABASE_USER=bn_moodle
      - MOODLE_DATABASE_NAME=bitnami_moodle
      - ALLOW_EMPTY_PASSWORD=yes
```
Über die Elemente in dem Tag `environment` werden Umgebungsvariablen an den Container übergeben. Viele Container nutzen diesen Weg, um beim Start interne Konfigurationen durchzuführen. In diesem Fall werden die Zugangsdaten für den oben konfigurierten MariaDB-Container angegeben, um eine Verbindung aufzubauen.

```    
    volumes:
      - '/mnt/swim/moodle-data/apache:/bitnami/apache'
      - '/mnt/swim/moodle-data/php:/bitnami/php'
      - '/mnt/swim/moodle-data/moodle:/bitnami/moodle'
```
Um Daten persistent über einen Neustart des Containers zu speichern, wird ein `volume` eingerichtet. Die Schreibweise verlinkt einen Speicherplatz auf dem lokalen System (Der String vor dem Doppelpunkt) auf einen Pfad in dem Container (der Pfad nach dem Doppelpunkt).  
Der Moodle-Contaier erlaubt das Mappen von bestimmten Ordnern im Container-internen Ordner `bitnami` in die Anwendung. Zusätzliche Konfiguration in Form von Dateien kann so mit in den Container übergeben werden.  
Die Pfade auf dem lokalen System sind den eigenen Gegebenheiten entsprechend anzupassen.

```
    networks:
      - moodle-net
```

Um verschiedene Container miteinander reden zu lassen, müssen sich diese im selben Netzwerk befinden. Zu diesem Zweck erlaubt Docker das Erzeugen von virtuellen Netzwerken. In diesem Falle sind alle Container im selben Netz, `moodle-net`.

```
    depends_on:
      - mariadb
```
Der Tag `depends_on` definiert, welcher Container zuerst gestartet werden soll, bevor der aktuelle Container starten darf. Hier startet der Container "moodle" erst, nachdem der Container "mariadb" läuft - dies verhindert Abstürze von Moodle, weil die Datenbank nicht erreichbar ist. Sollte der Container "mariadb" noch starten und keine Verbindungen akzeptieren, wird Moodle abstürzen.
<br>

```
volumes:
  mariadb_data:
    driver: local
  moodle_data:
    driver: local
```
Unabhänging von den Containern werden lokale Volumes definiert. Die Konfiguration mit dem Treiber `local` bedeutet lediglich, dass die Daten auf Host-System gespeichert werden sollen.

```
networks:
  moodle-net:
    external:
      name: moodle_moodle-net
```
Um die Container in einem Netz zu verbinden, muss ein Netzwerk existieren. hier wird das Netzwerk `moodle-net` definiert, dass sich nach außen hin für Container, welche nicht über diese docker-compose Datei definiert wurden, als `moodle_moodle-net` zeigt.

<br>

### config.php

In der Datei `config.php` liegt in dem Moodle-Conbtainer die interne Konfiguration für Moodle.  
Um während der Entwicklung Debugging-Informationen und Fehlermeldungen zu erhalten, müssen enige Zeilen in diese Datei hinzugefügt werden. Dafür verbindet man sich einfach auf den Container (`docker exec -ti $CONTAINERNAME bash`, wobei $CONTAINERNAME durch den tatsächlichen Namen des Containers ersetzt werden muss), und bearbeitet die Datei dort mit dem Editor `nano`:
`nano /opt/bitnami/moodle/config.php`  
Dort müssen folgende Zeilen hinzugefügt werden:

```PHP
@error_reporting(E_ALL | E_STRICT); // NOT FOR PRODUCTION SERVERS!
@ini_set('display_errors', '1');    // NOT FOR PRODUCTION SERVERS!
$CFG->debug = (E_ALL | E_STRICT);   // === DEBUG_DEVELOPER - NOT FOR PRODUCTION SERVERS!
$CFG->debugdisplay = 1;             // NOT FOR PRODUCTION SERVERS!
```

Es ist nicht nötig, die Datei in irgendeiner Form neu zu laden - die Änderungen werden direkt angewandt.

**Es gilt zu beachten, dass diese Änderungen den Neustart des Containers nicht überstehen und dann erneut durchgeführt werden müssen.**

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

Ein Backup der aktuellen Datenbank (Stand 18.07.2018 14:58) findet sich [hier](moodle-db/moodle.sql).


*****************

[Next - Chapter 4: Activiti unter Docker](activiti-unter-docker.md)
  
[Previous - Chapter 2: Docker](docker.md)