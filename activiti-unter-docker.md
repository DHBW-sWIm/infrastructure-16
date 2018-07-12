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

version: '2'
services:
 
  activiti:
    image: lengers/activiti:6.0.0
    container_name: "swim-activiti"
    environment:
      DB_TYPE: "h2"
      DB_HOST: "swim-activiti-h2"
      DB_PORT: 1521
      DB_PASS: ""                                                                         
      DB_USER: "sa"
      DB_NAME: "/opt/h2-data/activiti"
    restart: always
    networks:
      - moodle-net

  activitidb:
    image: zilvinas/h2-dockerfile
    container_name: "swim-activiti-h2"
    restart: always
    volumes:
      - "/mnt/swim/h2-activiti:/opt/h2-data"
      - "/mnt/swim/h2-backups:/data"
    networks:
      - moodle-net


networks:
  moodle-net:
    external:
      name: moodle_moodle-net



## Starten und Verwalten

### Backups

