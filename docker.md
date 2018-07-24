# Docker

Dieses Dokument soll einen kurzes Überblick über die Software Docker, Containervirtualisierung und Gründe für den Einsatz eben dieser im sWIm-Projekt geben.

## Was ist Docker?

Docker ist eine Software zum Betrieb von [Containervirtualisierung](https://www.wikiwand.com/de/Containervirtualisierung):

> Containervirtualisierung (auch: Betriebssystem- oder Applikationsvirtualisierung) ist eine Methode, um mehrere Instanzen eines Betriebssystems (als sog. „Gäste“) isoliert voneinander auf einem Hostsystem zu betreiben. Im Gegensatz zur Virtualisierung mittels eines Hypervisors hat Containervirtualisierung zwar einige Einschränkungen in der Art ihrer Gäste, gilt aber als besonders ressourcenschonend.

Anwendungen werden in sogenannten Containern ausgeführt, welche sich der Anwendung gegenüber wie ein separates Betriebssystem präsentieren. Durch elegante Ressourcenverwaltung benötigt ein Container lediglich wenige hundert Megabyte an Arbeitsspeicher, was eine starke Trennung von jeweils einer Anwendung je Container erlaubt.  
Somit eignet sich Docker deutlich besser als virtuelle Maschinen, welche für die gleiche Arbeit mehr Ressourcen verbrauchen würden. Dies senkt die Anforderungen des Projektes.

Ebenfalls nicht zu unterschätzen ist die Tatsache, dass die Konfiguration eines Docker-Containers einfach festgehalten und jederzeit wieder verwendet werden kann. Dadurch ist jeder Container eines Images stets gleich, und Anwendungen laufen in diesen Containern stabil und vorhersehbar.

## Warum überhaupt Docker?

Docker erlaubt nicht nur das unkomplizierte Starten von Diensten und Programmen in immer der gleichen Umgebung, sondern auch die Verknüpfung dieser Dienste mittels virtueller Netze. Dies ermöglicht eine Abtrennung einzelner Container, die somit nur von ausgewählten anderen Containern erreichbar sind.  
Ebenfalls erlaubt Docker die Skalierung von Diensten. Sollte der Bedarf bestehen, während der Entwicklungsphase je eine Moodle-Instanz pro zu entwickelndem Plugin zu betreiben, ist dies mit Docker problemlos, mit geringem Administrationsaufwand und ohne Unterschiede zwischen den Instanzen möglich.

## docker-compose

`docker-compose` ist ein Tool, welches das Starten, Verwalten und Verknüpfen von Docker-Containern erleichtert. Die Container samt ihrer anzuwendenen Parametern und Verknüpfungen zu anderen Containern werden in einer `.yml`-Datei festgehalten und sind so jederzeit reproduzierbar.


*****************

[Next - Chapter 3: Moodle unter Docker](moodle-unter-docker.md)
  
[Previous - Chapter 1: Einleitung](README.md)