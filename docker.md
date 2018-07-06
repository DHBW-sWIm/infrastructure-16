# Docker

Dieses Dokument soll einen kurzes Überblick über die Software Docker, Containervirtualisierung und Gründe für den Einsatz eben dieser im sWIm-Projekt geben.

## Was ist Docker?

Docker ist eine Software zum Betrieb von [Containervirtualisierung](https://www.wikiwand.com/de/Containervirtualisierung):

> Containervirtualisierung (auch: Betriebssystem- oder Applikationsvirtualisierung) ist eine Methode, um mehrere Instanzen eines Betriebssystems (als sog. „Gäste“) isoliert voneinander auf einem Hostsystem zu betreiben. Im Gegensatz zur Virtualisierung mittels eines Hypervisors hat Containervirtualisierung zwar einige Einschränkungen in der Art ihrer Gäste, gilt aber als besonders ressourcenschonend.

Anwendungen werden in sogenannten Containern ausgeführt, welche sich der Anwendung gegenüber wie ein separates Betriebssystem präsentieren. Durch elegante Ressourcenverwaltung benötigt ein Container lediglich wenige hundert Megabyte an Arbeitsspeicher, was eine starke Trennung von jeweils einer Anwendung je Container erlaubt.  
S

## Warum überhaupt Docker?

Docker erlaubt nicht nur das unkomplizierte Starten von Diensten und Programmen in immer der gleichen Umgebung, sondern auch die Verknüpfung dieser Dienste mittels virtueller Netze. Dies ermöglicht eine Abtrennung einzelner Container, die somit nur von ausgewählten anderen Containern erreichbar sind.  
Eben

## docker-compose

`docker-compose` ist ein Tool, welches das Starten, Verwalten und Verknüpfen von Docker-Containern erleichtert. Die Container samt ihrer anzuwendenen Parametern und Verknüpfungen zu anderen Containern werden in einer `.yml`-Datei festgehalten und sind so jederzeit reproduzierbar.