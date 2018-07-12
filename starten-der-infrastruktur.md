# Starten der Infrastruktur

Bevor die Infrastruktur gestartet wird, sollte die gesamte Dokumentation aufmerksam gelesen werden. Viele Container referenzieren Dateien, die vorher an eine bestimmte Lokation verschoben werden bzw. deren Speicherort in den Konfigurationsdateien angepasst werden muss.

Speziell handelt es sich für die Container um folgende Dateien:

+ **Nginx:**
  + Zertfikate für TLS
        + Können über Let's Encrypt recht schnell erzeugt werden - dies benötigt im Zweifelsfall den einmaligen Start des Containers mit auskommentierter Konfiguration für Port 443 (Nginx wird beim Start abstürzen, da die Zertifikate fehlen. Sobald Zertfikate angegeben wurden, kann Nginx mit normaler Konfiguration gestartet werden).
 + Die Konfigurationsdateien
       + Diese Dateien sollten in einem Verzeichnis liegen, auf den der Container Zugriff hat. Die Dateiberechtigungen sollten im Zweifel geändert werden.

+ **Moodle:**
  + 
*****************

[Previous - Chapter 1.5: Nginx als Reverse Proxy](nginx-als-reverse-proxy.md)