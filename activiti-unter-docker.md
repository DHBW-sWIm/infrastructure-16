# Activiti unter Docker


## Das Container-Image

Activiti stellt zwar eine Sammlung von Container bereit, für den Start einer einzelnen Instanz wären jedoch mindestens 5 Container mit umfassender Konfiguration nötig gewesen, welche ausschließlich für Entwicklungszwecke gedacht sind.  
Die von der Community entwickelten Images beruhen meist auf der Activiti-Version 5.8.x. Nach ausführlichen Tests stellte sich heraus, dass in dieser Version und allen getesteten Images mit dieser Version die REST API nicht voll funktionstüchtig war:  
Neu instanziierte Prozesse waren über die API nicht abrufbar. Damit waren diese Images für den Einsatz im Projektumfeld ungeeignet.

Ein eigenes Image mit Activiti 6.0 wurde erstellt. Der Prozess der Containererzeugung ist im Folgenden dokumentiert, um ein Upgrade auf höhere Versionen zu ermöglichen.

### Dockerfile

Das Dockerfile basiert auf dem offiziellen OpenJDK Docker Container mit Java 1.8. Es isntalliert den Webserver Apache Tomcat nach und implementiert Activiti in der Version 6.0.0. Einzelne vorkonfigurierte Dateien werden in das Image kopiert. 

Weitere Details finden sich in der Konfiguration im [Dockerfile](Activiti-Dockerfile/Dockerfile) des Images.

## Konfiguration
Die Konfiguration dieses Containers und der zugehörigen Datenbank findet ausschließlich über die docker-compose Datei statt. Eine weitere Konfiguration ist nicht nötig.

### docker-compose Datei

In der Datei [`activiti-compose.yml`](docker-compose/activiti-compose.yml) findet sich die gesamte Konfiguration des Container-Images für Moodle. Im Folgenden wird Zeile für Zeile dieser Datei erläutert, um eine Umkonfiguration durch nachfolgende Administratoren zu erleichtern.

`version: '2'`
Diese Zeile definiert die Version des docker-compose Files, und legt die Syntax fest. Für weitere Informationen, siehe [Compose file versions and upgrading
](https://docs.docker.com/compose/compose-file/compose-versioning/).

`services:`
Diese Zeile leitet die Konfiguration der zu startenden Container ein.

```
  activiti:
    image: lengers/activiti:6.0.0
    container_name: "swim-activiti"
```
Der Container "activiti" wird definiert. Der Tag `image` definiert, welches Docker-Image verwendet werden soll. Sollte das gewählte Image lokal nicht gefunden werden, so lädt Docker es beim Start der Container herunter.
Der Tag `container_name` definiert, mit welchem Namen der Container gestartet wird. Dieser Name gilt in Docker-internen Netzen als Hostname, und wird auch in allen Management-Tools für Docker verwendet.

```
    environment:
      DB_TYPE: "h2"
      DB_HOST: "swim-activiti-h2"
      DB_PORT: 1521
      DB_PASS: ""                                                                         
      DB_USER: "sa"
      DB_NAME: "/opt/h2-data/activiti"
```
Über die Elemente in dem Tag `environment` werden Umgebungsvariablen an den Container übergeben. Viele Container nutzen diesen Weg, um beim Start interne Konfigurationen durchzuführen. Im Falle des Activiti-Containers wird hier die DB definiert  (`DB_NAME: "/opt/h2-data/activiti"`, da H2 mit Dateien statt mit Schemata arbeitet), ein Standard-Benutzer wird eingerichtet (`DB_USER: "sa"`) und der Login als dieser Benutzer ohne Password wird erlaubt (`DB_PASS: ""`). Ebenfalls wird der Hostname des DB-Containers mit Port angegeben.

```
    restart: always
```
Der Tag `restart: always` sorgt dafür, dass der Container im Falle eines Fehlers neu startet, statt sich einfach nur zu beenden.
    
```
    networks:
      - moodle-net
```
Um verschiedene Container miteinander reden zu lassen, müssen sich diese im selben Netzwerk befinden. Zu diesem Zweck erlaubt Docker das Erzeugen von virtuellen Netzwerken. In diesem Falle sind alle Container im selben Netz, `moodle-net`.
<br>

```
  activitidb:
    image: zilvinas/h2-dockerfile
    container_name: "swim-activiti-h2"
    restart: always
```
Für die Datenbank wurde ein externes Container-Image für eine simple H2 Datenbank gewählt. 

```
    volumes:
      - "/mnt/swim/h2-activiti:/opt/h2-data"
      - "/mnt/swim/h2-backups:/data"
```
Um die Daten persistent zu halten, werden diese auf das lokale Dateisystem des Hosts gemappt. Diese Pfade vor den Doppelpunkten sind entsprechend der eigenen Konfiguration anzupassen.

```
    networks:
      - moodle-net
```
Um verschiedene Container miteinander reden zu lassen, müssen sich diese im selben Netzwerk befinden. Zu diesem Zweck erlaubt Docker das Erzeugen von virtuellen Netzwerken. In diesem Falle sind alle Container im selben Netz, `moodle-net`.

```
networks:
  moodle-net:
    external:
      name: moodle_moodle-net
```
Um die Container in einem Netz zu verbinden, muss ein Netzwerk existieren. hier wird das Netzwerk `moodle-net` definiert, dass sich nach außen hin für Container, welche nicht über diese docker-compose Datei definiert wurden, als `moodle_moodle-net` zeigt.

## Starten und Verwalten

Um Moodle und die damit verbundene Datenbank zu starten, wird folgendes Kommando verwendet:
`$ docker-compose -f activiti-compose.yml up -d`  
Dies startet die Einträge in der Datei [`activiti-compose.yml`](docker-compose/activiti-compose.yml) im "detached"-Modus (`-d`), die Container laufen also im Hintergrund.

Um die aktuellen Logs des Apache Webservers in dem Moodle-Container zu sehen, wird folgendes Kommando verwendet:
`$ docker logs -f swim-activiti`
Die Logs des Containers `swim-activiti` werden nun in Echtzeit angezeigt. Um die Logs des Datenbank-Containers zu sehen, wird der Name des Containers in obigem Befehl getauscht gegen `swim-activiti-h2`.

### Backups

Um ein Backup der H2 Datenbank durchzuführen, gibt es ein Skript zur Automatisierung. Weitere Informationen finden sich im [entsprechenden Dokument](docker-compose/H2-Backup/README.md).




*****************

[Next - Chapter 1.5: Nginx als Reverse Proxy](nginx-als-reverse-proxy.md)
  
[Previous - Chapter 1.3: Moodle unter Docker](moodle-unter-docker.md)