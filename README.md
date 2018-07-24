# Inhaltsverzeichnis

<!-- TOC -->

- [1. Infrastruktur - Einleitung](README.md)
	- [Übersicht](README.md#übersicht)
	- [Infrastrucutre as Code](README.md#infrastrucutre-as-code)
	- [Verwendete Systeme](README.md#verwendete-systeme)
	- [Start der Infrastrukur](README.md#start-der-infrastrukur)
- [2. Docker](docker.md)
	- [Was ist Docker?](docker.md#was-ist-docker)
	- [Warum überhaupt Docker?](docker.md#warum-überhaupt-docker)
	- [docker-compose](docker.md#docker-compose)
- [3. Moodle unter Docker](moodle-unter-docker.md)
    - [Das Container-Image](moodle-unter-docker.md#das-container-image)
    - [Konfiguration](moodle-unter-docker.md#konfiguration)
        - [docker-compose Datei](moodle-unter-docker.md#docker-compose-datei)
        - [config.php](moodle-unter-docker.md#configphp)
    - [Starten und Verwalten](moodle-unter-docker.md#starten-und-verwalten)
- [4. Activiti unter Docker](activiti-unter-docker.md)
     - [Das Container-Image](activiti-unter-docker.md#das-container-image)
     	- [Dockerfile](activiti-unter-docker.md#dockerfile)
     - [Konfiguration](activiti-unter-docker.md#konfiguration)
     	- [docker-compose Datei](activiti-unter-docker.md#docker-compose-datei)
     - [Starten und Verwalten](activiti-unter-docker.md#starten-und-verwalten)
     	- [Backups](activiti-unter-docker.md#backups)
- [5. Nginx als Reverse Proxy](nginx-als-reverse-proxy.md)
	- [Was ist ein Reverse Transparent Proxy?](nginx-als-reverse-proxy.md#was-ist-ein-reverse-transparent-proxy)
	- [Warum ein Reverse Transparent Proxy?](nginx-als-reverse-proxy.md#warum-ein-reverse-transparent-proxy)
	- [Konfiguration](nginx-als-reverse-proxy.md#konfiguration)
		- [docker-compose](nginx-als-reverse-proxy.md#docker-compose)
		- [Nginx Konfiguration](nginx-als-reverse-proxy.md#nginx-konfiguration)
			- [Activiti](nginx-als-reverse-proxy.md#activiti)
			- [Moodle](nginx-als-reverse-proxy.md#moodle)
	- [Starten und Verwalten](nginx-als-reverse-proxy.md#starten-und-verwalten)
- [6. Starten der Infrastruktur](starten-der-infrastruktur.md)
	- [Klonen](starten-der-infrastruktur.md#klonen)
	- [Dateien anpassen bzw. verschieben](starten-der-infrastruktur.md#dateien-anpassen-bzw-verschieben)
	- [Finaler Start](starten-der-infrastruktur.md#finaler-start)
	- [Debugging beim Start](starten-der-infrastruktur.md#debugging-beim-start)
<!-- /TOC -->

# Infrastruktur

Dieser Text soll einen Überblick über die Infrastruktur für das sWIm-Projekt des Jahrganges WWI-15-SCB geben. Ziel des Projektes war es, die Lern-Plattform Moodle an der DHBW um Funktionen zu erweitern.  
Alle verwendeten Dienste, Software oder anderweitige Angebote werden in diesem Rahmen entweder in einer Ausführlichkeit, die für den Betrieb und die Wartung der Infrastrukur nötig ist, erläutert und erklärt, oder eine Referenz auf die exakte Quelle wird angegeben.

## Übersicht

Für ein grundsätzliches Verständnis der Infrastruktur ist es notwendig, die verwendeten Dienste des Projektes zu kennen. 

Der Name des Projektes legt nahe, dass die Lern-Plattform **Moodle** beteiligt ist. Hierbei handelt es sich um eine in PHP geschriebene Webanwendung, welche einer Schule, Hochschule oder Universität die Verwaltung von Stundenten und Kursen ermöglicht und für die Studenten eine Möglichkeit bietet, mit den Dozenten im Austausch zu stehen. Kalenderverwaltung, Teilen von Dateien und Foren gehören zu den bekanntesten Funktionen. Moodle lässt sich durch Plugins in seiner Funktionalität nahezu beliebig erweitern, sofern man sich als Entwickler an die Vorgaben für Versionierung und Resourcen-Zugriff hält.

Um die Daten aller Studenten, Dozenten und Resourcen persistent zu halten, benötigt Moodle eine **Datenbank**. Hierbei ist laut [Dokumentation](https://docs.moodle.org/20/en/Create\_Moodle\_site\_database) dem Betreiber die freie Wahl zwischen *MySQL*, *MariaDB*, *PostgreSQL*, *MS SQL* und *OracleDB* gelassen. Aus gründen der Einfachheit, und zur Vermeidung später eventuell anfallender Lizenzkosten, wurde sich für eine **MariaDB** entschieden.

Um Prozesse innerhalb des Universitätslebens einfacher abbilden und durchführen zu können, wurde beschlossen, das Konzept eines **Business Process Management** Systems vom Vorjahr zu übernehmen. Zwar verwendete der Kurs des Vorjahres an dieser Stelle die Software [jBPM](https://www.jbpm.org/), eine kurze Einarbeitungsphase in dieses Tool durch einige Kursteilnehmer zeigte jedoch rasch, dass die Bedienung dieses Tools eine längere Einarbeitungszeit gebraucht hätte und mit "nicht intuitiv" von den Testern höflich als für dieses Projekt ungeeignet abgelehnt wurde. Eine Evaluierung anderer Optionen resultierte in der gemeinsamen Entschidung für [**Activiti**](https://www.activiti.org/). 

Auch Activiti benötigt für die Persistenz von Prozessen eine Datenbank. Hierfür wurde eine **H2** Datenbank verwendet. Die genaueren Gründe für diese Entscheidung finden sich in [Kapitel 4](activiti-unter-docker.md).

## Infrastrucutre as Code

Um eine leichte Migration auf andere Systeme, eine potentielle Skalierung oder eine Rekonfiguration zu erleichtern, wurde sich entschieden, die gesamte Infrastruktur des Projektes in Code festzuhalten.

Die Verwendung von [Docker](docker.md) als Betriebsplattform für alle Dienste des Projektes macht die Infrastruktur unabhängig von dem Betreiber der Systeme, auf der sie läuft, und erlaubt einen schnellen Umzug. Mehr dazu in [Kapitel 2](docker.md).

Hauptsächlich bedeutet dieses Setup für einen neuen Administrator, dass die Infrastruktur in sich selbst dokumentiert ist, da die verwendeten Docker-Container grundlegend eigene Dokumentation zu ihren Möglichkeiten und Konfigurationsoptionen bieten, und Aktualisierungen schnell und unkompliziert durchzuführen sind.

## Verwendete Systeme

Während des Projektes wurde die gesamte Infrastruktur auf privater Hardware gehostet. Dies lag an mehreren Gründen, die wie folgt erläutert sind:

+ **Einfachheit:** Im Umfeld des Kurses gab es bereits Server-Hardware, welche mit (für einen Heimserver überragender) Ausfallsicherheit durch RAID 5 und bereits installiertem, getestetem und produktiv genutztem Docker überzeugte. Das Starten erster Container für erste Test war auf diesem System deutlich schneller, als sich über die DHBW zunächst Zugriff auf Systeme zu besorgen und diese anschließend einzurichten.
Da es bis auf die in den Datenbanken abgelegten Daten quasi keine persistent zu haltenen Daten gab, war die Sorge bezüglich der Übergabe an folgende Kurse gering.

+ **Erreichbarkeit:** Zum Testen und Entwickeln von Plugins für Moodle und für Tests der Prozesse für Activiti ist ein Zugriff auf die Webinterfaces dieser beiden Dienste nötig. Systeme innerhalb des DHBW-Systems sind lediglich über einen VPn erreichbar. Für diesen VPN sind Studenten jedoch standardmäßig nicht zugelassen. Eine Zulassung der Studenten eines Kurses kann unter Umständen länger dauern. Zugriff auf Seiten durch diesen VPN ist dazu umständlicher und kann bei weniger technischen Projektmitgliedern zu Frustration führen.
Der verwendete Server war bereits über einen Hostnamen mit gültigem TLS-Zertifikat aus dem Internet erreichbar. Für dieses Projekt wurden lediglich zwei Subdomaisn hinzugefügt und die Dienste intern weitergeleitet. Für weitere Informationen zu diesem Setup, siehe [Kapitel 5](nginx-als-reverse-proxy.md).

## Start der Infrastrukur

Für eine kompakte Anleitung zum Start der Infrastruktur, siehe [Kapitel 6](starten-der-infrastruktur.md)

*****************

[Next - Chapter 2: Docker](docker.md)