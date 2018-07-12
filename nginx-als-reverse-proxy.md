# Nginx als Reverse Proxy

Nginx stellt die Schnittstelle zwischen den Diensten der Infrastruktur und dem Netzwerk, in welchem sie verfügbar gemacht werden sollen, dar. Dieses Netzwerk kann ein internes Netz sein, im Falle dieser Implementierung waren die Dienste über das Internet erreichbar. 

## Was ist ein Reverse Transparent Proxy?

![Reverse Proxy](/ https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Reverse_proxy_h2g2bob.svg/640px-Reverse_proxy_h2g2bob.svg.png?1531407567259)

> Der Reverse Proxy holt Ressourcen für einen Client von einem oder mehreren Servern. Die Umsetzung der Adresse ist atypisch und der Richtung des Aufrufes entgegengesetzt (deutsch „umgekehrter Proxy“). Die wahre Adresse des Zielsystems bleibt dem Client verborgen. ([Quelle](https://www.wikiwand.com/de/Reverse_Proxy))

Kurz gesagt bemerkt der User nicht, mit welchem System er interagiert, da sich alle durch den Reverse Proxy als ein System darstellen. Da der User dies in keiner Weise erkennen kann, ist der Vorgang transparent.

## Warum ein Reverse Transparent Proxy?

Der Einfachheit halber sollten Webserver auf den Ports 80 und 443 erreichbar sein, da dies die Standardports für Web-Traffic sind.  
Generell darf aber nur ein Dienst auf einmal auf einem Port aktiv sein. Da mehrere Container als mehrere Dienste gelten, kann maximal ein Container Anfragen auf diesen Ports beantworten. Um eine einfache Benutzung zu gewährleisten, kann nun ein Reverse Proxy Anfragen annehmen und, je nach Anfrage, an den entsprechenden Dienst weiterleiten.
Für den User prästentieren sich so sowohl Moodle als auch Activiti im Browser über die simple Eingabe der entsprechenden URL. 

## Konfiguration

Für den Reverse Proxy wurde der Webserver Nginx verwendet. Dieser wird der Portierbarkeit halber ebenfalls wieder über Docker betrieben. Im weiteren folgt die Konfiguration von der [`nginx-compose.yml`]() Datei sowie der Nginx-internen Konfiguration für zwei Subdomains ([für Moodle]() und [für Activiti]()) . Diese Konfigurationen werden ausführlich erläutert.

### docker-compose

### Nginx Konfiguration

## Starten und Verwalten




*****************

[Next - Chapter 1.6: Starten der Infrastruktur](starten-der-infrastruktur.md)
[Previous - Chapter 1.4: Activiti unter Docker](activiti-unter-docker.md)