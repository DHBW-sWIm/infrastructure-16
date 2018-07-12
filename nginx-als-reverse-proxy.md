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

Für den Reverse Proxy wurde der Webserver Nginx verwendet. Dieser wird der Portierbarkeit halber ebenfalls wieder über Docker betrieben. Im weiteren folgt die Konfiguration von der [`nginx-compose.yml`](docker-compose/nginx-compose.yml) Datei sowie der Nginx-internen Konfiguration für zwei Subdomains ([für Moodle]() und [für Activiti]()) . Diese Konfigurationen werden ausführlich erläutert.

### docker-compose

`version: "2"`
Diese Zeile definiert die Version des docker-compose Files, und legt die Syntax fest. Für weitere Informationen, siehe [Compose file versions and upgrading
](https://docs.docker.com/compose/compose-file/compose-versioning/).

`services:`
Diese Zeile leitet die Konfiguration der zu startenden Container ein.

```
  nginx:
    image: "wonderfall/boring-nginx:latest"
    container_name: swim-nginx
```
Der Container "nginx" wird definiert. Der Tag `image` definiert, welches Docker-Image verwendet werden soll. Sollte das gewählte Image lokal nicht gefunden werden, so lädt Docker es beim Start der Container herunter.  
Der Tag `container_name` definiert, mit welchem Namen der Container gestartet wird. Dieser Name gilt in Docker-internen Netzen als Hostname, und wird auch in allen Management-Tools für Docker verwendet.

```
    ports:
      - "80:8000"
      - "443:4430"
```
Das Portmapping wird definiert. Der Port 80 des Hostsystems wird auf den Port 8000 des Containers gemappt (da in einem Docker-Container kein Dienst auf einem Port unter 2000 laufen darf). Alle Anfragen, die nun auf Port 80 des Hostsystems gehen, werden an den Container durchgereicht, dieser beantwortet die Anfragen und sendet sie auf gleichem Wege zurück.  
Das Gleiche passiert für den Port 443 (genutzt für HTTPS), welcher auf Port 4430 des Containers umgeleitet wird.

```
    volumes:
      - /docker/certs:/certs
      - /mnt/nginx/sites-enabled:/sites-enabled
```
Die TLS-Zertfikate und die Konfigurationsdateien werden eingebunden.  
Die Zertfikate wurden mittels [*Let's Encrypt*](https://letsencrypt.org/) erstellt und sind logischerweise dem eigenen System anzupassen. Zertifikate von *Let's Encrypt* sind kostenlos und leicht zu erzeugen.  

In dem Ordner *sites-enabled* sollten die Konfigurationsdateien [`activiti.conf`](docker-compose/Nginx/activiti.conf) und [`moodle.conf`](docker-compose/Nginx/moodle.conf) liegen. Ohen diese Konfiguration sind die beiden Dienste von außerhalb nicht erreichbar.

```
    networks:
      - moodle-net
```
Um verschiedene Container miteinander reden zu lassen, müssen sich diese im selben Netzwerk befinden. Zu diesem Zweck erlaubt Docker das Erzeugen von virtuellen Netzwerken. In diesem Falle sind alle Container im selben Netz, `moodle-net`.

```
    restart: always
```
Der Tag `restart: always` sorgt dafür, dass der Container im Falle eines Fehlers neu startet, statt sich einfach nur zu beenden.

```
networks:
  moodle-net:
    external:
      name: moodle_moodle-net
```
Um die Container in einem Netz zu verbinden, muss ein Netzwerk existieren. hier wird das Netzwerk `moodle-net` definiert, dass sich nach außen hin für Container, welche nicht über diese docker-compose Datei definiert wurden, als `moodle_moodle-net` zeigt.

### Nginx Konfiguration

Die Konfiguration geht davon aus, dass Nginx auf einem System mit der Domain "myhost.de" läuft. Dies ist in allen der folgenden Konfigurationsdateien anzupassen.

#### Activiti

In der Datei [`activiti.conf`](docker-compose/Nginx/activiti.conf) ist der Transparent Proxy für Activiti definiert:

```
server {
  listen 8000;
  server_name activiti.myhost.de;

  error_log /var/log/nginx/activiti-error.log info;

  root /www;

  location / {
    return 301 https://$host$request_uri;
  }

  location /.well-known/ {}

}
```
Alle Anfragen auf Port 80 des Hosts (und damit auf Port 8000 des Containers) werden automatisch auf die TLS-verschlüsselte Verbindung auf Port 443 des Hosts (und damit auf Port 4430 des Containers) umgeleitet.  
Die einzige Ausnahme bilden hier Anfragen auf den Order `.well-known`, da dieser für das Einrichten von Let's Encrypt Zertfikaten erreichbar sein muss.

```
server {
  listen 4430 ssl spdy http2;
  server_name activiti.myhost.de;

  error_log /var/log/nginx/activiti-error.log info;

  ssl_certificate /certs/fullchain.pem;
  ssl_certificate_key /certs/privkey.pem;

  include /etc/nginx/conf/ssl_params;
  include /etc/nginx/conf/headers_params;

  add_header Strict-Transport-Security "max-age=31536000;";
  client_max_body_size 10000M;

  location / {
    resolver 127.0.0.11 ipv6=off;
    set $upstream_activiti swim-activiti;
    include /etc/nginx/conf/proxy_params;

    proxy_pass http://$upstream_activiti:8080;
  }
}
```
Die Zertfikate werden eingebunden, die vom Container selbst bereitgestellten Standard-Konfigurationen für TLS- und SSL-Verbindungen werden eingebunden, und die maximale Größe der hochladbaren Dateien wird erhöht (in diesem Fall 10GB, was zugegebenermaßen etwas übertrieben sein mag).

Anschließend wird für die Lokation `/`, also für alle Anfragen, definiert, dass diese an den internen Host "swim-activiti" auf Port 8080 weitergegeben werden sollen. Damit ist die Konfiguration des Proxys für Activiti komplett.

#### Moodle

In der Datei [`moodle.conf`](docker-compose/Nginx/moodle.conf) ist der Transparent Proxy für Moodle definiert:

```
server {
  listen 8000;
  server_name moodle.myhost.de;

  root /www;

  location / {
    return 301 https://$host$request_uri;
  }

  location /.well-known/ {}

}
```
Alle Anfragen auf Port 80 des Hosts (und damit auf Port 8000 des Containers) werden automatisch auf die TLS-verschlüsselte Verbindung auf Port 443 des Hosts (und damit auf Port 4430 des Containers) umgeleitet.  
Die einzige Ausnahme bilden hier Anfragen auf den Order `.well-known`, da dieser für das Einrichten von Let's Encrypt Zertfikaten erreichbar sein muss.

```
server {
  listen 4430 ssl spdy http2;
  server_name moodle.myhost.de;

  ssl_certificate /certs/fullchain.pem;
  ssl_certificate_key /certs/privkey.pem;

  include /etc/nginx/conf/ssl_params;
  include /etc/nginx/conf/headers_params;

  add_header Strict-Transport-Security "max-age=31536000;";
  client_max_body_size 10000M;

  location / {
    resolver 127.0.0.11 ipv6=off;
    set $upstream_moodle swim-moodle;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Scheme $scheme;
    proxy_redirect off;
    proxy_pass $scheme://$upstream_moodle;
  }

}
```

Die Zertfikate werden eingebunden, die vom Container selbst bereitgestellten Standard-Konfigurationen für TLS- und SSL-Verbindungen werden eingebunden, und die maximale Größe der hochladbaren Dateien wird erhöht (in diesem Fall 10GB, was zugegebenermaßen etwas übertrieben sein mag).

Anschließend wird für die Lokation `/`, also für alle Anfragen, definiert, dass diese an den internen Host "swim-moodle" auf Port 8080 weitergegeben werden sollen.  
Hierfür werden zusätzliche bestimmte Header gesetzt, um Moodle mitzuteilen, dass es sich hinter einem Proxy befindet und seine Antworten entsprechend anpassen muss. Damit ist die Konfiguration des Proxys für Moodle komplett.

## Starten und Verwalten




*****************

[Next - Chapter 1.6: Starten der Infrastruktur](starten-der-infrastruktur.md)
[Previous - Chapter 1.4: Activiti unter Docker](activiti-unter-docker.md)