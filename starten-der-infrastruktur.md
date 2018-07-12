# Starten der Infrastruktur

Bevor die Infrastruktur gestartet wird, sollte die gesamte Dokumentation aufmerksam gelesen werden. Viele Container referenzieren Dateien, die vorher an eine bestimmte Lokation verschoben werden bzw. deren Speicherort in den Konfigurationsdateien angepasst werden muss.

## Klonen

Um die Konfiguration einfach und schnell auf ein System zu bekommen, empfiehlt es sich, das Repository mittels Git zu klonen:

```bash
git clone https://github.com/DHBW-sWIm/Infrastruktur
```

## Dateien anpassen bzw. verschieben

Wie bereits erwähnt, müssen manche Dateien vor der Inbetriebnahme der Infrastruktur verschoben oder neu erzeugt werden. Speziell handelt es sich für die Container um folgende Dateien:

+ **Nginx:**
  + Zertfikate für TLS
        + Können über Let's Encrypt recht schnell erzeugt werden - dies benötigt im Zweifelsfall den einmaligen Start des Containers mit auskommentierter Konfiguration für Port 443 (Nginx wird beim Start abstürzen, da die Zertifikate fehlen. Sobald Zertfikate angegeben wurden, kann Nginx mit normaler Konfiguration gestartet werden).
 + Die Konfigurationsdateien
       + Diese Dateien sollten in einem Verzeichnis liegen, auf den der Container Zugriff hat. Die Dateiberechtigungen sollten im Zweifel geändert werden.

+ **Activiti:**
  + Die Verzeichnisse für die Datenbank sollten angepasst werden. Werden beim Start des Containers leere Ordner übergeben, so wird die H2 Datenbank in diese Ordner schreiben. Sollte bereits eine Datenbank in diesem Ordner liegen und der Name jenem in der Konfiguration entsprechen, so wird diese Datenbank verwendet.
  
## Finaler Start

Die Container sollten alle in einer gewissen Reihenfolge gestartet werden. Es empfiehlt sich, zunächst die Dienste Moodle und Activiti zu starten, und anschließend Nginx als Reverse Proxy hochzufahren. So ist gewährleistet, dass Nginx die Dienste tatsächlich erreichen kann.

Um Moodle und die damit verbundene Datenbank zu starten, wird folgendes Kommando verwendet:
`$ docker-compose -f moodle-compose.yml up -d`

Um Moodle und die damit verbundene Datenbank zu starten, wird folgendes Kommando verwendet:
`$ docker-compose -f activiti-compose.yml up -d`  

Um Nginx zu starten, wird folgendes Kommando verwendet:
`$ docker-compose -f nginx-compose.yml up -d`

Dies startet die Einträge in den entsprechenden Dateien im "detached"-Modus (`-d`), die Container laufen also im Hintergrund.
<br>
*Anschließend sollte die Infrastruktur voll lauffähig und unter dem eingetragenen Domainnamen erreichbar sein.*
<br>

## Debugging beim Start

Sollten Dienste nicht erreichbar sein, empfiehlt es sich, mittels `docker logs -f $CONTAINERNAME` die Logs der betroffenen Container während einer solchen Anfrage zu beobachten. Meist lässt sich so schnell nachvollziehen, wo die Ursache eines Problems liegt.

 Im Zweifel sind die beiden Freunde eines jeden Administrators, Google und StackOverflow, gute Hilfen, um Fehlermeldungen auf den Grund zu gehen.  




*****************

[Previous - Chapter 1.5: Nginx als Reverse Proxy](nginx-als-reverse-proxy.md)