# Activiti unter Docker


## Das Container-Image

Activiti stellt zwar eine Sammlung von Container bereit, für den Start einer einzelnen Instanz wären jedoch mindestens 5 Container mit umfassender Konfiguration nötig gewesen, welche ausschließlich für Entwicklungszwecke gedacht sind.  
Die von der Community entwickelten Images beruhen meist auf der Activiti-Version 5.8.x. Nach ausführlichen Tests stellte sich heraus, dass in dieser Version und allen getesteten Images mit dieser Version die REST API nicht voll funktionstüchtig war:  
Neu instanziierte Prozesse waren über die API nicht abrufbar. Damit waren diese Images für den Einsatz im Projektumfeld ungeeignet.

Ein eigenes Image mit Activiti 6.0 wurde erstellt. Der Prozess der Containererzeugung ist im Folgenden dokumentiert, um ein Upgrade auf höhere Versionen zu ermöglichen.

### Dockerfile


## Konfiguration

### docker-compose Datei

## Starten und Verwalten

